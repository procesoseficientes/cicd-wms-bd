﻿--SELECT * FROM [SAE70EMPRESA01].[dbo].[MINVE01] ORDER BY FECHA_DOCU DESC
-- =============================================
-- Autor:				gustavo.garcía
-- Fecha de Creacion: 	11-Nov-2021  
-- Description:			SP que crea explosiones en SAE

-- Autor:				Brandon Sicay
-- Fecha de Creacion: 	16-Jul-2022  
-- Description:			Correccion de costos en desarmado de master pack 

--Modificación:			Elder Lucas
--Fecha:				18 de noviembre 2022
--Descripción:			Se cambia @TABLA_DOCUMENTO_COMENTARIO a 57 (valor anterior: 56) para tomar el mismo correlativo que las ordenes de venta y los traslados

--Modificación:			Elder Lucas
--Fecha:				21 de noviembre 2022
--Descripción:			[OBS_DOCF01] ID correlativo 56, [OBS_DOCC01] ID Correlativo 57

/*
-- Ejemplo de Ejecucion:
				EXEC [dbo].[SAE_CREATE_EXPLOSION_BY_MASTERPACK] @MATERPACK_ID = 4491 -- numeric
				rollback
				Proceso fallido: Violation of PRIMARY KEY constraint 'PK_FACTR01'. Cannot insert duplicate key in object 'dbo.FACTR01'. The duplicate key value is (00000108-00000015).
				Proceso fallido: Cannot insert the value NULL into column 'CVE_DOC', table 'select *from SAE70EMPRESA01.dbo.FACTR01 where CVE_DOC like '%00000108-000000%''; column does not allow nulls. INSERT fails.
				
*/
-- =============================================
CREATE PROCEDURE [dbo].[SAE_CREATE_EXPLOSION_BY_MASTERPACK]
(@MATERPACK_ID NUMERIC)
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
            @SERIE_FOLIO VARCHAR(10) = 'WMS_EXP',
            @ULT_DOC_FOLIO INT,
            @CODIGO_CLIENTE_SAE VARCHAR(10),
            @NOMBRE_CLIENTE_SAE VARCHAR(100),
            @TIPO_CLIENTE_SAE VARCHAR(50),
            @FOLIO_DESDE INT,
            @NUM_MONEDA INT = 1,
            @TIPO_CAMBIO INT = 1,
            @TABLA_DOCUMENTO_COMENTARIO INT = 57,
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

	
        SELECT --min([D].SERIAL_NUMBER) SERIAL_NUMBER,
               [H].MASTER_PACK_HEADER_ID,
               H.[MATERIAL_ID] [MATERIAL_ID],
               sum(H.QTY*D.QTY)QTY,
			   SUM(D.QTY) QTY_DET,
			   CAST(-1.0000 AS FLOAT )COST,
               T.[TONE],
               T.[CALIBER],
               L.STATUS,
               W.ERP_WAREHOUSE [NUM_ALM],
               [M].[MATERIAL_NAME],
               [M].[ITEM_CODE_ERP],
               [M].[BASE_MEASUREMENT_UNIT],
               CAST(0 AS INT) [ENVIADO],
               CAST(0 AS INT) [NUMERO_MOVIMIENTO]
        INTO [#DETALLE]
        FROM [OP_WMS_ALZA].[wms].[OP_WMS_MASTER_PACK_DETAIL] [D]
            INNER JOIN [OP_WMS_ALZA].[wms].[OP_WMS_MASTER_PACK_HEADER] [H]
                ON [H].MASTER_PACK_HEADER_ID = [D].MASTER_PACK_HEADER_ID
            INNER JOIN [OP_WMS_ALZA].[wms].[OP_WMS_MATERIALS] [M]
                ON [M].[MATERIAL_ID] = [D].[MATERIAL_ID]
			INNER JOIN OP_WMS_ALZA.WMS.OP_WMS_LICENSES L
				ON H.LICENSE_ID=L.LICENSE_ID
			INNER JOIN [OP_WMS_ALZA].[wms].OP_WMS_INV_X_LICENSE IXL
				ON H.LICENSE_ID = IXL.LICENSE_ID 
				AND IXL.MATERIAL_ID=H.MATERIAL_ID
			LEFT JOIN OP_WMS_ALZA.WMS.OP_WMS_TONE_AND_CALIBER_BY_MATERIAL T
				ON T.TONE_AND_CALIBER_ID=IXL.TONE_AND_CALIBER_ID
			LEFT JOIN OP_WMS_ALZA.WMS.OP_WMS_WAREHOUSES W 
				ON W.WAREHOUSE_ID=L.CURRENT_WAREHOUSE
        WHERE [H].MASTER_PACK_HEADER_ID = @MATERPACK_ID
              --AND [H].[IS_AUTHORIZED] > 0
   
		GROUP BY [H].[MATERIAL_ID],
				[H].MASTER_PACK_HEADER_ID,
				 t.[TONE],
				 T.[CALIBER],
				 L.STATUS,
				 [M].[MATERIAL_NAME],
               [M].[ITEM_CODE_ERP],
			   
               [M].[BASE_MEASUREMENT_UNIT], W.ERP_WAREHOUSE

		-- ------------------------------------------------------------------------------------
        -- OBTENER DATOS DE ENCABEZADO MASTERPACK
        -- ------------------------------------------------------------------------------------	
        SELECT 
               [H].MASTER_PACK_HEADER_ID,
               [H].[IS_AUTHORIZED],
               [H].[ATTEMPTED_WITH_ERROR],
               [H].[IS_POSTED_ERP],
               [H].[POSTED_ERP],
               [H].[POSTED_RESPONSE],
               [H].[ERP_REFERENCE],
               [H].EXPLODED_DATE,
               [H].[ERP_REFERENCE_DOC_NUM],
			   isnull(W.ERP_WAREHOUSE,W2.ERP_WAREHOUSE) ERP_WAREHOUSE,
			   H.MATERIAL_ID,
			   M.ITEM_CODE_ERP,
			   H.QTY,
               CAST(0 AS INT) [ENVIADO],
               CAST(0 AS INT) [NUMERO_MOVIMIENTO]
        INTO [#ENCABEZADO]
        FROM [OP_WMS_ALZA].[wms].[OP_WMS_MASTER_PACK_HEADER] [H]
        INNER JOIN OP_WMS_ALZA.WMS.OP_WMS_LICENSES L
				ON H.LICENSE_ID=L.LICENSE_ID
		INNER JOIN OP_WMS_ALZA.WMS.OP_WMS_MATERIALS M ON H.MATERIAL_ID = M.MATERIAL_ID
		left join OP_WMS_ALZA.WMS.OP_WMS_LOGINS lg on lg.LOGIN_ID=L.CURRENT_WAREHOUSE
		LEFT JOIN OP_WMS_ALZA.WMS.OP_WMS_WAREHOUSES W 
				ON W.WAREHOUSE_ID=L.CURRENT_WAREHOUSE
		LEFT JOIN OP_WMS_ALZA.WMS.OP_WMS_WAREHOUSES W2
				 on W2.WAREHOUSE_ID=lg.[3PL_WAREHOUSE]
        WHERE [H].MASTER_PACK_HEADER_ID = @MATERPACK_ID
              --AND [H].[IS_AUTHORIZED] > 0;

		--oBTIENE ALMACEN ORIGEN
		SELECT  @ALMACEN=ERP_WAREHOUSE 
		FROM  [#ENCABEZADO]


    BEGIN TRY
        BEGIN TRANSACTION;
        -- ------------------------------------------------------------------------------------
        -- obtiene datos de Wms
        -- ------------------------------------------------------------------------------------


       declare @missing NUMERIC =0,
	   @pRESULT1 VARCHAR(200)=''; 

		DECLARE detail CURSOR FOR SELECT [ITEM_CODE_ERP],[MATERIAL_ID],[QTY] FROM [#ENCABEZADO]
		open detail
			fetch next from detail into @ERP_MATERIAL_CODE,@MATERIAL_ID_DETAIL,@QTY_DETAIL
			while @@FETCH_STATUS =0 and @missing= 0
			begin
				

   --         PRINT 'Ciclo detalle line: V:  ' + CAST(@LINE_NUM_DETAIL AS VARCHAR);
			--select @DEMAND_TYPE =demand_type 
			--	from [OP_WMS_ALZA].[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [H] 
			--	where h.PICKING_DEMAND_HEADER_ID=@MATERPACK_ID

			--IF @DEMAND_TYPE = 'TRANSFER_REQUEST'
		
			--	select @TIPO_DOCUMENTO_FOLIO = 'M',
			--			@CVE_CPTO=  CVE_MSAL 
			--		from  [SAE70EMPRESA01].[dbo].ALMACENES01 
			--		where CVE_ALM=@ALMACEN
			--PRINT @ERP_MATERIAL_CODE


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
				PRINT  @MATERPACK_ID
				BREAK;
		
            END;
			ELSE
			BEGIN
				print 'si hay'
			END
			fetch next from detail into @ERP_MATERIAL_CODE,@MATERIAL_ID_DETAIL,@QTY_DETAIL

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
		SELECT @ULTIMO_DOCUMENTO = CAST(@MATERPACK_ID AS int),
			@DOCUMENTO_ERP_FORMATEADO= ISNULL(@SERIE_FOLIO, 0) + [dbo].[FUNC_ADD_CHARS](@MATERPACK_ID, '0', 8)

		PRINT 'Obtuvo @DOCUMENTO_ERP_FORMATEADO' + CAST(@ULTIMO_DOCUMENTO AS VARCHAR);

        PRINT 'Obtuvo ultimo documento @ULTIMO_DOCUMENTO' + CAST(@ULTIMO_DOCUMENTO AS VARCHAR);


		--Obtiene tipo de movimiento

		SELECT @CVE_CPTO=53--C.SPARE4 
			--FROM [OP_WMS_ALZA].[wms].[OP_WMS_CONFIGURATIONS] C
			--INNER JOIN [OP_WMS_ALZA].[wms].[OP_WMS_PICKING_ERP_DOCUMENT] H ON C.PARAM_NAME=H.DEMAND_TYPE
			--WHERE H.[PICKING_ERP_DOCUMENT_ID] = @MATERPACK_ID
			PRINT 'G1'

        SELECT @ULTIMO_DOCUMENTO_COMENTARIO = [ULT_CVE]
        FROM [SAE70EMPRESA01].[dbo].[TBLCONTROL01]
        WHERE [ID_TABLA] = 56 --ID Correlativo;
		PRINT 'G2'
		print @TABLA_DOCUMENTO_COMENTARIO;
		print @ULTIMO_DOCUMENTO_COMENTARIO
        UPDATE [SAE70EMPRESA01].[dbo].[TBLCONTROL01]
        SET [ULT_CVE] = @ULTIMO_DOCUMENTO_COMENTARIO + 1
        WHERE [ID_TABLA] = 56
              AND [ULT_CVE] = @ULTIMO_DOCUMENTO_COMENTARIO;
		PRINT 'G3'
        SELECT TOP (1)
               @COMENTARIO
                   = 'Documento: '
                     + ISNULL(@DOCUMENTO_ERP_FORMATEADO, ' ') + ' Tarea Swift: '
                     + CAST([e].MASTER_PACK_HEADER_ID AS VARCHAR(18))+' '
        FROM [#ENCABEZADO] [e]
            --INNER JOIN [OP_WMS_ALZA].[wms].[OP_WMS_TASK_LIST] [t]
            --    ON [e].[WAVE_PICKING_ID] = [t].[WAVE_PICKING_ID];
			PRINT 'G4'
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
	   
	   WHILE EXISTS (SELECT TOP 1 1 FROM [#ENCABEZADO] WHERE [ENVIADO] = 0)
        BEGIN
			 PRINT 'Obtuvo Existencias CICLO'
            SELECT TOP (1)
                   @ERP_MATERIAL_CODE = [ITEM_CODE_ERP],
                   @MATERIAL_ID_DETAIL = [MATERIAL_ID],
                   --@LINE_NUM_DETAIL = SERIAL_NUMBER,
                   @QTY_DETAIL = [QTY],                   
                   @EXISTENCIAS = 0,
                   @EXISTENCIAS_GENERAL = 0
            FROM [#ENCABEZADO]
            WHERE [ENVIADO] = 0
           -- ORDER BY SERIAL_NUMBER ASC;
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
                   @COSTO_PROMEDIO_ANTERIOR = ISNULL([I].[COSTO_PROM],0)
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
                   H.[ITEM_CODE_ERP],
                   @ALMACEN ,
                   @ULTIMO_DOCUMENTO_MOVIMIENTO + 1,
                   @CVE_CPTO,
                   @FECHA_HOY,
                   @TIPO_DOCUMENTO_FOLIO,
                   @DOCUMENTO_ERP_FORMATEADO,
                   @CODIGO_CLIENTE_SAE,
                   null,
                   [H].[QTY],
                   0,
                   0,
                   @COSTO_PROMEDIO_ANTERIOR [COSTO],
                   0,
                   [D].[BASE_MEASUREMENT_UNIT],
                   0,
                   @EXISTENCIAS_GENERAL - [H].[QTY] [EXISTENCIA_GENERAL],
                   @EXISTENCIAS - [H].[QTY] [EXISTENCIA],
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
            FROM #ENCABEZADO [H]
                INNER JOIN [#DETALLE] [D]
                    ON [D].MASTER_PACK_HEADER_ID = [H].MASTER_PACK_HEADER_ID
            WHERE D.MATERIAL_ID = H.MATERIAL_ID;

			

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
            UPDATE #ENCABEZADO
            SET [ENVIADO] = 1,
                [NUMERO_MOVIMIENTO] = @ULTIMO_DOCUMENTO_MOVIMIENTO + 1
            WHERE MATERIAL_ID = @MATERIAL_ID_DETAIL;
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
        DECLARE @RESPONSE VARCHAR(500) = 'Proceso exitoso, Recepción: GG 1 ' + @DOCUMENTO_ERP_FORMATEADO;

        PRINT 'Actualizó Swift ';


        
        --SELECT 1 AS [Resultado],
        --       @RESPONSE [Mensaje],
        --       0 [Codigo],
        --       @DOCUMENTO_ERP_FORMATEADO [DbData];

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
         --   ROLLBACK TRANSACTION;
        DECLARE @MENSAJE_ERROR VARCHAR(500) = ERROR_MESSAGE();
		print 'ERROR: ' + @MENSAJE_ERROR
        --
        SELECT -1 AS [Resultado],
               'Proceso fallido: ' + @MENSAJE_ERROR [Mensaje],
               0 [Codigo],
               '0' [DbData];
			return
		--RAISERROR(@MENSAJE_ERROR, 16, 1);
    END CATCH;

	-------------------------------
	--------------------------------
	-----------INCOME-------------------
	----------------------------------

	
    BEGIN TRY
        BEGIN TRANSACTION;
       
	   
    -- ------------------------------------------------------------------------------------
    -- Declaramos variables
    -- ------------------------------------------------------------------------------------
    DECLARE @TABLA_DOCUMENTO_32 INT = 32,
			@ULTIMO_DOCUMENTO_32 INT = 0,
            --@ULTIMO_DOCUMENTO INT = 0,
            --@TIPO_DOCUMENTO_FOLIO VARCHAR(1) = 'M',
            --@SERIE_FOLIO VARCHAR(6) = 'WMS',
            --@ULT_DOC_FOLIO [INT],
            --@FOLIO_DESDE INT,
            @CODIGO_PROVEEDOR_SAE VARCHAR(10),
            @NOMBRE_PROVEEDOR_SAE VARCHAR(100),
            --@TABLA_DOCUMENTO_COMENTARIO INT = 57,
            --@ULTIMO_DOCUMENTO_COMENTARIO INT = 0,
            --@FECHA_SYNC DATETIME = GETDATE(),
            @DOCUMENTO_ERP_FORMATEADO2 VARCHAR(25),
            @TOTAL_COMPRA FLOAT,
            @TOTAL_IMPUESTO_COMPRA FLOAT,
            --@TOTAL_IMPORTE FLOAT,
            --@TOTAL_IMPUESTO_01 FLOAT,
            --@TOTAL_IMPUESTO_02 FLOAT,
            --@TOTAL_IMPUESTO_03 FLOAT,
            --@TOTAL_IMPUESTO_04 FLOAT,
            --@MES_ACTUAL DATETIME = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0),
            --@FECHA_HOY DATETIME = DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0),
            @ORDEN_COMPRA_DOCUMENTO VARCHAR(50)
            --@COMENTARIO VARCHAR(200);

			update  D set d.cost=ISNULL((@COSTO_PROMEDIO_ANTERIOR),0) / ISNULL([D].QTY_DET, 1) 
			from #DETALLE d


    --VARIABLES DETALLE
    --DECLARE @ERP_MATERIAL_CODE VARCHAR(25),
    --        @MATERIAL_ID_DETAIL VARCHAR(25),
    --        @LINE_NUM_DETAIL INT,
    --        @QTY_DETAIL NUMERIC(18, 6),
    --        @CVE_CPTO INT = 1,
    --        @SIGNO SMALLINT,
    --        @TIPO_MOV VARCHAR(1),
    --        @TABLA_DOCUMENTO_MOVIMIENTO INT = 44,
    --        @ULTIMO_DOCUMENTO_MOVIMIENTO INT = 0,
    --        @COSTO_ARTICULO_DOCUMENTO FLOAT,
    --        @COSTO_PROMEDO_CALCULADO FLOAT,
    --        @COSTO_PROMEDIO_ANTERIOR FLOAT,
    --        @EXISTENCIAS FLOAT = 0,
    --        @EXISTENCIAS_GENERAL FLOAT = 0,
    --        @CONTADOR_LINEA INT = 0,
    --        @ALMACEN INT = 0;
			--@DEMAND_TYPE VARCHAR(255) = 'RECEPCION_TRASLADO';

        -- ------------------------------------------------------------------------------------
        -- Obtiene ultimo documento
        -- ------------------------------------------------------------------------------------
		SELECT @ULTIMO_DOCUMENTO = CAST(@MATERPACK_ID AS int),
			@DOCUMENTO_ERP_FORMATEADO2= ISNULL(@SERIE_FOLIO, 0) + [dbo].[FUNC_ADD_CHARS](@MATERPACK_ID, '0', 8)-- + 'E'


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


        PRINT 'Obtuvo ultimo folio HH' + CAST(@DOCUMENTO_ERP_FORMATEADO2 AS VARCHAR);
       -- PRINT 'Obtuvo ultimo documento @ULTIMO_DOCUMENTO' + CAST(@ULTIMO_DOCUMENTO AS VARCHAR);
		--PRINT 'Obtiene el Almacen @ALMACEN' +  cast(@ALMACEN as varchar);


		SELECT @CVE_CPTO=14
			
          PRINT 'Obtuvo ultimo TIPO MOVIMIENTO gg' + CAST(@CVE_CPTO AS VARCHAR);

        SELECT @ULTIMO_DOCUMENTO_COMENTARIO = [ULT_CVE]
        FROM [SAE70EMPRESA01].[dbo].[TBLCONTROL01]
        WHERE [ID_TABLA] = 57 --ID Correlativo;


        UPDATE [SAE70EMPRESA01].[dbo].[TBLCONTROL01]
        SET [ULT_CVE] = @ULTIMO_DOCUMENTO_COMENTARIO + 1
        WHERE [ID_TABLA] = 57
              AND [ULT_CVE] = @ULTIMO_DOCUMENTO_COMENTARIO;

        --SELECT TOP (1)
        --       @COMENTARIO
        --           = 'Tarea Swift: ' + CAST([e].[TASK_ID] AS VARCHAR(18)) + ' Operada por: ' + [t].[TASK_ASSIGNEDTO]
        --             + ' Confirmada por: ' + [e].[CONFIRMED_BY]
        --FROM [#ENCABEZADO] [e]
        --    INNER JOIN [OP_WMS_ALZA].[wms].[OP_WMS_TASK_LIST] [t]
        --        ON [e].[TASK_ID] = [t].[SERIAL_NUMBER]
        --           AND [t].[TASK_TYPE] = 'TAREA_RECEPCION';


        PRINT 'Comentario ' + CAST(@COMENTARIO AS VARCHAR);
        INSERT INTO [SAE70EMPRESA01].[dbo].[OBS_DOCC01]
        (
            [CVE_OBS],
            [STR_OBS]
        )
        VALUES
        (@ULTIMO_DOCUMENTO_COMENTARIO + 1, @COMENTARIO);

		-- ------------------------------------------------------------------------------------
        -- INSERT DE DETALLE DE MOVIMIENTO EN SAE Y ACTUALIZACION DE COSTOS
        -- ------------------------------------------------------------------------------------
        WHILE EXISTS (SELECT TOP 1 1 FROM [#DETALLE] WHERE [ENVIADO] = 0)
        BEGIN
            SELECT TOP (1)
                   @ERP_MATERIAL_CODE = [ITEM_CODE_ERP],
                   @MATERIAL_ID_DETAIL = [MATERIAL_ID],
                   --@LINE_NUM_DETAIL = ERP_RECEPTION_DOCUMENT_DETAIL_ID,
				   @COSTO_ARTICULO_DOCUMENTO = COST,
                   @QTY_DETAIL = QTY,
                   @EXISTENCIAS = 0,
                   @EXISTENCIAS_GENERAL = 0
				   --@ALMACEN = [NUM_ALM]
            FROM [#DETALLE]
            WHERE [ENVIADO] = 0
          --  ORDER BY [LINE_NUM] ASC;
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
                   @COSTO_PROMEDO_CALCULADO = (([I].[EXIST] * [I].[COSTO_PROM]) + (@QTY_DETAIL * @COSTO_ARTICULO_DOCUMENTO)) / ([I].[EXIST] + @QTY_DETAIL),
                   @COSTO_PROMEDIO_ANTERIOR = [I].[COSTO_PROM]
				   FROM 
				   [SAE70EMPRESA01].[dbo].[INVE01] [I] LEFT JOIN 
				   [SAE70EMPRESA01].[dbo].[MULT01] [M]
                   ON [M].[CVE_ART] = [I].[CVE_ART]
                   AND [M].[CVE_ALM] = @ALMACEN
            WHERE [I].[CVE_ART] = @ERP_MATERIAL_CODE;
			PRINT '@QTY_DETAIL' + CAST(@QTY_DETAIL AS VARCHAR)
			PRINT '@COSTO_ARTICULO_DOCUMENTO'+ CAST(@COSTO_ARTICULO_DOCUMENTO AS VARCHAR)
			PRINT '@COSTO_PROMEDO_CALCULADO' +CAST(@COSTO_PROMEDO_CALCULADO AS VARCHAR)

			PRINT @ERP_MATERIAL_CODE
			--SELECT * FROM [SAE70EMPRESA01].[dbo].[INVE01] [I] WHERE CVE_ART='27102'

            PRINT 'Obtuvo Existencias ' + @ERP_MATERIAL_CODE + ' ' + CAST(@EXISTENCIAS AS VARCHAR) + ' '
                  + CAST(@EXISTENCIAS + @QTY_DETAIL AS VARCHAR);
            -- ------------------------------------------------------------------------------------
            -- inserta movimiento 
			--select * from  [SAE70EMPRESA01].[dbo].[MINVE01] order by FECHAELAB desc
            -- ------------------------------------------------------------------------------------
			--SELECT * FROM [SAE70EMPRESA01].[dbo].[MINVE01] ORDER BY FECHAELAB DESC
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
                   ISNULL(@DOCUMENTO_ERP_FORMATEADO2, 0),
                   null,
                   null,
                   QTY,
                   0,
                   0,
                   @COSTO_ARTICULO_DOCUMENTO [COSTO],
                   0,
                   [BASE_MEASUREMENT_UNIT],
                   0,
                   @EXISTENCIAS_GENERAL + QTY [EXISTENCIA_GENERAL],
                   @EXISTENCIAS + QTY [EXISTENCIA],
				   'P',
                   1,
                   GETDATE(),
                   @ULTIMO_DOCUMENTO_32 + 1 [CVE_FOLIO],
                   1,
                   'S',
                   @COSTO_PROMEDIO_ANTERIOR,
                   @COSTO_PROMEDO_CALCULADO,
                   @COSTO_PROMEDIO_ANTERIOR,
                   'S',
                   0
            FROM [#DETALLE] D
            WHERE MATERIAL_ID = @MATERIAL_ID_DETAIL;
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


           -- PRINT 'actualiza costos ';

            --UPDATE [SAE70EMPRESA01].[dbo].[PRVPROD01]
            --SET [COSTO] = @COSTO_ARTICULO_DOCUMENTO
            --WHERE [CVE_ART] = @ERP_MATERIAL_CODE
            --      AND [CVE_PROV] = @CODIGO_PROVEEDOR_SAE;

            PRINT 'termina linea';
            UPDATE [#DETALLE]
            SET [ENVIADO] = 1,
                [NUMERO_MOVIMIENTO] = @ULTIMO_DOCUMENTO_MOVIMIENTO +1
            WHERE MATERIAL_ID = @MATERIAL_ID_DETAIL;
        END;


        
  


        SELECT  @RESPONSE  =@RESPONSE+ 'Proceso exitoso, Recepción: ' + @DOCUMENTO_ERP_FORMATEADO2;

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

        DECLARE @MENSAJE_ERROR2 VARCHAR(500) = ERROR_MESSAGE();
		print 'ERROR3: ' + @MENSAJE_ERROR2
        --
        SELECT -1 AS [Resultado],
               'Proceso fallido: ' + @MENSAJE_ERROR2 [Mensaje],
               0 [Codigo],
               '0' [DbData];
	
    END CATCH;


END;













