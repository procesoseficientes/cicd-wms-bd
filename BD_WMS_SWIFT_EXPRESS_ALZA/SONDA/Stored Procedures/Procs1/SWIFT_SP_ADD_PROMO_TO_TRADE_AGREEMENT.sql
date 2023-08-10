-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	7/26/2017 @ Sprint Bearbeitung
-- Description:			Agrega un registro a la tabla SWIFT_TRADE_AGREEMENT_BY_PROMO

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_ADD_PROMO_TO_TRADE_AGREEMENT]
					@TRADE_AGREEMENT_ID = 1, -- int
					@PROMO_ID = 5, -- int
					@FREQUENCY = 'ALWAYS' -- varchar(50)
				-- 
				SELECT * FROM [SONDA].[SWIFT_TRADE_AGREEMENT_BY_PROMO] 
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_ADD_PROMO_TO_TRADE_AGREEMENT] (@TRADE_AGREEMENT_ID INT
, @PROMO_ID INT
, @FREQUENCY VARCHAR(50) = 'ALWAYS')
AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY
    DECLARE @ID INT
    --

    IF (EXISTS (SELECT
          [TAP].[TRADE_AGREEMENT_ID]
         ,[TAP].[PROMO_ID]
         ,[P].[PROMO_TYPE]
        FROM [SONDA].[SWIFT_TRADE_AGREEMENT_BY_PROMO] [TAP]
        INNER JOIN [SONDA].[SWIFT_PROMO] [P]
          ON [TAP].[PROMO_ID] = [P].[PROMO_ID]
        WHERE [TAP].[TRADE_AGREEMENT_ID] = @TRADE_AGREEMENT_ID
        AND [P].[PROMO_TYPE] = (SELECT
            [P2].[PROMO_TYPE]
          FROM [SONDA].[SWIFT_PROMO] [P2]
          WHERE [P2].[PROMO_ID] = @PROMO_ID))
      )
    BEGIN
      DECLARE @PROMO_TYPE VARCHAR(50) = (SELECT TOP 1
                  PROMO_TYPE
                FROM [SONDA].[SWIFT_PROMO] [P]
                WHERE [P].[PROMO_ID] = @PROMO_ID)
             ,@ERROR VARCHAR(100)
      SET @ERROR = 'No se pueden agregar dos promociones del mismo tipo.: ' +
                                                                             CASE @PROMO_TYPE
                                                                               WHEN 'BONUS_BY_COMBO' THEN 'Bonificación Combos'
                                                                               WHEN 'BONUS_BY_GENERAL_AMOUNT' THEN 'BMG'
                                                                               WHEN 'BONUS_BY_MULTIPLE' THEN 'Bonificación Múltiplos'
                                                                               WHEN 'BONUS_BY_SCALE' THEN 'Bonificación Escalas'
                                                                               WHEN 'DISCOUNT_BY_GENERAL_AMOUNT' THEN 'DMG'
                                                                               WHEN 'DISCOUNT_BY_SCALE' THEN 'Descuento Escalas'
                                                                               WHEN 'SALES_BY_MULTIPLE' THEN 'VM'
																			   WHEN 'DISCOUNT_BY_FAMILY_AND_PAYMENT_TYPE' THEN 'Tipo de Pago por Familia'
																			   WHEN 'SPECIAL_PRICE' THEN 'Precio Especial'
                                                                             END


      RAISERROR (@ERROR, 16, 1)
      RETURN;
    END


    INSERT INTO [SONDA].[SWIFT_TRADE_AGREEMENT_BY_PROMO] ([TRADE_AGREEMENT_ID]
    , [PROMO_ID]
    , [FREQUENCY])
      VALUES (@TRADE_AGREEMENT_ID  -- TRADE_AGREEMENT_ID - int
      , @PROMO_ID  -- PROMO_ID - int
      , @FREQUENCY  -- FREQUENCY - varchar(50)
      )
    --
    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
  END TRY
  BEGIN CATCH
    SELECT
      -1 AS Resultado
     ,ERROR_MESSAGE() Mensaje
     ,@@error Codigo
  END CATCH
END
