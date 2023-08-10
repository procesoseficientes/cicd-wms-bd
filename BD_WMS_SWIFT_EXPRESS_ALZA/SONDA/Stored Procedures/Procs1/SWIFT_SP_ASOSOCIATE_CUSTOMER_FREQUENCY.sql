-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	30-08-2016 @ Sprint θ
-- Description:			Inserta o Actualiza la frecuencia

-- Modificación:				    pablo.aguilar
-- Fecha de Modificación: 	21-09-2016 @ Sprint 1 A-Team
-- Description:			      Se agrega el merge con la tabla de poligono por cliente para actualizar sus datos. 

-- Modificacion 17-Jan-17 @ A-Team Sprint Adeben
					-- alberto.ruiz
					-- Se ajusto para que genere la cantidad de frecuencias que tiene asignadas el poligono

-- Modificacion 17-Jul-17 @ Nexus Team Sprint AgeOfEmpires
					-- alberto.ruiz
					-- Se agrego el @POLYGON_ID para la llave de la frecuencia

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [SONDA].[SWIFT_SP_ASOSOCIATE_CUSTOMER_FREQUENCY]
				   @FREQUENCY_WEEKS = 4
				   ,@SUNDAY = 1
				   ,@MONDAY = 0
				   ,@TUESDAY = 1
				   ,@WEDNESDAY = 1
				   ,@THURSDAY = 1
				   ,@FRIDAY  = 0
				   ,@SATURDAY  = 0
				   ,@LAST_DATE_VISITED = '20160904'
				   ,@LAST_UPDATED_BY = 'gerente@SONDA'
				   ,@POLYGON_ID = 10336
				   ,@REFERENCE_SOURCE = 'BO'
				   ,@CODE_CUSTOMER = '205'
				--
				SELECT * FROM [SONDA].SWIFT_FREQUENCY
				SELECT * FROM [SONDA].SWIFT_FREQUENCY_X_CUSTOMER WHERE CODE_CUSTOMER = '205'

*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_ASOSOCIATE_CUSTOMER_FREQUENCY](
	@FREQUENCY_WEEKS INT
	,@SUNDAY INT
	,@MONDAY INT
	,@TUESDAY INT
	,@WEDNESDAY INT
	,@THURSDAY INT
	,@FRIDAY INT
	,@SATURDAY INT
	,@LAST_DATE_VISITED DATE
	,@LAST_UPDATED_BY VARCHAR(25)
	,@POLYGON_ID INT
	,@REFERENCE_SOURCE VARCHAR(150)
	,@CODE_CUSTOMER VARCHAR(50)
)AS
BEGIN
	SET NOCOUNT ON;
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

	BEGIN TRY
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
			[TP].[TASK_TYPE] + CAST(@POLYGON_ID AS VARCHAR)
				+ CAST(@SUNDAY AS VARCHAR) + CAST(@MONDAY AS VARCHAR)
				+ CAST(@TUESDAY AS VARCHAR) + CAST(@WEDNESDAY AS VARCHAR)
				+ CAST(@THURSDAY AS VARCHAR) + CAST(@FRIDAY AS VARCHAR)
				+ CAST(@SATURDAY AS VARCHAR) + CAST(@FREQUENCY_WEEKS AS VARCHAR)  
				+ CAST(@POLYGON_ID AS VARCHAR)-- CODE_FREQUENCY - varchar(50)
			,@SUNDAY
			,@MONDAY
			,@TUESDAY
			,@WEDNESDAY
			,@THURSDAY
			,@FRIDAY
			,@SATURDAY
			,@FREQUENCY_WEEKS
			,@LAST_DATE_VISITED
			,GETDATE()  -- LAST_UPDATED - datetime
			,@LAST_UPDATED_BY  -- LAST_UPDATED_BY - varchar(25)
			,@POLYGON_ID  -- CODE_ROUTE - varchar(50)
			,[TP].[TASK_TYPE]
			,@POLYGON_ID
		FROM [SONDA].[SWIFT_TASK_BY_POLYGON] [TP]
		WHERE [TP].[POLYGON_ID] = @POLYGON_ID

		-- ------------------------------------------------------------
		-- Insertamos o actualizamos la frecuencia
		-- ------------------------------------------------------------
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

		-- ------------------------------------------------------------
		-- Se elemina el cliente si tiene una frecuencia asociada
		-- ------------------------------------------------------------
		DELETE FROM [SONDA].[SWIFT_FREQUENCY_X_CUSTOMER]
		WHERE [CODE_CUSTOMER] = @CODE_CUSTOMER;

		-- ------------------------------------------------------------
		-- Asociamos el cliente a la frecuencia
		-- ------------------------------------------------------------
		INSERT	INTO [SONDA].[SWIFT_FREQUENCY_X_CUSTOMER]
				(
					[ID_FREQUENCY]
					,[CODE_CUSTOMER]
					,[PRIORITY]
				)
		SELECT
			[F].[ID_FREQUENCY]
			,@CODE_CUSTOMER
			,0
		FROM [SONDA].[SWIFT_FREQUENCY] [F]
		INNER JOIN @FREQUENCY [FT] ON (
			[FT].[CODE_FREQUENCY] = [F].[CODE_FREQUENCY]
		)

		-- ------------------------------------------------------------------------------------
		-- Asocia o actualiza la asociacion del cliente con el poligono
		-- ------------------------------------------------------------------------------------
		MERGE [SONDA].[SWIFT_POLYGON_X_CUSTOMER] AS [PC]
		USING (
				SELECT
					@CODE_CUSTOMER AS [CODE_CUSTOMER]
					,@POLYGON_ID AS [POLYGON_ID]
				) AS [PT]
		ON (
			[PC].[POLYGON_ID] = [PT].[POLYGON_ID]
			AND [PC].[CODE_CUSTOMER] = [PT].[CODE_CUSTOMER]
			)
		WHEN MATCHED THEN
			UPDATE SET
					[PC].[IS_NEW] = 0
					,[PC].[HAS_PROPOSAL] = 1
					,[PC].[HAS_FREQUENCY] = 1
		WHEN NOT MATCHED THEN
			INSERT
					(
						[POLYGON_ID]
						,[CODE_CUSTOMER]
						,[IS_NEW]
						,[HAS_PROPOSAL]
						,[HAS_FREQUENCY]
					)
			VALUES	(
						@POLYGON_ID
						,@CODE_CUSTOMER
						,0
						,1
						,1
					);

		IF @@ERROR = 0
		BEGIN
			SELECT
				1 AS [Resultado]
				,'Proceso Exitoso' [Mensaje]
				,0 [CODIGO]
				,'0' AS [DbData];
		END;
		ELSE
		BEGIN
			SELECT
				-1 AS [Resultado]
				,ERROR_MESSAGE() [Mensaje]
				,@@ERROR [Codigo];
		END;
	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];
	END CATCH;
END
