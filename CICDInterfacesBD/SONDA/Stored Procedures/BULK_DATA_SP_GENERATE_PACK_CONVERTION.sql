-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	04-Nov-16 @ A-TEAM Sprint 4 
-- Description:			SP que genera la unidad de medidad y las conversiones

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[BULK_DATA_SP_GENERATE_PACK_CONVERTION]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[BULK_DATA_SP_GENERATE_PACK_CONVERTION]
AS
BEGIN
	SET NOCOUNT ON;
	
	-- ------------------------------------------------------------------------------------
	-- Agrega la unidad de medida manual en caso no la tenga
	-- ------------------------------------------------------------------------------------
	MERGE [SWIFT_EXPRESS].[SONDA].[SONDA_PACK_UNIT] AS [SPU]
	USING
		(
			SELECT
				'Manual' [CODE_PACK_UNIT]
		) AS [EPU]
	ON [SPU].[CODE_PACK_UNIT] COLLATE DATABASE_DEFAULT = [EPU].[CODE_PACK_UNIT]
	WHEN MATCHED THEN
		UPDATE SET
				[DESCRIPTION_PACK_UNIT] = 'Manual'
				,[LAST_UPDATE] = GETDATE()
				,[LAST_UPDATE_BY] = 'BULK_DATA'
				,[UM_ENTRY] = -1
	WHEN NOT MATCHED THEN
		INSERT
				(
					[CODE_PACK_UNIT]
					,[DESCRIPTION_PACK_UNIT]
					,[LAST_UPDATE]
					,[LAST_UPDATE_BY]
					,[UM_ENTRY]
				)
		VALUES	(
					'Manual'
					,'Manual'
					,GETDATE()
					,'BULK_DATA'
					,-1
				);

	-- ------------------------------------------------------------------------------------
	--	Genera las unidades de medida
	-- ------------------------------------------------------------------------------------
	MERGE [SWIFT_EXPRESS].[SONDA].[SONDA_PACK_CONVERSION] AS [TRG]
	USING
		(
			SELECT
				[epc].[CODE_SKU]
				,'Manual' [CODE_PACK_UNIT_FROM]
				,'Manual' [CODE_PACK_UNIT_TO]
				,1 [CONVERSION_FACTOR]
				,GETDATE() [LAST_UPDATE]
				,'BULK_DATA' [LAST_UPDATE_BY]
				,1 [ORDER]
			FROM [SWIFT_EXPRESS].[SONDA].[SWIFT_VIEW_ALL_SKU] [epc]
		) AS [SRC]
	ON [TRG].[CODE_SKU] COLLATE DATABASE_DEFAULT = [SRC].[CODE_SKU]
		AND [TRG].[CODE_PACK_UNIT_FROM] COLLATE DATABASE_DEFAULT = [SRC].[CODE_PACK_UNIT_FROM]
		AND [TRG].[CODE_PACK_UNIT_TO] COLLATE DATABASE_DEFAULT = [SRC].[CODE_PACK_UNIT_TO]
	WHEN MATCHED THEN
		UPDATE SET
				[CONVERSION_FACTOR] = [SRC].[CONVERSION_FACTOR]
				,[LAST_UPDATE] = [SRC].[LAST_UPDATE]
				,[LAST_UPDATE_BY] = [SRC].[LAST_UPDATE_BY]
				,[ORDER] = [SRC].[ORDER]
	WHEN NOT MATCHED THEN
		INSERT
				(
					[CODE_SKU]
					,[CODE_PACK_UNIT_FROM]
					,[CODE_PACK_UNIT_TO]
					,[CONVERSION_FACTOR]
					,[LAST_UPDATE]
					,[LAST_UPDATE_BY]
					,[ORDER]
				)
		VALUES	(
					[SRC].[CODE_SKU]
					,[SRC].[CODE_PACK_UNIT_FROM]
					,[SRC].[CODE_PACK_UNIT_TO]
					,[SRC].[CONVERSION_FACTOR]
					,[SRC].[LAST_UPDATE]
					,[SRC].[LAST_UPDATE_BY]
					,[SRC].[ORDER]
				);
	
END