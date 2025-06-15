create database Com2900G11;
go

use Com2900G11;
go

create schema empleado; --TABLA Y SP PARA PROFESORES
create schema general; --TABLAS Y SP QUE USAN TODOS LOS SCHEMAS
create schema socio; --TABLAS Y SP PARA EL USO DE LOS SOCIOS
go
--- TABLAS SOCIO---
create table socio.obraSocial
(
	id		int primary key identity(1,1),
	nombre	varchar(50) NOT NULL,
	tel_em	varchar(50) NOT NULL
);

create table socio.obraSocUsr
(
	id			int primary key identity(1,1),
	id_dat_os	int NOT NULL,
	num_socio	varchar(50) NOT NULL,
	constraint fk_osUsr foreign key (id_dat_os) references socio.obraSocial(id) 
);
go

create table socio.persona
(
	id				int primary key identity(1,1),
	nombre			varchar(50) NOT NULL,
	apellido		varchar(50) NOT NULL,
	dni				int UNIQUE NOT NULL CHECK(dni > 0),
	email			varchar(254) NOT NULL CHECK(email like '_%@_%._%'),
	fec_nacimiento	date NOT NULL,
	telefono		varchar(20) NOT NULL,
	tel_em			varchar(20) NOT NULL,
	saldo_actual	decimal(8,2) default 0,
	id_obrSoc_usr	int NOT NULL,
	constraint fk_obraSocUsr 
	foreign key (id_obrSoc_usr) 
	references socio.obraSocUsr(id)
);

create table socio.grupoFamiliar
(
	id			int identity(1,1),
	id_persona	int NOT NULL,
	es_resp		bit default 0,
	rel_resp	varchar(20) NOT NULL,
	fecha_alta	date NOT NULL,
	fecha_baja	date CHECK( fecha_baja > fecha_alta),
	constraint pk_GPFamiliar primary key (id,id_persona),
	constraint fk_personaGF foreign key (id_persona) references socio.persona(id)
);
go
--- TABLAS CUENTA ACCESO Y EMPLEADO ---
create table general.rol
(
	id				int primary key identity(1,1),
	descripcion		varchar(100) NOT NULL,
);
create table empleado.puesto
(
	id int primary key identity(1,1),
	descripcion		varchar(100) NOT NULL
);
create table empleado.empleado
(
	id			int primary key identity(1,1),
	nombre		varchar(50) NOT NULL,
	apellido	varchar(50) NOT NULL,
	dni			int UNIQUE NOT NULL CHECK(dni > 0),
	email		varchar(254) NOT NULL CHECK(email like '_%@_%._%'),
	id_puesto	int NOT NULL,
	constraint fk_puestoEmp foreign key (id_puesto) references empleado.puesto(id)
);
create table general.cuentaAcceso
(
	id					int primary key identity(1,1),
	usuario				varchar(50) NOT NULL,
	hash_contraseña		varchar(50) NOT NULL,
	vigencia_contra		date NOT NULL,
	id_rol				int NOT NULL,
	id_persona			int NOT NULL,
	id_empleado			int NOT NULL,
	constraint fk_rolCuenta foreign key (id_rol) references general.rol(id),
	constraint fk_perCuenta foreign key (id_persona) references socio.persona(id),
	constraint fk_empCuenta foreign key (id_empleado) references empleado.empleado(id)
);
go

--- TABLAS INV Y PILETA ---
create table socio.invitado
(
	id			int primary key identity(1,1),
	nombre		varchar(50) NOT NULL,
	apellido	varchar(50) NOT NULL,
	id_persAsc	int NOT NULL,
	constraint fk_perInv 
	foreign key (id_persAsc) 
	references socio.persona(id)
);

create table socio.tarifaPileta
(
	id		int primary key identity(1,1),
	tipo	varchar(50) COLLATE modern_spanish_CI_AS CHECK(tipo IN('Socio','Invitado')),
	precio	decimal(8,2) NOT NULL check(precio >= 0)
);

create table socio.pileta
(
	id			int primary key identity(1,1),
	id_persona	int NOT NULL,
	id_invitado int NOT NULL,
	fecha		date NOT NULL,
	id_tarifa	int NOT NULL,
	constraint fk_perPileta foreign key (id_persona) references socio.persona(id),
	constraint fk_invPileta foreign key (id_invitado) references socio.invitado(id),
	constraint fk_tarPilete foreign key (id_tarifa) references socio.tarifaPileta(id)
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

create table socio.estadoInscripcion
(
	id		int primary key identity(1,1),
	estado	varchar(50) NOT NULL,
	
);


create table socio.medioPago
(
	id		int primary key identity(1,1),
	tipo	varchar(50) NOT NULL,
); 
create table socio.inscripcion
(
	id			varchar(10) primary key CHECK(id like 'SN-_%'),
	id_persona	int NOT NULL,
	id_grupoF	int,
	fechaIni	datetime NOT NULL,
	fechaBaja	datetime,
	id_estado	int NOT NULL,
	id_cat		int NOT NULL,
	id_mPago	int NOT NULL,
	constraint fk_perInscripcion foreign key (id_persona) references socio.persona(id),
	constraint fk_gfInscripcion	foreign key (id_grupoF,id_persona) references socio.grupoFamiliar(id,id_persona),
	constraint fk_estInscripcion foreign key (id_estado) references socio.estadoInscripcion(id),
	constraint fk_catInscripcion foreign key (id_cat) references socio.categoria(id),
	constraint fk_mpagoInscripcion foreign key (id_mPago) references socio.medioPago(id)
);
go
--- CLASE/ACTIVIDAD ---
create table general.actividad
(
	id		int primary key identity(1,1),
	nombre	varchar(50) NOT NULL,
	costo	decimal(8,2) NOT NULL,
);

create table general.actividadExtra
(
	id		int primary key identity(1,1),
	nombre	varchar(50) NOT NULL,
	costo	decimal(8,2) NOT NULL
);

create table general.diaSemana
(
	id		int primary key identity(1,1),
	nombre	varchar(50) NOT NULL,
);
create table socio.inscripcionActividad
(
	id			int primary key identity(1,1),
	id_insc		varchar(10) NOT NULL,
	id_act		int NOT NULL,
	id_actE		int NOT NULL,
	fecha_insc	datetime NOT NULL,
	constraint fk_inscIActividad foreign key (id_insc) references socio.inscripcion(id),
	constraint fk_actIActivdad foreign key (id_act) references general.actividad(id),
	constraint fk_acteIActividad foreign key (id_actE) references general.actividadExtra(id),
);
create table general.clase
(
	id			int primary key identity(1,1),
	hora_ini	time NOT NULL,
	hora_fin	time NOT NULL CHECK(hora_fin>hora_ini),
	id_cat		int NOT NULL,
	id_act		int NOT NULL,
	id_dia		int NOT NULL,
	id_emp		int NOT NULL,
	constraint fk_actClase foreign key (id_act) references general.actividad(id),
	constraint fk_catClase foreign key (id_cat) references socio.categoria(id),
	constraint fk_empClase foreign key (id_emp) references empleado.empleado(id),
	constraint fk_diaClase foreign key (id_dia) references general.diaSemana(id),
);
go
--- TABLA PAGO Y FACTURA ---
create table socio.cuentaCorriente
(
	id			int primary key identity(1,1),
	id_per		int NOT NULL,
	saldo		decimal(8,2),
	constraint fk_perCCoriente foreign key (id_per) references socio.persona(id)
);
create table socio.estadoFactura 
(
	id			int primary key identity(1,1),
	descr		varchar(50) NOT NULL,
);
create table socio.factura
(
	id				int primary key identity(1,1),
	f_generacion	date NOT NULL,
	f_venc_1		date NOT NULL,
	f_venc_2		date NOT NULL,
	monto			decimal(8,2),
	descr			varchar(100) NOT NULL,
	id_insc			varchar(10) NOT NULL,
	id_regPileta	int NOT NULL,
	id_estFactura	int NOT NULL,
	constraint fk_inscFactura foreign key (id_insc) references socio.inscripcion(id),
	constraint fk_regpFactura foreign key (id_regPileta) references socio.pileta(id),
	constraint fk_estfFacutra foreign key (id_estFactura) references socio.estadoFactura(id)
);

create table socio.itemFactura
(
	id			int primary key identity(1,1),
	monto		decimal(8,2) NOT NULL,
	tipo_item	varchar(50) NOT NULL,


);
go
create table socio.tipoPago
(
	id		int primary key identity (1,1),
	descr	varchar(50) NOT NULL
);
create table socio.pago
(
	id			int primary key identity (1,1),
	f_pago		date NOT NULL,
	monto		decimal(8,2) NOT NULL,
	esDebitoAut	bit default 0,
	id_mPago	int NOT NULL,
	id_factura	int NOT NULL,
	id_tPago	int NOT NULL,
	constraint	fk_mpagoPago foreign key (id_mPago) references socio.medioPago(id),
	constraint	fk_facutraPago foreign key (id_factura) references socio.factura(id),
	constraint	fk_tpagoPago foreign key (id_tPago) references socio.tipoPago(id)

);
create table socio.tipoReembolso
(
	id			int primary key identity (1,1),
	descr		varchar(50) NOT NULL
);
create table socio.reembolso
(
	id				int primary key identity (1,1),
	monto			decimal(8,2) NOT NULL,
	f_reembolso		datetime NOT NULL,
	motivo			varchar(100) NOT NULL,
	id_tReembolso	int NOT NULL,
	constraint	fk_trmbReembolso foreign key (id_tReembolso) references socio.tipoReembolso(id)
);
create table socio.movCuenta
(
	id				int primary key identity (1,1),
	id_CCorriente	int NOT NULL,
	fecha			datetime NOT NULL,
	monto			decimal(8,2) NOT NULL,
	id_factura		int NOT NULL,
	id_pago			int NOT NULL,
	id_reembolso	int NOT NULL,
	constraint	fk_ccMovCuenta foreign key (id_CCorriente) references socio.cuentaCorriente(id),
	constraint	fk_factMovCuenta foreign key (id_factura) references socio.factura(id),
	constraint	fk_pagoMovCuenta foreign key (id_pago) references socio.pago(id),
	constraint	fk_rmbMovCuenta foreign key (id_reembolso) references socio.reembolso(id)

);
go

--------------------------- CREACION DE SOCIO-----------------------------------------

--OBRA SOCIAL
create or alter procedure socio.agregarObSocial
	@nombre varchar(50),
	@tel_em	varchar(50),
	@idOS	int
as
begin
	if(@nombre not in(select obraSocial.nombre from socio.obraSocial) and @tel_em not in(select obraSocial.tel_em from socio.obraSocial))
		insert into socio.obraSocial(nombre,tel_em)
		values(@nombre,@tel_em)
	else
		print('ya existe esa obra social')
	set @idOS = (select obraSocial.id from socio.obraSocial where @nombre = obraSocial.nombre)
	return @idOs
end

/*create or alter procedure socio.modificarOS
	@nombre varchar(50),
	@tel_em	varchar(50)
as
begin
	if(@nombre in(select obraSocial.nombre from socio.obraSocial))
		update obraSocial
		set tel_em = @tel_em
		where @nombre = nombre
	else
		print('No se encontro '+@nombre+' en la lista')
end*/

create or alter procedure socio.cargarSocioOS
	@nombre		varchar(50),
	@num_socio	varchar(50),
	@tel_em		varchar(50)
as
begin
	declare @id_os int
	if(@nombre in(select obraSocial.nombre from socio.obraSocial))
	begin	
		set @id_os = (select obraSocial.id from socio.obraSocial where @nombre = nombre)
		insert into socio.obraSocUsr(id_dat_os,num_socio) values (@id_os,@num_socio)
	end
	else
	begin
		exec socio.agregarObSocial @nombre,@tel_em,@id_os
		--set @id_os = (select obraSocial.id from socio.obraSocial where @nombre = nombre)
		insert into socio.obraSocUsr(id_dat_os,num_socio) values (@id_os,@num_socio)
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
	@tel_em		varchar(20),
	--@saldo		decimal(8,2),
	@num_OS		varchar(20),
	@nomOS		varchar(50),
	@telOS		varchar(50)
	)
as
begin
	declare @id_os int
	--set @id_os = (select obraSocial.id from socio.obraSocial where @nomOS = obraSocial.nombre collate modern_spanish_ci_ai) 
	if( @nomOs not in (select obraSocial.nombre from socio.obraSocial))
	begin
		exec socio.agregarObSocial @nomOS,@telOS,@id_os
	end
	if(@dni not in(select persona.dni from socio.persona))
	begin
		exec socio.cargarSocioOS @nomOS,@num_OS,@telOS
		set @id_os = (select obraSocUsr.id from socio.obraSocUsr where @num_OS = obraSocUsr.num_socio)
		insert into socio.persona(nombre,apellido,dni,email,fec_nacimiento,telefono,tel_em,saldo_actual,id_obrSoc_usr) 
		values (@nombre,@apellido,@dni,@email,@f_nac,@tel,@tel_em,0,@id_os)
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
	@descr varchar(100),
	@id_est int output
as
begin
	insert into socio.estadoInscripcion(estado) values(@descr)
	set @id_est = (select estadoInscripcion.estado from socio.estadoInscripcion where @descr = estadoInscripcion.estado)
	return @id_est
end
-- GRUPO FAMILIAR
create or alter procedure socio.agregarGrupoFamiliar
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