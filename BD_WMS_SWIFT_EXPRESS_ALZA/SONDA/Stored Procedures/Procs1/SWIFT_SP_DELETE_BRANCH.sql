﻿CREATE PROCEDURE [SONDA].[SWIFT_SP_DELETE_BRANCH]
@BRANCH_PK INT,
@pResult varchar(250) OUTPUT
AS
--IF ((SELECT COUNT(A.CODE_DRIVER) FROM [SONDA].SWIFT_MANIFEST_HEADER AS A WHERE A.CODE_DRIVER = @DRIVER )
--) = 0
--BEGIN 
	DELETE FROM SWIFT_BRANCHES WHERE BRANCH_PK=@BRANCH_PK
	SELECT @pResult = ''
--END
--ELSE
--	BEGIN
--		SELECT @pResult = 'El dato no se puede eliminar debido a que está siendo utilizado'
--	END
