-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	11-11-2015
-- Description:			Genera las tareas para el dia actual para todas las rutas o una

-- Modificacion 25-05-2016
-- alberto.ruiz
-- Se agrego la funcion de limpiar caracteres al nombre del cliente y el comentario de la tarea


  -- Modificacion 29-Nov-2016
-- pablo.aguilar
-- Se agrega join a la vista de clientes para obtener el codigo RGA 

-- Modificacion 2/17/2017 @ A-Team Sprint Chatuluka
-- rodrigo.gomez
-- Se agrego la columna NIT.

/*
-- Ejemplo de Ejecucion:
				exec [SONDA].SONDA_SP_GET_ROUTE_PLAN @CODE_ROUTE = '101109'
  select * from [SONDA].
*/
-- =============================================
CREATE PROCEDURE [SONDA].SONDA_SP_GET_ROUTE_PLAN @CODE_ROUTE VARCHAR(50)
AS
BEGIN
  SET NOCOUNT ON;
  --
  SELECT
    [RP].[TASK_ID]
   ,[RP].[CODE_FREQUENCY]
   ,[RP].[SCHEDULE_FOR]
   ,[RP].[ASSIGNED_BY]
   ,[RP].[DOC_PARENT]
   ,[RP].[EXPECTED_GPS]
   ,[dbo].[FUNC_REMOVE_SPECIAL_CHARS]([RP].[TASK_COMMENTS]) [TASK_COMMENTS]
   ,[RP].[TASK_SEQ]
   ,[RP].[TASK_ADDRESS]
   ,[RP].[RELATED_CLIENT_PHONE_1]
   ,[RP].[EMAIL_TO_CONFIRM]
   ,[RP].[RELATED_CLIENT_CODE]
   ,[dbo].[FUNC_REMOVE_SPECIAL_CHARS]([RP].[RELATED_CLIENT_NAME]) [RELATED_CLIENT_NAME]
   ,[RP].[TASK_PRIORITY]
   ,[RP].[TASK_STATUS]
   ,[RP].[SYNCED]
   ,[RP].[NO_PICKEDUP]
   ,[RP].[NO_VISIT_REASON]
   ,[RP].[IS_OFFLINE]
   ,[RP].[DOC_NUM]
   ,[RP].[TASK_TYPE]
   ,[RP].[TASK_DATE]
   ,[RP].[CREATED_STAMP]
   ,[RP].[ASSIGEND_TO]
   ,[RP].[CODE_ROUTE]
   ,[RP].[TARGET_DOC]
   ,[RP].[IN_PLAN_ROUTE]
   ,[RP].[CREATE_BY]
   ,ISNULL([C].[RGA_CODE] , '') RGA_CODE
   ,ISNULL([C].[TAX_ID_NUMBER] , 'C.F') NIT
   ,C.PHONE_CUSTOMER
  FROM [SONDA].[SONDA_ROUTE_PLAN] [RP]
    INNER JOIN [SONDA].[SWIFT_VIEW_ALL_COSTUMER] [C] ON [C].[CODE_CUSTOMER] = [RP].[RELATED_CLIENT_CODE]
  WHERE [RP].[CODE_ROUTE] = @CODE_ROUTE
  ORDER BY [RP].[TASK_SEQ]
END
