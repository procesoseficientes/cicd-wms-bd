-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	11-11-2015
-- Description:			Genera las tareas para el dia actual para todas las rutas o una

-- Modificado 01-22-2016
-- joel.delcompare
-- Se agrego la frecuencia 

-- Modificacion 01-22-2016
--              hector.gonzalez
--              Se agregaron se agregaron columans: IN_PLAN_ROUTE y CREATE_BY 

/*
-- Ejemplo de Ejecucion:
				exec [SONDA].SONDA_SP_GENERATE_ROUTE_PLAN
				--
				exec [SONDA].SONDA_SP_GENERATE_ROUTE_PLAN @CODE_FREQUENCY_OLD = '' ,@CODE_FREQUENCY_NEW = ''
				--
				exec [SONDA].SONDA_SP_GENERATE_ROUTE_PLAN @CODE_FREQUENCY_NEW = '00111101SALE001'
*/
-- =============================================
CREATE PROCEDURE SONDA.SONDA_SP_GENERATE_ROUTE_PLAN
-- Add the parameters for the stored procedure here
@CODE_FREQUENCY_OLD VARCHAR(50) = NULL
, @CODE_FREQUENCY_NEW VARCHAR(50) = NULL
AS
BEGIN
  SET NOCOUNT ON;
  --

  CREATE TABLE [#frecuenciaDia] (
    [ID_FREQUENCY] INT
  );
  --------------------------------------------------------------------
  -- Verifica que tipo de frecuencias debe utilizar
  --------------------------------------------------------------------
  DECLARE @GENERATE_ROUTE_PLAN_FROM_POLYGON VARCHAR(250) = '1';

  SELECT
    @GENERATE_ROUTE_PLAN_FROM_POLYGON = [SONDA].[SWIFT_FN_GET_PARAMETER]('IMPLEMENTATION',
    'GENERATE_ROUTE_PLAN_FROM_POLYGON');

  -- -----------------------------------------------------------------
  -- Elimina el registro o todos
  -- -----------------------------------------------------------------
  IF (
    @CODE_FREQUENCY_OLD IS NULL
    AND @CODE_FREQUENCY_NEW IS NULL
    )
  BEGIN
    TRUNCATE TABLE [SONDA].[SONDA_ROUTE_PLAN];
    --
    DELETE FROM [SONDA].[SWIFT_TASKS]
    WHERE [ASSIGNED_BY] = 'Proceso diario'
      AND [TASK_DATE] = CONVERT(DATE, GETDATE());
  END;
  ELSE
  BEGIN
    DELETE FROM [SONDA].[SWIFT_TASKS]
    WHERE [ASSIGNED_BY] = 'Proceso diario'
      AND [TASK_DATE] = CONVERT(DATE, GETDATE())
      AND [TASK_STATUS] = 'ASSIGNED'
      AND [TASK_ID] IN (SELECT
          [TASK_ID]
        FROM [SONDA].[SONDA_ROUTE_PLAN]
        WHERE [CODE_FREQUENCY] = @CODE_FREQUENCY_OLD);
    --
    DELETE [SONDA].[SONDA_ROUTE_PLAN]
    WHERE [CODE_FREQUENCY] = @CODE_FREQUENCY_OLD;
  END;


  -- -----------------------------------------------------------------
  -- Obtiene todas las frecuancias
  -- -----------------------------------------------------------------
  DECLARE @DATE DATETIME = GETDATE();
  --
  INSERT INTO [#frecuenciaDia]
  EXEC [SONDA].[SWIFT_SP_GET_FREQUENCY_X_TASK] @DATE = @DATE
                                              ,@CODE_FREQUENCY = @CODE_FREQUENCY_NEW;
  --
  SELECT DISTINCT
    [F].*
   ,[X].[CODE_CUSTOMER]
   ,[C].[NAME_CUSTOMER]
   ,COALESCE([C].[ADRESS_CUSTOMER], 'No tiene direccion') [ADRESS_CUSTOMER]
   ,COALESCE([C].[PHONE_CUSTOMER], 'No tiene telefono') [PHONE_CUSTOMER]
   ,[C].[GPS]
   ,NULL [EMAIL_TO_CONFIRM]
   ,[U].[LOGIN]
   ,[X].[PRIORITY] INTO [#frecuencia]
  FROM [SONDA].[SWIFT_FREQUENCY] [F]
  INNER JOIN [#frecuenciaDia] [D]
    ON ([F].[ID_FREQUENCY] = [D].[ID_FREQUENCY])
  INNER JOIN [SONDA].[SWIFT_FREQUENCY_X_CUSTOMER] [X]
    ON ([F].[ID_FREQUENCY] = [X].[ID_FREQUENCY])
  INNER JOIN [SONDA].[SWIFT_VIEW_ALL_COSTUMER] [C]
    ON ([X].[CODE_CUSTOMER] = [C].[CODE_CUSTOMER])
  INNER JOIN [SONDA].[USERS] [U]
    ON ([F].[CODE_ROUTE] = [U].[SELLER_ROUTE])
  WHERE GETDATE() BETWEEN [F].[LAST_WEEK_VISITED]
  AND DATEADD(WEEK, 1, [F].[LAST_WEEK_VISITED])
  AND [F].[IS_BY_POLIGON] = CAST(@GENERATE_ROUTE_PLAN_FROM_POLYGON AS INT)
  AND ([F].[IS_BY_POLIGON] = 1
  OR (GETDATE() BETWEEN [X].[LAST_WEEK_VISITED]
  AND DATEADD(WEEK, 1, [X].[LAST_WEEK_VISITED])))
  ORDER BY [X].[PRIORITY];

  -- -----------------------------------------------------------------
  -- Inserta en la tabla SWIFT_TASKS
  -- -----------------------------------------------------------------
  INSERT INTO [SONDA].[SWIFT_TASKS] ([TASK_TYPE]
  , [TASK_DATE]
  , [SCHEDULE_FOR]
  , [CREATED_STAMP]
  , [ASSIGEND_TO]
  , [ASSIGNED_BY]
  , [ASSIGNED_STAMP]
  , [CANCELED_STAMP]
  , [CANCELED_BY]
  , [ACCEPTED_STAMP]
  , [COMPLETED_STAMP]
  , [RELATED_PROVIDER_CODE]
  , [RELATED_PROVIDER_NAME]
  , [EXPECTED_GPS]
  , [POSTED_GPS]
  , [TASK_STATUS]
  , [TASK_COMMENTS]
  , [TASK_SEQ]
  , [REFERENCE]
  , [SAP_REFERENCE]
  , [COSTUMER_CODE]
  , [COSTUMER_NAME]
  , [RECEPTION_NUMBER]
  , [PICKING_NUMBER]
  , [COUNT_ID]
  , [ACTION]
  , [SCANNING_STATUS]
  , [ALLOW_STORAGE_ON_DIFF]
  , [CUSTOMER_PHONE]
  , [TASK_ADDRESS]
  , [VISIT_HOUR]
  , [ROUTE_IS_COMPLETED]
  , [EMAIL_TO_CONFIRM]
  , [IN_PLAN_ROUTE]
  , [CREATE_BY])
    SELECT
      [f].[TYPE_TASK]
     ,GETDATE()
     ,GETDATE()
     ,GETDATE()
     ,[f].[LOGIN]
     ,'Proceso diario'
     ,GETDATE()
     ,NULL
     ,NULL
     ,NULL
     ,NULL
     ,NULL
     ,NULL
     ,[f].[GPS]
     ,NULL
     ,'ASSIGNED'
     ,'Tarea generada para cliente ' + ISNULL([f].[NAME_CUSTOMER], '...')
     ,[f].[PRIORITY]
     ,NULL
     ,NULL
     ,[f].[CODE_CUSTOMER]
     ,ISNULL([f].[NAME_CUSTOMER], '...')
     ,NULL
     ,NULL
     ,NULL
     ,NULL
     ,NULL
     ,[f].[PRIORITY]
     ,[f].[PHONE_CUSTOMER]
     ,[f].[ADRESS_CUSTOMER]
     ,NULL
     ,NULL
     ,NULL
     ,1
     ,'BY_CALENDAR'
    FROM [#frecuencia] [f];

  -- -----------------------------------------------------------------
  -- Inserta en la tabla SONDA_ROUTE_PLAN
  -- -----------------------------------------------------------------
  INSERT INTO [SONDA].[SONDA_ROUTE_PLAN] ([TASK_ID]
  , [CODE_FREQUENCY]
  , [SCHEDULE_FOR]
  , [ASSIGNED_BY]
  , [DOC_PARENT]
  , [EXPECTED_GPS]
  , [TASK_COMMENTS]
  , [TASK_SEQ]
  , [TASK_ADDRESS]
  , [RELATED_CLIENT_PHONE_1]
  , [EMAIL_TO_CONFIRM]
  , [RELATED_CLIENT_CODE]
  , [RELATED_CLIENT_NAME]
  , [TASK_PRIORITY]
  , [TASK_STATUS]
  , [SYNCED]
  , [NO_PICKEDUP]
  , [NO_VISIT_REASON]
  , [IS_OFFLINE]
  , [DOC_NUM]
  , [TASK_TYPE]
  , [TASK_DATE]
  , [CREATED_STAMP]
  , [ASSIGEND_TO]
  , [CODE_ROUTE]
  , [IN_PLAN_ROUTE]
  , [CREATE_BY])
    SELECT
      [T].[TASK_ID]
     ,[F].[CODE_FREQUENCY]
     ,[T].[TASK_DATE]
     ,[T].[ASSIGNED_BY]
     ,0
     ,[T].[EXPECTED_GPS]
     ,ISNULL([T].[TASK_COMMENTS], '...')
     ,[T].[TASK_SEQ]
     ,[T].[TASK_ADDRESS]
     ,[F].[PHONE_CUSTOMER]
     ,[F].[EMAIL_TO_CONFIRM]
     ,[T].[COSTUMER_CODE]
     ,ISNULL([T].[COSTUMER_NAME], '...')
     ,[F].[PRIORITY]
     ,[T].[TASK_STATUS]
     ,1
     ,NULL
     ,NULL
     ,1
     ,NULL
     ,[T].[TASK_TYPE]
     ,[T].[TASK_DATE]
     ,[CREATED_STAMP]
     ,[T].[ASSIGEND_TO]
     ,[F].[CODE_ROUTE]
     ,1
     ,'BY_CALENDAR'
    FROM [#frecuencia] [F]
    INNER JOIN [SONDA].[SWIFT_TASKS] [T]
      ON (
      [T].[ASSIGEND_TO] = [F].[LOGIN]
      AND [T].[COSTUMER_CODE] = [F].[CODE_CUSTOMER]
      AND [T].[TASK_TYPE] = [F].[TYPE_TASK]
      AND [T].[TASK_STATUS] = 'ASSIGNED'
      AND [T].[TASK_DATE] = CONVERT(DATE, @DATE)
      );
END;
