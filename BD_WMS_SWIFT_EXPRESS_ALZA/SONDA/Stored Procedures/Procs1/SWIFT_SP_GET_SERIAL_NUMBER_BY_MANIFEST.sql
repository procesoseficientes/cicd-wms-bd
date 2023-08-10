-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	14-Nov-2017 @Reborn - TEAM Sprint Eberhard
-- Description:			SP que obtiene los numeros de serie


/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_SERIAL_NUMBER_BY_MANIFEST] @MANIFEST_HEADER_ID = 2145
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_SERIAL_NUMBER_BY_MANIFEST]
	(
		@MANIFEST_HEADER_ID INT
	)
AS
	BEGIN
		--
		SET NOCOUNT ON;
		
    DECLARE
			@DATABASE_NAME VARCHAR(MAX)
			,@SCHEMA_NAME VARCHAR(MAX)
			,@QUERY VARCHAR(MAX)
			,@CLIENT_CODE VARCHAR(50)
			,@TASK_ID INT
			,@TASK_STATUS VARCHAR(50)
			,@GPS_WAREHOUSE VARCHAR(50);

    SELECT TOP 1
				@DATABASE_NAME = [S].[DATABASE_NAME]
				,@SCHEMA_NAME = [S].[SCHEMA_NAME]
			FROM
				[SONDA].[SWIFT_SETUP_EXTERNAL_SOURCE] AS [S]
			WHERE
				[S].[EXTERNAL_SOURCE_ID] > 0;
		--
		
    SELECT
				@QUERY = '	      
        SELECT
          [CH].[MANIFEST_HEADER_ID]
          ,[CSN].[MATERIAL_ID]
          ,[CSN].[SERIAL_NUMBER]
        FROM ' + @DATABASE_NAME + '.' + @SCHEMA_NAME + '.[OP_WMS_CERTIFICATION_BY_SERIAL_NUMBER] [CSN]
        INNER JOIN ' + @DATABASE_NAME + '.' + @SCHEMA_NAME + '.[OP_WMS_CERTIFICATION_HEADER] [CH] ON(
          [CH].[CERTIFICATION_HEADER_ID] = [CSN].[CERTIFICATION_HEADER_ID]
        )
        WHERE [CH].[MANIFEST_HEADER_ID] = ' + CAST(@MANIFEST_HEADER_ID AS VARCHAR) + '		
		    ';

    PRINT(@QUERY)
    EXEC (@QUERY);		
		--		
	END;
