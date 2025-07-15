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

	-- Actividades realizadas por socios
	if object_id('tempdb..#actividades_por_socio') is not null drop table #actividades_por_socio;
	select
		p.id_socio,
		s.nro_socio,
		p.id_clase,
		month(p.fecha) as mes,
		year(p.fecha) as anio,
		a.id as id_actividad
	into #actividades_por_socio
	from general.presentismo p
	join socio.socio s on s.id = p.id_socio
	join general.clase c on c.id = p.id_clase
	join general.actividad a on a.id = c.id_actividad;

	-- Agrupa por socio y actividad, usando la menor fecha como fecha_alta
	with inscripciones_unicas as (
		select
			aps.id_actividad,
			aps.id_socio,
			min(DATEFROMPARTS(aps.anio, aps.mes, 1)) as fecha_alta
		from #actividades_por_socio aps
		group by aps.id_actividad, aps.id_socio
	)
	insert into socio.inscripcion_actividad (id_actividad, id_socio, fecha_alta, activa)
	select iu.id_actividad, iu.id_socio, iu.fecha_alta, 1
	from inscripciones_unicas iu
	left join socio.inscripcion_actividad ia
	  on ia.id_actividad = iu.id_actividad
	  and ia.id_socio = iu.id_socio
	where ia.id is null;

	-- Crear cuotas para cada socio, mes y año detectado en actividades
    if object_id('tempdb..#cuotas_a_crear') is not null drop table #cuotas_a_crear;
    select distinct
        aps.id_socio,
        aps.mes,
        aps.anio
    into #cuotas_a_crear
    from #actividades_por_socio aps
    where not exists (
        select 1 from socio.cuota c
        where c.id_socio = aps.id_socio and c.mes = aps.mes and c.anio = aps.anio
    );

    declare @id_socio int, @mes int, @anio int;
    while exists (select 1 from #cuotas_a_crear)
    begin
        select top 1 @id_socio = id_socio, @mes = mes, @anio = anio from #cuotas_a_crear;
        exec socio.altaCuota @id_socio = @id_socio, @mes = @mes, @anio = @anio;
        delete from #cuotas_a_crear where id_socio = @id_socio and mes = @mes and anio = @anio;
    end

	-- Generar facturas para cada cuota creada si no tiene factura
    if object_id('tempdb..#cuotas_generadas') is not null drop table #cuotas_generadas;
    select c.id as id_cuota, c.id_socio, c.anio, c.mes
    into #cuotas_generadas
    from socio.cuota c
    left join #actividades_por_socio aps on c.id_socio = aps.id_socio and c.mes = aps.mes and c.anio = aps.anio
	join socio.socio s on s.id = c.id_socio;
	--where s.responsable_pago = 1;

    declare @id_cuota int, @anio_fact int, @mes_fact int, @fecha_emision date;
    while exists (select 1 from #cuotas_generadas where id_cuota not in (select id from socio.cuota where id_factura is not null))
    begin
        select top 1 @id_cuota = id_cuota, @anio_fact = anio, @mes_fact = mes from #cuotas_generadas where id_cuota not in (select id from socio.cuota where id_factura is not null);
        set @fecha_emision = datefromparts(@anio_fact, @mes_fact, 1);
        exec socio.altaFacturaCuota @id_cuota = @id_cuota, @fecha_emision = @fecha_emision;
        delete from #cuotas_generadas where id_cuota = @id_cuota;
    end

	

end
GO