/*
    Archivo de Pruebas Detalladas - Caso 2: Socio Responsable de Pago con Socios Menores Asociados
    Fecha de entrega: 01/07/2025
    Número de comisión: 2900
    Número de grupo: 11
    Nombre de la materia: Bases de Datos Aplicadas
    Integrantes:
        - Costanzo, Marcos Ezequiel - 40955907
        - Sanchez, Diego Mauricio - 46361081
*/

use Com2900G11;
go

SET NOCOUNT ON;

-- =====================================================
-- LIMPIEZA INICIAL PARA PRUEBAS
-- =====================================================

print '=== LIMPIEZA INICIAL PARA PRUEBAS ===';
print 'Eliminando datos existentes para pruebas limpias...';

-- Limpiar datos existentes en orden inverso a las dependencias
delete from socio.movimiento_cuenta;
delete from socio.reembolso;
delete from socio.pago;
delete from socio.item_factura_extra;
delete from socio.item_factura_cuota;
delete from socio.factura_extra;
delete from socio.factura_cuota;
delete from socio.estado_cuenta;
delete from general.presentismo;
delete from general.clase;
delete from socio.inscripcion_actividad;
delete from socio.registro_pileta;
delete from socio.cuota;
delete from socio.inscripcion;
delete from socio.debito_automatico;
delete from socio.socio;
delete from socio.tutor;
delete from socio.obra_social_socio;
delete from socio.invitado;
delete from socio.tarifa_pileta;
delete from socio.categoria;
delete from general.actividad_extra;
delete from general.actividad;
delete from general.empleado;
delete from socio.tipo_reembolso;

-- Resetear identity columns
dbcc checkident ('socio.movimiento_cuenta', reseed, 0);
dbcc checkident ('socio.reembolso', reseed, 0);
dbcc checkident ('socio.pago', reseed, 0);
dbcc checkident ('socio.item_factura_extra', reseed, 0);
dbcc checkident ('socio.item_factura_cuota', reseed, 0);
dbcc checkident ('socio.factura_extra', reseed, 0);
dbcc checkident ('socio.factura_cuota', reseed, 0);
dbcc checkident ('socio.estado_cuenta', reseed, 0);
dbcc checkident ('general.presentismo', reseed, 0);
dbcc checkident ('general.clase', reseed, 0);
dbcc checkident ('socio.inscripcion_actividad', reseed, 0);
dbcc checkident ('socio.registro_pileta', reseed, 0);
dbcc checkident ('socio.cuota', reseed, 0);
dbcc checkident ('socio.inscripcion', reseed, 0);
dbcc checkident ('socio.debito_automatico', reseed, 0);
dbcc checkident ('socio.socio', reseed, 0);
dbcc checkident ('socio.tutor', reseed, 0);
dbcc checkident ('socio.obra_social_socio', reseed, 0);
dbcc checkident ('socio.invitado', reseed, 0);
dbcc checkident ('socio.tarifa_pileta', reseed, 0);
dbcc checkident ('socio.categoria', reseed, 0);
dbcc checkident ('general.actividad_extra', reseed, 0);
dbcc checkident ('general.actividad', reseed, 0);
dbcc checkident ('general.empleado', reseed, 0);
dbcc checkident ('socio.tipo_reembolso', reseed, 0);

print 'Limpieza completada exitosamente';
print '';

-- =====================================================
-- PREPARACIÓN DE DATOS BASE
-- =====================================================

print '=== PREPARACIÓN DE DATOS BASE ===';
print 'Insertando datos base necesarios para las pruebas...';

-- 1. Insertar tipos de reembolso
print '1. Insertando tipos de reembolso...';
exec socio.altaTipoReembolso @descripcion = 'Pago a cuenta';
exec socio.altaTipoReembolso @descripcion = 'Reembolso al medio de pago';

-- 2. Insertar empleados
print '2. Insertando empleados...';
exec general.altaEmpleado @nombre = 'Juan Pérez';
exec general.altaEmpleado @nombre = 'María González';
exec general.altaEmpleado @nombre = 'Carlos Rodríguez';

-- 3. Insertar categorías
print '3. Insertando categorías...';
exec socio.altaCategoria @nombre = 'Menor', @costo_mensual = 120.00, @edad_min = 0, @edad_max = 12;
exec socio.altaCategoria @nombre = 'Cadete', @costo_mensual = 150.00, @edad_min = 13, @edad_max = 17;
exec socio.altaCategoria @nombre = 'Mayor', @costo_mensual = 200.00, @edad_min = 18, @edad_max = 120;

-- 4. Insertar actividades deportivas
print '4. Insertando actividades deportivas...';
exec general.altaActividad @nombre = 'Futsal', @costo_mensual = 80.00;
exec general.altaActividad @nombre = 'Vóley', @costo_mensual = 70.00;
exec general.altaActividad @nombre = 'Taekwondo', @costo_mensual = 90.00;
exec general.altaActividad @nombre = 'Baile artístico', @costo_mensual = 85.00;
exec general.altaActividad @nombre = 'Natación', @costo_mensual = 75.00;
exec general.altaActividad @nombre = 'Ajedrez', @costo_mensual = 60.00;

-- 5. Insertar tarifas de pileta
print '5. Insertando tarifas de pileta...';
exec socio.altaTarifaPileta @tipo = 'Socio', @precio = 20.00;
exec socio.altaTarifaPileta @tipo = 'Invitado', @precio = 50.00;

-- 6. Insertar obras sociales
print '6. Insertando obras sociales...';
exec socio.altaObraSocialSocio @nombre = 'OSDE', @telefono_emergencia = '0800-333-OSDE', @numero_socio = '12345678';
exec socio.altaObraSocialSocio @nombre = 'Swiss Medical', @telefono_emergencia = '0800-555-1234', @numero_socio = '87654321';
exec socio.altaObraSocialSocio @nombre = 'Galeno', @telefono_emergencia = '0800-444-5678', @numero_socio = '11223344';
exec socio.altaObraSocialSocio @nombre = 'Sin obra social', @telefono_emergencia = 'Hospital Público', @numero_socio = '00000000';

-- 7. Insertar invitados
print '7. Insertando invitados...';
exec socio.altaInvitado @nombre = 'Fernando', @apellido = 'Silva', @dni = 88888888, @email = 'fernando.silva@email.com', @saldo_a_favor = 0.00;
exec socio.altaInvitado @nombre = 'Laura', @apellido = 'Torres', @dni = 99999999, @email = 'laura.torres@email.com', @saldo_a_favor = 0.00;

print 'Datos base preparados exitosamente';
print '';

-- =====================================================
-- CASO 2: SOCIO RESPONSABLE DE PAGO CON SOCIOS MENORES ASOCIADOS
-- =====================================================

print '=== CASO 2: SOCIO RESPONSABLE DE PAGO CON SOCIOS MENORES ASOCIADOS ===';
print 'Escenario: Familia López - Padre socio responsable y dos hijos menores';
print '';

-- =====================================================
-- 2.1 CREACIÓN DE SOCIOS Y GRUPO FAMILIAR
-- =====================================================

print '2.1 CREACIÓN DE SOCIOS Y GRUPO FAMILIAR';
print 'Creando familia López: padre responsable y dos hijos menores...';

-- Crear padre (socio responsable)
exec socio.altaSocio @nombre = 'Roberto', @apellido = 'López', @dni = 23456789, @email = 'roberto.lopez@email.com', 
    @fecha_nacimiento = '1985-03-15', @telefono = '11-4567-8901', @telefono_emergencia = '11-4567-8902', 
    @id_obra_social_socio = 1, @id_tutor = null, @id_grupo_familiar = null, @estado = 'Activo', @responsable_pago = 1;

-- Crear hijo mayor (cadete)
exec socio.altaSocio @nombre = 'Tomás', @apellido = 'López', @dni = 34567890, @email = 'tomas.lopez@email.com', 
    @fecha_nacimiento = '2010-07-22', @telefono = null, @telefono_emergencia = '11-4567-8902', 
    @id_obra_social_socio = 1, @id_tutor = null, @id_grupo_familiar = null, @estado = 'Activo', @responsable_pago = 0;

-- Crear hija menor
exec socio.altaSocio @nombre = 'Sofía', @apellido = 'López', @dni = 45678901, @email = 'sofia.lopez@email.com', 
    @fecha_nacimiento = '2015-11-08', @telefono = null, @telefono_emergencia = '11-4567-8902', 
    @id_obra_social_socio = 1, @id_tutor = null, @id_grupo_familiar = null, @estado = 'Activo', @responsable_pago = 0;

-- Obtener IDs de los socios creados
declare @id_padre int, @id_hijo1 int, @id_hija int;
select @id_padre = id from socio.socio where dni = 23456789;
select @id_hijo1 = id from socio.socio where dni = 34567890;
select @id_hija = id from socio.socio where dni = 45678901;

-- Asociar grupo familiar usando el campo id_grupo_familiar de la tabla socio
update socio.socio set id_grupo_familiar = @id_padre where id = @id_hijo1;
update socio.socio set id_grupo_familiar = @id_padre where id = @id_hija;

-- Verificar creación de socios
select
    'Socios creados' as Estado,
    nombre + ' ' + apellido as Nombre_Completo,
    dni as DNI,
    fecha_nacimiento as Fecha_Nacimiento,
    estado as Estado_Socio,
    case responsable_pago when 1 then 'Sí' else 'No' end as Responsable_Pago
from socio.socio 
where dni in (23456789, 34567890, 45678901)
order by fecha_nacimiento;

-- Verificar asociación de grupo familiar
select
    'Grupo familiar asociado' as Estado,
    sr.nombre + ' ' + sr.apellido as Responsable,
    sm.nombre + ' ' + sm.apellido as Menor,
    sm.id_grupo_familiar as ID_Grupo_Familiar
from socio.socio sr
inner join socio.socio sm on sr.id = sm.id_grupo_familiar
where sr.dni = 23456789;

-- Verificar que se crearon los estados de cuenta
select
    'Estados de cuenta creados' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    ec.saldo as Saldo_Inicial
from socio.estado_cuenta ec
inner join socio.socio s on ec.id_socio = s.id
where s.dni in (23456789, 34567890, 45678901)
order by s.fecha_nacimiento;

print 'Familia López creada exitosamente: Roberto (padre responsable) + Tomás (14 años) + Sofía (9 años)';
print '';

-- =====================================================
-- 2.2 CREACIÓN DE CUOTAS
-- =====================================================

print '2.2 CREACIÓN DE CUOTAS';
print 'Creando cuotas para cada miembro de la familia...';

-- Crear cuota para el padre (categoría Mayor)
exec socio.altaCuota @id_socio = @id_padre, @id_categoria = 3, @monto_total = 200.00;
declare @id_cuota_padre int;
select @id_cuota_padre = max(id) from socio.cuota where id_socio = @id_padre;

-- Crear cuota para el hijo (categoría Cadete)
exec socio.altaCuota @id_socio = @id_hijo1, @id_categoria = 2, @monto_total = 150.00;
declare @id_cuota_hijo int;
select @id_cuota_hijo = max(id) from socio.cuota where id_socio = @id_hijo1;

-- Crear cuota para la hija (categoría Menor)
exec socio.altaCuota @id_socio = @id_hija, @id_categoria = 1, @monto_total = 120.00;
declare @id_cuota_hija int;
select @id_cuota_hija = max(id) from socio.cuota where id_socio = @id_hija;

-- Verificar creación de cuotas
select 
    'Cuotas creadas' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    c.nombre as Categoria,
    cu.monto_total as Monto_Total
from socio.cuota cu
inner join socio.socio s on cu.id_socio = s.id
inner join socio.categoria c on cu.id_categoria = c.id
where cu.id in (@id_cuota_padre, @id_cuota_hijo, @id_cuota_hija)
order by s.fecha_nacimiento;

print 'Cuotas creadas exitosamente: Roberto (Mayor $200) + Tomás (Cadete $150) + Sofía (Menor $120)';
print '';

-- =====================================================
-- 2.3 INSCRIPCIÓN A ACTIVIDADES DEPORTIVAS
-- =====================================================

print '2.3 INSCRIPCIÓN A ACTIVIDADES DEPORTIVAS';
print 'Inscribiendo a los miembros de la familia a actividades deportivas...';

-- Padre: Futsal y Natación
exec socio.altaInscripcionActividad @id_cuota = @id_cuota_padre, @id_actividad = 1, @fecha_inscripcion = '2024-01-15';
exec socio.altaInscripcionActividad @id_cuota = @id_cuota_padre, @id_actividad = 5, @fecha_inscripcion = '2024-01-15';
print 'Roberto inscrito a Futsal y Natación';

-- Hijo: Vóley y Taekwondo
exec socio.altaInscripcionActividad @id_cuota = @id_cuota_hijo, @id_actividad = 2, @fecha_inscripcion = '2024-01-15';
exec socio.altaInscripcionActividad @id_cuota = @id_cuota_hijo, @id_actividad = 3, @fecha_inscripcion = '2024-01-15';
print 'Tomás inscrito a Vóley y Taekwondo';

-- Hija: Baile artístico y Ajedrez
exec socio.altaInscripcionActividad @id_cuota = @id_cuota_hija, @id_actividad = 4, @fecha_inscripcion = '2024-01-15';
exec socio.altaInscripcionActividad @id_cuota = @id_cuota_hija, @id_actividad = 6, @fecha_inscripcion = '2024-01-15';
print 'Sofía inscrita a Baile artístico y Ajedrez';

-- Verificar inscripciones
select 
    'Inscripciones activas' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    a.nombre as Actividad,
    a.costo_mensual as Costo_Mensual,
    ia.fecha_inscripcion as Fecha_Inscripcion
from socio.inscripcion_actividad ia
inner join socio.cuota c on ia.id_cuota = c.id
inner join socio.socio s on c.id_socio = s.id
inner join general.actividad a on ia.id_actividad = a.id
where c.id in (@id_cuota_padre, @id_cuota_hijo, @id_cuota_hija) and ia.activa = 1
order by s.fecha_nacimiento, a.nombre;

print 'Todos los miembros de la familia inscritos a 2 actividades cada uno';
print 'Esto debería generar descuentos del 10% por múltiples actividades + 15% por grupo familiar';
print '';

-- =====================================================
-- 2.4 CREACIÓN DE FACTURAS CUOTA
-- =====================================================

print '2.4 CREACIÓN DE FACTURAS CUOTA';
print 'Generando facturas cuota para cada miembro con descuentos aplicados...';

-- Generar factura para el padre
exec socio.altaFacturaCuota @id_cuota = @id_cuota_padre;
declare @id_factura_padre int;
select @id_factura_padre = max(id) from socio.factura_cuota where id_cuota = @id_cuota_padre;

-- Generar factura para el hijo
exec socio.altaFacturaCuota @id_cuota = @id_cuota_hijo;
declare @id_factura_hijo int;
select @id_factura_hijo = max(id) from socio.factura_cuota where id_cuota = @id_cuota_hijo;

-- Generar factura para la hija
exec socio.altaFacturaCuota @id_cuota = @id_cuota_hija;
declare @id_factura_hija int;
select @id_factura_hija = max(id) from socio.factura_cuota where id_cuota = @id_cuota_hija;

-- Verificar facturas creadas
select 
    'Facturas cuota generadas' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    numero_comprobante as Numero_Comprobante,
    fecha_emision as Fecha_Emision,
    importe_total as Importe_Total
from socio.factura_cuota fc
inner join socio.cuota c on fc.id_cuota = c.id
inner join socio.socio s on c.id_socio = s.id
where fc.id in (@id_factura_padre, @id_factura_hijo, @id_factura_hija)
order by s.fecha_nacimiento;

-- Verificar items de las facturas (para ver descuentos aplicados)
select 
    'Items de facturas' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    ifc.tipo_item as Concepto,
    ifc.cantidad as Cantidad,
    ifc.precio_unitario as Precio_Unitario,
    ifc.subtotal as Subtotal,
    ifc.importe_total as Importe_Total
from socio.item_factura_cuota ifc
inner join socio.factura_cuota fc on ifc.id_factura_cuota = fc.id
inner join socio.cuota c on fc.id_cuota = c.id
inner join socio.socio s on c.id_socio = s.id
where fc.id in (@id_factura_padre, @id_factura_hijo, @id_factura_hija)
order by s.fecha_nacimiento, ifc.tipo_item;

print 'Facturas cuota generadas exitosamente con descuentos aplicados';
print '';

-- =====================================================
-- 2.5 PROCESAMIENTO DE PAGOS
-- =====================================================

print '2.5 PROCESAMIENTO DE PAGOS';
print 'Procesando pagos de las facturas cuota por el responsable...';

-- Mostrar estado de cuenta ANTES de los pagos
print '';
print '--- ESTADO DE CUENTA ANTES DE LOS PAGOS ---';
select 
    'Estado de cuenta ANTES de los pagos' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    ec.saldo as Saldo_Actual,
    case 
        when ec.saldo > 0 then 'Saldo a favor'
        when ec.saldo < 0 then 'Deuda'
        else 'Saldo cero'
    end as Estado_Saldo
from socio.estado_cuenta ec
inner join socio.socio s on ec.id_socio = s.id
where ec.id_socio in (@id_padre, @id_hijo1, @id_hija)
order by s.fecha_nacimiento;

-- Obtener montos de las facturas
declare @monto_factura_padre decimal(8,2), @monto_factura_hijo decimal(8,2), @monto_factura_hija decimal(8,2);
select @monto_factura_padre = importe_total from socio.factura_cuota where id = @id_factura_padre;
select @monto_factura_hijo = importe_total from socio.factura_cuota where id = @id_factura_hijo;
select @monto_factura_hija = importe_total from socio.factura_cuota where id = @id_factura_hija;

-- Procesar pago de la factura del padre
print '';
print 'Procesando pago de Roberto: $' + cast(@monto_factura_padre as varchar(10)) + ' con tarjeta Visa...';
exec socio.altaPago @monto = @monto_factura_padre, @medio_de_pago = 'Visa', @id_factura_cuota = @id_factura_padre;

-- Procesar pago de la factura del hijo
print 'Procesando pago de Tomás: $' + cast(@monto_factura_hijo as varchar(10)) + ' con tarjeta Visa...';
exec socio.altaPago @monto = @monto_factura_hijo, @medio_de_pago = 'Visa', @id_factura_cuota = @id_factura_hijo;

-- Procesar pago de la factura de la hija
print 'Procesando pago de Sofía: $' + cast(@monto_factura_hija as varchar(10)) + ' con tarjeta Visa...';
exec socio.altaPago @monto = @monto_factura_hija, @medio_de_pago = 'Visa', @id_factura_cuota = @id_factura_hija;

-- Verificar pagos procesados
select 
    'Pagos procesados' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    p.monto as Monto_Pagado,
    p.medio_de_pago as Medio_de_Pago,
    p.fecha_pago as Fecha_Pago
from socio.pago p
inner join socio.factura_cuota fc on p.id_factura_cuota = fc.id
inner join socio.cuota c on fc.id_cuota = c.id
inner join socio.socio s on c.id_socio = s.id
where fc.id in (@id_factura_padre, @id_factura_hijo, @id_factura_hija)
order by s.fecha_nacimiento;

-- Mostrar estado de cuenta DESPUÉS de los pagos
print '';
print '--- ESTADO DE CUENTA DESPUÉS DE LOS PAGOS ---';
select 
    'Estado de cuenta DESPUÉS de los pagos' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    ec.saldo as Saldo_Actual,
    case 
        when ec.saldo > 0 then 'Saldo a favor'
        when ec.saldo < 0 then 'Deuda'
        else 'Saldo cero'
    end as Estado_Saldo
from socio.estado_cuenta ec
inner join socio.socio s on ec.id_socio = s.id
where ec.id_socio in (@id_padre, @id_hijo1, @id_hija)
order by s.fecha_nacimiento;

print 'Pagos procesados exitosamente por el responsable de la familia';
print '';

-- =====================================================
-- 2.6 CASOS ADICIONALES DEL GRUPO FAMILIAR
-- =====================================================

print '2.6 CASOS ADICIONALES DEL GRUPO FAMILIAR';
print 'Probando funcionalidades específicas del grupo familiar...';

-- =====================================================
-- 2.6.1 USO DE PILETA POR MENORES
-- =====================================================

print '2.6.1 USO DE PILETA POR MENORES';
print 'Registrando uso de pileta por los menores de la familia...';

-- Registro de pileta para Tomás
exec socio.altaRegistroPileta @id_socio = @id_hijo1, @id_invitado = null, @fecha = '2024-01-20', @id_tarifa = 1;
declare @id_registro_tomas int;
select @id_registro_tomas = max(id) from socio.registro_pileta where id_socio = @id_hijo1 and fecha = '2024-01-20';

-- Registro de pileta para Sofía
exec socio.altaRegistroPileta @id_socio = @id_hija, @id_invitado = null, @fecha = '2024-01-20', @id_tarifa = 1;
declare @id_registro_sofia int;
select @id_registro_sofia = max(id) from socio.registro_pileta where id_socio = @id_hija and fecha = '2024-01-20';

-- Generar facturas extra por uso de pileta
exec socio.altaFacturaExtra @id_registro_pileta = @id_registro_tomas;
exec socio.altaFacturaExtra @id_registro_pileta = @id_registro_sofia;

declare @id_factura_tomas int, @id_factura_sofia int;
select @id_factura_tomas = max(id) from socio.factura_extra where id_registro_pileta = @id_registro_tomas;
select @id_factura_sofia = max(id) from socio.factura_extra where id_registro_pileta = @id_registro_sofia;

-- Verificar facturas extra generadas
select 
    'Facturas extra por pileta' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    numero_comprobante as Numero_Comprobante,
    fecha_emision as Fecha_Emision,
    importe_total as Importe_Total
from socio.factura_extra fe
inner join socio.registro_pileta rp on fe.id_registro_pileta = rp.id
inner join socio.socio s on rp.id_socio = s.id
where fe.id in (@id_factura_tomas, @id_factura_sofia)
order by s.fecha_nacimiento;

print 'Facturas extra generadas por uso de pileta de los menores';
print '';

-- =====================================================
-- 2.6.2 PAGO DE FACTURAS EXTRA POR EL RESPONSABLE
-- =====================================================

print '2.6.2 PAGO DE FACTURAS EXTRA POR EL RESPONSABLE';
print 'Procesando pagos de facturas extra por el responsable...';

-- Obtener montos de las facturas extra
declare @monto_factura_tomas decimal(8,2), @monto_factura_sofia decimal(8,2);
select @monto_factura_tomas = importe_total from socio.factura_extra where id = @id_factura_tomas;
select @monto_factura_sofia = importe_total from socio.factura_extra where id = @id_factura_sofia;

-- Procesar pagos inmediatos
exec socio.altaPago @monto = @monto_factura_tomas, @medio_de_pago = 'Efectivo', @id_factura_extra = @id_factura_tomas;
exec socio.altaPago @monto = @monto_factura_sofia, @medio_de_pago = 'Efectivo', @id_factura_extra = @id_factura_sofia;

-- Verificar pagos de facturas extra
select 
    'Pagos facturas extra' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    p.monto as Monto_Pagado,
    p.medio_de_pago as Medio_de_Pago,
    p.fecha_pago as Fecha_Pago
from socio.pago p
inner join socio.factura_extra fe on p.id_factura_extra = fe.id
inner join socio.registro_pileta rp on fe.id_registro_pileta = rp.id
inner join socio.socio s on rp.id_socio = s.id
where fe.id in (@id_factura_tomas, @id_factura_sofia)
order by s.fecha_nacimiento;

print 'Pagos de facturas extra procesados exitosamente';
print '';

-- =====================================================
-- 2.6.3 CONFIGURACIÓN DE DÉBITO AUTOMÁTICO FAMILIAR
-- =====================================================

print '2.6.3 CONFIGURACIÓN DE DÉBITO AUTOMÁTICO FAMILIAR';
print 'Configurando débito automático para el responsable de la familia...';

-- Configurar débito automático para el padre
exec socio.altaDebitoAutomatico @id_responsable_pago = @id_padre, @medio_de_pago = 'Visa', @activo = 1, 
    @token_pago = 'tok_visa_roberto_123', @ultimos_4_digitos = 3456, @titular = 'Roberto López';

-- Verificar configuración de débito automático
select 
    'Débito automático configurado' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    da.medio_de_pago as Medio_de_Pago,
    da.ultimos_4_digitos as Ultimos_4_Digitos,
    da.titular as Titular,
    case da.activo when 1 then 'Activo' else 'Inactivo' end as Estado_DA
from socio.debito_automatico da
inner join socio.socio s on da.id_responsable_pago = s.id
where da.id_responsable_pago = @id_padre;

print 'Débito automático configurado para el responsable de la familia';
print '';

-- =====================================================
-- 2.7 VERIFICACIÓN FINAL DEL CASO
-- =====================================================

print '2.7 VERIFICACIÓN FINAL DEL CASO';
print 'Realizando verificación completa del caso familiar...';

-- Resumen del grupo familiar
select 
    'RESUMEN DEL GRUPO FAMILIAR' as Seccion,
    s.nombre + ' ' + s.apellido as Socio,
    s.dni as DNI,
    s.fecha_nacimiento as Fecha_Nacimiento,
    c.nombre as Categoria,
    cu.monto_total as Monto_Cuota,
    case s.responsable_pago when 1 then 'Sí' else 'No' end as Responsable_Pago
from socio.socio s
inner join socio.cuota cu on s.id = cu.id_socio
inner join socio.categoria c on cu.id_categoria = c.id
where s.id in (@id_padre, @id_hijo1, @id_hija)
order by s.fecha_nacimiento;

-- Resumen de actividades por miembro
select 
    'ACTIVIDADES POR MIEMBRO' as Seccion,
    s.nombre + ' ' + s.apellido as Socio,
    a.nombre as Actividad,
    a.costo_mensual as Costo_Mensual
from socio.inscripcion_actividad ia
inner join socio.cuota c on ia.id_cuota = c.id
inner join socio.socio s on c.id_socio = s.id
inner join general.actividad a on ia.id_actividad = a.id
where c.id in (@id_cuota_padre, @id_cuota_hijo, @id_cuota_hija) and ia.activa = 1
order by s.fecha_nacimiento, a.nombre;

-- Resumen de facturas generadas
select 
    'FACTURAS GENERADAS' as Seccion,
    s.nombre + ' ' + s.apellido as Socio,
    'Cuota' as Tipo,
    numero_comprobante as Numero,
    fecha_emision as Fecha,
    importe_total as Importe
from socio.factura_cuota fc
inner join socio.cuota c on fc.id_cuota = c.id
inner join socio.socio s on c.id_socio = s.id
where c.id in (@id_cuota_padre, @id_cuota_hijo, @id_cuota_hija)
union all
select 
    'FACTURAS GENERADAS' as Seccion,
    s.nombre + ' ' + s.apellido as Socio,
    'Extra - Pileta' as Tipo,
    numero_comprobante as Numero,
    fecha_emision as Fecha,
    importe_total as Importe
from socio.factura_extra fe
inner join socio.registro_pileta rp on fe.id_registro_pileta = rp.id
inner join socio.socio s on rp.id_socio = s.id
where rp.id_socio in (@id_hijo1, @id_hija)
order by Socio, Tipo, Fecha;

-- Resumen de pagos realizados
select 
    'PAGOS REALIZADOS' as Seccion,
    s.nombre + ' ' + s.apellido as Socio,
    p.monto as Monto,
    p.medio_de_pago as Medio_de_Pago,
    p.fecha_pago as Fecha_Pago,
    case 
        when p.id_factura_cuota is not null then 'Factura Cuota'
        when p.id_factura_extra is not null then 'Factura Extra'
        else 'Otro'
    end as Tipo_Factura
from socio.pago p
inner join socio.factura_cuota fc on p.id_factura_cuota = fc.id
inner join socio.cuota c on fc.id_cuota = c.id
inner join socio.socio s on c.id_socio = s.id
where c.id in (@id_cuota_padre, @id_cuota_hijo, @id_cuota_hija)
union all
select 
    'PAGOS REALIZADOS' as Seccion,
    s.nombre + ' ' + s.apellido as Socio,
    p.monto as Monto,
    p.medio_de_pago as Medio_de_Pago,
    p.fecha_pago as Fecha_Pago,
    'Factura Extra' as Tipo_Factura
from socio.pago p
inner join socio.factura_extra fe on p.id_factura_extra = fe.id
inner join socio.registro_pileta rp on fe.id_registro_pileta = rp.id
inner join socio.socio s on rp.id_socio = s.id
where rp.id_socio in (@id_hijo1, @id_hija)
order by Socio, Fecha_Pago;

-- Estado de cuenta final de todos los miembros
select 
    'ESTADO DE CUENTA FINAL' as Seccion,
    s.nombre + ' ' + s.apellido as Socio,
    ec.saldo as Saldo_Actual,
    case 
        when ec.saldo > 0 then 'Saldo a favor'
        when ec.saldo < 0 then 'Deuda'
        else 'Saldo cero'
    end as Estado_Saldo
from socio.estado_cuenta ec
inner join socio.socio s on ec.id_socio = s.id
where ec.id_socio in (@id_padre, @id_hijo1, @id_hija)
order by s.fecha_nacimiento;

-- Verificación de descuentos aplicados
select 
    'VERIFICACIÓN DE DESCUENTOS' as Seccion,
    s.nombre + ' ' + s.apellido as Socio,
    'Cuota base' as Concepto,
    cu.monto_total as Monto_Base,
    fc.importe_total as Monto_Final,
    cu.monto_total - fc.importe_total as Descuento_Aplicado,
    round(((cu.monto_total - fc.importe_total) / cu.monto_total * 100), 2) as Porcentaje_Descuento
from socio.factura_cuota fc
inner join socio.cuota cu on fc.id_cuota = cu.id
inner join socio.socio s on cu.id_socio = s.id
where cu.id in (@id_cuota_padre, @id_cuota_hijo, @id_cuota_hija)
order by s.fecha_nacimiento;