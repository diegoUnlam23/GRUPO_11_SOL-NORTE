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

            exec socio.insertarEstadoCuenta
                @id_socio = @rp,
                @saldo = 0;
        end
        else
        begin
            exec socio.insertarEstadoCuenta
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
    @id_socio int,
    @medio_de_pago varchar(50),
    @activo bit,
    @token_pago varchar(200),
    @ultimos_4_digitos int,
    @titular varchar(100)
begin
    if not exists (select 1 from socio.socio where id = @id_socio)
    begin
        raiserror('No existe un socio con ese ID.', 16, 1);
        return;
    end

    insert into socio.debito_automatico (id_socio, medio_de_pago, activo, token_pago, ultimos_4_digitos, titular)
    values (@id_socio, @medio_de_pago, @activo, @token_pago, @ultimos_4_digitos, @titular);
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

    declare @fecha_emision date = getdate();
    declare @fecha_vencimiento_1 date = dateadd(day, 30, @fecha_emision);
    declare @fecha_vencimiento_2 date = dateadd(day, 40, @fecha_emision);
    declare @periodo_facturado int = year(@fecha_emision) * 100 + month(@fecha_emision); -- AAAAMM
    declare @iva varchar(50) = '21%';
    declare @tipo_comprobante varchar(2) = 'B';
    declare @descripcion varchar(100);
    declare @importe_total decimal(8,2);
    declare @id_tarifa int;
    declare @precio_tarifa decimal(8,2);
    declare @numero_comprobante int;
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

        set @importe_total = @precio_tarifa;
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

        set @importe_total = @precio_tarifa;
        set @descripcion = 'Factura por actividad extra';
        set @tipo_item = 'Actividad Extra';
    end

    -- Generar número de comprobante (máximo + 1)
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


