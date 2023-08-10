-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	12/29/2016 @ A-TEAM Sprint Balder
-- Description:			inserta en ambas tablas de usuario

-- Modificacion 3/7/2017 @ A-Team Sprint Ebonne
					-- diego.as
					-- Se agrega propiedad CODE_PRICE_LIST

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_ADD_USER]
				-- 
				SELECT * FROM [SONDA].[USERS]
				SELECT * FROM [dbo].[SWIFT_USER]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_ADD_USER](
	@LOGIN varchar(50)
	,@NAME_USER varchar(50)
	,@TYPE_USER varchar(50)
	,@PASSWORD varchar(50)
	,@ENTERPRISE varchar(50)
	,@IMAGE varchar(max)
	,@RELATED_SELLER varchar(50) = NULL	
	,@SELLER_ROUTE varchar(50) = NULL	
	,@USER_TYPE varchar(50)
	,@DEFAULT_WAREHOUSE varchar(50) = NULL	
	,@USER_ROLE numeric
	,@PRESALE_WAREHOUSE nvarchar(50) = NULL	
	,@ROUTE_RETURN_WAREHOUSE varchar(50) = NULL	
	,@USE_PACK_UNIT INT	= NULL	
	,@ZONE_ID INT = NULL	
	,@DISTRIBUTION_CENTER_ID INT = NULL
	,@CODE_PRICE_LIST VARCHAR(25) = NULL
)
AS
BEGIN
	BEGIN TRY
		DECLARE @ID INT
		--
		INSERT INTO [SONDA].[USERS]
				(
					[LOGIN]
					,[NAME_USER]
					,[TYPE_USER]
					,[PASSWORD]
					,[ENTERPRISE]
					,[IMAGE]
					,[RELATED_SELLER]
					,[SELLER_ROUTE]
					,[USER_TYPE]
					,[DEFAULT_WAREHOUSE]
					,[USER_ROLE]
					,[PRESALE_WAREHOUSE]
					,[ROUTE_RETURN_WAREHOUSE]
					,[USE_PACK_UNIT]
					,[ZONE_ID]
					,[DISTRIBUTION_CENTER_ID]
					,[CODE_PRICE_LIST]
				)
		VALUES
				(
					@LOGIN  -- LOGIN - varchar(50)
					,@NAME_USER  -- NAME_USER - varchar(50)
					,@TYPE_USER  -- TYPE_USER - varchar(50)
					,@PASSWORD  -- PASSWORD - varchar(50)
					,@ENTERPRISE  -- ENTERPRISE - varchar(50)
					,@IMAGE  -- IMAGE - varchar(max)
					,@RELATED_SELLER  -- RELATED_SELLER - varchar(50)
					,@SELLER_ROUTE  -- SELLER_ROUTE - varchar(50)
					,@USER_TYPE  -- USER_TYPE - varchar(50)
					,@DEFAULT_WAREHOUSE  -- DEFAULT_WAREHOUSE - varchar(50)
					,@USER_ROLE  -- USER_ROLE - numeric
					,@PRESALE_WAREHOUSE  -- PRESALE_WAREHOUSE - nvarchar(50)
					,@ROUTE_RETURN_WAREHOUSE  -- ROUTE_RETURN_WAREHOUSE - varchar(50)
					,@USE_PACK_UNIT  -- USE_PACK_UNIT - int
					,@ZONE_ID  -- ZONE_ID - int
					,@DISTRIBUTION_CENTER_ID  -- DISTRIBUTION_CENTER_ID - int
					,@CODE_PRICE_LIST -- CODE_PRICE_LIST - varchar(25)
				)
		--
		SET @ID = SCOPE_IDENTITY()
		INSERT INTO [dbo].[SWIFT_USER]
				(
					[LOGIN]
					,[NAME_USER]
					,[TYPE_USER]
					,[PASSWORD]
					,[CODE_ENTERPRISE]
					,[USER_CORRELATIVE]
					,[IMAGE]
					,[SELLER_ROUTE]
					,[RELATED_SELLER]
					,[USER_TYPE]
					,[DEFAULT_WAREHOUSE]
					,[USER_ROLE]
					,[PRESALE_WAREHOUSE]
					,[ROUTE_RETURN_WAREHOUSE]
					,[USE_PACK_UNIT]
					,[DISTRIBUTION_CENTER_ID]
					,[CODE_PRICE_LIST]
				)
		VALUES
				(
					@LOGIN  -- LOGIN - varchar(50)
					,@NAME_USER  -- NAME_USER - varchar(50)
					,@TYPE_USER  -- TYPE_USER - varchar(50)
					,@PASSWORD  -- PASSWORD - varchar(50)
					,@ENTERPRISE  -- ENTERPRISE - varchar(50)
					,@ID
					,@IMAGE  -- IMAGE - varchar(max)
					,@SELLER_ROUTE  -- SELLER_ROUTE - varchar(50)
					,@RELATED_SELLER  -- RELATED_SELLER - varchar(50)
					,@USER_TYPE  -- USER_TYPE - varchar(50)
					,@DEFAULT_WAREHOUSE  -- DEFAULT_WAREHOUSE - varchar(50)
					,@USER_ROLE  -- USER_ROLE - numeric
					,@PRESALE_WAREHOUSE  -- PRESALE_WAREHOUSE - nvarchar(50)
					,@ROUTE_RETURN_WAREHOUSE  -- ROUTE_RETURN_WAREHOUSE - varchar(50)
					,@USE_PACK_UNIT  -- USE_PACK_UNIT - int
					,@DISTRIBUTION_CENTER_ID  -- DISTRIBUTION_CENTER_ID - int
					,@CODE_PRICE_LIST
				)
		--
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, CAST(@ID AS VARCHAR) DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN 'No se pudo insertar a la tabla Usuario'
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
