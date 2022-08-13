-- =============================================
-- Autor:					rodrigo.gomez
-- Fecha de Creacion: 		30-Jan-17 @ Reborn Team Sprint Trotzdem
-- Description:			    Obtiene las clases asociadas a la clase enviada

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [wms].[OP_WMS_FN_GET_ASSOCIATED_CLASSES](45)
*/
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FN_GET_ASSOCIATED_CLASSES]
(	
	@CLASS_ID INT
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT [C1].[CLASS_ID]
      ,[C1].[CLASS_NAME]
      ,[C1].[CLASS_DESCRIPTION]
      ,[C1].[CLASS_TYPE]
      ,[C1].[CREATED_BY]
      ,[C1].[CREATED_DATETIME]
      ,[C1].[LAST_UPDATED_BY]
      ,[C1].[LAST_UPDATED]
      ,[C1].[PRIORITY]
	FROM [wms].[OP_WMS_CLASS_ASSOCIATION] [CA]
	INNER JOIN [wms].[OP_WMS_CLASS] [C1] ON [C1].[CLASS_ID] = [CA].[CLASS_ASSOCIATED_ID]
	WHERE [CA].[CLASS_ID] = @CLASS_ID
	UNION ALL
	SELECT [CLASS_ID]
          ,[CLASS_NAME]
          ,[CLASS_DESCRIPTION]
          ,[CLASS_TYPE]
          ,[CREATED_BY]
          ,[CREATED_DATETIME]
          ,[LAST_UPDATED_BY]
          ,[LAST_UPDATED]
          ,[PRIORITY] FROM [wms].[OP_WMS_CLASS]
	WHERE [CLASS_ID] = @CLASS_ID
)