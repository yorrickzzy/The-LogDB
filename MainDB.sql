-- Create the Roles table
CREATE TABLE Roles (
    Role_ID INT AUTO_INCREMENT PRIMARY KEY,
    Role_Name VARCHAR(50) UNIQUE NOT NULL,
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert predefined roles
INSERT INTO Roles (Role_Name) VALUES
('Project Manager'),
('Root'),
('Viewer');

-- Create the Users table
CREATE TABLE Users (
    User_ID INT AUTO_INCREMENT PRIMARY KEY,
    User_Name VARCHAR(50) NOT NULL,
    Role_ID INT NOT NULL,
    Email VARCHAR(254) UNIQUE NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Updated_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    LastLoginDate TIMESTAMP NULL,
    FOREIGN KEY (Role_ID) REFERENCES Roles(Role_ID)
);

-- Create the Projects table
CREATE TABLE Projects (
    Project_ID INT AUTO_INCREMENT PRIMARY KEY,
    Project_Name VARCHAR(100) NOT NULL,
    Parent_Project_ID INT NULL,
    ProjectManager_ID INT NULL,
    StartDate DATE,
    EndDate DATE,
    Status ENUM('Planning', 'In Progress', 'Completed', 'On Hold', 'Canceled') DEFAULT 'Planning',
    Project_Description TEXT,
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Updated_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (Parent_Project_ID) REFERENCES Projects(Project_ID) ON DELETE SET NULL,
    FOREIGN KEY (ProjectManager_ID) REFERENCES Users(User_ID) ON DELETE SET NULL
);

-- Create the Subprojects table
CREATE TABLE Subprojects (
    Subproject_ID INT AUTO_INCREMENT PRIMARY KEY,
    Project_ID INT NOT NULL,
    Subproject_Name VARCHAR(100) NOT NULL,
    Description TEXT,
    StartDate DATE,
    EndDate DATE,
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (Project_ID) REFERENCES Projects(Project_ID) ON DELETE CASCADE
);

-- Create the UserProjects table
CREATE TABLE UserProjects (
    User_ID INT NOT NULL,
    Project_ID INT NOT NULL,
    Project_Role ENUM('Contributor', 'Manager', 'Viewer') NOT NULL,
    Assigned_Date DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (User_ID, Project_ID),
    FOREIGN KEY (User_ID) REFERENCES Users(User_ID) ON DELETE CASCADE,
    FOREIGN KEY (Project_ID) REFERENCES Projects(Project_ID) ON DELETE CASCADE
);

-- Create the Logs table
CREATE TABLE Logs (
    Log_ID BIGINT AUTO_INCREMENT PRIMARY KEY,
    Project_ID INT NOT NULL,
    User_ID INT NULL,
    Log_Level ENUM('INFO', 'WARNING', 'ERROR', 'DEBUG', 'CRITICAL') DEFAULT 'INFO',
    Module VARCHAR(100),
    Log_Message TEXT NOT NULL,
    AdditionalData JSON,
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (Project_ID) REFERENCES Projects(Project_ID) ON DELETE CASCADE,
    FOREIGN KEY (User_ID) REFERENCES Users(User_ID) ON DELETE SET NULL,
    INDEX idx_project_id (Project_ID),
    INDEX idx_user_id (User_ID),
    INDEX idx_log_level (Log_Level)
);

-- Create the AuditLogs table
CREATE TABLE AuditLogs (
    Audit_ID BIGINT AUTO_INCREMENT PRIMARY KEY,
    User_ID INT NULL,
    Action_Type VARCHAR(50) NOT NULL,
    Action_Details TEXT,
    Timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    IP_Address VARCHAR(45),
    FOREIGN KEY (User_ID) REFERENCES Users(User_ID) ON DELETE SET NULL,
    INDEX idx_user_id (User_ID),
    INDEX idx_action_type (Action_Type)
);

-- Create the Notifications table
CREATE TABLE Notifications (
    Notification_ID INT AUTO_INCREMENT PRIMARY KEY,
    User_ID INT NOT NULL,
    Project_ID INT NULL,
    Message TEXT NOT NULL,
    Status ENUM('Unread', 'Read') DEFAULT 'Unread',
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Read_At TIMESTAMP NULL,
    FOREIGN KEY (User_ID) REFERENCES Users(User_ID) ON DELETE CASCADE,
    FOREIGN KEY (Project_ID) REFERENCES Projects(Project_ID) ON DELETE SET NULL,
    INDEX idx_user_id (User_ID),
    INDEX idx_status (Status)
);

-- Create the Tasks table
CREATE TABLE Tasks (
    Task_ID INT AUTO_INCREMENT PRIMARY KEY,
    Project_ID INT NOT NULL,
    Assigned_User_ID INT NULL,
    Task_Name VARCHAR(100) NOT NULL,
    Description TEXT,
    Priority ENUM('Low', 'Medium', 'High', 'Critical') DEFAULT 'Medium',
    Status ENUM('Not Started', 'In Progress', 'Completed', 'Blocked') DEFAULT 'Not Started',
    Created_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Due_Date DATE,
    Completed_At TIMESTAMP NULL,
    FOREIGN KEY (Project_ID) REFERENCES Projects(Project_ID) ON DELETE CASCADE,
    FOREIGN KEY (Assigned_User_ID) REFERENCES Users(User_ID) ON DELETE SET NULL,
    INDEX idx_assigned_user (Assigned_User_ID),
    INDEX idx_status (Status),
    INDEX idx_priority (Priority)
);
