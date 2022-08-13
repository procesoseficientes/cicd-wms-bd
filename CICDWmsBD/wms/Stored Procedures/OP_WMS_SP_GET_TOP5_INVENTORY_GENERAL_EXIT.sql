﻿-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	11/23/2017 @ NEXUS-Team Sprint GTA 
-- Description:			Obtiene el los primeros 5 recepciones generales para enviar a ERP.

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_TOP5_INVENTORY_GENERAL_ENTRY]
					@OWNER = 'me_llega'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_TOP5_INVENTORY_GENERAL_EXIT](
	@OWNER VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE	@MAX_ATTEMPTS INT = 5
			,@SERIE VARCHAR(50);
	--
	SELECT
		@MAX_ATTEMPTS = [OWC].[NUMERIC_VALUE]
	FROM
		[wms].[OP_WMS_CONFIGURATIONS] [OWC]
	WHERE
		[OWC].[PARAM_TYPE] = 'SISTEMA'
		AND [OWC].[PARAM_GROUP] = 'MAX_NUMBER_OF_ATTEMPTS'
		AND [OWC].[PARAM_NAME] = 'MAX_NUMBER_OF_SENDING_ATTEMPTS_TO_ERP';
	--
	SELECT @SERIE = [TEXT_VALUE] 
	FROM [wms].[OP_WMS_CONFIGURATIONS]
	WHERE [PARAM_TYPE] = 'SISTEMA'
		AND [PARAM_GROUP] = 'PICKING_GENERALES_ERP'
	--
	SELECT DISTINCT
		[PED].[PICKING_ERP_DOCUMENT_ID] [DocNum]
		,[PED].[CREATED_DATE] [DocDate]
		,[PED].[CREATED_DATE] [TaxDate]
		,@SERIE [SeriesSalida]
	FROM [wms].[OP_WMS_PICKING_ERP_DOCUMENT] [PED]
		INNER JOIN [wms].[OP_WMS_TASK_LIST] [TL] ON [TL].[WAVE_PICKING_ID] = [PED].[WAVE_PICKING_ID]
	WHERE 
		[PED].[IS_POSTED_ERP] <> 1
		AND [PED].[ATTEMPTED_WITH_ERROR] < @MAX_ATTEMPTS
		AND [TL].[CLIENT_OWNER] = @OWNER
		AND [PED].[IS_AUTHORIZED] = 1
END