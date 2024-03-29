﻿


-- =============================================
-- Autor:				gustavo.garcía
-- Fecha de Creacion: 	11-Feb-2021  
-- Description:			SP que crea documentos de egreso a SAE por transferencia en base a CAI 
/*
-- Ejemplo de Ejecucion:
				EXEC [dbo].[SAE_CREATE_REMISION_BY_TRANSFER] @NEXT_PICKING_DEMAND_HEADER = 22856 -- numeric
				rollback
				Proceso fallido: Violation of PRIMARY KEY constraint 'PK_FACTR01'. Cannot insert duplicate key in object 'dbo.FACTR01'. The duplicate key value is (00000108-00000015).
				Proceso fallido: Cannot insert the value NULL into column 'CVE_DOC', table 'select *from SAE70EMPRESA01.dbo.FACTR01 where CVE_DOC like '%00000108-000000%''; column does not allow nulls. INSERT fails.
				
*/
-- =============================================
CREATE PROCEDURE [dbo].[SAE_CREATE_REMISION_BY_TRANSFER19062021]
(@NEXT_PICKING_DEMAND_HEADER NUMERIC)
AS
BEGIN
    SET NOCOUNT ON;
    --

    -- ------------------------------------------------------------------------------------
    -- Declaramos variables
    -- ------------------------------------------------------------------------------------
    DECLARE @ULTIMO_DOCUMENTO INT = 0,
			@CVE_FOLIO INT = 32,
			@CVE_ULTIMO_DOCUMENTO INT = 0,
            @TIPO_DOCUMENTO_FOLIO VARCHAR(1) = 'M',--Salida de inventario
            @SERIE_FOLIO VARCHAR(10) = '000001-08-',
            @ULT_DOC_FOLIO INT,
            @CODIGO_CLIENTE_SAE VARCHAR(10),
            @NOMBRE_CLIENTE_SAE VARCHAR(100),
            @TIPO_CLIENTE_SAE VARCHAR(50),
            @FOLIO_DESDE INT,
            @NUM_MONEDA INT = 1,
            @TIPO_CAMBIO INT = 1,
            @TABLA_DOCUMENTO_COMENTARIO INT = 56,
            @ULTIMO_DOCUMENTO_COMENTARIO INT = 0,
            @FECHA_SYNC DATETIME = GETDATE(),
            @DOCUMENTO_ERP_FORMATEADO VARCHAR(25),
            @TOTAL_DOCUMENTO FLOAT,
            @TOTAL_IMPORTE FLOAT,
            @TOTAL_IMPUESTO_01 FLOAT,
            @TOTAL_IMPUESTO_02 FLOAT,
            @TOTAL_IMPUESTO_03 FLOAT,
            @TOTAL_IMPUESTO_04 FLOAT,
            @MES_ACTUAL DATETIME = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0),
            @FECHA_HOY DATETIME = DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0),
            @ORDEN_VENTA_DOCUMENTO VARCHAR(50),
            @COMENTARIO VARCHAR(200),
            @USUARIO_OPERA SMALLINT = 477,
            @USUARIO_OPERA_NOMBRE VARCHAR(50) = 'wms',
            @COMENTARIO_PEDIDO VARCHAR(255) = '',
			@DEMAND_TYPE VARCHAR(255) = 'TRANSFER_REQUEST',--tipo de demanda de transferencias
			@CAI VARCHAR(100),
			@RANGO_INICIAL FLOAT,
			@RANGO_FINAL FLOAT,
			@FECHA_VENCIMIENTO DATE,
			@IDCAI INT =0



    --VARIABLES DETALLE
    DECLARE @ERP_MATERIAL_CODE VARCHAR(25),
            @MATERIAL_ID_DETAIL VARCHAR(25),
            @LINE_NUM_DETAIL INT,
            @QTY_DETAIL NUMERIC(18, 6),
            @CVE_CPTO INT = 51,
            @SIGNO SMALLINT,
            @TIPO_MOV VARCHAR(1),
            @TABLA_DOCUMENTO_MOVIMIENTO INT = 44,
            @ULTIMO_DOCUMENTO_MOVIMIENTO INT = 0,
            @TABLA_DOCUMENTO_BITACORA INT = 62,
            @ULTIMO_DOCUMENTO_BITACORA INT = 0,
            @COSTO_ARTICULO_DOCUMENTO FLOAT,
            @COSTO_PROMEDO_CALCULADO FLOAT,
            @COSTO_PROMEDIO_ANTERIOR FLOAT,
            @EXISTENCIAS FLOAT = 0,
            @EXISTENCIAS_GENERAL FLOAT = 0,
            @EXISTENCIAS_MULTI FLOAT = 0,
            @EXISTENCIAS_GENERAL_MULTI FLOAT = 0,
            @CONTADOR_LINEA INT = 0,
            @ALMACEN INT = 0;

    BEGIN TRY
        BEGIN TRANSACTION;
        -- ------------------------------------------------------------------------------------
        -- obtiene datos de Wms
        -- ------------------------------------------------------------------------------------


        SELECT [D].[PICKING_DEMAND_DETAIL_ID],
               [D].[PICKING_DEMAND_HEADER_ID],
               [D].[MATERIAL_ID],
               [D].[QTY],
               [D].[LINE_NUM],
               [D].[ERP_OBJECT_TYPE],
               [D].[PRICE],
               [D].[WAS_IMPLODED],
               [D].[QTY_IMPLODED],
               [D].[MASTER_ID_MATERIAL],
               [D].[MATERIAL_OWNER],
               [D].[ATTEMPTED_WITH_ERROR],
               [D].[IS_POSTED_ERP],
               [D].[POSTED_ERP],
               [D].[ERP_REFERENCE],
               [D].[POSTED_STATUS],
               [D].[POSTED_RESPONSE],
               [D].[INNER_SALE_STATUS],
               [D].[INNER_SALE_RESPONSE],
               [D].[TONE],
               [D].[CALIBER],
               [D].[DISCOUNT],
               [D].[IS_BONUS],
               [D].[DISCOUNT_TYPE],
               [D].[UNIT_MEASUREMENT],
               [D].[STATUS_CODE],
               [DF].[CVE_DOC],
               [DF].[NUM_PAR],
               [DF].[CVE_ART],
               [DF].[CANT],
               [DF].[PXS],
               [DF].[PREC],
               [DF].[COST],
               [DF].[IMPU1],
               [DF].[IMPU2],
               [DF].[IMPU3],
               [DF].[IMPU4],
               [DF].[IMP1APLA],
               [DF].[IMP2APLA],
               [DF].[IMP3APLA],
               [DF].[IMP4APLA],
               [DF].[TOTIMP1],
               [DF].[TOTIMP2],
               [DF].[TOTIMP3],
               [DF].[TOTIMP4],
               [DF].[DESC1],
               [DF].[DESC2],
               [DF].[DESC3],
               [DF].[COMI],
               [DF].[APAR],
               [DF].[ACT_INV],
               ISNULL([DF].[NUM_ALM],(SELECT ERP_WAREHOUSE AS [NUM_ALM] FROM  [OP_WMS_ALZA].[wms].OP_WMS_WAREHOUSES WHERE WAREHOUSE_ID=H.CODE_WAREHOUSE)) [NUM_ALM],
               [DF].[POLIT_APLI],
               [DF].[TIP_CAM],
               [DF].[UNI_VENTA],
               [DF].[TIPO_PROD],
               [DF].[CVE_OBS],
               [DF].[REG_SERIE],
               [DF].[E_LTPD],
               [DF].[TIPO_ELEM],
               [DF].[NUM_MOV],
               [DF].[TOT_PARTIDA],
               [DF].[IMPRIMIR],
               [DF].[UUID],
               [DF].[VERSION_SINC],
               [DF].[MAN_IEPS],
               [DF].[APL_MAN_IMP],
               [DF].[CUOTA_IEPS],
               [DF].[APL_MAN_IEPS],
               [DF].[MTO_PORC],
               [DF].[MTO_CUOTA],
               [DF].[CVE_ESQ],
               [DF].[DESCR_ART],
               [M].[MATERIAL_NAME],
               [M].[ITEM_CODE_ERP],
               [M].[BASE_MEASUREMENT_UNIT],
               CAST(0 AS INT) [ENVIADO],
               CAST(0 AS INT) [NUMERO_MOVIMIENTO]
        INTO [#DETALLE]
        FROM [OP_WMS_ALZA].[wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [D]
            INNER JOIN [OP_WMS_ALZA].[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [H]
                ON [H].[PICKING_DEMAND_HEADER_ID] = [D].[PICKING_DEMAND_HEADER_ID]
            INNER JOIN [OP_WMS_ALZA].[wms].[OP_WMS_MATERIALS] [M]
                ON [M].[MATERIAL_ID] = [D].[MATERIAL_ID]
            LEFT JOIN [SAE70EMPRESA01].[dbo].[PAR_FACTP01] [DF]
                ON LTRIM(RTRIM([DF].[CVE_DOC])) COLLATE DATABASE_DEFAULT = [H].[DOC_NUM] COLLATE DATABASE_DEFAULT
                   AND [DF].[NUM_PAR] = [D].[LINE_NUM]
        WHERE [H].[PICKING_DEMAND_HEADER_ID] = @NEXT_PICKING_DEMAND_HEADER
              AND [H].[IS_AUTHORIZED] > 0
              AND [D].[QTY] > 0;

		

        SELECT [H].[PICKING_DEMAND_HEADER_ID],
               [H].[DOC_NUM],
               [H].[CLIENT_CODE],
               [H].[CODE_ROUTE],
               [H].[CODE_SELLER],
               [H].[TOTAL_AMOUNT],
               [H].[SERIAL_NUMBER],
               [H].[DOC_NUM_SEQUENCE],
               [H].[EXTERNAL_SOURCE_ID],
               [H].[IS_FROM_ERP],
               [H].[IS_FROM_SONDA],
               [H].[LAST_UPDATE],
               [H].[LAST_UPDATE_BY],
               [H].[IS_COMPLETED],
               [H].[WAVE_PICKING_ID],
               [H].[CODE_WAREHOUSE],
               [H].[IS_AUTHORIZED],
               [H].[ATTEMPTED_WITH_ERROR],
               [H].[IS_POSTED_ERP],
               [H].[POSTED_ERP],
               [H].[POSTED_RESPONSE],
               [H].[ERP_REFERENCE],
               [H].[CLIENT_NAME],
               [H].[CREATED_DATE],
               [H].[ERP_REFERENCE_DOC_NUM],
               [H].[DOC_ENTRY],
               [H].[IS_CONSOLIDATED],
               [H].[PRIORITY],
               [H].[HAS_MASTERPACK],
               [H].[POSTED_STATUS],
               [H].[OWNER],
               [H].[CLIENT_OWNER],
               [H].[MASTER_ID_SELLER],
               [H].[SELLER_OWNER],
               [H].[SOURCE_TYPE],
               [H].[INNER_SALE_STATUS],
               [H].[INNER_SALE_RESPONSE],
               [H].[DEMAND_TYPE],
               [H].[TRANSFER_REQUEST_ID],
               [H].[ADDRESS_CUSTOMER],
               [H].[STATE_CODE],
               [H].[DISCOUNT],
               [H].[UPDATED_VEHICLE],
               [H].[UPDATED_VEHICLE_RESPONSE],
               [H].[UPDATED_VEHICLE_ATTEMPTED_WITH_ERROR],
               [H].[DELIVERY_NOTE_INVOICE],
               [H].[DEMAND_SEQUENCE],
               [H].[IS_CANCELED_FROM_SONDA_SD],
               [H].[TYPE_DEMAND_CODE],
               [H].[TYPE_DEMAND_NAME],
               [H].[IS_FOR_DELIVERY_IMMEDIATE],
               [H].[DEMAND_DELIVERY_DATE],
               [H].[IS_SENDING],
               [H].[LAST_UPDATE_IS_SENDING],
               [H].[PROJECT],
               [H].[DISPATCH_LICENSE_EXIT_DATETIME],
               [H].[DISPATCH_LICENSE_EXIT_BY],
               [FACT].[TIP_DOC],
               [FACT].[CVE_DOC],
               [FACT].[CVE_CLPV],
               [FACT].[STATUS],
               [FACT].[DAT_MOSTR],
               [FACT].[CVE_VEND],
               [FACT].[CVE_PEDI],
               [FACT].[FECHA_DOC],
               [FACT].[FECHA_ENT],
               [FACT].[FECHA_VEN],
               [FACT].[FECHA_CANCELA],
               [FACT].[CAN_TOT],
               [FACT].[IMP_TOT1],
               [FACT].[IMP_TOT2],
               [FACT].[IMP_TOT3],
               [FACT].[IMP_TOT4],
               [FACT].[DES_TOT],
               [FACT].[DES_FIN],
               [FACT].[COM_TOT],
               [FACT].[CONDICION],
               [FACT].[CVE_OBS],
               [FACT].[NUM_ALMA],
               [FACT].[ACT_CXC],
               [FACT].[ACT_COI],
               [FACT].[ENLAZADO],
               [FACT].[TIP_DOC_E],
               [FACT].[NUM_MONED],
               [FACT].[TIPCAMB],
               [FACT].[NUM_PAGOS],
               [FACT].[FECHAELAB],
               [FACT].[PRIMERPAGO],
               [FACT].[RFC],
               [FACT].[CTLPOL],
               [FACT].[ESCFD],
               [FACT].[AUTORIZA],
               [FACT].[SERIE],
               [FACT].[FOLIO],
               [FACT].[AUTOANIO],
               [FACT].[DAT_ENVIO],
               [FACT].[CONTADO],
               [FACT].[CVE_BITA],
               [FACT].[BLOQ],
               [FACT].[FORMAENVIO],
               [FACT].[DES_FIN_PORC],
               [FACT].[DES_TOT_PORC],
               [FACT].[IMPORTE],
               [FACT].[COM_TOT_PORC],
               [FACT].[METODODEPAGO],
               [FACT].[NUMCTAPAGO],
               [FACT].[TIP_DOC_ANT],
               [FACT].[DOC_ANT],
               [FACT].[TIP_DOC_SIG],
               [FACT].[DOC_SIG],
               [FACT].[UUID],
               [FACT].[VERSION_SINC],
               [FACT].[FORMADEPAGOSAT],
               [FACT].[USO_CFDI],
               [CLIE].[NOMBRE] [NOMBRE_CLIENTE],
               [CLIE].[TIPO_EMPRESA] [TIPO_EMPRESA_CLIENTE],
               [VEND].[NOMBRE] [NOMBRE_VENDEDOR],
               [C].[STR_OBS] [COMENTARIO_PEDIDO]
        INTO [#ENCABEZADO]
        FROM [OP_WMS_ALZA].[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [H]
            LEFT JOIN [SAE70EMPRESA01].[dbo].[FACTP01] [FACT]
                ON LTRIM(RTRIM([FACT].[CVE_DOC])) COLLATE DATABASE_DEFAULT = [H].[DOC_NUM] COLLATE DATABASE_DEFAULT
            LEFT JOIN [SAE70EMPRESA01].[dbo].[FACTP_CLIB01] [FACTCLIB]
                ON ([FACT].[CVE_DOC] = [FACTCLIB].[CLAVE_DOC])
            LEFT JOIN [SAE70EMPRESA01].[dbo].[CLIE01] [CLIE]
                ON [CLIE].[CLAVE] = [FACT].[CVE_CLPV]
            LEFT JOIN [SAE70EMPRESA01].[dbo].[VEND01] [VEND]
                ON ([FACT].[CVE_VEND] = [VEND].[CVE_VEND])
            LEFT JOIN [SAE70EMPRESA01].[dbo].[OBS_DOCF01] [C]
                ON [C].[CVE_OBS] = [FACT].[CVE_OBS]
        WHERE [H].[PICKING_DEMAND_HEADER_ID] = @NEXT_PICKING_DEMAND_HEADER
              AND [H].[IS_AUTHORIZED] > 0;


        -- ------------------------------------------------------------------------------------
        -- obtener variables de CLIENTE
        -- ------------------------------------------------------------------------------------

        SELECT TOP 1
               @CODIGO_CLIENTE_SAE = [H].[CVE_CLPV],
               @NOMBRE_CLIENTE_SAE = [H].[NOMBRE_CLIENTE],
               @TIPO_CLIENTE_SAE = [H].[TIPO_EMPRESA_CLIENTE]
        FROM [#ENCABEZADO] [H];

		--TODO: validar CAI fechas

		  --DECLARE @pRESULT VARCHAR(200)
    --                = 'La cantidad es mayor a la existencias de los siguientes productos: ' + @ERP_MATERIAL_CODE;
    --            RAISERROR(@pRESULT, 16, 1);

		--oBTIENE ALMACEN ORIGEN
		SELECT @ALMACEN=ERP_WAREHOUSE 
		FROM  [OP_WMS_ALZA].[wms].OP_WMS_WAREHOUSES 
			INNER JOIN [OP_WMS_ALZA].[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH] ON ( WAREHOUSE_ID=[PDH].CODE_WAREHOUSE)
		WHERE PICKING_DEMAND_HEADER_ID = @NEXT_PICKING_DEMAND_HEADER

        -- ------------------------------------------------------------------------------------
        -- Obtiene ultimo documento
        -- ------------------------------------------------------------------------------------
        SELECT @ULTIMO_DOCUMENTO = NUltimoDocumento,
				@ULT_DOC_FOLIO= NUltimoDocumento,
		        @FOLIO_DESDE = RangoInicial,
				@FECHA_VENCIMIENTO=FechaLimite,
				@CAI=CAI,
				@RANGO_INICIAL=RangoInicial,
				@RANGO_FINAL=RangoFinal,
				@DOCUMENTO_ERP_FORMATEADO = [SERIE] + [dbo].[FUNC_ADD_CHARS](NUltimoDocumento + 1 , '0', 8),
				@SERIE_FOLIO = [SERIE],
				@IDCAI=[IdCAI]
        FROM AlzaWeb.dbo.CAI
        WHERE Bodega = @ALMACEN 
		and Estado='A'
		AND cast(getDate() As Date) <= FechaLimite
		AND NUltimoDocumento >= RangoInicial - 1 and NUltimoDocumento < RangoFinal;


		PRINT 'Obtuvo @DOCUMENTO_ERP_FORMATEADO' + CAST(@ULTIMO_DOCUMENTO AS VARCHAR);

		if @DOCUMENTO_ERP_FORMATEADO is null
			begin
			
				PRINT 'Obtuvo el CAI @DOCUMENTO_ERP_FORMATEADO' + CAST(@ULTIMO_DOCUMENTO AS VARCHAR);

			 SELECT -1 AS [Resultado],
               'Proceso fallido: ' + 'Error, Validar rangos autorizados y fecha limite de emision, comuniquese con el administrador' [Mensaje],
               0 [Codigo],
               '0' [DbData]
			   COMMIT
			   return;
			end
		
		

        PRINT 'Obtuvo ultimo documento @ULTIMO_DOCUMENTO' + CAST(@ULTIMO_DOCUMENTO AS VARCHAR);

        UPDATE AlzaWeb.dbo.CAI
        SET NUltimoDocumento = @ULTIMO_DOCUMENTO + 1,FechaUltimoDocumento = GETDATE()
        WHERE Bodega = @ALMACEN AND IdCAI=@IDCAI;	
		
		--Obtiene tipo de movimiento

		select 
				@CVE_CPTO=  CVE_MSAL 
		from  [SAE70EMPRESA01].[dbo].ALMACENES01 
		where CVE_ALM=@ALMACEN

        SELECT @ULTIMO_DOCUMENTO_COMENTARIO = [ULT_CVE]
        FROM [SAE70EMPRESA01].[dbo].[TBLCONTROL01]
        WHERE [ID_TABLA] = @TABLA_DOCUMENTO_COMENTARIO;

        UPDATE [SAE70EMPRESA01].[dbo].[TBLCONTROL01]
        SET [ULT_CVE] = @ULTIMO_DOCUMENTO_COMENTARIO + 1
        WHERE [ID_TABLA] = @TABLA_DOCUMENTO_COMENTARIO
              AND [ULT_CVE] = @ULTIMO_DOCUMENTO_COMENTARIO;

        SELECT TOP (1)
               @COMENTARIO
                   = ISNULL([e].[COMENTARIO_PEDIDO], '') COLLATE DATABASE_DEFAULT + '   ' + 'Documento: '
                     + ISNULL(@DOCUMENTO_ERP_FORMATEADO, ' ') + ' Tarea Swift: '
                     + CAST([e].[WAVE_PICKING_ID] AS VARCHAR(18)) + ' Operada por: ' + ISNULL([t].[TASK_ASSIGNEDTO], ' ')
                     + ' Confirmada por: ' + ISNULL([t].[TASK_OWNER], ' ')
        FROM [#ENCABEZADO] [e]
            INNER JOIN [OP_WMS_ALZA].[wms].[OP_WMS_TASK_LIST] [t]
                ON [e].[WAVE_PICKING_ID] = [t].[WAVE_PICKING_ID];

 PRINT 'Obtuvo Existencias 5'

       -- PRINT 'Comentario ' + CAST(@COMENTARIO AS VARCHAR(250));
        INSERT INTO [SAE70EMPRESA01].[dbo].[OBS_DOCF01]
        (
            [CVE_OBS],
            [STR_OBS]
        )
        VALUES
        (@ULTIMO_DOCUMENTO_COMENTARIO + 1, @COMENTARIO);
        PRINT 'TAMAÑO COMENTARIO: ' + CAST(LEN(@COMENTARIO) AS VARCHAR(100));
		 PRINT 'Obtuvo Existencias 6'
       
	     -- ------------------------------------------------------------------------------------
        -- Obtiene ultimo documento
        -- ------------------------------------------------------------------------------------

        SELECT @CVE_ULTIMO_DOCUMENTO = [ULT_CVE]
        FROM [SAE70EMPRESA01].[dbo].[TBLCONTROL01]
        WHERE [ID_TABLA] = @CVE_FOLIO;

        PRINT 'Obtuvo ultimo documento @ULTIMO_DOCUMENTO_32' + CAST(@CVE_FOLIO AS VARCHAR);
        UPDATE [SAE70EMPRESA01].[dbo].[TBLCONTROL01]
        SET [ULT_CVE] = @CVE_ULTIMO_DOCUMENTO + 1
        WHERE [ID_TABLA] = @CVE_FOLIO
              AND [ULT_CVE] = @CVE_ULTIMO_DOCUMENTO;

	------------------------------------------------------------------------------   
	   
	   WHILE EXISTS (SELECT TOP 1 1 FROM [#DETALLE] WHERE [ENVIADO] = 0)
        BEGIN
			 PRINT 'Obtuvo Existencias CICLO'
            SELECT TOP (1)
                   @ERP_MATERIAL_CODE = [ITEM_CODE_ERP],
                   @MATERIAL_ID_DETAIL = [MATERIAL_ID],
                   @LINE_NUM_DETAIL = [LINE_NUM],
                   @QTY_DETAIL = [QTY],
                   @ORDEN_VENTA_DOCUMENTO = [CVE_DOC],
                   @EXISTENCIAS = 0,
                   @EXISTENCIAS_GENERAL = 0,
                   @ALMACEN = [NUM_ALM]
            FROM [#DETALLE]
            WHERE [ENVIADO] = 0
            ORDER BY [LINE_NUM] ASC;
            PRINT 'Ciclo detalle line: ' + CAST(@LINE_NUM_DETAIL AS VARCHAR);
	


            IF EXISTS
            (
                SELECT TOP 1
                       1
                FROM
                (
                    SELECT [INVE].[CVE_ART],
                           [MULT].[EXIST]
                    FROM [SAE70EMPRESA01].[dbo].[INVE01] [INVE]
                        LEFT JOIN [SAE70EMPRESA01].[dbo].[MULT01] [MULT]
                            ON [INVE].[CVE_ART] = [MULT].[CVE_ART]
                    WHERE [MULT].[CVE_ALM] = @ALMACEN
                          AND ([INVE].[CVE_ART] = @ERP_MATERIAL_CODE)
                    UNION ALL
                    SELECT [INVE].[CVE_ART],
                           [MULT].[EXIST]
                    FROM [SAE70EMPRESA01].[dbo].[INVE01] [INVE]
                        LEFT JOIN [SAE70EMPRESA01].[dbo].[CVES_ALTER01] [CA]
                            ON [INVE].[CVE_ART] = [CA].[CVE_ART]
                               AND
                               (
                                   [CA].[TIPO] = 'C'
                                   OR [CA].[TIPO] = 'N'
                               )
                               AND
                               (
                                   [CA].[CVE_CLPV] = @CODIGO_CLIENTE_SAE
                                   OR [CA].[CVE_CLPV] = ''
                                   OR [CA].[CVE_CLPV] IS NULL
                               )
                        LEFT JOIN [SAE70EMPRESA01].[dbo].[MULT01] [MULT]
                            ON [INVE].[CVE_ART] = [MULT].[CVE_ART]
                    WHERE [MULT].[CVE_ALM] = @ALMACEN
                          AND [CA].[CVE_ALTER] = @ERP_MATERIAL_CODE
                ) AS [T]
                GROUP BY [T].[CVE_ART]
                HAVING SUM([EXIST]) <
                (
                    SELECT SUM(@QTY_DETAIL)
                    FROM [#DETALLE]
                    WHERE [CVE_ART] = @ERP_MATERIAL_CODE
                )
            )
            BEGIN
                DECLARE @pRESULT VARCHAR(200)
                    = 'La cantidad es mayor a la existencias de los siguientes productos: ' + @ERP_MATERIAL_CODE;
                RAISERROR(@pRESULT, 16, 1);
            END;



            UPDATE [SAE70EMPRESA01].[dbo].[INVE01]
            SET [PEND_SURT] = (CASE
                                   WHEN [PEND_SURT] + (@QTY_DETAIL * -1) < 0 THEN
                                       0
                                   WHEN [PEND_SURT] + (@QTY_DETAIL * -1) >= 0 THEN
                                       [PEND_SURT] + (@QTY_DETAIL * -1)
                                   ELSE
                                       0
                               END
                              ),
                [VERSION_SINC] = @FECHA_SYNC
            WHERE [CVE_ART] = @ERP_MATERIAL_CODE;




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
                   @COSTO_PROMEDIO_ANTERIOR = [I].[COSTO_PROM]
           FROM [SAE70EMPRESA01].[dbo].[INVE01] [I]
                LEFT JOIN [SAE70EMPRESA01].[dbo].[MULT01] [M]
                    ON [M].[CVE_ART] = [I].[CVE_ART]
                       AND [M].[CVE_ALM] = @ALMACEN
            WHERE [I].[CVE_ART] =@ERP_MATERIAL_CODE;


            PRINT 'Obtuvo Existencias ' + @ERP_MATERIAL_CODE + ' ' + CAST(@EXISTENCIAS AS VARCHAR);


	  
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
                   [NUM_ALM],
                   @ULTIMO_DOCUMENTO_MOVIMIENTO + 1,
                   @CVE_CPTO,
                   @FECHA_HOY,
                   @TIPO_DOCUMENTO_FOLIO,
                   @DOCUMENTO_ERP_FORMATEADO,
                   @CODIGO_CLIENTE_SAE,
                   [H].[CVE_VEND],
                   [D].[QTY],
                   0,
                   0,
                   @COSTO_PROMEDIO_ANTERIOR [COSTO],
                   0,
                   [D].[BASE_MEASUREMENT_UNIT],
                   0,
                   @EXISTENCIAS_GENERAL - [D].[QTY] [EXISTENCIA_GENERAL],
                   @EXISTENCIAS - [D].[QTY] [EXISTENCIA],
				   'P',
                   1,
                   @FECHA_SYNC,
                   @CVE_ULTIMO_DOCUMENTO  [CVE_FOLIO],
                   @SIGNO,
                   'S',
                   @COSTO_PROMEDIO_ANTERIOR [COSTO_PROM_INI],
                   @COSTO_PROMEDIO_ANTERIOR [COSTO_PROM_FIN],
                   @COSTO_PROMEDIO_ANTERIOR [COSTO_PROM_GRAL],
                   'S',
                   0
            FROM [#DETALLE] [D]
                INNER JOIN [#ENCABEZADO] [H]
                    ON [D].[PICKING_DEMAND_HEADER_ID] = [H].[PICKING_DEMAND_HEADER_ID]
            WHERE [LINE_NUM] = @LINE_NUM_DETAIL;


		
			

            -- ------------------------------------------------------------------------------------
            -- actualiza existencias
            -- ------------------------------------------------------------------------------------

            UPDATE [SAE70EMPRESA01].[dbo].[INVE01]
            SET [EXIST] = [EXIST] - @QTY_DETAIL,
                [VERSION_SINC] = @FECHA_SYNC
            WHERE [CVE_ART] = @ERP_MATERIAL_CODE;


            UPDATE [SAE70EMPRESA01].[dbo].[MULT01]
            SET [EXIST] = [EXIST] - @QTY_DETAIL,
                [VERSION_SINC] = @FECHA_SYNC
            WHERE [CVE_ART] = @ERP_MATERIAL_CODE
                  AND [CVE_ALM] = @ALMACEN;


            PRINT 'termina linea';
            UPDATE [#DETALLE]
            SET [ENVIADO] = 1,
                [NUMERO_MOVIMIENTO] = @ULTIMO_DOCUMENTO_MOVIMIENTO + 1
            WHERE [LINE_NUM] = @LINE_NUM_DETAIL;
        END;
		            PRINT 'termina CICLO';


		             PRINT 'termina 1';
        -- ------------------------------------------------------------------------------------
        --  actualiza encabezados de compra 
        -- ------------------------------------------------------------------------------------
        SELECT @TOTAL_DOCUMENTO = SUM([D].[QTY] * [D].[PRICE]),
               @TOTAL_IMPUESTO_04 = SUM([D].[QTY] * [D].[PRICE] * [D].[IMPU4] / 100),
               @TOTAL_IMPUESTO_03 = SUM([D].[QTY] * [D].[PRICE] * [D].[IMPU3] / 100),
               @TOTAL_IMPUESTO_02 = SUM([D].[QTY] * [D].[PRICE] * [D].[IMPU2] / 100),
               @TOTAL_IMPUESTO_01 = SUM([D].[QTY] * [D].[PRICE] * [D].[IMPU1] / 100),
               @TOTAL_IMPORTE
                   = SUM([D].[QTY] * [D].[PRICE]) + SUM([D].[QTY] * [D].[PRICE] * [D].[IMPU4] / 100)
                     + SUM([D].[QTY] * [D].[PRICE] * [D].[IMPU3] / 100)
                     + SUM([D].[QTY] * [D].[PRICE] * [D].[IMPU2] / 100)
                     + SUM([D].[QTY] * [D].[PRICE] * [D].[IMPU1] / 100)
        FROM [#DETALLE] [D];



        UPDATE [#DETALLE]
        SET [ENVIADO] = 0;
        SELECT @CONTADOR_LINEA = 0;
		PRINT 'termina 3';
        WHILE EXISTS (SELECT TOP (1) 1 FROM [#DETALLE] WHERE [ENVIADO] = 0)
        BEGIN
            SELECT TOP (1)
                   @ERP_MATERIAL_CODE = [ITEM_CODE_ERP],
                   @MATERIAL_ID_DETAIL = [MATERIAL_ID],
                   @LINE_NUM_DETAIL = [LINE_NUM],
                   @QTY_DETAIL = [QTY],
                   @COSTO_ARTICULO_DOCUMENTO = [PREC],
                   @COSTO_PROMEDO_CALCULADO = [COST],
                   @ORDEN_VENTA_DOCUMENTO = [CVE_DOC]
            FROM [#DETALLE]
            WHERE [ENVIADO] = 0
            ORDER BY [LINE_NUM] ASC;


            UPDATE [SAE70EMPRESA01].[dbo].[INVE01]
            SET [VTAS_ANL_C] = [VTAS_ANL_C] + @QTY_DETAIL,
                [VTAS_ANL_M] = [VTAS_ANL_M] + (@COSTO_ARTICULO_DOCUMENTO * @QTY_DETAIL),
                [FCH_ULTVTA] = @FECHA_HOY,
                [VERSION_SINC] = @FECHA_SYNC
            WHERE [CVE_ART] = @ERP_MATERIAL_CODE;

            SELECT @CONTADOR_LINEA = @CONTADOR_LINEA + 1;

            UPDATE [#DETALLE]
            SET [ENVIADO] = 1
            WHERE [LINE_NUM] = @LINE_NUM_DETAIL;
        END;
					PRINT 'termina 666';
        

		--actualiza campos del CAI en el header
		UPDATE [OP_WMS_ALZA].[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] 
		SET CAI=@CAI,
			CAI_SERIE=@SERIE_FOLIO,
			CAI_NUMERO=@ULTIMO_DOCUMENTO+1,
			CAI_RANGO_INICIAL = @RANGO_INICIAL,
			CAI_RANGO_FINAL= @RANGO_FINAL,
			CAI_FECHA_VENCIMIENTO=@FECHA_VENCIMIENTO
		WHERE PICKING_DEMAND_HEADER_ID = @NEXT_PICKING_DEMAND_HEADER

		--Actualiza campos de CAI en manifiesto de carga 
		UPDATE MH
		SET MH.CAI=@CAI,
		MH.CAI_SERIE=@SERIE_FOLIO,
		MH.CAI_NUMERO=@ULTIMO_DOCUMENTO+1,
		MH.CAI_RANGO_INICIAL = @RANGO_INICIAL,
		MH.CAI_RANGO_FINAL= @RANGO_FINAL,
		MH.CAI_FECHA_VENCIMIENTO=@FECHA_VENCIMIENTO
		FROM [OP_WMS_ALZA].wms.[OP_WMS_MANIFEST_HEADER] MH
		INNER JOIN [OP_WMS_ALZA].wms.[OP_WMS_NEXT_PICKING_DEMAND_HEADER] PDH ON (PDH.TRANSFER_REQUEST_ID = MH.TRANSFER_REQUEST_ID)
		WHERE PICKING_DEMAND_HEADER_ID = @NEXT_PICKING_DEMAND_HEADER


		COMMIT;
        DECLARE @RESPONSE VARCHAR(500) = 'Proceso exitoso, Recepción: GG ' + @DOCUMENTO_ERP_FORMATEADO;

        PRINT 'Actualizó Swift ';


        
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