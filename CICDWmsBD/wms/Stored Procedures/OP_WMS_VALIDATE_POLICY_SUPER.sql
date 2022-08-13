-- =================================================
-- Autor:				michael.mazariegos
-- Fecha de creacion:	27/12/2019 @ G-Force - TEAM Sprint Oklahoma@Swift
-- Historia/Bug:		Product Backlog Item 34681: Auditoria de Apertura Contenedor Fiscal
-- Descripcion:			sp que valida si la poliza a buscar existe.

/*
-- Ejemplo de Ejecucion:
	EXEC [wms].[OP_WMS_VALIDATE_POLICY_SUPER]
	@POLICY_CODE = '2015232'
*/
CREATE PROCEDURE [wms].[OP_WMS_VALIDATE_POLICY_SUPER]
(@POLICY_CODE VARCHAR(25))
AS
BEGIN
    IF NOT EXISTS
    (
        SELECT [PH].[CODIGO_POLIZA]
        FROM [wms].[OP_WMS_POLIZA_HEADER] AS [PH]
        WHERE [PH].[CODIGO_POLIZA] = @POLICY_CODE
    )
    BEGIN
        SELECT 1 AS [RESULT],
               'NO EXISTE LA POLIZA' [MESSAGE],
               0 [CODE];
    END;
    ELSE
    BEGIN
        -- ---------------------------------------------------------------
        -- SI EXISTE ENTONCES MOSTRAMOS UN MENSAJE DE PROCESO EXITOSO
        -- ---------------------------------------------------------------
        SELECT 1 AS [RESULT],
               'Proceso Exitoso' [MESSAGE],
               1 [CODE];
    END;
END;