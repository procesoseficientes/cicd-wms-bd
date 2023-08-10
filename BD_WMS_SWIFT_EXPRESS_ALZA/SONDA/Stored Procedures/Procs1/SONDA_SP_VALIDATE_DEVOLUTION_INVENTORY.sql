﻿-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	11/15/2017 @ A-TEAM Sprint   
-- Description:			SP que obtiene los registros de 

/*
-- Ejemplo de Ejecucion:
		DECLARE @DEVOLUTION_ID INT;

				EXEC [SONDA].[SONDA_SP_VALIDATE_DEVOLUTION_INVENTORY]
				@DOC_SERIE = 'GUA0032@ARIUM'
				,@DOC_NUM = 23
				,@DEVOLUTION_INVENTORY_HEADER_ID = @DEVOLUTION_ID OUTPUT
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_VALIDATE_DEVOLUTION_INVENTORY](
	@DOC_SERIE VARCHAR(250)
	,@DOC_NUM INT
	,@DEVOLUTION_INVENTORY_HEADER_ID INT OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @DEVOLUTION_ID INT;
	
	--
	SELECT @DEVOLUTION_ID = [DEVOLUTION_ID]
	FROM [SONDA].[SONDA_DEVOLUTION_INVENTORY_HEADER]
	WHERE [DOC_SERIE] = @DOC_SERIE
	AND [DOC_NUM] = @DOC_NUM
	
	--
	IF(@DEVOLUTION_ID IS NOT NULL) BEGIN
		SET @DEVOLUTION_INVENTORY_HEADER_ID = @DEVOLUTION_ID
	END
	
	--
END
