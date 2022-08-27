﻿
CREATE PROCEDURE wms.OP_WMS_SP_ALTER_TYPE_CHANGE_X_LICENSE @LICENCESE_ID NUMERIC(18, 0),
@TYPE_CHARGE_ID INT,
@QTY NUMERIC(18, 0),
@LAST_UPDATED_BY VARCHAR(25),
@TYPE_TRANS AS VARCHAR(25),
@pResult VARCHAR(250) OUTPUT

AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRAN
  BEGIN
    DELETE wms.OP_WMS_TYPE_CHARGE_X_LICENSE
    WHERE LICENCESE_ID = @LICENCESE_ID
      AND TYPE_CHARGE_ID = @TYPE_CHARGE_ID
      AND TYPE_TRANS = @TYPE_TRANS

    IF @QTY > 0
    BEGIN

      INSERT INTO wms.OP_WMS_TYPE_CHARGE_X_LICENSE (LICENCESE_ID
      , TYPE_CHARGE_ID
      , QTY
      , LAST_UPDATED_BY
      , LAST_UPDATED
      , TYPE_TRANS)
        VALUES (@LICENCESE_ID, @TYPE_CHARGE_ID, @QTY, @LAST_UPDATED_BY, GETDATE(), @TYPE_TRANS)
    END
  END
  IF @@error = 0
  BEGIN
    SET @pResult = 'OK'
    COMMIT TRAN
  END
  ELSE
  BEGIN
    ROLLBACK TRAN
    SET @pResult = ERROR_MESSAGE()
  END

END