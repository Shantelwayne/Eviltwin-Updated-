-- Essential HMDM database tables (minimal set needed for seeding)

CREATE TABLE IF NOT EXISTS userroles (
    id serial NOT NULL CONSTRAINT roles_pr_key PRIMARY KEY,
    name varchar(50) NOT NULL,
    description TEXT,
    superadmin BOOLEAN NOT NULL DEFAULT false
);

CREATE TABLE IF NOT EXISTS users (
    id serial NOT NULL CONSTRAINT users_pr_key PRIMARY KEY,
    login varchar(30) NOT NULL CONSTRAINT login_key UNIQUE,
    email varchar(50),
    name varchar(50),
    password varchar(40) NOT NULL,
    customerid BIGINT,
    userroleid INT,
    passwordreset BOOLEAN NOT NULL DEFAULT FALSE,
    passwordresettoken varchar(40)
);

CREATE TABLE IF NOT EXISTS groups (
    id serial NOT NULL CONSTRAINT groups_pr_key PRIMARY KEY,
    name varchar(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS permissions (
    id serial NOT NULL CONSTRAINT permissions_pr_key PRIMARY KEY,
    name varchar(50) NOT NULL,
    description TEXT,
    superadmin BOOLEAN NOT NULL DEFAULT false
);

-- Insert initial data needed for seeding
INSERT INTO userroles (id, name, description) VALUES (1, 'Super-Admin', 'Can sign in as any user') ON CONFLICT (id) DO NOTHING;
INSERT INTO userroles (id, name, description) VALUES (2, 'Admin', 'Full access to the control panel') ON CONFLICT (id) DO NOTHING;  
INSERT INTO userroles (id, name, description) VALUES (3, 'User', 'Limited access to the control panel') ON CONFLICT (id) DO NOTHING;
INSERT INTO userroles (id, name, description) VALUES (100, 'Observer', 'Read-only access to the control panel') ON CONFLICT (id) DO NOTHING;

INSERT INTO groups (id, name) VALUES (1, 'General') ON CONFLICT (id) DO NOTHING;

INSERT INTO permissions (id, name, description) VALUES (1, 'superadmin', 'Super-administrator functions for the whole system') ON CONFLICT (id) DO NOTHING;
INSERT INTO permissions (id, name, description) VALUES (2, 'settings', 'Access to system settings') ON CONFLICT (id) DO NOTHING;

-- Insert admin user if not exists
INSERT INTO users (id, login, email, name, password) VALUES (1, 'admin', '', 'admin', '21232f297a57a5a743894a0e4a801fc3') ON CONFLICT (login) DO NOTHING;