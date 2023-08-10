-- =============================================
-- Autor:				joel.delcompare
-- Fecha de Creacion: 	01-17-2016
-- Description:			marca una factura como errada resultado de no poder enviarla hacia el ERP

-- Modificado 04-01-2017 @ A-TEAM Sprint Balder
		-- diego.as
		-- Se agrega esquema a la tabla SWIFT_PICKING_HEADER y se agrega el campo [IS_POSTED_ERP] con valor -1

/*
-- Ejemplo de Ejecucion:
          USE SWIFT_EXPRESS
          GO
          
          DECLARE @RC int
          DECLARE @PICKING_HEADER int
          DECLARE @POSTED_RESPONSE varchar(150)
          
          SET @PICKING_HEADER = 0 
          SET @POSTED_RESPONSE = '' 
          
          EXECUTE @RC = [SONDA].SWIFT_SP_MARK_PICKING_AS_FAILED_TO_ERP @PICKING_HEADER
                                                                    ,@POSTED_RESPONSE
          GO
*/
CREATE PROCEDURE [SONDA].SWIFT_SP_MARK_PICKING_AS_FAILED_TO_ERP
(              
	@PICKING_HEADER	INT,
	@POSTED_RESPONSE varchar(150)
)
AS
BEGIN TRY
DECLARE @ID NUMERIC(18, 0)
			UPDATE [SONDA].SWIFT_PICKING_HEADER
			SET 
			 [ATTEMPTED_WITH_ERROR]= [ATTEMPTED_WITH_ERROR] + 1
			,[POSTED_RESPONSE] =@POSTED_RESPONSE
        ,[IS_POSTED_ERP] = -1
			 WHERE 
			 PICKING_HEADER= @PICKING_HEADER
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
