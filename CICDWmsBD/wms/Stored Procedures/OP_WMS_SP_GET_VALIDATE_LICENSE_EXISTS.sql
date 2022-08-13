-- =============================================
-- Autor:					pablo.aguilar
-- Fecha de Creacion: 		19-Jan-18 @ Nexus Team Sprint @JUMANJI
-- Description:				Se copia funcionalidad de Licencia valida con objeto operación. 

/*
-- Ejemplo de Ejecucion:
        EXEC [wms].[OP_WMS_SP_GET_VALIDATE_LICENSE_EXISTS] @LICENCE_ID = 22732
		SELECT * FROM [wms].[OP_WMS_LICENSES]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_VALIDATE_LICENSE_EXISTS] (@LICENCE_ID AS
											INT)
AS
BEGIN
	SET NOCOUNT ON;
	--

	BEGIN TRY
		EXEC [wms].[OP_WMS_SP_GET_IS_VALID_LICENCE] @LICENCE_ID = @LICENCE_ID; -- int	
	END TRY		
	BEGIN CATCH

		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo]
			,CAST('' AS VARCHAR) [DbData];
		RETURN;	 

	END CATCH;

	SELECT
		1 AS [Resultado]
		,'Proceso Exitoso' [Mensaje]
		,0 [Codigo]
		,CAST('1' AS VARCHAR) [DbData];

  

END;