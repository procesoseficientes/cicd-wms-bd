
/* =============================================

Autor:                  diego.as
Fecha de Creacion:      16-01-2017 @ A-TEAM Sprint Adeben
Descripcion:            SP que inserta el tipo de tarea por poligono

Ejemplo de Ejecucion:

    EXEC [SONDA].SWIFT_SP_INSERT_TASK_BY_POLYGON
      @TYPE_TASK = 'PRESALE'
      ,@POLYGON_ID = 1
    --
    SELECT * FROM [SONDA].SWIFT_TASK_BY_POLYGON
==============================================*/
CREATE PROCEDURE [SONDA].SWIFT_SP_INSERT_TASK_BY_POLYGON
(
@TASK_TYPE VARCHAR(15)
,@POLYGON_ID INT  
) AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY

    -- ----------------------------------------
    -- Se inserta la tarea asociada al poligono
    -- ----------------------------------------
    INSERT INTO [SONDA].[SWIFT_TASK_BY_POLYGON] (
      [POLYGON_ID]
      , [TASK_TYPE]
      )
    VALUES (
      @POLYGON_ID 
      ,@TASK_TYPE
      );

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
