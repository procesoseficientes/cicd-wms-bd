-- =============================================
-- Autor:	              hector.gonzalez
-- Fecha de Creacion: 	2017-02-28 @ Team ERGON - Sprint Ganondorf
-- Description:	        Sp que trae los operadores asociados al mismo centro de distribucion y bodegas del operador enviado Y QUE PUEDEN REUBICAR


/*
-- Ejemplo de Ejecucion:  
	EXEC [wms].OP_WMS_SP_GET_CAN_REALLOCATE_OPERATORS_ASSIGNED_TO_DISTRIBUTION_CENTER_BY_USER @LOGIN = 'ADMIN'
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_GET_CAN_REALLOCATE_OPERATORS_ASSIGNED_TO_DISTRIBUTION_CENTER_BY_USER (@LOGIN VARCHAR(25))
AS
BEGIN
  SET NOCOUNT ON;
  --
  SELECT DISTINCT
    [LR].[LOGIN_ID]
   ,[LR].[LOGIN_NAME]
  FROM [wms].[OP_WMS_LOGINS] [LA]
  INNER JOIN [wms].[OP_WMS_LOGINS] [LR]
    ON (
    [LA].[DISTRIBUTION_CENTER_ID] = [LR].[DISTRIBUTION_CENTER_ID]
    )
  INNER JOIN [wms].[OP_WMS_WAREHOUSE_BY_USER] [WUA]
    ON (
    [WUA].[LOGIN_ID] = [LA].[LOGIN_ID]
    )
  INNER JOIN [wms].[OP_WMS_WAREHOUSE_BY_USER] [WUR]
    ON (
    [WUR].[LOGIN_ID] = [LR].[LOGIN_ID]
    AND [WUA].[WAREHOUSE_ID] = [WUR].[WAREHOUSE_ID]
    )
  WHERE [LA].[LOGIN_ID] = @LOGIN
  AND [LR].[LOGIN_STATUS] = 'ACTIVO'
  AND ([LR].[ROLE_ID] LIKE 'OPER%'
  OR [LR].[ROLE_ID] LIKE 'SUPER%')
  AND [LR].[CAN_RELOCATE] = 1
  ORDER BY [LR].[LOGIN_NAME]

END