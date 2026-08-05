-- Script de migración para emparejamiento de Smartwatch (Wear OS)
-- Ejecuta este código en la pestaña SQL de phpMyAdmin para actualizar la base de datos smart_home_db

USE smart_home_db;

CREATE TABLE IF NOT EXISTS smartwatch_pairing (
    device_id VARCHAR(100) PRIMARY KEY,
    pin_code VARCHAR(6) NOT NULL,
    username VARCHAR(100) DEFAULT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (username) REFERENCES users(username) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
