
/* ==========================================
Autor:				diego.as
Fecha de Creacion: 
Descripcion:		SP que Obtiene TODOS los parametros de un GRUPO en especifico

Ejemplo de Ejecucion:

	EXEC [SONDA].[SONDA_SP_GET_PARAMETER_BY_GROUP]
		@GROUP_ID = 'CONSIGNMENT'
========================================== */
CREATE PROCEDURE [SONDA].[SONDA_SP_GET_PARAMETER_BY_GROUP]
(
	@GROUP_ID VARCHAR(250)
) AS
BEGIN
	SELECT
		[P].[IDENTITY]
		,[P].[GROUP_ID]
		,[P].[PARAMETER_ID]
		,[P].[VALUE]
	FROM [SONDA].[SWIFT_PARAMETER] AS P
	WHERE [P].[GROUP_ID] = @GROUP_ID
END
