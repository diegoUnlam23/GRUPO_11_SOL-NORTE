/*
	- Consigna:
		El código fuente de generación de objetos (tablas, vistas, store procedures, etc.) y el de carga
		de datos iniciales (sea por importación o generación manual o aleatoria) debe estar preparado
		para ser ejecutado por archivo, como un solo bloque. Esto significa que debe realizar las
		validaciones correspondientes para crear/eliminar objetos de forma que dos ejecuciones
		seguidas no generen datos duplicados ni mensajes de error por objetos preexistentes.
	- Fecha de entrega: 17/06/2025
	- Número de comisión: 2900 
	- Número de grupo: 11
	- Nombre de la materia: Bases de Datos Aplicadas
	- Integrantes:
		- Costanzo, Marcos Ezequiel - 40955907
		- Sanchez, Diego Mauricio - 46361081
	RECOMENDACION DESCARGAR microsoft access database engine 2016,
	https://www.microsoft.com/en-us/download/details.aspx?id=54920
*/
use Com2900G11

set dateformat dmy;

CREATE TABLE socio.datos_sResponsable (
    id int identity(1,1),
	id_socio NVARCHAR(20),
    nombre NVARCHAR(100),
    apellido NVARCHAR(100),
    dni INT,
    email NVARCHAR(150),
    fnac DATE,
    tel bigint,
    tel_em bigint,
    id_os NVARCHAR(150),
    nro_os NVARCHAR(50),
    tel_os NVARCHAR(50)
);
go

create table socio.datos_gFamiliar
(
	id int identity(1,1),
	id_socio	nvarchar(20),
	id_socio_rp	nvarchar(20),
	nombre		nvarchar(50),
	apellido	nvarchar(50),
	dni			int,
	email		nvarchar(100),
	fech_nac	date,
	tel			bigint,
	tel_em		bigint,
	nom_os		nvarchar(50),
	id_os		nvarchar(100),
	tel_os		nvarchar(50)
)
go
create table socio.datos_pCuotas
(
	id int identity(1,1),
	id_pago		bigint,
	f_mov		date,
	id_socio_rp nvarchar(20),
	monto		int,
	m_pago		nvarchar(50)
)
go
create table socio.datos_asistencia
(
	id int identity(1,1),
	id_socio_rp		nvarchar(20),
	actividad		nvarchar(50),
	f_asistencia	nvarchar(20),
	asistencia		nvarchar(10),
	profesor		nvarchar(100)
)
go
exec sp_configure 'show advanced options', 1;
reconfigure;
exec sp_configure 'Ad Hoc Distributed Queries', 1;
reconfigure;
go

exec sp_MSset_oledb_prop 'Microsoft.ACE.OLEDB.16.0', N'AllowInProcess', 1
exec sp_MSset_oledb_prop 'Microsoft.ACE.OLEDB.16.0', N'DynamicParameters', 1
go

---------------------------------------------------------------------------
------------------- SP PARA LA IMPORTACION DEL EXCEL ----------------------
---------------------------------------------------------------------------
create or alter procedure socio.importacionDatos
    @arch nvarchar(255)
as
begin
    declare @linea nvarchar(MAX);

    set @linea = N'
        insert into socio.datos_sResponsable
        select * 
        from openrowset(
            ''Microsoft.ACE.OLEDB.16.0'', 
            ''Excel 12.0;Database=' + @arch + ';HDR=YES;IMEX=0'', 
            ''SELECT * FROM [Responsables de Pago$]''
        );';

    exec sp_executesql @linea;
	
	set @linea = N'
        insert into socio.datos_gFamiliar
        select * 
        from openrowset(
            ''Microsoft.ACE.OLEDB.16.0'', 
            ''Excel 12.0;Database=' + @arch + ';HDR=YES;IMEX=0'', 
            ''SELECT * FROM [Grupo Familiar$]''
        );';

    exec sp_executesql @linea;
	
	set @linea = N'
        insert into socio.datos_pCuotas
        select * 
        from openrowset(
            ''Microsoft.ACE.OLEDB.16.0'', 
            ''Excel 12.0;Database=' + @arch + ';HDR=YES;IMEX=0'', 
            ''SELECT * FROM [pago cuotas$]''
        );';

    
    exec sp_executesql @linea;

	set @linea = N'
        insert into socio.datos_asistencia
        select [Nro de Socio],[Actividad],[fecha de asistencia],[Asistencia],[Profesor] 
		from openrowset(
            ''Microsoft.ACE.OLEDB.16.0'', 
            ''Excel 12.0;Database=' + @arch + ';HDR=YES;IMEX=0'', 
            ''SELECT * FROM [presentismo_actividades$]''
        );';

    exec sp_executesql @linea;
end;
go

---------------------------------------------------------------------------
-------------- CARGA DE DATOS A LA TABLA OBRA SOCIAL ----------------------
---------------------------------------------------------------------------

create or alter procedure socio.cargaDatosObraSocial
as
begin
	declare @id_act int;
	declare @id_max int;
	
	
	select  @id_act = min(id),@id_max = max(id)
	from socio.datos_sResponsable d;

	declare @nom_os varchar(50);
	declare @tel_em varchar(50);

	while @id_act <= @id_max
	begin
		select @nom_os = id_os,@tel_em = tel_os
		from socio.datos_sResponsable
		exec socio.agregarDatosObraSocial @nombre = @nom_os ,@telefono_emergencia = @tel_em
		set @id_act = @id_act + 1;
	end

	select  @id_act = min(id),@id_max = max(id)
	from socio.datos_gFamiliar d;
	while @id_act <= @id_max
	begin
		select @nom_os = nom_os,@tel_em = tel_os
		from socio.datos_gFamiliar
		exec socio.agregarDatosObraSocial @nombre = @nom_os ,@telefono_emergencia = @tel_em
		set @id_act = @id_act + 1;
	end

end
go
---------------------------------------------------------------------------
---------CARGA DE DATOS A LA TABLA OBRA SOCIAL POR PERSONA ----------------
---------------------------------------------------------------------------

/*create or alter procedure socio.cargaDatosObraSocialPersona
as
begin
	declare @id_act int;
	declare @id_max int;
	
	
	select  @id_act = min(id),@id_max = max(id)
	from socio.datos_sResponsable d;
	while @id_act <= @id_max
	begin
		
		set @id_act = @id_act + 1;
	end
end
go*/

---------------------------------------------------------------------------
-------------------CARGA DE DATOS  POR PERSONA-----------------------------
---------------------------------------------------------------------------

create or alter procedure socio.cargaDatosPersona
as
begin
	declare @id_act int;
	declare @id_max int;

	select  @id_act = min(id),@id_max = max(id)
	from socio.datos_sResponsable d;

	declare @nombre varchar(50);
	declare @apellido varchar(50);
	declare @dni int;
	declare @f_nac date;
	declare @email varchar(150); 
	declare @tel varchar(50);
	declare @tel_em varchar(50);


	declare @nro_socio varchar(50);
	declare @nombre_os varchar(50);
	declare @id_obra_social int;
	
	while @id_act <= @id_max
	begin
		
		select @nombre = d.nombre,@apellido = d.apellido, @dni = dni,
			   @f_nac = d.fnac, @email = d.email, @tel = d.tel, @tel_em = d.tel_em ,
			   @nro_socio = d.nro_os, @nombre_os = d.id_os
		from socio.datos_sResponsable d;

		select @id_obra_social = id
		from socio.datos_obra_social
		where nombre = @nombre_os

		
		exec socio.agregarObraSocialPersona @id_datos_os = @id_obra_social, @numero_socio = @nro_socio;

		select @id_obra_social = id
		from socio.obra_social_persona
		where numero_socio = @nro_socio

		exec socio.agregarPersona 
		@nombre = @nombre,@apellido = @apellido,@dni = @dni,@email = @email,@fecha_nacimiento = @f_nac, 
		@telefono = @tel, @telefono_emergencia = @tel_em,@id_obra_social_persona = @id_obra_social;
		
		set @id_act = @id_act + 1;
	end
end
go


---------------------------------------------------------------------------
----------------CARGA DE DATOS  POR GRUPO FAMILIAR-------------------------
---------------------------------------------------------------------------

create or alter procedure socio.cargaDatosGrupoFamiliar
as
begin
	declare @id_act int;
	declare @id_max int;
	
	
	select  @id_act = min(id),@id_max = max(id)
	from socio.datos_gFamiliar d;

	declare @nombre varchar(50);
	declare @apellido varchar(50);
	declare @dni int;
	declare @f_nac date;
	declare @email varchar(150); 
	declare @tel varchar(50);
	declare @tel_em varchar(50);

	declare @relacion varchar(50);
	declare @es_responsable bit;
	declare @nro_socio varchar(50);
	
	declare @nro_socio_os varchar(50);
	declare @nombre_os varchar(50);
	declare @id_tabla int;

	while @id_act <= @id_max
	begin
		--- TOMO LOS DATOS DEL SOCIO MENOR DE EDAD ---
		select @nombre = d.nombre,@apellido = d.apellido, @dni = dni,
			   @f_nac = d.fech_nac, @email = d.email, @tel = d.tel, @tel_em = d.tel_em ,
			   @nro_socio_os = d.id_os, @nombre_os = d.nom_os,@nro_socio = d.id_socio_rp
		from socio.datos_gFamiliar d;

		select @id_tabla = id
		from socio.datos_obra_social
		where nombre = @nombre_os
		
		--- GUARDO SUS DATOS DE OBRA SOCIAL ---
		exec socio.agregarObraSocialPersona @id_datos_os = @id_tabla, @numero_socio = @nro_socio_os;

		--- BUSCO EL ID DE LA OBRA SOCIAL ---
		select @id_tabla = id
		from socio.obra_social_persona
		where numero_socio = @nro_socio_os
		
		--- INSERTO LOS DATOS EN LA TABLA PERSONA ---
		exec socio.agregarPersona 
		@nombre = @nombre,@apellido = @apellido,@dni = @dni,@email = @email,@fecha_nacimiento = @f_nac, 
		@telefono = @tel, @telefono_emergencia = @tel_em,@id_obra_social_persona = @id_tabla;

		--- TOMO EL ID DE LA PERSONA QUE ACABO DE CREAR MEDIANTE SU DNI ---
		select @id_tabla = id
		from socio.persona
		where @dni = dni

		--- ESTABLESCO LOS VALORES DE RELACION Y SI ES RESPONSABLE---
		set @relacion = N'MENOR';
		set @es_responsable = 0;
		--- INSERTO EN LA TABLA GRUPO FAMILIAR ---
		exec socio.agregarGrupoFamiliar @id_persona = @id_tabla,@es_responsable = @es_responsable,@relacion_con_responsable = @relacion;

		--- TOMO EL ID PERSONA DEL RESPONSABLE MEDIANTE SU NRO DE SOCIO Y DNI ---
		select @dni = r.dni
		from socio.datos_gFamiliar g join 
		socio.datos_sResponsable r on 
		g.id_socio_rp = r.id_socio
		where @nro_socio = r.id_socio

		select @id_tabla = id
		from socio.persona p
		where p.dni = @dni
		
		set @relacion = N'TUTOR';
		set @es_responsable = 1;
		exec socio.agregarGrupoFamiliar @id_persona = @id_tabla,@es_responsable = @es_responsable,@relacion_con_responsable = @relacion;

		set @id_act = @id_act + 1;
	end
end
/*
	EXEC QUE IRIAN EN TESTING O EN UN SP GENERAL
	exec socio.importacionDatos @arch = N'D:\Datos socios.xlsx'
	exec socio.cargaDatosObraSocial
	select * from socio.datos_gFamiliar
	exec socio.cargaDatosGrupoFamiliar
	exec socio.cargaDatosPersona
*/
