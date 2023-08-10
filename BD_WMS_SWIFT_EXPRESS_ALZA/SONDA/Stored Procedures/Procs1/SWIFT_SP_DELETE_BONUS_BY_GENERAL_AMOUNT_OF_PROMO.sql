-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-07-03 @ Team REBORN - Sprint Anpassung
-- Description:	        Sp que borra de la tabla SWIFT_PROMO_BONUS_BY_GENERAL_AMOUNT una bonificacion por monto general

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-08-14 @ Team REBORN - Sprint 
-- Description:	   Se agrega actualizacion de tabla SWIFT_PROMO

/*
-- Ejemplo de Ejecucion:
			EXEC  [SONDA].[SWIFT_SP_DELETE_BONUS_BY_GENERAL_AMOUNT_OF_PROMO] @PROMO_BONUS_BY_GENERAL_AMOUNT_ID = 2
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_DELETE_BONUS_BY_GENERAL_AMOUNT_OF_PROMO] (@PROMO_BONUS_BY_GENERAL_AMOUNT_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  --

  BEGIN TRY


    DECLARE @PROMO_ID INT;
    --
    SET @PROMO_ID = (SELECT TOP 1
        [PROMO_ID]
      FROM [SONDA].[SWIFT_PROMO_BONUS_BY_GENERAL_AMOUNT]
      WHERE [PROMO_BONUS_BY_GENERAL_AMOUNT_ID] = @PROMO_BONUS_BY_GENERAL_AMOUNT_ID)

    --Eliminamos la Bonificacion por monto general

    DELETE [SONDA].[SWIFT_PROMO_BONUS_BY_GENERAL_AMOUNT]
    WHERE [PROMO_BONUS_BY_GENERAL_AMOUNT_ID] = @PROMO_BONUS_BY_GENERAL_AMOUNT_ID
    --
    UPDATE [SONDA].[SWIFT_PROMO]
    SET [LAST_UPDATE] = GETDATE()
    WHERE [PROMO_ID] = @PROMO_ID;
    --

    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
     ,CAST(@PROMO_BONUS_BY_GENERAL_AMOUNT_ID AS VARCHAR) DbData

  END TRY
  BEGIN CATCH

    SELECT
      -1 AS Resultado
     ,ERROR_MESSAGE() Mensaje
     ,@@error Codigo

  END CATCH;

END
