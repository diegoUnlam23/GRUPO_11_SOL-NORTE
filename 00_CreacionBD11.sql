/*
	- Consigna:
		Genere store procedures para manejar la inserción, modificado, borrado (si corresponde,
		también debe decidir si determinadas entidades solo admitirán borrado lógico) de cada tabla.
		Los nombres de los store procedures NO deben comenzar con “SP”.
		Algunas operaciones implicarán store procedures que involucran varias tablas, uso de
		transacciones, etc. Puede que incluso realicen ciertas operaciones mediante varios SPs.
		Asegúrense de que los comentarios que acompañen al código lo expliquen.
		Genere esquemas para organizar de forma lógica los componentes del sistema y aplique esto
		en la creación de objetos. NO use el esquema “dbo”.
		Todos los SP creados deben estar acompañados de juegos de prueba. Se espera que
		realicen validaciones básicas en los SP (p/e cantidad mayor a cero, CUIT válido, etc.) y que
		en los juegos de prueba demuestren la correcta aplicación de las validaciones.
	- Fecha de entrega: 17/06/2025
	- Número de comisión: 2900 
	- Número de grupo: 11
	- Nombre de la materia: Bases de Datos Aplicadas
	- Integrantes:
		- Costanzo, Marcos Ezequiel - 40955907
		- Sanchez, Diego Mauricio - 46361081
*/

-- Creación de Base de Datos
create database Com2900G11;
go

use Com2900G11;
go

-- Creación de Esquemas
create schema empleado; --TABLAS Y SP PARA PROFESORES
create schema general; -- TABLAS Y SP QUE USAN TODOS LOS SCHEMAS
create schema socio; -- TABLAS Y SP PARA EL USO DE LOS SOCIOS
go

---------------------------------------------------------------------------
------------------------------ TABLAS SOCIO -------------------------------
---------------------------------------------------------------------------
create table socio.datos_obra_social
(
	id					int primary key identity(1,1),
	nombre				varchar(50) NOT NULL,
	telefono_emergencia	varchar(50) NOT NULL
);

-- Obra Social Persona
create table socio.obra_social_persona
(
	id 			 int primary key identity(1,1),
	id_datos_os	 int NOT NULL,
	numero_socio varchar(50) NOT NULL,
	foreign key (id_datos_os) references socio.datos_obra_social(id) 
);
go

-- Persona
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
	id_obra_social_persona	int,
	foreign key (id_obra_social_persona) references socio.obra_social_persona(id)
);

-- Grupo Familiar
create table socio.grupo_familiar
(
	id							int identity(1,1),
	id_persona					int NOT NULL,
	es_responsable				bit default 0,
	relacion_con_responsable	varchar(20) NOT NULL,
	primary key (id, id_persona),
	foreign key (id_persona) references socio.persona(id)
);
go
---------------------------------------------------------------------------
---------------------------- FIN TABLAS SOCIO -----------------------------
---------------------------------------------------------------------------


---------------------------------------------------------------------------
-------------------- TABLAS CUENTA ACCESO Y EMPLEADO ----------------------
---------------------------------------------------------------------------
-- Rol
create table general.rol
(
	id				int primary key identity(1,1),
	descripcion		varchar(100) NOT NULL
);

-- Puesto
create table empleado.puesto
(
	id 			int primary key identity(1,1),
	descripcion	varchar(100) NOT NULL
);

-- Empleado
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

-- Cuenta Acceso
create table general.cuenta_acceso
(
	id						int primary key identity(1,1),
	usuario					varchar(50) NOT NULL,
	hash_contraseña			varchar(50) NOT NULL,
	vigencia_contraseña		date NOT NULL,
	id_rol					int NOT NULL,
	id_persona				int,
	id_empleado				int,
	foreign key (id_rol) references general.rol(id),
	foreign key (id_persona) references socio.persona(id),
	foreign key (id_empleado) references empleado.empleado(id)
);
go

---------------------------------------------------------------------------
----------------------- TABLAS INVITADO Y PILETA --------------------------
---------------------------------------------------------------------------
-- Invitado
create table socio.invitado
(
	id						int primary key identity(1,1),
	nombre					varchar(50) NOT NULL,
	apellido				varchar(50) NOT NULL,
	dni						int UNIQUE NOT NULL CHECK(dni > 0),
	id_persona_asociada		int NOT NULL,
	foreign key (id_persona_asociada) references socio.persona(id)
);

-- Tarifa Pileta
create table socio.tarifa_pileta
(
	id		int primary key identity(1,1),
	tipo	varchar(50) COLLATE modern_spanish_CI_AS CHECK(tipo IN('Socio','Invitado')),
	precio	decimal(8,2) NOT NULL check(precio >= 0)
);

-- Registro Pileta
create table socio.registro_pileta
(
	id				int primary key identity(1,1),
	id_persona		int,
	id_invitado 	int,
	fecha			date NOT NULL,
	id_tarifa		int NOT NULL,
	foreign key (id_persona) references socio.persona(id),
	foreign key (id_invitado) references socio.invitado(id),
	foreign key (id_tarifa) references socio.tarifa_pileta(id)
);
go
---------------------------------------------------------------------------
---------------------- FIN TABLAS INVITADO Y PILETA -----------------------
---------------------------------------------------------------------------


---------------------------------------------------------------------------
----------------------- TABLAS INSCRIPCION Y CLASE ------------------------
---------------------------------------------------------------------------
-- Categoria
create table socio.categoria
(
	id			int primary key identity(1,1),
	nombre		varchar(10) NOT NULL,
	costo		decimal(8,2) NOT NULL CHECK(costo > 0),
	edad_min	int NOT NULL,
	edad_max	int NOT NULL CHECK(edad_max > edad_min)
);

-- Estado Inscripcion
create table socio.estado_inscripcion
(
	id		int primary key identity(1,1),
	estado	varchar(50) NOT NULL
);

-- Medio de Pago
create table socio.medio_de_pago
(
	id		int primary key identity(1,1),
	tipo	varchar(50) NOT NULL
);

-- Inscripcion
create table socio.inscripcion
(
	id					int,
	numero_socio		varchar(10) CHECK(id like 'SN-_%'),
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
---------------------------------------------------------------------------
--------------------- FIN TABLAS INSCRIPCION Y CLASE ----------------------
---------------------------------------------------------------------------


---------------------------------------------------------------------------
------------------------ TABLAS CLASE / ACTIVIDAD -------------------------
---------------------------------------------------------------------------
-- Actividad
create table general.actividad
(
	id		int primary key identity(1,1),
	nombre	varchar(50) NOT NULL,
	costo	decimal(8,2) NOT NULL
);

-- Actividad Extra
create table general.actividad_extra
(
	id		int primary key identity(1,1),
	nombre	varchar(50) NOT NULL,
	costo	decimal(8,2) NOT NULL
);

-- Dia Semana
create table general.dia_semana
(
	id		int primary key identity(1,1),
	nombre	varchar(50) NOT NULL
);

-- Inscripcion Actividad
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

-- Clase
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
---------------------------------------------------------------------------
---------------------- FIN TABLAS CLASE / ACTIVIDAD -----------------------
---------------------------------------------------------------------------


---------------------------------------------------------------------------
------------------------- TABLAS PAGO Y FACTURA ---------------------------
---------------------------------------------------------------------------
-- Cuenta Corriente
create table socio.cuenta_corriente
(
	id			int primary key identity(1,1),
	id_persona	int NOT NULL,
	saldo		decimal(8,2),
	foreign key (id_persona) references socio.persona(id)
);

-- Estado Factura
create table socio.estado_factura 
(
	id				int primary key identity(1,1),
	descripcion		varchar(50) NOT NULL
);

-- Factura
create table socio.factura
(
	id						int primary key identity(1,1),
	fecha_generacion		date NOT NULL,
	fecha_vencimiento_1		date NOT NULL,
	fecha_vencimiento_2		date NOT NULL,
	monto					decimal(8,2),
	descripcion				varchar(100) NOT NULL,
	id_inscripcion			int,
	id_registro_pileta		int,
	id_estado_factura		int NOT NULL,
	foreign key (id_inscripcion) references socio.inscripcion(id),
	foreign key (id_registro_pileta) references socio.registro_pileta(id),
	foreign key (id_estado_factura) references socio.estado_factura(id)
);

-- Item Factura
create table socio.item_factura
(
	id			int primary key identity(1,1),
	id_factura 	int NOT NULL,
	monto		decimal(8,2) NOT NULL,
	tipo_item	varchar(50) NOT NULL,
	foreign key (id_factura) references socio.factura(id)
);

-- Pago
create table socio.pago
(
	id						int primary key identity (1,1),
	fecha_pago				date NOT NULL,
	monto					decimal(8,2) NOT NULL,
	es_debito_automatico	bit default 0,
	id_factura				int NOT NULL,
	foreign key (id_factura) references socio.factura(id)
);

-- Tipo Reembolso
create table socio.tipo_reembolso
(
	id				int primary key identity (1,1),
	descripcion		varchar(50) NOT NULL
);

-- Reembolso
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

-- Movimiento Cuenta
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
---------------------------------------------------------------------------
----------------------- FIN TABLAS PAGO Y FACTURA -------------------------
---------------------------------------------------------------------------


---------------------------------------------------------------------------
---------------------------- PROCEDIMIENTOS -------------------------------
---------------------------------------------------------------------------

/*************************************************************************/
/************************ INICIO DATOS OBRA SOCIAL ***********************/
/*************************************************************************/
-- INSERT
create or alter procedure socio.agregarDatosObraSocial
    @nombre varchar(50),
    @telefono_emergencia varchar(50)
as
begin
    -- Validaciones básicas
    if (ltrim(rtrim(@nombre)) = '' or ltrim(rtrim(@telefono_emergencia)) = '')
    begin
        print 'El nombre y el teléfono de emergencia no pueden estar vacíos.';
        return;
    end

    -- Validar que no exista otra obra social con el mismo nombre
    if exists (select 1 from socio.datos_obra_social where nombre = @nombre)
    begin
        print 'Ya existe una obra social con ese nombre.';
        return;
    end

    -- Insertar la nueva obra social
    insert into socio.datos_obra_social (nombre, telefono_emergencia)
    values (@nombre, @telefono_emergencia);
end

-- UPDATE
create or alter procedure socio.actualizarDatosObraSocial
    @id int,
    @nuevo_nombre varchar(50),
    @nuevo_telefono_emergencia varchar(50)
as
begin
    -- Validaciones básicas
    if not exists (select 1 from socio.datos_obra_social where id = @id)
    begin
        print 'No existe una obra social con ese ID.';
        return;
    end

    if (ltrim(rtrim(@nuevo_nombre)) = '' or ltrim(rtrim(@nuevo_telefono_emergencia)) = '')
    begin
        print 'El nuevo nombre y el nuevo teléfono de emergencia no pueden estar vacíos.';
        return;
    end

    -- Validar que no haya otra obra social con el mismo nombre
    if exists (select 1 from socio.datos_obra_social where nombre = @nuevo_nombre and id <> @id)
    begin
        print 'Ya existe otra obra social con ese nombre.';
        return;
    end

    -- Actualizar la obra social
    update socio.datos_obra_social
    set nombre = @nuevo_nombre,
        telefono_emergencia = @nuevo_telefono_emergencia
    where id = @id;
end

-- DELETE
create or alter procedure socio.eliminarDatosObraSocial
    @id int
as
begin
    -- Validar que exista la obra social
    if not exists (select 1 from socio.datos_obra_social where id = @id)
    begin
        print 'No existe una obra social con ese ID.';
        return;
    end

    -- Validar que no esté siendo usada en otra tabla
    if exists (select 1 from socio.obra_social_persona where id_datos_os = @id)
    begin
        print 'No se puede eliminar la obra social porque está vinculada a una persona.';
        return;
    end

    -- Eliminar la obra social
    delete from socio.datos_obra_social where id = @id;
end
/*************************************************************************/
/************************* FIN DATOS OBRA SOCIAL *************************/
/*************************************************************************/

/*************************************************************************/
/*********************** INICIO OBRA SOCIAL PERSONA **********************/
/*************************************************************************/
-- INSERT
create or alter procedure socio.agregarObraSocialPersona
    @id_datos_os int,
    @numero_socio varchar(50)
as
begin
    -- Validaciones básicas
    if not exists (select 1 from socio.datos_obra_social where id = @id_datos_os)
    begin
        print 'No existe una obra social con ese ID.';
        return;
    end

    if (ltrim(rtrim(@numero_socio)) = '')
    begin
        print 'El número de socio no puede estar vacío.';
        return;
    end

    -- Insertar la obra social de la persona
    insert into socio.obra_social_persona (id_datos_os, numero_socio)
    values (@id_datos_os, @numero_socio);
end

-- UPDATE
create or alter procedure socio.actualizarObraSocialPersona
    @id int,
    @nuevo_id_datos_os int,
    @nuevo_numero_socio varchar(50)
as
begin
    -- Validar existencia del registro a actualizar
    if not exists (select 1 from socio.obra_social_persona where id = @id)
    begin
        print 'No existe una obra social persona con ese ID.';
        return;
    end

    -- Validar que la nueva obra social exista
    if not exists (select 1 from socio.datos_obra_social where id = @nuevo_id_datos_os)
    begin
        print 'La nueva obra social especificada no existe.';
        return;
    end

    if (ltrim(rtrim(@nuevo_numero_socio)) = '')
    begin
        print 'El número de socio no puede estar vacío.';
        return;
    end

    -- Actualizar la obra social de la persona
    update socio.obra_social_persona
    set id_datos_os = @nuevo_id_datos_os,
        numero_socio = @nuevo_numero_socio
    where id = @id;
end

-- DELETE
create or alter procedure socio.eliminarObraSocialPersona
    @id int
as
begin
    -- Validar existencia del registro a eliminar
    if not exists (select 1 from socio.obra_social_persona where id = @id)
    begin
        print 'No existe una obra social persona con ese ID.';
        return;
    end

    -- Validar que no esté vinculada a una persona
    if exists (select 1 from socio.persona where id_obra_social_persona = @id)
    begin
        print 'No se puede eliminar porque está vinculada a una persona.';
        return;
    end

    -- Eliminar la obra social de la persona
    delete from socio.obra_social_persona where id = @id;
end
/*************************************************************************/
/************************ FIN OBRA SOCIAL PERSONA ************************/
/*************************************************************************/

/*************************************************************************/
/***************************** INICIO PERSONA ****************************/
/*************************************************************************/
-- INSERT
create or alter procedure socio.agregarPersona
    @nombre                 varchar(50),
    @apellido               varchar(50),
    @dni                    int,
    @email                  varchar(254),
    @fecha_nacimiento       date,
    @telefono               varchar(20),
    @telefono_emergencia    varchar(20),
    @id_obra_social_persona int = null
as
begin
    set nocount on;

    if (@dni <= 0)
    begin
        print 'El DNI debe ser mayor a cero.';
        return;
    end

    if (@email not like '_%@_%._%')
    begin
        print 'El email no tiene un formato válido.';
        return;
    end

    begin try
        begin transaction;

        -- Insertar persona
        insert into socio.persona
            (nombre, apellido, dni, email, fecha_nacimiento, telefono, telefono_emergencia, id_obra_social_persona)
        values
            (@nombre, @apellido, @dni, @email, @fecha_nacimiento, @telefono, @telefono_emergencia, @id_obra_social_persona);

        declare @nuevo_id_persona int = scope_identity();

		-- Creamos cuenta corriente para la persona
		exec socio.insertarCuentaCorriente
			@id_persona = @nuevo_id_persona,
			@saldo = 0;

        commit transaction;

        print 'Persona agregada correctamente.';

    end try
    begin catch
        rollback transaction;
        declare @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
        print 'Error al agregar persona y cuenta corriente: ' + @ErrorMessage;
        return;
    end catch
end
go

-- UPDATE
create or alter procedure socio.actualizarPersona
    @id                     int,
    @nombre                 varchar(50),
    @apellido               varchar(50),
    @email                  varchar(254),
    @telefono               varchar(20),
    @telefono_emergencia    varchar(20),
    @id_obra_social_persona int = null
as
begin
    if not exists (select 1 from socio.persona where id = @id)
    begin
        print 'No existe una persona con el ID especificado.'
        return;
    end

    if(@email not like '_%@_%._%')
    begin
        print 'El email no tiene un formato válido.'
        return;
    end

    update socio.persona
    set nombre = @nombre,
        apellido = @apellido,
        email = @email,
        telefono = @telefono,
        telefono_emergencia = @telefono_emergencia,
        id_obra_social_persona = @id_obra_social_persona
    where id = @id

    print 'Persona actualizada correctamente.'
end
go

-- DELETE
-- No permitido en el sistema
/*************************************************************************/
/****************************** FIN PERSONA ******************************/
/*************************************************************************/

/*************************************************************************/
/************************* INICIO GRUPO FAMILIAR *************************/
/*************************************************************************/
-- INSERT
create or alter procedure socio.agregarGrupoFamiliar
    @id_persona int,
    @es_responsable bit = 0,
    @relacion_con_responsable varchar(20)
as
begin
    -- Validar que exista la persona
    if not exists (select 1 from socio.persona where id = @id_persona)
    begin
        print 'No existe una persona con el ID especificado.'
        return;
    end

    -- Validar relación no vacía
    if @relacion_con_responsable = ''
    begin
        print 'La relación con el responsable no puede ser vacía.'
        return;
    end

    insert into socio.grupo_familiar (id_persona, es_responsable, relacion_con_responsable)
    values (@id_persona, @es_responsable, @relacion_con_responsable)

    print 'Miembro del grupo familiar agregado correctamente.'
end
go

-- UPDATE
create or alter procedure socio.actualizarGrupoFamiliar
    @id int,
    @id_persona int,
    @es_responsable bit,
    @relacion_con_responsable varchar(20)
as
begin
    if not exists (select 1 from socio.grupo_familiar where id = @id)
    begin
        print 'No existe un miembro del grupo familiar con el ID especificado.'
        return;
    end

    if not exists (select 1 from socio.persona where id = @id_persona)
    begin
        print 'No existe una persona con el ID especificado.'
        return;
    end

    if @relacion_con_responsable = ''
    begin
        print 'La relación con el responsable no puede ser vacía.'
        return;
    end

    update socio.grupo_familiar
    set id_persona = @id_persona,
        es_responsable = @es_responsable,
        relacion_con_responsable = @relacion_con_responsable
    where id = @id

    print 'Miembro del grupo familiar actualizado correctamente.'
end
go

-- DELETE
create or alter procedure socio.eliminarGrupoFamiliar
    @id int
as
begin
    if not exists (select 1 from socio.grupo_familiar where id = @id)
    begin
        print 'No existe un miembro del grupo familiar con el ID especificado.'
        return;
    end

    delete from socio.grupo_familiar where id = @id

    print 'Miembro del grupo familiar eliminado correctamente.'
end
go
/*************************************************************************/
/*************************** FIN GRUPO FAMILIAR **************************/
/*************************************************************************/

/*************************************************************************/
/**************************** INICIO INVITADO ****************************/
/*************************************************************************/
-- INSERT
create or alter procedure socio.agregarInvitado
    @nombre varchar(50),
    @apellido varchar(50),
    @dni int,
    @id_persona_asociada int
as
begin
    -- Validar que la persona asociada exista
    if not exists (select 1 from socio.persona where id = @id_persona_asociada)
    begin
        print 'No existe una persona asociada con ese ID.'
        return;
    end

    -- Validar dni positivo
    if @dni <= 0
    begin
        print 'El DNI debe ser mayor a cero.'
        return;
    end

    -- Validar que el DNI no esté repetido
    if exists (select 1 from socio.invitado where dni = @dni)
    begin
        print 'Ya existe un invitado con ese DNI.'
        return;
    end

    insert into socio.invitado (nombre, apellido, dni, id_persona_asociada)
    values (@nombre, @apellido, @dni, @id_persona_asociada)

    print 'Invitado agregado correctamente.'
end
go

-- UPDATE
create or alter procedure socio.actualizarInvitado
    @id int,
    @nombre varchar(50),
    @apellido varchar(50),
    @dni int,
    @id_persona_asociada int
as
begin
    -- Validar que el invitado exista
    if not exists (select 1 from socio.invitado where id = @id)
    begin
        print 'No existe un invitado con ese ID.'
        return;
    end

    -- Validar que la persona asociada exista
    if not exists (select 1 from socio.persona where id = @id_persona_asociada)
    begin
        print 'No existe una persona asociada con ese ID.'
        return;
    end

    -- Validar dni positivo
    if @dni <= 0
    begin
        print 'El DNI debe ser mayor a cero.'
        return;
    end

    -- Validar que no haya otro invitado con el mismo DNI (excepto este)
    if exists (select 1 from socio.invitado where dni = @dni and id <> @id)
    begin
        print 'Ya existe otro invitado con ese DNI.'
        return;
    end

    update socio.invitado
    set nombre = @nombre,
        apellido = @apellido,
        dni = @dni,
        id_persona_asociada = @id_persona_asociada
    where id = @id

    print 'Invitado actualizado correctamente.'
end
go

-- DELETE
-- No permitido en el sistema
/*************************************************************************/
/***************************** FIN INVITADO ******************************/
/*************************************************************************/

/*************************************************************************/
/************************* INICIO TARIFA PILETA **************************/
/*************************************************************************/
-- INSERT
create or alter procedure socio.agregarTarifaPileta
    @tipo varchar(50),
    @precio decimal(8,2)
as
begin
    -- Validar que tipo sea 'Socio' o 'Invitado'
    if @tipo not in ('Socio', 'Invitado')
    begin
        print 'El tipo debe ser "Socio" o "Invitado".'
        return;
    end

    -- Validar precio no negativo
    if @precio < 0
    begin
        print 'El precio no puede ser negativo.'
        return;
    end

    insert into socio.tarifa_pileta (tipo, precio)
    values (@tipo, @precio)

    print 'Tarifa agregada correctamente.'
end
go

-- UPDATE
create or alter procedure socio.actualizarTarifaPileta
    @id int,
    @tipo varchar(50),
    @precio decimal(8,2)
as
begin
    -- Validar que la tarifa exista
    if not exists (select 1 from socio.tarifa_pileta where id = @id)
    begin
        print 'No existe una tarifa con ese ID.'
        return;
    end

    -- Validar tipo
    if @tipo not in ('Socio', 'Invitado')
    begin
        print 'El tipo debe ser "Socio" o "Invitado".'
        return;
    end

    -- Validar precio
    if @precio < 0
    begin
        print 'El precio no puede ser negativo.'
        return;
    end

    update socio.tarifa_pileta
    set tipo = @tipo,
        precio = @precio
    where id = @id

    print 'Tarifa actualizada correctamente.'
end
go

-- DELETE
create or alter procedure socio.eliminarTarifaPileta
    @id int
as
begin
    -- Validar que la tarifa exista
    if not exists (select 1 from socio.tarifa_pileta where id = @id)
    begin
        print 'No existe una tarifa con ese ID.'
        return;
    end

    -- Validar que no haya registros en registro_pileta para esta tarifa
    if exists (select 1 from socio.registro_pileta where id_tarifa = @id)
    begin
        print 'No se puede eliminar la tarifa porque está asociada a registros de la pileta.'
        return;
    end

    delete from socio.tarifa_pileta where id = @id

    print 'Tarifa eliminada correctamente.'
end
go
/*************************************************************************/
/*************************** FIN TARIFA PILETA ***************************/
/*************************************************************************/

/*************************************************************************/
/************************ INICIO REGISTRO PILETA *************************/
/*************************************************************************/
-- INSERT
create or alter procedure socio.agregarRegistroPileta
    @id_persona int = NULL,
    @id_invitado int = NULL,
    @fecha date,
    @id_tarifa int
as
begin
    -- Validar que exactamente uno entre persona e invitado esté presente
    if (@id_persona is null and @id_invitado is null)
    begin
        print 'Debe proporcionar id_persona o id_invitado.'
        return;
    end

    if (@id_persona is not null and @id_invitado is not null)
    begin
        print 'No puede proporcionar ambos id_persona y id_invitado a la vez.'
        return;
    end

    -- Validar persona si está presente
    if (@id_persona is not null)
    begin
        if not exists (select 1 from socio.persona where id = @id_persona)
        begin
            print 'No existe persona con ese ID.'
            return;
        end
    end

    -- Validar invitado si está presente
    if (@id_invitado is not null)
    begin
        if not exists (select 1 from socio.invitado where id = @id_invitado)
        begin
            print 'No existe invitado con ese ID.'
            return;
        end
    end

    -- Validar tarifa pileta
    if not exists (select 1 from socio.tarifa_pileta where id = @id_tarifa)
    begin
        print 'No existe tarifa pileta con ese ID.'
        return;
    end

    insert into socio.registro_pileta (id_persona, id_invitado, fecha, id_tarifa)
    values (@id_persona, @id_invitado, @fecha, @id_tarifa)

    print 'Registro pileta agregado correctamente.'
end
go

-- UPDATE
create or alter procedure socio.actualizarRegistroPileta
    @id int,
    @id_persona int = NULL,
    @id_invitado int = NULL,
    @fecha date,
    @id_tarifa int
as
begin
    -- Validar que el registro exista
    if not exists (select 1 from socio.registro_pileta where id = @id)
    begin
        print 'No existe un registro de pileta con ese ID.'
        return;
    end

    -- Validar que exactamente uno entre persona e invitado esté presente
    if (@id_persona is null and @id_invitado is null)
    begin
        print 'Debe proporcionar id_persona o id_invitado.'
        return;
    end

    if (@id_persona is not null and @id_invitado is not null)
    begin
        print 'No puede proporcionar ambos id_persona y id_invitado a la vez.'
        return;
    end

    -- Validar persona si está presente
    if (@id_persona is not null)
    begin
        if not exists (select 1 from socio.persona where id = @id_persona)
        begin
            print 'No existe persona con ese ID.'
            return;
        end
    end

    -- Validar invitado si está presente
    if (@id_invitado is not null)
    begin
        if not exists (select 1 from socio.invitado where id = @id_invitado)
        begin
            print 'No existe invitado con ese ID.'
            return;
        end
    end

    -- Validar tarifa pileta
    if not exists (select 1 from socio.tarifa_pileta where id = @id_tarifa)
    begin
        print 'No existe tarifa pileta con ese ID.'
        return;
    end

    -- Realizar actualización
    update socio.registro_pileta
    set id_persona = @id_persona,
        id_invitado = @id_invitado,
        fecha = @fecha,
        id_tarifa = @id_tarifa
    where id = @id

    print 'Registro pileta actualizado correctamente.'
end
go

-- DELETE
-- No permitido en el sistema
/*************************************************************************/
/************************* FIN REGISTRO PILETA ***************************/
/*************************************************************************/

/*************************************************************************/
/*************************** INICIO CATEGORIA ****************************/
/*************************************************************************/
-- INSERT
create or alter procedure socio.insertarCategoria
    @nombre varchar(10),
    @costo decimal(8,2),
    @edad_min int,
    @edad_max int
as
begin
    -- Validar que el costo sea mayor a 0
    if @costo <= 0
    begin
        print 'El costo debe ser mayor a 0.';
        return;
    end

    -- Validar que la edad máxima sea mayor que la edad mínima
    if @edad_max <= @edad_min
    begin
        print 'La edad máxima debe ser mayor que la edad mínima.';
        return;
    end

    -- Insertar la nueva categoría
    insert into socio.categoria (nombre, costo, edad_min, edad_max)
    values (@nombre, @costo, @edad_min, @edad_max);

    print 'Categoría insertada correctamente.';
end
go

-- UPDATE
create or alter procedure socio.actualizarCategoria
    @id_categoria int,
    @nombre varchar(10),
    @costo decimal(8,2),
    @edad_min int,
    @edad_max int
as
begin
    -- Validar que la categoría exista
    if not exists (select 1 from socio.categoria where id = @id_categoria)
    begin
        print 'La categoría no existe.';
        return;
    end

    -- Validar que el costo sea mayor a 0
    if @costo <= 0
    begin
        print 'El costo debe ser mayor a 0.';
        return;
    end

    -- Validar que la edad máxima sea mayor que la edad mínima
    if @edad_max <= @edad_min
    begin
        print 'La edad máxima debe ser mayor que la edad mínima.';
        return;
    end

    -- Actualizar la categoría
    update socio.categoria
    set nombre = @nombre,
        costo = @costo,
        edad_min = @edad_min,
        edad_max = @edad_max
    where id = @id_categoria;

    print 'Categoría actualizada correctamente.';
end
go

-- DELETE
create or alter procedure socio.eliminarCategoria
    @id_categoria int
as
begin
    -- Validar que la categoría exista
    if not exists (select 1 from socio.categoria where id = @id_categoria)
    begin
        print 'La categoría no existe.';
        return;
    end

    -- Eliminar la categoría
    delete from socio.categoria
    where id = @id_categoria;

    print 'Categoría eliminada correctamente.';
end
go
/*************************************************************************/
/**************************** FIN CATEGORIA ******************************/
/*************************************************************************/

/*************************************************************************/
/********************** INICIO ESTADO INSCRIPCION ************************/
/*************************************************************************/
-- INSERT
create or alter procedure socio.insertarEstadoInscripcion
    @estado varchar(50)
as
begin
    -- Validar que el estado no esté vacío
    if @estado is null or ltrim(rtrim(@estado)) = ''
    begin
        print 'El nombre del estado no puede estar vacío.'
        return;
    end

    -- Validar que no exista un estado igual (case insensitive)
    if exists (select 1 from socio.estado_inscripcion where lower(estado) = lower(@estado))
    begin
        print 'Ya existe un estado con ese nombre.'
        return;
    end

    insert into socio.estado_inscripcion (estado)
    values (@estado)

    print 'Estado de inscripción insertado correctamente.'
end
go

-- UPDATE
create or alter procedure socio.actualizarEstadoInscripcion
    @id int,
    @estado varchar(50)
as
begin
    -- Validar que el estado de inscripción exista
    if not exists (select 1 from socio.estado_inscripcion where id = @id)
    begin
        print 'No existe un estado de inscripción con ese ID.'
        return;
    end

    -- Validar que el nuevo nombre no esté vacío
    if @estado is null or ltrim(rtrim(@estado)) = ''
    begin
        print 'El nombre del estado no puede estar vacío.'
        return;
    end

    -- Validar que no exista otro estado con el mismo nombre (case insensitive)
    if exists (select 1 from socio.estado_inscripcion where lower(estado) = lower(@estado) and id <> @id)
    begin
        print 'Ya existe otro estado con ese nombre.'
        return;
    end

    update socio.estado_inscripcion
    set estado = @estado
    where id = @id

    print 'Estado de inscripción actualizado correctamente.'
end
go

-- DELETE
create or alter procedure socio.eliminarEstadoInscripcion
    @id int
as
begin
    -- Validar que el estado de inscripción exista
    if not exists (select 1 from socio.estado_inscripcion where id = @id)
    begin
        print 'No existe un estado de inscripción con ese ID.'
        return;
    end

    -- Validar que no haya inscripciones asociadas a este estado
    if exists (select 1 from socio.inscripcion where id_estado = @id)
    begin
        print 'No se puede eliminar el estado porque está asociado a inscripciones.'
        return;
    end

    -- Eliminar el estado de inscripción
    delete from socio.estado_inscripcion where id = @id

    print 'Estado de inscripción eliminado correctamente.'
end
go
/*************************************************************************/
/*********************** FIN ESTADO INSCRIPCION **************************/
/*************************************************************************/

/*************************************************************************/
/************************ INICIO MEDIO DE PAGO ***************************/
/*************************************************************************/
-- INSERT
create or alter procedure socio.insertarMedioDePago
    @tipo varchar(50)
as
begin
    -- Validar que el tipo no esté vacío
    if @tipo is null or ltrim(rtrim(@tipo)) = ''
    begin
        print 'El tipo de medio de pago no puede estar vacío.'
        return;
    end

    -- Validar que no exista un medio de pago con el mismo tipo (único)
    if exists (select 1 from socio.medio_de_pago where tipo = @tipo)
    begin
        print 'Ya existe un medio de pago con ese tipo.'
        return;
    end

    insert into socio.medio_de_pago (tipo)
    values (@tipo)

    print 'Medio de pago insertado correctamente.'
end
go

-- UPDATE
create or alter procedure socio.actualizarMedioDePago
    @id int,
    @tipo varchar(50)
as
begin
    -- Validar que el medio de pago exista
    if not exists (select 1 from socio.medio_de_pago where id = @id)
    begin
        print 'No existe un medio de pago con ese ID.'
        return;
    end

    -- Validar que el tipo no esté vacío
    if @tipo is null or ltrim(rtrim(@tipo)) = ''
    begin
        print 'El tipo de medio de pago no puede estar vacío.'
        return;
    end

    -- Validar que no haya otro medio de pago con el mismo tipo
    if exists (select 1 from socio.medio_de_pago where tipo = @tipo and id <> @id)
    begin
        print 'Ya existe otro medio de pago con ese tipo.'
        return;
    end

    update socio.medio_de_pago
    set tipo = @tipo
    where id = @id

    print 'Medio de pago actualizado correctamente.'
end
go

-- DELETE
create or alter procedure socio.eliminarMedioDePago
    @id int
as
begin
    -- Validar que el medio de pago exista
    if not exists (select 1 from socio.medio_de_pago where id = @id)
    begin
        print 'No existe un medio de pago con ese ID.'
        return;
    end

    -- Validar que no haya inscripciones usando este medio de pago
    if exists (select 1 from socio.inscripcion where id_medio_pago = @id)
    begin
        print 'No se puede eliminar el medio de pago porque está asociado a inscripciones.'
        return;
    end

    delete from socio.medio_de_pago where id = @id

    print 'Medio de pago eliminado correctamente.'
end
go
/*************************************************************************/
/************************* FIN MEDIO DE PAGO *****************************/
/*************************************************************************/

/*************************************************************************/
/************************* INICIO INSCRIPCION ****************************/
/*************************************************************************/
-- INSERT
create or alter procedure socio.insertarInscripcion
    @numero_socio varchar(10),
    @id_persona int,
    @id_grupo_familiar int = null,
    @fecha_inicio datetime,
    @fecha_baja datetime = null,
    @id_estado int,
    @id_categoria int,
    @id_medio_pago int
as
begin
    -- Validar formato del número de socio
    if @numero_socio is null or @numero_socio not like 'SN-%'
    begin
        print 'El número de socio debe comenzar con "SN-".'
        return;
    end

    -- Validar que no exista una inscripción con el mismo número de socio
    if exists (select 1 from socio.inscripcion where numero_socio = @numero_socio)
    begin
        print 'Ya existe una inscripción con ese número de socio.'
        return;
    end

    -- Validar que la persona exista
    if not exists (select 1 from socio.persona where id = @id_persona)
    begin
        print 'No existe la persona indicada.'
        return;
    end

    -- Validar que si se recibe id_grupo_familiar, exista la relación con id_persona
    if @id_grupo_familiar is not null
    begin
        if not exists (select 1 from socio.grupo_familiar where id = @id_grupo_familiar and id_persona = @id_persona)
        begin
            print 'No existe el grupo familiar para esa persona.'
            return;
        end
    end

    -- Validar que el estado exista
    if not exists (select 1 from socio.estado_inscripcion where id = @id_estado)
    begin
        print 'No existe el estado de inscripción indicado.'
        return;
    end

    -- Validar que la categoría exista
    if not exists (select 1 from socio.categoria where id = @id_categoria)
    begin
        print 'No existe la categoría indicada.'
        return;
    end

    -- Validar que el medio de pago exista
    if not exists (select 1 from socio.medio_de_pago where id = @id_medio_pago)
    begin
        print 'No existe el medio de pago indicado.'
        return;
    end

    -- Validar que fecha_baja sea mayor o igual a fecha_inicio si no es NULL
    if @fecha_baja is not null and @fecha_baja < @fecha_inicio
    begin
        print 'La fecha de baja no puede ser anterior a la fecha de inicio.'
        return;
    end

    -- Insertar inscripción
    insert into socio.inscripcion
        (numero_socio, id_persona, id_grupo_familiar, fecha_inicio, fecha_baja, id_estado, id_categoria, id_medio_pago)
    values
        (@numero_socio, @id_persona, @id_grupo_familiar, @fecha_inicio, @fecha_baja, @id_estado, @id_categoria, @id_medio_pago)

    print 'Inscripción insertada correctamente.'
end
go

-- UPDATE
create or alter procedure socio.actualizarInscripcion
    @id int,
    @id_grupo_familiar int = null,
    @fecha_inicio datetime,
    @fecha_baja datetime = null,
    @id_estado int,
    @id_categoria int,
    @id_medio_pago int
as
begin
    -- Validar que la inscripción exista
    if not exists (select 1 from socio.inscripcion where id = @id)
    begin
        print 'No existe una inscripción con ese ID.'
        return;
    end

    -- Validar que la categoría exista
    if not exists (select 1 from socio.categoria where id = @id_categoria)
    begin
        print 'No existe la categoría indicada.'
        return;
    end

    -- Validar que el estado exista
    if not exists (select 1 from socio.estado_inscripcion where id = @id_estado)
    begin
        print 'No existe el estado de inscripción indicado.'
        return;
    end

    -- Validar que el medio de pago exista
    if not exists (select 1 from socio.medio_de_pago where id = @id_medio_pago)
    begin
        print 'No existe el medio de pago indicado.'
        return;
    end

    -- Validar que grupo familiar exista si se provee
    if @id_grupo_familiar is not null
    begin
        if not exists (select 1 from socio.grupo_familiar where id = @id_grupo_familiar)
        begin
            print 'No existe el grupo familiar indicado.'
            return;
        end
    end

    -- Validar lógica de fechas
    if @fecha_baja is not null and @fecha_baja < @fecha_inicio
    begin
        print 'La fecha de baja no puede ser anterior a la fecha de inicio.'
        return;
    end

    -- Actualizar campos permitidos
    update socio.inscripcion
    set
        id_grupo_familiar = @id_grupo_familiar,
        fecha_inicio = @fecha_inicio,
        fecha_baja = @fecha_baja,
        id_estado = @id_estado,
        id_categoria = @id_categoria,
        id_medio_pago = @id_medio_pago
    where id = @id

    print 'Inscripción actualizada correctamente.'
end
go

-- DELETE
-- No permitido en el sistema
/*************************************************************************/
/************************** FIN INSCRIPCION ******************************/
/*************************************************************************/

/*************************************************************************/
/******************** INICIO INSCRIPCION ACTIVIDAD ***********************/
/*************************************************************************/
-- INSERT
create or alter procedure socio.insertarInscripcionActividad
    @id_inscripcion int,
    @id_actividad int = null,
    @id_actividad_extra int = null,
    @fecha_inscripcion datetime
as
begin
    -- Validar que exista la inscripción
    if not exists (select 1 from socio.inscripcion where id = @id_inscripcion)
    begin
        print 'No existe una inscripción con ese ID.'
        return;
    end

    -- Validar que al menos una actividad o actividad extra esté presente
    if @id_actividad is null and @id_actividad_extra is null
    begin
        print 'Debe ingresar al menos una actividad o una actividad extra.'
        return;
    end

    -- Si viene actividad, validar que exista
    if @id_actividad is not null and not exists (select 1 from general.actividad where id = @id_actividad)
    begin
        print 'No existe una actividad con ese ID.'
        return;
    end

    -- Si viene actividad extra, validar que exista
    if @id_actividad_extra is not null and not exists (select 1 from general.actividad_extra where id = @id_actividad_extra)
    begin
        print 'No existe una actividad extra con ese ID.'
        return;
    end

    insert into socio.inscripcion_actividad (id_inscripcion, id_actividad, id_actividad_extra, fecha_inscripcion)
    values (@id_inscripcion, @id_actividad, @id_actividad_extra, @fecha_inscripcion)

    print 'Inscripción a actividad creada correctamente.'
end
go

-- UPDATE
create or alter procedure socio.actualizarInscripcionActividad
    @id int,
    @id_inscripcion int,
    @id_actividad int = null,
    @id_actividad_extra int = null,
    @fecha_inscripcion datetime
as
begin
    -- Validar que exista la inscripción a actividad
    if not exists (select 1 from socio.inscripcion_actividad where id = @id)
    begin
        print 'No existe una inscripción a actividad con ese ID.'
        return;
    end

    -- Validar que exista la inscripción
    if not exists (select 1 from socio.inscripcion where id = @id_inscripcion)
    begin
        print 'No existe una inscripción con ese ID.'
        return;
    end

    -- Validar que al menos una actividad o actividad extra esté presente
    if @id_actividad is null and @id_actividad_extra is null
    begin
        print 'Debe ingresar al menos una actividad o una actividad extra.'
        return;
    end

    -- Si viene actividad, validar que exista
    if @id_actividad is not null and not exists (select 1 from general.actividad where id = @id_actividad)
    begin
        print 'No existe una actividad con ese ID.'
        return;
    end

    -- Si viene actividad extra, validar que exista
    if @id_actividad_extra is not null and not exists (select 1 from general.actividad_extra where id = @id_actividad_extra)
    begin
        print 'No existe una actividad extra con ese ID.'
        return;
    end

    update socio.inscripcion_actividad
    set id_inscripcion = @id_inscripcion,
        id_actividad = @id_actividad,
        id_actividad_extra = @id_actividad_extra,
        fecha_inscripcion = @fecha_inscripcion
    where id = @id

    print 'Inscripción a actividad actualizada correctamente.'
end
go

-- DELETE
create or alter procedure socio.eliminarInscripcionActividad
    @id int
as
begin
    -- Validar que exista la inscripción a actividad
    if not exists (select 1 from socio.inscripcion_actividad where id = @id)
    begin
        print 'No existe una inscripción a actividad con ese ID.'
        return;
    end

    delete from socio.inscripcion_actividad where id = @id

    print 'Inscripción a actividad eliminada correctamente.'
end
go
/*************************************************************************/
/********************* FIN INSCRIPCION ACTIVIDAD *************************/
/*************************************************************************/

/*************************************************************************/
/********************** INICIO CUENTA CORRIENTE **************************/
/*************************************************************************/
-- INSERT
create or alter procedure socio.insertarCuentaCorriente
    @id_persona int,
    @saldo decimal(8,2) = 0
as
begin
    -- Validar que la persona exista
    if not exists (select 1 from socio.persona where id = @id_persona)
    begin
        print 'No existe la persona indicada.'
        return;
    end

    -- Validar que la persona no tenga ya una cuenta corriente (asumiendo relación 1 a 1)
    if exists (select 1 from socio.cuenta_corriente where id_persona = @id_persona)
    begin
        print 'La persona ya tiene una cuenta corriente asociada.'
        return;
    end

    -- Insertar cuenta corriente
    insert into socio.cuenta_corriente (id_persona, saldo)
    values (@id_persona, @saldo)

    print 'Cuenta corriente insertada correctamente.'
end
go

-- UPDATE
create or alter procedure socio.actualizarCuentaCorriente
    @id int,
    @saldo decimal(8,2)
as
begin
    -- Validar que la cuenta exista
    if not exists (select 1 from socio.cuenta_corriente where id = @id)
    begin
        print 'No existe una cuenta corriente con ese ID.'
        return;
    end

    -- Actualizar saldo
    update socio.cuenta_corriente
    set saldo = saldo + @saldo
    where id = @id

    print 'Cuenta corriente actualizada correctamente.'
end
go

-- DELETE
-- No permitido en el sistema
/*************************************************************************/
/************************ FIN CUENTA CORRIENTE ***************************/
/*************************************************************************/

/*************************************************************************/
/*********************** INICIO ESTADO FACTURA ***************************/
/*************************************************************************/
-- INSERT
create or alter procedure socio.insertarEstadoFactura
    @descripcion varchar(50)
as
begin
    -- Validar que la descripción no exista
    if exists (select 1 from socio.estado_factura where descripcion = @descripcion)
    begin
        print 'Ya existe un estado de factura con esa descripción.'
        return;
    end

    insert into socio.estado_factura (descripcion)
    values (@descripcion)

    print 'Estado de factura insertado correctamente.'
end
go

-- UPDATE
create or alter procedure socio.actualizarEstadoFactura
    @id int,
    @descripcion varchar(50)
as
begin
    -- Validar que el estado exista
    if not exists (select 1 from socio.estado_factura where id = @id)
    begin
        print 'No existe un estado de factura con ese ID.'
        return;
    end

    -- Validar que la nueva descripción no esté duplicada
    if exists (select 1 from socio.estado_factura where descripcion = @descripcion and id <> @id)
    begin
        print 'Ya existe otro estado de factura con esa descripción.'
        return;
    end

    update socio.estado_factura
    set descripcion = @descripcion
    where id = @id

    print 'Estado de factura actualizado correctamente.'
end
go

-- DELETE
create or alter procedure socio.eliminarEstadoFactura
    @id int
as
begin
    -- Validar que el estado exista
    if not exists (select 1 from socio.estado_factura where id = @id)
    begin
        print 'No existe un estado de factura con ese ID.'
        return;
    end

    -- Validar que no esté siendo usado en facturas
    if exists (select 1 from socio.factura where id_estado_factura = @id)
    begin
        print 'No se puede eliminar el estado porque está siendo utilizado en alguna factura.'
        return;
    end

    delete from socio.estado_factura
    where id = @id

    print 'Estado de factura eliminado correctamente.'
end
go
/*************************************************************************/
/************************* FIN ESTADO FACTURA ****************************/
/*************************************************************************/

/*************************************************************************/
/********************** INICIO FACTURA CON ITEMS *************************/
/*************************************************************************/
-- INSERT
create or alter procedure socio.insertarFacturaCompleta
    @fecha_generacion date,
    @fecha_vencimiento_1 date,
    @fecha_vencimiento_2 date,
    @descripcion varchar(100),
    @id_inscripcion int = null,
    @id_registro_pileta int = null,
    @id_estado_factura int
as
begin
    set nocount on;

    declare @monto_total decimal(8,2) = 0;
    declare @id_factura int;
	declare @id_cuenta_corriente int;

    -- Validaciones básicas

    if @id_inscripcion is null and @id_registro_pileta is null
    begin
        print 'Error: La factura debe estar asociada a una inscripción, un registro de pileta, o ambos.';
        return;
    end

    if not exists (select 1 from socio.estado_factura where id = @id_estado_factura)
    begin
        print 'Error: No existe el estado de factura indicado.';
        return;
    end

    if @id_inscripcion is not null
    begin
        if not exists (select 1 from socio.inscripcion where id = @id_inscripcion)
        begin
            print 'Error: No existe la inscripción indicada.';
            return;
        end
    end

    if @id_registro_pileta is not null
    begin
        if not exists (select 1 from socio.registro_pileta where id = @id_registro_pileta)
        begin
            print 'Error: No existe el registro de pileta indicado.';
            return;
        end
    end

    if @fecha_vencimiento_1 < @fecha_generacion
    begin
        print 'Error: La primera fecha de vencimiento no puede ser anterior a la fecha de generación.';
        return;
    end

    if @fecha_vencimiento_2 < @fecha_vencimiento_1
    begin
        print 'Error: La segunda fecha de vencimiento no puede ser anterior a la primera fecha de vencimiento.';
        return;
    end

    begin try
        begin transaction;

        -- Calcular monto total para inscripción
        if @id_inscripcion is not null
        begin
            declare @costo_categoria decimal(8,2) = 0;
            select @costo_categoria = c.costo
            from socio.inscripcion i
            join socio.categoria c on i.id_categoria = c.id
            where i.id = @id_inscripcion;

            set @monto_total += isnull(@costo_categoria,0);

            -- Sumar costos de actividades
            declare @monto_actividades decimal(8,2) = 0;
            select @monto_actividades = isnull(sum(a.costo),0)
            from socio.inscripcion_actividad ia
            join socio.actividad a on ia.id_actividad = a.id
            where ia.id_inscripcion = @id_inscripcion;

            set @monto_total += @monto_actividades;

            -- Sumar costos de actividades extras
            declare @monto_actividades_extra decimal(8,2) = 0;
            select @monto_actividades_extra = isnull(sum(ae.costo),0)
            from socio.inscripcion_actividad ia
            join socio.actividad_extra ae on ia.id_actividad_extra = ae.id
            where ia.id_inscripcion = @id_inscripcion
              and ia.id_actividad_extra is not null;

            set @monto_total += @monto_actividades_extra;
        end

        -- Calcular costo de registro_pileta
        if @id_registro_pileta is not null
        begin
            declare @costo_pileta decimal(8,2) = 0;
            select @costo_pileta = costo
            from socio.registro_pileta
            where id = @id_registro_pileta;

            set @monto_total += isnull(@costo_pileta,0);
        end

        -- Insertar factura con monto total calculado
        insert into socio.factura
            (fecha_generacion, fecha_vencimiento_1, fecha_vencimiento_2, monto, descripcion, id_inscripcion, id_registro_pileta, id_estado_factura)
        values
            (@fecha_generacion, @fecha_vencimiento_1, @fecha_vencimiento_2, @monto_total, @descripcion, @id_inscripcion, @id_registro_pileta, @id_estado_factura);

        set @id_factura = scope_identity();

		-- Obtener cuenta corriente
		select @id_cuenta_corriente = id
		from socio.cuenta_corriente
		where id_persona in (
			select id_persona
			from socio.inscripcion
			where id = @id_inscripcion
		);

        if @id_cuenta_corriente is null
        begin
            print 'Error: No se encontró cuenta corriente para la persona asociada.';
            rollback transaction;
            return;
        end

		-- Insertamos el movimiento en la cuenta
		exec socio.insertarMovimientoCuenta
			@id_cuenta_corriente = @id_cuenta_corriente,
			@fecha = getdate(),
			@monto = -@monto_total,
			@id_factura = @id_factura,
			@id_pago = null,
			@id_reembolso = null;

        -- Insertar items

        if @id_inscripcion is not null
        begin
            -- Insertar categoría
            insert into socio.item_factura (id_factura, monto, tipo_item)
            select @id_factura, c.costo, 'Categoría'
            from socio.inscripcion i
            join socio.categoria c on i.id_categoria = c.id
            where i.id = @id_inscripcion;

            -- Insertar actividades
            insert into socio.item_factura (id_factura, monto, tipo_item)
            select @id_factura, a.costo, 'Actividad'
            from socio.inscripcion_actividad ia
            join socio.actividad a on ia.id_actividad = a.id
            where ia.id_inscripcion = @id_inscripcion;

            -- Insertar actividades extras
            insert into socio.item_factura (id_factura, monto, tipo_item)
            select @id_factura, ae.costo, 'Actividad Extra'
            from socio.inscripcion_actividad ia
            join socio.actividad_extra ae on ia.id_actividad_extra = ae.id
            where ia.id_inscripcion = @id_inscripcion
              and ia.id_actividad_extra is not null;
        end

        if @id_registro_pileta is not null
        begin
            insert into socio.item_factura (id_factura, monto, tipo_item)
            select @id_factura, costo, 'Uso de Pileta'
            from socio.registro_pileta
            where id = @id_registro_pileta
              and costo > 0;
        end

        commit transaction;

        print 'Factura e items insertados correctamente.';

    end try
    begin catch
        rollback transaction;
        declare @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
        print 'Error al insertar factura: ' + @ErrorMessage;
        return;
    end catch
end
go

-- UPDATE
-- No permitido en el sistema

-- DELETE
-- No permitido en el sistema
/*************************************************************************/
/************************ FIN FACTURA CON ITEMS **************************/
/*************************************************************************/

/*************************************************************************/
/***************************** INICIO PAGO *******************************/
/*************************************************************************/
-- INSERT
create or alter procedure socio.agregarPago
    @fecha_pago date,
    @monto decimal(8,2),
    @es_debito_automatico bit = 0,
    @id_factura int
as
begin
	set nocount on;

	declare @id_cuenta_corriente int;

    -- Validación de monto mayor a 0
    if @monto <= 0
    begin
        print 'El monto debe ser mayor a cero.';
        return;
    end

    -- Validación existencia de factura
    if not exists (select 1 from socio.factura where id = @id_factura)
    begin
        print 'No existe una factura con ese ID.';
        return;
    end

	begin try
		begin transaction;

		-- Insertar el pago
		insert into socio.pago (fecha_pago, monto, es_debito_automatico, id_factura)
		values (@fecha_pago, @monto, @es_debito_automatico, @id_factura);

		-- Obtener cuenta corriente
		select @id_cuenta_corriente = cc.id
		from socio.cuenta_corriente cc
		inner join socio.inscripcion i on cc.id_persona = i.id_persona
		inner join socio.factura f on f.id_inscripcion = i.id
		where f.id = @id_factura;

		-- Insertamos el movimiento en la cuenta
		exec socio.insertarMovimientoCuenta
			@id_cuenta_corriente = @id_cuenta_corriente,
			@fecha = getdate(),
			@monto = -@monto_total,
			@id_factura = @id_factura,
			@id_pago = null,
			@id_reembolso = null;
		
		commit transaction;

		print 'Pago insertado correctamente.'

	end try
	begin catch
        rollback transaction;
        declare @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
        print 'Error al insertar pago: ' + @ErrorMessage;
        return;
    end catch
end
go

-- UPDATE
-- No permitido en el sistema

-- DELETE
-- No permitido en el sistema
/*************************************************************************/
/******************************* FIN PAGO ********************************/
/*************************************************************************/

/*************************************************************************/
/************************** INICIO REEMBOLSO *****************************/
/*************************************************************************/
-- INSERT
create or alter procedure socio.agregarReembolso
    @id_pago int,
    @monto decimal(8,2),
    @fecha_reembolso datetime,
    @motivo varchar(100),
    @id_tipo_reembolso int
as
begin
    set nocount on;

	declare @id_cuenta_corriente int;

    -- Validar que exista el pago asociado
    if not exists (select 1 from socio.pago where id = @id_pago)
    begin
        print 'No existe un pago con ese ID.';
        return;
    end

    -- Validar que el monto sea mayor a 0
    if @monto <= 0
    begin
        print 'El monto debe ser mayor a cero.';
        return;
    end

    -- Validar que la fecha de reembolso no sea nula
    if @fecha_reembolso is null
    begin
        print 'La fecha de reembolso no puede ser nula.';
        return;
    end

    -- Validar que el motivo no esté vacío
    if ltrim(rtrim(@motivo)) = ''
    begin
        print 'El motivo no puede estar vacío.';
        return;
    end

    -- Validar que exista el tipo de reembolso
    if not exists (select 1 from socio.tipo_reembolso where id = @id_tipo_reembolso)
    begin
        print 'No existe un tipo de reembolso con ese ID.';
        return;
    end

	begin try
		begin transaction;

		-- Insertar el reembolso
		insert into socio.reembolso (id_pago, monto, fecha_reembolso, motivo, id_tipo_reembolso)
		values (@id_pago, @monto, @fecha_reembolso, @motivo, @id_tipo_reembolso);

		-- Obtener cuenta corriente
		select @id_cuenta_corriente = cc.id
		from socio.reembolso r
		join socio.pago p on r.id_pago = p.id
		join socio.factura f on p.id_factura = f.id
		join socio.inscripcion i on f.id_inscripcion = i.id
		join socio.cuenta_corriente cc on i.id_persona = cc.id_persona
		where r.id = @id_reembolso;

		-- Insertamos el movimiento en la cuenta
		exec socio.insertarMovimientoCuenta
			@id_cuenta_corriente = @id_cuenta_corriente,
			@fecha = getdate(),
			@monto = -@monto_total,
			@id_factura = @id_factura,
			@id_pago = null,
			@id_reembolso = null;

		commit transaction;

		print 'Reembolso insertado correctamente.'

	end try
	begin catch
        rollback transaction;
        declare @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
        print 'Error al insertar reembolso: ' + @ErrorMessage;
        return;
    end catch
end
go

-- UPDATE
-- No permitido en el sistema

-- DELETE
-- No permitido en el sistema
/*************************************************************************/
/**************************** FIN REEMBOLSO ******************************/
/*************************************************************************/

/*************************************************************************/
/************************ INICIO TIPO REEMBOLSO **************************/
/*************************************************************************/
-- INSERT
create or alter procedure socio.agregarTipoReembolso
    @descripcion varchar(50)
as
begin
    set nocount on;

    -- Descripción no puede ser nula ni vacía
    if @descripcion is null or ltrim(rtrim(@descripcion)) = ''
    begin
        print 'La descripcion no puede estar vacía.';
        return;
    end

    insert into socio.tipo_reembolso (descripcion)
    values (@descripcion);

    print 'Tipo de reembolso agregado correctamente.';
end;
go

-- UPDATE
create or alter procedure socio.actualizarTipoReembolso
    @id int,
    @descripcion varchar(50)
as
begin
    set nocount on;

    -- Verificar que el id sea positivo
    if @id <= 0
    begin
        print 'El id debe ser mayor a cero.';
        return;
    end

    -- La descripción no puede ser nula ni vacía
    if @descripcion is null or ltrim(rtrim(@descripcion)) = ''
    begin
        print 'La descripcion no puede estar vacía.';
        return;
    end

    -- Verificar que el id exista
    if not exists (select 1 from socio.tipo_reembolso where id = @id)
    begin
        print 'Tipo de reembolso no encontrado.';
        return;
    end

    update socio.tipo_reembolso
    set descripcion = @descripcion
    where id = @id;

    print 'Tipo de reembolso actualizado correctamente.';
end;
go

-- DELETE
create or alter procedure socio.eliminarTipoReembolso
    @id int
as
begin
    set nocount on;

    -- Verificar que el id sea positivo
    if @id <= 0
    begin
        print 'El id debe ser mayor a cero.';
        return;
    end

    -- Verificar que el id exista
    if not exists (select 1 from socio.tipo_reembolso where id = @id)
    begin
        print 'Tipo de reembolso no encontrado.';
        return;
    end

    -- Verificar que no existan reembolsos asociados
    if exists (select 1 from socio.reembolso where id_tipo_reembolso = @id)
    begin
        print 'No se puede eliminar porque existen reembolsos asociados.';
        return;
    end

    delete from socio.tipo_reembolso
    where id = @id;

    print 'Tipo de reembolso eliminado correctamente';
end;
go
/*************************************************************************/
/************************** FIN TIPO REEMBOLSO ***************************/
/*************************************************************************/

/*************************************************************************/
/********************** INICIO MOVIMIENTO CUENTA *************************/
/*************************************************************************/
-- INSERT
create or alter procedure socio.insertarMovimientoCuenta
    @id_cuenta_corriente int,
    @fecha datetime,
    @id_factura int = null,
    @id_pago int = null,
    @id_reembolso int = null
as
begin
    declare @monto decimal(8,2)

    -- Validar que la cuenta corriente exista
    if not exists (select 1 from socio.cuenta_corriente where id = @id_cuenta_corriente)
    begin
        print 'No existe la cuenta corriente indicada.'
        return;
    end

    -- Validar que al menos uno sea informado
    if @id_factura is null and @id_pago is null and @id_reembolso is null
    begin
        print 'Debe ingresar al menos un tipo de movimiento.'
        return;
    end

    -- CASO 1: Si viene REEMBOLSO, prioridad total (movimiento positivo)
    if @id_reembolso is not null
    begin
        if not exists (select 1 from socio.reembolso where id = @id_reembolso)
        begin
            print 'No existe el reembolso indicado.'
            return;
        end

        select @monto = monto from socio.reembolso where id = @id_reembolso
    end
    -- CASO 2: Si no viene reembolso pero viene PAGO (movimiento positivo)
    else if @id_pago is not null
    begin
        if not exists (select 1 from socio.pago where id = @id_pago)
        begin
            print 'No existe el pago indicado.'
            return;
        end

        select @monto = monto from socio.pago where id = @id_pago
    end
    -- CASO 3: Solo factura (movimiento negativo)
    else if @id_factura is not null
    begin
        if not exists (select 1 from socio.factura where id = @id_factura)
        begin
            print 'No existe la factura indicada.'
            return;
        end

        select @monto = -1 * total from socio.factura where id = @id_factura
    end

    -- Insertar el movimiento
    insert into socio.movimiento_cuenta (id_cuenta_corriente, fecha, monto, id_factura, id_pago, id_reembolso)
    values (@id_cuenta_corriente, @fecha, @monto, @id_factura, @id_pago, @id_reembolso)

    -- Actualizar saldo de la cuenta corriente
    exec socio.actualizarCuentaCorriente @id = @id_cuenta_corriente, @saldo = @monto;

    print 'Movimiento registrado correctamente y saldo actualizado.'
end
go

-- UPDATE
-- No permitido en el sistema

-- DELETE
-- No permitido en el sistema
/*************************************************************************/
/*********************** FIN MOVIMIENTO CUENTA ***************************/
/*************************************************************************/

/*************************************************************************/
/***************************** INICIO ROL ********************************/
/*************************************************************************/
-- INSERT
create or alter procedure general.agregarRol
    @descripcion varchar(100)
as
begin
    set nocount on;

    -- Descripción no puede ser nula ni vacía
    if @descripcion is null or ltrim(rtrim(@descripcion)) = ''
    begin
        print 'La descripción no puede estar vacía.';
        return;
    end

    insert into general.rol (descripcion)
    values (@descripcion);

    print 'Rol agregado correctamente.';
end;
go

-- UPDATE
create or alter procedure general.modificarRol
    @id int,
    @descripcion varchar(100)
as
begin
    set nocount on;

    -- Verificar que el id sea positivo
    if @id <= 0
    begin
        print 'El id debe ser mayor a cero.';
        return;
    end

    -- La descripción no puede ser nula ni vacía
    if @descripcion is null or ltrim(rtrim(@descripcion)) = ''
    begin
        print 'La descripción no puede estar vacía.';
        return;
    end

    -- Verificar que el id exista
    if not exists (select 1 from general.rol where id = @id)
    begin
        print 'Rol no encontrado.';
        return;
    end

    update general.rol
    set descripcion = @descripcion
    where id = @id;

    print 'Rol actualizado correctamente.';
end;
go

-- DELETE
create or alter procedure general.eliminarRol
    @id int
as
begin
    set nocount on;

    -- Verificar que el id sea positivo
    if @id <= 0
    begin
        print 'El id debe ser mayor a cero.';
        return;
    end

    -- Verificar que el id exista
    if not exists (select 1 from general.rol where id = @id)
    begin
        print 'Rol no encontrado.';
        return;
    end

    -- Validar que no existan cuentas de acceso con este rol
    if exists (select 1 from general.cuenta_acceso where id_rol = @id)
    begin
        print 'No se puede eliminar porque existen cuentas de acceso asociadas a este rol.';
        return;
    end

    delete from general.rol
    where id = @id;

    print 'Rol eliminado correctamente.';
end;
go
/*************************************************************************/
/****************************** FIN ROL **********************************/
/*************************************************************************/

/*************************************************************************/
/************************* INICIO ACTIVIDAD ******************************/
/*************************************************************************/
-- INSERT
create or alter procedure general.agregarActividad
    @nombre varchar(50),
    @costo decimal(8,2)
as
begin
    set nocount on;

    -- Nombre no puede ser nulo ni vacío
    if @nombre is null or ltrim(rtrim(@nombre)) = ''
    begin
        print 'El nombre no puede estar vacío.';
        return;
    end

    -- Costo debe ser mayor a 0
    if @costo <= 0
    begin
        print 'El costo debe ser mayor a cero.';
        return;
    end

    insert into general.actividad (nombre, costo)
    values (@nombre, @costo);

    print 'Actividad agregada correctamente.';
end;
go

-- UPDATE
create procedure general.modificarActividad
    @id int,
    @nombre varchar(50),
    @costo decimal(8,2)
as
begin
    set nocount on;

    -- Verificar que el id sea positivo
    if @id <= 0
    begin
        print 'El id debe ser mayor a cero.';
        return;
    end

    -- Nombre no puede ser nulo ni vacío
    if @nombre is null or ltrim(rtrim(@nombre)) = ''
    begin
        print 'El nombre no puede estar vacío.';
        return;
    end

    -- Costo debe ser mayor a 0
    if @costo <= 0
    begin
        print 'El costo debe ser mayor a cero.';
        return;
    end

    -- Verificar que el id exista
    if not exists (select 1 from general.actividad where id = @id)
    begin
        print 'Actividad no encontrada.';
        return;
    end

    update general.actividad
    set nombre = @nombre,
        costo = @costo
    where id = @id;

    print 'Actividad actualizada correctamente.';
end;
go

-- DELETE
create procedure general.eliminarActividad
    @id int
as
begin
    set nocount on;

    -- Verificar que el id sea positivo
    if @id <= 0
    begin
        print 'El id debe ser mayor a cero.';
        return;
    end

    -- Verificar que el id exista
    if not exists (select 1 from general.actividad where id = @id)
    begin
        print 'Actividad no encontrada.';
        return;
    end

    -- Validar que no existan inscripciones con esta actividad
    if exists (select 1 from socio.inscripcion_actividad where id_actividad = @id)
    begin
        print 'No se puede eliminar porque existen inscripciones asociadas a esta actividad.';
        return;
    end

    delete from general.actividad
    where id = @id;

    print 'Actividad eliminada correctamente.';
end;
go
/*************************************************************************/
/************************** FIN ACTIVIDAD ********************************/
/*************************************************************************/

/*************************************************************************/
/********************** INICIO ACTIVIDAD EXTRA ***************************/
/*************************************************************************/
-- INSERT
create procedure general.agregarActividadExtra
    @nombre varchar(50),
    @costo decimal(8,2)
as
begin
    set nocount on;

    -- Nombre no puede ser nulo ni vacío
    if @nombre is null or ltrim(rtrim(@nombre)) = ''
    begin
        print 'El nombre no puede estar vacío.';
        return;
    end

    -- Costo debe ser mayor a 0
    if @costo <= 0
    begin
        print 'El costo debe ser mayor a cero.';
        return;
    end

    insert into general.actividad_extra (nombre, costo)
    values (@nombre, @costo);

    print 'Actividad extra agregada correctamente.';
end;
go

-- UPDATE
create procedure general.modificarActividadExtra
    @id int,
    @nombre varchar(50),
    @costo decimal(8,2)
as
begin
    set nocount on;

    -- Verificar que el id sea positivo
    if @id <= 0
    begin
        print 'El id debe ser mayor a cero.';
        return;
    end

    -- Nombre no puede ser nulo ni vacío
    if @nombre is null or ltrim(rtrim(@nombre)) = ''
    begin
        print 'El nombre no puede estar vacío.';
        return;
    end

    -- Costo debe ser mayor a 0
    if @costo <= 0
    begin
        print 'El costo debe ser mayor a cero.';
        return;
    end

    -- Verificar que el id exista
    if not exists (select 1 from general.actividad_extra where id = @id)
    begin
        print 'Actividad extra no encontrada.';
        return;
    end

    update general.actividad_extra
    set nombre = @nombre,
        costo = @costo
    where id = @id;

    print 'Actividad extra actualizada correctamente.';
end;
go

-- DELETE
create procedure general.eliminarActividadExtra
    @id int
as
begin
    set nocount on;

    -- Verificar que el id sea positivo
    if @id <= 0
    begin
        print 'El id debe ser mayor a cero.';
        return;
    end

    -- Verificar que el id exista
    if not exists (select 1 from general.actividad_extra where id = @id)
    begin
        print 'Actividad extra no encontrada.';
        return;
    end

    -- Validar que no existan inscripciones con esta actividad extra
    if exists (select 1 from socio.inscripcion_actividad where id_actividad_extra = @id)
    begin
        print 'No se puede eliminar porque existen inscripciones asociadas a esta actividad extra.';
        return;
    end

    delete from general.actividad_extra
    where id = @id;

    print 'Actividad extra eliminada correctamente.';
end;
go
/*************************************************************************/
/*********************** FIN ACTIVIDAD EXTRA *****************************/
/*************************************************************************/

/*************************************************************************/
/************************ INICIO DIA SEMANA ******************************/
/*************************************************************************/
-- INSERT
create procedure general.agregarDiaSemana
    @nombre varchar(50)
as
begin
    set nocount on;

    -- Nombre no puede ser nulo ni vacío
    if @nombre is null or ltrim(rtrim(@nombre)) = ''
    begin
        print 'El nombre no puede estar vacío.';
        return;
    end

    insert into general.dia_semana (nombre)
    values (@nombre);

    print 'Día de la semana agregado correctamente.';
end;
go

-- UPDATE
create procedure general.modificarDiaSemana
    @id int,
    @nombre varchar(50)
as
begin
    set nocount on;

    -- Verificar que el id sea positivo
    if @id <= 0
    begin
        print 'El id debe ser mayor a cero.';
        return;
    end

    -- Nombre no puede ser nulo ni vacío
    if @nombre is null or ltrim(rtrim(@nombre)) = ''
    begin
        print 'El nombre no puede estar vacío.';
        return;
    end

    -- Verificar que el id exista
    if not exists (select 1 from general.dia_semana where id = @id)
    begin
        print 'Día de la semana no encontrado.';
        return;
    end

    update general.dia_semana
    set nombre = @nombre
    where id = @id;

    print 'Día de la semana actualizado correctamente.';
end;
go

-- DELETE
create procedure general.eliminarDiaSemana
    @id int
as
begin
    set nocount on;

    -- Verificar que el id sea positivo
    if @id <= 0
    begin
        print 'El id debe ser mayor a cero.';
        return;
    end

    -- Verificar que el id exista
    if not exists (select 1 from general.dia_semana where id = @id)
    begin
        print 'Día de la semana no encontrado.';
        return;
    end

    -- Verificar que no haya clases con este día
    if exists (select 1 from general.clase where id_dia_semana = @id)
    begin
        print 'No se puede eliminar porque existen clases asignadas a este día.';
        return;
    end

    delete from general.dia_semana
    where id = @id;

    print 'Día de la semana eliminado correctamente.';
end;
go
/*************************************************************************/
/************************** FIN DIA SEMANA *******************************/
/*************************************************************************/

/*************************************************************************/
/************************ INICIO CUENTA ACCESO ***************************/
/*************************************************************************/
-- INSERT
create procedure general.agregarCuentaAcceso
    @usuario varchar(50),
    @hashContraseña varchar(50),
    @vigenciaContraseña date,
    @idRol int,
    @idPersona int = null,
    @idEmpleado int = null
as
begin
    set nocount on;

    -- Validaciones básicas
    if @usuario is null or ltrim(rtrim(@usuario)) = ''
    begin
        print 'El usuario no puede estar vacío.';
        return;
    end

    if @hashContraseña is null or ltrim(rtrim(@hashContraseña)) = ''
    begin
        print 'La contraseña no puede estar vacía.';
        return;
    end

    if @vigenciaContraseña is null
    begin
        print 'La vigencia de la contraseña es obligatoria.';
        return;
    end

    if @idRol <= 0
    begin
        print 'El id del rol debe ser mayor a cero.';
        return;
    end

    -- Validación exclusiva para idPersona o idEmpleado (solo uno debe tener valor)
    if (@idPersona is null and @idEmpleado is null) or
       (@idPersona is not null and @idEmpleado is not null)
    begin
        print 'Debe ingresar idPersona o idEmpleado, pero no ambos ni ninguno.';
        return;
    end

    if @idPersona is not null and @idPersona <= 0
    begin
        print 'El id de la persona debe ser mayor a cero.';
        return;
    end

    if @idEmpleado is not null and @idEmpleado <= 0
    begin
        print 'El id del empleado debe ser mayor a cero.';
        return;
    end

    -- Verificar que existan referencias
    if not exists (select 1 from general.rol where id = @idRol)
    begin
        print 'El rol especificado no existe.';
        return;
    end

    if @idPersona is not null and not exists (select 1 from socio.persona where id = @idPersona)
    begin
        print 'La persona especificada no existe.';
        return;
    end

    if @idEmpleado is not null and not exists (select 1 from empleado.empleado where id = @idEmpleado)
    begin
        print 'El empleado especificado no existe.';
        return;
    end

    insert into general.cuenta_acceso
        (usuario, hash_contraseña, vigencia_contraseña, id_rol, id_persona, id_empleado)
    values
        (@usuario, @hashContraseña, @vigenciaContraseña, @idRol, @idPersona, @idEmpleado);

    print 'Cuenta de acceso agregada correctamente.';
end;
go

-- UPDATE
create procedure general.modificarCuentaAcceso
    @id int,
    @usuario varchar(50),
    @hashContraseña varchar(50),
    @vigenciaContraseña date,
    @idRol int,
    @idPersona int = null,
    @idEmpleado int = null
as
begin
    set nocount on;

    if @id <= 0
    begin
        print 'El id debe ser mayor a cero.';
        return;
    end

    if @usuario is null or ltrim(rtrim(@usuario)) = ''
    begin
        print 'El usuario no puede estar vacío.';
        return;
    end

    if @hashContraseña is null or ltrim(rtrim(@hashContraseña)) = ''
    begin
        print 'La contraseña no puede estar vacía.';
        return;
    end

    if @vigenciaContraseña is null
    begin
        print 'La vigencia de la contraseña es obligatoria.';
        return;
    end

    if @idRol <= 0
    begin
        print 'El id del rol debe ser mayor a cero.';
        return;
    end

    -- Validación exclusiva para idPersona o idEmpleado (solo uno debe tener valor)
    if (@idPersona is null and @idEmpleado is null) or
       (@idPersona is not null and @idEmpleado is not null)
    begin
        print 'Debe ingresar idPersona o idEmpleado, pero no ambos ni ninguno.';
        return;
    end

    if @idPersona is not null and @idPersona <= 0
    begin
        print 'El id de la persona debe ser mayor a cero.';
        return;
    end

    if @idEmpleado is not null and @idEmpleado <= 0
    begin
        print 'El id del empleado debe ser mayor a cero.';
        return;
    end

    if not exists (select 1 from general.cuenta_acceso where id = @id)
    begin
        print 'Cuenta de acceso no encontrada.';
        return;
    end

    if not exists (select 1 from general.rol where id = @idRol)
    begin
        print 'El rol especificado no existe.';
        return;
    end

    if @idPersona is not null and not exists (select 1 from socio.persona where id = @idPersona)
    begin
        print 'La persona especificada no existe.';
        return;
    end

    if @idEmpleado is not null and not exists (select 1 from empleado.empleado where id = @idEmpleado)
    begin
        print 'El empleado especificado no existe.';
        return;
    end

    update general.cuenta_acceso
    set usuario = @usuario,
        hash_contraseña = @hashContraseña,
        vigencia_contraseña = @vigenciaContraseña,
        id_rol = @idRol,
        id_persona = @idPersona,
        id_empleado = @idEmpleado
    where id = @id;

    print 'Cuenta de acceso actualizada correctamente.';
end;
go

-- DELETE
-- DELETE
create procedure general.eliminarCuentaAcceso
    @id int
as
begin
    set nocount on;

    -- Validar que el id sea mayor a cero
    if @id <= 0
    begin
        print 'El id debe ser mayor a cero.';
        return;
    end

    -- Validar que la cuenta de acceso exista
    if not exists (select 1 from general.cuenta_acceso where id = @id)
    begin
        print 'Cuenta de acceso no encontrada.';
        return;
    end

    -- Eliminar la cuenta de acceso
    delete from general.cuenta_acceso
    where id = @id;

    print 'Cuenta de acceso eliminada correctamente.';
end;
go
/*************************************************************************/
/************************* FIN CUENTA ACCESO *****************************/
/*************************************************************************/

/*************************************************************************/
/**************************** INICIO CLASE *******************************/
/*************************************************************************/
-- INSERT
create procedure general.agregarClase
    @horaInicio time,
    @horaFin time,
    @idCategoria int,
    @idActividad int,
    @idDiaSemana int,
    @idEmpleado int
as
begin
    set nocount on;

    -- Validar que la hora de inicio sea menor a la hora de fin
    if @horaInicio >= @horaFin
    begin
        print 'La hora de inicio debe ser anterior a la hora de fin.';
        return;
    end

    -- Validar que los IDs existan
    if not exists (select 1 from socio.categoria where id = @idCategoria)
    begin
        print 'Categoría no encontrada.';
        return;
    end

    if not exists (select 1 from general.actividad where id = @idActividad)
    begin
        print 'Actividad no encontrada.';
        return;
    end

    if not exists (select 1 from general.dia_semana where id = @idDiaSemana)
    begin
        print 'Día de la semana no encontrado.';
        return;
    end

    if not exists (select 1 from empleado.empleado where id = @idEmpleado)
    begin
        print 'Empleado no encontrado.';
        return;
    end

    -- Insertar la nueva clase
    insert into general.clase (hora_inicio, hora_fin, id_categoria, id_actividad, id_dia_semana, id_empleado)
    values (@horaInicio, @horaFin, @idCategoria, @idActividad, @idDiaSemana, @idEmpleado);

    print 'Clase agregada correctamente.';
end;
go

-- UPDATE
create procedure general.modificarClase
    @id int,
    @horaInicio time,
    @horaFin time,
    @idCategoria int,
    @idActividad int,
    @idDiaSemana int,
    @idEmpleado int
as
begin
    set nocount on;

    -- Validar que el id sea mayor a cero
    if @id <= 0
    begin
        print 'El id debe ser mayor a cero.';
        return;
    end

    -- Validar que la clase exista
    if not exists (select 1 from general.clase where id = @id)
    begin
        print 'Clase no encontrada.';
        return;
    end

    -- Validar que la hora de inicio sea menor a la hora de fin
    if @horaInicio >= @horaFin
    begin
        print 'La hora de inicio debe ser anterior a la hora de fin.';
        return;
    end

    -- Validar que los IDs existan
    if not exists (select 1 from socio.categoria where id = @idCategoria)
    begin
        print 'Categoría no encontrada.';
        return;
    end

    if not exists (select 1 from general.actividad where id = @idActividad)
    begin
        print 'Actividad no encontrada.';
        return;
    end

    if not exists (select 1 from general.dia_semana where id = @idDiaSemana)
    begin
        print 'Día de la semana no encontrado.';
        return;
    end

    if not exists (select 1 from empleado.empleado where id = @idEmpleado)
    begin
        print 'Empleado no encontrado.';
        return;
    end

    -- Actualizar la clase
    update general.clase
    set hora_inicio = @horaInicio,
        hora_fin = @horaFin,
        id_categoria = @idCategoria,
        id_actividad = @idActividad,
        id_dia_semana = @idDiaSemana,
        id_empleado = @idEmpleado
    where id = @id;

    print 'Clase actualizada correctamente.';
end;
go

-- DELETE
create procedure general.eliminarClase
    @id int
as
begin
    set nocount on;

    -- Validar que el id sea mayor a cero
    if @id <= 0
    begin
        print 'El id debe ser mayor a cero.';
        return;
    end

    -- Validar que la clase exista
    if not exists (select 1 from general.clase where id = @id)
    begin
        print 'Clase no encontrada.';
        return;
    end

    -- Eliminar la clase
    delete from general.clase where id = @id;

    print 'Clase eliminada correctamente.';
end;
go
/*************************************************************************/
/**************************** FIN CLASE **********************************/
/*************************************************************************/

/*************************************************************************/
/************************** INICIO PUESTO ********************************/
/*************************************************************************/
-- INSERT
create procedure empleado.agregarPuesto
    @nombre varchar(50)
as
begin
    set nocount on;

    -- Validar que el nombre no sea nulo ni vacío
    if ltrim(rtrim(@nombre)) = ''
    begin
        print 'El nombre no puede estar vacío.';
        return;
    end

    -- Insertar el nuevo puesto
    insert into empleado.puesto (nombre)
    values (@nombre);

    print 'Puesto agregado correctamente.';
end;
go

-- UPDATE
create procedure empleado.modificarPuesto
    @id int,
    @nombre varchar(50)
as
begin
    set nocount on;

    -- Validar que el id sea mayor a cero
    if @id <= 0
    begin
        print 'El id debe ser mayor a cero.';
        return;
    end

    -- Validar que el puesto exista
    if not exists (select 1 from empleado.puesto where id = @id)
    begin
        print 'Puesto no encontrado.';
        return;
    end

    -- Validar que el nombre no sea vacío
    if ltrim(rtrim(@nombre)) = ''
    begin
        print 'El nombre no puede estar vacío.';
        return;
    end

    -- Actualizar el puesto
    update empleado.puesto
    set nombre = @nombre
    where id = @id;

    print 'Puesto actualizado correctamente.';
end;
go

-- DELETE
create procedure empleado.eliminarPuesto
    @id int
as
begin
    set nocount on;

    -- Validar que el id sea mayor a cero
    if @id <= 0
    begin
        print 'El id debe ser mayor a cero.';
        return;
    end

    -- Validar que el puesto exista
    if not exists (select 1 from empleado.puesto where id = @id)
    begin
        print 'Puesto no encontrado.';
        return;
    end

    -- Validar que el puesto no esté asignado a ningún empleado
    if exists (select 1 from empleado.empleado where id_puesto = @id)
    begin
        print 'No se puede eliminar el puesto porque está asignado a uno o más empleados.';
        return;
    end

    -- Eliminar el puesto
    delete from empleado.puesto where id = @id;

    print 'Puesto eliminado correctamente.';
end;
go
/*************************************************************************/
/**************************** FIN PUESTO *********************************/
/*************************************************************************/

/*************************************************************************/
/************************* INICIO EMPLEADO *******************************/
/*************************************************************************/
-- INSERT
create procedure empleado.agregarEmpleado
    @nombre varchar(50),
    @apellido varchar(50),
    @idPuesto int
as
begin
    set nocount on;

    -- Validar que el nombre y apellido no sean vacíos
    if ltrim(rtrim(@nombre)) = ''
    begin
        print 'El nombre no puede estar vacío.';
        return;
    end

    if ltrim(rtrim(@apellido)) = ''
    begin
        print 'El apellido no puede estar vacío.';
        return;
    end

    -- Validar que el puesto exista
    if not exists (select 1 from empleado.puesto where id = @idPuesto)
    begin
        print 'Puesto no encontrado.';
        return;
    end

    -- Insertar el nuevo empleado
    insert into empleado.empleado (nombre, apellido, id_puesto)
    values (@nombre, @apellido, @idPuesto);

    print 'Empleado agregado correctamente.';
end;
go

-- UPDATE
create procedure empleado.modificarEmpleado
    @id int,
    @nombre varchar(50),
    @apellido varchar(50),
    @idPuesto int
as
begin
    set nocount on;

    -- Validar que el id sea mayor a cero
    if @id <= 0
    begin
        print 'El id debe ser mayor a cero.';
        return;
    end

    -- Validar que el empleado exista
    if not exists (select 1 from empleado.empleado where id = @id)
    begin
        print 'Empleado no encontrado.';
        return;
    end

    -- Validar que el nombre y apellido no sean vacíos
    if ltrim(rtrim(@nombre)) = ''
    begin
        print 'El nombre no puede estar vacío.';
        return;
    end

    if ltrim(rtrim(@apellido)) = ''
    begin
        print 'El apellido no puede estar vacío.';
        return;
    end

    -- Validar que el puesto exista
    if not exists (select 1 from empleado.puesto where id = @idPuesto)
    begin
        print 'Puesto no encontrado.';
        return;
    end

    -- Actualizar el empleado
    update empleado.empleado
    set nombre = @nombre,
        apellido = @apellido,
        id_puesto = @idPuesto
    where id = @id;

    print 'Empleado actualizado correctamente.';
end;
go

-- DELETE
create procedure empleado.eliminarEmpleado
    @id int
as
begin
    set nocount on;

    -- Validar que el id sea mayor a cero
    if @id <= 0
    begin
        print 'El id debe ser mayor a cero.';
        return;
    end

    -- Validar que el empleado exista
    if not exists (select 1 from empleado.empleado where id = @id)
    begin
        print 'Empleado no encontrado.';
        return;
    end

    -- Validar que el empleado no esté asignado a ninguna clase
    if exists (select 1 from general.clase where id_empleado = @id)
    begin
        print 'No se puede eliminar el empleado porque está asignado a una o más clases.';
        return;
    end

    -- Eliminar el empleado
    delete from empleado.empleado where id = @id;

    print 'Empleado eliminado correctamente.';
end;
go
/*************************************************************************/
/*************************** FIN EMPLEADO ********************************/
/*************************************************************************/
---------------------------------------------------------------------------
-------------------------- FIN PROCEDIMIENTOS -----------------------------
---------------------------------------------------------------------------