-- =============================================
-- Autor:                hector.gonzalez
-- Fecha de Creacion:    22-07-2016
-- Description:          obtiene los clientes por un polygon id 

-- Modificado 2016-08-024 Sprint ?
-- rudi.garcia
-- Se agrego un left join a la tabla "SWIFT_CUSTOMERS_NEW" para obtener la foto del scouting y un left join a la tabla "SWIFT_FREQUENCY_X_CUSTOMER" para saber si tiene una frecuencia.

-- Modificado 2016-09-20 Sprint 1 TEAM-A
-- rudi.garcia
-- Se agrego un left join a la tabla [SWIFT_POLYGON_X_CUSTOMER] para obtener el estado del cliente en el polygono. 

-- Modificado 2016-09-20 Sprint 2 TEAM-A
-- rudi.garcia
-- Se agrego el campo de id_poligono

-- Modificacion 6/1/2017 @ A-Team Sprint Jibade
-- rodrigo.gomez
-- Se permite filtrar los clientes por etiquetas y Canales.

-- Modificacion 21/08/2017 @ A-Team Sprint Bearbeitung
-- Rudi.garcia
-- Se modifico la consulta de los clientes para que filtrara en la tabla de  [SWIFT_CUSTOMER_ASSOCIATE_TO_POLYGON]

/* 
-- Ejemplo de Ejecucion:
        --
        EXEC [SONDA].[SWIFT_SP_GET_CUSTOMER_BY_POLYGON_ID]
        @POLYGON_ID = 9304
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_GET_CUSTOMER_BY_POLYGON_ID (@POLYGON_ID INT,
@TAG_COLOR VARCHAR(MAX) = NULL,
@CHANNEL_ID VARCHAR(MAX) = NULL)
AS
BEGIN
  BEGIN TRY
    --
    DECLARE @POLYGON_TYPE VARCHAR(250)
           ,@POLYGON_ID_PARENT INT

    DECLARE @CUSTOMER_TEMP TABLE (
      CODE_CUSTOMER VARCHAR(50)
     ,NAME_CUSTOMER VARCHAR(100)
     ,PHONE_CUSTOMER VARCHAR(50)
     ,ADRESS_CUSTOMER VARCHAR(MAX)
     ,LATITUDE VARCHAR(50)
     ,LONGITUDE VARCHAR(50)
     ,IS_IN BIT
    )

    DECLARE @CUSTOMER TABLE (
      CODE_CUSTOMER VARCHAR(50)
     ,NAME_CUSTOMER VARCHAR(100)
     ,PHONE_CUSTOMER VARCHAR(50)
     ,ADRESS_CUSTOMER VARCHAR(MAX)
     ,LATITUDE VARCHAR(50)
     ,LONGITUDE VARCHAR(50)
     ,IS_IN BIT
    )



    SELECT
      @POLYGON_TYPE = P.[POLYGON_TYPE]
     ,@POLYGON_ID_PARENT = [P].[POLYGON_ID_PARENT]
    FROM [SONDA].[SWIFT_POLYGON] [P]
    WHERE [P].[POLYGON_ID] = @POLYGON_ID

    DECLARE @TAG TABLE (
      TAG_COLOR VARCHAR(8)
    )
    --
    DECLARE @CHANNEL TABLE (
      [CHANNEL_ID] INT
    )
    --
    DECLARE @GEOMETRY_POLYGON GEOMETRY
           ,@TAGS_QTY INT = 0
           ,@CHANNELS_QTY INT = 0
    --
    IF (@TAG_COLOR <> '')
    BEGIN
      INSERT INTO @TAG ([TAG_COLOR])
        SELECT
          [VALUE]
        FROM [SONDA].[SWIFT_FN_SPLIT_2](@TAG_COLOR, '|')
      SET @TAGS_QTY = @@rowcount
    END
    --
    IF (@CHANNEL_ID <> '')
    BEGIN
      INSERT INTO @CHANNEL ([CHANNEL_ID])
        SELECT
          [VALUE]
        FROM [SONDA].[SWIFT_FN_SPLIT_2](@CHANNEL_ID, '|')
      SET @CHANNELS_QTY = @@rowcount
    END
    --


    IF @POLYGON_TYPE = 'REGION'
      OR @POLYGON_TYPE = 'SECTOR'
    BEGIN
      INSERT INTO @CUSTOMER
        SELECT DISTINCT
          C.CODE_CUSTOMER
         ,C.NAME_CUSTOMER
         ,C.PHONE_CUSTOMER
         ,C.ADRESS_CUSTOMER
         ,C.LATITUDE
         ,C.LONGITUDE
         ,1 IS_IN
        FROM [SONDA].[SWIFT_CUSTOMER_ASSOCIATE_TO_POLYGON] [CAP]
        INNER JOIN [SONDA].[SWIFT_VIEW_ALL_COSTUMER] [C]
          ON ([CAP].[CODE_CUSTOMER] = C.[CODE_CUSTOMER])
        WHERE [CAP].[POLYGON_ID] = @POLYGON_ID
    END
    ELSE
    BEGIN
      INSERT INTO @CUSTOMER_TEMP
        SELECT DISTINCT
          C.CODE_CUSTOMER
         ,C.NAME_CUSTOMER
         ,C.PHONE_CUSTOMER
         ,C.ADRESS_CUSTOMER
         ,C.LATITUDE
         ,C.LONGITUDE
         ,1 IS_IN
        FROM [SONDA].[SWIFT_CUSTOMER_ASSOCIATE_TO_POLYGON] [CAP]
        INNER JOIN [SONDA].[SWIFT_VIEW_ALL_COSTUMER] [C]
          ON ([CAP].[CODE_CUSTOMER] = C.[CODE_CUSTOMER])
        WHERE [CAP].[POLYGON_ID] = @POLYGON_ID_PARENT


      SELECT
        @GEOMETRY_POLYGON = [SONDA].SWIFT_GET_GEOMETRY_POLYGON_BY_POLIGON_ID(@POLYGON_ID)

      INSERT INTO @CUSTOMER
        SELECT DISTINCT
          C.CODE_CUSTOMER
         ,C.NAME_CUSTOMER
         ,C.PHONE_CUSTOMER
         ,C.ADRESS_CUSTOMER
         ,C.LATITUDE
         ,C.LONGITUDE
         ,@GEOMETRY_POLYGON.MakeValid().STContains(GEOMETRY::Point(ISNULL(C.LATITUDE, 0), ISNULL(C.LONGITUDE, 0), 0)) IS_IN
        FROM @CUSTOMER_TEMP [C]
        LEFT JOIN [SONDA].[SWIFT_TAG_X_CUSTOMER] [TXC]
          ON [TXC].[CUSTOMER] = [C].[CODE_CUSTOMER]
        LEFT JOIN [SONDA].[SWIFT_CHANNEL_X_CUSTOMER] [CHXC]
          ON [CHXC].[CODE_CUSTOMER] = [C].[CODE_CUSTOMER]
          AND ((@TAGS_QTY > 0
          AND [TXC].[TAG_COLOR] IN (SELECT
              *
            FROM @TAG)
          )
          OR (@TAGS_QTY = 0))
          AND ((@CHANNELS_QTY > 0
          AND [CHXC].[CHANNEL_ID] IN (SELECT
              *
            FROM @CHANNEL)
          )
          OR (@CHANNELS_QTY = 0))
    END

    DELETE FROM @CUSTOMER
    WHERE [IS_IN] = 0
    -- ------------------------------------------------------------------------------------
    -- Muestra quienes estan en el poligono
    -- ------------------------------------------------------------------------------------
    SELECT
      C.CODE_CUSTOMER
     ,C.NAME_CUSTOMER
     ,C.PHONE_CUSTOMER
     ,C.ADRESS_CUSTOMER
     ,C.LATITUDE
     ,C.LONGITUDE
     ,C.IS_IN
     ,ISNULL(CF.CODE_FREQUENCY, 0) AS CODE_FREQUENCY
     ,ISNULL(CONVERT(INT, CF.SUNDAY), 0) AS SUNDAY
     ,ISNULL(CONVERT(INT, CF.MONDAY), 0) AS MONDAY
     ,ISNULL(CONVERT(INT, CF.TUESDAY), 0) AS TUESDAY
     ,ISNULL(CONVERT(INT, CF.WEDNESDAY), 0) AS WEDNESDAY
     ,ISNULL(CONVERT(INT, CF.THURSDAY), 0) AS THURSDAY
     ,ISNULL(CONVERT(INT, CF.FRIDAY), 0) AS FRIDAY
     ,ISNULL(CONVERT(INT, CF.SATURDAY), 0) AS SATURDAY
     ,ISNULL(CONVERT(INT, CF.FREQUENCY_WEEKS), 0) AS FREQUENCY_WEEKS
     ,CF.LAST_DATE_VISITED
     ,(CASE
        WHEN PC.HAS_PROPOSAL IS NOT NULL THEN PC.HAS_PROPOSAL
        ELSE (CASE
            WHEN CF.CODE_CUSTOMER IS NOT NULL THEN 1
            ELSE 0
          END)
      END) HAS_PROPOSAL
     ,(CASE
        WHEN PC.HAS_FREQUENCY IS NOT NULL THEN PC.HAS_FREQUENCY
        ELSE (CASE
            WHEN FC.ID_FREQUENCY IS NOT NULL THEN 1
            ELSE 0
          END)
      END) HAS_FREQUENCY
     ,COALESCE(PC.IS_NEW, 0) IS_NEW
     ,PC.POLYGON_ID
     ,ROW_NUMBER() OVER (PARTITION BY C.CODE_CUSTOMER ORDER BY PC.POLYGON_ID DESC, FC.CODE_CUSTOMER DESC, CF.CODE_FREQUENCY DESC) [ROWNUM] INTO #RESULT
    FROM @CUSTOMER C
    LEFT JOIN [SONDA].[SWIFT_POLYGON_X_CUSTOMER] PC
      ON (C.CODE_CUSTOMER = PC.CODE_CUSTOMER
      AND PC.POLYGON_ID = @POLYGON_ID
      )
    LEFT JOIN [SONDA].SWIFT_CUSTOMER_FREQUENCY CF
      ON (CF.CODE_CUSTOMER = C.CODE_CUSTOMER)
    LEFT JOIN [SONDA].[SWIFT_FREQUENCY_X_CUSTOMER] FC
      ON (C.CODE_CUSTOMER = FC.CODE_CUSTOMER);

    SELECT
      R.CODE_CUSTOMER
     ,R.NAME_CUSTOMER
     ,R.PHONE_CUSTOMER
     ,R.ADRESS_CUSTOMER
     ,R.LATITUDE
     ,R.LONGITUDE
     ,R.IS_IN
     ,R.CODE_FREQUENCY
     ,R.SUNDAY
     ,R.MONDAY
     ,R.TUESDAY
     ,R.WEDNESDAY
     ,R.THURSDAY
     ,R.FRIDAY
     ,R.SATURDAY
     ,R.FREQUENCY_WEEKS
     ,R.LAST_DATE_VISITED
     ,R.HAS_PROPOSAL
     ,R.HAS_FREQUENCY
     ,R.IS_NEW
     ,R.POLYGON_ID
    FROM #RESULT R
    WHERE R.ROWNUM = 1;

  END TRY
  BEGIN CATCH
    SELECT
      -1 AS RESULTADO
     ,ERROR_MESSAGE() MENSAJE
     ,@@error CODIGO
  END CATCH
END
