-- =============================================
-- Autor:					henry.rodriguez
-- Fecha de Creacion: 		13-Junio-19 @ GForce-Team Sprint Cancun
-- Description:			    INSERTA LOS DATOS ENVIADOS DEL EXCEL

-- Autor:					kevin.guerra
-- Fecha de Creacion: 		30-03-2020 @ GForce@Paris Sprint B
-- Description:			    Ahora se maneja subfamilias por parte de wms.
/*
-- Ejemplo de Ejecucion:
EXECUTE [wms].[OP_WMS_SP_INSERT_SLOTTING_ZONE_BY_XML] @XML = '<ArrayOfZonaDePosicionamiento>
																	<ZonaDePosicionamiento>
																		<WAREHOUSE_CODE>BODEGA_02</WAREHOUSE_CODE>
																		<ZONE_ID>0</ZONE_ID>
																		<ZONE>Z_BODEGA_02</ZONE>
																		<FAMILY></FAMILY>
																		<CLASS_NAME></CLASS_NAME>
																		<MANDATORY>false</MANDATORY>
																	</ZonaDePosicionamiento>
																	<ZonaDePosicionamiento>
																		<WAREHOUSE_CODE>BODEGA_02</WAREHOUSE_CODE>
																		<ZONE_ID>0</ZONE_ID>
																		<ZONE>Z_BODEGA_02</ZONE>
																		<FAMILY>1</FAMILY>
																		<CLASS_NAME></CLASS_NAME>
																		<MANDATORY>false</MANDATORY>
																	</ZonaDePosicionamiento>
																</ArrayOfZonaDePosicionamiento>'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_INSERT_SLOTTING_ZONE_BY_XML] ( @XML AS XML )
AS
    BEGIN TRY

        SET NOCOUNT ON;

  ---------------------------------------------------------------------------------
  -- DECLARAMOS VARIABLE DE TIPO TABLA PARA ALMACENAR LOS DATOS DE XML -- TABLA PRINCIPAL
  ---------------------------------------------------------------------------------

        DECLARE @TEMPLATE_TABLE TABLE
            (
              [SLOTTING_ID] UNIQUEIDENTIFIER ,
              [WAREHOUSE_ID] VARCHAR(25) ,
              [ZONE_ID] INTEGER ,
              [ZONE] VARCHAR(50) ,
              [CLASS_ID] INTEGER ,
              [CLASS_NAME] VARCHAR(50) ,
              [MANDATORY] VARCHAR(10)
            );

  ---------------------------------------------------------------------------------
  -- DECLARAMOS UNA VARIABLE TIPO TABLA PARA ALMACER LOS DATOS DEL XML
  -- EN ESTA TABLA MANIPULAREMOS LOS REGISTROS
  ---------------------------------------------------------------------------------
    
        DECLARE @SLOTTING_ZONE_TABLE TABLE
            (
              [SLOTTING_ID] UNIQUEIDENTIFIER ,
              [WAREHOUSE_ID] VARCHAR(25) ,
              [ZONE_ID] INTEGER ,
              [ZONE] VARCHAR(50) ,
              [CLASS_ID] INTEGER ,
              [CLASS_NAME] VARCHAR(50) ,
              [MANDATORY] VARCHAR(10)
            );

  ---------------------------------------------------------------------------------
  -- LEEMOS DOCUMENTO XML E INSERTAMOS LOS DATOS A NUESTRA TABLA TEMPORAL -- PRINCIPAL
  ---------------------------------------------------------------------------------

        INSERT  INTO @TEMPLATE_TABLE
                ( [WAREHOUSE_ID] ,
                  [ZONE_ID] ,
                  [ZONE] ,
                  [CLASS_ID] ,
                  [CLASS_NAME] ,
                  [MANDATORY]
                )
                SELECT  [x].[data].[query]('./WAREHOUSE_CODE').[value]('.',
                                                              'VARCHAR(25)') [WAREHOUSE_ID] ,
                        [x].[data].[query]('./ZONE_ID').[value]('.', 'INTEGER') [ZONE_ID] ,
                        [x].[data].[query]('./ZONE').[value]('.',
                                                             'VARCHAR(50)') [ZONE_DESCRIPTION] ,
                        [x].[data].[query]('./FAMILY').[value]('.', 'INTEGER') [CLASS_ID] ,
                        [x].[data].[query]('./CLASS_NAME').[value]('.',
                                                              'VARCHAR(50)') [CLASS_NAME] ,
                        [x].[data].[query]('./MANDATORY').[value]('.',
                                                              'VARCHAR(5)') [MANDATORY]
                FROM    @XML.[nodes]('/ArrayOfZonaDePosicionamiento/ZonaDePosicionamiento')
                        AS [x] ( [data] );

  ---------------------------------------------------------------------------------
  -- INSERTAMOS LOS DATOS DE LA PRINCIPAL QUE CUMPLAN LA CONDICION
  -- VERIFICA SI LA ZONA EXISTE
  ---------------------------------------------------------------------------------
        INSERT  INTO @SLOTTING_ZONE_TABLE
                ( [WAREHOUSE_ID] ,
                  [ZONE_ID] ,
                  [ZONE]
                )
                SELECT  [TT].[WAREHOUSE_ID] ,
                        [TT].[ZONE_ID] ,
                        [TT].[ZONE]
                FROM    @TEMPLATE_TABLE [TT]
                        LEFT JOIN [wms].[OP_WMS_ZONE] [Z] ON ( [TT].[ZONE] = [Z].[ZONE]
                                                              AND [TT].[WAREHOUSE_ID] = [Z].[WAREHOUSE_CODE]
                                                              )
                WHERE   [Z].[ZONE_ID] IS NULL;


  ---------------------------------------------------------------------------------
  -- SI NO EXISTE LA ZONA O BODEGA RETORNA LOS REGISTROS NO ENCONTRADOS
  ---------------------------------------------------------------------------------

        IF ( EXISTS ( SELECT    1
                      FROM      @SLOTTING_ZONE_TABLE ) )
            BEGIN

                SELECT  -1 AS [Resultado] ,
                        CONCAT('No se encontro bodega: ', [F].[WAREHOUSE_ID],
                               ' , zona: ', [F].[ZONE]) AS [Mensaje] ,
                        -1 AS [Codigo]
                FROM    @SLOTTING_ZONE_TABLE [F];
                RETURN;
            END;

  ---------------------------------------------------------------------------------
  --DECLARAMOS LAS VARIABLES A UTILIZAR.
  ---------------------------------------------------------------------------------  
        DECLARE @SLOTTING_ID UNIQUEIDENTIFIER = NULL;
        DECLARE @WAREHOUSE_ID AS VARCHAR(25);
        DECLARE @ZONE_ID AS INTEGER;
        DECLARE @ZONE AS VARCHAR(50);
        DECLARE @CLASS_ID AS INTEGER;
        DECLARE @CLASS_NAME VARCHAR(50);
        DECLARE @MANDATORY VARCHAR(10);
        DECLARE @ID_ZONE AS INTEGER;
        DECLARE @PARAMETER_USE_SUB_FAMILY VARCHAR(50);

        SELECT  @PARAMETER_USE_SUB_FAMILY = value
        FROM    [wms].[OP_WMS_PARAMETER]
        WHERE   [GROUP_ID] = 'MATERIAL_SUB_FAMILY'
                AND [PARAMETER_ID] = 'USE_MATERIAL_SUB_FAMILY';

        IF ( @PARAMETER_USE_SUB_FAMILY IS NULL
             OR @PARAMETER_USE_SUB_FAMILY = '0'
           )
            BEGIN

  ---------------------------------------------------------------------------------
  -- INSERTAMOS LOS DATOS DE LA PRINCIPAL QUE CUMPLAN LA CONDICION
  -- VERIFICA SI LAS FAMILIAS EXISTEN
  ---------------------------------------------------------------------------------

                INSERT  INTO @SLOTTING_ZONE_TABLE
                        ( [WAREHOUSE_ID] ,
                          [CLASS_ID]
                        )
                        SELECT  [TT].[WAREHOUSE_ID] ,
                                [TT].[CLASS_ID]
                        FROM    @TEMPLATE_TABLE [TT]
                                LEFT JOIN [wms].[OP_WMS_CLASS] [C] ON [TT].[CLASS_ID] = [C].[CLASS_ID]
                        WHERE   [C].[CLASS_NAME] IS NULL;


  ---------------------------------------------------------------------------------
  -- SI NO EXISTEN LAS FAMILIAS MUESTRA LOS REGISTROS
  ---------------------------------------------------------------------------------

                IF ( EXISTS ( SELECT    1
                              FROM      @SLOTTING_ZONE_TABLE ) )
                    BEGIN

                        SELECT  -1 AS [Resultado] ,
                                CONCAT('No se encontro la familia: ',
                                       [F].[CLASS_ID], ', bodega: ',
                                       [F].[WAREHOUSE_ID]) AS [Mensaje] ,
                                -1 AS [Codigo]
                        FROM    @SLOTTING_ZONE_TABLE [F];
                        RETURN;
                    END;

  ---------------------------------------------------------------------------------
  -- SI LOS DATOS SON VERIFICADOS CORRECTAMENTE SE INSERTAN EN NUESTRA SEGUNDA TABLA
  ---------------------------------------------------------------------------------
  
                INSERT  INTO @SLOTTING_ZONE_TABLE
                        ( [SLOTTING_ID] ,
                          [WAREHOUSE_ID] ,
                          [ZONE_ID] ,
                          [ZONE] ,
                          [CLASS_ID] ,
                          [CLASS_NAME] ,
                          [MANDATORY]
                        )
                        SELECT  [SZ].[ID] ,
                                [TT].[WAREHOUSE_ID] ,
                                [TT].[ZONE_ID] ,
                                [TT].[ZONE] ,
                                [TT].[CLASS_ID] ,
                                [TT].[CLASS_NAME] ,
                                [TT].[MANDATORY]
                        FROM    @TEMPLATE_TABLE [TT]
                                LEFT JOIN [wms].[OP_WMS_SLOTTING_ZONE] [SZ] ON ( [TT].[ZONE] = [SZ].[ZONE]
                                                              AND [TT].[WAREHOUSE_ID] = [SZ].[WAREHOUSE_CODE]
                                                              );

  ---------------------------------------------------------------------------------
  -- VERIFICA SI NO EXISTEN CONFIGURACIONES DE SLOTTING
  -- SI NO EXISTEN LAS CREA
  ---------------------------------------------------------------------------------

                WHILE ( EXISTS ( SELECT 1
                                 FROM   @SLOTTING_ZONE_TABLE
                                 WHERE  [SLOTTING_ID] IS NULL ) )
                    BEGIN

                        SET @SLOTTING_ID = NEWID();

                        SELECT TOP ( 1 )
                                @WAREHOUSE_ID = [SST].[WAREHOUSE_ID] ,
                                @ZONE_ID = [SST].[ZONE_ID] ,
                                @ZONE = [SST].[ZONE] ,
                                @MANDATORY = [SST].[MANDATORY]
                        FROM    @SLOTTING_ZONE_TABLE [SST]
                        WHERE   [SST].[SLOTTING_ID] IS NULL;

                        SELECT  @ID_ZONE = 0;
                        SELECT  @ID_ZONE = [ZONE_ID]
                        FROM    [wms].[OP_WMS_ZONE]
                        WHERE   [ZONE] = @ZONE;

                        INSERT  INTO [wms].[OP_WMS_SLOTTING_ZONE]
                                ( [ID] ,
                                  [WAREHOUSE_CODE] ,
                                  [ZONE_ID] ,
                                  [ZONE] ,
                                  [MANDATORY]
                                )
                        VALUES  ( @SLOTTING_ID ,
                                  @WAREHOUSE_ID ,
                                  @ID_ZONE ,
                                  @ZONE ,
                                  @MANDATORY
                                );      

                        UPDATE  @SLOTTING_ZONE_TABLE
                        SET     [SLOTTING_ID] = @SLOTTING_ID
                        WHERE   [WAREHOUSE_ID] = @WAREHOUSE_ID
                                AND [ZONE] = @ZONE;
                    END;

  ---------------------------------------------------------------------------------
  -- ACTUALIZA EL ESTADO DEL CAMPO MANDATORIO
  ---------------------------------------------------------------------------------

                UPDATE  [SZ]
                SET     [SZ].[MANDATORY] = [SZT].[MANDATORY]
                FROM    [wms].[OP_WMS_SLOTTING_ZONE] [SZ]
                        INNER JOIN @SLOTTING_ZONE_TABLE [SZT] ON [SZ].[ID] = [SZT].[SLOTTING_ID];

  ---------------------------------------------------------------------------------
  -- INSERTA LAS FAMILIAS A LOS RESPECTIVOS SLOTTINGS
  ---------------------------------------------------------------------------------


                DELETE  [SZT]
                FROM    [wms].[OP_WMS_SLOTTING_ZONE_BY_CLASS] [SZBC]
                        INNER JOIN @SLOTTING_ZONE_TABLE [SZT] ON ( [SZBC].[CLASS_ID] = [SZT].[CLASS_ID]
                                                              AND [SZBC].[ID_SLOTTING_ZONE] = [SZT].[SLOTTING_ID]
                                                              );

                INSERT  INTO [wms].[OP_WMS_SLOTTING_ZONE_BY_CLASS]
                        ( [ID_SLOTTING_ZONE] ,
                          [CLASS_ID] ,
                          [CLASS_NAME]
                        )
                        SELECT  [SZT].[SLOTTING_ID] ,
                                [SZT].[CLASS_ID] ,
                                [C].[CLASS_NAME]
                        FROM    @SLOTTING_ZONE_TABLE AS [SZT]
                                INNER JOIN [wms].[OP_WMS_SLOTTING_ZONE] [SZ] ON ( [SZT].[SLOTTING_ID] = [SZ].[ID] )
                                INNER JOIN [wms].[OP_WMS_CLASS] [C] ON [SZT].[CLASS_ID] = [C].[CLASS_ID];

                SELECT  1 AS [Resultado] ,
                        'Proceso Exitoso' [Mensaje] ,
                        0 [Codigo];

            END;
        ELSE
            BEGIN

  ---------------------------------------------------------------------------------
  -- INSERTAMOS LOS DATOS DE LA PRINCIPAL QUE CUMPLAN LA CONDICION
  -- VERIFICA SI LAS SUB FAMILIAS EXISTEN
  ---------------------------------------------------------------------------------

                INSERT  INTO @SLOTTING_ZONE_TABLE
                        ( [WAREHOUSE_ID] ,
                          [CLASS_ID]
                        )
                        SELECT  [TT].[WAREHOUSE_ID] ,
                                [TT].[CLASS_ID]
                        FROM    @TEMPLATE_TABLE [TT]
                                LEFT JOIN [wms].[OP_WMS_SUB_CLASS] [C] ON [TT].[CLASS_ID] = [C].[SUB_CLASS_ID]
                        WHERE   [C].[SUB_CLASS_NAME] IS NULL;


  ---------------------------------------------------------------------------------
  -- SI NO EXISTEN LAS SUB FAMILIAS MUESTRA LOS REGISTROS
  ---------------------------------------------------------------------------------

                IF ( EXISTS ( SELECT    1
                              FROM      @SLOTTING_ZONE_TABLE ) )
                    BEGIN

                        SELECT  -1 AS [Resultado] ,
                                CONCAT('No se encontro la familia: ',
                                       [F].[CLASS_ID], ', bodega: ',
                                       [F].[WAREHOUSE_ID]) AS [Mensaje] ,
                                -1 AS [Codigo]
                        FROM    @SLOTTING_ZONE_TABLE [F];
                        RETURN;
                    END;

  ---------------------------------------------------------------------------------
  -- SI LOS DATOS SON VERIFICADOS CORRECTAMENTE SE INSERTAN EN NUESTRA SEGUNDA TABLA
  ---------------------------------------------------------------------------------
  
                INSERT  INTO @SLOTTING_ZONE_TABLE
                        ( [SLOTTING_ID] ,
                          [WAREHOUSE_ID] ,
                          [ZONE_ID] ,
                          [ZONE] ,
                          [CLASS_ID] ,
                          [CLASS_NAME] ,
                          [MANDATORY]
                        )
                        SELECT  [SZ].[ID] ,
                                [TT].[WAREHOUSE_ID] ,
                                [TT].[ZONE_ID] ,
                                [TT].[ZONE] ,
                                [TT].[CLASS_ID] ,
                                [TT].[CLASS_NAME] ,
                                [TT].[MANDATORY]
                        FROM    @TEMPLATE_TABLE [TT]
                                LEFT JOIN [wms].[OP_WMS_SLOTTING_ZONE] [SZ] ON ( [TT].[ZONE] = [SZ].[ZONE]
                                                              AND [TT].[WAREHOUSE_ID] = [SZ].[WAREHOUSE_CODE]
                                                              );

  ---------------------------------------------------------------------------------
  -- VERIFICA SI NO EXISTEN CONFIGURACIONES DE SLOTTING
  -- SI NO EXISTEN LAS CREA
  ---------------------------------------------------------------------------------

                WHILE ( EXISTS ( SELECT 1
                                 FROM   @SLOTTING_ZONE_TABLE
                                 WHERE  [SLOTTING_ID] IS NULL ) )
                    BEGIN

                        SET @SLOTTING_ID = NEWID();

                        SELECT TOP ( 1 )
                                @WAREHOUSE_ID = [SST].[WAREHOUSE_ID] ,
                                @ZONE_ID = [SST].[ZONE_ID] ,
                                @ZONE = [SST].[ZONE] ,
                                @MANDATORY = [SST].[MANDATORY]
                        FROM    @SLOTTING_ZONE_TABLE [SST]
                        WHERE   [SST].[SLOTTING_ID] IS NULL;

                        SELECT  @ID_ZONE = 0;
                        SELECT  @ID_ZONE = [ZONE_ID]
                        FROM    [wms].[OP_WMS_ZONE]
                        WHERE   [ZONE] = @ZONE;

                        INSERT  INTO [wms].[OP_WMS_SLOTTING_ZONE]
                                ( [ID] ,
                                  [WAREHOUSE_CODE] ,
                                  [ZONE_ID] ,
                                  [ZONE] ,
                                  [MANDATORY]
                                )
                        VALUES  ( @SLOTTING_ID ,
                                  @WAREHOUSE_ID ,
                                  @ID_ZONE ,
                                  @ZONE ,
                                  @MANDATORY
                                );      

                        UPDATE  @SLOTTING_ZONE_TABLE
                        SET     [SLOTTING_ID] = @SLOTTING_ID
                        WHERE   [WAREHOUSE_ID] = @WAREHOUSE_ID
                                AND [ZONE] = @ZONE;
                    END;

  ---------------------------------------------------------------------------------
  -- ACTUALIZA EL ESTADO DEL CAMPO MANDATORIO
  ---------------------------------------------------------------------------------

                UPDATE  [SZ]
                SET     [SZ].[MANDATORY] = [SZT].[MANDATORY]
                FROM    [wms].[OP_WMS_SLOTTING_ZONE] [SZ]
                        INNER JOIN @SLOTTING_ZONE_TABLE [SZT] ON [SZ].[ID] = [SZT].[SLOTTING_ID];

  ---------------------------------------------------------------------------------
  -- INSERTA LAS SUB FAMILIAS A LOS RESPECTIVOS SLOTTINGS
  ---------------------------------------------------------------------------------


                DELETE  [SZT]
                FROM    [wms].[OP_WMS_SLOTTING_ZONE_BY_SUB_CLASS] [SZBC]
                        INNER JOIN @SLOTTING_ZONE_TABLE [SZT] ON ( [SZBC].[SUB_CLASS_ID] = [SZT].[CLASS_ID]
                                                              AND [SZBC].[ID_SLOTTING_ZONE] = [SZT].[SLOTTING_ID]
                                                              );

                INSERT  INTO [wms].[OP_WMS_SLOTTING_ZONE_BY_SUB_CLASS]
                        ( [ID_SLOTTING_ZONE] ,
                          [SUB_CLASS_ID] ,
                          [SUB_CLASS_NAME]
                        )
                        SELECT  [SZT].[SLOTTING_ID] ,
                                [SZT].[CLASS_ID] ,
                                [C].[SUB_CLASS_NAME]
                        FROM    @SLOTTING_ZONE_TABLE AS [SZT]
                                INNER JOIN [wms].[OP_WMS_SLOTTING_ZONE] [SZ] ON ( [SZT].[SLOTTING_ID] = [SZ].[ID] )
                                INNER JOIN [wms].[OP_WMS_SUB_CLASS] [C] ON [SZT].[CLASS_ID] = [C].[SUB_CLASS_ID];

                SELECT  1 AS [Resultado] ,
                        'Proceso Exitoso' [Mensaje] ,
                        0 [Codigo];

            END;

    END TRY

    BEGIN CATCH

        SELECT  -1 AS [Resultado] ,
                ERROR_MESSAGE() [Mensaje] ,
                @@ERROR [Codigo];
    END CATCH;