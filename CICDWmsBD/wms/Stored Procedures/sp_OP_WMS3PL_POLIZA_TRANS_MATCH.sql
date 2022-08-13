﻿-- =============================================
-- Autor:					rudi.garcia
-- Fecha de Creacion: 		28/09/2017 @ Reborn-Team Sprint Collin 
-- Description:			    Se agrego licencia

/*
-- Ejemplo de Ejecucion:
        
*/
-- =============================================

CREATE PROCEDURE [wms].[sp_OP_WMS3PL_POLIZA_TRANS_MATCH]
			@CODIGO_POLIZA varchar(25)
           ,@TRANS_ID numeric(18,0)
           ,@LINENO_POLIZA numeric(18,0)
           ,@DOC_ID numeric(18,0)
           ,@SKU_DESCRIPTION varchar(250)
           ,@MATERIAL_CODE varchar(25)
           ,@MATERIAL_DESCRIPTION varchar(200)
           ,@QTY_TRANS numeric(18,4)
           ,@QTY_POLIZA numeric(18,4)
           ,@BULTOS_POLIZA numeric(18,4)
           ,@LAST_UPDATED_BY varchar(25)
           ,@QTY numeric(18,4)
           ,@COMMENTS varchar(max)
     AS

--declaramos las variables a utilizar
DECLARE @retCode INT
       ,@LICENSE_ID INT

SELECT @LICENSE_ID = [T].[LICENSE_ID]
FROM [wms].[OP_WMS_TRANS] [T]
WHERE [T].[SERIAL_NUMBER] = @TRANS_ID

IF NOT EXISTS(SELECT * FROM OP_WMS3PL_POLIZA_TRANS_MATCH WHERE CODIGO_POLIZA = @CODIGO_POLIZA AND TRANS_ID = @TRANS_ID AND LINENO_POLIZA = @LINENO_POLIZA 
														 AND MATERIAL_CODE = @MATERIAL_CODE)
BEGIN
	BEGIN TRANSACTION
		INSERT INTO OP_WMS3PL_POLIZA_TRANS_MATCH
           ([CODIGO_POLIZA],[TRANS_ID],[LINENO_POLIZA],[DOC_ID],[SKU_DESCRIPTION],[MATERIAL_CODE]
           ,[MATERIAL_DESCRIPTION],[QTY_TRANS],[QTY_POLIZA],[BULTOS_POLIZA],[LAST_UPDATED_BY]
           ,[LAST_UPDATED]
           , QTY
           , COMMENTS
           , LICENSE_ID
           )
		VALUES
           (@CODIGO_POLIZA ,@TRANS_ID ,@LINENO_POLIZA ,@DOC_ID ,@SKU_DESCRIPTION ,@MATERIAL_CODE ,@MATERIAL_DESCRIPTION 
           ,@QTY_TRANS ,@QTY_POLIZA ,@BULTOS_POLIZA ,@LAST_UPDATED_BY ,GETDATE(),  @QTY, @COMMENTS, @LICENSE_ID)
 
 			IF @@ERROR <> 0
				BEGIN
					ROLLBACK TRANSACTION
					SELECT @retCode = 0
					RETURN @retCode
				END
			ELSE
				BEGIN
					COMMIT TRANSACTION
					SELECT @retCode = 1
					RETURN @retCode
				END
	END
ELSE
BEGIN
	BEGIN TRANSACTION
		UPDATE [OP_WMS3PL_POLIZA_TRANS_MATCH]
	   SET [CODIGO_POLIZA] = @CODIGO_POLIZA
		  ,[TRANS_ID] = @TRANS_ID
		  ,[LINENO_POLIZA] = @LINENO_POLIZA
		  ,[DOC_ID] = @DOC_ID
		  ,[SKU_DESCRIPTION] = @SKU_DESCRIPTION
		  ,[MATERIAL_CODE] = @MATERIAL_CODE
		  ,[MATERIAL_DESCRIPTION] = @MATERIAL_DESCRIPTION
		  ,[QTY_TRANS] = @QTY_TRANS
		  ,[QTY_POLIZA] = @QTY_POLIZA
		  ,[BULTOS_POLIZA] = @BULTOS_POLIZA
		  ,[LAST_UPDATED_BY] = @LAST_UPDATED_BY
		  ,[LAST_UPDATED] = GETDATE()
		  , QTY = @QTY
		  , COMMENTS = @COMMENTS
      , LICENSE_ID = @LICENSE_ID
	 WHERE CODIGO_POLIZA = @CODIGO_POLIZA AND TRANS_ID = @TRANS_ID AND LINENO_POLIZA = @LINENO_POLIZA AND MATERIAL_CODE = @MATERIAL_CODE
	 	
	 IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRANSACTION
			SELECT @retCode = 0
			RETURN @retCode
		END
	ELSE
		BEGIN
			COMMIT TRANSACTION
			UPDATE [wms].OP_WMS_POLIZA_DETAIL set PICKING_STATUS = 'MATCH' WHERE DOC_ID = @DOC_ID AND LINE_NUMBER = @LINENO_POLIZA
			
			SELECT @retCode = 2
			RETURN @retCode
		END
		
		END