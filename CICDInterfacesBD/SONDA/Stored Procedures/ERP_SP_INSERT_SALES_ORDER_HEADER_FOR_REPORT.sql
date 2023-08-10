-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	9/28/2017 @ NEXUS-Team Sprint DuckHunt/SONDA
-- Description:			Inserta las ordenes de venta en ERP_SALES_ORDER_HEADER_CHANNEL_MODERN y devuelve el ID de secuencia para el reporte de trazabilidad.

/*
-- Ejemplo de Ejecucion:
				DECLARE @START_DATE DATETIME = GETDATE()-1
					,@END_DATE DATETIME = GETDATE()
					,@ID INT
				
				EXEC [SONDA].[ERP_SP_INSERT_SALES_ORDER_HEADER_FOR_REPORT] 
					@START_DATE = @START_DATE, -- varchar(100)
					@END_DATE = @END_DATE, -- varchar(100)
					@SEQUENCE = @ID OUTPUT	-- int

				SELECT @ID
*/
-- =============================================
CREATE PROCEDURE [SONDA].[ERP_SP_INSERT_SALES_ORDER_HEADER_FOR_REPORT](
	@START_DATE VARCHAR(100)
	,@END_DATE VARCHAR(100)
	,@SEQUENCE INT OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE 
		@SQL VARCHAR(4000) = '', 
		@ID INT
	--
	INSERT INTO [SONDA].[ERP_SALES_ORDER_SEQUENCE_CHANNEL_MODERN]
			([StartDate], [EndDate])
	VALUES
			(@START_DATE  -- StartDate - datetime
				, @END_DATE  -- EndDate - datetime
				)
	--
	SELECT 
		@ID = SCOPE_IDENTITY()
		,@SEQUENCE = SCOPE_IDENTITY()
	--
	SELECT @SQL = '
		INSERT INTO [SONDA].[ERP_SALES_ORDER_HEADER_CHANNEL_MODERN]
		SELECT
			'+CAST(@ID AS VARCHAR)+'
		  ,*
		FROM OPENQUERY([ERP_SERVER], ''
		SELECT DISTINCT 
			T0.DocDate,
			T0.DocNum as DocNum,
			T0.U_Serie,
			T0.U_NoDocto,
			T0.CardCode,
			T0.CardName,
			T0.CardCode U_MasterIDCustomer,
			''''Arium'''' U_OwnerCustomer,
			T2.SlpName,
			T0.U_oper,
			CAST(T0.DiscPrcnt AS DECIMAL) / 100 AS DESCUENTO_FACTURA,--T0.DiscPrcnt,
			CASE
			WHEN T0.CANCELED = ''''N'''' THEN ''''NO''''
			WHEN T0.CANCELED = ''''Y'''' THEN ''''SI''''
			END AS STATUS,
			T0.Comments,
			T0.DiscPrcnt,
			T0.Address,
			T0.Address2,
			T3.AddrTypeS AS ShipToAddressType,
			T3.StreetS AS ShipToStreet,
			T3.StateS AS ShipToState,
			T3.CountryS AS ShipToCountry,
			T0.DocEntry,
			T2.SlpCode,
			T0.DocCur,
			T0.DocRate,
			T0.DocDueDate,
			''''Arium'''' Owner,
			''''Arium'''' OwnerSlp,
			T2.SlpCode MasterIdSlp
			,T1.WhsCode
			,T0.[DocStatus]
			,T0.[DocTotal]
		FROM Me_Llega_DB.dbo.ORDR T0 
			INNER JOIN Me_Llega_DB.dbo.RDR1 T1 ON T0.DocEntry = T1.DocEntry
			INNER JOIN Me_Llega_DB.dbo.RDR12 T3 ON T0.DocEntry = T3.DocEntry
			INNER JOIN Me_Llega_DB.dbo.OSLP T2 ON T0.SlpCode = T2.SlpCode
		WHERE T0.DocDueDate BETWEEN CAST(''''' + @START_DATE + ''''' AS VARCHAR) AND CAST(''''' + @END_DATE + ''''' AS VARCHAR)
			
	'')	'
	--
	PRINT(@SQL)
	--
	EXEC(@SQL)
	--
	RETURN;
END