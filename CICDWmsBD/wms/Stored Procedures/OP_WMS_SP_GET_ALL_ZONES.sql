-- =============================================
-- Autor:					julian.chamale
-- Fecha de Creacion: 		27-Apr-17 @ ErgonTeam Ganondorf
-- Description:				Realizar un select a todo OP_WMS_ZONE para mostrarlo en pantalla. 
   
/*
-- Ejemplo de Ejecucion:
EXEC [wms].[OP_WMS_SP_GET_ALL_ZONES] 
*/
-- =============================================

--SET QUOTED_IDENTIFIER ON|OFF
--SET ANSI_NULLS ON|OFF
--GO
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_ALL_ZONES]
AS
	BEGIN
		SELECT
			[ZONE_ID]
			,[ZONE]
			,[DESCRIPTION]
			,[WAREHOUSE_CODE]
			,[RECEIVE_EXPLODED_MATERIALS]
			,[LINE_ID]
		FROM
			[wms].[OP_WMS_ZONE];		
	END;