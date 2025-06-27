-- Reemplazá NOMBRE_DB con el nombre real de tu base
USE master;
GO

-- Pone la base en modo SINGLE_USER para cerrar todas las conexiones activas
ALTER DATABASE Com2900G11 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

-- Ahora sí, podés eliminarla
DROP DATABASE Com2900G11;
GO