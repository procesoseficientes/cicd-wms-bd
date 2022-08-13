-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-02-21 @ Team ERGON - Sprint ERGON 
-- Description:	        

-- Modificacion 6/12/2018 @ GFORCE-Team Sprint Dinosaurio
					-- rodrigo.gomez
					-- Actualiza tambien el encabezado

-- Autor:					marvin.solares
-- Fecha de Creacion: 		7/9/2018 GForce@FocaMonje 
-- Description:			    asigna el costo del material a la transaccion

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].[OP_WMS_SP_RECOUNT_LOCATION] @LOGIN= 'ACAMACHO' 
, @TASK_ID = 7
, @LOCATION = 'B02-P01-F01-NU'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_RECOUNT_LOCATION] (
		@LOGIN VARCHAR(25)
		,@TASK_ID INT
		,@LOCATION VARCHAR(25)
	)
AS
BEGIN
	SET NOCOUNT ON;
  --

	DECLARE	@RESULT VARCHAR(200) = 'Error al marcar ubicacion para recontar.';

	BEGIN TRY
		BEGIN TRANSACTION;

		DELETE
			[E]
		FROM
			[wms].[OP_WMS_PHYSICAL_COUNTS_EXECUTION] [E]
		INNER JOIN [wms].[OP_WMS_PHYSICAL_COUNTS_DETAIL] [D] ON [E].[PHYSICAL_COUNT_DETAIL_ID] = [D].[PHYSICAL_COUNT_DETAIL_ID]
		INNER JOIN [wms].[OP_WMS_PHYSICAL_COUNTS_HEADER] [H] ON [D].[PHYSICAL_COUNT_HEADER_ID] = [H].[PHYSICAL_COUNT_HEADER_ID]
		WHERE
			[E].[LOCATION] = @LOCATION
			AND [H].[TASK_ID] = @TASK_ID
			AND [D].[ASSIGNED_TO] = @LOGIN
			AND [E].[EXECUTED_BY] = @LOGIN;
      

		UPDATE
			[CD]
		SET	
			[STATUS] = 'IN_PROGRESS'
		FROM
			[wms].[OP_WMS_PHYSICAL_COUNTS_DETAIL] [CD]
		INNER JOIN [wms].[OP_WMS_PHYSICAL_COUNTS_HEADER] [CH] ON [CD].[PHYSICAL_COUNT_HEADER_ID] = [CH].[PHYSICAL_COUNT_HEADER_ID]
		INNER JOIN [wms].[OP_WMS_TASK] [T] ON [CH].[TASK_ID] = [T].[TASK_ID]
		WHERE
			[CH].[TASK_ID] = @TASK_ID
			AND [CD].[ASSIGNED_TO] = @LOGIN
			AND [CD].[LOCATION] = @LOCATION;


		UPDATE
			[wms].[OP_WMS_PHYSICAL_COUNTS_HEADER]
		SET	
			[STATUS] = 'IN_PROGRESS'
		WHERE
			[TASK_ID] = @TASK_ID;

		UPDATE
			[wms].[OP_WMS_TASK]
		SET	
			[IS_COMPLETE] = 0
			,[COMPLETED_DATE] = NULL
		WHERE
			[TASK_ID] = @TASK_ID;
       ---------------------------------------------------------------------------------
      -- Insertar transaccion de DETALLE de conteo 
      ---------------------------------------------------------------------------------
		DECLARE
			@BARCODE_ID VARCHAR(25)
			,@MATERIAL_DESCRIPTION VARCHAR(200)
			,@CLIENT_OWNER VARCHAR(25)
			,@CLIENT_NAME VARCHAR(150)
			,@WAREHOUSE VARCHAR(25)
			,@MATERIAL_ID VARCHAR(25)
			,@LICENSE_ID NUMERIC
			,@QTY_SCANNED NUMERIC
			,@SERIAL VARCHAR(50)
			,@BATCH VARCHAR(50)
			,@EXPIRATION_DATE DATE;

		SELECT TOP 1
			@BARCODE_ID = [M].[MATERIAL_BARCODE]
			,@MATERIAL_DESCRIPTION = [M].[MATERIAL_DESCRIPTION]
			,@CLIENT_OWNER = [M].[CLIENT_OWNER]
			,@CLIENT_NAME = [M].[CLIENT_NAME]
			,@WAREHOUSE = [M].[TARGET_WAREHOUSE]
			,@MATERIAL_ID = [M].[MATERIAL_CODE]
			,@LICENSE_ID = [M].[TARGET_LICENSE]
			,@QTY_SCANNED = [M].[QUANTITY_UNITS]
			,@SERIAL = [M].[SERIAL]
			,@BATCH = [M].[BATCH]
			,@EXPIRATION_DATE = [M].[DATE_EXPIRATION]
		FROM
			[wms].[OP_WMS_TRANS] [M]
		WHERE
			[M].[TARGET_LOCATION] = @LOCATION
			AND [M].[LOGIN_ID] = @LOGIN
			AND [M].[TASK_ID] = @TASK_ID;
		PRINT 'LLEGO HASTA AQUI';

		IF @BARCODE_ID IS NOT NULL
		BEGIN
			INSERT	INTO [wms].[OP_WMS_TRANS]
					(
						[TRANS_DATE]
						,[LOGIN_ID]
						,[LOGIN_NAME]
						,[TRANS_TYPE]
						,[TRANS_DESCRIPTION]
						,[MATERIAL_BARCODE]
						,[MATERIAL_CODE]
						,[MATERIAL_DESCRIPTION]
						,[MATERIAL_COST]
						,[TARGET_LICENSE]
						,[TARGET_LOCATION]
						,[CLIENT_OWNER]
						,[CLIENT_NAME]
						,[QUANTITY_UNITS]
						,[TARGET_WAREHOUSE]
						,[LICENSE_ID]
						,[STATUS]
						,[TASK_ID]
						,[SERIAL]
						,[BATCH]
						,[DATE_EXPIRATION]
						,[TRANS_SUBTYPE]
						,[SOURCE_LOCATION]
					)
			VALUES
					(
						GETDATE()
						,@LOGIN
						,(SELECT TOP 1
								[LOGIN_NAME]
							FROM
								[wms].[OP_WMS_FUNC_GETLOGIN_NAME](@LOGIN))
						,'CONTEO_FISICO'
						,'CONTEO FISICO'
						,@BARCODE_ID
						,@MATERIAL_ID
						,@MATERIAL_DESCRIPTION
						,[wms].[OP_WMS_FN_GET_MATERIAL_COST_BY_MATERIAL](@MATERIAL_ID,
											@CLIENT_OWNER)
						,@LICENSE_ID
						,@LOCATION
						,@CLIENT_OWNER
						,@CLIENT_NAME
						,@QTY_SCANNED
						,@WAREHOUSE
						,@LICENSE_ID
						,'IN PROGRESS'
						,@TASK_ID
						,@SERIAL
						,@BATCH
						,@EXPIRATION_DATE
						,'CONTEO UBICACION'
						,''
					);
		END;



		COMMIT TRANSACTION;

		SET @RESULT = 'OK';
		SELECT
			@RESULT [RESULT];    
      
	END TRY
	BEGIN CATCH

		ROLLBACK TRANSACTION;
		SELECT
			@RESULT + ERROR_MESSAGE() [RESULT]; 

	END CATCH;

END;