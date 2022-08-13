
-- =============================================

-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-06-01 ErgonTeam@SHEIK
-- Description:	 Se modifica para que devuelva como output el documento OP_WMS_SP_INSERT_POLIZA_HEADER




/*
-- Ejemplo de Ejecucion:
		EXEC [wms].[OP_WMS_SP_INSERT_POLIZA_HEADER] @DOC_ID = 0
                                                ,@FECHA_LLEGADA = '2017-01-31 16:55:05.159'
                                                ,@LAST_UPDATED_BY = ''
                                                ,@LAST_UPDATED = '2017-01-31 16:55:05.159'
                                                ,@CLIENT_CODE = ''
                                                ,@FECHA_DOCUMENTO = '2017-01-31 16:55:05.159'
                                                ,@TIPO = ''
                                                ,@CODIGO_POLIZA = '0'
                                                ,@ACUERDO_COMERCIAL = ''
                                                ,@STATUS = ''
*/
-- =============================================

CREATE PROCEDURE [wms].OP_WMS_SP_INSERT_POLIZA_HEADER_FOR_EXTERNAL_INVENTORY @DOC_ID INT OUTPUT
, @FECHA_LLEGADA DATETIME
, @LAST_UPDATED_BY VARCHAR(25)
, @LAST_UPDATED DATETIME
, @CLIENT_CODE VARCHAR(25)
, @FECHA_DOCUMENTO DATETIME
, @TIPO VARCHAR(25) = 'INGRESO'
, @CODIGO_POLIZA VARCHAR(15)
, @ACUERDO_COMERCIAL VARCHAR(50) = ''
, @STATUS VARCHAR(15) = 'CREATED'
AS





  INSERT INTO [wms].[OP_WMS_POLIZA_HEADER] ([FECHA_LLEGADA]
  , [LAST_UPDATED_BY]
  , [LAST_UPDATED]
  , [CLIENT_CODE]
  , [FECHA_DOCUMENTO]
  , [TIPO]
  , [CODIGO_POLIZA]
  , [ACUERDO_COMERCIAL]
  , [STATUS]
    , [WAREHOUSE_REGIMEN]
    , [IS_EXTERNAL_INVENTORY])
    VALUES (@FECHA_LLEGADA, @LAST_UPDATED_BY, @LAST_UPDATED, @CLIENT_CODE, @FECHA_DOCUMENTO, @TIPO, @CODIGO_POLIZA, @ACUERDO_COMERCIAL, @STATUS, 'GENERAL', 1)

  SET @DOC_ID = SCOPE_IDENTITY()

  IF @CODIGO_POLIZA = '0'
  BEGIN
    UPDATE [wms].OP_WMS_POLIZA_HEADER
    SET CODIGO_POLIZA = @DOC_ID
    WHERE DOC_ID = @DOC_ID
  END