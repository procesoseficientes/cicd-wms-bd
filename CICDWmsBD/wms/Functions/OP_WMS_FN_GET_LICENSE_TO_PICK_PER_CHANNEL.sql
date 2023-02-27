﻿--================================================================
--Autor:				Elder Lucas
--Fecha de creación:	30 de septiembre 2022
--Descripción:			Función que devuelve las licencias a utilizar para crear una orden de venta por canal

--Modificación:				Elder Lucas
--Fecha de modificación:	2 de octubre 2022
--Descripción:				Manejo de producto sin batch, corección de ciclo por cantidad total de inventario insuficiente

/*
	EJEMPLO DE EJECUCIÓN

	SELECT * FROM [wms].[OP_WMS_FN_GET_LICENSE_TO_PICK_PER_CHANNEL](
		'ALZA/2107'
			,'BODEGA_SPS'
			, 55
			, 1
			,'BUEN-ESTADO'
			, 20
			,20
	)
		
*/
--================================================================
CREATE FUNCTION [wms].[OP_WMS_FN_GET_LICENSE_TO_PICK_PER_CHANNEL](
	@MATERIAL_ID VARCHAR(50)
	,@WAREHOUSE VARCHAR(20)
	,@QTY_REQUIRED NUMERIC(18,6)
	,@HAVE_BATCH INT = 0
	,@STATUS_CODE VARCHAR(20)
	,@TOLERANCIA INT
	,@TECHO NUMERIC(18,6) = 0
)
RETURNS  @PROCESSED_LICENSES TABLE
(
	 CURRENT_LOCATION VARCHAR(25)
	,CURRENT_WAREHOUSE VARCHAR(25)
	,LICENSE_ID INT
	,CODIGO_POLIZA VARCHAR(25)
	,QTY NUMERIC(18,6)
	,FECHA_DOCUMENTO DATETIME
	,ALLOW_FAST_PICKING INT
)
AS
BEGIN
	DECLARE @TAKEN_LICENSES TABLE
(
	LICENSE_ID INT
)

DECLARE @AVAILABLE_LICENSES TABLE
(
	 CURRENT_LOCATION VARCHAR(25)
	,CURRENT_WAREHOUSE VARCHAR(25)
	,LICENSE_ID INT
	,CODIGO_POLIZA VARCHAR(25)
	,QTY NUMERIC(18,6)
	,FECHA_DOCUMENTO DATETIME
	,ALLOW_FAST_PICKING INT
	,DATE_EXPIRATION DATETIME
	,CREATED_DATE DATETIME
	,FOR_FORKLIFT INT
)

DECLARE 
	 @CURRENT_LOCATION VARCHAR(25)
	,@CURRENT_WAREHOUSE VARCHAR(25)
	,@LICENSE_ID INT
	,@CODIGO_POLIZA VARCHAR(25)
	,@QTY NUMERIC(18,6)
	,@FECHA_DOCUMENTO DATETIME
	,@ALLOW_FAST_PICKING INT
	,@FOR_FORKLIFT INT
	,@POSITION INT = 0
	,@INSUFFICIENT_FLOOR_QTY INT = 0
	,@ROOF_QTY_REACHED INT = 0

--Obtenemos propiedades del material

SELECT
	@HAVE_BATCH = M.BATCH_REQUESTED,
	@TECHO = M.ROOF_QUANTITY
FROM WMS.OP_WMS_MATERIALS M
WHERE MATERIAL_ID = @MATERIAL_ID

INSERT INTO @AVAILABLE_LICENSES
SELECT	 VPAGB.CURRENT_LOCATION
		,VPAGB.CURRENT_WAREHOUSE 
		,VPAGB.LICENSE_ID
		,VPAGB.CODIGO_POLIZA 
		,VPAGB.QTY
		,VPAGB.FECHA_DOCUMENTO
		,VPAGB.ALLOW_FAST_PICKING
		,VPAGB.DATE_EXPIRATION
		,VPAGB.CREATED_DATE
		,SS.FOR_FORKLIFT
FROM WMS.OP_WMS_VIEW_PICKING_AVAILABLE_GENERAL_BATCH VPAGB
INNER JOIN WMS.OP_WMS_SHELF_SPOTS SS ON VPAGB.CURRENT_LOCATION = SS.LOCATION_SPOT
WHERE CURRENT_WAREHOUSE = @WAREHOUSE AND MATERIAL_ID = @MATERIAL_ID
	AND STATUS_CODE = @STATUS_CODE AND LICENSE_ID <> -1
	AND CAST(DATEADD(DAY, @TOLERANCIA, GETDATE()) AS DATE) < DATE_EXPIRATION
	AND VPAGB.QTY > 0

	INSERT INTO @AVAILABLE_LICENSES
SELECT	 VPAG.CURRENT_LOCATION
		,VPAG.CURRENT_WAREHOUSE 
		,VPAG.LICENSE_ID
		,VPAG.CODIGO_POLIZA 
		,VPAG.QTY
		,VPAG.FECHA_DOCUMENTO
		,VPAG.ALLOW_FAST_PICKING
		,NULL
		,VPAG.CREATED_DATE
		,SS.FOR_FORKLIFT
FROM WMS.OP_WMS_VIEW_PICKING_AVAILABLE_GENERAL VPAG
INNER JOIN WMS.OP_WMS_SHELF_SPOTS SS ON VPAG.CURRENT_LOCATION = SS.LOCATION_SPOT
WHERE CURRENT_WAREHOUSE = @WAREHOUSE AND MATERIAL_ID = @MATERIAL_ID
	AND STATUS_CODE = @STATUS_CODE AND LICENSE_ID <> -1
	AND VPAG.QTY > 0
	AND VPAG.BATCH_REQUESTED = 0

IF NOT EXISTS(SELECT TOP 1 1 FROM @AVAILABLE_LICENSES WHERE FOR_FORKLIFT = 0) SET @INSUFFICIENT_FLOOR_QTY = 1	
IF (@QTY_REQUIRED >= @TECHO) SET @ROOF_QTY_REACHED = 1

--Declaramos cursor con la información de las licencias que no venceran en los próximos 20 días y sus ubicaciones
DECLARE AVAILABLE_LICENSES CURSOR SCROLL FOR 
SELECT
	 CURRENT_LOCATION
	,CURRENT_WAREHOUSE
	,LICENSE_ID
	,CODIGO_POLIZA
	,QTY
	,FECHA_DOCUMENTO
	,ALLOW_FAST_PICKING
	,FOR_FORKLIFT
FROM @AVAILABLE_LICENSES
ORDER BY FOR_FORKLIFT DESC, DATE_EXPIRATION, CREATED_DATE

--Abrimos cursor
OPEN AVAILABLE_LICENSES 
FETCH AVAILABLE_LICENSES INTO @CURRENT_LOCATION, @CURRENT_WAREHOUSE, @LICENSE_ID, @CODIGO_POLIZA, @QTY, @FECHA_DOCUMENTO, @ALLOW_FAST_PICKING, @FOR_FORKLIFT;
WHILE(@@FETCH_STATUS = 0 AND @QTY_REQUIRED > 0) --Validamos que se haya hecho el scroll correctamente y que la cantidad necesaria aún sea mayor a 0
BEGIN
	SET @POSITION = @POSITION + 1 --indica en que posición del cursor estamos
	IF((@QTY_REQUIRED - @QTY) >= 0 AND ISNULL(@FOR_FORKLIFT, 0) = 1 AND ISNULL((SELECT TOP 1 1 FROM @TAKEN_LICENSES WHERE LICENSE_ID = @LICENSE_ID), 0) = 0 AND @ROOF_QTY_REACHED = 1)
	BEGIN
		INSERT INTO @TAKEN_LICENSES(LICENSE_ID) VALUES(@LICENSE_ID)

		SELECT @QTY_REQUIRED = @QTY_REQUIRED - @QTY
		INSERT INTO @PROCESSED_LICENSES(CURRENT_LOCATION, CURRENT_WAREHOUSE, LICENSE_ID, CODIGO_POLIZA, QTY, FECHA_DOCUMENTO, ALLOW_FAST_PICKING)
		VALUES (@CURRENT_LOCATION, @CURRENT_WAREHOUSE, @LICENSE_ID, @CODIGO_POLIZA, @QTY, @FECHA_DOCUMENTO, @ALLOW_FAST_PICKING)
	END
	ELSE IF (@INSUFFICIENT_FLOOR_QTY = 1 AND ISNULL(@FOR_FORKLIFT, 0) = 1 AND ISNULL((SELECT TOP 1 1 FROM @TAKEN_LICENSES WHERE LICENSE_ID = @LICENSE_ID), 0) = 0)
	BEGIN
		IF(@QTY >= @QTY_REQUIRED)
			BEGIN
				INSERT INTO @TAKEN_LICENSES(LICENSE_ID) VALUES(@LICENSE_ID)

				SELECT @QTY = @QTY_REQUIRED
				SELECT @QTY_REQUIRED = @QTY_REQUIRED - @QTY
				INSERT INTO @PROCESSED_LICENSES(CURRENT_LOCATION, CURRENT_WAREHOUSE, LICENSE_ID, CODIGO_POLIZA, QTY, FECHA_DOCUMENTO, ALLOW_FAST_PICKING)
				VALUES (@CURRENT_LOCATION, @CURRENT_WAREHOUSE, @LICENSE_ID, @CODIGO_POLIZA, @QTY, @FECHA_DOCUMENTO, @ALLOW_FAST_PICKING)
			END
			ELSE
			BEGIN
				INSERT INTO @TAKEN_LICENSES(LICENSE_ID) VALUES(@LICENSE_ID)

				SELECT @QTY_REQUIRED = @QTY_REQUIRED - @QTY
				INSERT INTO @PROCESSED_LICENSES(CURRENT_LOCATION, CURRENT_WAREHOUSE, LICENSE_ID, CODIGO_POLIZA, QTY, FECHA_DOCUMENTO, ALLOW_FAST_PICKING)
				VALUES (@CURRENT_LOCATION, @CURRENT_WAREHOUSE, @LICENSE_ID, @CODIGO_POLIZA, @QTY, @FECHA_DOCUMENTO, @ALLOW_FAST_PICKING)
			END
	END
	ELSE
	BEGIN
		IF(ISNULL(@FOR_FORKLIFT, 0) = 0 AND ISNULL((SELECT TOP 1 1 FROM @TAKEN_LICENSES WHERE LICENSE_ID = @LICENSE_ID), 0) = 0)
		BEGIN
			IF(@QTY >= @QTY_REQUIRED)
			BEGIN
				INSERT INTO @TAKEN_LICENSES(LICENSE_ID) VALUES(@LICENSE_ID)

				SELECT @QTY = @QTY_REQUIRED
				SELECT @QTY_REQUIRED = @QTY_REQUIRED - @QTY
				INSERT INTO @PROCESSED_LICENSES(CURRENT_LOCATION, CURRENT_WAREHOUSE, LICENSE_ID, CODIGO_POLIZA, QTY, FECHA_DOCUMENTO, ALLOW_FAST_PICKING)
				VALUES (@CURRENT_LOCATION, @CURRENT_WAREHOUSE, @LICENSE_ID, @CODIGO_POLIZA, @QTY, @FECHA_DOCUMENTO, @ALLOW_FAST_PICKING)
			END
			ELSE
			BEGIN
				INSERT INTO @TAKEN_LICENSES(LICENSE_ID) VALUES(@LICENSE_ID)

				SELECT @QTY_REQUIRED = @QTY_REQUIRED - @QTY
				INSERT INTO @PROCESSED_LICENSES(CURRENT_LOCATION, CURRENT_WAREHOUSE, LICENSE_ID, CODIGO_POLIZA, QTY, FECHA_DOCUMENTO, ALLOW_FAST_PICKING)
				VALUES (@CURRENT_LOCATION, @CURRENT_WAREHOUSE, @LICENSE_ID, @CODIGO_POLIZA, @QTY, @FECHA_DOCUMENTO, @ALLOW_FAST_PICKING)
			END
			
		END
	END
	
	FETCH NEXT FROM AVAILABLE_LICENSES INTO @CURRENT_LOCATION, @CURRENT_WAREHOUSE, @LICENSE_ID, @CODIGO_POLIZA, @QTY, @FECHA_DOCUMENTO, @ALLOW_FAST_PICKING, @FOR_FORKLIFT;
	IF((@@CURSOR_ROWS = @POSITION AND @QTY_REQUIRED != 0) AND ((SELECT COUNT(*) FROM @AVAILABLE_LICENSES) != (SELECT COUNT(*) FROM @TAKEN_LICENSES)))
	BEGIN 
		SELECT @POSITION = 0, @INSUFFICIENT_FLOOR_QTY = 1
	FETCH FIRST FROM AVAILABLE_LICENSES INTO @CURRENT_LOCATION, @CURRENT_WAREHOUSE, @LICENSE_ID, @CODIGO_POLIZA, @QTY, @FECHA_DOCUMENTO, @ALLOW_FAST_PICKING, @FOR_FORKLIFT;
	END
END
CLOSE AVAILABLE_LICENSES
DEALLOCATE AVAILABLE_LICENSES
RETURN
END