
-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		28-Oct-16 @ A-Team Sprint 
-- Description:			    SP que agrega el detalle de un acuerdo comercial

/*
-- Ejemplo de Ejecucion:
        DECLARE @pResult VARCHAR(250) = ''
		--
		[wms].[OP_WMS_SP_ALTER_TARIFICADOR_DETAIL]
			@ACUERDO_COMERCIAL = 12
			,@TYPE_CHARGE_ID = 1
			,@UNIT_PRICE = 10
			,@CURRENCY = 'CURRENCY'
			,@COMMENTS = 'COMMENTS'
			,@BILLING_FRECUENCY = 1
			,@LIMIT_TO = 100
			,@TYPE_MEASURE = 'TYPE_MEASURE'
			,@U_MEASURE = 'U_MEASURE'
			,@TX_SOURCE = '1'
			,@pResult = @pResult OUTPUT
		--
		SELECT @pResult [pResult]
		--
		SELECT * FROM  [wms].[OP_WMS_TARIFICADOR_DETAIL]
*/
-- =============================================
CREATE PROCEDURE wms.OP_WMS_SP_ALTER_TARIFICADOR_DETAIL @ACUERDO_COMERCIAL INT
, @TYPE_CHARGE_ID INT
, @UNIT_PRICE INT
, @CURRENCY VARCHAR(20)
, @COMMENTS VARCHAR(MAX)
, @BILLING_FRECUENCY INT
, @LIMIT_TO INT
, @TYPE_MEASURE VARCHAR(25)
, @U_MEASURE VARCHAR(15)
, @TX_SOURCE VARCHAR(25)
, @pResult VARCHAR(250) OUTPUT
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRAN;
  BEGIN
    INSERT INTO [wms].[OP_WMS_TARIFICADOR_DETAIL] ([ACUERDO_COMERCIAL]
    , [TYPE_CHARGE_ID]
    , [UNIT_PRICE]
    , [CURRENCY]
    , [COMMENTS]
    , [BILLING_FRECUENCY]
    , [LIMIT_TO]
    , [U_MEASURE]
    , [TX_SOURCE]
    , [TYPE_MEASURE])
      VALUES (@ACUERDO_COMERCIAL, @TYPE_CHARGE_ID, @UNIT_PRICE, @CURRENCY, @COMMENTS, @BILLING_FRECUENCY, @LIMIT_TO, @U_MEASURE, @TX_SOURCE, @TYPE_MEASURE);
  END;
  IF @@ERROR = 0
  BEGIN
    SELECT
      @pResult = 'OK';
    COMMIT TRAN;
  END;
  ELSE
  BEGIN
    ROLLBACK TRAN;
    SELECT
      @pResult = ERROR_MESSAGE();
  END;

END;