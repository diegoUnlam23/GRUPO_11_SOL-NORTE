create database Com2900G11;
go

use Com2900G11;
go

create schema empleado; --TABLA Y SP PARA PROFESORES
create schema general; --TABLAS Y SP QUE USAN TODOS LOS SCHEMAS
create schema socio; --TABLAS Y SP PARA EL USO DE LOS SOCIOS
go
--- TABLAS SOCIO---
create table socio.datos_obra_social
(
	id					int primary key identity(1,1),
	nombre				varchar(50) NOT NULL,
	telefono_emergencia	varchar(50) NOT NULL
);

create table socio.obra_social_usuario
(
	id 			 int primary key identity(1,1),
	id_datos_os	 int NOT NULL,
	numero_socio varchar(50) NOT NULL,
	foreign key (id_datos_os) references socio.datos_obra_social(id) 
);
go

create table socio.persona
(
	id						int primary key identity(1,1),
	nombre					varchar(50) NOT NULL,
	apellido				varchar(50) NOT NULL,
	dni						int UNIQUE NOT NULL CHECK(dni > 0),
	email					varchar(254) NOT NULL CHECK(email like '_%@_%._%'),
	fecha_nacimiento		date NOT NULL,
	telefono				varchar(20) NOT NULL,
	telefono_emergencia		varchar(20) NOT NULL,
	saldo_actual			decimal(8,2) default 0,
	id_obra_social_usuario	int NOT NULL,
	foreign key (id_obra_social_usuario) references socio.obra_social_usuario(id)
);

create table socio.grupo_familiar
(
	id							int identity(1,1),
	id_persona					int NOT NULL,
	es_responsable				bit default 0,
	relacion_con_responsable	varchar(20) NOT NULL,
	fecha_alta					date NOT NULL,
	fecha_baja					date CHECK( fecha_baja > fecha_alta),
	primary key (id, id_persona),
	foreign key (id_persona) references socio.persona(id)
);
go
--- TABLAS CUENTA ACCESO Y EMPLEADO ---
create table general.rol
(
	id				int primary key identity(1,1),
	descripcion		varchar(100) NOT NULL
);
create table empleado.puesto
(
	id 			int primary key identity(1,1),
	descripcion	varchar(100) NOT NULL
);
create table empleado.empleado
(
	id			int primary key identity(1,1),
	nombre		varchar(50) NOT NULL,
	apellido	varchar(50) NOT NULL,
	dni			int UNIQUE NOT NULL CHECK(dni > 0),
	email		varchar(254) NOT NULL CHECK(email like '_%@_%._%'),
	id_puesto	int NOT NULL,
	foreign key (id_puesto) references empleado.puesto(id)
);
create table general.cuenta_acceso
(
	id						int primary key identity(1,1),
	usuario					varchar(50) NOT NULL,
	hash_contraseña			varchar(50) NOT NULL,
	vigencia_contraseña		date NOT NULL,
	id_rol					int NOT NULL,
	id_persona				int NOT NULL,
	id_empleado				int NOT NULL,
	foreign key (id_rol) references general.rol(id),
	foreign key (id_persona) references socio.persona(id),
	foreign key (id_empleado) references empleado.empleado(id)
);
go

--- TABLAS INV Y PILETA ---
create table socio.invitado
(
	id						int primary key identity(1,1),
	nombre					varchar(50) NOT NULL,
	apellido				varchar(50) NOT NULL,
	dni						int UNIQUE NOT NULL CHECK(dni > 0),
	id_persona_asociada		int NOT NULL,
	foreign key (id_persona_asociada) references socio.persona(id)
);

create table socio.tarifa_pileta
(
	id		int primary key identity(1,1),
	tipo	varchar(50) COLLATE modern_spanish_CI_AS CHECK(tipo IN('Socio','Invitado')),
	precio	decimal(8,2) NOT NULL check(precio >= 0)
);

create table socio.registro_pileta
(
	id				int primary key identity(1,1),
	id_persona		int NOT NULL,
	id_invitado 	int NOT NULL,
	fecha			date NOT NULL,
	id_tarifa		int NOT NULL,
	foreign key (id_persona) references socio.persona(id),
	foreign key (id_invitado) references socio.invitado(id),
	foreign key (id_tarifa) references socio.tarifa_pileta(id)
);
go
--- TABLAS INSCRIPCION Y CLASE ---
create table socio.categoria
(
	id			int primary key identity(1,1),
	nombre		varchar(10) NOT NULL,
	costo		decimal(8,2) NOT NULL CHECK(costo > 0),
	edad_min	int NOT NULL,
	edad_max	int NOT NULL CHECK(edad_max > edad_min)
);

create table socio.estado_inscripcion
(
	id		int primary key identity(1,1),
	estado	varchar(50) NOT NULL
);


create table socio.medio_de_pago
(
	id		int primary key identity(1,1),
	tipo	varchar(50) NOT NULL
); 
create table socio.inscripcion
(
	id					varchar(10) primary key CHECK(id like 'SN-_%'),
	id_persona			int NOT NULL,
	id_grupo_familiar	int,
	fecha_inicio		datetime NOT NULL,
	fecha_baja			datetime,
	id_estado			int NOT NULL,
	id_categoria		int NOT NULL,
	id_medio_pago		int NOT NULL,
	foreign key (id_persona) references socio.persona(id),
	foreign key (id_grupo_familiar,id_persona) references socio.grupo_familiar(id,id_persona),
	foreign key (id_estado) references socio.estado_inscripcion(id),
	foreign key (id_categoria) references socio.categoria(id),
	foreign key (id_medio_pago) references socio.medio_de_pago(id)
);
go
--- CLASE/ACTIVIDAD ---
create table general.actividad
(
	id		int primary key identity(1,1),
	nombre	varchar(50) NOT NULL,
	costo	decimal(8,2) NOT NULL
);

create table general.actividad_extra
(
	id		int primary key identity(1,1),
	nombre	varchar(50) NOT NULL,
	costo	decimal(8,2) NOT NULL
);

create table general.dia_semana
(
	id		int primary key identity(1,1),
	nombre	varchar(50) NOT NULL
);
create table socio.inscripcion_actividad
(
	id					int primary key identity(1,1),
	id_inscripcion		varchar(10) NOT NULL,
	id_actividad		int NOT NULL,
	id_actividad_extra	int NOT NULL,
	fecha_inscripcion	datetime NOT NULL,
	foreign key (id_inscripcion) references socio.inscripcion(id),
	foreign key (id_actividad) references general.actividad(id),
	foreign key (id_actividad_extra) references general.actividad_extra(id)
);
create table general.clase
(
	id				int primary key identity(1,1),
	hora_inicio		time NOT NULL,
	hora_fin		time NOT NULL CHECK(hora_fin>hora_inicio),
	id_categoria	int NOT NULL,
	id_actividad	int NOT NULL,
	id_dia_semana	int NOT NULL,
	id_empleado		int NOT NULL,
	foreign key (id_actividad) references general.actividad(id),
	foreign key (id_categoria) references socio.categoria(id),
	foreign key (id_empleado) references empleado.empleado(id),
	foreign key (id_dia_semana) references general.dia_semana(id)
);
go
--- TABLA PAGO Y FACTURA ---
create table socio.cuenta_corriente
(
	id			int primary key identity(1,1),
	id_persona	int NOT NULL,
	saldo		decimal(8,2),
	foreign key (id_persona) references socio.persona(id)
);
create table socio.estado_factura 
(
	id				int primary key identity(1,1),
	descripcion		varchar(50) NOT NULL
);
create table socio.factura
(
	id						int primary key identity(1,1),
	fecha_generacion		date NOT NULL,
	fecha_vencimiento_1		date NOT NULL,
	fecha_vencimiento_2		date NOT NULL,
	monto					decimal(8,2),
	descripcion				varchar(100) NOT NULL,
	id_inscripcion			varchar(10) NOT NULL,
	id_registro_pileta		int NOT NULL,
	id_estado_factura		int NOT NULL,
	foreign key (id_inscripcion) references socio.inscripcion(id),
	foreign key (id_registro_pileta) references socio.registro_pileta(id),
	foreign key (id_estado_factura) references socio.estado_factura(id)
);

create table socio.item_factura
(
	id			int primary key identity(1,1),
	id_factura 	int NOT NULL,
	monto		decimal(8,2) NOT NULL,
	tipo_item	varchar(50) NOT NULL,
	foreign key (id_factura) references socio.factura(id)
);
go
create table socio.pago
(
	id						int primary key identity (1,1),
	fecha_pago				date NOT NULL,
	monto					decimal(8,2) NOT NULL,
	es_debito_automatico	bit default 0,
	id_factura				int NOT NULL,
	foreign key (id_factura) references socio.factura(id)
);
create table socio.tipo_reembolso
(
	id				int primary key identity (1,1),
	descripcion		varchar(50) NOT NULL
);
create table socio.reembolso
(
	id					int primary key identity (1,1),
	id_pago				int NOT NULL,
	monto				decimal(8,2) NOT NULL,
	fecha_reembolso		datetime NOT NULL,
	motivo				varchar(100) NOT NULL,
	id_tipo_reembolso	int NOT NULL,
	foreign key (id_pago) references socio.pago(id),
	foreign key (id_tipo_reembolso) references socio.tipo_reembolso(id)
);
create table socio.movimiento_cuenta
(
	id						int primary key identity (1,1),
	id_cuenta_corriente		int NOT NULL,
	fecha					datetime NOT NULL,
	monto					decimal(8,2) NOT NULL,
	id_factura				int NOT NULL,
	id_pago					int NOT NULL,
	id_reembolso			int NOT NULL,
	foreign key (id_cuenta_corriente) references socio.cuenta_corriente(id),
	foreign key (id_factura) references socio.factura(id),
	foreign key (id_pago) references socio.pago(id),
	foreign key (id_reembolso) references socio.reembolso(id)
);
go

--------------------------- CREACION DE SOCIO-----------------------------------------

--OBRA SOCIAL
create or alter procedure socio.agregarObSocial
	@nombre varchar(50),
	@telefono_emergencia	varchar(50),
	@idOS	int
as
begin
	if(@nombre not in(select datos_obra_social.nombre from socio.datos_obra_social) and @telefono_emergencia not in(select datos_obra_social.telefono_emergencia from socio.datos_obra_social))
		insert into socio.datos_obra_social(nombre,telefono_emergencia)
		values(@nombre,@telefono_emergencia)
	else
		print('ya existe esa obra social')
	set @idOS = (select datos_obra_social.id from socio.datos_obra_social where @nombre = datos_obra_social.nombre)
	return @idOs
end

/*create or alter procedure socio.modificarOS
	@nombre varchar(50),
	@telefono_emergencia	varchar(50)
as
begin
	if(@nombre in(select datos_obra_social.nombre from socio.datos_obra_social))
		update datos_obra_social
		set telefono_emergencia = @telefono_emergencia
		where @nombre = nombre
	else
		print('No se encontro '+@nombre+' en la lista')
end*/

create or alter procedure socio.cargarSocioOS
	@nombre		varchar(50),
	@numero_socio	varchar(50),
	@telefono_emergencia		varchar(50)
as
begin
	declare @id_os int
	if(@nombre in(select datos_obra_social.nombre from socio.datos_obra_social))
	begin	
		set @id_os = (select datos_obra_social.id from socio.datos_obra_social where @nombre = nombre)
		insert into socio.obra_social_usuario(id_datos_os,numero_socio) values (@id_os,@numero_socio)
	end
	else
	begin
		exec socio.agregarObSocial @nombre,@telefono_emergencia,@id_os
		--set @id_os = (select datos_obra_social.id from socio.datos_obra_social where @nombre = nombre)
		insert into socio.obra_social_usuario(id_datos_os,numero_socio) values (@id_os,@numero_socio)
	end
		
end

-- PERSONA
create or alter procedure socio.cargarPersona
	(
	@nombre		varchar(20),
	@apellido	varchar(20),
	@dni		int,
	@email		varchar(254),
	@f_nac		date,
	@tel		varchar(20),
	@telefono_emergencia		varchar(20),
	--@saldo		decimal(8,2),
	@num_OS		varchar(20),
	@nomOS		varchar(50),
	@telOS		varchar(50)
	)
as
begin
	declare @id_os int
	--set @id_os = (select datos_obra_social.id from socio.datos_obra_social where @nomOS = datos_obra_social.nombre collate modern_spanish_ci_ai) 
	if( @nomOs not in (select datos_obra_social.nombre from socio.datos_obra_social))
	begin
		exec socio.agregarObSocial @nomOS,@telOS,@id_os
	end
	if(@dni not in(select persona.dni from socio.persona))
	begin
		exec socio.cargarSocioOS @nomOS,@num_OS,@telOS
		set @id_os = (select obra_social_usuario.id from socio.obra_social_usuario where @num_OS = obra_social_usuario.numero_socio)
		insert into socio.persona(nombre,apellido,dni,email,fecha_nacimiento,telefono,telefono_emergencia,saldo_actual,id_obra_social_usuario) 
		values (@nombre,@apellido,@dni,@email,@f_nac,@tel,@telefono_emergencia,0,@id_os)
	end
end

-- CATEGORIA
create or alter procedure socio.crearCategoria
	(
	@nombre varchar(20),
	@costo decimal(8,2),
	@min	int,
	@max	int,
	@id_ret	int output
	)
as
begin 
	if(@nombre not in(select categoria.nombre from socio.categoria))
		insert into socio.categoria(nombre,costo,edad_min,edad_max)
		values (@nombre,@costo,@min,@max)
	set @id_ret = (select categoria.id from socio.categoria where @nombre = categoria.nombre)
	return @id_ret
end

create or alter procedure socio.modificarCategoria
	(
	@nombre varchar(20),
	@costo decimal(8,2),
	@min	int,
	@max	int
	)
as
begin 
	update socio.categoria
	set costo = @costo,
		edad_min = @min,
		edad_max = @max
	where @nombre = nombre
end
-- ESTADO DEL SOCIO

create or alter procedure socio.agregarEstadoSocio
	@descripcion varchar(100),
	@id_est int output
as
begin
	insert into socio.estado_inscripcion(estado) values(@descripcion)
	set @id_est = (select estado_inscripcion.estado from socio.estado_inscripcion where @descripcion = estado_inscripcion.estado)
	return @id_est
end
-- GRUPO FAMILIAR
create or alter procedure socio.agregargrupo_familiar
	(
	@dni_resp	int,
	@bool_resp	char(2) collate modern_spanish_ci_ai,
	@relacion	varchar(50),
	@f_alta		datetime,
	@f_baja		dateTime,

	)
as
begin 
end
--SOCIO
create or alter procedure socio.inscripcionSocio
	(
	@dni	int,
	
	)
as
begin
	--codigo
end

create or alter procedure socio.cargarInvitado
	(
	)
as
begin
end