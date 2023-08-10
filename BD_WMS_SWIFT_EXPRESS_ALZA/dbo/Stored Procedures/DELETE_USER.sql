CREATE PROC [dbo].[DELETE_USER]
@USER VARCHAR(150)
AS
DECLARE @SQL VARCHAR(MAX)

--SET @SQL = 'IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N'''+@USER+''')
--DROP SCHEMA ['+@USER+']'
--EXEC (@SQL)

--SET @SQL = 'IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N'''+@USER+''')
--DROP USER ['+@USER+']'
--EXEC (@SQL)

SET @SQL = 'IF  EXISTS (SELECT * FROM sys.server_principals WHERE name = N'''+@USER+''')
DROP LOGIN ['+@USER+']'
EXEC (@SQL)
