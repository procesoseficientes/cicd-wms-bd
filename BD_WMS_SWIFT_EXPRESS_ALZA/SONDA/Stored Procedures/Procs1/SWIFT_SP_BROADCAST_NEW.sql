-- =============================================
-- Autor:				alberto.ruiz	
-- Fecha de Creacion: 	03-12-2015
-- Description:			Se agrego la columna is_actibe_route y se le puso el valor por defecto en 0

-- Modificacion 24-Jan-17 @ A-Team Sprint Bankole
					-- alberto.ruiz
					-- Se agrego parametro de codigo de ruta para filtrar a quienes se les hace broadcast

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_BROADCAST_NEW] @CODE_BROADCAST = '' ,@SOURCE_TABLE = '' ,@SOURCE_KEY = '' ,@SOURCE_VALUE = ''
				--
				SELECT * FROM [SONDA].[SWIFT_PENDING_BROADCAST]
				--
				SELECT * FROM [SONDA].[SWIFT_ROUTES] WHERE IS_ACTIVE_ROUTE = 1
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_BROADCAST_NEW]
	@CODE_BROADCAST VARCHAR(150)
	,@SOURCE_TABLE VARCHAR(250)
	,@SOURCE_KEY VARCHAR(250)
	,@SOURCE_VALUE VARCHAR(250)
	,@OPERATION_TYPE VARCHAR(50)
	,@CODE_ROUTE VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @ROUTE TABLE (
		[CODE_ROUTE] VARCHAR(50)
	)

	-- ------------------------------------------------------------------------------------
	-- Obtiene las rutas a generar el broadcast
	-- ------------------------------------------------------------------------------------
	INSERT INTO @ROUTE
			([CODE_ROUTE])
	SELECT [R].[CODE_ROUTE]
	FROM [SONDA].[SWIFT_ROUTES] [R]
	WHERE --R.IS_ACTIVE_ROUTE = 1 AND 
		(
				@CODE_ROUTE IS NULL
				OR
				[R].[CODE_ROUTE] = @CODE_ROUTE
			)
    --
	INSERT INTO [SONDA].[SWIFT_PENDING_BROADCAST]
	(
		[CODE_BROADCAST]
		,[SOURCE_TABLE]
		,[SOURCE_KEY]
		,[SOURCE_VALUE]
		,[STATUS]
		,[ADDRESS]
		,[OPERATION_TYPE]
	)
	SELECT
		@CODE_BROADCAST
		,@SOURCE_TABLE
		,@SOURCE_KEY
		,@SOURCE_VALUE
		,'PENDING'
		,[R].[CODE_ROUTE]
		,@OPERATION_TYPE
	FROM @ROUTE [R]


	SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo];
END
