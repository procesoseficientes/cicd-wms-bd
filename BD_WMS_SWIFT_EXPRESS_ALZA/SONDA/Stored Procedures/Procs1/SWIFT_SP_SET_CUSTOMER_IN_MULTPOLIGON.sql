-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	29-Nov-16 @ A-TEAM Sprint 5 
-- Description:			SP para asociar a los clientes sin poligono a un poligono de capa 4

-- Modificacion 16-Jan-17 @ A-Team Sprint Adeben
					-- alberto.ruiz
					-- Se ajusto para que genere la cantidad de frecuencias que tiene asignadas el poligono

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_SET_CUSTOMER_IN_MULTPOLIGON]
					@LOGIN = 'GERENTE@SONDA'
					,@SECTOR_POLYGON_ID = 5168
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_SET_CUSTOMER_IN_MULTPOLIGON](
	@LOGIN VARCHAR(50)
	,@SECTOR_POLYGON_ID INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE
		@ROUTE INT 
		,@POLYGON_ID INT
		--,@ID_FREQUENCY INT
		,@GEOMETRY_POLYGON GEOMETRY
	--
	DECLARE @MULTIPOLYGON TABLE(
		[ROUTE] INT
		,[POLYGON_ID] INT
		--,[TASK_TYPE] VARCHAR(50)
	)
	--
	CREATE TABLE #POLYGON_BY_ROUTE (
		[ROUTE] INT
		,[POLYGON_ID] INT
		--,[ID_FREQUENCY] INT
		,[CODE_CUSTOMER] VARCHAR(50)
	)

	-- ------------------------------------------------------------------------------------
	-- Obtiene los poligonos que son de capa 4
	-- ------------------------------------------------------------------------------------
	INSERT INTO @MULTIPOLYGON
			(
				[ROUTE]
				,[POLYGON_ID]
				--,[TASK_TYPE]
			)
	SELECT
		[P].[ROUTE]
		,[P].[POLYGON_ID]
		--,[TP].[TASK_TYPE]
	FROM [SONDA].[SWIFT_POLYGON_BY_ROUTE] [P]
	INNER JOIN [SONDA].[SWIFT_POLYGON] [SP] ON (
		[SP].[POLYGON_ID] = [P].[POLYGON_ID]
	)
	--INNER JOIN [SONDA].[SWIFT_TASK_BY_POLYGON] [TP] ON (
	--	[TP].[POLYGON_ID] = [P].[POLYGON_ID]
	--)
	WHERE [P].[IS_MULTIPOLYGON] = 1
		AND [SP].[POLYGON_ID_PARENT] = @SECTOR_POLYGON_ID

	-- ------------------------------------------------------------------------------------
	-- Obtiene los clientes que no estan asociados a un poligono
	-- ------------------------------------------------------------------------------------
	SELECT 
		[C].[CODE_CUSTOMER]
		,geometry::[Point]([C].[LATITUDE], [C].[LONGITUDE], 0) [POINT]
	INTO #CUSTOMER
	FROM [SONDA].[SWIFT_VIEW_ALL_COSTUMER] [C]
	LEFT JOIN [SONDA].[SWIFT_POLYGON_X_CUSTOMER] [PXC] ON (
		[PXC].[CODE_CUSTOMER] = [C].[CODE_CUSTOMER]
	)
	WHERE [PXC].[POLYGON_ID] IS NULL
		AND [C].[LATITUDE] IS NOT NULL 
		AND [C].[LONGITUDE] IS NOT NULL
		AND [C].[GPS] IS NOT NULL

	-- ------------------------------------------------------------------------------------
	-- Recorre todos los poligonos para ir asignado los clientes respectivos a cada poligono
	-- ------------------------------------------------------------------------------------
	WHILE EXISTS(SELECT TOP 1 1 FROM @MULTIPOLYGON)
	BEGIN
		-- ------------------------------------------------------------------------------------
		-- Obtiene el poligono a operar
		-- ------------------------------------------------------------------------------------
		SELECT TOP 1
			@ROUTE = [M].[ROUTE]
			,@POLYGON_ID = [M].[POLYGON_ID]
			,@GEOMETRY_POLYGON = [SONDA].[SWIFT_GET_GEOMETRY_POLYGON_BY_POLIGON_ID]([M].[POLYGON_ID])
		FROM @MULTIPOLYGON [M]
		ORDER BY [POLYGON_ID] ASC

		-- ------------------------------------------------------------------------------------
		-- Obtiene los clientes asociados al poligono
		-- ------------------------------------------------------------------------------------
		INSERT INTO [#POLYGON_BY_ROUTE]
				(
					[ROUTE]
					,[POLYGON_ID]
					,[CODE_CUSTOMER]
				)
		SELECT
			@ROUTE
			,@POLYGON_ID
			,[C].[CODE_CUSTOMER]
		FROM [#CUSTOMER] [C]
		WHERE @GEOMETRY_POLYGON.MakeValid().STContains([C].[POINT]) = 1

		-- ------------------------------------------------------------------------------------
		-- Elimina el poligono al que se le acaban de asignar clientes
		-- ------------------------------------------------------------------------------------
		DELETE FROM @MULTIPOLYGON WHERE [POLYGON_ID] = @POLYGON_ID

		-- ------------------------------------------------------------------------------------
		-- Elimina los clientes a los cuales se les asocio un poligono
		-- ------------------------------------------------------------------------------------
		DELETE [C]
		FROM [#CUSTOMER] [C]
		INNER JOIN [#POLYGON_BY_ROUTE] [PBR] ON (
			[PBR].[CODE_CUSTOMER] = [C].[CODE_CUSTOMER]
		)
	END

	
	BEGIN TRY
	BEGIN TRAN
		-- ------------------------------------------------------------------------------------
		-- Genera la frecuencia del cliente
		-- ------------------------------------------------------------------------------------
		DELETE [FXC]
		FROM [SONDA].[SWIFT_FREQUENCY_X_CUSTOMER] [FXC]
		INNER JOIN [#POLYGON_BY_ROUTE] [PBR] ON (
			[PBR].[CODE_CUSTOMER] = [FXC].[CODE_CUSTOMER]
		)
		--
		INSERT INTO [SONDA].[SWIFT_FREQUENCY_X_CUSTOMER]
				(
					[ID_FREQUENCY]
					,[CODE_CUSTOMER]
					,[PRIORITY]
				)
		SELECT
			[FP].[ID_FREQUENCY]
			,[PBR].[CODE_CUSTOMER]
			,1
		FROM [#POLYGON_BY_ROUTE] [PBR]
		INNER JOIN [SONDA].[SWIFT_FREQUENCY_BY_POLYGON] [FP] ON (
			[FP].[POLYGON_ID] = [PBR].[POLYGON_ID]
		)

		-- ------------------------------------------------------------------------------------
		-- Genera la propuesta de vista del cliente
		-- ------------------------------------------------------------------------------------
		MERGE [SONDA].[SWIFT_CUSTOMER_FREQUENCY] AS [CF]
		USING (
			SELECT DISTINCT
				[PBR].[CODE_CUSTOMER]
				,[F].[SUNDAY]
				,[F].[MONDAY]
				,[F].[TUESDAY]
				,[F].[WEDNESDAY]
				,[F].[THURSDAY]
				,[F].[FRIDAY]
				,[F].[SATURDAY]
				,[F].[FREQUENCY_WEEKS]
				,[F].[LAST_WEEK_VISITED]
				,GETDATE() [LAST_UPDATED]
				,@LOGIN [LAST_UPDATED_BY]
			FROM [#POLYGON_BY_ROUTE] [PBR]
			INNER JOIN [SONDA].[SWIFT_FREQUENCY_BY_POLYGON] [FP] ON (
				[FP].[POLYGON_ID] = [PBR].[POLYGON_ID]
			)
			INNER JOIN [SONDA].[SWIFT_FREQUENCY] [F] ON (
				[F].[ID_FREQUENCY] = [FP].[ID_FREQUENCY]
			)
		) [NCF]
		ON (
			[CF].[CODE_CUSTOMER] = [NCF].[CODE_CUSTOMER]
		)
		WHEN MATCHED THEN
			UPDATE SET
				[CF].[SUNDAY] = [NCF].[SUNDAY]
				,[CF].[MONDAY] = [NCF].[MONDAY]
				,[CF].[TUESDAY] = [NCF].[TUESDAY]
				,[CF].[WEDNESDAY] = [NCF].[WEDNESDAY]
				,[CF].[THURSDAY] = [NCF].[THURSDAY]
				,[CF].[FRIDAY] = [NCF].[FRIDAY]
				,[CF].[SATURDAY] = [NCF].[SATURDAY]
				,[CF].[FREQUENCY_WEEKS] = [NCF].[FREQUENCY_WEEKS]
				,[CF].[LAST_DATE_VISITED] = [NCF].[LAST_WEEK_VISITED]
				,[CF].[LAST_UPDATED] = [NCF].[LAST_UPDATED]
				,[CF].[LAST_UPDATED_BY] = [NCF].[LAST_UPDATED_BY]
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
			VALUES
				(
					[NCF].[CODE_CUSTOMER]
					,[NCF].[SUNDAY]
					,[NCF].[MONDAY]
					,[NCF].[TUESDAY]
					,[NCF].[WEDNESDAY]
					,[NCF].[THURSDAY]
					,[NCF].[FRIDAY]
					,[NCF].[SATURDAY]
					,[NCF].[FREQUENCY_WEEKS]
					,[NCF].[LAST_WEEK_VISITED]
					,[NCF].[LAST_UPDATED]
					,[NCF].[LAST_UPDATED_BY]
				);

		-- ------------------------------------------------------------------------------------
		-- Genera la relacion de los clientes con el poligono
		-- ------------------------------------------------------------------------------------
		INSERT INTO [SONDA].[SWIFT_POLYGON_X_CUSTOMER]
				(
					[POLYGON_ID]
					,[CODE_CUSTOMER]
					,[IS_NEW]
					,[HAS_PROPOSAL]
					,[HAS_FREQUENCY]
				)
		SELECT
			[PBR].[POLYGON_ID]
			,[PBR].[CODE_CUSTOMER]
			,0
			,1
			,1
		FROM [#POLYGON_BY_ROUTE] [PBR] 
		
		-- ------------------------------------------------------------------------------------
		-- Muestra el resultado final
		-- ------------------------------------------------------------------------------------
		COMMIT
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '0' DbData
	END TRY
	BEGIN CATCH
		ROLLBACK
		--
		SELECT  
			-1 as Resultado
			,ERROR_MESSAGE() Mensaje 
			,@@ERROR Codigo
	END CATCH
END
