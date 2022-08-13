-- =============================================
-- Autor:					julian.chamale
-- Fecha de Creacion: 		27-Apr-17 @ ErgonTeam Ganondorf
-- Description:				Realizar un select a OP_WMS_ZONE con todas las zonas que este asociadas al parametro mediante la tabla de OP_WMS_ZONE_TO_REPLENISH_IN_ZONE
   
/*
-- Ejemplo de Ejecucion:
EXEC [wms].[OP_WMS_SP_GET_ZONES_ASOCCIATE_TO_ZONE_FOR_REPLENISH] @ZONE_ID = 1
*/
-- =============================================
--SET QUOTED_IDENTIFIER ON|OFF
--SET ANSI_NULLS ON|OFF
--GO
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_ZONES_ASOCCIATE_TO_ZONE_FOR_REPLENISH]
(
	@ZONE_ID INT
)
AS
	BEGIN
		SELECT
			Z.[ZONE_ID]
			,Z.[ZONE]
			,Z.[DESCRIPTION]
			,Z.[WAREHOUSE_CODE]
			,Z.[RECEIVE_EXPLODED_MATERIALS]
			,Z.[LINE_ID]
		FROM
			[wms].[OP_WMS_ZONE] Z
		INNER JOIN
			[wms].[OP_WMS_ZONE_TO_REPLENISH_IN_ZONE] R
		ON
			Z.[ZONE_ID] = R.[REPLENISH_ZONE_ID]
		WHERE
			R.[ZONE_ID] = @ZONE_ID
	END;