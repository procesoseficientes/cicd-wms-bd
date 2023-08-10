-- =============================================
-- Autor:				hector.gonzalez
-- Fecha de Creacion: 	17/11/2017 @ Reborn - TEAM Sprint Eberhard
-- Description:			SP que agrega un registro a las entregas canceladas

-- Modificacion 11/24/2017 @ Reborn-Team Sprint Nach
					-- diego.as
					-- Se agrega columna REASON_CANCEL

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_ADD_CANCELED_DELIVERY_BY_XML]
				@XML = '
					
<Data>
    <entregasCanceladas>        
        <pickingDemandHeader>15</pickingDemandHeader>        
        <docNum>132</docNum>
        <docSerie>132</docSerie>
        <docNumDelivery>132</docNumDelivery>
        <docEntry>155137</docEntry>        
        <isPosted>0</isPosted>               
        <postedDateTime>null</postedDateTime>   
		<reasonCancel>SIN RAZON</reasonCancel>       
    </entregasCanceladas>
    <dbuser>USONDA</dbuser>
    <dbuserpass>SONDAServer1237710</dbuserpass>
    <routeid>46</routeid>
    <loginId>hector@SONDA</loginId>
</Data>'

*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_ADD_CANCELED_DELIVERY_BY_XML] (@XML XML)
AS
BEGIN
  BEGIN TRY
    DECLARE @ID INT
           ,@PICKING_DEMAND_HEADER_ID INT
           ,@DOC_NUM INT
           ,@DOC_SERIE VARCHAR(250)
           ,@DOC_ENTRY INT
           ,@DELIVERY_CANCELED_ID INT
           ,@DOC_NUM_DELIVERY INT

    --

    DECLARE @DELIVERY_CANCELED TABLE (
      [DELIVERY_CANCELED_ID] INT
     ,[PICKING_DEMAND_HEADER_ID] INT
     ,[DOC_NUM] INT NULL
     ,[DOC_SERIE] VARCHAR(250)
     ,[DOC_NUM_DELIVERY] INT NULL
     ,[DOC_ENTRY] INT NULL
     ,[POSTED_DATETIME] DATETIME DEFAULT GETDATE()
	 ,[REASON_CACNCEL] VARCHAR(250)
    );

    DECLARE @DELIVERY_CANCELED_RESULT TABLE (
      [DELIVERY_CANCELED_ID] INT
     ,[PICKING_DEMAND_HEADER_ID] INT
     ,[DOC_NUM] INT NULL
     ,[DOC_SERIE] VARCHAR(250)
     ,[DOC_NUM_DELIVERY] INT NULL
     ,[DOC_ENTRY] INT NULL
     ,[IS_POSTED] INT NOT NULL
     ,[POSTED_DATETIME] DATETIME DEFAULT GETDATE()
    );

    -- --------------------------------------------------------------------------------------------------------

    INSERT INTO @DELIVERY_CANCELED ([DELIVERY_CANCELED_ID], [PICKING_DEMAND_HEADER_ID]
    , [DOC_NUM]
    , [DOC_SERIE]
    , [DOC_NUM_DELIVERY]
    , [DOC_ENTRY]
	, [REASON_CACNCEL])
      SELECT
        x.Rec.query('./deliveryCanceledId').value('.', 'int')
       ,x.Rec.query('./pickingDemandHeaderId').value('.', 'int')
       ,CASE [x].[Rec].[query]('./docNum').[value]('.', 'varchar(50)')
          WHEN 'NULL' THEN NULL
          WHEN 'UNDEFINED' THEN NULL
          ELSE [x].[Rec].[query]('./docNum').[value]('.', 'int')
        END
       ,CASE [x].[Rec].[query]('./docSerie').[value]('.', 'varchar(250)')
          WHEN 'NULL' THEN NULL
          WHEN 'UNDEFINED' THEN NULL
          ELSE [x].[Rec].[query]('./docSerie').[value]('.', 'varchar(250)')
        END
       ,CASE [x].[Rec].[query]('./docNumDelivery').[value]('.', 'varchar(50)')
          WHEN 'NULL' THEN NULL
          WHEN 'UNDEFINED' THEN NULL
          ELSE [x].[Rec].[query]('./docNumDelivery').[value]('.', 'int')
        END
       ,CASE [x].[Rec].[query]('./docEntry').[value]('.', 'varchar(50)')
          WHEN 'NULL' THEN NULL
          WHEN 'UNDEFINED' THEN NULL
          ELSE [x].[Rec].[query]('./docEntry').[value]('.', 'int')
        END
		,CASE [x].[Rec].[query]('./reasonCancel').[value]('.', 'varchar(250)')
          WHEN 'NULL' THEN NULL
          WHEN 'UNDEFINED' THEN NULL
          ELSE [x].[Rec].[query]('./reasonCancel').[value]('.', 'varchar(250)')
        END
      FROM @XML.nodes('Data/entregasCanceladas') AS x (Rec)

    -- ----------------------------------------------------------------------------------------------------------
    BEGIN TRAN INSERT_CANCELED_DELIVERY


    WHILE EXISTS (SELECT TOP 1
          1
        FROM @DELIVERY_CANCELED)
    BEGIN

      SELECT TOP 1
        @DELIVERY_CANCELED_ID = [DC].[DELIVERY_CANCELED_ID]
       ,@PICKING_DEMAND_HEADER_ID = [DC].[PICKING_DEMAND_HEADER_ID]
       ,@DOC_NUM = [DC].[DOC_NUM]
       ,@DOC_SERIE = [DC].[DOC_SERIE]
       ,@DOC_NUM_DELIVERY = [DC].[DOC_NUM_DELIVERY]
       ,@DOC_ENTRY = [DC].[DOC_ENTRY]
      FROM @DELIVERY_CANCELED AS DC

      --      

      INSERT INTO [SONDA].[SONDA_DELIVERY_CANCELED] (
        [PICKING_DEMAND_HEADER_ID]
      , [DOC_NUM]
      , [DOC_SERIE]
      , [DOC_NUM_DELIVERY]
      , [DOC_ENTRY]
      , [IS_POSTED]
      , [POSTED_DATETIME]
	  , [REASON_CANCEL])
        SELECT
          [DC].[PICKING_DEMAND_HEADER_ID]
         ,[DC].[DOC_NUM]
         ,[DC].[DOC_SERIE]
         ,[DC].[DOC_NUM_DELIVERY]
         ,[DC].[DOC_ENTRY]
         ,1
         ,GETDATE()
		 ,[DC].[REASON_CACNCEL]
        FROM @DELIVERY_CANCELED DC
        WHERE [DC].[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID

      --
      SET @ID = SCOPE_IDENTITY();

      INSERT INTO @DELIVERY_CANCELED_RESULT ([DELIVERY_CANCELED_ID], [PICKING_DEMAND_HEADER_ID], [DOC_NUM], [DOC_SERIE], [DOC_NUM_DELIVERY], [DOC_ENTRY], [IS_POSTED], [POSTED_DATETIME])
        VALUES (@DELIVERY_CANCELED_ID, @PICKING_DEMAND_HEADER_ID, @DOC_NUM, @DOC_SERIE, @DOC_NUM_DELIVERY, @DOC_ENTRY, 2, GETDATE());



      DELETE FROM @DELIVERY_CANCELED
      WHERE [DELIVERY_CANCELED_ID] = [DELIVERY_CANCELED_ID]

    END


    COMMIT TRANSACTION INSERT_CANCELED_DELIVERY
    --

    SELECT
      1 AS RESULTADO
     ,[DELIVERY_CANCELED_ID]
     ,[PICKING_DEMAND_HEADER_ID]
     ,[DOC_NUM]
     ,[DOC_SERIE]
     ,[DOC_NUM_DELIVERY]
     ,[DOC_ENTRY]
     ,[IS_POSTED]
     ,[POSTED_DATETIME]
    FROM @DELIVERY_CANCELED_RESULT

  END TRY
  BEGIN CATCH
    --    
    ROLLBACK TRANSACTION INSERT_CANCELED_DELIVERY

    SELECT
      -1 AS [Resultado]
     ,ERROR_MESSAGE() [Mensaje]
     ,@@error [Codigo]
     ,0 [DbData];

  END CATCH
END
