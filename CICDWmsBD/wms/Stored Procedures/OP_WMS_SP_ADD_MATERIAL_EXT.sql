-- =============================================
-- Autor:				JOSE.GARCIA
-- Fecha de Creacion: 	17-ENERO-17 
-- Description:			GENERA LOS MATERIALES A INSERTAR 
--						EN EL INVENTARIO EXTERNO

/*
-- Ejemplo de Ejecucion:
				--
				EXEC [wms].[OP_WMS_SP_ADD_MATERIAL_EXT]
				 @CLIENTE ='C00300'
                ,@USUARIO ='ADMIN'
				
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_ADD_MATERIAL_EXT]
( @CLIENTE VARCHAR(50)
  ,@USUARIO VARCHAR(50)
)
AS
BEGIN 

    -----------------------------------------------------------------
	--GENERA LOS MATERIALES
	-----------------------------------------------------------------

	SELECT 
		@CLIENTE [CLIENT_OWNER],
		@CLIENTE +'/'+ CEI.CODIGO [MATERIAL_ID],
		CEI.CODIGO [BARCODE_ID],
		CEI.DESCRIPCION [MATERIAL_NAME],
		CEI.DESCRIPCION [SHORT_NAME],
		0 [VOLUME_FACTOR],
		'' [MATERIAL_CLASS],
		0 [HIGH],
		0[LENGTH],
		0[WIDTH],
		0[MAX_X_BIN],
		0[SCAN_BY_ONE],
		0[REQUIRES_LOGISTICS_INFO],
		0[WEIGTH],
		GETDATE() [LAST_UPDATED],
		@USUARIO [LAST_UPDATED_BY],
		0[IS_CAR],
		0[BATCH_REQUESTED]
	INTO #TEMP
	FROM [wms].OP_WMS_CHARGE_EXTERNAL_INVENTORY CEI
	LEFT JOIN [wms].[OP_WMS_MATERIALS] MT 
		ON (MT.MATERIAL_ID = @CLIENTE +'/'+ CEI.CODIGO)


	-----------------------------------------------------------------
	--CORROBORA SI EXISTEN LOS MATERIALES
	-----------------------------------------------------------------

	BEGIN TRY
      MERGE [wms].[OP_WMS_MATERIALS] MT
	  USING (SELECT * FROM #TEMP ) AS ME
	  ON MT.MATERIAL_ID  = ME.MATERIAL_ID
      WHEN MATCHED THEN 
	   
	  UPDATE SET 
	   MT.LAST_UPDATED = GETDATE()
	  ,MT.LAST_UPDATED_BY = @USUARIO
	
WHEN NOT MATCHED THEN 

INSERT 
           ([CLIENT_OWNER]
			,[MATERIAL_ID]
			,[BARCODE_ID]
			,[MATERIAL_NAME]
			,[SHORT_NAME]
			,[VOLUME_FACTOR]
			,[MATERIAL_CLASS]
			,[HIGH]
			,[LENGTH]
			,[WIDTH]
			,[MAX_X_BIN]
			,[SCAN_BY_ONE]
			,[REQUIRES_LOGISTICS_INFO]
			,[WEIGTH]
			,[LAST_UPDATED]
			,[LAST_UPDATED_BY]
			,[IS_CAR]
			,[BATCH_REQUESTED])
     VALUES( ME.[CLIENT_OWNER]
			,ME.[MATERIAL_ID]
			,ME.[BARCODE_ID]
			,ME.[MATERIAL_NAME]
			,ME.[SHORT_NAME]
			,ME.[VOLUME_FACTOR]
			,ME.[MATERIAL_CLASS]
			,ME.[HIGH]
			,ME.[LENGTH]
			,ME.[WIDTH]
			,ME.[MAX_X_BIN]
			,ME.[SCAN_BY_ONE]
			,ME.[REQUIRES_LOGISTICS_INFO]
			,ME.[WEIGTH]
			,ME.[LAST_UPDATED]
			,ME.[LAST_UPDATED_BY]
			,ME.[IS_CAR]
			,ME.[BATCH_REQUESTED]
		   );

IF @@error = 0 BEGIN		
		 RETURN '1'--SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje --,  0 Codigo, '0' DbData
	END		
	ELSE BEGIN
		
		SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo
	END

END TRY
BEGIN CATCH     
	 SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo 
END CATCH
END