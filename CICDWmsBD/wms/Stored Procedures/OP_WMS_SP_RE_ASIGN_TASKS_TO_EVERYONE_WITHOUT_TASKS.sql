-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	02-Nov-16 @ A-TEAM Sprint 4 
-- Description:			SP que asigna las tareas pendientas de forma equitativa a todos los usuarios de tipo operador y activos que no tengan tareas

-- Modificación: rudi.garcia
-- Fecha de Creacion: 	2017-03-01 Team ERGON - Sprint IV ERGON
-- Description:	 Se agrego el parametro @LOGIN para el filtrado de operadores releacionados al CD del login y que no agarra todos los usuarios

-- Modificacion 10/6/2017 @ NEXUS-Team Sprint ewms
					-- rodrigo.gomez
					-- Se agrega la validacion de IN_PICKING_LINE

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_RE_ASIGN_TASKS_TO_EVERYONE_WITHOUT_TASKS] @LOGIN = 'ADMIN'
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_RE_ASIGN_TASKS_TO_EVERYONE_WITHOUT_TASKS (@LOGIN VARCHAR(50))
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @LOGIN_COUNT INT = 0
         ,@TAST_COUNT INT = 0
         ,@TASK_BY_LOGIN INT = 0
         ,@TASK_BY_LOGIN_TEMP INT = 0
         ,@TASK_RESIDUE INT = 0
         ,@LOGIN_ID VARCHAR(25)

  DECLARE @TB_USERS TABLE (
    [LOGIN_ID] VARCHAR(25)
   ,[LOGIN_NAME] VARCHAR(50)
  );
  --
  CREATE TABLE #TAST_TEMP (
    [WAVE_PICKING_ID] NUMERIC(18, 0)
  )

  BEGIN TRY
    BEGIN TRAN

    -- --------------------
    -- Se obtine los usuarios tipo operador relacionados al login enviado
    -- --------------------

    INSERT INTO @TB_USERS ([LOGIN_ID], [LOGIN_NAME])
    EXEC [wms].[OP_WMS_SP_GET_OPERATORS_ASSIGNED_TO_DISTRIBUTION_CENTER_BY_USER_FOR_REASIGN_TASK] @LOGIN

    -- ------------------------------------------------------------------------------------
    -- Obtiene los usuarios activos
    -- ------------------------------------------------------------------------------------
    SELECT
      [U].[LOGIN_ID] INTO #LOGIN
    FROM @TB_USERS [U]
    LEFT JOIN [wms].[OP_WMS_TASK_LIST] [TL]
      ON (
      [TL].[TASK_ASSIGNEDTO] = [U].[LOGIN_ID]
      AND [TL].[IS_COMPLETED] = 0
      AND [TL].[IS_CANCELED] = 0
      )
    WHERE [TL].[SERIAL_NUMBER] IS NULL
    --
    SELECT
      @LOGIN_COUNT = @@ROWCOUNT
    --
    PRINT '--> @LOGIN_COUNT: ' + CAST(@LOGIN_COUNT AS VARCHAR)

    -- ------------------------------------------------------------------------------------
    -- Obtiene las tareas libres
    -- ------------------------------------------------------------------------------------
    SELECT DISTINCT
      ISNULL([TL].[WAVE_PICKING_ID], [TL].[SERIAL_NUMBER]) [WAVE_PICKING_ID] INTO #TASK
    FROM [wms].[OP_WMS_TASK_LIST] [TL]
    WHERE [TL].[TASK_ASSIGNEDTO] = ''
    AND [TL].[IS_COMPLETED] = 0
    AND [TL].[IS_CANCELED] = 0
	AND [TL].[IN_PICKING_LINE] = 0
    ORDER BY ISNULL([TL].[WAVE_PICKING_ID], [TL].[SERIAL_NUMBER]) ASC
    --
    SELECT
      @TAST_COUNT = @@ROWCOUNT
    --
    PRINT '--> @TAST_COUNT: ' + CAST(@TAST_COUNT AS VARCHAR)

    -- ------------------------------------------------------------------------------------
    -- Verifica si hay tareas libres
    -- ------------------------------------------------------------------------------------
    IF (@LOGIN_COUNT > 0
      AND @TAST_COUNT > 0)
    BEGIN
      -- ------------------------------------------------------------------------------------
      -- Obtiene cantidad de tareas por usuario
      -- ------------------------------------------------------------------------------------
      SELECT
        @TASK_BY_LOGIN = CONVERT(INT, @TAST_COUNT / @LOGIN_COUNT)
       ,@TASK_RESIDUE = @TAST_COUNT % @LOGIN_COUNT
      --
      PRINT '--> @TASK_BY_LOGIN: ' + CAST(@TASK_BY_LOGIN AS VARCHAR)
      PRINT '--> @TASK_RESIDUE: ' + CAST(@TASK_RESIDUE AS VARCHAR)

      -- ------------------------------------------------------------------------------------
      -- Ciclo para asignar tareas
      -- ------------------------------------------------------------------------------------
      WHILE (@TAST_COUNT > 0)
      BEGIN
        -- ------------------------------------------------------------------------------------
        -- Obtiene el login a asignar tareas
        -- ------------------------------------------------------------------------------------
        SELECT TOP 1
          @LOGIN_ID = [L].[LOGIN_ID]
        FROM [#LOGIN] [L]
        --
        PRINT '----> @LOGIN_ID: ' + @LOGIN_ID

        -- ------------------------------------------------------------------------------------
        -- Marca la cantidad de tareas maxima por usuario
        -- ------------------------------------------------------------------------------------
        SELECT
          @TASK_BY_LOGIN_TEMP =
                               CASE
                                 WHEN @TASK_RESIDUE > 0 THEN (@TASK_BY_LOGIN + 1)
                                 ELSE @TASK_BY_LOGIN
                               END
        --
        PRINT '----> @TAST_COUNT: ' + CAST(@TAST_COUNT AS VARCHAR)
        PRINT '----> @TASK_RESIDUE: ' + CAST(@TASK_RESIDUE AS VARCHAR)
        PRINT '----> @TASK_BY_LOGIN_TEMP: ' + CAST(@TASK_BY_LOGIN_TEMP AS VARCHAR)
        --
        SET ROWCOUNT @TASK_BY_LOGIN_TEMP;

        -- ------------------------------------------------------------------------------------
        -- Obtiene las tareas para asignar al usuario
        -- ------------------------------------------------------------------------------------
        INSERT INTO [#TAST_TEMP]
          SELECT
            [T].[WAVE_PICKING_ID]
          FROM [#TASK] [T]
          ORDER BY [T].[WAVE_PICKING_ID] ASC

        -- ------------------------------------------------------------------------------------
        -- Asigna las tareas al usuario
        -- ------------------------------------------------------------------------------------
        SET ROWCOUNT 0;
        --
        UPDATE [TL]
        SET [TL].[TASK_ASSIGNEDTO] = @LOGIN_ID
           ,[TL].[ASSIGNED_DATE] = GETDATE()
        FROM [wms].[OP_WMS_TASK_LIST] [TL]
        INNER JOIN [#TAST_TEMP] [TT]
          ON (
          [TT].[WAVE_PICKING_ID] = ISNULL([TL].[WAVE_PICKING_ID], [TL].[SERIAL_NUMBER])
          )

        -- ------------------------------------------------------------------------------------
        -- Elimina las tareas ya asignadas y limpa la tabla temporal
        -- ------------------------------------------------------------------------------------
        DELETE [T]
          FROM [#TASK] [T]
          INNER JOIN [#TAST_TEMP] [TT]
            ON (
            [TT].[WAVE_PICKING_ID] = [T].[WAVE_PICKING_ID]
            )
        --
        TRUNCATE TABLE [#TAST_TEMP]

        -- ------------------------------------------------------------------------------------
        -- Elimina el login con tareas asignadas y resta la cantidad de tareas disponibles
        -- ------------------------------------------------------------------------------------
        DELETE FROM [#LOGIN]
        WHERE [LOGIN_ID] = @LOGIN_ID
        --
        SELECT
          @TAST_COUNT = (@TAST_COUNT - @TASK_BY_LOGIN_TEMP)
         ,@TASK_RESIDUE =
                         CASE
                           WHEN @TASK_BY_LOGIN_TEMP > @TASK_BY_LOGIN THEN (@TASK_RESIDUE - 1)
                           ELSE @TASK_RESIDUE
                         END
        --
        PRINT '---> Termina interacion'
      END
      --
      PRINT '--> Termina ciclo'
    END

    -- ------------------------------------------------------------------------------------
    -- Muetra resultado final
    -- ------------------------------------------------------------------------------------
    SET ROWCOUNT 0;
    --
    COMMIT
    --
    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
     ,'' DbData

  END TRY
  BEGIN CATCH
    ROLLBACK
    --
    SELECT
      -1 AS Resultado
     ,ERROR_MESSAGE() Mensaje
     ,@@ERROR Codigo
  END CATCH
END