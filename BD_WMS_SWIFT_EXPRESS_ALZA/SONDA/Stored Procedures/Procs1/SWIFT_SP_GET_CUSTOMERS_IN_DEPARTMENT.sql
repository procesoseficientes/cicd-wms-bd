-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	22-01-2016
-- Description:			Obtiene los clienteS que esten en el poligono de un departamento

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [SONDA].[SWIFT_SP_GET_CUSTOMERS_IN_DEPARTMENT] @DEPARTMENT_ID = 4
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_CUSTOMERS_IN_DEPARTMENT]
(	
	@DEPARTMENT_ID INT = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE
		@POLYGON VARCHAR(2000) = ''
		,@ROWS INT = 0
		,@ROW INT = 1
	
	-- ------------------------------------------------------------------------------------
	-- Obtiene el poligono de la ruta
	-- ------------------------------------------------------------------------------------
	SELECT *
	INTO #POLYGON
	FROM [SONDA].[SWIFT_FN_GET_POLYGON_BY_DEPARTMENT](@DEPARTMENT_ID) D
	ORDER BY D.DEPARTMENT_ID,D.POSITION
	--
	SELECT @ROWS = @@ROWCOUNT

	-- ------------------------------------------------------------------------------------
	-- Forma el poligono
	-- ------------------------------------------------------------------------------------
	WHILE @ROW <= @ROWS
	BEGIN
		PRINT '@ROW: ' + CAST(@ROW AS VARCHAR)
		--
		SELECT TOP 1 
			@POLYGON = @POLYGON + 
				CASE @ROW
					WHEN 1 THEN CAST(LATITUDE AS VARCHAR) + ' ' + CAST(LONGITUDE AS VARCHAR)
					ELSE ' ,' + CAST(LATITUDE AS VARCHAR) + ' ' + CAST(LONGITUDE AS VARCHAR)
				END
		FROM #POLYGON P
		WHERE P.POSITION = @ROW
		--
		SET @ROW = (@ROW + 1)
	END
	--
	SELECT TOP 1 
		@POLYGON = 'POLYGON((' + @POLYGON + ' ,' + CAST(LATITUDE AS VARCHAR) + ' ' + CAST(LONGITUDE AS VARCHAR) + '))'
	FROM #POLYGON P
	WHERE P.POSITION = 1
	--
	PRINT '@POLYGON: ' + @POLYGON
	--
	DECLARE @P geometry = geometry ::STGeomFromText(@POLYGON,0)

	-- ------------------------------------------------------------------------------------
	-- Verifica quienes estan en el poligono
	-- ------------------------------------------------------------------------------------
	SELECT 
		C.CODE_CUSTOMER
		,@p.MakeValid().STContains(geometry::Point(ISNULL(C.LATITUDE,0), ISNULL(C.LONGITUDE,0), 0)) IS_IN
	INTO #CUSTOMER
	FROM [SONDA].SWIFT_CUSTOMERS_NEW C

	-- ------------------------------------------------------------------------------------
	-- Muestra quienes estan en el poligono
	-- ------------------------------------------------------------------------------------
	SELECT 
		 CODE_CUSTOMER
		 ,@DEPARTMENT_ID DEPARTMENT_ID
	FROM #CUSTOMER
	WHERE IS_IN > 0
END
