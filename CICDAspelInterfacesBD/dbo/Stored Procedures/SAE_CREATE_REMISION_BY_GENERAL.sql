


-- =============================================
-- Autor:				gustavo.garcía
-- Fecha de Creacion: 	11-Feb-2021  
-- Description:			SP que crea documentos de egreso a SAE por transferencia en base a CAI 

-- Autor:				Brandon Sicay
-- Fecha de Creacion: 	08-Jun-2022  
-- Description:			Condicion de conceptos para considerar mezclas

-- Autor:				Brandon Sicay
-- Fecha de Creacion: 	22-Jun-2022  
-- Description:			Condicion cuando no hay existencias 

/*
-- Ejemplo de Ejecucion:
				EXEC [dbo].[SAE_CREATE_REMISION_BY_GENERAL] @NEXT_PICKING_DEMAND_HEADER = 222 -- numeric
				rollback
				Proceso fallido: Violation of PRIMARY KEY constraint 'PK_FACTR01'. Cannot insert duplicate key in object 'dbo.FACTR01'. The duplicate key value is (00000108-00000015).
				Proceso fallido: Cannot insert the value NULL into column 'CVE_DOC', table 'select *from SAE70EMPRESA01.dbo.FACTR01 where CVE_DOC like '%00000108-000000%''; column does not allow nulls. INSERT fails.
				
*/
-- =============================================
CREATE PROCEDURE [dbo].[SAE_CREATE_REMISION_BY_GENERAL]
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
            @SERIE_FOLIO VARCHAR(10) = 'WMS',
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
			@DEMAND_TYPE VARCHAR(255) = '',--tipo de demanda de transferencias
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


        SELECT min([D].SERIAL_NUMBER) SERIAL_NUMBER,
               [H].[PICKING_ERP_DOCUMENT_ID],
               [D].[MATERIAL_ID],
               sum([D].QUANTITY_ASSIGNED - D.QUANTITY_PENDING )QTY,
               [D].[TONE],
               [D].[CALIBER],
               [D].[STATUS_CODE],
               H.CODE_WAREHOUSE [NUM_ALM],
               [M].[MATERIAL_NAME],
               [M].[ITEM_CODE_ERP],
               [M].[BASE_MEASUREMENT_UNIT],
               CAST(0 AS INT) [ENVIADO],
               CAST(0 AS INT) [NUMERO_MOVIMIENTO]
        INTO [#DETALLE]
        FROM [OP_WMS_ALZA].[wms].[OP_WMS_TASK_LIST] [D]
            INNER JOIN [OP_WMS_ALZA].[wms].[OP_WMS_PICKING_ERP_DOCUMENT] [H]
                ON [H].WAVE_PICKING_ID = [D].WAVE_PICKING_ID
            INNER JOIN [OP_WMS_ALZA].[wms].[OP_WMS_MATERIALS] [M]
                ON [M].[MATERIAL_ID] = [D].[MATERIAL_ID]
        WHERE [H].[PICKING_ERP_DOCUMENT_ID] = @NEXT_PICKING_DEMAND_HEADER
              --AND [H].[IS_AUTHORIZED] > 0
              AND  [D].QUANTITY_ASSIGNED - D.QUANTITY_PENDING > 0
		GROUP BY [D].[MATERIAL_ID],
				[H].[PICKING_ERP_DOCUMENT_ID],
				 [D].[TONE],
				 [D].[CALIBER],
				 [D].[STATUS_CODE],
				 [M].[MATERIAL_NAME],
               [M].[ITEM_CODE_ERP],
               [M].[BASE_MEASUREMENT_UNIT],H.CODE_WAREHOUSE

			  

		

        SELECT 
               [H].[PICKING_ERP_DOCUMENT_ID],
			   [H].[WAVE_PICKING_ID],
               [H].[CODE_WAREHOUSE],
               [H].[IS_AUTHORIZED],
               [H].[ATTEMPTED_WITH_ERROR],
               [H].[IS_POSTED_ERP],
               [H].[POSTED_ERP],
               [H].[POSTED_RESPONSE],
               [H].[ERP_REFERENCE],
               [H].[CREATED_DATE],
               [H].[ERP_REFERENCE_DOC_NUM]
        INTO [#ENCABEZADO]
        FROM [OP_WMS_ALZA].[wms].[OP_WMS_PICKING_ERP_DOCUMENT] [H]
        
        WHERE [H].[PICKING_ERP_DOCUMENT_ID] = @NEXT_PICKING_DEMAND_HEADER
              --AND [H].[IS_AUTHORIZED] > 0;

		--oBTIENE ALMACEN ORIGEN
		SELECT @ALMACEN=ERP_WAREHOUSE 
		FROM  [OP_WMS_ALZA].[wms].OP_WMS_WAREHOUSES 
			INNER JOIN [OP_WMS_ALZA].[wms].[OP_WMS_PICKING_ERP_DOCUMENT] [PDH] ON ( WAREHOUSE_ID=[PDH].CODE_WAREHOUSE)
		WHERE [PICKING_ERP_DOCUMENT_ID] = @NEXT_PICKING_DEMAND_HEADER

       declare @missing NUMERIC =0,
	   @pRESULT1 VARCHAR(200)=''; 

		DECLARE detail CURSOR FOR SELECT [ITEM_CODE_ERP],[MATERIAL_ID],SERIAL_NUMBER,[QTY] FROM [#DETALLE]
		open detail
			fetch next from detail into @ERP_MATERIAL_CODE,@MATERIAL_ID_DETAIL,@LINE_NUM_DETAIL,@QTY_DETAIL
			while @@FETCH_STATUS =0 and @missing= 0
			begin
				

            PRINT 'Ciclo detalle line: V:  ' + CAST(@LINE_NUM_DETAIL AS VARCHAR);
			select @DEMAND_TYPE =demand_type 
				from [OP_WMS_ALZA].[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [H] 
				where h.PICKING_DEMAND_HEADER_ID=@NEXT_PICKING_DEMAND_HEADER

			IF @DEMAND_TYPE = 'TRANSFER_REQUEST'
		
				select @TIPO_DOCUMENTO_FOLIO = 'M',
						@CVE_CPTO=  CVE_MSAL 
					from  [SAE70EMPRESA01].[dbo].ALMACENES01 
					where CVE_ALM=@ALMACEN
			PRINT @ERP_MATERIAL_CODE


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
                    SELECT @QTY_DETAIL
                    
                )
            )
            BEGIN
				
				SELECT @missing=1,

				 @pRESULT1
                    = 'La cantidad es mayor a la existencia de los siguientes productos: ' + @ERP_MATERIAL_CODE;
				PRINT @pRESULT1;
				BREAK;
		
            END;
			ELSE
			BEGIN
				print 'si hay'
			END
			fetch next from detail into @ERP_MATERIAL_CODE,@MATERIAL_ID_DETAIL,@LINE_NUM_DETAIL,@QTY_DETAIL

		end
		close detail
		deallocate detail
		IF(@missing=1)
		BEGIN
			commit;
			print @pRESULT1
			SELECT -1 AS [Resultado],
               'Proceso fallido: ' + @pRESULT1 [Mensaje],
               0 [Codigo],
               '0' [DbData];
			RETURN;
		END;



        -- ------------------------------------------------------------------------------------
        -- Obtiene ultimo documento
        -- ------------------------------------------------------------------------------------
		SELECT @ULTIMO_DOCUMENTO = CAST(@NEXT_PICKING_DEMAND_HEADER AS int),
			@DOCUMENTO_ERP_FORMATEADO= ISNULL(@SERIE_FOLIO, 0) + [dbo].[FUNC_ADD_CHARS](@NEXT_PICKING_DEMAND_HEADER, '0', 8)

		PRINT 'Obtuvo @DOCUMENTO_ERP_FORMATEADO' + CAST(@ULTIMO_DOCUMENTO AS VARCHAR);

        PRINT 'Obtuvo ultimo documento @ULTIMO_DOCUMENTO' + CAST(@ULTIMO_DOCUMENTO AS VARCHAR);


		--Obtiene tipo de movimiento

		SELECT @CVE_CPTO=53--C.SPARE4 
			--FROM [OP_WMS_ALZA].[wms].[OP_WMS_CONFIGURATIONS] C
			--INNER JOIN [OP_WMS_ALZA].[wms].[OP_WMS_PICKING_ERP_DOCUMENT] H ON C.PARAM_NAME=H.DEMAND_TYPE
			--WHERE H.[PICKING_ERP_DOCUMENT_ID] = @NEXT_PICKING_DEMAND_HEADER

        SELECT @ULTIMO_DOCUMENTO_COMENTARIO = [ULT_CVE]
        FROM [SAE70EMPRESA01].[dbo].[TBLCONTROL01]
        WHERE [ID_TABLA] = @TABLA_DOCUMENTO_COMENTARIO;

        UPDATE [SAE70EMPRESA01].[dbo].[TBLCONTROL01]
        SET [ULT_CVE] = @ULTIMO_DOCUMENTO_COMENTARIO + 1
        WHERE [ID_TABLA] = @TABLA_DOCUMENTO_COMENTARIO
              AND [ULT_CVE] = @ULTIMO_DOCUMENTO_COMENTARIO;

        SELECT TOP (1)
               @COMENTARIO
                   = 'Documento: '
                     + ISNULL(@DOCUMENTO_ERP_FORMATEADO, ' ') + ' Tarea Swift: '
                     + CAST([e].[WAVE_PICKING_ID] AS VARCHAR(18)) + ' Operada por: ' + ISNULL([t].[TASK_ASSIGNEDTO], ' ')
                     + ' Confirmada por: ' + ISNULL([t].[TASK_OWNER], ' ')
        FROM [#ENCABEZADO] [e]
            INNER JOIN [OP_WMS_ALZA].[wms].[OP_WMS_TASK_LIST] [t]
                ON [e].[WAVE_PICKING_ID] = [t].[WAVE_PICKING_ID];

 PRINT 'alacen' + cast(@ALMACEN as varchar)

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
                   @LINE_NUM_DETAIL = SERIAL_NUMBER,
                   @QTY_DETAIL = [QTY],                   
                   @EXISTENCIAS = 0,
                   @EXISTENCIAS_GENERAL = 0
            FROM [#DETALLE]
            WHERE [ENVIADO] = 0
            ORDER BY SERIAL_NUMBER ASC;
            PRINT 'Ciclo detalle line: ' + CAST(@LINE_NUM_DETAIL AS VARCHAR);
			print 'material: ' + CAST(@MATERIAL_ID_DETAIL AS VARCHAR);
			print '@ERP_MATERIAL_CODE: ' + CAST(@ERP_MATERIAL_CODE AS VARCHAR);
			print '@QTY_DETAIL: ' + CAST(@QTY_DETAIL AS VARCHAR);
	


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
                    SELECT @QTY_DETAIL
                )
            )
            BEGIN
                DECLARE @pRESULT VARCHAR(200)
                    = 'La cantidad es mayor a la existencias de los siguientes productos: ' + @ERP_MATERIAL_CODE;
                RAISERROR(@pRESULT, 16, 1);
            END;
			print 'si hay existencia'
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
                   @ALMACEN ,
                   @ULTIMO_DOCUMENTO_MOVIMIENTO + 1,
                   @CVE_CPTO,
                   @FECHA_HOY,
                   @TIPO_DOCUMENTO_FOLIO,
                   @DOCUMENTO_ERP_FORMATEADO,
                   @CODIGO_CLIENTE_SAE,
                   null,
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
                   @CVE_ULTIMO_DOCUMENTO +1 [CVE_FOLIO],
                   @SIGNO,
                   'S',
                   @COSTO_PROMEDIO_ANTERIOR [COSTO_PROM_INI],
                   @COSTO_PROMEDIO_ANTERIOR [COSTO_PROM_FIN],
                   @COSTO_PROMEDIO_ANTERIOR [COSTO_PROM_GRAL],
                   'S',
                   0
            FROM [#DETALLE] [D]
                INNER JOIN [#ENCABEZADO] [H]
                    ON [D].[PICKING_ERP_DOCUMENT_ID] = [H].[PICKING_ERP_DOCUMENT_ID]
            WHERE SERIAL_NUMBER = @LINE_NUM_DETAIL;


		
			

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
            WHERE SERIAL_NUMBER = @LINE_NUM_DETAIL;
        END;
		            PRINT 'termina CICLO';
        -- ------------------------------------------------------------------------------------
        -- INSERTA EN BITACORA
        -- ------------------------------------------------------------------------------------

        SELECT @ULTIMO_DOCUMENTO_BITACORA = [ULT_CVE]
        FROM [SAE70EMPRESA01].[dbo].[TBLCONTROL01]
        WHERE [ID_TABLA] = @TABLA_DOCUMENTO_BITACORA;


        UPDATE [SAE70EMPRESA01].[dbo].[TBLCONTROL01]
        SET [ULT_CVE] = @ULTIMO_DOCUMENTO_BITACORA + 1
        WHERE [ID_TABLA] = @TABLA_DOCUMENTO_BITACORA
              AND [ULT_CVE] = @ULTIMO_DOCUMENTO_BITACORA;

        INSERT INTO [SAE70EMPRESA01].[dbo].[BITA01]
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
        (@ULTIMO_DOCUMENTO_BITACORA + 1, '_SAE_', 'F', @CODIGO_CLIENTE_SAE, @USUARIO_OPERA, @USUARIO_OPERA_NOMBRE,
         CAST(@COMENTARIO AS VARCHAR(55)), @FECHA_SYNC, '    3');

		             PRINT 'termina 1';
 


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
