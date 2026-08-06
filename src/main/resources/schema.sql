-- Create and select database (change 'vivon' to 'defaultdb' if you prefer)
CREATE DATABASE IF NOT EXISTS vivondb;
USE vivondb;
-- Turn off FK checks so we can drop tables regardless of FK order
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS conversation_members;
DROP TABLE IF EXISTS messages;
DROP TABLE IF EXISTS conversations;
DROP TABLE IF EXISTS users;
SET FOREIGN_KEY_CHECKS = 1;
-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    avatar VARCHAR(255),
    is_online BOOLEAN NOT NULL DEFAULT false
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- Create conversations table (no FK to messages yet)
CREATE TABLE IF NOT EXISTS conversations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    type ENUM('direct', 'group') NOT NULL,
    last_message_id BIGINT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- Create conversation_members table (references conversations + users)
CREATE TABLE IF NOT EXISTS conversation_members (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    conversation_id BIGINT NOT NULL,
    user_id INT NOT NULL,
    role ENUM('member', 'admin', 'owner') DEFAULT 'member',
    UNIQUE KEY unique_member (conversation_id, user_id),
    CONSTRAINT fk_conv_member_conv FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
    CONSTRAINT fk_conv_member_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- Create messages table (references conversations + users)
CREATE TABLE IF NOT EXISTS messages (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    conversation_id BIGINT NOT NULL,
    sender_id INT NOT NULL,
    content TEXT NOT NULL,
    message_type ENUM('text', 'image', 'system') DEFAULT 'text',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    CONSTRAINT fk_message_conv FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
    CONSTRAINT fk_message_sender FOREIGN KEY (sender_id) REFERENCES users(id),
    INDEX idx_conversation_created (conversation_id, created_at),
    INDEX idx_sender (sender_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
-- Now add the last_message FK (created after messages exists)
ALTER TABLE conversations
ADD CONSTRAINT fk_last_message FOREIGN KEY (last_message_id) REFERENCES messages(id) ON DELETE
SET NULL;