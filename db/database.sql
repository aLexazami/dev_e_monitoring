-- ============================================================================
-- e_monitoring - Complete Master Database Script
-- Contains: Base Tables, Migrations (Groups 1-4), Staff Fixes, 
--           Security, Project Types, and Foreign Key Constraints.
--
-- HOW TO USE:
--   1. Open phpMyAdmin -> Import tab -> Choose this file -> Go.
--   OR run via MySQL CLI:
--   mysql -u root -p e_monitoring < C:\xampp\htdocs\dev_e_monitoring\config\database.sql
-- ============================================================================

CREATE DATABASE IF NOT EXISTS e_monitoring
  CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE e_monitoring;
SET NAMES utf8mb4;

-- ----------------------------------------------------------------------------
-- 1. CORE TABLES
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('manager', 'supervisor', 'staff') NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    employee_id VARCHAR(20) DEFAULT NULL,
    department VARCHAR(80) DEFAULT NULL,
    contact_number VARCHAR(30) DEFAULT NULL,
    assigned_station VARCHAR(60) DEFAULT NULL,
    shift_schedule VARCHAR(80) DEFAULT NULL,
    last_signin VARCHAR(40) DEFAULT NULL,
    pref_defect_alert TINYINT(1) NOT NULL DEFAULT 1,
    pref_shift_reminder TINYINT(1) NOT NULL DEFAULT 1,
    pref_24h_format TINYINT(1) NOT NULL DEFAULT 0,
    assignment VARCHAR(50) NOT NULL DEFAULT 'Line 1',
    last_active VARCHAR(40) DEFAULT 'Now',
    status VARCHAR(20) NOT NULL DEFAULT 'Active',
    must_change_password TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS production_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    machine_id VARCHAR(50) NOT NULL,
    target_goal INT NOT NULL,
    good_count INT DEFAULT 0,
    ng_count INT DEFAULT 0,
    status ENUM('active', 'paused', 'completed') DEFAULT 'active',
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS defect_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    session_id INT,
    defect_type VARCHAR(100) NOT NULL,
    severity ENUM('low', 'medium', 'high') DEFAULT 'medium',
    reported_by INT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES production_sessions(id) ON DELETE CASCADE,
    FOREIGN KEY (reported_by) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Seed default user accounts (Password for all: password123)
INSERT INTO users (id, username, password, role, full_name, employee_id, department,
                   assigned_station, shift_schedule, last_signin, assignment, last_active, status)
VALUES
(1, 'manager1',    '$2b$10$A7TNEyUrs8vyDo9krn9S9e9Xh2wJ7/JgFbhzcOGkEhZz3huHSRNFe', 'manager',
    'Production Manager', 'MV-0001', 'Production Management', 'All lines',
    'Shift 1 · 06:00 AM – 02:00 PM', 'Today', 'All Lines', 'Now', 'Active'),
(2, 'supervisor1', '$2b$10$A7TNEyUrs8vyDo9krn9S9e9Xh2wJ7/JgFbhzcOGkEhZz3huHSRNFe', 'supervisor',
    'Shift Supervisor', 'MV-0002', 'Production - Line 1', 'ESP32-STN01 – STN04',
    'Shift 1 · 06:00 AM – 02:00 PM', 'Today', 'Line 1', 'Now', 'Active'),
(3, 'staff1',      '$2b$10$A7TNEyUrs8vyDo9krn9S9e9Xh2wJ7/JgFbhzcOGkEhZz3huHSRNFe', 'staff',
    'Line Operator', 'MV-0003', 'Production - Line 1', 'ESP32-STN04',
    'Shift 1 · 06:00 AM – 02:00 PM', 'Today', 'Line 1', 'Now', 'Active')
ON DUPLICATE KEY UPDATE
    password         = VALUES(password),
    employee_id      = VALUES(employee_id),
    department       = VALUES(department),
    assigned_station = VALUES(assigned_station),
    shift_schedule   = VALUES(shift_schedule);

INSERT IGNORE INTO production_sessions (id, machine_id, target_goal, good_count, ng_count, status, created_by) VALUES
(1, 'ESP32-STN04', 120, 71, 3, 'active', 3);

-- ----------------------------------------------------------------------------
-- 2. MASTER DATA & LOOKUPS
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS master_stations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    station_code VARCHAR(30) NOT NULL UNIQUE,
    line_name VARCHAR(30) NOT NULL,
    workstation_name VARCHAR(80) NOT NULL,
    ideal_cycle_sec INT NOT NULL DEFAULT 30,
    rate_per_hr INT NOT NULL DEFAULT 120,
    status VARCHAR(20) NOT NULL DEFAULT 'Online',
    last_calibrated VARCHAR(30) DEFAULT NULL,
    last_seen DATETIME DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO master_stations
 (id, station_code, line_name, workstation_name, ideal_cycle_sec, rate_per_hr, status, last_calibrated) VALUES
(1, 'ESP32-STN01', 'Line 1', 'Injection Molding', 30, 120, 'Online',      'Oct 02, 2026'),
(2, 'ESP32-STN02', 'Line 1', 'Trimming',          30, 120, 'Online',      'Oct 02, 2026'),
(3, 'ESP32-STN03', 'Line 1', 'Assembly',          36, 100, 'Online',      'Oct 03, 2026'),
(4, 'ESP32-STN04', 'Line 1', 'Inspection',        30, 120, 'Online',      'Oct 03, 2026'),
(5, 'ESP32-STN05', 'Line 2', 'Injection Molding', 30, 120, 'Online',      'Oct 01, 2026'),
(6, 'ESP32-STN06', 'Line 2', 'Inspection',        30, 120, 'Online',      'Oct 01, 2026'),
(7, 'ESP32-STN07', 'Line 3', 'Injection Molding', 30, 120, 'Maintenance', 'Sep 28, 2026');

CREATE TABLE IF NOT EXISTS master_project_types (
    id INT AUTO_INCREMENT PRIMARY KEY,
    project_type VARCHAR(100) NOT NULL UNIQUE,
    is_active TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO master_project_types (project_type) VALUES 
('Vent Caps (A2)'), 
('Thailand Socket Cover');

CREATE TABLE IF NOT EXISTS defect_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    count INT NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO defect_categories (id, category_name, count) VALUES
(1, 'Short shot', 0),
(2, 'Scratch',    0),
(3, 'Flash',      0),
(4, 'Crack',      0),
(5, 'Warpage',    0),
(6, 'Other',      0);

CREATE TABLE IF NOT EXISTS master_target_defaults (
    id INT AUTO_INCREMENT PRIMARY KEY,
    oee_target_pct DECIMAL(5,1) NOT NULL DEFAULT 85.0,
    yield_target_pct DECIMAL(5,1) NOT NULL DEFAULT 98.0,
    shift_target_units INT NOT NULL DEFAULT 320,
    shift_length_hours INT NOT NULL DEFAULT 8,
    availability_target_pct DECIMAL(5,1) NOT NULL DEFAULT 92.0,
    performance_target_pct DECIMAL(5,1) NOT NULL DEFAULT 96.0,
    quality_target_pct DECIMAL(5,1) NOT NULL DEFAULT 97.0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO master_target_defaults
 (id, oee_target_pct, yield_target_pct, shift_target_units, shift_length_hours,
  availability_target_pct, performance_target_pct, quality_target_pct) VALUES
(1, 85.0, 98.0, 320, 8, 92.0, 96.0, 97.0);

CREATE TABLE IF NOT EXISTS master_shift_schedule (
    id INT AUTO_INCREMENT PRIMARY KEY,
    shift_name VARCHAR(60) NOT NULL,
    time_range VARCHAR(40) NOT NULL,
    target_units INT NOT NULL DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'Scheduled'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO master_shift_schedule (id, shift_name, time_range, target_units, status) VALUES
(1, 'Shift 1 (Morning)',   '06:00 AM – 02:00 PM', 320, 'Scheduled'),
(2, 'Shift 2 (Afternoon)', '02:00 PM – 10:00 PM', 320, 'Scheduled'),
(3, 'Shift 3 (Night)',     '10:00 PM – 06:00 AM',   0, 'Off');

-- ----------------------------------------------------------------------------
-- 3. DEFECT REPORTS
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS defect_reports (
    id INT AUTO_INCREMENT PRIMARY KEY,
    report_code VARCHAR(20) DEFAULT NULL,
    project_type VARCHAR(100) DEFAULT NULL,
    workstation VARCHAR(100) DEFAULT NULL,
    station VARCHAR(30) DEFAULT 'ESP32-STN04',
    defect_category VARCHAR(100) NOT NULL,
    quantity_rejected INT NOT NULL DEFAULT 1,
    severity VARCHAR(20) NOT NULL DEFAULT 'Minor',
    notes TEXT DEFAULT NULL,
    image_path VARCHAR(255) DEFAULT NULL,
    reported_by VARCHAR(100) DEFAULT NULL,
    reported_by_id INT NULL,
    report_time VARCHAR(20) DEFAULT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'Pending',
    supervisor_comment TEXT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    operator_notes TEXT GENERATED ALWAYS AS (notes) VIRTUAL,
    photo_url VARCHAR(300) GENERATED ALWAYS AS (
                          IF(image_path IS NULL OR image_path = '', NULL,
                             CONCAT('/dev_e_monitoring/', image_path))) VIRTUAL,
    KEY idx_status (status),
    KEY idx_created (created_at),
    KEY idx_reported_by_created (reported_by_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------------------
-- 4. SHIFT & OPERATIONAL RECORDS
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS shift_records (
    id INT AUTO_INCREMENT PRIMARY KEY,
    staff_id INT DEFAULT NULL,
    shift_title VARCHAR(50) NOT NULL,
    shift_date DATE NOT NULL,
    time_start TIME NOT NULL,
    time_end TIME NOT NULL,
    time_range VARCHAR(40) DEFAULT NULL,
    produced_units INT NOT NULL DEFAULT 0,
    good_units INT NOT NULL DEFAULT 0,
    ng_units INT NOT NULL DEFAULT 0,
    rejected_units INT NOT NULL DEFAULT 0,
    pending_units INT NOT NULL DEFAULT 0,
    yield_rate DECIMAL(5,2) NOT NULL DEFAULT 100.00,
    yield_pct DECIMAL(5,1) NOT NULL DEFAULT 100.0,
    status VARCHAR(10) NOT NULL DEFAULT 'OPEN',
    planned_minutes INT DEFAULT NULL,
    run_minutes INT DEFAULT NULL,
    KEY idx_staff (staff_id),
    KEY idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS shift_workstation_yield (
    id INT AUTO_INCREMENT PRIMARY KEY,
    shift_record_id INT NOT NULL,
    station_code VARCHAR(30) NOT NULL,
    workstation_name VARCHAR(80) NOT NULL,
    output_units INT NOT NULL DEFAULT 0,
    ng_units INT NOT NULL DEFAULT 0,
    pending_units INT NOT NULL DEFAULT 0,
    yield_pct DECIMAL(5,1) NOT NULL DEFAULT 100.0,
    is_lowest TINYINT(1) NOT NULL DEFAULT 0,
    KEY idx_shift (shift_record_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS staff_activity_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    staff_id INT NOT NULL,
    log_time TIME NOT NULL,
    log_date DATE DEFAULT NULL,
    log_type VARCHAR(20) NOT NULL,
    details VARCHAR(255) NOT NULL,
    station_id VARCHAR(30) DEFAULT NULL,
    KEY idx_staff (staff_id),
    KEY idx_staff_date (staff_id, log_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------------------
-- 5. SUPERVISOR FLOOR MANAGEMENT
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS supervisor_line_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    session_code VARCHAR(30) NOT NULL,
    status VARCHAR(10) NOT NULL DEFAULT 'RUNNING',
    product_name VARCHAR(80) NOT NULL DEFAULT 'Vent Caps (A2)',
    start_time VARCHAR(20) DEFAULT NULL,
    elapsed_hours INT NOT NULL DEFAULT 0,
    opened_by VARCHAR(80) DEFAULT NULL,
    line_target INT NOT NULL DEFAULT 480,
    station_target INT NOT NULL DEFAULT 120,
    pause_reason VARCHAR(100) DEFAULT NULL,
    started_at DATETIME DEFAULT NULL,
    closed_at DATETIME DEFAULT NULL,
    paused_at DATETIME DEFAULT NULL,
    paused_seconds INT NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS supervisor_station_status (
    id INT AUTO_INCREMENT PRIMARY KEY,
    station_code VARCHAR(30) NOT NULL UNIQUE,
    workstation_name VARCHAR(80) NOT NULL,
    assigned_staff VARCHAR(80) DEFAULT NULL,
    status VARCHAR(10) NOT NULL DEFAULT 'RUNNING',
    good_units INT NOT NULL DEFAULT 0,
    ng_units INT NOT NULL DEFAULT 0,
    target_units INT NOT NULL DEFAULT 120
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS supervisor_hourly_output (
    id INT AUTO_INCREMENT PRIMARY KEY,
    hour_label VARCHAR(20) NOT NULL,
    good_units INT NOT NULL DEFAULT 0,
    ng_units INT NOT NULL DEFAULT 0,
    log_date DATE DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS supervisor_floor_alerts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    alert_type VARCHAR(20) NOT NULL,
    title VARCHAR(150) NOT NULL,
    subtitle VARCHAR(200) DEFAULT NULL,
    alert_time VARCHAR(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------------------
-- 6. SYSTEM SETTINGS, AUDIT, & SECURITY
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS system_settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    plant_name VARCHAR(120) NOT NULL DEFAULT 'Masters Vineyard Enterprise',
    time_zone VARCHAR(60) NOT NULL DEFAULT 'Asia/Manila (UTC+08:00)',
    time_format VARCHAR(30) NOT NULL DEFAULT '12-hour (12:00 PM)',
    alert_defect_30m TINYINT(1) NOT NULL DEFAULT 1,
    alert_line_stop_15m TINYINT(1) NOT NULL DEFAULT 1,
    alert_oee_under_target TINYINT(1) NOT NULL DEFAULT 1,
    alert_station_offline TINYINT(1) NOT NULL DEFAULT 1,
    alert_weekly_summary TINYINT(1) NOT NULL DEFAULT 0,
    inactivity_timeout VARCHAR(20) NOT NULL DEFAULT '30 minutes',
    min_password_len INT NOT NULL DEFAULT 10,
    password_expiry VARCHAR(20) NOT NULL DEFAULT '90 days',
    require_2fa_managers TINYINT(1) NOT NULL DEFAULT 0,
    history_retention VARCHAR(20) NOT NULL DEFAULT '24 months',
    weekly_export_schedule VARCHAR(40) NOT NULL DEFAULT 'Monday, 06:00 AM',
    checkin_interval_sec INT NOT NULL DEFAULT 10,
    offline_threshold_sec INT NOT NULL DEFAULT 60,
    device_api_key VARCHAR(64) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO system_settings (id) VALUES (1);

-- Generate initial device key for ESP32
UPDATE system_settings
   SET device_api_key = SHA2(CONCAT(UUID(), RAND(), NOW()), 256)
 WHERE id = 1 AND (device_api_key IS NULL OR device_api_key = '');

CREATE TABLE IF NOT EXISTS system_settings_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    log_timestamp VARCHAR(40) NOT NULL,
    actor VARCHAR(100) NOT NULL,
    action_description VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS user_access_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    requested_role VARCHAR(20) NOT NULL,
    assignment_line VARCHAR(30) NOT NULL,
    requested_by VARCHAR(100) NOT NULL,
    request_date VARCHAR(30) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS user_access_changes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    log_timestamp VARCHAR(40) NOT NULL,
    actor VARCHAR(100) NOT NULL,
    action_description VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS login_attempts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    ip VARCHAR(45) NOT NULL,
    attempted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_user_time (username, attempted_at),
    KEY idx_ip_time (ip, attempted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------------------
-- 7. MANAGER & ANALYTICS TABLES (Empty Structure for Production Use)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS oee_plant_metrics (
    id INT AUTO_INCREMENT PRIMARY KEY,
    overall_oee DECIMAL(5,1) NOT NULL,
    availability DECIMAL(5,1) NOT NULL,
    performance DECIMAL(5,1) NOT NULL,
    quality DECIMAL(5,1) NOT NULL,
    total_output INT NOT NULL,
    good_units INT NOT NULL,
    ng_units INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS oee_line_performance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    line_name VARCHAR(30) NOT NULL,
    share_pct VARCHAR(40) DEFAULT NULL,
    total_output INT NOT NULL DEFAULT 0,
    availability DECIMAL(5,1) NOT NULL,
    performance DECIMAL(5,1) NOT NULL,
    quality DECIMAL(5,1) NOT NULL,
    oee DECIMAL(5,1) NOT NULL,
    is_lowest TINYINT(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS oee_weekly_trend (
    id INT AUTO_INCREMENT PRIMARY KEY,
    week_label VARCHAR(20) NOT NULL,
    oee_value DECIMAL(5,1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS analytics_daily_yield (
    id INT AUTO_INCREMENT PRIMARY KEY,
    day_label VARCHAR(20) NOT NULL,
    yield_value DECIMAL(5,1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS analytics_root_cause (
    id INT AUTO_INCREMENT PRIMARY KEY,
    defect_type VARCHAR(100) NOT NULL,
    factor_name VARCHAR(100) NOT NULL,
    factor_category VARCHAR(50) NOT NULL,
    multiplier VARCHAR(10) NOT NULL,
    defect_share_pct DECIMAL(5,1) NOT NULL,
    output_share_pct DECIMAL(5,1) NOT NULL,
    KEY idx_defect (defect_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS analytics_report_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    file_format VARCHAR(10) NOT NULL,
    generated_time VARCHAR(40) NOT NULL,
    download_url VARCHAR(255) NOT NULL DEFAULT '#'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------------------
-- 8. FOREIGN KEY RELATIONSHIPS
-- ----------------------------------------------------------------------------
ALTER TABLE staff_activity_logs
    ADD CONSTRAINT fk_activity_user FOREIGN KEY (staff_id) REFERENCES users(id)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE shift_records
    ADD CONSTRAINT fk_shift_staff FOREIGN KEY (staff_id) REFERENCES users(id)
    ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE shift_workstation_yield
    ADD CONSTRAINT fk_wsyield_shift FOREIGN KEY (shift_record_id) REFERENCES shift_records(id)
    ON DELETE CASCADE ON UPDATE CASCADE,
    ADD CONSTRAINT fk_wsyield_station FOREIGN KEY (station_code) REFERENCES master_stations(station_code)
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE supervisor_station_status
    ADD CONSTRAINT fk_status_station FOREIGN KEY (station_code) REFERENCES master_stations(station_code)
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE defect_reports
    ADD CONSTRAINT fk_defect_station FOREIGN KEY (station) REFERENCES master_stations(station_code)
    ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE production_sessions
    ADD CONSTRAINT fk_session_machine FOREIGN KEY (machine_id) REFERENCES master_stations(station_code)
    ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE analytics_root_cause
    ADD CONSTRAINT fk_rootcause_category FOREIGN KEY (defect_type) REFERENCES defect_categories(category_name)
    ON DELETE CASCADE ON UPDATE CASCADE;

-- ----------------------------------------------------------------------------
-- 9. TRIGGERS
-- ----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_defect_reports_code;
DELIMITER $$
CREATE TRIGGER trg_defect_reports_code BEFORE INSERT ON defect_reports
FOR EACH ROW
BEGIN
    IF NEW.report_code IS NULL THEN
        SET NEW.report_code = CONCAT('DR-', LPAD((SELECT COALESCE(MAX(id), 0) + 1 FROM defect_reports), 4, '0'));
    END IF;
END$$
DELIMITER ;