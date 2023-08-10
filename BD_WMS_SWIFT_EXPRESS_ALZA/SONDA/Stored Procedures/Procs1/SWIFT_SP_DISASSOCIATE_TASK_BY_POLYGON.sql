
/* ===================================================================

Autor:                  diego.as
Fecha de Creacion:      16-01-2017 @ A-TEAM Sprint Adeben
Descripcion:            SP que elimina el tipo de tarea por poligono

Ejemplo de Ejecucion:

    EXEC [SONDA].SWIFT_SP_DISASSOCIATE_TASK_BY_POLYGON
      @POLYGON_ID = 63
    --
    SELECT * FROM [SONDA].SWIFT_TASK_BY_POLYGON WHERE POLYGON_ID = 63

=====================================================================*/
CREATE PROCEDURE [SONDA].SWIFT_SP_DISASSOCIATE_TASK_BY_POLYGON
(
  @POLYGON_ID INT  
) AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY

    -- --------------------------------------------
    -- Se eliminan las tareas asociadas al poligono
    -- --------------------------------------------
    DELETE FROM  [SONDA].[SWIFT_TASK_BY_POLYGON]
      WHERE [POLYGON_ID] = @POLYGON_ID

    -- ---------------------------------------
    -- Devuelve el resultado
    -- ---------------------------------------
    SELECT
				1 AS [Resultado]
				,'Proceso Exitoso' [Mensaje]
				,0 [Codigo]
				,'0' [DbData];
  END TRY
  BEGIN CATCH
    SELECT
				-1 AS [Resultado]
				,ERROR_MESSAGE() [Mensaje]
				,@@ERROR [Codigo]; 
  END CATCH
END
