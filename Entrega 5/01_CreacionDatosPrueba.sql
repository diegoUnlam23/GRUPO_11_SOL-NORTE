/*
	- Consigna:
		Cara de datos iniciales
	- Fecha de entrega: 17/06/2025
	- Número de comisión: 2900 
	- Número de grupo: 11
	- Nombre de la materia: Bases de Datos Aplicadas
	- Integrantes:
		- Costanzo, Marcos Ezequiel - 40955907
		- Sanchez, Diego Mauricio - 46361081
*/

-- Datos Obra Social
insert into socio.datos_obra_social (nombre, telefono_emergencia) values ('OSDE', '0800-555-6733');
insert into socio.datos_obra_social (nombre, telefono_emergencia) values ('Swiss Medical', '0800-444-7700');
insert into socio.datos_obra_social (nombre, telefono_emergencia) values ('Galeno', '0800-777-4253');

-- Datos de prueba para Obra Social Persona
-- Se usan los ID 1, 2 y 3 de la tabla socio.datos_obra_social cargados previamente.
insert into socio.obra_social_persona (id_datos_os, numero_socio) values (1, 'OS123456'); -- OSDE
insert into socio.obra_social_persona (id_datos_os, numero_socio) values (2, 'SM789012'); -- Swiss Medical
insert into socio.obra_social_persona (id_datos_os, numero_socio) values (3, 'GA345678'); -- Galeno
insert into socio.obra_social_persona (id_datos_os, numero_socio) values (1, 'OS654321'); -- OSDE
insert into socio.obra_social_persona (id_datos_os, numero_socio) values (2, 'SM210987'); -- Swiss Medical

-- Insert de Personas
-- Insertar persona: mayor individual
exec socio.agregarPersona
    @nombre = 'juan',
    @apellido = 'pérez',
    @dni = 30111222,
    @email = 'juan.perez@email.com',
    @fecha_nacimiento = '1990-05-15',
    @telefono = '123456789',
    @telefono_emergencia = '987654321',
    @id_obra_social_persona = 1;  -- Mayor individual

-- Insertar persona: responsable grupo familiar
exec socio.agregarPersona
    @nombre = 'laura',
    @apellido = 'gómez',
    @dni = 30222333,
    @email = 'laura.gomez@email.com',
    @fecha_nacimiento = '1985-07-20',
    @telefono = '111111111',
    @telefono_emergencia = '999999999',
    @id_obra_social_persona = 2;  -- Responsable grupo familiar

-- Insertar persona: integrante grupo familiar (cadete)
exec socio.agregarPersona
    @nombre = 'martín',
    @apellido = 'gómez',
    @dni = 40333444,
    @email = 'martin.gomez@email.com',
    @fecha_nacimiento = '2010-08-30',
    @telefono = '222222222',
    @telefono_emergencia = '888888888',
    @id_obra_social_persona = 2;  -- Integrante grupo familiar (cadete)

-- Insertar persona: integrante grupo familiar (menor)
exec socio.agregarPersona
    @nombre = 'sofía',
    @apellido = 'gómez',
    @dni = 50444555,
    @email = 'sofia.gomez@email.com',
    @fecha_nacimiento = '2015-03-10',
    @telefono = '333333333',
    @telefono_emergencia = '777777777',
    @id_obra_social_persona = 2;  -- Integrante grupo familiar (menor)

-- Insertar persona: cadete individual
exec socio.agregarPersona
    @nombre = 'tomás',
    @apellido = 'lópez',
    @dni = 60555666,
    @email = 'tomas.lopez@email.com',
    @fecha_nacimiento = '2008-11-25',
    @telefono = '444444444',
    @telefono_emergencia = '666666666',
    @id_obra_social_persona = 3;  -- Cadete individual

-- Insertar persona: menor individual
exec socio.agregarPersona
    @nombre = 'valentina',
    @apellido = 'martínez',
    @dni = 70766777,
    @email = 'valentina.martinez@email.com',
    @fecha_nacimiento = '2014-06-18',
    @telefono = '555555555',
    @telefono_emergencia = '555555555',
    @id_obra_social_persona = 1;  -- Menor individual
go

-- Insert de Grupo Familiar
-- Grupo Familiar de Laura Gómez
-- Laura es responsable
insert into socio.grupo_familiar (id_persona, es_responsable, relacion_con_responsable) values (2, 1, 'Responsable'); -- Laura Gómez
insert into socio.grupo_familiar (id_persona, es_responsable, relacion_con_responsable) values (3, 0, 'Hijo'); -- Martín Gómez
insert into socio.grupo_familiar (id_persona, es_responsable, relacion_con_responsable) values (4, 0, 'Hija'); -- Sofía Gómez
go

-- Insert de Invitados
-- Invitados asociados a Juan Pérez (ID 1)
insert into socio.invitado (nombre, apellido, dni, id_persona_asociada) values ('Carlos', 'Ramírez', 80877887, 1);
insert into socio.invitado (nombre, apellido, dni, id_persona_asociada) values ('María', 'López', 80988990, 1);

-- Invitados asociados a Laura Gómez (ID 2)
insert into socio.invitado (nombre, apellido, dni, id_persona_asociada) values ('Pedro', 'Sánchez', 80123456, 2);
insert into socio.invitado (nombre, apellido, dni, id_persona_asociada) values ('Ana', 'Fernández', 80234567, 2);

-- Invitado asociado a Tomás López (ID 5)
insert into socio.invitado (nombre, apellido, dni, id_persona_asociada) values ('Luis', 'García', 80345678, 5);
go

-- Tarifa Pileta
insert into socio.tarifa_pileta (tipo, precio) values ('Socio', 500.00);
insert into socio.tarifa_pileta (tipo, precio) values ('Invitado', 1000.00);

-- Registro Pileta
-- Juan Pérez (ID 1) usa la pileta como socio
insert into socio.registro_pileta (id_persona, id_invitado, fecha, id_tarifa) values (1, null, '2025-06-10', 1);
insert into socio.registro_pileta (id_persona, id_invitado, fecha, id_tarifa) values (1, null, '2025-06-11', 1);

-- Laura Gómez (ID 2) usa la pileta como socio
insert into socio.registro_pileta (id_persona, id_invitado, fecha, id_tarifa) values (2, null, '2025-06-12', 1);

-- Tomás López (ID 5) usa la pileta como socio
insert into socio.registro_pileta (id_persona, id_invitado, fecha, id_tarifa) values (5, null, '2025-06-13', 1);

-- Invitados de Juan Pérez (ID 1)
insert into socio.registro_pileta (id_persona, id_invitado, fecha, id_tarifa) values (1, 1, '2025-06-10', 2); -- Carlos Ramírez
insert into socio.registro_pileta (id_persona, id_invitado, fecha, id_tarifa) values (1, 2, '2025-06-11', 2); -- María López

-- Invitados de Laura Gómez (ID 2)
insert into socio.registro_pileta (id_persona, id_invitado, fecha, id_tarifa) values (2, 3, '2025-06-12', 2); -- Pedro Sánchez
insert into socio.registro_pileta (id_persona, id_invitado, fecha, id_tarifa) values (2, 4, '2025-06-12', 2); -- Ana Fernández

-- Invitado de Tomás López (ID 5)
insert into socio.registro_pileta (id_persona, id_invitado, fecha, id_tarifa) values (5, 5, '2025-06-13', 2); -- Luis García
go

-- Rol
insert into general.rol (descripcion) values ('Socio');
insert into general.rol (descripcion) values ('Empleado');
insert into general.rol (descripcion) values ('Administrador');

-- Cuenta Acceso Persona
-- Cuenta para Juan Pérez (persona id 1)
insert into general.cuenta_acceso
(usuario, hash_contraseña, vigencia_contraseña, id_rol, id_persona, id_empleado)
values
('juan.perez', hashbytes('sha2_256', 'pass123!'), dateadd(month, 3, getdate()), 1, 1, null);

-- Cuenta para Laura Gómez (persona id 2)
insert into general.cuenta_acceso
(usuario, hash_contraseña, vigencia_contraseña, id_rol, id_persona, id_empleado)
values
('laura.gomez', hashbytes('sha2_256', 'laura2025'), dateadd(month, 3, getdate()), 1, 2, null);

-- Cuenta para Tomás López (persona id 5)
insert into general.cuenta_acceso
(usuario, hash_contraseña, vigencia_contraseña, id_rol, id_persona, id_empleado)
values
('tomas.lopez', hashbytes('sha2_256', 'tomas2025'), dateadd(month, 3, getdate()), 1, 5, null);

-- Cuenta para Valentina Martínez (persona id 6)
insert into general.cuenta_acceso
(usuario, hash_contraseña, vigencia_contraseña, id_rol, id_persona, id_empleado)
values
('valentina.martinez', hashbytes('sha2_256', 'valen2025'), dateadd(month, 3, getdate()), 1, 6, null);
go

-- Puesto
insert into empleado.puesto (descripcion) values ('Profesor');

-- Empleados
-- empleado: profesor
insert into empleado.empleado (nombre, apellido, dni, email, id_puesto)
values ('mariano', 'gutiérrez', 40111222, 'mariano.gutierrez@email.com', 1);

-- empleado: profesor
insert into empleado.empleado (nombre, apellido, dni, email, id_puesto)
values ('carla', 'suárez', 40222333, 'carla.suarez@email.com', 1);
go

-- Cuenta Acceso Empleado
-- cuenta para Mariano Gutiérrez (empleado id 1)
insert into general.cuenta_acceso
(usuario, hash_contraseña, vigencia_contraseña, id_rol, id_persona, id_empleado)
values
('mariano.gutierrez', hashbytes('sha2_256', 'mariano2025'), dateadd(month, 3, getdate()), 2, null, 1);

-- cuenta para Carla Suárez (empleado id 2)
insert into general.cuenta_acceso
(usuario, hash_contraseña, vigencia_contraseña, id_rol, id_persona, id_empleado)
values
('carla.suarez', hashbytes('sha2_256', 'carla2025'), dateadd(month, 3, getdate()), 2, null, 2);
go

-- Dia Semana
insert into general.dia_semana (nombre) values ('Lunes');
insert into general.dia_semana (nombre) values ('Martes');
insert into general.dia_semana (nombre) values ('Miércoles');
insert into general.dia_semana (nombre) values ('Jueves');
insert into general.dia_semana (nombre) values ('Viernes');
insert into general.dia_semana (nombre) values ('Sábado');
insert into general.dia_semana (nombre) values ('Domingo');

-- Actividad
insert into general.actividad (nombre, costo) values ('Futsal', 3000.00);
insert into general.actividad (nombre, costo) values ('Vóley', 2800.00);
insert into general.actividad (nombre, costo) values ('Taekwondo', 3500.00);
insert into general.actividad (nombre, costo) values ('Baile artístico', 3200.00);
insert into general.actividad (nombre, costo) values ('Natación', 4000.00);
insert into general.actividad (nombre, costo) values ('Ajedrez', 2000.00);

-- Actividad Extra
insert into general.actividad_extra (nombre, costo) values ('Colonia de verano', 5000.00);
insert into general.actividad_extra (nombre, costo) values ('Alquiler del SUM', 7000.00);
insert into general.actividad_extra (nombre, costo) values ('Pileta verano', 3000.00);

-- Categoria
insert into socio.categoria (nombre, costo, edad_min, edad_max) values ('Menor', 1500.00, 0, 12);
insert into socio.categoria (nombre, costo, edad_min, edad_max) values ('Cadete', 2000.00, 13, 17);
insert into socio.categoria (nombre, costo, edad_min, edad_max) values ('Mayor', 2500.00, 18, 99);

-- Clase
-- Clase de futsal con Mariano Gutiérrez, categoría cadete
insert into general.clase (hora_inicio, hora_fin, id_categoria, id_actividad, id_dia_semana, id_empleado)
values ('18:00', '19:30', 2, 1, 2, 1); -- Martes

-- Clase de futsal con Mariano Gutiérrez, categoría cadete
insert into general.clase (hora_inicio, hora_fin, id_categoria, id_actividad, id_dia_semana, id_empleado)
values ('18:00', '19:30', 2, 1, 4, 1); -- Jueves

-- Clase de vóley con Carla Suárez, categoría mayor
insert into general.clase (hora_inicio, hora_fin, id_categoria, id_actividad, id_dia_semana, id_empleado)
values ('17:00', '18:30', 3, 2, 3, 2); -- Miércoles

-- Clase de vóley con Carla Suárez, categoría mayor
insert into general.clase (hora_inicio, hora_fin, id_categoria, id_actividad, id_dia_semana, id_empleado)
values ('17:00', '18:30', 3, 2, 5, 2); -- Viernes

-- Clase de taekwondo con Mariano Gutiérrez, categoría cadete
insert into general.clase (hora_inicio, hora_fin, id_categoria, id_actividad, id_dia_semana, id_empleado)
values ('19:30', '21:00', 2, 3, 2, 1); -- Martes

-- Clase de taekwondo con Mariano Gutiérrez, categoría cadete
insert into general.clase (hora_inicio, hora_fin, id_categoria, id_actividad, id_dia_semana, id_empleado)
values ('19:30', '21:00', 2, 3, 4, 1); -- Jueves

-- Clase de natación con Carla Suárez, categoría menor
insert into general.clase (hora_inicio, hora_fin, id_categoria, id_actividad, id_dia_semana, id_empleado)
values ('10:00', '12:00', 1, 5, 6, 2); -- Sábado

-- Clase de baile artístico con Mariano Gutiérrez, categoría menor
insert into general.clase (hora_inicio, hora_fin, id_categoria, id_actividad, id_dia_semana, id_empleado)
values ('16:00', '17:30', 1, 4, 1, 1); -- Lunes

-- Clase de ajedrez con Carla Suárez, categoría mayor
insert into general.clase (hora_inicio, hora_fin, id_categoria, id_actividad, id_dia_semana, id_empleado)
values ('15:00', '17:00', 3, 6, 7, 2); -- Domingo
go

-- Estado Factura
insert into socio.estado_factura (descripcion) values ('Pendiente');
insert into socio.estado_factura (descripcion) values ('Pagada');
insert into socio.estado_factura (descripcion) values ('Vencida');

-- Medio de Pago
insert into socio.medio_de_pago (tipo) values ('Efectivo');
insert into socio.medio_de_pago (tipo) values ('Tarjeta de crédito');
insert into socio.medio_de_pago (tipo) values ('Débito automático');

-- Estado Inscripcion
insert into socio.estado_inscripcion (estado) values ('Activa');
insert into socio.estado_inscripcion (estado) values ('Cancelada');

-- Insertamos Inscripcion e Inscripcion Actividad
-- Juan Pérez → actividad extra
-- Laura Gómez → sin actividad extra
-- Martín Gómez → actividad extra
-- Sofía Gómez → sin actividad extra
-- Tomás López → actividad extra
-- Valentina Martínez → sin actividad extra
-- Inscripción de Juan Pérez (id_persona = 1)
insert into socio.inscripcion (numero_socio, id_persona, id_grupo_familiar, fecha_inicio, fecha_baja, id_estado, id_categoria, id_medio_pago)
values ('SN-001', 1, null, getdate(), null, 1, 3, 1);

-- Inscripción de Laura Gómez (id_persona = 2) - Responsable grupo familiar
insert into socio.inscripcion (numero_socio, id_persona, id_grupo_familiar, fecha_inicio, fecha_baja, id_estado, id_categoria, id_medio_pago)
values ('SN-002', 2, 1, getdate(), null, 1, 3, 1);

-- Inscripción de Martín Gómez (id_persona = 3) - Hijo de Laura
insert into socio.inscripcion (numero_socio, id_persona, id_grupo_familiar, fecha_inicio, fecha_baja, id_estado, id_categoria, id_medio_pago)
values ('SN-003', 3, 2, getdate(), null, 1, 2, 1);

-- Inscripción de Sofía Gómez (id_persona = 4) - Hija de Laura
insert into socio.inscripcion (numero_socio, id_persona, id_grupo_familiar, fecha_inicio, fecha_baja, id_estado, id_categoria, id_medio_pago)
values ('SN-004', 4, 3, getdate(), null, 1, 1, 2);

-- Inscripción de Tomás López (id_persona = 5)
insert into socio.inscripcion (numero_socio, id_persona, id_grupo_familiar, fecha_inicio, fecha_baja, id_estado, id_categoria, id_medio_pago)
values ('SN-005', 5, null, getdate(), null, 1, 2, 1);

-- Inscripción de Valentina Martínez (id_persona = 6)
insert into socio.inscripcion (numero_socio, id_persona, id_grupo_familiar, fecha_inicio, fecha_baja, id_estado, id_categoria, id_medio_pago)
values ('SN-006', 6, null, getdate(), null, 1, 1, 2);
go

-- Juan Pérez inscripto a futsal y taekwondo, con colonia de verano como actividad extra
insert into socio.inscripcion_actividad (id_inscripcion, id_actividad, id_actividad_extra, fecha_inscripcion)
values (1, 1, 1, getdate());

insert into socio.inscripcion_actividad (id_inscripcion, id_actividad, id_actividad_extra, fecha_inscripcion)
values (1, 3, null, getdate());

-- Laura Gómez inscripta a vóley, sin actividad extra
insert into socio.inscripcion_actividad (id_inscripcion, id_actividad, id_actividad_extra, fecha_inscripcion)
values (2, 2, null, getdate());

-- Martín Gómez inscripto a taekwondo y ajedrez, con pileta de verano como actividad extra
insert into socio.inscripcion_actividad (id_inscripcion, id_actividad, id_actividad_extra, fecha_inscripcion)
values (3, 3, 3, getdate());

insert into socio.inscripcion_actividad (id_inscripcion, id_actividad, id_actividad_extra, fecha_inscripcion)
values (3, 6, null, getdate());

-- Sofía Gómez inscripta a baile artístico, sin actividad extra
insert into socio.inscripcion_actividad (id_inscripcion, id_actividad, id_actividad_extra, fecha_inscripcion)
values (4, 4, null, getdate());

-- Tomás López inscripto a natación, con alquiler del SUM como actividad extra
insert into socio.inscripcion_actividad (id_inscripcion, id_actividad, id_actividad_extra, fecha_inscripcion)
values (5, 5, 2, getdate());

-- Valentina Martínez inscripta a ajedrez, sin actividad extra
insert into socio.inscripcion_actividad (id_inscripcion, id_actividad, id_actividad_extra, fecha_inscripcion)
values (6, 6, null, getdate());
go

declare @fecha datetime = getdate();
declare @fecha_venc_1 datetime = dateadd(day, 30, @fecha);
declare @fecha_venc_2 datetime = dateadd(day, 60, @fecha);
-- Factura solo por inscripción (sin uso de pileta)
exec socio.insertarFacturaCompletaPersona
    @fecha_generacion   = @fecha,
    @fecha_vencimiento_1 = @fecha_venc_1,
    @fecha_vencimiento_2 = @fecha_venc_2,
    @descripcion        = 'Factura por inscripción mensual',
    @id_inscripcion     = 1,
    @id_registro_pileta = null,
    @id_estado_factura  = 1;  -- asumimos estado 'pendiente'

-- Factura solo por uso de pileta (registro sin inscripción)
exec socio.insertarFacturaCompletaInvitado
    @fecha_generacion   = @fecha,
    @fecha_vencimiento_1 = @fecha_venc_1,
    @fecha_vencimiento_2 = @fecha_venc_2,
    @descripcion        = 'Factura uso pileta semana 24',
    @id_registro_pileta = 5,
    @id_estado_factura  = 1;

-- Factura mixta: inscripción + uso de pileta (ambos aplicados)
exec socio.insertarFacturaCompletaPersona
    @fecha_generacion   = @fecha,
    @fecha_vencimiento_1 = @fecha_venc_1,
    @fecha_vencimiento_2 = @fecha_venc_2,
    @descripcion        = 'Factura inscripción + pileta',
    @id_inscripcion     = 2,
    @id_registro_pileta = 3,
    @id_estado_factura  = 1;

-- Tipo Reembolso (actualizado)
insert into socio.tipo_reembolso (descripcion) values ('Pago a cuenta');
insert into socio.tipo_reembolso (descripcion) values ('Medio de pago');

-- Pago 1: Asociado a la factura 1
exec socio.agregarPago
    @fecha_pago = '2024-06-17',
    @monto = 5000.00,
    @es_debito_automatico = 1,
    @id_factura = 1;

-- Pago 2: Asociado a la factura 2
exec socio.agregarPago
    @fecha_pago = '2024-06-18',
    @monto = 7500.00,
    @es_debito_automatico = 0,
    @id_factura = 2;

-- Pago 3: Asociado a la factura 3
exec socio.agregarPago
    @fecha_pago = '2024-06-19',
    @monto = 6200.00,
    @es_debito_automatico = 1,
    @id_factura = 3;
go

-- Reembolso 1: Del pago 1, tipo de reembolso 1
exec socio.agregarReembolso
    @id_pago = 1,
    @monto = 2000.00,
    @fecha_reembolso = '2024-06-20',
    @motivo = 'Devolución por error de facturación',
    @id_tipo_reembolso = 1;

-- Reembolso 2: Del pago 2, tipo de reembolso 2
exec socio.agregarReembolso
    @id_pago = 3,
    @monto = 1500.00,
    @fecha_reembolso = '2024-06-21',
    @motivo = 'Reembolso por servicio no prestado',
    @id_tipo_reembolso = 2;
go