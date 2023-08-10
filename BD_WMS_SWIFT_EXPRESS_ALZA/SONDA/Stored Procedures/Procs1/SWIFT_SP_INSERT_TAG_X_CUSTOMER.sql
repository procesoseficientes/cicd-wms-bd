-- =============================================
-- Author:<Author,,Name>
-- Create date: <Create Date,,>
-- Description:<Description,,>

-- Modificacion 8/9/2017 @ Reborn-Team Sprint Bearbeitung
					-- diego.as
					-- Se agrega insert a las columnas [DEVICE_NETWORK_TYPE], [IS_POSTED_OFFLINE]

--Ejemplo de ejecucion:
/*
  EXEC [SONDA].[SWIFT_SP_INSERT_TAG_X_CUSTOMER]
  	 @TAG_COLOR ='#123'
    ,@CUSTOMER = 1
	,@DEVICE_NETWORK_TYPE = '3G'
	,@IS_POSTED_OFFLINE = 0
	
    SELECT * FROM [SONDA].[SWIFT_TAG_X_CUSTOMER_NEW] WHERE TAG_COLOR = '#123' AND CUSTOMER = 1
*/

-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_INSERT_TAG_X_CUSTOMER]
	@TAG_COLOR VARCHAR(8)
	,@CUSTOMER VARCHAR(50)
	,@pRESULT VARCHAR(MAX) = '' OUTPUT
	,@DEVICE_NETWORK_TYPE VARCHAR(15)
	,@IS_POSTED_OFFLINE INT
AS
	BEGIN
		SET NOCOUNT ON;
		DECLARE	@tmpResult VARCHAR(MAX) = '';

		IF (@@ERROR = 0)
		BEGIN

			INSERT	INTO [SONDA].[SWIFT_TAG_X_CUSTOMER_NEW]
					([TAG_COLOR] ,[CUSTOMER], [DEVICE_NETWORK_TYPE], [IS_POSTED_OFFLINE])
			VALUES
					(@TAG_COLOR ,@CUSTOMER, @DEVICE_NETWORK_TYPE, @IS_POSTED_OFFLINE);

			SET @tmpResult = 'OK';
		END; 
		ELSE
		BEGIN
			SELECT
				@tmpResult = 'No se pudo agregar la etiqueta ';
		END;
		SELECT
			@pRESULT = @tmpResult;
	END;
