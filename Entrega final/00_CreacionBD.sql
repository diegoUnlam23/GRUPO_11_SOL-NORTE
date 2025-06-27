/*
    Consigna: Crear la base de datos para el proyecto
    Fecha de entrega: 24/06/2025
    Número de comisión: 2900
    Número de grupo: 11
    Nombre de la materia: Bases de Datos Aplicadas
    Integrantes:
        - Costanzo, Marcos Ezequiel - 40955907
        - Sanchez, Diego Mauricio - 46361081
*/

-- Elimina la base si ya existe para poder crearla limpia
IF DB_ID('Com2900G11') IS NOT NULL
BEGIN
    ALTER DATABASE Com2900G11 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Com2900G11;
END
GO

-- Crea la base de datos
CREATE DATABASE Com2900G11;
GO

-- Cambia el contexto a la base recién creada
USE Com2900G11;
GO


-- Creación de Base de Datos
create database Com2900G11;
go

use Com2900G11;
go