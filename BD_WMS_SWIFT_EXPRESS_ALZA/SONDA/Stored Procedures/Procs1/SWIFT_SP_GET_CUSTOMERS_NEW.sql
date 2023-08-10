-- =============================================
--  Autor:		joel.delcompare
-- Fecha de Creacion: 	2016-04-28 09:25:45
-- Description:		Obtiene un cliente para enviarlo al ERP

-- Modificado 2016-04-28 09:25:45
--joel.delcompare

  -- Modificado 2016Dec26
--pablo.aguilar
  -- Se agregan campos de envió a SAP 

-- Modificacion 6/22/2017 @ A-Team Sprint Khalid
					-- rodrigo.gomez
					-- Se cambia la fuente de los datos a la vista de todos los scoutings

/*
-- Ejemplo de Ejecucion:
USE SWIFT_EXPRESS
GO

DECLARE @RC int
DECLARE @CODE_CUSTOMER varchar(50)

SET @CODE_CUSTOMER = 'SO-1793' 

EXECUTE @RC = [SONDA].SWIFT_SP_GET_CUSTOMERS_NEW @CODE_CUSTOMER
GO
*/
-- =============================================

CREATE PROCEDURE [SONDA].SWIFT_SP_GET_CUSTOMERS_NEW (@CODE_CUSTOMER VARCHAR(50))
AS
BEGIN

   DECLARE @FIELD_NAME_FOR_TAX_ID AS VARCHAR(100)
         ,@CREATE_NEW_CUSTOMER_AS_LID AS INT
         ,@DEFAULT_GROUP_CODE AS INT

  SELECT
    @FIELD_NAME_FOR_TAX_ID = [SONDA].[SWIFT_FN_GET_PARAMETER]('SCOUTING', 'FIELD_NAME_FOR_TAX_ID')
   ,@CREATE_NEW_CUSTOMER_AS_LID = CAST([SONDA].[SWIFT_FN_GET_PARAMETER]('SCOUTING', 'CREATE_NEW_CUSTOMER_AS_LID') AS INT)
   ,@DEFAULT_GROUP_CODE = CAST( [SONDA].[SWIFT_FN_GET_PARAMETER]('SCOUTING', 'DEFAULT_GROUP_CODE') AS INT)
  SELECT
    [scn].[CUSTOMER]
   ,[scn].[CODE_CUSTOMER]
   ,[scn].[NAME_CUSTOMER]
   ,[scn].[PHONE_CUSTOMER]
   ,[scn].[ADRESS_CUSTOMER]
   ,[scn].[CLASSIFICATION_CUSTOMER]
   ,[scn].[CONTACT_CUSTOMER]
   ,[scn].[CODE_ROUTE]
   ,[scn].[LAST_UPDATE]
   ,[scn].[LAST_UPDATE_BY]
   ,[u].[RELATED_SELLER] [SALES_PERSON_CODE]
   ,[scn].[CREDIT_LIMIT]
   ,'' [SIGN]
   ,'' [PHOTO]
   ,[scn].[STATUS]
   ,[scn].[NEW]
   ,[scn].[GPS]
   ,[scn].[CODE_CUSTOMER_HH]
   ,[scn].[REFERENCE]
   ,[scn].[POST_DATETIME]
   ,[scn].[POS_SALE_NAME]
   ,[scn].[INVOICE_NAME]
   ,[scn].[INVOICE_ADDRESS]
   ,ISNULL([scn].[NIT], 'C.F.') AS [NIT]
   ,[scn].[CONTACT_ID]
   ,[scn].[COMMENTS]
   ,[scn].[ATTEMPTED_WITH_ERROR]
   ,[scn].[IS_POSTED_ERP]
   ,[scn].[POSTED_ERP]
   ,[scn].[POSTED_RESPONSE]
   ,[scn].[LATITUDE]
   ,[scn].[LONGITUDE]
   ,[scn].[SELLER_DEFAULT_CODE]
   ,ISNULL([scfn].[FREQUENCY_WEEKS], 1) [FREQUENCY_WEEKS]
   ,[scfn].[MONDAY]
   ,[scfn].[TUESDAY]
   ,[scfn].[WEDNESDAY]
   ,[scfn].[THURSDAY]
   ,[scfn].[FRIDAY]
   ,[scfn].[SATURDAY]
   ,[scfn].[SUNDAY]
   ,[scn].[CODE_CUSTOMER_BO]
   ,CASE
      WHEN [scn].[CODE_CUSTOMER_BO] IS NULL THEN 1
      WHEN SUBSTRING([scn].[CODE_CUSTOMER_BO], 1, 1) = '-' THEN 1
      ELSE 0
    END [IS_NEW]

   ,@FIELD_NAME_FOR_TAX_ID AS FIELD_NAME_FOR_TAX_ID
   ,@CREATE_NEW_CUSTOMER_AS_LID AS CREATE_NEW_CUSTOMER_AS_LID
   ,@DEFAULT_GROUP_CODE AS DEFAULT_GROUP_CODE
  FROM [SONDA].[SWIFT_VIEW_ALL_CUSTOMER_NEW] [scn]
  INNER JOIN [SONDA].[USERS] [u]
    ON (
    [u].[LOGIN] = [scn].[SELLER_DEFAULT_CODE]
    )
  LEFT JOIN [SONDA].[SWIFT_CUSTOMER_FREQUENCY_NEW] [scfn]
    ON (
    [scn].[CODE_CUSTOMER] = [scfn].[CODE_CUSTOMER]
    )
  WHERE [scn].[CODE_CUSTOMER] = @CODE_CUSTOMER
  ORDER BY ([scn].[CUSTOMER]) ASC;
END
