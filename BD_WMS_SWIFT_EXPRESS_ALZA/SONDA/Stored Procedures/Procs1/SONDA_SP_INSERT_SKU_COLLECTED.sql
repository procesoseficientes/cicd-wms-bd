-- =============================================
-- Autor:				juancarlos.escalante
-- Fecha de Creacion: 	28-09-2016
-- Description:			Insert a la tabla SONDA_SKU_COLLECTED

/*
	Ejemplo Ejecucion: 
    EXEC [SONDA].[SONDA_SP_INSERT_SKU_COLLECTED]
		@COLLECTED_TYPE = N'TYPE',
		@CODE_SKU = 'SKU0001',
		@QTY_SKU = 1,
		@IS_GOOD_STATE = 1,
		@IMG_1 = NULL,
		@IMG_2 = NULL,
		@IMG_3 = NULL,
		@LAST_UPDATE = N'09-28-2016',
		@LAST_UPDATE_BY = 'USER'
		,@SOURCE_DOC_TYPE = 'CONSIGNMENT'
		,@SOURCE_DOC_NUM = 258
	 --
     SELECT * FROM [SONDA].[SONDA_SKU_COLLECTED]
 */
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_INSERT_SKU_COLLECTED]
	@COLLECTED_TYPE VARCHAR(50)
	,@CODE_SKU VARCHAR(50)
	,@QTY_SKU INT
	,@IS_GOOD_STATE INT
	,@IMG_1 VARCHAR(MAX)
	,@IMG_2 VARCHAR(MAX)
	,@IMG_3 VARCHAR(MAX)	
	,@LAST_UPDATE DATETIME
	,@LAST_UPDATE_BY VARCHAR(50)
	,@SOURCE_DOC_TYPE VARCHAR(50)
	,@SOURCE_DOC_NUM VARCHAR(50)
AS
BEGIN
	DECLARE @ID INT
		--
	INSERT INTO [SONDA].[SONDA_SKU_COLLECTED]
           ([CODE_SKU]
           ,[QTY_SKU]
           ,[IS_GOOD_STATE]
           ,[IMG_1]
           ,[IMG_2]
           ,[IMG_3]
           ,[LAST_UPDATE]
           ,[LAST_UPDATE_BY]
		   ,[SOURCE_DOC_TYPE]
		   ,[SOURCE_DOC_NUM])
     VALUES
           (@CODE_SKU
           ,@QTY_SKU
           ,@IS_GOOD_STATE
           ,@IMG_1
           ,@IMG_2
           ,@IMG_3
           ,@LAST_UPDATE
           ,@LAST_UPDATE_BY
		   ,@SOURCE_DOC_TYPE
		   ,@SOURCE_DOC_NUM)
	SET @ID = SCOPE_IDENTITY()
	--
	SELECT  @ID ID
END
