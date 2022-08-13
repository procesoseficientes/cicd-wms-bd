-- =============================================
-- Autor:	              hector.gonzalez
-- Fecha de Creacion: 	2017-01-27 @ Team ERGON - Sprint ERGON II
-- Description:	        Sp que marca un master pack como mandado a ERP 

-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-03-01 Team ERGON - Sprint ERGON IV
-- Description:	 SE modifica para que consulte DocNum en base al docEntry obtenido y lo guarde en la tabla 

-- Modificacion 22-Aug-17 @ Nexus Team Sprint CommandAndConquer
					-- alberto.ruiz
					-- Ajuste por intercompany, se obtiene el doc num de forma dinamica

-- Modificacion 9/19/2017 @ NEXUS-Team Sprint 
					-- rodrigo.gomez
					-- Se agrega el parametro @IS_IMPLOSION, cuando este es 1, se desbloquea el inventario del masterpack y se agrega una nueva linea a la tabla masterpack.

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_MARK_MASTER_PACK_AS_SEND_TO_ERP]
				  @MASTER_PACK_HEADER_ID = 3
				  ,@POSTED_RESPONSE = 'Exito al guardar en sap11 No. Salida: 14;No. Entrada: 29; 11'
				  ,@ERP_REFERENCE = 'No. Salida: 14;No. Entrada: 29;'
				  ,@IS_IMPLOSION = 0
			--
			SELECT * FROM [wms].OP_WMS_MASTER_PACK_HEADER WHERE MASTER_PACK_HEADER_ID = 3
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_MARK_MASTER_PACK_AS_SEND_TO_ERP] (
	@MASTER_PACK_HEADER_ID INT
	,@POSTED_RESPONSE VARCHAR(500)
	,@ERP_REFERENCE VARCHAR(50)
	,@IS_IMPLOSION INT
) AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		CREATE TABLE [#DOC] ([DocNum] INT);
		DECLARE
			@DOC_ENTRY_IN INT
			,@NEW_ERP_REFERENCE VARCHAR(50)
			,@DOC_ENTRY_OUT INT
			,@QUERY NVARCHAR(MAX)
			,@OWNER VARCHAR(50)
			,@INTERFACE_DATA_BASE_NAME VARCHAR(50)
			,@ERP_DATABASE VARCHAR(50)
			,@SCHEMA_NAME VARCHAR(50)
			,@DOC_NUM_IN INT
			,@DOC_NUM_OUT INT;

		-- ------------------------------------------------------------------------------------
		-- Obtiene el doc entry de la entrada 
		-- ------------------------------------------------------------------------------------
		SELECT TOP 1 
			@DOC_ENTRY_IN = CAST([wms].[OP_WMS_FN_GET_NUMERIC_VALUE_FROM_STRING]([VALUE]) AS INT)
		FROM [wms].[OP_WMS_FN_SPLIT](@ERP_REFERENCE, ';')
		WHERE [VALUE] <> ''
			AND [VALUE] LIKE '%Entrada%';

		-- ------------------------------------------------------------------------------------
		-- Obtiene el doc entry de la salida
		-- ------------------------------------------------------------------------------------
		SELECT TOP 1 
			@DOC_ENTRY_OUT = CAST([wms].[OP_WMS_FN_GET_NUMERIC_VALUE_FROM_STRING]([VALUE]) AS INT)
		FROM [wms].[OP_WMS_FN_SPLIT](@ERP_REFERENCE, ';')
		WHERE [VALUE] <> ''
			AND [VALUE] LIKE '%Salida%';

		-- ------------------------------------------------------------------------------------
		-- Obtiene el dueño de la recepcion
		-- ------------------------------------------------------------------------------------
		SELECT @OWNER = [MI].[SOURCE]
		FROM [wms].[OP_WMS_MASTER_PACK_HEADER] [MPH]
		INNER JOIN [wms].[OP_WMS_MATERIAL_INTERCOMPANY] [MI] ON (
			[MPH].[MATERIAL_ID] = ([MI].[SOURCE] + '/' + [MI].[ITEM_CODE])
		)
		WHERE [MASTER_PACK_HEADER_ID] = @MASTER_PACK_HEADER_ID;

		-- ------------------------------------------------------------------------------------
		-- Obtiene la fuente del dueño de la recepcion
		-- ------------------------------------------------------------------------------------
		SELECT 
			@INTERFACE_DATA_BASE_NAME = [ES].[INTERFACE_DATA_BASE_NAME]
			,@ERP_DATABASE = [C].[ERP_DATABASE]
			,@SCHEMA_NAME = [ES].[SCHEMA_NAME]
		FROM [wms].[OP_SETUP_EXTERNAL_SOURCE] [ES]
		INNER JOIN [wms].[OP_WMS_COMPANY] [C] ON ([C].[EXTERNAL_SOURCE_ID] = [ES].[EXTERNAL_SOURCE_ID])
		WHERE [C].[COMPANY_NAME] = @OWNER

		-- ------------------------------------------------------------------------------------
		-- Obtiene el doc num de la entrada 
		-- ------------------------------------------------------------------------------------
		SELECT
			@QUERY = N'EXEC ' + @INTERFACE_DATA_BASE_NAME + '.' + @SCHEMA_NAME +'.[SWIFT_SP_GET_ERP_DOC_NUM_FOR_DOCUMENT_BY_DOC_ENTRY]
					@DATABASE ='+ @ERP_DATABASE + '
					,@TABLE = ''OIGN''
					,@DOC_ENTRY = ' + CAST(@DOC_ENTRY_IN AS VARCHAR) + '
					,@DOC_NUM = @DOC_NUM_IN OUTPUT';
		--
		PRINT @QUERY;
		--
		EXEC sp_executesql @QUERY,N'@DOC_NUM_IN INT =-1 OUTPUT',@DOC_NUM_IN = @DOC_NUM_IN OUTPUT;
		/*SELECT
			@QUERY = N' INSERT INTO  #DOC SELECT [DocNum]  FROM  OPENQUERY([ARIUMSERVER], ''
      SELECT [O].[DocNum] FROM [Me_Llega_DB].[dbo].[OIGN] [O] WHERE  [O].[DocEntry] IN ('
			+ CAST(@DOC_ENTRY_IN AS VARCHAR) + ')
  '')
  ';
		--
		PRINT @QUERY;
		--
		EXEC (@QUERY);*/

		-- ------------------------------------------------------------------------------------
		-- Obtiene el doc num de la salida
		-- ------------------------------------------------------------------------------------
		SELECT
			@QUERY = N'EXEC ' + @INTERFACE_DATA_BASE_NAME + '.' + @SCHEMA_NAME +'.[SWIFT_SP_GET_ERP_DOC_NUM_FOR_DOCUMENT_BY_DOC_ENTRY]
					@DATABASE ='+ @ERP_DATABASE + '
					,@TABLE = ''OIGE''
					,@DOC_ENTRY = ' + CAST(@DOC_ENTRY_OUT AS VARCHAR)  + '
					,@DOC_NUM = @DOC_NUM_OUT OUTPUT';
		--
		PRINT @QUERY;
		--
		EXEC sp_executesql @QUERY,N'@DOC_NUM_OUT INT =-1 OUTPUT',@DOC_NUM_OUT = @DOC_NUM_OUT OUTPUT;


		/*SELECT
			@QUERY = N' INSERT INTO  #DOC SELECT [DocNum]  FROM  OPENQUERY([ARIUMSERVER], ''
      SELECT [O].[DocNum] FROM [Me_Llega_DB].[dbo].[OIGE] [O] WHERE  [O].[DocEntry] IN ('
			+ CAST(@DOC_ENTRY_OUT AS VARCHAR) + ')
  '')
  ';
  --
		PRINT @QUERY;
		--
		EXEC (@QUERY);*/


		/*SELECT
			@NEW_ERP_REFERENCE = 'No. Entrada:' + STUFF((SELECT ';No. Salida: ' + CAST([O].[DocNum] AS VARCHAR)
		FROM [#DOC] [O]
		FOR XML	PATH('')), 1, 12, '') + ';';*/

		SELECT @NEW_ERP_REFERENCE = 'No. Entrada:' + CAST(@DOC_NUM_IN AS VARCHAR) + ';No. Salida: ' + CAST(@DOC_NUM_OUT AS VARCHAR)

		-- ------------------------------------------------------------------------------------
		-- Actualiza el envio del master pack
		-- ------------------------------------------------------------------------------------
		UPDATE [wms].[OP_WMS_MASTER_PACK_HEADER]
		SET	
			[LAST_UPDATED] = GETDATE()
			,[LAST_UPDATE_BY] = 'INTERFACE'
			,[IS_POSTED_ERP] = 1
			,[POSTED_ERP] = GETDATE()
			,[POSTED_RESPONSE] = REPLACE(@POSTED_RESPONSE, @ERP_REFERENCE, @NEW_ERP_REFERENCE)
			,[ERP_REFERENCE] = @ERP_REFERENCE
			,[ERP_REFERENCE_DOC_NUM] = @NEW_ERP_REFERENCE
			,[EXPLODED] = 1
		WHERE [MASTER_PACK_HEADER_ID] = @MASTER_PACK_HEADER_ID;

		IF @IS_IMPLOSION = 1 
		BEGIN
			DECLARE @ID INT
					,@LICENSE_ID INT	
					,@MASTER_PACK_CODE VARCHAR(50)
					,@CODIGO_POLIZA NUMERIC
					,@LOGIN VARCHAR(50)
					,@QTY INT
			-- ------------------------------------------------------------------------------------
			-- Se obtienen los datos
			-- ------------------------------------------------------------------------------------
			SELECT @LICENSE_ID = [LICENSE_ID]
					,@MASTER_PACK_CODE = [MATERIAL_ID]
					,@CODIGO_POLIZA = [POLICY_HEADER_ID]
					,@LOGIN = [LAST_UPDATE_BY]
					,@QTY = [QTY]
			FROM [wms].[OP_WMS_MASTER_PACK_HEADER]
			WHERE [MASTER_PACK_HEADER_ID] = @MASTER_PACK_HEADER_ID
			-- ------------------------------------------------------------------------------------
			-- Inserta en masterpack header
			-- ------------------------------------------------------------------------------------
			INSERT  INTO [wms].[OP_WMS_MASTER_PACK_HEADER]
                    ( [LICENSE_ID] ,
                      [MATERIAL_ID] ,
                      [POLICY_HEADER_ID] ,
                      [LAST_UPDATED] ,
                      [LAST_UPDATE_BY] ,
                      [EXPLODED] ,
                      [EXPLODED_DATE] ,
                      [RECEPTION_DATE] ,
                      [IS_AUTHORIZED] ,
                      [ATTEMPTED_WITH_ERROR] ,
                      [IS_POSTED_ERP] ,
                      [POSTED_ERP] ,
                      [POSTED_RESPONSE] ,
                      [ERP_REFERENCE] ,
                      [ERP_REFERENCE_DOC_NUM] ,
                      [QTY] ,
                      [IS_IMPLOSION]
		            )
            VALUES  ( @LICENSE_ID , -- LICENSE_ID - int
                      @MASTER_PACK_CODE , -- MATERIAL_ID - varchar(50)
                      @CODIGO_POLIZA , -- POLICY_HEADER_ID - numeric
                      GETDATE() , -- LAST_UPDATED - datetime
                      @LOGIN , -- LAST_UPDATE_BY - varchar(50)
                      0 , -- EXPLODED - int
                      GETDATE() , -- EXPLODED_DATE - datetime
                      GETDATE() , -- RECEPTION_DATE - datetime
                      0 , -- IS_AUTHORIZED - int
                      0 , -- ATTEMPTED_WITH_ERROR - int
                      0 , -- IS_POSTED_ERP - int
                      NULL , -- POSTED_ERP - datetime
                      NULL , -- POSTED_RESPONSE - varchar(500)
                      NULL , -- ERP_REFERENCE - varchar(50)
                      NULL , -- ERP_REFERENCE_DOC_NUM - varchar(200)
                      @QTY , -- QTY - int
                      0  -- IS_IMPLOSION - int
		            );
			--
			SET @ID = SCOPE_IDENTITY();
			-- ------------------------------------------------------------------------------------
			-- Inserta en MASTER_PACK_DETAIL
			-- ------------------------------------------------------------------------------------
            INSERT  INTO [wms].[OP_WMS_MASTER_PACK_DETAIL]
                    ( [MASTER_PACK_HEADER_ID] ,
                      [MATERIAL_ID] ,
                      [QTY] 
		            )
            SELECT  @ID ,
                    [COMPONENT_MATERIAL] ,
                    [QTY]
            FROM    [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK]
            WHERE   [MASTER_PACK_CODE] = @MASTER_PACK_CODE;
			-- ------------------------------------------------------------------------------------
			-- Desbloquea el inventario en INV_X_LICENSE
			-- ------------------------------------------------------------------------------------
			UPDATE [wms].[OP_WMS_INV_X_LICENSE]
			SET [IS_BLOCKED] = 0
			WHERE [LICENSE_ID] = @LICENSE_ID
		END
		-- ------------------------------------------------------------------------------------
		-- Muestra el resultado final
		-- ------------------------------------------------------------------------------------
		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,'0' [DbData];
	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];
	END CATCH;
END;