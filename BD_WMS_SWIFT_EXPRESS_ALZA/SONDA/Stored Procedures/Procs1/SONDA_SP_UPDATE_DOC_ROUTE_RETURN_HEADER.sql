
-- =============================================
-- Author:         diego.as
-- Create date:    18-02-2016
-- Description:    Actualiza los campos:
/*					[ATTEMPTED_WITH_ERROR] 
					,[IS_POSTED_ERP]
					,[POSTED_ERP]
					,[POSTED_RESPONSE]

					de la tabla:
						[SONDA].SONDA_DOC_ROUTE_RETURN_HEADER 
					en base al [ID_DOC_RETURN_HEADER] proporcionado.

-- Modificado 2016-07-14
		-- joel.delcompare
		-- Se agrego el parametro erp_reference 


*/
/*
Ejemplo de Ejecucion:

USE SWIFT_EXPRESS
GO

DECLARE @RC int
DECLARE @ID_HEADER int
DECLARE @ATTEMPTED_WITH_ERROR int
DECLARE @POSTED_RESPONSE varchar(150)
DECLARE @ERP_REFERENCE varchar(256)

SET @ID_HEADER = 0 
SET @ATTEMPTED_WITH_ERROR = 0 
SET @POSTED_RESPONSE = '' 
SET @ERP_REFERENCE = '' 

EXECUTE @RC = [SONDA].SONDA_SP_UPDATE_DOC_ROUTE_RETURN_HEADER @ID_HEADER
                                                           ,@ATTEMPTED_WITH_ERROR
                                                           ,@POSTED_RESPONSE
                                                           ,@ERP_REFERENCE
GO

*/
-- =============================================

CREATE PROCEDURE [SONDA].SONDA_SP_UPDATE_DOC_ROUTE_RETURN_HEADER (@ID_HEADER INT
, @ATTEMPTED_WITH_ERROR INT = NULL
, @POSTED_RESPONSE VARCHAR(150)
, @ERP_REFERENCE VARCHAR(256) 
  )
AS
BEGIN

  SET NOCOUNT ON;

  UPDATE [SONDA].[SONDA_DOC_ROUTE_RETURN_HEADER]
  SET [ATTEMPTED_WITH_ERROR] = @ATTEMPTED_WITH_ERROR
     ,[IS_POSTED_ERP] = 1
     ,[POSTED_ERP] = GETDATE()
     ,[POSTED_RESPONSE] = @POSTED_RESPONSE
    ,[ERP_REFERENCE] = @ERP_REFERENCE
  WHERE [ID_DOC_RETURN_HEADER] = @ID_HEADER

END
