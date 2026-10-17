<?php
// includes/header.php
require_once __DIR__ . '/../config/app.php';

// Redirect if unauthenticated
if (!isset($_SESSION['user_id'])) {
    header("Location: " . BASE_URL . "/login.php");
    exit();
}

$pageTitle = $pageTitle ?? 'Dashboard';
$userRole  = $_SESSION['role'] ?? 'staff';
$userName  = $_SESSION['full_name'] ?? $_SESSION['username'] ?? 'User';
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= htmlspecialchars($pageTitle); ?> | <?= htmlspecialchars(APP_NAME); ?></title>
    
    <!-- Dynamic CSS Path -->
    <link rel="stylesheet" href="<?= BASE_URL ?>/assets/css/style.css">
</head>
<body>

<nav class="navbar">
    <a href="<?= BASE_URL ?>/index.php" class="brand"><?= htmlspecialchars(APP_NAME); ?></a>
    <div class="user-info">
        <span>Welcome, <strong><?= htmlspecialchars($userName); ?></strong></span>
        <span class="role-badge role-<?= htmlspecialchars(strtolower($userRole)); ?>">
            <?= htmlspecialchars(ucfirst($userRole)); ?>
        </span>
        <a href="<?= BASE_URL ?>/backend/process_logout.php" class="logout-btn">Logout</a>
    </div>
</nav>

<main class="main-container">