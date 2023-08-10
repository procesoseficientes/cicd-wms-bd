-- =============================================
-- Autor:				pablo.aguilar
-- Fecha de Creacion: 	14-Oct-16 @ A-TEAM Sprint 
-- Description:			SP que obtiene el detalle de las consignaciones filtrado por consignacion

-- Modificaicon:				hector.gonzalez
-- Fecha de Creacion: 	09-Nov-16 @ A-TEAM Sprint 4
-- Description:			    Se cambio CONSIGNMENT_ID por DOC_SERI Y DOC_NUM

-- Modificado 13-Dic-2016
		-- rudi.garcia
		-- Se agrego el campo "SERIAL_NUMBER"

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_CONSIGMENT_TRANSACTIONS]  @DOC_SERIE = 'Serie Re-Consignación',@DOC_NUM = 22 
 */
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_GET_CONSIGMENT_TRANSACTIONS (  
  @DOC_SERIE VARCHAR(250),
  @DOC_NUM INT
  )
AS
BEGIN
DECLARE @CONSIGNMENT_BO_NUM INT
  --
  SELECT @CONSIGNMENT_BO_NUM = CONSIGNMENT_ID FROM [SONDA].SWIFT_CONSIGNMENT_HEADER sch WHERE sch.DOC_SERIE =@DOC_SERIE AND sch.DOC_NUM = @DOC_NUM
  --
  SELECT
		[scd].[DOC_SERIE]		
		,[scd].[DOC_NUM]
		,[scd].[CODE_SKU]
		,[VS].[DESCRIPTION_SKU]
		,[scd].[QTY_SKU]
		,CASE [scd].[ACTION]
			WHEN 'RECONSIGN' THEN 'RECONSIGNADO'
			WHEN 'PAID' THEN 'PAGADO'
			WHEN 'PICKUP' THEN 'RECOGIDO'
		END AS [ACTION]
		,[scd].[DOC_SERIE_TARGET]
		,[scd].[DOC_NUM_TARGET]
		,[scd].[DATE_TRANSACTION]
		,[scd].[POSTED_DATETIME]
		,[scd].[POSTED_BY]
		,[scd].[IS_POSTED]    
    , CASE WHEN ISNULL([scd].SERIAL_NUMBER,'0') = '0' THEN 'N/A' WHEN [scd].SERIAL_NUMBER = 'NULL' THEN 'N/A' ELSE [scd].SERIAL_NUMBER END AS [SERIAL_NUMBER]
	FROM [SONDA].[SONDA_HISTORICAL_TRACEABILITY_CONSIGNMENT] [scd]
		INNER JOIN [SONDA].[SWIFT_CONSIGNMENT_HEADER] [sch] ON 
		([sch].[DOC_SERIE] = [scd].[DOC_SERIE] AND [sch].[DOC_NUM] = [scd].[DOC_NUM]) 
		OR 
		([sch].[DOC_SERIE] = [scd].[DOC_SERIE_TARGET] AND [sch].[DOC_NUM] = [scd].[DOC_NUM_TARGET])
		INNER JOIN [SONDA].[SWIFT_VIEW_ALL_SKU] AS VS ON VS.CODE_SKU = scd.CODE_SKU 
	WHERE [sch].CONSIGNMENT_ID = @CONSIGNMENT_BO_NUM
END
