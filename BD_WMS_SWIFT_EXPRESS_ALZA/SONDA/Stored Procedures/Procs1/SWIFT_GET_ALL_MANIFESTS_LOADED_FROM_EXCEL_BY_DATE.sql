-- =============================================
-- Autor:					        hector.gonzalez
-- Fecha de Creacion: 		21-Oct-16 @ A-Team Sprint 3
-- Description:			      Obtiene los manifiestos creados desde excel entre dos fechas 

/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].SWIFT_GET_ALL_MANIFESTS_LOADED_FROM_EXCEL_BY_DATE
          @START_DATE = '2014-01-21'
          ,@END_DATE = '2016-10-20' 
*/
-- =============================================

CREATE PROCEDURE [SONDA].SWIFT_GET_ALL_MANIFESTS_LOADED_FROM_EXCEL_BY_DATE @START_DATE DATE,
@END_DATE DATE
AS

  SELECT
    A.MANIFEST_HEADER
   ,A.CREATED_DATE
   ,B.NAME_DRIVER
   ,A.LAST_UPDATE_BY
   ,A.STATUS
  FROM [SONDA].SWIFT_MANIFEST_HEADER A
  INNER JOIN [SONDA].SWIFT_DRIVERS B
    ON A.CODE_DRIVER = B.CODE_DRIVER
    AND CONVERT(DATE, A.CREATED_DATE) BETWEEN CONVERT(DATE, @START_DATE) AND CONVERT(DATE, @END_DATE)
    AND A.MANIFEST_SOURCE = 'LOAD_DATA_EXCEL'
