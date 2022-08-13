-- =============================================
-- Autor:	              hector.gonzalez
-- Fecha de Creacion: 	2017-01-16 @ Team ERGON - Sprint 1
-- Description:	        Sp que autoriza el envio de una recepcion a erp

-- Modificacion 10/10/2017 @ NEXUS-Team Sprint ewms
					-- rodrigo.gomez
					-- Se agrega condicion IS_VOID = 0 

-- Autor:                 marvin.solares
-- Fecha de Creacion:   20180823 GForce@Humano
-- Description:          se actualiza para que quede registrado que usuario confirmo la recepcion

/*
-- Ejemplo de Ejecucion:
			EXEC  [OP_WMS_SP_AUTHORIZE_ERP_RECEPTION_DOCUMENT] @ERP_RECEPTION_DOCUMENT_HEADER_ID = 3
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_AUTHORIZE_ERP_RECEPTION_DOCUMENT] (
		@ERP_RECEPTION_DOCUMENT_HEADER_ID INT
		,@LAST_UPDATE_BY VARCHAR(50)
		,@CONFIRMED INT = 0
	)
AS
BEGIN
	SET NOCOUNT ON;
  --
	BEGIN TRY

		DECLARE	@TASK_ID INT;
		SELECT TOP 1
			@TASK_ID = [TASK_ID]
		FROM
			[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]
		WHERE
			[ERP_RECEPTION_DOCUMENT_HEADER_ID] = @ERP_RECEPTION_DOCUMENT_HEADER_ID;

		UPDATE
			[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]
		SET	
			[IS_AUTHORIZED] = 1
			,[ATTEMPTED_WITH_ERROR] = 0
			,[IS_POSTED_ERP] = 0
			,[LAST_UPDATE] = GETDATE()
			,[LAST_UPDATE_BY] = @LAST_UPDATE_BY
			,[CONFIRMED_BY] = @LAST_UPDATE_BY
		WHERE
			[TASK_ID] = @TASK_ID
			AND [IS_VOID] = 0
			AND (
					@CONFIRMED = 1
					OR [CONFIRMED_BY] IS NOT NULL
				)
			AND [IS_POSTED_ERP] <> 1;

    --
		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,'0' [DbData];
	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];
	END CATCH;

END;