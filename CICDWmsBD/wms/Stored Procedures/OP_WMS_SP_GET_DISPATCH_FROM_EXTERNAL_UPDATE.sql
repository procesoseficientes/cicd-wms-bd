
-- =============================================
-- Autor:				JOSE.GARCIA
-- Fecha de Creacion: 	17-ENERO-17 
-- Description:			GENERA LOS MATERIALES A INSERTAR 
--						EN EL INVENTARIO EXTERNO

/*
-- Ejemplo de Ejecucion:
				--
				

		EXEC [wms].[OP_WMS_SP_GET_DISPATCH_FROM_EXTERNAL_UPDATE]
						
				
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_DISPATCH_FROM_EXTERNAL_UPDATE]

AS
		SELECT 
		       [LOGIN_ID]
			  ,[MATERIAL_ID]
			  ,[MATERIAL_NAME]
			  ,[QTY_REQUESTED]
			  ,[QTY_ONHAND]
			  ,[PROCESS_RESULT]
			  ,[PROCESS_STAMP]
			  ,[READY_TO_GO]
		  INTO #PROCESADO
		  FROM  [wms].[OP_WMS_DISPATCH_FROM_EXTERNAL]
		  WHERE [PROCESS_RESULT]='PROCESADO'

		  TRUNCATE TABLE [wms].[OP_WMS_DISPATCH_FROM_EXTERNAL]
		  SELECT * FROM #PROCESADO