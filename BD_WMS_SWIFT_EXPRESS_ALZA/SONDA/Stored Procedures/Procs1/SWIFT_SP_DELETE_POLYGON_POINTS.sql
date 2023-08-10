/*=======================================================
-- Author:         hector.gonzalez
-- Create date:    19-07-2016
-- Description:    Elimina un registro de la tabla [SWIFT_POLYGON_POINT] 
				   

-- EJEMPLO DE EJECUCION: 
		EXEC [SONDA].[SWIFT_SP_DELETE_POLYGON_POINTS]
		 @POLYGON_ID = 8

=========================================================*/
CREATE PROCEDURE [SONDA].[SWIFT_SP_DELETE_POLYGON_POINTS]
(
		@POLYGON_ID INT
) AS
BEGIN
		--
	BEGIN TRY
		--
		DELETE FROM [SONDA].[SWIFT_POLYGON_POINT]
		WHERE POLYGON_ID = @POLYGON_ID 

		--

		IF @@error = 0 BEGIN		
			SELECT  1 AS RESULTADO , 'Proceso Exitoso' MENSAJE ,  0 CODIGO
		END		
		ELSE BEGIN		
			SELECT  -1 AS RESULTADO , ERROR_MESSAGE() MENSAJE ,  @@ERROR CODIGO
		END
		--
	END TRY
	BEGIN CATCH
		SELECT  -1 AS RESULTADO , ERROR_MESSAGE() MENSAJE ,  @@ERROR CODIGO 
	END CATCH
	--
END
