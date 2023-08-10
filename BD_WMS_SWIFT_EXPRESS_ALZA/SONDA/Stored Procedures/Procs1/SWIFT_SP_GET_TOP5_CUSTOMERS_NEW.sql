-- =============================================
--  Autor:		joel.delcompare
-- Fecha de Creacion: 	2016-04-27 18:10:10
-- Description:		Obtiene los primeros 5 clientes que estan listos para ser enviados al erp   

--Modificacion 03-05-2016
-- alberto.ruiz
-- Se agregaron filtro para que solo obtenga a los scouting con status de aceptado

-- Modificacion 13-Oct-16 @ A-Team Sprint 3
-- alberto.ruiz
-- Se agregaron los campos CODE_CUSTOMER_BO y IS_NEW

-- Modificacion 26-DEC-16 @ A-Team Sprint BALDER
-- pablo.aguilar
-- Se agregaron los campos FIELD_NAME_FOR_TAX_ID y CREATE_NEW_CUSTOMER_AS_LID

-- Modificacion 1/23/2017 @ A-Team Sprint Bankole
-- rodrigo.gomez
-- Se agrego el parametro SHIPPING_ATTEMPTS y que el top5 se filtre solo mostrando los que tengan menos intentos que lo establecido en SHIPPING_ATTEMPTS

-- Modificacion 4/24/2017 @ A-Team Sprint Hondo
-- rodrigo.gomez
-- Se agrego el parametro @OWNER para que solo obtenga los clientes por de su owner.

-- Modificacion 6/1/2017 @ A-Team Sprint Jibade
					-- diego.as
					-- Se modifica para que la consulta devuelva las columnas ,[scn].[DEPARTAMENT], [scn].[MUNICIPALITY], [scn].[COLONY]

-- Modificacion 6/14/2017 @ A-Team Sprint Jibade
					-- diego.as
					-- Se agrega columna IS_FROM en el WHERE para filtrar y que obtenga unicamente los scoutings creados desde Sonda Core

-- Modificacion 6/22/2017 @ A-Team Sprint Khalid
					-- rodrigo.gomez
					-- Se cambia el origen de datos a la vista de scoutings, se agrega columan IS_FROM
/*
-- Ejemplo de Ejecucion:
USE SWIFT_EXPRESS
GO

DECLARE @RC int

EXECUTE @RC = [SONDA].SWIFT_SP_GET_TOP5_CUSTOMERS_NEW @OWNER='Arium'
EXEC [SONDA].SWIFT_SP_GET_TOP5_CUSTOMERS_NEW @OWNER='Arium'

GO
  
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_TOP5_CUSTOMERS_NEW](
	@OWNER VARCHAR(25)
)
AS

  DECLARE @FIELD_NAME_FOR_TAX_ID AS VARCHAR(100)
         ,@CREATE_NEW_CUSTOMER_AS_LID AS INT
         ,@DEFAULT_GROUP_CODE AS INT
		 ,@SHIPPING_ATTEMPTS AS INT

  SELECT
    @FIELD_NAME_FOR_TAX_ID = [SONDA].[SWIFT_FN_GET_PARAMETER]('SCOUTING', 'FIELD_NAME_FOR_TAX_ID')
   ,@CREATE_NEW_CUSTOMER_AS_LID = CAST([SONDA].[SWIFT_FN_GET_PARAMETER]('SCOUTING', 'CREATE_NEW_CUSTOMER_AS_LID') AS INT)
   ,@DEFAULT_GROUP_CODE = CAST( [SONDA].[SWIFT_FN_GET_PARAMETER]('SCOUTING', 'DEFAULT_GROUP_CODE') AS INT)
   ,@SHIPPING_ATTEMPTS = CAST( [SONDA].[SWIFT_FN_GET_PARAMETER]('SCOUTING', 'SHIPPING_ATTEMPTS') AS INT)

  SELECT TOP 5
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
   ,ISNULL([scn].[NIT], 'C.F.') [NIT]
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
   ,[scn].[OWNER_ID]
   ,CASE
      WHEN [scn].[CODE_CUSTOMER_BO] IS NULL THEN 1
      WHEN SUBSTRING([scn].[CODE_CUSTOMER_BO], 1, 1) = '-' THEN 1
      ELSE 0
    END [IS_NEW]
   ,@FIELD_NAME_FOR_TAX_ID AS FIELD_NAME_FOR_TAX_ID
   ,@CREATE_NEW_CUSTOMER_AS_LID AS CREATE_NEW_CUSTOMER_AS_LID
   ,@DEFAULT_GROUP_CODE AS DEFAULT_GROUP_CODE
	,ISNULL([scn].[DEPARTAMENT], 'NO ESPECIFICADO') AS DEPARTAMENT
	,ISNULL([scn].[MUNICIPALITY],'NO ESPECIFICADO') AS MUNICIPALITY
	,ISNULL([scn].[COLONY], 'NO ESPECIFICADO') AS COLONY
	,[scn].[IS_FROM]
  FROM [SONDA].[SWIFT_VIEW_ALL_CUSTOMER_NEW] [scn]
  INNER JOIN [SONDA].[SWIFT_VW_GET_NEWEST_ORDER_FOR_DUPLICATE_CUSTOMER_NEW] [OCN]
    ON (
    [OCN].[CUSTOMER] = [scn].[CUSTOMER]
    )
  INNER JOIN [SONDA].[USERS] [u]
    ON (
    [u].[LOGIN] = [scn].[SELLER_DEFAULT_CODE]
    )
  LEFT JOIN [SONDA].[SWIFT_CUSTOMER_FREQUENCY_NEW] [scfn]
    ON (
    [scn].[CODE_CUSTOMER] = [scfn].[CODE_CUSTOMER]
    )
  INNER JOIN [SONDA].[SWIFT_COMPANY] [sc]
	ON(
	[scn].[OWNER_ID] = [sc].[COMPANY_ID]
	)
  WHERE [OCN].[NEWEST_ORDER] = 1
  AND ISNULL([scn].[IS_POSTED_ERP],-1) = -1
  AND [scn].[STATUS] = 'ACCEPTED'
  AND [scn].[ATTEMPTED_WITH_ERROR] <= @SHIPPING_ATTEMPTS
  AND [sc].[COMPANY_NAME] = @OWNER
  ORDER BY ([scn].[CUSTOMER]) ASC, ([ATTEMPTED_WITH_ERROR]) ASC, ([POST_DATETIME]) ASC;
