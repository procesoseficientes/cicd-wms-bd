
-- =====================================================
-- Author:         diego.as
-- Create date:    05-05-2016
-- Description:    Trae las Unidades de Paquetes por cada uno de los SKUS que se tengan para Venta y Pre-Venta.
--				   
--Acuatlización: diego.as
--Fecha de Actualización: 10-05-2016
--Motivo: Se agrego el campo "[SALES_PACK_UNIT]"

--				   
--Acuatlización:	hector.gonzalez
--Fecha de Actualización: 13-09-2016
--Motivo: Se agrego el parametro @ROUTE_CODE a el sp [SONDA_SP_GET_SKU_PRESALE]

--Acuatlización: diego.as
--Fecha de Actualización: 04-11-2016
--Motivo: Se agrego el campo HANDLE_DIMENSION

-- Modificacion 5/4/2017 @ A-Team Sprint Hondo
					-- rodrigo.gomez
					-- Se agregaron columnas de owner y ownerid

/*
-- EJEMPLO DE EJECUCION: 
		
		EXEC [SONDA].[SWIFT_SP_GET_DEFAULT_PACK_SKU]
		@CODE_ROUTE = 'RUDI@SONDA'
			

*/
-- =====================================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_DEFAULT_PACK_SKU] (@CODE_ROUTE VARCHAR(50))
AS
BEGIN

  DECLARE @DEFAULT_WAREHOUSE VARCHAR(50)
         ,@PRESALE_WAREHOUSE VARCHAR(100)
  --
  SELECT
    @DEFAULT_WAREHOUSE = U.DEFAULT_WAREHOUSE
   ,@PRESALE_WAREHOUSE = U.PRESALE_WAREHOUSE
  FROM [SONDA].[USERS] U
  WHERE U.SELLER_ROUTE = @CODE_ROUTE
  
  --
  CREATE TABLE #SKUS (
    [WAREHOUSE] VARCHAR(50)
   ,[SKU] VARCHAR(250)
   ,[SKU_NAME] VARCHAR(250)
   ,[ON_HAND] INT
   ,[IS_COMITED] INT
   ,[DIFFERENCE] INT
   ,[SKU_PRICE] NUMERIC(18, 6)
   ,[CODE_FAMILY_SKU] VARCHAR(50)
   ,[SALES_PACK_UNIT] VARCHAR(50)
   ,[HANDLE_DIMENSION] NUMERIC(18,0)
   ,[OWNER] VARCHAR(50)
   ,[OWNER_ID] VARCHAR(50)
  )

  --
  INSERT INTO #SKUS
  EXEC [SONDA].[SONDA_SP_GET_SKU_PRESALE] @WAREHOUSES = @PRESALE_WAREHOUSE
                                         ,@CODE_ROUTE = @CODE_ROUTE

  --
  INSERT INTO [#SKUS]
  		(
  			[WAREHOUSE]
  			,[SKU]
  			,[SKU_NAME]
  			,[ON_HAND]
  			,[IS_COMITED]
  			,[DIFFERENCE]
  			,[SKU_PRICE]
  			,[CODE_FAMILY_SKU]
  			,[SALES_PACK_UNIT]
  			,[HANDLE_DIMENSION]
  		)
    SELECT
      [ROUTE_ID] AS [WAREHOUSE]
     ,[SKU]
     ,[SKU_NAME]
     ,[ON_HAND]
     ,0 AS [IS_COMMITED]
     ,0 AS [DIFFERENCE]
     ,[SKU_PRICE]
     ,[CODE_FAMILY_SKU]
     ,[SALES_PACK_UNIT]
     ,0 AS HANDLE_DIMENSION
    FROM [SONDA].[SONDA_POS_SKUS]
    WHERE ROUTE_ID = @DEFAULT_WAREHOUSE

  --
  SELECT DISTINCT
    PU.CODE_PACK_UNIT
   ,PU.CODE_SKU
  FROM #SKUS AS PS
  INNER JOIN [SONDA].[SWIFT_SKU_SALE_PACK_UNIT] AS PU
    ON (
    PU.CODE_SKU = PS.SKU COLLATE DATABASE_DEFAULT
    )

END
