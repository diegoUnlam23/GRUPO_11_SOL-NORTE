use Com2900G11;
go

create or alter procedure general.encriptarEmpleado
	@id int
as
begin
	declare @clave varchar(100) = 'profe_valeria_tutora';  
	declare @nombre_encriptado varbinary(256);
	declare @nombre_empleado varchar(150);

	if not exists (select 1 from general.empleado e where e.id = @id)
	begin
		raiserror('Empleado inexistente',16,1)
		return;
	end
	select @nombre_empleado = e.nombre from general.empleado e where e.id = @id
	set @nombre_encriptado = ENCRYPTBYPASSPHRASE(@clave,@nombre_empleado)
	
	update general.empleado
	set 
		nombre_cifrado =@nombre_encriptado,
		nombre = NULL
	where id = @id

end
go

create or alter procedure general.desencriptarEmpleado
	@id int
as
begin
	
	declare @clave varchar(100) = 'profe_valeria_tutora';  
	declare @nombre_encriptado varbinary(256);
	declare @nombre_empleado varchar(150);

	if not exists (select 1 from general.empleado e where e.id = @id)
	begin
		raiserror('Empleado inexistente',16,1)
		return;
	end 
	select @nombre_encriptado = e.nombre_cifrado from general.empleado e where e.id = @id
	set @nombre_empleado = convert(varchar(150),DECRYPTBYPASSPHRASE(@clave,@nombre_encriptado))
	
	update general.empleado
	set 
		nombre_cifrado =NULL,
		nombre = @nombre_empleado
	where id = @id

end