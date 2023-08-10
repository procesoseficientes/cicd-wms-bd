-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	25-Nov-16 @ A-TEAM Sprint 5
-- Description:			SP validad si ya tiene una modena por default 

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_VALIDATE_TRAN_FOR_CURRENCY]
					 @CURRENCY_ID = 1
				-- 
				SELECT * FROM [SONDA].[SWIFT_CURRENCY]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_VALIDATE_TRAN_FOR_CURRENCY](  
 @CURRENCY_ID INT = NULL
 ,@IS_DEFAULT INT = NULL
)
AS
BEGIN
	BEGIN TRY
    DECLARE @ID INT 
    
    -- ------------------------------------------------------------------------------------
  	-- Obtenemos el id que este por defecto
	  -- ------------------------------------------------------------------------------------

    SELECT TOP 1
      @ID = C.CURRENCY_ID
    FROM [SONDA].[SWIFT_CURRENCY] C
    WHERE C.IS_DEFAULT = 1
    
    -- ------------------------------------------------------------------------------------
  	-- Validamos si es el mismo
	  -- ------------------------------------------------------------------------------------
    IF ISNULL(@CURRENCY_ID, 0) <> ISNULL(@ID, 0) AND ISNULL(@IS_DEFAULT, 0) = 1 BEGIN    
    -- ------------------------------------------------------------------------------------
  	-- Validar si tiene transacciones la moneda ya que tenemos el id
	  -- ------------------------------------------------------------------------------------
    
    ----- Se debe agregar la validacion

    -- ------------------------------------------------------------------------------------
  	-- Si no tiene transacciones la moneda default se actualiza
	  -- ------------------------------------------------------------------------------------
      UPDATE [SONDA].[SWIFT_CURRENCY] SET
        [IS_DEFAULT] = 0
      WHERE [CURRENCY_ID] = @ID
    END
    --
		
    SELECT 1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '0' DbData

	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,ERROR_MESSAGE() Mensaje 
		,@@ERROR Codigo
	END CATCH
END
