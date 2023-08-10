/*
	-- =============================================
-- Autor:				JOSE ROBERTO
-- Fecha de Creacion: 	11-12-2015
-- Description:			Función que valida los resultados obtenidos de las funciones de validacion
--						de ruta con documentos y bodegas para ser llamado en el sp principal.

-- Ejemplo de Ejecucion:	
							DECLARE 
							@RESULT_BIT BIT =1
							,@RESULT_MESSAGE VARCHAR(50) ='ERROR EN VALIDACIÓN'
							,@RESULT VARCHAR

							SELECT [SONDA].[SWIFT_FUNC_VALIDATE_ROUTES_RESULTS] 
							(
							@RESULT_BIT
							,@RESULT_MESSAGE
							,@RESULT)

							SELECT @Result as RESULT
-- =============================================
*/
CREATE FUNCTION [SONDA].[SWIFT_FUNC_VALIDATE_ROUTES_RESULTS]
( 
	@RESULT_BIT BIT --Contiene el resultado 1= Correcto-Asignación, 0= Incoprecto-No Tiene Asignación
	,@RESULT_MESSAGE VARCHAR(2000)-- Contiene el valor del mensaje a concatenar delclarado en SP principal
	,@RESULT VARCHAR(2000)--Retorna el mensaje del error 
)

RETURNS VARCHAR(2000)
AS
BEGIN
		IF(@RESULT_BIT=0)
		BEGIN
			IF (@RESULT!='')
			BEGIN
				SET @RESULT= @RESULT + ', '+ @RESULT_MESSAGE
			END
			ELSE
			BEGIN
				SET @RESULT= @RESULT_MESSAGE
			END
		END
	--
	RETURN @RESULT
 END;
