-- =============================================
-- Modificacion:					hector.gonzalez
-- Fecha de Creacion: 		21-Oct-16 @ A-Team Sprint 3
-- Description:			      Se agrego Where para que no traiga registros cargados desde excel

/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].SWIFT_GET_ALL_MANIFESTS
          @DTBEGIN = '2016-10-21' 
          ,@DTEND = '2014-01-21'
*/
-- =============================================

CREATE PROCEDURE [SONDA].SWIFT_GET_ALL_MANIFESTS @DTBEGIN DATE,
@DTEND DATE
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

  AND CONVERT(DATE, @DTBEGIN) >= CONVERT(DATE, A.CREATED_DATE)
  AND CONVERT(DATE, @DTEND) <= CONVERT(DATE, A.CREATED_DATE)

  AND (A.MANIFEST_SOURCE != 'LOAD_DATA_EXCEL'
  OR A.MANIFEST_SOURCE IS NULL)
