﻿
-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	01-03-2016
-- Description:			SP que se encarga de limpiar el log de los registros que tienen mas de un mes

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [wms].[BULK_DATA_SP_CLEAN_LOG]
*/
-- =============================================
CREATE PROCEDURE [wms].[BULK_DATA_SP_CLEAN_LOG]
AS
BEGIN
  SET NOCOUNT ON;
  --
  DELETE FROM wms.[BULK_DATA_CONFIGURATION_LOG]
  WHERE START_RUN < DATEADD(MONTH, -1, GETDATE())
END


