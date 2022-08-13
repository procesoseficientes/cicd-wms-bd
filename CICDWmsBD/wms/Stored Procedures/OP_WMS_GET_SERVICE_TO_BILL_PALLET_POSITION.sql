-- =============================================
-- Autor:        pablo.aguilar
-- Fecha de Creacion:   09-Nov-16 @ A-TEAM Sprint 4 
-- Description:      SP que obtienen todos los servicios a cobrar de pallet position

-- Modificacion 10-Jan-17 @ A-Team Sprint Balder
-- alberto.ruiz
-- Se ajusto para que cobre con frecuencia y por ubicacion

-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-03-27 Team ERGON - Sprint ERGON HYPER
-- Description:	Se agrega como resultado de la consulta el codigo del acuerdo comercial utilizado para el cobro

/*
-- Ejemplo de Ejecucion:
      EXEC [wms].OP_WMS_GET_SERVICE_TO_BILL_PALLET_POSITION 
		@PROCESS_DATE = '2017-03-10 00:00:00.000'
		,@LAST_UPDATED_BY = 'AUTOMATIC_SERVICE'
		,@TYPE = 'AUTOMATIC_SERVICE'
  select 1 
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_GET_SERVICE_TO_BILL_PALLET_POSITION] (
		@PROCESS_DATE DATETIME
		,@LAST_UPDATED_BY VARCHAR(25)
		,@TYPE VARCHAR(25) --"ON_DEMAND", "AUTOMATIC_SERVICE")
	)
AS
BEGIN
	SET NOCOUNT ON;
  --
	SET LANGUAGE [us_english];
  --
	DECLARE	@SERVICE_CODE VARCHAR(25) = 'PP';
  --
	CREATE TABLE [#CLIENT_TO_BILL] (
		[CLIENT_CODE] [NVARCHAR](15) NOT NULL
		,[CLIENT_NAME] [NVARCHAR](100) NULL
		,[ACUERDO_COMERCIAL] [INT] NOT NULL
		,[TYPE_CHARGE_ID] [INT] NULL
		,[TYPE_CHARGE_DESCRIPTION] [VARCHAR](250) NULL
		,[SERVICE_ID] [INT] NOT NULL
		,[SERVICE_CODE] [VARCHAR](25) NULL
		,[SERVICE_DESCRIPTION] [VARCHAR](250) NULL
		,[UNIT_PRICE] [INT] NULL
		,[REGIMEN] [VARCHAR](25) NULL
		,[BILLING_FRECUENCY] [INT] NULL
	);

  -- ------------------------------------------------------------------------------------
  -- Obtiene los clientes
  -- ------------------------------------------------------------------------------------
	INSERT	INTO [#CLIENT_TO_BILL]
			(
				[CLIENT_CODE]
				,[CLIENT_NAME]
				,[ACUERDO_COMERCIAL]
				,[TYPE_CHARGE_ID]
				,[TYPE_CHARGE_DESCRIPTION]
				,[SERVICE_ID]
				,[SERVICE_CODE]
				,[SERVICE_DESCRIPTION]
				,[UNIT_PRICE]
				,[REGIMEN]
				,[BILLING_FRECUENCY]
			)
	SELECT
		[C].[CLIENT_CODE]
		,[C].[CLIENT_NAME]
		,[C].[ACUERDO_COMERCIAL]
		,[C].[TYPE_CHARGE_ID]
		,[C].[TYPE_CHARGE_DESCRIPTION]
		,[C].[SERVICE_ID]
		,[C].[SERVICE_CODE]
		,[C].[SERVICE_DESCRIPTION]
		,[C].[UNIT_PRICE]
		,[C].[REGIMEN]
		,[C].[BILLING_FRECUENCY]
	FROM
		[wms].[OP_WMS_FN_GET_CUSTOMERS_TO_BILL_BY_TRADE_AGREEMENT](1,
											@TYPE,
											@PROCESS_DATE,
											@SERVICE_CODE, 0) [C];

  -- ------------------------------------------------------------------------------------
  -- 
  -- ------------------------------------------------------------------------------------
	SELECT
		[L].[CLIENT_OWNER] [CLIENT_CODE]
		,[L].[CURRENT_WAREHOUSE]
		,[L].[CURRENT_LOCATION]
		,MIN([L].[LAST_UPDATED]) [LAST_UPDATED]
		,[IL].[TERMS_OF_TRADE]
	INTO
		[#POSITION_BY_CUSTOMER]
	FROM
		[wms].[OP_WMS_INV_X_LICENSE] [IL]
	INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON [IL].[LICENSE_ID] = [L].[LICENSE_ID]
	INNER JOIN [wms].[OP_WMS_SHELF_SPOTS] [S] ON [S].[LOCATION_SPOT] = [L].[CURRENT_LOCATION]
	INNER JOIN [#CLIENT_TO_BILL] [C] ON [C].[CLIENT_CODE] = [L].[CLIENT_OWNER]
										AND [IL].[TERMS_OF_TRADE] = [C].[ACUERDO_COMERCIAL]
	WHERE
		[IL].[QTY] > 0
	GROUP BY
		[L].[CLIENT_OWNER]
		,[L].[CURRENT_WAREHOUSE]
		,[L].[CURRENT_LOCATION]
		,[IL].[TERMS_OF_TRADE];

  -- ------------------------------------------------------------------------------------
  -- Obtiene el resultado previo
  -- ------------------------------------------------------------------------------------
	SELECT
		CAST(COUNT([PBC].[CURRENT_WAREHOUSE]) AS NUMERIC(18,
											2)) [QTY]
		,[C].[SERVICE_CODE] [TRANSACTION_TYPE]
		,[C].[UNIT_PRICE]
		* [wms].[OP_WMS_FN_GET_SERVICE_TO_BILL_PERCENTAGE](@TYPE,
											@PROCESS_DATE,
											MIN([PBC].[LAST_UPDATED]),
											[C].[BILLING_FRECUENCY]) [PRICE]
		,([C].[UNIT_PRICE]
			* [wms].[OP_WMS_FN_GET_SERVICE_TO_BILL_PERCENTAGE](@TYPE,
											@PROCESS_DATE,
											MIN([PBC].[LAST_UPDATED]),
											[C].[BILLING_FRECUENCY]))
		* COUNT([PBC].[CURRENT_WAREHOUSE]) [TOTAL_AMOUNT]
		,@PROCESS_DATE [PROCESS_DATE]
		,GETDATE() [CREATED_DATE]
		,GETDATE() [LAST_UPDATED_DATE]
		,@LAST_UPDATED_BY [LAST_UPDATED_BY]
		,[C].[TYPE_CHARGE_ID] [TYPE_CHARGE_ID]
		,[C].[TYPE_CHARGE_DESCRIPTION] [TYPE_CHARGE_DESCRIPTION]
		,[C].[CLIENT_CODE]
		,[C].[CLIENT_NAME]
		,CAST(0 AS INT) [IS_CHARGED]
		,CAST(NULL AS VARCHAR(30)) [INVOICE_REFERENCE]
		,CAST(NULL AS DATETIME) [CHARGED_DATE]
		,CAST(NULL AS NUMERIC) [LICENSE_ID]
		,[PBC].[CURRENT_WAREHOUSE] [LOCATION]
		,[C].[SERVICE_ID]
		,[C].[SERVICE_CODE]
		,[C].[SERVICE_DESCRIPTION]
		,[C].[REGIMEN] [REGIMEN]
		,CAST(NULL AS INT) [DOC_NUM]
		,CAST(NULL AS INT) [TRANSACTION_ID]
		,CASE CAST([wms].[OP_WMS_FN_GET_SERVICE_TO_BILL_PERCENTAGE](@TYPE,
											@PROCESS_DATE,
											MIN([PBC].[LAST_UPDATED]),
											[C].[BILLING_FRECUENCY]) AS INT)
			WHEN 1 THEN 0
			ELSE 1
			END [HAS_ADJUST]
		,[C].[BILLING_FRECUENCY]
		,[C].[ACUERDO_COMERCIAL]
	INTO
		[#PRE_RESULT]
	FROM
		[#CLIENT_TO_BILL] [C]
	INNER JOIN [#POSITION_BY_CUSTOMER] [PBC] ON (
											[PBC].[CLIENT_CODE] = [C].[CLIENT_CODE]
											AND [C].[ACUERDO_COMERCIAL] = [PBC].[TERMS_OF_TRADE]
											)
	GROUP BY
		[C].[UNIT_PRICE]
		,[C].[SERVICE_CODE]
		,[C].[TYPE_CHARGE_ID]
		,[C].[TYPE_CHARGE_DESCRIPTION]
		,[C].[CLIENT_CODE]
		,[C].[CLIENT_NAME]
		,[C].[SERVICE_ID]
		,[C].[SERVICE_CODE]
		,[C].[SERVICE_DESCRIPTION]
		,[C].[REGIMEN]
		,[C].[BILLING_FRECUENCY]
		,[C].[ACUERDO_COMERCIAL]
		,[PBC].[CURRENT_WAREHOUSE];
			
  -- ------------------------------------------------------------------------------------
  -- Eliminar registros ya cancelados de cobro mensual 
  -- ------------------------------------------------------------------------------------
	DELETE
		[R]
	FROM
		[#PRE_RESULT] [R]
	INNER JOIN [wms].[OP_WMS_SERVICES_TO_BILL] [S] ON (
											[S].[LOCATION] = [R].[LOCATION]
											AND [S].[SERVICE_CODE] = @SERVICE_CODE
											AND [S].[CLIENT_CODE] = [R].[CLIENT_CODE]
											AND [R].[BILLING_FRECUENCY] = [S].[BILLING_FRECUENCY]
											)
	WHERE
		[R].[BILLING_FRECUENCY] = 30
		AND [S].[PROCESS_DATE] > [wms].[OP_WMS_FN_GET_FIRST_DAY_OF_MONTH]([R].[PROCESS_DATE])
		AND [S].[IS_CHARGED] = 1;

  -- ------------------------------------------------------------------------------------
  -- Eliminar registros ya cancelados de cobro primera quincena
  -- ------------------------------------------------------------------------------------
	DELETE
		[R]
	FROM
		[#PRE_RESULT] [R]
	INNER JOIN [wms].[OP_WMS_SERVICES_TO_BILL] [S] ON (
											[S].[LOCATION] = [R].[LOCATION]
											AND [S].[SERVICE_CODE] = @SERVICE_CODE
											AND [S].[CLIENT_CODE] = [R].[CLIENT_CODE]
											AND [R].[BILLING_FRECUENCY] = [S].[BILLING_FRECUENCY]
											)
	WHERE
		[R].[BILLING_FRECUENCY] = 15
		AND DATEPART(DAY, [R].[PROCESS_DATE]) <= 15
		AND [S].[PROCESS_DATE] BETWEEN [wms].[OP_WMS_FN_GET_FIRST_DAY_OF_MONTH]([R].[PROCESS_DATE])
								AND		[wms].[OP_WMS_FN_GET_LAST_DAY_OF_FIRST_FORTNIGHT]([R].[PROCESS_DATE])
		AND [S].[IS_CHARGED] = 1;


  -- ------------------------------------------------------------------------------------
  -- Eliminar registros ya cancelados de cobro segunda quincena
  -- ------------------------------------------------------------------------------------
	DELETE
		[R]
	FROM
		[#PRE_RESULT] [R]
	INNER JOIN [wms].[OP_WMS_SERVICES_TO_BILL] [S] ON (
											[S].[LOCATION] = [R].[LOCATION]
											AND [S].[SERVICE_CODE] = @SERVICE_CODE
											AND [S].[CLIENT_CODE] = [R].[CLIENT_CODE]
											AND [R].[BILLING_FRECUENCY] = [S].[BILLING_FRECUENCY]
											)
	WHERE
		[R].[BILLING_FRECUENCY] = 15
		AND DATEPART(DAY, [R].[PROCESS_DATE]) > 15
		AND [S].[PROCESS_DATE] BETWEEN [wms].[OP_WMS_FN_GET_LAST_DAY_OF_FIRST_FORTNIGHT]([R].[PROCESS_DATE])
								AND		[wms].[OP_WMS_FN_GET_LAST_DAY_OF_MONTH]([R].[PROCESS_DATE])
		AND [S].[IS_CHARGED] = 1;



  -- ------------------------------------------------------------------------------------
  -- Eliminar registros ya cancelados de cobro semanal
  -- --------------------------------------------------------------------------------------  
	DELETE
		[R]
	FROM
		[#PRE_RESULT] [R]
	INNER JOIN [wms].[OP_WMS_SERVICES_TO_BILL] [S] ON (
											[S].[LOCATION] = [R].[LOCATION]
											AND [S].[SERVICE_CODE] = @SERVICE_CODE
											AND [S].[CLIENT_CODE] = [R].[CLIENT_CODE]
											AND [R].[BILLING_FRECUENCY] = [S].[BILLING_FRECUENCY]
											)
	WHERE
		[S].[SERVICE_CODE] = @SERVICE_CODE
		AND [R].[BILLING_FRECUENCY] = 7 -- FRECUENCIA SEMANAL
		AND DATEDIFF(WEEK, [R].[PROCESS_DATE],
						[S].[PROCESS_DATE]) = 0
		AND [S].[IS_CHARGED] = 1;


  -- ------------------------------------------------------------------------------------
  -- Eliminar registros ya cancelados de cobro diario
  -- --------------------------------------------------------------------------------------  
	DELETE
		[R]
	FROM
		[#PRE_RESULT] [R]
	INNER JOIN [wms].[OP_WMS_SERVICES_TO_BILL] [S] ON (
											[S].[IS_CHARGED] = 1
											AND [S].[LOCATION] = [R].[LOCATION]
											AND [S].[SERVICE_CODE] = @SERVICE_CODE
											AND [S].[CLIENT_CODE] = [R].[CLIENT_CODE]
											AND [R].[BILLING_FRECUENCY] = [S].[BILLING_FRECUENCY]
											)
	WHERE
		[S].[SERVICE_CODE] = @SERVICE_CODE
		AND [R].[BILLING_FRECUENCY] = 1 -- FRECUENCIA DIARIA
		AND [R].[PROCESS_DATE] = [S].[PROCESS_DATE];


  -- ------------------------------------------------------------------------------------
  -- Muestra el resultado
  -- ------------------------------------------------------------------------------------
	SELECT
		[R].[QTY]
		,[R].[TRANSACTION_TYPE]
		,[R].[PRICE]
		,[R].[TOTAL_AMOUNT]
		,[R].[PROCESS_DATE]
		,[R].[CREATED_DATE]
		,[R].[LAST_UPDATED_DATE]
		,[R].[LAST_UPDATED_BY]
		,[R].[TYPE_CHARGE_ID]
		,[R].[TYPE_CHARGE_DESCRIPTION]
		,[R].[CLIENT_CODE]
		,[R].[CLIENT_NAME]
		,[R].[IS_CHARGED]
		,[R].[INVOICE_REFERENCE]
		,[R].[CHARGED_DATE]
		,[R].[LICENSE_ID]
		,[R].[LOCATION]
		,[R].[SERVICE_ID]
		,[R].[SERVICE_CODE]
		,[R].[SERVICE_DESCRIPTION]
		,[R].[REGIMEN]
		,[R].[DOC_NUM]
		,[R].[TRANSACTION_ID]
		,[R].[HAS_ADJUST]
		,[R].[BILLING_FRECUENCY]
		,[R].[ACUERDO_COMERCIAL]
	FROM
		[#PRE_RESULT] [R];
END;

