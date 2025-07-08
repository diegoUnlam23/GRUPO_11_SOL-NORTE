/*
    Consigna: Crear las tablas requeridas para el modelo de datos del proyecto
    Fecha de entrega: 08/07/2025
    Número de comisión: 2900
    Número de grupo: 11
    Nombre de la materia: Bases de Datos Aplicadas
    Integrantes:
        - Costanzo, Marcos Ezequiel - 40955907
        - Sanchez, Diego Mauricio - 46361081
*/

use Com2900G11;
go

create table socio.obra_social_socio
(
	id 			        int primary key identity(1,1),
	nombre				varchar(50) NOT NULL,
	telefono_emergencia	varchar(50) NOT NULL,
	numero_socio        varchar(50) NOT NULL
);
go

create table socio.tutor
(
	id					int primary key identity(1,1),
	nombre				varchar(50) NOT NULL,
	apellido			varchar(50) NOT NULL,
	dni					int UNIQUE NOT NULL CHECK(dni > 0),
	email				varchar(254) CHECK(email like '_%@_%._%'),
	parentesco			varchar(20) NOT NULL,
	responsable_pago	bit,
);
go

create table socio.socio
(
	id						int primary key identity(1,1),
	nombre					varchar(100) NOT NULL,
	apellido				varchar(100) NOT NULL,
	dni						int UNIQUE NOT NULL CHECK(dni > 0),
	email					varchar(254) CHECK(email like '_%@_%._%'),
	fecha_nacimiento		date NOT NULL,
	telefono				varchar(20),
	telefono_emergencia		varchar(20),
	id_obra_social_socio	int,
	id_tutor				int,
	id_grupo_familiar		int,
	estado					varchar(20),
	responsable_pago		bit,
	nro_socio				varchar(20),
	foreign key (id_obra_social_socio) references socio.obra_social_socio(id),
	foreign key (id_tutor) references socio.tutor(id),
	foreign key (id_grupo_familiar) references socio.socio(id)
);
go

create table socio.debito_automatico
(
	id					int primary key identity(1,1),
	id_responsable_pago	int NOT NULL,
	medio_de_pago		varchar(50) NOT NULL,
	activo				bit NOT NULL,
	token_pago			varchar(200) NOT NULL,
	ultimos_4_digitos	int NOT NULL,
	titular				varchar(100) NOT NULL,
	foreign key (id_responsable_pago) references socio.socio(id)
)

create table socio.inscripcion
(
	id				    int primary key identity(1,1),
	id_socio		    int NOT NULL UNIQUE,
	fecha_inscripcion	date NOT NULL,
	foreign key (id_socio) references socio.socio(id)
);
go

create table general.empleado
(
	id				int primary key identity(1,1),
	nombre			varchar(50),
	nombre_cifrado	varbinary(256)
);
go

create table socio.categoria
(
	id			    int primary key identity(1,1),
	nombre		    varchar(10) NOT NULL,
	costo_mensual   decimal(12,2) NOT NULL CHECK(costo_mensual > 0),
	edad_min	    int NOT NULL,
	edad_max	    int NOT NULL 
);
go

create table socio.cuota
(
	id					int primary key identity(1,1),
	id_socio			int NOT NULL,
	id_categoria		int NOT NULL,
	monto_total			decimal(12,2),
	anio				int NOT NULL,
	mes					int NOT NULL,
	foreign key (id_socio) references socio.socio(id),
	foreign key (id_categoria) references socio.categoria(id),
	constraint UQ_cuota_socio_cat_periodo UNIQUE (id_socio, anio, mes)
);
go

create table socio.invitado
(
	id						int primary key identity(1,1),
	nombre					varchar(100) NOT NULL,
	apellido				varchar(100) NOT NULL,
	dni						int UNIQUE NOT NULL CHECK(dni > 0),
	email					varchar(254) CHECK(email like '_%@_%._%'),
	saldo_a_favor			decimal(12,2) DEFAULT 0.00 NOT NULL
);
go

create table socio.tarifa_pileta
(
	id		int primary key identity(1,1),
	tipo	varchar(50) COLLATE modern_spanish_CI_AS CHECK(tipo IN('Socio','Invitado')),
	precio	decimal(12,2) NOT NULL check(precio >= 0)
);
go

create table socio.registro_pileta
(
	id				    int primary key identity(1,1),
	id_socio		    int,
	id_invitado 	    int,
	fecha			    date NOT NULL,
	id_tarifa		    int NOT NULL,
	foreign key (id_socio) references socio.socio(id),
	foreign key (id_invitado) references socio.invitado(id),
	foreign key (id_tarifa) references socio.tarifa_pileta(id)
);
go

create table general.actividad
(
	id		        int primary key identity(1,1),
	nombre	        varchar(50) NOT NULL,
	costo_mensual   decimal(12,2) NOT NULL
);
go

create table general.actividad_extra
(
	id					int primary key identity(1,1),
	id_socio			int NOT NULL,
	nombre				varchar(50) NOT NULL,
	costo				decimal(12,2) NOT NULL
	foreign key (id_socio) references socio.socio(id)
);
go

create table socio.inscripcion_actividad
(
	id					int primary key identity(1,1),
	id_cuota			int NOT NULL,
	id_actividad		int NOT NULL,
	foreign key (id_cuota) references socio.cuota(id),
	foreign key (id_actividad) references general.actividad(id)
);
go

create table general.clase
(
	id				int primary key identity(1,1),
	hora_inicio		time NOT NULL,
	hora_fin		time NOT NULL,
    dia VARCHAR(10) NOT NULL CHECK (dia IN ('Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo')),
	id_categoria	int NOT NULL,
	id_actividad	int NOT NULL,
	id_empleado		int NOT NULL,
	foreign key (id_actividad) references general.actividad(id),
	foreign key (id_categoria) references socio.categoria(id),
	foreign key (id_empleado) references general.empleado(id),
);
go

create table general.presentismo
(
	id				int primary key identity(1,1),
	id_socio		int,
	id_clase		int NOT NULL,
	fecha			date,
	tipo_asistencia	varchar(2) NOT NULL,
	foreign key (id_socio) references socio.socio(id),
	foreign key (id_clase) references general.clase(id)
)
go

create table socio.estado_cuenta
(
	id				int primary key identity(1,1),
	id_socio		int,
	id_tutor		int,
	saldo			decimal(12,2) NOT NULL,
	foreign key (id_socio) references socio.socio(id),
	foreign key (id_tutor) references socio.tutor(id)
);
go

create table socio.factura_cuota
(
	id						int primary key identity(1,1),
    numero_comprobante      int NOT NULL,
    tipo_comprobante        varchar(2) NOT NULL,
	fecha_emision   		date NOT NULL,
    periodo_facturado       int NOT NULL,
    iva                     varchar(50) NOT NULL,
	fecha_vencimiento_1		date NOT NULL,
	fecha_vencimiento_2		date NOT NULL,
	importe_total			decimal(12,2),
	descripcion 			varchar(100) NOT NULL,
	id_cuota				int,
	foreign key (id_cuota) references socio.cuota(id)
);
go

create table socio.item_factura_cuota
(
	id			        int primary key identity(1,1),
	id_factura_cuota 	int NOT NULL,
    cantidad            int NOT NULL,
    precio_unitario     decimal(12,2) NOT NULL,
    alicuota_iva        decimal(12,2) NOT NULL,
    tipo_item           varchar(50) NOT NULL,
    subtotal            decimal(12,2) NOT NULL,
    importe_total       decimal(12,2) NOT NULL,
	foreign key (id_factura_cuota) references socio.factura_cuota(id)
);
go

create table socio.nota_credito
(
	id					int primary key identity(1,1),
	numero_nota_credito		int NOT NULL,
	fecha_anulacion			date NOT NULL,
	id_factura_origen		int NOT NULL,
	motivo_anulacion		varchar(100) NOT NULL,
	foreign key (id_factura_origen) references socio.factura_cuota(id)
);
go

create table socio.factura_extra
(
	id						int primary key identity(1,1),
    numero_comprobante      int NOT NULL,
    tipo_comprobante        varchar(2) NOT NULL,
	fecha_emision   		date NOT NULL,
    periodo_facturado       int NOT NULL,
    iva                     varchar(50) NOT NULL,
	fecha_vencimiento_1		date NOT NULL,
	fecha_vencimiento_2		date NOT NULL,
	importe_total			decimal(12,2),
	descripcion 			varchar(100) NOT NULL,
    id_registro_pileta		int,
	id_actividad_extra		int,
	foreign key (id_registro_pileta) references socio.registro_pileta(id),
    foreign key (id_actividad_extra) references general.actividad_extra(id)
);
go

create table socio.item_factura_extra
(
	id			        int primary key identity(1,1),
	id_factura_extra 	int NOT NULL,
    cantidad            int NOT NULL,
    precio_unitario     decimal(12,2) NOT NULL,
    alicuota_iva        decimal(12,2) NOT NULL,
    tipo_item           varchar(50) NOT NULL,
    subtotal            decimal(12,2) NOT NULL,
    importe_total       decimal(12,2) NOT NULL,
	foreign key (id_factura_extra) references socio.factura_extra(id)
);
go

create table socio.pago
(
	id						int primary key identity (1,1),
	fecha_pago				date NOT NULL,
	monto					decimal(12,2) NOT NULL,
	medio_de_pago			varchar(50) NOT NULL,
	es_debito_automatico	bit default 0 NOT NULL,
	id_factura_cuota		int,
	id_factura_extra		int,
	id_pago_externo			bigint,
	foreign key (id_factura_cuota) references socio.factura_cuota(id),
	foreign key (id_factura_extra) references socio.factura_extra(id)
);
go

create table socio.tipo_reembolso
(
	id				int primary key identity (1,1),
	descripcion		varchar(50) NOT NULL
);
go

create table socio.reembolso
(
	id					int primary key identity (1,1),
	id_pago				int NOT NULL,
	monto				decimal(12,2) NOT NULL,
	fecha_reembolso		datetime NOT NULL,
	motivo				varchar(100) NOT NULL,
	id_tipo_reembolso	int NOT NULL,
	foreign key (id_pago) references socio.pago(id),
	foreign key (id_tipo_reembolso) references socio.tipo_reembolso(id)
);
go

create table socio.movimiento_cuenta
(
	id						int primary key identity (1,1),
	id_estado_cuenta		int NOT NULL,
	fecha					datetime NOT NULL,
	monto					decimal(12,2) NOT NULL,
	id_factura				int,
	id_pago					int,
	id_reembolso			int,
	foreign key (id_estado_cuenta) references socio.estado_cuenta(id),
	foreign key (id_factura) references socio.factura_cuota(id),
	foreign key (id_pago) references socio.pago(id),
	foreign key (id_reembolso) references socio.reembolso(id)
);
go