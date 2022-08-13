-- =============================================
-- Autor:                rudi.garcia
-- Fecha de Creacion:    19-Oct-2018 @ A-TEAM Sprint G-Force@Kudo
-- Description:          SP que obtiene los datos del encabezado del certificado de deposito.

/*
-- Ejemplo de Ejecucion:
                EXEC [wms].OP_WMS_GET_CERTIFICATE_DEPOSIT_HEADER
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_GET_CERTIFICATE_DEPOSIT_HEADER] (@CERTIFICATE_DEPOSIT_ID_HEADER INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  SELECT
    [CDH].[CERTIFICATE_DEPOSIT_ID_HEADER]
   ,[CDH].[VALID_FROM]
   ,[CDH].[VALID_TO]
   ,[CDH].[LAST_UPDATED]
   ,[CDH].[LAST_UPDATED_BY]
   ,[CDH].[STATUS]
   ,[CDH].[CLIENT_CODE]
   ,[CDH].[INDIVIDUAL_DESIGNATION]
   ,[CDH].[STORAGE]
   ,[CDH].[DETAILED_NOTE]
   ,[CDH].[LEAF_NUMBER]
   ,[CDH].[MERCHANDISE_SUBJECT_TO_PAYMENTS]
   ,[CDH].[TOTAL]
   ,[CDH].[INSURANCE_POLICY]   
  FROM [wms].[OP_WMS_CERTIFICATE_DEPOSIT_HEADER] [CDH]
  WHERE [CDH].[CERTIFICATE_DEPOSIT_ID_HEADER] = @CERTIFICATE_DEPOSIT_ID_HEADER

END;