-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	20-Jul-17 @ Nexus TEAM Sprint AgeOfEmpires 
-- Description:			SP que desbloque la poliza

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_UNBLOCK_POLIZA]
					@POLIZA_HEADER_ID = 17304
					,@UNBLOCK_DOCUMENT = '123ABC'
					,@UNBLOCK_COMMENT = 'para prueba'
					,@LOGIN = 'ADMIN'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_UNBLOCK_POLIZA](
	@POLIZA_HEADER_ID INT
	,@UNBLOCK_DOCUMENT VARCHAR(25)
	,@UNBLOCK_COMMENT VARCHAR(250)
	,@LOGIN VARCHAR(25)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @FREE_STATUS VARCHAR(250) = ''
	--
	SELECT @FREE_STATUS = [wms].[OP_WMS_FN_GET_PARAMETER_VALUE]('STATUS','FREE')
	--
	BEGIN TRY
			UPDATE [I]
	    	SET 
	    		[I].[IS_BLOCKED] = 0
	    		,[I].[BLOCKED_STATUS] = @FREE_STATUS
	    	FROM [wms].[OP_WMS_INV_X_LICENSE] [I]
	    	INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON ([I].[LICENSE_ID] = [L].[LICENSE_ID])
	    	INNER JOIN [wms].[OP_WMS_POLIZA_HEADER] [PH] /*WITH(INDEX ([IN_OP_WMS_POLIZA_HEADER_CODIGO_POLIZA])) */ON ([L].[CODIGO_POLIZA] = [PH].[CODIGO_POLIZA])
			--
	    	UPDATE [wms].[OP_WMS_POLIZA_HEADER]
	    	SET 
	    		[IS_BLOCKED] = 0
	    		,[BLOCKED_STATUS] = @FREE_STATUS
	    		,[DOCUMENTO_DESBLOQUEO] = @UNBLOCK_DOCUMENT
	    		,[COMENTARIO_DESBLOQUEO] = @UNBLOCK_COMMENT
				,[USUARIO_DESBLOQUEO] = @LOGIN
				,[FECHA_DESBLOQUEO] = GETDATE()
	    	WHERE [DOC_ID] = @POLIZA_HEADER_ID
			--
			SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '' DbData
	END TRY
	BEGIN CATCH
		ROLLBACK
		--
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN ''
			ELSE ERROR_MESSAGE() 
		END Mensaje 
	END CATCH
END