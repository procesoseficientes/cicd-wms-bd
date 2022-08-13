-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	16-Aug-17 @ Nexus Team Sprint Banjo-Kazooie 
-- Description:			SP que borra el detalle de una solicitud de transferencia

/*
-- Ejemplo de Ejecucion:
				DECLARE @TRANSFER_REQUEST_ID INT = 2
				--
				SELECT * FROM [wms].[OP_WMS_TRANSFER_REQUEST_DETAIL] WHERE [TRANSFER_REQUEST_ID] = @TRANSFER_REQUEST_ID
				--
				EXEC [wms].[OP_WMS_SP_DELETE_TRANSFER_REQUEST_DETAIL]
					@TRANSFER_REQUEST_ID = @TRANSFER_REQUEST_ID
					,@MATERIAL_ID = 'prueba'
				-- 
				SELECT * FROM [wms].[OP_WMS_TRANSFER_REQUEST_DETAIL] WHERE [TRANSFER_REQUEST_ID] = @TRANSFER_REQUEST_ID
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_DELETE_TRANSFER_REQUEST_DETAIL](
	@TRANSFER_REQUEST_ID INT
	,@MATERIAL_ID VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		DELETE FROM [wms].[OP_WMS_TRANSFER_REQUEST_DETAIL] 
		WHERE [TRANSFER_REQUEST_ID] = @TRANSFER_REQUEST_ID
			AND [MATERIAL_ID] = @MATERIAL_ID
		--
		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,'' [DbData];
	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo]; 
	END CATCH
END