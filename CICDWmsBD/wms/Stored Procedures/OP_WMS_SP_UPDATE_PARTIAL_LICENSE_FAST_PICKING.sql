-- =============================================
-- Autor:				marvin.solares
-- Fecha de Creacion: 	20180921 GForce@Kiwi
-- Description:			SP que mueve la licencia creada en reubicacion parcial a una licencia de la ubicacion cuando la ubicacion es de fast picking

-- Autor:	        marvin.solares
-- Fecha de Creacion: 	20181810 GForce@Mamba
-- Description:		Se modifica para que el merge inserte correctamente el codigo de barras cuando es ubicacion fast picking

-- Autor:				henry.rodriguez
-- Fecha de Creacion: 	11-Julio-2019 GForce@Dublin
-- Description:			Se agregaron los campos IDLE y PROJECT_ID, para que actualizara los campos en inv_x_license .

-- Autor:				marvin.solares
-- Fecha de Creacion: 	30-Julio-2019 GForce@Dublin
-- Description:			se modifican informacion de licencias reservadas en proyecto cuando es ubicacion de fast picking
/*
-- Ejemplo de Ejecucion:
EXEC [wms].[OP_WMS_SP_UPDATE_PARTIAL_LICENSE_FAST_PICKING] @LOGIN_ID = '', -- varchar(50)
	@LICENSE_ID = 0, -- int
	@LOCATION_ID = '', -- varchar(25)
	@TRANS_TYPE = '', -- varchar(25)
	@TASK_ID = 0, -- int
	@MATERIAL_ID_REALLOC = '', -- varchar(50)
	@QTY_REALLOC = NULL -- numeric
*/
-- =============================================

CREATE PROCEDURE [wms].[OP_WMS_SP_UPDATE_PARTIAL_LICENSE_FAST_PICKING] (
		@LOGIN_ID VARCHAR(50)
		,@LICENSE_ID INT
		,@LOCATION_ID VARCHAR(25)
		,@TRANS_TYPE VARCHAR(25)
		,@MATERIAL_ID_REALLOC VARCHAR(50)
		,@QTY_REALLOC NUMERIC(18, 2)
	)
AS
BEGIN

	DECLARE
		@ORIGIN_LOCATION_LICENSE INT = -1
		,@STATUS_ID_ORIGINAL INT
		,@CLIENT_OWNER VARCHAR(50)
		,@IDLE INT = 0
		,@PROJECT_ID UNIQUEIDENTIFIER = NULL;

	SELECT TOP 1
		@CLIENT_OWNER = [L].[CLIENT_OWNER]
	FROM
		[wms].[OP_WMS_LICENSES] [L]
	WHERE
		[L].[LICENSE_ID] = @LICENSE_ID; 


	-- ------------------------------------------------------------------------------------
	-- buscamos la licencia donde tenemos que trasladar la informacion procesada en la recepcion
	-- ------------------------------------------------------------------------------------
	SELECT TOP 1
		@ORIGIN_LOCATION_LICENSE = [L].[LICENSE_ID]
	FROM
		[wms].[OP_WMS_LICENSES] [L]
	INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [INVL] ON [L].[LICENSE_ID] = [INVL].[LICENSE_ID]
	WHERE
		[L].[CURRENT_LOCATION] = @LOCATION_ID
		AND [L].[STATUS] = 'ALLOCATED'
		AND [L].[LICENSE_ID] <> @LICENSE_ID --EXCLUIMOS DEL SELECT LA LICENCIA CREADA EN LA RECEPCION
		AND [L].[CLIENT_OWNER] = @CLIENT_OWNER
	GROUP BY
		[L].[LICENSE_ID]
	ORDER BY
		SUM([INVL].[QTY]) DESC;

	-- ------------------------------------------------------------------------------------
	-- si no tengo licencias en la ubicacion me salgo del procedimiento
	-- ya que la licencia creada en la recepcion es la que se utilizara para futuras recepciones
	-- ------------------------------------------------------------------------------------
	IF @ORIGIN_LOCATION_LICENSE = -1
	BEGIN
		-- ------------------------------------------------------------------------------------
		-- libero el inventario
		-- ------------------------------------------------------------------------------------
		UPDATE
			[wms].[OP_WMS_INV_X_LICENSE]
		SET	
			[LOCKED_BY_INTERFACES] = 0
		WHERE
			[MATERIAL_ID] = @MATERIAL_ID_REALLOC
			AND [LICENSE_ID] = @LICENSE_ID;
		RETURN;
	END;


	SELECT TOP 1
		@STATUS_ID_ORIGINAL = [STATUS_ID]
		,@IDLE = [IDLE]
		,@PROJECT_ID = [PROJECT_ID]
	FROM
		[wms].[OP_WMS_INV_X_LICENSE]
	WHERE
		[LICENSE_ID] = @LICENSE_ID;

	-- ------------------------------------------------------------------------------------
	-- actualizamos las transacciones y mantenemos las propiedades de batch, tonos, calibres y vin
	-- ------------------------------------------------------------------------------------
	
	UPDATE
		[wms].[OP_WMS_TRANS]
	SET	
		[LICENSE_ID] = @ORIGIN_LOCATION_LICENSE
		,[TARGET_LICENSE] = @ORIGIN_LOCATION_LICENSE
	WHERE
		[LICENSE_ID] = @LICENSE_ID
		AND [MATERIAL_CODE] = @MATERIAL_ID_REALLOC;


	-- ------------------------------------------------------------------------------------
	-- actualizamos las series a la licencia origen
	-- ------------------------------------------------------------------------------------
	UPDATE
		[wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER]
	SET	
		[LICENSE_ID] = @ORIGIN_LOCATION_LICENSE
	WHERE
		[LICENSE_ID] = @LICENSE_ID
		AND [MATERIAL_ID] = @MATERIAL_ID_REALLOC
		AND [STATUS] > 0;

	-- ------------------------------------------------------------------------------------
	-- actualizamos la informacion de master pack
	-- ------------------------------------------------------------------------------------
	-- ------------------------------------------------------------------------------------
	-- obtenemos los materiales de la licencia creada en recepcion que son master pack
	-- ------------------------------------------------------------------------------------
	
	SELECT
		[IL].[MATERIAL_ID]
		,[IL].[QTY]
	INTO
		[#MATERIALS]
	FROM
		[wms].[OP_WMS_INV_X_LICENSE] [IL]
	INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON ([M].[MATERIAL_ID] = [IL].[MATERIAL_ID])
	INNER JOIN [wms].[OP_WMS_MASTER_PACK_HEADER] [MPH] ON [MPH].[LICENSE_ID] = [IL].[LICENSE_ID]
											AND [MPH].[MATERIAL_ID] = [IL].[MATERIAL_ID]
											AND [MPH].[LICENSE_ID] = [IL].[LICENSE_ID]
	WHERE
		[M].[IS_MASTER_PACK] = 1
		AND [IL].[LICENSE_ID] = @LICENSE_ID
		AND [MPH].[EXPLODED] = 0
		AND [IL].[MATERIAL_ID] = @MATERIAL_ID_REALLOC;

	WHILE EXISTS ( SELECT TOP 1
						1
					FROM
						[#MATERIALS] [M] )
	BEGIN
		DECLARE
			@MATERIAL_ID VARCHAR(50)
			,@QTY NUMERIC(18, 4)
			,@BATCH_NEW_LICENCE VARCHAR(50)
			,@DATE_EXPIRATION_NEW_LICENSE DATE
			,@MASTER_PACK_HEADER_ID INT;

		SELECT TOP 1
			@MATERIAL_ID = [MATERIAL_ID]
			,@QTY = [QTY]
		FROM
			[#MATERIALS];

		SELECT TOP 1
			@BATCH_NEW_LICENCE = [BATCH]
			,@DATE_EXPIRATION_NEW_LICENSE = [DATE_EXPIRATION]
		FROM
			[wms].[OP_WMS_INV_X_LICENSE]
		WHERE
			[LICENSE_ID] = @LICENSE_ID
			AND [MATERIAL_ID] = @MATERIAL_ID;

		IF EXISTS ( SELECT TOP 1
						1
					FROM
						[wms].[OP_WMS_MASTER_PACK_HEADER]
					WHERE
						[LICENSE_ID] = @ORIGIN_LOCATION_LICENSE
						AND [MATERIAL_ID] = @MATERIAL_ID
						AND [EXPLODED] = 0 )
		BEGIN
				--si encuentro el material en la licencia existente y no ha sido explotado solo sumo cantidades en el header
			UPDATE
				[wms].[OP_WMS_MASTER_PACK_HEADER]
			SET	
				[QTY] = [QTY] + @QTY
			WHERE
				[LICENSE_ID] = @ORIGIN_LOCATION_LICENSE
				AND [MATERIAL_ID] = @MATERIAL_ID
				AND [EXPLODED] = 0;
				--sobreescribo el batch con el batch de la licencia creada en recepcion cuando aplique
			UPDATE
				[D]
			SET	
				[D].[BATCH] = @BATCH_NEW_LICENCE
				,[D].[DATE_EXPIRATION] = @DATE_EXPIRATION_NEW_LICENSE
			FROM
				[wms].[OP_WMS_MASTER_PACK_DETAIL] [D]
			INNER JOIN [wms].[OP_WMS_MASTER_PACK_HEADER] [H] ON [H].[MASTER_PACK_HEADER_ID] = [D].[MASTER_PACK_HEADER_ID]
											AND [H].[MATERIAL_ID] = @MATERIAL_ID
											AND [H].[EXPLODED] = 0
			WHERE
				[H].[LICENSE_ID] = @ORIGIN_LOCATION_LICENSE;
				
				--elimino las filas usadas pues al momento de actualizar la licencia previa ya no representan nada en el sistema
			SELECT TOP 1
				@MASTER_PACK_HEADER_ID = [MASTER_PACK_HEADER_ID]
			FROM
				[wms].[OP_WMS_MASTER_PACK_HEADER]
			WHERE
				[LICENSE_ID] = @LICENSE_ID
				AND [MATERIAL_ID] = @MATERIAL_ID
				AND [EXPLODED] = 0;

				--primero elimino el detalle y luego el encabezado
			DELETE FROM
				[wms].[OP_WMS_MASTER_PACK_DETAIL]
			WHERE
				[MASTER_PACK_HEADER_ID] = @MASTER_PACK_HEADER_ID;

			DELETE FROM
				[wms].[OP_WMS_MASTER_PACK_HEADER]
			WHERE
				[MASTER_PACK_HEADER_ID] = @MASTER_PACK_HEADER_ID;

		END;
		ELSE
		BEGIN
				--cambiamos el license_id en la fila insertada en masterpackheader por la licencia existente previa 
			UPDATE
				[wms].[OP_WMS_MASTER_PACK_HEADER]
			SET	
				[LICENSE_ID] = @ORIGIN_LOCATION_LICENSE
			WHERE
				[LICENSE_ID] = @LICENSE_ID
				AND [MATERIAL_ID] = @MATERIAL_ID;
		END;

		DELETE FROM
			[#MATERIALS]
		WHERE
			[MATERIAL_ID] = @MATERIAL_ID;

	END;
	-- ------------------------------------------------------------------------------------
	-- actualizamos la informacion de la licencia
	-- ------------------------------------------------------------------------------------
	SELECT
		*
	INTO
		[#INVENTORY_NEW_LICENSE]
	FROM
		[wms].[OP_WMS_INV_X_LICENSE]
	WHERE
		[LICENSE_ID] = @LICENSE_ID
		AND [MATERIAL_ID] = @MATERIAL_ID_REALLOC;--INVENTARIO LICENCIA CREADA EN LA RECEPCION

	WHILE EXISTS ( SELECT TOP 1
						1
					FROM
						[#INVENTORY_NEW_LICENSE] )
	BEGIN
		DECLARE	@MATERIAL_ID_NEW_LICENSE VARCHAR(50);

		SELECT TOP 1
			@MATERIAL_ID_NEW_LICENSE = [MATERIAL_ID]
		FROM
			[#INVENTORY_NEW_LICENSE];

		MERGE [wms].[OP_WMS_INV_X_LICENSE] AS [OLD]
		USING
			(SELECT
					[PK_LINE]
					,[LICENSE_ID]
					,[MATERIAL_ID]
					,[MATERIAL_NAME]
					,[QTY]
					,[VOLUME_FACTOR]
					,[WEIGTH]
					,[SERIAL_NUMBER]
					,[COMMENTS]
					,[LAST_UPDATED]
					,[LAST_UPDATED_BY]
					,[BARCODE_ID]
					,[TERMS_OF_TRADE]
					,[STATUS]
					,[CREATED_DATE]
					,[DATE_EXPIRATION]
					,[BATCH]
					,[ENTERED_QTY]
					,[VIN]
					,[HANDLE_SERIAL]
					,[IS_EXTERNAL_INVENTORY]
					,[IS_BLOCKED]
					,[BLOCKED_STATUS]
					,[STATUS_ID]
					,[TONE_AND_CALIBER_ID]
					,[LOCKED_BY_INTERFACES]
					,[IDLE]
					,[PROJECT_ID]
				FROM
					[#INVENTORY_NEW_LICENSE]
				WHERE
					[MATERIAL_ID] = @MATERIAL_ID_NEW_LICENSE)
			AS [N]
		ON [N].[MATERIAL_ID] = [OLD].[MATERIAL_ID]
			AND [OLD].[LICENSE_ID] = @ORIGIN_LOCATION_LICENSE
		WHEN MATCHED THEN
			UPDATE SET
					[OLD].[QTY] = [OLD].[QTY] + [N].[QTY]
					,[OLD].[ENTERED_QTY] = [OLD].[ENTERED_QTY]
					+ [N].[QTY]
					,[OLD].[BATCH] = [N].[BATCH]
					,[OLD].[TONE_AND_CALIBER_ID] = [N].[TONE_AND_CALIBER_ID]
					,[OLD].[DATE_EXPIRATION] = [N].[DATE_EXPIRATION]
					,[OLD].[LOCKED_BY_INTERFACES] = 0
					,[OLD].[IDLE] = [N].[IDLE]
					,[OLD].[PROJECT_ID] = [N].[PROJECT_ID]
		WHEN NOT MATCHED THEN
			INSERT
					(
						[LICENSE_ID]
						,[MATERIAL_ID]
						,[MATERIAL_NAME]
						,[QTY]
						,[VOLUME_FACTOR]
						,[WEIGTH]
						,[SERIAL_NUMBER]
						,[COMMENTS]
						,[LAST_UPDATED]
						,[LAST_UPDATED_BY]
						,[BARCODE_ID]
						,[TERMS_OF_TRADE]
						,[STATUS]
						,[CREATED_DATE]
						,[DATE_EXPIRATION]
						,[BATCH]
						,[ENTERED_QTY]
						,[VIN]
						,[HANDLE_SERIAL]
						,[IS_EXTERNAL_INVENTORY]
						,[IS_BLOCKED]
						,[BLOCKED_STATUS]
						,[STATUS_ID]
						,[TONE_AND_CALIBER_ID]
						,[LOCKED_BY_INTERFACES]
						,[IDLE]
						,[PROJECT_ID]
					)
			VALUES	(
						@ORIGIN_LOCATION_LICENSE  -- LICENSE_ID - numeric
						,[N].[MATERIAL_ID]
						,[N].[MATERIAL_NAME]
						,[N].[QTY]
						,[N].[VOLUME_FACTOR]
						,[N].[WEIGTH]
						,[N].[SERIAL_NUMBER]
						,[N].[COMMENTS]
						,[N].[LAST_UPDATED]
						,[N].[LAST_UPDATED_BY]
						,[N].[BARCODE_ID]
						,[N].[TERMS_OF_TRADE]
						,[N].[STATUS]
						,[N].[CREATED_DATE]
						,[N].[DATE_EXPIRATION]
						,[N].[BATCH]
						,[N].[ENTERED_QTY]
						,[N].[VIN]
						,[N].[HANDLE_SERIAL]
						,[N].[IS_EXTERNAL_INVENTORY]
						,[N].[IS_BLOCKED]
						,[N].[BLOCKED_STATUS]
						,@STATUS_ID_ORIGINAL
						,[N].[TONE_AND_CALIBER_ID]
						,0
						,@IDLE
						,@PROJECT_ID
					);
		
		-- ------------------------------------------------------------------------------------
		-- aquí modifico la informacion de la licencia creada en recepcion reservada para el proyecto dado que por ser fast picking
		-- estamos asignando el inventario a la licencia original en la ubicación de fast picking
		-- ------------------------------------------------------------------------------------
		IF @PROJECT_ID IS NOT NULL
		BEGIN

			IF EXISTS ( SELECT TOP 1
							1
						FROM
							[wms].[OP_WMS_INVENTORY_RESERVED_BY_PROJECT]
						WHERE
							[PROJECT_ID] = @PROJECT_ID
							AND [MATERIAL_ID] = @MATERIAL_ID_REALLOC
							AND [LICENSE_ID] = @ORIGIN_LOCATION_LICENSE )
			BEGIN
			-- ------------------------------------------------------------------------------------
			-- sumamos la cantidad de reubicacion a la licencia original que ya había sido reservada para el proyecto
			-- y eliminamos la fila original que habíamos insertado en la tabla de inventario reservado dado que al trasladarse a fast picking
			-- se cancela la licencia creada en el proceso
			-- ------------------------------------------------------------------------------------
				UPDATE
					[wms].[OP_WMS_INVENTORY_RESERVED_BY_PROJECT]
				SET	
					[QTY_LICENSE] = [QTY_LICENSE]
					+ @QTY_REALLOC
					,[QTY_RESERVED] = [QTY_RESERVED]
					+ @QTY_REALLOC
				WHERE
					[PROJECT_ID] = @PROJECT_ID
					AND [MATERIAL_ID] = @MATERIAL_ID_REALLOC
					AND [LICENSE_ID] = @ORIGIN_LOCATION_LICENSE;
				
				DELETE
					[wms].[OP_WMS_INVENTORY_RESERVED_BY_PROJECT]
				WHERE
					[MATERIAL_ID] = @MATERIAL_ID_REALLOC
					AND [PROJECT_ID] = @PROJECT_ID
					AND [LICENSE_ID] = @LICENSE_ID;

				DELETE
					[wms].[OP_WMS_LOG_INVENTORY_RESERVED_BY_PROJECT]
				WHERE
					[MATERIAL_ID] = @MATERIAL_ID_REALLOC
					AND [PROJECT_ID] = @PROJECT_ID
					AND [LICENSE_ID] = @LICENSE_ID;

			END;
			ELSE
			BEGIN
				-- ------------------------------------------------------------------------------------
				-- buscamos la licencia creada en el proceso de reubicacion, reemplazamos el license_id por el de la licencia de la ubicacion de fast picking
				-- tanto en el inventario reservado como en el log insertado
				-- ------------------------------------------------------------------------------------
				DECLARE	@PK_LINE_OLD_LICENSE [NUMERIC](18, 0);
				SELECT
					@PK_LINE_OLD_LICENSE = [PK_LINE]
				FROM
					[wms].[OP_WMS_INV_X_LICENSE]
				WHERE
					[LICENSE_ID] = @ORIGIN_LOCATION_LICENSE
					AND [MATERIAL_ID] = @MATERIAL_ID_REALLOC;
				
				UPDATE
					[wms].[OP_WMS_INVENTORY_RESERVED_BY_PROJECT]
				SET	
					[PK_LINE] = @PK_LINE_OLD_LICENSE
					,[LICENSE_ID] = @ORIGIN_LOCATION_LICENSE
				WHERE
					[LICENSE_ID] = @LICENSE_ID
					AND [MATERIAL_ID] = @MATERIAL_ID_REALLOC
					AND [PROJECT_ID] = @PROJECT_ID;

				UPDATE
					[wms].[OP_WMS_LOG_INVENTORY_RESERVED_BY_PROJECT]
				SET	
					[PK_LINE] = @PK_LINE_OLD_LICENSE
					,[LICENSE_ID] = @ORIGIN_LOCATION_LICENSE
				WHERE
					[LICENSE_ID] = @LICENSE_ID
					AND [MATERIAL_ID] = @MATERIAL_ID_REALLOC
					AND [PROJECT_ID] = @PROJECT_ID;

			END; 
		END;

		DELETE FROM
			[#INVENTORY_NEW_LICENSE]
		WHERE
			[MATERIAL_ID] = @MATERIAL_ID_NEW_LICENSE;

	END;

	-- ------------------------------------------------------------------------------------
	-- ELIMINAMOS EL INVENTARIO DE LA LICENCIA CREADA PARA LA REUBICACION
	-- ------------------------------------------------------------------------------------
	UPDATE
		[wms].[OP_WMS_INV_X_LICENSE]
	SET	
		[QTY] = 0
	WHERE
		[LICENSE_ID] = @LICENSE_ID
		AND [MATERIAL_ID] = @MATERIAL_ID_REALLOC;


	-- ------------------------------------------------------------------------------------
	-- no borramos la licencia pero la dejamos fuera de uso
	-- hacemos el update hasta que la licencia quede sin inventario
	-- ------------------------------------------------------------------------------------
	IF (SELECT
			SUM([QTY])
		FROM
			[wms].[OP_WMS_INV_X_LICENSE]
		WHERE
			[LICENSE_ID] = @LICENSE_ID) = 0
	BEGIN
		UPDATE
			[wms].[OP_WMS_LICENSES]
		SET	
			[WAVE_PICKING_ID] = 0
			,[STATUS] = NULL
			,[LAST_UPDATED] = GETDATE()
			,[LAST_LICENSE_USED_IN_FAST_PICKING] = @ORIGIN_LOCATION_LICENSE
			,[LAST_UPDATED_BY] = @LOGIN_ID
		WHERE
			[LICENSE_ID] = @LICENSE_ID;
		
	END;
		
END;