-- =======================================================
-- Author:         hector.gonzalez
-- Create date:    19-07-2016
-- Description:    Modifica un registro de la tabla [SWIFT_POLYGON] 

-- Modificacion 29-08-2016 @ Sprint θ
			-- alberto.ruiz
			-- Se agrego llamado para actualizar la ruta		

-- Modificacion 30-09-2016 @ A-Team Sprint 2
-- rudi.garcia
-- Se elimino la parte donde actualiza la ruta.
		   

/*
-- EJEMPLO DE EJECUCION: 
		EXEC [SONDA].[SWIFT_SP_UPDATE_POLYGON]
			@POLYGON_ID = 1099
			,@POLYGON_NAME ='pacopaco2' 
			,@POLYGON_DESCRIPTION = 'Cuatro Caminos'
			,@COMMENT = 'Por la Super 24'
			,@LAST_UPDATE_BY = 'gerente@SONDA'
		--
		SELECT * FROM [SONDA].[SWIFT_POLYGON] WHERE POLYGON_NAME = 'pacopaco2'
		--
		SELECT * FROM [SONDA].SWIFT_ROUTES WHERE NAME_ROUTE = 'pacopaco2'
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_UPDATE_POLYGON (
	@POLYGON_ID INT
	,@POLYGON_NAME VARCHAR(250)
	,@POLYGON_DESCRIPTION VARCHAR(250)
	,@COMMENT VARCHAR(250)
	,@LAST_UPDATE_BY VARCHAR(50)
  ,@TYPE_TASK VARCHAR(20) = NULL
  --,@SAVE_ROUTE INT = 0
  ,@CODE_WAREHOUSE VARCHAR(50) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	--	
	BEGIN TRY  
  --
  -- ------------------------------------------------------------
	-- Actualiza el tipo de tarea de la frecuencia
	-- ------------------------------------------------------------	
  EXEC [SONDA].[SWIFT_SP_UPDATE_FREQUENCY_BY_POYGON]
          @POLYGON_ID = @POLYGON_ID
          ,@TYPE_TASK = @TYPE_TASK
          ,@LAST_UPDATED_BY = @LAST_UPDATE_BY
  -- ------------------------------------------------------------
	-- Validad si tiene hijos el poligono para borrar 
	-- ------------------------------------------------------------	
	IF [SONDA].SWIFT_FN_VALIDATE_POLYGON_HAS_CHILD(@POLYGON_ID) = 0
	BEGIN
		DELETE FROM [SONDA].[SWIFT_POLYGON_POINT]
		WHERE POLYGON_ID = @POLYGON_ID  
	END
	--
	UPDATE [SONDA].[SWIFT_POLYGON]
	SET 
		POLYGON_NAME = @POLYGON_NAME
		,POLYGON_DESCRIPTION = @POLYGON_DESCRIPTION
		,COMMENT = @COMMENT
		,LAST_UPDATE_BY = @LAST_UPDATE_BY
		,LAST_UPDATE_DATETIME = GETDATE()
    ,TYPE_TASK = @TYPE_TASK
    ,CODE_WAREHOUSE = @CODE_WAREHOUSE
	WHERE POLYGON_ID = @POLYGON_ID
    
	-- ------------------------------------------------------------
	-- Actualiza la ruta
	-- ------------------------------------------------------------	
--  IF @SAVE_ROUTE = 1 BEGIN
--    EXEC [SONDA].[SWIFT_SP_UPDATE_ROUTE_FROM_POLYGON]
--    	@CODE_ROUTE = @POLYGON_ID
--    	,@NAME_ROUTE = @POLYGON_NAME
--    --    
--  END
	
	--
	SELECT
		1 AS Resultado
		,'Proceso Exitoso' Mensaje
		,0 Codigo
		,CONVERT(VARCHAR(16), @POLYGON_ID) DbData

	END TRY
	BEGIN CATCH	
		DECLARE @ERROR_CODE INT
		--
		SET @ERROR_CODE = @@ERROR
		--
		ROLLBACK
		--
		SELECT
			-1 AS RESULTADO
			,CASE CAST(@ERROR_CODE AS VARCHAR)
				WHEN '2627' THEN 'No se puede guardar el poligono porque ya existe uno con ese nombre'
				ELSE ERROR_MESSAGE() 
			END MENSAJE
			,@ERROR_CODE CODIGO
			,'0' AS DbData	
	END CATCH
END
