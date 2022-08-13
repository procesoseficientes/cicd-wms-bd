-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-01-13 @ Team ERGON - Sprint ERGON 1
-- Description:	 




/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_INSERT_RECEPTION_GENERAL_POLICY] @ORDER_NUM = '23123'
                                                           ,@DOC_DATE = '2017-01-13 12:04:20.617'
                                                           ,@LAST_UPDATED_BY = 'ADMIN'
                                                           ,@CLIENT_CODE = 'C00030'
                                                           ,@STATUS = 'Created'
                                                           ,@TRADE_AGREEMENT = '1019'
                                                           ,@TYPE = 'INGRESO'
                                                           ,@INSURANCE_POLICY = '46'
                                                           ,@OPERATOR = 'ADMIN'
                                                           ,@TRASLATION = 'NO'

  SELECT * FROM [wms].[OP_WMS_POLIZA_HEADER] [OWPH]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_INSERT_RECEPTION_GENERAL_POLICY](
  @ORDER_NUM VARCHAR(50)
, @DOC_DATE DATETIME
, @LAST_UPDATED_BY VARCHAR(50)
, @CLIENT_CODE VARCHAR(50)
, @STATUS VARCHAR(50) = 'Created'
, @TRADE_AGREEMENT VARCHAR(50)
, @TYPE VARCHAR(50) = 'INGRESO'
, @INSURANCE_POLICY VARCHAR(50)
, @TRASLATION VARCHAR(50) = 'NO'
, @ASSIGNED_TO VARCHAR(50) = ''
)
AS
BEGIN
	SET NOCOUNT ON;

DECLARE @DOC_ID int 
	--
INSERT INTO [wms].[OP_WMS_POLIZA_HEADER] 
  ([NUMERO_ORDEN]
  , [REGIMEN]
  , [FECHA_LLEGADA]
  , [LAST_UPDATED_BY]
  , [LAST_UPDATED]
  , [STATUS]
  , [ACUERDO_COMERCIAL]
  , [WAREHOUSE_REGIMEN]
  , [CLIENT_CODE]
  , [CODIGO_POLIZA]
  , [FECHA_DOCUMENTO]
  , [TIPO]
  , [POLIZA_ASEGURADA]
  , [TRANSLATION]
  , [POLIZA_ASSIGNEDTO] 
  )
  VALUES (@ORDER_NUM, 'GENERAL', @DOC_DATE, @LAST_UPDATED_BY, GETDATE(), @STATUS,@TRADE_AGREEMENT, 'GENERAL', @CLIENT_CODE,'', @DOC_DATE, @TYPE,@INSURANCE_POLICY, @TRASLATION,  @ASSIGNED_TO );
 
			SET @DOC_ID = SCOPE_IDENTITY()
    
        PRINT @DOC_ID 
      UPDATE [wms].[OP_WMS_POLIZA_HEADER] SET [CODIGO_POLIZA] = @DOC_ID WHERE [DOC_ID] = @DOC_ID
	  			PRINT 'Marca como bloqueado en SAE '

			UPDATE 
				FACT 
			SET	
				FACT.BLOQ='W',
				FACT.[ENLAZADO] = 'W'
			FROM [SAE70EMPRESA01].[dbo].[COMPO01] FACT
			WHERE CVE_DOC=@ORDER_NUM		
					UPDATE 
				FACT 
			SET	
				FACT.BLOQ='W',
				FACT.[ENLAZADO] = 'W'
			FROM [SAE70EMPRESA01].[dbo].[FACTF01] FACT
			WHERE CVE_DOC=@ORDER_NUM	
	  PRINT 'END UPDATE'
	IF @@error = 0 BEGIN		
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, CONVERT(VARCHAR(16), @DOC_ID) DbData
	END		
	ELSE BEGIN		
		SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo
	END
    		
  END
