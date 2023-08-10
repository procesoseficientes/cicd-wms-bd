/*=======================================================
-- Author:         diego.as
-- Create date:    20-06-2016
-- Description:    Elimina las etiquetas por cliente en 
					la tabla SWIFT_TAG_X_CUSTOMER_NEW

-- Modificacion: 25-06-2016
--			Autor: diego.as
--			Descripcion: Se modifico proceso de eliminacion para que retorne 
						 algun tipo de mensaje en cualquiera de los casos (error de operacion, proceso exitoso)

-- Modificacion: 05-07-2016
--			Autor: diego.as
--			Descripcion: Se modifico para que actualice la columna UPDATED_FROM_BO de la tabla SWIFT_CUSTOMERS_NEW
						que indica si ha sido modificado desde el BO

-- EJEMPLO DE EJECUCION: 
		EXEC [SONDA].[SWIFT_SP_DELETE_TAGS_BY_SCOUTING]
			@TAG_COLOR = '#33CCCC'
			,@CUSTOMER_ID = '2290'
=========================================================*/
CREATE PROCEDURE [SONDA].[SWIFT_SP_DELETE_TAGS_BY_SCOUTING]
( 
	@TAG_COLOR VARCHAR(250),
	@CUSTOMER_ID VARCHAR(250),
	@LOGIN VARCHAR(250)
) AS 
BEGIN
	--
	BEGIN TRY
		--
		DELETE FROM [SONDA].[SWIFT_TAG_X_CUSTOMER_NEW]
		WHERE [TAG_COLOR] = @TAG_COLOR
			  AND [CUSTOMER] = @CUSTOMER_ID

		--
		UPDATE [SONDA].[SWIFT_CUSTOMERS_NEW]
			SET [UPDATED_FROM_BO] = 1
				,[LAST_UPDATE] = GETDATE()
				,[LAST_UPDATE_BY] = @LOGIN
			WHERE [CODE_CUSTOMER] = @CUSTOMER_ID
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
