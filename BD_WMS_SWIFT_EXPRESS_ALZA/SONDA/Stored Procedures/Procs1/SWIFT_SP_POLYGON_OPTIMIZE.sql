-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	31-08-2016
-- Description:			SP que ordena la prioridad de la frecuencia en base de quien esta mas cerca de la bodega y luego al cliente mas cercano

-- Modificacion:		    hector.gonzalez
-- Fecha de Creacion: 	05-09-2016
-- Descripcion:			    Se agrego parametro @DISTANCE 

-- Modificacion 25-Apr-17 @ A-Team Sprint Hondo
					-- alberto.ruiz
					-- Se agrego que valide si el vendedor tiene GPS, si tiene ese es su punto de partida y si es nulo, vacio o 0,0 debe de ser el del CDD

-- Modificacion 12-Jun-17 @ A-Team Sprint Jibade
					-- alberto.ruiz
					-- Se agrego que optimice por cada tipo de tarea la frecuencia
/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [SONDA].[SWIFT_SP_POLYGON_OPTIMIZE]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_POLYGON_OPTIMIZE]
AS
BEGIN
	SET NOCOUNT ON;
	--
	CREATE TABLE #CUSTOMER (
		ID_FREQUENCY INT
		,CODE_CUSTOMER VARCHAR(50)
		,[PRIORITY] INT
		,GPS VARCHAR(50)
		,DISTIANCE NUMERIC(18,6)
	)
	--
	DECLARE
		@TYPE_POLYGON_WITH_WAREHOUSE VARCHAR(50)
		,@TYPE_POLYGON_ROUTE VARCHAR(50)
		,@ID_FREQUENCY INT
		,@GPS_WAREHOUSE VARCHAR(50)
		,@PRIORITY INT
		,@CODE_CUSTOMER VARCHAR(50)
		,@GPS_CUSTOMER VARCHAR(50)
    ,@DISTANCE FLOAT
    ,@POLYGON_ID INT

	BEGIN TRAN
	BEGIN TRY
		-- ------------------------------------------------------------
		-- Obtiene parametros iniciales
		-- ------------------------------------------------------------
		SELECT 
			@TYPE_POLYGON_WITH_WAREHOUSE = [SONDA].SWIFT_FN_GET_PARAMETER('POLYGON','TYPE_POLYGON_WITH_WAREHOUSE')
			,@TYPE_POLYGON_ROUTE = [SONDA].SWIFT_FN_GET_PARAMETER('POLYGON','TYPE_POLYGON_ROUTE')
		
		-- ------------------------------------------------------------
		-- Obtiene las frecuencias para optimizar
		-- ------------------------------------------------------------
		SELECT 
			[F].[ID_FREQUENCY]
			, CASE
				WHEN [S].[GPS] IS NULL THEN [W].[GPS_WAREHOUSE]
				WHEN [S].[GPS] = '' THEN [W].[GPS_WAREHOUSE]
				WHEN [S].[GPS] = '0,0' THEN [W].[GPS_WAREHOUSE]
				ELSE [S].[GPS]
			END [GPS_WAREHOUSE]
			,[PR].[POLYGON_ID]
		INTO [#FREQUENCY]
		FROM [SONDA].[SWIFT_FREQUENCY] [F]
		INNER JOIN [SONDA].[SWIFT_FREQUENCY_BY_POLYGON] [PBR] ON (
			[PBR].[ID_FREQUENCY] = [F].[ID_FREQUENCY]
		)
		INNER JOIN [SONDA].[SWIFT_POLYGON] [PR] ON (
			[PR].[POLYGON_ID] = [PBR].[POLYGON_ID]
		)
		INNER JOIN [SONDA].[SWIFT_POLYGON] [PS] ON (
			[PR].[POLYGON_ID_PARENT] = [PS].[POLYGON_ID]
			AND [PR].[POLYGON_TYPE] = @TYPE_POLYGON_ROUTE
			AND [PS].[POLYGON_TYPE] = @TYPE_POLYGON_WITH_WAREHOUSE
		)
		INNER JOIN [SONDA].[SWIFT_WAREHOUSES] [W] ON (
			[PS].[CODE_WAREHOUSE] = [W].[CODE_WAREHOUSE]
		)
		INNER JOIN [SONDA].[USERS] [U] ON ([U].[SELLER_ROUTE] = [F].[CODE_ROUTE])
		INNER JOIN [SONDA].[SWIFT_SELLER] [S] ON ([U].[RELATED_SELLER] = [S].[SELLER_CODE])
		WHERE [PS].[CODE_WAREHOUSE] IS NOT NULL

		-- ------------------------------------------------------------
		-- Recorre las frecuencias
		-- ------------------------------------------------------------
		WHILE EXISTS(SELECT TOP 1 1 FROM #FREQUENCY)
		BEGIN
			-- ------------------------------------------------------------
			-- Obtiene la frecuencia para obtimizar
			-- ------------------------------------------------------------
			SELECT TOP 1
				@ID_FREQUENCY = F.ID_FREQUENCY
				,@GPS_WAREHOUSE = F.GPS_WAREHOUSE
				,@PRIORITY = 1
        ,@POLYGON_ID = F.POLYGON_ID
			FROM #FREQUENCY F

			-- ------------------------------------------------------------
			-- Obtiene los clientes de la frecuencia con la distancia de la bodega
			-- ------------------------------------------------------------
			INSERT INTO #CUSTOMER
			SELECT
				FC.ID_FREQUENCY
				,FC.CODE_CUSTOMER
				,FC.[PRIORITY]
				,C.GPS
				,dbo.SONDA_FN_CALCULATE_DISTANCE(@GPS_WAREHOUSE,C.GPS) DISTIANCE
			FROM [SONDA].SWIFT_FREQUENCY_X_CUSTOMER FC
			INNER JOIN [SONDA].SWIFT_VIEW_ALL_COSTUMER C ON (
				FC.CODE_CUSTOMER = C.CODE_CUSTOMER
			)
			WHERE ID_FREQUENCY = @ID_FREQUENCY
			ORDER BY 5 ASC

			-- ------------------------------------------------------------
			-- Obtiene el cliente mas cercano y su GPS
			-- ------------------------------------------------------------
			SELECT TOP 1
				@CODE_CUSTOMER = C.CODE_CUSTOMER
				,@GPS_CUSTOMER = C.GPS
        ,@DISTANCE = C.DISTIANCE
			FROM #CUSTOMER C
			ORDER BY DISTIANCE ASC
			--
			PRINT '@ID_FREQUENCY: ' + CAST(@ID_FREQUENCY AS VARCHAR)
			PRINT '@GPS_WAREHOUSE: ' + @GPS_WAREHOUSE
			PRINT '@CODE_CUSTOMER: ' + @CODE_CUSTOMER
			PRINT '@PRIORITY: ' + CAST(@PRIORITY AS VARCHAR)

			-- ------------------------------------------------------------
			-- Actualiza el cliente mas cercano
			-- ------------------------------------------------------------
			EXEC [SONDA].[SWIFT_SP_SET_CUSTOMER_PRIORITY_IN_FREQUENCY]
					@ID_FREQUENCY = @ID_FREQUENCY
					,@CODE_CUSTOMER = @CODE_CUSTOMER
					,@PRIORITY = @PRIORITY
          ,@DISTANCE = @DISTANCE
			--
			SET @PRIORITY = (@PRIORITY + 1)

			-- ------------------------------------------------------------
			-- Borra el cliente mas cercano
			-- ------------------------------------------------------------
			DELETE FROM #CUSTOMER WHERE CODE_CUSTOMER = @CODE_CUSTOMER

			WHILE EXISTS(SELECT TOP 1 1 FROM #CUSTOMER)
			BEGIN
				-- ------------------------------------------------------------
				-- Actualiza la distancia en base al ultimo cliente
				-- ------------------------------------------------------------
				UPDATE #CUSTOMER
				SET DISTIANCE = dbo.SONDA_FN_CALCULATE_DISTANCE(@GPS_CUSTOMER,GPS)

				-- ------------------------------------------------------------
				-- Obtiene el cliente mas cercano y su GPS
				-- ------------------------------------------------------------
				SELECT TOP 1
					@CODE_CUSTOMER = C.CODE_CUSTOMER
					,@GPS_CUSTOMER = C.GPS
          ,@DISTANCE = C.DISTIANCE
				FROM #CUSTOMER C
				ORDER BY DISTIANCE ASC
				--
				PRINT '@ID_FREQUENCY: ' + CAST(@ID_FREQUENCY AS VARCHAR)
				PRINT '@GPS_CUSTOMER: ' + @GPS_CUSTOMER
				PRINT '@CODE_CUSTOMER: ' + @CODE_CUSTOMER
				PRINT '@PRIORITY: ' + CAST(@PRIORITY AS VARCHAR)

				-- ------------------------------------------------------------
				-- Actualiza el cliente mas cercano
				-- ------------------------------------------------------------
				EXEC [SONDA].[SWIFT_SP_SET_CUSTOMER_PRIORITY_IN_FREQUENCY]
						@ID_FREQUENCY = @ID_FREQUENCY
						,@CODE_CUSTOMER = @CODE_CUSTOMER
						,@PRIORITY = @PRIORITY
            ,@DISTANCE = @DISTANCE
				--
				SET @PRIORITY = (@PRIORITY + 1)

				-- ------------------------------------------------------------
				-- Borra el cliente mas cercano
				-- ------------------------------------------------------------
				DELETE FROM #CUSTOMER WHERE CODE_CUSTOMER = @CODE_CUSTOMER
			END 

			-- ------------------------------------------------------------
			-- Borra el registro actual
			-- ------------------------------------------------------------
			DELETE FROM #FREQUENCY WHERE ID_FREQUENCY = @ID_FREQUENCY

     	-- ------------------------------------------------------------
			-- Actualiza el LAST_OPTIMIZATION del poligono
			-- ------------------------------------------------------------

      UPDATE [SONDA].SWIFT_POLYGON
      SET LAST_OPTIMIZATION = GETDATE()
      WHERE POLYGON_ID = @POLYGON_ID;
      
      PRINT '@POLYGON: ' + CAST(@POLYGON_ID AS VARCHAR)

		END

		PRINT 'COMMIT'
		--
		COMMIT 
	END TRY
	BEGIN CATCH
		ROLLBACK
		DECLARE @ERROR VARCHAR(1000) = ERROR_MESSAGE()
		PRINT 'CATCH: ' + @ERROR
		RAISERROR (@ERROR,16,1)
	END CATCH
END
