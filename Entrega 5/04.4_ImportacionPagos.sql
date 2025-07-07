/*
    Consigna: Importar pagos de cuotas desde un archivo CSV  
    Fecha de entrega: 08/07/2025
    Número de comisión: 2900
    Número de grupo: 11
    Nombre de la materia: Bases de Datos Aplicadas
    Integrantes:
        - Costanzo, Marcos Ezequiel - 40955907
        - Sanchez, Diego Mauricio - 46361081
*/

USE Com2900G11;
GO

-- Habilitamos las consulta Ad Hoc para importar los datos de excel
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
go

CREATE OR ALTER PROCEDURE socio.importarPagosCuotasDesdeArchivo
    @arch VARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    -- Tabla temporal para importar el CSV
    IF OBJECT_ID('tempdb..##pagos_cuotas') IS NOT NULL
        DROP TABLE ##pagos_cuotas;

    CREATE TABLE ##pagos_cuotas (
        id_pago_externo VARCHAR(50),      -- Id de pago del CSV, solo referencia
        fecha VARCHAR(20),
        nro_socio_rp VARCHAR(20),
        valor DECIMAL(18,2),
        medio_pago VARCHAR(50)
    );

    -- Tabla temporal para datos limpios
    IF OBJECT_ID('tempdb..#procesar') IS NOT NULL
        DROP TABLE #procesar;

    CREATE TABLE #procesar (
        RowNum INT IDENTITY(1,1),
        id_pago_externo VARCHAR(50),
        fecha DATE,
        nro_socio_rp VARCHAR(20),
        valor DECIMAL(18,2),
        medio_pago VARCHAR(50)
    );

    DECLARE @script NVARCHAR(MAX);
    DECLARE @current_row INT = 1, @max_row INT;

    -- Importar el CSV
    SET @script = N'
    BULK INSERT ##pagos_cuotas
    FROM ''' + @arch + '''
    WITH (
        FIELDTERMINATOR ='';'',
        ROWTERMINATOR = ''\n'',
        CODEPAGE = ''65001'',
        FIRSTROW = 2
    )';
    EXEC sp_executesql @script;

    -- Eliminar filas con datos incompletos y aplicar TRIM
    DELETE FROM ##pagos_cuotas
    WHERE id_pago_externo IS NULL OR LTRIM(RTRIM(id_pago_externo)) = ''
       OR fecha IS NULL OR LTRIM(RTRIM(fecha)) = ''
       OR nro_socio_rp IS NULL OR LTRIM(RTRIM(nro_socio_rp)) = ''
       OR valor IS NULL;

    -- Preparar datos limpios para procesar
    INSERT INTO #procesar (id_pago_externo, fecha, nro_socio_rp, valor, medio_pago)
    SELECT 
        LTRIM(RTRIM(pc.id_pago_externo)),
        TRY_PARSE(pc.fecha AS date USING 'es-AR'),
        LTRIM(RTRIM(pc.nro_socio_rp)),
        pc.valor,
        LTRIM(RTRIM(pc.medio_pago))
    FROM ##pagos_cuotas pc;

    -- Procesar registros
    SELECT @max_row = MAX(RowNum) FROM #procesar;

    WHILE @current_row <= @max_row
    BEGIN
        DECLARE @id_pago_externo VARCHAR(50), @fecha DATE, @nro_socio_rp VARCHAR(20), @valor DECIMAL(18,2), @medio_pago VARCHAR(50),
                @id_socio INT, @id_categoria INT, @periodo VARCHAR(7), @id_cuota INT, @id_factura INT, @mes INT, @anio INT;
                
        -- Obtener datos de la fila
        SELECT 
            @id_pago_externo = id_pago_externo,
            @fecha = fecha,
            @nro_socio_rp = nro_socio_rp,
            @valor = valor,
            @medio_pago = medio_pago
        FROM #procesar
        WHERE RowNum = @current_row;

        -- Buscar socio
        SELECT @id_socio = id FROM socio.socio WHERE nro_socio = @nro_socio_rp;

        -- Buscar la fecha de nacimiento del socio
        DECLARE @fecha_nacimiento DATE;
        SELECT @fecha_nacimiento = fecha_nacimiento FROM socio.socio WHERE id = @id_socio;

        -- Buscar la categoría correspondiente según la edad
        DECLARE @edad INT;
        SET @edad = DATEDIFF(YEAR, @fecha_nacimiento, @fecha) - 
                    CASE WHEN (MONTH(@fecha) < MONTH(@fecha_nacimiento)) OR 
                              (MONTH(@fecha) = MONTH(@fecha_nacimiento) AND DAY(@fecha) < DAY(@fecha_nacimiento)) 
                         THEN 1 ELSE 0 END;

        SELECT TOP 1 @id_categoria = id
        FROM socio.categoria
        WHERE @edad BETWEEN edad_min AND edad_max;

        -- Determinar mes y año de la cuota
        SET @mes = MONTH(@fecha);
        SET @anio = YEAR(@fecha);

        -- Buscar o crear cuota
        SET @id_cuota = NULL;
        SELECT @id_cuota = id FROM socio.cuota
        WHERE id_socio = @id_socio AND mes = @mes AND anio = @anio;

        IF @id_cuota IS NULL
        BEGIN
            -- Obtener costo de la cuota según categoría
            DECLARE @costo DECIMAL(8,2);
            SELECT @costo = costo_mensual FROM socio.categoria WHERE id = @id_categoria;

            -- Insertar cuota
            INSERT INTO socio.cuota(id_socio, id_categoria, mes, anio, monto_total)
            VALUES(@id_socio, @id_categoria, @mes, @anio, @costo);
            SET @id_cuota = SCOPE_IDENTITY();
        END

        -- Generar valores automáticamente
        declare @numero_comprobante int;
        declare @tipo_comprobante varchar(2) = 'B';
        declare @periodo_facturado int = @anio * 100 + @mes;
        declare @iva varchar(50) = '21%';
        declare @fecha_vencimiento_1 date = dateadd(day, 30, @fecha);
        declare @fecha_vencimiento_2 date = dateadd(day, 40, @fecha);
        declare @descripcion varchar(100) = 'Factura por cuota mensual (datos importados)';

        -- Generar número de comprobante automáticamente
        select @numero_comprobante = isnull(max(numero_comprobante), 0) + 1 from socio.factura_cuota;

        -- Buscar o crear factura
        SET @id_factura = NULL;
        SELECT @id_factura = id FROM socio.factura_cuota
        WHERE id_cuota = @id_cuota;

        IF @id_factura IS NULL
        BEGIN
            -- Insertar factura
            INSERT INTO socio.factura_cuota(
                numero_comprobante, tipo_comprobante, fecha_emision, periodo_facturado, iva,    
                fecha_vencimiento_1, fecha_vencimiento_2, importe_total, descripcion, id_cuota
            )
            VALUES(
                @numero_comprobante, @tipo_comprobante, @fecha, @periodo_facturado, @iva,
                @fecha_vencimiento_1, @fecha_vencimiento_2, @valor, @descripcion, @id_cuota
            );
            SET @id_factura = SCOPE_IDENTITY();
        END

        -- Tomamos "Efectivo" como "Rapipago" ya que el sistema no acepta "Efectivo"
        IF @medio_pago = 'Efectivo'
            SET @medio_pago = 'Rapipago';

        -- Insertar el item de la factura
        INSERT INTO socio.item_factura_cuota (
            id_factura_cuota, cantidad, precio_unitario, alicuota_iva, tipo_item, subtotal, importe_total
        )
        VALUES(@id_factura, 1, @valor, 21, 'Cuota', @valor, @valor);

        -- Insertar el pago
        INSERT INTO socio.pago(
            fecha_pago, monto, medio_de_pago, es_debito_automatico, 
            id_factura_cuota, id_factura_extra, id_pago_externo
        )
        VALUES(@fecha, @valor, @medio_pago, 0, @id_factura, NULL, @id_pago_externo);

        SET @current_row = @current_row + 1;
    END

    -- Eliminar tablas temporales
    DROP TABLE ##pagos_cuotas;
    DROP TABLE #procesar;
END
GO