-- =================================================
-- Autor:				michael.mazariegos
-- Fecha de creacion:	26/12/2019 @ G-Force - TEAM Sprint Oklahoma@Swift
-- Historia/Bug:		Product Backlog Item 34681: Auditoria de Apertura Contenedor Fiscal
-- Descripcion:			sp que obtiene las imagenes asociadas a un código de póliza 

/*
-- Ejemplo de Ejecucion:
	EXEC [wms].[OP_WMS_GET_IMAGES_X_POLICY_SUPER]
	@POLICY_CODE = '2015232'
*/
CREATE   PROCEDURE [wms].[OP_WMS_GET_IMAGES_X_POLICY_SUPER]
(@POLICY_CODE VARCHAR(25))
AS
BEGIN
    SELECT IMAGE_64,
		   IMAGEN,
           CODIGO_POLIZA,
           PHOTO_ID
    FROM [wms].[OP_WMS_IMAGENES_POLIZA]
    WHERE CODIGO_POLIZA = @POLICY_CODE
          AND IMAGE_64 IS NOT NULL OR IMAGEN IS NOT NULL
    ORDER BY PHOTO_ID DESC;
END;


-- EXEC OP_WMS_GET_IMAGES_X_POLICY_SUPER