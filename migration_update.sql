-- Ejecuta estas consultas en la pestaña SQL de phpMyAdmin para actualizar tu base de datos existente

USE smart_home_db;

-- 1. Añadir la columna de nombre real a la tabla de usuarios
ALTER TABLE users ADD COLUMN name VARCHAR(100) NOT NULL DEFAULT 'Usuario' AFTER id;

-- Actualizar los nombres de los usuarios de prueba
UPDATE users SET name = 'Papá' WHERE username = 'papa@hometask.com';
UPDATE users SET name = 'Carlos' WHERE username = 'carlos@hometask.com';

-- 2. Añadir la columna de fecha límite a la tabla de tareas (deberes)
ALTER TABLE tasks ADD COLUMN due_date VARCHAR(10) NOT NULL DEFAULT '2026-05-27' AFTER is_completed;
