-- Script de creación de Base de Datos para HomeTask Smart
-- Compatible con XAMPP MySQL / MariaDB y phpMyAdmin

CREATE DATABASE IF NOT EXISTS hometask_smart;
USE hometask_smart;

-- Tabla de Usuarios
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL, -- Ahora guarda correos electrónicos
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL, -- 'padre' o 'hijo'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla de Tareas (Deberes)
CREATE TABLE IF NOT EXISTS tasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    assignee VARCHAR(50) NOT NULL,
    time VARCHAR(20) NOT NULL,
    points INT NOT NULL,
    is_completed TINYINT(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla de Dispositivos Inteligentes (Domótica)
CREATE TABLE IF NOT EXISTS smart_devices (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    is_on TINYINT(1) DEFAULT 0,
    type VARCHAR(20) NOT NULL, -- 'light', 'thermostat', 'tv'
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insertar usuarios iniciales de prueba (con correos y contraseñas seguras según las nuevas reglas)
INSERT INTO users (username, password, role) VALUES 
('papa@hometask.com', 'Password123!', 'padre'),
('carlos@hometask.com', 'Password123!', 'hijo')
ON DUPLICATE KEY UPDATE username=username;

-- Insertar tareas iniciales de prueba
INSERT INTO tasks (title, assignee, time, points, is_completed) VALUES 
('Sacar la basura', 'Papá', '8:00 PM', 10, 0),
('Regar las plantas', 'Mamá', '6:00 PM', 5, 0),
('Limpiar la cocina', 'Carlos', '9:00 PM', 15, 0),
('Pasear al perro', 'Ana', '4:00 PM', 10, 1),
('Lavar platos', 'Carlos', '2:00 PM', 10, 1);

-- Insertar dispositivos iniciales de prueba
INSERT INTO smart_devices (name, is_on, type) VALUES 
('Luces Sala', 1, 'light'),
('Termostato', 0, 'thermostat'),
('Smart TV', 1, 'tv');
