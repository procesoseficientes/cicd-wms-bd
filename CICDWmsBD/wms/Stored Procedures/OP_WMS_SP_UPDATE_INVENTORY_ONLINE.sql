-- =============================================
-- Autor:				Henry.Rodriguez
-- Fecha de Creacion: 	2019-04-08 G-FORCE@/WAPITI
-- Description:	        SP que actualiza inventario en linea

/*
		EXEC wms.OP_WMS_SP_UPDATE_INVENTORY_ONLINE @XML = '<DataSet>
																  <Inventory>
																	<Licencia>297742</Licencia>
																	<Ubicacion>B01-P01</Ubicacion>
																	<Codigo_Material>viscosa/VBA1001</Codigo_Material>
																	<Descripcion>Bando Faja 5PK970</Descripcion>
																	<inv.Licencia>5.0000</inv.Licencia>
																	<Estado>ESTADO_DEFAULT</Estado>
																	<Numero_Lote>001</Numero_Lote>
																	<Fecha_Expiracion>04/10/2019 00:00:00</Fecha_Expiracion>
																	<Tono>10</Tono>
																	<Calibre />
																	<PK_LINE>477271</PK_LINE>
																	<BATCH_REQUESTED>0</BATCH_REQUESTED>
																	<STATUS_ID>13156</STATUS_ID>
																	<TONE_AND_CALIBER_ID>3144</TONE_AND_CALIBER_ID>
																	<USER>ADMINISTRADOR</USER>
																  </Inventory>
																</DataSet>'
																																
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_UPDATE_INVENTORY_ONLINE] @XML AS XML
AS
BEGIN
    SET NOCOUNT ON;
    SELECT [x].[data].[query]('./PK_LINE').[value]('.', 'INTEGER') [PK_LINE],
           [x].[data].[query]('./Licencia').[value]('.', 'VARCHAR(50)') [Licencia],
           [x].[data].[query]('./Ubicacion').[value]('.', 'VARCHAR(50)') [Ubicacion],
           [x].[data].[query]('./Codigo_Material').[value]('.', 'VARCHAR(50)') [Codigo_Material],
           [x].[data].[query]('./Descripcion').[value]('.', 'VARCHAR(100)') [Descripcion],
           [x].[data].[query]('./inv.Licencia').[value]('.', 'VARCHAR(50)') [inv.Licencia],
           [x].[data].[query]('./Estado').[value]('.', 'VARCHAR(50)') [Estado],
           [x].[data].[query]('./Numero_Lote').[value]('.', 'VARCHAR(50)') [Numero_Lote],
           [x].[data].[query]('./Fecha_Expiracion').[value]('.', 'DATE') [Fecha_Expiracion],
           [x].[data].[query]('./Tono').[value]('.', 'VARCHAR(50)') [Tono],
           [x].[data].[query]('./Calibre').[value]('.', 'VARCHAR(50)') [Calibre],
           [x].[data].[query]('./STATUS_ID').[value]('.', 'INTEGER') [STATUS_ID],
           [x].[data].[query]('./TONE_AND_CALIBER_ID').[value]('.', 'VARCHAR(10)') [TONE_AND_CALIBER_ID],
           [x].[data].[query]('./USER').[value]('.', 'VARCHAR(50)') [USERNAME]
    INTO [#INVENTORY]
    FROM @XML.[nodes]('/DataSet/Inventory') AS [x]([data]);

    DECLARE @PK_LINE INTEGER;
    DECLARE @Licencia VARCHAR(50);
    DECLARE @Ubicacion VARCHAR(50);
    DECLARE @Codigo_Material VARCHAR(50);
    DECLARE @Estado VARCHAR(50);
    DECLARE @Numero_Lote VARCHAR(50);
    DECLARE @Fecha_Expiracion DATE;
    DECLARE @Tono VARCHAR(50);
    DECLARE @Calibre VARCHAR(50);
    DECLARE @STATUS_ID INTEGER;
    DECLARE @existTonoCaliber VARCHAR(10);
    DECLARE @USER VARCHAR(50);
    DECLARE @TextValue AS VARCHAR(200);
    DECLARE @Color AS VARCHAR(50);
    DECLARE @ID_TONE_CALIBER INTEGER;
    DECLARE @ID_UPD_TC INTEGER;
    DECLARE @JSON VARCHAR(MAX);

    BEGIN TRANSACTION;

    WHILE (EXISTS (SELECT * FROM [#INVENTORY]))
    BEGIN

        --SELECIONA EL PRIMER REGISTRO Y ASIGNA VALOR A LAS VARIABLES
        --TABLA TEMPORAL DE LOS DATOS XML
        SELECT TOP (1)
               @PK_LINE = [PK_LINE],
               @Licencia = [Licencia],
               @Ubicacion = [Ubicacion],
               @Codigo_Material = [Codigo_Material],
               @Estado = [Estado],
               @Numero_Lote = [Numero_Lote],
               @Fecha_Expiracion = [Fecha_Expiracion],
               @Tono = [Tono],
               @Calibre = [Calibre],
               @STATUS_ID = [STATUS_ID],
               @existTonoCaliber = [TONE_AND_CALIBER_ID],
               @USER = [USERNAME]
        FROM [#INVENTORY];

        --SELECIONA EL PRIMER REGISTRO Y ASIGNA VALOR A LAS VARIABLES
        --TABLA OP_WMS_CONFIGURATIONS 
        SELECT TOP 1
               @TextValue = [TEXT_VALUE],
               @Color = [COLOR]
        FROM [wms].[OP_WMS_CONFIGURATIONS]
        WHERE [PARAM_GROUP] = 'ESTADOS'
              AND [PARAM_NAME] = @Estado;

        --CREAR JSON
        SELECT @JSON
            = '{"PK_LINE":"' + CONVERT(VARCHAR(50), @PK_LINE, 120) + '","Licencia":"' + @Licencia
              + '","Codigo_Material":"' + @Codigo_Material + '","Estado anterior":"' + [SM].[STATUS_NAME] + '","Estado":"' + @Estado + '","Numero_Lote":"'
              + @Numero_Lote + '","Numero_Lote_anterior":"' + ISNULL([BATCH], '') + '","Fecha_Expiracion":"'
              + CONVERT(VARCHAR(50), @Fecha_Expiracion, 120) + '","Fecha_Expiracion_Anterior":"'
              + CONVERT(VARCHAR(50), ISNULL([DATE_EXPIRATION], ''), 120) + '","Tono":"' + @Tono
              + +'","Tono_Anterior":"' + ISNULL([TC].[TONE], '') + '","Calibre":"' + @Calibre
              + +'","CalibreAnterior":"' + ISNULL([TC].[CALIBER], '') + '"}'
        FROM [wms].[OP_WMS_INV_X_LICENSE] [il]
            LEFT JOIN [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TC]
                ON [TC].[TONE_AND_CALIBER_ID] = [il].[TONE_AND_CALIBER_ID]
			LEFT JOIN [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [SM]
                ON [SM].[LICENSE_ID] = [il].[LICENSE_ID]
        WHERE [PK_LINE] = @PK_LINE;

        --SI LOS VALORES SON VACIOS LOS RETORNA NULOS
        IF @Fecha_Expiracion = ''
           OR @Numero_Lote = ''
        BEGIN
            SET @Fecha_Expiracion = NULL;
            SET @Numero_Lote = NULL;
        END;

        IF @Tono = ''
        BEGIN
            SET @Tono = NULL;
        END;

        IF @Calibre = ''
        BEGIN
            SET @Calibre = NULL;
        END;

        BEGIN TRY

            --INSERTA UN NUEVO REGISTRO EN LA TABLA DE TONOS Y CALIBRES SI NO EXISTE
            IF @existTonoCaliber = ''
            BEGIN
                INSERT INTO [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL]
                (
                    [MATERIAL_ID],
                    [TONE],
                    [CALIBER]
                )
                VALUES
                (   @Codigo_Material, -- MATERIAL_ID - varchar(50)
                    @Tono,            -- TONE - varchar(20)
                    @Calibre          -- CALIBER - varchar(20)
                    );
                SELECT @ID_TONE_CALIBER = SCOPE_IDENTITY();
            END;

            ELSE
            BEGIN
                UPDATE [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL]
                SET [TONE] = @Tono,
                    [CALIBER] = @Calibre
                WHERE [TONE_AND_CALIBER_ID] = @existTonoCaliber;
            END;

            IF @ID_TONE_CALIBER <> 0
            BEGIN
                SET @ID_UPD_TC = @ID_TONE_CALIBER;
            END;
            ELSE
            BEGIN
                SET @ID_UPD_TC = @existTonoCaliber;
            END;

            --MODIFICA LOS CAMPOS EN LA TABLA DE INVENTARIO X LICENCIA 
            UPDATE [wms].[OP_WMS_INV_X_LICENSE]
            SET [DATE_EXPIRATION] = @Fecha_Expiracion,
                [BATCH] = @Numero_Lote,
                [TONE_AND_CALIBER_ID] = @ID_UPD_TC
            WHERE [PK_LINE] = @PK_LINE;

            --MODIFICA LOS CAMPOS EN ESTADO DE LA LICENCIA
            --VERIFICA SI EXISTE REGISTRO EN LA TABLA OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE
            --SI NO EXISTE AGREGA UN NUEVO REGISTRO.
            DECLARE @REGISTROS VARCHAR(50);
            DECLARE @NUEVO_ESTADO_ID INTEGER;

            IF EXISTS
            (
                SELECT *
                FROM [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE]
                WHERE [LICENSE_ID] = @Licencia
            )
            BEGIN
                UPDATE [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE]
                SET [STATUS_NAME] = @Estado,
                    [DESCRIPTION] = @TextValue,
                    [COLOR] = @Color,
                    [STATUS_CODE] = @Estado,
                    [LICENSE_ID] = @Licencia
                WHERE [STATUS_ID] = @STATUS_ID;
            END;
            ELSE
            BEGIN
                INSERT INTO [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE]
                (
                    [STATUS_NAME],
                    [BLOCKS_INVENTORY],
                    [ALLOW_REALLOC],
                    [TARGET_LOCATION],
                    [DESCRIPTION],
                    [COLOR],
                    [STATUS_CODE],
                    [LICENSE_ID]
                )
                VALUES
                (   @Estado,    -- STATUS_NAME - varchar(100)
                    0,          -- BLOCKS_INVENTORY - int
                    1,          -- ALLOW_REALLOC - int
                    '',         -- TARGET_LOCATION - varchar(25)
                    @TextValue, -- DESCRIPTION - varchar(200)
                    @Color,     -- COLOR - varchar(20)
                    @Estado,    -- STATUS_CODE - varchar(50)
                    @Licencia   -- LICENSE_ID - numeric
                    );
                SELECT @NUEVO_ESTADO_ID = SCOPE_IDENTITY();

                --ACTUALIZA EL STATUS_ID EN OP_WMS_INV_X_LICENSE DE LA LICENCIA QUE SE ESTA ACTUALIZANDO
                UPDATE [wms].[OP_WMS_INV_X_LICENSE]
                SET [STATUS_ID] = @NUEVO_ESTADO_ID
                WHERE [PK_LINE] = @PK_LINE;

            END;




            --PROCESO PARA INSERTAR LOG DE LOS CAMBIOS REALIZADOS

            EXECUTE [dbo].[OP_WMS_SP_INSERT_LOG_ERROR_WMS] @SOURCE_APP = 'BACKOFFICE',                                     -- varchar(50)
                                                           @METHOD = 'OP_WMS_SP_UPDATE_INVENTORY_ONLINE',                  -- varchar(200)
                                                           @SQL_FUNCTION_OR_SP_NAME = 'OP_WMS_SP_UPDATE_INVENTORY_ONLINE', -- varchar(300)
                                                           @LOGIN_ID = @USER,                                              -- varchar(50)
                                                           @JSON_REQUEST = @JSON,                                          -- varchar(max)
                                                           @MESSAGE_ERROR = '',                                            -- varchar(500)
                                                           @STACK_TRACE = '';                                              -- varchar(max)					

        END TRY
        BEGIN CATCH

            DECLARE @pResult VARCHAR(200),
                    @ErrorCode INT;
            SELECT @pResult = ERROR_MESSAGE();
            SELECT @ErrorCode = IIF(@@ERROR <> 0, @@ERROR, @ErrorCode);
            SELECT -1 AS [Resultado],
                   ERROR_MESSAGE() AS [Mensaje],
                   @ErrorCode AS [Codigo];

            EXECUTE [dbo].[OP_WMS_SP_INSERT_LOG_ERROR_WMS] @SOURCE_APP = 'BACKOFFICE',                                     -- varchar(50)
                                                           @METHOD = 'OP_WMS_SP_UPDATE_INVENTORY_ONLINE',                  -- varchar(200)
                                                           @SQL_FUNCTION_OR_SP_NAME = 'OP_WMS_SP_UPDATE_INVENTORY_ONLINE', -- varchar(300)
                                                           @LOGIN_ID = @USER,                                              -- varchar(50)
                                                           @JSON_REQUEST = @JSON,                                          -- varchar(max)
                                                           @MESSAGE_ERROR = @pResult,                                      -- varchar(500)
                                                           @STACK_TRACE = @pResult;                                        -- varchar(max)

        END CATCH;

        --ELIMINA EL PRIMER REGISTRO QUE SE INSERTO CORRECTAMENTE
        DELETE TOP (1)
        FROM [#INVENTORY];

    END;


    COMMIT TRANSACTION;


END;