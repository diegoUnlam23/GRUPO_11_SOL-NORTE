/*
    Archivo de Pruebas Detalladas - Caso 1: Socio mayor de edad responsable de pago
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

exec general.limpiarDatosPrueba;

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
-- CASO 1: SOCIO MAYOR DE EDAD RESPONSABLE DE PAGO
-- =====================================================

print '=== CASO 1: SOCIO MAYOR DE EDAD RESPONSABLE DE PAGO ===';
print 'Escenario: Pedro Martínez - Socio mayor de edad, responsable de pago, sin dependientes';
print '';

-- =====================================================
-- 1.1 CREACIÓN DEL SOCIO
-- =====================================================

print '1.1 CREACIÓN DEL SOCIO';
print 'Creando socio mayor de edad responsable de pago...';

exec socio.altaSocio @nombre = 'Pedro', @apellido = 'Martínez', @dni = 12345678, @email = 'pedro.martinez@email.com', 
    @fecha_nacimiento = '1990-01-30', @telefono = '11-3456-7890', @telefono_emergencia = '11-3456-7891', 
    @id_obra_social_socio = 1, @id_tutor = null, @id_grupo_familiar = null, @estado = 'Activo', @responsable_pago = 1;

-- Verificar creación del socio
select
    'Socio creado' as Estado,
    nombre + ' ' + apellido as Nombre_Completo,
    dni as DNI,
    email as Email,
    fecha_nacimiento as Fecha_Nacimiento,
    estado as Estado_Socio,
    case responsable_pago when 1 then 'Sí' else 'No' end as Responsable_Pago
from socio.socio 
where dni = 12345678;

-- Verificar que se creó el estado de cuenta
select
    'Estado de cuenta creado' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    ec.saldo as Saldo_Inicial
from socio.estado_cuenta ec
inner join socio.socio s on ec.id_socio = s.id
where s.dni = 12345678;

print 'Socio Pedro Martínez creado exitosamente';
print '';

-- =====================================================
-- 1.2 CREACIÓN DE CUOTA
-- =====================================================

print '1.2 CREACIÓN DE CUOTA';
print 'Creando cuota para el socio...';

declare @id_socio_pedro int, @id_cuota_pedro int;
select @id_socio_pedro = id from socio.socio where dni = 12345678;

exec socio.altaCuota @id_socio = @id_socio_pedro, @id_categoria = 3, @monto_total = 200.00;
select @id_cuota_pedro = max(id) from socio.cuota where id_socio = @id_socio_pedro;

-- Verificar creación de la cuota
select 
    'Cuota creada' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    c.nombre as Categoria,
    cu.monto_total as Monto_Total
from socio.cuota cu
inner join socio.socio s on cu.id_socio = s.id
inner join socio.categoria c on cu.id_categoria = c.id
where cu.id = @id_cuota_pedro;

print 'Cuota creada exitosamente para Pedro Martínez - Categoría Mayor ($200.00)';
print '';

-- =====================================================
-- 1.3 INSCRIPCIÓN A ACTIVIDADES DEPORTIVAS
-- =====================================================

print '1.3 INSCRIPCIÓN A ACTIVIDADES DEPORTIVAS';
print 'Inscribiendo a Pedro Martínez a múltiples actividades deportivas...';

-- Inscribir a Futsal
exec socio.altaInscripcionActividad @id_cuota = @id_cuota_pedro, @id_actividad = 1, @fecha_inscripcion = '2024-01-15';
print 'Inscripción a Futsal completada';

-- Inscribir a Natación
exec socio.altaInscripcionActividad @id_cuota = @id_cuota_pedro, @id_actividad = 5, @fecha_inscripcion = '2024-01-15';
print 'Inscripción a Natación completada';

-- Inscribir a Ajedrez
exec socio.altaInscripcionActividad @id_cuota = @id_cuota_pedro, @id_actividad = 6, @fecha_inscripcion = '2024-01-15';
print 'Inscripción a Ajedrez completada';

-- Verificar inscripciones
select 
    'Inscripciones activas' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    a.nombre as Actividad,
    a.costo_mensual as Costo_Mensual,
    ia.fecha_inscripcion as Fecha_Inscripcion,
    case ia.activa when 1 then 'Activa' else 'Inactiva' end as Estado_Inscripcion
from socio.inscripcion_actividad ia
inner join socio.cuota c on ia.id_cuota = c.id
inner join socio.socio s on c.id_socio = s.id
inner join general.actividad a on ia.id_actividad = a.id
where c.id = @id_cuota_pedro and ia.activa = 1
order by a.nombre;

print 'Pedro Martínez inscrito a 3 actividades deportivas (Futsal, Natación, Ajedrez)';
print 'Esto debería generar un descuento del 10% por múltiples actividades deportivas';
print '';

-- =====================================================
-- 1.4 CREACIÓN DE FACTURA CUOTA
-- =====================================================

print '1.4 CREACIÓN DE FACTURA CUOTA';
print 'Generando factura cuota con descuentos aplicados...';

exec socio.altaFacturaCuota @id_cuota = @id_cuota_pedro;

-- Verificar factura creada
declare @id_factura_cuota_pedro int;
select @id_factura_cuota_pedro = max(id) from socio.factura_cuota where id_cuota = @id_cuota_pedro;

select 
    'Factura cuota generada' as Estado,
    numero_comprobante as Numero_Comprobante,
    fecha_emision as Fecha_Emision,
    fecha_vencimiento_1 as Fecha_Vencimiento,
    importe_total as Importe_Total,
    'CUIT: 30-12345678-9' as CUIT_Empresa,
    'IVA: Responsable Inscripto' as Condicion_IVA,
    'Tipo: A' as Tipo_Comprobante
from socio.factura_cuota 
where id = @id_factura_cuota_pedro;

-- Verificar items de la factura
select 
    'Items de factura' as Estado,
    tipo_item as Concepto,
    cantidad as Cantidad,
    precio_unitario as Precio_Unitario,
    alicuota_iva as Alicuota_IVA,
    subtotal as Subtotal,
    importe_total as Importe_Total
from socio.item_factura_cuota
where id_factura_cuota = @id_factura_cuota_pedro;

print 'Factura cuota generada exitosamente con formato AFIP';
print 'Vencimiento: 5 días desde la generación';
print 'Segundo vencimiento: 10 días con 10% de recargo';
print '';

-- =====================================================
-- 1.5 PROCESAMIENTO DE PAGO
-- =====================================================

print '1.5 PROCESAMIENTO DE PAGO';
print 'Procesando pago de la factura cuota...';

declare @monto_factura_cuota_pedro decimal(8,2);
select @monto_factura_cuota_pedro = importe_total from socio.factura_cuota where id = @id_factura_cuota_pedro;

-- Mostrar estado de cuenta ANTES del pago
print '';
print '--- ESTADO DE CUENTA ANTES DEL PAGO ---';
select 
    'Estado de cuenta ANTES del pago' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    ec.saldo as Saldo_Actual,
    case 
        when ec.saldo > 0 then 'Saldo a favor'
        when ec.saldo < 0 then 'Deuda'
        else 'Saldo cero'
    end as Estado_Saldo
from socio.estado_cuenta ec
inner join socio.socio s on ec.id_socio = s.id
where ec.id_socio = @id_socio_pedro;

-- Mostrar movimientos ANTES del pago
print '';
print '--- MOVIMIENTOS ANTES DEL PAGO ---';
select 
    'Movimientos ANTES del pago' as Estado,
    mc.fecha as Fecha,
    case 
        when mc.id_factura is not null then 'Factura'
        when mc.id_pago is not null then 'Pago'
        when mc.id_reembolso is not null then 'Reembolso'
        else 'Otro'
    end as Tipo,
    mc.monto as Monto,
    case 
        when mc.id_factura is not null then 'Factura ID: ' + cast(mc.id_factura as varchar(10))
        when mc.id_pago is not null then 'Pago ID: ' + cast(mc.id_pago as varchar(10))
        when mc.id_reembolso is not null then 'Reembolso ID: ' + cast(mc.id_reembolso as varchar(10))
        else 'Sin descripción'
    end as Descripcion
from socio.movimiento_cuenta mc
inner join socio.estado_cuenta ec on mc.id_estado_cuenta = ec.id
where ec.id_socio = @id_socio_pedro
order by mc.fecha desc;

-- Procesar pago con tarjeta de crédito
print '';
print 'Procesando pago de $' + cast(@monto_factura_cuota_pedro as varchar(10)) + ' con tarjeta Visa...';
exec socio.altaPago @monto = @monto_factura_cuota_pedro, @medio_de_pago = 'Visa', @id_factura_cuota = @id_factura_cuota_pedro;

-- Verificar pago procesado
select 
    'Pago procesado' as Estado,
    monto as Monto_Pagado,
    medio_de_pago as Medio_de_Pago,
    fecha_pago as Fecha_Pago,
    'Factura cuota pagada completamente' as Observacion
from socio.pago
where id_factura_cuota = @id_factura_cuota_pedro;

-- Mostrar estado de cuenta DESPUÉS del pago
print '';
print '--- ESTADO DE CUENTA DESPUÉS DEL PAGO ---';
select 
    'Estado de cuenta DESPUÉS del pago' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    ec.saldo as Saldo_Actual,
    case 
        when ec.saldo > 0 then 'Saldo a favor'
        when ec.saldo < 0 then 'Deuda'
        else 'Saldo cero'
    end as Estado_Saldo
from socio.estado_cuenta ec
inner join socio.socio s on ec.id_socio = s.id
where ec.id_socio = @id_socio_pedro;

-- Mostrar movimientos DESPUÉS del pago
print '';
print '--- MOVIMIENTOS DESPUÉS DEL PAGO ---';
select 
    'Movimientos DESPUÉS del pago' as Estado,
    mc.fecha as Fecha,
    case 
        when mc.id_factura is not null then 'Factura'
        when mc.id_pago is not null then 'Pago'
        when mc.id_reembolso is not null then 'Reembolso'
        else 'Otro'
    end as Tipo,
    mc.monto as Monto,
    case 
        when mc.id_factura is not null then 'Factura ID: ' + cast(mc.id_factura as varchar(10))
        when mc.id_pago is not null then 'Pago ID: ' + cast(mc.id_pago as varchar(10))
        when mc.id_reembolso is not null then 'Reembolso ID: ' + cast(mc.id_reembolso as varchar(10))
        else 'Sin descripción'
    end as Descripcion
from socio.movimiento_cuenta mc
inner join socio.estado_cuenta ec on mc.id_estado_cuenta = ec.id
where ec.id_socio = @id_socio_pedro
order by mc.fecha desc;

print 'Pago procesado exitosamente con tarjeta Visa';
print '';

-- =====================================================
-- 1.6 USO DE PILETA
-- =====================================================

print '1.6 USO DE PILETA';
print 'Registrando uso de pileta por el socio...';

-- Registrar uso de pileta
exec socio.altaRegistroPileta @id_socio = @id_socio_pedro, @id_invitado = null, @fecha = '2024-01-20', @id_tarifa = 1;

-- Verificar registro de pileta
select 
    'Registro de pileta' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    rp.fecha as Fecha_Uso,
    tp.tipo as Tipo_Tarifa,
    tp.precio as Precio
from socio.registro_pileta rp
inner join socio.socio s on rp.id_socio = s.id
inner join socio.tarifa_pileta tp on rp.id_tarifa = tp.id
where rp.id_socio = @id_socio_pedro and rp.fecha = '2024-01-20';

print 'Uso de pileta registrado exitosamente';
print '';

-- =====================================================
-- 1.7 CREACIÓN DE FACTURA EXTRA (PILETA)
-- =====================================================

print '1.7 CREACIÓN DE FACTURA EXTRA (PILETA)';
print 'Generando factura extra por uso de pileta...';

-- Verificar que se generó automáticamente la factura extra
declare @id_factura_extra_pileta int;
select @id_factura_extra_pileta = max(id) from socio.factura_extra where id_registro_pileta = 1;

select 
    'Factura extra generada' as Estado,
    numero_comprobante as Numero_Comprobante,
    fecha_emision as Fecha_Emision,
    importe_total as Importe_Total,
    'Factura inmediata por uso de pileta' as Tipo
from socio.factura_extra 
where id = @id_factura_extra_pileta;

-- Mostrar estado de cuenta DESPUÉS de generar factura extra
print '';
print '--- ESTADO DE CUENTA DESPUÉS DE GENERAR FACTURA EXTRA ---';
select 
    'Estado de cuenta DESPUÉS de factura extra' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    ec.saldo as Saldo_Actual,
    case 
        when ec.saldo > 0 then 'Saldo a favor'
        when ec.saldo < 0 then 'Deuda'
        else 'Saldo cero'
    end as Estado_Saldo
from socio.estado_cuenta ec
inner join socio.socio s on ec.id_socio = s.id
where ec.id_socio = @id_socio_pedro;

print 'Factura extra generada automáticamente por uso de pileta';
print '';

-- =====================================================
-- 1.8 PAGO DE FACTURA EXTRA
-- =====================================================

print '1.8 PAGO DE FACTURA EXTRA';
print 'Procesando pago de la factura extra...';

declare @monto_factura_extra_pileta decimal(8,2);
select @monto_factura_extra_pileta = importe_total from socio.factura_extra where id = @id_factura_extra_pileta;

-- Mostrar estado de cuenta ANTES del pago de factura extra
print '';
print '--- ESTADO DE CUENTA ANTES DEL PAGO DE FACTURA EXTRA ---';
select 
    'Estado de cuenta ANTES del pago de factura extra' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    ec.saldo as Saldo_Actual,
    case 
        when ec.saldo > 0 then 'Saldo a favor'
        when ec.saldo < 0 then 'Deuda'
        else 'Saldo cero'
    end as Estado_Saldo
from socio.estado_cuenta ec
inner join socio.socio s on ec.id_socio = s.id
where ec.id_socio = @id_socio_pedro;

-- Procesar pago de factura extra
print '';
print 'Procesando pago de $' + cast(@monto_factura_extra_pileta as varchar(10)) + ' con MasterCard...';
print 'NOTA: Las facturas extra son pagos inmediatos que NO afectan el estado de cuenta';
exec socio.altaPago @monto = @monto_factura_extra_pileta, @medio_de_pago = 'MasterCard', @id_factura_extra = @id_factura_extra_pileta;

-- Verificar pago de factura extra
select 
    'Pago factura extra procesado' as Estado,
    monto as Monto_Pagado,
    medio_de_pago as Medio_de_Pago,
    fecha_pago as Fecha_Pago,
    'Factura extra pagada completamente' as Observacion
from socio.pago
where id_factura_extra = @id_factura_extra_pileta;

-- Mostrar estado de cuenta DESPUÉS del pago de factura extra (NO DEBERÍA CAMBIAR)
print '';
print '--- ESTADO DE CUENTA DESPUÉS DEL PAGO DE FACTURA EXTRA ---';
print 'NOTA: El estado de cuenta NO debería cambiar porque las facturas extra son pagos inmediatos';
select 
    'Estado de cuenta DESPUÉS del pago de factura extra (NO CAMBIA)' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    ec.saldo as Saldo_Actual,
    case 
        when ec.saldo > 0 then 'Saldo a favor'
        when ec.saldo < 0 then 'Deuda'
        else 'Saldo cero'
    end as Estado_Saldo,
    'Las facturas extra NO generan movimientos en la cuenta' as Observacion
from socio.estado_cuenta ec
inner join socio.socio s on ec.id_socio = s.id
where ec.id_socio = @id_socio_pedro;

-- Mostrar movimientos DESPUÉS del pago de factura extra (NO DEBERÍA HABER NUEVOS MOVIMIENTOS)
print '';
print '--- MOVIMIENTOS DESPUÉS DEL PAGO DE FACTURA EXTRA ---';
print 'NOTA: NO debería haber nuevos movimientos porque las facturas extra son pagos inmediatos';
select 
    'Movimientos DESPUÉS del pago de factura extra (NO CAMBIAN)' as Estado,
    mc.fecha as Fecha,
    case 
        when mc.id_factura is not null then 'Factura'
        when mc.id_pago is not null then 'Pago'
        when mc.id_reembolso is not null then 'Reembolso'
        else 'Otro'
    end as Tipo,
    mc.monto as Monto,
    case 
        when mc.id_factura is not null then 'Factura ID: ' + cast(mc.id_factura as varchar(10))
        when mc.id_pago is not null then 'Pago ID: ' + cast(mc.id_pago as varchar(10))
        when mc.id_reembolso is not null then 'Reembolso ID: ' + cast(mc.id_reembolso as varchar(10))
        else 'Sin descripción'
    end as Descripcion
from socio.movimiento_cuenta mc
inner join socio.estado_cuenta ec on mc.id_estado_cuenta = ec.id
where ec.id_socio = @id_socio_pedro
order by mc.fecha desc;

print 'Pago de factura extra procesado exitosamente con MasterCard';
print 'IMPORTANTE: Las facturas extra son pagos inmediatos que NO afectan el estado de cuenta';
print '';

-- =====================================================
-- 1.9 ACTIVIDAD EXTRA
-- =====================================================

print '1.9 ACTIVIDAD EXTRA';
print 'Registrando actividad extra para el socio...';

-- Crear actividad extra
exec general.altaActividadExtra @id_socio = @id_socio_pedro, @nombre = 'Alquiler del SUM para cumpleaños', @costo = 500.00;

-- Verificar actividad extra creada
select 
    'Actividad extra creada' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    ae.nombre as Actividad,
    ae.costo as Costo
from general.actividad_extra ae
inner join socio.socio s on ae.id_socio = s.id
where ae.id_socio = @id_socio_pedro;

print 'Actividad extra "Alquiler del SUM para cumpleaños" registrada';
print '';

-- =====================================================
-- 1.10 CREACIÓN DE FACTURA EXTRA (ACTIVIDAD EXTRA)
-- =====================================================

print '1.10 CREACIÓN DE FACTURA EXTRA (ACTIVIDAD EXTRA)';
print 'Generando factura extra por actividad extra...';

-- Verificar que se generó automáticamente la factura extra
declare @id_factura_extra_actividad int;
select @id_factura_extra_actividad = max(id) from socio.factura_extra where id_actividad_extra = 1;

select 
    'Factura extra actividad generada' as Estado,
    numero_comprobante as Numero_Comprobante,
    fecha_emision as Fecha_Emision,
    importe_total as Importe_Total,
    'Factura por actividad extra' as Tipo
from socio.factura_extra 
where id = @id_factura_extra_actividad;

-- Mostrar estado de cuenta DESPUÉS de generar factura extra por actividad
print '';
print '--- ESTADO DE CUENTA DESPUÉS DE GENERAR FACTURA EXTRA POR ACTIVIDAD ---';
print 'NOTA: El estado de cuenta NO debería cambiar porque las facturas extra son inmediatas';
select 
    'Estado de cuenta DESPUÉS de factura extra por actividad (NO CAMBIA)' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    ec.saldo as Saldo_Actual,
    case 
        when ec.saldo > 0 then 'Saldo a favor'
        when ec.saldo < 0 then 'Deuda'
        else 'Saldo cero'
    end as Estado_Saldo,
    'Las facturas extra NO generan movimientos en la cuenta' as Observacion
from socio.estado_cuenta ec
inner join socio.socio s on ec.id_socio = s.id
where ec.id_socio = @id_socio_pedro;

print 'Factura extra generada automáticamente por actividad extra';
print '';

-- =====================================================
-- 1.11 PAGO DE FACTURA EXTRA (ACTIVIDAD EXTRA)
-- =====================================================

print '1.11 PAGO DE FACTURA EXTRA (ACTIVIDAD EXTRA)';
print 'Procesando pago de la factura extra por actividad...';

declare @monto_factura_extra_actividad decimal(8,2);
select @monto_factura_extra_actividad = importe_total from socio.factura_extra where id = @id_factura_extra_actividad;

-- Mostrar estado de cuenta ANTES del pago de factura extra por actividad
print '';
print '--- ESTADO DE CUENTA ANTES DEL PAGO DE FACTURA EXTRA POR ACTIVIDAD ---';
select 
    'Estado de cuenta ANTES del pago de factura extra por actividad' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    ec.saldo as Saldo_Actual,
    case 
        when ec.saldo > 0 then 'Saldo a favor'
        when ec.saldo < 0 then 'Deuda'
        else 'Saldo cero'
    end as Estado_Saldo
from socio.estado_cuenta ec
inner join socio.socio s on ec.id_socio = s.id
where ec.id_socio = @id_socio_pedro;

-- Procesar pago de factura extra por actividad
print '';
print 'Procesando pago de $' + cast(@monto_factura_extra_actividad as varchar(10)) + ' con Transferencia Mercado Pago...';
print 'NOTA: Las facturas extra son pagos inmediatos que NO afectan el estado de cuenta';
exec socio.altaPago @monto = @monto_factura_extra_actividad, @medio_de_pago = 'Transferencia Mercado Pago', @id_factura_extra = @id_factura_extra_actividad;

-- Verificar pago de factura extra por actividad
select 
    'Pago factura extra actividad procesado' as Estado,
    monto as Monto_Pagado,
    medio_de_pago as Medio_de_Pago,
    fecha_pago as Fecha_Pago,
    'Factura extra por actividad pagada completamente' as Observacion
from socio.pago
where id_factura_extra = @id_factura_extra_actividad;

-- Mostrar estado de cuenta DESPUÉS del pago de factura extra por actividad (NO DEBERÍA CAMBIAR)
print '';
print '--- ESTADO DE CUENTA DESPUÉS DEL PAGO DE FACTURA EXTRA POR ACTIVIDAD ---';
print 'NOTA: El estado de cuenta NO debería cambiar porque las facturas extra son pagos inmediatos';
select 
    'Estado de cuenta DESPUÉS del pago de factura extra por actividad (NO CAMBIA)' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    ec.saldo as Saldo_Actual,
    case 
        when ec.saldo > 0 then 'Saldo a favor'
        when ec.saldo < 0 then 'Deuda'
        else 'Saldo cero'
    end as Estado_Saldo,
    'Las facturas extra NO generan movimientos en la cuenta' as Observacion
from socio.estado_cuenta ec
inner join socio.socio s on ec.id_socio = s.id
where ec.id_socio = @id_socio_pedro;

-- Mostrar movimientos DESPUÉS del pago de factura extra por actividad (NO DEBERÍA HABER NUEVOS MOVIMIENTOS)
print '';
print '--- MOVIMIENTOS DESPUÉS DEL PAGO DE FACTURA EXTRA POR ACTIVIDAD ---';
print 'NOTA: NO debería haber nuevos movimientos porque las facturas extra son pagos inmediatos';
select 
    'Movimientos DESPUÉS del pago de factura extra por actividad (NO CAMBIAN)' as Estado,
    mc.fecha as Fecha,
    case 
        when mc.id_factura is not null then 'Factura'
        when mc.id_pago is not null then 'Pago'
        when mc.id_reembolso is not null then 'Reembolso'
        else 'Otro'
    end as Tipo,
    mc.monto as Monto,
    case 
        when mc.id_factura is not null then 'Factura ID: ' + cast(mc.id_factura as varchar(10))
        when mc.id_pago is not null then 'Pago ID: ' + cast(mc.id_pago as varchar(10))
        when mc.id_reembolso is not null then 'Reembolso ID: ' + cast(mc.id_reembolso as varchar(10))
        else 'Sin descripción'
    end as Descripcion
from socio.movimiento_cuenta mc
inner join socio.estado_cuenta ec on mc.id_estado_cuenta = ec.id
where ec.id_socio = @id_socio_pedro
order by mc.fecha desc;

print 'Pago de factura extra por actividad procesado exitosamente con Transferencia Mercado Pago';
print 'IMPORTANTE: Las facturas extra son pagos inmediatos que NO afectan el estado de cuenta';
print '';

-- =====================================================
-- 1.12 DÉBITO AUTOMÁTICO
-- =====================================================

print '1.12 DÉBITO AUTOMÁTICO';
print 'Configurando débito automático para el socio...';

-- Crear débito automático
exec socio.altaDebitoAutomatico @id_responsable_pago = @id_socio_pedro, @medio_de_pago = 'Visa', @activo = 1, 
    @token_pago = 'tok_visa_pedro_123', @ultimos_4_digitos = 1234, @titular = 'Pedro Martínez';

-- Verificar débito automático creado
select 
    'Débito automático configurado' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    da.medio_de_pago as Medio_de_Pago,
    da.ultimos_4_digitos as Ultimos_4_Digitos,
    da.titular as Titular,
    case da.activo when 1 then 'Activo' else 'Inactivo' end as Estado_Debito
from socio.debito_automatico da
inner join socio.socio s on da.id_responsable_pago = s.id
where da.id_responsable_pago = @id_socio_pedro;

print 'Débito automático configurado exitosamente con tarjeta Visa';
print '';

-- =====================================================
-- 1.12.1 PROCESAMIENTO DE DÉBITO AUTOMÁTICO
-- =====================================================

print '1.12.1 PROCESAMIENTO DE DÉBITO AUTOMÁTICO';
print 'Simulando procesamiento automático de débitos...';

-- Mostrar estado de cuenta ANTES del procesamiento automático
print '';
print '--- ESTADO DE CUENTA ANTES DEL PROCESAMIENTO AUTOMÁTICO ---';
select 
    'Estado de cuenta ANTES del procesamiento automático' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    ec.saldo as Saldo_Actual,
    case 
        when ec.saldo > 0 then 'Saldo a favor'
        when ec.saldo < 0 then 'Deuda'
        else 'Saldo cero'
    end as Estado_Saldo
from socio.estado_cuenta ec
inner join socio.socio s on ec.id_socio = s.id
where ec.id_socio = @id_socio_pedro;

-- Mostrar facturas de cuota ANTES de procesar débitos automáticos
print '';
print '--- FACTURAS DE CUOTA ANTES DEL DÉBITO AUTOMÁTICO ---';
select 
    'Facturas existentes' as Estado,
    fc.id as ID_Factura,
    fc.numero_comprobante as Numero,
    fc.fecha_emision as Fecha,
    fc.periodo_facturado as Periodo,
    fc.importe_total as Importe,
    fc.descripcion as Descripcion
from socio.factura_cuota fc
inner join socio.cuota c on fc.id_cuota = c.id
where c.id_socio = @id_socio_pedro
order by fc.fecha_emision;

-- Procesar débitos automáticos (primera vez)
print '';
print 'Procesando débitos automáticos para la fecha 2024-01-15 (primera vez)...';
exec socio.procesarDebitosAutomaticos @fecha_procesamiento = '2024-01-15';

-- Mostrar facturas de cuota DESPUÉS del primer procesamiento
print '';
print '--- FACTURAS DE CUOTA DESPUÉS DEL PRIMER DÉBITO AUTOMÁTICO ---';
select 
    'Facturas después del débito automático' as Estado,
    fc.id as ID_Factura,
    fc.numero_comprobante as Numero,
    fc.fecha_emision as Fecha,
    fc.periodo_facturado as Periodo,
    fc.importe_total as Importe,
    fc.descripcion as Descripcion
from socio.factura_cuota fc
inner join socio.cuota c on fc.id_cuota = c.id
where c.id_socio = @id_socio_pedro
order by fc.fecha_emision;

-- Mostrar estado de cuenta DESPUÉS del procesamiento automático
print '';
print '--- ESTADO DE CUENTA DESPUÉS DEL PROCESAMIENTO AUTOMÁTICO ---';
select 
    'Estado de cuenta DESPUÉS del procesamiento automático' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    ec.saldo as Saldo_Actual,
    case 
        when ec.saldo > 0 then 'Saldo a favor'
        when ec.saldo < 0 then 'Deuda'
        else 'Saldo cero'
    end as Estado_Saldo,
    'Débito automático procesado exitosamente' as Observacion
from socio.estado_cuenta ec
inner join socio.socio s on ec.id_socio = s.id
where ec.id_socio = @id_socio_pedro;

-- Verificar factura y pago generados automáticamente
print '';
print '--- VERIFICACIÓN DE FACTURA Y PAGO AUTOMÁTICO ---';
select 
    'Factura automática generada' as Estado,
    fc.numero_comprobante as Numero_Factura,
    fc.fecha_emision as Fecha_Emision,
    fc.importe_total as Importe_Total,
    'Generada automáticamente por débito automático' as Tipo
from socio.factura_cuota fc
inner join socio.cuota c on fc.id_cuota = c.id
where c.id_socio = @id_socio_pedro
and cast(fc.fecha_emision as date) = cast(getdate() as date);

select 
    'Pago automático procesado' as Estado,
    p.monto as Monto_Pagado,
    p.medio_de_pago as Medio_de_Pago,
    p.fecha_pago as Fecha_Pago,
    'Procesado automáticamente por débito automático' as Tipo
from socio.pago p
inner join socio.factura_cuota fc on p.id_factura_cuota = fc.id
inner join socio.cuota c on fc.id_cuota = c.id
where c.id_socio = @id_socio_pedro
and cast(p.fecha_pago as date) = cast(getdate() as date);

print 'Débito automático procesado exitosamente';
print 'IMPORTANTE: El sistema genera facturas y procesa pagos automáticamente para socios con débito automático activo';
print '';

-- =====================================================
-- 1.13 REGISTRO DE PRESENTISMO
-- =====================================================

print '1.13 REGISTRO DE PRESENTISMO';
print 'Registrando presentismo en clases...';

-- Crear clase para registrar presentismo
exec general.altaClase @hora_inicio = '18:00', @hora_fin = '19:00', @dia = 'Lunes', @id_categoria = 3, @id_actividad = 1, @id_empleado = 1;

-- Registrar presentismo
declare @id_clase_futsal int;
select @id_clase_futsal = id from general.clase where id_actividad = 1 and id_categoria = 3;

exec general.altaPresentismo @id_socio = @id_socio_pedro, @id_clase = @id_clase_futsal, @fecha = '2024-01-22', @tipo_asistencia = 'A';

-- Verificar presentismo registrado
select 
    'Presentismo registrado' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    a.nombre as Actividad,
    CONVERT(varchar(5), c.hora_inicio, 108) + ' - ' + CONVERT(varchar(5), c.hora_fin, 108) as Horario,
    c.dia as Dia,
    p.fecha as Fecha_Asistencia
from general.presentismo p
inner join socio.socio s on p.id_socio = s.id
inner join general.clase c on p.id_clase = c.id
inner join general.actividad a on c.id_actividad = a.id
where p.id_socio = @id_socio_pedro;

print 'Presentismo registrado exitosamente en clase de Futsal';
print '';

-- =====================================================
-- 1.14 CONSULTA DE ESTADO DE CUENTA
-- =====================================================

print '1.14 CONSULTA DE ESTADO DE CUENTA';
print 'Consultando estado de cuenta del socio...';

-- Verificar estado de cuenta
select 
    'Estado de cuenta' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    ec.saldo as Saldo_Actual,
    case 
        when ec.saldo > 0 then 'Saldo a favor'
        when ec.saldo < 0 then 'Deuda'
        else 'Saldo cero'
    end as Estado_Saldo
from socio.estado_cuenta ec
inner join socio.socio s on ec.id_socio = s.id
where ec.id_socio = @id_socio_pedro;

-- Verificar movimientos de cuenta
select 
    'Movimientos de cuenta' as Estado,
    mc.fecha as Fecha,
    case 
        when mc.id_factura is not null then 'Factura'
        when mc.id_pago is not null then 'Pago'
        when mc.id_reembolso is not null then 'Reembolso'
        else 'Otro'
    end as Tipo,
    mc.monto as Monto,
    case 
        when mc.id_factura is not null then 'Factura ID: ' + cast(mc.id_factura as varchar(10))
        when mc.id_pago is not null then 'Pago ID: ' + cast(mc.id_pago as varchar(10))
        when mc.id_reembolso is not null then 'Reembolso ID: ' + cast(mc.id_reembolso as varchar(10))
        else 'Sin descripción'
    end as Descripcion
from socio.movimiento_cuenta mc
inner join socio.estado_cuenta ec on mc.id_estado_cuenta = ec.id
where ec.id_socio = @id_socio_pedro
order by mc.fecha desc;

print 'Estado de cuenta consultado exitosamente';
print '';

-- =====================================================
-- 1.15 REEMBOLSO
-- =====================================================

print '1.15 REEMBOLSO';
print 'Procesando reembolso por error en facturación...';

-- Obtener un pago para reembolsar
declare @id_pago_reembolso int;
select @id_pago_reembolso = max(id) from socio.pago where id_factura_cuota = @id_factura_cuota_pedro;

-- Mostrar estado de cuenta ANTES del reembolso
print '';
print '--- ESTADO DE CUENTA ANTES DEL REEMBOLSO ---';
select 
    'Estado de cuenta ANTES del reembolso' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    ec.saldo as Saldo_Actual,
    case 
        when ec.saldo > 0 then 'Saldo a favor'
        when ec.saldo < 0 then 'Deuda'
        else 'Saldo cero'
    end as Estado_Saldo
from socio.estado_cuenta ec
inner join socio.socio s on ec.id_socio = s.id
where ec.id_socio = @id_socio_pedro;

-- Procesar reembolso
exec socio.altaReembolso @id_pago = @id_pago_reembolso, @motivo = 'Error en facturación - Duplicado', @id_tipo_reembolso = 2;

-- Verificar reembolso procesado
select 
    'Reembolso procesado' as Estado,
    r.fecha_reembolso as Fecha_Reembolso,
    r.motivo as Motivo,
    tr.descripcion as Tipo_Reembolso,
    r.monto as Monto_Reembolsado
from socio.reembolso r
inner join socio.tipo_reembolso tr on r.id_tipo_reembolso = tr.id
where r.id_pago = @id_pago_reembolso;

-- Mostrar estado de cuenta DESPUÉS del reembolso
print '';
print '--- ESTADO DE CUENTA DESPUÉS DEL REEMBOLSO ---';
select 
    'Estado de cuenta DESPUÉS del reembolso' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    ec.saldo as Saldo_Actual,
    case 
        when ec.saldo > 0 then 'Saldo a favor'
        when ec.saldo < 0 then 'Deuda'
        else 'Saldo cero'
    end as Estado_Saldo
from socio.estado_cuenta ec
inner join socio.socio s on ec.id_socio = s.id
where ec.id_socio = @id_socio_pedro;

-- Mostrar movimientos DESPUÉS del reembolso
print '';
print '--- MOVIMIENTOS DESPUÉS DEL REEMBOLSO ---';
select 
    'Movimientos DESPUÉS del reembolso' as Estado,
    mc.fecha as Fecha,
    case 
        when mc.id_factura is not null then 'Factura'
        when mc.id_pago is not null then 'Pago'
        when mc.id_reembolso is not null then 'Reembolso'
        else 'Otro'
    end as Tipo,
    mc.monto as Monto,
    case 
        when mc.id_factura is not null then 'Factura ID: ' + cast(mc.id_factura as varchar(10))
        when mc.id_pago is not null then 'Pago ID: ' + cast(mc.id_pago as varchar(10))
        when mc.id_reembolso is not null then 'Reembolso ID: ' + cast(mc.id_reembolso as varchar(10))
        else 'Sin descripción'
    end as Descripcion
from socio.movimiento_cuenta mc
inner join socio.estado_cuenta ec on mc.id_estado_cuenta = ec.id
where ec.id_socio = @id_socio_pedro
order by mc.fecha desc;

print 'Reembolso procesado exitosamente';
print '';

-- =====================================================
-- 1.16 REINTEGRO POR LLUVIA
-- =====================================================

print '1.16 REINTEGRO POR LLUVIA';
print 'Procesando reintegro por lluvia...';

-- Registrar uso de pileta en día de lluvia
exec socio.altaRegistroPileta @id_socio = @id_socio_pedro, @id_invitado = null, @fecha = '2024-01-25', @id_tarifa = 1;

-- Procesar pago de pileta
declare @id_factura_pileta_lluvia int, @monto_pileta_lluvia decimal(8,2);
select @id_factura_pileta_lluvia = max(id) from socio.factura_extra where id_registro_pileta = 2;
select @monto_pileta_lluvia = importe_total from socio.factura_extra where id = @id_factura_pileta_lluvia;

-- Mostrar estado de cuenta ANTES del pago de pileta por lluvia
print '';
print '--- ESTADO DE CUENTA ANTES DEL PAGO DE PILETA POR LLUVIA ---';
select 
    'Estado de cuenta ANTES del pago de pileta por lluvia' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    ec.saldo as Saldo_Actual,
    case 
        when ec.saldo > 0 then 'Saldo a favor'
        when ec.saldo < 0 then 'Deuda'
        else 'Saldo cero'
    end as Estado_Saldo
from socio.estado_cuenta ec
inner join socio.socio s on ec.id_socio = s.id
where ec.id_socio = @id_socio_pedro;

print '';
print 'Procesando pago de $' + cast(@monto_pileta_lluvia as varchar(10)) + ' con Visa...';
exec socio.altaPago @monto = @monto_pileta_lluvia, @medio_de_pago = 'Visa', @id_factura_extra = @id_factura_pileta_lluvia;

-- Mostrar estado de cuenta DESPUÉS del pago de pileta por lluvia
print '';
print '--- ESTADO DE CUENTA DESPUÉS DEL PAGO DE PILETA POR LLUVIA ---';
select 
    'Estado de cuenta DESPUÉS del pago de pileta por lluvia' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    ec.saldo as Saldo_Actual,
    case 
        when ec.saldo > 0 then 'Saldo a favor'
        when ec.saldo < 0 then 'Deuda'
        else 'Saldo cero'
    end as Estado_Saldo
from socio.estado_cuenta ec
inner join socio.socio s on ec.id_socio = s.id
where ec.id_socio = @id_socio_pedro;

-- Procesar reintegro por lluvia
print '';
print 'Procesando reintegro del 60% por lluvia...';
print 'NOTA: El reintegro del 60% se aplica mediante el parámetro de porcentaje pasado a altaReembolso';
print 'Monto esperado: $' + cast(@monto_pileta_lluvia as varchar(10)) + ' * 0.60 = $' + cast(@monto_pileta_lluvia * 0.60 as varchar(10));
exec socio.procesarReintegroLluvia @fecha_lluvia = '2024-01-25', @porcentaje_reintegro = 60.00;

-- Mostrar estado de cuenta DESPUÉS del reintegro por lluvia
print '';
print '--- ESTADO DE CUENTA DESPUÉS DEL REINTEGRO POR LLUVIA ---';
select 
    'Estado de cuenta DESPUÉS del reintegro por lluvia' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    ec.saldo as Saldo_Actual,
    case 
        when ec.saldo > 0 then 'Saldo a favor'
        when ec.saldo < 0 then 'Deuda'
        else 'Saldo cero'
    end as Estado_Saldo,
    'Reintegro del 60% aplicado mediante parámetro de porcentaje' as Observacion
from socio.estado_cuenta ec
inner join socio.socio s on ec.id_socio = s.id
where ec.id_socio = @id_socio_pedro;

-- Mostrar movimientos DESPUÉS del reintegro por lluvia
print '';
print '--- MOVIMIENTOS DESPUÉS DEL REINTEGRO POR LLUVIA ---';
select 
    'Movimientos DESPUÉS del reintegro por lluvia' as Estado,
    mc.fecha as Fecha,
    case 
        when mc.id_factura is not null then 'Factura'
        when mc.id_pago is not null then 'Pago'
        when mc.id_reembolso is not null then 'Reembolso'
        else 'Otro'
    end as Tipo,
    mc.monto as Monto,
    case 
        when mc.id_factura is not null then 'Factura ID: ' + cast(mc.id_factura as varchar(10))
        when mc.id_pago is not null then 'Pago ID: ' + cast(mc.id_pago as varchar(10))
        when mc.id_reembolso is not null then 'Reembolso ID: ' + cast(mc.id_reembolso as varchar(10))
        else 'Sin descripción'
    end as Descripcion
from socio.movimiento_cuenta mc
inner join socio.estado_cuenta ec on mc.id_estado_cuenta = ec.id
where ec.id_socio = @id_socio_pedro
order by mc.fecha desc;

-- Verificar el reembolso específico por lluvia
print '';
print '--- VERIFICACIÓN DEL REEMBOLSO POR LLUVIA ---';
select 
    'Reembolso por lluvia verificado' as Estado,
    r.fecha_reembolso as Fecha_Reembolso,
    r.motivo as Motivo,
    r.monto as Monto_Reembolsado,
    tr.descripcion as Tipo_Reembolso,
    '60% aplicado automáticamente por altaReembolso' as Observacion
from socio.reembolso r
inner join socio.tipo_reembolso tr on r.id_tipo_reembolso = tr.id
inner join socio.pago p on r.id_pago = p.id
where p.id_factura_extra = @id_factura_pileta_lluvia
and r.motivo = 'Reintegro por lluvia';

print 'Reintegro por lluvia procesado exitosamente (60% del valor de entrada)';
print 'IMPORTANTE: El reintegro del 60% se aplica mediante el parámetro de porcentaje pasado a altaReembolso';
print '';

-- =====================================================
-- 1.17 INVITADO A PILETA
-- =====================================================

print '1.17 INVITADO A PILETA';
print 'Registrando invitado a pileta...';

-- Registrar invitado a pileta
exec socio.altaRegistroPileta @id_socio = null, @id_invitado = 1, @fecha = '2024-01-26', @id_tarifa = 2;

-- Verificar factura inmediata para invitado
declare @id_factura_invitado int;
select @id_factura_invitado = max(id) from socio.factura_extra where id_registro_pileta = 3;

select 
    'Factura invitado generada' as Estado,
    numero_comprobante as Numero_Comprobante,
    fecha_emision as Fecha_Emision,
    importe_total as Importe_Total,
    'Factura inmediata para invitado' as Tipo
from socio.factura_extra 
where id = @id_factura_invitado;

-- Procesar pago inmediato del invitado
declare @monto_invitado decimal(8,2);
select @monto_invitado = importe_total from socio.factura_extra where id = @id_factura_invitado;

-- Mostrar estado de cuenta ANTES del pago del invitado
print '';
print '--- ESTADO DE CUENTA ANTES DEL PAGO DEL INVITADO ---';
select 
    'Estado de cuenta ANTES del pago del invitado' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    ec.saldo as Saldo_Actual,
    case 
        when ec.saldo > 0 then 'Saldo a favor'
        when ec.saldo < 0 then 'Deuda'
        else 'Saldo cero'
    end as Estado_Saldo
from socio.estado_cuenta ec
inner join socio.socio s on ec.id_socio = s.id
where ec.id_socio = @id_socio_pedro;

print '';
print 'Procesando pago de $' + cast(@monto_invitado as varchar(10)) + ' en efectivo por invitado...';
exec socio.altaPago @monto = @monto_invitado, @medio_de_pago = 'Efectivo', @id_factura_extra = @id_factura_invitado;

-- Mostrar estado de cuenta DESPUÉS del pago del invitado
print '';
print '--- ESTADO DE CUENTA DESPUÉS DEL PAGO DEL INVITADO ---';
select 
    'Estado de cuenta DESPUÉS del pago del invitado' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    ec.saldo as Saldo_Actual,
    case 
        when ec.saldo > 0 then 'Saldo a favor'
        when ec.saldo < 0 then 'Deuda'
        else 'Saldo cero'
    end as Estado_Saldo
from socio.estado_cuenta ec
inner join socio.socio s on ec.id_socio = s.id
where ec.id_socio = @id_socio_pedro;

-- Mostrar movimientos DESPUÉS del pago del invitado
print '';
print '--- MOVIMIENTOS DESPUÉS DEL PAGO DEL INVITADO ---';
select 
    'Movimientos DESPUÉS del pago del invitado' as Estado,
    mc.fecha as Fecha,
    case 
        when mc.id_factura is not null then 'Factura'
        when mc.id_pago is not null then 'Pago'
        when mc.id_reembolso is not null then 'Reembolso'
        else 'Otro'
    end as Tipo,
    mc.monto as Monto,
    case 
        when mc.id_factura is not null then 'Factura ID: ' + cast(mc.id_factura as varchar(10))
        when mc.id_pago is not null then 'Pago ID: ' + cast(mc.id_pago as varchar(10))
        when mc.id_reembolso is not null then 'Reembolso ID: ' + cast(mc.id_reembolso as varchar(10))
        else 'Sin descripción'
    end as Descripcion
from socio.movimiento_cuenta mc
inner join socio.estado_cuenta ec on mc.id_estado_cuenta = ec.id
where ec.id_socio = @id_socio_pedro
order by mc.fecha desc;

print 'Invitado registrado y factura pagada inmediatamente';
print '';

-- =====================================================
-- 1.18 VERIFICACIÓN FINAL DEL CASO
-- =====================================================

print '1.18 VERIFICACIÓN FINAL DEL CASO';
print 'Realizando verificación completa del caso...';

-- Resumen del socio
select 
    'RESUMEN DEL SOCIO' as Seccion,
    s.nombre + ' ' + s.apellido as Socio,
    s.dni as DNI,
    s.email as Email,
    s.estado as Estado,
    case s.responsable_pago when 1 then 'Sí' else 'No' end as Responsable_Pago,
    c.nombre as Categoria,
    cu.monto_total as Monto_Cuota
from socio.socio s
inner join socio.cuota cu on s.id = cu.id_socio
inner join socio.categoria c on cu.id_categoria = c.id
where s.id = @id_socio_pedro;

-- Resumen de actividades
select 
    'ACTIVIDADES INSCRITO' as Seccion,
    a.nombre as Actividad,
    a.costo_mensual as Costo_Mensual,
    ia.fecha_inscripcion as Fecha_Inscripcion
from socio.inscripcion_actividad ia
inner join socio.cuota c on ia.id_cuota = c.id
inner join general.actividad a on ia.id_actividad = a.id
where c.id = @id_cuota_pedro and ia.activa = 1
order by a.nombre;

-- Resumen de facturas
select 
    'FACTURAS GENERADAS' as Seccion,
    'Cuota' as Tipo,
    numero_comprobante as Numero,
    fecha_emision as Fecha,
    importe_total as Importe,
    'Cuota mensual del socio' as Descripcion
from socio.factura_cuota
where id_cuota = @id_cuota_pedro
union all
select 
    'FACTURAS GENERADAS' as Seccion,
    'Extra - Pileta' as Tipo,
    numero_comprobante as Numero,
    fecha_emision as Fecha,
    importe_total as Importe,
    'Uso de pileta el 20/01/2024' as Descripcion
from socio.factura_extra fe
inner join socio.registro_pileta rp on fe.id_registro_pileta = rp.id
where rp.id_socio = @id_socio_pedro and rp.fecha = '2024-01-20'
union all
select 
    'FACTURAS GENERADAS' as Seccion,
    'Extra - Pileta' as Tipo,
    numero_comprobante as Numero,
    fecha_emision as Fecha,
    importe_total as Importe,
    'Uso de pileta el 25/01/2024 (reembolsado 60% por lluvia)' as Descripcion
from socio.factura_extra fe
inner join socio.registro_pileta rp on fe.id_registro_pileta = rp.id
where rp.id_socio = @id_socio_pedro and rp.fecha = '2024-01-25'
union all
select 
    'FACTURAS GENERADAS' as Seccion,
    'Extra - Actividad' as Tipo,
    numero_comprobante as Numero,
    fecha_emision as Fecha,
    importe_total as Importe,
    'Alquiler del SUM para cumpleaños' as Descripcion
from socio.factura_extra fe
inner join general.actividad_extra ae on fe.id_actividad_extra = ae.id
where ae.id_socio = @id_socio_pedro;

-- Resumen de pagos
select 
    'PAGOS REALIZADOS' as Seccion,
    monto as Monto,
    medio_de_pago as Medio_de_Pago,
    fecha_pago as Fecha_Pago,
    case 
        when id_factura_cuota is not null then 'Factura Cuota'
        when id_factura_extra is not null then 'Factura Extra'
        else 'Otro'
    end as Tipo_Factura
from socio.pago
where id_factura_cuota = @id_factura_cuota_pedro 
   or id_factura_extra in (
       select fe.id from socio.factura_extra fe
       inner join socio.registro_pileta rp on fe.id_registro_pileta = rp.id
       where rp.id_socio = @id_socio_pedro
       union
       select fe.id from socio.factura_extra fe
       inner join general.actividad_extra ae on fe.id_actividad_extra = ae.id
       where ae.id_socio = @id_socio_pedro
   )
order by fecha_pago;

-- Estado de cuenta final
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
where ec.id_socio = @id_socio_pedro;