-- =============================================
-- Autor:				PEDRO LOUKOTA
-- Fecha de Creacion: 	25-11-2015
-- Description:			ACTUALIZA COORDENADAS DEL SCOUTING


/*
-- Ejemplo de Ejecucion:				
				--
				exec [SONDA].[UPDATE_SWIFT_CUSTOMERS_NEW_COORDINATES]
										@GPS = '',
										@CODE_CUSTOMER = '',

				--				
*/
-- =============================================

CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_CUSTOMERS_NEW_COORDINATES]
@GPS VARCHAR(max),
@CUSTOMER INT
AS
BEGIN

TRY
	SET NOCOUNT ON;



UPDATE [SONDA].[SWIFT_CUSTOMERS_NEW]
   
   SET [GPS] = @GPS

 WHERE [CUSTOMER] = @CUSTOMER


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
