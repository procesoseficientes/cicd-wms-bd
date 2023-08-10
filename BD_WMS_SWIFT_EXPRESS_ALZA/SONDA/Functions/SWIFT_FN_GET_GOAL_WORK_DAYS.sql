-- =============================================
-- Autor:					rodrigo.gomez
-- Fecha de Creacion: 		7/6/2018 @ GFORCE-Team Sprint Faisan 
-- Description:			    Obtiene los dias laborales de la meta

/*
-- Ejemplo de Ejecucion:
        SELECT [SONDA].[SWIFT_FN_GET_GOAL_WORK_DAYS]('2018-07-01 00:00:00.000', '2018-08-01 00:00:00.000', 1)
		--
        SELECT [SONDA].[SWIFT_FN_GET_GOAL_WORK_DAYS]('2018-07-01 00:00:00.000', '2018-08-01 00:00:00.000', 0)
*/
-- =============================================
CREATE FUNCTION [SONDA].[SWIFT_FN_GET_GOAL_WORK_DAYS]
    (
     @DATE_FROM DATETIME
    ,@DATE_TO DATETIME
    ,@INCLUDE_SATURDAY INT
    )
RETURNS INT
AS
BEGIN
    DECLARE
        @DAYS INT
       ,@WEEKEND_VALUE INT;
    
    SELECT
        @WEEKEND_VALUE = CASE WHEN @INCLUDE_SATURDAY = 1 THEN 1
                              ELSE 2
                         END;

    SELECT
        @DAYS = DATEDIFF(dd, @DATE_FROM, @DATE_TO)
        + CASE WHEN DATEPART(dw, @DATE_FROM) = 7 THEN 1
               ELSE 0
          END - (DATEDIFF(wk, @DATE_FROM, @DATE_TO) * @WEEKEND_VALUE)
        - CASE WHEN DATEPART(dw, @DATE_FROM) = 1 THEN 1
               ELSE 0
          END + CASE WHEN DATEPART(dw, @DATE_TO) = 1 THEN 1
                     ELSE 0
                END;
	--
    RETURN @DAYS; 

END;
