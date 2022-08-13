﻿
CREATE PROCEDURE wms.OP_WMS_SP_ALTER_TARIFICADOR_HEADER @AcuerdoComercialId INT OUTPUT,
@ACUERDO_COMERCIAL_NOMBRE VARCHAR(50),
@VALID_FROM DATE,
@VALID_TO DATE,
@EXPIRES INT,
@CURRENCY VARCHAR(20),
@STATUS VARCHAR(20),
@WAREHOUSE_WEATHER VARCHAR(20),
@COMMENTS VARCHAR(MAX),
@REGIMEN VARCHAR(25),
@AUTHORIZER VARCHAR(25),
@pResult VARCHAR(250) OUTPUT

AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRAN
  BEGIN
    INSERT INTO wms.OP_WMS_TARIFICADOR_HEADER (ACUERDO_COMERCIAL_NOMBRE
    , VALID_FROM
    , VALID_TO
    , EXPIRES
    , CURRENCY
    , [STATUS]
    , WAREHOUSE_WEATHER
    , COMMENTS
    , REGIMEN
    , AUTHORIZER)
      VALUES (@ACUERDO_COMERCIAL_NOMBRE, @VALID_FROM, @VALID_TO, @EXPIRES, @CURRENCY, @STATUS, @WAREHOUSE_WEATHER, @COMMENTS, @REGIMEN, @AUTHORIZER)
  END
  IF @@error = 0
  BEGIN
    SELECT
      @AcuerdoComercialId = MAX(ACUERDO_COMERCIAL_ID)
    FROM wms.OP_WMS_TARIFICADOR_HEADER

    SELECT
      @pResult = 'OK'
    COMMIT TRAN
  END
  ELSE
  BEGIN
    ROLLBACK TRAN
    SELECT
      @pResult = ERROR_MESSAGE()
  END

END