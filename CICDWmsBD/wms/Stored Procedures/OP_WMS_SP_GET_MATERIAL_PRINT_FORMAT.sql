-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	4/27/2018 @ GForce-Team Sprint Capibara 
-- Description:			Obtiene el formato de impresion de material

-- Autor:				henry.rodriguez
-- Fecha de Creacion: 	05/01/2020 @ GForce-Team Sprint Crystalmaiden
-- Description:			Se cambia inner join por left join en caso de no tener configurado companias

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_MATERIAL_PRINT_FORMAT]
					@MATERIAL_ID = 'viscosa/VDE1001'
					,@LOGIN = 'ACAMACHO'
					,@BARCODE_ID = 'viscosa/VDE1001C'<
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_MATERIAL_PRINT_FORMAT] (
		@MATERIAL_ID VARCHAR(50)
		,@LOGIN VARCHAR(25)
		,@BARCODE_ID VARCHAR(100) = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE
		@COMPANY VARCHAR(100)
		,@MATERIAL_NAME VARCHAR(200);


	IF (@BARCODE_ID IS NULL)
	BEGIN                        
		SELECT TOP 1
			@BARCODE_ID = [BARCODE_ID]
			,@MATERIAL_NAME = [MATERIAL_NAME]
			,@COMPANY = UPPER([CLIENT_OWNER]) + ' - '
			+ isnull([C].[COMPANY_NAME],'ALZAHN')
		FROM
			[wms].[OP_WMS_MATERIALS] [M]
		LEFT JOIN [wms].[OP_WMS_COMPANY] [C] ON [C].[CLIENT_CODE] = [M].[CLIENT_OWNER]
		WHERE
			(
				[MATERIAL_ID] = @MATERIAL_ID
				OR [BARCODE_ID] = @MATERIAL_ID
				OR [ALTERNATE_BARCODE] = @MATERIAL_ID
			);
		PRINT @BARCODE_ID;
	END;
	ELSE
	BEGIN
		SELECT TOP 1
			@MATERIAL_NAME = [M].[MATERIAL_NAME] + '-'
			+ [UMM].[MEASUREMENT_UNIT]
			,@COMPANY = [M].[CLIENT_OWNER] + ' '
			+ [C].[COMPANY_NAME]
		FROM
			[wms].[OP_WMS_MATERIALS] [M]
		INNER JOIN [wms].[OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL] [UMM] ON [UMM].[MATERIAL_ID] = [M].[MATERIAL_ID]
		INNER JOIN [wms].[OP_WMS_COMPANY] [C] ON [C].[CLIENT_CODE] = [M].[CLIENT_OWNER]
		WHERE
			[M].[MATERIAL_ID] = @MATERIAL_ID
			AND (
					[UMM].[BARCODE] = @BARCODE_ID
					OR [UMM].[ALTERNATIVE_BARCODE] = @BARCODE_ID
				);
	END;

	DECLARE	@LABEL_SIZE VARCHAR(25);
	SELECT
		@LABEL_SIZE = [VALUE]
	FROM
		[wms].[OP_WMS_PARAMETER]
	WHERE
		[PARAMETER_ID] = 'LABEL_SIZE';

	IF @LABEL_SIZE = '3X2'
	BEGIN

		SELECT
			'! 0 50 50 436 1
! U1 LMARGIN 0
! U1 PAGE-WIDTH 1400
CENTER 570 T 0 5 3 10 ' + @COMPANY + '
LINE 0 50 570 50 2'
			+ CASE	WHEN LEN(@MATERIAL_NAME) <= 45 THEN '
CENTER 570 T 0 5 0 60 ' + @MATERIAL_NAME + '
'					ELSE '
CENTER 570 T 0 2.8 0 60 ' + @MATERIAL_NAME
				END + '
BARCODE 128 1 1 100 20 110 ' + @BARCODE_ID + '
CENTER 570 T 0 5 0 230 ' + @BARCODE_ID + '
LINE 0 300 570 300 2
CENTER 570 T 0 2 0 310 ' + @LOGIN + ' / '
			+ CONVERT(VARCHAR(50), GETDATE()) + '
CENTER 570 T 0 1 0 340 www.procesoseficientes.com
L 5 T 0 2 0 130
PRINT
! U1 getvar "device.host_status"
' AS [FORMAT];
	END; 
	ELSE
	BEGIN

		SELECT
			'! 0 50 50 635 1
! U1 LMARGIN 10
! U1 PAGE-WIDTH 1400
CENTER 570 T 0 3 0 10 ' + @COMPANY + '
LINE 0 60 570 60 2 
' + CASE	WHEN LEN(@MATERIAL_NAME) <= 45 THEN '
CENTER 570 T 0 5 0 70 ' + @MATERIAL_NAME + '
'			ELSE '
CENTER 570 T 0 2.8 0 70 
' + @MATERIAL_NAME
	END + '
'
			+ CASE	WHEN LEN(@BARCODE_ID) < 10
					THEN 'BARCODE 128 3 1 200 20 140 '
					ELSE 'BARCODE 128 2 1 200 20 140 '
				END + @BARCODE_ID + '
CENTER 570 T 0 6 0 420 ' + @BARCODE_ID + '
LINE 0 500 570 500 2
CENTER 570 T 0 2 0 510 ' + @LOGIN + ' / '
			+ CONVERT(VARCHAR(50), GETDATE()) + '
CENTER 570 T 0 1 0 550 www.procesoseficientes.com
L 5 T 0 2 0 130 
PRINT
! U1 getvar "device.host_status"
' AS [FORMAT];

	END; 
END;