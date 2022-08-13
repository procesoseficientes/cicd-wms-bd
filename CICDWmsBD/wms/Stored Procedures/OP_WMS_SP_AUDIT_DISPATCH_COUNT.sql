-- =============================================
-- Autor:					rudi.garcia
-- Fecha de Creacion: 		14-Dec-16 @ A-Team Sprint 6
-- Description:			    Inserta la uditoria por conteo
-- =============================================

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_AUDIT_DISPATCH_COUNT] @pAUDIT_ID = 3901
                                             ,@pMETHOD = 'INPUT'
                                             ,@pCODIGO_POLIZA = '212755'
                                             ,@pBARCODE_ID = 'LECHE-USA'
                                             ,@pQTY_INPUTED = 5
                                             ,@pSERIAL_ID = ''
                                             ,@pLOGIN_ID = 'ACAMACHO'
                                             ,@pRESULT = @p8 OUTPUT
                                             ,@BATCH = '55'
                                             ,@DATE_EXPIRATION = '2016-12-12'
*/
-- =============================================

CREATE PROCEDURE [wms].OP_WMS_SP_AUDIT_DISPATCH_COUNT @pAUDIT_ID NUMERIC(18, 0),
@pMETHOD VARCHAR(25),
@pCODIGO_POLIZA VARCHAR(50),
@pBARCODE_ID VARCHAR(50),
@pQTY_INPUTED NUMERIC(18, 0),
@pSERIAL_ID VARCHAR(50),
@pLOGIN_ID VARCHAR(25),
@BATCH VARCHAR(50),
@DATE_EXPIRATION DATE,
@pResult VARCHAR(250) OUTPUT
AS
  DECLARE @pSCANNED NUMERIC(18, 0);
  DECLARE @pINPUTED NUMERIC(18, 0);
  DECLARE @pMATERIAL_ID VARCHAR(50);
  DECLARE @pCLIENT_ID VARCHAR(25);
  DECLARE @pInputedCountAcu NUMERIC(18, 0);
  DECLARE @pInputedCountTotal NUMERIC(18, 0);
  DECLARE @pInputedCount NUMERIC(18, 0);
  DECLARE @pBatchReuested NUMERIC(18, 0);
  DECLARE @pQtyTrans NUMERIC(18, 0);
  BEGIN
    BEGIN TRY
      BEGIN
        SELECT
          @pCLIENT_ID = (SELECT TOP 1
              CLIENT_CODE
            FROM [wms].OP_WMS_POLIZA_HEADER
            WHERE NUMERO_ORDEN = (SELECT
                NUMERO_ORDEN
              FROM [wms].OP_WMS_AUDIT_DISPATCH_CONTROL
              WHERE AUDIT_ID = @pAUDIT_ID)
            AND CODIGO_POLIZA = (SELECT
                CODIGO_POLIZA
              FROM [wms].OP_WMS_AUDIT_DISPATCH_CONTROL
              WHERE AUDIT_ID = @pAUDIT_ID))

        SELECT
          @pMATERIAL_ID = ISNULL((SELECT TOP 1
              MATERIAL_ID
            FROM [wms].OP_WMS_MATERIALS
            WHERE (BARCODE_ID = @pBARCODE_ID
            OR ALTERNATE_BARCODE = @pBARCODE_ID)
            AND CLIENT_OWNER = @pCLIENT_ID)
          , 'N/F')


        IF (@pMATERIAL_ID = 'N/F')
        BEGIN
          SELECT
            @pResult = 'SKU ' + @pBARCODE_ID + ' NO EXISTE'
          RETURN -1
        END

        IF (@pBARCODE_ID = @pSERIAL_ID)
        BEGIN
          SELECT
            @pResult = 'NUMERO DE SERIE ' + @pSERIAL_ID + ' ES INVALIDO'
          RETURN -1
        END

        IF (@pMETHOD = 'INPUT')
        BEGIN
          SELECT
            @pINPUTED = @pQTY_INPUTED
          SELECT
            @pSCANNED = 0
        END
        ELSE
        BEGIN
          SELECT
            @pINPUTED = 0
          SELECT
            @pSCANNED = 1
        END

        IF EXISTS (SELECT
              1
            FROM [wms].OP_WMS_AUDIT_DISPATCH_SERIES
            WHERE AUDIT_ID = @pAUDIT_ID
            AND SERIAL_NUMBER = @pSERIAL_ID)
        BEGIN
          SELECT
            @pResult = 'NUMERO DE SERIE ' + @pSERIAL_ID + ' YA FUE ESCANEADO'
          RETURN -1
        END

        IF (@pMETHOD = 'INPUT')
        BEGIN

          SELECT TOP 1
            @pBatchReuested = BATCH_REQUESTED
          FROM [wms].OP_WMS_MATERIALS
          WHERE MATERIAL_ID = @pMATERIAL_ID
          AND CLIENT_OWNER = @pCLIENT_ID

          IF @pBatchReuested = 1
          BEGIN
--            IF NOT EXISTS (SELECT
--                  1
--                FROM [wms].OP_WMS_TRANS T
--                INNER JOIN [wms].OP_WMS_INV_X_LICENSE IV
--                  ON T.LICENSE_ID = IV.LICENSE_ID
--                WHERE T.CODIGO_POLIZA = @pCODIGO_POLIZA
--                AND T.TRANS_SUBTYPE = 'PICKING'
--                AND MATERIAL_ID = @pMATERIAL_ID
--                AND IV.BATCH = @BATCH
--                AND IV.DATE_EXPIRATION = @DATE_EXPIRATION)
--            BEGIN
--              SELECT
--                @pResult = 'NUMERO DE LOTE O FECHA EXPIRACION INVALIDO ' + @BATCH + '-' + CONVERT(VARCHAR(10), @DATE_EXPIRATION)
--              RETURN -1
--            END
            --Obtiene la cantidad de piking del sku
--            SELECT
--              @pQtyTrans = SUM(T.QUANTITY_UNITS * -1)
--            FROM [wms].OP_WMS_TRANS T
--            INNER JOIN [wms].OP_WMS_INV_X_LICENSE IV
--              ON T.LICENSE_ID = IV.LICENSE_ID
--            WHERE T.CODIGO_POLIZA = @pCODIGO_POLIZA
--            AND T.TRANS_SUBTYPE = 'PICKING'
--            AND MATERIAL_ID = @pMATERIAL_ID
--            AND IV.BATCH = @BATCH
--            AND IV.DATE_EXPIRATION = @DATE_EXPIRATION
--
--            SELECT
--              @pQtyTrans = ISNULL(@pQtyTrans, 0)
--
--            IF @pQtyTrans < @pQTY_INPUTED
--            BEGIN
--              SELECT
--                @pResult = 'Sobrepaso la cantidad de picking'
--              RETURN -1
--            END
            --Obtine la cantidad de auditoria 
            SELECT
              @pInputedCount = ISNULL(INPUTED_COUNT, 0)
            FROM [wms].OP_WMS_AUDIT_DISPATCH_SKUS S
            WHERE CODIGO_POLIZA = @pCODIGO_POLIZA
            AND AUDIT_ID = @pAUDIT_ID
            AND MATERIAL_ID = @pMATERIAL_ID
            AND BATCH = @BATCH
            AND DATE_EXPIRATION = @DATE_EXPIRATION

            SELECT
              @pInputedCount = ISNULL(@pInputedCount, 0)

            --Obtiene la cantidad acumulada de las auditorias
            SELECT
              @pInputedCountAcu = ISNULL(SUM(INPUTED_COUNT), 0)
            FROM [wms].OP_WMS_AUDIT_DISPATCH_SKUS
            WHERE CODIGO_POLIZA = @pCODIGO_POLIZA
            AND MATERIAL_ID = @pMATERIAL_ID
            AND BATCH = @BATCH
            AND DATE_EXPIRATION = @DATE_EXPIRATION

            SELECT
              @pInputedCountAcu = ISNULL(@pInputedCountAcu, 0)

--            IF (@pQTY_INPUTED + (@pInputedCountAcu - @pInputedCount)) > @pQtyTrans
--            BEGIN
--              SELECT
--                @pResult = 'Sobrepaso la cantidad de picking'
--              RETURN -1
--            END

            --Obtiene la cantidad total de picking
            SELECT
              @pInputedCountTotal = SUM(T.QUANTITY_UNITS * -1)
            FROM [wms].OP_WMS_TRANS T
            INNER JOIN [wms].OP_WMS_INV_X_LICENSE IV
              ON T.LICENSE_ID = IV.LICENSE_ID
            WHERE T.CODIGO_POLIZA = @pCODIGO_POLIZA
            AND T.TRANS_SUBTYPE = 'PICKING'
            AND MATERIAL_ID = @pMATERIAL_ID
            AND IV.BATCH = @BATCH
            AND IV.DATE_EXPIRATION = @DATE_EXPIRATION

            SELECT
              @pInputedCountTotal = ISNULL(@pInputedCountTotal, 0)
          END
          ELSE
          BEGIN
            SELECT
              @DATE_EXPIRATION = '01/01/2010'
            --Obtiene la cantidad de piking del sku
            SELECT
              @pQtyTrans = SUM(T.QUANTITY_UNITS * -1)
            FROM [wms].OP_WMS_TRANS T
            INNER JOIN [wms].OP_WMS_INV_X_LICENSE IV
              ON T.LICENSE_ID = IV.LICENSE_ID
            WHERE T.CODIGO_POLIZA = @pCODIGO_POLIZA
            AND T.TRANS_SUBTYPE = 'PICKING'
            AND MATERIAL_ID = @pMATERIAL_ID

            SELECT
              @pQtyTrans = ISNULL(@pQtyTrans, 0)

--            IF @pQtyTrans < @pQTY_INPUTED
--            BEGIN
--              SELECT
--                @pResult = 'Sobrepaso la cantidad de picking'
--              RETURN -1
--            END

            --Obtine la cantidad de auditoria 
            SELECT
              @pInputedCount = ISNULL(INPUTED_COUNT, 0)
            FROM [wms].OP_WMS_AUDIT_DISPATCH_SKUS S
            WHERE CODIGO_POLIZA = @pCODIGO_POLIZA
            AND AUDIT_ID = @pAUDIT_ID
            AND MATERIAL_ID = @pMATERIAL_ID

            SELECT
              @pInputedCount = ISNULL(@pInputedCount, 0)

            --Obtiene la cantidad acumulada de las auditorias
            SELECT
              @pInputedCountAcu = ISNULL(SUM(INPUTED_COUNT), 0)
            FROM [wms].OP_WMS_AUDIT_DISPATCH_SKUS
            WHERE CODIGO_POLIZA = @pCODIGO_POLIZA
            AND MATERIAL_ID = @pMATERIAL_ID

            SELECT
              @pInputedCountAcu = ISNULL(@pInputedCountAcu, 0)

--            IF (@pQTY_INPUTED + (@pInputedCountAcu - @pInputedCount)) > @pQtyTrans
--            BEGIN
--              SELECT
--                @pResult = 'Sobrepaso la cantidad de picking'
--              RETURN -1
--            END

            --Obtiene la cantidad total de picking
            SELECT
              @pInputedCountTotal = SUM(T.QUANTITY_UNITS * -1)
            FROM [wms].OP_WMS_TRANS T
            INNER JOIN [wms].OP_WMS_INV_X_LICENSE IV
              ON T.LICENSE_ID = IV.LICENSE_ID
            WHERE T.CODIGO_POLIZA = @pCODIGO_POLIZA
            AND T.TRANS_SUBTYPE = 'PICKING'
            AND MATERIAL_ID = @pMATERIAL_ID

            SELECT
              @pInputedCountTotal = ISNULL(@pInputedCountTotal, 0)
          END

--          IF ((@pInputedCountAcu - @pInputedCount) + @pQTY_INPUTED) > @pInputedCountTotal
--          BEGIN
--            SELECT
--              @pResult = 'Cantidad mayor al PICKING (' + CONVERT(VARCHAR(18), @pInputedCountTotal) + ')'
--            RETURN -1
--          END

        END

        INSERT INTO [wms].[OP_WMS_AUDIT_DISPATCH_SKUS] ([AUDIT_ID]
        , [CODIGO_POLIZA]
        , [MATERIAL_ID]
        , [BARCODE_ID]
        , [MATERIAL_NAME]
        , [SCANNED_COUNT]
        , [INPUTED_COUNT]
        , [LAST_UPDATED]
        , [LAST_UPDATED_BY]
        , BATCH
        , DATE_EXPIRATION)
          VALUES (@pAUDIT_ID, @pCODIGO_POLIZA, @pMATERIAL_ID, @pBARCODE_ID, (SELECT MATERIAL_NAME FROM [wms].OP_WMS_MATERIALS WHERE MATERIAL_ID = @pMATERIAL_ID), @pSCANNED, @pINPUTED, CURRENT_TIMESTAMP, @pLOGIN_ID, @BATCH, @DATE_EXPIRATION)

        IF (@pMETHOD = 'SCANNING')
        BEGIN
        BEGIN TRY
          BEGIN
            INSERT INTO [wms].[OP_WMS_AUDIT_DISPATCH_SERIES] ([AUDIT_ID]
            , [SERIAL_NUMBER]
            , [MATERIAL_ID]
            , [LAST_UPDATED])
              VALUES (@pAUDIT_ID, @pSERIAL_ID, @pMATERIAL_ID, CURRENT_TIMESTAMP)

            IF @@ERROR = 0
            BEGIN
              SELECT
                @pResult = 'OK'
            END
            ELSE
            BEGIN
              SELECT
                @pResult = ERROR_MESSAGE()
            END

          END
        END TRY
        BEGIN CATCH
          SELECT
            @pResult = 'N/S: ' + @pSERIAL_ID + ' ' + ERROR_MESSAGE()
        END CATCH
        END

        IF @@ERROR = 0
        BEGIN
          SELECT
            @pResult = 'OK'
        END
        ELSE
        BEGIN
          SELECT
            @pResult = ERROR_MESSAGE()
        END
      END
    END TRY
    BEGIN CATCH

      IF (@pMETHOD = 'INPUT')
      BEGIN
        UPDATE [wms].[OP_WMS_AUDIT_DISPATCH_SKUS]
        SET [INPUTED_COUNT] = @pQTY_INPUTED
           ,[LAST_UPDATED] = CURRENT_TIMESTAMP
           ,[LAST_UPDATED_BY] = @pLOGIN_ID
        WHERE [AUDIT_ID] = @pAUDIT_ID
        AND [CODIGO_POLIZA] = @pCODIGO_POLIZA
        AND [MATERIAL_ID] = @pMATERIAL_ID
        AND BATCH = @BATCH
        AND DATE_EXPIRATION = @DATE_EXPIRATION

        IF @@ERROR = 0
        BEGIN
          SELECT
            @pResult = 'OK'
        END
        ELSE
        BEGIN
          SELECT
            @pResult = ERROR_MESSAGE()
        END

      END
      ELSE
      BEGIN
      BEGIN TRY
        BEGIN
          --SELECT @pMATERIAL_ID = ISNULL((SELECT TOP 1 MATERIAL_ID FROM [wms].OP_WMS_MATERIALS 
          --	WHERE (BARCODE_ID = @pBARCODE_ID OR ALTERNATE_BARCODE = @pBARCODE_ID)  AND CLIENT_OWNER = @pCLIENT_ID),'N/F')

          --IF(@pMATERIAL_ID = 'N/F') BEGIN
          --	SELECT	@pResult	= 'SKU ' + @pBARCODE_ID +' NO EXISTE (CLIENT:'+@pCLIENT_ID+')'
          --	RETURN -1
          --END	

          INSERT INTO [wms].[OP_WMS_AUDIT_DISPATCH_SERIES] ([AUDIT_ID]
          , [SERIAL_NUMBER]
          , [MATERIAL_ID]
          , [LAST_UPDATED])
            VALUES (@pAUDIT_ID, @pSERIAL_ID, @pMATERIAL_ID, CURRENT_TIMESTAMP)

          UPDATE [wms].[OP_WMS_AUDIT_DISPATCH_SKUS]
          SET [SCANNED_COUNT] = [SCANNED_COUNT] + 1
             ,[LAST_UPDATED] = CURRENT_TIMESTAMP
             ,[LAST_UPDATED_BY] = @pLOGIN_ID
          WHERE [AUDIT_ID] = @pAUDIT_ID
          AND [CODIGO_POLIZA] = @pCODIGO_POLIZA
          AND [MATERIAL_ID] = @pMATERIAL_ID
          AND BATCH = @BATCH
          AND DATE_EXPIRATION = @DATE_EXPIRATION

          IF @@ERROR = 0
          BEGIN
            SELECT
              @pResult = 'OK'
          END
          ELSE
          BEGIN
            SELECT
              @pResult = ERROR_MESSAGE()
          END

        END
      END TRY
      BEGIN CATCH
        SELECT
          @pResult = 'N/S: ' + @pSERIAL_ID + ' YA FUE ESCANEADO.' + ERROR_MESSAGE()
      END CATCH

      END

    END CATCH

  END