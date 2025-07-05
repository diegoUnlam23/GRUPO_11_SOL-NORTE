/*
    Consigna: Implementar los SP necesarios para cumplir con la lógica del sistema
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

---- Obra Social Socio ----
-- Insert
create or alter procedure socio.altaObraSocialSocio
    @nombre varchar(50),
    @telefono_emergencia varchar(50),
    @numero_socio varchar(50)
as
begin
    SET NOCOUNT ON;
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
    SET NOCOUNT ON;
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
    SET NOCOUNT ON;
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
    SET NOCOUNT ON;
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
    SET NOCOUNT ON;
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
    SET NOCOUNT ON;
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
    SET NOCOUNT ON;
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
	@nro_socio varchar(50) = null,
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
    SET NOCOUNT ON;
    if @dni <= 0
    begin
        raiserror('El DNI debe ser mayor a 0.', 16, 1);
        return;
    end

    if @email not like '%@%._%'
    begin
        raiserror('El email no tiene un formato válido.', 16, 1);
        return;
    end

    -- Generar nro_socio automáticamente si no se envía por parámetro
    if @nro_socio is null or LTRIM(RTRIM(@nro_socio)) = ''
    begin
        declare @ultimo_nro int;
        select @ultimo_nro = MAX(CAST(SUBSTRING(nro_socio, 4, LEN(nro_socio)) AS INT))
        from socio.socio
        where nro_socio like 'SN-%';
        set @nro_socio = 'SN-' + cast(isnull(@ultimo_nro, 4000) + 1 as varchar);
    end

    begin try
        begin transaction;

        insert into socio.socio (nro_socio, nombre, apellido, dni, email, fecha_nacimiento, telefono, telefono_emergencia, id_obra_social_socio, id_tutor, id_grupo_familiar, estado, responsable_pago)
        values (@nro_socio, @nombre, @apellido, @dni, @email, @fecha_nacimiento, @telefono, @telefono_emergencia, @id_obra_social_socio, @id_tutor, @id_grupo_familiar, @estado, @responsable_pago);

        declare @id_socio_new int = scope_identity();

        declare @edad int;
        declare @fecha_actual date;
        set @edad = datediff(YEAR, @fecha_nacimiento, getdate());
        set @fecha_actual = getdate();

        -- Ajuste si no cumplió aún este año
        if dateadd(year, @edad, @fecha_nacimiento) > cast(@fecha_actual as date)
            set @edad = @edad - 1;

        -- Determinar el responsable de pago para el estado de cuenta
        declare @id_responsable_pago int;
        
        if @edad < 18
        begin
            -- Para menores, el responsable de pago puede ser tutor o grupo familiar
            set @id_responsable_pago = isnull(@id_tutor, @id_grupo_familiar);
        end
        else
        begin
            -- Para mayores, el responsable de pago es el propio socio si es responsable
            if @responsable_pago = 1
                set @id_responsable_pago = @id_socio_new;
            else
                set @id_responsable_pago = isnull(@id_tutor, @id_grupo_familiar);
        end

        -- Solo crear estado de cuenta si no existe uno para el responsable de pago
        if @edad < 18 and @id_tutor is not null
        begin
            if not exists (select 1 from socio.estado_cuenta where id_tutor = @id_tutor)
            begin
                exec socio.altaEstadoCuenta @id_tutor = @id_tutor, @saldo = 0;
            end
        end
        else if @id_responsable_pago is not null
        begin
            if not exists (select 1 from socio.estado_cuenta where id_socio = @id_responsable_pago)
            begin
                exec socio.altaEstadoCuenta @id_socio = @id_responsable_pago, @saldo = 0;
            end
        end

        exec socio.altaInscripcion
            @id_socio_new,
            @fecha_actual;

        commit transaction;
    end try
    begin catch
        rollback transaction;
        declare @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
        print 'Error al agregar socio: ' + @ErrorMessage;
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
    SET NOCOUNT ON;
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
    SET NOCOUNT ON;
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
    SET NOCOUNT ON;
    if not exists (select 1 from socio.socio where id = @id_responsable_pago)
    begin
        raiserror('No existe un socio responsable de pago con ese ID.', 16, 1);
        return;
    end

    -- Validar medio de pago permitido
    if @medio_de_pago not in ('Visa', 'MasterCard', 'Tarjeta Naranja', 'Pago Fácil', 'Rapipago', 'Transferencia Mercado Pago')
    begin
        raiserror('El medio de pago no es válido. Debe ser: Visa, MasterCard, Tarjeta Naranja, Pago Fácil, Rapipago, Transferencia Mercado Pago o Débito automático.', 16, 1);
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
    SET NOCOUNT ON;
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
    SET NOCOUNT ON;
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
create or alter procedure general.altaEmpleado
    @nombre varchar(100)
as
begin
    SET NOCOUNT ON;
    insert into general.empleado (nombre)
    values (@nombre);
end
go
-- Update
create or alter procedure general.modificacionEmpleado
    @id int,
    @nombre varchar(100)
as
begin
    SET NOCOUNT ON;
    update general.empleado
    set nombre = @nombre
    where id = @id;
end
go

-- Delete
create or alter procedure general.bajaEmpleado
    @id int
as
begin
    SET NOCOUNT ON;
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
    SET NOCOUNT ON;
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
    SET NOCOUNT ON;
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
    SET NOCOUNT ON;
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
    SET NOCOUNT ON;
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
create or alter procedure general.altaActividadExtra
    @id_socio int,
    @nombre varchar(50),
    @costo decimal(8,2)
as
begin
    SET NOCOUNT ON;
    if not exists (select 1 from socio.socio where id = @id_socio)
    begin
        raiserror('No existe un socio con ese ID.', 16, 1);
        return;
    end

    begin try
        begin transaction;

        insert into general.actividad_extra (id_socio, nombre, costo)
        values (@id_socio, @nombre, @costo);

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
    @id_registro_pileta int = null,
    @id_actividad_extra int = null
as
begin
    SET NOCOUNT ON;
    -- Validar que al menos uno de los parámetros no sea null
    if @id_registro_pileta is null and @id_actividad_extra is null
    begin
        raiserror('Debe proporcionar al menos un id_registro_pileta o id_actividad_extra.', 16, 1);
        return;
    end

    -- Generar valores automáticamente
    declare @numero_comprobante int;
    declare @tipo_comprobante varchar(2) = 'B';
    declare @fecha_emision date = getdate();
    declare @periodo_facturado int = year(@fecha_emision) * 100 + month(@fecha_emision);
    declare @iva varchar(50) = '21%';
    declare @fecha_vencimiento_1 date = dateadd(day, 30, @fecha_emision);
    declare @fecha_vencimiento_2 date = dateadd(day, 40, @fecha_emision);
    declare @descripcion varchar(100);
    declare @importe_total decimal(8,2);

    -- Generar número de comprobante automáticamente
    select @numero_comprobante = isnull(max(numero_comprobante), 0) + 1 from socio.factura_extra;

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
        declare @nombre_actividad_extra varchar(50);
        select @precio_tarifa = costo, @nombre_actividad_extra = nombre 
        from general.actividad_extra where id = @id_actividad_extra;
        
        if @precio_tarifa is null
        begin
            raiserror('No se encontró el costo de la actividad extra.', 16, 1);
            return;
        end

        set @importe_total = @precio_tarifa;
        set @descripcion = 'Factura por actividad extra';
        set @tipo_item = @nombre_actividad_extra;
    end

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
    SET NOCOUNT ON;
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
    SET NOCOUNT ON;
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
    SET NOCOUNT ON;
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
    SET NOCOUNT ON;
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
    SET NOCOUNT ON;
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
    SET NOCOUNT ON;
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
    @fecha date,
    @tipo_asistencia varchar(1)
as
begin
    SET NOCOUNT ON;
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

    -- Verificamos que la categoría del socio sea la misma que la categoría de la clase
    declare @fecha_actual date = getdate();
    declare @fecha_nacimiento_socio date;
    select @fecha_nacimiento_socio = fecha_nacimiento
    from socio.socio
    where id = @id_socio;

    declare @edad_socio int;
    set @edad_socio = datediff(YEAR, @fecha_nacimiento_socio, @fecha_actual);
    if dateadd(year, @edad_socio, @fecha_nacimiento_socio) > cast(@fecha_actual as date)
        set @edad_socio = @edad_socio - 1;

    -- Buscamos la categoria del socio
    declare @id_categoria_socio int;
    select @id_categoria_socio = id_categoria
    from socio.socio
    where id = @id_socio;

    -- Buscamos la categoria de la clase
    declare @id_categoria_clase int;
    select @id_categoria_clase = id_categoria
    from general.clase
    where id = @id_clase;

    -- Verificamos que el socio tenga la misma categoría que la clase
    if @id_categoria_socio <> @id_categoria_clase
    begin
        raiserror('El socio no tiene la misma categoría que la clase.', 16, 1);
        return;
    end

    insert into general.presentismo (id_socio, id_clase, fecha, tipo_asistencia)
    values (@id_socio, @id_clase, @fecha, @tipo_asistencia);
end
go

-- Update
create or alter procedure general.modificacionPresentismo
    @id int,
    @id_socio int,
    @id_clase int,
    @fecha date,
    @tipo_asistencia varchar(1)
as
begin
    SET NOCOUNT ON;
    if not exists (select 1 from general.presentismo where id = @id)
    begin
        raiserror('No existe un presentismo con ese ID.', 16, 1);
        return;
    end

    update general.presentismo
    set id_socio = @id_socio,
        id_clase = @id_clase,
        fecha = @fecha,
        tipo_asistencia = @tipo_asistencia
    where id = @id;
end
go

---- Inscripción Actividad ----
-- Insert
create or alter procedure socio.altaInscripcionActividad
    @id_cuota int,
    @id_actividad int
as
begin
    SET NOCOUNT ON;
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

        insert into socio.inscripcion_actividad (id_cuota, id_actividad)
        values (@id_cuota, @id_actividad);

        -- Actualizar el monto total de la cuota sumandole el precio de la actividad
        --declare @monto_total decimal(8,2);
        select @monto_total = monto_total from socio.cuota where id = @id_cuota;
        set @monto_total = @monto_total + @precio_actividad;

        -- Llamado al procedimiento para actualizar el monto total de la cuota
        exec socio.modificacionMontoCuota @id_cuota, @monto_total;

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
    @id_cuota int,
    @id_actividad int
as
begin
    SET NOCOUNT ON;
    -- Verificamos que la cuota exista
    if not exists (select 1 from socio.cuota where id = @id_cuota)
    begin
        raiserror('No existe una cuota con ese ID.', 16, 1);
        return;
    end

    -- Verificamos que la actividad exista
    if not exists (select 1 from general.actividad where id = @id_actividad)
    begin
        raiserror('No existe una actividad con ese ID.', 16, 1);
        return;
    end

    -- Verificamos que la inscripción a actividad exista
    if not exists (select 1 from socio.inscripcion_actividad where id_cuota = @id_cuota and id_actividad = @id_actividad)
    begin
        raiserror('No existe una inscripción a actividad con ese ID.', 16, 1);
        return;
    end

    declare @precio_actividad decimal(8,2);
    select @precio_actividad = costo_mensual from general.actividad where id = @id_actividad;

    if @precio_actividad is null
    begin
        raiserror('No se encontró el precio de la actividad.', 16, 1);
        return;
    end

    begin try
        begin transaction;

        delete from socio.inscripcion_actividad
        where id_cuota = @id_cuota and id_actividad = @id_actividad;

        -- Actualizar el monto total de la cuota restandole el precio de la actividad
        declare @monto_total decimal(8,2);
        select @monto_total = monto_total from socio.cuota where id = @id_cuota;
        set @monto_total = @monto_total - @precio_actividad;

        -- Llamado al procedimiento para actualizar el monto total de la cuota
        exec socio.modificacionMontoCuota @id_cuota, @monto_total;

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
    @mes int,
    @anio int,
    @monto_total decimal(8,2) = 0
as
begin
    SET NOCOUNT ON;
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

    if exists (select 1 from socio.cuota where id_socio = @id_socio and mes = @mes and anio = @anio)
    begin
        raiserror('Ya existe una cuota para ese socio en ese mes y año.', 16, 1);
        return;
    end

    insert into socio.cuota (id_socio, id_categoria, mes, anio, monto_total)
    values (@id_socio, @id_categoria, @mes, @anio, @monto_total);
end
go

-- Update
create or alter procedure socio.modificacionMontoCuota
    @id int,
    @monto_total decimal(8,2)
as
begin
    SET NOCOUNT ON;
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
    SET NOCOUNT ON;
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
    where ia.id_cuota = @id_cuota;
    
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
    @id_cuota int,
    @fecha_emision date
as
begin
    -- Validamos que el socio esté activo
    if not exists (select 1 from socio.socio where id = (select id_socio from socio.cuota where id = @id_cuota) and estado = 'Activo')
    begin
        raiserror('El socio no está activo.', 16, 1);
        return;
    end

    -- Validar que exista la cuota y que el periodo coincida con la fecha enviada
    declare @anio_param int = year(@fecha_emision);
    declare @mes_param int = month(@fecha_emision);
    declare @anio_cuota int;
    declare @mes_cuota int;
    select @anio_cuota = anio, @mes_cuota = mes from socio.cuota where id = @id_cuota;
    if @anio_cuota is null or @mes_cuota is null
    begin
        raiserror('No existe una cuota con ese ID.', 16, 1);
        return;
    end
    if @anio_cuota <> @anio_param or @mes_cuota <> @mes_param
    begin
        raiserror('La cuota asociada no corresponde al periodo de la fecha de emisión enviada.', 16, 1);
        return;
    end

    -- Generar valores automáticamente
    declare @numero_comprobante int;
    declare @tipo_comprobante varchar(2) = 'B';
    declare @periodo_facturado int = @anio_param * 100 + @mes_param;
    declare @iva varchar(50) = '21%';
    declare @fecha_vencimiento_1 date = dateadd(day, 30, @fecha_emision);
    declare @fecha_vencimiento_2 date = dateadd(day, 40, @fecha_emision);
    declare @descripcion varchar(100) = 'Factura por cuota mensual';

    -- Generar número de comprobante automáticamente
    select @numero_comprobante = isnull(max(numero_comprobante), 0) + 1 from socio.factura_cuota;

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
    declare @es_tutor bit = 0;
    if @responsable_pago = 1
    begin
        -- El socio es responsable de pago
        set @id_responsable_pago = @id_socio;
        set @es_tutor = 0;
    end
    else
    begin
        -- El socio no es responsable de pago, buscar en grupo familiar o tutor
        if @id_grupo_familiar is not null
        begin
            set @id_responsable_pago = @id_grupo_familiar;
            set @es_tutor = 0;
        end
        else if @id_tutor is not null
        begin
            set @id_responsable_pago = @id_tutor;
            set @es_tutor = 1;
        end
        else
        begin
            raiserror('El socio no es responsable de pago y no tiene grupo familiar ni tutor asignado.', 16, 1);
            return;
        end
    end

    -- Obtener el ID del estado de cuenta del responsable de pago
    if @es_tutor = 1
        select @id_estado_cuenta = id from socio.estado_cuenta where id_tutor = @id_responsable_pago;
    else
        select @id_estado_cuenta = id from socio.estado_cuenta where id_socio = @id_responsable_pago;

    if @id_estado_cuenta is null
    begin
        raiserror('No existe un estado de cuenta para el responsable de pago.', 16, 1);
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

    -- Calcular total de actividades
    declare @total_actividades decimal(8,2);
    select @total_actividades = isnull(sum(a.costo_mensual), 0)
    from socio.inscripcion_actividad ia
    inner join general.actividad a on ia.id_actividad = a.id
    where ia.id_cuota = @id_cuota;

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

    declare @importe_total decimal(8,2) = @total_con_descuentos;

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

        declare @monto_negativo decimal(8,2) = @importe_total * -1;

        -- Insertar movimiento de cuenta (monto negativo porque es una factura)
        exec socio.altaMovimientoCuenta
            @id_estado_cuenta = @id_estado_cuenta,
            @monto = @monto_negativo,
            @id_factura = @id_factura_cuota;

        -- Actualizar el estado de cuenta del responsable de pago
        if @es_tutor = 1
            exec socio.modificacionEstadoCuenta @id_tutor = @id_responsable_pago, @monto = @monto_negativo;
        else
            exec socio.modificacionEstadoCuenta @id_socio = @id_responsable_pago, @monto = @monto_negativo;

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
    where ia.id_cuota = @id_cuota;

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
                a.costo_mensual - @descuento_familiar_por_actividad
            from socio.inscripcion_actividad ia
            inner join general.actividad a on ia.id_actividad = a.id
            where ia.id_cuota = @id_cuota;
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
    @id_socio int = null,
    @id_tutor int = null,
    @saldo decimal(8,2) = 0
as
begin
    -- Validar que se proporcione al menos uno de los dos parámetros
    if @id_socio is null and @id_tutor is null
    begin
        raiserror('Debe proporcionar al menos un id_socio o id_tutor.', 16, 1);
        return;
    end

    -- Validar que no se proporcionen ambos parámetros
    if @id_socio is not null and @id_tutor is not null
    begin
        raiserror('Solo puede proporcionar un tipo de responsable (socio o tutor), no ambos.', 16, 1);
        return;
    end

    -- Validar que no exista ya un estado de cuenta para ese socio/tutor
    if @id_socio is not null
    begin
        -- Validar que existe el socio
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
    end
    else if @id_tutor is not null
    begin
        -- Validar que existe el tutor
        if not exists (select 1 from socio.tutor where id = @id_tutor)
        begin
            raiserror('No existe un tutor con ese ID.', 16, 1);
            return;
        end

        if exists (select 1 from socio.estado_cuenta where id_tutor = @id_tutor)
        begin
            raiserror('Ya existe un estado de cuenta para este tutor.', 16, 1);
            return;
        end
    end

    -- Crear el nuevo estado de cuenta
    insert into socio.estado_cuenta (id_socio, id_tutor, saldo)
    values (@id_socio, @id_tutor, @saldo);
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
    @id_socio int = null,
    @id_tutor int = null,
    @monto decimal(8,2)
as
begin
    -- Validar que se proporcione al menos uno de los dos parámetros
    if @id_socio is null and @id_tutor is null
    begin
        raiserror('Debe proporcionar al menos un id_socio o id_tutor.', 16, 1);
        return;
    end

    -- Validar que no se proporcionen ambos parámetros
    if @id_socio is not null and @id_tutor is not null
    begin
        raiserror('Solo puede proporcionar un tipo de responsable (socio o tutor), no ambos.', 16, 1);
        return;
    end

    declare @id_estado_cuenta int;

    -- Buscar el estado de cuenta según el tipo de responsable
    if @id_socio is not null
    begin
        -- Validar que existe el socio
        if not exists (select 1 from socio.socio where id = @id_socio)
        begin
            raiserror('No existe un socio con ese ID.', 16, 1);
            return;
        end

        select @id_estado_cuenta = id from socio.estado_cuenta where id_socio = @id_socio;

        if @id_estado_cuenta is null
        begin
            raiserror('No existe un estado de cuenta para este socio.', 16, 1);
            return;
        end
    end
    else if @id_tutor is not null
    begin
        -- Validar que existe el tutor
        if not exists (select 1 from socio.tutor where id = @id_tutor)
        begin
            raiserror('No existe un tutor con ese ID.', 16, 1);
            return;
        end

        select @id_estado_cuenta = id from socio.estado_cuenta where id_tutor = @id_tutor;

        if @id_estado_cuenta is null
        begin
            raiserror('No existe un estado de cuenta para este tutor.', 16, 1);
            return;
        end
    end

    print 'monto: ' + cast(@monto as varchar(15));

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

    -- Declarar todas las variables al inicio
    declare @id_pago int;
    declare @id_socio_responsable int;
    declare @id_estado_cuenta int;
    declare @importe_factura decimal(8,2);
    declare @tipo_factura varchar(20);
    declare @message varchar(50);
    declare @es_invitado bit = 0;
    declare @id_invitado int;
    declare @saldo_disponible decimal(8,2) = 0;
    declare @monto_a_descontar decimal(8,2) = 0;
    declare @monto_negativo decimal(8,2) = 0;
    declare @id_cuota int;
    declare @id_socio int;
    declare @responsable_pago bit;
    declare @id_grupo_familiar int;
    declare @id_tutor int;
    declare @id_registro_pileta int;
    declare @id_actividad_extra int;
    declare @es_tutor bit = 0;

    -- Validar medio de pago permitido
    if @medio_de_pago not in ('Visa', 'MasterCard', 'Tarjeta Naranja', 'Pago Fácil', 'Rapipago', 'Transferencia Mercado Pago')
    begin
        raiserror('El medio de pago no es válido. Debe ser: Visa, MasterCard, Tarjeta Naranja, Pago Fácil, Rapipago o Transferencia Mercado Pago.', 16, 1);
        return;
    end

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

        -- Determinar el responsable de pago y si es tutor
        if @responsable_pago = 1
        begin
            set @id_socio_responsable = @id_socio;
            set @es_tutor = 0;
        end
        else
        begin
            if @id_grupo_familiar is not null
            begin
                set @id_socio_responsable = @id_grupo_familiar;
                set @es_tutor = 0;
            end
            else if @id_tutor is not null
            begin
                set @id_socio_responsable = @id_tutor;
                set @es_tutor = 1;
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

        -- Para facturas extra, obtener el socio o invitado y determinar el responsable de pago
        select @importe_factura = fe.importe_total,
               @id_registro_pileta = fe.id_registro_pileta,
               @id_actividad_extra = fe.id_actividad_extra
        from socio.factura_extra fe
        where fe.id = @id_factura_extra;

        -- Determinar el socio o invitado responsable según el tipo de factura extra
        if @id_registro_pileta is not null
        begin
            -- Factura por registro de pileta
            select @id_socio = rp.id_socio,
                   @id_invitado = rp.id_invitado
            from socio.registro_pileta rp
            where rp.id = @id_registro_pileta;

            -- Verificar si es un pago de invitado
            if @id_invitado is not null
            begin
                set @es_invitado = 1;
                set @tipo_factura = 'EXTRA_INVITADO';
            end
            else if @id_socio is not null
            begin
                -- Obtener información del socio para determinar responsable de pago
                select @responsable_pago = s.responsable_pago,
                       @id_grupo_familiar = s.id_grupo_familiar,
                       @id_tutor = s.id_tutor
                from socio.socio s
                where s.id = @id_socio;

                -- Determinar el responsable de pago y si es tutor
                if @responsable_pago = 1
                begin
                    set @id_socio_responsable = @id_socio;
                    set @es_tutor = 0;
                end
                else
                begin
                    if @id_grupo_familiar is not null
                    begin
                        set @id_socio_responsable = @id_grupo_familiar;
                        set @es_tutor = 0;
                    end
                    else if @id_tutor is not null
                    begin
                        set @id_socio_responsable = @id_tutor;
                        set @es_tutor = 1;
                    end
                    else
                    begin
                        raiserror('El socio no es responsable de pago y no tiene grupo familiar ni tutor asignado.', 16, 1);
                        return;
                    end
                end

                set @tipo_factura = 'EXTRA_SOCIO';
            end
            else
            begin
                raiserror('No se encontró ni socio ni invitado asociado al registro de pileta.', 16, 1);
                return;
            end
        end
        else if @id_actividad_extra is not null
        begin
            -- Factura por actividad extra - obtener el socio desde la actividad extra
            select @id_socio = ae.id_socio
            from general.actividad_extra ae
            where ae.id = @id_actividad_extra;

            if @id_socio is null
            begin
                raiserror('No se encontró el socio asociado a la actividad extra.', 16, 1);
                return;
            end

            -- Obtener información del socio para determinar responsable de pago
            select @responsable_pago = s.responsable_pago,
                   @id_grupo_familiar = s.id_grupo_familiar,
                   @id_tutor = s.id_tutor
            from socio.socio s
            where s.id = @id_socio;

            -- Determinar el responsable de pago y si es tutor
            if @responsable_pago = 1
            begin
                set @id_socio_responsable = @id_socio;
                set @es_tutor = 0;
            end
            else
            begin
                if @id_grupo_familiar is not null
                begin
                    set @id_socio_responsable = @id_grupo_familiar;
                    set @es_tutor = 0;
                end
                else if @id_tutor is not null
                begin
                    set @id_socio_responsable = @id_tutor;
                    set @es_tutor = 1;
                end
                else
                begin
                    raiserror('El socio no es responsable de pago y no tiene grupo familiar ni tutor asignado.', 16, 1);
                    return;
                end
            end

            set @tipo_factura = 'EXTRA_ACTIVIDAD';
        end
    end

    -- Calcular saldo disponible y monto a descontar según el tipo de usuario
    if @es_invitado = 1
    begin
        -- Para invitados: usar saldo_a_favor
        select @saldo_disponible = saldo_a_favor
        from socio.invitado
        where id = @id_invitado;

        if @saldo_disponible is null
            set @saldo_disponible = 0;

        -- El monto a descontar es el mínimo entre el saldo disponible y el monto del pago
        set @monto_a_descontar = case 
            when @saldo_disponible >= @monto then @monto
            else @saldo_disponible
        end;
    end
    else
    begin
        -- Para socios/tutores: usar saldo positivo del estado de cuenta
        if @es_tutor = 1
            select @saldo_disponible = case 
                when saldo > 0 then saldo
                else 0
            end
            from socio.estado_cuenta
            where id_tutor = @id_socio_responsable;
        else
            select @saldo_disponible = case 
                when saldo > 0 then saldo
                else 0
            end
            from socio.estado_cuenta
            where id_socio = @id_socio_responsable;

        if @saldo_disponible is null
            set @saldo_disponible = 0;

        -- El monto a descontar es el mínimo entre el saldo disponible y el monto del pago
        set @monto_a_descontar = case 
            when @saldo_disponible >= @monto then @monto
            else @saldo_disponible
        end;
    end

    begin try
        begin transaction;

        -- Insertar el pago (siempre se registra el monto completo)
        insert into socio.pago (
            fecha_pago, monto, medio_de_pago, es_debito_automatico, 
            id_factura_cuota, id_factura_extra
        ) values (
            @fecha_pago, @monto, @medio_de_pago, @es_debito_automatico,
            @id_factura_cuota, @id_factura_extra
        );
        set @id_pago = scope_identity();

        -- Llamamos al procedimiento para generar la cuota del próximo mes copiando las mismas actividades, monto, etc
        exec socio.copiarCuota @id_cuota = @id_cuota, @mes = @mes_actual, @anio = @anio_actual;

        -- Actualizar saldo según el tipo de usuario
        if @es_invitado = 1
        begin
            -- Para invitados: descontar del saldo_a_favor
            if @monto_a_descontar > 0
            begin
                update socio.invitado
                set saldo_a_favor = saldo_a_favor - @monto_a_descontar
                where id = @id_invitado;
            end
        end
        else
        begin
            -- Para socios/tutores: generar movimientos de cuenta SOLO para facturas cuota
            -- Las facturas extra son pagos inmediatos y NO deben afectar el estado de cuenta
            
            if @tipo_factura = 'CUOTA'
            begin
                -- Obtener el estado de cuenta del responsable de pago
                if @es_tutor = 1
                    select @id_estado_cuenta = id 
                    from socio.estado_cuenta 
                    where id_tutor = @id_socio_responsable;
                else
                    select @id_estado_cuenta = id 
                    from socio.estado_cuenta 
                    where id_socio = @id_socio_responsable;

                if @id_estado_cuenta is null
                begin
                    raiserror('No existe un estado de cuenta para el responsable de pago.', 16, 1);
                    return;
                end

                -- Verificar si hay saldo a favor (saldo positivo) para descontar
                if @monto_a_descontar > 0
                begin
                    -- Generar movimiento de cuenta por el monto descontado del saldo a favor
                    exec socio.altaMovimientoCuenta
                        @id_estado_cuenta = @id_estado_cuenta,
                        @monto = @monto_a_descontar,
                        @id_pago = @id_pago;

                    -- Actualizar el estado de cuenta descontando el saldo a favor utilizado
                    set @monto_negativo = @monto_a_descontar * -1;
                    if @es_tutor = 1
                        exec socio.modificacionEstadoCuenta @id_tutor = @id_socio_responsable, @monto = @monto_negativo;
                    else
                        exec socio.modificacionEstadoCuenta @id_socio = @id_socio_responsable, @monto = @monto_negativo;
                end

                -- Generar movimiento de cuenta por el monto neto del pago (monto total - saldo a favor utilizado)
                declare @monto_neto decimal(8,2);
                set @monto_neto = @monto - @monto_a_descontar;

                if @monto_neto > 0
                begin
                    exec socio.altaMovimientoCuenta
                        @id_estado_cuenta = @id_estado_cuenta,
                        @monto = @monto_neto,
                        @id_pago = @id_pago;

                    -- Actualizar el estado de cuenta sumando el monto neto del pago
                    if @es_tutor = 1
                        exec socio.modificacionEstadoCuenta @id_tutor = @id_socio_responsable, @monto = @monto_neto;
                    else
                        exec socio.modificacionEstadoCuenta @id_socio = @id_socio_responsable, @monto = @monto_neto;
                end

                -- Obtener el saldo final después de todas las actualizaciones
                declare @saldo_final decimal(8,2);
                if @es_tutor = 1
                    select @saldo_final = saldo from socio.estado_cuenta where id_tutor = @id_socio_responsable;
                else
                    select @saldo_final = saldo from socio.estado_cuenta where id_socio = @id_socio_responsable;
            end
            else
            begin
                -- Para facturas extra: NO generar movimientos de cuenta ni afectar estado de cuenta
                -- Son pagos inmediatos que se registran pero no alteran el saldo
                print 'Pago de factura extra procesado - No se afecta el estado de cuenta (pago inmediato)';
            end
        end

        commit transaction;

        -- Mostrar resumen del pago procesado
        print '=== RESUMEN DEL PAGO ===';
        print 'Monto de la factura: $' + cast(@importe_factura as varchar(15));
        print 'Monto pagado: $' + cast(@monto as varchar(15));
        print 'Saldo disponible: $' + cast(@saldo_disponible as varchar(15));
        print 'Monto descontado del saldo: $' + cast(@monto_a_descontar as varchar(15));
        if @es_invitado = 1
        begin
            print 'Tipo: Pago de Invitado';
            print 'Saldo a favor restante: $' + cast(@saldo_disponible - @monto_a_descontar as varchar(15));
        end
        else
        begin
            if @tipo_factura = 'CUOTA'
            begin
                print 'Tipo: Pago de Factura Cuota (Socio/Tutor)';
                if @monto_a_descontar > 0
                begin
                    print 'Se utilizó saldo a favor del estado de cuenta';
                    print 'Monto neto aplicado al estado de cuenta: $' + cast(@monto - @monto_a_descontar as varchar(15));
                end
                else
                    print 'No se utilizó saldo a favor';
            end
            else
            begin
                print 'Tipo: Pago de Factura Extra (Socio/Tutor) - PAGO INMEDIATO';
                print 'NOTA: Las facturas extra NO afectan el estado de cuenta (pago inmediato)';
                if @monto_a_descontar > 0
                begin
                    print 'Se utilizó saldo a favor del estado de cuenta';
                    print 'Monto neto aplicado al estado de cuenta: $' + cast(@monto - @monto_a_descontar as varchar(15));
                end
                else
                    print 'No se utilizó saldo a favor';
            end
        end
        print '========================';

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
    @fecha_reembolso datetime = null,
    @motivo varchar(100) = 'Reembolso completo',
    @id_tipo_reembolso int = 1,
    @porcentaje_reembolso decimal(5,2) = 100.00
as
begin
    declare @monto decimal(8,2);
    declare @monto_pago decimal(8,2);
    
    -- Validar que el pago existe y obtener su monto
    select @monto_pago = monto 
    from socio.pago 
    where id = @id_pago;
    
    if @monto_pago is null
    begin
        raiserror('No existe un pago con ese ID.', 16, 1);
        return;
    end

    -- Validar que el porcentaje esté entre 0 y 100
    if @porcentaje_reembolso < 0 or @porcentaje_reembolso > 100
    begin
        raiserror('El porcentaje de reembolso debe estar entre 0 y 100.', 16, 1);
        return;
    end

    -- Calcular el monto del reembolso basado en el porcentaje
    set @monto = @monto_pago * (@porcentaje_reembolso / 100.00);

    -- Validar que el tipo de reembolso existe
    if not exists (select 1 from socio.tipo_reembolso where id = @id_tipo_reembolso)
    begin
        raiserror('No existe un tipo de reembolso con ese ID.', 16, 1);
        return;
    end

    -- Establecer fecha de reembolso por defecto
    if @fecha_reembolso is null
        set @fecha_reembolso = getdate();

    -- Determinar el responsable de pago del pago original
    declare @id_socio_responsable int;
    declare @id_estado_cuenta int;
    declare @id_reembolso int;
    declare @es_tutor bit = 0;

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

        -- Determinar el responsable de pago y si es tutor
        if @responsable_pago = 1
        begin
            set @id_socio_responsable = @id_socio;
            set @es_tutor = 0;
        end
        else
        begin
            if @id_grupo_familiar is not null
            begin
                set @id_socio_responsable = @id_grupo_familiar;
                set @es_tutor = 0;
            end
            else if @id_tutor is not null
            begin
                set @id_socio_responsable = @id_tutor;
                set @es_tutor = 1;
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

            -- Determinar el responsable de pago y si es tutor
            if @responsable_pago = 1
            begin
                set @id_socio_responsable = @id_socio;
                set @es_tutor = 0;
            end
            else
            begin
                if @id_grupo_familiar is not null
                begin
                    set @id_socio_responsable = @id_grupo_familiar;
                    set @es_tutor = 0;
                end
                else if @id_tutor is not null
                begin
                    set @id_socio_responsable = @id_tutor;
                    set @es_tutor = 1;
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
    if @es_tutor = 1
        select @id_estado_cuenta = id 
        from socio.estado_cuenta 
        where id_tutor = @id_socio_responsable;
    else
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
        if @es_tutor = 1
            exec socio.modificacionEstadoCuenta @id_tutor = @id_socio_responsable, @monto = @monto;
        else
            exec socio.modificacionEstadoCuenta @id_socio = @id_socio_responsable, @monto = @monto;

        commit transaction;
        
        -- Mostrar resumen del reembolso
        print '=== REEMBOLSO PROCESADO ===';
        print 'ID Pago: ' + cast(@id_pago as varchar(10));
        print 'Monto del pago original: $' + cast(@monto_pago as varchar(15));
        print 'Porcentaje de reembolso: ' + cast(@porcentaje_reembolso as varchar(10)) + '%';
        print 'Monto reembolsado: $' + cast(@monto as varchar(15));
        if @porcentaje_reembolso = 100.00
            print 'Tipo: Reembolso completo (100% del pago original)';
        else
            print 'Tipo: Reembolso parcial (' + cast(@porcentaje_reembolso as varchar(10)) + '% del pago original)';
        print 'Motivo: ' + @motivo;
        print 'Fecha: ' + cast(@fecha_reembolso as varchar(20));
        print '==========================';
        
    end try
    begin catch
        rollback transaction;
        declare @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
        raiserror('Error al crear el reembolso: %s', 16, 1, @ErrorMessage);
        return;
    end catch
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

                -- Crear reembolso con el porcentaje especificado
                exec socio.altaReembolso
                    @id_pago = @id_pago,
                    @fecha_reembolso = @fecha_lluvia,
                    @motivo = 'Reintegro por lluvia',
                    @id_tipo_reembolso = @id_tipo_reembolso,
                    @porcentaje_reembolso = @porcentaje_reintegro;

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


---- Actividad ----
-- Insert
create or alter procedure general.altaActividad
    @nombre varchar(50),
    @costo_mensual decimal(8,2)
as
begin
    if @costo_mensual <= 0
    begin
        raiserror('El costo mensual debe ser mayor a 0.', 16, 1);
        return;
    end

    if exists (select 1 from general.actividad where nombre = @nombre)
    begin
        raiserror('Ya existe una actividad con ese nombre.', 16, 1);
        return;
    end

    insert into general.actividad (nombre, costo_mensual)
    values (@nombre, @costo_mensual);
end
go

-- Update
create or alter procedure general.modificacionActividad
    @id int,
    @nombre varchar(50),
    @costo_mensual decimal(8,2)
as
begin
    if not exists (select 1 from general.actividad where id = @id)
    begin
        raiserror('No existe una actividad con ese ID.', 16, 1);
        return;
    end

    if @costo_mensual <= 0
    begin
        raiserror('El costo mensual debe ser mayor a 0.', 16, 1);
        return;
    end

    if exists (select 1 from general.actividad where nombre = @nombre and id <> @id)
    begin
        raiserror('Ya existe otra actividad con ese nombre.', 16, 1);
        return;
    end

    update general.actividad
    set nombre = @nombre,
        costo_mensual = @costo_mensual
    where id = @id;
end
go

-- Delete
create or alter procedure general.bajaActividad
    @id int
as
begin
    if not exists (select 1 from general.actividad where id = @id)
    begin
        raiserror('No existe una actividad con ese ID.', 16, 1);
        return;
    end

    if exists (select 1 from socio.inscripcion_actividad where id_actividad = @id)
    begin
        raiserror('No se puede eliminar porque está vinculada a inscripciones de actividad.', 16, 1);
        return;
    end

    if exists (select 1 from general.clase where id_actividad = @id)
    begin
        raiserror('No se puede eliminar porque está vinculada a clases.', 16, 1);
        return;
    end

    delete from general.actividad where id = @id;
end
go


---- Categoría ----
-- Insert
create or alter procedure socio.altaCategoria
    @nombre varchar(50),
    @costo_mensual decimal(8,2),
    @edad_min int,
    @edad_max int
as
begin
    if @costo_mensual <= 0
    begin
        raiserror('El costo mensual debe ser mayor a 0.', 16, 1);
        return;
    end

    if @edad_min < 0 or @edad_max < 0
    begin
        raiserror('Las edades deben ser mayores o iguales a 0.', 16, 1);
        return;
    end

    if @edad_min > @edad_max
    begin
        raiserror('La edad mínima no puede ser mayor a la edad máxima.', 16, 1);
        return;
    end

    if exists (select 1 from socio.categoria where nombre = @nombre)
    begin
        raiserror('Ya existe una categoría con ese nombre.', 16, 1);
        return;
    end

    insert into socio.categoria (nombre, costo_mensual, edad_min, edad_max)
    values (@nombre, @costo_mensual, @edad_min, @edad_max);
end
go

-- Update
create or alter procedure socio.modificacionCategoria
    @id int,
    @nombre varchar(50),
    @costo_mensual decimal(8,2),
    @edad_min int,
    @edad_max int
as
begin
    if not exists (select 1 from socio.categoria where id = @id)
    begin
        raiserror('No existe una categoría con ese ID.', 16, 1);
        return;
    end

    if @costo_mensual <= 0
    begin
        raiserror('El costo mensual debe ser mayor a 0.', 16, 1);
        return;
    end

    if @edad_min < 0 or @edad_max < 0
    begin
        raiserror('Las edades deben ser mayores o iguales a 0.', 16, 1);
        return;
    end

    if @edad_min > @edad_max
    begin
        raiserror('La edad mínima no puede ser mayor a la edad máxima.', 16, 1);
        return;
    end

    if exists (select 1 from socio.categoria where nombre = @nombre and id <> @id)
    begin
        raiserror('Ya existe otra categoría con ese nombre.', 16, 1);
        return;
    end

    update socio.categoria
    set nombre = @nombre,
        costo_mensual = @costo_mensual,
        edad_min = @edad_min,
        edad_max = @edad_max
    where id = @id;
end
go

create or alter procedure socio.modificarPrecioCategoria
    @id int,
    @costo_mensual decimal(8,2)
as
begin
    if not exists (select 1 from socio.categoria where id = @id)
    begin
        raiserror('No existe una categoría con ese ID.', 16, 1);
        return;
    end

    update socio.categoria
    set costo_mensual = @costo_mensual
    where id = @id;
end

-- Delete
create or alter procedure socio.bajaCategoria
    @id int
as
begin
    if not exists (select 1 from socio.categoria where id = @id)
    begin
        raiserror('No existe una categoría con ese ID.', 16, 1);
        return;
    end

    if exists (select 1 from socio.cuota where id_categoria = @id)
    begin
        raiserror('No se puede eliminar porque está vinculada a cuotas.', 16, 1);
        return;
    end

    if exists (select 1 from general.clase where id_categoria = @id)
    begin
        raiserror('No se puede eliminar porque está vinculada a clases.', 16, 1);
        return;
    end

    delete from socio.categoria where id = @id;
end
go


---- Tarifa Pileta ----
-- Insert
create or alter procedure socio.altaTarifaPileta
    @tipo varchar(20),
    @precio decimal(8,2)
as
begin
    if @precio <= 0
    begin
        raiserror('El precio debe ser mayor a 0.', 16, 1);
        return;
    end

    if exists (select 1 from socio.tarifa_pileta where tipo = @tipo)
    begin
        raiserror('Ya existe una tarifa con ese tipo.', 16, 1);
        return;
    end

    insert into socio.tarifa_pileta (tipo, precio)
    values (@tipo, @precio);
end
go

-- Update
create or alter procedure socio.modificacionTarifaPileta
    @id int,
    @tipo varchar(20),
    @precio decimal(8,2)
as
begin
    if not exists (select 1 from socio.tarifa_pileta where id = @id)
    begin
        raiserror('No existe una tarifa con ese ID.', 16, 1);
        return;
    end

    if @precio <= 0
    begin
        raiserror('El precio debe ser mayor a 0.', 16, 1);
        return;
    end

    if exists (select 1 from socio.tarifa_pileta where tipo = @tipo and id <> @id)
    begin
        raiserror('Ya existe otra tarifa con ese tipo.', 16, 1);
        return;
    end

    update socio.tarifa_pileta
    set tipo = @tipo,
        precio = @precio
    where id = @id;
end
go

-- Delete
create or alter procedure socio.bajaTarifaPileta
    @id int
as
begin
    if not exists (select 1 from socio.tarifa_pileta where id = @id)
    begin
        raiserror('No existe una tarifa con ese ID.', 16, 1);
        return;
    end

    if exists (select 1 from socio.registro_pileta where id_tarifa = @id)
    begin
        raiserror('No se puede eliminar porque está vinculada a registros de pileta.', 16, 1);
        return;
    end

    delete from socio.tarifa_pileta where id = @id;
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


---- Sistema de Débito Automático ----
-- Procedimiento para procesar débitos automáticos y generar facturas y pagos sin duplicados
create or alter procedure socio.procesarDebitosAutomaticos
    @fecha_procesamiento date = null
as
begin
    set nocount on;
    if @fecha_procesamiento is null
        set @fecha_procesamiento = getdate();

    /*if @fecha_procesamiento > getdate()
    begin
        raiserror('No se puede procesar débitos automáticos para una fecha futura.', 16, 1);
        return;
    end*/

    declare @cantidad_procesados int = 0;
    declare @total_procesado decimal(10,2) = 0;
    declare @cantidad_exitosos int = 0;
    declare @cantidad_fallidos int = 0;

    begin try
        begin transaction;

        -- Obtener todos los responsables de débito automático activos (socios y tutores)
        declare @socios table (id_responsable_pago int, id_cuota int, monto_cuota decimal(8,2), es_tutor bit, medio_de_pago varchar(50));

        insert into @socios (id_responsable_pago, id_cuota, monto_cuota, es_tutor, medio_de_pago)
        -- Socios responsables de pago
        select da.id_responsable_pago, c.id, c.monto_total, 0, da.medio_de_pago
        from socio.debito_automatico da
        inner join socio.socio s on s.id = da.id_responsable_pago and s.responsable_pago = 1
        inner join socio.cuota c on c.id_socio = s.id
        where da.activo = 1

        union all

        -- Tutores responsables de pago
        select da.id_responsable_pago, c.id, c.monto_total, 1, da.medio_de_pago
        from socio.debito_automatico da
        inner join socio.tutor t on t.id = da.id_responsable_pago
        inner join socio.socio s on s.id_tutor = t.id
        inner join socio.cuota c on c.id_socio = s.id
        where da.activo = 1;

        -- Variables para iterar
        declare @id_responsable_pago int, @id_cuota int, @monto_cuota decimal(8,2), @es_tutor bit, @medio_de_pago varchar(50);
        declare @id_factura_cuota int, @id_pago int;

        -- Iterar sobre la tabla de responsables adheridos al débito automático
        while exists (select 1 from @socios)
        begin
            select top 1 @id_responsable_pago = id_responsable_pago, @id_cuota = id_cuota, @monto_cuota = monto_cuota, @es_tutor = es_tutor, @medio_de_pago = medio_de_pago from @socios;

            -- Generar factura de cuota
            exec socio.altaFacturaCuota @id_cuota = @id_cuota, @fecha_emision = @fecha_procesamiento;
            select @id_factura_cuota = max(id) from socio.factura_cuota where id_cuota = @id_cuota;

            -- Obtener el importe real de la factura (con descuentos)
            declare @monto_factura decimal(8,2);
            select @monto_factura = importe_total from socio.factura_cuota where id = @id_factura_cuota;

            -- Generar pago de la factura
            exec socio.altaPago 
                @monto = @monto_factura, 
                @medio_de_pago = @medio_de_pago, 
                @es_debito_automatico = 1,
                @id_factura_cuota = @id_factura_cuota;
            select @id_pago = scope_identity();

            set @cantidad_exitosos = @cantidad_exitosos + 1;
            set @total_procesado = @total_procesado + @monto_cuota;
            set @cantidad_procesados = @cantidad_procesados + 1;

            delete from @socios where id_responsable_pago = @id_responsable_pago and id_cuota = @id_cuota;
        end

        commit transaction;

        print '=== DÉBITOS AUTOMÁTICOS PROCESADOS ===';
        print 'Cantidad total de débitos procesados: ' + cast(@cantidad_procesados as varchar(10));
        print '  - Débitos exitosos: ' + cast(@cantidad_exitosos as varchar(10));
        print 'Total procesado: $' + cast(@total_procesado as varchar(15));
        print '=====================================';
    end try
    begin catch
        rollback transaction;
        declare @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
        raiserror('Error al procesar débitos automáticos: %s', 16, 1, @ErrorMessage);
        return;
    end catch
end
go

-- =============================================
-- UTILIDAD DE LIMPIEZA DE DATOS DE PRUEBA
-- =============================================
create or alter procedure general.limpiarDatosPrueba
as
begin
    set nocount on;
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
end
GO


-- Procedimiento para dar de baja un socio de un grupo familiar
create or alter procedure socio.bajaSocioDeGrupoFamiliar
    @id_socio int,
    @nuevo_responsable_pago int = null   -- ID del nuevo socio responsable o tutor
as
begin
    SET NOCOUNT ON;
    
    -- Validar que el socio existe
    if not exists (select 1 from socio.socio where id = @id_socio)
    begin
        raiserror('No existe un socio con ese ID.', 16, 1);
        return;
    end

    -- Obtener información del socio
    declare @nombre_socio varchar(100), @apellido_socio varchar(100);
    declare @fecha_nacimiento date, @edad int;
    declare @id_grupo_familiar_actual int, @responsable_pago_actual bit;
    declare @id_tutor_actual int;
    declare @fecha_actual date = getdate();

    select @nombre_socio = nombre,
           @apellido_socio = apellido,
           @fecha_nacimiento = fecha_nacimiento,
           @id_grupo_familiar_actual = id_grupo_familiar,
           @responsable_pago_actual = responsable_pago,
           @id_tutor_actual = id_tutor
    from socio.socio
    where id = @id_socio;

    -- Calcular edad
    set @edad = datediff(YEAR, @fecha_nacimiento, @fecha_actual);
    if dateadd(year, @edad, @fecha_nacimiento) > cast(@fecha_actual as date)
        set @edad = @edad - 1;

    -- Validar que el socio está en un grupo familiar
    if @id_grupo_familiar_actual is null
    begin
        raiserror('El socio no pertenece a ningún grupo familiar.', 16, 1);
        return;
    end

    -- Validar que no es el responsable del grupo familiar
    if @id_socio = @id_grupo_familiar_actual
    begin
        raiserror('No se puede dar de baja al responsable del grupo familiar. Primero debe asignar un nuevo responsable.', 16, 1);
        return;
    end

    -- Para menores de edad, validar que se proporcione un nuevo responsable
    if @edad < 18
    begin
        if @nuevo_responsable_pago is null
        begin
            raiserror('Para socios menores de edad, debe proporcionar un nuevo responsable de pago (socio o tutor).', 16, 1);
            return;
        end

        -- Determinar automáticamente si el nuevo responsable es tutor o socio
        declare @es_tutor bit = 0;
        declare @es_socio bit = 0;
        
        -- Verificar si es tutor
        if exists (select 1 from socio.tutor where id = @nuevo_responsable_pago)
        begin
            set @es_tutor = 1;
        end
        -- Verificar si es socio
        else if exists (select 1 from socio.socio where id = @nuevo_responsable_pago)
        begin
            set @es_socio = 1;
            
            -- Validar que el nuevo socio responsable es mayor de edad
            declare @edad_nuevo_responsable int;
            declare @fecha_nacimiento_nuevo date;
            
            select @fecha_nacimiento_nuevo = fecha_nacimiento
            from socio.socio
            where id = @nuevo_responsable_pago;

            set @edad_nuevo_responsable = datediff(YEAR, @fecha_nacimiento_nuevo, @fecha_actual);
            if dateadd(year, @edad_nuevo_responsable, @fecha_nacimiento_nuevo) > cast(@fecha_actual as date)
                set @edad_nuevo_responsable = @edad_nuevo_responsable - 1;

            if @edad_nuevo_responsable < 18
            begin
                raiserror('El nuevo socio responsable debe ser mayor de edad.', 16, 1);
                return;
            end
        end
        else
        begin
            raiserror('No existe un socio o tutor con ese ID.', 16, 1);
            return;
        end
    end

    begin try
        begin transaction;

        -- Actualizar el socio según su edad
        if @edad < 18
        begin
            -- Para menores: asignar nuevo responsable y quitar del grupo familiar
            if @es_tutor = 1
            begin
                -- Asignar tutor como responsable
                update socio.socio
                set id_grupo_familiar = null,
                    id_tutor = @nuevo_responsable_pago,
                    responsable_pago = 0
                where id = @id_socio;

                -- Crear estado de cuenta para el tutor si no existe
                if not exists (select 1 from socio.estado_cuenta where id_tutor = @nuevo_responsable_pago)
                begin
                    exec socio.altaEstadoCuenta @id_tutor = @nuevo_responsable_pago, @saldo = 0;
                end
            end
            else
            begin
                -- Asignar nuevo socio como responsable
                update socio.socio
                set id_grupo_familiar = @nuevo_responsable_pago,
                    id_tutor = null,
                    responsable_pago = 0
                where id = @id_socio;

                -- Crear estado de cuenta para el nuevo socio responsable si no existe
                if not exists (select 1 from socio.estado_cuenta where id_socio = @nuevo_responsable_pago)
                begin
                    exec socio.altaEstadoCuenta @id_socio = @nuevo_responsable_pago, @saldo = 0;
                end
            end
        end
        else
        begin
            -- Para mayores: hacer responsable de pago y quitar del grupo familiar
            update socio.socio
            set id_grupo_familiar = null,
                id_tutor = null,
                responsable_pago = 1
            where id = @id_socio;

            -- Crear estado de cuenta para el socio si no existe
            if not exists (select 1 from socio.estado_cuenta where id_socio = @id_socio)
            begin
                exec socio.altaEstadoCuenta @id_socio = @id_socio, @saldo = 0;
            end
        end

        commit transaction;
    end try
    begin catch
        rollback transaction;
        declare @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
        raiserror('Error al dar de baja el socio del grupo familiar: %s', 16, 1, @ErrorMessage);
        return;
    end catch
end
go


-- Procedimiento para cambiar el responsable de un grupo familiar
create or alter procedure socio.cambiarResponsableGrupoFamiliar
    @id_grupo_familiar int,
    @nuevo_responsable int
as
begin
    SET NOCOUNT ON;
    
    -- Validar que el grupo familiar existe
    if not exists (select 1 from socio.socio where id_grupo_familiar = @id_grupo_familiar)
    begin
        raiserror('No existe un grupo familiar con ese ID.', 16, 1);
        return;
    end
    
    -- Validar que el nuevo responsable existe
    if not exists (select 1 from socio.socio where id = @nuevo_responsable)
    begin
        raiserror('No existe un socio o tutor con ese ID.', 16, 1);
        return;
    end
    
    -- Validar que el nuevo responsable no es el responsable actual
    if @id_grupo_familiar = @nuevo_responsable
    begin
        raiserror('El nuevo responsable no puede ser el mismo que el responsable actual.', 16, 1);
        return;
    end

    -- Verificar que el nuevo responsable no es menor de edad
    declare @edad_nuevo_responsable int;
    declare @fecha_nacimiento_nuevo date;
    declare @fecha_actual date = getdate();
    select @fecha_nacimiento_nuevo = fecha_nacimiento
    from socio.socio
    where id = @nuevo_responsable;
    
    set @edad_nuevo_responsable = datediff(YEAR, @fecha_nacimiento_nuevo, @fecha_actual);
    if dateadd(year, @edad_nuevo_responsable, @fecha_nacimiento_nuevo) > cast(@fecha_actual as date)
        set @edad_nuevo_responsable = @edad_nuevo_responsable - 1;

    if @edad_nuevo_responsable < 18
    begin
        raiserror('El nuevo responsable debe ser mayor de edad.', 16, 1);
        return;
    end
    
    -- Actualizar el responsable del grupo familiar
    update socio.socio
    set id_grupo_familiar = @nuevo_responsable
    where id_grupo_familiar = @id_grupo_familiar;

    -- Actualizar el estado de cuenta del nuevo responsable
    if not exists (select 1 from socio.estado_cuenta where id_socio = @nuevo_responsable)
    begin
        exec socio.altaEstadoCuenta @id_socio = @nuevo_responsable, @saldo = 0;
    end
end
go


-- Procedimiento para copiar una cuota
create or alter procedure socio.copiarCuota
    @id_cuota int
as
begin
    SET NOCOUNT ON;

    declare @mes_siguiente int;
    declare @anio_siguiente int;

    select @mes = mes, @anio = anio
    from socio.cuota
    where id = @id_cuota;

    if @mes = 12
    begin
        set @mes_siguiente = 1;
        set @anio_siguiente = @anio + 1;
    end
    else
    begin
        set @mes_siguiente = @mes + 1;
        set @anio_siguiente = @anio;
    end
    
    -- Validar que la cuota existe
    if not exists (select 1 from socio.cuota where id = @id_cuota)
    begin
        raiserror('No existe una cuota con ese ID.', 16, 1);
        return;
    end

    -- Obtener información de la cuota
    declare @id_socio int;
    declare @id_categoria int;
    declare @mes int;
    declare @anio int;
    declare @monto_total decimal(8,2);

    select @id_socio = id_socio,
           @id_categoria = id_categoria,
           @mes = mes,
           @anio = anio,
           @monto_total = monto_total
    from socio.cuota
    where id = @id_cuota;

    -- Verificar que la cuota anterior esté pagada
    if not exists (
        select 1 from socio.factura_cuota fc 
        inner join socio.pago p on fc.id = p.id_factura_cuota 
        where fc.id_cuota = @id_cuota
    )
    begin
        raiserror('No se puede copiar una cuota que no está pagada.', 16, 1);
        return;
    end

    -- Verificar que no exista ya una cuota para el mes siguiente
    if exists (select 1 from socio.cuota where id_socio = @id_socio and mes = @mes_siguiente and anio = @anio_siguiente)
    begin
        raiserror('Ya existe una cuota para el mes siguiente.', 16, 1);
        return;
    end

    begin try
        begin transaction;

            -- Copiar la cuota
            insert into socio.cuota (id_socio, id_categoria, mes, anio, monto_total)
            select @id_socio, @id_categoria, @mes_siguiente, @anio_siguiente, @monto_total
            from socio.cuota
            where id = @id_cuota;
            
            -- Copiar las inscripciones a actividades
            insert into socio.inscripcion_actividad (id_cuota, id_actividad)
            select @id_cuota_nueva, id_actividad
            from socio.inscripcion_actividad
            where id_cuota = @id_cuota;

            -- Vamos a calcular el monto total de las actividades copiadas por si hubo aumento de precio
            declare @monto_total_actividades decimal(8,2);
            select @monto_total_actividades = isnull(sum(a.costo_mensual), 0)
            from socio.inscripcion_actividad ia
            inner join general.actividad a on ia.id_actividad = a.id
            where ia.id_cuota = @id_cuota_nueva;

            -- Con la fecha de nacimiento del socio, vamos a buscar la categoria la nueva por si cambia
            declare @fecha_nacimiento date;
            select @fecha_nacimiento = fecha_nacimiento
            from socio.socio
            where id = @id_socio;

            declare @edad_nueva int;
            set @edad_nueva = datediff(YEAR, @fecha_nacimiento, @fecha_actual);
            if dateadd(year, @edad_nueva, @fecha_nacimiento) > cast(@fecha_actual as date)
                set @edad_nueva = @edad_nueva - 1;

            -- Buscamos la nueva categoria (por si cambia)
            declare @id_categoria_nueva int;
            declare @monto_categoria_nueva decimal(8,2);
            select @id_categoria_nueva = id, @monto_categoria_nueva = costo_mensual
            from socio.categoria
            where edad_min <= @edad_nueva and edad_max >= @edad_nueva;

            -- Actualizamos el monto total de la cuota (actividades + categoria)
            set @monto_total = @monto_total_actividades + @monto_categoria_nueva;

            -- Actualizamos el monto total de la cuota
            update socio.cuota
            set monto_total = @monto_total
            where id = @id_cuota_nueva;

            -- Actualizamos la categoria de la cuota
            update socio.cuota
            set id_categoria = @id_categoria_nueva
            where id = @id_cuota_nueva;

        commit transaction;
    end try
    begin catch
        rollback transaction;
        declare @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
        raiserror('Error al copiar la cuota: %s', 16, 1, @ErrorMessage);
        return;
    end catch
end
go