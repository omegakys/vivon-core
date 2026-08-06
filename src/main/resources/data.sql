-- Mock data for chat application schema
-- Insert users (keeping existing data)
INSERT IGNORE INTO users (username, email, password, avatar, is_online)
VALUES (
        'Snevs',
        'blabla@',
        '$2a$10$FO4k9CqYocbZDk5NSMTMCOlGPDRtvp8soLeX0ZeTvp6xau.TY4xzK',
        'placeholder1.png',
        1
    ),
    -- password = 1234
    (
        'Mås',
        'test@ok.com',
        '$2a$10$H1uL6WqqkfAYmGuL6Bb8tuV69PBnFu6yN80.tKyxHasGzyHxvny4y',
        'placeholder2.png',
        0
    ),
    -- password = lol
    (
        'BjörnBoy',
        'mail',
        '$2a$10$JyHHmOdhzBSNfDcSsNNv/uT/uEi1BU6amnBZtisEaQo4Vk6LhVFlO',
        'placeholder3.png',
        1
    ),
    -- password = pass
    (
        'Emma',
        'emma@example.com',
        '$2a$10$abc123xyz',
        'placeholder4.png',
        1
    ),
    (
        'Alex',
        'alex@test.com',
        '$2a$10$def456uvw',
        'placeholder5.png',
        0
    ),
    (
        'Sophie',
        'sophie@mail.com',
        '$2a$10$ghi789rst',
        'placeholder6.png',
        1
    );
-- Insert conversations (DMs and group chats)
INSERT IGNORE INTO conversations (id, name, type)
VALUES (1, NULL, 'direct'),
    -- DM between Snevs and Mås
    (2, NULL, 'direct'),
    -- DM between Snevs and BjörnBoy
    (3, 'Weekend Plans', 'group'),
    -- Group chat
    (4, 'Work Team', 'group'),
    -- Another group chat
    (5, NULL, 'direct'),
    -- DM between Emma and Alex
    (6, 'Gaming Squad', 'group');
-- Gaming group
-- Insert conversation members
INSERT IGNORE INTO conversation_members (conversation_id, user_id, role)
VALUES -- Conversation 1: Snevs and Mås DM
    (1, 1, 'member'),
    (1, 2, 'member'),
    -- Conversation 2: Snevs and BjörnBoy DM
    (2, 1, 'member'),
    (2, 3, 'member'),
    -- Conversation 3: Weekend Plans group
    (3, 1, 'owner'),
    (3, 2, 'member'),
    (3, 3, 'admin'),
    (3, 4, 'member'),
    -- Conversation 4: Work Team group
    (4, 1, 'admin'),
    (4, 4, 'owner'),
    (4, 5, 'member'),
    (4, 6, 'member'),
    -- Conversation 5: Emma and Alex DM
    (5, 4, 'member'),
    (5, 5, 'member'),
    -- Conversation 6: Gaming Squad
    (6, 1, 'member'),
    (6, 3, 'owner'),
    (6, 5, 'admin'),
    (6, 6, 'member');
-- Insert messages
INSERT IGNORE INTO messages (
        conversation_id,
        sender_id,
        content,
        message_type,
        created_at
    )
VALUES -- Conversation 1: Snevs and Mås DM
    (
        1,
        2,
        'Hey, what is up?',
        'text',
        '2025-06-01 10:00:00'
    ),
    (
        1,
        1,
        'Not much, just chilling.',
        'text',
        '2025-06-01 10:05:00'
    ),
    (
        1,
        2,
        'You coming to the event?',
        'text',
        '2025-06-02 14:30:00'
    ),
    (
        1,
        1,
        'Absolutely! I''ll be there.',
        'text',
        '2025-06-02 14:35:00'
    ),
    (
        1,
        2,
        'Great! See you there 👍',
        'text',
        '2025-06-02 14:40:00'
    ),
    -- Conversation 2: Snevs and BjörnBoy DM
    (
        2,
        3,
        'Got the files you sent. Thanks!',
        'text',
        '2025-06-03 09:15:00'
    ),
    (
        2,
        1,
        'No problem! Let me know if you need anything else.',
        'text',
        '2025-06-03 09:20:00'
    ),
    (
        2,
        3,
        'Will do. The project looks good so far.',
        'text',
        '2025-06-03 11:45:00'
    ),
    -- Conversation 3: Weekend Plans group
    (
        3,
        1,
        'Welcome everyone to the weekend planning group!',
        'system',
        '2025-06-01 08:00:00'
    ),
    (
        3,
        1,
        'So what should we do this weekend?',
        'text',
        '2025-06-01 08:01:00'
    ),
    (
        3,
        2,
        'How about we go hiking?',
        'text',
        '2025-06-01 08:15:00'
    ),
    (
        3,
        4,
        'I''m up for hiking! 🥾',
        'text',
        '2025-06-01 08:20:00'
    ),
    (
        3,
        3,
        'Count me in! What time?',
        'text',
        '2025-06-01 08:25:00'
    ),
    (
        3,
        1,
        'Let''s meet at 9 AM at the park entrance',
        'text',
        '2025-06-01 08:30:00'
    ),
    -- Conversation 4: Work Team group
    (
        4,
        4,
        'Team meeting at 2 PM today',
        'text',
        '2025-06-04 13:00:00'
    ),
    (
        4,
        1,
        'I''ll be there',
        'text',
        '2025-06-04 13:05:00'
    ),
    (
        4,
        5,
        'Can we make it 2:30? I have another call',
        'text',
        '2025-06-04 13:10:00'
    ),
    (
        4,
        6,
        'That works for me too',
        'text',
        '2025-06-04 13:12:00'
    ),
    (
        4,
        4,
        'Sure, 2:30 it is!',
        'text',
        '2025-06-04 13:15:00'
    ),
    -- Conversation 5: Emma and Alex DM
    (
        5,
        4,
        'Hey Alex! How was your presentation?',
        'text',
        '2025-06-05 16:00:00'
    ),
    (
        5,
        5,
        'It went really well! Thanks for asking 😊',
        'text',
        '2025-06-05 16:30:00'
    ),
    (
        5,
        4,
        'That''s awesome! Want to grab coffee later?',
        'text',
        '2025-06-05 16:35:00'
    ),
    -- Conversation 6: Gaming Squad
    (
        6,
        3,
        'Gaming session tonight at 8 PM?',
        'text',
        '2025-06-06 17:00:00'
    ),
    (
        6,
        1,
        'I''m in! What are we playing?',
        'text',
        '2025-06-06 17:05:00'
    ),
    (
        6,
        5,
        'How about that new co-op game?',
        'text',
        '2025-06-06 17:10:00'
    ),
    (
        6,
        6,
        'Perfect! I''ve been wanting to try it',
        'text',
        '2025-06-06 17:15:00'
    ),
    (
        6,
        3,
        'Sounds like a plan! See you all at 8',
        'text',
        '2025-06-06 17:20:00'
    );
-- Update conversations with last_message_id
UPDATE conversations
SET last_message_id = 5
WHERE id = 1;
-- Mås's "Great! See you there 👍"
UPDATE conversations
SET last_message_id = 8
WHERE id = 2;
-- BjörnBoy's "Will do. The project looks good so far."
UPDATE conversations
SET last_message_id = 14
WHERE id = 3;
-- Snevs's "Let's meet at 9 AM at the park entrance"
UPDATE conversations
SET last_message_id = 19
WHERE id = 4;
-- Emma's "Sure, 2:30 it is!"
UPDATE conversations
SET last_message_id = 22
WHERE id = 5;
-- Emma's "That's awesome! Want to grab coffee later?"
UPDATE conversations
SET last_message_id = 27
WHERE id = 6;
-- BjörnBoy's "Sounds like a plan! See you all at 8"