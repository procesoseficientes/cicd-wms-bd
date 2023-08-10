/****** Object:  StoredProcedure [SONDA].[SWIFT_SP_GET_QUERY_LIST]    Script Date: 8/7/2018 3:23:55 PM ******/
-- =============================================
-- Autor:				Yaqueline Canahui
-- Fecha de Creacion: 	07-Aug-18 @ G-FORCE @ Hormiga
-- Description:			SP que ejecuta una consulta de la lista de querys predefinidos. 
/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[OP_WMS_SP_EXECUTE_QUERY_FROM_QUERY_LIST]@QUERY_LIST_ID = 1
		,@LOGIN = 'ADMIN'
				*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_EXECUTE_QUERY_FROM_QUERY_LIST] (
		@QUERY_LIST_ID INT
		,@WHERE VARCHAR(MAX)
		,@LOGIN VARCHAR(50)
	)
AS
BEGIN
	SET NOCOUNT ON;
	--

	DECLARE	@QUERY VARCHAR(MAX);
	SELECT TOP 1
		@QUERY = [QUERY]
	FROM
		[SONDA].[SWIFT_QUERY_LIST]
	WHERE
		[ID] = @QUERY_LIST_ID;
	PRINT @QUERY + @WHERE;
	EXEC (@QUERY + @WHERE);
END;
