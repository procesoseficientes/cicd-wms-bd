
-- =============================================
-- Autor:				Christian Hernandez 
-- Fecha de Creacion: 	05/25/2018
-- Description:			SP que obtiene los paquetes de conversion de los productos de las listas de precios de los clientes en el plan de ruta y la lista de precio por default 
-- Ejemplo de ejecucion: EXEC SONDA.SONDA_SP_GET_PACK_CONVERSION_FOR_ROUTE @CODE_ROUTE = '46' --
-- =============================================

CREATE PROCEDURE [SONDA].[SONDA_SP_GET_PACK_CONVERSION_FOR_ROUTE]
    @CODE_ROUTE VARCHAR(50)
AS
    BEGIN
        SET NOCOUNT ON;

---Se crea una tabla temporal desde [SONDA].[SONDA_SP_GET_PRICE_LIST_BY_SKU_PACK_SCALE_FOR_ROUTE]  para traer la lista de precio por defecto y la que tiene asignada para su ruta 

        DECLARE @PRICE_LISTS TABLE
            (
              [CODE_PRICE_LIST] VARCHAR(100) ,
              [CODE_SKU] VARCHAR(100) ,
              [CODE_PACK_UNIT] VARCHAR(100) ,
              [PRIORITY] INT ,
              [LOW_LIMIT] NUMERIC(18, 6) ,
              [HIGH_LIMIT] NUMERIC(18, 6) ,
              [PRICE] NUMERIC(18, 6)
            ); 


        INSERT  INTO @PRICE_LISTS
                EXEC [SONDA].[SONDA_SP_GET_PRICE_LIST_BY_SKU_PACK_SCALE_FOR_ROUTE] @CODE_ROUTE = @CODE_ROUTE;  

---Se hace un distinct para no mutiplexsar todos los campos del PACK_CONVERSION filtrado desde la tabla anterior	
        SELECT  DISTINCT
                [PC].[PACK_CONVERSION] ,
                [PC].[CODE_SKU] ,
                [PC].[CODE_PACK_UNIT_FROM] ,
                [PC].[CODE_PACK_UNIT_TO] ,
                [PC].[CONVERSION_FACTOR] ,
                [PC].[LAST_UPDATE] ,
                [PC].[LAST_UPDATE_BY] ,
                [PC].[ORDER]
        FROM    [SONDA].[SONDA_PACK_CONVERSION] AS [PC]
                INNER JOIN @PRICE_LISTS AS [L] ON ( [L].[CODE_SKU] = [PC].[CODE_SKU] );
    END;
