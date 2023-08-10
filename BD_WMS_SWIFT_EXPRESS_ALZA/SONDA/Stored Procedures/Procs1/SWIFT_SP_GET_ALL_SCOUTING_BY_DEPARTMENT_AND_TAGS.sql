-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	22-01-2016
-- Description:			Obtiene los clienteS que esten en el poligono de un departamento

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [SONDA].[SWIFT_SP_GET_ALL_SCOUTING_BY_DEPARTMENT_AND_TAGS]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_ALL_SCOUTING_BY_DEPARTMENT_AND_TAGS]

AS
BEGIN
	SET NOCOUNT ON;
	--
	TRUNCATE TABLE [SONDA].SWIFT_TEMP_REPORT_SCOUTING
	TRUNCATE TABLE [SONDA].SWIFT_TEMP_ONLY_SCOUTING
	TRUNCATE TABLE [SONDA].SWIFT_TEMP_ONLY_DEPARTAMENT
	--
	CREATE TABLE #T (
		CODE_CUSTOMER VARCHAR(100)
		,DEPARTMENT_ID INT
	)
	--
	CREATE TABLE #CUSTOMER(
  	  [CODE_CUSTOMER] [varchar](50),
  	  [NombreCliente] [varchar](50),
  	  [DireccionCliente] [varchar](max),
  	  [ReferenciaCliente] [varchar](150),
  	  [TelefonoCliente] [varchar](50),
  	  [Ruta] [varchar](50),
  	  [Operador] [varchar](50),
  	  [FECHA] [date],
  	  [HORA] [time](7),
  	  [Etiqueta] [varchar](50)
	) 
	--
	SELECT 
		D.DEPARTMENT_ID
		,D.NAME
	INTO #D
	FROM [SONDA].[SWIFT_POLYGON_BY_DEPARTMENT] D
	--WHERE D.DEPARTMENT_ID IN (4,14,21)
	ORDER BY D.DEPARTMENT_ID ASC
	--
	DECLARE
		@DEPARTMENT_ID INT
		,@NAME VARCHAR(100)

	WHILE EXISTS (SELECT TOP 1 1 FROM #D)
	BEGIN
		SELECT 
			@DEPARTMENT_ID = D.DEPARTMENT_ID
			,@NAME = D.NAME
		FROM #D D
		--
		PRINT '@NAME: ' + @NAME
		--PRINT '@DEPARTMENT_ID: ' + CAST(@DEPARTMENT_ID AS VARCHAR)
		--
		INSERT INTO #T
		EXEC [SONDA].[SWIFT_SP_GET_CUSTOMERS_IN_DEPARTMENT] @DEPARTMENT_ID = @DEPARTMENT_ID
		--
		DELETE FROM #D WHERE DEPARTMENT_ID = @DEPARTMENT_ID
	END

	-- ------------------------------------------------------------------------------------
	-- Muestra quienes estan en el poligono
	-- ------------------------------------------------------------------------------------
	INSERT INTO [SONDA].SWIFT_TEMP_ONLY_DEPARTAMENT
	SELECT
		T.CODE_CUSTOMER
		,D.NAME
	FROM #T T
	INNER JOIN [SONDA].[SWIFT_POLYGON_BY_DEPARTMENT] D ON (T.DEPARTMENT_ID = D.DEPARTMENT_ID)

	-- ------------------------------------------------------------------------------------
	-- Obtiene clientes
	-- ------------------------------------------------------------------------------------
	INSERT INTO #CUSTOMER
	EXEC [SONDA].[SWIFT_SP_GET_CUSTOMERS_IN_SCOUTING]
	--
	INSERT INTO [SONDA].SWIFT_TEMP_ONLY_SCOUTING select * from #CUSTOMER

	-- ------------------------------------------------------------------------------------
	-- Obtiene clientes
	-- ------------------------------------------------------------------------------------
	INSERT INTO [SONDA].SWIFT_TEMP_REPORT_SCOUTING
	SELECT C.*,ISNULL(D.NAME,'Sin GPS')
	FROM #CUSTOMER C
	LEFT JOIN #T T ON (C.CODE_CUSTOMER = T.CODE_CUSTOMER)
	INNER JOIN [SONDA].SWIFT_POLYGON_BY_DEPARTMENT D ON (T.DEPARTMENT_ID = D.DEPARTMENT_ID)
END
