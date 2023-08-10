-- =============================================
-- Autor:				pedro.loukota
-- Fecha de Creacion: 	06-11-2015
-- Description:			inserta datos en la tabla de SONDA clientes

--Modificado 05-05-2016
				-- alberto.ruiz
				-- Se agrego el parametro @USE_PACK_UNIT

/*
-- Ejemplo de Ejecucion:
			EXEC [dbo].[SWIFT_SP_INSERT_USER]
				@LOGIN = 'PRUEBA@SONDA'
				,@NAME_USER = 'prueba'
				,@TYPE_USER = 'prueba'
				,@PASSWORD = '123'
				,@CODE_ENTERPRISE = ''
				,@USER_CORRELATIVE = 0
				,@IMAGE = ''
				,@SELLER_ROUTE  = ''
				,@RELATED_SELLER  = ''
				,@USER_TYPE  = ''
				,@DEFAULT_WAREHOUSE  = ''
				,@PRESALE_WAREHOUSE  = ''
				,@USER_ROLE  = 1
				,@USE_PACK_UNIT = 1
			--
			SELECT * FROM [dbo].[SWIFT_USER] WHERE [LOGIN] = 'PRUEBA@SONDA'
			--
			DELETE [dbo].[SWIFT_USER] WHERE [LOGIN] = 'PRUEBA@SONDA'
*/
-- =============================================
CREATE PROCEDURE [dbo].[SWIFT_SP_INSERT_USER]
	@LOGIN VARCHAR(50)
	,@NAME_USER VARCHAR(50)
	,@TYPE_USER VARCHAR(50)
	,@PASSWORD VARCHAR(50)
	,@CODE_ENTERPRISE VARCHAR(50)
	,@USER_CORRELATIVE INT
	,@IMAGE VARCHAR(MAX)
	,@SELLER_ROUTE VARCHAR(50)
	,@RELATED_SELLER VARCHAR(50)
	,@USER_TYPE VARCHAR(50)
	,@DEFAULT_WAREHOUSE VARCHAR(50)
	,@PRESALE_WAREHOUSE VARCHAR(50)
	,@USER_ROLE NUMERIC(18,0)
	,@USE_PACK_UNIT INT = 0
AS
BEGIN
	SET NOCOUNT ON;
	--
	INSERT INTO [dbo].[SWIFT_USER] (
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
		,[PRESALE_WAREHOUSE]
        ,[USER_ROLE]
		,[USE_PACK_UNIT]
	)
	VALUES (
		@LOGIN 
		,@NAME_USER
		,@TYPE_USER
		,@PASSWORD
		,@CODE_ENTERPRISE
		,@USER_CORRELATIVE
		,@IMAGE
		,@SELLER_ROUTE	
		,@RELATED_SELLER
		,@USER_TYPE 
		,@DEFAULT_WAREHOUSE 
		,@PRESALE_WAREHOUSE
		,@USER_ROLE
		,@USE_PACK_UNIT
	)
END
