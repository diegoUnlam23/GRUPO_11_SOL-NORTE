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



