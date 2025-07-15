USE Com2900G11;
GO

create or alter procedure socio.ejecutarImportacionesConDatos
    @ruta_general varchar(255)
as
begin
    set nocount on;

    exec general.limpiarDatosPrueba;

    exec socio.altaCategoria @nombre = 'Menor', @costo_mensual = 10000.00, @edad_min = 0, @edad_max = 12;
    exec socio.altaCategoria @nombre = 'Cadete', @costo_mensual = 15000.00, @edad_min = 13, @edad_max = 17;
    exec socio.altaCategoria @nombre = 'Mayor', @costo_mensual = 25000.00, @edad_min = 18, @edad_max = 120;

    exec general.altaActividad @nombre = 'Futsal', @costo_mensual = 25000.00;
    exec general.altaActividad @nombre = 'Vóley', @costo_mensual = 30000.00;
    exec general.altaActividad @nombre = 'Taekwondo', @costo_mensual = 250000.00;
    exec general.altaActividad @nombre = 'Baile artístico', @costo_mensual = 30000.00;
    exec general.altaActividad @nombre = 'Natación', @costo_mensual = 45000.00;
    exec general.altaActividad @nombre = 'Ajedrez', @costo_mensual = 20000.00;

    exec socio.altaTipoReembolso @descripcion = 'Pago a cuenta';
    exec socio.altaTipoReembolso @descripcion = 'Reembolso al medio de pago';

    exec socio.altaTarifaPileta @tipo = 'Socio', @precio = 25000.00;
    exec socio.altaTarifaPileta @tipo = 'Invitado', @precio = 30000.00;

    declare @ruta_socios varchar(255) = @ruta_general + '\socios.csv';
    declare @ruta_grupo_familiar varchar(255) = @ruta_general + '\grupo-familiar.csv';
    declare @ruta_presentismo varchar(255) = @ruta_general + '\presentismo.csv';
    declare @ruta_pagos_cuotas varchar(255) = @ruta_general + '\pago-cuotas.csv';

    exec socio.importarSociosDesdeArchivo @arch = @ruta_socios;

    exec socio.importarGrupoFamiliarDesdeArchivo @arch = @ruta_grupo_familiar;

    exec socio.importarPresentismoDesdeArchivo @arch = @ruta_presentismo;

    exec socio.AltaFacturaImportacion;

    exec socio.importarPagosCuotasDesdeArchivo @arch = @ruta_pagos_cuotas;
end