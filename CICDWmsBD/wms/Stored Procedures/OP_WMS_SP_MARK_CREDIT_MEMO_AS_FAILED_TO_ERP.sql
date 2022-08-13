-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	10/11/2017 @ NEXUS-Team Sprint ewms 
-- Description:			Marca una recepcion de devolucion de factura como fallida a ERP

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_MARK_CREDIT_MEMO_AS_FAILED_TO_ERP]
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_MARK_CREDIT_MEMO_AS_FAILED_TO_ERP
(
    @OWNER VARCHAR(50)
, @RECEPTION_HEADER_ID INT
, @POSTED_RESPONSE VARCHAR(500)
)
AS
BEGIN
    SET NOCOUNT ON;
	--
    BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Actualiza el encabezado
		-- ------------------------------------------------------------------------------------
        UPDATE
            [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]
        SET
            [LAST_UPDATE] = GETDATE()
            , [LAST_UPDATE_BY] = 'INTERFACE'
            , [ATTEMPTED_WITH_ERROR] = [ATTEMPTED_WITH_ERROR] + 1
            , [IS_POSTED_ERP] = -1
            , [POSTED_ERP] = GETDATE()
            , [POSTED_RESPONSE] = @POSTED_RESPONSE
        WHERE
            [ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_HEADER_ID;		
		-- ------------------------------------------------------------------------------------
		-- Actualiza el detalle
		-- ------------------------------------------------------------------------------------
        UPDATE
            [RDD]
        SET
            [ATTEMPTED_WITH_ERROR] = [ATTEMPTED_WITH_ERROR] + 1
            , [IS_POSTED_ERP] = -1
            , [POSTED_ERP] = GETDATE()
            , [POSTED_RESPONSE] = @POSTED_RESPONSE
        FROM
            [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [RDD]
        INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [RDD].[MATERIAL_ID]
        WHERE
            [RDD].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_HEADER_ID
            AND ( [M].[CLIENT_OWNER] = @OWNER );
		-- ------------------------------------------------------------------------------------
		-- Muestra resultado final
		-- ------------------------------------------------------------------------------------
        SELECT
            1 AS [Resultado]
            , 'Proceso Exitoso' [Mensaje]
            , 0 [Codigo]
            , '' [DbData];
    END TRY
    BEGIN CATCH
        SELECT
            -1 AS [Resultado]
            , CASE CAST(@@ERROR AS VARCHAR)
                WHEN '2627' THEN ''
                ELSE ERROR_MESSAGE()
            END [Mensaje]
            , @@ERROR [Codigo]; 
    END CATCH;
END;