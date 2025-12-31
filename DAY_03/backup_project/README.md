This is an small project using Bash Scripting made to handle the automatic backup of the database 
in case of accidental disaster which is based on real world DevOps project.


# Backup the database data using pg_dump (PostGres SQL)
# Rotation system and deletion in backup
 -> If there is more no of backup file than retention count then it will filter the newest and oldest file
    and delete the oldest file preventing the server/system crash.
