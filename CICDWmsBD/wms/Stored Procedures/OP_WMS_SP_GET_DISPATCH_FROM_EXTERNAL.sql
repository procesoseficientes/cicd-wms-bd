-- =============================================
-- Autor:				JOSE.GARCIA
-- Fecha de Creacion: 	17-ENERO-17 
-- Description:			GENERA LOS MATERIALES A INSERTAR 
--						EN EL INVENTARIO EXTERNO

-- Modificacion:				rudi.garcia
-- Fecha de Creacion: 	21-06-2017
-- Description:			Se agrego el case para verificar si las cantidades vienen null

/*
-- Ejemplo de Ejecucion:
				--
				

		EXEC [wms].[OP_WMS_SP_GET_DISPATCH_FROM_EXTERNAL]
						
				
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_GET_DISPATCH_FROM_EXTERNAL

AS

  SELECT
    [LOGIN_ID]
   ,[MATERIAL_ID]
   ,[MATERIAL_NAME]
   ,[QTY_REQUESTED]
   ,[QTY_ONHAND]
   --,[PROCESS_RESULT]
   ,CASE
      WHEN [QTY_REQUESTED] IS NULL THEN 'ERROR'
      WHEN [QTY_ONHAND] IS NULL THEN 'ERROR'
      ELSE [PROCESS_RESULT]
    END AS [PROCESS_RESULT]
   ,[PROCESS_STAMP]
   ,[READY_TO_GO]
  FROM [wms].[OP_WMS_DISPATCH_FROM_EXTERNAL]