-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-07-24 @ Team REBORN - Sprint Bearbeitung
-- Description:			SP que elimina una promocion siempre y cuando no este asociada a un Acuerdo Comercial

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].SWIFT_SP_DELETE_PROMO_OF_BONUS_BY_COMBO
				@PROMO_ID = 2128
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_DELETE_PROMO_OF_BONUS_BY_COMBO (@PROMO_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  -- -----------------------------------------------------------------
  -- Se almacena en una variable local para evitar Parameter Sniffing
  -- -----------------------------------------------------------------
  DECLARE @PROMOTION_ID INT = @PROMO_ID;
  DECLARE @THIS_ASSOCIATE INT = 0;
  DECLARE @PROMO_RULE_BY_COMBO_ID INT;

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

      -- -------------------------------------------------------------------------------
      -- Se obtienen las reglas que se eliminaran
      -- -------------------------------------------------------------------------------
      SELECT
        [PBR].[PROMO_ID]
       ,[PBR].[PROMO_RULE_BY_COMBO_ID] INTO #PROMO_RULES_BY_COMBO_ID
      FROM [SONDA].[SWIFT_PROMO_BY_BONUS_RULE] [PBR]
      WHERE [PBR].[PROMO_ID] = @PROMOTION_ID

      -- -------------------------------------------------------------------------------
      -- Se eliminan las relaciones entre la promo y las reglas
      -- -------------------------------------------------------------------------------

      DELETE FROM [SONDA].[SWIFT_PROMO_BY_BONUS_RULE]
      WHERE [PROMO_ID] = @PROMOTION_ID

      -- --------------------------------------------------------------------------------
      -- Se elimina la promocion
      -- --------------------------------------------------------------------------------
      DELETE FROM [SONDA].[SWIFT_PROMO]
      WHERE [PROMO_ID] = @PROMOTION_ID



      -- -------------------------------------------------------------------------------
      -- Se recorren las reglas y sus skus y se eliminan
      -- -------------------------------------------------------------------------------
      WHILE EXISTS (SELECT TOP 1
            1
          FROM [#PROMO_RULES_BY_COMBO_ID]
          ORDER BY [PROMO_RULE_BY_COMBO_ID])
      BEGIN
        SELECT
          @PROMO_RULE_BY_COMBO_ID = [prbci].[PROMO_RULE_BY_COMBO_ID]
        FROM [#PROMO_RULES_BY_COMBO_ID] [prbci]
        ORDER BY [prbci].[PROMO_RULE_BY_COMBO_ID]

        DELETE FROM [SONDA].[SWIFT_PROMO_SKU_BY_PROMO_RULE]
        WHERE [PROMO_RULE_BY_COMBO_ID] = @PROMO_RULE_BY_COMBO_ID

        DELETE FROM [SONDA].[SWIFT_PROMO_BY_COMBO_PROMO_RULE]
        WHERE [PROMO_RULE_BY_COMBO_ID] = @PROMO_RULE_BY_COMBO_ID

        DELETE FROM [#PROMO_RULES_BY_COMBO_ID]
        WHERE [PROMO_RULE_BY_COMBO_ID] = @PROMO_RULE_BY_COMBO_ID

      END

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
