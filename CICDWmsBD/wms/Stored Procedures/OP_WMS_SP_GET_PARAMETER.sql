-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	11/6/2017 @ NEXUS-Team Sprint F-Zero 
-- Description:			Obtiene los parametros por grupo y id

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_PARAMETER]
					@GROUP_ID = 'NEXT'
					,@PARAMETER_ID = 'HAS_NEXT'
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_GET_PARAMETER(
	@GROUP_ID VARCHAR(250)
	,@PARAMETER_ID VARCHAR(250) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT [P].[IDENTITY]
          ,[P].[GROUP_ID]
          ,[P].[PARAMETER_ID]
          ,[P].[VALUE]
          ,[P].[LABEL]
	FROM [wms].[OP_WMS_PARAMETER] [P]
	WHERE [P].[GROUP_ID] = @GROUP_ID
		AND ([P].[PARAMETER_ID] = @PARAMETER_ID OR @PARAMETER_ID IS NULL)
		AND [P].[IDENTITY] > 0
END