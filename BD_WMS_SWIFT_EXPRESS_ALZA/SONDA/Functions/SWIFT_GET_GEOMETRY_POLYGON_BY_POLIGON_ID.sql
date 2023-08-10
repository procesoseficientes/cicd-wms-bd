
-- =============================================
-- Autor:				hector.gonzalez
-- Fecha de Creacion: 	21-07-2016
-- Description:			Obtiene el poligono de un poligo id  


/*
	SELECT [SONDA].SWIFT_GET_GEOMETRY_POLYGON_BY_POLIGON_ID (9) AS VALUE
*/
-- =============================================
CREATE FUNCTION [SONDA].[SWIFT_GET_GEOMETRY_POLYGON_BY_POLIGON_ID] (@POLYGON_ID INT)
RETURNS GEOMETRY
AS
	BEGIN

		DECLARE
			@ROWS INT = 0
			,@ROW INT = 1
			,@POLYGON NVARCHAR(MAX) = ''
			,@P GEOMETRY;


		DECLARE	@POLIGON_POINTS AS TABLE
			(
				[POLYGON_ID] INT NOT NULL
				,[POSITION] INT NOT NULL
				,[LATITUDE] VARCHAR(250) NOT NULL
				,[LONGITUDE] VARCHAR(250) NOT NULL
			);
  -- ------------------------------------------------------------------------------------
  -- Obtiene los puntos del poligono
  -- ------------------------------------------------------------------------------------
		INSERT	INTO @POLIGON_POINTS
				(
					[POLYGON_ID]
					,[POSITION]
					,[LATITUDE]
					,[LONGITUDE]
				)
		SELECT
			[POLYGON_ID]
			,[POSITION]
			,[LATITUDE]
			,[LONGITUDE]
		FROM
			[SONDA].[SWIFT_POLYGON_POINT] [PP]
		WHERE
			[PP].[POLYGON_ID] = @POLYGON_ID
		ORDER BY
			[PP].[POLYGON_ID]
			,[PP].[POSITION];

  --
		SELECT
			@ROWS = @@ROWCOUNT
			,@POLYGON = ''
			,@ROW = 1;
  -- ------------------------------------------------------------------------------------
  -- Forma el poligono
  -- ------------------------------------------------------------------------------------
		WHILE @ROW <= @ROWS
		BEGIN
    --
			SELECT TOP 1
				@POLYGON = @POLYGON + CASE @ROW
										WHEN 1
										THEN CAST([P].[LATITUDE] AS VARCHAR) + ' '
												+ CAST([P].[LONGITUDE] AS VARCHAR)
										ELSE ' ,' + CAST([P].[LATITUDE] AS VARCHAR)
												+ ' '
												+ CAST([P].[LONGITUDE] AS VARCHAR)
										END
			FROM
				@POLIGON_POINTS [P]
			WHERE
				[P].[POSITION] = @ROW;
    --
			SET @ROW = (@ROW + 1);
		END;

		SELECT TOP 1
			@POLYGON = 'POLYGON((' + @POLYGON + ' ,'
			+ CAST([PO].[LATITUDE] AS VARCHAR) + ' ' + CAST([PO].[LONGITUDE] AS VARCHAR)
			+ '))'
		FROM
			@POLIGON_POINTS [PO]
		WHERE
			[PO].[POSITION] = 1;

		SET @P = [geometry]::[STGeomFromText](@POLYGON ,0);
  
		RETURN @P;
	END;
