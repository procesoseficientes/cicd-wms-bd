-- =============================================
-- Autor:				hector.gonzalez
-- Fecha de Creacion:	20-04-2016
-- Description:			Obtiene los encabezados del Excel a descargar

-- Modificacion:			hector.gonzalez
-- Fecha de Creacion:	24-10-2016
-- Description:			  se agrando el varchar de @COLUMNAS 

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [SONDA].SWIFT_SP_GET_TEMPLATES @ID_TEMPLATE = 2
					
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_GET_TEMPLATES

  @ID_TEMPLATE INT

AS
BEGIN
  
	SET NOCOUNT ON;

DECLARE @DELIMITER VARCHAR(50),
  @COLUMNAS VARCHAR(500)
-- ------------------------------------------------------------------------------------
-- Obtiene el delimitador
--------------------------------------------------------------------------------------
  SELECT @DELIMITER = [SONDA].SWIFT_FN_GET_PARAMETER('DELIMITER','DEFAULT_DELIMITER')

-- ------------------------------------------------------------------------------------
-- Obtienen columnas
--------------------------------------------------------------------------------------
    SELECT @COLUMNAS= sdt.COLUMNS_DOC
      			FROM [SONDA].SWIFT_DOC_TEMPLATE sdt 
            WHERE sdt.ID_TEMPLATE_DOC=@ID_TEMPLATE
-- ------------------------------------------------------------------------------------
-- Se genera el split para obtener tabla de columnas
--------------------------------------------------------------------------------------


  SELECT * 
    FROM [SONDA].[SWIFT_FN_SPLIT]
        (@COLUMNAS,@DELIMITER)
  
END
