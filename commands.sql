-- Create the 'commands' table to store command names and descriptions
CREATE TABLE IF NOT EXISTS `commands` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `command` VARCHAR(255) NOT NULL,
    `commandText` VARCHAR(255) DEFAULT 'No description provided'
);

-- Create the 'keybinds' table to store keybinds and their descriptions
CREATE TABLE IF NOT EXISTS `keybinds` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `keybind` VARCHAR(255) NOT NULL,
    `keybindText` VARCHAR(255) DEFAULT 'No keybind description provided'
);
