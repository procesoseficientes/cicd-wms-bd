-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	11/15/2017 @ Reborn - TEAM Sprint Eberhard
-- Description:			SP que inserta un registro de devolucion de inventario de una consignacion por medio de xml

-- Modificacion 1/19/2018 @ Reborn-Team Sprint Strom
					-- diego.as
					-- Se agrega validacion identificador de dispositivo

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_INSERT_DEVOLUTION_INVENTORY_BY_XML]
				@XML = '
					<Data>
					   <documentoDeDevolucion>
						  <SKU_COLLECTED_ID>-24</SKU_COLLECTED_ID>
						  <CUSTOMER_ID>SO-157169</CUSTOMER_ID>
						  <DOC_SERIE>GUA0032@ARIUM</DOC_SERIE>
						  <DOC_NUM>24</DOC_NUM>
						  <CODE_ROUTE>29</CODE_ROUTE>
						  <GPS_URL>14.6498937,-90.5397304</GPS_URL>
						  <POSTED_DATETIME>null</POSTED_DATETIME>
						  <POSTED_BY>null</POSTED_BY>
						  <LAST_UPDATE>2017/11/15 15:46:51</LAST_UPDATE>
						  <LAST_UPDATE_BY>Nl0015@SONDA</LAST_UPDATE_BY>
						  <TOTAL_AMOUNT>575.51</TOTAL_AMOUNT>
						  <IS_POSTED>0</IS_POSTED>
						  <IMG_1>data:image/jpeg;base64,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</IMG_1>
						  <IMG_2>undefined</IMG_2>
						  <IMG_3>undefined</IMG_3>
						  <SKU_COLLECTED_BO_ID>null</SKU_COLLECTED_BO_ID>
						  <DEVOLUTION_DETAIL>
							 <SKU_COLLECTED_ID>-24</SKU_COLLECTED_ID>
							 <CODE_SKU>CP0000527</CODE_SKU>
							 <QTY_SKU>6</QTY_SKU>
							 <IS_GOOD_STATE>1</IS_GOOD_STATE>
							 <LAST_UPDATE>2017/11/15 15:46:08</LAST_UPDATE>
							 <LAST_UPDATE_BY>Nl0015@SONDA</LAST_UPDATE_BY>
							 <SOURCE_DOC_TYPE>CONSIGNMENT</SOURCE_DOC_TYPE>
							 <SOURCE_DOC_NUM>-6</SOURCE_DOC_NUM>
							 <TOTAL_AMOUNT>311.76</TOTAL_AMOUNT>
							 <HANDLE_SERIAL>null</HANDLE_SERIAL>
							 <SERIAL_NUMBER>null</SERIAL_NUMBER>
						  </DEVOLUTION_DETAIL>
						  <DEVOLUTION_DETAIL>
							 <SKU_COLLECTED_ID>-24</SKU_COLLECTED_ID>
							 <CODE_SKU>I00000156</CODE_SKU>
							 <QTY_SKU>5</QTY_SKU>
							 <IS_GOOD_STATE>0</IS_GOOD_STATE>
							 <LAST_UPDATE>2017/11/15 15:46:17</LAST_UPDATE>
							 <LAST_UPDATE_BY>Nl0015@SONDA</LAST_UPDATE_BY>
							 <SOURCE_DOC_TYPE>CONSIGNMENT</SOURCE_DOC_TYPE>
							 <SOURCE_DOC_NUM>-6</SOURCE_DOC_NUM>
							 <TOTAL_AMOUNT>263.75</TOTAL_AMOUNT>
							 <HANDLE_SERIAL>null</HANDLE_SERIAL>
							 <SERIAL_NUMBER>null</SERIAL_NUMBER>
						  </DEVOLUTION_DETAIL>
					   </documentoDeDevolucion>
					   <dbuser>USONDA</dbuser>
					   <dbuserpass>SONDAServer1237710</dbuserpass>
					   <battery>58</battery>
					   <routeid>29</routeid>
					   <default_warehouse>V005</default_warehouse>
					   <deviceId>3b396881f40a8de3</deviceId>
					</Data>
				'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_INSERT_DEVOLUTION_INVENTORY_BY_XML](
	@XML XML
)
AS
BEGIN
	BEGIN TRY
		DECLARE @ID INT
		,@DEVOLUTION_ID INT
		,@DOC_SERIE VARCHAR(250)
		,@DOC_NUM INT
		,@CODE_SKU VARCHAR(250)
		,@IS_GOOD_STATE INT
		,@HANDLE_SERIAL INT
		,@SERIAL_NUMBER VARCHAR(150)
		,@QTY_SKU INT
		,@DEFAULT_WAREHOUSE VARCHAR(50)
		,@CODE_ROUTE VARCHAR(50)
		,@DEVICE_ID VARCHAR(50);

		--
		DECLARE @DEVOLUTION_DETAIL TABLE(
			[DEVOLUTION_ID] INT
			, [CODE_SKU] VARCHAR(250)
			, [QTY_SKU] INT
			, [IS_GOOD_STATE] INT
			, [POSTED_DATETIME] DATETIME
			, [POSTED_BY] VARCHAR(250)
			, [LAST_UPDATE] DATETIME
			, [LAST_UPDATE_BY] VARCHAR(250)
			, [TOTAL_AMOUNT] NUMERIC(18,6)
			, [SOURCE_DOC_TYPE] VARCHAR(50)
			, [SOURCE_DOC_NUM] INT
			, [HANDLE_SERIAL] INT
			, [SERIAL_NUMBER] VARCHAR(150)
		)

		--
		BEGIN TRY
		
		-- -------------------------------------------------------------------------------
		-- Se obtiene la bodega por defecto del operador
		-- -------------------------------------------------------------------------------
		SELECT 
			@DEFAULT_WAREHOUSE = x.Rec.query('./default_warehouse').value('.', 'varchar(50)')  
			,@CODE_ROUTE = x.Rec.query('./routeid').value('.', 'varchar(50)')  
			,@DEVICE_ID = x.Rec.query('./deviceId').value('.', 'varchar(50)')  
		FROM @XML.nodes('Data') AS x (Rec);

		-- -------------------------------------------------------------------------------
		-- Se valida el identificador del dispositivo
		-- -------------------------------------------------------------------------------
		EXEC [SONDA].[SONDA_SP_VALIDATE_DEVICE_ID_OF_USER_FOR_TRANSACTION] @CODE_ROUTE = @CODE_ROUTE , -- varchar(50)
			@DEVICE_ID = @DEVICE_ID -- varchar(50)
		

		-- -------------------------------------------------------------------------------
		-- Se obtiene el detalle del documento para procesarlo posteriormente
		-- -------------------------------------------------------------------------------
		INSERT INTO @DEVOLUTION_DETAIL
				(
					[CODE_SKU]
					,[QTY_SKU]
					,[IS_GOOD_STATE]
					,[POSTED_DATETIME]
					,[POSTED_BY]
					,[LAST_UPDATE]
					,[LAST_UPDATE_BY]
					,[TOTAL_AMOUNT]
					,[SOURCE_DOC_TYPE]
					,[SOURCE_DOC_NUM]
					,[HANDLE_SERIAL]
					,[SERIAL_NUMBER]
				)
		 SELECT
		   x.Rec.query('./CODE_SKU').value('.', 'varchar(250)')
		   ,x.Rec.query('./QTY_SKU').value('.', 'int')
		   ,x.Rec.query('./IS_GOOD_STATE').value('.', 'int')
		   ,GETDATE()
		   ,x.Rec.query('./LAST_UPDATE_BY').value('.', 'varchar(250)')
		   ,x.Rec.query('./LAST_UPDATE').value('.', 'varchar(250)')
		   ,x.Rec.query('./LAST_UPDATE_BY').value('.', 'varchar(250)')
		   ,x.Rec.query('./TOTAL_AMOUNT').value('.', 'numeric(18,6)')
		   ,x.Rec.query('./SOURCE_DOC_TYPE').value('.', 'varchar(250)')
		   ,x.Rec.query('./SOURCE_DOC_NUM').value('.', 'int')
		   ,CASE [x].[Rec].[query]('./HANDLE_SERIAL').[value]('.', 'varchar(50)') WHEN 'NULL' THEN NULL WHEN 'UNDEFINED' THEN NULL ELSE [x].[Rec].[query]('./HANDLE_SERIAL').[value]('.', 'int') END
		   ,CASE [x].[Rec].[query]('./SERIAL_NUMBER').[value]('.', 'varchar(150)') WHEN 'NULL' THEN NULL WHEN 'UNDEFINED' THEN NULL ELSE [x].[Rec].[query]('./SERIAL_NUMBER').[value]('.', 'varchar(150)') END
		  FROM @XML.nodes('Data/documentoDeDevolucion/DEVOLUTION_DETAIL') AS x (Rec);
		PRINT('OBTUVO DETALLE DE DOCUMENTO');
		-- -------------------------------------------------------------------------------
		-- Se obtiene el numero y serie del documento actual para su respectiva validacion
		-- -------------------------------------------------------------------------------
		 SELECT
		   @DOC_SERIE = x.Rec.query('./DOC_SERIE').value('.', 'varchar(250)')
		   ,@DOC_NUM = x.Rec.query('./DOC_NUM').value('.', 'int')
		  FROM @XML.nodes('Data/documentoDeDevolucion') AS x (Rec);

			-- --------------------------------------------------------------------------
			-- Se valida la existencia del documento actual
			-- --------------------------------------------------------------------------
			EXEC [SONDA].[SONDA_SP_VALIDATE_DEVOLUTION_INVENTORY] 
				@DOC_SERIE = @DOC_SERIE ,
				@DOC_NUM = @DOC_NUM,
				@DEVOLUTION_INVENTORY_HEADER_ID = @DEVOLUTION_ID OUTPUT
			
			-- --------------------------------------------------------------------------
			-- Si el documento actual ya existe se devuelve el id del mismo
			-- --------------------------------------------------------------------------
			IF(@DEVOLUTION_ID IS NOT NULL) BEGIN
				SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, @DEVOLUTION_ID AS DbData, 1 DocumentoYaExistiaEnServidor
			END
			ELSE BEGIN

			BEGIN TRANSACTION INSERT_DEVOLUTION_TRANS;

				-- --------------------------------------------------------------------------
				-- Si el documento actual no existe se procesa
				-- --------------------------------------------------------------------------
				INSERT INTO [SONDA].[SONDA_DEVOLUTION_INVENTORY_HEADER](
					[CODE_CUSTOMER]
					,[DOC_SERIE]
					,[DOC_NUM]
					,[CODE_ROUTE]
					,[GPS_URL]
					,[POSTED_DATETIME]
					,[POSTED_BY]
					,[LAST_UPDATE]
					,[LAST_UPDATE_BY] 
					,[TOTAL_AMOUNT] 
					,[IS_POSTED] 
					,[IMG_1]
					,[IMG_2]
					,[IMG_3]
				)
				SELECT 
					x.Rec.query('./CUSTOMER_ID').value('.', 'varchar(250)')
					,x.Rec.query('./DOC_SERIE').value('.', 'varchar(250)')
					,x.Rec.query('./DOC_NUM').value('.', 'int')
					,x.Rec.query('./CODE_ROUTE').value('.', 'varchar(50)')
					,x.Rec.query('./GPS_URL').value('.', 'varchar(250)')
					,GETDATE()
					,x.Rec.query('./CODE_ROUTE').value('.', 'varchar(50)')
					,GETDATE()
					,x.Rec.query('./LAST_UPDATE_BY').value('.', 'varchar(50)')
					,x.Rec.query('./TOTAL_AMOUNT').value('.', 'numeric(18,6)')
					,1
					,CASE [x].[Rec].[query]('./IMG_1').[value]('.', 'varchar(max)') WHEN 'NULL' THEN NULL WHEN 'UNDEFINED' THEN NULL ELSE [x].[Rec].[query]('./IMG_1').[value]('.', 'varchar(max)') END
					,CASE [x].[Rec].[query]('./IMG_2').[value]('.', 'varchar(max)') WHEN 'NULL' THEN NULL WHEN 'UNDEFINED' THEN NULL ELSE [x].[Rec].[query]('./IMG_2').[value]('.', 'varchar(max)') END
					,CASE [x].[Rec].[query]('./IMG_3').[value]('.', 'varchar(max)') WHEN 'NULL' THEN NULL WHEN 'UNDEFINED' THEN NULL ELSE [x].[Rec].[query]('./IMG_3').[value]('.', 'varchar(max)') END
				FROM @XML.nodes('Data/documentoDeDevolucion') AS x (Rec);

				-- --------------------------------------------------------------------------
				-- Se obtiene el id del documento procesado
				-- --------------------------------------------------------------------------
				SET @ID = SCOPE_IDENTITY()

				-- --------------------------------------------------------------------------
				-- Se inserta el detalle del documento
				-- --------------------------------------------------------------------------
				INSERT INTO [SONDA].[SONDA_DEVOLUTION_INVENTORY_DETAIL]
						(
							[DEVOLUTION_ID]
							,[CODE_SKU]
							,[QTY_SKU]
							,[IS_GOOD_STATE]
							,[POSTED_DATETIME]
							,[POSTED_BY]
							,[LAST_UPDATE]
							,[LAST_UPDATE_BY]
							,[TOTAL_AMOUNT]
							,[SOURCE_DOC_TYPE]
							,[SOURCE_DOC_NUM]
							,[HANDLE_SERIAL]
							,[SERIAL_NUMBER]
						)
				SELECT @ID
						,[CODE_SKU]
						,[QTY_SKU]
						,[IS_GOOD_STATE]
						,[POSTED_DATETIME]
						,[POSTED_BY]
						,[LAST_UPDATE]
						,[LAST_UPDATE_BY]
						,[TOTAL_AMOUNT]
						,[SOURCE_DOC_TYPE]
						,[SOURCE_DOC_NUM]
						,[HANDLE_SERIAL]
						,[SERIAL_NUMBER] 
				FROM @DEVOLUTION_DETAIL

			-- --------------------------------------------------------------------------
			-- Se procesa la devolucion del inventario
			-- --------------------------------------------------------------------------
				WHILE EXISTS(SELECT TOP 1 1 FROM @DEVOLUTION_DETAIL) BEGIN
					-- --------------------------------------------------------------------------
					-- Se obtiene el producto a devolver
					-- --------------------------------------------------------------------------
					SELECT TOP 1
						@CODE_SKU = DD.[CODE_SKU]
						,@IS_GOOD_STATE = DD.[IS_GOOD_STATE]
						,@HANDLE_SERIAL = DD.[HANDLE_SERIAL]
						,@QTY_SKU = DD.[QTY_SKU]
						,@SERIAL_NUMBER = DD.[SERIAL_NUMBER]
					FROM @DEVOLUTION_DETAIL AS DD

					--
					IF (@IS_GOOD_STATE = 1) BEGIN
						-- -------------------------------------------------------------------------------------
						-- Si el producto esta en BUEN ESTADO y NO MANEJA SERIE se suma a la bodega del vendedor
						-- -------------------------------------------------------------------------------------
						  IF (@HANDLE_SERIAL = 0) BEGIN
							
							UPDATE [SONDA].[SONDA_POS_SKUS]
							SET ON_HAND = (ON_HAND + @QTY_SKU)
							WHERE SKU = @CODE_SKU
							AND ROUTE_ID = @DEFAULT_WAREHOUSE
							
							-- -------------------------------------------------------------------------------------
							-- Se actualiza el inventario
							-- -------------------------------------------------------------------------------------
							UPDATE [SONDA].[SWIFT_INVENTORY]
							SET ON_HAND = (ON_HAND + @QTY_SKU)
							WHERE SKU = @CODE_SKU
							AND WAREHOUSE = @DEFAULT_WAREHOUSE

						  END
						  ELSE  BEGIN
							-- -------------------------------------------------------------------------------------
							-- Si el producto MANEJA SERIE se suma a la bodega del vendedor
							-- -------------------------------------------------------------------------------------
							UPDATE [SONDA].[SONDA_POS_SKUS]
							SET ON_HAND = (ON_HAND + 1)
							WHERE SKU = @CODE_SKU
							AND ROUTE_ID = @DEFAULT_WAREHOUSE
							AND REQUERIES_SERIE = 1
							--
							UPDATE [SONDA].[SWIFT_INVENTORY]
							SET ON_HAND = (ON_HAND + 1)
							WHERE SKU = @CODE_SKU
							AND WAREHOUSE = @DEFAULT_WAREHOUSE
							AND SERIAL_NUMBER = @SERIAL_NUMBER

						  END
					END

					-- ------------------------------------------------------------------------------------------------
					-- Se elimina el registro temporal que fue procesado
					-- ------------------------------------------------------------------------------------------------
					DELETE FROM @DEVOLUTION_DETAIL WHERE [CODE_SKU] = @CODE_SKU
					--

				END
			
			--
			COMMIT TRANSACTION [INSERT_DEVOLUTION_TRANS];

			--
			SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, @ID AS DbData, 0 DocumentoYaExistiaEnServidor

			END

		END TRY
		BEGIN CATCH
			--
			IF(XACT_STATE()) <> 0 BEGIN
				ROLLBACK TRANSACTION [INSERT_DEVOLUTION_TRANS];
			END
			

			--
			SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  0 Codigo, @ID AS DbData, 0 DocumentoYaExistiaEnServidor
		END CATCH

		
	END TRY
	BEGIN CATCH
		DECLARE @ERROR VARCHAR(MAX) = ERROR_MESSAGE();
		RAISERROR(@ERROR,16,1);
	END CATCH
END
