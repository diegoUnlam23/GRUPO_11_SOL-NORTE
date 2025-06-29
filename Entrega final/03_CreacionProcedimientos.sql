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
    values (@nombre, @telefono_emergencia, @numero_socio);
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
create or alter procedure socio.bajaTutor
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
    @fecha_inscripcion date
as
begin
    if not exists (select 1 from socio.socio where id = @id_socio)
    begin
        raiserror('No existe un socio con ese ID.', 16, 1);
        return;
    end

    insert into inscripcion(id_socio, fecha_inscripcion)
    values (@id_socio, @fecha_inscripcion);
end
go
-- Update: no permitido en el sistema


-- Delete: no permitido en el sistema



---- Socio ----
-- Insert
create or alter procedure socio.altaSocio
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
as
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
            @id_socio_new,
            @fecha_actual;

        commit transaction;
    end try
    begin catch
        rollback transaction;
        declare @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
        print 'Error al agregar estado de cuenta: ' + @ErrorMessage;
        return;
    end catch 
end
go

-- Update
create or alter procedure socio.modificacionSocio
    @id int,
    @nombre varchar(100),
    @apellido varchar(100),
    @dni int,
    @email varchar(254),
    @fecha_nacimiento date,
    @telefono varchar(20),
    @telefono_emergencia varchar(20),
    @id_obra_social_socio int
    /*@id_tutor int,*/
    /*@id_grupo_familiar int,*/
    /*@estado varchar(20)*/
    /*@responsable_pago bit*/
as
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
        --parentesco = @parentesco,
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
go
-- Delete
create or alter procedure socio.actualizarEstadoSocio
    @id int,
    @estado varchar(20)
as
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
as
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
as
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
create or alter procedure socio.bajaDebitoAutomatico
    @id int
as
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
create or alter procedure socio.altaEmpleado
    @nombre varchar(100)
as
begin
    insert into general.empleado (nombre)
    values (@nombre);
end
go
-- Update
create or alter procedure socio.modificacionEmpleado
    @id int,
    @nombre varchar(100)
as
begin
    update general.empleado
    set nombre = @nombre
    where id = @id;
end
go

-- Delete
create or alter procedure socio.bajaEmpleado
    @id int
as
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
create or alter procedure socio.altaInvitado
    @nombre varchar(100),
    @apellido varchar(100),
    @dni int,
    @email varchar(254),
    @saldo_a_favor decimal(8,2) = 0
as
begin
    insert into socio.invitado (nombre, apellido, dni, email, saldo_a_favor)
    values (@nombre, @apellido, @dni, @email, @saldo_a_favor);
end
go

-- Update
create or alter procedure socio.modificacionInvitado
    @id int,
    @nombre varchar(100),
    @apellido varchar(100),
    @dni int,
    @email varchar(254),
    @saldo_a_favor decimal(8,2)
as
begin
    update socio.invitado
    set nombre = @nombre,
        apellido = @apellido,
        dni = @dni,
        email = @email,
        saldo_a_favor = @saldo_a_favor
    where id = @id;
end
go
-- Delete
create or alter procedure socio.bajaInvitado
    @id int
as
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
create or alter procedure socio.altaRegistroPileta
    @id_socio int,
    @id_invitado int,
    @fecha date,
    @id_tarifa int
as
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
    end try
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
as
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
    end try
    begin catch
        rollback transaction;
        return;
    end catch
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
as
begin
    insert into socio.tipo_reembolso (descripcion)
    values (@descripcion);
end
go

-- Update
create or alter procedure socio.modificacionTipoReembolso
    @id int,
    @descripcion varchar(50)
as
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
create or alter procedure socio.bajaTipoReembolso
    @id int
as
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
create or alter procedure general.altaClase
    @hora_inicio time,
    @hora_fin time,
    @dia varchar(10),
    @id_categoria int,
    @id_actividad int,
    @id_empleado int
as
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
create or alter procedure general.modificacionClase
    @id int,
    @hora_inicio time,
    @hora_fin time,
    @dia varchar(10),
    @id_categoria int,
    @id_actividad int,
    @id_empleado int
as
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
go
-- Delete
create or alter procedure general.bajaClase
    @id int
as
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
create or alter procedure general.altaPresentismo
    @id_socio int,
    @id_clase int,
    @fecha date
as
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
create or alter procedure general.modificacionPresentismo
    @id int,
    @id_socio int,
    @id_clase int,
    @fecha date
as
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
go

---- Inscripción Actividad ----
-- Insert
create or alter procedure socio.altaInscripcionActividad
    @id_cuota int,
    @id_actividad int,
    @activa bit = 1,
    @fecha_inscripcion date,
    @fecha_baja date = null
as
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
    select @precio_actividad = costo_mensual from general.actividad where id = @id_actividad;

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
        --declare @monto_total decimal(8,2);
        select @monto_total = monto_total from socio.cuota where id = @id_cuota;
        set @monto_total = @monto_total + @precio_actividad;

        -- Llamado al procedimiento para actualizar el monto total de la cuota
        exec socio.modificacionCuota @id_cuota, @monto_total;

        commit transaction;
    end try
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
create or alter procedure socio.bajaInscripcionActividad
    @id int
as
begin
    if not exists (select 1 from socio.inscripcion_actividad where id = @id)
    begin
        raiserror('No existe una inscripción a actividad con ese ID.', 16, 1);
        return;
    end

    declare @id_cuota int;
    select @id_cuota = id_cuota from socio.inscripcion_actividad where id = @id;

    declare @precio_actividad decimal(8,2);
    select @precio_actividad = costo_mensual from general.actividad where id = (select id_actividad from socio.inscripcion_actividad where id = @id);

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
    end try
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
create or alter procedure socio.altaCuota
    @id_socio int,
    @id_categoria int,
    @monto_total decimal(8,2) = 0
as
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
create or alter procedure socio.modificacionCuota
    @id int,
    @monto_total decimal(8,2)
as
begin
    if not exists (select 1 from socio.cuota where id = @id)
    begin
        raiserror('No existe una cuota con ese ID.', 16, 1);
        return;
    end

    update socio.cuota
    set --id_categoria = @id_categoria,
        monto_total = @monto_total
    where id = @id;
end
go

-- Delete: no permitido en el sistema


---- Cálculo de Descuentos ----
-- Procedimiento para calcular descuentos en facturación
create or alter procedure socio.calcularDescuentos
    @id_cuota int,
    @costo_categoria decimal(8,2),
    @total_actividades decimal(8,2),
    @descuento_familiar decimal(8,2) output,
    @descuento_actividades decimal(8,2) output,
    @total_con_descuentos decimal(8,2) output
as
begin
    declare @id_socio int;
    declare @id_grupo_familiar int;
    declare @cantidad_actividades int;
    declare @total_sin_descuentos decimal(8,2);
    
    -- Inicializar variables
    set @descuento_familiar = 0;
    set @descuento_actividades = 0;
    
    -- Obtener información del socio
    select @id_socio = c.id_socio,
           @id_grupo_familiar = s.id_grupo_familiar
    from socio.cuota c
    inner join socio.socio s on c.id_socio = s.id
    where c.id = @id_cuota;
    
    -- Calcular total sin descuentos
    set @total_sin_descuentos = @costo_categoria + @total_actividades;
    
    -- Verificar descuento familiar (15% en el total de la facturación de membresías)
    if @id_grupo_familiar is not null
    begin
        -- Verificar si hay otros miembros en el grupo familiar
        declare @cantidad_miembros_familia int;
        select @cantidad_miembros_familia = count(*)
        from socio.socio
        where id_grupo_familiar = @id_grupo_familiar
        or id = @id_grupo_familiar;
        
        if @cantidad_miembros_familia > 1
        begin
            set @descuento_familiar = @total_sin_descuentos * 0.15; -- 15% de descuento
        end
    end
    
    -- Verificar descuento por múltiples actividades (10% en el total de actividades deportivas)
    select @cantidad_actividades = count(*)
    from socio.inscripcion_actividad ia
    where ia.id_cuota = @id_cuota
    and ia.activa = 1;
    
    if @cantidad_actividades > 1
    begin
        set @descuento_actividades = @total_actividades * 0.10; -- 10% de descuento en actividades
    end
    
    -- Calcular total con descuentos
    set @total_con_descuentos = @total_sin_descuentos - @descuento_familiar - @descuento_actividades;
end
go

-- Procedimiento para consultar descuentos aplicados a una factura
create or alter procedure socio.consultarDescuentosFactura
    @id_factura_cuota int
as
begin
    if not exists (select 1 from socio.factura_cuota where id = @id_factura_cuota)
    begin
        raiserror('No existe una factura cuota con ese ID.', 16, 1);
        return;
    end

    -- Mostrar información de la factura
    select 
        fc.numero_comprobante,
        fc.fecha_emision,
        fc.importe_total as 'Total Factura',
        s.nombre + ' ' + s.apellido as 'Socio',
        c.nombre as 'Categoría'
    from socio.factura_cuota fc
    inner join socio.cuota cu on fc.id_cuota = cu.id
    inner join socio.socio s on cu.id_socio = s.id
    inner join socio.categoria c on cu.id_categoria = c.id
    where fc.id = @id_factura_cuota;

    -- Mostrar items de la factura con descuentos
    select 
        tipo_item,
        cantidad,
        precio_unitario,
        subtotal,
        importe_total,
        case 
            when tipo_item like '%Descuento%' then 'DESCUENTO'
            else 'ITEM'
        end as 'Tipo'
    from socio.item_factura_cuota
    where id_factura_cuota = @id_factura_cuota
    order by 
        case when tipo_item like '%Descuento%' then 2 else 1 end,
        tipo_item;

    -- Mostrar resumen de descuentos
    select 
        sum(case when tipo_item like '%Familiar%' then abs(importe_total) else 0 end) as 'Descuento Familiar',
        sum(case when tipo_item like '%Múltiples Actividades%' then abs(importe_total) else 0 end) as 'Descuento Actividades',
        sum(case when tipo_item like '%Descuento%' then abs(importe_total) else 0 end) as 'Total Descuentos'
    from socio.item_factura_cuota
    where id_factura_cuota = @id_factura_cuota
    and tipo_item like '%Descuento%';
end
go


---- Factura Cuota ----
-- Insert
create or alter procedure socio.altaFacturaCuota
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
as
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

    -- Calcular total de actividades
    declare @total_actividades decimal(8,2);
    select @total_actividades = isnull(sum(a.costo_mensual), 0)
    from socio.inscripcion_actividad ia
    inner join general.actividad a on ia.id_actividad = a.id
    where ia.id_cuota = @id_cuota
    and ia.activa = 1;

    -- Calcular descuentos
    declare @descuento_familiar decimal(8,2);
    declare @descuento_actividades decimal(8,2);
    declare @total_con_descuentos decimal(8,2);

    exec socio.calcularDescuentos
        @id_cuota = @id_cuota,
        @costo_categoria = @costo_categoria,
        @total_actividades = @total_actividades,
        @descuento_familiar = @descuento_familiar output,
        @descuento_actividades = @descuento_actividades output,
        @total_con_descuentos = @total_con_descuentos output;

    -- Si no se proporciona importe_total, usar el calculado con descuentos
    if @importe_total is null
        set @importe_total = @total_con_descuentos;

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

        -- Insertar los items de la factura cuota (categoría y actividades) con descuentos
        exec socio.altaItemFacturaCuota 
            @id_factura_cuota = @id_factura_cuota, 
            @descuento_familiar = @descuento_familiar, 
            @descuento_actividades = @descuento_actividades;

        -- Obtener el ID del estado de cuenta del responsable de pago
        select @id_estado_cuenta = id from socio.estado_cuenta where id_socio = @id_responsable_pago;

        if @id_estado_cuenta is null
        begin
            raiserror('No existe un estado de cuenta para el responsable de pago (ID: %d).', 16, 1, @id_responsable_pago);
            return;
        end

        declare @monto_negativo decimal(8,2) = @importe_total * -1;

        -- Insertar movimiento de cuenta (monto negativo porque es una factura)
        exec socio.altaMovimientoCuenta
            @id_estado_cuenta = @id_estado_cuenta,
            @monto = @monto_negativo,
            @id_factura = @id_factura_cuota;

        -- Actualizar el estado de cuenta del responsable de pago
        exec socio.modificacionEstadoCuenta
            @id_socio = @id_responsable_pago,
            @monto = @monto_negativo;

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
    @id_factura_cuota int,
    @descuento_familiar decimal(8,2) = 0,
    @descuento_actividades decimal(8,2) = 0
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
    declare @total_actividades decimal(8,2);
    declare @cantidad_actividades int;

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

    -- Obtener información de actividades
    select @total_actividades = isnull(sum(a.costo_mensual), 0),
           @cantidad_actividades = count(*)
    from socio.inscripcion_actividad ia
    inner join general.actividad a on ia.id_actividad = a.id
    where ia.id_cuota = @id_cuota
    and ia.activa = 1;

    begin try
        begin transaction;

        -- Calcular descuento aplicado a la categoría (proporcional al descuento familiar)
        declare @descuento_categoria decimal(8,2) = 0;
        if @descuento_familiar > 0
        begin
            declare @total_sin_descuentos decimal(8,2) = @costo_categoria + @total_actividades;
            if @total_sin_descuentos > 0
                set @descuento_categoria = (@costo_categoria / @total_sin_descuentos) * @descuento_familiar;
        end

        -- Insertar item de la categoría con descuento familiar aplicado
        insert into socio.item_factura_cuota (
            id_factura_cuota, cantidad, precio_unitario, alicuota_iva, tipo_item, subtotal, importe_total
        ) values (
            @id_factura_cuota, 1, @costo_categoria, 21, 'Categoría - ' + @nombre_categoria, 
            @costo_categoria, @costo_categoria - @descuento_categoria
        );

        -- Insertar items de todas las actividades asociadas a la cuota con descuentos aplicados
        if @cantidad_actividades > 0
        begin
            -- Calcular descuento por actividad (proporcional al descuento de actividades)
            declare @descuento_por_actividad decimal(8,2) = 0;
            if @descuento_actividades > 0 and @total_actividades > 0
                set @descuento_por_actividad = @descuento_actividades / @cantidad_actividades;

            -- Calcular descuento familiar por actividad (proporcional)
            declare @descuento_familiar_por_actividad decimal(8,2) = 0;
            if @descuento_familiar > 0
            begin
                declare @total_sin_descuentos_act decimal(8,2) = @costo_categoria + @total_actividades;
                if @total_sin_descuentos_act > 0
                    set @descuento_familiar_por_actividad = (@total_actividades / @total_sin_descuentos_act) * @descuento_familiar / @cantidad_actividades;
            end

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
                a.costo_mensual - @descuento_por_actividad - @descuento_familiar_por_actividad
            from socio.inscripcion_actividad ia
            inner join general.actividad a on ia.id_actividad = a.id
            where ia.id_cuota = @id_cuota
            and ia.activa = 1;
        end

        -- Insertar items de descuentos si existen
        if @descuento_familiar > 0
        begin
            insert into socio.item_factura_cuota (
                id_factura_cuota, cantidad, precio_unitario, alicuota_iva, tipo_item, subtotal, importe_total
            ) values (
                @id_factura_cuota, 1, -@descuento_familiar, 21, 'Descuento Familiar (15%)', 
                -@descuento_familiar, -@descuento_familiar
            );
        end

        if @descuento_actividades > 0
        begin
            insert into socio.item_factura_cuota (
                id_factura_cuota, cantidad, precio_unitario, alicuota_iva, tipo_item, subtotal, importe_total
            ) values (
                @id_factura_cuota, 1, -@descuento_actividades, 21, 'Descuento Múltiples Actividades (10%)', 
                -@descuento_actividades, -@descuento_actividades
            );
        end

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
	declare @message varchar(50);

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
        --declare @id_socio int;
        --declare @responsable_pago bit;
        --declare @id_grupo_familiar int;
        --declare @id_tutor int;

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
	set @message = N' El monto del pago '+ CAST(@monto AS NVARCHAR(20)) + ' debe coincidir con el importe de la factura '+ CAST(@importe_factura AS NVARCHAR(20)) +' ';
    if @monto != @importe_factura
    begin
        raiserror(@message, 16, 1);
        return;
    end

    -- Obtener el estado de cuenta del responsable de pago
    select @id_estado_cuenta = id 
    from socio.estado_cuenta 
    where id_socio = @id_socio_responsable;

	set @message = N'No existe un estado de cuenta para el responsable de pago (ID: .'+ @id_socio_responsable +' )';
    if @id_estado_cuenta is null
    begin
        raiserror('No existe un estado de cuenta para el responsable de pago (ID: %d).', 16, 1);
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
	declare @message varchar(50);
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

	set @message = N'El monto del reembolso ('+ CAST(@monto AS VARCHAR(20)) +') no puede exceder el monto del pago ('+ CAST(@monto_pago AS VARCHAR(20))+ ').'
    if @monto > @monto_pago
    begin
        raiserror(@message, 16, 1);
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

-- Procedimiento de ejemplo para demostrar el uso de descuentos
-- Este procedimiento muestra cómo crear una factura con descuentos automáticos
create or alter procedure socio.ejemploFacturaConDescuentos
    @id_cuota int
as
begin
    declare @id_factura_cuota int;
    declare @costo_categoria decimal(8,2);
    declare @total_actividades decimal(8,2);
    declare @descuento_familiar decimal(8,2);
    declare @descuento_actividades decimal(8,2);
    declare @total_con_descuentos decimal(8,2);

    -- Obtener información de la cuota
    select @costo_categoria = c.costo_mensual
    from socio.cuota cu
    inner join socio.categoria c on cu.id_categoria = c.id
    where cu.id = @id_cuota;

    -- Obtener total de actividades
    select @total_actividades = isnull(sum(a.costo_mensual), 0)
    from socio.inscripcion_actividad ia
    inner join general.actividad a on ia.id_actividad = a.id
    where ia.id_cuota = @id_cuota
    and ia.activa = 1;

    -- Calcular descuentos
    exec socio.calcularDescuentos
        @id_cuota = @id_cuota,
        @costo_categoria = @costo_categoria,
        @total_actividades = @total_actividades,
        @descuento_familiar = @descuento_familiar output,
        @descuento_actividades = @descuento_actividades output,
        @total_con_descuentos = @total_con_descuentos output;

    -- Mostrar información de descuentos calculados
    print '=== RESUMEN DE DESCUENTOS ===';
    print 'Costo Categoría: $' + cast(@costo_categoria as varchar(10));
    print 'Total Actividades: $' + cast(@total_actividades as varchar(10));
    print 'Subtotal: $' + cast(@costo_categoria + @total_actividades as varchar(10));
    print 'Descuento Familiar (15%): $' + cast(@descuento_familiar as varchar(10));
    print 'Descuento Múltiples Actividades (10%): $' + cast(@descuento_actividades as varchar(10));
    print 'Total con Descuentos: $' + cast(@total_con_descuentos as varchar(10));
    print '============================';

    -- Crear la factura
    exec socio.altaFacturaCuota
        @id_cuota = @id_cuota,
        @importe_total = @total_con_descuentos;

    -- Obtener el ID de la factura creada
    select @id_factura_cuota = max(id) from socio.factura_cuota where id_cuota = @id_cuota;

    -- Mostrar detalles de la factura
    print 'Factura creada con ID: ' + cast(@id_factura_cuota as varchar(10));
    
    -- Consultar descuentos aplicados
    exec socio.consultarDescuentosFactura @id_factura_cuota;
end
go


---- Sistema de Reintegro por Lluvia ----
-- Procedimiento para procesar reintegros por lluvia usando el sistema de reembolsos
create or alter procedure socio.procesarReintegroLluvia
    @fecha_lluvia date,
    @porcentaje_reintegro decimal(5,2) = 60.00
as
begin
    -- Validar que la fecha no sea futura
    if @fecha_lluvia > getdate()
    begin
        raiserror('No se puede procesar reintegros para una fecha futura.', 16, 1);
        return;
    end

    -- Validar que el porcentaje esté entre 0 y 100
    if @porcentaje_reintegro < 0 or @porcentaje_reintegro > 100
    begin
        raiserror('El porcentaje de reintegro debe estar entre 0 y 100.', 16, 1);
        return;
    end

    -- Obtener el tipo de reembolso "Pago a cuenta"
    declare @id_tipo_reembolso int;
    select @id_tipo_reembolso = id from socio.tipo_reembolso where descripcion = 'Pago a cuenta';
    
    if @id_tipo_reembolso is null
    begin
        raiserror('No existe el tipo de reembolso "Pago a cuenta".', 16, 1);
        return;
    end

    declare @cantidad_procesados int = 0;
    declare @total_procesado decimal(10,2) = 0;
    declare @cantidad_socios int = 0;
    declare @cantidad_invitados int = 0;

    begin try
        begin transaction;

        -- Crear tabla temporal para procesar registros
        create table #registros_procesar (
            id int identity(1,1),
            id_registro_pileta int,
            id_socio int,
            id_invitado int,
            id_tarifa int,
            precio_tarifa decimal(8,2),
            monto_reintegro decimal(8,2),
            id_responsable_pago int,
            tipo_usuario varchar(10),
            id_factura_extra int
        );

        -- Llenar tabla temporal con todos los registros a procesar
        insert into #registros_procesar (id_registro_pileta, id_socio, id_invitado, id_tarifa, precio_tarifa, monto_reintegro, id_responsable_pago, tipo_usuario, id_factura_extra)
        select 
            rp.id,
            rp.id_socio,
            rp.id_invitado,
            rp.id_tarifa,
            tp.precio,
            tp.precio * (@porcentaje_reintegro / 100.00),
            case 
                when rp.id_socio is not null then
                    case 
                        when s.responsable_pago = 1 then rp.id_socio
                        when s.id_grupo_familiar is not null then s.id_grupo_familiar
                        when s.id_tutor is not null then s.id_tutor
                        else rp.id_socio
                    end
                else null
            end,
            case when rp.id_socio is not null then 'SOCIO' else 'INVITADO' end,
            fe.id
        from socio.registro_pileta rp
        inner join socio.tarifa_pileta tp on rp.id_tarifa = tp.id
        inner join socio.factura_extra fe on fe.id_registro_pileta = rp.id
        left join socio.socio s on rp.id_socio = s.id
        where rp.fecha = @fecha_lluvia;

        -- Variables para el WHILE
        declare @contador int = 1;
        declare @max_id int;
        declare @id_registro_pileta int;
        declare @id_socio int;
        declare @id_invitado int;
        declare @id_tarifa int;
        declare @precio_tarifa decimal(8,2);
        declare @monto_reintegro decimal(8,2);
        declare @id_responsable_pago int;
        declare @tipo_usuario varchar(10);
        declare @id_factura_extra int;
        declare @id_pago int;
        declare @id_reembolso int;
        declare @id_estado_cuenta int;

        -- Obtener el máximo ID para el WHILE
        select @max_id = max(id) from #registros_procesar;

        -- Procesar cada registro con WHILE
        while @contador <= @max_id
        begin
            -- Obtener datos del registro actual
            select 
                @id_registro_pileta = id_registro_pileta,
                @id_socio = id_socio,
                @id_invitado = id_invitado,
                @id_tarifa = id_tarifa,
                @precio_tarifa = precio_tarifa,
                @monto_reintegro = monto_reintegro,
                @id_responsable_pago = id_responsable_pago,
                @tipo_usuario = tipo_usuario,
                @id_factura_extra = id_factura_extra
            from #registros_procesar
            where id = @contador;

            if @tipo_usuario = 'SOCIO'
            begin
                -- Procesar socio
                -- Obtener el ID del pago existente
                select @id_pago = id from socio.pago 
                where id_factura_extra = @id_factura_extra;

                -- Validar que el pago existe
                if @id_pago is null
                begin
                    raiserror('No se encontró el pago para la factura extra', 16, 1);
                    return;
                end

                -- Crear reembolso
                exec socio.altaReembolso
                    @id_pago = @id_pago,
                    @monto = @monto_reintegro,
                    @fecha_reembolso = @fecha_lluvia,
                    @motivo = 'Reintegro por lluvia',
                    @id_tipo_reembolso = @id_tipo_reembolso;

                set @cantidad_socios = @cantidad_socios + 1;
            end
            else if @tipo_usuario = 'INVITADO'
            begin
                -- Procesar invitado
                update socio.invitado
                set saldo_a_favor = saldo_a_favor + @monto_reintegro
                where id = @id_invitado;

                set @cantidad_invitados = @cantidad_invitados + 1;
            end

            set @total_procesado = @total_procesado + @monto_reintegro;
            set @cantidad_procesados = @cantidad_procesados + 1;
            set @contador = @contador + 1;
        end

        -- Limpiar tabla temporal
        drop table #registros_procesar;

        commit transaction;

        -- Mostrar resumen del proceso
        print '=== REINTEGRO POR LLUVIA PROCESADO ===';
        print 'Fecha de lluvia: ' + cast(@fecha_lluvia as varchar(10));
        print 'Porcentaje de reintegro: ' + cast(@porcentaje_reintegro as varchar(10)) + '%';
        print 'Cantidad total de registros procesados: ' + cast(@cantidad_procesados as varchar(10));
        print '  - Socios procesados: ' + cast(@cantidad_socios as varchar(10)) + ' (reembolsos)';
        print '  - Invitados procesados: ' + cast(@cantidad_invitados as varchar(10)) + ' (saldo a favor)';
        print 'Total reintegrado: $' + cast(@total_procesado as varchar(15));
        print '=====================================';

    end try
    begin catch
        if object_id('tempdb..#registros_procesar') is not null
            drop table #registros_procesar;

        rollback transaction;
        declare @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
        raiserror('Error al procesar reintegro por lluvia: %s', 16, 1, @ErrorMessage);
        return;
    end catch
end
go


-- Procedimiento para consultar saldo a favor de un invitado específico
create or alter procedure socio.consultarSaldoInvitado
    @id_invitado int = null,
    @dni_invitado int = null
as
begin
    declare @id int;
    
    -- Determinar el ID del invitado
    if @id_invitado is not null
    begin
        set @id = @id_invitado;
    end
    else if @dni_invitado is not null
    begin
        select @id = id from socio.invitado where dni = @dni_invitado;
        if @id is null
        begin
            raiserror('No se encontró un invitado con el DNI especificado.', 16, 1);
            return;
        end
    end
    else
    begin
        raiserror('Debe proporcionar un ID de invitado o DNI.', 16, 1);
        return;
    end

    -- Mostrar información del invitado
    select 
        i.nombre + ' ' + i.apellido as 'Invitado',
        i.dni,
        i.email,
        i.saldo_a_favor as 'Saldo a Favor'
    from socio.invitado i
    where i.id = @id;

    -- Mostrar historial de uso de pileta
    print '';
    print '=== HISTORIAL DE USO DE PILETA ===';
    select 
        rp.fecha,
        tp.tipo as 'Tipo Tarifa',
        tp.precio as 'Precio Pagado',
        case 
            when rp.fecha <= getdate() then 'Completado'
            else 'Programado'
        end as 'Estado'
    from socio.registro_pileta rp
    inner join socio.tarifa_pileta tp on rp.id_tarifa = tp.id
    where rp.id_invitado = @id
    order by rp.fecha desc;

    -- Mostrar resumen de uso
    declare @total_uso decimal(8,2);
    declare @cantidad_visitas int;
    
    select @total_uso = isnull(sum(tp.precio), 0),
           @cantidad_visitas = count(*)
    from socio.registro_pileta rp
    inner join socio.tarifa_pileta tp on rp.id_tarifa = tp.id
    where rp.id_invitado = @id;

    print '';
    print '=== RESUMEN ===';
    print 'Total gastado en pileta: $' + cast(@total_uso as varchar(10));
    print 'Cantidad de visitas: ' + cast(@cantidad_visitas as varchar(10));
    
    declare @saldo_actual decimal(8,2);
    select @saldo_actual = saldo_a_favor from socio.invitado where id = @id;
    print 'Saldo a favor actual: $' + cast(@saldo_actual as varchar(10));
    
    if @saldo_actual > 0
    begin
        print 'El invitado tiene crédito disponible para futuras visitas.';
    end
end
go


