-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	16-Aug-17 @ Nexus Team Sprint Banjo-Kazooie
-- Description:			SP que actualiza la solicitud de transferencia

/*
-- Ejemplo de Ejecucion:
				DECLARE @TRANSFER_REQUEST_ID INT = 1
				--
				SELECT * FROM [wms].[OP_WMS_TRANSFER_REQUEST_HEADER] WHERE [TRANSFER_REQUEST_ID] = @TRANSFER_REQUEST_ID
				--
				EXEC [wms].[OP_WMS_SP_UPDATE_TRANSFER_REQUEST_HEADER]
					@TRANSFER_REQUEST_ID = @TRANSFER_REQUEST_ID
					,@REQUEST_TYPE = 'prueba1'
					,@WAREHOUSE_FROM = 'prueba1'
					,@WAREHOUSE_TO = 'prueba1'
					,@DELIVERY_DATE = '20170825'
					,@COMMENT = 'prueba1'
					,@STATUS = 'prueba1'
					,@LAST_UPDATE_BY = 'prueba1'
					,@OWNER = 'prueba1'
				-- 
				SELECT * FROM [wms].[OP_WMS_TRANSFER_REQUEST_HEADER] WHERE [TRANSFER_REQUEST_ID] = @TRANSFER_REQUEST_ID
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_UPDATE_TRANSFER_REQUEST_HEADER](
	@TRANSFER_REQUEST_ID INT
	,@REQUEST_TYPE VARCHAR(50)
	,@WAREHOUSE_FROM VARCHAR(25)
	,@WAREHOUSE_TO VARCHAR(25)
	,@DELIVERY_DATE DATETIME
	,@COMMENT VARCHAR(250)
	,@STATUS VARCHAR(25)
	,@LAST_UPDATE_BY VARCHAR(25)
	,@OWNER VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		UPDATE [wms].[OP_WMS_TRANSFER_REQUEST_HEADER]
		SET	
			[REQUEST_TYPE] = @REQUEST_TYPE
			,[WAREHOUSE_FROM] = @WAREHOUSE_FROM
			,[WAREHOUSE_TO] = @WAREHOUSE_TO
			,[DELIVERY_DATE] = @DELIVERY_DATE
			,[COMMENT] = @COMMENT
			,[STATUS] = @STATUS
			,[LAST_UPDATE] = GETDATE()
			,[LAST_UPDATE_BY] = @LAST_UPDATE_BY
			,[OWNER] = @OWNER
		WHERE [TRANSFER_REQUEST_ID] = @TRANSFER_REQUEST_ID
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '' DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,ERROR_MESSAGE() Mensaje 
		,@@ERROR Codigo 
	END CATCH
END