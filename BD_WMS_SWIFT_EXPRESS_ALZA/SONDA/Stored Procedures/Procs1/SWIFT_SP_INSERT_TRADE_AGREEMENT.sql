-- =============================================
-- Autor:				        hector.gonzalez
-- Fecha de Creacion: 	12-09-2016 @ A-TEAM Sprint 1
-- Description:			    SP que inserta los acuerdos comerciales

-- Modificacion 12-09-2016 @ A-TEAM Sprint 1
						-- alberto.ruiz
						-- Se agrego parametro de LINKED_TO

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].SWIFT_SP_INSERT_TRADE_AGREEMENT
  @CODE_TRADE_AGREEMENT = 'CodeTradeAgreement2'
  ,@NAME_TRADE_AGREEMENT = 'NameTradeAgreement2'
  ,@DESCRIPTION_TRADE_AGREEMENT = 'DescriptionTradeAgreement'
  ,@VALID_START_DATETIME = '20160909 00:05:00.000'
  ,@VALID_END_DATETIME = '20161009 00:05:00.000'
  ,@STATUS = 1
  ,@LAST_UPDATE_BY = 'prueba@SONDA'
  ,@LINKED_TO = 'CUSTOMER'

				-- 
				SELECT * FROM [SONDA].SWIFT_TRADE_AGREEMENT
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_INSERT_TRADE_AGREEMENT](
	@CODE_TRADE_AGREEMENT VARCHAR(50)
  ,@NAME_TRADE_AGREEMENT VARCHAR(250)
  ,@DESCRIPTION_TRADE_AGREEMENT VARCHAR(250)
  ,@VALID_START_DATETIME DATETIME 
  ,@VALID_END_DATETIME DATETIME
  ,@STATUS INT
  ,@LAST_UPDATE_BY VARCHAR(50)
  ,@LINKED_TO VARCHAR(250)
)
AS
BEGIN
	BEGIN TRY
		DECLARE @ID INT
		--
		INSERT INTO [SONDA].SWIFT_TRADE_AGREEMENT (
			CODE_TRADE_AGREEMENT
      ,NAME_TRADE_AGREEMENT
      ,DESCRIPTION_TRADE_AGREEMENT
      ,VALID_START_DATETIME
      ,VALID_END_DATETIME
      ,STATUS
      ,LAST_UPDATE
      ,LAST_UPDATE_BY
	  ,LINKED_TO
		) VALUES (
      	@CODE_TRADE_AGREEMENT 
		,@NAME_TRADE_AGREEMENT 
		,@DESCRIPTION_TRADE_AGREEMENT 
		,@VALID_START_DATETIME 
		,DATEADD(SECOND,-1,DATEADD(DAY,1,@VALID_END_DATETIME))
		,@STATUS 
		,GETDATE()
		,@LAST_UPDATE_BY 
		,@LINKED_TO
		)
		--
		SET @ID = SCOPE_IDENTITY()
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, CAST(@ID AS VARCHAR) DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN 'Ya existe un acuerdo comercial con el mismo codigo de canal'
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
