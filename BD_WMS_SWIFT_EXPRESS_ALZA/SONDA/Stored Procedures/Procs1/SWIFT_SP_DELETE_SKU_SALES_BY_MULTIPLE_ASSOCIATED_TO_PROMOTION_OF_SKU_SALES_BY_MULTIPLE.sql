-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	7/26/2017 @ Reborn-TEAM Sprint Bearbeitung
-- Description:			SP que borra un registro de la tabla SWIFT_PROMO_SKU_SALES_BY_MULTIPLE

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-08-14 @ Team REBORN - Sprint 
-- Description:	   Se agrego actualizacion a SWIFT_PROMO

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [SONDA].SWIFT_PROMO WHERE PROMO_ID = 9
				
        SELECT * FROM [SONDA].[SWIFT_PROMO_SKU_SALES_BY_MULTIPLE]
				WHERE [PROMO_ID] = 9
				--
				EXEC [SONDA].[SWIFT_SP_DELETE_SKU_SALES_BY_MULTIPLE_ASSOCIATED_TO_PROMOTION_OF_SKU_SALES_BY_MULTIPLE]
				@SWIFT_PROMO_SKU_SALES_BY_MULTIPLE_ID = 4
				-- 
				SELECT * FROM [SONDA].[SWIFT_PROMO_SKU_SALES_BY_MULTIPLE]
				WHERE [PROMO_ID] = 9
        
        SELECT * FROM [SONDA].SWIFT_PROMO WHERE PROMO_ID = 9
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_DELETE_SKU_SALES_BY_MULTIPLE_ASSOCIATED_TO_PROMOTION_OF_SKU_SALES_BY_MULTIPLE] (@SWIFT_PROMO_SKU_SALES_BY_MULTIPLE_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @PROMO_ID INT;
  --
  SET @PROMO_ID = (SELECT TOP 1
      [PROMO_ID]
    FROM [SONDA].[SWIFT_PROMO_SKU_SALES_BY_MULTIPLE]
    WHERE [SWIFT_PROMO_SKU_SALES_BY_MULTIPLE_ID] = @SWIFT_PROMO_SKU_SALES_BY_MULTIPLE_ID)
  --
  BEGIN TRY
    DELETE FROM [SONDA].[SWIFT_PROMO_SKU_SALES_BY_MULTIPLE]
    WHERE [SWIFT_PROMO_SKU_SALES_BY_MULTIPLE_ID] = @SWIFT_PROMO_SKU_SALES_BY_MULTIPLE_ID
    --
    UPDATE [SONDA].[SWIFT_PROMO]
    SET [LAST_UPDATE] = GETDATE()
    WHERE [PROMO_ID] = @PROMO_ID;
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
