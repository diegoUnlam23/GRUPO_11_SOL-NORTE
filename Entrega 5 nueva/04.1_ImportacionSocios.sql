/*
    Consigna: Importar socios desde un archivo CSV  
    Fecha de entrega: 08/07/2025
    Número de comisión: 2900
    Número de grupo: 11
    Nombre de la materia: Bases de Datos Aplicadas
    Integrantes:
        - Costanzo, Marcos Ezequiel - 40955907
        - Sanchez, Diego Mauricio - 46361081
*/

USE Com2900G11;
GO

-- Habilitamos las consulta Ad Hoc para importar los datos de excel
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
go


CREATE OR ALTER PROCEDURE socio.importarSociosDesdeArchivo
    @arch VARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    -- Tabla temporal para los datos importados
    CREATE TABLE ##responsable_pago
    (
        id_socio    VARCHAR(20),
        nombre      VARCHAR(100),
        apellido    VARCHAR(100),
        dni         INT,
        email       VARCHAR(150),
        fnac        VARCHAR(100),
        tel         VARCHAR(100),
        tel_em      VARCHAR(100),
        id_os       VARCHAR(150),
        nro_os      VARCHAR(50),
        tel_os      VARCHAR(50)
    );
    
    -- Tabla temporal para procesar los registros válidos
    CREATE TABLE #procesar
    (
        RowNum INT IDENTITY(1,1),
        id_socio VARCHAR(20),
        nombre VARCHAR(100),
        apellido VARCHAR(100),
        dni INT,
        email VARCHAR(150),
        fnac DATE,
        tel VARCHAR(100),
        tel_em VARCHAR(100),
        id_os VARCHAR(150),
        nro_os VARCHAR(50),
        tel_os VARCHAR(50)
    );
    
    DECLARE @script NVARCHAR(MAX);
    DECLARE @current_row INT = 1, @max_row INT;
    
    -- Importar datos
    SET @script = N'
    BULK INSERT ##responsable_pago
    FROM '''+ @arch +'''
    WITH
    (
        fieldterminator ='';'',
        rowterminator = ''\n'',
        codepage = ''ACP'',
        FIRSTROW = 2
    )';
    
    EXEC sp_executesql @script;
    
    -- Filtrar y cargar registros válidos en la tabla de procesamiento
    INSERT INTO #procesar (id_socio, nombre, apellido, dni, email, fnac, tel, tel_em, id_os, nro_os, tel_os)
    SELECT 
        LTRIM(RTRIM(id_socio)), 
        LTRIM(RTRIM(nombre)), 
        LTRIM(RTRIM(apellido)), 
        dni, 
        LTRIM(RTRIM(email)), 
        TRY_PARSE(fnac AS date USING 'es-AR'),
        LTRIM(RTRIM(tel)), 
        LTRIM(RTRIM(tel_em)), 
        LTRIM(RTRIM(id_os)), 
        LTRIM(RTRIM(nro_os)), 
        LTRIM(RTRIM(tel_os))
    FROM ##responsable_pago
    WHERE TRY_PARSE(fnac AS date USING 'es-AR') IS NOT NULL
    AND NOT EXISTS (SELECT 1 FROM socio.socio s WHERE s.dni = ##responsable_pago.dni)
    AND dni IN (
        SELECT dni 
        FROM ##responsable_pago 
        GROUP BY dni 
        HAVING COUNT(*) = 1
    );
    
    -- Obtener el rango de filas a procesar
    SELECT @max_row = MAX(RowNum) FROM #procesar;
    
    -- Procesar cada registro
    WHILE @current_row <= @max_row
    BEGIN
        DECLARE @nro_socio VARCHAR(10), @nombre VARCHAR(150), @apellido VARCHAR(150);
        DECLARE @dni INT, @fecha DATE, @email VARCHAR(150), @tel NVARCHAR(50);
        DECLARE @tel_em NVARCHAR(50), @id_os VARCHAR(50), @tel_os VARCHAR(50), @nro_os VARCHAR(50);
        DECLARE @id INT;
        
        -- Obtener los datos de la fila actual
        SELECT 
            @nro_socio = id_socio,
            @nombre = nombre,
            @apellido = apellido,
            @dni = dni,
            @email = email,
            @fecha = fnac,
            @tel = tel,
            @tel_em = tel_em,
            @id_os = id_os,
            @nro_os = nro_os,
            @tel_os = tel_os
        FROM #procesar
        WHERE RowNum = @current_row;
        
        -- Insertar en obra_social_socio
        INSERT INTO obra_social_socio(nombre, telefono_emergencia, numero_socio)
        VALUES(@id_os, @tel_os, @nro_os);
        
        SET @id = SCOPE_IDENTITY();
        
        -- Insertar el socio
        EXEC socio.altaSocio 
            @nro_socio = @nro_socio,
            @nombre = @nombre,
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
            @estado = 'Activo',
            @importacion = 1;
        
        -- Pasar a la siguiente fila
        SET @current_row = @current_row + 1;
    END
    
    -- Eliminar tablas temporales
    DROP TABLE ##responsable_pago;
    DROP TABLE #procesar;
END