-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		11-07-2016 @ Sprint  ζ
-- Description:			    SP que crea el centro de distibucion

-- Modificacion 12/27/2016 @ A-Team Sprint Balder
					-- rodrigo.gomez
					-- Se le agreron las columnas ADDRESS_DISTRIBUTION_CENTER, LATITUDE Y LONGITUDE 
/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].[SWIFT_SP_INSERT_DISTRIBUTION_CENTER]
			@NAME_DISTRIBUTION_CENTER = 'HOLA3'
			,@DESCRIPTION_DISTRIBUTION_CENTER = 'HOLA'
			,@LOGO_IMG = NULL
			,@LOGIN = 'OPER1@SONDA'
			,@ADDRESS_DISTRIBUTION_CENTER = 'Guatemala'
			,@LATITUDE = 14.64072
			,@LONGITUDE = -90.51327
		--
		SELECT * FROM [SONDA].[SWIFT_DISTRIBUTION_CENTER]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_INSERT_DISTRIBUTION_CENTER] (
	@NAME_DISTRIBUTION_CENTER VARCHAR(250)
	,@DESCRIPTION_DISTRIBUTION_CENTER VARCHAR(250)
	,@LOGO_IMG VARCHAR(MAX)
	,@LOGIN VARCHAR(50)
	,@ADDRESS_DISTRIBUTION_CENTER VARCHAR(250)
	,@LATITUDE NUMERIC(18,8)
	,@LONGITUDE NUMERIC(18,8)
)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;
		--
		DECLARE @ID INT
		--
		INSERT INTO [SONDA].[SWIFT_DISTRIBUTION_CENTER]
    			(
    				[NAME_DISTRIBUTION_CENTER]
    				,[DESCRIPTION_DISTRIBUTION_CENTER]
    				,[LOGO_IMG]
    				,[LAST_UPDATE_BY]
    				,[LAST_UPDATE_DATETIME]
					,[ADRESS_DISTRIBUTION_CENTER]
					,[LATITUDE]
					,[LONGITUDE]
    			)
		VALUES
    			(
    				@NAME_DISTRIBUTION_CENTER  -- NAME_DISTRIBUTION_CENTER - varchar(250)
    				,@DESCRIPTION_DISTRIBUTION_CENTER  -- DESCRIPTION_DISTRIBUTION_CENTER - varchar(250)
    				,@LOGO_IMG  -- LOGO_IMG - varchar(max)
    				,@LOGIN  -- LAST_UPDATE_BY - varchar(50)
    				,GETDATE()  -- LAST_UPDATE_DATETIME - datetime
					,@ADDRESS_DISTRIBUTION_CENTER -- ADRESS_DISTRIBUTION_CENTER varchar(250)
					,@LATITUDE -- LATITUDE numeric(18,8)
					,@LONGITUDE  -- LONGITUDE numeric(18,8)
    			)
		--	   
		SELECT @ID = SCOPE_IDENTITY()
	
	  IF @@error = 0 BEGIN		
			SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, CONVERT(VARCHAR(16), @ID) DbData
		END		
		ELSE BEGIN		
			SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo
		END
	END TRY
	BEGIN CATCH     
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN 'Ya existe un Centro de Distribucion con el Nombre de Centro de Distribucion'
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo
	END CATCH
END
