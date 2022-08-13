-- =============================================
-- Autor:				gustavo.garcia
-- Fecha de Creacion: 	09-feb-21 
-- Description:			
/*
-- Ejemplo de Ejecucion:
				EXEC [dbo].[SAE_CREATE_INVENTORY_INCOME_BY_TRANSFER_SAE] @RECEPTION_DOCUMENT_HEADER = 4077 -- numeric

Proceso fallido: Violation of PRIMARY KEY constraint 'PK_COMPR_CLIB01'. Cannot insert duplicate key in object 'dbo.COMPR_CLIB01'. The duplicate key value is (0).
Proceso fallido: Violation of PRIMARY KEY constraint 'PK_COMPR01'. Cannot insert duplicate key in object 'dbo.COMPR01'. The duplicate key value is (000001-08-00091009).
Proceso fallido: Violation of PRIMARY KEY constraint 'PK_PAR_COMPR_CLIB01'. Cannot insert duplicate key in object 'dbo.PAR_COMPR_CLIB01'. The duplicate key value is (000001-08-00091009, 1).
*/
-- =============================================
CREATE PROCEDURE [dbo].[SAE_CREATE_INVENTORY_INCOME_GENERAL]
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
            @ULTIMO_DOCUMENTO INT = 0,
            @TIPO_DOCUMENTO_FOLIO VARCHAR(1) = 'M',
            @SERIE_FOLIO VARCHAR(6) = 'WMS',
            @ULT_DOC_FOLIO [INT],
            @FOLIO_DESDE INT,
            @CODIGO_PROVEEDOR_SAE VARCHAR(10),
            @NOMBRE_PROVEEDOR_SAE VARCHAR(100),
            @TABLA_DOCUMENTO_COMENTARIO INT = 57,
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
            @MES_ACTUAL DATETIME = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0),
            @FECHA_HOY DATETIME = DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0),
            @ORDEN_COMPRA_DOCUMENTO VARCHAR(50),
            @COMENTARIO VARCHAR(200);



    --VARIABLES DETALLE
    DECLARE @ERP_MATERIAL_CODE VARCHAR(25),
            @MATERIAL_ID_DETAIL VARCHAR(25),
            @LINE_NUM_DETAIL INT,
            @QTY_DETAIL NUMERIC(18, 6),
            @CVE_CPTO INT = 1,
            @SIGNO SMALLINT,
            @TIPO_MOV VARCHAR(1),
            @TABLA_DOCUMENTO_MOVIMIENTO INT = 44,
            @ULTIMO_DOCUMENTO_MOVIMIENTO INT = 0,
            @COSTO_ARTICULO_DOCUMENTO FLOAT,
            @COSTO_PROMEDO_CALCULADO FLOAT,
            @COSTO_PROMEDIO_ANTERIOR FLOAT,
            @EXISTENCIAS FLOAT = 0,
            @EXISTENCIAS_GENERAL FLOAT = 0,
            @CONTADOR_LINEA INT = 0,
            @ALMACEN INT = 0;
			--@DEMAND_TYPE VARCHAR(255) = 'RECEPCION_TRASLADO';

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
               D.WAREHOUSE_CODE [NUM_ALM],            
               CAST(0 AS INT) [NUMERO_MOVIMIENTO]
       INTO [#DETALLE]
        FROM [OP_WMS_ALZA].[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [D]
            INNER JOIN [OP_WMS_ALZA].[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [H]
                ON [H].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = [D].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
            INNER JOIN [OP_WMS_ALZA].[wms].[OP_WMS_MATERIALS] [M]
                ON [M].[MATERIAL_ID] = [D].[MATERIAL_ID]        
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
			   [PDH].CAI_NUMERO,
			   [PDH].CAI_SERIE
        INTO [#ENCABEZADO]
        FROM [OP_WMS_ALZA].[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [H]
			INNER JOIN [OP_WMS_ALZA].[wms].[OP_WMS_MANIFEST_HEADER] [MH] ON (MH.MANIFEST_HEADER_ID =H.DOC_NUM)
			INNER JOIN [OP_WMS_ALZA].[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH] ON (PDH.DOC_NUM = MH.TRANSFER_REQUEST_ID)
        WHERE [ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_DOCUMENT_HEADER;


        -- ------------------------------------------------------------------------------------
        -- Obtiene ultimo documento
        -- ------------------------------------------------------------------------------------
		SELECT @ULTIMO_DOCUMENTO = CAST(@RECEPTION_DOCUMENT_HEADER AS int),
			@DOCUMENTO_ERP_FORMATEADO= ISNULL(@SERIE_FOLIO, 0) + [dbo].[FUNC_ADD_CHARS](@RECEPTION_DOCUMENT_HEADER, '0', 8)


			        -- ------------------------------------------------------------------------------------
        -- Obtiene ultimo documento
        -- ------------------------------------------------------------------------------------

        SELECT @ULTIMO_DOCUMENTO_32 = [ULT_CVE]
        FROM [SAE70EMPRESA01].[dbo].[TBLCONTROL01]
        WHERE [ID_TABLA] = @TABLA_DOCUMENTO_32;

        PRINT 'Obtuvo ultimo documento @ULTIMO_DOCUMENTO_32' + CAST(@ULTIMO_DOCUMENTO_32 AS VARCHAR);
        UPDATE [SAE70EMPRESA01].[dbo].[TBLCONTROL01]
        SET [ULT_CVE] = @ULTIMO_DOCUMENTO_32 + 1
        WHERE [ID_TABLA] = @TABLA_DOCUMENTO_32
              AND [ULT_CVE] = @ULTIMO_DOCUMENTO_32;


        PRINT 'Obtuvo ultimo folio HH' + CAST(@DOCUMENTO_ERP_FORMATEADO AS VARCHAR);
       -- PRINT 'Obtuvo ultimo documento @ULTIMO_DOCUMENTO' + CAST(@ULTIMO_DOCUMENTO AS VARCHAR);
		--PRINT 'Obtiene el Almacen @ALMACEN' +  cast(@ALMACEN as varchar);


		SELECT @CVE_CPTO=C.SPARE4 
			FROM [OP_WMS_ALZA].[wms].[OP_WMS_CONFIGURATIONS] C
			INNER JOIN [OP_WMS_ALZA].[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] H ON C.PARAM_NAME=H.RECEPTION_TYPE_ERP
			WHERE H.ERP_RECEPTION_DOCUMENT_HEADER_ID = @RECEPTION_DOCUMENT_HEADER
		
          PRINT 'Obtuvo ultimo TIPO MOVIMIENTO gg' + CAST(@CVE_CPTO AS VARCHAR);

        SELECT @ULTIMO_DOCUMENTO_COMENTARIO = [ULT_CVE]
        FROM [SAE70EMPRESA01].[dbo].[TBLCONTROL01]
        WHERE [ID_TABLA] = @TABLA_DOCUMENTO_COMENTARIO;


        UPDATE [SAE70EMPRESA01].[dbo].[TBLCONTROL01]
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
        INSERT INTO [SAE70EMPRESA01].[dbo].[OBS_DOCC01]
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
                   @LINE_NUM_DETAIL = ERP_RECEPTION_DOCUMENT_DETAIL_ID,
                   @QTY_DETAIL = [QTY_CONFIRMED],
                   @EXISTENCIAS = 0,
                   @EXISTENCIAS_GENERAL = 0,
				   @ALMACEN = [NUM_ALM]
            FROM [#DETALLE]
            WHERE [ENVIADO] = 0
            ORDER BY [LINE_NUM] ASC;
            PRINT 'Ciclo detalle line: ' + CAST(@LINE_NUM_DETAIL AS VARCHAR);

            SELECT @ULTIMO_DOCUMENTO_MOVIMIENTO = [ULT_CVE]
            FROM [SAE70EMPRESA01].[dbo].[TBLCONTROL01]
            WHERE [ID_TABLA] = @TABLA_DOCUMENTO_MOVIMIENTO;


            UPDATE [SAE70EMPRESA01].[dbo].[TBLCONTROL01]
            SET [ULT_CVE] = @ULTIMO_DOCUMENTO_MOVIMIENTO + 1
            WHERE [ID_TABLA] = @TABLA_DOCUMENTO_MOVIMIENTO
                  AND [ULT_CVE] = @ULTIMO_DOCUMENTO_MOVIMIENTO;

            SELECT TOP (1)
                   @TIPO_MOV = [TIPO_MOV],
                   @SIGNO = [SIGNO]
            FROM [SAE70EMPRESA01].[dbo].[CONM01]
            WHERE [CVE_CPTO] = @CVE_CPTO
            ORDER BY [CVE_CPTO];


            SELECT TOP (1)
                   @EXISTENCIAS = ISNULL([M].[EXIST], 0),
                   @EXISTENCIAS_GENERAL = [I].[EXIST],
                   @COSTO_PROMEDIO_ANTERIOR = [I].[COSTO_PROM],
                   @COSTO_PROMEDO_CALCULADO = [I].[COSTO_PROM],
				   @COSTO_ARTICULO_DOCUMENTO= [I].[COSTO_PROM]
  
           FROM [SAE70EMPRESA01].[dbo].[INVE01] [I]
                LEFT JOIN [SAE70EMPRESA01].[dbo].[MULT01] [M]
                    ON [M].[CVE_ART] = [I].[CVE_ART]
                       AND [M].[CVE_ALM] = @ALMACEN
            WHERE [I].[CVE_ART] = @ERP_MATERIAL_CODE;

            PRINT 'Obtuvo Existencias ' + @ERP_MATERIAL_CODE + ' ' + CAST(@EXISTENCIAS AS VARCHAR) + ' '
                  + CAST(@EXISTENCIAS + @QTY_DETAIL AS VARCHAR);
            -- ------------------------------------------------------------------------------------
            -- inserta movimiento 
            -- ------------------------------------------------------------------------------------

            INSERT INTO [SAE70EMPRESA01].[dbo].[MINVE01]
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
				[TIPO_PROD],
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
                   [ITEM_CODE_ERP],
                   --[ERP_WAREHOUSE_CODE],
				   --DEM. 11/01/2020. Se hara cambio ya que si la OC se actualiza en SAE, toma el Almacen viejo y no el Nuevo.
				   --Problemas reportados Alza SPS con Proyesa.
				   @ALMACEN,
                   @ULTIMO_DOCUMENTO_MOVIMIENTO + 1,
                   @CVE_CPTO,
                   @FECHA_HOY,
                   @TIPO_DOCUMENTO_FOLIO,
                   ISNULL(@DOCUMENTO_ERP_FORMATEADO, 0),
                   null,
                   null,
                   [QTY_CONFIRMED],
                   0,
                   0,
                   @COSTO_PROMEDIO_ANTERIOR [COSTO],
                   0,
                   [BASE_MEASUREMENT_UNIT],
                   0,
                   @EXISTENCIAS_GENERAL + [QTY_CONFIRMED] [EXISTENCIA_GENERAL],
                   @EXISTENCIAS + [QTY_CONFIRMED] [EXISTENCIA],
				   'P',
                   1,
                   GETDATE(),
                   @ULTIMO_DOCUMENTO_32 + 1 [CVE_FOLIO],
                   1,
                   'S',
                   @COSTO_PROMEDIO_ANTERIOR [COSTO_PROM_INI],
                   @COSTO_PROMEDO_CALCULADO [COSTO_PROM_FIN],
                   @COSTO_PROMEDIO_ANTERIOR [COSTO_PROM_GRAL],
                   'S',
                   0
            FROM [#DETALLE] D
            WHERE ERP_RECEPTION_DOCUMENT_DETAIL_ID = @LINE_NUM_DETAIL;
            -- ------------------------------------------------------------------------------------
            -- actualiza costos
            -- ------------------------------------------------------------------------------------

            UPDATE [SAE70EMPRESA01].[dbo].[INVE01]
            SET [EXIST] = [EXIST] + @QTY_DETAIL,
                [VERSION_SINC] = GETDATE()
            WHERE [CVE_ART] = @ERP_MATERIAL_CODE;

            UPDATE [SAE70EMPRESA01].[dbo].[MULT01]
            SET [EXIST] = [EXIST] + @QTY_DETAIL,
                [VERSION_SINC] = GETDATE()
            WHERE [CVE_ART] = @ERP_MATERIAL_CODE
                  AND [CVE_ALM] = @ALMACEN;


           -- PRINT 'actualiza costos ';

            --UPDATE [SAE70EMPRESA01].[dbo].[PRVPROD01]
            --SET [COSTO] = @COSTO_ARTICULO_DOCUMENTO
            --WHERE [CVE_ART] = @ERP_MATERIAL_CODE
            --      AND [CVE_PROV] = @CODIGO_PROVEEDOR_SAE;

            PRINT 'termina linea';
            UPDATE [#DETALLE]
            SET [ENVIADO] = 1,
                [NUMERO_MOVIMIENTO] = @ULTIMO_DOCUMENTO_MOVIMIENTO +1
            WHERE ERP_RECEPTION_DOCUMENT_DETAIL_ID = @LINE_NUM_DETAIL;
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






