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

// Conectar a 'smart_home_db'
$databases = ["smart_home_db"];
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
        $name = isset($data['name']) ? trim($data['name']) : '';
        $user = isset($data['username']) ? trim($data['username']) : '';
        $pass = isset($data['password']) ? $data['password'] : '';
        $role = isset($data['role']) ? $data['role'] : '';

        if (empty($name) || empty($user) || empty($pass) || empty($role)) {
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
            $stmt = $db->prepare("INSERT INTO users (name, username, password, role) VALUES (?, ?, ?, ?)");
            $stmt->execute([$name, $user, $pass, $role]);
            echo json_encode(["success" => true]);
        } catch (Exception $e) {
            echo json_encode(["error" => $e->getMessage()]);
        }
        break;

    case 'validate_login':
        $user = isset($data['username']) ? trim($data['username']) : '';
        $pass = isset($data['password']) ? $data['password'] : '';

        try {
            $stmt = $db->prepare("SELECT name, username, password, role FROM users WHERE LOWER(username) = ? AND password = ?");
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
            $stmt = $db->query("SELECT name, username, role FROM users");
            $users = [];
            while ($row = $stmt->fetch()) {
                $users[] = [
                    "name" => $row['name'],
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
            $stmt = $db->query("SELECT id, title, assignee, time, points, is_completed, due_date, priority FROM tasks");
            $tasks = [];
            while ($row = $stmt->fetch()) {
                $tasks[] = [
                    "id" => (string)$row['id'],
                    "title" => $row['title'],
                    "assignee" => $row['assignee'],
                    "time" => $row['time'],
                    "points" => (int)$row['points'],
                    "isCompleted" => (int)$row['is_completed'] === 1,
                    "date" => $row['due_date'],
                    "priority" => isset($row['priority']) ? $row['priority'] : 'media'
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
        $date = isset($data['due_date']) ? $data['due_date'] : '2026-05-27';
        $priority = isset($data['priority']) ? $data['priority'] : 'media';

        try {
            $stmt = $db->prepare("INSERT INTO tasks (title, assignee, time, points, is_completed, due_date, priority) VALUES (?, ?, ?, ?, 0, ?, ?)");
            $stmt->execute([$title, $assignee, $time, $points, $date, $priority]);
            $insertId = $db->lastInsertId();
            echo json_encode([
                "id" => (string)$insertId,
                "title" => $title,
                "assignee" => $assignee,
                "time" => $time,
                "points" => $points,
                "isCompleted" => false,
                "date" => $date,
                "priority" => $priority
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

    case 'update_task':
        $id = isset($data['id']) ? (int)$data['id'] : 0;
        $title = isset($data['title']) ? $data['title'] : '';
        $assignee = isset($data['assignee']) ? $data['assignee'] : '';
        $points = isset($data['points']) ? (int)$data['points'] : 10;
        $time = isset($data['time']) ? $data['time'] : '';
        $date = isset($data['due_date']) ? $data['due_date'] : '2026-05-27';
        $priority = isset($data['priority']) ? $data['priority'] : 'media';

        try {
            $stmt = $db->prepare("UPDATE tasks SET title = ?, assignee = ?, points = ?, time = ?, due_date = ?, priority = ? WHERE id = ?");
            $stmt->execute([$title, $assignee, $points, $time, $date, $priority, $id]);
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

    case 'sync_weather':
        $lat = isset($data['latitude']) ? floatval($data['latitude']) : 19.4326;
        $lon = isset($data['longitude']) ? floatval($data['longitude']) : -99.1332;

        try {
            $weatherUrl = "https://api.open-meteo.com/v1/forecast?latitude={$lat}&longitude={$lon}&current_weather=true";
            $ctx = stream_context_create(['http' => ['timeout' => 3]]);
            $response = @file_get_contents($weatherUrl, false, $ctx);
            
            $isRaining = false;
            $temp = 20;
            $weatherCode = 0;

            if ($response) {
                $weatherData = json_decode($response, true);
                if (isset($weatherData['current_weather'])) {
                    $curr = $weatherData['current_weather'];
                    $temp = $curr['temperature'];
                    $weatherCode = intval($curr['weathercode']);
                    
                    $rainCodes = [51, 53, 55, 61, 63, 65, 80, 81, 82, 95, 96, 99];
                    if (in_array($weatherCode, $rainCodes)) {
                        $isRaining = true;
                    }
                }
            }

            $weatherDesc = "Despejado";
            $weatherEmoji = "☀️";
            if ($isRaining) {
                $weatherDesc = "Lluvioso";
                $weatherEmoji = "🌧️";
            } elseif ($weatherCode >= 1 && $weatherCode <= 3) {
                $weatherDesc = "Parcialmente Nublado";
                $weatherEmoji = "⛅";
            }

            $stmt = $db->query("SELECT id, title, assignee, time, points, is_completed, due_date FROM tasks");
            $tasks = $stmt->fetchAll();

            $outdoorKeywords = ['regar', 'plantas', 'perro', 'jardin', 'basura', 'patio', 'exterior', 'dog', 'trash', 'garden', 'lawn'];
            $indoorKeywords = ['limpiar', 'cocina', 'platos', 'lavar', 'aspirar', 'ordenar', 'organizar', 'pieza', 'cuarto', 'ropa'];

            $updatedTasks = [];
            foreach ($tasks as $task) {
                $titleLower = strtolower($task['title']);
                $newPriority = 'media';

                $isOutdoor = false;
                foreach ($outdoorKeywords as $kw) {
                    if (strpos($titleLower, $kw) !== false) {
                        $isOutdoor = true;
                        break;
                    }
                }

                $isIndoor = false;
                if (!$isOutdoor) {
                    foreach ($indoorKeywords as $kw) {
                        if (strpos($titleLower, $kw) !== false) {
                            $isIndoor = true;
                            break;
                        }
                    }
                }

                if ($isOutdoor) {
                    $newPriority = $isRaining ? 'baja' : 'alta';
                } elseif ($isIndoor) {
                    $newPriority = $isRaining ? 'alta' : 'media';
                } else {
                    $newPriority = 'media';
                }

                $updateStmt = $db->prepare("UPDATE tasks SET priority = ? WHERE id = ?");
                $updateStmt->execute([$newPriority, $task['id']]);

                $updatedTasks[] = [
                    "id" => (string)$task['id'],
                    "title" => $task['title'],
                    "assignee" => $task['assignee'],
                    "time" => $task['time'],
                    "points" => (int)$task['points'],
                    "isCompleted" => (int)$task['is_completed'] === 1,
                    "date" => $task['due_date'],
                    "priority" => $newPriority
                ];
            }

            echo json_encode([
                "success" => true,
                "weather" => [
                    "temp" => $temp,
                    "code" => $weatherCode,
                    "description" => $weatherDesc,
                    "emoji" => $weatherEmoji,
                    "isRaining" => $isRaining
                ],
                "tasks" => $updatedTasks
            ]);
        } catch (Exception $e) {
            echo json_encode(["error" => $e->getMessage()]);
        }
        break;

    case 'send_family_notification':
        $title = isset($data['title']) ? trim($data['title']) : '';
        $body = isset($data['body']) ? trim($data['body']) : '';

        if (empty($title) || empty($body)) {
            echo json_encode(["error" => "Parametros de notificacion incompletos"]);
            break;
        }

        try {
            $stmt = $db->prepare("INSERT INTO notifications (title, body) VALUES (?, ?)");
            $stmt->execute([$title, $body]);
            $notifId = $db->lastInsertId();

            $logMsg = "[" . date('Y-m-d H:i:s') . "] NOTIFICATION: {$title} - {$body}\n";
            @file_put_contents(__DIR__ . '/notifications.log', $logMsg, FILE_APPEND);

            $firebaseStatus = "No configurado (archivo service_account.json ausente)";
            $saPath = __DIR__ . '/service_account.json';
            
            if (file_exists($saPath)) {
                $sa = json_decode(file_get_contents($saPath), true);
                if ($sa && isset($sa['project_id'])) {
                    $projectId = $sa['project_id'];
                    $jwtToken = helper_generate_fcm_token($sa);
                    if ($jwtToken) {
                        $fcmUrl = "https://fcm.googleapis.com/v1/projects/{$projectId}/messages:send";
                        $payload = [
                            "message" => [
                                "topic" => "family",
                                "notification" => [
                                    "title" => $title,
                                    "body" => $body
                                ],
                                "data" => [
                                    "click_action" => "FLUTTER_NOTIFICATION_CLICK"
                                ]
                            ]
                        ];

                        $ch = curl_init();
                        curl_setopt($ch, CURLOPT_URL, $fcmUrl);
                        curl_setopt($ch, CURLOPT_POST, true);
                        curl_setopt($ch, CURLOPT_HTTPHEADER, [
                            "Authorization: Bearer {$jwtToken}",
                            "Content-Type: application/json"
                        ]);
                        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
                        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
                        curl_setopt($ch, CURLOPT_TIMEOUT, 5);
                        $fcmResponse = curl_exec($ch);
                        curl_close($ch);
                        
                        if ($fcmResponse) {
                            $firebaseStatus = "Enviado con exito a Firebase. Respuesta: " . $fcmResponse;
                        } else {
                            $firebaseStatus = "Fallo al enviar a Firebase (CURL error)";
                        }
                    } else {
                        $firebaseStatus = "Error generando token OAuth2 de Firebase (revisa formato de JWT)";
                    }
                } else {
                    $firebaseStatus = "Formato de archivo service_account.json incorrecto";
                }
            }

            echo json_encode([
                "success" => true,
                "id" => $notifId,
                "title" => $title,
                "body" => $body,
                "firebase_status" => $firebaseStatus
            ]);
        } catch (Exception $e) {
            echo json_encode(["error" => $e->getMessage()]);
        }
        break;

    case 'get_notifications':
        try {
            $stmt = $db->query("SELECT id, title, body, created_at FROM notifications ORDER BY id DESC LIMIT 50");
            $notifs = $stmt->fetchAll();
            echo json_encode($notifs);
        } catch (Exception $e) {
            echo json_encode(["error" => $e->getMessage()]);
        }
        break;

    case 'generate_pairing_code':
        $deviceId = isset($data['device_id']) ? trim($data['device_id']) : '';
        if (empty($deviceId)) {
            echo json_encode(["error" => "ID de dispositivo vacío"]);
            break;
        }
        try {
            $pin = sprintf("%04d", rand(0, 9999));
            $expiresAt = date('Y-m-d H:i:s', strtotime('+5 minutes'));

            $stmt = $db->prepare("INSERT INTO smartwatch_pairing (device_id, pin_code, username, expires_at) 
                                  VALUES (?, ?, NULL, ?) 
                                  ON DUPLICATE KEY UPDATE pin_code = ?, username = NULL, expires_at = ?");
            $stmt->execute([$deviceId, $pin, $expiresAt, $pin, $expiresAt]);

            echo json_encode(["success" => true, "pin" => $pin]);
        } catch (Exception $e) {
            echo json_encode(["error" => $e->getMessage()]);
        }
        break;

    case 'link_pairing_code':
        $pin = isset($data['pin']) ? trim($data['pin']) : '';
        $user = isset($data['username']) ? trim($data['username']) : '';

        if (empty($pin) || empty($user)) {
            echo json_encode(["error" => "Parámetros incompletos"]);
            break;
        }

        try {
            $stmt = $db->prepare("SELECT device_id FROM smartwatch_pairing 
                                  WHERE pin_code = ? AND expires_at > NOW() AND username IS NULL");
            $stmt->execute([$pin]);
            $row = $stmt->fetch();

            if ($row) {
                $deviceId = $row['device_id'];
                $stmtUpdate = $db->prepare("UPDATE smartwatch_pairing SET username = ? WHERE device_id = ? AND pin_code = ?");
                $stmtUpdate->execute([$user, $deviceId, $pin]);
                echo json_encode(["success" => true, "message" => "Vinculación exitosa"]);
            } else {
                echo json_encode(["success" => false, "message" => "PIN inválido o expirado"]);
            }
        } catch (Exception $e) {
            echo json_encode(["error" => $e->getMessage()]);
        }
        break;

    case 'check_pairing_status':
        $deviceId = isset($data['device_id']) ? trim($data['device_id']) : '';
        if (empty($deviceId)) {
            echo json_encode(["error" => "ID de dispositivo vacío"]);
            break;
        }

        try {
            $stmt = $db->prepare("SELECT username FROM smartwatch_pairing WHERE device_id = ? AND expires_at > NOW()");
            $stmt->execute([$deviceId]);
            $row = $stmt->fetch();

            if ($row && !empty($row['username'])) {
                $stmtUser = $db->prepare("SELECT name, username, role FROM users WHERE LOWER(username) = ?");
                $stmtUser->execute([strtolower($row['username'])]);
                $userData = $stmtUser->fetch();
                
                if ($userData) {
                    echo json_encode(["success" => true, "linked" => true, "user" => $userData]);
                } else {
                    echo json_encode(["success" => false, "linked" => false, "message" => "Usuario no encontrado"]);
                }
            } else {
                echo json_encode(["success" => true, "linked" => false]);
            }
        } catch (Exception $e) {
            echo json_encode(["error" => $e->getMessage()]);
        }
        break;

    default:
        echo json_encode(["error" => "Accion no valida: " . $action]);
        break;
}

function helper_generate_fcm_token($sa) {
    if (!isset($sa['private_key']) || !isset($sa['client_email']) || !isset($sa['token_uri'])) {
        return null;
    }

    $header = json_encode(['alg' => 'RS256', 'typ' => 'JWT']);
    $now = time();
    $payload = json_encode([
        'iss' => $sa['client_email'],
        'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
        'aud' => $sa['token_uri'],
        'exp' => $now + 3600,
        'iat' => $now
    ]);

    $base64UrlHeader = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($header));
    $base64UrlPayload = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($payload));

    $signature = '';
    $success = openssl_sign(
        $base64UrlHeader . "." . $base64UrlPayload,
        $signature,
        $sa['private_key'],
        'SHA256'
    );

    if (!$success) {
        return null;
    }

    $base64UrlSignature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($signature));
    $jwt = $base64UrlHeader . "." . $base64UrlPayload . "." . $base64UrlSignature;

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $sa['token_uri']);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query([
        'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        'assertion' => $jwt
    ]));
    curl_setopt($ch, CURLOPT_TIMEOUT, 5);
    $res = curl_exec($ch);
    curl_close($ch);

    if ($res) {
        $resData = json_decode($res, true);
        if (isset($resData['access_token'])) {
            return $resData['access_token'];
        }
    }
    return null;
}
