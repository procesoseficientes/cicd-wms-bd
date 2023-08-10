-- =============================================
-- Autor:				joel.delcompare
-- Fecha de Creacion: 	01-18-2016
-- Description:			marca una recepcion como errada resultado de no poder enviarla hacia el ERP

-- Modificado Fecha
		-- anonymous
		-- sin motivo

/*
-- Ejemplo de Ejecucion:
          USE SWIFT_EXPRESS
          GO
          
          DECLARE @RC int
          DECLARE @RECEPTION_HEADER int
          DECLARE @POSTED_RESPONSE varchar(150)
          
          SET @RECEPTION_HEADER = 0 
          SET @POSTED_RESPONSE = '' 
          
          EXECUTE @RC = [SONDA].SWIFT_SP_MARK_RECEPTION_AS_FAILED_TO_ERP @RECEPTION_HEADER
                                                                    ,@POSTED_RESPONSE
          GO
*/
CREATE PROCEDURE [SONDA].[SWIFT_SP_MARK_RECEPTION_AS_FAILED_TO_ERP]
(              
	@RECEPTION_HEADER	INT,
	@POSTED_RESPONSE varchar(150)
)
AS
BEGIN TRY
DECLARE @ID NUMERIC(18, 0)
			UPDATE SWIFT_RECEPTION_HEADER
			SET 
			 [ATTEMPTED_WITH_ERROR]= [ATTEMPTED_WITH_ERROR] + 1
			,[POSTED_RESPONSE] =@POSTED_RESPONSE
			 WHERE 
			 RECEPTION_HEADER= @RECEPTION_HEADER
IF @@error = 0 BEGIN		
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, CONVERT(VARCHAR(50),@ID) DbData
	END		
	ELSE BEGIN
		
		SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo
	END

END TRY
BEGIN CATCH     
	 SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo 
END CATCH
