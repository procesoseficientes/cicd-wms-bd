
-- =============================================
-- Autor:				jose.garcia
-- Fecha de Creacion: 	06-01-2016
-- Description:			Actualiza el inventario por licencia o inserta la cantidad nueva del 
--						nuevo codigo que se esta creando

-- Autor:					marvin.solares
-- Fecha de Creacion: 		7/9/2018 GForce@FocaMonje 
-- Description:			    asigna el costo del material a la transaccion

/*
-- Ejemplo de Ejecucion:				
				--
				exec [wms].[OP_WMS_SP_UPDATE_OR_INSERT_OP_WMS_INV_X_LICENSE_EXT] 
						@CUSTOMER ='C00330'
						,@USER  ='ADMIN'
						,@ACUERDO_COMERCIAL ='12'
						,@RESULTADO =''
						,@LICENSE_ID='305866'
						,@POLIZA = ''
						,@LOCATION = ''
						,@WAREHOUSE = ''
				--				
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_UPDATE_OR_INSERT_OP_WMS_INV_X_LICENSE_EXT]
	@CUSTOMER VARCHAR(MAX)
	,@USER VARCHAR(50)
	,@ACUERDO_COMERCIAL VARCHAR(25)
	,@RESULTADO AS VARCHAR(250) = '' OUTPUT
	,@LICENSE_ID INT
	,@POLIZA VARCHAR(50)
	,@LOCATION VARCHAR(50)
	,@WAREHOUSE VARCHAR(50)
AS
BEGIN TRY
  -- BEGIN
	MERGE [wms].[OP_WMS_INV_X_LICENSE] [I]
	USING
		(SELECT
				*
			FROM
				[wms].[OP_WMS_CHARGE_EXTERNAL_INVENTORY])
		AS [EXT]
	ON [I].[MATERIAL_ID] = @CUSTOMER + '/' + [EXT].[CODIGO]
		AND [I].[LICENSE_ID] = @LICENSE_ID
	WHEN MATCHED THEN
		UPDATE SET
				[I].[QTY] = [I].[QTY] + [EXT].[QTY]--(CASE WHEN @signo='+' THEN I.QTY + @QTY  ELSE I.QTY-@QTY END )
				,[I].[LAST_UPDATED] = GETDATE()
				,[I].[LAST_UPDATED_BY] = @USER
				,[I].[DATE_EXPIRATION] = GETDATE()
				,[I].[ENTERED_QTY] = [EXT].[QTY]
	WHEN NOT MATCHED THEN
		INSERT
				(
					[LICENSE_ID]
					,[MATERIAL_ID]
					,[MATERIAL_NAME]
					,[QTY]
					,[VOLUME_FACTOR]
					,[WEIGTH]
					,[SERIAL_NUMBER]
					,[COMMENTS]
					,[LAST_UPDATED]
					,[LAST_UPDATED_BY]
					,[BARCODE_ID]
					,[TERMS_OF_TRADE]
					,[STATUS]
					,[CREATED_DATE]
					,[DATE_EXPIRATION]
					,[BATCH]
					,[ENTERED_QTY]
					,[VIN]
					,[HANDLE_SERIAL]
					,[IS_EXTERNAL_INVENTORY]
				)
		VALUES	(
					@LICENSE_ID
					,@CUSTOMER + '/' + [EXT].[CODIGO]
					,[EXT].[DESCRIPCION]
					,[EXT].[QTY]
					,0
					,0
					,'N/A'
					,'N/A'
					,GETDATE()
					,@USER
					,@CUSTOMER + '/' + [EXT].[CODIGO]
					,@ACUERDO_COMERCIAL
					,'PROCESSED'
					,GETDATE()
					,GETDATE()
					,@LICENSE_ID
					,[EXT].[QTY]
					,''
					,0
					,1
				);



	MERGE [wms].[OP_WMS_TRANS] [I]
	USING
		(SELECT
				*
			FROM
				[wms].[OP_WMS_CHARGE_EXTERNAL_INVENTORY])
		AS [EXT]
	ON [I].[MATERIAL_CODE] = @CUSTOMER + '/' + [EXT].[CODIGO]
		AND [I].[LICENSE_ID] = @LICENSE_ID
		AND [I].[CODIGO_POLIZA] = @POLIZA
	WHEN MATCHED THEN
		UPDATE SET
				[I].[QUANTITY_UNITS] = [I].[QUANTITY_UNITS]
				+ [EXT].[QTY]--(CASE WHEN @signo='+' THEN I.QTY + @QTY  ELSE I.QTY-@QTY END )
	WHEN NOT MATCHED THEN
		INSERT
				(
					[TERMS_OF_TRADE]
					,[TRANS_DATE]
					,[LOGIN_ID]
					,[LOGIN_NAME]
					,[TRANS_TYPE]
					,[TRANS_DESCRIPTION]
					,[TRANS_EXTRA_COMMENTS]
					,[MATERIAL_BARCODE]
					,[MATERIAL_CODE]
					,[MATERIAL_DESCRIPTION]
					,[MATERIAL_TYPE]
					,[MATERIAL_COST]
					,[SOURCE_LICENSE]
					,[TARGET_LICENSE]
					,[SOURCE_LOCATION]
					,[TARGET_LOCATION]
					,[CLIENT_OWNER]
					,[CLIENT_NAME]
					,[QUANTITY_UNITS]
					,[SOURCE_WAREHOUSE]
					,[TARGET_WAREHOUSE]
					,[TRANS_SUBTYPE]
					,[CODIGO_POLIZA]
					,[LICENSE_ID]
					,[STATUS]
					,[TRANS_MT2]
					,[VIN]
					,[TASK_ID]
					,[SERIAL]
					,[BATCH]
					,[DATE_EXPIRATION]
					,[CODE_SUPPLIER]
					,[NAME_SUPPLIER]
				)
		VALUES	(
					@ACUERDO_COMERCIAL
					,CURRENT_TIMESTAMP
					,@USER
					,(SELECT
							*
						FROM
							[wms].[OP_WMS_FUNC_GETLOGIN_NAME](@USER))
					,'INGRESO_GENERAL'
					,ISNULL((SELECT
									*
								FROM
									[wms].[OP_WMS_FUNC_GETTRANS_DESC]('INGRESO_GENERAL')),
							'INGRESO_GENERAL')
					,'N/A'
					,[EXT].[CODIGO]
					,@CUSTOMER + '/' + [EXT].[CODIGO]
					,[EXT].[DESCRIPCION]
					,NULL
					,[wms].[OP_WMS_FN_GET_MATERIAL_COST_BY_MATERIAL](@CUSTOMER + '/' + [EXT].[CODIGO],
											@CUSTOMER)
					,@LICENSE_ID
					,@LICENSE_ID
					,@LOCATION
					,@LOCATION
					,@CUSTOMER
					,(SELECT
							*
						FROM
							[wms].[OP_WMS_FUNC_GETCLIENT_NAME](@CUSTOMER))
					,[EXT].[QTY]
					,@WAREHOUSE
					,@WAREHOUSE
					,''
					,@POLIZA
					,@LICENSE_ID
					,'PROCESSED'
					,0
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
				);




	DECLARE	@RESULT INT;
	SELECT
		@RESULT = COUNT(*)
	FROM
		[wms].[OP_WMS_INV_X_LICENSE]
	WHERE
		[LICENSE_ID] = @LICENSE_ID;

	RETURN @RESULT;



END TRY
BEGIN CATCH
	SET @RESULTADO = 'ERROR EN CODIGO -> ' + @CUSTOMER
		+ ' <- ';
	SELECT
		@RESULTADO AS [RESULTADO];
END CATCH;