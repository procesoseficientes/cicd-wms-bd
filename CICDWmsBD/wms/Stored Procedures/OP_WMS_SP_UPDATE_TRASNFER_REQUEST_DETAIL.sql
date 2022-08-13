-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	16-Aug-17 @ Nexus Team Sprint Banjo-Kazooie 
-- Description:			SP que actualiza el detalle de la solicitud de transferencia

/*
-- Ejemplo de Ejecucion:
				DECLARE @TRANSFER_REQUEST_ID INT = 2
				--
				SELECT * FROM [wms].[OP_WMS_TRANSFER_REQUEST_DETAIL] WHERE [TRANSFER_REQUEST_ID] = @TRANSFER_REQUEST_ID
				--
				EXEC [wms].[OP_WMS_SP_UPDATE_TRASNFER_REQUEST_DETAIL]
					@TRANSFER_REQUEST_ID = @TRANSFER_REQUEST_ID
					,@MATERIAL_ID = 'prueba'
					,@MATERIAL_NAME = 'prueba'
					,@IS_MASTERPACK = 0
					,@QTY = 123
					,@STATUS = 'prueba'
				-- 
				SELECT * FROM [wms].[OP_WMS_TRANSFER_REQUEST_DETAIL] WHERE [TRANSFER_REQUEST_ID] = @TRANSFER_REQUEST_ID
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_UPDATE_TRASNFER_REQUEST_DETAIL](
	@TRANSFER_REQUEST_ID INT
	,@MATERIAL_ID VARCHAR(50)
	,@MATERIAL_NAME VARCHAR(200)
	,@IS_MASTERPACK INT
	,@QTY NUMERIC(18,6)
	,@STATUS VARCHAR(25)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		UPDATE [wms].[OP_WMS_TRANSFER_REQUEST_DETAIL]
		SET	
			[MATERIAL_NAME] = @MATERIAL_NAME
			,[IS_MASTERPACK] = @IS_MASTERPACK
			,[QTY] = @QTY
			,[STATUS] = @STATUS
		WHERE [TRANSFER_REQUEST_ID] = @TRANSFER_REQUEST_ID
			AND [MATERIAL_ID] = @MATERIAL_ID
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '' DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,ERROR_MESSAGE() Mensaje 
		,@@ERROR Codigo 
	END CATCH
END