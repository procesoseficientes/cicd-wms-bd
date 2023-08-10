-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	10/24/2017 @ Reborn-TEAM Sprint Drache
-- Description:			SP que obtiene los registros de tareas de entrega de la tabla SWIFT_TASKS

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-11-16 @ Team REBORN - Sprint Eberhard [PHONE_CUSTOMER]
-- Description:	   Se agrega 

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_GET_DELIVERY_TASKS]
				@LOGIN_ID = 'ADOLFO@SONDA'
*/
-- =============================================
CREATE PROCEDURE [SONDA].SONDA_SP_GET_DELIVERY_TASKS (@LOGIN_ID VARCHAR(50))
AS
BEGIN
  SET NOCOUNT ON;
  --
  SELECT
  DISTINCT
    [TASK_ID]
   ,[TASK_TYPE]
   ,[TASK_DATE]
   ,[SCHEDULE_FOR]
   ,[CREATED_STAMP]
   ,[ASSIGEND_TO]
   ,[ASSIGNED_BY]
   ,[ACCEPTED_STAMP]
   ,[COMPLETED_STAMP]
   ,[EXPECTED_GPS]
   ,[POSTED_GPS]
   ,[dbo].[FUNC_REMOVE_SPECIAL_CHARS]([T].[TASK_COMMENTS]) [TASK_COMMENTS]
   ,[TASK_SEQ]
   ,[COSTUMER_CODE] RELATED_CLIENT_CODE
   ,[dbo].[FUNC_REMOVE_SPECIAL_CHARS]([T].[COSTUMER_NAME]) [RELATED_CLIENT_NAME]
   ,[T].[TASK_ADDRESS]
   ,[TASK_STATUS]
   ,ISNULL(VC.[RGA_CODE], '') RGA_CODE
   ,ISNULL(VC.[TAX_ID_NUMBER], 'C.F') NIT
   ,[VC].[PHONE_CUSTOMER]
  FROM [SONDA].[SWIFT_TASKS] AS T
  INNER JOIN [SONDA].[SWIFT_VIEW_ALL_COSTUMER] AS VC
    ON [VC].[CODE_CUSTOMER] = T.[COSTUMER_CODE]
  WHERE T.[ASSIGEND_TO] = @LOGIN_ID
  AND T.[TASK_TYPE] = 'DELIVERY_SD'
  AND T.[SCHEDULE_FOR] = CAST(GETDATE() AS DATE)
  AND T.[TASK_STATUS] = 'ASSIGNED'
  ORDER BY T.[TASK_SEQ]
END
