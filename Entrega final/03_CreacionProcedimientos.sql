/*
    Consigna: Implementar los SP necesarios para cumplir con la lógica del sistema
    Fecha de entrega: 24/06/2025
    Número de comisión: 2900
    Número de grupo: 11
    Nombre de la materia: Bases de Datos Aplicadas
    Integrantes:
        - Costanzo, Marcos Ezequiel - 40955907
        - Sanchez, Diego Mauricio - 46361081
*/

use Com2900G11;
go

---- Obra Social Socio ----
-- Insert
create or alter procedure socio.altaObraSocialSocio
    @nombre varchar(50),
    @telefono_emergencia varchar(50),
    @numero_socio varchar(50)
as
begin
    insert into socio.obra_social_socio (nombre, telefono_emergencia, numero_socio)
    value (@nombre, @telefono_emergencia, @numero_socio);
end
go

-- Update
create or alter procedure socio.modificacionObraSocialSocio
    @id int,
    @nombre varchar(50),
    @telefono_emergencia varchar(50),
    @numero_socio varchar(50)
as
begin
    if not exists (select 1 from socio.obra_social_socio where id = @id)
    begin
        raiserror('No existe una obra social con ese ID.', 16, 1);
        return;
    end;

    update socio.obra_social_socio
    set nombre = @nombre,
        telefono_emergencia = @telefono_emergencia,
        numero_socio = @numero_socio
    where id = @id;
end
go

-- Delete
create or alter procedure socio.bajaObraSocialSocio
    @id int
as
begin
    if not exists (select 1 from socio.obra_social_socio where id = @id)
    begin
        raiserror('No existe una obra social con ese ID.', 16, 1);
        return;
    end;

    if exists (select 1 from socio.socio where id_obra_social_socio = @id)
    begin
        raiserror('No se puede eliminar porque está vinculada a un socio.', 16, 1);
        return;
    end

    delete from socio.obra_social_socio where id = @id;
end
go


---- Tutor ----
-- Insert
create or alter procedure socio.altaTutor
    @nombre varchar(50),
    @apellido varchar(50),
    @dni int,
    @email varchar(254),
    @parentesco varchar(20)
as
begin
    if @dni <= 0
    begin
        raiserror('El DNI debe ser mayor a 0.', 16, 1);
        return;
    end

    if exists (select 1 from socio.tutor where dni = @dni)
    begin
        raiserror('Ya existe un tutor con ese DNI.', 16, 1);
        return;
    end

    insert into socio.tutor (nombre, apellido, dni, email, parentesco, responsable_pago)
    values (@nombre, @apellido, @dni, @email, @parentesco, 1);
end
go

-- Update
create or alter procedure socio.modificacionTutor
    @id int,
    @nombre varchar(50),
    @apellido varchar(50),
    @dni int,
    @email varchar(254),
    @parentesco varchar(20)
as
begin
    if not exists (select 1 from socio.tutor where id = @id)
    begin
        raiserror('No existe un tutor con ese ID.', 16, 1);
        return;
    end

    if exists (select 1 from socio.tutor where dni = @dni and id <> @id)
    begin
        raiserror('Ya existe otro tutor con ese DNI.', 16, 1);
    end

    update socio.tutor
    set nombre = @nombre,
        apellido = @apellido,
        dni = @dni,
        email = @email,
        parentesco = @parentesco,
        responsable_pago =  1;
end
go

-- Delete
create or replace procedure socio.bajaTutor
    @id int
as
begin
    if not exists (select 1 from socio.tutor where id = @id)
    begin
        raiserror('No exite un tutor con ese ID.', 16, 1);
        return;
    end

    delete from socio.tutor where id = @id;
end
go


---- Inscripción ----
-- Insert
create or alter procedure socio.altaInscripcion
    @id_socio int,
    @fecha_inscripcion
begin
    if not exists (select 1 from socio.socio where id = @id_socio)
    begin
        raiserror('No existe un socio con ese ID.', 16, 1);
        return;
    end

    insert into (id_socio, fecha_inscripcion)
    values (@id_socio, @fecha_inscripcion);
end

-- Update: no permitido en el sistema


-- Delete: no permitido en el sistema



---- Socio ----
-- Insert
create or replace procedure socio.altaSocio
    @nombre varchar(100),
    @apellido varchar(100),
    @dni int,
    @email varchar(254),
    @fecha_nacimiento date,
    @telefono varchar(20),
    @telefono_emergencia varchar(20),
    @id_obra_social_socio int,
    @id_tutor int,
    @id_grupo_familiar int,
    @estado varchar(20),
    @responsable_pago bit
begin
    if @dni <= 0
    begin
        raiserror('El DNI debe ser mayor a 0.', 16, 1);
        return;
    end

    if @email not like '_%@_%._%'
    begin
        raiserror('El email no tiene un formato válido.', 16, 1);
        return;
    end

    begin try
        begin transaction;

        insert into socio.socio (nombre, apellido, dni, email, fecha_nacimiento, telefono, telefono_emergencia, id_obra_social_socio, id_tutor, id_grupo_familiar, estado, responsable_pago)
        values (@nombre, @apellido, @dni, @email, @fecha_nacimiento, @telefono, @telefono_emergencia, @id_obra_social_socio, @id_tutor, @id_grupo_familiar, @estado, @responsable_pago);

        declare @id_socio_new int = scope_identity();


        declare @edad int;
        declare @fecha_actual date;
        set @edad = datediff(YEAR, @fecha_nacimiento, getdate());
        set @fecha_actual = getdate();

        -- Ajuste si no cumplió aún este año
        if dateadd(year, @edad, @fecha_nacimiento) > cast(@fecha_actual as date)
            set @edad = @edad - 1;

        if @edad < 18
        begin
            declare @rp int;
            set @rp = isnull(@id_tutor, @id_grupo_familiar);

            exec socio.altaEstadoCuenta
                @id_socio = @rp,
                @saldo = 0;
        end
        else
        begin
            exec socio.altaEstadoCuenta
                @id_socio = @id_socio_new,
                @saldo = 0;
        end

        exec socio.altaInscripcion
            @id_socio,
            @fecha_actual;

        commit transaction;
    end try;
    begin catch
        rollback transaction;
        declare @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
        print 'Error al agregar estado de cuenta: ' + @ErrorMessage;
        return;
    end catch 
end
go

-- Update
create or replace procedure socio.modificacionSocio
    @id int,
    @nombre varchar(100),
    @apellido varchar(100),
    @dni int,
    @email varchar(254),
    @fecha_nacimiento date,
    @telefono varchar(20),
    @telefono_emergencia varchar(20),
    @id_obra_social_socio int,
    /*@id_tutor int,*/
    /*@id_grupo_familiar int,*/
    /*@estado varchar(20)*/
    /*@responsable_pago bit*/
begin
    if @dni <= 0
    begin
        raiserror('El DNI debe ser mayor a 0.', 16, 1);
        return;
    end

    if @email not like '_%@_%._%'
    begin
        raiserror('El email no tiene un formato válido.', 16, 1);
        return;
    end

    update socio.tutor
    set nombre = @nombre,
        apellido = @apellido,
        dni = @dni,
        email = @email,
        parentesco = @parentesco,
        responsable_pago =  1;

    update socio.socio
    set nombre = @nombre,
        apellido = @apellido,
        dni = @dni,
        email = @email,
        fecha_nacimiento = @fecha_nacimiento,
        telefono = @telefono,
        telefono_emergencia = @telefono_emergencia,
        id_obra_social_socio = @id_obra_social_socio;
end

-- Delete
create or replace procedure socio.actualizarEstadoSocio
    @id int,
    @estado varchar(20)
begin
    if not exists (select 1 from socio.socio where id = @id)
    begin
        raiserror('No existe un socio con ese ID.', 16, 1);
        return;
    end

    if @estado not in ('Activo', 'Inactivo', 'Moroso')
    begin
        raiserror('El estado no es válido.', 16, 1);
        return;
    end

    update socio.socio
    set estado = @estado;
end
go


---- Debito Automatico ----
-- Insert
create or alter procedure socio.altaDebitoAutomatico
    @id_responsable_pago int,
    @medio_de_pago varchar(50),
    @activo bit = 1,
    @token_pago varchar(200),
    @ultimos_4_digitos int,
    @titular varchar(100)
begin
    if not exists (select 1 from socio.socio where id = @id_responsable_pago)
    begin
        raiserror('No existe un socio responsable de pago con ese ID.', 16, 1);
        return;
    end

    insert into socio.debito_automatico (id_responsable_pago, medio_de_pago, activo, token_pago, ultimos_4_digitos, titular)
    values (@id_responsable_pago, @medio_de_pago, @activo, @token_pago, @ultimos_4_digitos, @titular);
end
go

-- Update
create or alter procedure socio.modificacionDebitoAutomatico
    @id int,
    @medio_de_pago varchar(50),
    @activo bit,
    @token_pago varchar(200),
    @ultimos_4_digitos int,
    @titular varchar(100)
begin
    if not exists (select 1 from socio.debito_automatico where id = @id)
    begin
        raiserror('No existe un debito automatico con ese ID.', 16, 1);
        return;
    end

    update socio.debito_automatico
    set medio_de_pago = @medio_de_pago,
        activo = @activo,
        token_pago = @token_pago,
        ultimos_4_digitos = @ultimos_4_digitos,
        titular = @titular
    where id = @id;
end
go

-- Delete
create or replace procedure socio.bajaDebitoAutomatico
    @id int
begin
    if not exists (select 1 from socio.debito_automatico where id = @id)
    begin
        raiserror('No existe un debito automatico con ese ID.', 16, 1);
        return;
    end

    -- No se borra sino que se da de baja
    update socio.debito_automatico
    set activo = 0
    where id = @id;
end
go


---- Empleado ----
-- Insert
create or replace procedure socio.altaEmpleado
    @nombre varchar(100)
begin
    insert into general.empleado (nombre)
    values (@nombre);
end

-- Update
create or replace procedure socio.modificacionEmpleado
    @id int,
    @nombre varchar(100)
begin
    update general.empleado
    set nombre = @nombre
    where id = @id;
end
go

-- Delete
create or replace procedure socio.bajaEmpleado
    @id int,
begin
    if not exists (select 1 from general.empleado where id = @id)
    begin
        raiserror('No existe un empleado con ese ID.', 16, 1);
        return;
    end

    if exists (select 1 from general.clase where id_empleado = @id)
    begin
        raiserror('No se puede eliminar porque está asignado a una clase.', 16, 1);
        return;
    end

    delete from general.empleado
    where id = @id;
end
go


---- Invitado ----
-- Insert
create or replace procedure socio.altaInvitado
    @nombre varchar(100),
    @apellido varchar(100),
    @dni int,
    @email varchar(254)
begin
    insert into socio.invitado (nombre, apellido, dni, email)
    values (@nombre, @apellido, @dni, @email);
end
go

-- Update
create or replace procedure socio.modificacionInvitado
    @id int,
    @nombre varchar(100),
    @apellido varchar(100),
    @dni int,
    @email varchar(254)
begin
    update socio.invitado
    set nombre = @nombre,
        apellido = @apellido,
        dni = @dni,
        email = @email
    where id = @id;
end

-- Delete
create or replace procedure socio.bajaInvitado
    @id int
begin
    if not exists (select 1 from socio.invitado where id = @id)
    begin
        raiserror('No existe un invitado con ese ID.', 16, 1);
        return;
    end

    delete from socio.invitado
    where id = @id;
end
go


---- Registro Pileta ----
-- Insert
create or replace procedure socio.altaRegistroPileta
    @id_socio int,
    @id_invitado int,
    @fecha date,
    @id_tarifa int,
begin
    declare @id_registro_pileta int;

    if @id_socio is not null and not exists (select 1 from socio.socio where id = @id_socio)
    begin
        raiserror('No existe un socio con ese ID.', 16, 1);
        return;
    end

    if @id_invitado is not null and not exists (select 1 from socio.invitado where id = @id_invitado)
    begin
        raiserror('No existe un invitado con ese ID.', 16, 1);
        return;
    end

    if not exists (select 1 from socio.tarifa_pileta where id = @id_tarifa)
    begin
        raiserror('No existe una tarifa con ese ID.', 16, 1);
        return;
    end

    if exists (select 1 from socio.registro_pileta where id_socio = @id_socio and fecha = @fecha)
    begin
        raiserror('Ya existe un registro para ese socio y fecha.', 16, 1);
        return;
    end

    begin try
        begin transaction;

        insert into socio.registro_pileta (id_socio, id_invitado, fecha, id_tarifa)
        values (@id_socio, @id_invitado, @fecha, @id_tarifa);

        set @id_registro_pileta = scope_identity();

        exec socio.altaFacturaExtra
            @id_registro_pileta = @id_registro_pileta;

        commit transaction;
    end try;
    begin catch
        rollback transaction;
        return;
    end catch;
end
go


---- Actividad Extra ----
-- Insert
create or alter procedure socio.altaActividadExtra
    @id_socio int,
    @nombre varchar(50),
    @costo decimal(8,2)
begin
    if not exists (select 1 from socio.socio where id = @id_socio)
    begin
        raiserror('No existe un socio con ese ID.', 16, 1);
        return;
    end

    begin try
        begin transaction;

        insert into general.actividad_extra (nombre, costo)
        values (@nombre, @costo);

        declare @id_actividad_extra int = scope_identity();

        exec socio.altaFacturaExtra
            @id_actividad_extra = @id_actividad_extra;

        commit transaction;
    end try;
    begin catch
        rollback transaction;
        return;
    end catch;
end
go


---- Factura Extra ----
-- Insert
create or alter procedure socio.altaFacturaExtra
    @numero_comprobante int = null,
    @tipo_comprobante varchar(2) = 'B',
    @fecha_emision date = null,
    @periodo_facturado int = null,
    @iva varchar(50) = '21%',
    @fecha_vencimiento_1 date = null,
    @fecha_vencimiento_2 date = null,
    @importe_total decimal(8,2) = null,
    @descripcion varchar(100) = null,
    @id_registro_pileta int = null,
    @id_actividad_extra int = null
as
begin
    -- Validar que al menos uno de los parámetros no sea null
    if @id_registro_pileta is null and @id_actividad_extra is null
    begin
        raiserror('Debe proporcionar al menos un id_registro_pileta o id_actividad_extra.', 16, 1);
        return;
    end

    -- Establecer valores por defecto si no se proporcionan
    if @fecha_emision is null
        set @fecha_emision = getdate();
    
    if @fecha_vencimiento_1 is null
        set @fecha_vencimiento_1 = dateadd(day, 30, @fecha_emision);
    
    if @fecha_vencimiento_2 is null
        set @fecha_vencimiento_2 = dateadd(day, 40, @fecha_emision);
    
    if @periodo_facturado is null
        set @periodo_facturado = year(@fecha_emision) * 100 + month(@fecha_emision); -- AAAAMM

    declare @id_tarifa int;
    declare @precio_tarifa decimal(8,2);
    declare @id_factura_extra int;
    declare @tipo_item varchar(50);

    -- Caso 1: Factura por registro de pileta
    if @id_registro_pileta is not null
    begin
        -- Validar que existe el registro de pileta
        if not exists (select 1 from socio.registro_pileta where id = @id_registro_pileta)
        begin
            raiserror('No existe el registro de pileta especificado.', 16, 1);
            return;
        end

        -- Obtener datos del registro de pileta
        select @id_tarifa = id_tarifa from socio.registro_pileta where id = @id_registro_pileta;
        select @precio_tarifa = precio from socio.tarifa_pileta where id = @id_tarifa;
        
        if @precio_tarifa is null
        begin
            raiserror('No se encontró la tarifa de pileta.', 16, 1);
            return;
        end

        if @importe_total is null
            set @importe_total = @precio_tarifa;
        
        if @descripcion is null
            set @descripcion = 'Factura por uso de pileta';
        
        set @tipo_item = 'Uso de Pileta';
    end

    -- Caso 2: Factura por actividad extra
    if @id_actividad_extra is not null
    begin
        -- Validar que existe la actividad extra
        if not exists (select 1 from general.actividad_extra where id = @id_actividad_extra)
        begin
            raiserror('No existe la actividad extra especificada.', 16, 1);
            return;
        end

        -- Obtener datos de la actividad extra
        select @precio_tarifa = costo from general.actividad_extra where id = @id_actividad_extra;
        
        if @precio_tarifa is null
        begin
            raiserror('No se encontró el costo de la actividad extra.', 16, 1);
            return;
        end

        if @importe_total is null
            set @importe_total = @precio_tarifa;
        
        if @descripcion is null
            set @descripcion = 'Factura por actividad extra';
        
        set @tipo_item = 'Actividad Extra';
    end

    -- Generar número de comprobante si no se proporciona
    if @numero_comprobante is null
        select @numero_comprobante = isnull(max(numero_comprobante), 0) + 1 from socio.factura_extra;

    -- Insertar la factura extra
    insert into socio.factura_extra (
        numero_comprobante, tipo_comprobante, fecha_emision, periodo_facturado, iva,
        fecha_vencimiento_1, fecha_vencimiento_2, importe_total, descripcion, id_registro_pileta, id_actividad_extra
    ) values (
        @numero_comprobante, @tipo_comprobante, @fecha_emision, @periodo_facturado, @iva,
        @fecha_vencimiento_1, @fecha_vencimiento_2, @importe_total, @descripcion, @id_registro_pileta, @id_actividad_extra
    );
    set @id_factura_extra = scope_identity();

    -- Insertar el item de la factura extra
    insert into socio.item_factura_extra (
        id_factura_extra, cantidad, precio_unitario, alicuota_iva, tipo_item, subtotal, importe_total
    ) values (
        @id_factura_extra, 1, @precio_tarifa, 21, @tipo_item, @precio_tarifa, @precio_tarifa
    );
end
go


---- Tipo Reembolso ----
-- Insert
create or alter procedure socio.altaTipoReembolso
    @descripcion varchar(50)
begin
    insert into socio.tipo_reembolso (descripcion)
    values (@descripcion);
end
go

-- Update
create or alter procedure socio.modificacionTipoReembolso
    @id int,
    @descripcion varchar(50)
begin
    if not exists (select 1 from socio.tipo_reembolso where id = @id)
    begin
        raiserror('No existe un tipo de reembolso con ese ID.', 16, 1);
        return;
    end

    update socio.tipo_reembolso
    set descripcion = @descripcion
    where id = @id;
end
go

-- Delete
create or replace procedure socio.bajaTipoReembolso
    @id int
begin
    if not exists (select 1 from socio.tipo_reembolso where id = @id)
    begin
        raiserror('No existe un tipo de reembolso con ese ID.', 16, 1);
        return;
    end

    if exists (select 1 from socio.reembolso where id_tipo_reembolso = @id)
    begin
        raiserror('No se puede eliminar porque está asignado a un reembolso.', 16, 1);
        return;
    end

    delete from socio.tipo_reembolso
    where id = @id;
end
go


---- Clase ----
-- Insert
create or replace procedure general.altaClase
    @hora_inicio time,
    @hora_fin time,
    @dia varchar(10),
    @id_categoria int,
    @id_actividad int,
    @id_empleado int
begin
    if not exists (select 1 from socio.categoria where id = @id_categoria)
    begin
        raiserror('No existe una categoria con ese ID.', 16, 1);
        return;
    end

    if not exists (select 1 from general.actividad where id = @id_actividad)
    begin
        raiserror('No existe una actividad con ese ID.', 16, 1);
        return;
    end

    if not exists (select 1 from general.empleado where id = @id_empleado)
    begin
        raiserror('No existe un empleado con ese ID.', 16, 1);
        return;
    end

    insert into general.clase (hora_inicio, hora_fin, dia, id_categoria, id_actividad, id_empleado)
    values (@hora_inicio, @hora_fin, @dia, @id_categoria, @id_actividad, @id_empleado);
end
go

-- Update
create or replace procedure general.modificacionClase
    @id int,
    @hora_inicio time,
    @hora_fin time,
    @dia varchar(10),
    @id_categoria int,
    @id_actividad int,
    @id_empleado int
begin
    if not exists (select 1 from general.clase where id = @id)
    begin
        raiserror('No existe una clase con ese ID.', 16, 1);
        return;
    end

    update general.clase
    set hora_inicio = @hora_inicio,
        hora_fin = @hora_fin,
        dia = @dia,
        id_categoria = @id_categoria,
        id_actividad = @id_actividad,
        id_empleado = @id_empleado
    where id = @id;
end

-- Delete
create or replace procedure general.bajaClase
    @id int
begin
    if not exists (select 1 from general.clase where id = @id)
    begin
        raiserror('No existe una clase con ese ID.', 16, 1);
        return;
    end

    delete from general.clase
    where id = @id;
end
go


---- Presentismo ----
-- Insert
create or replace procedure general.altaPresentismo
    @id_socio int,
    @id_clase int,
    @fecha date
begin
    if not exists (select 1 from socio.socio where id = @id_socio)
    begin
        raiserror('No existe un socio con ese ID.', 16, 1);
        return;
    end

    if not exists (select 1 from general.clase where id = @id_clase)
    begin
        raiserror('No existe una clase con ese ID.', 16, 1);
        return;
    end

    insert into general.presentismo (id_socio, id_clase, fecha)
    values (@id_socio, @id_clase, @fecha);
end
go

-- Update
create or replace procedure general.modificacionPresentismo
    @id int,
    @id_socio int,
    @id_clase int,
    @fecha date
begin
    if not exists (select 1 from general.presentismo where id = @id)
    begin
        raiserror('No existe un presentismo con ese ID.', 16, 1);
        return;
    end

    update general.presentismo
    set id_socio = @id_socio,
        id_clase = @id_clase,
        fecha = @fecha
    where id = @id;
end


---- Inscripción Actividad ----
-- Insert
create or replace procedure socio.altaInscripcionActividad
    @id_cuota int,
    @id_actividad int,
    @activa bit = 1,
    @fecha_inscripcion date = getdate(),
    @fecha_baja date = null
begin
    if not exists (select 1 from socio.cuota where id = @id_cuota)
    begin
        raiserror('No existe una cuota con ese ID.', 16, 1);
        return;
    end

    if not exists (select 1 from general.actividad where id = @id_actividad)
    begin
        raiserror('No existe una actividad con ese ID.', 16, 1);
        return;
    end

    declare @monto_total decimal(8,2);
    select @monto_total = monto_total from socio.cuota where id = @id_cuota;

    if @monto_total is null
    begin
        raiserror('No se encontró el monto total de la cuota.', 16, 1);
        return;
    end

    declare @precio_actividad decimal(8,2);
    select @precio_actividad = precio from general.actividad where id = @id_actividad;

    if @precio_actividad is null
    begin
        raiserror('No se encontró el precio de la actividad.', 16, 1);
        return;
    end

    -- Transacciones
    begin try
        begin transaction;

        insert into socio.inscripcion_actividad (id_cuota, id_actividad, activa, fecha_inscripcion, fecha_baja)
        values (@id_cuota, @id_actividad, @activa, @fecha_inscripcion, @fecha_baja);

        -- Actualizar el monto total de la cuota sumandole el precio de la actividad
        declare @monto_total decimal(8,2);
        select @monto_total = monto_total from socio.cuota where id = @id_cuota;
        set @monto_total = @monto_total + @precio_actividad;

        -- Llamado al procedimiento para actualizar el monto total de la cuota
        exec socio.modificacionCuota @id_cuota, @monto_total;

        commit transaction;
    end try;
    begin catch
        rollback transaction;
        declare @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
        print 'Error al agregar la inscripción a actividad: ' + @ErrorMessage;
        return;
    end catch
end
go

-- Update: no permitido en el sistema

-- Delete
create or replace procedure socio.bajaInscripcionActividad
    @id int
begin
    if not exists (select 1 from socio.inscripcion_actividad where id = @id)
    begin
        raiserror('No existe una inscripción a actividad con ese ID.', 16, 1);
        return;
    end

    declare @id_cuota int;
    select @id_cuota = id_cuota from socio.inscripcion_actividad where id = @id;

    declare @precio_actividad decimal(8,2);
    select @precio_actividad = precio from general.actividad where id = (select id_actividad from socio.inscripcion_actividad where id = @id);

    if @precio_actividad is null
    begin
        raiserror('No se encontró el precio de la actividad.', 16, 1);
        return;
    end

    begin try
        begin transaction;

        update socio.inscripcion_actividad
        set activa = 0,
            fecha_baja = getdate()
        where id = @id;

        -- Actualizar el monto total de la cuota restandole el precio de la actividad
        declare @monto_total decimal(8,2);
        select @monto_total = monto_total from socio.cuota where id = @id_cuota;
        set @monto_total = @monto_total - @precio_actividad;

        -- Llamado al procedimiento para actualizar el monto total de la cuota
        exec socio.modificacionCuota @id_cuota, @monto_total;

        commit transaction;
    end try;
    begin catch
        rollback transaction;
        declare @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
        print 'Error al eliminar la inscripción a actividad: ' + @ErrorMessage;
        return;
    end catch
end
go


---- Cuota ----
-- Insert
create or replace procedure socio.altaCuota
    @id_socio int,
    @id_categoria int,
    @monto_total decimal(8,2) = 0
begin
    if not exists (select 1 from socio.socio where id = @id_socio)
    begin
        raiserror('No existe un socio con ese ID.', 16, 1);
        return;
    end

    if not exists (select 1 from socio.categoria where id = @id_categoria)
    begin
        raiserror('No existe una categoria con ese ID.', 16, 1);
        return;
    end

    insert into socio.cuota (id_socio, id_categoria, monto_total)
    values (@id_socio, @id_categoria, @monto_total);
end
go

-- Update
create or replace procedure socio.modificacionCuota
    @id int,
    @monto_total decimal(8,2)
begin
    if not exists (select 1 from socio.cuota where id = @id)
    begin
        raiserror('No existe una cuota con ese ID.', 16, 1);
        return;
    end

    update socio.cuota
    set id_categoria = @id_categoria,
        monto_total = @monto_total
    where id = @id;
end
go

-- Delete: no permitido en el sistema


---- Factura Cuota ----
-- Insert
create or replace procedure socio.altaFacturaCuota
    @numero_comprobante int = null,
    @tipo_comprobante varchar(2) = 'B',
    @fecha_emision date = null,
    @periodo_facturado int = null,
    @iva varchar(50) = '21%',
    @fecha_vencimiento_1 date = null,
    @fecha_vencimiento_2 date = null,
    @importe_total decimal(8,2) = null,
    @descripcion varchar(100) = null,
    @id_cuota int
begin
    if not exists (select 1 from socio.cuota where id = @id_cuota)
    begin
        raiserror('No existe una cuota con ese ID.', 16, 1);
        return;
    end

    -- Establecer valores por defecto si no se proporcionan
    if @fecha_emision is null
        set @fecha_emision = getdate();
    
    if @fecha_vencimiento_1 is null
        set @fecha_vencimiento_1 = dateadd(day, 30, @fecha_emision);
    
    if @fecha_vencimiento_2 is null
        set @fecha_vencimiento_2 = dateadd(day, 40, @fecha_emision);
    
    if @periodo_facturado is null
        set @periodo_facturado = year(@fecha_emision) * 100 + month(@fecha_emision); -- AAAAMM

    -- Obtener datos de la cuota y del socio
    declare @id_socio int;
    declare @id_categoria int;
    declare @monto_total_cuota decimal(8,2);
    declare @costo_categoria decimal(8,2);
    declare @nombre_categoria varchar(10);
    declare @id_factura_cuota int;
    declare @id_estado_cuenta int;
    declare @id_responsable_pago int;
    declare @responsable_pago bit;
    declare @id_grupo_familiar int;
    declare @id_tutor int;

    select @id_socio = c.id_socio, 
           @id_categoria = c.id_categoria, 
           @monto_total_cuota = c.monto_total,
           @responsable_pago = s.responsable_pago,
           @id_grupo_familiar = s.id_grupo_familiar,
           @id_tutor = s.id_tutor
    from socio.cuota c
    inner join socio.socio s on c.id_socio = s.id
    where c.id = @id_cuota;

    if @id_socio is null
    begin
        raiserror('No se encontró la información de la cuota.', 16, 1);
        return;
    end

    -- Determinar el responsable de pago
    if @responsable_pago = 1
    begin
        -- El socio es responsable de pago
        set @id_responsable_pago = @id_socio;
    end
    else
    begin
        -- El socio no es responsable de pago, buscar en grupo familiar o tutor
        if @id_grupo_familiar is not null
        begin
            set @id_responsable_pago = @id_grupo_familiar;
        end
        else if @id_tutor is not null
        begin
            set @id_responsable_pago = @id_tutor;
        end
        else
        begin
            raiserror('El socio no es responsable de pago y no tiene grupo familiar ni tutor asignado.', 16, 1);
            return;
        end
    end

    -- Obtener información de la categoría
    select @costo_categoria = costo_mensual, @nombre_categoria = nombre
    from socio.categoria 
    where id = @id_categoria;

    if @costo_categoria is null
    begin
        raiserror('No se encontró la información de la categoría.', 16, 1);
        return;
    end

    begin try
        begin transaction;

        -- Insertar la factura cuota
        insert into socio.factura_cuota (
            numero_comprobante, tipo_comprobante, fecha_emision, periodo_facturado, iva,
            fecha_vencimiento_1, fecha_vencimiento_2, importe_total, descripcion, id_cuota
        ) values (
            @numero_comprobante, @tipo_comprobante, @fecha_emision, @periodo_facturado, @iva,
            @fecha_vencimiento_1, @fecha_vencimiento_2, @importe_total, @descripcion, @id_cuota
        );
        set @id_factura_cuota = scope_identity();

        -- Insertar los items de la factura cuota (categoría y actividades)
        exec socio.altaItemFacturaCuota @id_factura_cuota;

        -- Obtener el ID del estado de cuenta del responsable de pago
        select @id_estado_cuenta = id from socio.estado_cuenta where id_socio = @id_responsable_pago;

        if @id_estado_cuenta is null
        begin
            raiserror('No existe un estado de cuenta para el responsable de pago (ID: %d).', 16, 1, @id_responsable_pago);
            return;
        end

        -- Insertar movimiento de cuenta (monto negativo porque es una factura)
        exec socio.altaMovimientoCuenta
            @id_estado_cuenta = @id_estado_cuenta,
            @monto = -@importe_total,
            @id_factura = @id_factura_cuota;

        -- Actualizar el estado de cuenta del responsable de pago
        exec socio.modificacionEstadoCuenta
            @id_socio = @id_responsable_pago,
            @monto = -@importe_total;

        commit transaction;
    end try
    begin catch
        rollback transaction;
        declare @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
        raiserror('Error al crear la factura cuota: %s', 16, 1, @ErrorMessage);
        return;
    end catch
end
go


---- Item Factura Cuota ----
-- Insert
create or alter procedure socio.altaItemFacturaCuota
    @id_factura_cuota int
as
begin
    if not exists (select 1 from socio.factura_cuota where id = @id_factura_cuota)
    begin
        raiserror('No existe una factura cuota con ese ID.', 16, 1);
        return;
    end

    declare @id_cuota int;
    declare @id_socio int;
    declare @id_categoria int;
    declare @costo_categoria decimal(8,2);
    declare @nombre_categoria varchar(10);

    -- Obtener información de la factura y cuota
    select @id_cuota = fc.id_cuota
    from socio.factura_cuota fc
    where fc.id = @id_factura_cuota;

    if @id_cuota is null
    begin
        raiserror('No se encontró la información de la cuota asociada a la factura.', 16, 1);
        return;
    end

    -- Obtener información de la cuota
    select @id_socio = c.id_socio, 
           @id_categoria = c.id_categoria
    from socio.cuota c
    where c.id = @id_cuota;

    if @id_categoria is null
    begin
        raiserror('No se encontró la información de la categoría de la cuota.', 16, 1);
        return;
    end

    -- Obtener información de la categoría
    select @costo_categoria = costo_mensual, @nombre_categoria = nombre
    from socio.categoria 
    where id = @id_categoria;

    if @costo_categoria is null
    begin
        raiserror('No se encontró la información de la categoría.', 16, 1);
        return;
    end

    begin try
        begin transaction;

        -- Insertar item de la categoría
        insert into socio.item_factura_cuota (
            id_factura_cuota, cantidad, precio_unitario, alicuota_iva, tipo_item, subtotal, importe_total
        ) values (
            @id_factura_cuota, 1, @costo_categoria, 21, 'Categoría - ' + @nombre_categoria, @costo_categoria, @costo_categoria
        );

        -- Insertar items de todas las actividades asociadas a la cuota
        insert into socio.item_factura_cuota (
            id_factura_cuota, cantidad, precio_unitario, alicuota_iva, tipo_item, subtotal, importe_total
        )
        select 
            @id_factura_cuota,
            1,
            a.costo_mensual,
            21,
            'Actividad - ' + a.nombre,
            a.costo_mensual,
            a.costo_mensual
        from socio.inscripcion_actividad ia
        inner join general.actividad a on ia.id_actividad = a.id
        where ia.id_cuota = @id_cuota
        and ia.activa = 1;

        commit transaction;
    end try
    begin catch
        rollback transaction;
        declare @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
        raiserror('Error al crear los items de factura cuota: %s', 16, 1, @ErrorMessage);
        return;
    end catch
end
go


---- Estado Cuenta ----
-- Insert
create or alter procedure socio.altaEstadoCuenta
    @id_socio int,
    @saldo decimal(8,2) = 0
as
begin
    if not exists (select 1 from socio.socio where id = @id_socio)
    begin
        raiserror('No existe un socio con ese ID.', 16, 1);
        return;
    end

    if exists (select 1 from socio.estado_cuenta where id_socio = @id_socio)
    begin
        raiserror('Ya existe un estado de cuenta para este socio.', 16, 1);
        return;
    end

    insert into socio.estado_cuenta (id_socio, saldo)
    values (@id_socio, @saldo);
end
go


---- Movimiento Cuenta ----
-- Insert
create or alter procedure socio.altaMovimientoCuenta
    @id_estado_cuenta int,
    @monto decimal(8,2),
    @id_factura int = null,
    @id_pago int = null,
    @id_reembolso int = null
as
begin
    if not exists (select 1 from socio.estado_cuenta where id = @id_estado_cuenta)
    begin
        raiserror('No existe un estado de cuenta con ese ID.', 16, 1);
        return;
    end

    -- Validar que al menos uno de los parámetros de referencia no sea null
    if @id_factura is null and @id_pago is null and @id_reembolso is null
    begin
        raiserror('Debe proporcionar al menos un id_factura, id_pago o id_reembolso.', 16, 1);
        return;
    end

    insert into socio.movimiento_cuenta (id_estado_cuenta, fecha, monto, id_factura, id_pago, id_reembolso)
    values (@id_estado_cuenta, getdate(), @monto, @id_factura, @id_pago, @id_reembolso);
end
go

-- Update
create or alter procedure socio.modificacionEstadoCuenta
    @id_socio int,
    @monto decimal(8,2)
as
begin
    if not exists (select 1 from socio.socio where id = @id_socio)
    begin
        raiserror('No existe un socio con ese ID.', 16, 1);
        return;
    end

    declare @id_estado_cuenta int;
    select @id_estado_cuenta = id from socio.estado_cuenta where id_socio = @id_socio;

    if @id_estado_cuenta is null
    begin
        raiserror('No existe un estado de cuenta para este socio.', 16, 1);
        return;
    end

    update socio.estado_cuenta
    set saldo = saldo + @monto
    where id = @id_estado_cuenta;
end
go


---- Pago ----
-- Insert
create or alter procedure socio.altaPago
    @fecha_pago date = null,
    @monto decimal(8,2),
    @medio_de_pago varchar(50),
    @es_debito_automatico bit = 0,
    @id_factura_cuota int = null,
    @id_factura_extra int = null
as
begin
    -- Validar que al menos una factura sea proporcionada
    if @id_factura_cuota is null and @id_factura_extra is null
    begin
        raiserror('Debe proporcionar al menos un id_factura_cuota o id_factura_extra.', 16, 1);
        return;
    end

    -- Validar que no se proporcionen ambas facturas
    if @id_factura_cuota is not null and @id_factura_extra is not null
    begin
        raiserror('Solo puede proporcionar un tipo de factura (cuota o extra), no ambas.', 16, 1);
        return;
    end

    -- Establecer fecha de pago por defecto
    if @fecha_pago is null
        set @fecha_pago = getdate();

    declare @id_pago int;
    declare @id_socio_responsable int;
    declare @id_estado_cuenta int;
    declare @importe_factura decimal(8,2);
    declare @tipo_factura varchar(20);

    -- Determinar el tipo de factura y obtener información
    if @id_factura_cuota is not null
    begin
        -- Validar que existe la factura cuota
        if not exists (select 1 from socio.factura_cuota where id = @id_factura_cuota)
        begin
            raiserror('No existe una factura cuota con ese ID.', 16, 1);
            return;
        end

        -- Obtener información de la factura cuota y determinar el responsable de pago
        declare @id_cuota int;
        declare @id_socio int;
        declare @responsable_pago bit;
        declare @id_grupo_familiar int;
        declare @id_tutor int;

        select @id_cuota = fc.id_cuota,
               @importe_factura = fc.importe_total
        from socio.factura_cuota fc
        where fc.id = @id_factura_cuota;

        -- Obtener información del socio y determinar responsable de pago
        select @id_socio = c.id_socio,
               @responsable_pago = s.responsable_pago,
               @id_grupo_familiar = s.id_grupo_familiar,
               @id_tutor = s.id_tutor
        from socio.cuota c
        inner join socio.socio s on c.id_socio = s.id
        where c.id = @id_cuota;

        -- Determinar el responsable de pago
        if @responsable_pago = 1
        begin
            set @id_socio_responsable = @id_socio;
        end
        else
        begin
            if @id_grupo_familiar is not null
            begin
                set @id_socio_responsable = @id_grupo_familiar;
            end
            else if @id_tutor is not null
            begin
                set @id_socio_responsable = @id_tutor;
            end
            else
            begin
                raiserror('El socio no es responsable de pago y no tiene grupo familiar ni tutor asignado.', 16, 1);
                return;
            end
        end

        set @tipo_factura = 'CUOTA';
    end
    else
    begin
        -- Validar que existe la factura extra
        if not exists (select 1 from socio.factura_extra where id = @id_factura_extra)
        begin
            raiserror('No existe una factura extra con ese ID.', 16, 1);
            return;
        end

        -- Para facturas extra, obtener el socio y determinar el responsable de pago
        declare @id_registro_pileta int;
        declare @id_actividad_extra int;
        declare @id_socio int;
        declare @responsable_pago bit;
        declare @id_grupo_familiar int;
        declare @id_tutor int;

        select @importe_factura = fe.importe_total,
               @id_registro_pileta = fe.id_registro_pileta,
               @id_actividad_extra = fe.id_actividad_extra
        from socio.factura_extra fe
        where fe.id = @id_factura_extra;

        -- Determinar el socio responsable según el tipo de factura extra
        if @id_registro_pileta is not null
        begin
            -- Factura por registro de pileta
            select @id_socio = rp.id_socio
            from socio.registro_pileta rp
            where rp.id = @id_registro_pileta;

            if @id_socio is null
            begin
                raiserror('No se encontró el socio asociado al registro de pileta.', 16, 1);
                return;
            end

            -- Obtener información del socio para determinar responsable de pago
            select @responsable_pago = s.responsable_pago,
                   @id_grupo_familiar = s.id_grupo_familiar,
                   @id_tutor = s.id_tutor
            from socio.socio s
            where s.id = @id_socio;

            -- Determinar el responsable de pago
            if @responsable_pago = 1
            begin
                set @id_socio_responsable = @id_socio;
            end
            else
            begin
                if @id_grupo_familiar is not null
                begin
                    set @id_socio_responsable = @id_grupo_familiar;
                end
                else if @id_tutor is not null
                begin
                    set @id_socio_responsable = @id_tutor;
                end
                else
                begin
                    raiserror('El socio no es responsable de pago y no tiene grupo familiar ni tutor asignado.', 16, 1);
                    return;
                end
            end
        end
        else if @id_actividad_extra is not null
        begin
            -- Factura por actividad extra - necesitaríamos el socio asociado
            raiserror('Para facturas de actividad extra, se requiere información adicional del socio.', 16, 1);
            return;
        end

        set @tipo_factura = 'EXTRA';
    end

    -- Validar que el monto del pago coincida con el importe de la factura
    if @monto != @importe_factura
    begin
        raiserror('El monto del pago (%.2f) debe coincidir con el importe de la factura (%.2f).', 16, 1, @monto, @importe_factura);
        return;
    end

    -- Obtener el estado de cuenta del responsable de pago
    select @id_estado_cuenta = id 
    from socio.estado_cuenta 
    where id_socio = @id_socio_responsable;

    if @id_estado_cuenta is null
    begin
        raiserror('No existe un estado de cuenta para el responsable de pago (ID: %d).', 16, 1, @id_socio_responsable);
        return;
    end

    begin try
        begin transaction;

        -- Insertar el pago
        insert into socio.pago (
            fecha_pago, monto, medio_de_pago, es_debito_automatico, 
            id_factura_cuota, id_factura_extra
        ) values (
            @fecha_pago, @monto, @medio_de_pago, @es_debito_automatico,
            @id_factura_cuota, @id_factura_extra
        );
        set @id_pago = scope_identity();

        -- Generar movimiento de cuenta para ambos tipos de factura
        -- Insertar movimiento de cuenta (monto positivo porque es un pago)
        exec socio.altaMovimientoCuenta
            @id_estado_cuenta = @id_estado_cuenta,
            @monto = @monto,
            @id_pago = @id_pago;

        -- Actualizar el estado de cuenta del responsable de pago
        exec socio.modificacionEstadoCuenta
            @id_socio = @id_socio_responsable,
            @monto = @monto;

        commit transaction;
    end try
    begin catch
        rollback transaction;
        declare @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
        raiserror('Error al crear el pago: %s', 16, 1, @ErrorMessage);
        return;
    end catch
end
go

---- Reembolso ----
-- Insert
create or alter procedure socio.altaReembolso
    @id_pago int,
    @monto decimal(8,2),
    @fecha_reembolso datetime = null,
    @motivo varchar(100),
    @id_tipo_reembolso int
as
begin
    -- Validar que el pago existe
    if not exists (select 1 from socio.pago where id = @id_pago)
    begin
        raiserror('No existe un pago con ese ID.', 16, 1);
        return;
    end

    -- Validar que el tipo de reembolso existe
    if not exists (select 1 from socio.tipo_reembolso where id = @id_tipo_reembolso)
    begin
        raiserror('No existe un tipo de reembolso con ese ID.', 16, 1);
        return;
    end

    -- Establecer fecha de reembolso por defecto
    if @fecha_reembolso is null
        set @fecha_reembolso = getdate();

    -- Validar que el monto del reembolso no exceda el monto del pago
    declare @monto_pago decimal(8,2);
    select @monto_pago = monto from socio.pago where id = @id_pago;

    if @monto > @monto_pago
    begin
        raiserror('El monto del reembolso (%.2f) no puede exceder el monto del pago (%.2f).', 16, 1, @monto, @monto_pago);
        return;
    end

    -- Determinar el responsable de pago del pago original
    declare @id_socio_responsable int;
    declare @id_estado_cuenta int;
    declare @id_reembolso int;

    -- Obtener información del pago para determinar el responsable
    declare @id_factura_cuota int;
    declare @id_factura_extra int;
    declare @id_socio int;
    declare @responsable_pago bit;
    declare @id_grupo_familiar int;
    declare @id_tutor int;

    select @id_factura_cuota = p.id_factura_cuota,
           @id_factura_extra = p.id_factura_extra
    from socio.pago p
    where p.id = @id_pago;

    -- Determinar el responsable de pago según el tipo de factura
    if @id_factura_cuota is not null
    begin
        -- Factura cuota
        declare @id_cuota int;
        select @id_cuota = fc.id_cuota
        from socio.factura_cuota fc
        where fc.id = @id_factura_cuota;

        select @id_socio = c.id_socio,
               @responsable_pago = s.responsable_pago,
               @id_grupo_familiar = s.id_grupo_familiar,
               @id_tutor = s.id_tutor
        from socio.cuota c
        inner join socio.socio s on c.id_socio = s.id
        where c.id = @id_cuota;

        -- Determinar el responsable de pago
        if @responsable_pago = 1
        begin
            set @id_socio_responsable = @id_socio;
        end
        else
        begin
            if @id_grupo_familiar is not null
            begin
                set @id_socio_responsable = @id_grupo_familiar;
            end
            else if @id_tutor is not null
            begin
                set @id_socio_responsable = @id_tutor;
            end
            else
            begin
                raiserror('El socio no es responsable de pago y no tiene grupo familiar ni tutor asignado.', 16, 1);
                return;
            end
        end
    end
    else if @id_factura_extra is not null
    begin
        -- Factura extra
        declare @id_registro_pileta int;
        declare @id_actividad_extra int;

        select @id_registro_pileta = fe.id_registro_pileta,
               @id_actividad_extra = fe.id_actividad_extra
        from socio.factura_extra fe
        where fe.id = @id_factura_extra;

        if @id_registro_pileta is not null
        begin
            -- Factura por registro de pileta
            select @id_socio = rp.id_socio
            from socio.registro_pileta rp
            where rp.id = @id_registro_pileta;

            if @id_socio is null
            begin
                raiserror('No se encontró el socio asociado al registro de pileta.', 16, 1);
                return;
            end

            -- Obtener información del socio para determinar responsable de pago
            select @responsable_pago = s.responsable_pago,
                   @id_grupo_familiar = s.id_grupo_familiar,
                   @id_tutor = s.id_tutor
            from socio.socio s
            where s.id = @id_socio;

            -- Determinar el responsable de pago
            if @responsable_pago = 1
            begin
                set @id_socio_responsable = @id_socio;
            end
            else
            begin
                if @id_grupo_familiar is not null
                begin
                    set @id_socio_responsable = @id_grupo_familiar;
                end
                else if @id_tutor is not null
                begin
                    set @id_socio_responsable = @id_tutor;
                end
                else
                begin
                    raiserror('El socio no es responsable de pago y no tiene grupo familiar ni tutor asignado.', 16, 1);
                    return;
                end
            end
        end
        else if @id_actividad_extra is not null
        begin
            -- Factura por actividad extra - necesitaríamos el socio asociado
            raiserror('Para reembolsos de facturas de actividad extra, se requiere información adicional del socio.', 16, 1);
            return;
        end
    end

    -- Obtener el estado de cuenta del responsable de pago
    select @id_estado_cuenta = id 
    from socio.estado_cuenta 
    where id_socio = @id_socio_responsable;

    if @id_estado_cuenta is null
    begin
        raiserror('No existe un estado de cuenta para el responsable de pago (ID: %d).', 16, 1, @id_socio_responsable);
        return;
    end

    begin try
        begin transaction;

        -- Insertar el reembolso
        insert into socio.reembolso (
            id_pago, monto, fecha_reembolso, motivo, id_tipo_reembolso
        ) values (
            @id_pago, @monto, @fecha_reembolso, @motivo, @id_tipo_reembolso
        );
        set @id_reembolso = scope_identity();

        -- Insertar movimiento de cuenta (monto positivo porque es un reembolso)
        exec socio.altaMovimientoCuenta
            @id_estado_cuenta = @id_estado_cuenta,
            @monto = @monto,
            @id_reembolso = @id_reembolso;

        -- Actualizar el estado de cuenta del responsable de pago
        exec socio.modificacionEstadoCuenta
            @id_socio = @id_socio_responsable,
            @monto = @monto;

        commit transaction;
    end try
    begin catch
        rollback transaction;
        declare @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
        raiserror('Error al crear el reembolso: %s', 16, 1, @ErrorMessage);
        return;
    end catch
end
go


