-- =============================================
-- Autor:				gustavo.garcia
-- Fecha de Creacion: 	09-feb-21 
-- Description:			

-- Modificación:	   Elder Lucas
-- Fecha modificación: 17 de marzo 2022
-- Descripció:		   Se reemplaza el origen de el precio para obtener el que se obtuvo al imprimir el pase de salida

-- Modificación:	   Elder Lucas
-- Fecha modificación: 22 de marzo 2022
-- Descripció:		   Se agrega manejo de concepto
/*
-- Ejemplo de Ejecucion:
				EXEC [dbo].[SAE_CREATE_INVENTORY_INCOME_BY_TRANSFER_SAE] @RECEPTION_DOCUMENT_HEADER = 4077 -- numeric

Proceso fallido: Violation of PRIMARY KEY constraint 'PK_COMPR_CLIB01'. Cannot insert duplicate key in object 'dbo.COMPR_CLIB01'. The duplicate key value is (0).
Proceso fallido: Violation of PRIMARY KEY constraint 'PK_COMPR01'. Cannot insert duplicate key in object 'dbo.COMPR01'. The duplicate key value is (000001-08-00091009).
Proceso fallido: Violation of PRIMARY KEY constraint 'PK_PAR_COMPR_CLIB01'. Cannot insert duplicate key in object 'dbo.PAR_COMPR_CLIB01'. The duplicate key value is (000001-08-00091009, 1).
*/
-- =============================================
CREATE PROCEDURE [dbo].[SAE_CREATE_INVENTORY_INCOME_BY_TRANSFER_SAE]
(@RECEPTION_DOCUMENT_HEADER NUMERIC)
AS
BEGIN
    SET NOCOUNT ON;
    --

    -- ------------------------------------------------------------------------------------
    -- Declaramos variables
    -- ------------------------------------------------------------------------------------
    DECLARE @TABLA_DOCUMENTO_32 INT = 32,
            @ULTIMO_DOCUMENTO INT = 0,
            @TIPO_DOCUMENTO_FOLIO VARCHAR(1) = 'M',
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
			@DEMAND_TYPE VARCHAR(255) = 'RECEPCION_TRASLADO';

    BEGIN TRY
        BEGIN TRANSACTION;
        -- ------------------------------------------------------------------------------------
        -- obtiene datos de Wms
        -- ------------------------------------------------------------------------------------

        SELECT MAX([D].[ERP_RECEPTION_DOCUMENT_DETAIL_ID])[ERP_RECEPTION_DOCUMENT_DETAIL_ID],
               MAX([D].[ERP_RECEPTION_DOCUMENT_HEADER_ID])[ERP_RECEPTION_DOCUMENT_HEADER_ID],
               [D].[MATERIAL_ID],
               SUM([D].[QTY])[QTY],
               MAX([D].[LINE_NUM])[LINE_NUM],
               MAX([D].[ERP_OBJECT_TYPE])[ERP_OBJECT_TYPE],
               MAX([D].[WAREHOUSE_CODE])[WAREHOUSE_CODE],
               MAX([D].[CURRENCY])[CURRENCY],
               MAX([D].[RATE])[RATE],
               MAX([D].[TAX_CODE])[TAX_CODE],
               MAX([D].[VAT_PERCENT])[VAT_PERCENT],
               MAX([D].[PRICE])[PRICE],
               MAX([D].[DISCOUNT])[DISCOUNT],
               MAX([D].[COST_CENTER])[COST_CENTER],
               SUM([D].[QTY_ASSIGNED])[QTY_ASSIGNED],
               MAX([D].[UNIT])[UNIT],
               MAX([D].[UNIT_DESCRIPTION])[UNIT_DESCRIPTION],
               sum([D].[QTY_CONFIRMED])[QTY_CONFIRMED],
               MAX([D].[IS_CONFIRMED])[IS_CONFIRMED],
               0 [ENVIADO],
               MAX([M].[ITEM_CODE_ERP])[ITEM_CODE_ERP],
               MAX([M].[BASE_MEASUREMENT_UNIT])[BASE_MEASUREMENT_UNIT],
               MAX([H].[DOC_ID])[DOC_ID],
               MAX([H].[TYPE])[TYPE],
               MAX([H].[CODE_SUPPLIER])[CODE_SUPPLIER],
               MAX([H].[CODE_CLIENT])[CODE_CLIENT],
               MAX([H].[ERP_DATE])[ERP_DATE],
               MAX([H].[IS_AUTHORIZED])[IS_AUTHORIZED],
               MAX([H].[IS_COMPLETE])[IS_COMPLETE],
               MAX([H].[TASK_ID])[TASK_ID],
               MAX([H].[EXTERNAL_SOURCE_ID])[EXTERNAL_SOURCE_ID],
               MAX([H].[ERP_REFERENCE_DOC_NUM])[ERP_REFERENCE_DOC_NUM],
               MAX([H].[DOC_NUM])[DOC_NUM],
               MAX([H].[NAME_SUPPLIER])[NAME_SUPPLIER],
               MAX([H].[OWNER])[OWNER],
               MAX([H].[IS_FROM_WAREHOUSE_TRANSFER])[IS_FROM_WAREHOUSE_TRANSFER],
               MAX([H].[IS_FROM_ERP])[IS_FROM_ERP],
               MAX([H].[DOC_ID_POLIZA])[DOC_ID_POLIZA],
               MAX([H].[LOCKED_BY_INTERFACES])[LOCKED_BY_INTERFACES],
               MAX([H].[IS_VOID])[IS_VOID],
               MAX([H].[SOURCE])[SOURCE],
               MAX([H].[ERP_WAREHOUSE_CODE])[ERP_WAREHOUSE_CODE],
               MAX([H].[DOC_ENTRY])[DOC_ENTRY],
               MAX([H].[MANIFEST_HEADER_ID])[MANIFEST_HEADER_ID],
               MAX([H].[PLATE_NUMBER])[PLATE_NUMBER],
               MAX([H].[ADDRESS])[ADDRESS],
               MAX([H].[DOC_CURRENCY])[DOC_CURRENCY],
               MAX([H].[DOC_RATE])[DOC_RATE],
               MAX([H].[SUBSIDIARY])[SUBSIDIARY],
               MAX([H].[USER_CONFIRMED])[USER_CONFIRMED],
               MAX([H].[DATE_CONFIRMED])[DATE_CONFIRMED],
               MAX([H].[CONFIRMED_BY])[CONFIRMED_BY],
               MAX([H].[RECEPTION_TYPE_ERP])[RECEPTION_TYPE_ERP],
               MAX([CD].[CVE_DOC])[CVE_DOC],
               MAX([CD].[NUM_PAR])[NUM_PAR],
               MAX([CD].[CVE_ART])[CVE_ART],
               MAX([CD].[CANT])[CANT],
               MAX([CD].[PXR])[PXR],
               MAX([CD].[PREC])[PREC],
               MAX([CD].[COST])[COST],
               MAX([CD].[IMPU1])[IMPU1],
               MAX([CD].[IMPU2])[IMPU2],
               MAX([CD].[IMPU3])[IMPU3],
               MAX([CD].[IMPU4])[IMPU4],
               MAX([CD].[IMP1APLA])[IMP1APLA],
               MAX([CD].[IMP2APLA])[IMP2APLA],
               MAX([CD].[IMP3APLA])[IMP3APLA],
               MAX([CD].[IMP4APLA])[IMP4APLA],
               MAX([CD].[TOTIMP1])[TOTIMP1],
               MAX([CD].[TOTIMP2])[TOTIMP2],
               MAX([CD].[TOTIMP3])[TOTIMP3],
               MAX([CD].[TOTIMP4])[TOTIMP4],
               MAX([CD].[DESCU])[DESCU],
               MAX([CD].[ACT_INV])[ACT_INV],
               MAX([CD].[TIP_CAM])[TIP_CAM],
               MAX([CD].[UNI_VENTA])[UNI_VENTA],
               MAX([CD].[TIPO_ELEM])[TIPO_ELEM],
               MAX([CD].[TIPO_PROD])[TIPO_PROD],
               MAX([CD].[CVE_OBS])[CVE_OBS],
               MAX([CD].[E_LTPD])[E_LTPD],
               MAX([CD].[REG_SERIE])[REG_SERIE],
               MAX([CD].[FACTCONV])[FACTCONV],
               MAX([CD].[COST_DEV])[COST_DEV],
               MAX(ISNULL([CD].[NUM_ALM],D.WAREHOUSE_CODE)) [NUM_ALM],
               MAX([CD].[MINDIRECTO])[MINDIRECTO],
               MAX([CD].[NUM_MOV])[NUM_MOV],
               MAX([CD].[TOT_PARTIDA])[TOT_PARTIDA],
               MAX([CD].[MAN_IEPS])[MAN_IEPS],
               MAX([CD].[APL_MAN_IMP])[APL_MAN_IMP],
               MAX([CD].[CUOTA_IEPS])[CUOTA_IEPS],
               MAX([CD].[APL_MAN_IEPS])[APL_MAN_IEPS],
               MAX([CD].[MTO_PORC])[MTO_PORC],
               MAX([CD].[MTO_CUOTA])[MTO_CUOTA],
               MAX([CD].[CVE_ESQ])[CVE_ESQ],
               MAX([CD].[DESCR_ART])[DESCR_ART],
               CAST(0 AS INT) [NUMERO_MOVIMIENTO],
			   MAX([D].COST_BY_MATERIAL) COST_BY_MATERIAL
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
        WHERE [H].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_DOCUMENT_HEADER
              AND [IS_CONFIRMED] = 1
              AND [QTY_CONFIRMED] > 0
		GROUP BY D.MATERIAL_ID;

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
               [CH].[NUM_ALMA],
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
               [CH].[FORMAENVIO],
			   [PDH].CAI_NUMERO,
			   [PDH].CAI_SERIE
        INTO [#ENCABEZADO]
        FROM [OP_WMS_ALZA].[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [H]
            LEFT JOIN [SAE70EMPRESA01].[dbo].[COMPO01] [CH]
                ON RTRIM(LTRIM([CH].[CVE_DOC])) COLLATE DATABASE_DEFAULT = [H].[DOC_ID] COLLATE DATABASE_DEFAULT
			INNER JOIN [OP_WMS_ALZA].[wms].[OP_WMS_MANIFEST_HEADER] [MH] ON (MH.MANIFEST_HEADER_ID =H.DOC_NUM)
			INNER JOIN [OP_WMS_ALZA].[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH] ON (PDH.DOC_NUM = MH.TRANSFER_REQUEST_ID)
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

		--oBTIENE ALMACEN ORIGEN
		SELECT @ALMACEN= CAST(W.ERP_WAREHOUSE AS int)
	 FROM  [OP_WMS_ALZA].[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [PDH] 
	 INNER JOIN [OP_WMS_ALZA].[wms].[OP_WMS_MANIFEST_HEADER] [MH] ON MH.MANIFEST_HEADER_ID= PDH.DOC_NUM
	 INNER JOIN [OP_WMS_ALZA].[wms].[OP_WMS_TRANSFER_REQUEST_HEADER] [TRH] ON TRH.TRANSFER_REQUEST_ID=MH.TRANSFER_REQUEST_ID
	 INNER JOIN[OP_WMS_ALZA].[wms].[OP_WMS_WAREHOUSES] [W] ON W.[WAREHOUSE_ID] = TRH.WAREHOUSE_TO
	 			WHERE ERP_RECEPTION_DOCUMENT_HEADER_ID = @RECEPTION_DOCUMENT_HEADER

        -- ------------------------------------------------------------------------------------
        -- Obtiene ultimo documento
        -- ------------------------------------------------------------------------------------



        SELECT @ULTIMO_DOCUMENTO = CAST(CAI_NUMERO AS int),
			@SERIE_FOLIO=CAI_SERIE,
			@DOCUMENTO_ERP_FORMATEADO= ISNULL(CAI_SERIE, 0) + [dbo].[FUNC_ADD_CHARS](CAI_NUMERO, '0', 8)
        FROM [#ENCABEZADO];



        PRINT 'Obtuvo ultimo folio' + CAST(@DOCUMENTO_ERP_FORMATEADO AS VARCHAR);
        PRINT 'Obtuvo ultimo documento @ULTIMO_DOCUMENTO' + CAST(@ULTIMO_DOCUMENTO AS VARCHAR);
		PRINT 'Obtiene el Almacen @ALMACEN' +  cast(@ALMACEN as varchar);


		-- ------------------------------------------------------------------------------------
        -- Identificamos el concepto
        -- ------------------------------------------------------------------------------------

		

			
			DECLARE @BODEGA_ORIGEN INT,
				@BODEGA_DESTINO INT,
				@TRANSFER_REQUEST_ID INT,
				@CLIMA VARCHAR(10)

			SELECT 
				@TRANSFER_REQUEST_ID = TRH.TRANSFER_REQUEST_ID
			FROM OP_WMS_ALZA.wms.OP_WMS_TRANSFER_REQUEST_HEADER TRH
				INNER JOIN OP_WMS_ALZA.wms.OP_WMS_TASK_LIST TL
					ON TRH.TRANSFER_REQUEST_ID = TL.TRANSFER_REQUEST_ID
				INNER JOIN OP_WMS_ALZA.wms.OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER RDH
					ON RDH.TASK_ID = TL.SERIAL_NUMBER AND RDH.ERP_RECEPTION_DOCUMENT_HEADER_ID = @RECEPTION_DOCUMENT_HEADER


			SELECT 
				@BODEGA_ORIGEN = W.ERP_WAREHOUSE
			FROM OP_WMS_ALZA.wms.OP_WMS_WAREHOUSES W
				INNER JOIN OP_WMS_ALZA.wms.OP_WMS_TRANSFER_REQUEST_HEADER TRH
					ON TRH.WAREHOUSE_FROM = W.WAREHOUSE_ID AND TRH.TRANSFER_REQUEST_ID = @TRANSFER_REQUEST_ID--OR TRH.WAREHOUSE_TO = W.WAREHOUSE_ID



			SELECT 
				@BODEGA_DESTINO = W.ERP_WAREHOUSE
			FROM OP_WMS_ALZA.wms.OP_WMS_WAREHOUSES W
				INNER JOIN OP_WMS_ALZA.wms.OP_WMS_TRANSFER_REQUEST_HEADER TRH
					ON TRH.WAREHOUSE_TO = W.WAREHOUSE_ID AND TRH.TRANSFER_REQUEST_ID = @TRANSFER_REQUEST_ID

			SELECT TOP 1
				@CLIMA = CASE 
					WHEN  LIN_PROD IN('CONG','PAPA','24C&E') THEN 'FRIO'
					ELSE 'SECO'
				END
			FROM OP_WMS_ALZA.wms.OP_WMS_VIEW_SAE_COST_BY_PRODUCT CBT
			INNER JOIN OP_WMS_ALZA.wms.OP_WMS_MATERIALS M
				ON CBT.CVE_ART = M.ITEM_CODE_ERP COLLATE DATABASE_DEFAULT
			INNER JOIN #DETALLE D
				ON D.MATERIAL_ID = M.MATERIAL_ID

			PRINT @BODEGA_ORIGEN
			PRINT @BODEGA_DESTINO
			PRINT @CLIMA

			SELECT 
				@CVE_CPTO = ConceptoEntrada
			FROM [AlzaWeb].[dbo].[ConceptosTraslados] CT
			WHERE 
				BodegaOrigen = @BODEGA_ORIGEN 
				AND BodegaDestino = @BODEGA_DESTINO
				AND CT.PRODUCT_TYPE = @CLIMA
		--select 
		--		@CVE_CPTO=  CVE_MENT 
	 --from  [SAE70EMPRESA01].[dbo].ALMACENES01 
		--where CVE_ALM=@ALMACEN
	------------------------------------------------------------------------------------------------------------------	
		PRINT 'Obtiene el Almacen @ALMACEN' +  cast(@ALMACEN as varchar);

          PRINT 'Obtuvo ultimo TIPO MOVIMIENTO ' + CAST(@CVE_CPTO AS VARCHAR);

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
                   @COSTO_ARTICULO_DOCUMENTO = [COST],
                   @COSTO_PROMEDO_CALCULADO = [COST],
                   @ORDEN_COMPRA_DOCUMENTO = ISNULL([CVE_DOC],''),
                   @EXISTENCIAS = 0,
                   @EXISTENCIAS_GENERAL = 0
				   --,                   @ALMACEN = [NUM_ALM]
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
                   @COSTO_PROMEDO_CALCULADO = [I].[COSTO_PROM]
                       --= (([I].[EXIST] * [I].[COSTO_PROM]) + (@QTY_DETAIL * @COSTO_ARTICULO_DOCUMENTO))
                       --  / ([I].[EXIST] + @QTY_DETAIL)
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
                   D.COST_BY_MATERIAL [COSTO],
                   0,
                   [BASE_MEASUREMENT_UNIT],
                   0,
                   @EXISTENCIAS_GENERAL + [QTY_CONFIRMED] [EXISTENCIA_GENERAL],
                   @EXISTENCIAS + [QTY_CONFIRMED] [EXISTENCIA],
				   'P',
                   1,
                   GETDATE(),
                   (SELECT TOP 1 CVE_FOLIO  FROM  [SAE70EMPRESA01].[dbo].[MINVE01] M WHERE M.CVE_ART COLLATE DATABASE_DEFAULT =D.[ITEM_CODE_ERP]  COLLATE DATABASE_DEFAULT  AND REFER=@DOCUMENTO_ERP_FORMATEADO AND SIGNO ='-1'),   --@ULTIMO_DOCUMENTO + 1 [CVE_FOLIO],
                   @SIGNO,
                   'S',
                   D.COST_BY_MATERIAL [COSTO_PROM_INI],
                   D.COST_BY_MATERIAL [COSTO_PROM_FIN],
                   D.COST_BY_MATERIAL [COSTO_PROM_GRAL],
                   'S',
                   (SELECT TOP 1 M.NUM_MOV FROM  [SAE70EMPRESA01].[dbo].[MINVE01] M WHERE M.CVE_ART  COLLATE DATABASE_DEFAULT =D.[ITEM_CODE_ERP]  COLLATE DATABASE_DEFAULT  AND REFER=@DOCUMENTO_ERP_FORMATEADO AND SIGNO = '-1')
            FROM [#DETALLE] D
            WHERE [LINE_NUM] = @LINE_NUM_DETAIL;




            -- ------------------------------------------------------------------------------------
            -- actualiza costos
            -- ------------------------------------------------------------------------------------

            UPDATE [SAE70EMPRESA01].[dbo].[INVE01]
            SET [EXIST] = [EXIST] + @QTY_DETAIL,
                [VERSION_SINC] = GETDATE()
                --[ULT_COSTO] = @COSTO_ARTICULO_DOCUMENTO,
                --[COSTO_PROM] = @COSTO_PROMEDO_CALCULADO
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

            PRINT 'termina linea';
            UPDATE [#DETALLE]
            SET [ENVIADO] = 1,
                [NUMERO_MOVIMIENTO] = @ULTIMO_DOCUMENTO_MOVIMIENTO + 1
            WHERE [LINE_NUM] = @LINE_NUM_DETAIL;
        END;


        -- ------------------------------------------------------------------------------------
        --  actualiza encabezados de compra 
        -- ------------------------------------------------------------------------------------
        SELECT @TOTAL_COMPRA = SUM([D].[QTY_CONFIRMED] * [D].[COST]),
               @TOTAL_IMPUESTO_04 = SUM([D].[QTY_CONFIRMED] * [D].[COST] * [D].[IMPU4] / 100),
               @TOTAL_IMPUESTO_03 = SUM([D].[QTY_CONFIRMED] * [D].[COST] * [D].[IMPU3] / 100),
               @TOTAL_IMPUESTO_02 = SUM([D].[QTY_CONFIRMED] * [D].[COST] * [D].[IMPU2] / 100),
               @TOTAL_IMPUESTO_01 = SUM([D].[QTY_CONFIRMED] * [D].[COST] * [D].[IMPU1] / 100),
               @TOTAL_IMPORTE
                   = SUM([D].[QTY_CONFIRMED] * [D].[COST]) + SUM([D].[QTY_CONFIRMED] * [D].[COST] * [D].[IMPU4] / 100)
                     + SUM([D].[QTY_CONFIRMED] * [D].[COST] * [D].[IMPU3] / 100)
                     + SUM([D].[QTY_CONFIRMED] * [D].[COST] * [D].[IMPU2] / 100)
                     + SUM([D].[QTY_CONFIRMED] * [D].[COST] * [D].[IMPU1] / 100)
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
        --INSERT INTO [SAE70EMPRESA01].[dbo].[COMPR01]
        --(
        --    [TIP_DOC],
        --    [CVE_DOC],
        --    [CVE_CLPV],
        --    [STATUS],
        --    [SU_REFER],
        --    [FECHA_DOC],
        --    [FECHA_REC],
        --    [FECHA_PAG],
        --    [CAN_TOT],
        --    [IMP_TOT1],
        --    [IMP_TOT2],
        --    [IMP_TOT3],
        --    [IMP_TOT4],
        --    [DES_TOT],
        --    [DES_FIN],
        --    [OBS_COND],
        --    [CVE_OBS],
        --    [NUM_ALMA],
        --    [ACT_CXP],
        --    [ACT_COI],
        --    [ENLAZADO],
        --    [TIP_DOC_E],
        --    [NUM_MONED],
        --    [TIPCAMB],
        --    [FECHAELAB],
        --    [SERIE],
        --    [FOLIO],
        --    [CTLPOL],
        --    [ESCFD],
        --    [CONTADO],
        --    [BLOQ],
        --    [TOT_IND],
        --    [DES_FIN_PORC],
        --    [DES_TOT_PORC],
        --    [IMPORTE],
        --    [DOC_ANT],
        --    [TIP_DOC_ANT]
        --)
        --SELECT TOP (1)
        --       @TIPO_DOCUMENTO_FOLIO,
        --      ISNULL(@DOCUMENTO_ERP_FORMATEADO, 0),
        --       [E].[CVE_CLPV],
        --       'O',
        --       CAST('SWIFT: ' + CAST([TASK_ID] AS VARCHAR) AS VARCHAR(20)) [SU_REFER],
        --       @FECHA_HOY [FECHA_DOC],
        --       @FECHA_HOY [FECHA_REC],
        --       DATEADD(MONTH, 3, @FECHA_HOY) [FECHA_PAG],
        --       @TOTAL_COMPRA,
        --       @TOTAL_IMPUESTO_01,
        --       @TOTAL_IMPUESTO_02,
        --       @TOTAL_IMPUESTO_03,
        --       @TOTAL_IMPUESTO_04,
        --       [E].[DES_TOT],
        --       [E].[DES_FIN],
        --       [E].[OBS_COND],
        --       @ULTIMO_DOCUMENTO_COMENTARIO + 1,
        --       [E].[NUM_ALMA],
        --       'S' [ACT_CXP],
        --       'N' [ACT_COI],
        --       'O' [ENLAZADO],
        --       'o' [TIP_DOC_E],
        --       [E].[NUM_MONED] [NUM_MONED],
        --       [E].[TIPCAMB],
        --       GETDATE(),
        --       @SERIE_FOLIO,
        --       @ULT_DOC_FOLIO + 1 [FOLIO],
        --       0 [CTLPOL],
        --       'N' [ESCFD],
        --       'N' [CONTADO],
        --       'N' [BLOQ],
        --       [E].[TOT_IND] [TOT_IND],
        --       [E].[DES_FIN] [DES_FIN_PORC],
        --       [E].[DES_TOT_PORC] [DES_TOT_PORC],
        --       @TOTAL_IMPORTE [IMPORTE],
        --       [E].[CVE_DOC] [DOC_ANT],
        --       [E].[TIP_DOC] [TIP_DOC_ANT]
        --FROM [#ENCABEZADO] [E]
        --ORDER BY [E].[DOC_ID] DESC;
        --PRINT 'inserta en compro04';
        --INSERT INTO [SAE70EMPRESA01].[dbo].[COMPR_CLIB01]
        --(
        --    [CLAVE_DOC],
        --    [CAMPLIB1],
        --    [CAMPLIB2],
        --    [CAMPLIB3],
        --    [CAMPLIB4],
        --    [CAMPLIB5],
        --    [CAMPLIB6],
        --    [CAMPLIB7],
        --    [CAMPLIB8],
        --    [CAMPLIB9],
        --    [CAMPLIB10],
        --    [CAMPLIB11],
        --    [CAMPLIB12],
        --    [CAMPLIB13],
        --    [CAMPLIB14]
        --)
        --VALUES
        --(ISNULL(@DOCUMENTO_ERP_FORMATEADO, 0), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

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
                   @COSTO_ARTICULO_DOCUMENTO = [COST],
                   @COSTO_PROMEDO_CALCULADO = [COST]
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
            (@TIPO_DOCUMENTO_FOLIO, ISNULL(@DOCUMENTO_ERP_FORMATEADO, 0), 'A', 'o', @ORDEN_COMPRA_DOCUMENTO, @LINE_NUM_DETAIL,
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
            ('o', @ORDEN_COMPRA_DOCUMENTO, 'S', @TIPO_DOCUMENTO_FOLIO, ISNULL(@DOCUMENTO_ERP_FORMATEADO, 0), @LINE_NUM_DETAIL,
             @LINE_NUM_DETAIL, @QTY_DETAIL);

            --INSERT INTO [SAE70EMPRESA01].[dbo].[PAR_COMPR_CLIB01]
            --(
            --    [CLAVE_DOC],
            --    [NUM_PART],
            --    [CAMPLIB1],
            --    [CAMPLIB2]
            --)
            --VALUES
            --(ISNULL(@DOCUMENTO_ERP_FORMATEADO, 0), @LINE_NUM_DETAIL, NULL, NULL);

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






