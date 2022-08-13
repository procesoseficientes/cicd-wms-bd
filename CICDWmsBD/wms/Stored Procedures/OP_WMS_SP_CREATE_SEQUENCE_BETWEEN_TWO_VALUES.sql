-- =============================================
-- Autor:				pablo.aguilar
-- Fecha de Creacion: 	23-Jan-19 @ G-FORCE 
-- Description:			SP que genera las series con secuencias para el ingreso
/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_CREATE_SEQUENCE_BETWEEN_TWO_VALUES] @PREFIX = 'U-', -- varchar(500)
						@START_VALUE = '02025', -- varchar(500)
						@END_VALUE = '02050', -- varchar(500)
						@SUFIX = '' -- varchar(500)

*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_CREATE_SEQUENCE_BETWEEN_TWO_VALUES] (
		@PREFIX VARCHAR(500)
		,@START_VALUE VARCHAR(500)
		,@END_VALUE VARCHAR(500)
		,@SUFIX VARCHAR(500)
	)
AS
BEGIN
	SET NOCOUNT ON;
	--

	
	DECLARE	@width INT     = LEN(@START_VALUE);
	DECLARE	@pad CHAR(1) = '0';



	DECLARE	@startnum INT= CAST(@START_VALUE AS INT);
	DECLARE	@endnum INT= CAST(@END_VALUE AS INT);
	WITH	[gen]
				AS (SELECT
						@startnum AS [num]
					UNION ALL
					SELECT
						[num] + 1
					FROM
						[gen]
					WHERE
						[num] + 1 <= @endnum)
		SELECT
		 @PREFIX + CAST(	STUFF(CONVERT(VARCHAR(99), [gen].[num]),                            -- source string (converted from numeric value)
					CASE	WHEN [gen].[num] < 0 THEN 2
							ELSE 1
					END,                 -- insert position
					0,                                                  -- count of characters to remove from source string
					REPLICATE(@pad,
								@width
								- LEN(CONVERT(VARCHAR(99), [gen].[num])))-- text to be inserted
         ) AS VARCHAR) + @SUFIX
		FROM
			[gen]
	OPTION
			(MAXRECURSION 32767);
	
END;

