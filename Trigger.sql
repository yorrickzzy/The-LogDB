
-- 1. Trigger: Automatically create associated records for the project manager.
-- When the ProjectManager_ID is specified in the Projects table, automatically insert a record into the UserProjects table, setting the project manager as the Manager for that project.
DROP TRIGGER IF EXISTS after_project_insert;
DELIMITER $$

CREATE TRIGGER after_project_insert
AFTER INSERT ON Projects
FOR EACH ROW
BEGIN
    IF NEW.ProjectManager_ID IS NOT NULL THEN
        INSERT INTO UserProjects (User_ID, Project_ID, Project_Role)
        VALUES (NEW.ProjectManager_ID, NEW.Project_ID, 'Manager');
    END IF;
END $$

DELIMITER ;

-- 2. Trigger: Task completion time auto-update
-- When the task status changes to Completed, automatically set the Completed_At field to the current time.
DROP TRIGGER IF EXISTS before_task_update;
DELIMITER $$

CREATE TRIGGER before_task_update
BEFORE UPDATE ON Tasks
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Completed' AND OLD.Status != 'Completed' THEN
        SET NEW.Completed_At = CURRENT_TIMESTAMP;
    END IF;
END $$

DELIMITER ;

-- 3.Trigger: Log project status updates
-- When the status in the Projects table is updated, automatically insert a log entry into the Logs table to record the updated status information.
DROP TRIGGER IF EXISTS after_project_update;
DELIMITER $$

CREATE TRIGGER after_project_update
AFTER UPDATE ON Projects
FOR EACH ROW
BEGIN
    IF NEW.Status != OLD.Status THEN
        INSERT INTO Logs (Project_ID, User_ID, Log_Level, Module, Log_Message, Created_At)
        VALUES (NEW.Project_ID, NULL, 'INFO', 'Project Management', 
                CONCAT('Project status changed from ', OLD.Status, ' to ', NEW.Status),
                CURRENT_TIMESTAMP);
    END IF;
END $$

DELIMITER ;

-- 4. Trigger: Automatically send a notification to the task owner
-- When the Assigned_User_ID in the Tasks table changes, automatically insert a notification into the Notifications table.
DROP TRIGGER IF EXISTS after_task_assign;
DELIMITER $$

CREATE TRIGGER after_task_assign
AFTER UPDATE ON Tasks
FOR EACH ROW
BEGIN
    IF NEW.Assigned_User_ID IS NOT NULL AND NEW.Assigned_User_ID != OLD.Assigned_User_ID THEN
        INSERT INTO Notifications (User_ID, Project_ID, Message, Status, Created_At)
        VALUES (NEW.Assigned_User_ID, NEW.Project_ID, 
                CONCAT('You have been assigned to the task: ', NEW.Task_Name),
                'Unread', CURRENT_TIMESTAMP);
    END IF;
END $$

DELIMITER ;

-- 5. Trigger: Automatically update the status of the parent project
-- When the status of all subtasks in a subproject changes to Completed, automatically update the status of the parent project to Completed.
DROP TRIGGER IF EXISTS after_subproject_tasks_update;
DELIMITER $$

CREATE TRIGGER after_subproject_tasks_update
AFTER UPDATE ON Tasks
FOR EACH ROW
BEGIN
    DECLARE remaining_tasks INT;
    IF NEW.Status = 'Completed' THEN
        SELECT COUNT(*) INTO remaining_tasks
        FROM Tasks
        WHERE Project_ID = NEW.Project_ID AND Status != 'Completed';

        IF remaining_tasks = 0 THEN
            UPDATE Projects
            SET Status = 'Completed'
            WHERE Project_ID = NEW.Project_ID;
        END IF;
    END IF;
END $$

DELIMITER ;

-- 6. Trigger: Automatically update the user's last login time
-- When the user logs into the system (e.g., by updating the LastLoginDate), automatically set this field to the current time.
DROP TRIGGER IF EXISTS before_user_login_update;
DELIMITER $$

CREATE TRIGGER before_user_login_update
BEFORE UPDATE ON Users
FOR EACH ROW
BEGIN
    IF NEW.LastLoginDate != OLD.LastLoginDate THEN
        SET NEW.LastLoginDate = CURRENT_TIMESTAMP;
    END IF;
END $$

DELIMITER ;

-- 7. Automatically clean up read notifications
-- When the notification status in the Notifications table is updated to Read and the time exceeds 90 days, automatically delete the notification record.
DROP TRIGGER IF EXISTS after_notification_read;
DELIMITER $$

CREATE TRIGGER after_notification_read
AFTER UPDATE ON Notifications
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Read' AND DATEDIFF(CURRENT_DATE, NEW.Read_At) > 90 THEN
        DELETE FROM Notifications WHERE Notification_ID = NEW.Notification_ID;
    END IF;
END $$

DELIMITER ;

-- 8.Automatically assign default notifications
-- When a user is created, automatically assign a welcome notification to them.
DROP TRIGGER IF EXISTS after_user_insert;
DELIMITER $$

CREATE TRIGGER after_user_insert
AFTER INSERT ON Users
FOR EACH ROW
BEGIN
    INSERT INTO Notifications (User_ID, Message, Status, Created_At)
    VALUES (NEW.User_ID, 'Welcome to the system! Please update your profile.', 'Unread', CURRENT_TIMESTAMP);
END $$

DELIMITER ;

