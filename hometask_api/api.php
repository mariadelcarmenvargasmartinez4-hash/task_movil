<?php
// Habilitar CORS para permitir peticiones desde Flutter Web (navegador)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Content-Type: application/json; charset=UTF-8");

// Finalizar la petición de manera limpia si es del tipo pre-vuelo (OPTIONS)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

// Configuración de la base de datos MySQL (XAMPP por defecto)
$host = "127.0.0.1";
$username = "root";
$password = "";

// Intentar conectar a 'smart_home_db' (visto en tu phpMyAdmin) o a 'hometask_smart'
$databases = ["smart_home_db", "hometask_smart"];
$db = null;
$conn_error = "";

foreach ($databases as $db_name) {
    try {
        $db = new PDO("mysql:host={$host};dbname={$db_name};charset=utf8", $username, $password);
        $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        $db->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
        break; // Conexión exitosa, salir del bucle
    } catch (PDOException $exception) {
        $conn_error = $exception->getMessage();
    }
}

if (!$db) {
    echo json_encode(["error" => "Error de conexión de base de datos: " . $conn_error]);
    exit();
}

// Obtener datos del cuerpo de la petición POST en formato JSON
$data = json_decode(file_get_contents("php://input"), true);
if (!$data) {
    // Respaldo para parámetros estándar GET/POST
    $data = $_REQUEST;
}

$action = isset($data['action']) ? $data['action'] : '';

switch ($action) {
    case 'get_users':
        try {
            $stmt = $db->query("SELECT username, password, role FROM users");
            echo json_encode($stmt->fetchAll());
        } catch (Exception $e) {
            echo json_encode(["error" => $e->getMessage()]);
        }
        break;

    case 'register_user':
        $user = isset($data['username']) ? trim($data['username']) : '';
        $pass = isset($data['password']) ? $data['password'] : '';
        $role = isset($data['role']) ? $data['role'] : '';

        if (empty($user) || empty($pass) || empty($role)) {
            echo json_encode(["error" => "Parámetros incompletos"]);
            break;
        }

        try {
            // Verificar si el usuario ya existe
            $stmt = $db->prepare("SELECT id FROM users WHERE LOWER(username) = ?");
            $stmt->execute([strtolower($user)]);
            if ($stmt->fetch()) {
                echo json_encode(["success" => false, "message" => "El usuario ya existe"]);
                break;
            }

            // Insertar el usuario
            $stmt = $db->prepare("INSERT INTO users (username, password, role) VALUES (?, ?, ?)");
            $stmt->execute([$user, $pass, $role]);
            echo json_encode(["success" => true]);
        } catch (Exception $e) {
            echo json_encode(["error" => $e->getMessage()]);
        }
        break;

    case 'validate_login':
        $user = isset($data['username']) ? trim($data['username']) : '';
        $pass = isset($data['password']) ? $data['password'] : '';

        try {
            $stmt = $db->prepare("SELECT username, password, role FROM users WHERE LOWER(username) = ? AND password = ?");
            $stmt->execute([strtolower($user), $pass]);
            $userData = $stmt->fetch();
            if ($userData) {
                echo json_encode(["success" => true, "user" => $userData]);
            } else {
                echo json_encode(["success" => false, "message" => "Credenciales incorrectas"]);
            }
        } catch (Exception $e) {
            echo json_encode(["error" => $e->getMessage()]);
        }
        break;

    case 'get_users':
        try {
            $stmt = $db->query("SELECT username, role FROM users");
            $users = [];
            while ($row = $stmt->fetch()) {
                $users[] = [
                    "username" => $row['username'],
                    "role" => $row['role']
                ];
            }
            echo json_encode($users);
        } catch (Exception $e) {
            echo json_encode(["error" => $e->getMessage()]);
        }
        break;

    case 'get_tasks':
        try {
            $stmt = $db->query("SELECT id, title, assignee, time, points, is_completed FROM tasks");
            $tasks = [];
            while ($row = $stmt->fetch()) {
                $tasks[] = [
                    "id" => (string)$row['id'],
                    "title" => $row['title'],
                    "assignee" => $row['assignee'],
                    "time" => $row['time'],
                    "points" => (int)$row['points'],
                    "isCompleted" => (int)$row['is_completed'] === 1
                ];
            }
            echo json_encode($tasks);
        } catch (Exception $e) {
            echo json_encode(["error" => $e->getMessage()]);
        }
        break;

    case 'add_task':
        $title = isset($data['title']) ? $data['title'] : '';
        $assignee = isset($data['assignee']) ? $data['assignee'] : '';
        $points = isset($data['points']) ? (int)$data['points'] : 10;
        $time = isset($data['time']) ? $data['time'] : '';

        try {
            $stmt = $db->prepare("INSERT INTO tasks (title, assignee, time, points, is_completed) VALUES (?, ?, ?, ?, 0)");
            $stmt->execute([$title, $assignee, $time, $points]);
            $insertId = $db->lastInsertId();
            echo json_encode([
                "id" => (string)$insertId,
                "title" => $title,
                "assignee" => $assignee,
                "time" => $time,
                "points" => $points,
                "isCompleted" => false
            ]);
        } catch (Exception $e) {
            echo json_encode(["error" => $e->getMessage()]);
        }
        break;

    case 'update_task_completion':
        $id = isset($data['id']) ? (int)$data['id'] : 0;
        $isCompleted = isset($data['is_completed']) ? (int)$data['is_completed'] : 0;

        try {
            $stmt = $db->prepare("UPDATE tasks SET is_completed = ? WHERE id = ?");
            $stmt->execute([$isCompleted, $id]);
            echo json_encode(["success" => true]);
        } catch (Exception $e) {
            echo json_encode(["error" => $e->getMessage()]);
        }
        break;

    case 'delete_task':
        $id = isset($data['id']) ? (int)$data['id'] : 0;

        try {
            $stmt = $db->prepare("DELETE FROM tasks WHERE id = ?");
            $stmt->execute([$id]);
            echo json_encode(["success" => true]);
        } catch (Exception $e) {
            echo json_encode(["error" => $e->getMessage()]);
        }
        break;

    case 'get_devices':
        try {
            $stmt = $db->query("SELECT id, name, is_on, type FROM smart_devices");
            $devices = [];
            while ($row = $stmt->fetch()) {
                $devices[] = [
                    "id" => (string)$row['id'],
                    "name" => $row['name'],
                    "isOn" => (int)$row['is_on'] === 1,
                    "type" => $row['type']
                ];
            }
            echo json_encode($devices);
        } catch (Exception $e) {
            echo json_encode(["error" => $e->getMessage()]);
        }
        break;

    case 'update_device_status':
        $id = isset($data['id']) ? (int)$data['id'] : 0;
        $isOn = isset($data['is_on']) ? (int)$data['is_on'] : 0;

        try {
            $stmt = $db->prepare("UPDATE smart_devices SET is_on = ? WHERE id = ?");
            $stmt->execute([$isOn, $id]);
            echo json_encode(["success" => true]);
        } catch (Exception $e) {
            echo json_encode(["error" => $e->getMessage()]);
        }
        break;

    case 'get_rewards':
        try {
            $stmt = $db->query("SELECT id, title, points FROM rewards");
            $rewards = [];
            while ($row = $stmt->fetch()) {
                $rewards[] = [
                    "id" => (string)$row['id'],
                    "title" => $row['title'],
                    "points" => (int)$row['points']
                ];
            }
            echo json_encode($rewards);
        } catch (Exception $e) {
            echo json_encode(["error" => $e->getMessage()]);
        }
        break;

    case 'add_reward':
        $title = isset($data['title']) ? $data['title'] : '';
        $points = isset($data['points']) ? (int)$data['points'] : 50;

        try {
            $stmt = $db->prepare("INSERT INTO rewards (title, points) VALUES (?, ?)");
            $stmt->execute([$title, $points]);
            $insertId = $db->lastInsertId();
            echo json_encode([
                "id" => (string)$insertId,
                "title" => $title,
                "points" => $points
            ]);
        } catch (Exception $e) {
            echo json_encode(["error" => $e->getMessage()]);
        }
        break;

    case 'delete_reward':
        $id = isset($data['id']) ? (int)$data['id'] : 0;

        try {
            $stmt = $db->prepare("DELETE FROM rewards WHERE id = ?");
            $stmt->execute([$id]);
            echo json_encode(["success" => true]);
        } catch (Exception $e) {
            echo json_encode(["error" => $e->getMessage()]);
        }
        break;

    case 'claim_reward':
        $reward_id = isset($data['reward_id']) ? (int)$data['reward_id'] : 0;
        $claimed_by = isset($data['claimed_by']) ? trim($data['claimed_by']) : '';
        $points = isset($data['points']) ? (int)$data['points'] : 0;

        try {
            $stmt = $db->prepare("INSERT INTO claimed_rewards (reward_id, claimed_by, points) VALUES (?, ?, ?)");
            $stmt->execute([$reward_id, $claimed_by, $points]);
            $insertId = $db->lastInsertId();
            echo json_encode([
                "id" => (string)$insertId,
                "rewardId" => (string)$reward_id,
                "claimedBy" => $claimed_by,
                "points" => $points
            ]);
        } catch (Exception $e) {
            echo json_encode(["error" => $e->getMessage()]);
        }
        break;

    case 'get_claimed_rewards':
        try {
            $stmt = $db->query("SELECT cr.id, cr.reward_id, r.title, cr.claimed_by, cr.points, cr.claimed_at FROM claimed_rewards cr JOIN rewards r ON cr.reward_id = r.id");
            $claimed = [];
            while ($row = $stmt->fetch()) {
                $claimed[] = [
                    "id" => (string)$row['id'],
                    "rewardId" => (string)$row['reward_id'],
                    "title" => $row['title'],
                    "claimedBy" => $row['claimed_by'],
                    "points" => (int)$row['points'],
                    "claimedAt" => $row['claimed_at']
                ];
            }
            echo json_encode($claimed);
        } catch (Exception $e) {
            echo json_encode(["error" => $e->getMessage()]);
        }
        break;

    default:
        echo json_encode(["error" => "Accion no valida: " . $action]);
        break;
}
