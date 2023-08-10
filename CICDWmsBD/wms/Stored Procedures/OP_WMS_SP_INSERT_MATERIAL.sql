-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	10/3/2017 @ NEXUS-Team Sprint ewms
-- Description:			inserta un material en la tabla OP_WMS_MATERIALS
--
-- Modification:		marvin.garcia
-- Fecha de Mod:		5/28/2018 @ A-Team Sprint Dinosaurio
-- Description:			se agrego el campo QUALITY_CONTROL

-- Autor:					marvin.solares
-- Fecha de Creacion: 		20180816 GForce@Humano 
-- Description:			    se agregan columnas HANDLE_CORRELATIVE_SERIALS Y PREFIX_CORRELATIVE_SERIALS

-- Autor:				henry.rodriguez
-- Fecha de creacion:	26-Jun-2019 G-Force@Cancun-Swift3pl
-- Descripcion:			Se agrego campos LEAD_TIME, SUPPLIER, NAME_SUPPLIER

-- Autor:				kevin.guerra
-- Fecha de creacion:	24-03-2020 G-Force@B
-- Descripcion:			Se agrega el campo MATERIAL_SUB_CLASS

-- Autor:				Juan Jose Elgueta
-- Fecha de creacion:	02-07-2020 
-- Descripcion:			Se agrega el campo EXPIRATION_TOLERANCE

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_INSERT_MATERIAL]
				-- 
				SELECT * FROM [wms].[OP_WMS_MATERIALS] 
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_INSERT_MATERIAL] (
		@CLIENT_OWNER VARCHAR(25)
		,@MATERIAL_ID VARCHAR(50)
		,@BARCODE_ID VARCHAR(25)
		,@ALTERNATE_BARCODE VARCHAR(25)
		,@MATERIAL_NAME VARCHAR(200)
		,@SHORT_NAME VARCHAR(200)
		,@VOLUME_FACTOR DECIMAL(18, 4)
		,@MATERIAL_CLASS VARCHAR(25)
		,@MATERIAL_SUB_CLASS VARCHAR(25)
		,@HIGH NUMERIC(18, 3)
		,@LENGTH NUMERIC(18, 3)
		,@WIDTH NUMERIC(18, 3)
		,@MAX_X_BIN INT
		,@SCAN_BY_ONE INT
		,@REQUIRES_LOGISTICS_INFO INT
		,@WEIGTH DECIMAL(18, 6)
		,@LOGIN VARCHAR(50)
		,@IS_CAR INT
		,@MT3 NUMERIC(18, 2)
		,@BATCH_REQUESTED INT
		,@SERIAL_NUMBER_REQUESTS INT
		,@IS_MASTER_PACK INT
		,@ERP_AVERAGE_PRICE NUMERIC(18, 6)
		,@WEIGHT_MEASUREMENT VARCHAR(50)
		,@EXPLODE_IN_RECEPTION INT
		,@HANDLE_TONE INT
		,@HANDLE_CALIBER INT
		,@USE_PICKING_LINE INT
		,@QUALITY_CONTROL INT
		,@PREFIX_CORRELATIVE_SERIALS VARCHAR(20)
		,@HANDLE_CORRELATIVE_SERIALS INT
		,@LEAD_TIME INT
		,@SUPPLIER VARCHAR(64)
		,@NAME_SUPPLIER VARCHAR(250)
		,@EXPIRATION_TOLERANCE INT
		,@ROOF_QUANTITY NUMERIC(18, 6)
		,@ALLOW_DECIMAL_VALUE INT
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		DECLARE	@ID INT;
		--
		INSERT	INTO [wms].[OP_WMS_MATERIALS]
				(
					[CLIENT_OWNER]
					,[MATERIAL_ID]
					,[BARCODE_ID]
					,[ALTERNATE_BARCODE]
					,[MATERIAL_NAME]
					,[SHORT_NAME]
					,[VOLUME_FACTOR]
					,[MATERIAL_CLASS]
					,[MATERIAL_SUB_CLASS]
					,[HIGH]
					,[LENGTH]
					,[WIDTH]
					,[MAX_X_BIN]
					,[SCAN_BY_ONE]
					,[REQUIRES_LOGISTICS_INFO]
					,[WEIGTH]
					,[LAST_UPDATED]
					,[LAST_UPDATED_BY]
					,[IS_CAR]
					,[MT3]
					,[BATCH_REQUESTED]
					,[SERIAL_NUMBER_REQUESTS]
					,[IS_MASTER_PACK]
					,[WEIGHT_MEASUREMENT]
					,[EXPLODE_IN_RECEPTION]
					,[HANDLE_TONE]
					,[HANDLE_CALIBER]
					,[USE_PICKING_LINE]
					,[QUALITY_CONTROL]
					,[PREFIX_CORRELATIVE_SERIALS]
					,[HANDLE_CORRELATIVE_SERIALS]
					,[LEAD_TIME]
					,[SUPPLIER]
					,[NAME_SUPPLIER]
					,[EXPIRATION_TOLERANCE]
					,[ROOF_QUANTITY]
					,[ALLOW_DECIMAL_VALUE]
				)
		VALUES
				(
					@CLIENT_OWNER
					, -- CLIENT_OWNER - varchar(25)
					@CLIENT_OWNER + '/' + @MATERIAL_ID
					, -- MATERIAL_ID - varchar(50)
					@BARCODE_ID
					, -- BARCODE_ID - varchar(25)
					@ALTERNATE_BARCODE
					, -- ALTERNATE_BARCODE - varchar(25)
					@MATERIAL_NAME
					, -- MATERIAL_NAME - varchar(200)
					@SHORT_NAME
					, -- SHORT_NAME - varchar(200)
					@VOLUME_FACTOR
					, -- VOLUME_FACTOR - decimal
					@MATERIAL_CLASS
					, -- MATERIAL_CLASS - varchar(25)
					@MATERIAL_SUB_CLASS
					, -- MATERIAL_SUB_CLASS - varchar(25)
					@HIGH
					, -- HIGH - numeric
					@LENGTH
					, -- LENGTH - numeric
					@WIDTH
					, -- WIDTH - numeric
					@MAX_X_BIN
					, -- MAX_X_BIN - numeric
					@SCAN_BY_ONE
					, -- SCAN_BY_ONE - numeric
					@REQUIRES_LOGISTICS_INFO
					, -- REQUIRES_LOGISTICS_INFO - numeric
					@WEIGTH
					, -- WEIGTH - decimal
					GETDATE()
					, -- LAST_UPDATED - datetime
					@LOGIN
					, -- LAST_UPDATED_BY - varchar(25)
					@IS_CAR
					, -- IS_CAR - numeric
					@MT3
					, -- MT3 - numeric
					@BATCH_REQUESTED
					, -- BATCH_REQUESTED - numeric
					@SERIAL_NUMBER_REQUESTS
					, -- SERIAL_NUMBER_REQUESTS - numeric
					@IS_MASTER_PACK
					, -- IS_MASTER_PACK - int
					@WEIGHT_MEASUREMENT
					, -- WEIGHT_MEASUREMENT - varchar(50)
					@EXPLODE_IN_RECEPTION
					, -- EXPLODE_IN_RECEPTION - int
					@HANDLE_TONE
					, -- HANDLE_TONE - int
					@HANDLE_CALIBER
					, -- HANDLE_CALIBER - int
					@USE_PICKING_LINE
					,  -- USE_PICKING_LINE - int
					@QUALITY_CONTROL
					,  -- QUALITY_CONTROL - int
					@PREFIX_CORRELATIVE_SERIALS
					, -- PREFIX_CORRELATIVE_SERIALS varchar(20)
					@HANDLE_CORRELATIVE_SERIALS
					,-- HANDLE_CORRELATIVE_SERIALS int
					@LEAD_TIME
					,-- LEAD_TIME INT
					@SUPPLIER	-- SUPPLIER VARCHAR(64)
					,@NAME_SUPPLIER -- NAME_SUPPLIER VARCHAR(250)
					,@EXPIRATION_TOLERANCE -- TOLERANCE_DAYS_EXPIRATION INT 
					,@ROOF_QUANTITY -- ROOF_QUANTITY NUMERIC(18, 6)
					,@ALLOW_DECIMAL_VALUE -- ALLOW_DECIMAL_VALUE INT 
					
				);
		--
		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,CAST(@MATERIAL_ID AS VARCHAR) [DbData];
	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,CASE CAST(@@ERROR AS VARCHAR)
				WHEN '2627' THEN ''
				ELSE ERROR_MESSAGE()
				END [Mensaje]
			,@@ERROR [Codigo]; 
	END CATCH;
END;