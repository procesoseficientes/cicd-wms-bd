-- =============================================
-- Autor:				pablo.aguilar
-- Fecha de Creacion: 	05-Jul-19 @ Nexus Team Sprint  
-- Description:			SP que 
/*
-- Ejemplo de Ejecucion:
				EXEC [dbo].[SAE_CREATE_INVENTORY_INCOME_BY_PURCHASE_ORDER] @RECEPTION_DOCUMENT_HEADER = 18153 -- numeric


*/
-- =============================================
CREATE PROCEDURE [dbo].[SAE_CREATE_INVENTORY_INCOME_BY_PURCHASE_ORDER]
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
            @TIPO_DOCUMENTO_FOLIO VARCHAR(1) = 'r',
            @SERIE_FOLIO VARCHAR(6) = 'RECP',
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
            @TOTAL_DESCUENTO FLOAT,
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
            @ALMACEN INT = 0,
			@DEMAND_TYPE VARCHAR(255) = 'RECEPCION_COMPRA_LOCAL';

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
               [CD].[PXR],
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
               [CD].[DESCU],
               [CD].[ACT_INV],
               [CD].[TIP_CAM],
               [CD].[UNI_VENTA],
               [CD].[TIPO_ELEM],
               [CD].[TIPO_PROD],
               [CD].[CVE_OBS],
               [CD].[E_LTPD],
               [CD].[REG_SERIE],
               [CD].[FACTCONV],
               [CD].[COST_DEV],
               ISNULL(D.WAREHOUSE_CODE,[CD].[NUM_ALM]) [NUM_ALM],
               [CD].[MINDIRECTO],
               [CD].[NUM_MOV],
               [CD].[TOT_PARTIDA],
               [CD].[MAN_IEPS],
               [CD].[APL_MAN_IMP],
               [CD].[CUOTA_IEPS],
               [CD].[APL_MAN_IEPS],
               [CD].[MTO_PORC],
               [CD].[MTO_CUOTA],
               [CD].[CVE_ESQ],
               [CD].[DESCR_ART],
               CAST(0 AS INT) [NUMERO_MOVIMIENTO],
			   	[CD].COST-[CD].COST*[CD].[DESCU]/100 UNITARIO_CON_DESCUENTO,
				0 AS COSTO_CALCULADO,
				0 COSTO_ANTERIOR
      INTO [#DETALLE]
       FROM [OP_WMS_ALZA].[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [D]
            INNER JOIN [OP_WMS_ALZA].[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [H]
                ON [H].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = [D].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
            INNER JOIN [OP_WMS_ALZA].[wms].[OP_WMS_MATERIALS] [M]
                ON [M].[MATERIAL_ID] = [D].[MATERIAL_ID]
            LEFT JOIN [SAE70EMPRESA01].[dbo].[COMPO01] [CH]
                ON LTRIM(RTRIM([CH].[CVE_DOC])) COLLATE DATABASE_DEFAULT = [H].[DOC_ID] COLLATE DATABASE_DEFAULT
            LEFT JOIN [SAE70EMPRESA01].[dbo].[PAR_COMPO01] [CD]
                ON [CH].[CVE_DOC] = [CD].[CVE_DOC]
                   AND [D].[LINE_NUM] = [CD].[NUM_PAR]
        WHERE [H].[ERP_RECEPTION_DOCUMENT_HEADER_ID] =@RECEPTION_DOCUMENT_HEADER
              AND [IS_CONFIRMED] = 1
              AND [QTY_CONFIRMED] > 0;


		DECLARE @DETALLE_COUNT INT=0;
		SELECT @DETALLE_COUNT = COUNT(*) FROM [#DETALLE]
		IF(@DETALLE_COUNT=0)
		BEGIN
			    UPDATE [SAE70EMPRESA01].[dbo].[COMPO01]
					SET [BLOQ] = 'N', [ENLAZADO]='O'
					WHERE  LTRIM(RTRIM([CVE_DOC])) collate database_default in (select  [DOC_NUM]  collate database_default 
						from [OP_WMS_ALZA].[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] 
						where [ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_DOCUMENT_HEADER) ;
				COMMIT;        
				SELECT 1 AS [Resultado],
					   'sin movimientos' [Mensaje],
					   0 [Codigo],
					   '-1' [DbData];
				return;
		END;
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
               ISNULL([CH].[CVE_CLPV],'') CVE_CLPV,
               [CH].[STATUS],
               [CH].[SU_REFER],
               [CH].[FECHA_DOC],
               [CH].[FECHA_REC],
               [CH].[FECHA_PAG],
               [CH].[FECHA_CANCELA],
               [CH].[CAN_TOT],
               [CH].[IMP_TOT1],
               [CH].[IMP_TOT2],
               [CH].[IMP_TOT3],
               [CH].[IMP_TOT4],
               [CH].[DES_TOT],
               [CH].[DES_FIN],
               [CH].[TOT_IND],
               [CH].[OBS_COND],
               [CH].[CVE_OBS],
               (select top 1 D.[NUM_ALM] from [#DETALLE] D) as [NUM_ALMA],---
               [CH].[ACT_CXP],
               [CH].[ACT_COI],
               [CH].[NUM_MONED],
               [CH].[TIPCAMB],
               [CH].[ENLAZADO],
               [CH].[TIP_DOC_E],
               [CH].[NUM_PAGOS],
               [CH].[FECHAELAB],
               [CH].[SERIE],
               [CH].[FOLIO],
               [CH].[CTLPOL],
               [CH].[ESCFD],
               [CH].[CONTADO],
               [CH].[BLOQ],
               [CH].[DES_FIN_PORC],
               [CH].[DES_TOT_PORC],
               [CH].[IMPORTE],
               [CH].[TIP_DOC_ANT],
               [CH].[DOC_ANT],
               [CH].[TIP_DOC_SIG],
               [CH].[DOC_SIG],
               [CH].[FORMAENVIO]
        INTO [#ENCABEZADO]
        FROM [OP_WMS_ALZA].[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [H]
            LEFT JOIN [SAE70EMPRESA01].[dbo].[COMPO01] [CH]
                ON RTRIM(LTRIM([CH].[CVE_DOC])) COLLATE DATABASE_DEFAULT = [H].[DOC_ID] COLLATE DATABASE_DEFAULT
        WHERE [ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_DOCUMENT_HEADER;


        -- ------------------------------------------------------------------------------------
        -- obtener variables de proveedor
        -- ------------------------------------------------------------------------------------
        SELECT @CODIGO_PROVEEDOR_SAE = [P].[CLAVE],
               @NOMBRE_PROVEEDOR_SAE = [P].[NOMBRE]
        FROM [SAE70EMPRESA01].[dbo].[PROV01] [P]
            INNER JOIN [#ENCABEZADO] [H]
                ON [H].[CVE_CLPV] = [P].[CLAVE]
        WHERE [P].[STATUS] <> 'B';



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

        -- ------------------------------------------------------------------------------------
        -- obtiene folios y serie de documento de recepción 
        -- ------------------------------------------------------------------------------------
        SELECT TOP (1)
               @ULT_DOC_FOLIO = [ULT_DOC],
               @FOLIO_DESDE = [FOLIODESDE],
               @DOCUMENTO_ERP_FORMATEADO = [SERIE] + [dbo].[FUNC_ADD_CHARS]([ULT_DOC] + 1, '0', 8)
        FROM [SAE70EMPRESA01].[dbo].[FOLIOSC01]
        WHERE [TIP_DOC] = @TIPO_DOCUMENTO_FOLIO
              AND [SERIE] = @SERIE_FOLIO
        GROUP BY [TIP_DOC],
                 [SERIE],
                 [FOLIODESDE],
                 [FOLIOHASTA],
                 [ULT_DOC],
                 [FECH_ULT_DOC]
        ORDER BY [FOLIOHASTA] DESC;

        PRINT 'Obtuvo ultimo folio' + CAST(@DOCUMENTO_ERP_FORMATEADO AS VARCHAR);

        UPDATE [SAE70EMPRESA01].[dbo].[FOLIOSC01]
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
                   @LINE_NUM_DETAIL = [LINE_NUM],
                   @QTY_DETAIL = [QTY_CONFIRMED],
                   @COSTO_ARTICULO_DOCUMENTO = UNITARIO_CON_DESCUENTO,

                   --@COSTO_PROMEDO_CALCULADO = [COST],
                   @ORDEN_COMPRA_DOCUMENTO = ISNULL([CVE_DOC],''),
                   @EXISTENCIAS = 0,
                   @EXISTENCIAS_GENERAL = 0,
                   @ALMACEN = [NUM_ALM]
            FROM [#DETALLE]
            WHERE [ENVIADO] = 0
            ORDER BY [LINE_NUM] ASC;
            PRINT 'Ciclo detalle line: ' + CAST(@LINE_NUM_DETAIL AS VARCHAR)+@ERP_MATERIAL_CODE+'-'+ +'-MATERIAL-'+@MATERIAL_ID_DETAIL;
						select @DEMAND_TYPE =type 
				from [OP_WMS_ALZA].[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [H] 
				where h.ERP_RECEPTION_DOCUMENT_HEADER_ID=@RECEPTION_DOCUMENT_HEADER

			IF @DEMAND_TYPE = 'RECEPCION_TRASLADO'
		
			select @TIPO_DOCUMENTO_FOLIO = 'M',
				@CVE_CPTO=  CVE_MSAL 
			from  [SAE70EMPRESA01].[dbo].ALMACENES01 
			where CVE_MENT=@ALMACEN
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
                   @COSTO_PROMEDO_CALCULADO
                       = (([I].[EXIST] * [I].[COSTO_PROM]) + (@QTY_DETAIL * @COSTO_ARTICULO_DOCUMENTO))
                         / ([I].[EXIST] + @QTY_DETAIL)
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
                   @DOCUMENTO_ERP_FORMATEADO,
                   @CODIGO_PROVEEDOR_SAE,
                   '',
                   [QTY_CONFIRMED],
                   0,
                   0,
                   UNITARIO_CON_DESCUENTO [COSTO],
                   0,
                   [BASE_MEASUREMENT_UNIT],
                   0,
                   @EXISTENCIAS_GENERAL + [QTY_CONFIRMED] [EXISTENCIA_GENERAL],
                   @EXISTENCIAS + [QTY_CONFIRMED] [EXISTENCIA],
                   1,
                   GETDATE(),
                   @ULTIMO_DOCUMENTO_32 + 1 [CVE_FOLIO],
                   @SIGNO,
                   'S',
                   @COSTO_PROMEDIO_ANTERIOR [COSTO_PROM_INI],
                   @COSTO_PROMEDO_CALCULADO [COSTO_PROM_FIN],
                   @COSTO_PROMEDIO_ANTERIOR [COSTO_PROM_GRAL],
                   'N',
                   0
            FROM [#DETALLE]
            WHERE [LINE_NUM] = @LINE_NUM_DETAIL;




            -- ------------------------------------------------------------------------------------
            -- actualiza costos
            -- ------------------------------------------------------------------------------------

            UPDATE [SAE70EMPRESA01].[dbo].[INVE01]
            SET [EXIST] = [EXIST] + @QTY_DETAIL,
                [VERSION_SINC] = GETDATE(),
                [ULT_COSTO] = @COSTO_ARTICULO_DOCUMENTO,
                [COSTO_PROM] = @COSTO_PROMEDO_CALCULADO
            WHERE [CVE_ART] = @ERP_MATERIAL_CODE;

            UPDATE [SAE70EMPRESA01].[dbo].[MULT01]
            SET [EXIST] = [EXIST] + @QTY_DETAIL,
                [VERSION_SINC] = GETDATE()
            WHERE [CVE_ART] = @ERP_MATERIAL_CODE
                  AND [CVE_ALM] = @ALMACEN;


            PRINT 'actualiza costos ';

            UPDATE [SAE70EMPRESA01].[dbo].[PRVPROD01]
            SET [COSTO] = @COSTO_ARTICULO_DOCUMENTO
            WHERE [CVE_ART] = @ERP_MATERIAL_CODE
                  AND [CVE_PROV] = @CODIGO_PROVEEDOR_SAE;

            PRINT 'termina linea';--
            UPDATE [#DETALLE]
            SET [ENVIADO] = 1,
                [NUMERO_MOVIMIENTO] = @ULTIMO_DOCUMENTO_MOVIMIENTO + 1,  
				COSTO_CALCULADO=ISNULL(@COSTO_PROMEDO_CALCULADO,0),
				COSTO_ANTERIOR=ISNULL(@COSTO_PROMEDIO_ANTERIOR,0)
            WHERE [LINE_NUM] = @LINE_NUM_DETAIL;
        END;


        -- ------------------------------------------------------------------------------------
        --  actualiza encabezados de compra 
        -- ------------------------------------------------------------------------------------
        SELECT @TOTAL_COMPRA = SUM([D].[QTY_CONFIRMED] * [D].[COST]),
               @TOTAL_IMPUESTO_04 = SUM([D].[QTY_CONFIRMED] * [D].UNITARIO_CON_DESCUENTO * [D].[IMPU4] / 100),
               @TOTAL_IMPUESTO_03 = SUM([D].[QTY_CONFIRMED] * [D].UNITARIO_CON_DESCUENTO * [D].[IMPU3] / 100),
               @TOTAL_IMPUESTO_02 = SUM([D].[QTY_CONFIRMED] * [D].UNITARIO_CON_DESCUENTO * [D].[IMPU2] / 100),
               @TOTAL_IMPUESTO_01 = SUM([D].[QTY_CONFIRMED] * [D].UNITARIO_CON_DESCUENTO * [D].[IMPU1] / 100),
			   @TOTAL_DESCUENTO = SUM(D.[QTY_CONFIRMED]*D.COST*D.DESCU/100),
               @TOTAL_IMPORTE
                   = SUM([D].[QTY_CONFIRMED] * [D].UNITARIO_CON_DESCUENTO) + SUM([D].[QTY_CONFIRMED] * [D].UNITARIO_CON_DESCUENTO * [D].[IMPU4] / 100)
                     + SUM([D].[QTY_CONFIRMED] * [D].UNITARIO_CON_DESCUENTO * [D].[IMPU3] / 100)
                     + SUM([D].[QTY_CONFIRMED] * [D].UNITARIO_CON_DESCUENTO * [D].[IMPU2] / 100)
                     + SUM([D].[QTY_CONFIRMED] * [D].UNITARIO_CON_DESCUENTO * [D].[IMPU1] / 100)
        FROM [#DETALLE] [D];

        PRINT 'Actualiza ACOMP04';
        UPDATE [SAE70EMPRESA01].[dbo].[ACOMP01]
        SET [RVTA_COM] = [RVTA_COM] + @TOTAL_COMPRA,
            [RDESCTO] = [RDESCTO] + 0,
            [RDES_FIN] = [RDES_FIN] + 0,
            [RIMP] = [RIMP] + @TOTAL_IMPUESTO_COMPRA,
            [RTOT_IND] = [RTOT_IND] + 0
        WHERE [PER_ACUM] = @MES_ACTUAL;

        -- ------------------------------------------------------------------------------------
        -- inserta documento de recepción
        -- ------------------------------------------------------------------------------------
        INSERT INTO [SAE70EMPRESA01].[dbo].[COMPR01]
        (
            [TIP_DOC],
            [CVE_DOC],
            [CVE_CLPV],
            [STATUS],
            [SU_REFER],
            [FECHA_DOC],
            [FECHA_REC],
            [FECHA_PAG],
            [CAN_TOT],
            [IMP_TOT1],
            [IMP_TOT2],
            [IMP_TOT3],
            [IMP_TOT4],
            [DES_TOT],
            [DES_FIN],
            [OBS_COND],
            [CVE_OBS],
            [NUM_ALMA],
            [ACT_CXP],
            [ACT_COI],
            [ENLAZADO],
            [TIP_DOC_E],
            [NUM_MONED],
            [TIPCAMB],
            [FECHAELAB],
            [SERIE],
            [FOLIO],
            [CTLPOL],
            [ESCFD],
            [CONTADO],
            [BLOQ],
            [TOT_IND],
            [DES_FIN_PORC],
            [DES_TOT_PORC],
            [IMPORTE],
            [DOC_ANT],
            [TIP_DOC_ANT],
			FORMAENVIO
        )
        SELECT TOP (1)
               @TIPO_DOCUMENTO_FOLIO,
               @DOCUMENTO_ERP_FORMATEADO,
               [E].[CVE_CLPV],
               'O',
               CAST('SWIFT: ' + CAST([TASK_ID] AS VARCHAR) AS VARCHAR(20)) [SU_REFER],
               @FECHA_HOY [FECHA_DOC],
               @FECHA_HOY [FECHA_REC],
               DATEADD(MONTH, 3, @FECHA_HOY) [FECHA_PAG],
               @TOTAL_COMPRA,
               @TOTAL_IMPUESTO_01,
               @TOTAL_IMPUESTO_02,
               @TOTAL_IMPUESTO_03,
               @TOTAL_IMPUESTO_04,
               @TOTAL_DESCUENTO,
               [E].[DES_FIN],
               [E].[OBS_COND],
               @ULTIMO_DOCUMENTO_COMENTARIO + 1,
               [E].[NUM_ALMA],
               'S' [ACT_CXP],
               'N' [ACT_COI],
               'O' [ENLAZADO],
               'o' [TIP_DOC_E],
               [E].[NUM_MONED] [NUM_MONED],
               [E].[TIPCAMB],
               GETDATE(),
               @SERIE_FOLIO,
               @ULT_DOC_FOLIO + 1 [FOLIO],
               0 [CTLPOL],
               'N' [ESCFD],
               'N' [CONTADO],
               'N' [BLOQ],
               [E].[TOT_IND] [TOT_IND],
               [E].[DES_FIN] [DES_FIN_PORC],
               [E].[DES_TOT_PORC] [DES_TOT_PORC],
               @TOTAL_IMPORTE [IMPORTE],
               [E].[CVE_DOC] [DOC_ANT],
               [E].[TIP_DOC] [TIP_DOC_ANT],
			   ISNULL(E.FORMAENVIO,'I')
        FROM [#ENCABEZADO] [E]
        ORDER BY [E].[DOC_ID] DESC;
        PRINT 'inserta en compro04';
        INSERT INTO [SAE70EMPRESA01].[dbo].[COMPR_CLIB01]
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
            [CAMPLIB14]
        )
        VALUES
        (@DOCUMENTO_ERP_FORMATEADO, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

        UPDATE [#DETALLE]
        SET [ENVIADO] = 0;
        SELECT @CONTADOR_LINEA = 0;
		        PRINT 'ANTES';

        WHILE EXISTS (SELECT TOP (1) 1 FROM [#DETALLE] WHERE [ENVIADO] = 0)
        BEGIN
            SELECT TOP (1)
                   @ERP_MATERIAL_CODE = [ITEM_CODE_ERP],
                   @MATERIAL_ID_DETAIL = [MATERIAL_ID],
                   @LINE_NUM_DETAIL = [LINE_NUM],
                   @QTY_DETAIL = [QTY_CONFIRMED],
                   @COSTO_ARTICULO_DOCUMENTO = UNITARIO_CON_DESCUENTO,
                   @COSTO_PROMEDO_CALCULADO = COSTO_CALCULADO,
				   @COSTO_PROMEDIO_ANTERIOR=COSTO_ANTERIOR
            FROM [#DETALLE]
            WHERE [ENVIADO] = 0
            ORDER BY [LINE_NUM] ASC;

			PRINT 'DENTRO DLE CICLO';

            UPDATE [SAE70EMPRESA01].[dbo].[PAR_COMPO01]
            SET [PXR] = (CASE
                             WHEN [PXR] < @QTY_DETAIL THEN
                                 0
                             ELSE
                                 [PXR] - @QTY_DETAIL
                         END
                        )
            WHERE [CVE_DOC] = @ORDEN_COMPRA_DOCUMENTO
                  AND [NUM_PAR] = @LINE_NUM_DETAIL
                  AND [CVE_ART] = @ERP_MATERIAL_CODE;


            UPDATE [SAE70EMPRESA01].[dbo].[INVE01]
            SET [COMP_X_REC] = (CASE
                                    WHEN [COMP_X_REC] + (@QTY_DETAIL * -1) < 0 THEN
                                        0
                                    WHEN [COMP_X_REC] + (@QTY_DETAIL * -1) >= 0 THEN
                                        [COMP_X_REC] + (@QTY_DETAIL * -1)
                                    ELSE
                                        0
                                END
                               )
            WHERE [CVE_ART] = @ERP_MATERIAL_CODE;



            UPDATE [SAE70EMPRESA01].[dbo].[INVE01]
            SET [COMP_ANL_C] = [COMP_ANL_C] + @QTY_DETAIL,
                [COMP_ANL_M] = [COMP_ANL_M] + @COSTO_ARTICULO_DOCUMENTO * @QTY_DETAIL,
                [FCH_ULTCOM] = @FECHA_HOY
            WHERE [CVE_ART] = @ERP_MATERIAL_CODE;


            INSERT INTO [SAE70EMPRESA01].[dbo].[PAR_COMPR01]
            (
                [CVE_DOC],
                [NUM_PAR],
                [CVE_ART],
                [CANT],
                [PXR],
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
                [DESCU],
                [ACT_INV],
                [NUM_ALM],
                [TIP_CAM],
                [UNI_VENTA],
                [TIPO_PROD],
                [TIPO_ELEM],
                [CVE_OBS],
                [REG_SERIE],
                [E_LTPD],
                [FACTCONV],
                [COST_DEV],
                [MINDIRECTO],
                [NUM_MOV],
                [TOT_PARTIDA],
                [MAN_IEPS],
                [APL_MAN_IMP],
                [CUOTA_IEPS],
                [APL_MAN_IEPS],
                [MTO_PORC],
                [MTO_CUOTA],
                [CVE_ESQ]
            )
            SELECT TOP 1
                   @DOCUMENTO_ERP_FORMATEADO [CVE_DOC],
                   [D].[LINE_NUM] [NUM_PAR],
                   [D].[CVE_ART] [CVE_ART],
                   [D].[QTY_CONFIRMED] [CANT],
                   [D].[QTY_CONFIRMED] [PXR],
                   [D].[PREC]*[TIP_CAM] [PREC],
                   [D].COST [COST],
                   [D].[IMPU1] [IMPU1],
                   [D].[IMPU2] [IMPU2],
                   [D].[IMPU3] [IMPU3],
                   [D].[IMPU4] [IMPU4],
                   [D].[IMP1APLA] [IMP1APLA],
                   [D].[IMP2APLA] [IMP2APLA],
                   [D].[IMP3APLA] [IMP3APLA],
                   [D].[IMP4APLA] [IMP4APLA],
                   @TOTAL_IMPUESTO_01 [TOTIMP1],
                   @TOTAL_IMPUESTO_02 [TOTIMP2],
                   @TOTAL_IMPUESTO_03 [TOTIMP3],
                   [D].[QTY_CONFIRMED] * D.UNITARIO_CON_DESCUENTO*[D].[IMPU4]/100 [TOTIMP4],
                   [D].[DESCU] [DESCU],
                   'S' [ACT_INV],
                   [D].[NUM_ALM] [NUM_ALM],
                   [D].[TIP_CAM] [TIP_CAM],
                   [D].[UNI_VENTA] [UNI_VENTA],
                   [D].[TIPO_PROD] [TIPO_PROD],
                   [D].[TIPO_ELEM] [TIPO_ELEM],
                   [D].[CVE_OBS] [CVE_OBS],
                   [D].[REG_SERIE] [REG_SERIE],
                   [D].[E_LTPD],
                   [D].[FACTCONV],
                   [D].UNITARIO_CON_DESCUENTO,
                   [D].[MINDIRECTO],
                   [NUMERO_MOVIMIENTO] [NUM_MOV],
                   [D].[QTY_CONFIRMED] * [D].[COST] [TOT_PARTIDA],
                   [D].[MAN_IEPS],
                   [D].[APL_MAN_IMP],
                   [D].[CUOTA_IEPS],
                   [D].[APL_MAN_IEPS],
                   [D].[MTO_PORC],
                   [D].[MTO_CUOTA],
                   [D].[CVE_ESQ]
            FROM [#DETALLE] [D]
            WHERE [LINE_NUM] = @LINE_NUM_DETAIL;

            PRINT 'Inserto en parcompo ' + CAST(@ULTIMO_DOCUMENTO_MOVIMIENTO AS VARCHAR);

            UPDATE [SAE70EMPRESA01].[dbo].[COMPO01]
            SET [DOC_SIG] = @DOCUMENTO_ERP_FORMATEADO,
                [TIP_DOC_SIG] = @TIPO_DOCUMENTO_FOLIO
            WHERE [CVE_DOC] = @ORDEN_COMPRA_DOCUMENTO;


            UPDATE [SAE70EMPRESA01].[dbo].[COMPO01]
            SET [TIP_DOC_E] = @TIPO_DOCUMENTO_FOLIO,
                [ENLAZADO] = (CASE
                                  WHEN
                                  (
                                      SELECT SUM([P].[PXR])
                                      FROM [SAE70EMPRESA01].[dbo].[PAR_COMPO01] [P]
                                      WHERE [P].[CVE_DOC] = @ORDEN_COMPRA_DOCUMENTO
                                            AND [COMPO01].[CVE_DOC] = [P].[CVE_DOC]
                                  ) = 0 THEN
                                      'T'
                                  WHEN
                                  (
                                      SELECT SUM([P].[PXR])
                                      FROM [SAE70EMPRESA01].[dbo].[PAR_COMPO01] [P]
                                      WHERE [P].[CVE_DOC] = @ORDEN_COMPRA_DOCUMENTO
                                            AND [COMPO01].[CVE_DOC] = [P].[CVE_DOC]
                                  ) > 0 THEN
                                      'P'
                                  ELSE
                                      [ENLAZADO]
                              END
                             )
            WHERE [COMPO01].[CVE_DOC] = @ORDEN_COMPRA_DOCUMENTO;


            UPDATE [SAE70EMPRESA01].[dbo].[COMPO01]
            SET [TIP_DOC_E] = @TIPO_DOCUMENTO_FOLIO,
				BLOQ='N',
                [ENLAZADO] = (CASE
                                  WHEN
                                  (
                                      SELECT SUM([P].[PXR])
                                      FROM [SAE70EMPRESA01].[dbo].[PAR_COMPO01] [P]
                                      WHERE [P].[CVE_DOC] = @ORDEN_COMPRA_DOCUMENTO
                                            AND [COMPO01].[CVE_DOC] = [P].[CVE_DOC]
                                  ) = 0 THEN
                                      'T'
                                  WHEN
                                  (
                                      SELECT SUM([P].[PXR])
                                      FROM [SAE70EMPRESA01].[dbo].[PAR_COMPO01] [P]
                                      WHERE [P].[CVE_DOC] = @ORDEN_COMPRA_DOCUMENTO
                                            AND [COMPO01].[CVE_DOC] = [P].[CVE_DOC]
                                  ) > 0 THEN
                                      'P'
                                  ELSE
                                      [ENLAZADO]
                              END
                             )
            WHERE [COMPO01].[CVE_DOC] = @ORDEN_COMPRA_DOCUMENTO;


            INSERT INTO [SAE70EMPRESA01].[dbo].[DOCTOSIGC01]
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
            (@TIPO_DOCUMENTO_FOLIO, @DOCUMENTO_ERP_FORMATEADO, 'A', 'o', @ORDEN_COMPRA_DOCUMENTO, @LINE_NUM_DETAIL,
             @LINE_NUM_DETAIL, @QTY_DETAIL);




            INSERT INTO [SAE70EMPRESA01].[dbo].[DOCTOSIGC01]
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
            ('o', @ORDEN_COMPRA_DOCUMENTO, 'S', @TIPO_DOCUMENTO_FOLIO, @DOCUMENTO_ERP_FORMATEADO, @LINE_NUM_DETAIL,
             @LINE_NUM_DETAIL, @QTY_DETAIL);

            INSERT INTO [SAE70EMPRESA01].[dbo].[PAR_COMPR_CLIB01]
            (
                [CLAVE_DOC],
                [NUM_PART],
                [CAMPLIB1],
                [CAMPLIB2]
            )
            VALUES
            (@DOCUMENTO_ERP_FORMATEADO, @LINE_NUM_DETAIL, NULL, NULL);

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
