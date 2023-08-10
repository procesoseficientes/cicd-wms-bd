-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	6/29/2017 @ A-TEAM Sprint Anpassung 
-- Description:			SP que borra una promo de descuento por escala

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-08-14 @ Team REBORN - Sprint 
-- Description:	   Se agrego update a SWIFT_PROMO

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [SONDA].SWIFT_PROMO WHERE PROMO_ID = 7
				SELECT * FROM [SONDA].[SWIFT_PROMO_DISCOUNT_BY_SCALE]
				--
				EXEC [SONDA].[SWIFT_SP_DELETE_PROMO_OF_DISCOUNT_BY_SCALE]
				@PROMO_DISCOUNT_BY_SCALE_ID = 2
				-- 
				SELECT * FROM [SONDA].[SWIFT_PROMO_DISCOUNT_BY_SCALE]
        SELECT * FROM [SONDA].SWIFT_PROMO WHERE PROMO_ID = 7
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_DELETE_PROMO_OF_DISCOUNT_BY_SCALE] (@PROMO_DISCOUNT_BY_SCALE_ID INT)
AS
BEGIN
  BEGIN TRY

    DECLARE @PROMO_ID INT;
    --
    SET @PROMO_ID = (SELECT TOP 1
        [PROMO_ID]
      FROM [SONDA].[SWIFT_PROMO_DISCOUNT_BY_SCALE]
      WHERE [PROMO_DISCOUNT_ID] = @PROMO_DISCOUNT_BY_SCALE_ID)
    --
    DELETE FROM [SONDA].[SWIFT_PROMO_DISCOUNT_BY_SCALE]
    WHERE [PROMO_DISCOUNT_ID] = @PROMO_DISCOUNT_BY_SCALE_ID
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
