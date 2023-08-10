﻿CREATE PROCEDURE [SONDA].[SWIFT_SP_PROCESS_SKU_RECEPTION_TASK]
@pTASK_ID	INT,
@pBARCODE	VARCHAR(75),
@pQTY		NUMERIC(18,2),
@pLOGIN_ID	VARCHAR(50),

@pResult varchar(250) OUTPUT
AS
	DECLARE @lBARCODE			VARCHAR(75);
	DECLARE @lSKU				VARCHAR(75);
	DECLARE @lDOC_REFERENCE		VARCHAR(50);
	DECLARE @lRECEPTION_HEADER	INT;
	DECLARE @lSCANNED			INT;
	
		BEGIN TRY
			SELECT @lBARCODE = UPPER(@pBARCODE);
			
			SELECT @lSKU = ISNULL((SELECT CODE_SKU FROM SWIFT_VIEW_SKU WHERE BARCODE_SKU = @lBARCODE OR CODE_SKU = @lBARCODE),'N/F');
			IF(@lSKU = 'N/F') BEGIN
				SELECT	@pResult	= 'ERROR, SKU: ' +@lBARCODE+ ', NO EXISTE';
				RETURN -9
			END
			
			SELECT @lDOC_REFERENCE = ISNULL((SELECT SAP_REFERENCE FROM SWIFT_TASKS WHERE TASK_ID = @pTASK_ID),-9999)
			IF(@lDOC_REFERENCE = -9999) BEGIN
				SELECT	@pResult	= 'ERROR, TAREA: ' +convert(varchar(10), @pTASK_ID)+ ', NO TIENE CODIGO DE RECEPCION';
				RETURN -9
			END
			
			SELECT @lRECEPTION_HEADER = ISNULL((SELECT RECEPTION_NUMBER FROM SWIFT_TASKS WHERE TASK_ID = @pTASK_ID),-9999)
			
			IF EXISTS(SELECT 1 FROM SWIFT_TASKS WHERE TASK_ID = @pTASK_ID AND ACCEPTED_STAMP IS NULL) BEGIN
				UPDATE SWIFT_TASKS set SCANNING_STATUS = 'IN_PROGRESS', ACCEPTED_STAMP = CURRENT_TIMESTAMP WHERE TASK_ID = @pTASK_ID
			END 
			
			SELECT @lSCANNED = [SCANNED] 
			FROM [SWIFT_RECEPTION_DETAIL]
			WHERE	[RECEPTION_HEADER] = @lRECEPTION_HEADER AND CODE_SKU = @lSKU
			--
			IF (@lSCANNED + @pQTY) < 0 
			BEGIN
				SELECT	@pResult	= 'ERROR, La cantidad ingresada es mayor a la cantidad ya anteriormente escaneada';
				RETURN -9
			END

			--CHECK IF SKU IS CONTAINED IN RECEPTION_DETAIL
			IF EXISTS(SELECT 1 FROM 
						SWIFT_RECEPTION_DETAIL WHERE 
						RECEPTION_HEADER = @lRECEPTION_HEADER 
						AND CODE_SKU = @lSKU) BEGIN
				UPDATE [SWIFT_RECEPTION_DETAIL]
				   SET [SCANNED]		= [SCANNED]+@pQTY
					  ,[LAST_UPDATE]	= CURRENT_TIMESTAMP
					  ,[LAST_UPDATE_BY] = @pLOGIN_ID
					  ,[DIFFERENCE]		= EXPECTED - ([SCANNED]+@pQTY)
				 WHERE	[RECEPTION_HEADER] = @lRECEPTION_HEADER AND 
						CODE_SKU = @lSKU
			END 
			ELSE BEGIN
				INSERT INTO [SWIFT_RECEPTION_DETAIL]
					   ([RECEPTION_HEADER]
					   ,[CODE_SKU]
					   ,[DESCRIPTION_SKU]
					   ,[EXPECTED]
					   ,[SCANNED]
					   ,[RESULT]
					   ,[COMMENTS]
					   ,[LAST_UPDATE]
					   ,[LAST_UPDATE_BY]
					   ,[DIFFERENCE])
				 VALUES
					   (@lRECEPTION_HEADER
					   ,@lSKU
					   ,(SELECT DESCRIPTION_SKU FROM SWIFT_VIEW_SKU WHERE CODE_SKU = @lSKU)
					   ,0
					   ,@pQTY
					   ,NULL
					   ,'SKU NO ESPERADO, VINO DE MAS'
					   ,CURRENT_TIMESTAMP
					   ,@pLOGIN_ID
					   ,@pQTY)
			END
			
			SELECT	@pResult	= 'OK';
			RETURN 0
			
		END TRY
		BEGIN CATCH
			SELECT	@pResult	= ERROR_MESSAGE()
		END CATCH
