-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	25-Nov-16 @ A-TEAM Sprint 5
-- Description:			SP que actualiza una moneda

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_UPDATE_CURRENCY]
					 @CURRENCY_ID = 1
          ,@CODE_CURRENCY = 'gt'
          ,@NAME_CURRENCY = 'Quetzal'
          ,@SYMBOL_CURRENCY = 'Q'
          ,@IS_DEFAULT = 0
				-- 
				SELECT * FROM [SONDA].[SWIFT_CURRENCY]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_CURRENCY](  
  @CURRENCY_ID INT
 ,@CODE_CURRENCY VARCHAR(50)
 ,@NAME_CURRENCY VARCHAR(250)
 ,@SYMBOL_CURRENCY VARCHAR(5)
 ,@IS_DEFAULT INT
)
AS
BEGIN
	BEGIN TRY		
		--
		UPDATE [SONDA].[SWIFT_CURRENCY] SET
      CODE_CURRENCY = @CODE_CURRENCY
      ,NAME_CURRENCY = @NAME_CURRENCY
      ,SYMBOL_CURRENCY = @SYMBOL_CURRENCY
      ,IS_DEFAULT = @IS_DEFAULT
    WHERE CURRENCY_ID = @CURRENCY_ID			
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '0' DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN 'Error: Ya existe la moneda'
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
