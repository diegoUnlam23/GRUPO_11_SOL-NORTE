/*
    Archivo de Pruebas Detalladas para Caso 3: Tutor Responsable de Pago con Socios Menores Asociados
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
exec socio.altaCategoria @nombre = 'Menor', @costo_mensual = 10000.00, @edad_min = 0, @edad_max = 12;
exec socio.altaCategoria @nombre = 'Cadete', @costo_mensual = 15000.00, @edad_min = 13, @edad_max = 17;
exec socio.altaCategoria @nombre = 'Mayor', @costo_mensual = 25000.00, @edad_min = 18, @edad_max = 120;

-- 4. Insertar actividades deportivas
print '4. Insertando actividades deportivas...';
exec general.altaActividad @nombre = 'Futsal', @costo_mensual = 25000.00;
exec general.altaActividad @nombre = 'Vóley', @costo_mensual = 30000.00;
exec general.altaActividad @nombre = 'Taekwondo', @costo_mensual = 250000.00;
exec general.altaActividad @nombre = 'Baile artístico', @costo_mensual = 30000.00;
exec general.altaActividad @nombre = 'Natación', @costo_mensual = 45000.00;
exec general.altaActividad @nombre = 'Ajedrez', @costo_mensual = 2000.00;

-- 5. Insertar tarifas de pileta
print '5. Insertando tarifas de pileta...';
exec socio.altaTarifaPileta @tipo = 'Socio', @precio = 25000.00;
exec socio.altaTarifaPileta @tipo = 'Invitado', @precio = 30000.00;

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
-- CASO 3: TUTOR RESPONSABLE DE PAGO CON SOCIOS MENORES ASOCIADOS
-- =====================================================

print '=== CASO 3: TUTOR RESPONSABLE DE PAGO CON SOCIOS MENORES ASOCIADOS ===';
print 'Escenario: Tutor no socio responsable de pago, con dos menores asociados como socios';
print '';

-- =====================================================
-- 3.1 CREACIÓN DEL TUTOR (NO SOCIO)
-- =====================================================

print '3.1 CREACIÓN DEL TUTOR (NO SOCIO)';
print 'Creando tutor responsable de pago (no socio)...';

exec socio.altaTutor @nombre = 'Gabriela', @apellido = 'Fernández', @dni = 23456789, @email = 'gabriela.fernandez@email.com', @parentesco = 'Madre';

-- Verificar creación del tutor
select
    'Tutor creado' as Estado,
    nombre + ' ' + apellido as Nombre_Completo,
    dni as DNI,
    email as Email
from socio.tutor 
where dni = 23456789;

print 'Tutor Gabriela Fernández creado exitosamente';
print '';

-- =====================================================
-- 3.2 CREACIÓN DE SOCIOS MENORES ASOCIADOS AL TUTOR
-- =====================================================

print '3.2 CREACIÓN DE SOCIOS MENORES ASOCIADOS AL TUTOR';
print 'Creando dos menores asociados al tutor Gabriela Fernández...';

declare @id_tutor_gabriela int, @id_grupo_familiar int;
select @id_tutor_gabriela = id from socio.tutor where dni = 23456789;

-- Primer menor
exec socio.altaSocio @nombre = 'Martín', @apellido = 'Fernández', @dni = 34567890, @email = 'martin.fernandez@email.com', 
    @fecha_nacimiento = '2015-05-10', @telefono = '11-3333-4444', @telefono_emergencia = '11-3333-4445', 
    @id_obra_social_socio = 1, @id_tutor = @id_tutor_gabriela, @id_grupo_familiar = null, @estado = 'Activo', @responsable_pago = 0;

-- Obtener grupo familiar generado automáticamente
select @id_grupo_familiar = id_grupo_familiar from socio.socio where dni = 34567890;

-- Segundo menor (mismo grupo familiar)
exec socio.altaSocio @nombre = 'Lucía', @apellido = 'Fernández', @dni = 45678901, @email = 'lucia.fernandez@email.com', 
    @fecha_nacimiento = '2012-08-22', @telefono = '11-4444-5555', @telefono_emergencia = '11-4444-5556', 
    @id_obra_social_socio = 2, @id_tutor = @id_tutor_gabriela, @id_grupo_familiar = @id_grupo_familiar, @estado = 'Activo', @responsable_pago = 0;

-- Verificar creación de los menores y su asociación al tutor y grupo familiar
select
    'Socios menores creados' as Estado,
    s.nombre + ' ' + s.apellido as Nombre_Completo,
    s.dni as DNI,
    s.email as Email,
    s.fecha_nacimiento as Fecha_Nacimiento,
    s.estado as Estado_Socio,
    t.nombre + ' ' + t.apellido as Tutor,
    s.id_grupo_familiar as Grupo_Familiar,
    s.nro_socio as Nro_Socio
from socio.socio s
inner join socio.tutor t on s.id_tutor = t.id
where s.dni in (34567890, 45678901);

print 'Menores Martín y Lucía Fernández creados y asociados correctamente a la tutora Gabriela Fernández';
print '';

-- =====================================================
-- 3.3 CREACIÓN DE CUOTAS PARA LOS MENORES
-- =====================================================

print '3.3 CREACIÓN DE CUOTAS PARA LOS MENORES';
print 'Creando cuota para Martín Fernández (Menor) y Lucía Fernández (Cadete)...';

declare @id_socio_martin int, @id_socio_lucia int, @id_cuota_martin int, @id_cuota_lucia int;
select @id_socio_martin = id from socio.socio where dni = 34567890;
select @id_socio_lucia = id from socio.socio where dni = 45678901;

-- Martín: categoría Menor (id_categoria = 1)
exec socio.altaCuota @id_socio = @id_socio_martin, @id_categoria = 1, @monto_total = 120.00, @mes = 7, @anio = 2025;
select @id_cuota_martin = max(id) from socio.cuota where id_socio = @id_socio_martin;

-- Lucía: categoría Menor (id_categoria = 1) - tiene 12 años en 2024
exec socio.altaCuota @id_socio = @id_socio_lucia, @id_categoria = 1, @monto_total = 150.00, @mes = 7, @anio = 2025;
select @id_cuota_lucia = max(id) from socio.cuota where id_socio = @id_socio_lucia;

-- Verificar creación de cuotas
select 
    'Cuota creada' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    c.nombre as Categoria,
    cu.monto_total as Monto_Total
from socio.cuota cu
inner join socio.socio s on cu.id_socio = s.id
inner join socio.categoria c on cu.id_categoria = c.id
where cu.id in (@id_cuota_martin, @id_cuota_lucia);

print 'Cuotas creadas exitosamente para Martín y Lucía Fernández';
print '';

-- =====================================================
-- 3.4 INSCRIPCIÓN A ACTIVIDADES DEPORTIVAS
-- =====================================================

print '3.4 INSCRIPCIÓN A ACTIVIDADES DEPORTIVAS';
print 'Inscribiendo a los menores a actividades deportivas...';

-- Martín: Futsal (id_actividad = 1), Natación (id_actividad = 5)
exec socio.altaInscripcionActividad @id_cuota = @id_cuota_martin, @id_actividad = 1;
exec socio.altaInscripcionActividad @id_cuota = @id_cuota_martin, @id_actividad = 5;

-- Lucía: Baile artístico (id_actividad = 4), Ajedrez (id_actividad = 6)
exec socio.altaInscripcionActividad @id_cuota = @id_cuota_lucia, @id_actividad = 4;
exec socio.altaInscripcionActividad @id_cuota = @id_cuota_lucia, @id_actividad = 6;

-- Verificar inscripciones
select 
    'Inscripciones activas' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    a.nombre as Actividad,
    a.costo_mensual as Costo_Mensual
from socio.inscripcion_actividad ia
inner join socio.cuota c on ia.id_cuota = c.id
inner join socio.socio s on c.id_socio = s.id
inner join general.actividad a on ia.id_actividad = a.id
where c.id in (@id_cuota_martin, @id_cuota_lucia)
order by s.nombre, a.nombre;

print 'Menores inscriptos a actividades deportivas';
print '';

-- =====================================================
-- 3.5 GENERACIÓN DE FACTURA CUOTA (CON DESCUENTO FAMILIAR)
-- =====================================================

print '3.5 GENERACIÓN DE FACTURA CUOTA (CON DESCUENTO FAMILIAR)';
print 'Generando factura de cuota para cada menor, aplicando descuento familiar si corresponde...';

-- Martín
exec socio.altaFacturaCuota @id_cuota = @id_cuota_martin, @fecha_emision = '2025-07-04';
declare @id_factura_cuota_martin int;
select @id_factura_cuota_martin = max(id) from socio.factura_cuota where id_cuota = @id_cuota_martin;

-- Lucía
exec socio.altaFacturaCuota @id_cuota = @id_cuota_lucia, @fecha_emision = '2025-07-04';
declare @id_factura_cuota_lucia int;
select @id_factura_cuota_lucia = max(id) from socio.factura_cuota where id_cuota = @id_cuota_lucia;

-- Verificar facturas generadas
select 
    'Factura cuota generada' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    fc.numero_comprobante as Numero_Comprobante,
    fc.fecha_emision as Fecha_Emision,
    fc.importe_total as Importe_Total
from socio.factura_cuota fc
inner join socio.cuota cu on fc.id_cuota = cu.id
inner join socio.socio s on cu.id_socio = s.id
where fc.id in (@id_factura_cuota_martin, @id_factura_cuota_lucia);

-- Verificar items de la factura de Martín
select 
    'Items de factura' as Estado,
    tipo_item as Concepto,
    cantidad as Cantidad,
    precio_unitario as Precio_Unitario,
    alicuota_iva as Alicuota_IVA,
    subtotal as Subtotal,
    importe_total as Importe_Total
from socio.item_factura_cuota
where id_factura_cuota = @id_factura_cuota_martin;

-- Verificar items de la factura de Lucía
select 
    'Items de factura' as Estado,
    tipo_item as Concepto,
    cantidad as Cantidad,
    precio_unitario as Precio_Unitario,
    alicuota_iva as Alicuota_IVA,
    subtotal as Subtotal,
    importe_total as Importe_Total
from socio.item_factura_cuota
where id_factura_cuota = @id_factura_cuota_lucia;

print 'Facturas de cuota generadas exitosamente para ambos menores';
print '';

-- =====================================================
-- 3.6 PROCESAMIENTO DE PAGO DE FACTURAS DE CUOTA (POR EL TUTOR)
-- =====================================================

print '3.6 PROCESAMIENTO DE PAGO DE FACTURAS DE CUOTA (POR EL TUTOR)';
print 'Procesando pago de ambas facturas de cuota por parte del tutor responsable...';

declare @monto_factura_martin decimal(12,2), @monto_factura_lucia decimal(12,2);
select @monto_factura_martin = importe_total from socio.factura_cuota where id = @id_factura_cuota_martin;
select @monto_factura_lucia = importe_total from socio.factura_cuota where id = @id_factura_cuota_lucia;
select @id_tutor_gabriela = id from socio.tutor where dni = 23456789;

-- Estado de cuenta del tutor ANTES del pago
print '';
print '--- ESTADO DE CUENTA DEL TUTOR ANTES DEL PAGO ---';
select 
    'Estado de cuenta ANTES del pago' as Estado,
    t.nombre + ' ' + t.apellido as Tutor,
    ec.saldo as Saldo_Actual,
    case 
        when ec.saldo > 0 then 'Saldo a favor'
        when ec.saldo < 0 then 'Deuda'
        else 'Saldo cero'
    end as Estado_Saldo
from socio.estado_cuenta ec
inner join socio.tutor t on ec.id_tutor = t.id
where ec.id_tutor = @id_tutor_gabriela;

-- Procesar pago de la factura de Martín (por el tutor)
exec socio.altaPago @monto = @monto_factura_martin, @medio_de_pago = 'Visa', @id_factura_cuota = @id_factura_cuota_martin;

-- Procesar pago de la factura de Lucía (por el tutor)
exec socio.altaPago @monto = @monto_factura_lucia, @medio_de_pago = 'Visa', @id_factura_cuota = @id_factura_cuota_lucia;

-- Estado de cuenta del tutor DESPUÉS del pago
print '';
print '--- ESTADO DE CUENTA DEL TUTOR DESPUÉS DEL PAGO ---';
select 
    'Estado de cuenta DESPUÉS del pago' as Estado,
    t.nombre + ' ' + t.apellido as Tutor,
    ec.saldo as Saldo_Actual,
    case 
        when ec.saldo > 0 then 'Saldo a favor'
        when ec.saldo < 0 then 'Deuda'
        else 'Saldo cero'
    end as Estado_Saldo
from socio.estado_cuenta ec
inner join socio.tutor t on ec.id_tutor = t.id
where ec.id_tutor = @id_tutor_gabriela;

-- Movimientos de cuenta del tutor
print '';
print '--- MOVIMIENTOS DE CUENTA DEL TUTOR ---';
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
where ec.id_tutor = @id_tutor_gabriela
order by mc.fecha desc;

print 'Pagos procesados exitosamente por el tutor Gabriela Fernández';
print '';

-- =====================================================
-- 3.7 USO DE PILETA POR LOS MENORES
-- =====================================================

print '3.7 USO DE PILETA POR LOS MENORES';
print 'Registrando uso de pileta por Martín y Lucía Fernández...';

-- Martín usa la pileta (id_tarifa = 1, Socio)
exec socio.altaRegistroPileta @id_socio = @id_socio_martin, @id_invitado = null, @fecha = '2024-02-10', @id_tarifa = 1;
-- Lucía usa la pileta (id_tarifa = 1, Socio)
exec socio.altaRegistroPileta @id_socio = @id_socio_lucia, @id_invitado = null, @fecha = '2024-02-10', @id_tarifa = 1;

-- Verificar facturas extra generadas automáticamente
print '';
print '--- FACTURAS EXTRA POR USO DE PILETA ---';
declare @id_factura_extra_martin int, @id_factura_extra_lucia int;
select @id_factura_extra_martin = max(id) from socio.factura_extra where id_registro_pileta = (select max(id) from socio.registro_pileta where id_socio = @id_socio_martin);
select @id_factura_extra_lucia = max(id) from socio.factura_extra where id_registro_pileta = (select max(id) from socio.registro_pileta where id_socio = @id_socio_lucia);

select 
    'Factura extra generada' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    fe.numero_comprobante as Numero_Comprobante,
    fe.fecha_emision as Fecha_Emision,
    fe.importe_total as Importe_Total,
    'Factura inmediata por uso de pileta' as Tipo
from socio.factura_extra fe
inner join socio.registro_pileta rp on fe.id_registro_pileta = rp.id
inner join socio.socio s on rp.id_socio = s.id
where fe.id in (@id_factura_extra_martin, @id_factura_extra_lucia);

print 'Facturas extra generadas automáticamente por uso de pileta';
print '';

-- =====================================================
-- 3.8 PAGO DE FACTURA EXTRA POR USO DE PILETA
-- =====================================================

print '3.8 PAGO DE FACTURA EXTRA POR USO DE PILETA';
print 'Procesando pago de las facturas extra por uso de pileta (por el tutor)...';

declare @monto_factura_extra_martin decimal(12,2), @monto_factura_extra_lucia decimal(12,2);
select @monto_factura_extra_martin = importe_total from socio.factura_extra where id = @id_factura_extra_martin;
select @monto_factura_extra_lucia = importe_total from socio.factura_extra where id = @id_factura_extra_lucia;

-- Estado de cuenta del tutor ANTES del pago de facturas extra
print '';
print '--- ESTADO DE CUENTA DEL TUTOR ANTES DEL PAGO DE FACTURAS EXTRA ---';
select 
    'Estado de cuenta ANTES del pago de facturas extra' as Estado,
    t.nombre + ' ' + t.apellido as Tutor,
    ec.saldo as Saldo_Actual,
    case 
        when ec.saldo > 0 then 'Saldo a favor'
        when ec.saldo < 0 then 'Deuda'
        else 'Saldo cero'
    end as Estado_Saldo
from socio.estado_cuenta ec
inner join socio.tutor t on ec.id_tutor = t.id
where t.dni = 23456789;

-- Pago de factura extra de Martín
exec socio.altaPago @monto = @monto_factura_extra_martin, @medio_de_pago = 'Visa', @id_factura_extra = @id_factura_extra_martin;
-- Pago de factura extra de Lucía
exec socio.altaPago @monto = @monto_factura_extra_lucia, @medio_de_pago = 'Visa', @id_factura_extra = @id_factura_extra_lucia;

-- Estado de cuenta del tutor DESPUÉS del pago de facturas extra (NO DEBERÍA CAMBIAR)
print '';
print '--- ESTADO DE CUENTA DEL TUTOR DESPUÉS DEL PAGO DE FACTURAS EXTRA ---';
print 'NOTA: El estado de cuenta NO debería cambiar porque las facturas extra son pagos inmediatos';
select 
    'Estado de cuenta DESPUÉS del pago de facturas extra (NO CAMBIA)' as Estado,
    t.nombre + ' ' + t.apellido as Tutor,
    ec.saldo as Saldo_Actual,
    case 
        when ec.saldo > 0 then 'Saldo a favor'
        when ec.saldo < 0 then 'Deuda'
        else 'Saldo cero'
    end as Estado_Saldo,
    'Las facturas extra NO generan movimientos en la cuenta' as Observacion
from socio.estado_cuenta ec
inner join socio.tutor t on ec.id_tutor = t.id
where t.dni = 23456789;

print 'Pagos de facturas extra procesados exitosamente (no afectan el estado de cuenta)';
print '';

-- =====================================================
-- 3.9 ACTIVIDAD EXTRA PARA UN MENOR
-- =====================================================

print '3.9 ACTIVIDAD EXTRA PARA UN MENOR';
print 'Registrando actividad extra (alquiler de SUM) para Lucía Fernández...';

exec general.altaActividadExtra @id_socio = @id_socio_lucia, @nombre = 'Alquiler del SUM para cumpleaños', @costo = 500.00;

-- Verificar actividad extra creada y factura generada
print '';
print '--- FACTURA EXTRA POR ACTIVIDAD EXTRA ---';
declare @id_factura_extra_actividad int;
select @id_factura_extra_actividad = max(id) from socio.factura_extra where id_actividad_extra = (select max(id) from general.actividad_extra where id_socio = @id_socio_lucia);

select 
    'Factura extra actividad generada' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    fe.numero_comprobante as Numero_Comprobante,
    fe.fecha_emision as Fecha_Emision,
    fe.importe_total as Importe_Total,
    'Factura por actividad extra' as Tipo
from socio.factura_extra fe
inner join general.actividad_extra ae on fe.id_actividad_extra = ae.id
inner join socio.socio s on ae.id_socio = s.id
where fe.id = @id_factura_extra_actividad;

print 'Factura extra generada automáticamente por actividad extra';
print '';

-- =====================================================
-- 3.10 PAGO DE FACTURA EXTRA POR ACTIVIDAD EXTRA
-- =====================================================

print '3.10 PAGO DE FACTURA EXTRA POR ACTIVIDAD EXTRA';
print 'Procesando pago de la factura extra por actividad extra (por el tutor)...';

declare @monto_factura_extra_actividad decimal(12,2);
select @monto_factura_extra_actividad = importe_total from socio.factura_extra where id = @id_factura_extra_actividad;

-- Estado de cuenta del tutor ANTES del pago de factura extra por actividad
print '';
print '--- ESTADO DE CUENTA DEL TUTOR ANTES DEL PAGO DE FACTURA EXTRA POR ACTIVIDAD ---';
select 
    'Estado de cuenta ANTES del pago de factura extra por actividad' as Estado,
    t.nombre + ' ' + t.apellido as Tutor,
    ec.saldo as Saldo_Actual,
    case 
        when ec.saldo > 0 then 'Saldo a favor'
        when ec.saldo < 0 then 'Deuda'
        else 'Saldo cero'
    end as Estado_Saldo
from socio.estado_cuenta ec
inner join socio.tutor t on ec.id_tutor = t.id
where t.dni = 23456789;

-- Pago de factura extra por actividad
exec socio.altaPago @monto = @monto_factura_extra_actividad, @medio_de_pago = 'Visa', @id_factura_extra = @id_factura_extra_actividad;

-- Estado de cuenta del tutor DESPUÉS del pago de factura extra por actividad (NO DEBERÍA CAMBIAR)
print '';
print '--- ESTADO DE CUENTA DEL TUTOR DESPUÉS DEL PAGO DE FACTURA EXTRA POR ACTIVIDAD ---';
print 'NOTA: El estado de cuenta NO debería cambiar porque las facturas extra son pagos inmediatos';
select 
    'Estado de cuenta DESPUÉS del pago de factura extra por actividad (NO CAMBIA)' as Estado,
    t.nombre + ' ' + t.apellido as Tutor,
    ec.saldo as Saldo_Actual,
    case 
        when ec.saldo > 0 then 'Saldo a favor'
        when ec.saldo < 0 then 'Deuda'
        else 'Saldo cero'
    end as Estado_Saldo,
    'Las facturas extra NO generan movimientos en la cuenta' as Observacion
from socio.estado_cuenta ec
inner join socio.tutor t on ec.id_tutor = t.id
where t.dni = 23456789;

print 'Pago de factura extra por actividad procesado exitosamente (no afecta el estado de cuenta)';
print '';

-- =====================================================
-- 3.11 REGISTRO DE PRESENTISMO EN CLASE
-- =====================================================

print '3.11 REGISTRO DE PRESENTISMO EN CLASE';
print 'Registrando presentismo en clase para Martín y Lucía Fernández...';

-- Verificar categorías de los socios antes de crear las clases
print '';
print '--- VERIFICACIÓN DE CATEGORÍAS DE LOS SOCIOS ---';
select 
    'Categoría del socio' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    s.fecha_nacimiento as Fecha_Nacimiento,
    datediff(YEAR, s.fecha_nacimiento, getdate()) as Edad_Calculada,
    c.nombre as Categoria,
    c.edad_min as Edad_Min,
    c.edad_max as Edad_Max
from socio.socio s
inner join socio.cuota cu on s.id = cu.id_socio
inner join socio.categoria c on cu.id_categoria = c.id
where s.id in (@id_socio_martin, @id_socio_lucia);

-- Crear clase para registrar presentismo (Futsal, categoría Menor, empleado 1)
print '';
print 'Creando clase de Futsal para categoría Menor...';
exec general.altaClase @hora_inicio = '17:00', @hora_fin = '18:00', @dia = 'Martes', @id_categoria = 1, @id_actividad = 1, @id_empleado = 1;
declare @id_clase_futsal int;
select @id_clase_futsal = id from general.clase where id_actividad = 1 and id_categoria = 1;

-- Verificar clase creada
select 
    'Clase creada' as Estado,
    a.nombre as Actividad,
    c.nombre as Categoria,
    cl.hora_inicio as Hora_Inicio,
    cl.hora_fin as Hora_Fin,
    cl.dia as Dia
from general.clase cl
inner join general.actividad a on cl.id_actividad = a.id
inner join socio.categoria c on cl.id_categoria = c.id
where cl.id = @id_clase_futsal;

-- Presentismo Martín (Futsal)
print '';
print 'Registrando presentismo de Martín en clase de Futsal...';
exec general.altaPresentismo @id_socio = @id_socio_martin, @id_clase = @id_clase_futsal, @fecha = '2024-02-13', @tipo_asistencia = 'A';

-- Crear clase para registrar presentismo (Baile artístico, categoría Menor, empleado 2)
print '';
print 'Creando clase de Baile artístico para categoría Menor...';
exec general.altaClase @hora_inicio = '18:00', @hora_fin = '19:00', @dia = 'Miércoles', @id_categoria = 1, @id_actividad = 4, @id_empleado = 2;
declare @id_clase_baile int;
select @id_clase_baile = id from general.clase where id_actividad = 4 and id_categoria = 1;

-- Verificar clase creada
select 
    'Clase creada' as Estado,
    a.nombre as Actividad,
    c.nombre as Categoria,
    cl.hora_inicio as Hora_Inicio,
    cl.hora_fin as Hora_Fin,
    cl.dia as Dia
from general.clase cl
inner join general.actividad a on cl.id_actividad = a.id
inner join socio.categoria c on cl.id_categoria = c.id
where cl.id = @id_clase_baile;

-- Presentismo Lucía (Baile artístico)
print '';
print 'Registrando presentismo de Lucía en clase de Baile artístico...';
exec general.altaPresentismo @id_socio = @id_socio_lucia, @id_clase = @id_clase_baile, @fecha = '2024-02-14', @tipo_asistencia = 'A';

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
where p.id_socio in (@id_socio_martin, @id_socio_lucia);

print 'Presentismo registrado exitosamente para ambos menores';
print '';

-- =====================================================
-- 3.12 CONSULTA DE ESTADO DE CUENTA Y MOVIMIENTOS DEL TUTOR
-- =====================================================

print '3.12 CONSULTA DE ESTADO DE CUENTA Y MOVIMIENTOS DEL TUTOR';
print 'Consultando estado de cuenta y movimientos del tutor responsable...';

-- Estado de cuenta
select 
    'Estado de cuenta' as Estado,
    t.nombre + ' ' + t.apellido as Tutor,
    ec.saldo as Saldo_Actual,
    case 
        when ec.saldo > 0 then 'Saldo a favor'
        when ec.saldo < 0 then 'Deuda'
        else 'Saldo cero'
    end as Estado_Saldo
from socio.estado_cuenta ec
inner join socio.tutor t on ec.id_tutor = t.id
where t.dni = 23456789;

-- Movimientos de cuenta
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
where ec.id_tutor = (select id from socio.tutor where dni = 23456789)
order by mc.fecha desc;

print 'Estado de cuenta y movimientos consultados exitosamente';
print '';

-- =====================================================
-- 3.13 REEMBOLSO POR ERROR EN FACTURACIÓN
-- =====================================================

print '3.13 REEMBOLSO POR ERROR EN FACTURACIÓN';
print 'Procesando reembolso por error en facturación de la cuota de Lucía Fernández...';

-- Obtener un pago de Lucía para reembolsar
declare @id_pago_reembolso int;
select @id_pago_reembolso = max(id) from socio.pago where id_factura_cuota = @id_factura_cuota_lucia;

-- Estado de cuenta ANTES del reembolso
print '';
print '--- ESTADO DE CUENTA DEL TUTOR ANTES DEL REEMBOLSO ---';
select 
    'Estado de cuenta ANTES del reembolso' as Estado,
    t.nombre + ' ' + t.apellido as Tutor,
    ec.saldo as Saldo_Actual,
    case 
        when ec.saldo > 0 then 'Saldo a favor'
        when ec.saldo < 0 then 'Deuda'
        else 'Saldo cero'
    end as Estado_Saldo
from socio.estado_cuenta ec
inner join socio.tutor t on ec.id_tutor = t.id
where t.dni = 23456789;

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

-- Estado de cuenta DESPUÉS del reembolso
print '';
print '--- ESTADO DE CUENTA DEL TUTOR DESPUÉS DEL REEMBOLSO ---';
select 
    'Estado de cuenta DESPUÉS del reembolso' as Estado,
    t.nombre + ' ' + t.apellido as Tutor,
    ec.saldo as Saldo_Actual,
    case 
        when ec.saldo > 0 then 'Saldo a favor'
        when ec.saldo < 0 then 'Deuda'
        else 'Saldo cero'
    end as Estado_Saldo
from socio.estado_cuenta ec
inner join socio.tutor t on ec.id_tutor = t.id
where t.dni = 23456789;

print 'Reembolso procesado exitosamente';
print '';

-- =====================================================
-- 3.14 REINTEGRO POR LLUVIA (OPCIONAL)
-- =====================================================

print '3.15 REINTEGRO POR LLUVIA (OPCIONAL)';
print 'Simulando uso de pileta por Martín Fernández en día de lluvia y reintegro del 60%...';

-- Registrar uso de pileta en día de lluvia
exec socio.altaRegistroPileta @id_socio = @id_socio_martin, @id_invitado = null, @fecha = '2024-02-20', @id_tarifa = 1;
declare @id_factura_pileta_lluvia int, @monto_pileta_lluvia decimal(12,2);
select @id_factura_pileta_lluvia = max(id) from socio.factura_extra where id_registro_pileta = (select max(id) from socio.registro_pileta where id_socio = @id_socio_martin and fecha = '2024-02-20');
select @monto_pileta_lluvia = importe_total from socio.factura_extra where id = @id_factura_pileta_lluvia;

-- Verificar factura extra generada por uso de pileta en día de lluvia
print '';
print '--- FACTURA EXTRA POR USO DE PILETA EN DÍA DE LLUVIA ---';
select 
    'Factura extra generada' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    fe.numero_comprobante as Numero_Comprobante,
    fe.fecha_emision as Fecha_Emision,
    fe.importe_total as Importe_Total,
    'Uso de pileta el 20/02/2024 (día de lluvia)' as Descripcion
from socio.factura_extra fe
inner join socio.registro_pileta rp on fe.id_registro_pileta = rp.id
inner join socio.socio s on rp.id_socio = s.id
where fe.id = @id_factura_pileta_lluvia;

-- Estado de cuenta del tutor ANTES del pago de pileta por lluvia
print '';
print '--- ESTADO DE CUENTA DEL TUTOR ANTES DEL PAGO DE PILETA POR LLUVIA ---';
select 
    'Estado de cuenta ANTES del pago de pileta por lluvia' as Estado,
    t.nombre + ' ' + t.apellido as Tutor,
    ec.saldo as Saldo_Actual,
    case 
        when ec.saldo > 0 then 'Saldo a favor'
        when ec.saldo < 0 then 'Deuda'
        else 'Saldo cero'
    end as Estado_Saldo
from socio.estado_cuenta ec
inner join socio.tutor t on ec.id_tutor = t.id
where t.dni = 23456789;

-- Pago de la factura extra por uso de pileta en día de lluvia
print '';
print 'Procesando pago de $' + cast(@monto_pileta_lluvia as varchar(10)) + ' con Visa...';
print 'NOTA: Las facturas extra son pagos inmediatos que NO afectan el estado de cuenta';
exec socio.altaPago @monto = @monto_pileta_lluvia, @medio_de_pago = 'Visa', @id_factura_extra = @id_factura_pileta_lluvia;

-- Estado de cuenta del tutor DESPUÉS del pago de pileta por lluvia (NO DEBERÍA CAMBIAR)
print '';
print '--- ESTADO DE CUENTA DEL TUTOR DESPUÉS DEL PAGO DE PILETA POR LLUVIA ---';
print 'NOTA: El estado de cuenta NO debería cambiar porque las facturas extra son pagos inmediatos';
select 
    'Estado de cuenta DESPUÉS del pago de pileta por lluvia (NO CAMBIA)' as Estado,
    t.nombre + ' ' + t.apellido as Tutor,
    ec.saldo as Saldo_Actual,
    case 
        when ec.saldo > 0 then 'Saldo a favor'
        when ec.saldo < 0 then 'Deuda'
        else 'Saldo cero'
    end as Estado_Saldo,
    'Las facturas extra NO generan movimientos en la cuenta' as Observacion
from socio.estado_cuenta ec
inner join socio.tutor t on ec.id_tutor = t.id
where t.dni = 23456789;

-- Procesar reintegro por lluvia (60%)
print '';
print 'Procesando reintegro del 60% por lluvia...';
print 'Monto esperado: $' + cast(@monto_pileta_lluvia as varchar(10)) + ' * 0.60 = $' + cast(@monto_pileta_lluvia * 0.60 as varchar(10));
exec socio.procesarReintegroLluvia @fecha_lluvia = '2024-02-20', @porcentaje_reintegro = 60.00;

-- Estado de cuenta del tutor DESPUÉS del reintegro por lluvia
print '';
print '--- ESTADO DE CUENTA DEL TUTOR DESPUÉS DEL REINTEGRO POR LLUVIA ---';
select 
    'Estado de cuenta DESPUÉS del reintegro por lluvia' as Estado,
    t.nombre + ' ' + t.apellido as Tutor,
    ec.saldo as Saldo_Actual,
    case 
        when ec.saldo > 0 then 'Saldo a favor'
        when ec.saldo < 0 then 'Deuda'
        else 'Saldo cero'
    end as Estado_Saldo,
    'Reintegro del 60% aplicado automáticamente' as Observacion
from socio.estado_cuenta ec
inner join socio.tutor t on ec.id_tutor = t.id
where t.dni = 23456789;

-- Movimientos de cuenta DESPUÉS del reintegro por lluvia
print '';
print '--- MOVIMIENTOS DE CUENTA DESPUÉS DEL REINTEGRO POR LLUVIA ---';
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
where ec.id_tutor = (select id from socio.tutor where dni = 23456789)
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
    '60% aplicado automáticamente por procesarReintegroLluvia' as Observacion
from socio.reembolso r
inner join socio.tipo_reembolso tr on r.id_tipo_reembolso = tr.id
inner join socio.pago p on r.id_pago = p.id
where p.id_factura_extra = @id_factura_pileta_lluvia and r.motivo = 'Reintegro por lluvia';

print 'Reintegro por lluvia procesado exitosamente (60% del valor de entrada)';
print 'IMPORTANTE: El reintegro del 60% se aplica automáticamente y SÍ afecta el estado de cuenta del tutor';
print '';

-- =====================================================
-- 3.15 INVITADO A PILETA (OPCIONAL)
-- =====================================================

print '3.16 INVITADO A PILETA (OPCIONAL)';
print 'Registrando invitado a pileta gestionado por el tutor (amigo de Lucía)...';

-- Alta de invitado (si no existe)
exec socio.altaInvitado @nombre = 'Sofía', @apellido = 'Gómez', @dni = 77777777, @email = 'sofia.gomez@email.com', @saldo_a_favor = 0.00;

-- Registrar invitado a pileta (id_tarifa = 2, Invitado)
declare @id_invitado int;
select @id_invitado = id from socio.invitado where dni = 77777777;

exec socio.altaRegistroPileta @id_socio = null, @id_invitado = @id_invitado, @fecha = '2024-02-22', @id_tarifa = 2;
declare @id_factura_invitado int, @monto_invitado decimal(12,2);
select @id_factura_invitado = max(id) from socio.factura_extra where id_registro_pileta = (select max(id) from socio.registro_pileta where id_invitado = (select id from socio.invitado where dni = 77777777));
select @monto_invitado = importe_total from socio.factura_extra where id = @id_factura_invitado;

-- Pago inmediato del invitado
exec socio.altaPago @monto = @monto_invitado, @medio_de_pago = 'Visa', @id_factura_extra = @id_factura_invitado;

-- Verificar factura y pago
select 
    'Factura invitado generada' as Estado,
    i.nombre + ' ' + i.apellido as Invitado,
    fe.numero_comprobante as Numero_Comprobante,
    fe.fecha_emision as Fecha_Emision,
    fe.importe_total as Importe_Total
from socio.factura_extra fe
inner join socio.registro_pileta rp on fe.id_registro_pileta = rp.id
inner join socio.invitado i on rp.id_invitado = i.id
where fe.id = @id_factura_invitado;

print 'Invitado registrado y factura pagada inmediatamente';
print ''; 

-- =====================================================
-- 3.17 CREACIÓN DE CUOTAS ADICIONALES PARA DÉBITO AUTOMÁTICO
-- =====================================================

print '3.17 CREACIÓN DE CUOTAS ADICIONALES PARA DÉBITO AUTOMÁTICO';
print 'Creando cuotas adicionales para septiembre de 2025 que serán procesadas por débito automático...';

-- Crear cuotas adicionales para septiembre de 2025 (sin facturas previas)
exec socio.altaCuota @id_socio = @id_socio_martin, @id_categoria = 1, @monto_total = 120.00, @mes = 9, @anio = 2025;
exec socio.altaCuota @id_socio = @id_socio_lucia, @id_categoria = 1, @monto_total = 150.00, @mes = 9, @anio = 2025;

-- Verificar cuotas adicionales creadas
select 
    'Cuotas adicionales creadas' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    c.nombre as Categoria,
    cu.mes as Mes,
    cu.anio as Anio,
    cu.monto_total as Monto_Total,
    case 
        when fc.id is null then 'Sin facturar'
        else 'Ya facturada'
    end as Estado_Factura
from socio.cuota cu
inner join socio.socio s on cu.id_socio = s.id
inner join socio.categoria c on cu.id_categoria = c.id
left join socio.factura_cuota fc on cu.id = fc.id_cuota
where cu.mes = 9 and cu.anio = 2025
and s.id in (@id_socio_martin, @id_socio_lucia);

print 'Cuotas adicionales creadas exitosamente para septiembre de 2025';
print '';

-- =====================================================
-- 3.18 DÉBITO AUTOMÁTICO PARA TUTOR
-- =====================================================

print '3.18 DÉBITO AUTOMÁTICO PARA TUTOR';
print 'Configurando débito automático para el tutor responsable...';

-- Crear débito automático para el tutor
exec socio.altaDebitoAutomatico @id_responsable_pago = @id_tutor_gabriela, @medio_de_pago = 'MasterCard', @activo = 1, 
    @token_pago = 'tok_mastercard_gabriela_456', @ultimos_4_digitos = 5678, @titular = 'Gabriela Fernández';

-- Verificar débito automático creado
select 
    'Débito automático configurado' as Estado,
    t.nombre + ' ' + t.apellido as Tutor,
    da.medio_de_pago as Medio_de_Pago,
    da.ultimos_4_digitos as Ultimos_4_Digitos,
    da.titular as Titular,
    case da.activo when 1 then 'Activo' else 'Inactivo' end as Estado_Debito
from socio.debito_automatico da
inner join socio.tutor t on da.id_responsable_pago = t.id
where da.id_responsable_pago = @id_tutor_gabriela;

print 'Débito automático configurado exitosamente para el tutor';
print '';

-- =====================================================
-- 3.19 PROCESAMIENTO AUTOMÁTICO DE DÉBITOS
-- =====================================================

print '3.19 PROCESAMIENTO AUTOMÁTICO DE DÉBITOS';
print 'Simulando procesamiento automático de débitos para el tutor...';

-- Estado de cuenta ANTES del procesamiento automático
print '';
print '--- ESTADO DE CUENTA ANTES DEL PROCESAMIENTO AUTOMÁTICO ---';
select 
    'Estado de cuenta ANTES del procesamiento automático' as Estado,
    t.nombre + ' ' + t.apellido as Tutor,
    ec.saldo as Saldo_Actual
from socio.estado_cuenta ec
inner join socio.tutor t on ec.id_tutor = t.id
where t.dni = 23456789;

-- Mostrar facturas existentes ANTES del procesamiento automático
print '';
print '--- FACTURAS EXISTENTES ANTES DEL PROCESAMIENTO AUTOMÁTICO ---';
select 
    'Facturas existentes' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    fc.numero_comprobante as Numero_Factura,
    fc.fecha_emision as Fecha_Emision,
    fc.periodo_facturado as Periodo,
    fc.importe_total as Importe,
    fc.descripcion as Descripcion
from socio.factura_cuota fc
inner join socio.cuota c on fc.id_cuota = c.id
inner join socio.socio s on c.id_socio = s.id
where s.id in (@id_socio_martin, @id_socio_lucia)
order by fc.fecha_emision;

-- Procesar débitos automáticos
print '';
print 'Procesando débitos automáticos para la fecha 2025-09-15...';
exec socio.procesarDebitosAutomaticos @fecha_procesamiento = '2025-09-15';

-- Mostrar facturas generadas automáticamente
print '';
print '--- FACTURAS GENERADAS AUTOMÁTICAMENTE ---';
select 
    'Facturas generadas automáticamente' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    fc.numero_comprobante as Numero_Factura,
    fc.fecha_emision as Fecha_Emision,
    fc.periodo_facturado as Periodo,
    fc.importe_total as Importe,
    'Generada automáticamente por débito automático' as Descripcion
from socio.factura_cuota fc
inner join socio.cuota c on fc.id_cuota = c.id
inner join socio.socio s on c.id_socio = s.id
where s.id in (@id_socio_martin, @id_socio_lucia)
and fc.periodo_facturado = 202509
order by fc.fecha_emision;

-- Mostrar pagos procesados automáticamente
print '';
print '--- PAGOS PROCESADOS AUTOMÁTICAMENTE ---';
select 
    'Pagos procesados automáticamente' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    p.monto as Monto_Pagado,
    p.medio_de_pago as Medio_de_Pago,
    p.fecha_pago as Fecha_Pago,
    fc.numero_comprobante as Numero_Factura,
    'Procesado automáticamente por débito automático' as Descripcion
from socio.pago p
inner join socio.factura_cuota fc on p.id_factura_cuota = fc.id
inner join socio.cuota c on fc.id_cuota = c.id
inner join socio.socio s on c.id_socio = s.id
where s.id in (@id_socio_martin, @id_socio_lucia)
and fc.periodo_facturado = 202509
order by p.fecha_pago;

-- Estado de cuenta DESPUÉS del procesamiento automático
print '';
print '--- ESTADO DE CUENTA DESPUÉS DEL PROCESAMIENTO AUTOMÁTICO ---';
select 
    'Estado de cuenta DESPUÉS del procesamiento automático' as Estado,
    t.nombre + ' ' + t.apellido as Tutor,
    ec.saldo as Saldo_Actual,
    'Débito automático procesado exitosamente' as Observacion
from socio.estado_cuenta ec
inner join socio.tutor t on ec.id_tutor = t.id
where t.dni = 23456789;

-- Movimientos de cuenta DESPUÉS del procesamiento automático
print '';
print '--- MOVIMIENTOS DE CUENTA DESPUÉS DEL PROCESAMIENTO AUTOMÁTICO ---';
select 
    'Movimientos DESPUÉS del procesamiento automático' as Estado,
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
where ec.id_tutor = (select id from socio.tutor where dni = 23456789)
order by mc.fecha desc;

print 'Débito automático procesado exitosamente para el tutor';
print 'IMPORTANTE: El sistema genera facturas y procesa pagos automáticamente para tutores con débito automático activo';
print '';

-- =====================================================
-- 3.20 VERIFICACIÓN: MENORES NO TIENEN ESTADO DE CUENTA PROPIO
-- =====================================================

print '3.20 VERIFICACIÓN: MENORES NO TIENEN ESTADO DE CUENTA PROPIO';
print 'Verificando que los menores NO tienen estado de cuenta propio...';

-- Verificar que los menores NO tienen estado de cuenta
select 
    'Verificación de estado de cuenta' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    case 
        when ec.id is null then 'NO tiene estado de cuenta'
        else 'SÍ tiene estado de cuenta (ERROR)'
    end as Estado_Cuenta,
    'Los menores NO deben tener estado de cuenta propio' as Observacion
from socio.socio s
left join socio.estado_cuenta ec on s.id = ec.id_socio
where s.dni in (34567890, 45678901);

print 'Verificación completada: Los menores NO tienen estado de cuenta propio, todo se maneja a través del tutor';
print '';

-- =====================================================
-- 3.20 VERIFICACIÓN DE GRUPO FAMILIAR
-- =====================================================

print '3.20 VERIFICACIÓN DE GRUPO FAMILIAR';
print 'Verificando que ambos menores pertenecen al mismo grupo familiar...';

select 
    'Grupo familiar verificado' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    s.id_grupo_familiar as Grupo_Familiar,
    t.nombre + ' ' + t.apellido as Tutor,
    'Ambos menores comparten grupo familiar y tutor' as Observacion
from socio.socio s
inner join socio.tutor t on s.id_tutor = t.id
where s.dni in (34567890, 45678901)
order by s.id_grupo_familiar, s.nombre;

print 'Ambos menores pertenecen al mismo grupo familiar y comparten tutor';
print '';