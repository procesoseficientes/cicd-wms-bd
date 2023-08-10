-- =============================================
-- Autor:				pablo.aguilar
-- Fecha de Creacion: 	05-Jul-19 @ Nexus Team Sprint  
-- Description:			SP que 
/*
-- Ejemplo de Ejecucion:
				EXEC [dbo].[SAE_CREATE_INVENTORY_INCOME_BY_CREDIT_MEMO_SAE_PRUEBAS] @RECEPTION_DOCUMENT_HEADER = 725 -- numeric
				ROLLBACK
*/
-- =============================================
CREATE PROCEDURE [dbo].[SAE_CREATE_INVENTORY_INCOME_BY_CREDIT_MEMO_SAE_PRUEBAS1]
(@RECEPTION_DOCUMENT_HEADER NUMERIC)
AS
BEGIN
    SET NOCOUNT ON;
    --

    -- ------------------------------------------------------------------------------------
    -- Declaramos variables
    -- ------------------------------------------------------------------------------------
    DECLARE @TABLA_DOCUMENTO_32 INT = 32,
            @ULTIMO_DOCUMENTO_32 INT = 0,
            @TIPO_DOCUMENTO_FOLIO VARCHAR(1) = 'D',
            @SERIE_FOLIO VARCHAR(25) = '00000106-',
            @ULT_DOC_FOLIO [INT],
            @FOLIO_DESDE INT,
            @CODIGO_PROVEEDOR_SAE VARCHAR(10),
            @NOMBRE_PROVEEDOR_SAE VARCHAR(100),
            @TABLA_DOCUMENTO_COMENTARIO INT = 56,
            @ULTIMO_DOCUMENTO_COMENTARIO INT = 0,
            @FECHA_SYNC DATETIME = GETDATE(),
            @DOCUMENTO_ERP_FORMATEADO VARCHAR(25),
            @TOTAL_COMPRA FLOAT,
            @TOTAL_IMPUESTO_COMPRA FLOAT,
            @TOTAL_IMPORTE FLOAT,
            @TOTAL_IMPUESTO_01 FLOAT,
            @TOTAL_IMPUESTO_02 FLOAT,
            @TOTAL_IMPUESTO_03 FLOAT,
            @TOTAL_IMPUESTO_04 FLOAT,
            @TOTAL_DESCUENTO_01 FLOAT,
            @TOTAL_DESCUENTO_02 FLOAT,
            @TOTAL_DESCUENTO_03 FLOAT,
            @MES_ACTUAL DATETIME = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0),
            @FECHA_HOY DATETIME = DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0),
            @FACTURA_DOCUMENTO VARCHAR(50),
            @COMENTARIO VARCHAR(200),
            @TABLA_DOCUMENTO_BITACORA INT = 62,
            @ULTIMO_DOCUMENTO_BITACORA INT = 0,
            @USUARIO_OPERA SMALLINT = 477,
            @USUARIO_OPERA_NOMBRE VARCHAR(50) = 'wms';



    --VARIABLES DETALLE
    DECLARE @ERP_MATERIAL_CODE VARCHAR(25),
            @MATERIAL_ID_DETAIL VARCHAR(25),
            @LINE_NUM_DETAIL INT,
            @QTY_DETAIL NUMERIC(18, 6),
            @CVE_CPTO INT = 2,
            @SIGNO SMALLINT,
            @TIPO_MOV VARCHAR(1),
            @TABLA_DOCUMENTO_MOVIMIENTO INT = 44,
            @ULTIMO_DOCUMENTO_MOVIMIENTO INT = 0,
            @COSTO_ARTICULO_DOCUMENTO FLOAT,
            @COSTO_PROMEDO_CALCULADO FLOAT,
            @COSTO_PROMEDIO_ANTERIOR FLOAT,
            @PRECIO FLOAT,
            @EXISTENCIAS FLOAT = 0,
            @EXISTENCIAS_GENERAL FLOAT = 0,
            @CONTADOR_LINEA INT = 0,
            @ALMACEN INT = 0;

    BEGIN TRY
        BEGIN TRANSACTION;
        -- ------------------------------------------------------------------------------------
        -- obtiene datos de Wms
        -- ------------------------------------------------------------------------------------

        SELECT [D].[ERP_RECEPTION_DOCUMENT_DETAIL_ID],
               [D].[ERP_RECEPTION_DOCUMENT_HEADER_ID],
               [D].[MATERIAL_ID],
               [D].[QTY],
               [D].[LINE_NUM],
               [D].[ERP_OBJECT_TYPE],
               [D].[WAREHOUSE_CODE],
               [D].[CURRENCY],
               [D].[RATE],
               [D].[TAX_CODE],
               [D].[VAT_PERCENT],
               [D].[PRICE],
               [D].[DISCOUNT],
               [D].[COST_CENTER],
               [D].[QTY_ASSIGNED],
               [D].[UNIT],
               [D].[UNIT_DESCRIPTION],
               [D].[QTY_CONFIRMED],
               [D].[IS_CONFIRMED],
               0 [ENVIADO],
               [M].[ITEM_CODE_ERP],
               [M].[BASE_MEASUREMENT_UNIT],
               [H].[DOC_ID],
               [H].[TYPE],
               [H].[CODE_SUPPLIER],
               [H].[CODE_CLIENT],
               [H].[ERP_DATE],
               [H].[IS_AUTHORIZED],
               [H].[IS_COMPLETE],
               [H].[TASK_ID],
               [H].[EXTERNAL_SOURCE_ID],
               [H].[ERP_REFERENCE_DOC_NUM],
               [H].[DOC_NUM],
               [H].[NAME_SUPPLIER],
               [H].[OWNER],
               [H].[IS_FROM_WAREHOUSE_TRANSFER],
               [H].[IS_FROM_ERP],
               [H].[DOC_ID_POLIZA],
               [H].[LOCKED_BY_INTERFACES],
               [H].[IS_VOID],
               [H].[SOURCE],
               [H].[ERP_WAREHOUSE_CODE],
               [H].[DOC_ENTRY],
               [H].[MANIFEST_HEADER_ID],
               [H].[PLATE_NUMBER],
               [H].[ADDRESS],
               [H].[DOC_CURRENCY],
               [H].[DOC_RATE],
               [H].[SUBSIDIARY],
               [H].[USER_CONFIRMED],
               [H].[DATE_CONFIRMED],
               [H].[CONFIRMED_BY],
               [H].[RECEPTION_TYPE_ERP],
               [CD].[CVE_DOC],
               [CD].[NUM_PAR],
               [CD].[CVE_ART],
               [CD].[CANT],
               [CD].[PXS],
               [CD].[PREC],
               [CD].[COST],
               [CD].[IMPU1],
               [CD].[IMPU2],
               [CD].[IMPU3],
               [CD].[IMPU4],
               [CD].[IMP1APLA],
               [CD].[IMP2APLA],
               [CD].[IMP3APLA],
               [CD].[IMP4APLA],
               [CD].[TOTIMP1],
               [CD].[TOTIMP2],
               [CD].[TOTIMP3],
               [CD].[TOTIMP4],
               [CD].[DESC1],
               [CD].[DESC2],
               [CD].[DESC3],
               [CD].[COMI],
               [CD].[APAR],
               [CD].[ACT_INV],
               [CD].[NUM_ALM],
               [CD].[POLIT_APLI],
               [CD].[TIP_CAM],
               [CD].[UNI_VENTA],
               [CD].[TIPO_PROD],
               [CD].[CVE_OBS],
               [CD].[REG_SERIE],
               [CD].[E_LTPD],
               [CD].[TIPO_ELEM],
               [CD].[NUM_MOV],
               [CD].[TOT_PARTIDA],
               [CD].[IMPRIMIR],
               [CD].[UUID],
               [CD].[VERSION_SINC],
               [CD].[MAN_IEPS],
               [CD].[APL_MAN_IMP],
               [CD].[CUOTA_IEPS],
               [CD].[APL_MAN_IEPS],
               [CD].[MTO_PORC],
               [CD].[MTO_CUOTA],
               [CD].[CVE_ESQ],
               [CD].[DESCR_ART],
               CAST(0 AS INT) [NUMERO_MOVIMIENTO]
        INTO [#DETALLE]
        FROM [OP_WMS_ALZA].[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [D]
            INNER JOIN [OP_WMS_ALZA].[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [H]
                ON [H].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = [D].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
            INNER JOIN [OP_WMS_ALZA].[wms].[OP_WMS_MATERIALS] [M]
                ON [M].[MATERIAL_ID] = [D].[MATERIAL_ID]
            INNER JOIN [SAE70EMPRESA01_PRUEBAS].[dbo].[FACTF01] [CH]
                ON LTRIM(RTRIM([CH].[CVE_DOC])) COLLATE DATABASE_DEFAULT = [H].[DOC_ID] COLLATE DATABASE_DEFAULT
            INNER JOIN [SAE70EMPRESA01_PRUEBAS].[dbo].[PAR_FACTF01] [CD]
                ON [CH].[CVE_DOC] = [CD].[CVE_DOC]
                   AND [D].[LINE_NUM] = [CD].[NUM_PAR]
        WHERE [H].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_DOCUMENT_HEADER
              AND [IS_CONFIRMED] = 1
              AND [QTY_CONFIRMED] > 0;

        --obtiene detalle
        SELECT [H].[DOC_ID],
               [H].[TYPE],
               [H].[CODE_SUPPLIER],
               [H].[CODE_CLIENT],
               [H].[ERP_DATE],
               [H].[IS_AUTHORIZED],
               [H].[IS_COMPLETE],
               [H].[TASK_ID],
               [H].[EXTERNAL_SOURCE_ID],
               [H].[ERP_REFERENCE_DOC_NUM],
               [H].[DOC_NUM],
               [H].[NAME_SUPPLIER],
               [H].[OWNER],
               [H].[IS_FROM_WAREHOUSE_TRANSFER],
               [H].[IS_FROM_ERP],
               [H].[DOC_ID_POLIZA],
               [H].[LOCKED_BY_INTERFACES],
               [H].[IS_VOID],
               [H].[SOURCE],
               [H].[ERP_WAREHOUSE_CODE],
               [H].[DOC_ENTRY],
               [H].[MANIFEST_HEADER_ID],
               [H].[PLATE_NUMBER],
               [H].[ADDRESS],
               [H].[DOC_CURRENCY],
               [H].[DOC_RATE],
               [H].[SUBSIDIARY],
               [H].[USER_CONFIRMED],
               [H].[DATE_CONFIRMED],
               [H].[CONFIRMED_BY],
               [H].[RECEPTION_TYPE_ERP],
               [CH].[TIP_DOC],
               [CH].[CVE_DOC],
               [CH].[CVE_CLPV],
               [CH].[STATUS],
               [CH].[DAT_MOSTR],
               [CH].[CVE_VEND],
               [CH].[CVE_PEDI],
               [CH].[FECHA_DOC],
               [CH].[FECHA_ENT],
               [CH].[FECHA_VEN],
               [CH].[FECHA_CANCELA],
               [CH].[CAN_TOT],
               [CH].[IMP_TOT1],
               [CH].[IMP_TOT2],
               [CH].[IMP_TOT3],
               [CH].[IMP_TOT4],
               [CH].[DES_TOT],
               [CH].[DES_FIN],
               [CH].[COM_TOT],
               [CH].[CONDICION],
               [CH].[CVE_OBS],
               [CH].[NUM_ALMA],
               [CH].[ACT_CXC],
               [CH].[ACT_COI],
               [CH].[ENLAZADO],
               [CH].[TIP_DOC_E],
               [CH].[NUM_MONED],
               [CH].[TIPCAMB],
               [CH].[NUM_PAGOS],
               [CH].[FECHAELAB],
               [CH].[PRIMERPAGO],
               [CH].[RFC],
               [CH].[CTLPOL],
               [CH].[ESCFD],
               [CH].[AUTORIZA],
               [CH].[SERIE],
               [CH].[FOLIO],
               [CH].[AUTOANIO],
               [CH].[DAT_ENVIO],
               [CH].[CONTADO],
               [CH].[CVE_BITA],
               [CH].[BLOQ],
               [CH].[FORMAENVIO],
               [CH].[DES_FIN_PORC],
               [CH].[DES_TOT_PORC],
               [CH].[IMPORTE],
               [CH].[COM_TOT_PORC],
               [CH].[METODODEPAGO],
               [CH].[NUMCTAPAGO],
               [CH].[TIP_DOC_ANT],
               [CH].[DOC_ANT],
               [CH].[TIP_DOC_SIG],
               [CH].[DOC_SIG],
               [CH].[UUID],
               [CH].[VERSION_SINC],
               [CH].[FORMADEPAGOSAT],
               [CH].[USO_CFDI],
               [CL].[CAMPLIB1],
               [CL].[CAMPLIB2],
               [CL].[CAMPLIB3],
               [CL].[CAMPLIB4],
               [CL].[CAMPLIB5],
               [CL].[CAMPLIB6],
               [CL].[CAMPLIB7],
               [CL].[CAMPLIB8],
               [CL].[CAMPLIB9],
               [CL].[CAMPLIB10],
               [CL].[CAMPLIB11],
               [CL].[CAMPLIB12],
               [CL].[CAMPLIB13],
               [CL].[CAMPLIB14],
               [CL].[CAMPLIB15],
               [CL].[CAMPLIB16],
               [CL].[CAMPLIB17],
               [CL].[CAMPLIB18],
               [CL].[CAMPLIB19],
               [CL].[CAMPLIB20],
               [CL].[CAMPLIB21]
        INTO [#ENCABEZADO]
        FROM [OP_WMS_ALZA].[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [H]
            INNER JOIN [SAE70EMPRESA01_PRUEBAS].[dbo].[FACTF01] [CH]
                ON RTRIM(LTRIM([CH].[CVE_DOC])) COLLATE DATABASE_DEFAULT = [H].[DOC_ID] COLLATE DATABASE_DEFAULT
            INNER JOIN [SAE70EMPRESA01_PRUEBAS].[dbo].[FACTF_CLIB01] [CL]
                ON [CH].[CVE_DOC] = [CL].[CLAVE_DOC]
        WHERE [ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_DOCUMENT_HEADER;


        IF EXISTS
        (
            SELECT TOP 1
                   1
            FROM [#ENCABEZADO]
            WHERE LEN([CAMPLIB18]) < 5
                  OR [CAMPLIB18] = ''
                  OR [CAMPLIB18] IS NULL
        )
        BEGIN
            DECLARE @pRESULT VARCHAR(200) = 'No se encontró información de CAI en factura origen. ';
            RAISERROR(@pRESULT, 16, 1);
        END;

        -- ------------------------------------------------------------------------------------
        -- obtener variables de proveedor
        -- ------------------------------------------------------------------------------------
        SELECT @CODIGO_PROVEEDOR_SAE = [P].[CLAVE],
               @NOMBRE_PROVEEDOR_SAE = [P].[NOMBRE]
        FROM [SAE70EMPRESA01_PRUEBAS].[dbo].[CLIE01] [P]
            INNER JOIN [#ENCABEZADO] [H]
                ON [H].[CVE_CLPV] = [P].[CLAVE]
        WHERE [P].[STATUS] <> 'B';



        -- ------------------------------------------------------------------------------------
        -- Obtiene ultimo documento
        -- ------------------------------------------------------------------------------------

        SELECT @ULTIMO_DOCUMENTO_32 = [ULT_CVE]
        FROM [SAE70EMPRESA01_PRUEBAS].[dbo].[TBLCONTROL01]
        WHERE [ID_TABLA] = @TABLA_DOCUMENTO_32;

        PRINT 'Obtuvo ultimo documento @ULTIMO_DOCUMENTO_32' + CAST(@ULTIMO_DOCUMENTO_32 AS VARCHAR);
        UPDATE [SAE70EMPRESA01_PRUEBAS].[dbo].[TBLCONTROL01]
        SET [ULT_CVE] = @ULTIMO_DOCUMENTO_32 + 1
        WHERE [ID_TABLA] = @TABLA_DOCUMENTO_32
              AND [ULT_CVE] = @ULTIMO_DOCUMENTO_32;


        -- ------------------------------------------------------------------------------------
        -- obtiene folios y serie de documento de recepción 
        -- ------------------------------------------------------------------------------------
        SELECT TOP (1)
               @ULT_DOC_FOLIO = [ULT_DOC],
               @FOLIO_DESDE = [FOLIODESDE],
               @DOCUMENTO_ERP_FORMATEADO = [SERIE] + [dbo].[FUNC_ADD_CHARS]([ULT_DOC] + 1, '0', 8)
        FROM [SAE70EMPRESA01_PRUEBAS].[dbo].[FOLIOSF01]
        WHERE [TIP_DOC] = @TIPO_DOCUMENTO_FOLIO
              AND [SERIE] = @SERIE_FOLIO
        GROUP BY [TIP_DOC],
                 [SERIE],
                 [FOLIODESDE],
                 [FOLIOHASTA],
                 [ULT_DOC],
                 [FECH_ULT_DOC]
        ORDER BY [FOLIOHASTA] DESC;

        PRINT 'Obtuvo ultimo folio' + CAST(ISNULL(@DOCUMENTO_ERP_FORMATEADO, 'ERROR') AS VARCHAR);

        UPDATE [SAE70EMPRESA01_PRUEBAS].[dbo].[FOLIOSF01]
        SET [ULT_DOC] = (CASE
                             WHEN [ULT_DOC] < @ULT_DOC_FOLIO + 1 THEN
                                 @ULT_DOC_FOLIO + 1
                             ELSE
                                 [ULT_DOC]
                         END
                        ),
            [FECH_ULT_DOC] = GETDATE()
        WHERE [TIP_DOC] = @TIPO_DOCUMENTO_FOLIO
              AND [SERIE] = @SERIE_FOLIO
              AND [FOLIODESDE] = @FOLIO_DESDE;


        SELECT @ULTIMO_DOCUMENTO_COMENTARIO = [ULT_CVE]
        FROM [SAE70EMPRESA01_PRUEBAS].[dbo].[TBLCONTROL01]
        WHERE [ID_TABLA] = @TABLA_DOCUMENTO_COMENTARIO;


        UPDATE [SAE70EMPRESA01_PRUEBAS].[dbo].[TBLCONTROL01]
        SET [ULT_CVE] = @ULTIMO_DOCUMENTO_COMENTARIO + 1
        WHERE [ID_TABLA] = @TABLA_DOCUMENTO_COMENTARIO
              AND [ULT_CVE] = @ULTIMO_DOCUMENTO_COMENTARIO;

        SELECT TOP (1)
               @COMENTARIO
                   = 'Tarea Swift: ' + CAST([e].[TASK_ID] AS VARCHAR(18)) + ' Operada por: ' + [t].[TASK_ASSIGNEDTO]
                     + ' Confirmada por: ' + [e].[CONFIRMED_BY]
        FROM [#ENCABEZADO] [e]
            INNER JOIN [OP_WMS_ALZA].[wms].[OP_WMS_TASK_LIST] [t]
                ON [e].[TASK_ID] = [t].[SERIAL_NUMBER]
                   AND [t].[TASK_TYPE] = 'TAREA_RECEPCION';


        PRINT 'Comentario ' + CAST(@COMENTARIO AS VARCHAR);
        INSERT INTO [SAE70EMPRESA01_PRUEBAS].[dbo].[OBS_DOCF01]
        (
            [CVE_OBS],
            [STR_OBS]
        )
        VALUES
        (@ULTIMO_DOCUMENTO_COMENTARIO + 1, @COMENTARIO);


        WHILE EXISTS (SELECT TOP 1 1 FROM [#DETALLE] WHERE [ENVIADO] = 0)
        BEGIN
            SELECT TOP (1)
                   @ERP_MATERIAL_CODE = [ITEM_CODE_ERP],
                   @MATERIAL_ID_DETAIL = [MATERIAL_ID],
                   @LINE_NUM_DETAIL = [LINE_NUM],
                   @QTY_DETAIL = [QTY_CONFIRMED],
                   @COSTO_ARTICULO_DOCUMENTO = [COST],
                   @COSTO_PROMEDO_CALCULADO = [COST],
                   @FACTURA_DOCUMENTO = [CVE_DOC],
                   @EXISTENCIAS = 0,
                   @EXISTENCIAS_GENERAL = 0,
                   @ALMACEN = [NUM_ALM]
            FROM [#DETALLE]
            WHERE [ENVIADO] = 0
            ORDER BY [LINE_NUM] ASC;
            PRINT 'Ciclo detalle line: ' + CAST(@LINE_NUM_DETAIL AS VARCHAR);

            SELECT @ULTIMO_DOCUMENTO_MOVIMIENTO = [ULT_CVE]
            FROM [SAE70EMPRESA01_PRUEBAS].[dbo].[TBLCONTROL01]
            WHERE [ID_TABLA] = @TABLA_DOCUMENTO_MOVIMIENTO;


            UPDATE [SAE70EMPRESA01_PRUEBAS].[dbo].[TBLCONTROL01]
            SET [ULT_CVE] = @ULTIMO_DOCUMENTO_MOVIMIENTO + 1
            WHERE [ID_TABLA] = @TABLA_DOCUMENTO_MOVIMIENTO
                  AND [ULT_CVE] = @ULTIMO_DOCUMENTO_MOVIMIENTO;

            SELECT TOP (1)
                   @TIPO_MOV = [TIPO_MOV],
                   @SIGNO = [SIGNO]
            FROM [SAE70EMPRESA01_PRUEBAS].[dbo].[CONM01]
            WHERE [CVE_CPTO] = @CVE_CPTO
            ORDER BY [CVE_CPTO];


            SELECT TOP (1)
                   @EXISTENCIAS = ISNULL([M].[EXIST], 0),
                   @EXISTENCIAS_GENERAL = [I].[EXIST],
                   @COSTO_PROMEDIO_ANTERIOR = [I].[COSTO_PROM],
                   @COSTO_PROMEDO_CALCULADO
                       = (([I].[EXIST] * [I].[COSTO_PROM]) + (@QTY_DETAIL * @COSTO_ARTICULO_DOCUMENTO))
                         / ([I].[EXIST] + @QTY_DETAIL)
            FROM [SAE70EMPRESA01_PRUEBAS].[dbo].[INVE01] [I]
                LEFT JOIN [SAE70EMPRESA01_PRUEBAS].[dbo].[MULT01] [M]
                    ON [M].[CVE_ART] = [I].[CVE_ART]
                       AND [M].[CVE_ALM] = @ALMACEN
            WHERE [I].[CVE_ART] = @ERP_MATERIAL_CODE;

            PRINT 'Obtuvo Existencias ' + @ERP_MATERIAL_CODE + ' ' + CAST(@EXISTENCIAS AS VARCHAR) + ' '
                  + CAST(@EXISTENCIAS + @QTY_DETAIL AS VARCHAR);
            -- ------------------------------------------------------------------------------------
            -- inserta movimiento 
            -- ------------------------------------------------------------------------------------

            INSERT INTO [SAE70EMPRESA01_PRUEBAS].[dbo].[MINVE01]
            (
                [CVE_ART],
                [ALMACEN],
                [NUM_MOV],
                [CVE_CPTO],
                [FECHA_DOCU],
                [TIPO_DOC],
                [REFER],
                [CLAVE_CLPV],
                [VEND],
                [CANT],
                [CANT_COST],
                [PRECIO],
                [COSTO],
                [REG_SERIE],
                [UNI_VENTA],
                [E_LTPD],
                [EXIST_G],
                [EXISTENCIA],
                [FACTOR_CON],
                [FECHAELAB],
                [CVE_FOLIO],
                [SIGNO],
                [COSTEADO],
                [COSTO_PROM_INI],
                [COSTO_PROM_FIN],
                [COSTO_PROM_GRAL],
                [DESDE_INVE],
                [MOV_ENLAZADO]
            )
            SELECT TOP 1
                   [D].[ITEM_CODE_ERP],
                   [D].[ERP_WAREHOUSE_CODE],
                   @ULTIMO_DOCUMENTO_MOVIMIENTO + 1,
                   @CVE_CPTO,
                   @FECHA_HOY,
                   @TIPO_DOCUMENTO_FOLIO,
                   @DOCUMENTO_ERP_FORMATEADO,
                   [H].[CVE_CLPV],
                   [H].[CVE_VEND],
                   [D].[QTY_CONFIRMED],
                   0,
                   [D].[PREC],
                   [D].[COST] [COSTO],
                   0 [REG_SERIE],
                   [D].[BASE_MEASUREMENT_UNIT],
                   0,
                   @EXISTENCIAS_GENERAL + [QTY_CONFIRMED] [EXISTENCIA_GENERAL],
                   @EXISTENCIAS + [QTY_CONFIRMED] [EXISTENCIA],
                   1,
                   @FECHA_SYNC,
                   @ULTIMO_DOCUMENTO_32 + 1 [CVE_FOLIO],
                   @SIGNO,
                   'S',
                   @COSTO_PROMEDIO_ANTERIOR [COSTO_PROM_INI],
                   @COSTO_PROMEDO_CALCULADO [COSTO_PROM_FIN],
                   @COSTO_PROMEDIO_ANTERIOR [COSTO_PROM_GRAL],
                   'N',
                   [D].[NUM_MOV]
            FROM [#DETALLE] [D]
                INNER JOIN [#ENCABEZADO] [H]
                    ON [D].[CVE_DOC] = [H].[CVE_DOC]
            WHERE [LINE_NUM] = @LINE_NUM_DETAIL;




            -- ------------------------------------------------------------------------------------
            -- actualiza costos
            -- ------------------------------------------------------------------------------------

            UPDATE [SAE70EMPRESA01_PRUEBAS].[dbo].[INVE01]
            SET [EXIST] = [EXIST] + @QTY_DETAIL,
                [VERSION_SINC] = @FECHA_SYNC
            WHERE [CVE_ART] = @ERP_MATERIAL_CODE;

            UPDATE [SAE70EMPRESA01_PRUEBAS].[dbo].[MULT01]
            SET [EXIST] = [EXIST] + @QTY_DETAIL,
                [VERSION_SINC] = @FECHA_SYNC
            WHERE [CVE_ART] = @ERP_MATERIAL_CODE
                  AND [CVE_ALM] = @ALMACEN;




            PRINT 'termina linea';
            UPDATE [#DETALLE]
            SET [ENVIADO] = 1,
                [NUMERO_MOVIMIENTO] = @ULTIMO_DOCUMENTO_MOVIMIENTO + 1
            WHERE [LINE_NUM] = @LINE_NUM_DETAIL;
        END;

        -- ------------------------------------------------------------------------------------
        -- INSERTA EN BITACORA
        -- ------------------------------------------------------------------------------------

        SELECT @ULTIMO_DOCUMENTO_BITACORA = [ULT_CVE]
        FROM [SAE70EMPRESA01_PRUEBAS].[dbo].[TBLCONTROL01]
        WHERE [ID_TABLA] = @TABLA_DOCUMENTO_BITACORA;


        UPDATE [SAE70EMPRESA01_PRUEBAS].[dbo].[TBLCONTROL01]
        SET [ULT_CVE] = @ULTIMO_DOCUMENTO_BITACORA + 1
        WHERE [ID_TABLA] = @TABLA_DOCUMENTO_BITACORA
              AND [ULT_CVE] = @ULTIMO_DOCUMENTO_BITACORA;

        INSERT INTO [SAE70EMPRESA01_PRUEBAS].[dbo].[BITA01]
        (
            [CVE_BITA],
            [CVE_CAMPANIA],
            [STATUS],
            [CVE_CLIE],
            [CVE_USUARIO],
            [NOM_USUARIO],
            [OBSERVACIONES],
            [FECHAHORA],
            [CVE_ACTIVIDAD]
        )
        VALUES
        (@ULTIMO_DOCUMENTO_BITACORA + 1, '_SAE_', 'F', @CODIGO_PROVEEDOR_SAE, @USUARIO_OPERA, @USUARIO_OPERA_NOMBRE,
         CAST(@COMENTARIO AS VARCHAR(55)), @FECHA_SYNC, '    6');

        -- ------------------------------------------------------------------------------------
        --  actualiza encabezados de compra 
        -- ------------------------------------------------------------------------------------
        SELECT @TOTAL_COMPRA = SUM([D].[QTY_CONFIRMED] * [D].[PREC]),
               @TOTAL_IMPUESTO_04
                   = SUM([D].[QTY_CONFIRMED] * ([D].[PREC] * ((100 - [D].[DESC1] - [D].[DESC2] - [D].[DESC3]) / 100))
                         * ([D].[IMPU4] / 100)
                        ),
               @TOTAL_IMPUESTO_03
                   = SUM([D].[QTY_CONFIRMED] * ([D].[PREC] * ((100 - [D].[DESC1] - [D].[DESC2] - [D].[DESC3]) / 100))
                         * ([D].[IMPU3] / 100)
                        ),
               @TOTAL_IMPUESTO_02
                   = SUM([D].[QTY_CONFIRMED] * ([D].[PREC] * ((100 - [D].[DESC1] - [D].[DESC2] - [D].[DESC3]) / 100))
                         * ([D].[IMPU2] / 100)
                        ),
               @TOTAL_IMPUESTO_01
                   = SUM([D].[QTY_CONFIRMED] * ([D].[PREC] * ((100 - [D].[DESC1] - [D].[DESC2] - [D].[DESC3]) / 100))
                         * ([D].[IMPU1] / 100)
                        ),
               @TOTAL_DESCUENTO_01 = SUM([D].[QTY_CONFIRMED] * [D].[PREC] * ([D].[DESC1] / 100)),
               @TOTAL_DESCUENTO_02 = SUM([D].[QTY_CONFIRMED] * [D].[PREC] * ([D].[DESC2] / 100)),
               @TOTAL_DESCUENTO_03 = SUM([D].[QTY_CONFIRMED] * [D].[PREC] * ([D].[DESC3] / 100)),
               @TOTAL_IMPORTE
                   = SUM([D].[QTY_CONFIRMED] * [D].[PREC])
                     + SUM([D].[QTY_CONFIRMED] * ([D].[PREC] * ((100 - [D].[DESC1] - [D].[DESC2] - [D].[DESC3]) / 100))
                           * [D].[IMPU4] / 100
                          )
                     + SUM([D].[QTY_CONFIRMED] * ([D].[PREC] * ((100 - [D].[DESC1] - [D].[DESC2] - [D].[DESC3]) / 100))
                           * [D].[IMPU3] / 100
                          )
                     + SUM([D].[QTY_CONFIRMED] * ([D].[PREC] * ((100 - [D].[DESC1] - [D].[DESC2] - [D].[DESC3]) / 100))
                           * [D].[IMPU2] / 100
                          )
                     + SUM([D].[QTY_CONFIRMED] * ([D].[PREC] * ((100 - [D].[DESC1] - [D].[DESC2] - [D].[DESC3]) / 100))
                           * [D].[IMPU1] / 100
                          )
        FROM [#DETALLE] [D];


        INSERT INTO [SAE70EMPRESA01_PRUEBAS].[dbo].[CUEN_DET01]
        (
            [CVE_CLIE],
            [REFER],
            [NUM_CARGO],
            [NUM_CPTO],
            [CVE_OBS],
            [NO_FACTURA],
            [DOCTO],
            [IMPORTE],
            [FECHA_APLI],
            [FECHA_VENC],
            [AFEC_COI],
            [STRCVEVEND],
            [NUM_MONED],
            [TCAMBIO],
            [IMPMON_EXT],
            [FECHAELAB],
            [ID_MOV],
            [NO_PARTIDA],
            [TIPO_MOV],
            [SIGNO],
            [USUARIO]
        )
        SELECT [CVE_CLPV],
               [CVE_DOC],
               1,
               12,
               0,
               [CVE_DOC],
               @DOCUMENTO_ERP_FORMATEADO,
               @TOTAL_IMPORTE,
               @FECHA_HOY,
               @FECHA_HOY,
               'A',
               [CVE_VEND],
               [NUM_MONED],
               [TIPCAMB],
               @TOTAL_IMPORTE,
               @FECHA_SYNC,
               1,
               1,
               'A',
               -1,
               @USUARIO_OPERA
        FROM [#ENCABEZADO];



        -- ------------------------------------------------------------------------------------
        -- inserta documento de recepción
        -- ------------------------------------------------------------------------------------

        INSERT INTO [SAE70EMPRESA01_PRUEBAS].[dbo].[FACTD01]
        (
            [TIP_DOC],
            [CVE_DOC],
            [CVE_CLPV],
            [STATUS],
            [DAT_MOSTR],
            [CVE_VEND],
            [CVE_PEDI],
            [FECHA_DOC],
            [FECHA_ENT],
            [FECHA_VEN],
            [CAN_TOT],
            [IMP_TOT1],
            [IMP_TOT2],
            [IMP_TOT3],
            [IMP_TOT4],
            [DES_TOT],
            [DES_FIN],
            [COM_TOT],
            [CONDICION],
            [CVE_OBS],
            [NUM_ALMA],
            [ACT_CXC],
            [ACT_COI],
            [ENLAZADO],
            [NUM_MONED],
            [TIPCAMB],
            [NUM_PAGOS],
            [FECHAELAB],
            [PRIMERPAGO],
            [RFC],
            [CTLPOL],
            [ESCFD],
            [AUTORIZA],
            [SERIE],
            [FOLIO],
            [AUTOANIO],
            [DAT_ENVIO],
            [CONTADO],
            [CVE_BITA],
            [BLOQ],
            [TIP_DOC_E],
            [DES_FIN_PORC],
            [DES_TOT_PORC],
            [COM_TOT_PORC],
            [IMPORTE],
            [METODODEPAGO],
            [NUMCTAPAGO],
            [DOC_ANT],
            [TIP_DOC_ANT],
            [UUID],
            [VERSION_SINC],
            [FORMADEPAGOSAT],
            [USO_CFDI]
        )
        SELECT @TIPO_DOCUMENTO_FOLIO [TIP_DOC],
               @DOCUMENTO_ERP_FORMATEADO [CVE_DOC],
               [H].[CVE_CLPV] [CVE_CLPV],
               'O' [STATUS],
               [H].[DAT_MOSTR] [DAT_MOSTR],
               [H].[CVE_VEND] [CVE_VEND],
               [H].[CVE_PEDI] [CVE_PEDI],
               @FECHA_HOY [FECHA_DOC],
               [H].[FECHA_ENT] [FECHA_ENT],
               [H].[FECHA_VEN] [FECHA_VEN],
               @TOTAL_COMPRA [CAN_TOT],
               @TOTAL_IMPUESTO_01 [IMP_TOT1],
               @TOTAL_IMPUESTO_02 [IMP_TOT2],
               @TOTAL_IMPUESTO_03 [IMP_TOT3],
               @TOTAL_IMPUESTO_04 [IMP_TOT4],
               @TOTAL_DESCUENTO_01 + @TOTAL_DESCUENTO_02 + @TOTAL_DESCUENTO_03 [DES_TOT],
               [H].[DES_FIN] [DES_FIN],
               [H].[COM_TOT] [COM_TOT],
               [H].[CONDICION] [CONDICION],
               @ULTIMO_DOCUMENTO_COMENTARIO + 1 [CVE_OBS],
               [H].[NUM_ALMA] [NUM_ALMA],
               'S' [ACT_CXC],
               'N' [ACT_COI],
               'O' [ENLAZADO],
               [H].[NUM_MONED] [NUM_MONED],
               [H].[TIPCAMB] [TIPCAMB],
               [H].[NUM_PAGOS] [NUM_PAGOS],
               @FECHA_SYNC [FECHAELAB],
               [H].[PRIMERPAGO] [PRIMERPAGO],
               [H].[RFC] [RFC],
               [H].[CTLPOL] [CTLPOL],
               [H].[ESCFD] [ESCFD],
               0 [AUTORIZA],
               @SERIE_FOLIO [SERIE],
               @ULT_DOC_FOLIO + 1 [FOLIO],
               '0' [AUTOANIO],
               [H].[DAT_ENVIO] [DAT_ENVIO],
               [H].[CONTADO] [CONTADO],
               @ULTIMO_DOCUMENTO_BITACORA + 1 [CVE_BITA],
               'N' [BLOQ],
               'F' [TIP_DOC_E],
               [H].[DES_FIN_PORC] [DES_FIN_PORC],
               [H].[DES_TOT_PORC] [DES_TOT_PORC],
               [H].[COM_TOT_PORC] [COM_TOT_PORC],
               @TOTAL_IMPORTE [IMPORTE],
               'PPD' [METODODEPAGO],
               '' [NUMCTAPAGO],
               [H].[CVE_DOC] [DOC_ANT],
               [H].[TIP_DOC] [TIP_DOC_ANT],
               [H].[UUID] [UUID],
               @FECHA_SYNC [VERSION_SINC],
               '99' [FORMADEPAGOSAT],
               'P01' [USO_CFDI]
        FROM [#ENCABEZADO] [H];
        PRINT 'inserta en [FACTD01]';
        INSERT INTO [SAE70EMPRESA01_PRUEBAS].[dbo].[FACTD_CLIB01]
        (
            [CLAVE_DOC],
            [CAMPLIB1],
            [CAMPLIB2],
            [CAMPLIB3],
            [CAMPLIB4],
            [CAMPLIB5],
            [CAMPLIB6],
            [CAMPLIB7],
            [CAMPLIB8],
            [CAMPLIB9],
            [CAMPLIB10],
            [CAMPLIB11],
            [CAMPLIB12],
            [CAMPLIB13],
            [CAMPLIB14],
            [CAMPLIB15],
            [CAMPLIB16],
            [CAMPLIB17],
            [CAMPLIB18],
            [CAMPLIB19],
            [CAMPLIB20],
            [CAMPLIB21]
        )
        SELECT @DOCUMENTO_ERP_FORMATEADO,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               [h].[FECHA_DOC],
               NULL,
               [h].[CAMPLIB18],
               'Devolucion',
               NULL,
               NULL
        FROM [#ENCABEZADO] [h];

        UPDATE [#DETALLE]
        SET [ENVIADO] = 0;
        SELECT @CONTADOR_LINEA = 0;

        WHILE EXISTS (SELECT TOP (1) 1 FROM [#DETALLE] WHERE [ENVIADO] = 0)
        BEGIN
            SELECT TOP (1)
                   @ERP_MATERIAL_CODE = [ITEM_CODE_ERP],
                   @MATERIAL_ID_DETAIL = [MATERIAL_ID],
                   @LINE_NUM_DETAIL = [LINE_NUM],
                   @QTY_DETAIL = [QTY_CONFIRMED],
                   @COSTO_ARTICULO_DOCUMENTO = [COST],
                   @COSTO_PROMEDO_CALCULADO = [COST],
                   @PRECIO = [PREC]
            FROM [#DETALLE]
            WHERE [ENVIADO] = 0
            ORDER BY [LINE_NUM] ASC;

            UPDATE [SAE70EMPRESA01_PRUEBAS].[dbo].[PAR_FACTF01]
            SET [PXS] = (CASE
                             WHEN [PXS] < @QTY_DETAIL THEN
                                 0
                             ELSE
                                 [PXS] - @QTY_DETAIL
                         END
                        )
            WHERE [CVE_DOC] = @FACTURA_DOCUMENTO
                  AND [NUM_PAR] = @LINE_NUM_DETAIL
                  AND [CVE_ART] = @ERP_MATERIAL_CODE;

            UPDATE [SAE70EMPRESA01_PRUEBAS].[dbo].[INVE01]
            SET [VTAS_ANL_C] = [VTAS_ANL_C] - @QTY_DETAIL,
                [VTAS_ANL_M] = [VTAS_ANL_M] - (@QTY_DETAIL * @PRECIO),
                [VERSION_SINC] = @FECHA_SYNC
            WHERE [CVE_ART] = @ERP_MATERIAL_CODE;


            INSERT INTO [SAE70EMPRESA01_PRUEBAS].[dbo].[PAR_FACTD01]
            (
                [CVE_DOC],
                [NUM_PAR],
                [CVE_ART],
                [CANT],
                [PXS],
                [PREC],
                [COST],
                [IMPU1],
                [IMPU2],
                [IMPU3],
                [IMPU4],
                [IMP1APLA],
                [IMP2APLA],
                [IMP3APLA],
                [IMP4APLA],
                [TOTIMP1],
                [TOTIMP2],
                [TOTIMP3],
                [TOTIMP4],
                [D].[DESC1],
                [D].[DESC2],
                [D].[DESC3],
                [D].[COMI],
                [D].[APAR],
                [ACT_INV],
                [NUM_ALM],
                [POLIT_APLI],
                [TIP_CAM],
                [UNI_VENTA],
                [TIPO_PROD],
                [TIPO_ELEM],
                [CVE_OBS],
                [REG_SERIE],
                [E_LTPD],
                [NUM_MOV],
                [TOT_PARTIDA],
                [IMPRIMIR],
                [MAN_IEPS],
                [APL_MAN_IMP],
                [CUOTA_IEPS],
                [APL_MAN_IEPS],
                [MTO_PORC],
                [MTO_CUOTA],
                [CVE_ESQ],
                [UUID],
                [VERSION_SINC]
            )
            SELECT @DOCUMENTO_ERP_FORMATEADO [CVE_DOC],
                   [D].[NUM_PAR],
                   [D].[CVE_ART],
                   [D].[QTY_CONFIRMED] [CANT],
                   [D].[QTY_CONFIRMED] [PXS],
                   [D].[PREC],
                   [COST],
                   [D].[IMPU1],
                   [D].[IMPU2],
                   [D].[IMPU3],
                   [D].[IMPU4],
                   [D].[IMP1APLA],
                   [D].[IMP2APLA],
                   [D].[IMP3APLA],
                   [D].[IMP4APLA],
                   CAST(([D].[QTY_CONFIRMED] * [D].[PREC] * [D].[IMPU1]) / 100 AS FLOAT) [TOTIMP1],
                   CAST(([D].[QTY_CONFIRMED] * [D].[PREC] * [D].[IMPU2]) / 100 AS FLOAT) [TOTIMP2],
                   CAST(([D].[QTY_CONFIRMED] * [D].[PREC] * [D].[IMPU3]) / 100 AS FLOAT) [TOTIMP3],
                   CAST(([D].[QTY_CONFIRMED] * [D].[PREC] * [D].[IMPU4]) / 100 AS FLOAT) [TOTIMP4],
                   [D].[DESC1],
                   [D].[DESC2],
                   [D].[DESC3],
                   [D].[COMI],
                   [D].[APAR],
                   [D].[ACT_INV],
                   [D].[NUM_ALM],
                   [D].[POLIT_APLI],
                   [D].[TIP_CAM],
                   [D].[UNI_VENTA],
                   [D].[TIPO_PROD],
                   [D].[TIPO_ELEM],
                   0 [CVE_OBS],
                   [REG_SERIE],
                   [E_LTPD],
                   [D].[NUMERO_MOVIMIENTO] [NUM_MOV],
                   [D].[QTY_CONFIRMED] * [D].[PREC] [TOT_PARTIDA],
                   [D].[IMPRIMIR],
                   [D].[MAN_IEPS],
                   [D].[APL_MAN_IMP],
                   [D].[CUOTA_IEPS],
                   [D].[APL_MAN_IEPS],
                   [D].[MTO_PORC],
                   [D].[MTO_CUOTA],
                   [D].[CVE_ESQ],
                   [D].[UUID],
                   @FECHA_SYNC [VERSION_SINC]
            FROM [#DETALLE] [D]
            WHERE [LINE_NUM] = @LINE_NUM_DETAIL;


            UPDATE [SAE70EMPRESA01_PRUEBAS].[dbo].[FACTF01]
            SET [TIP_DOC_E] = @TIPO_DOCUMENTO_FOLIO,
                [ENLAZADO] = (CASE
                                  WHEN
                                  (
                                      SELECT SUM([P].[PXS])
                                      FROM [SAE70EMPRESA01_PRUEBAS].[dbo].[PAR_FACTF01] [P]
                                      WHERE [P].[CVE_DOC] = @FACTURA_DOCUMENTO
                                            AND [FACTF01].[CVE_DOC] = [P].[CVE_DOC]
                                  ) = 0 THEN
                                      'T'
                                  WHEN
                                  (
                                      SELECT SUM([P].[PXS])
                                      FROM [SAE70EMPRESA01_PRUEBAS].[dbo].[PAR_FACTF01] [P]
                                      WHERE [P].[CVE_DOC] = @FACTURA_DOCUMENTO
                                            AND [FACTF01].[CVE_DOC] = [P].[CVE_DOC]
                                  ) > 0 THEN
                                      'P'
                                  ELSE
                                      [ENLAZADO]
                              END
                             )
            WHERE [FACTF01].[CVE_DOC] = @FACTURA_DOCUMENTO;

            UPDATE [SAE70EMPRESA01_PRUEBAS].[dbo].[FACTF01]
            SET [DOC_SIG] = @DOCUMENTO_ERP_FORMATEADO,
                [TIP_DOC_SIG] = @TIPO_DOCUMENTO_FOLIO
            WHERE [CVE_DOC] = @FACTURA_DOCUMENTO;

            INSERT INTO [SAE70EMPRESA01_PRUEBAS].[dbo].[DOCTOSIGF01]
            (
                [TIP_DOC],
                [CVE_DOC],
                [ANT_SIG],
                [TIP_DOC_E],
                [CVE_DOC_E],
                [PARTIDA],
                [PART_E],
                [CANT_E]
            )
            VALUES
            (N'F', @FACTURA_DOCUMENTO, N'S', @TIPO_DOCUMENTO_FOLIO, @DOCUMENTO_ERP_FORMATEADO, @LINE_NUM_DETAIL,
             @LINE_NUM_DETAIL, @QTY_DETAIL);

            INSERT INTO [SAE70EMPRESA01_PRUEBAS].[dbo].[DOCTOSIGF01]
            (
                [TIP_DOC],
                [CVE_DOC],
                [ANT_SIG],
                [TIP_DOC_E],
                [CVE_DOC_E],
                [PARTIDA],
                [PART_E],
                [CANT_E]
            )
            VALUES
            (@TIPO_DOCUMENTO_FOLIO, @DOCUMENTO_ERP_FORMATEADO, N'A', N'F', @FACTURA_DOCUMENTO, @LINE_NUM_DETAIL,
             @LINE_NUM_DETAIL, @QTY_DETAIL);

            INSERT INTO [SAE70EMPRESA01_PRUEBAS].[dbo].[PAR_FACTD_CLIB01]
            (
                [CLAVE_DOC],
                [NUM_PART]
            )
            VALUES
            (@DOCUMENTO_ERP_FORMATEADO, @LINE_NUM_DETAIL);

            SELECT @CONTADOR_LINEA = @CONTADOR_LINEA + 1;

            UPDATE [#DETALLE]
            SET [ENVIADO] = 1
            WHERE [LINE_NUM] = @LINE_NUM_DETAIL;
        END;


        DECLARE @RESPONSE VARCHAR(500) = 'Proceso exitoso, Recepción: ' + @DOCUMENTO_ERP_FORMATEADO;

        PRINT 'Actualizó Swift ';


        COMMIT;
        SELECT 1 AS [Resultado],
               @RESPONSE [Mensaje],
               0 [Codigo],
               @DOCUMENTO_ERP_FORMATEADO [DbData];

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @MENSAJE_ERROR VARCHAR(500) = ERROR_MESSAGE();

        --
        SELECT -1 AS [Resultado],
               'Proceso fallido: ' + @MENSAJE_ERROR [Mensaje],
               0 [Codigo],
               '0' [DbData];

    END CATCH;

END;