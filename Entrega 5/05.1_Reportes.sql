/*
    Consigna: Creacion de Reportes
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


--REPORTE 1
create or alter procedure general.ver_morosos
    @fecha1 date,
    @fecha2 date
as
begin
    with morosos as (
        select
            s.id as socio,
            s.nombre,
            s.apellido,
            MONTH(fc.fecha_emision) as mes_incumplido,
            count(*) over (partition by s.id) as total_incumplido
        from socio.socio s
        join socio.cuota c on s.id = c.id_socio
        join socio.factura_cuota fc on fc.id_cuota = c.id
        left join socio.pago p on fc.id = p.id_factura_cuota
        left join socio.nota_credito nc on nc.id_factura_origen = fc.id
        where (p.fecha_pago is null or fc.fecha_vencimiento_2 < p.fecha_pago)
          and fc.fecha_vencimiento_2 between @fecha1 and @fecha2
          and nc.id is null
    )
    select
        'Morosos recurrentes' as Reporte,
        @fecha1 as periodo_inicio,
        @fecha2 as periodo_fin,
        socio,
        nombre,
        apellido,
        mes_incumplido,
        total_incumplido,
        rank() over (order by total_incumplido desc) as ranking
    from morosos
    where total_incumplido >= 2
    order by ranking, socio, mes_incumplido;
end
go


--REPORTE 2
create or alter procedure general.ingresos_acumulados
as
begin
	with ingreso_mes(actividad,mes,ingresos) as
	(
		select a.nombre,MONTH(p.fecha_pago) as mes,sum(a.costo_mensual) as ingresos
		from general.actividad a 
		join socio.inscripcion_actividad ia on
		a.id = ia.id_actividad 
		join socio.cuota c on
		c.id = ia.id_cuota 
		join socio.factura_cuota fc on
		fc.id_cuota = c.id 
		join socio.pago p on
		fc.id = p.id_factura_cuota
		where p.fecha_pago is not null
		group by a.nombre, month(p.fecha_pago)
	) 

	select actividad,mes,
		   (
				select sum(ingresos)
				from ingreso_mes im2
				where im2.actividad = im1.actividad
				and im2.mes <= im1.mes
		   )as ingreso_acumulado
	from ingreso_mes im1
	order by actividad,mes
end
go


--REPORTE 3
create or alter procedure general.inasistencia_alternada
as
begin
	select
		cat.nombre as categoria,
		a.nombre as actividad,
		count(distinct s.id) as total_socios,
		count(*) as total_inasistencias
	from general.presentismo p
	join general.clase c on
	c.id = p.id_clase
	join socio.categoria cat on
	c.id_categoria = cat.id
	join general.actividad a on
	a.id = c.id_actividad
	join socio.socio s on
	s.id = p.id_socio
	where p.tipo_asistencia in ('A','J')
	group by cat.nombre,a.nombre
	order by total_inasistencias desc;
end
go


--REPORTE 4
create or alter procedure general.inasistencia
as
begin
	select s.nro_socio, s.nombre,s.apellido, datediff(year,s.fecha_nacimiento,getdate())as edad, cat.nombre as categoria,a.nombre as actividad
	from socio.socio s 
	join general.presentismo p on
	p.id_socio = s.id
	join general.clase c on
	c.id = p.id_clase
	join socio.categoria cat on
	c.id_categoria = cat.id
	join general.actividad a on
	a.id = c.id_actividad
	where p.tipo_asistencia in ('A','J')
	group by s.nro_socio, s.nombre,s.apellido, datediff(year,s.fecha_nacimiento,getdate()), cat.nombre,a.nombre
end
go