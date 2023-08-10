-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	23-Aug-17 @ Nexus Team Sprint CommandAndConquer
-- Description:			SP que obtiene la orden de venta del ERP

-- Modificacion 9/18/2017 @ Reborn-Team Sprint Collin
					-- diego.as
					-- Se agrega columna WAREHOUSE en el select

-- Modificacion 10/16/2017 @ NEXUS-Team Sprint eNave
					-- rodrigo.gomez
					-- Se devuelve el parametro @POSTED_STATUS 

-- Modificacion 11/3/2017 @ NEXUS-Team Sprint F-Zero
					-- rodrigo.gomez
					-- Se agrega columna de descuento
/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].SWIFT_SP_GET_ERP_DOCUMENT_FOR_DELIVERY_NOTE_BY_DOC_NUM
					@DATABASE = 'ME_LLEGA_DB'
					,@DOC_NUM = 50
					,@PICKING_DEMAND_HEADER_ID = 5210
					,@HAS_MASTERPACK_IMPLODED = 0
					,@POSTED_STATUS = 0
				--
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_ERP_DOCUMENT_FOR_DELIVERY_NOTE_BY_DOC_NUM](
	@DATABASE VARCHAR(50)
	,@DOC_NUM INT 
	,@PICKING_DEMAND_HEADER_ID INT
	,@HAS_MASTERPACK_IMPLODED INT
	,@POSTED_STATUS INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @QUERY NVARCHAR(2000)
	--
	SELECT @QUERY = N'
		SELECT *
		FROM (SELECT * FROM OPENQUERY([ERP_SERVER],''
			SELECT
				'+CAST(@PICKING_DEMAND_HEADER_ID AS VARCHAR)+' AS DocNum
				,SOERP.DocNum AS DocEntry
				,SOERP.CardCode AS CardCode
				,SOERP.CardName AS CardName
				,''''N'''' AS HandWritten
				,SOERP.DocDate AS DocDate
				,SOERP.Comments AS Comments
				,SOERP.DocCur AS DocCur
				,ISNULL(SOERP.DocRate, 0) AS DocRate
				,ISNULL(SOERP.SlpCode,0) AS SalesPersonCode 
				,CAST(NULL AS INT) AS TrnspCode --,SOERP.TrnspCode 
				,R12.AddrTypeS AS ShipToAddressType
				,R12.StreetS AS ShipToStreet
				,R12.StateS AS ShipToState
				,R12.CountryS AS ShipToCountry
				,SOERP.Address
				,SOERP.Address2
				,ISNULL(SOERP.DiscPrcnt, 0) AS DiscPrcnt
				,CAST(NULL AS VARCHAR) AS UFacSerie
				,CAST(NULL AS VARCHAR) AS UFacNit
				,CAST(NULL AS VARCHAR) AS UFacNom
				,CAST(NULL AS VARCHAR) AS UFacFecha
				,CAST(NULL AS VARCHAR) AS UTienda
				,CAST(NULL AS VARCHAR) AS UStatusNc
				,CAST(NULL AS VARCHAR) AS UnoExencion
				,CAST(NULL AS VARCHAR) AS UtipoDocumento
				,CAST(NULL AS VARCHAR) AS UUsuario
				,CAST(NULL AS VARCHAR) AS UFacnum
				,CAST(NULL AS VARCHAR) AS USucursal
				,CAST(NULL AS VARCHAR) AS U_Total_Flete
				,CAST(NULL AS VARCHAR) AS UTipoPago
				,CAST(NULL AS VARCHAR) AS UCuotas
				,CAST(NULL AS VARCHAR) AS UTotalTarjeta
				,CAST(NULL AS VARCHAR) AS UFechap
				,CAST(NULL AS VARCHAR) AS UTrasladoOC
				,''''0'''' AS Classification
				,' + CAST(@HAS_MASTERPACK_IMPLODED AS VARCHAR) + ' AS HAS_MASTERPACK
				,ISNULL(SOERP.U_Bodega , ''''N/A'''') AS U_Bodega 
				,' + CAST(@POSTED_STATUS AS VARCHAR) + ' AS POSTED_STATUS
				,DiscPrcnt as DISCOUNT
			FROM ' + @DATABASE + '.dbo.ORDR SOERP 
				INNER JOIN ' + @DATABASE + '.dbo.RDR12 R12 ON R12.DocEntry = SOERP.DocEntry
			WHERE SOERP.DocNum = '+ CAST(@DOC_NUM AS VARCHAR)+ ''')) A'
	--
	PRINT @QUERY;
	--
	EXEC sp_executesql @QUERY;
END