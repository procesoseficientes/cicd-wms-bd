
-- =============================================
-- Autor:	              hector.gonzalez
-- Fecha de Creacion: 	2017-01-16 @ Team ERGON - Sprint ERGON 
-- Description:	        Sp que trae el top 5 de los documentos de recepcion para sap

-- Modificacion 10-Aug-17 @ Nexus Team Sprint Banjo-Kazooie
-- alberto.ruiz
-- Ajuste por intercompany

-- Modificacion 8/31/2017 @ NEXUS-Team Sprint CommandAndConquer
-- rodrigo.gomez
-- Excluye los documentos de recepcion por solicitud de traslado

-- Modificacion 10/10/2017 @ NEXUS-Team Sprint ewms
-- rodrigo.gomez
-- Excluye los documentos cuando IS_VOID = 1 y se agrega validacion cuando la recepcion viene de una factura

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_GET_TOP5_RECEPTION_DOCUMENT]
				@OWNER = 'wms'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_TOP5_RECEPTION_DOCUMENT] (@OWNER VARCHAR(50))
AS
BEGIN
    SET NOCOUNT ON;
  --
    SELECT TOP 5
	----CONVERT(varchar(10),[RDH].[ERP_RECEPTION_DOCUMENT_HEADER_ID])AS [DocNum]
	--CAST([RDH].[ERP_RECEPTION_DOCUMENT_HEADER_ID] as varchar) AS [DocNum]
        [RDH].[ERP_RECEPTION_DOCUMENT_HEADER_ID] AS [DocNum]
       ,CAST(RDH.DOC_ID as int) AS [DOC_ID]
       ,[RDH].[TYPE]
       ,[RDH].[CODE_SUPPLIER]
       ,[RDH].[CODE_CLIENT]
       ,[RDH].[ERP_DATE]
       ,[RDH].[LAST_UPDATE]
       ,[RDH].[LAST_UPDATE_BY]
       ,[RDH].[ATTEMPTED_WITH_ERROR]
       ,[RDH].[IS_POSTED_ERP]
       ,[RDH].[POSTED_ERP]
       ,[RDH].[POSTED_RESPONSE]
       ,[RDH].[ERP_REFERENCE]
       ,[RDH].[IS_AUTHORIZED]
       ,[RDH].[IS_COMPLETE]
       ,[RDH].[TASK_ID]
       ,[RDH].[EXTERNAL_SOURCE_ID]
    INTO
        [#RECEPTION_DOCUMENT]
    FROM
        [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RDH]
    WHERE
        [RDH].[ERP_RECEPTION_DOCUMENT_HEADER_ID] > 0
        AND ISNULL([RDH].[IS_POSTED_ERP], 0) = 0
        AND ISNULL([RDH].[ATTEMPTED_WITH_ERROR], 0) = 0
        AND ISNULL([RDH].[IS_AUTHORIZED], 0) = 1
        AND [RDH].[IS_FROM_WAREHOUSE_TRANSFER] = 0
        AND [RDH].[SOURCE] <> 'INVOICE'
        AND [RDH].[OWNER] = @OWNER
        AND [RDH].[IS_VOID] = 0
        AND ISNULL([RDH].[IS_SENDING],0) = 0
        AND [RDH].[SOURCE] <> 'RECEPCION_GENERAL'
		;--AND 1 = 2;

    UPDATE
        [RDH]
    SET
        [RDH].[IS_SENDING] = 1
       ,[RDH].[LAST_UPDATE_IS_SENDING] = GETDATE()
    FROM
        [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RDH]
    INNER JOIN [#RECEPTION_DOCUMENT] [RD] ON ([RD].[DocNum] = [RDH].[ERP_RECEPTION_DOCUMENT_HEADER_ID]);

    SELECT
        *
    FROM
        [#RECEPTION_DOCUMENT];


END;