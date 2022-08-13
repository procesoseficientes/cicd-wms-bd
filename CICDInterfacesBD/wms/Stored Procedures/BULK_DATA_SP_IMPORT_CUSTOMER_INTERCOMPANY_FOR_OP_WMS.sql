-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		09-Aug-17 @ Nexus Team Sprint Banjo-Kazooie
-- Description:			    SP para obtener el codigo de cliente por cada base de datos de la multiempresa

-- Modificacion 8/21/2017 @ NEXUS-Team Sprint CommandAndConquer
					-- rodrigo.gomez
					-- Se agregan las columnas [CARD_NAME] y [LICTRADNUM]

-- Modificacion 20-Nov-17 @ Nexus Team Sprint GTA
					-- alberto.ruiz
					-- Se agrega tabla intermedia

/*
-- Ejemplo de Ejecucion:
        EXEC [wms].[BULK_DATA_SP_IMPORT_CUSTOMER_INTERCOMPANY_FOR_OP_WMS]
		--
		SELECT * FROM [OP_WMS_wms].[wms].[OP_WMS_CUSTOMER_INTERCOMPANY]
*/
-- =============================================
CREATE PROCEDURE [wms].[BULK_DATA_SP_IMPORT_CUSTOMER_INTERCOMPANY_FOR_OP_WMS]
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @CUSTOMER_INTERCOMPANY TABLE (
		[MASTER_ID] VARCHAR(50)
		,[CARD_CODE] VARCHAR(50)
		,[SOURCE] VARCHAR(50)
		,[CARD_NAME] VARCHAR(250)
		,[LICTRADNUM] VARCHAR(50)
	)
	--
	INSERT INTO @CUSTOMER_INTERCOMPANY
			(
				[MASTER_ID]
				,[CARD_CODE]
				,[SOURCE]
				,[CARD_NAME]
				,[LICTRADNUM]
			)
	SELECT
		[MASTER_ID]
		,[CARD_CODE]
		,[SOURCE]
		,[CARD_NAME]
		,[TAX_ID]
	FROM [SWIFT_INTERFACES_ONLINE].[wms].[ERP_VIEW_CUSTOMER_SOURCE]
	--
	DELETE FROM [OP_WMS_wms].[wms].[OP_WMS_CUSTOMER_INTERCOMPANY]
	--
	INSERT INTO [OP_WMS_wms].[wms].[OP_WMS_CUSTOMER_INTERCOMPANY]
			(
				[MASTER_ID]
				,[CARD_CODE]
				,[SOURCE]
				,[CARD_NAME]
				,[LICTRADNUM]
			)
	SELECT
		[MASTER_ID]
		,[CARD_CODE]
		,[SOURCE]
		,[CARD_NAME]
		,[LICTRADNUM]
	FROM @CUSTOMER_INTERCOMPANY
END

