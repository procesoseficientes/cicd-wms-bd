-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-09 @ Team REBORN - Sprint Drache
-- Description:	        Sp que trae las empresas de transporte

-- Modificacion 11/6/2017 @ NEXUS-Team Sprint F-Zero
					-- rodrigo.gomez
					-- Se agrega is_own

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].OP_WMS_SP_GET_TRANSPORT_COMPANY @TRANSPORT_COMPANY_CODE = NULL
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_GET_TRANSPORT_COMPANY
    (
     @TRANSPORT_COMPANY_CODE INT = NULL
    )
AS
BEGIN
    SET NOCOUNT ON;
	--

    SELECT
        [TC].[TRANSPORT_COMPANY_CODE]
       ,[TC].[NAME]
       ,[TC].[ADDRESS]
       ,[TC].[TELEPHONE]
       ,[TC].[CONTACT]
       ,[TC].[MAIL]
       ,[TC].[LAST_UPDATE]
       ,[TC].[LAST_UPDATE_BY]
	   ,[TC].[IS_OWN]
    FROM
        [wms].[OP_WMS_TRANSPORT_COMPANY] [TC]
    WHERE
        (
         @TRANSPORT_COMPANY_CODE IS NULL
         OR [TC].[TRANSPORT_COMPANY_CODE] = @TRANSPORT_COMPANY_CODE
        )
		AND [TC].[TRANSPORT_COMPANY_CODE] > 0;


END;