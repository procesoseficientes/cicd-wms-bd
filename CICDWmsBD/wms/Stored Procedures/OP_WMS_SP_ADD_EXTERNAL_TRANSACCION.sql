-- =============================================
-- Autor:				JOSE.GARCIA
-- Fecha de Creacion: 	17-ENERO-17 
-- Description:			GENERA LOS MATERIALES A INSERTAR 
--						EN EL INVENTARIO EXTERNO

/*
-- Ejemplo de Ejecucion:
				--
				

				EXEC [wms].[OP_WMS_SP_ADD_EXTERNAL_TRANSACCION]
						@CLIENTE ='C00330'
						,@CLIENTE_NOMBRE ='ALTURISA'
						,@USUARIO ='AD'
						,@BODEGA ='BODEGA_16_ALTURISA'
						,@UBICACION='B16ALT-P01-F01-NU'
						,@POLIZA_SEGURO ='IN-11073'
						,@ACUERDO_COMERCIAL ='1015'
						,@FECHA_OPERACION ='1/15/2017 11:00:00 am' ---02-23 14:39:19.027'

				
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_ADD_EXTERNAL_TRANSACCION (@CLIENTE VARCHAR(50)
, @CLIENTE_NOMBRE VARCHAR(50)
, @USUARIO VARCHAR(50)
, @BODEGA VARCHAR(50)
, @UBICACION VARCHAR(50)
, @POLIZA_SEGURO VARCHAR(50)
, @ACUERDO_COMERCIAL VARCHAR(50)
, @FECHA_OPERACION DATETIME
, @RESULTADO VARCHAR(50) = '')
AS
  DECLARE @ERROR VARCHAR(250) = 'Error: '
  DECLARE @TRANS VARCHAR(250) = ''
  DECLARE @RESUMEN VARCHAR(250) = ':'
  BEGIN
    BEGIN TRY
      -----------------------------------------------------------------
      --GENERA LOS MATERIALES =1
      -----------------------------------------------------------------	
      PRINT 'GENERA MATERIALESS '
      DECLARE @RESULTADO_MATERIALES VARCHAR(50);
      EXEC @RESULTADO_MATERIALES = [wms].[OP_WMS_SP_ADD_MATERIAL_EXT] @CLIENTE = @CLIENTE
                                                                         ,@USUARIO = @USUARIO

      --SELECT @RESULTADO_MATERIALES [MATERIALES]



      -----------------------------------------------------------------
      --GENERA POLIZA HEADER 
      -----------------------------------------------------------------	
      PRINT 'GENERA POLIZA HEADER '

      DECLARE @POLIZA_NUM INT
      DECLARE @HOY DATETIME = GETDATE()


      EXEC [wms].[OP_WMS_SP_INSERT_POLIZA_HEADER_FOR_EXTERNAL_INVENTORY] @DOC_ID = @POLIZA_NUM OUTPUT
                                                                            ,@FECHA_LLEGADA = @FECHA_OPERACION
                                                                            ,@LAST_UPDATED_BY = @USUARIO
                                                                            ,@LAST_UPDATED = @HOY
                                                                            ,@CLIENT_CODE = @CLIENTE
                                                                            ,@FECHA_DOCUMENTO = @FECHA_OPERACION
                                                                            ,@TIPO = 'INGRESO'
                                                                            ,@CODIGO_POLIZA = '0'
                                                                            ,@ACUERDO_COMERCIAL = @ACUERDO_COMERCIAL
                                                                            ,@STATUS = 'COSTED'



      PRINT '@POLIZA_NUM' + CAST(@POLIZA_NUM AS VARCHAR)
      -----------------------------------------------------------------
      --INSERTA DETALLE DE POLIZA 
      -----------------------------------------------------------------
      PRINT 'GENERA DETALLE POLIZA '
      IF (@POLIZA_NUM > 0)
      BEGIN

        DECLARE @RESULTADO_POLIZA_DETAIL VARCHAR(2500) = NULL
        EXEC @RESULTADO_POLIZA_DETAIL = [wms].[OP_WMS_SP_INSERT_OP_WMS_POLIZA_DETAIL_EXT] @CUSTOMER = @CLIENTE
                                                                                             ,@USER = @USUARIO
                                                                                             ,@HEADER = @POLIZA_NUM

      --SELECT @RESULTADO_POLIZA_DETAIL [POLIZA_DETAIL]
      --PRINT 'LICENCIA OK'
      END
      ELSE
      BEGIN
        --PRINT 'LICENCIA ERROR'
        SET @ERROR = @ERROR + ' al generar poliza'
      END

      -----------------------------------------------------------------
      --GENERA LICENCIA DIST -1
      -----------------------------------------------------------------

      PRINT 'GENERA LICENCIA'
      DECLARE @RESULTADO_LICENCIA VARCHAR(250);
      DECLARE @LICENCIA INT
      EXEC [wms].[OP_WMS_SP_CREA_LICENCIA] @pCODIGO_POLIZA = @POLIZA_NUM
                                              ,@pLOGIN = @USUARIO
                                              ,@pLICENCIA_ID = @LICENCIA OUTPUT
                                              ,@pCLIENT_OWNER = @CLIENTE
                                              ,@pREGIMEN = 'GENERAL'
                                              ,@pResult = @RESULTADO_LICENCIA OUTPUT

      PRINT 'LICENCIA' + CAST(@LICENCIA AS VARCHAR)
      UPDATE [wms].[OP_WMS_LICENSES]
      SET [CURRENT_LOCATION] = @UBICACION
         ,[CURRENT_WAREHOUSE] = @BODEGA
         ,[STATUS] = 'ALLOCATED'
      WHERE [LICENSE_ID] = @LICENCIA

      --SELECT @RESULTADO_LICENCIA [LICENCIA] --233132
      SET @RESUMEN = @RESUMEN + '_' + @RESULTADO_LICENCIA



      -----------------------------------------------------------------
      --INSERTA DETALLE DE INVENTARIO POR LICENCIA
      -----------------------------------------------------------------
      PRINT 'GENERA INVENTARIO POLIZA '
      IF (@RESULTADO_POLIZA_DETAIL > 0)
      BEGIN

        DECLARE @RESULTADO_INVENTARIO_LICENCIA VARCHAR(250)
        EXEC @RESULTADO_INVENTARIO_LICENCIA = [wms].[OP_WMS_SP_UPDATE_OR_INSERT_OP_WMS_INV_X_LICENSE_EXT] @CUSTOMER = @CLIENTE
                                                                                                             ,@USER = @USUARIO
                                                                                                             ,@ACUERDO_COMERCIAL = @ACUERDO_COMERCIAL
                                                                                                             ,@RESULTADO = ''
                                                                                                             ,@LICENSE_ID = @LICENCIA
                                                                                                             ,@POLIZA = @POLIZA_NUM
                                                                                                             ,@LOCATION = @UBICACION
                                                                                                             ,@WAREHOUSE = @BODEGA




        PRINT 'ERRO -' + @RESULTADO_INVENTARIO_LICENCIA

      --SELECT @RESULTADO_INVENTARIO_LICENCIA [INVENTARIO_LICENCIA]
      END
      ELSE
      BEGIN
        SET @ERROR = @ERROR + ' al generar poliza detalle'
      END



      TRUNCATE TABLE [wms].[OP_WMS_CHARGE_EXTERNAL_INVENTORY]

      SELECT
        'EXITO|' + CAST(@POLIZA_NUM AS VARCHAR) + '|' + CAST(@LICENCIA AS VARCHAR) + ''

    END TRY
    BEGIN CATCH
      TRUNCATE TABLE [wms].[OP_WMS_CHARGE_EXTERNAL_INVENTORY]
      SELECT
        @ERROR + ERROR_MESSAGE()---1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo 
    END CATCH
  END