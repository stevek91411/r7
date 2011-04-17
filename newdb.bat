C:\stephen\ruby\instantrails\mysql\bin\mysql -h localhost -u root -p <db\create.sql
call rake db:migrate 
call rake db:fixtures:load