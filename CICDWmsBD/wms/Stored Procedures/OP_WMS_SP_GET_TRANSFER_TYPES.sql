-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		16-Aug-17 @ Nexus Team Sprint Banjo-Kazooie
-- Description:			    SP para obtener los tipos de solicitudes de traslado

/*
-- Ejemplo de Ejecucion:
        EXEC [wms].[OP_WMS_SP_GET_TRANSFER_TYPES]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_TRANSFER_TYPES]
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @PARAM_GROUP VARCHAR(25) = 'SOLICITUD_TRASLADO'
	--
	SELECT [PARAM_TYPE]
			,[PARAM_GROUP]
			,[PARAM_GROUP_CAPTION]
			,[PARAM_NAME]
			,[PARAM_CAPTION]
			,[NUMERIC_VALUE]
			,[TEXT_VALUE]
	FROM [wms].[OP_WMS_CONFIGURATIONS] 
	WHERE [PARAM_GROUP] = @PARAM_GROUP

END