-- =============================================
-- Autor:				pablo.aguilar
-- Fecha de Creacion: 	12-May-18 @ G-FORCE @ Capibara 
-- Description:			SP que ejecuta una consulta de la lista de querys predefinidos. 

-- Autor:				rudi.garcia
-- Fecha de Creacion: 	03-Jan-2019 @ G-FORCE @ Quetzal 
-- Description:			Se agregaron los parametros de rango de fecha.

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_EXECUTE_QUERY_FROM_QUERY_LIST]@QUERY_LIST_ID = 1
		,@LOGIN = 'ADMIN'
				*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_EXECUTE_QUERY_FROM_QUERY_LIST] (
		@QUERY_LIST_ID INT
		,@WHERE VARCHAR(MAX)
		,@LOGIN VARCHAR(50)   
		,@START_DATE DATE
		,@END_DATE DATE 
	)
AS
BEGIN
	SET NOCOUNT ON;
	--

	DECLARE	@QUERY VARCHAR(MAX);
	SELECT TOP 1
		@QUERY = 'DECLARE @START_DATE DATE = ''' + CAST(@START_DATE AS VARCHAR) + ''', @END_DATE DATE = ''' + CAST(@END_DATE AS VARCHAR) +  ''' '+  [QUERY]
	FROM
		[wms].[OP_WMS_QUERY_LIST]
	WHERE
		[ID] = @QUERY_LIST_ID;
	PRINT @QUERY + @WHERE;
	EXEC (@QUERY + @WHERE);
END;