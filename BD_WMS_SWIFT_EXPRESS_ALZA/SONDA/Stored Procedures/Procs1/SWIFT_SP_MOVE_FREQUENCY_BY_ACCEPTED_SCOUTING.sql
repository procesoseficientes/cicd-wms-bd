﻿-- =============================================
--  Autor:		          hector.gonzalez
-- Fecha de Creacion: 	2016-08-26
-- Description:		      Mueve las frecuencias de un scouting hacia un cliente 

/*
-- Ejemplo de Ejecucion:

USE SWIFT_EXPRESS
GO

DECLARE @RC int
DECLARE @CODE_CUSTOMER varchar(50)

SET @CODE_CUSTOMER = '173' 

EXECUTE @RC = [SONDA].SWIFT_SP_MOVE_FREQUENCY_BY_ACCEPTED_SCOUTING @CODE_CUSTOMER
GO

*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_MOVE_FREQUENCY_BY_ACCEPTED_SCOUTING @CODE_CUSTOMER VARCHAR(50)
AS
BEGIN TRY

  DELETE [SONDA].SWIFT_CUSTOMER_FREQUENCY
    WHERE CODE_CUSTOMER = @CODE_CUSTOMER;

  INSERT INTO [SONDA].SWIFT_CUSTOMER_FREQUENCY (CODE_CUSTOMER, SUNDAY, MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, FREQUENCY_WEEKS, LAST_DATE_VISITED, LAST_UPDATED, LAST_UPDATED_BY)
    SELECT 
  scfn.CODE_CUSTOMER
 ,scfn.SUNDAY
 ,scfn.MONDAY
 ,scfn.TUESDAY
 ,scfn.WEDNESDAY
 ,scfn.THURSDAY
 ,scfn.FRIDAY
 ,scfn.SATURDAY
 ,scfn.FREQUENCY_WEEKS
 ,scfn.LAST_DATE_VISITED
 ,scfn.LAST_UPDATED
 ,scfn.LAST_UPDATED_BY FROM [SONDA].SWIFT_CUSTOMER_FREQUENCY_NEW scfn
    WHERE scfn.CODE_CUSTOMER = @CODE_CUSTOMER;
  

END TRY
BEGIN CATCH
  DECLARE @ERROR VARCHAR(1000) = ERROR_MESSAGE()
    RAISERROR (@ERROR, 16, 1)
END CATCH
