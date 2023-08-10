
-- =============================================
-- Autor:				joel.delcompare
-- Fecha de Creacion: 	01-17-2016
-- Description:			marca un picking como envido resultado del proceso exitoso de envio hacia el ERP

-- Modificado 2016-07-14
		-- joel.delcompare
		-- Se agrego el parametro erp_reference 



/*
USE SWIFT_EXPRESS
GO

DECLARE @RC int
DECLARE @PICKING_HEADER int
DECLARE @POSTED_RESPONSE varchar(150)
DECLARE @ERP_REFERENCE varchar(256)

SET @PICKING_HEADER = 0 
SET @POSTED_RESPONSE = '' 
SET @ERP_REFERENCE = '' 

EXECUTE @RC = [SONDA].SWIFT_SP_MARK_PICKING_AS_SEND_TO_ERP @PICKING_HEADER
                                                        ,@POSTED_RESPONSE
                                                        ,@ERP_REFERENCE
GO
*/
CREATE PROCEDURE [SONDA].SWIFT_SP_MARK_PICKING_AS_SEND_TO_ERP @PICKING_HEADER INT,
@POSTED_RESPONSE VARCHAR(150), @ERP_REFERENCE VARCHAR(256) 

AS
BEGIN TRY
  DECLARE @ID NUMERIC(18, 0)
  UPDATE SWIFT_PICKING_HEADER
  SET [IS_POSTED_ERP] = 1
     ,[POSTED_ERP] = GETDATE()
     ,[POSTED_RESPONSE] = @POSTED_RESPONSE
    ,[ERP_REFERENCE] = @ERP_REFERENCE
  WHERE PICKING_HEADER = @PICKING_HEADER
  IF @@error = 0
  BEGIN
    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
     ,CONVERT(VARCHAR(50), @ID) DbData
  END
  ELSE
  BEGIN

    SELECT
      -1 AS Resultado
     ,ERROR_MESSAGE() Mensaje
     ,@@ERROR Codigo
  END

END TRY
BEGIN CATCH
  SELECT
    -1 AS Resultado
   ,ERROR_MESSAGE() Mensaje
   ,@@ERROR Codigo
END CATCH
