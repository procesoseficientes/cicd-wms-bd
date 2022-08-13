-- =============================================
-- Autor:	              hector.gonzalez
-- Fecha de Creacion: 	2017-01-27 @ Team ERGON - Sprint ERGON II
-- Description:	        Sp que obtiene el top 5 master pack para en envio al erp que an fallado

-- Modificacion 10-Aug-17 @ Nexus Team Sprint Banjo-Kazooie
					-- alberto.ruiz
					-- Ajuste por intercompany

-- Modificacion 9/19/2017 @ NEXUS-Team Sprint DuckHunt
					-- rodrigo.gomez
					-- Se agrega la columna IS_IMPLOSION
/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_GET_TOP5_FAILED_MASTER_PACK_EXPLOTION]
				@OWNER = 'arium'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_TOP5_FAILED_MASTER_PACK_EXPLOTION](
	@OWNER VARCHAR(50)
) AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE	@MAX_ATTEMPTS INT = 5;
	--
	SELECT @MAX_ATTEMPTS = [owc].[NUMERIC_VALUE]
	FROM [wms].[OP_WMS_CONFIGURATIONS] [owc]
	WHERE [owc].[PARAM_TYPE] = 'SISTEMA'
		AND [owc].[PARAM_GROUP] = 'MAX_NUMBER_OF_ATTEMPTS'
		AND [owc].[PARAM_NAME] = 'MAX_NUMBER_OF_SENDING_ATTEMPTS_TO_ERP';
	--
	SELECT TOP 5
		[MPH].[MASTER_PACK_HEADER_ID]
		,[MPH].[LICENSE_ID]
		,[MPH].[MATERIAL_ID]
		,[MPH].[POLICY_HEADER_ID]
		,[MPH].[LAST_UPDATED]
		,[MPH].[LAST_UPDATE_BY]
		,[MPH].[EXPLODED]
		,[MPH].[EXPLODED_DATE]
		,[MPH].[RECEPTION_DATE]
		,[MPH].[IS_AUTHORIZED]
		,[MPH].[ATTEMPTED_WITH_ERROR]
		,[MPH].[IS_POSTED_ERP]
		,[MPH].[POSTED_ERP]
		,[MPH].[POSTED_RESPONSE]
		,[MPH].[ERP_REFERENCE]
		,[MPH].[IS_IMPLOSION]
	FROM [wms].[OP_WMS_MASTER_PACK_HEADER] [MPH]
	INNER JOIN [wms].[OP_WMS_MATERIAL_INTERCOMPANY] [MI] ON (
		[MPH].[MATERIAL_ID] = ([MI].[SOURCE] + '/' + [MI].[ITEM_CODE])
	)
	WHERE [MPH].[MASTER_PACK_HEADER_ID] > 0
		AND ISNULL([MPH].[IS_POSTED_ERP], 0) = -1
		AND ISNULL([MPH].[ATTEMPTED_WITH_ERROR], 0) < @MAX_ATTEMPTS
		AND ISNULL([MPH].[ATTEMPTED_WITH_ERROR], 0) > 0
		AND ([MPH].[EXPLODED] = 1 OR [MPH].[IS_IMPLOSION] = 1)
		AND [MI].[SOURCE] = @OWNER;
END;