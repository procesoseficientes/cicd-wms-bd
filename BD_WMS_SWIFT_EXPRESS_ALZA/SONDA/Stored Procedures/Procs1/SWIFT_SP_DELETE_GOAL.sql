-- =============================================
-- Autor:				Yaqueline Canahui
-- Fecha de Creacion: 	05-07-2018
-- Description:			Eliminación de metas y detalle.

/*
-- Ejemplo de Ejecucion:
				exec [SONDA].[SWIFT_SP_DELETE_GOAL]
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_DELETE_GOAL @GOAL_HEADER_ID AS INT
AS
BEGIN
  DECLARE @CURRENT_STATUS AS VARCHAR(50) = ''
  BEGIN TRY
    --Se realizan los calculos para la meta diaria por vendedor
    BEGIN
      --Validamos el estado actual de la meta
      SELECT
        @CURRENT_STATUS = STATUS
      FROM [SONDA].SWIFT_GOAL_HEADER
      WHERE GOAL_HEADER_ID = @GOAL_HEADER_ID

      IF @CURRENT_STATUS = 'CREATED'
      BEGIN
        --Se elimina el detalle de la meta
        DELETE FROM [SONDA].SWIFT_GOAL_DETAIL
        WHERE GOAL_HEADER_ID = @GOAL_HEADER_ID

        DELETE FROM [SONDA].SWIFT_GOAL_HEADER
        WHERE GOAL_HEADER_ID = @GOAL_HEADER_ID
        -- -----------------------------------------------------------
        -- Se devuelve resultado positivo
        -- -----------------------------------------------------------
        SELECT
          1 AS Resultado
         ,'Proceso Exitoso' Mensaje
         ,0 Codigo
         ,'0' DbData
      END
      ELSE
        SELECT
          -1 AS Resultado
         ,'Estado inválido para eliminar la meta' Mensaje
         ,0 Codigo
         ,'0' DbData
    END
  END TRY
  BEGIN CATCH
    SELECT
      -1 AS Resultado
     ,ERROR_MESSAGE() Mensaje
     ,@@ERROR Codigo
  END CATCH
END
