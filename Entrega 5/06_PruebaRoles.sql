USE Com2900G11;
GO

-- Crear logins y usuarios para cada rol (solo para entorno de prueba)
-- Es importante que estos logins existan en el servidor o serán creados aquí

-- Presidente
CREATE LOGIN usr_presidente WITH PASSWORD = 'Test1234!';
CREATE USER usr_presidente FOR LOGIN usr_presidente;
ALTER ROLE presidente ADD MEMBER usr_presidente;

-- Vicepresidente
CREATE LOGIN usr_vicepresidente WITH PASSWORD = 'Test1234!';
CREATE USER usr_vicepresidente FOR LOGIN usr_vicepresidente;
ALTER ROLE vicepresidente ADD MEMBER usr_vicepresidente;

-- Vocal
CREATE LOGIN usr_vocal WITH PASSWORD = 'Test1234!';
CREATE USER usr_vocal FOR LOGIN usr_vocal;
ALTER ROLE vocal ADD MEMBER usr_vocal;

-- Secretario
CREATE LOGIN usr_secretario WITH PASSWORD = 'Test1234!';
CREATE USER usr_secretario FOR LOGIN usr_secretario;
ALTER ROLE secretario ADD MEMBER usr_secretario;

-- Socios Web
CREATE LOGIN usr_socios_web WITH PASSWORD = 'Test1234!';
CREATE USER usr_socios_web FOR LOGIN usr_socios_web;
ALTER ROLE socios_web ADD MEMBER usr_socios_web;

-- Admin Socio
CREATE LOGIN usr_admin_socio WITH PASSWORD = 'Test1234!';
CREATE USER usr_admin_socio FOR LOGIN usr_admin_socio;
ALTER ROLE admin_socio ADD MEMBER usr_admin_socio;

-- Jefe Tesoreria
CREATE LOGIN usr_jefe_tesoreria WITH PASSWORD = 'Test1234!';
CREATE USER usr_jefe_tesoreria FOR LOGIN usr_jefe_tesoreria;
ALTER ROLE jefe_tesoreria ADD MEMBER usr_jefe_tesoreria;

-- Admin Cobranza
CREATE LOGIN usr_admin_cobranza WITH PASSWORD = 'Test1234!';
CREATE USER usr_admin_cobranza FOR LOGIN usr_admin_cobranza;
ALTER ROLE admin_cobranza ADD MEMBER usr_admin_cobranza;

-- Admin Morosidad
CREATE LOGIN usr_admin_morosidad WITH PASSWORD = 'Test1234!';
CREATE USER usr_admin_morosidad FOR LOGIN usr_admin_morosidad;
ALTER ROLE admin_morosidad ADD MEMBER usr_admin_morosidad;

-- Admin Facturacion
CREATE LOGIN usr_admin_facturacion WITH PASSWORD = 'Test1234!';
CREATE USER usr_admin_facturacion FOR LOGIN usr_admin_facturacion;
ALTER ROLE admin_facturacion ADD MEMBER usr_admin_facturacion;

GO

