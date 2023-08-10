-- =============================================
-- Autor:             rudi.garcia
-- Fecha de Creacion: 31-08-2016 @ Sprint θ 
-- Description:       Guardar el nuevo tipo de tarea para la ruta

/* 
-- Ejemplo de Ejecucion:
        --
        EXEC [SONDA].[SWIFT_SP_UPDATE_FREQUENCY_BY_POYGON]
          @POLYGON_ID = 3102
          ,@TYPE_TASK = 'PRESALE'
          ,@LAST_UPDATED_BY = 'gerente@SONDA'
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_UPDATE_FREQUENCY_BY_POYGON (
  @POLYGON_ID INT
  ,@TYPE_TASK VARCHAR(20)
  ,@LAST_UPDATED_BY VARCHAR(50)
)
AS
BEGIN  
    DECLARE 
      @TYPE_TASK_OLD VARCHAR(50)
    
    -- ------------------------------------------------------------
	  -- Se obtiene el tipo de tarea antigua de la ruta
	  -- ------------------------------------------------------------	
    SELECT TOP 1
      @TYPE_TASK_OLD = TYPE_TASK
    FROM [SONDA].SWIFT_POLYGON p
    WHERE p.POLYGON_ID = @POLYGON_ID
    
    -- ------------------------------------------------------------
	  -- Se actualizan las frecuencias con el nuevo tipo de tarea
	  -- ------------------------------------------------------------
    UPDATE [SONDA].SWIFT_FREQUENCY SET 
      CODE_FREQUENCY = (@TYPE_TASK 
                        + CONVERT(VARCHAR, @POLYGON_ID) 
                        + CONVERT(VARCHAR, SUNDAY)
                        + CONVERT(VARCHAR, MONDAY)
                        + CONVERT(VARCHAR, TUESDAY)
                        + CONVERT(VARCHAR, WEDNESDAY)
                        + CONVERT(VARCHAR, THURSDAY)
                        + CONVERT(VARCHAR, FRIDAY)
                        + CONVERT(VARCHAR, SATURDAY)
                      )
      ,TYPE_TASK = @TYPE_TASK
      ,LAST_UPDATED_BY = @LAST_UPDATED_BY
      ,LAST_UPDATED = GETDATE()
    WHERE CODE_ROUTE = CONVERT(VARCHAR, @POLYGON_ID)  
END
