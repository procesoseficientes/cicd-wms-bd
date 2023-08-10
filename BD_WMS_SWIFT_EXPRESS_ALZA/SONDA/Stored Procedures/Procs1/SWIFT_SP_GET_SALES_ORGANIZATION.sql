-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	2/23/2017 @ A-TEAM Sprint Chatuluka 
-- Description:			Selecciona uno o todos los registros de la tabla SWIFT_SALES_ORGANIZATION 

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_SALES_ORGANIZATION]
					@SALES_ORGANIZATION_ID INT = 2
				--
				EXEC [SONDA].[SWIFT_SP_GET_SALES_ORGANIZATION]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_SALES_ORGANIZATION](
	@SALES_ORGANIZATION_ID INT = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT [SO].[SALES_ORGANIZATION_ID]
			,[SO].[NAME_SALES_ORGANIZATION]
			,[SO].[DESCRIPTION_SALES_ORGANIZATION] 
	FROM [SONDA].[SWIFT_SALES_ORGANIZATION] [SO]
	WHERE @SALES_ORGANIZATION_ID IS NULL 
		OR [SO].[SALES_ORGANIZATION_ID] = @SALES_ORGANIZATION_ID
	
END
