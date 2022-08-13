-- =============================================
-- Autor:				marvin.solares
-- Fecha de Creacion: 	20180906 GForce@Jaguarundi
-- Description:			SP que devuelve la informacion cuando la licencia es de despacho
/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_INFO_LICENSE_DISPATCH] @LICENSE_ID = 480527
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_INFO_LICENSE_DISPATCH] (@LICENSE_ID INT)
AS
BEGIN
	DECLARE
		@WAVE_PICKING INT = 0
		,@TOTAL_LICENSES INT = 0
		,@LAST_UPDATED_BY VARCHAR(50)
		,@CORRELATIVE INT = 0
		,@REGIMEN VARCHAR(50) = ''
		,@DOC_NUM VARCHAR(50)
		,@CUSTOMER VARCHAR(50)
		,@DUE_DATE DATE = NULL;


	SELECT TOP 1
		@WAVE_PICKING = [WAVE_PICKING_ID]
		,@REGIMEN = [REGIMEN]
	FROM
		[wms].[OP_WMS_LICENSES]
	WHERE
		[LICENSE_ID] = @LICENSE_ID;

		-- ------------------------------------------------------------------------------------
		-- obtengo las licencias con su respectivo contador
		-- ------------------------------------------------------------------------------------

	SELECT
		ROW_NUMBER() OVER (ORDER BY [T].[LICENSE_ID] ASC) AS [Row]
		,[T].[LAST_UPDATED_BY]
		,[T].[LICENSE_ID]
	INTO
		[#LICENSES_TEMP]
	FROM
		[wms].[OP_WMS_LICENSES] [T]
	WHERE
		[WAVE_PICKING_ID] = @WAVE_PICKING;

		-- ------------------------------------------------------------------------------------
		-- obtengo los valores que me serviran para el select de retorno del procedimiento
		-- ------------------------------------------------------------------------------------
	SELECT TOP 1
		@CORRELATIVE = [Row]
		,@LAST_UPDATED_BY = [LAST_UPDATED_BY]
	FROM
		[#LICENSES_TEMP]
	WHERE
		[LICENSE_ID] = @LICENSE_ID;

		-- ------------------------------------------------------------------------------------
		-- obtengo el total de licencias de despachos creadas para la ola
		-- ------------------------------------------------------------------------------------

	SET @TOTAL_LICENSES = (SELECT
								COUNT(1)
							FROM
								[#LICENSES_TEMP]);

	-- ------------------------------------------------------------------------------------
	-- valido si es picking general o demanda de despacho
	-- ------------------------------------------------------------------------------------
	IF EXISTS ( SELECT TOP 1
					1
				FROM
					[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]
				WHERE
					[WAVE_PICKING_ID] = @WAVE_PICKING )
	BEGIN
		SELECT TOP 1
			@CUSTOMER = [CLIENT_CODE]
			,@DUE_DATE = [DEMAND_DELIVERY_DATE]
			,@DOC_NUM = [DOC_NUM]
		FROM
			[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]
		WHERE
			[WAVE_PICKING_ID] = @WAVE_PICKING;
	END;
	ELSE
	BEGIN
		SET @CUSTOMER = 'GENERAL';
		SET @DOC_NUM = 'GENERAL';
	END;
	
	SELECT
		@WAVE_PICKING [WAVE_PICKING_ID]
		,@DOC_NUM [DOC_NUM]
		,@CUSTOMER [CUSTOMER_NAME]
		,@DUE_DATE [DUE_DATE]
		,@LAST_UPDATED_BY [PREPARED_BY]
		,@CORRELATIVE [CORRELATIVE]
		,@TOTAL_LICENSES [TOTAL_LICENSES];

	
END;