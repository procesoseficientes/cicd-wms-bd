-- =============================================
-- Autor:				Yaqueline Canahui
-- Fecha de Creacion: 	09-Aug-2018 @ G-FORCE Sprint Hormiga
-- Description:			SP que obtiene los roles.

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_ROLE]
				--
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_ROLE]
AS
BEGIN
  SELECT * FROM SONDA.SWIFT_ROLE
END
