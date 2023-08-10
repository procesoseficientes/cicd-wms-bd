-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	28-Sep-16 @ A-TEAM Sprint 2
-- Description:			SP que inserta el poligono por ruta

-- Modificacion 21-Apr-17 @ A-Team Sprint Hondo
					-- alberto.ruiz
					-- Se agrega el parametro IS_MULTISELLER
/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_INSERT_POLYGON_X_ROUTE]
					@ROUTE = 1
					,@POLYGON_ID = 63
					,@ID_FREQUENCY = 24
				-- 
				EXEC [SONDA].[SWIFT_SP_INSERT_POLYGON_X_ROUTE]
					@ROUTE = 1
					,@POLYGON_ID = 63
					,@ID_FREQUENCY = 24
					,@IS_MULTIPOLYGON = 1
				-- 
				SELECT * FROM [SONDA].[SWIFT_POLYGON_BY_ROUTE] 
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_INSERT_POLYGON_X_ROUTE (
	@ROUTE INT
	,@POLYGON_ID INT
	,@ID_FREQUENCY INT = NULL
	,@IS_MULTIPOLYGON INT = 0
	,@IS_MULTISELLER INT = 0
) AS
BEGIN
	SET NOCOUNT ON;
	--
  BEGIN TRY
    DECLARE @ID INT
    --
	MERGE [SONDA].[SWIFT_POLYGON_BY_ROUTE] [PR]
	USING (SELECT @POLYGON_ID AS [POLYGON_ID]) AS [P]
	ON [PR].[POLYGON_ID] = [P].[POLYGON_ID]
	WHEN MATCHED THEN
		UPDATE SET
				[PR].[ROUTE] = @ROUTE
				,[PR].[ID_FREQUENCY] = @ID_FREQUENCY
				,[PR].[IS_MULTIPOLYGON] = @IS_MULTIPOLYGON
				,[PR].[IS_MULTISELLER] = @IS_MULTISELLER
	WHEN NOT MATCHED THEN
		INSERT
				(
					[ROUTE]
					,[POLYGON_ID]
					,[ID_FREQUENCY]
					,[IS_MULTIPOLYGON]
					,[IS_MULTISELLER]
				)
		VALUES	(
					@ROUTE  -- ROUTE - int
					,@POLYGON_ID  -- POLYGON_ID - int
					,@ID_FREQUENCY  -- ID_FREQUENCY - int
					,@IS_MULTIPOLYGON -- IS_MULTIPOLYGON - int
					,@IS_MULTISELLER
				);

    -- ------------------------------------------------------------
    -- Actualizamos el poligono para que no este disponible
    -- ------------------------------------------------------------
    UPDATE [SONDA].SWIFT_POLYGON
    SET AVAILABLE = 0
    WHERE POLYGON_ID = @POLYGON_ID
    --
    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
     ,'0' DbData
  END TRY
  BEGIN CATCH
    SELECT
      -1 AS Resultado
     ,CASE CAST(@@ERROR AS VARCHAR)
        WHEN '2627' THEN 'El poligono ya esta asociado a vendedor o ruta'
        ELSE ERROR_MESSAGE()
      END Mensaje
     ,@@ERROR Codigo
  END CATCH
END
