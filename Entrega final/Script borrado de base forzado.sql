-- Reemplazá NOMBRE_DB con el nombre real de tu base
USE master;
GO

-- Pone la base en modo SINGLE_USER para cerrar todas las conexiones activas
ALTER DATABASE Com2900G11 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

-- Ahora sí, podés eliminarla
DROP DATABASE Com2900G11;
GO

USE master;
GO

-- Ver conexiones activas
SELECT
    session_id,
    login_name,
    host_name,
    program_name,
    status
FROM sys.dm_exec_sessions
WHERE database_id = DB_ID('Com2900G11');

KILL 84;

DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql += 'DROP PROCEDURE [' + SCHEMA_NAME(schema_id) + '].[' + name + '];' + CHAR(13)
FROM sys.procedures;

EXEC sp_executesql @sql;