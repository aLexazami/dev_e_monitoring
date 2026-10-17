<?php
require_once __DIR__ . '/app.php';

// Prevent session warnings if session is already active
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

/**
 * Helper function to load environment variables from .env file
 */
function loadEnv(string $path): void {
    if (!file_exists($path)) {
        return;
    }

    $lines = file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        $line = trim($line);
        // Skip empty lines or comments
        if ($line === '' || strpos($line, '#') === 0) {
            continue;
        }

        if (strpos($line, '=') !== false) {
            list($name, $value) = explode('=', $line, 2);
            $name = trim($name);
            $value = trim($value);

            // Strip quotes if present (e.g., DB_PASSWORD="secret")
            $value = trim($value, '"\'');

            if (!array_key_exists($name, $_SERVER) && !array_key_exists($name, $_ENV)) {
                putenv(sprintf('%s=%s', $name, $value));
                $_ENV[$name] = $value;
                $_SERVER[$name] = $value;
            }
        }
    }
}

// Load .env from the project root directory
loadEnv(dirname(__DIR__) . '/.env');

// Enable exception reporting for MySQLi
mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

// Fetch parameters from environment variables with safe fallbacks
$host   = getenv('DB_HOST') ?: '127.0.0.1';
$user   = getenv('DB_USERNAME') ?: 'root';
$pass   = getenv('DB_PASSWORD') !== false ? getenv('DB_PASSWORD') : '';
$dbname = getenv('DB_DATABASE') ?: 'e_monitoring';
$port   = (int)(getenv('DB_PORT') ?: 3306);

try {
    $conn = new mysqli($host, $user, $pass, $dbname, $port);
    $conn->set_charset("utf8mb4");
} catch (mysqli_sql_exception $e) {
    die("<div style='font-family:Arial; padding:20px; background:#fff3f3; color:#721c24; border:1px solid #f5c6cb; border-radius:5px;'>
        <h3>Database Connection Failure</h3>
        <p><strong>Error:</strong> " . htmlspecialchars($e->getMessage()) . "</p>
        <p>Please check your <code>.env</code> file settings or verify that the database exists in phpMyAdmin.</p>
    </div>");
}