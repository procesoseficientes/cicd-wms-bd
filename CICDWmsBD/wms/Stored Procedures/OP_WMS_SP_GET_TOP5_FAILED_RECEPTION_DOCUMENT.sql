
-- =============================================
-- Autor:	              hector.gonzalez
-- Fecha de Creacion: 	2017-01-16 @ Team ERGON - Sprint ERGON 
-- Description:	        Sp que trae el top 5 de los documentos de recepcion para sap erroneos

-- Modificacion 10-Aug-17 @ Nexus Team Sprint Banjo-Kazooie
-- alberto.ruiz
-- Ajuste por intercompany

-- Modificacion 8/31/2017 @ NEXUS-Team Sprint CommandAndConquer
-- rodrigo.gomez
-- Excluye los documentos de recepcion por solicitud de traslado

-- Modificacion 10/10/2017 @ NEXUS-Team Sprint ewms
-- rodrigo.gomez
-- Excluye los documentos cuando IS_VOID = 1 y se excluyen las recepciones que vengan de facturas para devoluciones
/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_GET_TOP5_FAILED_RECEPTION_DOCUMENT]
				@OWNER = 'arium'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_TOP5_FAILED_RECEPTION_DOCUMENT] (@OWNER VARCHAR(50))
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @MAX_ATTEMPTS INT = 5;
  --
  SELECT
    @MAX_ATTEMPTS = [owc].[NUMERIC_VALUE]
  FROM [wms].[OP_WMS_CONFIGURATIONS] [owc]
  WHERE [owc].[PARAM_TYPE] = 'SISTEMA'
  AND [owc].[PARAM_GROUP] = 'MAX_NUMBER_OF_ATTEMPTS'
  AND [owc].[PARAM_NAME] = 'MAX_NUMBER_OF_SENDING_ATTEMPTS_TO_ERP';
  --
  SELECT TOP 5
  CONVERT(varchar(10),[RDH].[ERP_RECEPTION_DOCUMENT_HEADER_ID])AS [DocNum]
    --[RDH].[ERP_RECEPTION_DOCUMENT_HEADER_ID] AS [DocNum]
   ,[RDH].[DOC_ID]
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
  FROM [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RDH]
  WHERE [RDH].[ERP_RECEPTION_DOCUMENT_HEADER_ID] > 0
  AND ISNULL([RDH].[IS_POSTED_ERP], 0) = -1
  AND ISNULL([RDH].[ATTEMPTED_WITH_ERROR], 0) < @MAX_ATTEMPTS
  AND ISNULL([RDH].[ATTEMPTED_WITH_ERROR], 0) > 0
  AND ISNULL([RDH].[IS_AUTHORIZED], 0) = 1
  AND [RDH].[IS_FROM_WAREHOUSE_TRANSFER] = 0
  AND [RDH].[SOURCE] <> 'INVOICE'
  AND [RDH].[OWNER] = @OWNER
  AND [RDH].[IS_VOID] = 0;
END;