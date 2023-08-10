-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion:	30-08-2016
-- Description:			Se creo table para las etiquetas del scouting temporal

/*
  -- Ejemplo de Ejecucion:
		EXEC [SONDA].[SWIFT_SP_INSERT_TAG_X_CUSTOMER_TEMP]
			@TAG_COLOR = '#123ACD'
			,@CUSTOMER = 'SO1'
		--
		SELECT * FROM [SONDA].[SWIFT_TAG_X_CUSTOMER_NEW_TEMP]
			
        
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_INSERT_TAG_X_CUSTOMER_TEMP]
	 @TAG_COLOR varchar(8)
	 ,@CUSTOMER varchar(50)

AS
BEGIN	
	SET NOCOUNT ON;
	--
	INSERT INTO [SONDA].[SWIFT_TAG_X_CUSTOMER_NEW_TEMP]([TAG_COLOR], [CUSTOMER])
	VALUES(@TAG_COLOR, @CUSTOMER)	
END
