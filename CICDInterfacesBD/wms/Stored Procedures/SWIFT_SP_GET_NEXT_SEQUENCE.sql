﻿
CREATE PROC [wms].[SWIFT_SP_GET_NEXT_SEQUENCE] @SEQUENCE_NAME VARCHAR(50),
@pResult NUMERIC(18, 0) OUTPUT
AS
  --STORED PROCEDURE QUE DEVUELVE UNA RESPUESTA
  DECLARE @COUNT INT
  SET @COUNT = (SELECT
      COUNT([SEQUENCE_NAME])
    FROM [wms].[SWIFT_SEQUENCES]
    WHERE [SEQUENCE_NAME] = @SEQUENCE_NAME)

  IF (@COUNT = 0)
  BEGIN
    INSERT INTO [wms].[SWIFT_SEQUENCES] ([SEQUENCE_NAME], [CURRENT_NUMBER])
      VALUES (@SEQUENCE_NAME, 1)
    SET @pResult = 1
  END
  ELSE
  BEGIN
    SET @pResult = (SELECT TOP 1
        [CURRENT_NUMBER]
      FROM [wms].[SWIFT_SEQUENCES]
      WHERE [SEQUENCE_NAME] = @SEQUENCE_NAME
      ORDER BY [CURRENT_NUMBER] DESC)
    + 1
    UPDATE [wms].[SWIFT_SEQUENCES]
    SET [CURRENT_NUMBER] = @pResult
    WHERE [SEQUENCE_NAME] = @SEQUENCE_NAME
  END

