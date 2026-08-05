-- Ejecuta estas consultas en la pestaña SQL de phpMyAdmin para actualizar tu base de datos existente

USE smart_home_db;

-- 1. Añadir la columna de prioridad a la tabla de tareas (deberes)
ALTER TABLE tasks ADD COLUMN priority VARCHAR(20) NOT NULL DEFAULT 'media';

-- 2. Crear la tabla de notificaciones para el historial familiar local
CREATE TABLE IF NOT EXISTS notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
