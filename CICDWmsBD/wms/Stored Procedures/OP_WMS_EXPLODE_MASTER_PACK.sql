-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-01-26 @ Team ERGON - Sprint ERGON II
-- Description:	 Explosión de un masterpack bajo demanda. 

-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-03-10 Team ERGON - Sprint ERGON V
-- Description:	 Se agrega parámetro de material para explotar

-- Modificación: hector.gonzalez
-- Fecha de Creacion: 	2017-03-20 Team ERGON - Sprint ERGON V
-- Description:	 Se agrego validacion para ver si el Master pack tiene detalle al explotar

-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-07-07 Nexus@AgeOfEmpires
-- Description:	 Agregar un validación sobre el campo  EXPLODE_IN_RECEPTION, agregar validación por autorización automática.

-- Autor: hector.gonzalez
-- Fecha de Creacion: 	2017-09-04 @ Team REBORN - Sprint 
-- Description:	   Se agrego STATUS_ID al merge

-- Modificacion 19/9/2017 @ Reborn-Team Sprint Collin
-- rudi.garcia
-- Se agrego [LOCKED_BY_INTERFACES] al merge

-- Modificacion 9/20/2017 @ NEXUS-Team Sprint DuckHunt
-- rodrigo.gomez
-- Se agregan validaciones para que no explote las implosiones

-- Modificacion 2/21/2018 @LOGISTICA_wms
-- alejandro.ochoa
-- Se toma en cuenta la excepcion por bodega para la Exposion en Recepcion

-- Modificacion 5/30/2018 @ GForce-Team Sprint Dinosaurio
-- marvin.solares
-- Se modifica el state error para uso en translate para mostrar mensajes de error en version Android

-- Modificacion 7/06/2018 GForce@Elefante
-- marvin.solares
-- Se traslada el costo del material en todos los insert de transacciones

-- Autor:				marvin.solares
-- Fecha de Creacion: 	20190207 GForce@Suricato
-- Descripcion:			se graba informacion del proveedor en el registro de inventario por licencia para agilizar las consultas sobre el inventario

-- Modificacion:	Elder Lucas
-- Fecha:			25 de julio 2022
-- Descripción:		Se inserta tarea de explosión


/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_EXPLODE_MASTER_PACK] @LICENSE_ID = 4 , @MATERIAL_ID = 'MELLEGA/C00000493'
                                                ,@LAST_UPDATE_BY = 'PABS'
      SELECT * FROM [wms].[OP_WMS_MASTER_PACK_HEADER] [H]
      SELECT * FROM [wms].[OP_WMS_MASTER_PACK_DETAIL] [D] 
      SELECT * FROM [wms].[OP_WMS_INV_X_LICENSE]  WHERE [LICENSE_ID] = 177679
  SELECT * FROM [wms].OP_WMS_TRANS WHERE [LICENSE_ID] = 177679
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_EXPLODE_MASTER_PACK] (
		@LICENSE_ID INT
		,@MATERIAL_ID VARCHAR(50)
		,@LAST_UPDATE_BY VARCHAR(50)
		,@MANUAL_EXPLOTION INT = 1
		,@FROM_HAND_HELD INT = 0
	)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE
		@CLIENT_CODE VARCHAR(50)
		,@EXPLODE_IN_RECEPTION INT
		,@LOGIN_NAME VARCHAR(50)
		,@AUTOMATIC_AUTHORIZATION INT = 0
		,@LICENCE_WAREHOUSE VARCHAR(30);


  ---------------------------------------------------------------------------------
  -- Obtener datos
  ---------------------------------------------------------------------------------  
  ---Obtiene el cliente
	SELECT TOP 1
		@CLIENT_CODE = [L].[CLIENT_OWNER]
		,@LICENCE_WAREHOUSE = [L].[CURRENT_WAREHOUSE]
		,@LICENCE_WAREHOUSE = [L].[CURRENT_WAREHOUSE]
	FROM
		[wms].[OP_WMS_LICENSES] [L]
	WHERE
		[L].[LICENSE_ID] = @LICENSE_ID;

  ---Obtiene el id del material ya que el parámetro podria devolver ya sea barcode o alternative barcode.
  ---Obtiene la propiedad de Exposion en Recepcion tomando en cuenta las excepciones por bodega
	SELECT TOP 1
		@MATERIAL_ID = [M].[MATERIAL_ID]
		,@EXPLODE_IN_RECEPTION = ISNULL([PW].[VALUE],
										[M].[EXPLODE_IN_RECEPTION])
	FROM
		[wms].[OP_WMS_MATERIALS] [M]
	LEFT JOIN [wms].[OP_WMS_MATERIAL_PROPERTY_BY_WAREHOUSE] [PW] ON (
											[PW].[MATERIAL_ID] = [M].[MATERIAL_ID]
											AND [PW].[WAREHOUSE_ID] = @LICENCE_WAREHOUSE
											)
	LEFT JOIN [wms].[OP_WMS_MATERIAL_PROPERTY] [MP] ON (
											[MP].[MATERIAL_PROPERTY_ID] = [PW].[MATERIAL_PROPERTY_ID]
											AND [MP].[NAME] = 'EXPLODE_IN_RECEPTION'
											)
	WHERE
		(
			[M].[MATERIAL_ID] = @MATERIAL_ID
			OR [M].[BARCODE_ID] = @MATERIAL_ID
			OR [M].[ALTERNATE_BARCODE] = @MATERIAL_ID
		)
		AND [M].[CLIENT_OWNER] = @CLIENT_CODE;

	SELECT TOP 1
		@LOGIN_NAME = [L].[LOGIN_NAME]
	FROM
		[wms].[OP_WMS_LOGINS] [L]
	WHERE
		[L].[LOGIN_ID] = @LAST_UPDATE_BY;

	SELECT TOP 1
		@AUTOMATIC_AUTHORIZATION = CAST([C].[NUMERIC_VALUE] AS INT)
	FROM
		[wms].[OP_WMS_CONFIGURATIONS] [C]
	WHERE
		[C].[PARAM_TYPE] = 'SISTEMA'
		AND [C].[PARAM_GROUP] = 'MASTER_PACK_SETTINGS'
		AND [C].[PARAM_NAME] = 'AUTORIZA_ERP_AUTOMATICO';
						print 'g1'

  ---------------------------------------------------------------------------------
  -- Validación de datos 
  ---------------------------------------------------------------------------------  

   IF ((SELECT COUNT(*) FROM wms.OP_WMS_INV_X_LICENSE WHERE LICENSE_ID = @LICENSE_ID) > 1)
	BEGIN
		RAISERROR ('Debe tener solo un material para ser explotada, reubique el que desea explotar', 16, 101);
		RETURN;
	END

	IF NOT EXISTS ( SELECT TOP 1
						1
					FROM
						[wms].[OP_WMS_MASTER_PACK_HEADER] [PH]
					WHERE
						[PH].[LICENSE_ID] = @LICENSE_ID
						AND [PH].[MATERIAL_ID] = @MATERIAL_ID
						AND [PH].[IS_IMPLOSION] = 0 )
	BEGIN
		RAISERROR ('El material escaneado no existe en el control de master pack por licencia.', 16, 101);
		RETURN;
	END;

	IF EXISTS(
				SELECT TOP 1 1 FROM OP_WMS_ALZA.WMS.OP_WMS_FN_GET_COMMITED_INVENTORY_BY_LICENCE() WHERE LICENCE_ID = @LICENSE_ID
			)
			BEGIN

				RAISERROR ( 'La licencia ESTÁ COMPROMETIDA', 16, 101);

				RETURN;
			END

	IF EXISTS ( SELECT TOP 1
					1
				FROM
					[wms].[OP_WMS_MASTER_PACK_HEADER] [H]
				LEFT JOIN [wms].[OP_WMS_MASTER_PACK_DETAIL] [D] ON [H].[MASTER_PACK_HEADER_ID] = [D].[MASTER_PACK_HEADER_ID]
				WHERE
					[D].[MASTER_PACK_DETAIL_ID] IS NULL
					AND [H].[LICENSE_ID] = @LICENSE_ID
					AND [H].[MATERIAL_ID] = @MATERIAL_ID
					AND [H].[IS_IMPLOSION] = 0 )
	BEGIN
		RAISERROR ('El master pack seleccionado no puede explotar por que: no tiene Componentes configurados.', 16, 102);
		RETURN;
	END;

	--IF @MANUAL_EXPLOTION = 1
	--	AND @EXPLODE_IN_RECEPTION = 1
	--BEGIN
	--	RAISERROR ('No se permite explosión manual, por configuración de material de explosión en recepción.', 16, 103);
	--	RETURN;
	--END;

  --
	BEGIN TRY
		BEGIN TRANSACTION;

		IF EXISTS ( SELECT TOP 1
						1
					FROM
						[wms].[OP_WMS_MASTER_PACK_HEADER] [H]
					WHERE
						[H].[LICENSE_ID] = @LICENSE_ID
						AND [H].[MATERIAL_ID] = @MATERIAL_ID
						AND [H].[EXPLODED] = 1
						AND [H].[IS_IMPLOSION] = 0
						AND [H].[QTY] > 0 )
		BEGIN
			ROLLBACK;
			RAISERROR ('El master pack seleccionado ya ha realizado su explosión o ya no hay inventario disponible.', 16, 104);
			RETURN;
		END;
		print 'g1.1'
    ---------------------------------------------------------------------
    -- Operar inventario
    ---------------------------------------------------------------------
    -- Agregar inventario de componentes de masterpack
		MERGE [wms].[OP_WMS_INV_X_LICENSE] [IL]
		USING
			(SELECT
					[H].[LICENSE_ID] [LICENSE_ID]
					,[D].[MATERIAL_ID] [MATERIAL_ID]
					,[M].[MATERIAL_NAME] [MATERIAL_NAME]
					,[D].[QTY] * [H].[QTY] [QTY]
					,[M].[VOLUME_FACTOR] [VOLUME_FACTOR]
					,[M].[WEIGTH] [WEIGTH]
					,NULL [SERIAL_NUMBER]
					,'Explode In' [COMMENTS]
					,GETDATE() AS [LAST_UPDATED]
					,@LAST_UPDATE_BY [LAST_UPDATED_BY]
					,[M].[BARCODE_ID] [BARCODE_ID]
					,[P].[ACUERDO_COMERCIAL] [TERMS_OF_TRADE]
					,'PROCESSED' [STATUS]
					,GETDATE() AS [CREATED_DATE]
					,[D].[DATE_EXPIRATION] [DATE_EXPIRATION]
					,[D].[BATCH] [BATCH]
					,[D].[QTY] * [H].[QTY] [ENTERED_QTY]
					,NULL [VIN]
					,0 [HANDLE_SERIAL]
					,[IXL].[STATUS_ID]
					,[IXL].[LOCKED_BY_INTERFACES]
					,[IXL].[CODE_SUPPLIER]
					,[IXL].[NAME_SUPPLIER]
				FROM
					[wms].[OP_WMS_MASTER_PACK_HEADER] [H]
				INNER JOIN [wms].[OP_WMS_MASTER_PACK_DETAIL] [D] ON [H].[MASTER_PACK_HEADER_ID] = [D].[MASTER_PACK_HEADER_ID]
				INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [D].[MATERIAL_ID] = [M].[MATERIAL_ID]
				INNER JOIN [wms].[OP_WMS_POLIZA_HEADER] [P] ON [H].[POLICY_HEADER_ID] = [P].[DOC_ID]
				INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IXL] ON (
											[H].[LICENSE_ID] = [IXL].[LICENSE_ID]
											AND [H].[MATERIAL_ID] = [IXL].[MATERIAL_ID]
											)
				WHERE
					[H].[LICENSE_ID] = @LICENSE_ID
					AND [H].[MATERIAL_ID] = @MATERIAL_ID
					AND [H].[IS_IMPLOSION] = 0) AS [NIL]
		ON [NIL].[MATERIAL_ID] = [IL].[MATERIAL_ID]
			AND [IL].[LICENSE_ID] = [NIL].[LICENSE_ID]
		WHEN MATCHED THEN
			UPDATE SET
					[QTY] = [IL].[QTY] + [NIL].[QTY]
					,[COMMENTS] = 'Merge ExplodeIN'
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
						,[STATUS_ID]
						,[LOCKED_BY_INTERFACES]
						,[CODE_SUPPLIER]
						,[NAME_SUPPLIER]
					)
			VALUES	(
						[NIL].[LICENSE_ID]
						,[NIL].[MATERIAL_ID]
						,[NIL].[MATERIAL_NAME]
						,[NIL].[QTY]
						,[NIL].[VOLUME_FACTOR]
						,[NIL].[WEIGTH]
						,[NIL].[SERIAL_NUMBER]
						,[NIL].[COMMENTS]
						,[NIL].[LAST_UPDATED]
						,[NIL].[LAST_UPDATED_BY]
						,[NIL].[BARCODE_ID]
						,[NIL].[TERMS_OF_TRADE]
						,[NIL].[STATUS]
						,[NIL].[CREATED_DATE]
						,[NIL].[DATE_EXPIRATION]
						,[NIL].[BATCH]
						,[NIL].[ENTERED_QTY]
						,[NIL].[VIN]
						,[NIL].[HANDLE_SERIAL]
						,[NIL].[STATUS_ID]
						,[NIL].[LOCKED_BY_INTERFACES]
						,[NIL].[CODE_SUPPLIER]
						,[NIL].[NAME_SUPPLIER]
					);
print 'g2'
    ---------------------------------------------------------------------
    -- Crear transacciones 
    ---------------------------------------------------------------------
    -- Transaccion de salida
		INSERT	INTO [wms].[OP_WMS_TRANS]
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
					,[SOURCE_LOCATION]
					,[TARGET_LICENSE]
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
					,[SERIAL]
					,[BATCH]
					,[DATE_EXPIRATION]
				)
		SELECT
			[P].[ACUERDO_COMERCIAL] [TERMS_OF_TRADE]
			,GETDATE() [TRANS_DATE]
			,@LAST_UPDATE_BY [LOGIN_ID]
			,@LOGIN_NAME [LOGIN_NAME]
			,'EXPLODE_OUT' [TRANS_TYPE]
			,'EXPLODE OUT' [TRANS_DESCRIPTION]
			,'N/A' [TRANS_EXTRA_COMMENTS]
			,[M].[BARCODE_ID] [MATERIAL_BARCODE]
			,[H].[MATERIAL_ID] [MATERIAL_CODE]
			,[M].[MATERIAL_NAME] [MATERIAL_DESCRIPTION]
			,[M].[MATERIAL_CLASS] [MATERIAL_TYPE]
			,[M].[ERP_AVERAGE_PRICE] [MATERIAL_COST]
			,[H].[LICENSE_ID] [SOURCE_LICENSE]
			,[L].[CURRENT_LOCATION] [SOURCE_LOCATION]
			,NULL [TARGET_LICENSE]
			,[L].[CURRENT_LOCATION] [TARGET_LOCATION]
			,[P].[CLIENT_CODE] [CLIENT_OWNER]
			,[C].[CLIENT_NAME] [CLIENT_NAME]
			,CAST([H].[QTY] * -1 AS NUMERIC) [QUANTITY_UNITS]
			,[S].[WAREHOUSE_PARENT] [SOURCE_WAREHOUSE]
			,NULL [TARGET_WAREHOUSE]
			,'EXPLODE_OUT' [TRANS_SUBTYPE]
			,[P].[CODIGO_POLIZA] [CODIGO_POLIZA]
			,[L].[LICENSE_ID] [LICENSE_ID]
			,'PROCESSED' [STATUS]
			,NULL [SERIAL]
			,[I].[BATCH] [BATCH]
			,[I].[DATE_EXPIRATION] [DATE_EXPIRATION]
		FROM
			[wms].[OP_WMS_MASTER_PACK_HEADER] [H]
		INNER JOIN [wms].[OP_WMS_POLIZA_HEADER] [P] ON [H].[POLICY_HEADER_ID] = [P].[DOC_ID]
		INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [H].[MATERIAL_ID] = [M].[MATERIAL_ID]
		INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON [H].[LICENSE_ID] = [L].[LICENSE_ID]
		INNER JOIN [wms].[OP_WMS_VIEW_CLIENTS] [C] ON [P].[CLIENT_CODE] = [C].[CLIENT_CODE]
		INNER JOIN [wms].[OP_WMS_SHELF_SPOTS] [S] ON [S].[LOCATION_SPOT] = [L].[CURRENT_LOCATION]
		INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [I] ON [I].[LICENSE_ID] = [L].[LICENSE_ID]
											AND [H].[MATERIAL_ID] = [I].[MATERIAL_ID]
		INNER JOIN [wms].[OP_WMS_MASTER_PACK_DETAIL] [D] ON [H].[MASTER_PACK_HEADER_ID] = [D].[MASTER_PACK_HEADER_ID]
		WHERE
			[H].[LICENSE_ID] = @LICENSE_ID
			AND [H].[MATERIAL_ID] = @MATERIAL_ID
			AND [H].[IS_IMPLOSION] = 0;

			print 'g3'
    --transacción de entrada
		INSERT	INTO [wms].[OP_WMS_TRANS]
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
					,[SOURCE_LOCATION]
					,[TARGET_LICENSE]
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
					,[SERIAL]
					,[BATCH]
					,[DATE_EXPIRATION]
				)
		SELECT
			[P].[ACUERDO_COMERCIAL] [TERMS_OF_TRADE]
			,GETDATE() [TRANS_DATE]
			,@LAST_UPDATE_BY [LOGIN_ID]
			,@LOGIN_NAME [LOGIN_NAME]
			,'EXPLODE_IN' [TRANS_TYPE]
			,'EXPLODE IN' [TRANS_DESCRIPTION]
			,'N/A' [TRANS_EXTRA_COMMENTS]
			,[M].[BARCODE_ID] [MATERIAL_BARCODE]
			,[D].[MATERIAL_ID] [MATERIAL_CODE]
			,[M].[MATERIAL_NAME] [MATERIAL_DESCRIPTION]
			,[M].[MATERIAL_CLASS] [MATERIAL_TYPE]
			,[M].[ERP_AVERAGE_PRICE] [MATERIAL_COST]
			,[H].[LICENSE_ID] [SOURCE_LICENSE]
			,[L].[CURRENT_LOCATION] [SOURCE_LOCATION]
			,[H].[LICENSE_ID] [TARGET_LICENSE]
			,[L].[CURRENT_LOCATION] [TARGET_LOCATION]
			,[P].[CLIENT_CODE] [CLIENT_OWNER]
			,[C].[CLIENT_NAME] [CLIENT_NAME]
			,[D].[QTY] * [H].[QTY] [QUANTITY_UNITS]
			,[S].[WAREHOUSE_PARENT] [SOURCE_WAREHOUSE]
			,[S].[WAREHOUSE_PARENT] [TARGET_WAREHOUSE]
			,'EXPLODE_IN' [TRANS_SUBTYPE]
			,[P].[CODIGO_POLIZA] [CODIGO_POLIZA]
			,[L].[LICENSE_ID] [LICENSE_ID]
			,'PROCESSED' [STATUS]
			,NULL [SERIAL]
			,[D].[BATCH] [BATCH]
			,[D].[DATE_EXPIRATION] [DATE_EXPIRATION]
		FROM
			[wms].[OP_WMS_MASTER_PACK_DETAIL] [D]
		INNER JOIN [wms].[OP_WMS_MASTER_PACK_HEADER] [H] ON [D].[MASTER_PACK_HEADER_ID] = [H].[MASTER_PACK_HEADER_ID]
		INNER JOIN [wms].[OP_WMS_POLIZA_HEADER] [P] ON [H].[POLICY_HEADER_ID] = [P].[DOC_ID]
		INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [D].[MATERIAL_ID] = [M].[MATERIAL_ID]
		INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON [H].[LICENSE_ID] = [L].[LICENSE_ID]
		INNER JOIN [wms].[OP_WMS_VIEW_CLIENTS] [C] ON [P].[CLIENT_CODE] = [C].[CLIENT_CODE]
		INNER JOIN [wms].[OP_WMS_SHELF_SPOTS] [S] ON [S].[LOCATION_SPOT] = [L].[CURRENT_LOCATION]
		WHERE
			[H].[LICENSE_ID] = @LICENSE_ID
			AND [H].[MATERIAL_ID] = @MATERIAL_ID
			AND [H].[IS_IMPLOSION] = 0;
print 'g5'

    ---------------------------------------------------------------------------------
    -- While para validar si alguno de los productos explotados eran masterpack y asi registrarlos
    ---------------------------------------------------------------------------------  

		SELECT
			[D].[MASTER_PACK_DETAIL_ID]
			,[D].[MATERIAL_ID]
			,[D].[QTY] * [H].[QTY] [QTY]
			,[H].[LICENSE_ID]
			,[H].[MATERIAL_ID] [MASTER_PACK_MATERIAL_ID]
		INTO
			[#MASTERPACK_COMPONENTS]
		FROM
			[wms].[OP_WMS_MASTER_PACK_DETAIL] [D]
		INNER JOIN [wms].[OP_WMS_MASTER_PACK_HEADER] [H] ON [D].[MASTER_PACK_HEADER_ID] = [H].[MASTER_PACK_HEADER_ID]
		INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [D].[MATERIAL_ID] = [M].[MATERIAL_ID]
		WHERE
			[H].[LICENSE_ID] = @LICENSE_ID
			AND [H].[MATERIAL_ID] = @MATERIAL_ID
			AND [M].[IS_MASTER_PACK] = 1
			AND [H].[IS_IMPLOSION] = 0;

		DECLARE
			@M_MASTER_PACK_ID INT
			,@M_MATERIAL_ID VARCHAR(50)
			,@M_QTY INT
			,@M_LICENSE_ID INT
			,@M_MASTER_PACK_MATERIAL_ID VARCHAR(50);

				print 'Inicio del while'

		WHILE EXISTS ( SELECT TOP 1
							1
						FROM
							[#MASTERPACK_COMPONENTS] )
		BEGIN
			SELECT TOP 1
				@M_MASTER_PACK_ID = [MASTER_PACK_DETAIL_ID]
				,@M_MATERIAL_ID = [MATERIAL_ID]
				,@M_QTY = [QTY]
				,@M_LICENSE_ID = [LICENSE_ID]
				,@M_MASTER_PACK_MATERIAL_ID = [MASTER_PACK_MATERIAL_ID]
			FROM
				[#MASTERPACK_COMPONENTS];

				print @M_MATERIAL_ID
				print @M_LICENSE_ID
				print @LAST_UPDATE_BY
				print @M_QTY
			EXEC [wms].[OP_WMS_SP_INSERT_MASTER_PACK] @MATERIAL_ID_MASTER_PACK = @M_MATERIAL_ID,
				@LICENSE_ID = @M_LICENSE_ID,
				@LAST_UPDATE_BY = @LAST_UPDATE_BY,
				@QTY = @M_QTY;

			DELETE
				[#MASTERPACK_COMPONENTS]
			WHERE
				@M_MASTER_PACK_ID = [MASTER_PACK_DETAIL_ID];
		END;



    -- Rebajar inventario de masterpack 
		UPDATE
			[wms].[OP_WMS_INV_X_LICENSE]
		SET	
			[QTY] = 0
		WHERE
			[LICENSE_ID] = @LICENSE_ID
			AND @MATERIAL_ID = [MATERIAL_ID];


    ---------------------------------------------------------------------------------
    -- Marcar como explotada la transacción
    ---------------------------------------------------------------------------------  
		UPDATE
			[wms].[OP_WMS_MASTER_PACK_HEADER]
		SET	
			[EXPLODED] = 1
			,[EXPLODED_DATE] = GETDATE()
			,[IS_AUTHORIZED] = @AUTOMATIC_AUTHORIZATION
			,[LAST_UPDATED] = GETDATE()
			,[LAST_UPDATE_BY] = @LAST_UPDATE_BY
		WHERE
			[LICENSE_ID] = @LICENSE_ID
			AND [MATERIAL_ID] = @MATERIAL_ID
			AND [IS_IMPLOSION] = 0;


		--Realizamos insección de tarea en OP_WMS_TASK_LIST
		IF(@FROM_HAND_HELD = 1)
		BEGIN
		INSERT INTO wmS.OP_WMS_TASK_LIST
		(
			TASK_TYPE,
			TASK_SUBTYPE,
			TASK_OWNER,
			TASK_ASSIGNEDTO,
			TASK_COMMENTS,
			ASSIGNED_DATE,
			QUANTITY_PENDING,
			QUANTITY_ASSIGNED,
			CODIGO_POLIZA_SOURCE,
			LICENSE_ID_SOURCE,
			REGIMEN,
			IS_COMPLETED,
			IS_DISCRETIONAL,
			MATERIAL_ID,
			BARCODE_ID,
			MATERIAL_NAME,
			WAREHOUSE_SOURCE,
			WAREHOUSE_TARGET,
			LOCATION_SPOT_SOURCE,
			LOCATION_SPOT_TARGET,
			CLIENT_OWNER,
			CLIENT_NAME,
			ACCEPTED_DATE,
			COMPLETED_DATE,
			IS_ACCEPTED,
			IS_FROM_ERP,
			FROM_MASTERPACK,
			MASTER_PACK_CODE,
			STATUS_CODE,
			ORDER_NUMBER
		)
		SELECT TOP 1
		'MASTER_PACK',--TASK_TYPE
		'DESARMADO_MASTERPACK',--TASK_SUBTYPE
		@LOGIN_NAME,--TASK_OWNER
		@LOGIN_NAME,--TASK_ASSIGNEDTO
		CONCAT('TAREA DE DESARMADO#', MPH.MASTER_PACK_HEADER_ID),--TASK_COMMENTS
		GETDATE(),--ASSIGNED_DATE
		0,--QUANTITY_PENDING
		MPH.QTY,--QUANTITY_ASSIGNED
		L.CODIGO_POLIZA,--CODIGO_POLIZA_SOURCE
		L.LICENSE_ID,--LICENSE_ID_SOURCE
		'GENERAL',--REGIMEN
		1,--IS_COMPLETED
		1,--IS_DISCRETIONAL
		M.MATERIAL_ID, --MATERIAL_ID
		M.BARCODE_ID, --BARCODE_ID
		M.MATERIAL_NAME, --MATERIAL_NAME
		L.CURRENT_WAREHOUSE, --WAREHOUSE_SOURCE
		L.CURRENT_WAREHOUSE, --WAREHOUSE_TARGET
		L.CURRENT_LOCATION, --LOCATION_SPOT_SOURCE
		L.CURRENT_LOCATION, --LOCATION_SPOT_SOURCE
		@CLIENT_CODE,--CLIENT_OWNER
		VC.CLIENT_NAME,--CLIENT_NAME
		GETDATE(), --ACCEPTED_DATE
		GETDATE(), --COMPLETED_DATE
		1,--IS_ACCEPTED
		1,--IS_FROM_ERP
		1,--FROM_MASTERPACK
		M.MATERIAL_ID, --MASTERPACK_CODE
		MBL.STATUS_CODE, --STATUS_CODE
		MPH.MASTER_PACK_HEADER_ID
		FROM wms.OP_WMS_LICENSES L
		INNER JOIN wms.OP_WMS_MASTER_PACK_HEADER MPH ON L.LICENSE_ID = MPH.LICENSE_ID AND MPH.MATERIAL_ID = @MATERIAL_ID
		INNER JOIN wms.OP_WMS_MATERIALS M ON M.MATERIAL_ID = @MATERIAL_ID
		--INNER JOIN wms.OP_WMS_COMPONENTS_BY_MASTER_PACK CBM ON CBM.MASTER_PACK_CODE = M.MATERIAL_ID
		INNER JOIN wms.OP_WMS_VIEW_CLIENTS VC on VC.CLIENT_CODE = @CLIENT_CODE
		INNER JOIN WMS.OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE MBL ON MBL.LICENSE_ID = L.LICENSE_ID
		WHERE L.LICENSE_ID = @LICENSE_ID
		END

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION;
		END;

		DECLARE
			@ErrMsg VARCHAR(4000)
			,@Errseverity INT;

		SELECT
			@ErrMsg = ERROR_MESSAGE()
			,@Errseverity = ERROR_SEVERITY();

		RAISERROR (@ErrMsg, @Errseverity, 1);
	END CATCH;

END;
GO

