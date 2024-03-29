﻿-- =============================================
-- Autor:                rudi.garcia
-- Fecha de Creacion:    19-Oct-2018 @ A-TEAM Sprint G-Force@Kudo
-- Description:          SP que actualiza los campos para el reporte del certificado de deposito.

/*
-- Ejemplo de Ejecucion:
                EXEC [wms].OP_WMS_INSERT_ADDITIONAL_DATA_FROM_CERTIFICATE_DEPOSIT_HEADER
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_INSERT_ADDITIONAL_DATA_FROM_CERTIFICATE_DEPOSIT_HEADER] (@CERTIFICATE_DEPOSIT_ID_HEADER INT
, @INDIVIDUAL_DESIGNATION INT
, @STORAGE VARCHAR(20)
, @DETAILED_NOTE VARCHAR(256)
, @LEAF_NUMBER INT
, @MERCHANDISE_SUBJECT_TO_PAYMENTS INT
, @TOTAL NUMERIC(18, 2)
, @INSURANCE_POLICY VARCHAR(50)
, @INSURANCE_POLICY_NAME VARCHAR(50))
AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY

    UPDATE [wms].[OP_WMS_CERTIFICATE_DEPOSIT_HEADER]
    SET [INDIVIDUAL_DESIGNATION] = @INDIVIDUAL_DESIGNATION
       ,[STORAGE] = @STORAGE
       ,[DETAILED_NOTE] = @DETAILED_NOTE
       ,[LEAF_NUMBER] = @LEAF_NUMBER
       ,[MERCHANDISE_SUBJECT_TO_PAYMENTS] = @MERCHANDISE_SUBJECT_TO_PAYMENTS
       ,[TOTAL] = @TOTAL
       ,[INSURANCE_POLICY] = @INSURANCE_POLICY
       ,[INSURANCE_POLICY_NAME] = @INSURANCE_POLICY_NAME
    WHERE [CERTIFICATE_DEPOSIT_ID_HEADER] = @CERTIFICATE_DEPOSIT_ID_HEADER;

    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
     ,CAST(@CERTIFICATE_DEPOSIT_ID_HEADER AS VARCHAR) DbData

  END TRY
  BEGIN CATCH
    SELECT
      -1 AS Resultado
     ,ERROR_MESSAGE() Mensaje
     ,@@ERROR Codigo
  END CATCH


END;