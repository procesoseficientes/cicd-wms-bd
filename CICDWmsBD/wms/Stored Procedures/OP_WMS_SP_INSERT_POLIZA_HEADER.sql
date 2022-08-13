
-- =============================================
-- Autor:				        hector.gonzalez
-- Fecha de Creacion: 	2017-01-31 @Team Ergon Sprint Ergon II
-- Description:			    Sp que inserta una poliza header

-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-08-30 Nexus@Command&Conquer
-- Description:	 Se modifica para validar que si ya existe el código de póliza no cree una nueva. 

/*
-- Ejemplo de Ejecucion:
          EXEC [wms].OP_WMS_SP_INSERT_POLIZA_HEADER @DOC_ID = 0
                                                           ,@FECHA_LLEGADA = '2017-08-30 09:35:52.170'
                                                           ,@LAST_UPDATED_BY = N'PABS'
                                                           ,@LAST_UPDATED = '2017-08-30 09:35:52.170'
                                                           ,@CLIENT_CODE = N'wms_ALMACENADORA'
                                                           ,@FECHA_DOCUMENTO = '2017-08-30 09:35:52.170'
                                                           ,@TIPO = N'EGRESO'
                                                           ,@CODIGO_POLIZA = N'52-wms_ALMACENADORA'
*/
-- =============================================

CREATE PROCEDURE [wms].[OP_WMS_SP_INSERT_POLIZA_HEADER] @DOC_ID INT
, @FECHA_LLEGADA DATETIME
, @LAST_UPDATED_BY VARCHAR(25)
, @LAST_UPDATED DATETIME
, @CLIENT_CODE VARCHAR(25)
, @FECHA_DOCUMENTO DATETIME
, @TIPO VARCHAR(25) = 'INGRESO'
, @CODIGO_POLIZA VARCHAR(25)
, @ACUERDO_COMERCIAL VARCHAR(50) = ''
, @STATUS VARCHAR(15) = 'CREATED'
AS

BEGIN TRY

  SELECT
    @DOC_ID = NULL;

  ---------------------------------------------------------------------------------
  -- Valida si ya existe ese código de poliza 
  ---------------------------------------------------------------------------------  
  SELECT TOP 1
    @DOC_ID = [H].[DOC_ID]
  FROM [wms].[OP_WMS_POLIZA_HEADER] [H]
  WHERE [H].[CODIGO_POLIZA] = @CODIGO_POLIZA
  AND [H].[TIPO] = @TIPO

  IF (@DOC_ID IS NOT NULL)
  BEGIN
    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
     ,CAST(@DOC_ID AS VARCHAR) DbData
    RETURN;
  END
  ELSE
  BEGIN

    INSERT INTO [wms].[OP_WMS_POLIZA_HEADER] ([FECHA_LLEGADA]
    , [LAST_UPDATED_BY]
    , [LAST_UPDATED]
    , [CLIENT_CODE]
    , [FECHA_DOCUMENTO]
    , [TIPO]
    , [CODIGO_POLIZA]
    , [ACUERDO_COMERCIAL]
    , [STATUS])
      VALUES (@FECHA_LLEGADA, @LAST_UPDATED_BY, @LAST_UPDATED, @CLIENT_CODE, @FECHA_DOCUMENTO, @TIPO, @CODIGO_POLIZA, @ACUERDO_COMERCIAL, @STATUS)

    SET @DOC_ID = SCOPE_IDENTITY()

    IF @CODIGO_POLIZA = '0'
    BEGIN
      UPDATE [wms].OP_WMS_POLIZA_HEADER
      SET CODIGO_POLIZA = @DOC_ID
      WHERE DOC_ID = @DOC_ID
    END
    IF @@error <> 0
    BEGIN

      SELECT
        -1 AS Resultado
       ,ERROR_MESSAGE() Mensaje
       ,@@error Codigo
       ,'0' DbData

    END
    ELSE
    BEGIN
      SELECT
        1 AS Resultado
       ,'Proceso Exitoso' Mensaje
       ,0 Codigo
       ,CAST(@DOC_ID AS VARCHAR) DbData
    END
  END

END TRY
BEGIN CATCH
  SELECT
    -1 AS Resultado
   ,ERROR_MESSAGE() Mensaje
   ,@@error Codigo
   ,NULL DbData
END CATCH