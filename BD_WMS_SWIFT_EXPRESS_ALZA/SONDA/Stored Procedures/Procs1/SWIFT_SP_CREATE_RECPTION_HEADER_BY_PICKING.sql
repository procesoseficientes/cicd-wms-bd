-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	25-02-2016
/* Description: SP que INSERTA un RECEPTION_HEADER 
				en base al PICKING_HEADER 
				que recibe como parametro.
*/

/*
-- Ejemplo de Ejecucion:
		EXEC [SONDA].[SWIFT_SP_CREATE_RECPTION_HEADER_BY_PICKING]
			@PICKING_HEADER = 1020
		---------------------------------------------------------
		SELECT TYPE_RECEPTION
			,CODE_PROVIDER
			,CODE_USER
			,REFERENCE
			,DOC_SAP_RECEPTION
			,STATUS
			,LAST_UPDATE
			,SCHEDULE_FOR
			,SEQ
			,COMMENTS
			,SOURCE_DOC_TYPE
			,SOURCE_DOC
			,TARGET_DOC
		FROM [SONDA].[SWIFT_RECEPTION_HEADER]
		WHERE RECEPTION_HEADER = 2024
*/
-- =============================================

CREATE PROCEDURE [SONDA].[SWIFT_SP_CREATE_RECPTION_HEADER_BY_PICKING]
(
	@PICKING_HEADER INT
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ID INT

	-- ------------------------------------------------------------------------------------
	-- INSERTA RECEPTION_HEADER 
	-- ------------------------------------------------------------------------------------
	BEGIN TRY
	INSERT INTO [SONDA].[SWIFT_RECEPTION_HEADER] (
		TYPE_RECEPTION
		,CODE_PROVIDER
		,CODE_USER
		,DOC_SAP_RECEPTION
		,STATUS
		,LAST_UPDATE
		,SCHEDULE_FOR
		,SEQ
		,SOURCE_DOC_TYPE
		,SOURCE_DOC
		)
	SELECT 'PICKING' AS TYPE_RECEPTION
			,PH.CODE_CLIENT
			,PH.CODE_USER
			,PH.DOC_SAP_RECEPTION
			,'ASSIGNED' AS STATUS
			,GETDATE() AS LAST_UPDATE
			,(CAST(GETDATE() AS DATE)) AS SCHEDULE_FOR
			,2 AS SEQ
			,SC.GROUP_CLASSIFICATION
			,PH.PICKING_HEADER
		FROM [SONDA].[SWIFT_PICKING_HEADER] AS PH
		INNER JOIN [SONDA].[SWIFT_CLASSIFICATION] AS SC ON(
			SC.CLASSIFICATION = PH.CLASSIFICATION_PICKING
		)
		WHERE PH.PICKING_HEADER = @PICKING_HEADER
		SET @ID = SCOPE_IDENTITY()
	-- ------------------------------------------------------------------------------------
	-- DEVUELVE EL ID 
	-- ------------------------------------------------------------------------------------
	SELECT @ID AS ID

	END TRY
	BEGIN CATCH
		DECLARE @ERROR VARCHAR(1000) = ERROR_MESSAGE()
		PRINT 'CATCH: ' + @ERROR
		RAISERROR (@ERROR,16,1)
	END CATCH

END
