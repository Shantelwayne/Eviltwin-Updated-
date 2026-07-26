-- Essential HMDM database schema tables
-- Based on Liquibase changelog

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id serial NOT NULL CONSTRAINT users_pr_key PRIMARY KEY,
    login varchar(30) NOT NULL CONSTRAINT login_key UNIQUE,
    email varchar(50),
    name varchar(50),
    password varchar(40) NOT NULL,
    customerId BIGINT,
    userRoleId INT,
    allDevicesAvailable BOOLEAN NOT NULL DEFAULT TRUE,
    allConfigAvailable BOOLEAN NOT NULL DEFAULT TRUE,
    passwordReset BOOLEAN NOT NULL DEFAULT FALSE,
    authToken varchar(40),
    passwordResetToken varchar(40),
    authData TEXT,
    lastLoginFail BIGINT NOT NULL DEFAULT 0,
    twoFactorSecret TEXT,
    twoFactorAccepted BOOLEAN NOT NULL DEFAULT false
);

-- Create userRoles table
CREATE TABLE IF NOT EXISTS userRoles (
    id serial NOT NULL CONSTRAINT roles_pr_key PRIMARY KEY,
    name varchar(50) NOT NULL,
    description TEXT,
    superadmin BOOLEAN NOT NULL DEFAULT false
);

-- Create permissions table
CREATE TABLE IF NOT EXISTS permissions (
    id serial NOT NULL CONSTRAINT permissions_pr_key PRIMARY KEY,
    name varchar(50) NOT NULL,
    description TEXT,
    superadmin BOOLEAN NOT NULL DEFAULT false
);

-- Create userRolePermissions table
CREATE TABLE IF NOT EXISTS userRolePermissions (
    roleId INT NOT NULL REFERENCES userRoles( id ) ON DELETE CASCADE,
    permissionId INT NOT NULL REFERENCES permissions( id ) ON DELETE CASCADE
);

-- Create customers table
CREATE TABLE IF NOT EXISTS customers (
    id serial NOT NULL CONSTRAINT customers_pr_key PRIMARY KEY,
    name varchar(50) NOT NULL,
    description TEXT,
    filesDir TEXT NOT NULL,
    master BOOLEAN NOT NULL DEFAULT false,
    prefix VARCHAR(100),
    registrationTime BIGINT,
    lastLoginTime BIGINT,
    accountType INT NOT NULL DEFAULT 0,
    expiryTime BIGINT,
    deviceLimit INT NOT NULL DEFAULT 3,
    customerStatus VARCHAR(100),
    email varchar(50),
    firstName VARCHAR(100),
    lastName VARCHAR(100),
    language VARCHAR(100),
    inactiveState INT NOT NULL DEFAULT 0,
    pauseState INT NOT NULL DEFAULT 0,
    abandonState INT NOT NULL DEFAULT 0,
    sizeLimit INT NOT NULL DEFAULT 100,
    signupStatus VARCHAR(100) DEFAULT 'active',
    signupToken VARCHAR(100)
);

-- Create groups table  
CREATE TABLE IF NOT EXISTS groups (
    id serial NOT NULL CONSTRAINT groups_pr_key PRIMARY KEY,
    name varchar(100) NOT NULL,
    customerId BIGINT
);

-- Create configurations table
CREATE TABLE IF NOT EXISTS configurations (
    id serial NOT NULL CONSTRAINT configurations_pr_key PRIMARY KEY,
    name varchar(100) NOT NULL,
    description text,
    type int NOT NULL DEFAULT 0,
    password varchar(100),
    customerId BIGINT,
    backgroundColor varchar(20),
    textColor varchar(20),
    backgroundImageUrl varchar(500),
    iconSize TEXT DEFAULT 'SMALL'::TEXT NOT NULL,
    desktopHeader TEXT DEFAULT 'NO_HEADER'::TEXT NOT NULL,
    useDefaultDesignSettings BOOLEAN NOT NULL DEFAULT TRUE,
    qrCodeKey TEXT NOT NULL DEFAULT MD5(RANDOM()::TEXT),
    gps BOOLEAN,
    bluetooth BOOLEAN,
    wifi BOOLEAN,
    mobileData BOOLEAN,
    mainAppId INT,
    eventReceivingComponent VARCHAR(512),
    kioskMode BOOLEAN NOT NULL DEFAULT FALSE,
    contentAppId INT,
    autoUpdate BOOLEAN NOT NULL DEFAULT FALSE,
    blockStatusBar BOOLEAN NOT NULL DEFAULT FALSE,
    systemUpdateType INT NOT NULL DEFAULT 0,
    systemUpdateFrom VARCHAR(10),
    systemUpdateTo VARCHAR(10),
    usbStorage BOOLEAN,
    requestUpdates VARCHAR(20) NOT NULL DEFAULT 'DONOTTRACK',
    pushOptions VARCHAR(20) NOT NULL DEFAULT 'mqttWorker',
    autoBrightness BOOLEAN,
    brightness INT DEFAULT 180,
    manageTimeout BOOLEAN DEFAULT false,
    timeout INT DEFAULT 60,
    lockVolume BOOLEAN DEFAULT false,
    wifiSSID VARCHAR(256),
    wifiPassword VARCHAR(256),
    wifiSecurityType VARCHAR(16),
    passwordMode VARCHAR(50),
    mobileEnrollment BOOLEAN NOT NULL DEFAULT false,
    manageVolume BOOLEAN,
    volume INT,
    showWifi BOOLEAN,
    restrictions TEXT,
    defaultFilePath TEXT NOT NULL DEFAULT '/',
    keepaliveTime INT,
    qrParameters TEXT,
    autostartForeground BOOLEAN,
    disableScreenshots BOOLEAN,
    permissive BOOLEAN,
    kioskExit BOOLEAN DEFAULT true,
    kioskHome BOOLEAN,
    kioskRecents BOOLEAN,
    kioskNotifications BOOLEAN,
    kioskSystemInfo BOOLEAN,
    kioskKeyguard BOOLEAN,
    orientation INT,
    runDefaultLauncher BOOLEAN,
    timeZone VARCHAR(200),
    allowedClasses TEXT,
    newServerUrl TEXT,
    lockSafeSettings BOOLEAN,
    disableLocation BOOLEAN NOT NULL DEFAULT FALSE,
    appPermissions VARCHAR(20) NOT NULL DEFAULT 'GRANTALL',
    displayStatus BOOLEAN NOT NULL DEFAULT false,
    encryptDevice BOOLEAN NOT NULL DEFAULT false,
    downloadUpdates VARCHAR(20) NOT NULL DEFAULT 'UNLIMITED',
    kioskScreenOn BOOLEAN,
    launcherUrl TEXT,
    adminExtras TEXT,
    desktopHeaderTemplate TEXT,
    kioskLockButtons BOOLEAN,
    scheduleAppUpdate BOOLEAN,
    appUpdateFrom VARCHAR(10),
    appUpdateTo VARCHAR(10)
);

-- Add unique constraint to qrCodeKey
ALTER TABLE configurations ADD CONSTRAINT qrCodeKey_uniq UNIQUE (qrCodeKey);

-- Insert initial data
INSERT INTO userRoles (id, name, description, superadmin) VALUES (1, 'Супер-Администратор', 'Всевидящее око Саурона', TRUE) ON CONFLICT (id) DO NOTHING;
INSERT INTO userRoles (id, name, description) VALUES (2, 'Администратор', 'Выполняет функции администратора для одной клиентской записи') ON CONFLICT (id) DO NOTHING;
INSERT INTO userRoles (id, name, description) VALUES (3, 'Пользователь', 'Пользователь для одной клиентской записи') ON CONFLICT (id) DO NOTHING;
INSERT INTO userRoles (id, name, description) VALUES (100, 'Наблюдатель', 'Наблюдатель зорко наблюдает') ON CONFLICT (id) DO NOTHING;

INSERT INTO permissions (id, name, description, superadmin) VALUES (1, 'superadmin', 'Функции супер-администратора всего приложения', TRUE) ON CONFLICT (id) DO NOTHING;
INSERT INTO permissions (id, name, description) VALUES (2, 'settings', 'Имеет доступ к настройкам и видит их в меню') ON CONFLICT (id) DO NOTHING;
INSERT INTO permissions (id, name, description) VALUES (3, 'configurations', 'Имеет доступ к конфигурациям, приложениям и файлам и видит их в меню') ON CONFLICT (id) DO NOTHING;
INSERT INTO permissions (id, name, description) VALUES (4, 'edit_devices', 'Имеет доступ к редактированию и добавлению устройств') ON CONFLICT (id) DO NOTHING;

INSERT INTO userRolePermissions (roleId, permissionId) VALUES (1, 1) ON CONFLICT DO NOTHING;
INSERT INTO userRolePermissions (roleId, permissionId) VALUES (2, 2) ON CONFLICT DO NOTHING;
INSERT INTO userRolePermissions (roleId, permissionId) VALUES (2, 3) ON CONFLICT DO NOTHING;
INSERT INTO userRolePermissions (roleId, permissionId) VALUES (2, 4) ON CONFLICT DO NOTHING;
INSERT INTO userRolePermissions (roleId, permissionId) VALUES (3, 3) ON CONFLICT DO NOTHING;
INSERT INTO userRolePermissions (roleId, permissionId) VALUES (3, 4) ON CONFLICT DO NOTHING;

INSERT INTO customers (name, description, master, filesDir) VALUES ('DEFAULT', 'Default customer account used for managing the application data in PRIVATE usage scenario', FALSE, '') ON CONFLICT (name) DO NOTHING;

INSERT INTO groups (name, customerId) VALUES ('Общая', (SELECT id FROM customers WHERE name = 'DEFAULT')) ON CONFLICT DO NOTHING;

INSERT INTO configurations (name, description, customerId) VALUES ('По умолчанию', 'Базовая конфигурация для всех устройств', (SELECT id FROM customers WHERE name = 'DEFAULT')) ON CONFLICT DO NOTHING;

-- Insert default admin user
INSERT INTO users(login, email, name, password, customerId, userRoleId)
VALUES ('admin', 'admin@localhost.com', 'admin', '21232f297a57a5a743894a0e4a801fc3', (SELECT id FROM customers WHERE name = 'DEFAULT'), 2) ON CONFLICT (login) DO NOTHING;

-- Restart sequences
ALTER SEQUENCE permissions_id_seq RESTART WITH 100;
ALTER SEQUENCE userroles_id_seq RESTART WITH 101;