-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		03-06-2016
-- Description:			    SP que recrea un objeto existente

/*
-- Ejemplo de Ejecucion:
        --
		EXEC [SONDA].[SWIFT_SP_RECREATE_OBJECT]
			@SCHEMA_NAME = 'cerouno'
			,@OBJECT_NAME = 'ERP_ORDER_DETAIL'
			,@OBJECT_DEFINITION  = '
CREATE VIEW [cerouno].[ERP_ORDER_DETAIL]
as 
select *from openquery (ERP_SERVER,''SELECT
  so.DocEntry DOC_ENTRY,
  so.ItemCode ITEM_CODE,
  so.ObjType AS OBJ_TYPE,
  so.LineNum AS LINE_NUM
FROM  [Prueba].dbo.RDR1 AS so '')'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_RECREATE_OBJECT]
	@SCHEMA_NAME VARCHAR(250)
	,@OBJECT_NAME VARCHAR(250)
	,@OBJECT_DEFINITION NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE 
		@QUERY NVARCHAR(MAX)
		,@OBJECT_TYPE VARCHAR(250)
	
	-- ------------------------------------------------------------------------------------
	-- Si existe el objeto lo elimina
	-- ------------------------------------------------------------------------------------
	IF OBJECT_ID(@SCHEMA_NAME + '.' + @OBJECT_NAME) IS NOT NULL 
	BEGIN
		-- ------------------------------------------------------------------------------------
		-- Obtiene el tipo de objeto
		-- ------------------------------------------------------------------------------------
		SELECT @OBJECT_TYPE = [type]
		FROM SYS.[objects]
		WHERE [object_id] = OBJECT_ID(@SCHEMA_NAME + '.' + @OBJECT_NAME)
		
		-- ------------------------------------------------------------------------------------
		-- Genere la eliminacion del objeto
		-- ------------------------------------------------------------------------------------
		SELECT @QUERY =  'DROP ' + CASE @OBJECT_TYPE
									WHEN 'P' THEN 'PROCEDURE'
									WHEN 'V' THEN 'VIEW'
									WHEN 'U' THEN 'TABLE'
									WHEN 'FN' THEN 'FUNCTION'
									WHEN 'TF' THEN 'FUNCTION'
									WHEN 'IF' THEN 'FUNCTION'
									ELSE ''
								END + ' ' + @SCHEMA_NAME + '.' + @OBJECT_NAME + ';'
		--
		PRINT '------> @QUERY: ' + @QUERY
		--
		EXEC(@QUERY)
		--
		PRINT '------> Se elimino el objeto: ' + @SCHEMA_NAME + '.' + @OBJECT_NAME
	END

	-- ------------------------------------------------------------------------------------
	-- Recrea el objeto
	-- ------------------------------------------------------------------------------------
	EXEC(@OBJECT_DEFINITION)
	--
	PRINT '------> Se creo el objeto: ' + @SCHEMA_NAME + '.' + @OBJECT_NAME
END

