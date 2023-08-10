-- =============================================
-- Autor:				ppablo.loukota
-- Fecha de Creacion: 	07-12-2015
-- Description:			Actualiza la secuencia de documentos
--                      
/*
-- Ejemplo de Ejecucion:				
				--


DECLARE @ID_DOCUMENT_SECUENCE int
DECLARE @DOC_TYPE varchar(50)
DECLARE @ASSIGNED_DATETIME datetime
DECLARE @POST_DATETIME datetime
DECLARE @ASSIGNED_BY varchar(100)
DECLARE @DOC_FROM int
DECLARE @DOC_TO int
DECLARE @SERIE varchar(100)
DECLARE @ASSIGNED_TO varchar(100)
DECLARE @CURRENT_DOC int
DECLARE @STATUS varchar(15)
DECLARE @BRANCH_NAME varchar(50)
DECLARE @BRANCH_ADDRESS varchar(150)

-- TODO: Set parameter values here.

EXECUTE  [SONDA].[SWIFT_SP_UPDATE_DOCUMENT_SEQUENCE] 
   @ID_DOCUMENT_SECUENCE
  ,@DOC_TYPE
  ,@ASSIGNED_DATETIME
  ,@POST_DATETIME
  ,@ASSIGNED_BY
  ,@DOC_FROM
  ,@DOC_TO
  ,@SERIE
  ,@ASSIGNED_TO
  ,@CURRENT_DOC
  ,@STATUS
  ,@BRANCH_NAME
  ,@BRANCH_ADDRESS
GO

				--				
*/
-- =============================================


CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_DOCUMENT_SEQUENCE]
	 @ID_DOCUMENT_SECUENCE INT
	,@DOC_TYPE varchar(50)
	,@SERIE varchar(100)	
	,@ASSIGNED_BY varchar(100)
	,@ASSIGNED_TO varchar(100)
	
AS
BEGIN TRY

	UPDATE [SONDA].[SWIFT_DOCUMENT_SEQUENCE]
	   SET DOC_TYPE = @DOC_TYPE      
		  ,ASSIGNED_BY = @ASSIGNED_BY      
		  ,SERIE = @SERIE
		  ,ASSIGNED_TO = @ASSIGNED_TO
		  ,ASSIGNED_DATETIME = GETDATE()
	WHERE ID_DOCUMENT_SECUENCE = @ID_DOCUMENT_SECUENCE
	
	IF @@error = 0 BEGIN
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '0' DbData
	END		
	ELSE BEGIN		
		SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo
	END
END TRY
BEGIN CATCH     
	 SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo 
END CATCH
