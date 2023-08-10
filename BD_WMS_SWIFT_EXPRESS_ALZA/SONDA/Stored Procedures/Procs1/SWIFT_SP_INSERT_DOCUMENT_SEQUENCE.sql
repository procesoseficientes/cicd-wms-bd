-- =============================================
-- Autor:				ppablo.loukota
-- Fecha de Creacion: 	07-12-2015
-- Description:			Inserta la secuencia de documentos
--                      
/*
-- Ejemplo de Ejecucion:				
				--
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

EXECUTE [SONDA].[SWIFT_SP_INSERT_DOCUMENT_SEQUENCE] 
   @DOC_TYPE
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
CREATE PROCEDURE [SONDA].[SWIFT_SP_INSERT_DOCUMENT_SEQUENCE]	
	 @DOC_TYPE VARCHAR(50)	
	,@POST_DATETIME DATETIME
	,@ASSIGNED_BY VARCHAR(100)
	,@DOC_FROM INT
	,@DOC_TO INT
	,@SERIE VARCHAR(100)
	,@ASSIGNED_TO VARCHAR(100)
	,@CURRENT_DOC INT
	,@STATUS VARCHAR(15)
	,@BRANCH_NAME VARCHAR(50)
	,@BRANCH_ADDRESS VARCHAR(150)
AS
BEGIN TRY

	INSERT INTO [SONDA].[SWIFT_DOCUMENT_SEQUENCE]
			( 			   
			DOC_TYPE
			,ASSIGNED_DATETIME
			,POST_DATETIME 
			,ASSIGNED_BY
			,DOC_FROM
			,DOC_TO
			,SERIE
			,ASSIGNED_TO
			,CURRENT_DOC
	   		,STATUS
			,BRANCH_NAME
			,BRANCH_ADDRESS
			)
		 VALUES
			(			 
			 @DOC_TYPE
			,GETDATE()
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
			)
	IF @@error = 0 BEGIN
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje , 0 Codigo
	END		
	ELSE BEGIN		
		SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo
	END
END TRY
BEGIN CATCH     
	 SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo 
END CATCH
