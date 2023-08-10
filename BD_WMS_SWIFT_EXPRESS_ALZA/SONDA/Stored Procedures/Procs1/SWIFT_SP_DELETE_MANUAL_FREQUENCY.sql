CREATE PROCEDURE [SONDA].[SWIFT_SP_DELETE_MANUAL_FREQUENCY]	
    @XML AS XML
		
AS
BEGIN TRY
------------------------------------------------------------
--Creamos tablas temporales para obtener el ID frequency. 
------------------------------------------------------------
	DECLARE @TABLE_IDS TABLE(
		ID_FREQUENCY VARCHAR(50)
	)

	INSERT	INTO @TABLE_IDS (ID_FREQUENCY)
		SELECT
			[x].[Rec].[query]('./IDS_FREQUENCY').[value]('.' ,'varchar(50)')
		FROM
			@XML.[nodes]('ArrayOfFrecuencia/Frecuencia') AS [x] ([Rec]);

	DECLARE @TEMP_TABLE_IDS TABLE(
		ID_FREQUENCY INT
	)

	INSERT INTO @TEMP_TABLE_IDS (ID_FREQUENCY)  
	SELECT ID_FREQUENCY FROM SONDA.SWIFT_FREQUENCY_X_CUSTOMER 
	WHERE CONVERT(VARCHAR(30),ID_FREQUENCY) + CODE_CUSTOMER IN  (SELECT * FROM @TABLE_IDS);

------------------------------------------------------------	
--Eliminamos las secuencias del cliente que se encontro (hijos)
------------------------------------------------------------

	DELETE FROM SONDA.SWIFT_FREQUENCY_X_CUSTOMER
	WHERE  CONVERT(VARCHAR(30),ID_FREQUENCY) + CODE_CUSTOMER IN  (SELECT * FROM @TABLE_IDS);

------------------------------------------------------------
--verificamos si los aun hay hijos para eliminar al papa
------------------------------------------------------------
	
	IF NOT EXISTS(SELECT * FROM SONDA.SWIFT_FREQUENCY_X_CUSTOMER
			  WHERE ID_FREQUENCY IN (SELECT * FROM @TEMP_TABLE_IDS))
		BEGIN
			DELETE FROM SONDA.SWIFT_FREQUENCY WHERE ID_FREQUENCY IN (SELECT ID_FREQUENCY FROM @TEMP_TABLE_IDS);
		END

------------------------------------------------------------
--chequea la transaccion si fue exitoso	
------------------------------------------------------------
	IF @@error = 0 BEGIN		
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '0' DbData
	END		
	ELSE BEGIN
		
		SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo
	END

END TRY
BEGIN CATCH     
	 SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo 
END CATCH
