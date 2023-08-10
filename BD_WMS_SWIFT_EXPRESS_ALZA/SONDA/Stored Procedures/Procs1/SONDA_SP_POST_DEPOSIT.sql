-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		16-Feb-17 @ A-Team Sprint Chatuluka
-- Description:			    Se agregaron los parametros DOC_NUM, DOC_SERIE y LIQUIDATION_ID

-- Modificacion 1/19/2018 @ Reborn-Team Sprint Strom
					-- diego.as
					-- Se agrega validacion de identificador de dispositivo

/*
-- Ejemplo de Ejecucion:
		DECLARE @pResult VARCHAR(250)
		--
		EXEC [SONDA].[SONDA_SP_POST_DEPOSIT]
			@pBANK_ACCOUNT = '1231231231231231'
			,@pGPS = '14.59,-90.5416'
			,@pAMT = 666
			,@pPOS_ID = '4'
			,@pDEPOSIT_DATETIME = '2017-02-16 02:44:06.370'
			,@pLOGIN_ID = 'RUDI@SONDA'
			,@pOFFLINE = 0
			,@pTRANS_REF = 1
			,@pResult = @pResult OUTPUT
			,@DOC_SERIE = 'PRUEBA'
			,@DOC_NUM = 3
			,@DEVICE_ID = '3b396881f40a8de3'
		--
		SELECT @pResult
		--
        SELECT * FROM [SONDA].[SONDA_DEPOSITS] ORDER BY 1 DESC
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_POST_DEPOSIT] (
	@pBANK_ACCOUNT VARCHAR(50)
	,@pGPS VARCHAR(150)
	,@pAMT MONEY
	,@pPOS_ID VARCHAR(25)
	,@pDEPOSIT_DATETIME DATETIME
	,@pLOGIN_ID VARCHAR(25)
	,@pOFFLINE INT
	,@pTRANS_REF INT
	,@pResult VARCHAR(250) OUTPUT
	,@DOC_SERIE VARCHAR(50)
	,@DOC_NUM INT
	,@IMAGE_1 VARCHAR(MAX) = NULL
	,@DEVICE_ID VARCHAR(50)
)AS
BEGIN
	SET NOCOUNT ON;
	--
    DECLARE	
		@ErrorMessage NVARCHAR(4000)
		,@ErrorSeverity INT
		,@ErrorState INT
		,@pNewID INT;
    	
    BEGIN TRY
	 
		-- -----------------------------------------------------------------
		-- Se valida el identificador del dispositivo
		-- -----------------------------------------------------------------
	   	EXEC [SONDA].[SONDA_SP_VALIDATE_DEVICE_ID_OF_USER_FOR_TRANSACTION] @CODE_ROUTE = @pPOS_ID , -- varchar(50)
	   		@DEVICE_ID = @DEVICE_ID -- varchar(50)

		--
    	INSERT INTO [SONDA].[SONDA_DEPOSITS]
    			(
    				[TRANS_TYPE]
    				,[TRANS_DATETIME]
    				,[BANK_ID]
    				,[ACCOUNT_NUM]
    				,[AMOUNT]
    				,[POSTED_BY]
    				,[POSTED_DATETIME]
    				,[POS_TERMINAL]
    				,[GPS_URL]
    				,[IS_OFFLINE]
    				,[TRANS_REF]
					,[DOC_SERIE]
    				,[DOC_NUM]
					,[IMAGE_1]
    			)
    	VALUES
    			(
    				'BANK_DEPOSIT'
    				,CURRENT_TIMESTAMP
    				,(SELECT ISNULL([ACCOUNT_BANK], 'N/F') FROM [SONDA_VIEW_BANK_ACCOUNTS] WHERE [ACCOUNT_NUMBER] = @pBANK_ACCOUNT)
    				,@pBANK_ACCOUNT
    				,@pAMT
    				,@pLOGIN_ID
    				,@pDEPOSIT_DATETIME
    				,@pPOS_ID
    				,@pGPS
    				,@pOFFLINE
    				,@pTRANS_REF
					,@DOC_SERIE
					,@DOC_NUM
					,@IMAGE_1
    			);
    	
		-- ------------------------------------------------------------------------------------
		-- Se actualiza la secuencia de documentos si es mayor
		-- ------------------------------------------------------------------------------------
		UPDATE SWIFT_DOCUMENT_SEQUENCE 
		SET CURRENT_DOC = @DOC_NUM
		WHERE ASSIGNED_TO = @pPOS_ID
			AND SERIE = @DOC_SERIE
			AND CURRENT_DOC < @DOC_NUM
		--
    	SELECT @pResult = CAST(SCOPE_IDENTITY() AS VARCHAR)
    END TRY
    BEGIN CATCH
    	SELECT @pResult = ERROR_MESSAGE();
    END CATCH;
END
