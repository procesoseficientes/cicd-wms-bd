-- =============================================
-- Autor:                hector.gonzalez
-- Fecha de Creacion:     20-07-2016
-- Description:          obtiene la cantidad de clientes y el porcentaje del poligono 

-- Modificacion 25-07-2016
-- alberto.ruiz
-- optimizacion

-- Modificacion 30-08-2016 @ Sprint θ
-- rudi.garcia
-- Se agrego el campo de tipo de tarea

-- Modificacion 30-08-2016 @ Sprint ι
-- alberto.ruiz
-- Se agrego parametro @CODE_WAREHOUSE

-- Modificacion 05-09-2016 @ Sprint ι
-- alberto.ruiz
-- Se agrego parametro LAST_OPTIMIZATION

-- Modificacion 30-09-2016 @ A-Team Sprint 2
-- rudi.garcia
-- Se agrego parametro IS_MULTIPOLYGON, para obtener solo los multipoligonos

-- Modificacion 16-Jan-17 @ A-Team Sprint Adeben
-- alberto.ruiz
-- Se ajusto el tipo y descripcion de tarea a que el poligono tiene mas de un tipo de tarea

-- Modificación: pablo.aguilar
-- Fecha: 	2017-04-24 ATeam@Hondo 
-- Description:	 Se agrega el campo de @IS_MULTISELLER INT = 0 y se filtra por este campo en la consulta

-- Modificacion 07-Jul-17 @ Nexus Team Sprint Khalid
-- alberto.ruiz
-- Se agrego condicion si es multivendedor para que no elimine clientes de listado

/*
-- Ejemplo de Ejecucion:
        --
        EXEC [SONDA].[SWIFT_SP_GET_CUSTOMER_PERCENT_BY_POLYGON_TYPE]
			@POLYGON_TYPE = 'REGION'
		--
		EXEC [SONDA].[SWIFT_SP_GET_CUSTOMER_PERCENT_BY_POLYGON_TYPE]
			@POLYGON_TYPE = 'SECTOR'
			,@POLYGON_SUB_TYPE = 'COMMERCIAL'
			,@POLYGON_ID_PARENT = 63
		--
		EXEC [SONDA].[SWIFT_SP_GET_CUSTOMER_PERCENT_BY_POLYGON_TYPE]
			@POLYGON_TYPE = 'RUTA'
			,@POLYGON_SUB_TYPE = 'COMMERCIAL'
			,@POLYGON_ID_PARENT = 5167
			,@IS_MULTIPOLYGON = 1
			,@AVAILABLE = 1
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_GET_CUSTOMER_PERCENT_BY_POLYGON_TYPE (@POLYGON_TYPE VARCHAR(250)
, @POLYGON_SUB_TYPE VARCHAR(250) = NULL
, @POLYGON_ID_PARENT INT = NULL
, @IS_MULTIPOLYGON INT = 0
, @AVAILABLE INT = 0
, @IS_MULTISELLER INT = 0)
AS
BEGIN
  BEGIN TRY
    -- ------------------------------------------------------------------------------------
    -- Declaramos las variables a utilizar
    -- ------------------------------------------------------------------------------------
    DECLARE @TOTAL_CUSTOMERS INT = 0
           ,@vPOLYGON_ID INT
           ,@CUSTOMER_COUNT INT
           ,@PERCENT NUMERIC(18, 6)

    DECLARE @CUSTOMER TABLE (
      [CODE_CUSTOMER] VARCHAR(50)
    )
    --
    DECLARE @POLYGON TABLE (
      [POLYGON_ID] INT
     ,[POLYGON_ID_PARENT] INT
    )
    --
    DECLARE @POLYGON_AVG TABLE (
      POLYGON_ID INT
     ,CUSTOMERS_COUNT INT
     ,CUSTOMERS_PERCENT NUMERIC(18, 6)
    )

    -- ------------------------------------------------------------------------------------
    -- Obtenemos todos los poligonos del tipo y subtipo a generar
    -- ------------------------------------------------------------------------------------
    INSERT INTO @POLYGON
      SELECT
        [P].[POLYGON_ID]
       ,[P].[POLYGON_ID_PARENT]
      FROM [SONDA].[SWIFT_POLYGON] [P]
      LEFT JOIN [SONDA].[SWIFT_POLYGON_BY_ROUTE] [PR]
        ON (
        [PR].[POLYGON_ID] = [P].[POLYGON_ID]
        )
      WHERE P.POLYGON_TYPE = @POLYGON_TYPE
      AND (P.SUB_TYPE = @POLYGON_SUB_TYPE
      OR @POLYGON_SUB_TYPE IS NULL)
      AND (P.POLYGON_ID_PARENT = @POLYGON_ID_PARENT
      OR @POLYGON_ID_PARENT IS NULL)
      AND [P].[IS_MULTISELLER] = @IS_MULTISELLER
    --AND ([PR].[POLYGON_ID] IS NULL OR [PR].[IS_MULTIPOLYGON] = @IS_MULTIPOLYGON)

    -- ------------------------------------------------------------------------------------
    -- Obtiene los clientes
    -- ------------------------------------------------------------------------------------
    INSERT INTO @CUSTOMER
      SELECT
        [C].[CODE_CUSTOMER]
      FROM [SONDA].SWIFT_VIEW_ALL_COSTUMER C
      WHERE GPS <> '0,0'
      AND (C.LATITUDE IS NOT NULL
      AND C.LONGITUDE IS NOT NULL)
      AND GPS IS NOT NULL

    -- ------------------------------------------------------------------------------------
    -- Obtiene el total de clientes
    -- ------------------------------------------------------------------------------------
    SELECT
      @TOTAL_CUSTOMERS = @@rowcount
    --
    IF @POLYGON_ID_PARENT IS NOT NULL
    BEGIN

      SELECT
        @TOTAL_CUSTOMERS = COUNT(1)
      FROM [SONDA].[SWIFT_CUSTOMER_ASSOCIATE_TO_POLYGON] [CAP]
      WHERE [CAP].[POLYGON_ID] = @POLYGON_ID_PARENT
    END

    -- ------------------------------------------------------------------------------------
    -- Inicia ciclo para cada poligono obtenido
    -- ------------------------------------------------------------------------------------
    WHILE EXISTS (SELECT TOP 1
          1
        FROM @POLYGON)
    BEGIN
      SELECT TOP 1
        @vPOLYGON_ID = POLYGON_ID
      FROM @POLYGON
      ORDER BY POLYGON_ID_PARENT ASC

      -- ------------------------------------------------------------------------------------
      -- ObtIene el total de clientes del poligono actual 
      -- ------------------------------------------------------------------------------------	 
      IF @POLYGON_TYPE = 'REGION'
        OR @POLYGON_TYPE = 'SECTOR'
      BEGIN
        SELECT
          @CUSTOMER_COUNT = COUNT(1)
        FROM [SONDA].[SWIFT_CUSTOMER_ASSOCIATE_TO_POLYGON] [CAP]
        WHERE [CAP].[POLYGON_ID] = @vPOLYGON_ID
      END
      ELSE
      BEGIN
        SELECT
          @CUSTOMER_COUNT = COUNT(1)
        FROM [SONDA].[SWIFT_POLYGON_X_CUSTOMER] [PC]
        WHERE [PC].[POLYGON_ID] = @vPOLYGON_ID
      END


      SELECT
        @PERCENT =
                  CASE CAST(@TOTAL_CUSTOMERS AS NUMERIC(18, 6))
                    WHEN 0 THEN 0
                    ELSE (CAST(@CUSTOMER_COUNT AS NUMERIC(18, 6)) * 100 / CAST(@TOTAL_CUSTOMERS AS NUMERIC(18, 6)))
                  END
      --
      INSERT INTO @POLYGON_AVG (POLYGON_ID
      , CUSTOMERS_COUNT
      , CUSTOMERS_PERCENT)
        VALUES (@vPOLYGON_ID, @CUSTOMER_COUNT, @PERCENT)

      -- ------------------------------------------------------------------------------------
      -- Elimina el registro actual
      -- ------------------------------------------------------------------------------------
      DELETE FROM @POLYGON
      WHERE POLYGON_ID = @vPOLYGON_ID
    END

    -- ------------------------------------------------------------------------------------
    -- Muestra el resultado
    -- ------------------------------------------------------------------------------------
    SELECT
      [A].[POLYGON_ID]
     ,[P].[POLYGON_NAME]
     ,[P].[SUB_TYPE]
     ,[A].[CUSTOMERS_COUNT]
     ,[A].[CUSTOMERS_PERCENT]
     ,[PP].[POLYGON_NAME] [PARENT_NAME]
     ,[P].[POLYGON_DESCRIPTION]
     ,[P].[COMMENT]
     ,[SONDA].[SWIFT_FN_VALIDATE_POLYGON_HAS_CHILD]([A].[POLYGON_ID]) [HAS_CHILD]
     ,CASE CAST([SONDA].[SWIFT_FN_VALIDATE_POLYGON_HAS_CHILD]([A].[POLYGON_ID]) AS VARCHAR)
        WHEN '1' THEN 'No'
        ELSE 'SI'
      END [HAS_CHILD_MESSAGE]
     ,[SONDA].[SWIFT_FN_GET_TASK_TYPE_BY_POLYGON]([A].[POLYGON_ID]) [TYPE_TASK]
     ,[SONDA].[SWIFT_FUNC_GET_TASK_TYPE_DESCRIPTION_BY_POLYGON]([A].[POLYGON_ID]) [TYPE_TASK_DESCRIPTION]
     ,[W].[CODE_WAREHOUSE]
     ,[W].[DESCRIPTION_WAREHOUSE]
     ,[P].[LAST_OPTIMIZATION]
     ,[PR].[ID_FREQUENCY]
     ,[VS].[SELLER_CODE]
     ,[VS].[SELLER_NAME]
     ,ISNULL([PR].[IS_MULTIPOLYGON], 0) [IS_MULTIPOLYGON]
     ,ISNULL([P].[AVAILABLE], 0) [AVAILABLE]
    FROM @POLYGON_AVG [A]
    INNER JOIN [SONDA].[SWIFT_POLYGON] [P]
      ON (
      [A].[POLYGON_ID] = [P].[POLYGON_ID]
      )
    LEFT JOIN [SONDA].[SWIFT_POLYGON] [PP]
      ON (
      [P].[POLYGON_ID_PARENT] = [PP].[POLYGON_ID]
      )
    LEFT JOIN [SONDA].[SWIFT_WAREHOUSES] [W]
      ON (
      [P].[CODE_WAREHOUSE] = [W].[CODE_WAREHOUSE]
      )
    LEFT JOIN [SONDA].[SWIFT_POLYGON_BY_ROUTE] [PR]
      ON (
      [PR].[POLYGON_ID] = [P].[POLYGON_ID]
      )
    LEFT JOIN [SONDA].[SWIFT_ROUTES] [R]
      ON (
      [R].[ROUTE] = [PR].[ROUTE]
      )
    LEFT JOIN [SONDA].[SWIFT_VIEW_ALL_SELLERS] [VS]
      ON (
      [R].[SELLER_CODE] = [VS].[SELLER_CODE]
      )
  END TRY
  BEGIN CATCH
    SELECT
      -1 AS RESULTADO
     ,ERROR_MESSAGE() MENSAJE
     ,@@error CODIGO
  END CATCH
END
