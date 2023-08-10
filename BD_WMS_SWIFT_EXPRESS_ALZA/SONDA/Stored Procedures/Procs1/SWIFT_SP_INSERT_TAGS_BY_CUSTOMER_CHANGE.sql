
/*============================
-- Author:         hector.gonzalez
-- Create date:    13-07-2016
-- Description:    Inserta las etiquetas por cliente con cambios en la tabla [SWIFT_TAG_X_CUSTOMER_CHANGE]


-- EJEMPLO DE EJECUCION: 
		EXEC [SONDA].[SWIFT_SP_INSERT_TAGS_BY_CUSTOMER_CHANGE]
			@TAG_COLOR = '#33CCCC'
			,@CUSTOMER = '12'
			,@LOGIN = 'gerente@SONDA'
		------------------------------------------------
		SELECT * FROM [SONDA].[SWIFT_TAG_X_CUSTOMER_NEW]
		WHERE [CUSTOMER] = '3'
		------------------------------------------------
============================*/
CREATE PROCEDURE [SONDA].[SWIFT_SP_INSERT_TAGS_BY_CUSTOMER_CHANGE]
( 
	@TAG_COLOR VARCHAR(250),
	@CUSTOMER VARCHAR(250),
	@LOGIN VARCHAR(250)
) AS 
BEGIN
	--
	BEGIN TRY
		--
		INSERT INTO [SONDA].[SWIFT_TAG_X_CUSTOMER_CHANGE](
			[TAG_COLOR]
			,[CUSTOMER]
		)
		VALUES (
			@TAG_COLOR
			,@CUSTOMER
		)
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
