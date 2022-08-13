-- =============================================
-- Autor:					rodrigo.gomez
-- Fecha de Creacion: 		9/1/2017 @ NEXUS-Team Sprint CommandAndConquer
-- Description:			    Hace split de un texto y lo separa en columnas

/*
-- Ejemplo de Ejecucion:
        SELECT  [wms].OP_WMS_FN_SPLIT_COLUMNS('MC-1540',1,'-') PREFIX
				,[wms].OP_WMS_FN_SPLIT_COLUMNS('MC-1540',2,'-') ID
*/
-- =============================================

--SELECT * FROM [wms].[OP_WMS_FN_SPLIT]()

CREATE FUNCTION [wms].OP_WMS_FN_SPLIT_COLUMNS(
 @TEXT      varchar(8000)
,@COLUMN    tinyint
,@DELIMITER char(1)
)RETURNS varchar(8000)
AS
  BEGIN
       DECLARE @POS_START  int = 1
       DECLARE @POS_END    int = CHARINDEX(@DELIMITER, @TEXT, @POS_START)

       WHILE (@COLUMN >1 AND @POS_END> 0)
         BEGIN
             SET @POS_START = @POS_END + 1
             SET @POS_END = CHARINDEX(@DELIMITER, @TEXT, @POS_START)
             SET @COLUMN = @COLUMN - 1
         END 

       IF @COLUMN > 1  SET @POS_START = LEN(@TEXT) + 1
       IF @POS_END = 0 SET @POS_END = LEN(@TEXT) + 1 

       RETURN SUBSTRING (@TEXT, @POS_START, @POS_END - @POS_START)
  END