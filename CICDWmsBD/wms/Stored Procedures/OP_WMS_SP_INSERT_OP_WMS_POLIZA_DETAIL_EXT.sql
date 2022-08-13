-- =============================================
-- Autor:	--
-- Fecha de Creación: 	--
-- Description:	 --

-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-06-01 ErgonTeam@Sheik
-- Description:	se agrega para que la cantidad de vultos aproxime hacia arriba.

/*
-- Ejemplo de Ejecucion:
			
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_INSERT_OP_WMS_POLIZA_DETAIL_EXT @CUSTOMER VARCHAR(MAX)
, @USER VARCHAR(50)
, @HEADER INT

AS
BEGIN TRY
  INSERT INTO [wms].[OP_WMS_POLIZA_DETAIL]
    SELECT
      @HEADER
     ,ROW_NUMBER() OVER (ORDER BY EXT.CODIGO)
     ,@CUSTOMER + '/' + EXT.CODIGO + '|' + EXT.DESCRIPCION
     ,'0'
     ,[EXT].[QTY]
     ,'10'
     ,'0'
     ,'KG'
     ,[EXT].[QTY]
     ,[EXT].[COSTO_TOTAL]
     ,[EXT].[PPRECIO_UNITARIO]
     ,0
     ,'0'
     ,0
     ,0
     ,0
     ,0
     ,0
     ,0
     ,0
     ,'GT'
     ,'GT'
     ,''
     ,''
     ,''
     ,@USER
     ,GETDATE()
     ,NULL
     ,NULL
     ,@CUSTOMER
     ,''
     ,0
     ,ROW_NUMBER() OVER (ORDER BY EXT.CODIGO)
     ,'COMPLETED'
     ,NULL
     ,NULL
     ,NULL
     ,NULL
    FROM [wms].OP_WMS_CHARGE_EXTERNAL_INVENTORY EXT


  DECLARE @RESULT INT
  SELECT
    @RESULT = COUNT(*)
  FROM [wms].[OP_WMS_POLIZA_DETAIL]
  WHERE DOC_ID = @HEADER

  RETURN @RESULT

  IF @@error = 0
  BEGIN
    SELECT
      @RESULT AS Resultado --, 'Proceso Exitoso' Mensaje --,  0 Codigo, '0' DbData
  END
  ELSE
  BEGIN

    RETURN
    SELECT
      -1 AS Resultado
     ,ERROR_MESSAGE() Mensaje
     ,@@error Codigo
  END



END TRY




BEGIN CATCH
  SELECT
    -1 AS Resultado
   ,ERROR_MESSAGE() Mensaje
   ,@@error Codigo
END CATCH