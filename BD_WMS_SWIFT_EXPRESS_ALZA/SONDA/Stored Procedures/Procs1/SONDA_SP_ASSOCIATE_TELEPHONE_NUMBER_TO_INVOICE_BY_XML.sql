-- =============================================
-- Autor:					diego.as
-- Fecha de Creacion: 		7/30/2017 @ Reborn-Team Sprint Bearbeitung
-- Description:			    SP que actualiza el numero de telefono de una factura

/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].SONDA_SP_ASSOCIATE_TELEPHONE_NUMBER_TO_INVOICE_BY_XML
		@XML = ''
		,@JSON = NULL
*/
-- =============================================
CREATE PROCEDURE [SONDA].SONDA_SP_ASSOCIATE_TELEPHONE_NUMBER_TO_INVOICE_BY_XML(
	@XML XML
	,@JSON VARCHAR(MAX) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @INVOICE_TO_ASSOCIATE TABLE (
		INVOICE_NUM INT
		,POS_TERMINAL VARCHAR(250)
		,AUTH_ID VARCHAR(250)
		,SAT_SERIE VARCHAR(250)
		,ID INT
		,TELEPHONE_NUMBER VARCHAR(50)
	)
	--
	DECLARE 
		@INVOICE_NUM INT
		,@POS_TERMINAL VARCHAR(250)
		,@AUTH_ID VARCHAR(250)
		,@SAT_SERIE VARCHAR(250)
		,@ID INT
		,@TELEPHONE_NUMBER VARCHAR(50)

	
	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Obtiene las facturas
		-- ------------------------------------------------------------------------------------
		INSERT INTO @INVOICE_TO_ASSOCIATE
				(
					[INVOICE_NUM]
					,[POS_TERMINAL]
					,[AUTH_ID]
					,[SAT_SERIE]
					,[ID]
					,[TELEPHONE_NUMBER]
				)
		SELECT
			x.Rec.query('./InvoiceId').value('.', 'int')
			,x.Rec.query('./PosTerminal').value('.', 'varchar(250)')
			,x.Rec.query('./AuthId').value('.', 'varchar(250)')
			,x.Rec.query('./SatSerie').value('.', 'varchar(250)')
			,x.Rec.query('./IdBo').value('.', 'int')
			,x.Rec.query('./TelephoneNumber').value('.', 'varchar(50)')
		FROM @XML.nodes('Data/invoices') AS x(Rec)
		
		-- ------------------------------------------------------------------------------------
		-- Se recorre cada factura
		-- ------------------------------------------------------------------------------------
		WHILE EXISTS(SELECT TOP 1 1 FROM @INVOICE_TO_ASSOCIATE)
		BEGIN
			-- -------------------------------------------------------------------------------
			-- Se obtienen los datos de la factura a evaluar
			-- -------------------------------------------------------------------------------
			SELECT TOP 1
				@INVOICE_NUM = ITA.[INVOICE_NUM]
				,@POS_TERMINAL = ITA.[POS_TERMINAL]
				,@AUTH_ID = ITA.[AUTH_ID]
				,@SAT_SERIE = ITA.[SAT_SERIE]
				,@ID = [ITA].[ID]
				,@TELEPHONE_NUMBER = ITA.[TELEPHONE_NUMBER]
			FROM @INVOICE_TO_ASSOCIATE AS ITA
			
			-- ------------------------------------------------------------------------------------
			-- Se actualizan los datos de la factura
			-- ------------------------------------------------------------------------------------
			UPDATE [SONDA].[SONDA_POS_INVOICE_HEADER]
			SET [TELEPHONE_NUMBER] = @TELEPHONE_NUMBER
			WHERE [INVOICE_ID] = @INVOICE_NUM
			AND [POS_TERMINAL] = @POS_TERMINAL
			AND [CDF_RESOLUCION] = @AUTH_ID
			AND [CDF_SERIE] = @SAT_SERIE
			AND ID = @ID

			-- ------------------------------------------------------------------------------------
			-- Elimina la factura evaluada
			-- ------------------------------------------------------------------------------------
			DELETE FROM @INVOICE_TO_ASSOCIATE 
			WHERE [INVOICE_NUM] = @INVOICE_NUM
			AND [POS_TERMINAL] = @POS_TERMINAL
			AND [AUTH_ID] = @AUTH_ID
			AND [SAT_SERIE] = @SAT_SERIE
			AND ID = @ID
			AND [TELEPHONE_NUMBER] = @TELEPHONE_NUMBER
		END
	END TRY
	BEGIN CATCH
		DECLARE @ERROR VARCHAR(1000) = ERROR_MESSAGE()
		PRINT 'CATCH: ' + @ERROR
		RAISERROR (@ERROR,16,1)
	END CATCH
END
