-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	6/21/2017 @ A-TEAM Sprint Khalid
-- Description:			Agrega una etiqueta a un scouting en la tabla SONDA_TAG_X_CUSTOMER_NEW

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_INSERT_TAG_SONDA_CUSTOMER_NEW]
					@TAG_COLOR = '#33CCCC', -- varchar(50)
					@CUSTOMER_ID = 1 -- int
				-- 
				SELECT * FROM [SONDA].[SONDA_TAG_X_CUSTOMER_NEW] 
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_INSERT_TAG_SONDA_CUSTOMER_NEW](
	@TAG_COLOR VARCHAR(50)
	,@CUSTOMER_ID INT
	,@LOGIN VARCHAR(250)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		--
		INSERT INTO [SONDA].[SONDA_TAG_X_CUSTOMER_NEW]
				([TAG_COLOR], [CUSTOMER_ID])
		VALUES
				(@TAG_COLOR -- TAG_COLOR - varchar(8)
					, @CUSTOMER_ID  -- CUSTOMER_ID - int
					)
		--
		UPDATE [SONDA].[SONDA_CUSTOMER_NEW]
			SET [LAST_UPDATE] = GETDATE()
				,[LAST_UPDATE_BY] = @LOGIN
				,[UPDATED_FROM_BO] = 1
			WHERE [CUSTOMER_ID] = @CUSTOMER_ID
		--
		IF @@error = 0 BEGIN		
			SELECT  1 AS RESULTADO , 'Proceso Exitoso' MENSAJE ,  0 CODIGO
		END		
		ELSE BEGIN		
			SELECT  -1 AS RESULTADO , ERROR_MESSAGE() MENSAJE ,  @@ERROR CODIGO
		END
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN ''
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
