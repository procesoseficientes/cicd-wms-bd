----------------------------------------------------------------------------------------
-- =============================================
-- Autor:                 marvin.solares
-- Fecha de Creacion:   20180822 GForce@Humano
-- Description:          SP que obtiene el ultimo correlativo asignado
/*
-- Ejemplo de Ejecucion:
		EXEC [wms].[OP_WMS_SP_GET_LAST_ASSIGNED_SERIAL_CORRELATIVE] 
		
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_LAST_ASSIGNED_SERIAL_CORRELATIVE]
AS
BEGIN

	DECLARE
		@CORRELATIVE_ID VARCHAR(20)
		,@RANGE_NUM_START DECIMAL
		,@RANGE_NUM_END DECIMAL
		,@LAST_ASSIGNED_CORRELATIVE NUMERIC(18, 0);

		-- ------------------------------------------------------------------------------------
		-- Obtengo la configuracion del rango de la serie correlativa
		-- ------------------------------------------------------------------------------------
	SELECT
		@CORRELATIVE_ID = [TEXT_VALUE]
		,@RANGE_NUM_START = [RANGE_NUM_START]
		,@RANGE_NUM_END = [RANGE_NUM_END]
	FROM
		[wms].[OP_WMS_CONFIGURATIONS]
	WHERE
		[PARAM_TYPE] = 'SISTEMA'
		AND [PARAM_GROUP] = 'RECEPCION'
		AND [PARAM_NAME] = 'RANGO_SERIES_CORRELATIVAS';

		-- ------------------------------------------------------------------------------------
		-- Asigno el valor del ultimo correlativo
		-- ------------------------------------------------------------------------------------
	SELECT
		@LAST_ASSIGNED_CORRELATIVE = ISNULL(MAX([SERIAL_CORRELATIVE]),
											0)
	FROM
		[wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER]
	WHERE
		[SERIAL_CORRELATIVE_ID] = @CORRELATIVE_ID;

	IF @LAST_ASSIGNED_CORRELATIVE = 0
	BEGIN
		SET @LAST_ASSIGNED_CORRELATIVE = @RANGE_NUM_START;
	END;
	IF @LAST_ASSIGNED_CORRELATIVE = @RANGE_NUM_END
	BEGIN
	SELECT
		-1 AS [Resultado]
		,'Usted ha alcanzado el máximo asignado para esta serie correlativa, para continuar deberá asignar un nuevo identificador de serie' [Mensaje]
		,100 [Codigo]
		,CAST(0 AS VARCHAR(20)) [DbData];
	END
	ELSE
	BEGIN
	SELECT
		1 AS [Resultado]
		,'Proceso Exitoso' [Mensaje]
		,0 [Codigo]
		,CAST(@LAST_ASSIGNED_CORRELATIVE AS VARCHAR(20)) [DbData];
	END
	

END;