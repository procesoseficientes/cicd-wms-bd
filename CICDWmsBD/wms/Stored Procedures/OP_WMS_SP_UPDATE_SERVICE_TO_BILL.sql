

/*=============================================
Autor:				diego.as
Fecha de Creacion:	28-10-2016 @ TEAM-A SPRINT 4
Descripcion:		SP que obtiene actualiza el registro
					de servicios a cobrar  */

-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-03-14 Team ERGON - Sprint ERGON V
-- Description:	 se pone el parametro de DOC_Num opcional por el Bug #9561: Error Servicios por cobrar Tarifario 

  /*  EJEMPLO DE EJECUCION:
	EXEC [wms].OP_WMS_SP_UPDATE_SERVICE_TO_BILL
	@SERVICES_TO_BILL_ID = 1
		,@QTY = 5
		,@TRANSACTION_TYPE = 'PRUEBA'
		,@PRICE = 18.50
		,@TOTAL_AMOUNT = 92.50
		,@PROCESS_DATE = '2014-10-13 00:00:00.000'
		,@LAST_UPDATED_BY = 'PRUEBA'
		,@TYPE_CHARGE_ID = 5
		,@TYPE_CHARGE_DESCRIPTION = 'PRUEBA'
		,@CLIENT_CODE = 'C00001'
		,@CLIENT_NAME = 'ABBOTT LABORATORIOS, S.A.'
		,@IS_CHARGED = 0
		,@INVOICE_REFERENCE = 'PRUEBA'
		,@CHARGED_DATE '2014-10-10 00:00:00.000'
		,@LICENSE_ID = 5
		,@LOCATION 'P001R001C001'
		,@SERVICE_ID = 5
		,@SERVICE_CODE = 'S05'
		,@SERVICE_DESCRIPTION = 'PRUEBA'
		,@REGIMEN = 'FISCAL'
		,@DOC_NUM 5
		,@TRANSACTION_ID 5
	--
	SELECT * FROM [wms].[OP_WMS_SERVICES_TO_BILL] WHERE SERVICES_TO_BILL_ID = 1
=============================================*/
CREATE PROCEDURE [wms].[OP_WMS_SP_UPDATE_SERVICE_TO_BILL] (@SERVICES_TO_BILL_ID INT
, @QTY INT
, @TRANSACTION_TYPE VARCHAR(25)
, @PRICE NUMERIC(18, 2)
, @TOTAL_AMOUNT NUMERIC(18, 2)
, @PROCESS_DATE DATETIME
, @LAST_UPDATED_BY VARCHAR(25)
, @TYPE_CHARGE_ID INT
, @TYPE_CHARGE_DESCRIPTION VARCHAR(250)
, @CLIENT_CODE VARCHAR(25)
, @CLIENT_NAME VARCHAR(250)
, @IS_CHARGED INT
, @INVOICE_REFERENCE VARCHAR(30) = NULL
, @CHARGED_DATE DATETIME = NULL
, @LICENSE_ID NUMERIC(9, 0) = NULL
, @LOCATION VARCHAR(25) = NULL
, @SERVICE_ID INT = NULL
, @SERVICE_CODE VARCHAR(25)
, @SERVICE_DESCRIPTION VARCHAR(250)
, @REGIMEN VARCHAR(25)
, @DOC_NUM INT = NULL
, @TRANSACTION_ID INT = NULL)
AS
BEGIN TRY
  --
  UPDATE [wms].[OP_WMS_SERVICES_TO_BILL]
  SET QTY =
           CASE @QTY
             WHEN NULL THEN QTY
             ELSE @QTY
           END
     ,TRANSACTION_TYPE =
                        CASE @TRANSACTION_TYPE
                          WHEN NULL THEN TRANSACTION_TYPE
                          ELSE @TRANSACTION_TYPE
                        END
     ,PRICE =
             CASE @PRICE
               WHEN NULL THEN PRICE
               ELSE @PRICE
             END
     ,TOTAL_AMOUNT =
                    CASE @TOTAL_AMOUNT
                      WHEN NULL THEN TOTAL_AMOUNT
                      ELSE @TOTAL_AMOUNT
                    END
     ,PROCESS_DATE =
                    CASE @PROCESS_DATE
                      WHEN NULL THEN PROCESS_DATE
                      ELSE @PROCESS_DATE
                    END
     ,LAST_UPDATED_DATE = GETDATE()
     ,LAST_UPDATED_BY =
                       CASE @LAST_UPDATED_BY
                         WHEN NULL THEN LAST_UPDATED_BY
                         ELSE @LAST_UPDATED_BY
                       END
     ,TYPE_CHARGE_ID =
                      CASE @TYPE_CHARGE_ID
                        WHEN NULL THEN TYPE_CHARGE_ID
                        ELSE @TYPE_CHARGE_ID
                      END
     ,TYPE_CHARGE_DESCRIPTION =
                               CASE @TYPE_CHARGE_DESCRIPTION
                                 WHEN NULL THEN TYPE_CHARGE_DESCRIPTION
                                 ELSE @TYPE_CHARGE_DESCRIPTION
                               END
     ,CLIENT_CODE =
                   CASE @CLIENT_CODE
                     WHEN NULL THEN CLIENT_CODE
                     ELSE @CLIENT_CODE
                   END
     ,CLIENT_NAME =
                   CASE @CLIENT_NAME
                     WHEN NULL THEN CLIENT_NAME
                     ELSE @CLIENT_NAME
                   END
     ,IS_CHARGED =
                  CASE @IS_CHARGED
                    WHEN NULL THEN IS_CHARGED
                    ELSE @IS_CHARGED
                  END
     ,INVOICE_REFERENCE =
                         CASE @INVOICE_REFERENCE
                           WHEN NULL THEN INVOICE_REFERENCE
                           ELSE @INVOICE_REFERENCE
                         END
     ,CHARGED_DATE =
                    CASE @CHARGED_DATE
                      WHEN NULL THEN CHARGED_DATE
                      ELSE @CHARGED_DATE
                    END
     ,LICENSE_ID =
                  CASE @LICENSE_ID
                    WHEN NULL THEN LICENSE_ID
                    ELSE @LICENSE_ID
                  END
     ,LOCATION =
                CASE @LOCATION
                  WHEN NULL THEN LOCATION
                  ELSE @LOCATION
                END
     ,SERVICE_ID =
                  CASE @SERVICE_ID
                    WHEN NULL THEN SERVICE_ID
                    ELSE @SERVICE_ID
                  END
     ,SERVICE_CODE =
                    CASE @SERVICE_CODE
                      WHEN NULL THEN SERVICE_CODE
                      ELSE @SERVICE_CODE
                    END
     ,SERVICE_DESCRIPTION =
                           CASE @SERVICE_DESCRIPTION
                             WHEN NULL THEN SERVICE_DESCRIPTION
                             ELSE @SERVICE_DESCRIPTION
                           END
     ,REGIMEN =
               CASE @REGIMEN
                 WHEN NULL THEN REGIMEN
                 ELSE @REGIMEN
               END
     ,DOC_NUM =
               CASE @DOC_NUM
                 WHEN NULL THEN DOC_NUM
                 ELSE @DOC_NUM
               END
     ,TRANSACTION_ID =
                      CASE @TRANSACTION_ID
                        WHEN NULL THEN TRANSACTION_ID
                        ELSE @TRANSACTION_ID
                      END
  WHERE SERVICES_TO_BILL_ID = @SERVICES_TO_BILL_ID
  --
  SELECT
    1 AS [RESULTADO]
   ,'Proceso Exitoso' [MENSAJE]
   ,0 [CODIGO]
--
END TRY
BEGIN CATCH
  SELECT
    -1 AS Resultado
   ,ERROR_MESSAGE() Mensaje
   ,@@ERROR Codigo
END CATCH