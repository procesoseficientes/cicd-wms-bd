-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	2/16/2017 @ A-TEAM Sprint Chatuluka 
-- Description:			Selecciona todos los depositos filtrando por LIQUIDATION_ID

-- Modificacion 3/6/2017 @ A-Team Sprint Ebonne
					-- rodrigo.gomez
					-- Se agrego la columna IMAGE_1
/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_DEPOSIT_BY_LIQUIDATION]
					@LIQUIDATION_ID = 776
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_DEPOSIT_BY_LIQUIDATION](
	@LIQUIDATION_ID INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT [D].[TRANS_ID]
			,[D].[TRANS_TYPE]
			,[D].[TRANS_DATETIME]
			,ISNULL([D].[BANK_ID], '') [BANK_ID]
			,[D].[ACCOUNT_NUM]
			,[D].[AMOUNT]
			,[D].[POSTED_BY]
			,[D].[POSTED_DATETIME]
			,[D].[POS_TERMINAL]
			,[D].[GPS_URL]
			,[D].[TRANS_REF]
			,[D].[IS_OFFLINE]
			,[D].[STATUS]
			,[D].[DOC_SERIE]
			,[D].[DOC_NUM]
			,[D].[LIQUIDATION_ID] 
			,ISNULL([D].[IMAGE_1], '') [IMAGE_1]
	FROM [SONDA].[SONDA_DEPOSITS] [D]
	WHERE [D].[LIQUIDATION_ID] = @LIQUIDATION_ID

END
