-- =============================================
-- Autor:				crystian.ozorio
-- Fecha de Creación:	27-01-2020
-- Descripción:			Se agrega nombre del cliente como salida del SP para agregarla a la pantalla como salida en la pantalla de salida del backoffice para la pantalla de catalogo de productos
-- Modificación:		27-01-2020 G-force@Kioto
						


-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	15-Dec-16 @ A-TEAM Sprint 6 
-- Description:			Realiza la busqueda parcial del material

-- Modificacion 06-Jul-17 @ Nexus Team Sprint AgeOfEmpires
					-- alberto.ruiz
					-- Se agregan las columnas [IS_MASTER_PACK],[ERP_AVERAGE_PRICE],[WEIGHT_MEASUREMENT]

-- Modificacion 14-Jul-17 @ TeamOmikron Nexus@AgeOfEmpires
					-- eder.chamale
					-- Tunning

-- Modificacion 9/12/2017 @ NEXUS-Team Sprint DuckHunt
					-- rodrigo.gomez
					-- Se agrega columna CLASS_NAME

-- Autor:					marvin.solares
-- Fecha de Creacion: 		20180816 GForce@Humano 
-- Description:			    se agregan columnas HANDLE_CORRELATIVE_SERIALS Y PREFIX_CORRELATIVE_SERIALS

-- Autor:					marvin.solares
-- Fecha de Creacion: 		201090628 GForce@Cancun
-- Description:			    se agregan columnas SUPPLIER, NAME_SUPPLIER Y LEAD_TIME

-- Autor:					kevin.guerra
-- Fecha de Creacion: 		GForce@B
-- Description:			    Se agrega columna MATERIAL_SUB_CLASS

-- Autor:					fabrizio delcompare
-- Fecha de Creacion: 		31-7-2020
-- Description:			    select distinct al rededor de query

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SEARCH_PARTIAL_MATERIALS]
					@MATERIAL_ID = '', -- varchar(50)
					@MATERIAL_NAME = '', -- varchar(200)
					@SHORT_NAME = '' -- varchar(200)
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SEARCH_PARTIAL_MATERIALS] (
		@MATERIAL_ID VARCHAR(50)
		,@MATERIAL_NAME VARCHAR(200)
		,@SHORT_NAME VARCHAR(200)
	)
AS
BEGIN	
/*DECLARE @MATERIAL_ID VARCHAR(50)= '', -- varchar(50)
					@MATERIAL_NAME VARCHAR(200)= '', -- varchar(200)
					@SHORT_NAME VARCHAR(200)= '' -- varchar(200)*/
	SET NOCOUNT ON;
	--
	SELECT DISTINCT * FROM (
	--
	SELECT
		[M].[CLIENT_OWNER]
		,[M].[MATERIAL_ID]
		,[M].[BARCODE_ID]
		,[M].[ALTERNATE_BARCODE]
		,[M].[MATERIAL_NAME]
		,[M].[SHORT_NAME]
		,[M].[VOLUME_FACTOR]
		,[M].[MATERIAL_CLASS]
		,[M].[MATERIAL_SUB_CLASS]
		,ISNULL([C].[CLASS_NAME], '') [CLASS_NAME]
		,ISNULL([SC].[SUB_CLASS_NAME], '') [SUB_CLASS_NAME]
		,[M].[HIGH]
		,[M].[LENGTH]
		,[M].[WIDTH]
		,[M].[MAX_X_BIN]
		,[M].[SCAN_BY_ONE]
		,[M].[REQUIRES_LOGISTICS_INFO]
		,[M].[WEIGTH]
		,NULL AS [IMAGE_1]
		,NULL AS [IMAGE_2]
		,NULL AS [IMAGE_3]
		,[M].[LAST_UPDATED]
		,[M].[LAST_UPDATED_BY]
		,[M].[IS_CAR]
		,CASE	WHEN [M].[IS_CAR] = 1 THEN 'SI'
				ELSE 'NO'
			END [IS_CAR_DESCRIPTION]
		,[M].[MT3]
		,[M].[BATCH_REQUESTED]
		,CASE	WHEN [M].[BATCH_REQUESTED] = 1 THEN 'SI'
				ELSE 'NO'
			END [BATCH_REQUESTED_DESCRIPTION]
		,[M].[SERIAL_NUMBER_REQUESTS]
		,CASE	WHEN [M].[SERIAL_NUMBER_REQUESTS] = 1
				THEN 'SI'
				ELSE 'NO'
			END [SERIAL_NUMBER_REQUESTS_DESCRIPTION]
		,CASE	WHEN [MM].[QTY_MEASURE] IS NULL THEN 0
				ELSE [MM].[QTY_MEASURE]
			END [QTY_MEASURE]
		,[M].[IS_MASTER_PACK]
		,CASE	WHEN [M].[IS_MASTER_PACK] = 1 THEN 'SI'
				ELSE 'NO'
			END [IS_MASTER_PACK_DESCRIPTION]
		,[M].[ERP_AVERAGE_PRICE]
		,[M].[WEIGHT_MEASUREMENT]
		,[M].[EXPLODE_IN_RECEPTION]
		,CASE	WHEN [M].[EXPLODE_IN_RECEPTION] = 1
				THEN 'SI'
				ELSE 'NO'
			END [EXPLODE_IN_RECEPTION_DESCRIPTION]
		,CASE	WHEN [M].[QUALITY_CONTROL] = 1 THEN 'SI'
				ELSE 'NO'
			END [QUALITY_CONTROL]
		,CASE	WHEN [M].[HANDLE_CORRELATIVE_SERIALS] = 1
				THEN 'SI'
				ELSE 'NO'
			END [HANDLE_CORRELATIVE_SERIALS]
		,[M].[PREFIX_CORRELATIVE_SERIALS]
		,[M].[SUPPLIER]
		,[M].[NAME_SUPPLIER]
		,[M].[LEAD_TIME]
		,[CL].[CLIENT_NAME]
	FROM
		[wms].[OP_WMS_MATERIALS] [M]
		INNER JOIN [wms].OP_WMS_VIEW_CLIENTS CL ON M.CLIENT_OWNER=CL.CLIENT_CODE
	LEFT JOIN (SELECT
					[MM].[MATERIAL_ID]
					,COUNT([MM].[MATERIAL_ID]) [QTY_MEASURE]
				FROM
					[wms].[OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL] [MM]
				GROUP BY
					[MM].[MATERIAL_ID]) [MM] ON [MM].[MATERIAL_ID] = [M].[MATERIAL_ID]
	LEFT JOIN [wms].[OP_WMS_CLASS] [C] ON [M].[MATERIAL_CLASS] = [C].[CLASS_ID]
	LEFT JOIN [wms].[OP_WMS_SUB_CLASS] [SC] ON [M].[MATERIAL_SUB_CLASS] = [SC].[SUB_CLASS_ID]
	WHERE
		UPPER([M].[MATERIAL_ID]) LIKE '%' + @MATERIAL_ID
		+ '%'
		OR UPPER([M].[MATERIAL_NAME]) LIKE '%'
		+ @MATERIAL_NAME + '%'
		OR UPPER([M].[SHORT_NAME]) LIKE '%' + @SHORT_NAME
		+ '%'
	) AS T
	ORDER BY
		[MATERIAL_ID]
		,[MATERIAL_NAME]
		,[SHORT_NAME];
END;