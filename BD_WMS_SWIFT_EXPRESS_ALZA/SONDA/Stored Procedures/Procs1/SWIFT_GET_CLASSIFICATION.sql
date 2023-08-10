/*===============================================
-- Autor: 
-- Fecha de Creacion: 
-- Descripcion

-- Modificado:	14-10-2016 @ TEAM-A Sprint 3
-- Autor:		diego.as
-- Descripcion:	Sp que obtiene las CLASSIFICACION en base al GRUPO (GROUP_CLASSIFICATION)
				que se le envia como parametro.	
	
	Ejemplo de Ejecucion:
		--
		EXEC [SONDA].[SWIFT_GET_CLASSIFICATION]
			@GROUP = 'NO_INVOICE_REASON_POS'
===============================================*/
CREATE PROCEDURE [SONDA].[SWIFT_GET_CLASSIFICATION]
	@GROUP VARCHAR(50)
AS
SELECT     
	CLASSIFICATION, 
	NAME_CLASSIFICATION, 
	PRIORITY_CLASSIFICATION, 
	VALUE_TEXT_CLASSIFICATION, 
	MPC01, 
	GROUP_CLASSIFICATION
FROM         
	[SONDA].[SWIFT_CLASSIFICATION]
WHERE     
	(GROUP_CLASSIFICATION = @GROUP)
