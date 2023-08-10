-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	8/11/2017 @ NEXUS-Team Sprint Banjo-Kazooie 
-- Description:			Inserta las ordenes de venta en ERP_SALES_ORDER_HEADER_CHANNEL_MODERN y devuelve el ID de secuencia.

-- Modificacion 22-Sep-17 @ Nexus Team Sprint DuckHunt
-- alberto.ruiz
-- Se agrego condficion del docstatus y u_ruta

-- Modificacion 20-Nov-17 @ Reborn Team Sprint Nach
-- rudi.garcia
-- Se agrego join con la tabla [OSHP] par abtener el tipo de despacho


/*
-- Ejemplo de Ejecucion:
				DECLARE @START_DATE DATETIME = GETDATE()-30
					,@END_DATE DATETIME = GETDATE()
					,@ID INT
				
				EXEC [SONDA].[ERP_SP_INSERT_SALES_ORDER_HEADER] 
					@START_DATE = @START_DATE, -- varchar(100)
					@END_DATE = @END_DATE, -- varchar(100)
					@SEQUENCE = @ID OUTPUT	-- int

				SELECT @ID
*/
-- =============================================
CREATE PROCEDURE [SONDA].[ERP_SP_INSERT_SALES_ORDER_HEADER] (@START_DATE VARCHAR(100)
, @END_DATE VARCHAR(100)
, @SEQUENCE INT OUTPUT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @SQL VARCHAR(4000) = ''
         ,@ID INT
         ,@ONLY_SALES_ORDERS_WITH_SPECIFIC_STATUS_OF_PREPARATION VARCHAR(1) = '0'
          ,@GET_TYPE_OF_DEMAND VARCHAR(1) = '0'
  SELECT
    @ONLY_SALES_ORDERS_WITH_SPECIFIC_STATUS_OF_PREPARATION = ISNULL([P].[VALUE], '0')
  FROM [OP_WMS_ALSERSA].[alsersa].[OP_WMS_PARAMETER] [P]
  WHERE [P].[GROUP_ID] = 'CLIENT_CONFIGURATIONS'
  AND [P].[PARAMETER_ID] = 'ONLY_SALES_ORDERS_WITH_SPECIFIC_DATA_ON_COLUMN';

 SELECT
    @GET_TYPE_OF_DEMAND = ISNULL([P].[VALUE], '0')
  FROM [OP_WMS_ALSERSA].[alsersa].[OP_WMS_PARAMETER] [P]
  WHERE [P].[GROUP_ID] = 'PICKING_DEMAND'
  AND [P].[PARAMETER_ID] = 'GET_TYPE_OF_DEMAND'

  INSERT INTO [SONDA].[ERP_SALES_ORDER_SEQUENCE_CHANNEL_MODERN] ([StartDate], [EndDate])
    VALUES (
				CAST(@START_DATE AS DATETIME)  -- StartDate - datetime
				,CAST(@END_DATE AS DATETIME)  -- EndDate - datetime
    )
  SELECT
    @ID = SCOPE_IDENTITY()
   ,@SEQUENCE = SCOPE_IDENTITY()

  SELECT
    @SQL = '
		INSERT INTO [SONDA].[ERP_SALES_ORDER_HEADER_CHANNEL_MODERN]
		SELECT
			' + CAST(@ID AS VARCHAR) + '
		  ,*
		FROM OPENQUERY([ERP_SERVER], ''
		SELECT DISTINCT 
			T0.DocDate,
			T0.DocNum as DocNum,
			'''''''' U_Serie,
			'''''''' U_NoDocto,
			T0.CardCode,
			T0.CardName,
			T0.CardCode U_MasterIDCustomer,
			''''Arium'''' U_OwnerCustomer,
			T2.SlpName,
			'''''''' U_oper,
			CAST(T0.DiscPrcnt AS DECIMAL) / 100 AS DESCUENTO_FACTURA,--T0.DiscPrcnt,
			CASE
			WHEN T0.CANCELED = ''''N'''' THEN ''''FACTURA''''
			WHEN T0.CANCELED = ''''Y'''' THEN ''''ANULADA''''
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
			T0.DocDueDate
			, ''''Arium'''' Owner
			, ''''Arium'''' OwnerSlp
			, T2.SlpCode MasterIdSlp
			, T1.WhsCode
			, T0.DocStatus
			, T0.[DocTotal]'

      IF @GET_TYPE_OF_DEMAND = '1' BEGIN
      SELECT
      @SQL = @SQL + ' ,[T0].[TrnspCode] [TYPE_DEMAND_CODE]
                      ,[OS].[TrnspName] [TYPE_DEMAND_NAME]
					  ,[T0].[U_Proyecto] [PROJECT]'
    END
    ELSE BEGIN
      SELECT
      @SQL = @SQL + ' ,0 [TYPE_DEMAND_CODE]
                      ,'''''''' [TYPE_DEMAND_NAME]
					  ,'''''''' [PROJECT] '
    END
      
    SELECT
      @SQL = @SQL +
		' FROM Me_Llega_DB.dbo.ORDR T0 
				INNER JOIN Me_Llega_DB.DBO.RDR1 T1 ON T0.DocEntry = T1.DocEntry --AND T0.U_Owner = T1.U_Owner
				INNER JOIN Me_Llega_DB.DBO.RDR12 T3 ON T0.DocEntry = T3.DocEntry --AND T0.U_Owner = T3.U_Owner
				INNER JOIN Me_Llega_DB.dbo.OSLP T2 ON [T0].[SlpCode] = [T2].[SlpCode]'

    IF @GET_TYPE_OF_DEMAND = '1' BEGIN
      SELECT
      @SQL = @SQL + ' INNER JOIN Me_Llega_DB.[dbo].[OSHP] [OS] ON ([T0].[TrnspCode] = [OS].[TrnspCode]) '
    END

    SELECT
      @SQL = @SQL + 
		'WHERE T0.CANCELED <> ''''C''''
			AND T0.[DocStatus] <> ''''C''''
			AND T0.CardCode  NOT LIKE ''''SO%''''
			--AND T0.[U_Ruta] = ''''Si''''
			--AND T0.[U_consignacion] = ''''No''''
			AND T0.DocDueDate BETWEEN CAST(''''' + @START_DATE + ''''' AS VARCHAR) AND CAST(''''' + @END_DATE + ''''' AS VARCHAR)	
			'

	  IF @ONLY_SALES_ORDERS_WITH_SPECIFIC_STATUS_OF_PREPARATION = '1'
  BEGIN
    SELECT
      @SQL = @SQL + ' AND T0.U_Estado2 = ''''03'''' '')  '
  END
  ELSE
  BEGIN
    SELECT
      @SQL = @SQL + ' '') '
  END
  
	PRINT('SQL: ' + @SQL)	
  
  EXEC (@SQL)

  RETURN;
END