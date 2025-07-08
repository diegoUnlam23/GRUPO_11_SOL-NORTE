use Com2900G11;
go

--PRESIDENTE
grant control on database::Com2900G11 to presidente;

--VICEPRESIDENTE
grant control on database::Com2900G11 to vicepresidente;
deny delete on database::Com2900G11 to vicepresidente;

--VOCAL
grant select on database::Com2900G11 to vocal;

--SECRETARIO
grant update on database::Com2900G11 to secretario;

--ADMINISTRADOR MOROSIDAD
grant execute on general.ver_morosos to admin_morosidad;
grant select on socio.factura_cuota to admin_morosidad;
grant execute on socio.actualizarEstadoSocio to admin_morosidad;



--ADMINISTRADOR COBRANZA
grant execute on socio.altaPago to admin_cobranza;
grant execute on socio.altaReembolso to admin_cobranza;
grant execute on socio.ModificacionReembolso to admin_cobranza;
grant execute on socio.procesarReintegroLluvia to admin_cobranza;
grant control on socio.pago to admin_cobranza;
grant control on socio.reembolso to admin_cobranza;



--ADMINISTRADOR FACTURACION
grant control on socio.factura_cuota to admin_facturacion;
grant control on socio.item_factura_cuota to admin_facturacion;
grant execute on socio.AltaFacturaCuota to admin_facturacion;
grant execute on socio.AltaItemFacturaCuota	 to admin_facturacion;
grant execute on socio.AltaFacturaExtra to admin_facturacion;
grant control on socio.factura_extra to admin_facturacion;
grant control on socio.item_factura_extra to admin_facturacion;



--ADMINISTRADOR SOCIOS
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
	select s.id, a.nombre
	from socio.socio s
	join socio.cuota c on
	c.id_socio = s.id
	join socio.inscripcion_actividad ia on
	ia.id_cuota = c.id 
	join general.actividad a on
	ia.id_actividad = a.id;
go


--SOCIOS WEB
grant select on socio.ver_grupoFamiliar to socios_web;
grant select on socio.ver_cuota to socios_web;
grant select on socio.ver_actividades to socios_web;
grant execute on socio.bajaSocioDeGrupoFamiliar to socios_web;
grant execute on socio.altaInscripcionActividad to socios_web;
grant execute on socio.altaRegistroPileta to socios_web;

