-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	30-04-2018 @ A-TEAM Sprint Caribú
-- Description:			SP que agrega la promo de descuento por familia

-- Autor:				marvin.garcia
-- Fecha de Modificacion: 19-jun-2018 @ A-Team Sprint Caribú
-- Descripcion:			se cambia casteo de campo '/DISCOUNT' a float al extraer de XML

/*
-- Ejemplo de Ejecucion:
		EXEC [SONDA].SWIFT_SP_ADD_PROMO_OF_DISCOUNT_BY_FAMILY
		@PROMO_ID = 2114
		,@XML = ''
		,@LOGIN_ID = 'GERENTE@SONDA'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_ADD_PROMO_OF_DISCOUNT_BY_FAMILY] (@PROMO_ID INT
, @XML XML
, @LOGIN_ID VARCHAR)
AS
BEGIN
  BEGIN TRY

    DECLARE @TABLE_FAMILY TABLE (
      CODE_FAMILY_SKU VARCHAR(50)
     ,LOW_AMOUNT NUMERIC(18, 6)
     ,HIGH_AMOUNT NUMERIC(18, 6)
     ,DISCOUNT NUMERIC(18, 6)
     ,DISCOUNT_TYPE VARCHAR(50)
    )

    INSERT INTO @TABLE_FAMILY ([CODE_FAMILY_SKU], [LOW_AMOUNT], [HIGH_AMOUNT], [DISCOUNT], [DISCOUNT_TYPE])
      SELECT
        x.Rec.query('./CODE_FAMILY_SKU').value('.', 'varchar(50)')
       ,x.Rec.query('./LOW_AMOUNT').value('.', 'numeric(18, 6)')
       ,x.Rec.query('./HIGH_AMOUNT').value('.', 'numeric(18, 6)')
       ,x.Rec.query('./DISCOUNT').value('.', 'float')
       ,x.Rec.query('./DISCOUNT_TYPE').value('.', 'varchar(50)')
      FROM @XML.nodes('ArrayOfDescuentoPorMontoGeneralDePromo/DescuentoPorMontoGeneralDePromo') AS x (Rec)



    DECLARE @TABLE_RESULT TABLE (
      Resultado INT
     ,Mensaje VARCHAR(250)
    )


    INSERT INTO @TABLE_RESULT ([Resultado], [Mensaje])
      SELECT
        -1
       ,CASE
                WHEN [F].[LOW_AMOUNT] BETWEEN [DF].[LOW_AMOUNT] AND [DF].[HIGH_AMOUNT] THEN 'Límite inferior del Rango de Venta Mínima se encuentra entre rango existente.'
                WHEN [F].[HIGH_AMOUNT] BETWEEN [DF].[LOW_AMOUNT] AND [DF].[HIGH_AMOUNT] THEN 'Límite superior del Rango de Venta Máxima se encuentra entre rango existente.'
                WHEN [DF].[LOW_AMOUNT] BETWEEN [F].[LOW_AMOUNT] AND [F].[HIGH_AMOUNT] THEN 'Rango de Venta Mínima y Venta Máxima, absorbe un rango existente.'
                ELSE 'Rangos mal definidos.'
              END

      FROM [SONDA].[SWIFT_PROMO_DISCOUNT_BY_FAMILY] AS [DF]
      INNER JOIN @TABLE_FAMILY [F]
        ON (
        [DF].[CODE_FAMILY_SKU] = [F].[CODE_FAMILY_SKU]
        )
      WHERE (
      (
      [F].[LOW_AMOUNT] BETWEEN [DF].[LOW_AMOUNT] AND [DF].[HIGH_AMOUNT]
      OR [F].[HIGH_AMOUNT] BETWEEN [DF].[LOW_AMOUNT] AND [DF].[HIGH_AMOUNT]
      )
      OR (
      [DF].[LOW_AMOUNT] BETWEEN [F].[LOW_AMOUNT] AND [F].[HIGH_AMOUNT]
      OR [DF].[HIGH_AMOUNT] BETWEEN [F].[LOW_AMOUNT] AND [F].[HIGH_AMOUNT]
      )
      )
      AND [DF].[PROMO_ID] = @PROMO_ID

    IF NOT EXISTS (SELECT TOP 1
          1
        FROM @TABLE_RESULT)
    BEGIN
      INSERT INTO [SONDA].[SWIFT_PROMO_DISCOUNT_BY_FAMILY] ([PROMO_ID]
      , [CODE_FAMILY_SKU]
      , [LOW_AMOUNT]
      , [HIGH_AMOUNT]
      , [DISCOUNT]
      , [DISCOUNT_TYPE]
      )
        SELECT
          @PROMO_ID
         ,[CODE_FAMILY_SKU]
         ,[LOW_AMOUNT]
         ,[HIGH_AMOUNT]
         ,[DISCOUNT]
         ,[DISCOUNT_TYPE]         
        FROM @TABLE_FAMILY      
    END

    SELECT
        [R].[Resultado]
       ,[R].[Mensaje]
       ,0 Codigo
    FROM @TABLE_RESULT [R]
  END TRY
  BEGIN CATCH
    SELECT
      -1 AS Resultado
     ,CASE CAST(@@error AS VARCHAR)
        WHEN '2627' THEN 'Error al insertar el descuento por familia de escala.'
        ELSE ERROR_MESSAGE()
      END Mensaje
     ,@@error Codigo
  END CATCH
END
