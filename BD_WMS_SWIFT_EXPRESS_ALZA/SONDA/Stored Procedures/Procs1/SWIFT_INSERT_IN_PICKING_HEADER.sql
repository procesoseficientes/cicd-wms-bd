﻿-- =============================================
-- Autor:				jose.garcia
-- Fecha de Creacion: 	25-01-2016
-- Description:			Agrego el parametro CODE_WAREHOUSE_SOURCE para la correcta inserción 
-- [*MODIFICACIÓN*]		en la tabla [SWIFT_PICKING_HEADER]

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_INSERT_IN_PICKING_HEADER]	
			     @PICKING_HEADER= 01252016
				,@CODE_WAREHOUSE_SOURCE='01252016'
				,@COMMENTS ='01252016'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_INSERT_IN_PICKING_HEADER]
	@PICKING_HEADER INT
	,@COMMENTS VARCHAR(MAX)
	,@CODE_WAREHOUSE_SOURCE varchar(50)
AS
	INSERT INTO SWIFT_PICKING_HEADER
		(CLASSIFICATION_PICKING
		,CODE_CLIENT
		,CODE_USER
		,REFERENCE
		,DOC_SAP_RECEPTION
		,STATUS
		,LAST_UPDATE
		,SCHEDULE_FOR
		,SEQ
		,COMMENTS
		,CODE_WAREHOUSE_SOURCE)
	SELECT CLASSIFICATION_PICKING
		,CODE_CLIENT
		,CODE_USER
		,REFERENCE
		,DOC_SAP_RECEPTION
		,STATUS
		,LAST_UPDATE
		,SCHEDULE_FOR
		,SEQ
		,@COMMENTS 
		,@CODE_WAREHOUSE_SOURCE
	FROM SWIFT_TEMP_PICKING_HEADER 
	WHERE PICKING_HEADER=@PICKING_HEADER