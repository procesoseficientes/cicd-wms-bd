-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		29-08-2016 @ Sprint θ
-- Description:			    SP que elimina una ruta al eliminar un poligono de ruta

-- Modificacion 30-09-2016 @ A-Team Sprint 2
-- rudi.garcia
-- Se agrego el try catch y que se retorne una operacion.


/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].[SWIFT_SP_UPDATE_ROUTE_FROM_POLYGON]
			@CODE_ROUTE = 'pablo@SONDA'
			,@NAME_ROUTE = 'Ruta de pablo2'
		--
		SELECT * FROM [SONDA].SWIFT_ROUTES WHERE CODE_ROUTE = 'pablo@SONDA'

*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_UPDATE_ROUTE_FROM_POLYGON (
	@CODE_ROUTE VARCHAR(50)
	,@NAME_ROUTE VARCHAR(50)
	,@CODE_COUNTRY VARCHAR(250) = 'GT'
	,@NAME_COUNTRY VARCHAR(250) = 'Guatemala'
  ,@SELLER_CODE VARCHAR(50) = NULL
)
AS
BEGIN
  BEGIN TRY
	  SET NOCOUNT ON;
    DECLARE @ID_ROUTE INT
	--
  	UPDATE [SONDA].SWIFT_ROUTES
  	SET
  		NAME_ROUTE = @NAME_ROUTE
  		,LAST_UPDATE_BY = 'Poligonos'
  		,LAST_UPDATE =  GETDATE()
  		,CODE_COUNTRY = @CODE_COUNTRY
  		,NAME_COUNTRY = @NAME_COUNTRY
      ,SELLER_CODE = @SELLER_CODE
  	WHERE CODE_ROUTE = @CODE_ROUTE
  -- ------------------------------------------------------------
		-- Muetra el resutlado
		-- ------------------------------------------------------------

    SELECT TOP 1 @ID_ROUTE  = [ROUTE]
    FROM [SONDA].SWIFT_ROUTES
    WHERE CODE_ROUTE = @CODE_ROUTE
		
    IF @@error = 0
		BEGIN
		  SELECT
			1 AS RESULTADO
		   ,'Proceso Exitoso' MENSAJE
		   ,0 CODIGO
		   , CONVERT(VARCHAR, @ID_ROUTE)  AS DbData
		END 
		ELSE
		BEGIN
		  SELECT
			-1 AS RESULTADO
		   ,ERROR_MESSAGE() MENSAJE
		   ,@@ERROR CODIGO
			, '0' AS DbData
		END
	END TRY
  BEGIN CATCH
		DECLARE @ERROR_CODE INT
		--
		SET @ERROR_CODE = @@ERROR
		--
		SELECT
			-1 AS RESULTADO
			, ERROR_MESSAGE() AS MENSAJE
			,@ERROR_CODE CODIGO
			, '0' AS DbData
		--
	END CATCH
END
