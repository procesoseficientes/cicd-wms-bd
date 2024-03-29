﻿

CREATE PROCEDURE [wms].[sp_OP_WMS3PL_DOCS_REFERENCIA]
@DOC_ID numeric(18,0),
@NUMERO_DUA varchar(15),
@NUMERO_DOCUMENTO varchar(50),
@TIPO_DOCUMENTO varchar(15),
@FECHA_DOCUMENTO date,
@OBSERVACIONES varchar(250),
@LAST_UPDATED_BY varchar(25),
@LAST_UPDATED   date
AS

--declaramos las variables a utilizar
DECLARE @retCode int

IF NOT EXISTS(SELECT * FROM OP_WMS3PL_DOCS_REFERENCIA WHERE DOC_ID = @DOC_ID AND NUMERO_DOCUMENTO = @NUMERO_DOCUMENTO AND TIPO_DOCUMENTO = @TIPO_DOCUMENTO)
	BEGIN
	BEGIN TRANSACTION
		INSERT INTO OP_WMS3PL_DOCS_REFERENCIA ( DOC_ID,NUMERO_DUA,NUMERO_DOCUMENTO,TIPO_DOCUMENTO,FECHA_DOCUMENTO,OBSERVACIONES,LAST_UPDATED_BY,LAST_UPDATED)
		VALUES (@DOC_ID,@NUMERO_DUA,@NUMERO_DOCUMENTO, @TIPO_DOCUMENTO, @FECHA_DOCUMENTO,@OBSERVACIONES,@LAST_UPDATED_BY,@LAST_UPDATED)
		
			IF @@ERROR <> 0
				BEGIN
					ROLLBACK TRANSACTION
					SET @retCode = 0
					RETURN @retCode
				END
			ELSE
				BEGIN
					COMMIT TRANSACTION
					SET @retCode = 1
					RETURN @retCode
				END
	END
ELSE
	BEGIN
	BEGIN TRANSACTION
		UPDATE OP_WMS3PL_DOCS_REFERENCIA
		SET NUMERO_DUA = @NUMERO_DUA,TIPO_DOCUMENTO = @TIPO_DOCUMENTO,FECHA_DOCUMENTO = @FECHA_DOCUMENTO, OBSERVACIONES = @OBSERVACIONES
			,LAST_UPDATED_BY = @LAST_UPDATED_BY, LAST_UPDATED = @LAST_UPDATED
		WHERE DOC_ID = @DOC_ID AND NUMERO_DOCUMENTO = @NUMERO_DOCUMENTO AND TIPO_DOCUMENTO = @TIPO_DOCUMENTO
		
		IF @@ERROR <> 0
				BEGIN
					ROLLBACK TRANSACTION
					SET @retCode = 0
					RETURN @retCode
				END
			ELSE
				BEGIN
					COMMIT TRANSACTION
					SET @retCode = 2
					RETURN @retCode
				END
	END