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
    case responsable_pago when 1 then 'Sí' else 'No' end as Responsable_Pago,
    nro_socio as Nro_Socio
from socio.socio 
where dni in (23456789, 34567890, 45678901)
order by fecha_nacimiento;

-- Verificar asociación de grupo familiar
select
    'Grupo familiar asociado' as Estado,
    sr.nombre + ' ' + sr.apellido as Responsable,
    sm.nombre + ' ' + sm.apellido as Menor,
    sm.id_grupo_familiar as ID_Grupo_Familiar,
    sr.nro_socio as Nro_Socio_Responsable,
    sm.nro_socio as Nro_Socio_Menor
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
exec socio.altaCuota @id_socio = @id_padre, @id_categoria = 3, @monto_total = 200.00, @mes = 7, @anio = 2025;
declare @id_cuota_padre int;
select @id_cuota_padre = max(id) from socio.cuota where id_socio = @id_padre;

-- Crear cuota para el hijo (categoría Cadete)
exec socio.altaCuota @id_socio = @id_hijo1, @id_categoria = 2, @monto_total = 150.00, @mes = 7, @anio = 2025;
declare @id_cuota_hijo int;
select @id_cuota_hijo = max(id) from socio.cuota where id_socio = @id_hijo1;

-- Crear cuota para la hija (categoría Menor)
exec socio.altaCuota @id_socio = @id_hija, @id_categoria = 1, @monto_total = 120.00, @mes = 7, @anio = 2025;
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
exec socio.altaInscripcionActividad @id_cuota = @id_cuota_padre, @id_actividad = 1;
exec socio.altaInscripcionActividad @id_cuota = @id_cuota_padre, @id_actividad = 5;
print 'Roberto inscrito a Futsal y Natación';

-- Hijo: Vóley y Taekwondo
exec socio.altaInscripcionActividad @id_cuota = @id_cuota_hijo, @id_actividad = 2;
exec socio.altaInscripcionActividad @id_cuota = @id_cuota_hijo, @id_actividad = 3;
print 'Tomás inscrito a Vóley y Taekwondo';

-- Hija: Baile artístico y Ajedrez
exec socio.altaInscripcionActividad @id_cuota = @id_cuota_hija, @id_actividad = 4;
exec socio.altaInscripcionActividad @id_cuota = @id_cuota_hija, @id_actividad = 6;
print 'Sofía inscrita a Baile artístico y Ajedrez';

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
where c.id in (@id_cuota_padre, @id_cuota_hijo, @id_cuota_hija)
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
exec socio.altaFacturaCuota @id_cuota = @id_cuota_padre, @fecha_emision = '2025-07-04';
declare @id_factura_padre int;
select @id_factura_padre = max(id) from socio.factura_cuota where id_cuota = @id_cuota_padre;

-- Generar factura para el hijo
exec socio.altaFacturaCuota @id_cuota = @id_cuota_hijo, @fecha_emision = '2025-07-04';
declare @id_factura_hijo int;
select @id_factura_hijo = max(id) from socio.factura_cuota where id_cuota = @id_cuota_hijo;

-- Generar factura para la hija
exec socio.altaFacturaCuota @id_cuota = @id_cuota_hija, @fecha_emision = '2025-07-04';
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

-- Registro de pileta para Tomás que no genera factura extra
exec socio.altaRegistroPileta @id_socio = @id_hijo1, @id_invitado = null, @fecha = '2024-01-20', @id_tarifa = 1;
declare @id_registro_tomas int;
select @id_registro_tomas = max(id) from socio.registro_pileta where id_socio = @id_hijo1 and fecha = '2024-01-20';

-- Registro de pileta para Sofía que ya genera factura extra
exec socio.altaRegistroPileta @id_socio = @id_hija, @id_invitado = null, @fecha = '2024-01-20', @id_tarifa = 1;
declare @id_registro_sofia int;
select @id_registro_sofia = max(id) from socio.registro_pileta where id_socio = @id_hija and fecha = '2024-01-20';

declare @id_factura_tomas int, @id_factura_sofia int;
select @id_factura_tomas = max(id) from socio.factura_extra where id_registro_pileta = @id_registro_tomas;
select @id_factura_sofia = max(id) from socio.factura_extra where id_registro_pileta = @id_registro_sofia;

print 'id factura tomas: ' + cast(@id_factura_tomas as varchar(10));
print 'id factura sofia: ' + cast(@id_factura_sofia as varchar(10));

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
exec socio.altaPago @monto = @monto_factura_tomas, @medio_de_pago = 'Visa', @id_factura_extra = @id_factura_tomas;
exec socio.altaPago @monto = @monto_factura_sofia, @medio_de_pago = 'Visa', @id_factura_extra = @id_factura_sofia;

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
-- 2.6.4 PROCESAMIENTO DE DÉBITO AUTOMÁTICO FAMILIAR
-- =====================================================

print '2.6.4 PROCESAMIENTO DE DÉBITO AUTOMÁTICO FAMILIAR';
print 'Simulando procesamiento automático de débitos para el grupo familiar...';

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
where ec.id_socio in (@id_padre, @id_hijo1, @id_hija)
order by s.fecha_nacimiento;

-- Mostrar facturas de cuota ANTES de procesar débitos automáticos
print '';
print '--- FACTURAS DE CUOTA ANTES DEL DÉBITO AUTOMÁTICO ---';
select 
    'Facturas existentes' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    fc.id as ID_Factura,
    fc.numero_comprobante as Numero,
    fc.fecha_emision as Fecha,
    fc.periodo_facturado as Periodo,
    fc.importe_total as Importe,
    fc.descripcion as Descripcion
from socio.factura_cuota fc
inner join socio.cuota c on fc.id_cuota = c.id
inner join socio.socio s on c.id_socio = s.id
where c.id_socio in (@id_padre, @id_hijo1, @id_hija)
order by s.fecha_nacimiento, fc.fecha_emision;

-- Procesar débitos automáticos para el grupo familiar
print '';
print 'Procesando débitos automáticos para la fecha 2025-08-15';
exec socio.procesarDebitosAutomaticos @fecha_procesamiento = '2025-08-15';

-- Mostrar facturas de cuota DESPUÉS del procesamiento
print '';
print '--- FACTURAS DE CUOTA DESPUÉS DEL DÉBITO AUTOMÁTICO ---';
select 
    'Facturas después del débito automático' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    fc.id as ID_Factura,
    fc.numero_comprobante as Numero,
    fc.fecha_emision as Fecha,
    fc.periodo_facturado as Periodo,
    fc.importe_total as Importe,
    fc.descripcion as Descripcion
from socio.factura_cuota fc
inner join socio.cuota c on fc.id_cuota = c.id
inner join socio.socio s on c.id_socio = s.id
where c.id_socio in (@id_padre, @id_hijo1, @id_hija)
order by s.fecha_nacimiento, fc.fecha_emision;

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
where ec.id_socio in (@id_padre, @id_hijo1, @id_hija)
order by s.fecha_nacimiento;

-- Verificar pagos generados automáticamente
select 
    'Pagos automáticos procesados' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    p.monto as Monto_Pagado,
    p.medio_de_pago as Medio_de_Pago,
    p.fecha_pago as Fecha_Pago,
    'Procesado automáticamente por débito automático' as Tipo
from socio.pago p
inner join socio.factura_cuota fc on p.id_factura_cuota = fc.id
inner join socio.cuota c on fc.id_cuota = c.id
inner join socio.socio s on c.id_socio = s.id
where c.id_socio in (@id_padre, @id_hijo1, @id_hija)
and cast(p.fecha_pago as date) = cast(getdate() as date)
order by s.fecha_nacimiento;

print 'Débito automático procesado exitosamente para el grupo familiar';
print 'IMPORTANTE: El sistema genera facturas y procesa pagos automáticamente para socios con débito automático activo';
print '';

-- =====================================================
-- 2.7 NUEVAS FUNCIONALIDADES DEL 03.1
-- =====================================================

print '2.7 NUEVAS FUNCIONALIDADES DEL 03.1';
print 'Probando funcionalidades adicionales para el grupo familiar...';

-- =====================================================
-- 2.7.1 SISTEMA DE REINTEGRO POR LLUVIA
-- =====================================================

print '2.7.1 SISTEMA DE REINTEGRO POR LLUVIA';
print 'Probando sistema de reintegro por lluvia para el grupo familiar...';

-- Registrar uso de pileta en día de lluvia para los menores que crea las facturas automaticamente
exec socio.altaRegistroPileta @id_socio = @id_hijo1, @id_invitado = null, @fecha = '2024-01-25', @id_tarifa = 1;
exec socio.altaRegistroPileta @id_socio = @id_hija, @id_invitado = null, @fecha = '2024-01-25', @id_tarifa = 1;

declare @id_registro_tomas_lluvia int, @id_registro_sofia_lluvia int;
select @id_registro_tomas_lluvia = max(id) from socio.registro_pileta where id_socio = @id_hijo1 and fecha = '2024-01-25';
select @id_registro_sofia_lluvia = max(id) from socio.registro_pileta where id_socio = @id_hija and fecha = '2024-01-25';

declare @id_factura_tomas_lluvia int, @id_factura_sofia_lluvia int;
select @id_factura_tomas_lluvia = max(id) from socio.factura_extra where id_registro_pileta = @id_registro_tomas_lluvia;
select @id_factura_sofia_lluvia = max(id) from socio.factura_extra where id_registro_pileta = @id_registro_sofia_lluvia;

-- Procesar pagos de las facturas extra
declare @monto_factura_tomas_lluvia decimal(8,2), @monto_factura_sofia_lluvia decimal(8,2);
select @monto_factura_tomas_lluvia = importe_total from socio.factura_extra where id = @id_factura_tomas_lluvia;
select @monto_factura_sofia_lluvia = importe_total from socio.factura_extra where id = @id_factura_sofia_lluvia;

exec socio.altaPago @monto = @monto_factura_tomas_lluvia, @medio_de_pago = 'Visa', @id_factura_extra = @id_factura_tomas_lluvia;
exec socio.altaPago @monto = @monto_factura_sofia_lluvia, @medio_de_pago = 'Visa', @id_factura_extra = @id_factura_sofia_lluvia;

-- Mostrar estado de cuenta ANTES del reintegro por lluvia
print '';
print '--- ESTADO DE CUENTA ANTES DEL REINTEGRO POR LLUVIA ---';
select 
    'Estado de cuenta ANTES del reintegro por lluvia' as Estado,
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

-- Procesar reintegro por lluvia (60% del valor)
print '';
print 'Procesando reintegro por lluvia del 60% para el 25/01/2024...';
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
    'Reintegro del 60% aplicado automáticamente' as Observacion
from socio.estado_cuenta ec
inner join socio.socio s on ec.id_socio = s.id
where ec.id_socio in (@id_padre, @id_hijo1, @id_hija)
order by s.fecha_nacimiento;

-- Verificar reembolsos generados
print '';
print '--- REEMBOLSOS POR LLUVIA GENERADOS ---';
select 
    'Reembolsos por lluvia' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    r.fecha_reembolso as Fecha_Reembolso,
    r.motivo as Motivo,
    r.monto as Monto_Reembolsado,
    tr.descripcion as Tipo_Reembolso
from socio.reembolso r
inner join socio.tipo_reembolso tr on r.id_tipo_reembolso = tr.id
inner join socio.pago p on r.id_pago = p.id
inner join socio.factura_extra fe on p.id_factura_extra = fe.id
inner join socio.registro_pileta rp on fe.id_registro_pileta = rp.id
inner join socio.socio s on rp.id_socio = s.id
where rp.fecha = '2024-01-25'
and r.motivo = 'Reintegro por lluvia'
order by s.fecha_nacimiento;

print 'Reintegro por lluvia procesado exitosamente para el grupo familiar';
print '';

-- =====================================================
-- 2.7.2 ACTIVIDADES EXTRA PARA EL GRUPO FAMILIAR
-- =====================================================

print '2.7.2 ACTIVIDADES EXTRA PARA EL GRUPO FAMILIAR';
print 'Registrando actividades extra para los miembros de la familia...';

-- Actividad extra para Tomás: Alquiler de cancha de fútbol
exec general.altaActividadExtra @id_socio = @id_hijo1, @nombre = 'Alquiler cancha fútbol', @costo = 50000.00;
declare @id_actividad_extra_tomas int;
select @id_actividad_extra_tomas = max(id) from general.actividad_extra where id_socio = @id_hijo1;

-- Actividad extra para Sofía: Clase particular de baile
exec general.altaActividadExtra @id_socio = @id_hija, @nombre = 'Clase particular baile', @costo = 35000.00;
declare @id_actividad_extra_sofia int;
select @id_actividad_extra_sofia = max(id) from general.actividad_extra where id_socio = @id_hija;

-- Verificar facturas extra generadas automáticamente
select 
    'Facturas extra por actividades' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    ae.nombre as Actividad_Extra,
    ae.costo as Costo,
    fe.numero_comprobante as Numero_Factura,
    fe.fecha_emision as Fecha_Emision,
    fe.importe_total as Importe_Total
from socio.factura_extra fe
inner join general.actividad_extra ae on fe.id_actividad_extra = ae.id
inner join socio.socio s on ae.id_socio = s.id
where ae.id in (@id_actividad_extra_tomas, @id_actividad_extra_sofia)
order by s.fecha_nacimiento;

-- Procesar pagos de actividades extra
declare @id_factura_actividad_tomas int, @id_factura_actividad_sofia int;
declare @monto_actividad_tomas decimal(8,2), @monto_actividad_sofia decimal(8,2);

select @id_factura_actividad_tomas = fe.id, @monto_actividad_tomas = fe.importe_total
from socio.factura_extra fe
inner join general.actividad_extra ae on fe.id_actividad_extra = ae.id
where ae.id = @id_actividad_extra_tomas;

select @id_factura_actividad_sofia = fe.id, @monto_actividad_sofia = fe.importe_total
from socio.factura_extra fe
inner join general.actividad_extra ae on fe.id_actividad_extra = ae.id
where ae.id = @id_actividad_extra_sofia;

exec socio.altaPago @monto = @monto_actividad_tomas, @medio_de_pago = 'MasterCard', @id_factura_extra = @id_factura_actividad_tomas;
exec socio.altaPago @monto = @monto_actividad_sofia, @medio_de_pago = 'MasterCard', @id_factura_extra = @id_factura_actividad_sofia;

print 'Actividades extra registradas y pagadas exitosamente';
print '';

-- =====================================================
-- 2.7.3 INVITADOS A PILETA POR EL GRUPO FAMILIAR
-- =====================================================

print '2.7.3 INVITADOS A PILETA POR EL GRUPO FAMILIAR';
print 'Registrando invitados a pileta por los miembros de la familia...';

-- Invitado de Tomás: su amigo Carlos
exec socio.altaInvitado @nombre = 'Carlos', @apellido = 'González', @dni = 11111111, @email = 'carlos.gonzalez@email.com', @saldo_a_favor = 0.00;

-- Invitado de Sofía: su prima Ana
exec socio.altaInvitado @nombre = 'Ana', @apellido = 'López', @dni = 22222222, @email = 'ana.lopez@email.com', @saldo_a_favor = 0.00;

declare @id_invitado_carlos int, @id_invitado_ana int;
select @id_invitado_carlos = id from socio.invitado where dni = 11111111;
select @id_invitado_ana = id from socio.invitado where dni = 22222222;

-- Registrar invitados a pileta
exec socio.altaRegistroPileta @id_socio = null, @id_invitado = @id_invitado_carlos, @fecha = '2024-01-28', @id_tarifa = 2;
exec socio.altaRegistroPileta @id_socio = null, @id_invitado = @id_invitado_ana, @fecha = '2024-01-28', @id_tarifa = 2;

-- Verificar facturas extra generadas para invitados
select 
    'Facturas extra para invitados' as Estado,
    i.nombre + ' ' + i.apellido as Invitado,
    'Invitado por ' + s.nombre + ' ' + s.apellido as Invitado_Por,
    fe.numero_comprobante as Numero_Factura,
    fe.fecha_emision as Fecha_Emision,
    fe.importe_total as Importe_Total
from socio.factura_extra fe
inner join socio.registro_pileta rp on fe.id_registro_pileta = rp.id
inner join socio.invitado i on rp.id_invitado = i.id
inner join socio.socio s on (
    case 
        when i.dni = 11111111 then @id_hijo1  -- Carlos es invitado de Tomás
        when i.dni = 22222222 then @id_hija   -- Ana es invitada de Sofía
    end
) = s.id
where rp.fecha = '2024-01-28'
order by i.nombre;

-- Procesar pagos de invitados
declare @id_factura_invitado_carlos int, @id_factura_invitado_ana int;
declare @monto_invitado_carlos decimal(8,2), @monto_invitado_ana decimal(8,2);

select @id_factura_invitado_carlos = fe.id, @monto_invitado_carlos = fe.importe_total
from socio.factura_extra fe
inner join socio.registro_pileta rp on fe.id_registro_pileta = rp.id
where rp.id_invitado = @id_invitado_carlos and rp.fecha = '2024-01-28';

select @id_factura_invitado_ana = fe.id, @monto_invitado_ana = fe.importe_total
from socio.factura_extra fe
inner join socio.registro_pileta rp on fe.id_registro_pileta = rp.id
where rp.id_invitado = @id_invitado_ana and rp.fecha = '2024-01-28';

exec socio.altaPago @monto = @monto_invitado_carlos, @medio_de_pago = 'Pago Fácil', @id_factura_extra = @id_factura_invitado_carlos;
exec socio.altaPago @monto = @monto_invitado_ana, @medio_de_pago = 'Rapipago', @id_factura_extra = @id_factura_invitado_ana;

print 'Invitados registrados y facturas pagadas exitosamente';
print '';

-- =====================================================
-- 2.7.4 REGISTRO DE PRESENTISMO PARA EL GRUPO FAMILIAR
-- =====================================================

print '2.7.4 REGISTRO DE PRESENTISMO PARA EL GRUPO FAMILIAR';
print 'Registrando presentismo en clases para los miembros de la familia...';

-- Crear clases para diferentes categorías
exec general.altaClase @hora_inicio = '16:00', @hora_fin = '17:00', @dia = 'Martes', @id_categoria = 2, @id_actividad = 2, @id_empleado = 2; -- Vóley para Cadetes
exec general.altaClase @hora_inicio = '15:00', @hora_fin = '16:00', @dia = 'Miércoles', @id_categoria = 1, @id_actividad = 4, @id_empleado = 3; -- Baile para Menores

-- Registrar presentismo
declare @id_clase_voley int, @id_clase_baile int;
select @id_clase_voley = id from general.clase where id_actividad = 2 and id_categoria = 2;
select @id_clase_baile = id from general.clase where id_actividad = 4 and id_categoria = 1;

-- Tomás en clase de Vóley
exec general.altaPresentismo @id_socio = @id_hijo1, @id_clase = @id_clase_voley, @fecha = '2024-01-23', @tipo_asistencia = 'A';

-- Sofía en clase de Baile
exec general.altaPresentismo @id_socio = @id_hija, @id_clase = @id_clase_baile, @fecha = '2024-01-24', @tipo_asistencia = 'A';

-- Verificar presentismo registrado
select 
    'Presentismo registrado' as Estado,
    s.nombre + ' ' + s.apellido as Socio,
    a.nombre as Actividad,
    c.nombre as Categoria,
    CONVERT(varchar(5), cl.hora_inicio, 108) + ' - ' + CONVERT(varchar(5), cl.hora_fin, 108) as Horario,
    cl.dia as Dia,
    p.fecha as Fecha_Asistencia,
    case p.tipo_asistencia 
        when 'A' then 'Asistió'
        when 'F' then 'Faltó'
        when 'J' then 'Justificada'
        else 'Otro'
    end as Tipo_Asistencia
from general.presentismo p
inner join socio.socio s on p.id_socio = s.id
inner join general.clase cl on p.id_clase = cl.id
inner join general.actividad a on cl.id_actividad = a.id
inner join socio.categoria c on cl.id_categoria = c.id
where p.id_socio in (@id_hijo1, @id_hija)
order by s.fecha_nacimiento, p.fecha;

print 'Presentismo registrado exitosamente para los menores de la familia';
print '';

-- =====================================================
-- 2.7.5 PRUEBAS DE NOTAS DE CRÉDITO PARA EL GRUPO FAMILIAR
-- =====================================================

print '2.7.5 PRUEBAS DE NOTAS DE CRÉDITO PARA EL GRUPO FAMILIAR';
print 'Probando funcionalidad de notas de crédito para el grupo familiar...';

-- Crear una cuota sin facturar para probar NC
print '';
print 'Creando una nueva cuota sin facturar para probar NC...';
declare @id_cuota_sin_facturar_familiar int;
exec socio.altaCuota @id_socio = @id_hijo1, @id_categoria = 2, @monto_total = 150.00, @mes = 11, @anio = 2025;
select @id_cuota_sin_facturar_familiar = max(id) from socio.cuota where id_socio = @id_hijo1 and mes = 11 and anio = 2025;

-- Generar factura para esta cuota
declare @id_factura_sin_pagar_familiar int;
exec socio.altaFacturaCuota @id_cuota = @id_cuota_sin_facturar_familiar, @fecha_emision = '2025-11-01';
select @id_factura_sin_pagar_familiar = max(id) from socio.factura_cuota where id_cuota = @id_cuota_sin_facturar_familiar;

print 'Factura #' + cast(@id_factura_sin_pagar_familiar as varchar) + ' creada para cuota sin pagar de Tomás';

-- Mostrar estado de cuenta ANTES de la NC
print '';
print '--- ESTADO DE CUENTA ANTES DE LA NOTA DE CRÉDITO ---';
select 
    'Estado de cuenta ANTES de la NC' as Estado,
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

-- Generar nota de crédito para la factura sin pagar
print '';
print 'Generando nota de crédito para factura #' + cast(@id_factura_sin_pagar_familiar as varchar) + '...';
exec socio.generarNotaCredito @id_factura_origen = @id_factura_sin_pagar_familiar, @motivo_anulacion = 'ERROR_FACTURACION_FAMILIAR';

-- Verificar nota de crédito creada
declare @id_nota_credito_familiar int;
select @id_nota_credito_familiar = max(id) from socio.nota_credito where id_factura_origen = @id_factura_sin_pagar_familiar;

select 
    'Nota de Crédito creada para factura sin pagar' as Estado,
    numero_nota_credito as Numero_NC,
    fecha_anulacion as Fecha_Anulacion,
    motivo_anulacion as Motivo,
    'Factura #' + cast(id_factura_origen as varchar) as Factura_Origen
from socio.nota_credito
where id = @id_nota_credito_familiar;

-- Mostrar estado de cuenta DESPUÉS de la NC
print '';
print '--- ESTADO DE CUENTA DESPUÉS DE LA NOTA DE CRÉDITO ---';
select 
    'Estado de cuenta DESPUÉS de la NC' as Estado,
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

print 'Nota de crédito generada exitosamente para el grupo familiar';
print '';