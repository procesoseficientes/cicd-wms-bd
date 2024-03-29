﻿-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	7/6/2017 @ NEXUS-Team Sprint AgeOfEmpires 
-- Description:			Valida si existe la ubicacion

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_VALIDATED_IF_JOIN_SPOT_EXISTS]
					@WAREHOUSE_PARENT = 'BODEGA_01'
					,@LOCATION_SPOT = 'B01-P01-F01-NU'
				--
				EXEC [wms].[OP_WMS_SP_VALIDATED_IF_JOIN_SPOT_EXISTS]
					@WAREHOUSE_PARENT = 'BODEGA_01'
					,@LOCATION_SPOT = 'B01-P01-F01-NU@'
				--
				EXEC [wms].[OP_WMS_SP_VALIDATED_IF_JOIN_SPOT_EXISTS]
					@LOCATION_SPOT = 'B01-P01-F01-NU'
				--
				EXEC [wms].[OP_WMS_SP_VALIDATED_IF_JOIN_SPOT_EXISTS]
					@LOCATION_SPOT = 'PISO1'
					,@WAREHOUSE_PARENT = ''
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_VALIDATED_IF_JOIN_SPOT_EXISTS](
	@WAREHOUSE_PARENT VARCHAR(25) = NULL	
	,@LOCATION_SPOT VARCHAR(25)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @EXISTS INT = 0
	--
	SELECT TOP 1 @EXISTS = 1
	FROM [wms].[OP_WMS_SHELF_SPOTS] 
	WHERE ([WAREHOUSE_PARENT] = @WAREHOUSE_PARENT OR @WAREHOUSE_PARENT IS NULL OR @WAREHOUSE_PARENT = '')
	AND [LOCATION_SPOT] = @LOCATION_SPOT
	--
	SELECT @EXISTS [EXISTS]
END