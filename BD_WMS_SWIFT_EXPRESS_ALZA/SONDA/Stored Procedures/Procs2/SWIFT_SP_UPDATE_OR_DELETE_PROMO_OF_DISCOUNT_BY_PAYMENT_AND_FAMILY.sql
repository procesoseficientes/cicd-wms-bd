-- =============================================
-- Autor:                Marvin.Garcia - Cristian.Hernandez
-- Fecha de Creacion:     14-05-2018 @ A-TEAM Sprint Caribú
-- Description:            SP que actualiza o elimina promoción de descuento a familia por tipo dee pago

-- Autor:                Marvin.Garcia
-- Fecha de Modificacion:19-06-2018 @ A-TEAM Sprint Caribú
-- Description:          se cambia casteo de campo '/DISCOUNT' a float al extraer de XML
/*
-- Ejemplo de Ejecucion:
        EXEC SONDA.SWIFT_SP_UPDATE_OR_DELETE_PROMO_OF_DISCOUNT_BY_PAYMENT_AND_FAMILY 
		@PROMO_ID = 0,
		@XML = NULL, 
		@LOGIN_ID = ''
*/
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_OR_DELETE_PROMO_OF_DISCOUNT_BY_PAYMENT_AND_FAMILY] (@PROMO_ID INT
, @XML XML
, @LOGIN_ID VARCHAR)
AS
BEGIN
  BEGIN TRY

    DECLARE @TABLE_FAMILY TABLE (
      PROMO_DISCOUNT_ID INT
     ,DISCOUNT NUMERIC(18, 6)
     ,IS_UPDATE INT
    )


    INSERT INTO @TABLE_FAMILY ([PROMO_DISCOUNT_ID], [DISCOUNT], [IS_UPDATE])
      SELECT
        x.Rec.query('./PROMO_IDENTITY').value('.', 'int')
       ,x.Rec.query('./DISCOUNT').value('.', 'float')
       ,x.Rec.query('./IS_UPDATE').value('.', 'int')       
      FROM @XML.nodes('ArrayOfDescuentoPorMontoGeneralDePromo/DescuentoPorMontoGeneralDePromo') AS x (Rec)

    -- --------------------------------
    -- Se actualiza los descuentos 
    -- --------------------------------

    UPDATE [DF]
    SET [DF].[DISCOUNT] = [F].[DISCOUNT]
       ,[DF].[LAST_UPDATE] = GETDATE()
    FROM [SONDA].[SWIFT_PROMO_DISCOUNT_BY_PAYMENT_TYPE_AND_FAMILY] [DF]
    INNER JOIN @TABLE_FAMILY [F]
      ON (
      [F].[PROMO_DISCOUNT_ID] = [DF].[PROMO_DISCOUNT_ID]
      )
    WHERE [F].[IS_UPDATE] = 1

    -- --------------------------------
    -- Se eliminan los descuentos
    -- --------------------------------

    DELETE [DF]
      FROM [SONDA].[SWIFT_PROMO_DISCOUNT_BY_PAYMENT_TYPE_AND_FAMILY] [DF]
      INNER JOIN @TABLE_FAMILY [F]
        ON (
        [F].[PROMO_DISCOUNT_ID] = [DF].[PROMO_DISCOUNT_ID]
        )
    WHERE [F].[IS_UPDATE] = 0

    -- --------------------------------
    -- Se actualiza la promo
    -- --------------------------------

    UPDATE [SONDA].[SWIFT_PROMO]
    SET [LAST_UPDATE] = GETDATE()
    WHERE [PROMO_ID] = @PROMO_ID;


    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo

  END TRY
  BEGIN CATCH
    SELECT
      -1 AS Resultado
     ,CASE CAST(@@error AS VARCHAR)
        WHEN '2627' THEN 'Error al insertar el descuento por tipo de pago y familia de escala.'
        ELSE ERROR_MESSAGE()
      END Mensaje
     ,@@error Codigo
  END CATCH
END
