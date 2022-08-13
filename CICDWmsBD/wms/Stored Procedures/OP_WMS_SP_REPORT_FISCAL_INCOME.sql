-- =============================================
-- Autor:				juancarlos.escalante
-- Fecha de Creacion: 	30-09-2016
-- Description:			SP para generar el reporte de ingresos fiscales

-- Modificacion:				hector.gonzalez
-- Fecha de Creacion: 	14-03-2017
-- Description:			    Se agrego GRUPO_REGIMEN

-- Descripcion:	        hector.gonzalez
-- Fecha de Creacion: 	27-03-2017 Team Ergon SPRINT Hyper
-- Description:			    Se agrego bodegas de usuario logueado

-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-05-31 ErgonTeam@SHEIK
-- Description:	 Se agrega busqueda por multiples clientes y se arreglan join de valorización

-- Modificación: rudi.garcia
-- Fecha de Modificación: 2017-06-21 ErgonTeam@BreathOfTheWeild
-- Description:	 Se cambio el where con los clientes para que sea con poliza header

-- Modificacion 18-Jul-17 @ Nexus Team Sprint AgeOfEmpires
-- alberto.ruiz
-- Se agregan columnas de vencimiento

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-09-05 @ Team REBORN - Sprint Collin
-- Description:	   Se agregaron STATUS_NAME, [BLOCKS_INVENTORY] y COLOR

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-09-16 @ Team REBORN - Sprint Collin
-- Description:	   Se agrega TONE y CALIBER

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-09-20 @ Team REBORN - Sprint Collin
-- Description:	   Se modifica tamanio de columna CLIENT_CODE de tabla @CLIENT por bug

-- Autor:	        rudi.garcia
-- Fecha de Creacion: 	20-Feb-2018 @ Team REBORN - Sprint Ulrich
-- Description:	   Se cambio la formula para el sacar el IMPUESTO y CUSTOMS_AMOUNT

/*
	Ejemplo Ejecucion: 
	EXEC	[wms].[OP_WMS_SP_REPORT_FISCAL_INCOME]
			@FECHA_INICIO = '2016-10-21 00:00:00.000',
			@FECHA_FINAL = '2017-09-22 00:00:00.000',
			@CLIENT_CODE = 'C00030',
			@LOGIN = 'ADMIN'
 */
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_REPORT_FISCAL_INCOME] (@FECHA_INICIO DATETIME
, @FECHA_FINAL DATETIME
, @CLIENT_CODE VARCHAR(MAX)
, @LOGIN VARCHAR(25))
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @WAREHOUSE_REGIMEN VARCHAR(25) = 'FISCAL'
  --
  DECLARE @CLIENT TABLE (
    [CLIENT_CODE] NVARCHAR(25)
    UNIQUE ([CLIENT_CODE])
  )
  --
  DECLARE @WAREHOUSES TABLE (
    [WAREHOUSE_ID] VARCHAR(25)
   ,[NAME] VARCHAR(50)
   ,[COMMENTS] VARCHAR(150)
   ,[ERP_WAREHOUSE] VARCHAR(50)
   ,[ALLOW_PICKING] NUMERIC
   ,[DEFAULT_RECEPTION_LOCATION] VARCHAR(25)
   ,[SHUNT_NAME] VARCHAR(25)
   ,[WAREHOUSE_WEATHER] VARCHAR(50)
   ,[WAREHOUSE_STATUS] INT
   ,[IS_3PL_WAREHUESE] INT
   ,[WAHREHOUSE_ADDRESS] VARCHAR(250)
   ,[GPS_URL] VARCHAR(100)
   ,[WAREHOUSE_BY_USER_ID] INT
    UNIQUE ([WAREHOUSE_ID])
  );
  --
  INSERT INTO @CLIENT
    SELECT
      [C].[value]
    FROM [wms].[OP_WMS_FUNC_SPLIT](@CLIENT_CODE, '|') [C];
  --
  INSERT INTO @WAREHOUSES
  EXEC [wms].[OP_WMS_SP_GET_WAREHOUSE_ASSOCIATED_WITH_USER] @LOGIN_ID = @LOGIN;

  -- ------------------------------------------------------------------------------------
  -- Muestra resultado
  -- ------------------------------------------------------------------------------------
  SELECT
    [PH].[DOC_ID]
   ,[T].[CLIENT_NAME] AS [CLIENTE]
   ,[PH].[CLIENT_CODE]
   ,[VF].[VALOR_UNITARIO]
   ,[PH].[WAREHOUSE_REGIMEN] AS [REGIMEN]
   ,[PTM].[BULTOS_POLIZA] AS [BULTOS]
   ,[PTM].[QTY_TRANS] AS [CANTIDAD]
   ,[VF].[VALOR_UNITARIO] * [PTM].[QTY_TRANS] AS [TOTAL]
   ,[PTM].[MATERIAL_DESCRIPTION] AS [DESCRIPCION]
   ,[PTM].[MATERIAL_CODE] AS [MATERIAL_ID]
   ,[PH].[FECHA_DOCUMENTO] AS [FECHA]
   ,[PH].[NUMERO_ORDEN] AS [ORDEN]
   ,[PH].[CODIGO_POLIZA] AS [POLIZA]
   ,[VC].[CLIENT_NAME] AS [CONSIGNATARIO]
   ,[PH].[REGIMEN] AS [REGIMEN_DOCUMENTO]
   ,[C].[SPARE1] AS [GRUPO_REGIMEN]
   ,[T].[SOURCE_WAREHOUSE]
   ,[T].[TARGET_WAREHOUSE]
   ,(PTM.[QTY_TRANS] * ([PD].[CUSTOMS_AMOUNT] / [PTM].[BULTOS_POLIZA])) AS CUSTOMS_AMOUNT   
   ,ISNULL([PD].[DAI], 0) AS [DAI]
   ,ISNULL([PD].[IVA], 0) AS [IVA]
   ,((((ISNULL([PD].[DAI], 0) + ISNULL([PD].[IVA], 0)))*PTM.[QTY_TRANS])/[PTM].[BULTOS_POLIZA]) AS IMPUESTO   
   ,CASE [PH].[WAREHOUSE_REGIMEN]
      WHEN 'FISCAL' THEN [wms].[OP_WMS_FN_GET_DAYS_BY_REGIMEN]([PH].[REGIMEN])
      ELSE NULL
    END [DIAS_REGIMEN]
   ,CASE [PH].[WAREHOUSE_REGIMEN]
      WHEN 'FISCAL' THEN DATEDIFF(DAY, GETDATE(), [wms].[OP_WMS_FN_GET_EXPIRATION_DATE_FOR_POLIZA]([PH].[CODIGO_POLIZA]))
      ELSE NULL
    END [DIAS_PARA_VENCER]
   ,CASE [PH].[WAREHOUSE_REGIMEN]
      WHEN 'FISCAL' THEN [wms].[OP_WMS_FN_GET_EXPIRATION_DATE_FOR_POLIZA]([PH].[CODIGO_POLIZA])
      ELSE NULL
    END [FECHA_VENCIMIENTO]
   ,CASE
      WHEN [PH].[WAREHOUSE_REGIMEN] = 'FISCAL' AND
        DATEDIFF(DAY, GETDATE(), [wms].[OP_WMS_FN_GET_EXPIRATION_DATE_FOR_POLIZA]([PH].[CODIGO_POLIZA])) < 1 THEN 'Bloqueado'
      ELSE 'Libre'
    END [ESTADO_REGIMEN]
   ,[VF].[STATUS_NAME]
   ,[VF].[BLOCKS_INVENTORY]
   ,[VF].[COLOR]
   ,[VF].[TONE]
   ,[VF].[CALIBER]  
   ,[T].[SERIAL] 
   ,[T].[BATCH]
   ,CASE 
      WHEN [T].[BATCH] IS NULL THEN NULL
      WHEN [T].[BATCH] = '' THEN NULL
      ELSE [T].[DATE_EXPIRATION]
    END AS [DATE_EXPIRATION]
   ,[T].[VIN]
  FROM [wms].[OP_WMS_POLIZA_HEADER] [PH]
  INNER JOIN [wms].[OP_WMS3PL_POLIZA_TRANS_MATCH] [PTM]
    ON ([PH].[DOC_ID] = [PTM].[DOC_ID])
  INNER JOIN [wms].[OP_WMS_TRANS] [T]
    ON ([T].[SERIAL_NUMBER] = [PTM].[TRANS_ID])
  INNER JOIN [wms].[OP_WMS_VIEW_VALORIZACION_FISCAL] [VF]
    ON (
    [VF].[LICENSE_ID] = [T].[LICENSE_ID]
    AND [VF].[MATERIAL_ID] = [T].[MATERIAL_CODE]
    AND [VF].[CODIGO_POLIZA] = [T].[CODIGO_POLIZA]
    )
  INNER JOIN [wms].[OP_WMS_POLIZA_DETAIL] [PD]
    ON (
    [PD].[DOC_ID] = [PH].[DOC_ID]
    AND [PTM].[LINENO_POLIZA] = [PD].[LINE_NUMBER]
    )
  INNER JOIN [wms].[OP_WMS_VIEW_CLIENTS] [VC]
    ON ([VC].[CLIENT_CODE] = [PH].[CLIENT_CODE])
  INNER JOIN [wms].[OP_WMS_CONFIGURATIONS] [C]
    ON (
    [PH].[REGIMEN] = [C].[PARAM_NAME]
    AND [C].[PARAM_GROUP] = 'REGIMEN'
    )
  INNER JOIN @WAREHOUSES [W]
    ON ([T].[TARGET_WAREHOUSE] = [W].[WAREHOUSE_ID] COLLATE database_default)
  INNER JOIN @CLIENT [CL]
    ON [CL].[CLIENT_CODE] = [VC].[CLIENT_CODE]
  WHERE [PH].[WAREHOUSE_REGIMEN] = 'FISCAL'
  AND [PH].[TIPO] = 'INGRESO'
  AND [PH].[FECHA_DOCUMENTO] BETWEEN @FECHA_INICIO AND @FECHA_FINAL;
END;