-- Drop tables if they already exist to ensure a clean setup
DROP TABLE IF EXISTS activity_log CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS attachments CASCADE;
DROP TABLE IF EXISTS comments CASCADE;
DROP TABLE IF EXISTS task_labels_assignments CASCADE;
DROP TABLE IF EXISTS task_labels CASCADE;
DROP TABLE IF EXISTS tasks CASCADE;
DROP TABLE IF EXISTS user_workspace CASCADE;
DROP TABLE IF EXISTS workspaces CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Users table: storing user data with relevant constraints
CREATE TABLE users (
    user_id VARCHAR(50) PRIMARY KEY NOT NULL,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    avatar_url VARCHAR(255),
    role VARCHAR(50) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

-- Workspaces table: organizing different workspaces
CREATE TABLE workspaces (
    workspace_id VARCHAR(50) PRIMARY KEY NOT NULL,
    name VARCHAR(255) NOT NULL,
    owner_id VARCHAR(50) NOT NULL,
    visibility VARCHAR(20) NOT NULL DEFAULT 'private',
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    CONSTRAINT fk_owner FOREIGN KEY (owner_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- User_Workspace: mapping users to multiple workspaces with roles
CREATE TABLE user_workspace (
    user_workspace_id VARCHAR(50) PRIMARY KEY NOT NULL,
    user_id VARCHAR(50) NOT NULL,
    workspace_id VARCHAR(50) NOT NULL,
    role VARCHAR(50) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_workspace FOREIGN KEY (workspace_id) REFERENCES workspaces(workspace_id) ON DELETE CASCADE
);

-- Tasks table: individual task details
CREATE TABLE tasks (
    task_id VARCHAR(50) PRIMARY KEY NOT NULL,
    workspace_id VARCHAR(50) NOT NULL,
    created_by VARCHAR(50) NOT NULL,
    assigned_to VARCHAR(50),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    due_date DATE,
    priority VARCHAR(20) NOT NULL DEFAULT 'Medium',
    status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    is_favorited BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    CONSTRAINT fk_workspace FOREIGN KEY (workspace_id) REFERENCES workspaces(workspace_id) ON DELETE CASCADE,
    CONSTRAINT fk_creator FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_assigned FOREIGN KEY (assigned_to) REFERENCES users(user_id) ON DELETE SET NULL
);

-- Task_Labels: labels/tags for categorizing tasks
CREATE TABLE task_labels (
    label_id VARCHAR(50) PRIMARY KEY NOT NULL,
    name VARCHAR(255) NOT NULL,
    workspace_id VARCHAR(50) NOT NULL,
    CONSTRAINT fk_workspace_lbl FOREIGN KEY (workspace_id) REFERENCES workspaces(workspace_id) ON DELETE CASCADE
);

-- Task_Labels_Assignments: linking tasks and labels (many-to-many)
CREATE TABLE task_labels_assignments (
    task_label_assignment_id VARCHAR(50) PRIMARY KEY NOT NULL,
    task_id VARCHAR(50) NOT NULL,
    label_id VARCHAR(50) NOT NULL,
    CONSTRAINT fk_task FOREIGN KEY (task_id) REFERENCES tasks(task_id) ON DELETE CASCADE,
    CONSTRAINT fk_label FOREIGN KEY (label_id) REFERENCES task_labels(label_id) ON DELETE CASCADE
);

-- Comments: comments on tasks for collaboration
CREATE TABLE comments (
    comment_id VARCHAR(50) PRIMARY KEY NOT NULL,
    task_id VARCHAR(50) NOT NULL,
    author_id VARCHAR(50) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP,
    CONSTRAINT fk_task_comment FOREIGN KEY (task_id) REFERENCES tasks(task_id) ON DELETE CASCADE,
    CONSTRAINT fk_author FOREIGN KEY (author_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Attachments: files attached to tasks
CREATE TABLE attachments (
    attachment_id VARCHAR(50) PRIMARY KEY NOT NULL,
    task_id VARCHAR(50) NOT NULL,
    file_url VARCHAR(255) NOT NULL,
    filename VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    CONSTRAINT fk_task_attachment FOREIGN KEY (task_id) REFERENCES tasks(task_id) ON DELETE CASCADE
);

-- Notifications: user notifications related to tasks, comments, etc.
CREATE TABLE notifications (
    notification_id VARCHAR(50) PRIMARY KEY NOT NULL,
    user_id VARCHAR(50) NOT NULL,
    type VARCHAR(50) NOT NULL,
    content JSON NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL,
    CONSTRAINT fk_user_notification FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Activity_Log: auditing of activity on tasks
CREATE TABLE activity_log (
    activity_id VARCHAR(50) PRIMARY KEY NOT NULL,
    task_id VARCHAR(50) NOT NULL,
    performed_by VARCHAR(50) NOT NULL,
    activity_type VARCHAR(50) NOT NULL,
    description TEXT NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    CONSTRAINT fk_task_activity FOREIGN KEY (task_id) REFERENCES tasks(task_id) ON DELETE CASCADE,
    CONSTRAINT fk_user_activity FOREIGN KEY (performed_by) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Insert sample seed data for users
INSERT INTO users (user_id, name, email, password_hash, avatar_url, role, created_at, updated_at) VALUES
('u_001', 'Alice Johnson', 'alice@example.com', 'hash_placeholder_1', 'https://picsum.photos/seed/1/200', 'Admin', NOW(), NOW()),
('u_002', 'Bob Smith', 'bob@example.com', 'hash_placeholder_2', 'https://picsum.photos/seed/2/200', 'Team Member', NOW(), NOW()),
('u_003', 'Charlie Lee', 'charlie@example.com', 'hash_placeholder_3', 'https://picsum.photos/seed/3/200', 'Viewer', NOW(), NOW());

-- Insert sample workspaces
INSERT INTO workspaces (workspace_id, name, owner_id, visibility, created_at, updated_at) VALUES
('w_001', 'Design Project', 'u_001', 'private', NOW(), NOW()),
('w_002', 'Development Sprint', 'u_002', 'public', NOW(), NOW());

-- Map users to workspaces
INSERT INTO user_workspace (user_workspace_id, user_id, workspace_id, role, created_at) VALUES
('uw_001', 'u_001', 'w_001', 'Admin', NOW()),
('uw_002', 'u_002', 'w_001', 'Team Member', NOW()),
('uw_003', 'u_003', 'w_002', 'Viewer', NOW());

-- Insert sample tasks
INSERT INTO tasks (task_id, workspace_id, created_by, assigned_to, title, description, due_date, priority, status, is_favorited, created_at, updated_at) VALUES
('t_001', 'w_001', 'u_001', 'u_002', 'Design Homepage', 'Create a modern homepage design', '2024-05-15', 'High', 'In Progress', TRUE, NOW(), NOW()),
('t_002', 'w_002', 'u_002', NULL, 'Implement Login', 'Build authentication module', '2024-05-20', 'Medium', 'Pending', FALSE, NOW(), NOW());

-- Insert sample labels
INSERT INTO task_labels (label_id, name, workspace_id) VALUES
('l_001', 'UI', 'w_001'),
('l_002', 'Backend', 'w_002');

-- Assign labels to tasks
INSERT INTO task_labels_assignments (task_label_assignment_id, task_id, label_id) VALUES
('a_001', 't_001', 'l_001'),
('a_002', 't_002', 'l_002');

-- Sample comments on tasks
INSERT INTO comments (comment_id, task_id, author_id, content, created_at, updated_at) VALUES
('c_001', 't_001', 'u_002', 'Please review the initial design drafts.', NOW(), NOW()),
('c_002', 't_002', 'u_002', 'Authentication module should support OAuth.', NOW(), NOW());

-- Sample attachments
INSERT INTO attachments (attachment_id, task_id, file_url, filename, created_at) VALUES
('att_001', 't_001', 'https://picsum.photos/seed/101/200', 'homepage_draft.png', NOW()),
('att_002', 't_002', 'https://picsum.photos/seed/102/200', 'auth_spec.docx', NOW());

-- Sample notifications
INSERT INTO notifications (notification_id, user_id, type, content, is_read, created_at) VALUES
('n_001', 'u_002', 'Assignment', '{"task_id": "t_001", "message": "You have been assigned a new task."}', FALSE, NOW()),
('n_002', 'u_003', 'Comment', '{"task_id": "t_002", "message": "New comment on your task."}', FALSE, NOW());

-- Sample activity logs
INSERT INTO activity_log (activity_id, task_id, performed_by, activity_type, description, timestamp) VALUES
('a_001', 't_001', 'u_002', 'Status Change', 'Changed status to In Progress', NOW()),
('a_002', 't_002', 'u_002', 'Edit', 'Updated task description', NOW());