-- =============================================
-- Autor:	        rudi.garcia
-- Fecha de Creacion: 	2017-10-09 @ Team REBORN - Sprint Drache
-- Description:	        Sp que el detalle de la certificacion.

-- Modificacion 11/13/2017 @ NEXUS-Team Sprint F-Zero
					-- rodrigo.gomez
					-- Se inserta el detalle si es por caja

-- Modificacion 11/29/2017 @ NEXUS-Team Sprint GTA
					-- rodrigo.gomez
					-- Se agrega filtro por ola de picking al escanear por caja
/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_INSERT_CERTIFICATION_DETAIL] @CERTIFICATION_HEADER_ID = 1                                                
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_INSERT_CERTIFICATION_DETAIL
    (
     @CERTIFICATION_HEADER_ID INT
    ,@LABEL_ID INT = NULL
    ,@QTY DECIMAL(18, 4) = 0
    ,@CERTIFICATION_TYPE VARCHAR(50)
    ,@LAST_UPDATE VARCHAR(25)
    ,@MATERIAL_ID VARCHAR(50) = NULL
    ,@BOX_BARCODE VARCHAR(50) = NULL
	)
AS
BEGIN
    SET NOCOUNT ON;
	--
	
    BEGIN TRY

		--
        DECLARE
            @CERTIFICATION_DETAIL_ID INT = NULL
           ,@MANIFEST_HEDAER_ID INT = NULL
		   ,@WAVE_PICKING_ID INT = NULL;

		-- ------------------------------------------------------------
		-- Obtenemos el manifiesto encaebezado
		-- ------------------------------------------------------------

        SELECT TOP 1
            @MANIFEST_HEDAER_ID = [CH].[MANIFEST_HEADER_ID]
        FROM
            [wms].[OP_WMS_CERTIFICATION_HEADER] [CH]
        WHERE
            [CH].[CERTIFICATION_HEADER_ID] = @CERTIFICATION_HEADER_ID;


		-- ------------------------------------------------------------
		-- Validamos si la etiqueta ya existe en la certificacion
		-- ------------------------------------------------------------

        SELECT TOP 1
            @CERTIFICATION_DETAIL_ID = [CD].[CERTIFICATION_DETAIL_ID]
        FROM
            [wms].[OP_WMS_CERTIFICATION_DETAIL] [CD]
        WHERE
            [CD].[CERTIFICATION_HEADER_ID] = @CERTIFICATION_HEADER_ID
            AND [CD].[LABEL_ID] = @LABEL_ID;

        IF @CERTIFICATION_DETAIL_ID IS NOT NULL
        BEGIN
            SELECT
                2 AS [Resultado]
               ,'Etiqueta ya fue escaneada, Desea eliminarla?' [Mensaje]
               ,0 [Codigo]
               ,CAST(@CERTIFICATION_DETAIL_ID AS VARCHAR) [DbData];

            RETURN;
        END;

		-- ------------------------------------------------------------------------------------
		-- Se valida si es por canasta
		-- ------------------------------------------------------------------------------------

		IF @BOX_BARCODE IS NOT NULL
		BEGIN
			-- ------------------------------------------------------------
			-- Validamos si la caja pertenece al manifiesto
			-- ------------------------------------------------------------
            IF NOT EXISTS ( SELECT TOP 1 1
							FROM
								[wms].[OP_WMS_PICKING_LABEL_BY_MANIFEST] [PLM]
							INNER JOIN [wms].[OP_WMS_MANIFEST_DETAIL] [MD] ON ([MD].[MANIFEST_DETAIL_ID] = [PLM].[MANIFEST_DETAIL_ID])
							INNER JOIN [wms].[OP_WMS_PICKING_LABELS] [PL] ON ([PL].[LABEL_ID] = [PLM].[LABEL_ID])
							WHERE
								[MD].[MANIFEST_HEADER_ID] = @MANIFEST_HEDAER_ID
								AND [PL].[BARCODE] = @BOX_BARCODE )
            BEGIN
				-- ------------------------------------------------------------
				-- Retornamos el mensaje de que la etiqueta no pertenece al manifiesto.
				-- ------------------------------------------------------------
                SELECT
                    -1 AS [Resultado]
                   ,'La caja escaneada no pertenece al manifiesto.' [Mensaje]
                   ,1001 [Codigo]
                   ,CAST(@BOX_BARCODE AS VARCHAR) [DbData];

                RETURN;
			END
			ELSE
			BEGIN
				IF EXISTS ( SELECT TOP 1 1 
							FROM 
								[wms].[OP_WMS_CERTIFICATION_DETAIL] [CD]
							INNER JOIN [wms].[OP_WMS_CERTIFICATION_HEADER] [CH] ON [CH].[CERTIFICATION_HEADER_ID] = [CD].[CERTIFICATION_HEADER_ID]
							WHERE [CH].[MANIFEST_HEADER_ID] = @MANIFEST_HEDAER_ID AND [CD].[BOX_BARCODE] = @BOX_BARCODE)
				BEGIN
					-- ------------------------------------------------------------
					-- Retornamos el mensaje de que la etiqueta no pertenece al manifiesto.
					-- ------------------------------------------------------------
					SELECT
						2 AS [Resultado]
					   ,'Caja ya escaneada, Desea eliminarla?' [Mensaje]
					   ,@CERTIFICATION_HEADER_ID [Codigo]
					   ,CAST(@BOX_BARCODE AS VARCHAR) [DbData];

					RETURN;
				END
				ELSE	
				BEGIN

					--PRINT 'ola' + CAST( ISNULL(	@WAVE_PICKING_ID, 0) AS VARCHAR)
					--INSERT INTO [wms].[OP_WMS_CERTIFICATION_DETAIL]
					--        (
					--         [CERTIFICATION_HEADER_ID]
					--        ,[LABEL_ID]
					--        ,[MATERIAL_ID]
					--        ,[QTY]
					--        ,[CERTIFICATION_TYPE]
					--        ,[LAST_UPDATED]
					--        ,[LAST_UPDATED_BY]
					--        ,[BOX_BARCODE]
					--        )
					--SELECT DISTINCT @CERTIFICATION_HEADER_ID
					--	,NULL
					--	,[DT].[MATERIAL_ID]
					--	,0--[QUANTITY]
					--	,'CAJA'
					--	,GETDATE()
					--	,@LAST_UPDATE
					--	,0--mh.[BOX_ID]
					--FROM [wms].[OP_WMS_CERTIFICATION_HEADER] [CH]
					--INNER JOIN [wms].[OP_WMS_MANIFEST_HEADER] [MH] ON [MH].[MANIFEST_HEADER_ID] = [CH].[MANIFEST_HEADER_ID]
					--INNER JOIN [wms].[OP_WMS_MANIFEST_DETAIL] [MD] ON [MD].[MANIFEST_HEADER_ID] = [MH].[MANIFEST_HEADER_ID]
					----INNER JOIN [wms].[OP_WMS_DISTRIBUTED_TASK] [DT] ON [wms].[OP_WMS_FN_SPLIT_COLUMNS]([ERP_DOC], 2,'-') = [MD].[WAVE_PICKING_ID]
					--WHERE [BOX_ID] = @BOX_BARCODE
					--	AND [CH].[CERTIFICATION_HEADER_ID] = @CERTIFICATION_HEADER_ID

					GOTO FIN
				END
			END
		END

		-- ------------------------------------------------------------
		-- Validamos si es por etiqueta o producto.
		-- ------------------------------------------------------------
        IF @LABEL_ID IS NOT NULL
        BEGIN
			-- ------------------------------------------------------------
			-- Validamos si la etiqueta pertenece al manifiesto
			-- ------------------------------------------------------------
            IF NOT EXISTS ( SELECT TOP 1
                                1
                            FROM
                                [wms].[OP_WMS_PICKING_LABEL_BY_MANIFEST] [PLM]
                            INNER JOIN [wms].[OP_WMS_MANIFEST_DETAIL] [MD] ON ([MD].[MANIFEST_DETAIL_ID] = [PLM].[MANIFEST_DETAIL_ID])
                            WHERE
                                [PLM].[LABEL_ID] = @LABEL_ID
                                AND [MD].[MANIFEST_HEADER_ID] = @MANIFEST_HEDAER_ID )
            BEGIN
				-- ------------------------------------------------------------
				-- Retornamos el mensaje de que la etiqueta no pertenece al manifiesto.
				-- ------------------------------------------------------------
                SELECT
                    -1 AS [Resultado]
                   ,'La etiqueta escanedado no pertenece al manifiesto.' [Mensaje]
                   ,1001 [Codigo]
                   ,CAST(@LABEL_ID AS VARCHAR) [DbData];

                RETURN;
            END;
            ELSE
            BEGIN
			-- ------------------------------------------------------------
			-- Obtenemos la cantidad de esa etiqueta.
			-- ------------------------------------------------------------
                SELECT TOP 1
                    @QTY = [PL].[QTY]
                   ,@MATERIAL_ID = [PL].[MATERIAL_ID]
                FROM
                    [wms].[OP_WMS_PICKING_LABELS] [PL]
                WHERE
                    [PL].[LABEL_ID] = @LABEL_ID;
            END;
        END;

		-- ------------------------------------------------------------
		-- Validamos si el producto pertence al manifiesto.
		-- ------------------------------------------------------------
        IF NOT EXISTS ( SELECT TOP 1
                            1
                        FROM
                            [wms].[OP_WMS_PICKING_LABEL_BY_MANIFEST] [PLM]
                        INNER JOIN [wms].[OP_WMS_MANIFEST_DETAIL] [MD] ON ([MD].[MANIFEST_DETAIL_ID] = [PLM].[MANIFEST_DETAIL_ID])
                        INNER JOIN [wms].[OP_WMS_PICKING_LABELS] [PL] ON ([PL].[LABEL_ID] = [PLM].[LABEL_ID])
                        WHERE
                            [MD].[MANIFEST_HEADER_ID] = @MANIFEST_HEDAER_ID
                            AND [PL].[MATERIAL_ID] = @MATERIAL_ID )
        BEGIN
			-- ------------------------------------------------------------
			-- Retornamos el mensaje de que el material no pertenece al manifiesto.
			-- ------------------------------------------------------------
            SELECT
                -1 AS [Resultado]
               ,'El material escaneado no pertenece al manifiesto.' [Mensaje]
               ,1001 [Codigo]
               ,CAST(@LABEL_ID AS VARCHAR) [DbData];

            RETURN;
        END;
        ELSE
        BEGIN
			-- ------------------------------------------------------------
			-- Obtenemos los totales del material
			-- ------------------------------------------------------------
            DECLARE
                @TOTAL_QTY DECIMAL(18, 4) = 0
               ,@QTY_SCAN DECIMAL(18, 4) = 0;
            SELECT
                @TOTAL_QTY = SUM([PLM].[QTY])
            FROM
                [wms].[OP_WMS_PICKING_LABEL_BY_MANIFEST] [PLM]
            INNER JOIN [wms].[OP_WMS_MANIFEST_DETAIL] [MD] ON ([MD].[MANIFEST_DETAIL_ID] = [PLM].[MANIFEST_DETAIL_ID])
            INNER JOIN [wms].[OP_WMS_PICKING_LABELS] [PL] ON ([PL].[LABEL_ID] = [PLM].[LABEL_ID])
            WHERE
                [MD].[MANIFEST_HEADER_ID] = @MANIFEST_HEDAER_ID
                AND [PL].[MATERIAL_ID] = @MATERIAL_ID;

            SELECT
                @QTY_SCAN = ISNULL(SUM([CD].[QTY]), 0)
            FROM
                [wms].[OP_WMS_CERTIFICATION_DETAIL] [CD]
            WHERE
                [CD].[CERTIFICATION_HEADER_ID] = @CERTIFICATION_HEADER_ID
                AND [CD].[MATERIAL_ID] = @MATERIAL_ID;


			-- ------------------------------------------------------------
			-- Validamos que la cantidad no sobrepase a las etiquetas asociadas al manifiesto, cuando este se por material
			-- ------------------------------------------------------------
            IF @LABEL_ID IS NULL
                AND (@QTY + @QTY_SCAN) > @TOTAL_QTY
            BEGIN
                SELECT
                    -1 AS [Resultado]
                   ,'Cantidad incorrecta' [Mensaje]
                   ,1003 [Codigo]
                   ,'' [DbData];
                RETURN;
            END;
        END;

        DECLARE @ID INT = 0;

		-- ------------------------------------------------------------
		-- Validamos si hay registro con tipo de certificacion material y que la etiqueta traiga null
		-- ------------------------------------------------------------
        IF EXISTS ( SELECT TOP 1
                        1
                    FROM
                        [wms].[OP_WMS_CERTIFICATION_DETAIL] [CD]
                    WHERE
                        [CD].[CERTIFICATION_HEADER_ID] = @CERTIFICATION_HEADER_ID
                        AND [CD].[MATERIAL_ID] = @MATERIAL_ID
                        AND [CD].[CERTIFICATION_TYPE] = 'MATERIAL'
                        AND @LABEL_ID IS NULL )
        BEGIN
		-- ------------------------------------------------------------
		-- Si existe se le suma la cantidad
		-- ------------------------------------------------------------
            UPDATE
                [wms].[OP_WMS_CERTIFICATION_DETAIL]
            SET
                [QTY] += @QTY
            WHERE
                [CERTIFICATION_HEADER_ID] = @CERTIFICATION_HEADER_ID
                AND [MATERIAL_ID] = @MATERIAL_ID
                AND [CERTIFICATION_TYPE] = 'MATERIAL';
        END;
        ELSE
        BEGIN
		-- ------------------------------------------------------------
		-- Si no existe se agrega
		-- ------------------------------------------------------------
            INSERT  INTO [wms].[OP_WMS_CERTIFICATION_DETAIL]
                    (
                     [CERTIFICATION_HEADER_ID]
                    ,[LABEL_ID]
                    ,[MATERIAL_ID]
                    ,[QTY]
                    ,[CERTIFICATION_TYPE]
                    ,[LAST_UPDATED]
                    ,[LAST_UPDATED_BY]
                    )
            VALUES
                    (
                     @CERTIFICATION_HEADER_ID
                    ,@LABEL_ID
                    ,@MATERIAL_ID
                    ,@QTY
                    ,@CERTIFICATION_TYPE
                    ,GETDATE()
                    ,@LAST_UPDATE
                    );

            SET @ID = SCOPE_IDENTITY();

            IF @LABEL_ID IS NOT NULL
            BEGIN
			-- ------------------------------------------------------------
			-- Eliminamos las series de la etiqueta por si los ingresaron por material
			-- ------------------------------------------------------------
                DELETE
                    [CSN]
                FROM
                    [wms].[OP_WMS_CERTIFICATION_BY_SERIAL_NUMBER] CSN
                INNER JOIN [wms].[OP_WMS_PICKING_LABELS_BY_SERIAL_NUMBER] [PLS] ON ([CSN].[SERIAL_NUMBER] = [PLS].[SERIAL_NUMBER])
                WHERE
                    [CSN].[MATERIAL_ID] = @MATERIAL_ID
                    AND [CSN].[CERTIFICATION_HEADER_ID] = @CERTIFICATION_HEADER_ID
                    AND [PLS].[LABEL_ID] = @LABEL_ID;
        
				-- ------------------------------------------------------------
				-- Insertamos las series de la etiqueta
				-- ------------------------------------------------------------

                DECLARE @QUERY VARCHAR(MAX);
        
                SET @QUERY = 'INSERT INTO [wms].[OP_WMS_CERTIFICATION_BY_SERIAL_NUMBER] ([CERTIFICATION_HEADER_ID], [MATERIAL_ID], [SERIAL_NUMBER])
						SELECT TOP ' + CAST(CAST(@QTY AS INT) AS VARCHAR) + '
						  ' + CAST(@CERTIFICATION_HEADER_ID AS VARCHAR) + '
						  ,''' + @MATERIAL_ID + ''' 
						  ,[PLS].[SERIAL_NUMBER]
						FROM  [wms].[OP_WMS_PICKING_LABELS_BY_SERIAL_NUMBER] [PLS]
						LEFT JOIN [wms].[OP_WMS_CERTIFICATION_BY_SERIAL_NUMBER] [CSN] ON(
						  [PLS].[SERIAL_NUMBER] = [CSN].[SERIAL_NUMBER]
						)
						WHERE [PLS].[LABEL_ID] = ' + CAST(@LABEL_ID AS VARCHAR) + '
						AND [CSN].[CERTIFICATION_HEADER_ID] IS NULL';
       
                PRINT (@QUERY);
                EXEC(@QUERY);

            END;      
        END;


        DECLARE
            @TOTAL_CERTIFICATION DECIMAL(18, 4) = 0
           ,@TOTAL_LABEL DECIMAL(18, 4) = 0
           ,@TOTAL_MATERIAL DECIMAL(18, 4) = 0;

		-- ------------------------------------------------------------
		-- Obtenemos los totales para la validacion de las etiqueta con el material
		-- ------------------------------------------------------------
        SELECT
            @TOTAL_CERTIFICATION = SUM([CD].[QTY])
        FROM
            [wms].[OP_WMS_CERTIFICATION_DETAIL] [CD]
        WHERE
            [CERTIFICATION_HEADER_ID] = @CERTIFICATION_HEADER_ID
            AND [CD].[MATERIAL_ID] = @MATERIAL_ID;

        SELECT
            @TOTAL_LABEL = SUM([CD].[QTY])
        FROM
            [wms].[OP_WMS_CERTIFICATION_DETAIL] [CD]
        WHERE
            [CERTIFICATION_HEADER_ID] = @CERTIFICATION_HEADER_ID
            AND [CD].[MATERIAL_ID] = @MATERIAL_ID
            AND [CD].[CERTIFICATION_TYPE] = 'ETIQUETA';

		-- ------------------------------------------------------------
		-- Validamos si ya sobrepasa la cantidad establecidad en el manifiesto para hacer el ajuste.
		-- ------------------------------------------------------------
        IF @TOTAL_CERTIFICATION > @TOTAL_QTY
        BEGIN
            SET @TOTAL_MATERIAL = (@TOTAL_QTY - @TOTAL_LABEL);

            IF @TOTAL_MATERIAL <= 0
            BEGIN
                DELETE
                    [wms].[OP_WMS_CERTIFICATION_DETAIL]
                WHERE
                    [CERTIFICATION_HEADER_ID] = @CERTIFICATION_HEADER_ID
                    AND [MATERIAL_ID] = @MATERIAL_ID
                    AND [CERTIFICATION_TYPE] = 'MATERIAL';
            END;
            ELSE
            BEGIN
                UPDATE
                    [wms].[OP_WMS_CERTIFICATION_DETAIL]
                SET
                    [QTY] = @TOTAL_MATERIAL
                WHERE
                    [CERTIFICATION_HEADER_ID] = @CERTIFICATION_HEADER_ID
                    AND [MATERIAL_ID] = @MATERIAL_ID
                    AND [CERTIFICATION_TYPE] = 'MATERIAL';
            END;
        END;

		FIN:
        SELECT
            1 AS [Resultado]
           ,'Proceso Exitoso' [Mensaje]
           ,0 [Codigo]
           ,CAST(@ID AS VARCHAR) [DbData];

    END TRY
    BEGIN CATCH
        SELECT
            -1 AS [Resultado]
           ,ERROR_MESSAGE() [Mensaje]
           ,@@error [Codigo];
    END CATCH;

END;