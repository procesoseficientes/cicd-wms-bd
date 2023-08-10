-- =============================================
-- Autor:				hector.gonzalez
-- Fecha de Creacion: 	18/12/2017 @ Reborn - TEAM Sprint Pannen
-- Description:			SP que actualiza las tareas por xml

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_UPDATE_TASKS_BY_XML]
				@XML = '
					
<Data>
    <tareas>        
        <taskId>494148</taskId>        
        <relatedClientCode>SO-2463736</relatedClientCode>
        <taskBoId>494148</taskBoId>
        <completedSuccessfully>null</completedSuccessfully>
        <reason>null</reason>
        <acceptedStamp>null</acceptedStamp>       
        <completedStamp>null</completedStamp>               
        <taskStatus>ASSIGNED</taskStatus>
        <postedGps>null</postedGps>
        <taskSeq>1</taskSeq>
    </tareas>
    <dbuser>USONDA</dbuser>
    <dbuserpass>SONDAServer1237710</dbuserpass>
    <routeid>46</routeid>
    <loginId>hector@SONDA</loginId>
</Data>'

*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_TASKS_BY_XML] (@XML XML)
AS
BEGIN
  BEGIN TRY
    DECLARE @ID INT
           ,@TASK_ID INT
           ,@TASK_BO_ID INT
           ,@CUSTOMER_CODE VARCHAR(25)
           ,@COMPLETED_SUCCESSFULLY INT
           ,@REASON VARCHAR(50)
           ,@ACCEPTED_STAMP DATETIME
           ,@COMPLETED_STAMP DATETIME
           ,@TASK_STATUS VARCHAR(250)
           ,@POSTED_GPS VARCHAR(250)
           ,@TASK_SEQ INT
           ,@LOG_MESSAGE VARCHAR(100)
    --

    DECLARE @TASKS TABLE (
      [TASK_ID] INT
     ,[TASK_BO_ID] INT
     ,[CUSTOMER_CODE] VARCHAR(25)
     ,[COMPLETED_SUCCESSFULLY] INT NULL
     ,[REASON] VARCHAR(50) NULL
     ,[ACCEPTED_STAMP] DATETIME NULL
     ,[COMPLETED_STAMP] DATETIME NULL
     ,[TASK_STATUS] VARCHAR(250) NULL
     ,[POSTED_GPS] VARCHAR(250) NULL
     ,[TASK_SEQ] INT NULL
    );

    DECLARE @TASKS_RESULT TABLE (
      [TASK_ID] INT
     ,[TASK_BO_ID] INT
     ,[CUSTOMER_CODE] VARCHAR(25)
     ,[COMPLETED_SUCCESSFULLY] INT NULL
     ,[REASON] VARCHAR(50) NULL
     ,[ACCEPTED_STAMP] DATETIME NULL
     ,[COMPLETED_STAMP] DATETIME NULL
     ,[TASK_STATUS] VARCHAR(250) NULL
     ,[POSTED_GPS] VARCHAR(250) NULL
     ,[TASK_SEQ] INT NULL
    );

    -- --------------------------------------------------------------------------------------------------------

    INSERT INTO @TASKS ([TASK_ID]
    , [CUSTOMER_CODE]
    , [TASK_BO_ID]
    , [COMPLETED_SUCCESSFULLY]
    , [REASON]
    , [ACCEPTED_STAMP]
    , [COMPLETED_STAMP]
    , [TASK_STATUS]
    , [POSTED_GPS]
    , [TASK_SEQ])
      SELECT
        x.Rec.query('./taskId').value('.', 'int')
       ,x.Rec.query('./relatedClientCode').value('.', 'varchar(25)')
       ,CASE [x].[Rec].[query]('./taskBoId').[value]('.', 'varchar(50)')
          WHEN 'NULL' THEN NULL
          WHEN 'UNDEFINED' THEN NULL
          ELSE [x].[Rec].[query]('./taskBoId').[value]('.', 'int')
        END
       ,CASE [x].[Rec].[query]('./completedSuccessfully').[value]('.', 'varchar(50)')
          WHEN 'NULL' THEN NULL
          WHEN 'UNDEFINED' THEN NULL
          ELSE [x].[Rec].[query]('./completedSuccessfully').[value]('.', 'int')
        END
       ,CASE [x].[Rec].[query]('./reason').[value]('.', 'varchar(250)')
          WHEN 'NULL' THEN NULL
          WHEN 'UNDEFINED' THEN NULL
          ELSE [x].[Rec].[query]('./reason').[value]('.', 'varchar(50)')
        END
       ,CASE [x].[Rec].[query]('./acceptedStamp').[value]('.', 'varchar(50)')
          WHEN 'NULL' THEN NULL
          WHEN 'UNDEFINED' THEN NULL
          ELSE [x].[Rec].[query]('./acceptedStamp').[value]('.', 'datetime')
        END
       ,CASE [x].[Rec].[query]('./completedStamp').[value]('.', 'varchar(50)')
          WHEN 'NULL' THEN NULL
          WHEN 'UNDEFINED' THEN NULL
          ELSE [x].[Rec].[query]('./completedStamp').[value]('.', 'datetime')
        END
       ,CASE [x].[Rec].[query]('./taskStatus').[value]('.', 'varchar(50)')
          WHEN 'NULL' THEN NULL
          WHEN 'UNDEFINED' THEN NULL
          ELSE [x].[Rec].[query]('./taskStatus').[value]('.', 'varchar(250)')
        END
       ,CASE [x].[Rec].[query]('./postedGps').[value]('.', 'varchar(50)')
          WHEN 'NULL' THEN NULL
          WHEN 'UNDEFINED' THEN NULL
          ELSE [x].[Rec].[query]('./postedGps').[value]('.', 'varchar(250)')
        END
       ,CASE [x].[Rec].[query]('./taskSeq').[value]('.', 'varchar(50)')
          WHEN 'NULL' THEN NULL
          WHEN 'UNDEFINED' THEN NULL
          ELSE [x].[Rec].[query]('./taskSeq').[value]('.', 'int')
        END
      FROM @XML.nodes('Data/tareas') AS x (Rec)

    -- ----------------------------------------------------------------------------------------------------------


    WHILE EXISTS (SELECT TOP 1
          1
        FROM @TASKS)
    BEGIN

      SELECT TOP 1
        @TASK_ID = [T].[TASK_ID]
       ,@CUSTOMER_CODE = [T].[CUSTOMER_CODE]
       ,@COMPLETED_SUCCESSFULLY = [T].[COMPLETED_SUCCESSFULLY]
       ,@REASON = [T].[REASON]
       ,@ACCEPTED_STAMP = [T].[ACCEPTED_STAMP]
       ,@COMPLETED_STAMP = [T].[COMPLETED_STAMP]
       ,@TASK_STATUS = [T].[TASK_STATUS]
       ,@POSTED_GPS = [T].[POSTED_GPS]
       ,@TASK_SEQ = [T].[TASK_SEQ]
       ,@TASK_BO_ID = [T].[TASK_BO_ID]
      FROM @TASKS AS T

    --      
    BEGIN TRY

      UPDATE [SONDA].[SWIFT_TASKS]
      SET COMPLETED_SUCCESSFULLY = @COMPLETED_SUCCESSFULLY
         ,REASON = @REASON
         ,[ACCEPTED_STAMP] = @ACCEPTED_STAMP
         ,[COMPLETED_STAMP] = @COMPLETED_STAMP
         ,[TASK_STATUS] = @TASK_STATUS
         ,[POSTED_GPS] = @POSTED_GPS
         ,[TASK_SEQ] = @TASK_SEQ
      WHERE TASK_ID = @TASK_ID
      AND COSTUMER_CODE = @CUSTOMER_CODE

      --      

      INSERT INTO @TASKS_RESULT ([TASK_ID], [CUSTOMER_CODE], [COMPLETED_SUCCESSFULLY], [REASON], [ACCEPTED_STAMP], [COMPLETED_STAMP], [TASK_STATUS], [POSTED_GPS], [TASK_SEQ], [TASK_BO_ID])
        VALUES (@TASK_ID, @CUSTOMER_CODE, @COMPLETED_SUCCESSFULLY, @REASON, @ACCEPTED_STAMP, @COMPLETED_STAMP, @TASK_STATUS, @POSTED_GPS, @TASK_SEQ, @TASK_BO_ID);


    END TRY
    BEGIN CATCH
      SET @LOG_MESSAGE = ERROR_MESSAGE()
      EXEC [SONDA].[SONDA_SP_INSERT_SONDA_SERVER_ERROR_LOG] @CODE_ROUTE = NULL
                                                           ,@LOGIN = NULL
                                                           ,@SOURCE_ERROR = 'SWIFT_SP_UPDATE_TASKS_BY_XML'
                                                           ,@DOC_RESOLUTION = NULL
                                                           ,@DOC_SERIE = NULL
                                                           ,@DOC_NUM = NULL
                                                           ,@MESSAGE_ERROR = @LOG_MESSAGE
                                                           ,@SEVERITY_CODE = 10

    END CATCH

      DELETE FROM @TASKS
      WHERE [TASK_ID] = @TASK_ID

    END

    --

    SELECT
      1 AS RESULTADO
     ,[TASK_ID]
     ,[CUSTOMER_CODE]
     ,[COMPLETED_SUCCESSFULLY]
     ,[REASON]
     ,[ACCEPTED_STAMP]
     ,[COMPLETED_STAMP]
     ,[TASK_STATUS]
     ,[POSTED_GPS]
     ,[TASK_SEQ]
     ,[TASK_BO_ID]
    FROM @TASKS_RESULT

  END TRY
  BEGIN CATCH
    --    


    SELECT
      -1 AS [Resultado]
     ,ERROR_MESSAGE() [Mensaje]
     ,@@error [Codigo]
     ,0 [DbData];

  END CATCH
END
