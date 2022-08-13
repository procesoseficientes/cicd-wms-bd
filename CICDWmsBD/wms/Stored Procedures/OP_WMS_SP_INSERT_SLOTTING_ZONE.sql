-- =============================================
-- Autor:					henry.rodriguez
-- Fecha de Creacion: 		12-Junio-19 @ GForce-Team Sprint Cancun
-- Description:			    Inserta nueva configuracion de slotting
--/*
-- Ejemplo de Ejecucion:
--        EXECUTE [wms].[OP_WMS_SP_INSERT_SLOTTING_ZONE] @WAREHOUSE_CODE = 'BODEGA_01', -- varchar(25)
--														 @ZONE_ID = 64, -- int
--														 @ZONE = 'Z_BODEGA_01', -- varchar(50)
--														 @MANDATORY = 0 -- bit
--*/
-- =============================================

CREATE PROCEDURE [wms].[OP_WMS_SP_INSERT_SLOTTING_ZONE]
    (
      @WAREHOUSE_CODE VARCHAR(25) ,
      @ZONE_ID INTEGER ,
      @ZONE VARCHAR(50) ,
      @MANDATORY BIT
    )
AS

    BEGIN TRY

        INSERT  INTO [wms].[OP_WMS_SLOTTING_ZONE]
                ( [ID] ,
                  [WAREHOUSE_CODE] ,
                  [ZONE_ID] ,
                  [ZONE] ,
                  [MANDATORY]
		        )
        VALUES  ( NEWID() , -- ID - UNIQUEIDENTIFIER
                  @WAREHOUSE_CODE , -- WAREHOUSE_CODE - varchar(25)
                  @ZONE_ID , -- ZONE_ID - int
                  @ZONE , -- ZONE_DESCRIPTION - varchar(50)
                  @MANDATORY  -- MANDATORY - bit
		        );
		
        SELECT  1 AS [Resultado] ,
                'Proceso Exitoso' [Mensaje] ,
                0 [Codigo];

    END TRY
    BEGIN CATCH
        SELECT  -1 AS [Resultado] ,
                ERROR_MESSAGE() [Mensaje] ,
                @@ERROR [Codigo];
    END CATCH;