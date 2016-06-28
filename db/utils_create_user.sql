set password for 'root'@'localhost' = password('vagrant');
create user 'peckr' identified by 'p@ssw0rd';
grant all privileges on peckr_development.* to 'peckr';