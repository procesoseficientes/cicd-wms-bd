-- =============================================
-- Author:         diego.as
-- Create date:    05-02-2016
-- Description:    Insertar registros en la Tabla 
--				   [SONDA].SONDA_DOC_ROUTE_RETURN_HEADER 
--				   con transacción y control de errores.

--Actualización:	diego.as
--Udate date:		10-2-2016
--Description:		Por motivo de redundancia se quitaron los parametros:
--					@LAST_UPDATE
--					@LAST_UPDATE_BY
--					@ATTEMPTED_WITH_ERROR
--					@IS_POSTED_ERP
--					@POSTED_ERP
--					@POSTED_RESPONSE

--					Se agregó la variable @ID que devuelve el ultimo identity generado.


/*
Ejemplo de Ejecucion:

					EXEC [SONDA].[SONDA_SP_INSERT_RETURN_RECEPTION_HEADER] 
					@USER_LOGIN = 'oper1@SONDA'
					,@WAREHOUSE_SOURCE = 'V004'
					,@WAREHOUSE_TARGET = 'C001'
					,@STATUS_DOC =NULL 

					SELECT * FROM [SONDA].[SONDA_DOC_ROUTE_RETURN_HEADER]
		
				
*/
-- =============================================

CREATE PROCEDURE [SONDA].SONDA_SP_INSERT_RETURN_RECEPTION_HEADER
(
	@USER_LOGIN AS varchar(50)
	,@WAREHOUSE_SOURCE varchar(50)
	,@WAREHOUSE_TARGET varchar(50)
	,@STATUS_DOC varchar(20)
)
AS
BEGIN
    SET NOCOUNT ON;
	--
	DECLARE 
		@ID INT
		,@NAME_USER VARCHAR(50)

    BEGIN TRAN TransAdd
    BEGIN TRY
		SELECT @NAME_USER = FU.NAME_USER 
		FROM [SONDA].USERS AS FU 
		WHERE FU.LOGIN = @USER_LOGIN
		
		INSERT INTO [SONDA].[SONDA_DOC_ROUTE_RETURN_HEADER] (
			USER_LOGIN
			,WAREHOUSE_SOURCE
			,WAREHOUSE_TARGET
			,NAME_USER
			,LAST_UPDATE
			,LAST_UPDATE_BY
			,STATUS_DOC
			,ATTEMPTED_WITH_ERROR
			,IS_POSTED_ERP
			,POSTED_ERP
			,POSTED_RESPONSE
		)
		VALUES(
			@USER_LOGIN
			,@WAREHOUSE_SOURCE
			,@WAREHOUSE_TARGET
			,@NAME_USER
			,GETDATE()
			,@USER_LOGIN
			,@STATUS_DOC
			,NULL
			,NULL
			,NULL
			,NULL
		)
		--
		SET @ID = SCOPE_IDENTITY()
		--
        COMMIT TRAN TransAdd
		--
		SELECT @ID AS ID
    END TRY
    BEGIN CATCH
		ROLLBACK
		DECLARE @ERROR VARCHAR(1000)= ERROR_MESSAGE()
		RAISERROR (@ERROR,16,1)
    END CATCH
END
