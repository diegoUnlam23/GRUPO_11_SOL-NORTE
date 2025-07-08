/*
    Consigna: Importar presentismo desde un archivo CSV  
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

CREATE OR ALTER PROCEDURE socio.importarPresentismoDesdeArchivo
    @arch VARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..##presentismo') IS NOT NULL
        DROP TABLE ##presentismo;

    CREATE TABLE ##presentismo
    (
        nro_socio VARCHAR(20),
        actividad VARCHAR(100),
        fecha_asistencia VARCHAR(20),
        asistencia VARCHAR(5),
        profesor VARCHAR(100)
    );

    -- Tabla temporal para datos limpios
    IF OBJECT_ID('tempdb..#procesar') IS NOT NULL
        DROP TABLE #procesar;

    CREATE TABLE #procesar
    (
        RowNum INT IDENTITY(1,1),
        nro_socio VARCHAR(20),
        actividad VARCHAR(100),
        fecha_asistencia DATE,
        asistencia VARCHAR(5),
        profesor VARCHAR(100)
    );

    DECLARE @script NVARCHAR(MAX);
    DECLARE @current_row INT = 1, @max_row INT;

    -- Importar datos
    SET @script = N'
    BULK INSERT ##presentismo
    FROM ''' + @arch + '''
		WITH
		(
			fieldterminator ='';'',
			rowterminator = ''\n'',
			CODEPAGE = ''65001'',
			FIRSTROW = 2
		)'

	EXEC sp_executesql @script;

    -- Eliminar filas con datos incompletos y aplicar TRIM
    DELETE FROM ##presentismo
    WHERE nro_socio IS NULL OR LTRIM(RTRIM(nro_socio)) = ''
       OR actividad IS NULL OR LTRIM(RTRIM(actividad)) = ''
       OR fecha_asistencia IS NULL OR LTRIM(RTRIM(fecha_asistencia)) = ''
       OR asistencia IS NULL OR LTRIM(RTRIM(asistencia)) = ''
       OR profesor IS NULL OR LTRIM(RTRIM(profesor)) = '';

	-- Preparar datos limpios para procesar
    INSERT INTO #procesar (nro_socio, actividad, fecha_asistencia, asistencia, profesor)
    SELECT 
        LTRIM(RTRIM(p.nro_socio)),
        LTRIM(RTRIM(p.actividad)),
        TRY_PARSE(p.fecha_asistencia AS date USING 'es-AR'),
        LTRIM(RTRIM(p.asistencia)),
        LTRIM(RTRIM(p.profesor))
    FROM ##presentismo p;

	-- Procesar registros
    SELECT @max_row = MAX(RowNum) FROM #procesar;
	
	WHILE @current_row <= @max_row
	BEGIN
		DECLARE @nro_socio VARCHAR(20), @actividad VARCHAR(100), @fecha_asistencia DATE, @asistencia VARCHAR(5), @profesor VARCHAR(100),
			@id_empleado INT, @id_actividad INT, @id_socio INT, @fecha_nac DATE, @id_categoria INT, @dia_semana VARCHAR(20), @id_clase INT, @edad INT;

		-- Obtener datos limpios
		SELECT 
			@nro_socio = nro_socio,
			@actividad = actividad,
			@fecha_asistencia = fecha_asistencia,
			@asistencia = asistencia,
			@profesor = profesor
		FROM #procesar
		WHERE RowNum = @current_row;

		-- Insertar profesor en general.empleado si no existe
		IF NOT EXISTS (SELECT 1 FROM general.empleado WHERE nombre = @profesor)
		BEGIN
			INSERT INTO general.empleado(nombre) VALUES(@profesor);
			SET @id_empleado = SCOPE_IDENTITY();
		END
		ELSE
			SELECT @id_empleado = id FROM general.empleado WHERE nombre = @profesor;

		-- Buscar id de la actividad
		SELECT @id_actividad = id FROM general.actividad WHERE nombre = @actividad;

		-- Buscar id del socio y su fecha de nacimiento
		SELECT @id_socio = id, @fecha_nac = fecha_nacimiento FROM socio.socio WHERE nro_socio = @nro_socio;

		-- Calcular la edad del socio en la fecha de asistencia
		SET @edad = DATEDIFF(year, @fecha_nac, @fecha_asistencia)
			   - CASE WHEN DATEADD(year, DATEDIFF(year, @fecha_nac, @fecha_asistencia), @fecha_nac) > @fecha_asistencia THEN 1 ELSE 0 END;

		-- Buscar la categoría correspondiente
		SELECT @id_categoria = id FROM socio.categoria WHERE @edad BETWEEN edad_min AND edad_max;

		SET DATEFIRST 1;
		-- Mapear el día de la semana a los valores válidos
		SET @dia_semana = 
			CASE DATEPART(weekday, @fecha_asistencia)
				WHEN 1 THEN 'Lunes'
				WHEN 2 THEN 'Martes'
				WHEN 3 THEN 'Miércoles'
				WHEN 4 THEN 'Jueves'
				WHEN 5 THEN 'Viernes'
				WHEN 6 THEN 'Sábado'
				WHEN 7 THEN 'Domingo'
			END;

		-- Buscar si ya existe la clase
		SET @id_clase = NULL;
		SELECT @id_clase = id FROM general.clase
		WHERE id_actividad = @id_actividad
		  AND id_empleado = @id_empleado
		  AND dia = @dia_semana
		  AND id_categoria = @id_categoria;

		-- Si la clase no existe, crearla
		IF @id_clase IS NULL
		BEGIN
			INSERT INTO general.clase(id_actividad, id_empleado, dia, hora_inicio, hora_fin, id_categoria)
			VALUES(@id_actividad, @id_empleado, @dia_semana, '00:00', '00:00', @id_categoria);
			SET @id_clase = SCOPE_IDENTITY();
		END
		ELSE
			SELECT @id_clase = id FROM general.clase
			WHERE id_actividad = @id_actividad
			  AND id_empleado = @id_empleado
			  AND dia = @dia_semana
			  AND id_categoria = @id_categoria;

		-- Insertar presentismo
		INSERT INTO general.presentismo(id_socio, id_clase, fecha, tipo_asistencia)
		VALUES(@id_socio, @id_clase, @fecha_asistencia, @asistencia);

		SET @current_row = @current_row + 1;
	END

	-- Eliminar tablas temporales
	DROP TABLE ##presentismo;
	DROP TABLE #procesar;
END
GO 

create or alter procedure socio.altaFacturaImportacion
as
begin
	set nocount on;

	-- 1. Agrupar actividades por socio, año, mes
	if object_id('tempdb..#actividades_mes') is not null drop table #actividades_mes;
	select
		p.id_socio,
		YEAR(p.fecha) as anio,
		MONTH(p.fecha) as mes,
		min(c.id) as id_categoria, -- suponemos que la categoria es la de la primer clase del mes
		a.id as id_actividad
	into #actividades_mes
	from general.presentismo p
	inner join general.clase cl on p.id_clase = cl.id
	inner join general.actividad a on cl.id_actividad = a.id
	inner join socio.categoria c on cl.id_categoria = c.id
	group by p.id_socio, YEAR(p.fecha), MONTH(p.fecha), a.id;

	-- 2. Crear cuotas si no existen
	if object_id('tempdb..#cuotas_a_crear') is not null drop table #cuotas_a_crear;
	select distinct id_socio, id_categoria, anio, mes
	into #cuotas_a_crear
	from #actividades_mes am
	where not exists (
		select 1 from socio.cuota c
		where c.id_socio = am.id_socio and c.id_categoria = am.id_categoria and c.anio = am.anio and c.mes = am.mes
	);

	insert into socio.cuota (id_socio, id_categoria, anio, mes, monto_total)
	select id_socio, id_categoria, anio, mes, 0
	from #cuotas_a_crear;

	-- 3. Obtener todas las cuotas a procesar (nuevas y existentes)
	if object_id('tempdb..#cuotas_mes') is not null drop table #cuotas_mes;
	select c.id as id_cuota, c.id_socio, c.id_categoria, c.anio, c.mes, procesado = 0
	into #cuotas_mes
	from socio.cuota c
	inner join (
		select distinct id_socio, anio, mes from #actividades_mes
	) am on c.id_socio = am.id_socio and c.anio = am.anio and c.mes = am.mes;

	-- 4. Insertar inscripciones a actividades (si no existen)
	insert into socio.inscripcion_actividad (id_cuota, id_actividad)
	select cm.id_cuota, am.id_actividad
	from #cuotas_mes cm
	inner join #actividades_mes am
		on cm.id_socio = am.id_socio and cm.anio = am.anio and cm.mes = am.mes
	left join socio.inscripcion_actividad ia
		on ia.id_cuota = cm.id_cuota and ia.id_actividad = am.id_actividad
	where ia.id is null;

	-- 5. Calcular y actualizar el monto_total de la cuota
	update c
	set monto_total = isnull(cat.costo_mensual,0) + isnull(act.total_actividades,0)
	from socio.cuota c
	inner join socio.categoria cat on c.id_categoria = cat.id
	left join (
		select ia.id_cuota, sum(a.costo_mensual) as total_actividades
		from socio.inscripcion_actividad ia
		inner join general.actividad a on ia.id_actividad = a.id
		group by ia.id_cuota
	) act on c.id = act.id_cuota
	where exists (
		select 1 from #cuotas_mes cm where cm.id_cuota = c.id
	);

	-- 6. Llamar a altaFacturaCuota para cada cuota generada
	update #cuotas_mes set procesado = 0 where procesado is null;

	declare @id_cuota int, @anio int, @mes int, @fecha_emision date;

	while exists (select 1 from #cuotas_mes where procesado = 0)
	begin
		select top 1 @id_cuota = id_cuota, @anio = anio, @mes = mes
		from #cuotas_mes
		where procesado = 0;

		set @fecha_emision = datefromparts(@anio, @mes, 1);

		exec socio.altaFacturaCuota @id_cuota = @id_cuota, @fecha_emision = @fecha_emision;

		update #cuotas_mes set procesado = 1 where id_cuota = @id_cuota;


		-- COMENTAR ESTO EN CASO DE NO QUERER GENERAR PAGOS
		-- En caso de que pidan hacer de cuenta que fueron pagas, generamos los pagos.
		-- Obtenemos el monto de la cuota
		/*declare @monto_cuota decimal(12,2);
		select @monto_cuota = monto_total from socio.cuota where id = @id_cuota;

		-- Obtenemos el id de la factura de la cuota
		declare @id_factura_cuota int;
		select @id_factura_cuota = id from socio.factura_cuota where id_cuota = @id_cuota;

		-- Generamos el pago
		exec socio.altaPago
			@fecha_pago = @fecha_emision,
			@monto = @monto_cuota,
			@medio_de_pago = 'Visa',
			@es_debito_automatico = 0,
			@id_factura_cuota = @id_factura_cuota;*/
	end

	-- Eliminar tablas temporales
	drop table #actividades_mes;
	drop table #cuotas_a_crear;
	drop table #cuotas_mes;
end
GO 