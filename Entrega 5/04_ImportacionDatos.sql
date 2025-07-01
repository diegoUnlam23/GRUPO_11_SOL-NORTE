/*
    Consigna: Importacion de Datos
    Fecha de entrega: 24/06/2025
    Número de comisión: 2900
    Número de grupo: 11
    Nombre de la materia: Bases de Datos Aplicadas
    Integrantes:
        - Costanzo, Marcos Ezequiel - 40955907
        - Sanchez, Diego Mauricio - 46361081
*/
USE Com2900G11
GO

-- Habilitamos las consulta Ad Hoc para importar los datos de excel
exec sp_configure 'show advanced options', 1;
reconfigure

exec sp_configure 'Ad Hoc Distributed Queries', 1;
reconfigure

-- Otorgamos los permisos al proveedor de OLEDB para poder linkear el archivo excel
/*
exec master.dbo.sp_MSset_oledb_prop 
    N'Microsoft.ACE.OLEDB.16.0', 
    N'AllowInProcess', 1;
    
exec master.dbo.sp_MSset_oledb_prop 
    N'Microsoft.ACE.OLEDB.16.0', 
    N'DynamicParameters', 1;
go*/

go
create or alter procedure	socio.Importar_RP
	@arch	varchar(200),
	@hoja	varchar(200)
as
begin
	begin try
		create table ##responsable_pago
		(
			num_reg		int identity(1,1),
			id_socio	varchar(20),
			nombre		varchar(100),
			apellido	varchar(100),
			dni			int,
			email		varchar(150),
			fnac		varchar(100),
			tel			bigint,
			tel_em		bigint,
			id_os		varchar(150),
			nro_os		varchar(50),
			tel_os		varchar(50)
		);
		
		declare @script nvarchar(max);
		declare @act int,@fin int,
		@nombre varchar(150),
		@apellido varchar(150),
		@dni int,
		@fecha date,
		@email varchar(150),
		@tel nvarchar(50),
		@tel_em nvarchar(50),
		@id_os varchar(50),
		@tel_os varchar(50),
		@nro_os varchar(50),
		@id int;
		set @script = N'
					insert into ##responsable_pago
					select * 
					from openrowset(
					''Microsoft.ACE.OLEDB.16.0'', 
					''Excel 12.0;Database=' + @arch + ';HDR=YES;IMEX=0'', 
					''SELECT * FROM ['+@hoja+'$]''
					);';
		exec sp_executesql @script;


		--usando sp y recorriendo 1 por 1
		set @act = (select min(num_reg) from ##responsable_pago);
		set @fin = (select max(num_reg) from ##responsable_pago);

		while @act <= @fin
		begin
			select @nombre = nombre,@apellido = apellido, @tel = cast(tel as varchar),@tel_em = cast(tel_em as varchar),
				   @dni = dni,@fecha = TRY_CONVERT(date,fnac),@email = email,@id_os = id_os,
				   @nro_os = nro_os,@tel_os = tel_os
			from ##responsable_pago rp where num_reg = @act and TRY_CONVERT(date,fnac) is not null
			and not exists 
				(
					select 1 from socio.socio s where s.dni = rp.dni
				)
			and rp.dni in
				(
					select dni
					from ##responsable_pago
					group by dni
					having count(*) = 1
				)
			insert into obra_social_socio(nombre,telefono_emergencia,numero_socio)
			values(@id_os,@tel_os,@nro_os)
			set @id = SCOPE_IDENTITY();
			exec socio.altaSocio @nombre = @nombre,
									 @apellido = @apellido,
									 @dni = @dni,
									 @email = @email,
									 @fecha_nacimiento = @fecha,
									 @telefono = @tel,
									 @telefono_emergencia = @tel_em,
									 @id_obra_social_socio = @id,
									 @id_tutor = NULL,
									 @id_grupo_familiar = NULL,
									 @responsable_pago = 1,
									 @estado = N'al dia'


			set @act = @act + 1;
			print 'Importacion existosa'
		end
	end try
	begin catch
		print 'No se pudo completar la importacion ->'+ ERROR_MESSAGE();
	end catch
end
go
--exec socio.Importar_RP @arch = N'C:\Users\diego\Downloads\TPI-2025-1C\TPI-2025-1C\Datos socios.xlsx',@hoja = N'Responsables de Pago'

create or alter procedure	socio.Importar_GF
	@arch	varchar(200),
	@hoja	varchar(200)
as
begin
	begin try
		create table ##grupo_familiar
		(
			num_reg		int identity(1,1),
			id_socio	varchar(20),
			id_rp		varchar(20),
			nombre		varchar(100),
			apellido	varchar(100),
			dni			int,
			email		varchar(150),
			fnac		varchar(100),
			tel			bigint,
			tel_em		bigint,
			id_os		varchar(150),
			nro_os		nvarchar(50),
			tel_os		varchar(50)
		);
		
		declare @script nvarchar(max);
		declare @act int,@fin int,
		@nombre varchar(150),
		@apellido varchar(150),
		@dni int,
		@fecha date,
		@email varchar(150),
		@tel nvarchar(50),
		@tel_em nvarchar(50),
		@id_os varchar(50),
		@tel_os varchar(50),
		@nro_os nvarchar(50),
		@id int,
		@id_rp int;
		set @script = N'
					insert into ##grupo_familiar
					select * 
					from openrowset(
					''Microsoft.ACE.OLEDB.16.0'', 
					''Excel 12.0;Database=' + @arch + ';HDR=YES;IMEX=1'', 
					''SELECT * FROM ['+@hoja+'$]''
					);';
		exec sp_executesql @script;
		--usando sp y recorriendo 1 por 1
		set @act = (select min(num_reg) from ##grupo_familiar);
		set @fin = (select max(num_reg) from ##grupo_familiar);

		while @act <= @fin
		begin
			select @nombre = nombre,@apellido = apellido, @tel = cast(tel as varchar),@tel_em = cast(tel_em as varchar),
				   @dni = dni,@fecha = TRY_CONVERT(date,fnac),@email = email,@id_os = id_os,
				   @nro_os = nro_os,@tel_os = tel_os
			from ##grupo_familiar rp where num_reg = @act and TRY_CONVERT(date,fnac) is not null
			and not exists 
				(
					select 1 from socio.socio s where s.dni = rp.dni
				)
			and rp.dni in
				(
					select dni
					from ##grupo_familiar gf
					group by dni
					having count(*) = 1
				)
			if @id_os is not null
			begin
				insert into obra_social_socio(nombre,telefono_emergencia,numero_socio)
				values(@id_os,@tel_os,@nro_os)
				set @id = SCOPE_IDENTITY();
			end
			
			select @id_rp = s.id
			from socio.socio s
			where s.dni = (select r.dni 
							from ##responsable_pago r
							join ##grupo_familiar gf on
							r.id_socio = gf.id_rp
							where gf.num_reg = @act)
			exec socio.altaSocio @nombre = @nombre,
									 @apellido = @apellido,
									 @dni = @dni,
									 @email = @email,
									 @fecha_nacimiento = @fecha,
									 @telefono = @tel,
									 @telefono_emergencia = @tel_em,
									 @id_obra_social_socio = @id,
									 @id_tutor = NULL,
									 @id_grupo_familiar = @id_rp,
									 @responsable_pago = 0,
									 @estado = N'al dia'

			set @act = @act + 1;
			
			
		end
		--select * from #grupo_familiar
		--print 'Importacion existosa'
	end try
	begin catch
		print 'No se pudo completar la importacion ->'+ ERROR_MESSAGE();
	end catch
end
exec socio.Importar_GF @arch = N'C:\Users\diego\Downloads\TPI-2025-1C\TPI-2025-1C\Datos socios.xlsx',@hoja = N'Grupo Familiar'
select * from ##grupo_familiar
select * from ##responsable_pago