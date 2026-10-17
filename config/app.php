<?php
// config/app.php

// Ensure environment variables are loaded if helper function exists
if (function_exists('loadEnv')) {
    loadEnv(dirname(__DIR__) . '/.env');
}

// 1. Base URL Routing Constant
if (!defined('BASE_URL')) {
    $subfolder = getenv('LOCAL_SUBFOLDER') ?: 'dev_e_monitoring';
    define('BASE_URL', '/' . trim($subfolder, '/'));
}

// 2. Application Identity Constants
if (!defined('APP_NAME')) {
    define('APP_NAME', getenv('SYSTEM_ACCESS_NAME') ?: 'e-Monitoring System');
}

if (!defined('APP_ENV')) {
    define('APP_ENV', getenv('SYSTEM_FLAG') ?: 'DEV');
}

// 3. Timezone Setting
date_default_timezone_set(getenv('APP_TIMEZONE') ?: 'Asia/Manila');

// 4. Session Cookie Management
if (!function_exists('session_cookie_options')) {
    function session_cookie_options(bool $keep): array {
        $https = !empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off';
        return [
            'lifetime' => $keep ? (30 * 86400) : 0, // Fixed multiplication operator
            'path'     => '/',
            'secure'   => $https,
            'httponly' => true,
            'samesite' => 'Lax'
        ];
    }
}

// 5. Initialize Session securely
if (session_status() === PHP_SESSION_NONE && PHP_SAPI !== 'cli') {
    $sessionName = getenv('SESSION_NAME') ?: 'dev_e_monitoring_session';
    session_name($sessionName);

    ini_set('session.gc_maxlifetime', (string)(30 * 86400)); // Fixed multiplication operator
    session_set_cookie_params(session_cookie_options(!empty($_COOKIE['mv_keep'])));
    session_start();
}