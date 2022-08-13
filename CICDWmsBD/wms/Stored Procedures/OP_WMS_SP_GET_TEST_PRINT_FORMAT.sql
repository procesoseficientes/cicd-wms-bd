-- =============================================
-- Autor:				marvin.solares
-- Fecha de Creacion: 	5/21/2018 @ GForce-Team Sprint Capibara 
-- Description:			Obtiene el formato de impresion de prueba

-- Autor:					marvin.solares
-- Fecha de Creacion: 		7/11/2018 GForce@FocaMonje 
-- Description:			    se modifica el formato para que imprima etiquetas de 3x3

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_TEST_PRINT_FORMAT]
					@LOGIN = 'ACAMACHO'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_TEST_PRINT_FORMAT] (@LOGIN VARCHAR(25))
AS
BEGIN
		DECLARE	@LABEL_SIZE VARCHAR(25)	,
		@COMPANY VARCHAR(100);

	SELECT TOP 1
		@COMPANY = [COMPANY_NAME]
	FROM
		[wms].[OP_SETUP_COMPANY];


	SELECT
		@LABEL_SIZE = [VALUE]
	FROM
		[wms].[OP_WMS_PARAMETER]
	WHERE
		[PARAMETER_ID] = 'LABEL_SIZE';

	IF @LABEL_SIZE = '3X3'
	BEGIN

	
		SELECT
			N'! 0 50 50 635 1
! U1 LMARGIN 0
! U1 PAGE-WIDTH 1400
CENTER 570 T 0 3 3 20 '+  @COMPANY+ '
CENTER 570 T 0 6 3 60 Swift 3PL
BARCODE 128 1 1 200 60 140 test_print
CENTER 570 T 0 6 0 360 Impresion prueba
LINE 0 500 570 500 2
CENTER 570 T 0 2 0 510 ' + @LOGIN + ' / '
			+ CONVERT(VARCHAR(50), GETDATE()) + '
CENTER 570 T 0 1 0 550 www.mobilityscm.com
L 5 T 0 2 0 130
PRINT
! U1 getvar "device.host_status"
' AS [FORMAT];
	END;
	ELSE
	BEGIN
		SELECT
			N'! 0 50 50 436 1
! U1 LMARGIN 0
! U1 PAGE-WIDTH 1400
CENTER 570 T 0 6 3 10 Impresion AMESA
CENTER 570 T 0 5 0 60 Swift WMS 3PL AMESA
BARCODE 128 1 1 130 20 110 PRUEBA_AMESA
CENTER 570 T 0 6 0 260 Prueba_Impresion
LINE 0 300 570 300 2
CENTER 570 T 0 2 0 310 ' + @LOGIN + ' / '
			+ CONVERT(VARCHAR(50), GETDATE()) + '
CENTER 570 T 0 1 0 340 www.mobilityscm.com
L 5 T 0 2 0 130
PRINT
! U1 getvar "device.host_status"
' AS [FORMAT];
	END;
	
END;