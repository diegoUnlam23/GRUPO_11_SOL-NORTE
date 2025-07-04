/*
    Casos de Prueba: Baja de Socios de Grupo Familiar
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

print '====================================================';
print 'CASOS DE PRUEBA: BAJA DE SOCIOS DE GRUPO FAMILIAR';
print '====================================================';
print '';

-- =====================================================
-- 1. PREPARACIÓN DE DATOS DE PRUEBA
-- =====================================================

print '1. PREPARACIÓN DE DATOS DE PRUEBA';
print 'Creando familia de prueba para los casos de baja...';

-- Crear obra social
exec socio.altaObraSocialSocio @nombre = 'OSDE', @telefono_emergencia = '0800-333-6733', @numero_socio = '12345678';

-- Crear categorías
exec socio.altaCategoria @nombre = 'Menor', @costo_mensual = 10000.00, @edad_min = 0, @edad_max = 12;
exec socio.altaCategoria @nombre = 'Cadete', @costo_mensual = 15000.00, @edad_min = 13, @edad_max = 17;
exec socio.altaCategoria @nombre = 'Mayor', @costo_mensual = 25000.00, @edad_min = 18, @edad_max = 120;

-- Crear tarifas de pileta
exec socio.altaTarifaPileta @tipo = 'Socio', @precio = 25000.00;

-- Crear tutor externo
exec socio.altaTutor @nombre = 'María', @apellido = 'González', @dni = 98765432, @email = 'maria.gonzalez@email.com', @parentesco = 'Tía';

-- Crear familia Pérez (padre, madre, dos hijos)
print 'Creando familia Pérez...';

-- Padre (responsable)
exec socio.altaSocio @nombre = 'Carlos', @apellido = 'Pérez', @dni = 11111111, @email = 'carlos.perez@email.com', 
    @fecha_nacimiento = '1980-05-15', @telefono = '11-1111-1111', @telefono_emergencia = '11-1111-1112', 
    @id_obra_social_socio = 1, @id_tutor = null, @id_grupo_familiar = null, @estado = 'Activo', @responsable_pago = 1;

-- Madre
exec socio.altaSocio @nombre = 'Ana', @apellido = 'Pérez', @dni = 22222222, @email = 'ana.perez@email.com', 
    @fecha_nacimiento = '1982-08-20', @telefono = '11-2222-2222', @telefono_emergencia = '11-2222-2223', 
    @id_obra_social_socio = 1, @id_tutor = null, @id_grupo_familiar = null, @estado = 'Activo', @responsable_pago = 0;

-- Hijo mayor (15 años)
exec socio.altaSocio @nombre = 'Lucas', @apellido = 'Pérez', @dni = 33333333, @email = 'lucas.perez@email.com', 
    @fecha_nacimiento = '2009-03-10', @telefono = null, @telefono_emergencia = '11-1111-1112', 
    @id_obra_social_socio = 1, @id_tutor = null, @id_grupo_familiar = null, @estado = 'Activo', @responsable_pago = 0;

-- Hija menor (10 años)
exec socio.altaSocio @nombre = 'Valentina', @apellido = 'Pérez', @dni = 44444444, @email = 'valentina.perez@email.com', 
    @fecha_nacimiento = '2014-12-05', @telefono = null, @telefono_emergencia = '11-1111-1112', 
    @id_obra_social_socio = 1, @id_tutor = null, @id_grupo_familiar = null, @estado = 'Activo', @responsable_pago = 0;

-- Obtener IDs de los socios creados
declare @id_padre int, @id_madre int, @id_hijo int, @id_hija int, @id_tutor int;
select @id_padre = id from socio.socio where dni = 11111111;
select @id_madre = id from socio.socio where dni = 22222222;
select @id_hijo = id from socio.socio where dni = 33333333;
select @id_hija = id from socio.socio where dni = 44444444;
select @id_tutor = id from socio.tutor where dni = 98765432;

-- Asociar grupo familiar (padre como responsable)
update socio.socio set id_grupo_familiar = @id_padre where id = @id_hijo;
update socio.socio set id_grupo_familiar = @id_padre where id = @id_hija;
update socio.socio set id_grupo_familiar = @id_padre where id = @id_madre;

-- Verificar creación de la familia
select
    'Familia Pérez creada' as Estado,
    nombre + ' ' + apellido as Nombre_Completo,
    dni as DNI,
    fecha_nacimiento as Fecha_Nacimiento,
    datediff(YEAR, fecha_nacimiento, getdate()) as Edad,
    case responsable_pago when 1 then 'Sí' else 'No' end as Responsable_Pago
from socio.socio 
where dni in (11111111, 22222222, 33333333, 44444444)
order by fecha_nacimiento;

print 'Familia Pérez creada exitosamente';
print '';

select
    'Tutor externo' as Estado,
    nombre + ' ' + apellido as Nombre_Completo,
    dni as DNI,
    email as Email,
    parentesco as Parentesco
from socio.tutor
where dni = 98765432;

-- =====================================================
-- 2. CASO 1: BAJA DE SOCIO MAYOR DE EDAD DEL GRUPO
-- =====================================================

print '2. CASO 1: BAJA DE SOCIO MAYOR DE EDAD DEL GRUPO';
print 'Escenario: La madre Ana Pérez (mayor de edad) se da de baja del grupo familiar';
print '';

-- Verificar estado inicial
print 'Estado inicial de Ana Pérez:';
select
    'Estado inicial antes de la baja' as Estado,
    nombre + ' ' + apellido as Nombre,
    datediff(YEAR, fecha_nacimiento, getdate()) as Edad,
    case responsable_pago when 1 then 'Sí' else 'No' end as Responsable_Pago,
    id_grupo_familiar as ID_Grupo_Familiar
from socio.socio where dni = 22222222;

print '';

-- Dar de baja a Ana Pérez del grupo familiar
print 'Ejecutando baja de Ana Pérez del grupo familiar...';
exec socio.bajaSocioDeGrupoFamiliar @id_socio = @id_madre;

print '';

-- Verificar estado final
print 'Estado final de Ana Pérez:';
select 
    'Estado final después de la baja' as Estado,
    nombre + ' ' + apellido as Nombre,
    datediff(YEAR, fecha_nacimiento, getdate()) as Edad,
    case responsable_pago when 1 then 'Sí' else 'No' end as Responsable_Pago,
    id_grupo_familiar as ID_Grupo_Familiar
from socio.socio where dni = 22222222;

print 'Caso 1 completado: Ana Pérez ahora es responsable de pago independiente';
print '';

-- Estado cuenta de Ana Pérez
print 'Estado cuenta de Ana Pérez:';
select
    'Creado el estado de cuenta de Ana Pérez' as Estado,
    *
from socio.estado_cuenta where id_socio = @id_madre;

print '';

-- =====================================================
-- 3. CASO 2: BAJA DE SOCIO MENOR CON NUEVO SOCIO RESPONSABLE
-- =====================================================

print '3. CASO 2: BAJA DE SOCIO MENOR CON NUEVO SOCIO RESPONSABLE';
print 'Escenario: Lucas Pérez (15 años) se da de baja del grupo familiar y se asigna a su madre como responsable (el sistema detecta automáticamente que es un socio)';
print '';

-- Verificar estado inicial
print 'Estado inicial de Lucas Pérez:';
select 
    'Estado inicial antes de la baja y asignado a su madre como responsable' as Estado,
    nombre + ' ' + apellido as Nombre,
    datediff(YEAR, fecha_nacimiento, getdate()) as Edad,
    case responsable_pago when 1 then 'Sí' else 'No' end as Responsable_Pago,
    id_grupo_familiar as ID_Grupo_Familiar
from socio.socio where dni = 33333333;

print '';

-- Dar de baja a Lucas Pérez del grupo familiar, asignándolo a su madre
print 'Ejecutando baja de Lucas Pérez del grupo familiar, asignándolo a Ana Pérez...';
exec socio.bajaSocioDeGrupoFamiliar @id_socio = @id_hijo, @nuevo_responsable_pago = @id_madre;

print '';

-- Verificar estado final
print 'Estado final de Lucas Pérez:';
select 
    'Estado final después de la baja y asignado a su madre como responsable' as Estado,
    nombre + ' ' + apellido as Nombre,
    datediff(YEAR, fecha_nacimiento, getdate()) as Edad,
    case responsable_pago when 1 then 'Sí' else 'No' end as Responsable_Pago,
    id_grupo_familiar as ID_Grupo_Familiar
from socio.socio where dni = 33333333;

print 'Caso 2 completado: Lucas Pérez ahora está bajo la responsabilidad de Ana Pérez';
print '';

-- =====================================================
-- 4. CASO 3: BAJA DE SOCIO MENOR CON TUTOR EXTERNO
-- =====================================================

print '4. CASO 3: BAJA DE SOCIO MENOR CON TUTOR EXTERNO';
print 'Escenario: Valentina Pérez (10 años) se da de baja del grupo familiar y se asigna a un tutor externo (el sistema detecta automáticamente que es un tutor)';
print '';

-- Verificar estado inicial
print 'Estado inicial de Valentina Pérez:';
select 
    'Estado inicial antes de la baja y asignada al tutor externo' as Estado,
    nombre + ' ' + apellido as Nombre,
    datediff(YEAR, fecha_nacimiento, getdate()) as Edad,
    case responsable_pago when 1 then 'Sí' else 'No' end as Responsable_Pago,
    id_grupo_familiar as ID_Grupo_Familiar,
    id_tutor as ID_Tutor
from socio.socio where dni = 44444444;

print '';

-- Dar de baja a Valentina Pérez del grupo familiar, asignándola al tutor externo
print 'Ejecutando baja de Valentina Pérez del grupo familiar, asignándola al tutor María González...';
exec socio.bajaSocioDeGrupoFamiliar @id_socio = @id_hija, @nuevo_responsable_pago = @id_tutor;

print '';

-- Verificar estado final
print 'Estado final de Valentina Pérez:';
select 
    'Estado final después de la baja y asignada al tutor externo' as Estado,
    nombre + ' ' + apellido as Nombre,
    datediff(YEAR, fecha_nacimiento, getdate()) as Edad,
    case responsable_pago when 1 then 'Sí' else 'No' end as Responsable_Pago,
    id_grupo_familiar as ID_Grupo_Familiar,
    id_tutor as ID_Tutor
from socio.socio where dni = 44444444;

print 'Caso 3 completado: Valentina Pérez ahora está bajo la responsabilidad del tutor María González';
print '';

-- =====================================================
-- 5. CASO 4: CAMBIO DE RESPONSABLE DEL GRUPO FAMILIAR
-- =====================================================

print '5. CASO 4: CAMBIO DE RESPONSABLE DEL GRUPO FAMILIAR';
print 'Escenario: Cambiar el responsable del grupo familiar de Carlos a Ana Pérez';
print '';

-- Crear nuevos menores para el grupo familiar
print 'Creando nuevos menores para el grupo familiar...';

-- Nuevo hijo
exec socio.altaSocio @nombre = 'Diego', @apellido = 'Pérez', @dni = 55555555, @email = 'diego.perez@email.com', 
    @fecha_nacimiento = '2012-07-18', @telefono = null, @telefono_emergencia = '11-1111-1112', 
    @id_obra_social_socio = 1, @id_tutor = null, @id_grupo_familiar = @id_padre, @estado = 'Activo', @responsable_pago = 0;

-- Nueva hija
exec socio.altaSocio @nombre = 'Camila', @apellido = 'Pérez', @dni = 66666666, @email = 'camila.perez@email.com', 
    @fecha_nacimiento = '2016-11-25', @telefono = null, @telefono_emergencia = '11-1111-1112', 
    @id_obra_social_socio = 1, @id_tutor = null, @id_grupo_familiar = @id_padre, @estado = 'Activo', @responsable_pago = 0;

-- Verificar estado inicial del grupo
print 'Estado inicial del grupo familiar:';
select 
    'Estado inicial del grupo familiar' as Estado,
    nombre + ' ' + apellido as Nombre,
    datediff(YEAR, fecha_nacimiento, getdate()) as Edad,
    case responsable_pago when 1 then 'Sí' else 'No' end as Responsable_Pago,
    id_grupo_familiar as ID_Grupo_Familiar
from socio.socio 
where dni in (11111111, 55555555, 66666666)
order by fecha_nacimiento;

print '';

-- Cambiar responsable del grupo familiar
print 'Cambiando responsable del grupo familiar de Carlos a Ana Pérez...';
exec socio.cambiarResponsableGrupoFamiliar @id_grupo_familiar = @id_padre, @nuevo_responsable = @id_madre;

print '';

-- Verificar estado final del grupo
print 'Estado final del grupo familiar:';
select 
    'Estado final del grupo familiar después del cambio de responsable de Carlos a Ana Pérez' as Estado,
    nombre + ' ' + apellido as Nombre,
    datediff(YEAR, fecha_nacimiento, getdate()) as Edad,
    case responsable_pago when 1 then 'Sí' else 'No' end as Responsable_Pago,
    id_grupo_familiar as ID_Grupo_Familiar
from socio.socio 
where dni in (22222222, 55555555, 66666666)
order by fecha_nacimiento;

print 'Caso 4 completado: Ana Pérez es ahora la responsable del grupo familiar';
print '';

-- =====================================================
-- 6. CASO 5: CASOS DE ERROR
-- =====================================================

print '6. CASO 5: CASOS DE ERROR';
print 'Probando validaciones de los procedimientos...';
print '';

-- Error 1: Intentar dar de baja a un socio que no está en grupo familiar
print 'Error 1: Intentar dar de baja a un socio que no está en grupo familiar...';
begin try
    exec socio.bajaSocioDeGrupoFamiliar @id_socio = @id_madre;
    print 'ERROR: No se detectó el error esperado';
end try
begin catch
    print 'Error capturado correctamente: ' + ERROR_MESSAGE();
end catch

print '';

-- Error 2: Intentar dar de baja a un menor sin especificar nuevo responsable
print 'Error 2: Intentar dar de baja a un menor sin especificar nuevo responsable...';
-- Primero agregar un menor al grupo de Ana
declare @id_nuevo_menor int;
exec socio.altaSocio @nombre = 'Test', @apellido = 'Menor', @dni = 77777777, @email = 'test@email.com', 
    @fecha_nacimiento = '2015-01-01', @telefono = null, @telefono_emergencia = '11-1111-1112', 
    @id_obra_social_socio = 1, @id_tutor = null, @id_grupo_familiar = @id_madre, @estado = 'Activo', @responsable_pago = 0;

select @id_nuevo_menor = id from socio.socio where dni = 77777777;

begin try
    exec socio.bajaSocioDeGrupoFamiliar @id_socio = @id_nuevo_menor;
    print 'ERROR: No se detectó el error esperado';
end try
begin catch
    print 'Error capturado correctamente: ' + ERROR_MESSAGE();
end catch

print '';

-- Error 3: Intentar cambiar responsable por un menor
print 'Error 3: Intentar cambiar responsable por un menor...';
begin try
    exec socio.cambiarResponsableGrupoFamiliar @id_grupo_familiar = @id_madre, @nuevo_responsable = @id_nuevo_menor;
    print 'ERROR: No se detectó el error esperado';
end try
begin catch
    print 'Error capturado correctamente: ' + ERROR_MESSAGE();
end catch

print '';