-- =============================================
-- Autor:				      rudi.garcia
-- Fecha de Creacion: 29-03-2016
-- Description:			Obtiene las rutas con picking
-- Modificado: 05-05-2016
-- pablo.aguilar
-- Se agrega LEFT JOIN SWIFT_VEHICLE_X_USER a SELECT para devolver asociación el vehiculo asociado al vendedor
/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [SONDA].[SONDA_SP_GET_ROUTE_BY_PICKING]			
					
*/
-- =============================================

CREATE PROCEDURE [SONDA].SONDA_SP_GET_ROUTE_BY_PICKING

AS
BEGIN
  --
  SET NOCOUNT ON;

  DECLARE @PICKING_CLOSED_STATUS VARCHAR(50)
  -- ----------------------------------------------------------------------------------
  -- Se obtiene el stado para picking
  -- ----------------------------------------------------------------------------------	
  PRINT ('Se obtiene el stado para picking')
  SELECT
    @PICKING_CLOSED_STATUS = P.VALUE
  FROM [SONDA].SWIFT_PARAMETER P
  WHERE P.GROUP_ID = 'PICKING'
  AND P.PARAMETER_ID = 'CLOSED_STATUS'

  -- ----------------------------------------------------------------------------------
  -- Se obtiene la cantidad de picking de las rutas
  -- ----------------------------------------------------------------------------------	
  PRINT ('Se obtiene las rutas con picking')
  SELECT
    ISNULL(VR.CODE_ROUTE, 'No tiene una ruta') AS CODE_ROUTE_DETAIL
   ,ISNULL(VR.NAME_ROUTE, 'No tiene una ruta') AS NAME_ROUTE_DETAIL
   ,ISNULL(VS.SELLER_CODE, 'No tiene un vendedor') AS SELLER_CODE
   ,ISNULL(VS.SELLER_NAME, 'No tiene un vendedor') AS SELLER_NAME
   ,COUNT(A.PICKING_HEADER) AS QTY INTO #DETAIL
  FROM [SONDA].SWIFT_PICKING_HEADER A
  LEFT JOIN [SONDA].SWIFT_VIEW_ALL_COSTUMER B
    ON (A.CODE_CLIENT = B.CODE_CUSTOMER)
  --LEFT JOIN [SONDA].SWIFT_FREQUENCY_X_CUSTOMER FC ON (A.CODE_CLIENT = FC.CODE_CUSTOMER)
  --LEFT JOIN [SONDA].SWIFT_FREQUENCY F ON (F.ID_FREQUENCY = FC.ID_FREQUENCY)
  LEFT JOIN [SONDA].SWIFT_VIEW_ALL_SELLERS VS
    ON (A.CODE_SELLER = VS.SELLER_CODE)
  LEFT JOIN [SONDA].SWIFT_VIEW_ALL_ROUTE VR
    ON (VR.CODE_ROUTE = A.CODE_ROUTE)
  LEFT JOIN [SONDA].SWIFT_MANIFEST_DETAIL MD
    ON (A.PICKING_HEADER = MD.CODE_PICKING)
  WHERE MD.CODE_PICKING IS NULL
  AND A.STATUS = @PICKING_CLOSED_STATUS
  AND A.FF_STATUS = @PICKING_CLOSED_STATUS
  GROUP BY VR.CODE_ROUTE
          ,VR.NAME_ROUTE
          ,VS.SELLER_CODE
          ,VS.SELLER_NAME

  -- ----------------------------------------------------------------------------------
  -- Se obtiene las rutas con la cantidad de picking
  -- ----------------------------------------------------------------------------------	
  PRINT ('Se obtiene las rutas con picking')
  SELECT    
    D.CODE_ROUTE_DETAIL
   ,D.NAME_ROUTE_DETAIL
   ,D.QTY
   ,D.SELLER_CODE
   ,D.SELLER_NAME
   ,VR.ROUTE
   ,VR.CODE_ROUTE
   ,VR.NAME_ROUTE
   ,VR.GEOREFERENCE_ROUTE
   ,VR.COMMENT_ROUTE
   ,VR.LAST_UPDATE
   ,VR.LAST_UPDATE_BY
   ,sv.CODE_VEHICLE
  FROM #DETAIL D
  LEFT JOIN [SONDA].SWIFT_VIEW_ALL_ROUTE VR
    ON (D.CODE_ROUTE_DETAIL = VR.CODE_ROUTE)
  LEFT JOIN [SONDA].USERS u 
    ON  (u.RELATED_SELLER = D.SELLER_CODE)
  LEFT JOIN  [SONDA].SWIFT_VEHICLE_X_USER svxu
    ON (svxu.[LOGIN] = u.[LOGIN])
  LEFT JOIN  [SONDA].SWIFT_VEHICLES sv
    ON (sv.VEHICLE = svxu.VEHICLE)
  WHERE 
    (u.SELLER_ROUTE = VR.CODE_ROUTE OR  VR.CODE_ROUTE IS NULL )
    AND (D.QTY IS NOT NULL
  OR D.QTY > 0)

END
