-- =============================================


-- Autor:	        marvin.solares
-- Fecha de Creacion: 	20181810 GForce@Mamba
-- Description:		Se que obtiene la ultima licencia procesada en reubicacion total o parcial

/*
-- Ejemplo de Ejecucion:
		--
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_LAST_LICENSE_REALLOC_BY_USER]
	@LICENSE_ID NUMERIC(18, 0)
	,@LOGIN_ID VARCHAR(50)
AS
BEGIN
	DECLARE	@LAST_LICENSE_ID NUMERIC(18, 0);


	SELECT
		@LAST_LICENSE_ID = [LAST_LICENSE_USED_IN_FAST_PICKING]
	FROM
		[wms].[OP_WMS_LICENSES]
	WHERE
		[LICENSE_ID] = @LICENSE_ID
		AND [LAST_UPDATED_BY] = @LOGIN_ID;

	IF @LAST_LICENSE_ID IS NULL
	BEGIN
		SET @LAST_LICENSE_ID = @LICENSE_ID;
	END;

	SELECT
		1 AS [Resultado]
		,'Proceso Exitoso' AS [Mensaje]
		,1 AS [Codigo]
		,CAST(@LAST_LICENSE_ID AS VARCHAR) AS [DbData];
END;