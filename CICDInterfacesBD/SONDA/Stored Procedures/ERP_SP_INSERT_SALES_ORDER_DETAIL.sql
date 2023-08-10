-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	8/11/2017 @ NEXUS-Team Sprint Banjo-Kazooie 
-- Description:			Se inserta el detalle del pedido en ERP_SALES_ORDER_DETAIL_CHANNEL_MODERN y se devuelve la secuencia

-- Modificacion 9/21/2017 @ NEXUS-Team Sprint DuckHunt
					-- rodrigo.gomez
					-- Se cambia el filtro por DocDueDate en lugar de Docdate

-- Modificacion 03-Nov-17 @ Nexus Team Sprint F-Zero
					-- alberto.ruiz
					-- Se agrega descuento

/*
-- Ejemplo de Ejecucion:
				DECLARE @START_DATE DATETIME = GETDATE()-30
					,@END_DATE DATETIME = GETDATE()
					,@ID INT
				
				EXEC [SONDA].[ERP_SP_INSERT_SALES_ORDER_DETAIL] 
					@START_DATE = @START_DATE, -- varchar(100)
					@END_DATE = @END_DATE, -- varchar(100)
					@SEQUENCE = @ID OUTPUT	-- int

				SELECT @ID
*/
-- =============================================
CREATE PROCEDURE [SONDA].[ERP_SP_INSERT_SALES_ORDER_DETAIL](
	@START_DATE VARCHAR(100)
	,@END_DATE VARCHAR(100)
	,@SEQUENCE INT OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @SQL VARCHAR(4000) = '', 
		@ID INT

	INSERT INTO [SONDA].[ERP_SALES_ORDER_SEQUENCE_CHANNEL_MODERN]
			([StartDate], [EndDate])
	VALUES
			(@START_DATE  -- StartDate - datetime
				, @END_DATE  -- EndDate - datetime
				)
	SELECT @ID = SCOPE_IDENTITY(), @SEQUENCE = SCOPE_IDENTITY()

	select @SQL = '
		INSERT INTO [SONDA].[ERP_SALES_ORDER_DETAIL_CHANNEL_MODERN]
		SELECT
			'+CAST(@ID AS VARCHAR)+'
		  ,*
		FROM OPENQUERY([ARIUMSERVER], ''
		SELECT DISTINCT
			[T0].[DocDate]
			,[T0].[DocNum]
			,[T0].[U_Serie]
			,[T0].[U_NoDocto]
			,[T0].[CardCode]
			,[T0].[CardName]
			,[T2].[SlpName]
			,[T0].[U_oper]
			,[T1].[ItemCode]
			,[T1].[ItemCode] [U_MasterIdSKU]
			,''''Arium'''' [U_OwnerSKU]
			,[T1].[Dscription]
			,CASE	WHEN [T0].[CANCELED] = ''''N'''' THEN [T1].[Quantity]
					WHEN [T0].[CANCELED] = ''''Y'''' THEN 0
				END AS Quantity
			,CASE	WHEN [T0].[CANCELED] = ''''N'''' THEN [T1].[PriceAfVAT]
					WHEN [T0].[CANCELED] = ''''Y'''' THEN 0
				END AS PRECIO_CON_IVA
			,CASE	WHEN [T0].[CANCELED] = ''''N''''
					THEN ([T1].[Quantity] * [T1].[PriceAfVAT])
					WHEN [T0].[CANCELED] = ''''Y'''' THEN 0
				END AS TOTAL_LINEA_SIN_DESCUENTO
			,CASE	WHEN [T0].[CANCELED] = ''''N''''
					THEN ([T1].[Quantity] * [T1].[PriceAfVAT])
							- (([T1].[Quantity] * [T1].[PriceAfVAT])
								* ([T0].[DiscPrcnt] / 100))
					WHEN [T0].[CANCELED] = ''''Y'''' THEN 0
				END AS TOTAL_LINEA_CON_DESCUENTO_APLICADO
			,[T1].[WhsCode]
			,CAST([T0].[DiscPrcnt] AS DECIMAL) / 100 AS DESCUENTO_FACTURA
			,CASE	WHEN [T0].[CANCELED] = ''''N'''' THEN ''''FACTURA''''
					WHEN [T0].[CANCELED] = ''''Y'''' THEN ''''ANULADA''''
				END AS STATUS
			,[T1].[LineNum] + 1 AS NUMERO_LINEA
			,[T0].[CardCode] [U_MasterIDCustomer]
			,''''Arium'''' [U_OwnerCustomer]
			,''''Arium'''' [Owner]
			,T1.OpenQty
			,T1.DiscPrcnt LineDiscPrcnt
		FROM Me_Llega_DB.dbo.ORDR T0--ENCABEZADO OV
			INNER JOIN Me_Llega_DB.dbo.RDR1 T1 ON T0.[DocEntry] = T1.[DocEntry]-- DETALLE OV
			LEFT JOIN Me_Llega_DB.dbo.OSLP T2 ON T0.U_OPER = T2.U_OPERADOR  --EMPLEADOS DE VENTAS
		WHERE
			[T0].[CANCELED] <> ''''C''''
			AND [T0].[CardCode] NOT LIKE ''''SO%''''
			AND T0.DocDueDate BETWEEN CAST('''''+@START_DATE+''''' AS VARCHAR) AND CAST('''''+@END_DATE+''''' AS VARCHAR);
	'')	'
	--
	PRINT(@SQL)
	--
	EXEC(@SQL)
	--
	RETURN;
END