-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		29-08-2016 @ Sprint θ
-- Description:			    SP que crea ruta apartir de que se creo el poligono de ruta

-- Modificacion 30-09-2016 @ A-Team Sprint 2
-- rudi.garcia
-- Se agrego la secuencia para la ruta


/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].[SWIFT_SP_INSERT_ROUTE_FROM_POLYGON]
			@CODE_ROUTE = 'pablo@SONDA'
			,@NAME_ROUTE = 'Ruta de pablo'
		--
		SELECT * FROM [SONDA].SWIFT_ROUTES WHERE CODE_ROUTE = 'pablo@SONDA'

*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_INSERT_ROUTE_FROM_POLYGON (
	@CODE_ROUTE VARCHAR(50)
	,@NAME_ROUTE VARCHAR(50)
	,@CODE_COUNTRY VARCHAR(250) = 'GT'
	,@NAME_COUNTRY VARCHAR(250) = 'Guatemala'
  ,@SELLER_CODE VARCHAR(50) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
  --
  BEGIN TRY
    
    DECLARE  @ROUTE_SEQUENCE INT

    SELECT @ROUTE_SEQUENCE = NEXT VALUE 
    FOR [SONDA].ROUTE_SEQUENCE
	  --
	  INSERT INTO [SONDA].SWIFT_ROUTES (
      ROUTE
  		,CODE_ROUTE
  		,NAME_ROUTE
  		,LAST_UPDATE_BY
  		,LAST_UPDATE
  		,IS_ACTIVE_ROUTE
  		,CODE_COUNTRY
  		,NAME_COUNTRY
      ,SELLER_CODE
  	) VALUES (
      @ROUTE_SEQUENCE
  		,@CODE_ROUTE
  		,@NAME_ROUTE
  		,'Poligonos'
  		,GETDATE()
  		,1
  		,@CODE_COUNTRY
  		,@NAME_COUNTRY
      ,@SELLER_CODE
  	)
    -- ------------------------------------------------------------
		-- Muetra el resutlado
		-- ------------------------------------------------------------
		IF @@error = 0
		BEGIN
		  SELECT
			1 AS RESULTADO
		   ,'Proceso Exitoso' MENSAJE
		   ,0 CODIGO
		   , CONVERT(VARCHAR(16), @ROUTE_SEQUENCE)  AS DbData
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
