-- =============================================
--  Autor:		joel.delcompare
-- Fecha de Creacion: 	2016-04-28 10:04:54
-- Description:		Mueve las etiquetas de un scouting hacia un cliente 

-- Modificacion 6/22/2017 @ A-Team Sprint Khalid
					-- rodrigo.gomez
					-- Se cambio el origen de datos a la vista de tags

/*
-- Ejemplo de Ejecucion:

USE SWIFT_EXPRESS
GO

DECLARE @RC int
DECLARE @CODE_CUSTOMER varchar(50)

SET @CODE_CUSTOMER = '173' 

EXECUTE @RC = [SONDA].SWIFT_SP_MOVE_TAGS_BY_ACCEPTED_SCOUTING @CODE_CUSTOMER
GO

*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_MOVE_TAGS_BY_ACCEPTED_SCOUTING @CODE_CUSTOMER VARCHAR(50)
AS
BEGIN TRY

  DELETE [SONDA].SWIFT_TAG_X_CUSTOMER
    WHERE CUSTOMER = @CODE_CUSTOMER;

  INSERT INTO [SONDA].SWIFT_TAG_X_CUSTOMER (TAG_COLOR, CUSTOMER)
    SELECT
      stxcn.TAG_COLOR
     ,stxcn.CUSTOMER
    FROM [SONDA].[SWIFT_VIEW_ALL_TAG_X_CUSTOMER_NEW] stxcn
    WHERE stxcn.CUSTOMER = @CODE_CUSTOMER;

  

END TRY
BEGIN CATCH
  DECLARE @ERROR VARCHAR(1000) = ERROR_MESSAGE()
    RAISERROR (@ERROR, 16, 1)
END CATCH
