
-- =============================================
-- Autor:                jose.garcia
-- Fecha de Creacion:     06-01-2016
-- Description:            Resta el inventario de la tabla inv_x_licencia
/*
-- Ejemplo de Ejecucion:
                --

                exec [wms].[OP_WMS_SP_UPDATE_INV_X_LICENSE_EXT]
                            @QTY ='30'
                            ,@MATERIAL_ID ='C00330/1193190'


                --
*/
-- =============================================

CREATE PROCEDURE [wms].OP_WMS_SP_UPDATE_INV_X_LICENSE_EXT
                           
  (  @QTY AS NUMERIC(18,2)
   ,@MATERIAL_ID AS VARCHAR(25)
    ,@LOGIN_ID AS VARCHAR(25)
    ,@WAVE_PICKING_ID DECIMAL
    ,@CODIGO_POLIZA VARCHAR(15) 
  )


AS
BEGIN
    DECLARE @QTY_FOR_LICENCIA NUMERIC(18,2)
    DECLARE @LICENCE_ID VARCHAR(25)
    DECLARE @RESULTADO VARCHAR(50) ='ANTES'
    

    WHILE (@QTY>0)
    BEGIN

        --OBTENEMOS LA LICENCIA A DESPACHAR
        SELECT TOP 1 @LICENCE_ID = LICENSE_ID, @QTY_FOR_LICENCIA =  QTY FROM [wms].[OP_WMS_INV_X_LICENSE]
        WHERE MATERIAL_ID=@MATERIAL_ID AND QTY>0


        --OBTENEMOS LA CANTIDAD DE LA LICENCIA A DESPACHAR
--        SELECT @QTY_FOR_LICENCIA = QTY FROM [wms].[OP_WMS_INV_X_LICENSE]
--        WHERE LICENSE_ID= @LICENCE_ID AND MATERIAL_ID=@MATERIAL_ID

        --COMPARAMOS SI LA PRIMERA LICENCIA CUBRE EL DESPACHO O DE DESPACHA DE VARIAS
        IF (@QTY>@QTY_FOR_LICENCIA)
        BEGIN

            --RESTAMOS CANTIDAD DE DESPACHO

                SET @QTY=@QTY-@QTY_FOR_LICENCIA

            --DEJAMOS LICENCIA EN 0
                UPDATE
                [wms].[OP_WMS_INV_X_LICENSE]
                SET QTY=0
                WHERE LICENSE_ID= @LICENCE_ID
                AND MATERIAL_ID= @MATERIAL_ID

                
                EXEC [wms].OP_WMS_SP_INSERT_TASK_EXT @WAVE_PICKING_ID = @WAVE_PICKING_ID
                                                    , @QTY = @QTY
                                                    , @LICENCE_ID = @LICENCE_ID
                                                    , @MATERIAL_ID = @MATERIAL_ID
                                                    , @LOGIN_ID = @LOGIN_ID
                                                    , @CODIGIO_POLIZA_TARGET= @CODIGO_POLIZA
                --SET @RESULTADO='EXITO'
                --SELECT @RESULTADO AS RESTULTADO
        END
            ELSE
            BEGIN

            --HACER EL UPDATE A LA LICENCIA
                UPDATE
                 [wms].[OP_WMS_INV_X_LICENSE]
                    SET QTY=QTY-@QTY
                    WHERE LICENSE_ID= @LICENCE_ID
                    AND MATERIAL_ID= @MATERIAL_ID

                    EXEC [wms].OP_WMS_SP_INSERT_TASK_EXT @WAVE_PICKING_ID = @WAVE_PICKING_ID
                                                    , @QTY = @QTY
                                                    , @LICENCE_ID = @LICENCE_ID
                                                    , @MATERIAL_ID = @MATERIAL_ID
                                                    , @LOGIN_ID = @LOGIN_ID
                                                    , @CODIGIO_POLIZA_TARGET= @CODIGO_POLIZA
                    RETURN 2
                        --IF (@RESULTADO !='EXITO')
                        --    BEGIN
                        --        SELECT @RESULTADO AS RESTULTADO
                        --    END
                        --        ELSE
                        --        BEGIN
                        --        SET @RESULTADO='EXITO'
                        --            SELECT @RESULTADO AS RESTULTADO
                    --END
            END
            



END

END