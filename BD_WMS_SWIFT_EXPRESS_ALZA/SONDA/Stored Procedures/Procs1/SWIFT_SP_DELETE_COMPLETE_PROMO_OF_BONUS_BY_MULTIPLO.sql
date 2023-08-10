-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-07-24 @ Team REBORN - Sprint Bearbeitung
-- Description:			SP que elimina una promocion siempre y cuando no este asociada a un Acuerdo Comercial

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].SWIFT_SP_DELETE_COMPLETE_PROMO_OF_BONUS_BY_MULTIPLO
				@PROMO_ID = 2128
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_DELETE_COMPLETE_PROMO_OF_BONUS_BY_MULTIPLO (@PROMO_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  -- -----------------------------------------------------------------
  -- Se almacena en una variable local para evitar Parameter Sniffing
  -- -----------------------------------------------------------------
  DECLARE @PROMOTION_ID INT = @PROMO_ID;
  DECLARE @THIS_ASSOCIATE INT = 0;

  BEGIN TRY
    -- ---------------------------------------------------------------------------------------------------
    -- Se verifica si la promocion enviada como parametro se encuentra asociada a algun acuerdo comercial
    -- ---------------------------------------------------------------------------------------------------
    SELECT
      @THIS_ASSOCIATE = 1
    FROM [SONDA].[SWIFT_TRADE_AGREEMENT_BY_PROMO]
    WHERE [PROMO_ID] = @PROMOTION_ID;

    IF (@THIS_ASSOCIATE = 1)
    BEGIN
      RAISERROR ('No se puede eliminar la Promoción debido a que está siendo utilizada en un Acuerdo Comercial', 16, 1);
    END
    ELSE
    BEGIN

      -- --------------------------------------------------------------------------------
      -- Se eliminan los detalles de la promo por multiplo
      -- --------------------------------------------------------------------------------
      DELETE FROM [SONDA].[SWIFT_PROMO_BONUS_BY_MULTIPLE]
      WHERE [PROMO_ID] = @PROMOTION_ID

      -- --------------------------------------------------------------------------------
      -- Se eliminan la promocion 
      -- --------------------------------------------------------------------------------
      DELETE FROM [SONDA].[SWIFT_PROMO]
      WHERE [PROMO_ID] = @PROMOTION_ID

      -- --------------------------------------------------------------------------------
      -- Se devuelve el resultado como EXITOSO
      -- --------------------------------------------------------------------------------
      SELECT
        1 AS Resultado
       ,'Proceso Exitoso' Mensaje
       ,0 Codigo
       ,'' DbData
    END

  END TRY
  BEGIN CATCH
    -- ---------------------------------------------------------------
    -- Se devuelve el resultado como ERRONEO
    -- ---------------------------------------------------------------
    SELECT
      -1 AS Resultado
     ,ERROR_MESSAGE() Mensaje
     ,@@error Codigo
  END CATCH
END
