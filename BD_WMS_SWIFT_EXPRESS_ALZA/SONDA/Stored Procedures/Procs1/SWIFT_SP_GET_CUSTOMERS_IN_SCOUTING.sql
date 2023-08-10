-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	22-01-2016
-- Description:			Obtiene los clienteS que esten en el poligono de un departamento

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [SONDA].[SWIFT_SP_GET_CUSTOMERS_IN_SCOUTING]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_CUSTOMERS_IN_SCOUTING]

AS
BEGIN
	SET NOCOUNT ON;
	
	-- -------------------------------------------------------------------------
	-- Obtiene clientes con cantidad de etiquetas de tienda
	-- -------------------------------------------------------------------------
	SELECT --TA.TAG_VALUE_TEXT
		T.CUSTOMER
		,SUM(
			CASE TA.TAG_COLOR
				WHEN '#F00251' THEN 1
				WHEN '#FF99CC' THEN 1
				WHEN '#79F2DA' THEN 1
				ELSE 0
			END
		) QTY
	INTO #TAG_TIENDA
	FROM [SONDA].SWIFT_TAG_X_CUSTOMER_NEW T
	INNER JOIN [SONDA].SWIFT_TAGS TA ON (T.TAG_COLOR = TA.TAG_COLOR)
	GROUP BY T.CUSTOMER

	-- -------------------------------------------------------------------------
	-- Obtiene el resultado de los scouting con una o sin etiqueta de tienda 
	-- -------------------------------------------------------------------------
	SELECT
		C.CODE_CUSTOMER
		,C.NAME_CUSTOMER NombreCliente
		,C.ADRESS_CUSTOMER DireccionCliente
		,C.REFERENCE ReferenciaCliente
		,C.PHONE_CUSTOMER TelefonoCliente
		,C.CODE_ROUTE Ruta
		,C.LAST_UPDATE_BY Operador
		,CONVERT(DATE,C.LAST_UPDATE,111) FECHA
		,CONVERT(TIME,C.LAST_UPDATE) HORA
		,ISNULL(TA.TAG_VALUE_TEXT,'Sin Etiqueta') Etiqueta
	INTO #R
	FROM [SONDA].SWIFT_CUSTOMERS_NEW C
	INNER JOIN [SONDA].SWIFT_TAG_X_CUSTOMER_NEW T ON (C.CODE_CUSTOMER = T.CUSTOMER)
	INNER JOIN [SONDA].SWIFT_TAGS TA ON (T.TAG_COLOR = TA.TAG_COLOR)
	--WHERE C.LAST_UPDATE < '20160127 00:00:00.000' 
	AND C.CODE_CUSTOMER NOT IN (SELECT DISTINCT CUSTOMER FROM #TAG_TIENDA TT WHERE TT.QTY > 1)
	ORDER BY 7,1 DESC

	-- -------------------------------------------------------------------------
	-- Borra los clientes que tienen solo una tienda o ninguna en etiqueta
	-- -------------------------------------------------------------------------
	DELETE T
	FROM #TAG_TIENDA T
	INNER JOIN #R R ON (T.CUSTOMER = R.CODE_CUSTOMER)

	-- -------------------------------------------------------------------------
	-- Obtiene el resultado de los scouting con tienda C
	-- -------------------------------------------------------------------------
	SELECT TT.CUSTOMER
	INTO #TAG_TIENDA_2
	FROM #TAG_TIENDA TT
	INNER JOIN [SONDA].SWIFT_TAG_X_CUSTOMER_NEW T ON (TT.CUSTOMER = T.CUSTOMER)
	INNER JOIN [SONDA].SWIFT_TAGS TA ON (T.TAG_COLOR = TA.TAG_COLOR)
	WHERE TT.QTY > 1 AND T.TAG_COLOR = '#79F2DA'

	-- -------------------------------------------------------------------------
	-- Obtiene el resultado de los scouting con mas de una etiqueta de tienda y con etiqueta de Tienda C 
	-- -------------------------------------------------------------------------
	INSERT INTO #R
	SELECT
		C.CODE_CUSTOMER
		,C.NAME_CUSTOMER NombreCliente
		,C.ADRESS_CUSTOMER DireccionCliente
		,C.REFERENCE ReferenciaCliente
		,C.PHONE_CUSTOMER TelefonoCliente
		,C.CODE_ROUTE Ruta
		,C.LAST_UPDATE_BY Operador
		,CONVERT(DATE,C.LAST_UPDATE,111) FECHA
		,CONVERT(TIME,C.LAST_UPDATE) HORA
		,ISNULL(TA.TAG_VALUE_TEXT,'Sin Etiqueta') Etiqueta
	FROM [SONDA].SWIFT_CUSTOMERS_NEW C
	LEFT JOIN [SONDA].SWIFT_TAG_X_CUSTOMER_NEW T ON (C.CODE_CUSTOMER = T.CUSTOMER)
	LEFT JOIN [SONDA].SWIFT_TAGS TA ON (T.TAG_COLOR = TA.TAG_COLOR)
	---WHERE C.LAST_UPDATE < '20160127 00:00:00.000'
	AND C.CODE_CUSTOMER IN (SELECT DISTINCT CUSTOMER FROM #TAG_TIENDA_2 TT)
	AND T.TAG_COLOR NOT IN ('#F00251','#FF99CC')
	ORDER BY 7,1 DESC

	-- -------------------------------------------------------------------------
	-- Borra los clientes
	-- -------------------------------------------------------------------------
	DELETE T
	FROM #TAG_TIENDA T
	INNER JOIN #R R ON (T.CUSTOMER = R.CODE_CUSTOMER)

	-- -------------------------------------------------------------------------
	-- Obtiene el resultado de los scouting con mas de una etiqueta de tienda y con etiqueta de Tienda B 
	-- -------------------------------------------------------------------------
	SELECT TT.CUSTOMER
	INTO #TAG_TIENDA_3
	FROM #TAG_TIENDA TT
	INNER JOIN [SONDA].SWIFT_TAG_X_CUSTOMER_NEW T ON (TT.CUSTOMER = T.CUSTOMER)
	INNER JOIN [SONDA].SWIFT_TAGS TA ON (T.TAG_COLOR = TA.TAG_COLOR)
	WHERE TT.QTY > 1 AND T.TAG_COLOR = '#79F2DA'

	-- -------------------------------------------------------------------------
	-- Obtiene el resultado de los scouting con mas de una etiqueta de tienda y con etiqueta de Tienda B 
	-- -------------------------------------------------------------------------
	INSERT INTO #R
	SELECT
		C.CODE_CUSTOMER
		,C.NAME_CUSTOMER NombreCliente
		,C.ADRESS_CUSTOMER DireccionCliente
		,C.REFERENCE ReferenciaCliente
		,C.PHONE_CUSTOMER TelefonoCliente
		,C.CODE_ROUTE Ruta
		,C.LAST_UPDATE_BY Operador
		,CONVERT(DATE,C.LAST_UPDATE,111) FECHA
		,CONVERT(TIME,C.LAST_UPDATE) HORA
		,ISNULL(TA.TAG_VALUE_TEXT,'Sin Etiqueta') Etiqueta
	FROM [SONDA].SWIFT_CUSTOMERS_NEW C
	INNER JOIN [SONDA].SWIFT_TAG_X_CUSTOMER_NEW T ON (C.CODE_CUSTOMER = T.CUSTOMER)
	INNER JOIN [SONDA].SWIFT_TAGS TA ON (T.TAG_COLOR = TA.TAG_COLOR)
	--WHERE C.LAST_UPDATE < '20160127 00:00:00.000'
	AND C.CODE_CUSTOMER IN (SELECT DISTINCT CUSTOMER FROM #TAG_TIENDA_3 TT)
	AND T.TAG_COLOR NOT IN ('#F00251','#79F2DA')
	ORDER BY 7,1 DESC

	SELECT * FROM #R
	
END
