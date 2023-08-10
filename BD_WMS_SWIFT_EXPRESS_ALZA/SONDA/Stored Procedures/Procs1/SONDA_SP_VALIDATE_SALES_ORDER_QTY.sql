-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	05-Jul-17  
-- Description:			SP que valida la cantidad de pedidos de la ruta 

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_VALIDATE_SALES_ORDER_QTY]
					@CODE_ROUTE = '44'
					,@SALES_ORDER_QTY = 12
					,@DOC_SERIE = 'GUA0032@ARIUM'
					,@DOC_NUM = 7967
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_VALIDATE_SALES_ORDER_QTY] (
	@CODE_ROUTE VARCHAR(50)
	,@SALES_ORDER_QTY INT
	,@DOC_SERIE VARCHAR(100)
	,@DOC_NUM INT
) AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @SALE_ORDER TABLE (
		[DOC_SERIE] VARCHAR(100)
		,[DOC_NUM] INT
		,[SALES_ORDER_ID] INT
		,[IS_READY_TO_SEND] INT
	)
	--
	DECLARE 
		@QTY INT
		,@SUCCESS INT = 0
		,@IS_READY_TO_SEND_QTY INT = 0;
	
	BEGIN TRY
		-- ------------------------------------------------------------------------------------
	    -- Obtiene las ordenes de la ruta
	    -- ------------------------------------------------------------------------------------
	    INSERT INTO @SALE_ORDER
	    		(
	    			[DOC_SERIE]
	    			,[DOC_NUM]
	    			,[SALES_ORDER_ID]
	    			,[IS_READY_TO_SEND]
	    		)
	    SELECT
	    	[H].[DOC_SERIE]
	    	,[H].[DOC_NUM]
	    	,MIN([H].[SALES_ORDER_ID])
	    	,MAX([H].[IS_READY_TO_SEND])
	    FROM [SONDA].[SONDA_SALES_ORDER_HEADER] [H]
	    WHERE [H].[SALES_ORDER_ID] > 0
	    	AND [H].[DOC_SERIE] = @DOC_SERIE
	    	AND [H].[DOC_NUM] >= @DOC_NUM
	    	AND [H].[POSTED_DATETIME] >= FORMAT(GETDATE(),'yyyyMMdd')
			AND [H].[IS_ACTIVE_ROUTE] = 1
	    GROUP BY
	    	[H].[DOC_SERIE]
	    	,[H].[DOC_NUM]
	    --
	    SET @QTY = @@ROWCOUNT
	    
	    -- ------------------------------------------------------------------------------------
	    -- Valida la cantidad de ordenes
	    -- ------------------------------------------------------------------------------------
	    IF @QTY = @SALES_ORDER_QTY
	    BEGIN
	    	SELECT @IS_READY_TO_SEND_QTY = COUNT(*)
	    	FROM @SALE_ORDER [S]
	    	WHERE [S].[IS_READY_TO_SEND] = 1
	    
	    	-- ------------------------------------------------------------------------------------
	    	-- Valida si todos estan listos
	    	-- ------------------------------------------------------------------------------------
	    	IF @IS_READY_TO_SEND_QTY = @SALES_ORDER_QTY
	    	BEGIN
	    		SET @SUCCESS = 1
	    	END
	    	ELSE
	    	BEGIN
	    		--PRINT 'Hay pedidos no listos'
	    		--
	    		BEGIN TRY
	    			BEGIN TRAN
	    			--
	    			UPDATE [H]
	    			SET [H].[IS_READY_TO_SEND] = 1
	    			FROM [SONDA].[SONDA_SALES_ORDER_HEADER] [H]
	    			INNER JOIN @SALE_ORDER [S] ON ([S].[SALES_ORDER_ID] = [H].[SALES_ORDER_ID])
	    			WHERE [S].[IS_READY_TO_SEND] = 0
	    			--
	    			COMMIT
	    			--
	    			SET @SUCCESS = 1
	    		END TRY
	    		BEGIN CATCH
	    			ROLLBACK
	    			--
	    			DECLARE @ERROR2 VARCHAR(2000) = ERROR_MESSAGE()
	    			PRINT 'CATCH2: ' + @ERROR2
	    			RAISERROR (@ERROR2, 16, 1)
	    		END CATCH
	    	END
	    END
	    ELSE
	    BEGIN
	    	--PRINT 'No hay la misma cantidad'
	    	--
	    	SET @SUCCESS = 0
	    END
	    
	    -- ------------------------------------------------------------------------------------
	    -- Muestra el resultado
	    -- ------------------------------------------------------------------------------------
	    SELECT @SUCCESS [SUCCESS]
	END TRY
	BEGIN CATCH
	    DECLARE @ERROR1 VARCHAR(2000) = ERROR_MESSAGE()
	    PRINT 'CATCH1: ' + @ERROR1
	    RAISERROR (@ERROR1, 16, 1)
	END CATCH
END
