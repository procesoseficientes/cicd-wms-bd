-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	28-Sep-16 @ A-TEAM Sprint 2
-- Description:			Inserta la frecuencia

-- Modificacion 06-Dec-16 @ A-Team Sprint 5
					-- alberto.ruiz
					-- Se agrego que elimine los clientes asociados a las frecuencias de la misma ruta y mismo tipo de tarea

-- Modificacion 16-Dec-16 @ A-Team Sprint 6
					-- alberto.ruiz
					-- Se ajustos asocociacion de clientes a frecuencia

-- Modificacion 16-Jan-17 @ A-Team Sprint Adeben
					-- alberto.ruiz
					-- Se ajusto para que genere la cantidad de frecuencias que tiene asignadas el poligono

-- Modificacion 17-Jul-17 @ Nexus Team Sprint AgeOfEmpires
					-- alberto.ruiz
					-- Se agrego el @POLYGON_ID para la llave de la frecuencia

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_INSERT_FREQUENCY_BY_POLYGON]
					@SUNDAY = 0
					,@MONDAY = 0
					,@TUESDAY = 1
					,@WEDNESDAY = 0
					,@THURSDAY = 0
					,@FRIDAY = 0
					,@SATURDAY = 0
					,@FRECUENCY_WEEKS = 1
					,@LAST_WEEK_VISITED = '20160925'
					,@LAST_UPDATED_BY = 'generente@SONDA'
					,@CODE_ROUTE = 'RUDI@SONDA'
					,@TYPE_TASK = 'PRESALE'
					,@POLYGON_ID = 66
				-- 
				SELECT * FROM [SONDA].[SWIFT_FREQUENCY] WHERE CODE_ROUTE= 'RUDI@SONDA' AND TYPE_TASK = 'PRESALE'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_INSERT_FREQUENCY_BY_POLYGON] (
	@SUNDAY AS INT
	,@MONDAY AS INT
	,@TUESDAY AS INT
	,@WEDNESDAY AS INT
	,@THURSDAY AS INT
	,@FRIDAY AS INT
	,@SATURDAY AS INT
	,@FRECUENCY_WEEKS AS INT
	,@LAST_WEEK_VISITED AS DATE
	,@LAST_UPDATED_BY AS NVARCHAR(25)
	,@CODE_ROUTE AS VARCHAR(50)
	,@TYPE_TASK AS VARCHAR(20) = NULL
	,@POLYGON_ID INT
) AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		DECLARE @ID_FREQUENCY INT
		--
		DECLARE @FREQUENCY TABLE (
			[CODE_FREQUENCY] VARCHAR(50)
			,[SUNDAY] INT
			,[MONDAY] INT
			,[TUESDAY] INT
			,[WEDNESDAY] INT
			,[THURSDAY] INT
			,[FRIDAY] INT
			,[SATURDAY] INT
			,[FREQUENCY_WEEKS] INT
			,[LAST_WEEK_VISITED] DATE
			,[LAST_UPDATED] DATETIME
			,[LAST_UPDATED_BY] VARCHAR(25)
			,[CODE_ROUTE] VARCHAR(50)
			,[TYPE_TASK] VARCHAR(20)
			,[POLYGON_ID] INT
		) 
		--
		DECLARE @FREQUENCY_FOR_CUSTOMER TABLE (
			[ID_FREQUENCY] INT
			,[CODE_FREQUENCY] VARCHAR(50)
			,[TYPE_TASK] VARCHAR(20)
		)
		
		-- ------------------------------------------------------------------------------------
		-- Genera la llave unica de la frecuencia
		-- ------------------------------------------------------------------------------------
		INSERT INTO @FREQUENCY
				(
					[CODE_FREQUENCY]
					,[SUNDAY]
					,[MONDAY]
					,[TUESDAY]
					,[WEDNESDAY]
					,[THURSDAY]
					,[FRIDAY]
					,[SATURDAY]
					,[FREQUENCY_WEEKS]
					,[LAST_WEEK_VISITED]
					,[LAST_UPDATED]
					,[LAST_UPDATED_BY]
					,[CODE_ROUTE]
					,[TYPE_TASK]
					,[POLYGON_ID]
				)
		SELECT
			[TP].[TASK_TYPE] + @CODE_ROUTE
				+ CAST(@SUNDAY AS VARCHAR) + CAST(@MONDAY AS VARCHAR)
				+ CAST(@TUESDAY AS VARCHAR) + CAST(@WEDNESDAY AS VARCHAR)
				+ CAST(@THURSDAY AS VARCHAR) + CAST(@FRIDAY AS VARCHAR)
				+ CAST(@SATURDAY AS VARCHAR) + CAST(@FRECUENCY_WEEKS AS VARCHAR)
				+ CAST(@POLYGON_ID AS VARCHAR) -- CODE_FREQUENCY - varchar(50)
			,@SUNDAY
			,@MONDAY
			,@TUESDAY
			,@WEDNESDAY
			,@THURSDAY
			,@FRIDAY
			,@SATURDAY
			,@FRECUENCY_WEEKS
			,@LAST_WEEK_VISITED
			,GETDATE()  -- LAST_UPDATED - datetime
			,@LAST_UPDATED_BY  -- LAST_UPDATED_BY - varchar(25)
			,@CODE_ROUTE  -- CODE_ROUTE - varchar(50)
			,[TP].[TASK_TYPE]
			,@POLYGON_ID
		FROM [SONDA].[SWIFT_TASK_BY_POLYGON] [TP]
		WHERE [TP].[POLYGON_ID] = @POLYGON_ID
			
		-- ------------------------------------------------------------------------------------
		-- Inserta o actualiza la frecuencia
		-- ------------------------------------------------------------------------------------
		MERGE [SONDA].[SWIFT_FREQUENCY] [F]
		USING
			(
				SELECT
					[FT].[CODE_FREQUENCY]
					,[FT].[SUNDAY]
					,[FT].[MONDAY]
					,[FT].[TUESDAY]
					,[FT].[WEDNESDAY]
					,[FT].[THURSDAY]
					,[FT].[FRIDAY]
					,[FT].[SATURDAY]
					,[FT].[FREQUENCY_WEEKS]
					,[FT].[LAST_WEEK_VISITED]
					,[FT].[LAST_UPDATED]
					,[FT].[LAST_UPDATED_BY]
					,[FT].[CODE_ROUTE]
					,[FT].[TYPE_TASK]
					,[FT].[POLYGON_ID]
				FROM @FREQUENCY [FT]
			) AS [NF]
		ON [F].[CODE_FREQUENCY] = [NF].[CODE_FREQUENCY]
		WHEN MATCHED THEN
			UPDATE SET
						[F].[SUNDAY] = [NF].[SUNDAY]
						,[F].[MONDAY] = [NF].[MONDAY]
						,[F].[TUESDAY] = [NF].[TUESDAY]
						,[F].[WEDNESDAY] = [NF].[WEDNESDAY]
						,[F].[THURSDAY] = [NF].[THURSDAY]
						,[F].[FRIDAY] = [NF].[FRIDAY]
						,[F].[SATURDAY] = [NF].[SATURDAY]
						,[F].[FREQUENCY_WEEKS] = [NF].[FREQUENCY_WEEKS]
						,[F].[LAST_WEEK_VISITED] = [NF].[LAST_WEEK_VISITED]
						,[F].[LAST_UPDATED] = [NF].[LAST_UPDATED]
						,[F].[LAST_UPDATED_BY] = [NF].[LAST_UPDATED_BY]
						,[F].[POLYGON_ID] = [NF].[POLYGON_ID]
		WHEN NOT MATCHED THEN
			INSERT
					(
						[CODE_FREQUENCY]
						,[SUNDAY]
						,[MONDAY]
						,[TUESDAY]
						,[WEDNESDAY]
						,[THURSDAY]
						,[FRIDAY]
						,[SATURDAY]
						,[FREQUENCY_WEEKS]
						,[LAST_WEEK_VISITED]
						,[LAST_UPDATED]
						,[LAST_UPDATED_BY]
						,[CODE_ROUTE]
						,[TYPE_TASK]
						,[POLYGON_ID]
					)
			VALUES	(
						[NF].[CODE_FREQUENCY]
						,[NF].[SUNDAY]
						,[NF].[MONDAY]
						,[NF].[TUESDAY]
						,[NF].[WEDNESDAY]
						,[NF].[THURSDAY]
						,[NF].[FRIDAY]
						,[NF].[SATURDAY]
						,[NF].[FREQUENCY_WEEKS]
						,[NF].[LAST_WEEK_VISITED]
						,[NF].[LAST_UPDATED]
						,[NF].[LAST_UPDATED_BY]
						,[NF].[CODE_ROUTE]
						,[NF].[TYPE_TASK]
						,[NF].[POLYGON_ID]
					);
		-- ------------------------------------------------------------------------------------
		-- Obtiene las frecuencias del poligono
		-- ------------------------------------------------------------------------------------
		INSERT INTO @FREQUENCY_FOR_CUSTOMER
				(
					[ID_FREQUENCY]
					,[CODE_FREQUENCY]
					,[TYPE_TASK]
				)
		SELECT
			[F].ID_FREQUENCY
			,[F].[CODE_FREQUENCY]
			,[F].[TYPE_TASK]
		FROM [SONDA].[SWIFT_FREQUENCY] [F]
		INNER JOIN @FREQUENCY [FT] ON (
			[FT].[CODE_FREQUENCY] = [F].[CODE_FREQUENCY]
		)

		-- ------------------------------------------------------------------------------------
		-- Elimina los clientes del poligono de cualquier frecuencia asociada
		-- ------------------------------------------------------------------------------------
		DELETE [FC]
		FROM [SONDA].[SWIFT_POLYGON_X_CUSTOMER] [PC]
		INNER JOIN [SONDA].[SWIFT_FREQUENCY_X_CUSTOMER] [FC] ON (
			[FC].[CODE_CUSTOMER] = [PC].[CODE_CUSTOMER]
		)
		INNER JOIN [SONDA].[SWIFT_FREQUENCY_BY_POLYGON] [FP] ON (
			[FP].[POLYGON_ID] = [PC].[POLYGON_ID]
			AND [FP].[ID_FREQUENCY] = [FC].[ID_FREQUENCY]
		)
		WHERE [PC].[POLYGON_ID] = @POLYGON_ID

		-- ------------------------------------------------------------------------------------
		-- Establece la relacion entre poligono y frecuencias
		-- ------------------------------------------------------------------------------------
		DELETE FROM [SONDA].[SWIFT_FREQUENCY_BY_POLYGON] WHERE [POLYGON_ID] = @POLYGON_ID
		--
		INSERT INTO [SONDA].[SWIFT_FREQUENCY_BY_POLYGON]
				([POLYGON_ID] 
				,[ID_FREQUENCY])
		SELECT DISTINCT
			@POLYGON_ID
			,[F].[ID_FREQUENCY]
		FROM @FREQUENCY_FOR_CUSTOMER [F]

		-- ------------------------------------------------------------------------------------
		-- Agrega los clientes a la frecuencia
		-- ------------------------------------------------------------------------------------
		INSERT INTO [SONDA].[SWIFT_FREQUENCY_X_CUSTOMER]
		(
			[ID_FREQUENCY]
			,[CODE_CUSTOMER]
			,[PRIORITY]
		)
		SELECT
			[FP].[ID_FREQUENCY]
			,[PC].[CODE_CUSTOMER]
			,1
		FROM [SONDA].[SWIFT_POLYGON_X_CUSTOMER] PC
		INNER JOIN [SONDA].[SWIFT_FREQUENCY_BY_POLYGON] [FP] ON (
			[FP].[POLYGON_ID] = [PC].[POLYGON_ID]
		)
		WHERE [PC].[POLYGON_ID] = @POLYGON_ID

		-- ------------------------------------------------------------------------------------
		-- Agrega propuesta de clientes
		-- ------------------------------------------------------------------------------------
		MERGE [SONDA].[SWIFT_CUSTOMER_FREQUENCY] [CF]
		USING
			(
				SELECT 
					[PC].[POLYGON_ID]						
					,[PC].[CODE_CUSTOMER]						
					,@SUNDAY [SUNDAY]
					,@MONDAY [MONDAY]
					,@TUESDAY [TUESDAY]
					,@WEDNESDAY [WEDNESDAY]
					,@THURSDAY [THURSDAY]
					,@FRIDAY [FRIDAY]
					,@SATURDAY [SATURDAY]
					,@FRECUENCY_WEEKS [FREQUENCY_WEEKS]
				FROM [SONDA].[SWIFT_POLYGON_X_CUSTOMER] PC 
				WHERE [PC].[POLYGON_ID] = @POLYGON_ID
			) [PC]
		ON (
			[CF].[CODE_CUSTOMER] = [PC].[CODE_CUSTOMER]
		)
		WHEN MATCHED THEN
			UPDATE SET
				[CF].[SUNDAY] = [PC].[SUNDAY]
				,[CF].[MONDAY] = [PC].[MONDAY]
				,[CF].[TUESDAY] = [PC].[TUESDAY]
				,[CF].[WEDNESDAY] = [PC].[WEDNESDAY]
				,[CF].[THURSDAY] = [PC].[THURSDAY]
				,[CF].[FRIDAY] = [PC].[FRIDAY]
				,[CF].[SATURDAY] = [PC].[SATURDAY]
				,[CF].[FREQUENCY_WEEKS] = [PC].[FREQUENCY_WEEKS]
				,[CF].[LAST_UPDATED] = GETDATE()
				,[CF].[LAST_UPDATED_BY] = @LAST_UPDATED_BY
		WHEN NOT MATCHED THEN
			INSERT
			(
				[CODE_CUSTOMER]
				,[SUNDAY]
				,[MONDAY]
				,[TUESDAY]
				,[WEDNESDAY]
				,[THURSDAY]
				,[FRIDAY]
				,[SATURDAY]
				,[FREQUENCY_WEEKS]
				,[LAST_DATE_VISITED]
				,[LAST_UPDATED]
				,[LAST_UPDATED_BY]
			)
			VALUES(
				[PC].[CODE_CUSTOMER]
				,[PC].[SUNDAY]
				,[PC].[MONDAY]
				,[PC].[TUESDAY]
				,[PC].[WEDNESDAY]
				,[PC].[THURSDAY]
				,[PC].[FRIDAY]
				,[PC].[SATURDAY]
				,[PC].[FREQUENCY_WEEKS]
				,GETDATE()
				,GETDATE()
				,@LAST_UPDATED_BY
			);
			
		-- ------------------------------------------------------------------------------------
		-- Marca los clientes del poligono como viejos con tareas
		-- ------------------------------------------------------------------------------------
		UPDATE [PC]
		SET
			IS_NEW = 0
			,HAS_PROPOSAL = 1
			,HAS_FREQUENCY = 1
		FROM [SONDA].[SWIFT_POLYGON_X_CUSTOMER] PC
		WHERE [PC].[POLYGON_ID] = @POLYGON_ID

		-- ------------------------------------------------------------------------------------
		-- Obtiene la frecuencia a operar
		-- ------------------------------------------------------------------------------------
		SELECT TOP 1 
			@ID_FREQUENCY = [F].[ID_FREQUENCY]
		FROM @FREQUENCY_FOR_CUSTOMER [F]

		-- ------------------------------------------------------------------------------------
		-- muestra el resultado
		-- ------------------------------------------------------------------------------------
		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,CAST(@ID_FREQUENCY AS VARCHAR) [DbData];
	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo]; 
	END CATCH;
END;
