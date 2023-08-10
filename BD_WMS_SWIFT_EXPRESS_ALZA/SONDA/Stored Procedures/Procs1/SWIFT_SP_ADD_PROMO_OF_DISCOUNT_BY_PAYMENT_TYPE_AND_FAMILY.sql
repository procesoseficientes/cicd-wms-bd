-- =============================================
-- Description:			agrega y verifica que una promocion por tipo de pago no este repetida
-- Modificacion:		Christian Hernandez 
-- Fecha de modificacion:5/15/2018 (validacion para DISCOUNT_BY_FAMILY_AND_PAYMENT_TYPE para descuentos de credito y contado)

-- Description:			se cambia casteo de campo '/DISCOUNT' a float al extraer de XML
-- Modificacion:		Marvin.Garcia 
-- Fecha de modificacion:19/06/2018
/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_PROMO_ASSOCIATED_TO_TRADE_AGREEMENT] 
					@TRADE_AGREEMENT_ID = 1
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_ADD_PROMO_OF_DISCOUNT_BY_PAYMENT_TYPE_AND_FAMILY] 
(@PROMO_ID INT
, @XML XML
, @LOGIN_ID VARCHAR)
AS
BEGIN

    DECLARE @TABLE_FAMILY TABLE (
      CODE_FAMILY_SKU VARCHAR(50)
     ,PAYMENT_TYPE VARCHAR(50)
	 ,DISCOUNT NUMERIC(18, 6)
     ,DISCOUNT_TYPE VARCHAR(50)
    )

    INSERT INTO @TABLE_FAMILY ([CODE_FAMILY_SKU], PAYMENT_TYPE, [DISCOUNT], [DISCOUNT_TYPE])
      SELECT
        x.Rec.query('./CODE_FAMILY_SKU').value('.', 'varchar(50)')
       ,x.Rec.query('./PAYMENT_TYPE').value('.', 'varchar(50)')
       ,x.Rec.query('./DISCOUNT').value('.', 'float')
       ,x.Rec.query('./DISCOUNT_TYPE').value('.', 'varchar(50)')
      FROM @XML.nodes('ArrayOfDescuentoPorMontoGeneralDePromo/DescuentoPorMontoGeneralDePromo') AS x (Rec)
	  


    DECLARE @TABLE_RESULT TABLE (
      Resultado INT
     ,Mensaje VARCHAR(250)
    )

	INSERT INTO @TABLE_RESULT(Resultado, Mensaje)
	SELECT -1, 'La familia de sku '+ f. CODE_FAMILY_SKU +' ya existe.' 
	FROM @TABLE_FAMILY F 
	INNER JOIN SONDA.[SWIFT_PROMO_DISCOUNT_BY_PAYMENT_TYPE_AND_FAMILY] DPF ON(
		F.CODE_FAMILY_SKU = DPF.CODE_FAMILY_SKU
		AND F.PAYMENT_TYPE = DPF.PAYMENT_TYPE
	)
	WHERE DPF.PROMO_ID = @PROMO_ID
	
	IF NOT EXISTS (SELECT TOP 1 1 FROM @TABLE_RESULT)BEGIN
		 
      INSERT INTO [SONDA].[SWIFT_PROMO_DISCOUNT_BY_PAYMENT_TYPE_AND_FAMILY] 
	  ([PROMO_ID]
      , [CODE_FAMILY_SKU]
	  , [PAYMENT_TYPE]
      , [DISCOUNT]
      , [DISCOUNT_TYPE]
      )
        SELECT
          @PROMO_ID
         ,[CODE_FAMILY_SKU]
         ,[PAYMENT_TYPE]
         ,[DISCOUNT]
         ,[DISCOUNT_TYPE]         
        FROM @TABLE_FAMILY      
	END    

	SELECT Resultado, Mensaje FROM @TABLE_RESULT
END
