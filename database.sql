-- Script de creación de Base de Datos para HomeTask Smart
-- Compatible con XAMPP MySQL / MariaDB y phpMyAdmin

CREATE DATABASE IF NOT EXISTS smart_home_db;
USE smart_home_db;

-- Tabla de Usuarios
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL, -- Nombre real para mostrar y asignar responsabilidades
    username VARCHAR(100) UNIQUE NOT NULL, -- Correo de login
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
    due_date VARCHAR(10) NOT NULL DEFAULT '2026-05-27', -- Fecha programada (formato YYYY-MM-DD)
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

-- Tabla de Recompensas (Premios)
CREATE TABLE IF NOT EXISTS rewards (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    points INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tabla de Recompensas Canjeadas (Historial de Canjes)
CREATE TABLE IF NOT EXISTS claimed_rewards (
    id INT AUTO_INCREMENT PRIMARY KEY,
    reward_id INT NOT NULL,
    claimed_by VARCHAR(100) NOT NULL,
    points INT NOT NULL,
    claimed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reward_id) REFERENCES rewards(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insertar usuarios iniciales de prueba
INSERT INTO users (name, username, password, role) VALUES 
('Papá', 'papa@hometask.com', 'Password123!', 'padre'),
('Carlos', 'carlos@hometask.com', 'Password123!', 'hijo')
ON DUPLICATE KEY UPDATE username=username;

-- Insertar tareas iniciales de prueba (con fechas reales en Mayo de 2026)
INSERT INTO tasks (title, assignee, time, points, is_completed, due_date) VALUES 
('Sacar la basura', 'Papá', '8:00 PM', 10, 0, '2026-05-21'),
('Regar las plantas', 'Mamá', '6:00 PM', 5, 0, '2026-05-22'),
('Limpiar la cocina', 'Carlos', '9:00 PM', 15, 0, '2026-05-27'),
('Pasear al perro', 'Ana', '4:00 PM', 10, 1, '2026-05-27'),
('Lavar platos', 'Carlos', '2:00 PM', 10, 1, '2026-05-28');

-- Insertar dispositivos iniciales de prueba
INSERT INTO smart_devices (name, is_on, type) VALUES 
('Luces Sala', 1, 'light'),
('Termostato', 0, 'thermostat'),
('Smart TV', 1, 'tv');

-- Insertar recompensas iniciales de prueba
INSERT INTO rewards (title, points) VALUES 
('1 Hora de Videojuegos', 50),
('Ir por un helado familiar', 30),
('Tarde libre de deberes', 100),
('Permiso para dormir tarde', 60),
('Elegir película del domingo', 40);
