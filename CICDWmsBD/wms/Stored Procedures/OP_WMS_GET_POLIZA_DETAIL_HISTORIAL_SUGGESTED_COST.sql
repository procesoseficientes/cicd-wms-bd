
-- =============================================
-- Autor:	              pablo.aguilar
-- Fecha de Creacion: 	2017-05-29 @ Team ERGON - Sprint Sheik
-- Description:	        Obtiene el segerido de costos para la poliza 

-- Autor:	              marvin.solares
-- Fecha de Creacion: 	20191217 GForce@Madagascar
-- Description:	        agrego en el filtro registros provenientes de traslado a general

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].[OP_WMS_GET_POLIZA_DETAIL_PENDING_AUTHORIZED] @CODE_POLIZA = 101007
      EXEC [wms].[OP_WMS_GET_POLIZA_DETAIL_HISTORIAL_SUGGESTED_COST]  @CODE_POLIZA = 252821
    SELECT * FROM [wms].[OP_WMS_POLIZA_DETAIL] [HD] WHERE DOC_ID = 123123
  SELECT * FROM [wms].OP_WMS_POLIZA_HEADER WHERE DOC_ID = 252821
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_GET_POLIZA_DETAIL_HISTORIAL_SUGGESTED_COST]
(@CODE_POLIZA VARCHAR(25))
AS
BEGIN
    SET NOCOUNT ON;
    --  

    ---------------------------------------------------------------------------------
    -- CONSULTA COSTO DE POLIZA Y REGISTRO DE TRANSACCIONES
    ---------------------------------------------------------------------------------  
    SELECT [PD].[LINE_NUMBER],
           [T].[MATERIAL_CODE] AS [MATERIAL_ID],
           MAX([T].[MATERIAL_DESCRIPTION]) AS [SKU_DESCRIPTION],
           SUM([T].[QUANTITY_UNITS]) AS QTY,
           ISNULL(MAX([PD].[UNITARY_PRICE]), 0) AS [UNITARY_PRICE],
           ISNULL(MAX([PD].[UNITARY_PRICE]), 0) * SUM([T].[QUANTITY_UNITS]) AS [CUSTOMS_AMOUNT],
           [PD].[LAST_UPDATED]
    INTO #POLIZA_DETAIL
    FROM [wms].[OP_WMS_TRANS] [T]
        INNER JOIN [wms].[OP_WMS_POLIZA_HEADER] [PH]
            ON ([T].[CODIGO_POLIZA] = [PH].[CODIGO_POLIZA])
        LEFT JOIN [wms].[OP_WMS_POLIZA_DETAIL] [PD]
            ON (
                   [PH].[DOC_ID] = [PD].[DOC_ID]
                   AND [PD].[MATERIAL_ID] = [T].[MATERIAL_CODE]
               )
    WHERE [T].[CODIGO_POLIZA] = @CODE_POLIZA
          AND
          (
              [T].[TRANS_TYPE] = 'INICIALIZACION_GENERAL'
              OR [T].[TRANS_TYPE] = 'INGRESO_GENERAL'
              OR [T].[TRANS_TYPE] = 'RECEP_GENERAL_X_TRASLADO'
          )
          AND [T].[STATUS] = 'PROCESSED'
          AND ISNULL([PD].[IS_AUTHORIZED], 0) = 0
    GROUP BY [PD].[LINE_NUMBER],
             [T].[MATERIAL_CODE],
             [PD].[LAST_UPDATED];


    ---------------------------------------------------------------------------------
    -- SE CONSULTA HISTORICOS DE DETALLES DE LOS MATERIALES DE ESTA POLIZA.
    ---------------------------------------------------------------------------------  
    SELECT [HD].[MATERIAL_ID],
           [HD].[UNITARY_PRICE],
           [ROW_NUM] = ROW_NUMBER() OVER (PARTITION BY [HD].[MATERIAL_ID] ORDER BY [HD].[LAST_UPDATED]),
           [HD].[LAST_UPDATED]
    INTO #HISTORICAL_DETAILS
    FROM [wms].[OP_WMS_POLIZA_DETAIL] [HD]
    WHERE [HD].[UNITARY_PRICE] > 0
          AND EXISTS
    (
        SELECT TOP 1
               1
        FROM [#POLIZA_DETAIL] [PD]
        WHERE [PD].[MATERIAL_ID] = [HD].[MATERIAL_ID]
    );

    ---------------------------------------------------------------------------------
    -- SE PREPARA EL RESULTADO MOSTRANDO EL SUGERIDO HISTORICO O EL DEL COSTEO DE LA POLIZA SEGUN SEA EL CASO. 
    ---------------------------------------------------------------------------------  
    SELECT [PD].[LINE_NUMBER],
           [PD].[MATERIAL_ID],
           [PD].[SKU_DESCRIPTION],
           [PD].[QTY],
           CASE
               WHEN [PD].[UNITARY_PRICE] = 0 THEN
                   ISNULL([HD].[UNITARY_PRICE], 0)
               ELSE
                   [PD].[UNITARY_PRICE]
           END [UNITARY_PRICE],
           [PD].[QTY] * CASE
                            WHEN [PD].[UNITARY_PRICE] = 0 THEN
                                ISNULL([HD].[UNITARY_PRICE], 0)
                            ELSE
                                [PD].[UNITARY_PRICE]
                        END [CUSTOMS_AMOUNT],
           CASE
               WHEN [PD].[LAST_UPDATED] IS NULL THEN
                   [HD].[LAST_UPDATED]
               ELSE
                   [PD].[LAST_UPDATED]
           END [LAST_UPDATED]
    FROM [#POLIZA_DETAIL] AS [PD]
        LEFT JOIN #HISTORICAL_DETAILS [HD]
            ON [PD].[MATERIAL_ID] = [HD].[MATERIAL_ID]
               AND [HD].[ROW_NUM] = 1;


END;