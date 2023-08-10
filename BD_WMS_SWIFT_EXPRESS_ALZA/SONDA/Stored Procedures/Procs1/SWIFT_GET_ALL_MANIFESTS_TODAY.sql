-- =============================================
-- Modificacion:					hector.gonzalez
-- Fecha de Creacion: 		21-Oct-16 @ A-Team Sprint 3
-- Description:			      Se agrego Where para que no traiga registros cargados desde excel

/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].SWIFT_GET_ALL_MANIFESTS_TODAY
*/
-- =============================================

CREATE PROCEDURE [SONDA].SWIFT_GET_ALL_MANIFESTS_TODAY
AS
  SELECT
    A.MANIFEST_HEADER
   ,A.CREATED_DATE
   ,B.NAME_DRIVER
   ,A.LAST_UPDATE_BY
   ,A.STATUS
  FROM [SONDA].SWIFT_MANIFEST_HEADER A
      ,[SONDA].SWIFT_DRIVERS B
  WHERE A.CODE_DRIVER = B.CODE_DRIVER
  AND (A.MANIFEST_SOURCE != 'LOAD_DATA_EXCEL'
  OR A.MANIFEST_SOURCE IS NULL)
