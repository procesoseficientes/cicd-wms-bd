-- =============================================
-- Autor:				marvin.solares
-- Fecha de Creacion: 	18-Septiembre-2019 G-Force@Gumarcaj
-- Description:			Sp que actualiza el manifiesto luego de generar las tareas de entrega en next

-- Autor:				alexis.guerra
-- Fecha de Creacion: 	17-Octubre-2019 G-Force@IrlandaDelNorte
-- Description:			Se agrego parametro de status para actualizar el estado del manifiesto

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[UpdateStatusManifest] @MANIFEST_HEADER_ID = 1108
*/
-- =============================================  
CREATE PROCEDURE [wms].[UpdateStatusManifest] (
		@MANIFEST_HEADER_ID INT
		,@USER_LOGIN VARCHAR(50)
		,@STATUS VARCHAR(50) = null
	)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE
		[wms].[OP_WMS_MANIFEST_HEADER]
	SET	
		[STATUS] = isnull(@STATUS,'ON_ROUTE')
		,[LAST_UPDATE_BY] = @USER_LOGIN
		,[LAST_UPDATE] = GETDATE()
	WHERE
		[MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID;


	SELECT
		1 AS [Result]
		,'Proceso Exitoso' [Message]
		,0 [Code]
		,'' [DbData];
	

END;