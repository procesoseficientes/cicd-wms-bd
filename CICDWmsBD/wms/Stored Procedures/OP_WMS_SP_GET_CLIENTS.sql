-- =============================================
-- Autor:					rudi.garcia
-- Fecha de Creacion: 		3-11-2016 @ TEM-A SPRINT 4
-- Description:			    SP que obtiene los clientes

-- Modificacion 18-Jan-18 @ Nexus Team Sprint Strom
					-- alberto.ruiz
					-- Se agregan los nuevos campos de la vista al select

/*
-- Ejemplo de Ejecucion:
        EXEC [wms].[OP_WMS_SP_GET_CLIENTS]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_CLIENTS]
AS
BEGIN
	SET NOCOUNT ON;
	--  
	SELECT
		[VC].[CLIENT_CODE]
		,[VC].[CLIENT_NAME]
		,[VC].[CLIENT_ROUTE]
		,[VC].[CLIENT_CLASS]
		,[VC].[CLIENT_STATUS]
		,[VC].[CLIENT_REGION]
		,[VC].[CLIENT_ADDRESS]
		,[VC].[CLIENT_CA]
		,[VC].[CLIENT_ERP_CODE]
		,[VC].[IS_ACTIVE]
		,[VC].[CAN_EDIT]
	FROM [wms].[OP_WMS_VIEW_CLIENTS] [VC];
END;