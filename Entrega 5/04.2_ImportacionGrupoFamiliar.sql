/*
    Consigna: Importar grupo familiar desde un archivo CSV  
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

CREATE OR ALTER PROCEDURE socio.importarGrupoFamiliarDesdeArchivo
    @arch VARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..##grupo_familiar') IS NOT NULL
        DROP TABLE ##grupo_familiar;

    CREATE TABLE ##grupo_familiar
    (
        id_socio VARCHAR(20),
        id_socio_rp VARCHAR(20),
        nombre VARCHAR(100),
        apellido VARCHAR(100),
        dni INT,
        email VARCHAR(150),
        fnac VARCHAR(100),
        tel VARCHAR(100),
        tel_em VARCHAR(100),
        os_nombre VARCHAR(150),
        os_nro VARCHAR(50),
        os_tel VARCHAR(50)
    );

    -- Tabla temporal para datos limpios
    IF OBJECT_ID('tempdb..#procesar') IS NOT NULL
        DROP TABLE #procesar;

	CREATE TABLE #procesar
    (
        RowNum INT IDENTITY(1,1),
        id_socio VARCHAR(20),
        id_socio_rp VARCHAR(20),
        nombre VARCHAR(100),
        apellido VARCHAR(100),
        dni INT,
        email VARCHAR(150),
        fnac DATE,
        tel VARCHAR(100),
        tel_em VARCHAR(100),
        os_nombre VARCHAR(150),
        os_nro VARCHAR(50),
        os_tel VARCHAR(50)
    );

    DECLARE @script NVARCHAR(MAX);
    DECLARE @current_row INT = 1, @max_row INT;

    -- Importar datos
    SET @script = N'
    BULK INSERT ##grupo_familiar
    FROM ''' + @arch + '''
    WITH
    (
        fieldterminator ='';'',
        rowterminator = ''\n'',
        codepage = ''ACP'',
        FIRSTROW = 2
    )';
    
    EXEC sp_executesql @script;

    -- Eliminar filas con datos incompletos y aplicar TRIM
    DELETE FROM ##grupo_familiar
    WHERE id_socio_rp IS NULL OR LTRIM(RTRIM(id_socio_rp)) = ''
       OR nombre IS NULL OR LTRIM(RTRIM(nombre)) = ''
       OR apellido IS NULL OR LTRIM(RTRIM(apellido)) = ''
       OR dni IS NULL;

	-- Preparar datos limpios para procesar
    INSERT INTO #procesar (id_socio, id_socio_rp, nombre, apellido, dni, email, fnac, tel, tel_em, os_nombre, os_nro, os_tel)
    SELECT 
        LTRIM(RTRIM(gf.id_socio)),
        LTRIM(RTRIM(gf.id_socio_rp)),
        LTRIM(RTRIM(gf.nombre)),
        LTRIM(RTRIM(gf.apellido)),
        gf.dni,
        LTRIM(RTRIM(gf.email)),
        TRY_PARSE(gf.fnac AS date USING 'es-AR'),
        LTRIM(RTRIM(gf.tel)),
        LTRIM(RTRIM(gf.tel_em)),
        LTRIM(RTRIM(gf.os_nombre)),
        LTRIM(RTRIM(gf.os_nro)),
        LTRIM(RTRIM(gf.os_tel))
    FROM ##grupo_familiar gf
    LEFT JOIN socio.socio s ON s.nro_socio = LTRIM(RTRIM(gf.id_socio_rp))
    WHERE s.id IS NOT NULL;

    -- Procesar registros
    SELECT @max_row = MAX(RowNum) FROM #procesar;

    WHILE @current_row <= @max_row
    BEGIN
        DECLARE @nombre VARCHAR(100), @apellido VARCHAR(100), @dni INT, @email VARCHAR(150), 
                @fecha DATE, @tel VARCHAR(100), @tel_em VARCHAR(100), @os_nombre VARCHAR(150), 
                @os_nro VARCHAR(50), @os_tel VARCHAR(50), @id_os INT, 
                @nro_socio VARCHAR(20), @nro_socio_rp VARCHAR(20), @id_grupo_familiar INT;
        
        -- Obtener datos limpios
        SELECT 
            @nro_socio = id_socio,
            @nro_socio_rp = id_socio_rp,
            @nombre = nombre,
            @apellido = apellido,
            @dni = dni,
            @email = email,
            @fecha = fnac,
            @tel = tel,
            @tel_em = tel_em,
            @os_nombre = os_nombre,
            @os_nro = os_nro,
            @os_tel = os_tel
        FROM #procesar
        WHERE RowNum = @current_row;
        
        -- Insertar obra social si hay datos
        SET @id_os = NULL;
        IF @os_nombre IS NOT NULL AND @os_nombre <> ''
        BEGIN
            INSERT INTO obra_social_socio(nombre, telefono_emergencia, numero_socio)
            VALUES(@os_nombre, @os_tel, @os_nro);
            SET @id_os = SCOPE_IDENTITY();
        END

		-- Buscamos el id del socio responsable de pago
		select @id_grupo_familiar = id from socio.socio where nro_socio = @nro_socio_rp;
        
        -- Insertar socio
        IF @nro_socio_rp IS NOT NULL
        BEGIN
            EXEC socio.altaSocio
                @nro_socio = @nro_socio,
                @nombre = @nombre,
                @apellido = @apellido,
                @dni = @dni,
                @email = @email,
                @fecha_nacimiento = @fecha,
                @telefono = @tel,
                @telefono_emergencia = @tel_em,
                @id_obra_social_socio = @id_os,
                @id_tutor = NULL,
                @id_grupo_familiar = @id_grupo_familiar,
                @responsable_pago = 0,
                @estado = 'Activo',
                @importacion = 1;
        END
        
        SET @current_row = @current_row + 1;
    END
    
    -- Eliminar tablas temporales
    DROP TABLE ##grupo_familiar;
    DROP TABLE #procesar;
END
GO
