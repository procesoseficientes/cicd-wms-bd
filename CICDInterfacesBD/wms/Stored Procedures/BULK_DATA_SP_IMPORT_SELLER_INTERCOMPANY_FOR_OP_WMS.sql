-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		09-Aug-17 @ Nexus Team Sprint Banjo-Kazooie
-- Description:			    SP para obtener el codigo de cliente por cada base de datos de la multiempresa

-- Modificacion 8/22/2017 @ NEXUS-Team Sprint CommandAndConquer
					-- rodrigo.gomez
					-- Se agrega columna SERIE al insert

-- Modificacion 20-Nov-17 @ Nexus Team Sprint GTA
					-- alberto.ruiz
					-- Se agrega tabla intermedia

/*
-- Ejemplo de Ejecucion:
        EXEC [wms].[BULK_DATA_SP_IMPORT_SELLER_INTERCOMPANY_FOR_OP_WMS]
		--
		SELECT * FROM [OP_WMS_wms].[wms].[OP_WMS_SELLER_INTERCOMPANY]
*/
-- =============================================
CREATE PROCEDURE [wms].[BULK_DATA_SP_IMPORT_SELLER_INTERCOMPANY_FOR_OP_WMS]
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @SELLER_INTERCOMPANY TABLE (
		[MASTER_ID] VARCHAR(50)
		,[SLP_CODE] VARCHAR(50)
		,[SOURCE] VARCHAR(50)
		,[SERIE] VARCHAR(50)
	)
	--
	INSERT INTO @SELLER_INTERCOMPANY
			(
				[MASTER_ID]
				,[SLP_CODE]
				,[SOURCE]
				,[SERIE]
			)
	SELECT
		ISNULL([MASTER_ID],'-1')
		,[SLP_CODE]
		,[SOURCE]
		,ISNULL([SERIE], '')
	FROM [SWIFT_INTERFACES_ONLINE].[wms].[ERP_VIEW_SELLER_SOURCE]
	--
	DELETE FROM [OP_WMS_wms].[wms].[OP_WMS_SELLER_INTERCOMPANY]
	--
	INSERT INTO [OP_WMS_wms].[wms].[OP_WMS_SELLER_INTERCOMPANY]
			(
				[MASTER_ID]
				,[SLP_CODE]
				,[SOURCE]
				,[SERIE]
			)
	SELECT
		[MASTER_ID]
		,[SLP_CODE]
		,[SOURCE]
		,[SERIE]
	FROM @SELLER_INTERCOMPANY
END

