﻿-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	4/30/2018 @ GForce-Team Sprint Capibara
-- Description:			Obtiene el formato de impresion de estado

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_STATUS_PRINT_INFO]
					@CODE_STATUS = 'ESTADO_DEFAULT'
					,@TASK_ID = 295281
					,@LOGIN = 'ACAMACHO'
					,@CLIENT_OWNER = 'wms'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_STATUS_PRINT_INFO] (
		@CODE_STATUS VARCHAR(50)
		,@TASK_ID INT
		,@LOGIN VARCHAR(25)
		,@CLIENT_OWNER VARCHAR(50)
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE
		@NAME_STATUS VARCHAR(100)
		,@DESCRIPTION VARCHAR(200)
		,@STATUS_LOCK VARCHAR(50)
		,@CODE_SUPPLIER VARCHAR(50)
		,@NAME_SUPPLIER VARCHAR(100)
		,@LABEL_SUPPLIER VARCHAR(50);

	--
	SELECT
		@NAME_STATUS = [PARAM_CAPTION]
		,@DESCRIPTION = [TEXT_VALUE]
		,@STATUS_LOCK = [SPARE1]
	FROM
		[wms].[OP_WMS_CONFIGURATIONS]
	WHERE
		[PARAM_TYPE] = 'ESTADO'
		AND [PARAM_GROUP] = 'ESTADOS'
		AND [PARAM_NAME] = @CODE_STATUS;

	--
	SELECT TOP 1
		@CODE_SUPPLIER = [RDH].[CODE_SUPPLIER]
		,@NAME_SUPPLIER = [RDH].[NAME_SUPPLIER]
		,@LABEL_SUPPLIER = ' Proveedor: '
	FROM
		[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RDH]
	WHERE
		[RDH].[TASK_ID] = @TASK_ID;
	--
	IF @CODE_SUPPLIER IS NULL
	BEGIN
		SELECT TOP 1
			@CODE_SUPPLIER = [CLIENT_CODE]
			,@NAME_SUPPLIER = [CLIENT_NAME]
			,@LABEL_SUPPLIER = ' Cliente: '
		FROM
			[wms].[OP_WMS_VIEW_CLIENTS]
		WHERE
			[CLIENT_CODE] LIKE '%' + @CLIENT_OWNER + '%' COLLATE DATABASE_DEFAULT;	                              
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
	-- Etiqueta 2x3
		SELECT
			@NAME_STATUS [NAME_STATUS]
			,@DESCRIPTION [DESCRIPTION]
			,@STATUS_LOCK [STATUS_LOCK]
			,@CODE_SUPPLIER [CODE_SUPPLIER]
			,@NAME_SUPPLIER [NAME_SUPPLIER]
			,@LABEL_SUPPLIER [LABEL_SUPPLIER]
			,N'! 0 50 50 436 1 
! U1 LMARGIN 10
! U1 PAGE-WIDTH 1400
LEFT 570 T 0 3 3 5 Estado:' + @NAME_STATUS + '
LEFT 570 T 0 3 0 45 Fecha: '
			+ CAST(GETDATE() AS VARCHAR(100)) + '
LEFT 570 T 0 3 0 85 Operador: ' + @LOGIN + '
LEFT 570 T 0 3 0 125 Descripcion:
LEFT 570 T 0 3 0 165  '
			+ CASE	WHEN LEN(@DESCRIPTION) <= 34
					THEN @DESCRIPTION
					ELSE SUBSTRING(@DESCRIPTION, 0, 34) + '
				'
				END + '
LEFT 570 T 0 3 0 195  '
			+ CASE	WHEN LEN(@DESCRIPTION) > 34
					THEN SUBSTRING(@DESCRIPTION, 34,
									LEN(@DESCRIPTION)) + '
								'
					ELSE '
				'
				END
			+ CASE	WHEN LEN(@NAME_SUPPLIER) > 0
					THEN 'LEFT 570 T 0 3 0 135  '
							+ @NAME_SUPPLIER
					ELSE ''
				END + '

LINE 0 300 570 300 2' + CHAR(13) + '
CENTER 570 T 0 2 0 310 ' + @LOGIN + ' / '
			+ CONVERT(VARCHAR(50), GETDATE()) + '' + CHAR(13)
			+ '
CENTER 570 T 0 1 0 340 www.mobilityscm.com' + CHAR(13) + '
L 5 T 0 2 0 130 ' + CHAR(13) + '

PRINT
! U1 getvar "device.host_status"
' AS [FORMAT];

	END;
	ELSE
	BEGIN 
	-- Etiqueta 3x3
		SELECT
			@NAME_STATUS [NAME_STATUS]
			,@DESCRIPTION [DESCRIPTION]
			,@STATUS_LOCK [STATUS_LOCK]
			,@CODE_SUPPLIER [CODE_SUPPLIER]
			,@NAME_SUPPLIER [NAME_SUPPLIER]
			,@LABEL_SUPPLIER [LABEL_SUPPLIER]
			,N'! 0 50 50 635 1 
! U1 LMARGIN 10
! U1 PAGE-WIDTH 1400
LEFT 570 T 0 3 3 20 Estado:' + @NAME_STATUS + '
LEFT 570 T 0 3 0 70 Fecha: '
			+ CAST(GETDATE() AS VARCHAR(100)) + '
LEFT 570 T 0 3 0 120 Operador: ' + @LOGIN + '
LEFT 570 T 0 3 0 170 Descripcion:
LEFT 570 T 0 3 0 220  '
			+ CASE	WHEN LEN(@DESCRIPTION) <= 34
					THEN @DESCRIPTION
					ELSE SUBSTRING(@DESCRIPTION, 0, 34) + '
				'
				END + '
LEFT 570 T 0 3 0 270  '
			+ CASE	WHEN LEN(@DESCRIPTION) > 34
					THEN SUBSTRING(@DESCRIPTION, 34,
									LEN(@DESCRIPTION)) + '
								'
					ELSE '
				'
				END
			+ CASE	WHEN LEN(@NAME_SUPPLIER) > 0
					THEN 'LEFT 570 T 0 3 0 320  '
							+ @NAME_SUPPLIER
					ELSE ''
				END + '

LINE 0 500 570 500 2
CENTER 570 T 0 2 0 510 ' + @LOGIN + ' / '
			+ CONVERT(VARCHAR(50), GETDATE()) + '
CENTER 570 T 0 1 0 550 www.mobilityscm.com
L 5 T 0 2 0 130 
PRINT
! U1 getvar "device.host_status"
' AS [FORMAT];
	END; 


END;