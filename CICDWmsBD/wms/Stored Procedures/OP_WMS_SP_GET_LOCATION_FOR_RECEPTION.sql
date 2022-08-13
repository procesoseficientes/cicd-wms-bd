
-- =============================================
-- Autor:				        hector.gonzalez
-- Fecha de Creacion: 	2017-01-13 @TeamErgon Sprint 1
-- Description:			    Obtiene las ubicaciones de tipo puerta y rampa
 
 -- Modificación: pablo.aguilar
 -- Fecha de Modificación: 2017-06-15 ErgonTeam@SHEIK
 -- Description:	 SE modifica para que la columna AVAILABLE devuelva un varchar
 
 
 

/*
	Ejemplo Ejecucion: 
    EXEC	[wms].[OP_WMS_SP_GET_LOCATION_FOR_RECEPTION] @DISTRIBUTION_CENTER_ID= 'CTR_SUR' 
		
 */
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_GET_LOCATION_FOR_RECEPTION (@DISTRIBUTION_CENTER_ID VARCHAR(25) = NULL)
AS
BEGIN

  SELECT
    owss.WAREHOUSE_PARENT
   ,owss.ZONE
   ,owss.LOCATION_SPOT
   ,owss.SPOT_TYPE
   ,owss.SPOT_ORDERBY
   ,owss.SPOT_AISLE
   ,owss.SPOT_COLUMN
   ,owss.SPOT_LEVEL
   ,owss.SPOT_PARTITION
   ,owss.SPOT_LABEL
   ,owss.ALLOW_PICKING
   ,owss.ALLOW_STORAGE
   ,owss.ALLOW_REALLOC
   ,CAST(owss.AVAILABLE AS VARCHAR) AVAILABLE
   ,owss.LINE_ID
   ,owss.SPOT_LINE
   ,owss.LOCATION_OVERLOADED
   ,owss.MAX_MT2_OCCUPANCY
  FROM [wms].OP_WMS_SHELF_SPOTS owss
  INNER JOIN [wms].[OP_WMS_WAREHOUSES] [W]
    ON W.[WAREHOUSE_ID] = [owss].[WAREHOUSE_PARENT]
  WHERE (owss.SPOT_TYPE = 'RAMPA'
  OR owss.SPOT_TYPE = 'PUERTA' OR [owss].[SPOT_TYPE] ='RECEPCION')
  AND (@DISTRIBUTION_CENTER_ID IS NULL
  OR [W].[DISTRIBUTION_CENTER_ID] = @DISTRIBUTION_CENTER_ID)


END
