-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	03-Nov-16 @ A-TEAM Sprint 4
-- Description:			SP que agrega inventario sin transaccion

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_ADD_INVENTORY]
					@SERIAL_NUMBER = NULL
					,@WAREHOUSE = 'C001'
					,@LOCATION = 'C001'
					,@SKU = '100002'
					,@SKU_DESCRIPTION = 'DU CB AL AA 1SB X 120CS 12SW HLLY'
					,@ON_HAND = 10
					,@BATCH_ID = NULL
					,@LAST_UPDATE_BY = 'GERENTE@SONDA'
					,@TXN_ID = NULL
					,@IS_SCANNED = 0
					,@PALLET_ID = NULL
				-- 
				SELECT * 
				FROM [SONDA].[SWIFT_INVENTORY] 
				WHERE WAREHOUSE = 'C001' 
					AND LOCATION = 'C001'
					AND SKU = '100002'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_ADD_INVENTORY](
	@SERIAL_NUMBER VARCHAR(150) = NULL
	,@WAREHOUSE VARCHAR(50)
	,@LOCATION VARCHAR(50)
	,@SKU VARCHAR(50)
	,@SKU_DESCRIPTION VARCHAR(max)
	,@ON_HAND float
	,@BATCH_ID VARCHAR(150) = NULL
	,@LAST_UPDATE_BY VARCHAR
	,@TXN_ID INT = NULL
	,@IS_SCANNED INT
	,@PALLET_ID INT = NULL
)
AS
BEGIN
	BEGIN TRY
		DECLARE @ID INT
		--
		MERGE [SONDA].[SWIFT_INVENTORY] [SI]
		USING (
			SELECT
				@SERIAL_NUMBER SERIAL_NUMBER
				,@WAREHOUSE WAREHOUSE
				,@LOCATION LOCATION
				,@SKU SKU
				,@BATCH_ID BATCH_ID
				,@PALLET_ID PALLET_ID
		) [I]
		ON (
			ISNULL([SI].[SERIAL_NUMBER],'NOSERIE') = ISNULL([I].[SERIAL_NUMBER],'NOSERIE')
			AND [SI].[WAREHOUSE] = [I].[WAREHOUSE]
			AND [SI].[LOCATION] = [I].[LOCATION]
			AND [SI].[SKU] = [I].[SKU]
			AND ISNULL([SI].[BATCH_ID],'NOBATCH') = ISNULL([I].[BATCH_ID],'NOBATCH')
			AND ISNULL([SI].[PALLET_ID],0) = ISNULL([I].[PALLET_ID],0)
		)
		WHEN MATCHED THEN 
			UPDATE SET
				[SI].[SKU_DESCRIPTION] = @SKU_DESCRIPTION
				,[SI].[ON_HAND] = ([SI].[ON_HAND] + @ON_HAND)
				,[SI].[LAST_UPDATE] = GETDATE()
				,[SI].[LAST_UPDATE_BY] = @LAST_UPDATE_BY
				,[SI].[TXN_ID] = @TXN_ID
				,[SI].[IS_SCANNED] = @IS_SCANNED
				,[SI].[RELOCATED_DATE] = GETDATE()
		WHEN NOT MATCHED THEN
			INSERT 
				(
					[SERIAL_NUMBER]
					,[WAREHOUSE]
					,[LOCATION]
					,[SKU]
					,[SKU_DESCRIPTION]
					,[ON_HAND]
					,[BATCH_ID]
					,[LAST_UPDATE]
					,[LAST_UPDATE_BY]
					,[TXN_ID]
					,[IS_SCANNED]
					,[RELOCATED_DATE]
					,[PALLET_ID]
				)
		VALUES
				(
					@SERIAL_NUMBER
					,@WAREHOUSE
					,@LOCATION
					,@SKU
					,@SKU_DESCRIPTION
					,@ON_HAND
					,@BATCH_ID
					,GETDATE()
					,@LAST_UPDATE_BY 
					,@TXN_ID
					,@IS_SCANNED
					,GETDATE() 
					,@PALLET_ID
				);
		--
		SET @ID = SCOPE_IDENTITY()
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, CAST(@ID AS VARCHAR) DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,ERROR_MESSAGE() Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
