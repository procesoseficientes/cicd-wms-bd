-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	31/May/2018 G-Force@Dinosaurio
-- Description:			actualiza el detalle de la recepcion.

/*

  USE SWIFT_EXPRESS
GO

EXEC [wms].OP_WMS_SP_UPDATE_RECEPTION_DETAIL @XML
                                                
GO
					
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_UPDATE_RECEPTION_DETAIL] (@XML XML)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE	@RESULT_XML TABLE (
			[ERP_RECEPTION_DOCUMENT_DETAIL_ID] INT
			,[MATERIAL_ID] VARCHAR(50)
			,[QTY] INT
		);



	BEGIN TRY
    -- ------------------------------------------------------------------------------------
    -- Obtenemos los registros del xml
    -- ------------------------------------------------------------------------------------
		INSERT	INTO @RESULT_XML
				(
					[ERP_RECEPTION_DOCUMENT_DETAIL_ID]
					,[MATERIAL_ID]
					,[QTY]
				)
		SELECT
			[x].[Rec].[query]('./ERP_RECEPTION_DOCUMENT_DETAIL_ID').[value]('.',
											'int') [TRANS_ID]
			,[x].[Rec].[query]('./MATERIAL_ID').[value]('.',
											'varchar(50)') [TRANS_TYPE]
			,[x].[Rec].[query]('./QTY').[value]('.', 'int') [TRANS_DATE_TIME]
		FROM
			@XML.[nodes]('/Data/documents/deposit') AS [x] ([Rec]);

    -- ------------------------------------------------------------------------------------
    -- Actualizamos el detalle de la recepcion 
    -- ------------------------------------------------------------------------------------

		UPDATE
			[ERD]
		SET	
			[ERD].[QTY_ASSIGNED] = [RX].[QTY]
		FROM
			[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [ERD]
		INNER JOIN @RESULT_XML [RX] ON ([ERD].[ERP_RECEPTION_DOCUMENT_DETAIL_ID] = [RX].[ERP_RECEPTION_DOCUMENT_DETAIL_ID]);


		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo];

	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];
	END CATCH;
END;