-- =============================================
-- Autor:				hector.gonzalez
-- Fecha de Creacion: 	17/11/2017 @ Reborn - TEAM Sprint Eberhard
-- Description:			SP que actualiza el estado de un picking en una entrega y si no existe lo agrega

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_UPDATE_PICKING_DEMAND_BY_TASK_BY_XML]
				@XML = '
					
<Data>
    <demandasDespachoPorTarea>        
        <pickingDemandHeaderId>15</pickingDemandHeaderId>        
        <pickingDemandStatus>PENDING</pickingDemandStatus>
        <taskId>132</taskId>        
        <isPosted>0</isPosted>                       
    </demandasDespachoPorTarea>
    <dbuser>USONDA</dbuser>
    <dbuserpass>SONDAServer1237710</dbuserpass>
    <routeid>46</routeid>
    <loginId>hector@SONDA</loginId>
</Data>'
  
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_UPDATE_PICKING_DEMAND_BY_TASK_BY_XML] (@XML XML)
AS
BEGIN
  BEGIN TRY


    --

    DECLARE @PICKING_DEMAND_BY_TASK TABLE (
      [TASK_ID] INT
     ,[PICKING_DEMAND_HEADER_ID] INT
     ,[IS_POSTED] INT NULL
     ,[PICKING_DEMAND_STATUS] VARCHAR(250)
    );

    DECLARE @PICKING_DEMAND_BY_TASK_RESULT TABLE (
      [PICKING_DEMAND_HEADER_ID] INT
     ,[TASK_ID] INT NULL
     ,[PICKING_DEMAND_STATUS] VARCHAR(50)
     ,[IS_POSTED] INT
    );

    -- --------------------------------------------------------------------------------------------------------

    INSERT INTO @PICKING_DEMAND_BY_TASK ([TASK_ID]
    , [PICKING_DEMAND_HEADER_ID]
    , [PICKING_DEMAND_STATUS]
    , [IS_POSTED])
      SELECT
        x.Rec.query('./taskId').value('.', 'int') [TASK_ID]
       ,x.Rec.query('./pickingDemandHeaderId').value('.', 'int') [PICKING_DEMAND_HEADER_ID]
       ,CASE [x].[Rec].[query]('./pickingDemandStatus').[value]('.', 'varchar(50)')
          WHEN 'NULL' THEN NULL
          WHEN 'UNDEFINED' THEN NULL
          ELSE [x].[Rec].[query]('./pickingDemandStatus').[value]('.', 'varchar(50)')
        END [PICKING_DEMAND_STATUS]
       ,2 [IS_POSTED]
      FROM @XML.nodes('Data/demandasDespachoPorTarea') AS x (Rec)

    -- ----------------------------------------------------------------------------------------------------------

    MERGE [SONDA].[SONDA_PICKING_DEMAND_BY_TASK] AS TRG
    USING (SELECT
        [TASK_ID]
       ,[PICKING_DEMAND_HEADER_ID]
       ,[PICKING_DEMAND_STATUS]
       ,[IS_POSTED]
      FROM @PICKING_DEMAND_BY_TASK) AS SRC
    ON TRG.[PICKING_DEMAND_HEADER_ID] = [SRC].[PICKING_DEMAND_HEADER_ID]
    WHEN MATCHED
      THEN UPDATE
        SET [TRG].[PICKING_DEMAND_STATUS] = [SRC].[PICKING_DEMAND_STATUS]
           ,[TRG].[TASK_ID] = [SRC].[TASK_ID]
           ,[TRG].[IS_POSTED] = [SRC].[IS_POSTED]
    WHEN NOT MATCHED
      THEN INSERT ([TASK_ID], [PICKING_DEMAND_HEADER_ID], [PICKING_DEMAND_STATUS], [IS_POSTED])
          VALUES ([SRC].[TASK_ID], [SRC].[PICKING_DEMAND_HEADER_ID], [SRC].[PICKING_DEMAND_STATUS], [SRC].[IS_POSTED]);
    --

    SELECT
      1 AS RESULTADO
     ,[TASK_ID]
     ,[PICKING_DEMAND_HEADER_ID]
     ,2 AS [IS_POSTED]
     ,[PICKING_DEMAND_STATUS]
    FROM @PICKING_DEMAND_BY_TASK

  END TRY
  BEGIN CATCH
    --    

    SELECT
      -1 AS RESULTADO
     ,ERROR_MESSAGE() [Mensaje]
     ,@@error [Codigo]
     ,0 [DbData];

  END CATCH
END
