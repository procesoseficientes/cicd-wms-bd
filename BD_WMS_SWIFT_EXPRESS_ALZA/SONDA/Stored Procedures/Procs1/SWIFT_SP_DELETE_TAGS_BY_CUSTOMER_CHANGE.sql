/*=======================================================
-- Author:         hector.gonzalez
-- Create date:    13-07-2016
-- Description:    Elimina las etiquetas por cliente con cambios en la tabla [SWIFT_TAG_X_CUSTOMER_CHANGE]

-- EJEMPLO DE EJECUCION: 
		EXEC [SONDA].[SWIFT_SP_DELETE_TAGS_BY_CUSTOMER_CHANGE]
			@TAG_COLOR = '#33CCCC'
			,@CUSTOMER_ID = '3'
			,@LOGIN = 'gerente@SONDA'
=========================================================*/
CREATE PROCEDURE [SONDA].[SWIFT_SP_DELETE_TAGS_BY_CUSTOMER_CHANGE]
( 
	@TAG_COLOR VARCHAR(250),
	@CUSTOMER VARCHAR(250),
	@LOGIN VARCHAR(250)
) AS 
BEGIN
	--
	BEGIN TRY
		--
		DELETE FROM [SONDA].[SWIFT_TAG_X_CUSTOMER_CHANGE]
		WHERE [TAG_COLOR] = @TAG_COLOR
			  AND [CUSTOMER] = @CUSTOMER

		--
		UPDATE [SONDA].[SWIFT_CUSTOMER_CHANGE]
			SET [LAST_UPDATE] = GETDATE()
				,[LAST_UPDATE_BY] = @LOGIN
			WHERE [CUSTOMER] = @CUSTOMER
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
