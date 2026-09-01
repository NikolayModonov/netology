-- 1.2 Create user
CREATE USER 'sys_temp'@'localhost' IDENTIFIED BY 'password';

-- 1.3 Show users
SELECT Host, User FROM mysql.user;

-- 1.4 Grant all privileges
GRANT ALL PRIVILEGES ON *.* TO 'sys_temp'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;

-- 1.5 Show grants
SHOW GRANTS FOR 'sys_temp'@'localhost';

-- 1.6 Change authentication
ALTER USER 'sys_temp'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';

-- 1.8 Show tables in Sakila
USE sakila;
SHOW TABLES;

-- 2 Primary keys
SELECT TABLE_NAME, COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'sakila' AND CONSTRAINT_NAME = 'PRIMARY'
ORDER BY TABLE_NAME, ORDINAL_POSITION;
