/*
    Consigna: Crear los esquemas necesarios para el proyecto
    Fecha de entrega: 24/06/2025
    Número de comisión: 2900
    Número de grupo: 11
    Nombre de la materia: Bases de Datos Aplicadas
    Integrantes:
        - Costanzo, Marcos Ezequiel - 40955907
        - Sanchez, Diego Mauricio - 46361081
*/

USE Com2900G11;
GO

-- Crear esquema 'general' si no existe
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'general')
BEGIN
    EXEC('CREATE SCHEMA general');
END
GO

-- Crear esquema 'socio' si no existe
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'socio')
BEGIN
    EXEC('CREATE SCHEMA socio');
END
GO