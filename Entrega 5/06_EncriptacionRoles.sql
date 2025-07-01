/*
    Consigna: Creacion de Roles y Encriptacion de datos
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

/*create table general.roles
(
	id		int primary key identity(1,1),
	area	varchar(25) check(area in ('Tesoreria','Socios','Autoridades')),
	rol		varchar(30) collate modern_spanish_ci_ai
);*/

create role presidente;
create role vicepresidente;
create role vocal;
create role secretario;
create role socios_web;
create role admin_socio;
create role jefe_tesoreria;
create role admin_cobranza;
create role admin_morosidad;
create role admin_facturacion;




grant control on database::Com2900G11 to presidente;

grant control on database::Com2900G11 to vicepresidente;
deny delete on database::Com2900G11 to vicepresidente;

grant select on database::Com2900G11 to vocal;

grant update on database::Com2900G11 to secretario;


grant execute on general.ver_morosos to admin_morosidad;
grant select on socio.factura to admin_morosidad;
grant update on socio.socio to admin_morosidad;

grant control on socio.pago to admin_morosidad;
grant control on socio.reembolso to admin_morosidad;


grant control on socio.factura_cuota to admin_facturacion;
grant control on socio.item_factura_cuota to admin_facturacion;
grant control on socio.factura_extra to admin_facturacion;
grant control on socio.item_factura_extra to admin_facturacion;


grant control on socio.socio to admin_socio;
grant control on socio.tutor to admin_socio;
grant control on socio.invitado to admin_socio;


go


create or alter view socio.ver_grupoFamiliar
with schemabinding
as
	select id,nombre,apellido
	from socio.socio s
	where s.id = s.id_grupo_familiar;
go

create or alter view socio.ver_cuota
with schemabinding
as
	select c.id,monto_total
	from socio.socio s
	join socio.cuota c on
	c.id_socio = s.id
go

create or alter view socio.ver_actividades
with schemabinding
as
	select a.nombre
	from socio.socio s
	join socio.cuota c on
	c.id_socio = s.id
	join socio.inscripcion_actividad ia on
	ia.id_cuota = c.id 
	join general.actividad a on
	ia.id_actividad = a.id;
go

grant select on socio.ver_grupoFamiliar to socios_web;
grant select on socio.ver_cuota to socios_web;
grant select on socio.ver_actividades to socios_web;
grant execute on socio.altaInscripcionActividad to socios_web;




