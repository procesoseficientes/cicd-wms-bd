-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	7/26/2017 @Reborn-TEAM Sprint Bearbeitung
-- Description:			SP que actualiza un registro de la tabla SWIFT_PROMO_SKU_SALES_BY_MULTIPLE

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-08-14 @ Team REBORN - Sprint 
-- Description:	   Se agrega LAST_UPDATE

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_UPDATE_SKU_SALES_BY_MULTIPLE_ASSOCIATED_TO_PROMOTION_OF_SKU_SALES_BY_MULTIPLE]
					@SWIFT_PROMO_SKU_SALES_BY_MULTIPLE_ID = 2
					, @MULTIPLE = 10
				-- 
				SELECT * FROM [SONDA].[SWIFT_PROMO_SKU_SALES_BY_MULTIPLE]
					WHERE PROMO_ID = 9 AND CODE_SKU = '100011' AND PACK_UNIT = 1
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_SKU_SALES_BY_MULTIPLE_ASSOCIATED_TO_PROMOTION_OF_SKU_SALES_BY_MULTIPLE] (@SWIFT_PROMO_SKU_SALES_BY_MULTIPLE_ID INT
, @MULTIPLE INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY
    --
    UPDATE [SONDA].[SWIFT_PROMO_SKU_SALES_BY_MULTIPLE]
    SET [MULTIPLE] = @MULTIPLE
       ,[LAST_UPDATE] = GETDATE()
    WHERE [SWIFT_PROMO_SKU_SALES_BY_MULTIPLE_ID] = @SWIFT_PROMO_SKU_SALES_BY_MULTIPLE_ID
    --
    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
     ,'' DbData
  END TRY
  BEGIN CATCH
    SELECT
      -1 AS Resultado
     ,ERROR_MESSAGE() Mensaje
     ,@@error Codigo
  END CATCH
END
