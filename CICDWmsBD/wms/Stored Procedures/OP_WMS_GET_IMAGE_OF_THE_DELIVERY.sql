-- =============================================
-- Autor:	        rudi.garcia
-- Fecha de Creacion: 	2017-11-24 @ Team G-Force - Sprint Quetzal
-- Description:	        Sp que obtiene las imagenes.

-- Modificacion:		henry.rodriguez
-- Fecha:				02-Agosto-2019 G-Force@Estambul
-- Descripcion:			Se agregan campos [DELIVERY_IMAGE_2], [DELIVERY_IMAGE_3], [DELIVERY_IMAGE_4],[DELIVERY_SIGNATURE] en consulta.

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].OP_WMS_GET_IMAGE_OF_THE_DELIVERY @DELIVERY_NOTE_ID = 1
*/
  --get images of the delivery
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_GET_IMAGE_OF_THE_DELIVERY] (
		@DELIVERY_NOTE_ID INT
	)
AS
BEGIN
	SET NOCOUNT ON;
  --
	SET NOCOUNT ON;
  --
	DECLARE
		@EXTERNAL_SOURCE_ID INT
		,@SOURCE_NAME VARCHAR(50)
		,@DATA_BASE_NAME VARCHAR(50)
		,@SCHEMA_NAME VARCHAR(50)
		,@QUERY NVARCHAR(MAX);

	CREATE TABLE [#RESULT] (
		[DELIVERY_IMAGE] VARCHAR(MAX)
		,[DELIVERY_IMAGE_2] VARCHAR(MAX)
		,[DELIVERY_IMAGE_3] VARCHAR(MAX)
		,[DELIVERY_IMAGE_4] VARCHAR(MAX)
		,[DELIVERY_SIGNATURE] VARCHAR(MAX)
	);

	DECLARE	@EXTERNAL_SOURCE TABLE (
			[EXTERNAL_SOURCE_ID] INT
			,[SOURCE_NAME] VARCHAR(50)
			,[DATA_BASE_NAME] VARCHAR(50)
			,[SCHEMA_NAME] VARCHAR(50)
			,[INTERFACE_DATA_BASE_NAME] VARCHAR(50)
		);
    
  -- ------------------------------------------------------------------------------------
  -- Obtiene las fuentes externas
  -- ------------------------------------------------------------------------------------
	INSERT	INTO @EXTERNAL_SOURCE
	SELECT TOP 1
		[ES].[EXTERNAL_SOURCE_ID]
		,[ES].[SOURCE_NAME]
		,[ES].[DATA_BASE_NAME]
		,[ES].[SCHEMA_NAME]
		,[ES].[INTERFACE_DATA_BASE_NAME]
	FROM
		[wms].[OP_SETUP_EXTERNAL_SOURCE] [ES]
	WHERE
		[ES].[EXTERNAL_SOURCE_ID] > 0
		AND [ES].[IS_SONDA_SD] = 1;

	WHILE EXISTS ( SELECT TOP 1
						1
					FROM
						@EXTERNAL_SOURCE
					WHERE
						[EXTERNAL_SOURCE_ID] > 0 )
	BEGIN
    -- ------------------------------------------------------------------------------------
    -- Se toma la primera fuente extermna
    -- ------------------------------------------------------------------------------------
		SELECT TOP 1
			@EXTERNAL_SOURCE_ID = [ES].[EXTERNAL_SOURCE_ID]
			,@SOURCE_NAME = [ES].[SOURCE_NAME]
			,@DATA_BASE_NAME = [ES].[DATA_BASE_NAME]
			,@SCHEMA_NAME = [ES].[SCHEMA_NAME]
			,@QUERY = N''
		FROM
			@EXTERNAL_SOURCE [ES]
		WHERE
			[ES].[EXTERNAL_SOURCE_ID] > 0
		ORDER BY
			[ES].[EXTERNAL_SOURCE_ID];
    --
		PRINT '----> @EXTERNAL_SOURCE_ID: '
			+ CAST(@EXTERNAL_SOURCE_ID AS VARCHAR);
		PRINT '----> @SOURCE_NAME: ' + @SOURCE_NAME;
		PRINT '----> @DATA_BASE_NAME: ' + @DATA_BASE_NAME;
		PRINT '----> @SCHEMA_NAME: ' + @SCHEMA_NAME;

    -- ------------------------------------------------------------------------------------
    -- Obtiene las ordenes de venta de la fuente externa
    -- ------------------------------------------------------------------------------------
		SELECT
			@QUERY = '   
      INSERT INTO [#RESULT]
      SELECT      
        [DNH].[DELIVERY_IMAGE], 
		[DNH].[DELIVERY_IMAGE_2], 
		[DNH].[DELIVERY_IMAGE_3], 
		[DNH].[DELIVERY_IMAGE_4], 
		[DNH].[DELIVERY_SIGNATURE]
      FROM ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME
			+ '.[SONDA_DELIVERY_NOTE_HEADER] [DNH]      
      WHERE [DNH].[DELIVERY_NOTE_ID] = '
			+ CAST(@DELIVERY_NOTE_ID AS VARCHAR) + '   
      ';
		PRINT @QUERY;

		EXEC [sp_executesql] @QUERY;

    -- ------------------------------------------------------------------------------------
    -- Eleminamos la fuente externa
    -- ------------------------------------------------------------------------------------
		DELETE FROM
			@EXTERNAL_SOURCE
		WHERE
			[EXTERNAL_SOURCE_ID] = @EXTERNAL_SOURCE_ID;
	END;


	SELECT
		*
	FROM
		[#RESULT] [R];

END;