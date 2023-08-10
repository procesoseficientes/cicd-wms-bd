/*==============================================

-- MODIFICADO: 09-03-2016
	-- diego.as
	-- Se modifico la Insercion de la transaccion puesto que tenia demasiados
		SELECT internos y provocaba la devolucion de N registros en las Subconsultas.
		Ahora trabaja con un INSERT - SELECT, asi tambien, se modificaron algunos errores 
		ortograficos que provocaban la devolucion de valores NULL.

		Ademas, se agrego el ejemplo de ejecucion, tomar en cuenta cambiar la SERIE del SKU
		al momento de ejecutar el ejemplo.

	EJEMPLO DE EJECUCION:
		
		EXEC [SONDA].[SWIFT_SP_PROCESS_PICKING]
			@pTASK_ID = 16574
			,@pBARCODE_LOC = 'A3'
			,@pSKU = '100017'
			,@pSERIE = '1000000007'
			,@pQTY = 1
			,@pLOGIN_ID = 'OPER1@SONDA'
			,@pTXN_ID = ''
			,@pResult = ''
===============================================*/

CREATE PROCEDURE [SONDA].[SWIFT_SP_PROCESS_PICKING]
(
@pTASK_ID INT
,@pBARCODE_LOC VARCHAR(75)
,@pSKU VARCHAR(75)
,@pSERIE VARCHAR(75)
,@pQTY NUMERIC(18,2)
,@pLOGIN_ID VARCHAR(50)
,@pTXN_ID INT OUTPUT
,@pResult VARCHAR(250) OUTPUT
)
AS
BEGIN
    DECLARE @lSKU VARCHAR(75)
		,@lTASK_COMMENTS VARCHAR(250)
		,@lWAREHOUSE VARCHAR(50)
      
		,@lSAP_REFERENCE VARCHAR(50)
		,@lHEADER_REFERENCE INT
		,@ErrorMessage NVARCHAR(4000)
		,@ErrorSeverity INT
		,@ErrorState INT
		,@lERP_INTERFACE_TYPE VARCHAR(50)
		,@lPICKING_HEADER INT
		,@NAME_USER VARCHAR(50)

            BEGIN TRY
				
				  (SELECT @NAME_USER = NAME_USER FROM dbo.SWIFT_USER WHERE LOGIN = @pLOGIN_ID)
      
                  SELECT @lSKU = ISNULL((SELECT 1 FROM [SONDA].SWIFT_VIEW_SKU  WHERE CODE_SKU = @pSKU OR BARCODE_SKU = @pSKU),'NF')
				   IF(@lSKU = 'NF') BEGIN
					SELECT @pResult = 'ERROR, SKU: ' +@pSKU+ ', NO EXISTE';
                    --RETURN -6
				  END

				  SELECT @lPICKING_HEADER = (SELECT [PICKING_NUMBER] FROM [SONDA].[SWIFT_TASKS] WHERE [TASK_ID] = @pTASK_ID)

				  IF NOT EXISTS(SELECT 1 FROM [SONDA].[SWIFT_PICKING_DETAIL] WHERE [PICKING_HEADER] = @lPICKING_HEADER AND [CODE_SKU] = @lSKU) BEGIN
				  	SELECT @pResult = 'ERROR, SKU: ' +@lSKU+ ' NO EXISTE EN LA TAREA ' + CONVERT(VARCHAR(10),@pTASK_ID) + ' PH: ' + CONVERT(VARCHAR(10),@lPICKING_HEADER);
                    --RETURN -5				  
				  END

				  --SI MANEJA SERIE
				  IF(@pSERIE != '')  BEGIN
					IF NOT EXISTS(SELECT 1 FROM [SONDA].[SWIFT_INVENTORY] WHERE [SKU] = @pSKU AND [SERIAL_NUMBER] = @pSERIE AND [LOCATION] = @pBARCODE_LOC)BEGIN
						SELECT @pResult = 'ERROR, SKU: ' +@pSKU+ '/ SERIE: ' + @pSERIE + ' UBICACION NO EXISTE EN INVETARIO';
						--RETURN -7
					END
				  END

                  IF NOT EXISTS(SELECT TOP 1 CODE_WAREHOUSE FROM [SONDA].SWIFT_LOCATIONS WHERE CODE_LOCATION = @pBARCODE_LOC) BEGIN
                    SELECT @pResult = 'ERROR, UBICACION: ' +@pBARCODE_LOC+ ', NO EXISTE';
                    --RETURN -8
                  END
                  
                  SELECT @lSAP_REFERENCE = ISNULL((SELECT SAP_REFERENCE FROM [SONDA].SWIFT_TASKS WHERE TASK_ID = @pTASK_ID),'N/F')
                  IF(@lSAP_REFERENCE = 'N/F') BEGIN
                    SELECT @pResult = 'ERROR, TAREA: ' +convert(varchar(10), @pTASK_ID)+ ', NO TIENE DOCUMENTO ERP';
                    --RETURN -9
                  END

                  SELECT @lHEADER_REFERENCE = ISNULL((SELECT PICKING_NUMBER FROM [SONDA].SWIFT_TASKS WHERE TASK_ID = @pTASK_ID),-9999)
                  IF(@lHEADER_REFERENCE = -9999) BEGIN
                    SELECT @pResult = 'ERROR, TAREA: ' +convert(varchar(10), @pTASK_ID)+ ', NO TIENE DOCUMENTO ERP';
                    --RETURN -10
                  END
				 
                  SELECT @lERP_INTERFACE_TYPE = ISNULL((SELECT MPC01 FROM [SONDA].SWIFT_CLASSIFICATION 
														WHERE CLASSIFICATION = (SELECT CLASSIFICATION_PICKING 
														FROM [SONDA].SWIFT_PICKING_HEADER 
														WHERE PICKING_HEADER = @lHEADER_REFERENCE)),'NF')
                  
				  IF(@lERP_INTERFACE_TYPE = 'NF') BEGIN
                    SELECT @pResult = 'ERROR, TIPO DE RECEPCION NO TIENE INTERFAZ EN SAP: ' +@lERP_INTERFACE_TYPE;
                    --RETURN -11
                  END
                 
                  --SELECT @lTASK_COMMENTS = (SELECT TASK_COMMENTS FROM [SONDA].SWIFT_TASKS WHERE TASK_ID = @pTASK_ID)
                  
                  SELECT @lWAREHOUSE = (SELECT CODE_WAREHOUSE FROM [SONDA].SWIFT_LOCATIONS WHERE CODE_LOCATION = @pBARCODE_LOC)
                      
				IF EXISTS( SELECT CODE_SKU FROM [SONDA].SWIFT_PICKING_DETAIL 
							WHERE PICKING_HEADER = @lHEADER_REFERENCE 
							AND CODE_SKU = @pSKU) BEGIN

					UPDATE [SONDA].SWIFT_PICKING_HEADER 
					SET LAST_UPDATE = GETDATE() 
						,LAST_UPDATE_BY = @pLOGIN_ID 
					WHERE PICKING_HEADER = @lHEADER_REFERENCE					      

					UPDATE [SONDA].[SWIFT_PICKING_DETAIL]
						SET SCANNED = ISNULL(SCANNED,0)+@pQTY
							,[DIFFERENCE] = (DISPATCH - (ISNULL(SCANNED,0)+@pQTY))
							,[LAST_UPDATE]  = GETDATE()
							,[LAST_UPDATE_BY] = @pLOGIN_ID
					WHERE [PICKING_HEADER] = @lHEADER_REFERENCE AND CODE_SKU = @pSKU
				END
						
				 --SI MANEJA SERIE
                 IF(@pSERIE != '') BEGIN
						DELETE FROM [SONDA].[SWIFT_TXNS_SERIES]
						WHERE [TXN_CODE_SKU] = @pSKU AND [TXN_SERIE] = @pSERIE
                        
						DELETE FROM [SONDA].[SWIFT_INVENTORY]
                        WHERE SKU = @pSKU AND LOCATION = @pBARCODE_LOC AND SERIAL_NUMBER = @pSERIE
					END
				ELSE
					BEGIN
						DECLARE @lQTY NUMERIC(18,2) 
						SET @lQTY = @pQTY
						DECLARE @INVENTORY INT
						DECLARE @ON_HAND FLOAT
						
						--DECLARE @RESULT NUMERIC(18,2) 
						--SELECT @RESULT = SUM(ON_HAND) FROM SWIFT_INVENTORY  WHERE SKU = UPPER(@pSKU) AND [LOCATION] = UPPER(RTRIM(@pBARCODE_LOC))
						DECLARE InventoryCursor CURSOR FOR
						SELECT INVENTORY, ON_HAND FROM [SONDA].SWIFT_INVENTORY  WHERE SKU = @pSKU AND [LOCATION] = @pBARCODE_LOC
						OPEN InventoryCursor;
						--FETCH NEXT FROM InventoryCursor;

						WHILE(@lQTY > 0)
						BEGIN
							FETCH NEXT FROM InventoryCursor INTO @INVENTORY, @ON_HAND
							IF(@lQTY > @ON_HAND)
							BEGIN									
								DELETE FROM [SONDA].[SWIFT_INVENTORY]
								WHERE INVENTORY = @INVENTORY
								SET @lQTY = (@lQTY - @ON_HAND)
								--CONTINUE
							END
							ELSE IF(@lQTY = @ON_HAND)
							BEGIN								
								DELETE FROM [SONDA].[SWIFT_INVENTORY]
								WHERE INVENTORY = @INVENTORY
								SET @lQTY = 0
								--BREAK
							END
							ELSE IF(@lQTY < @ON_HAND)
							BEGIN							
								UPDATE [SONDA].[SWIFT_INVENTORY]
								SET ON_HAND = (ON_HAND - @lQTY) 
								WHERE INVENTORY = @INVENTORY
								SET @lQTY = 0
								--BREAK
							END
						END
						CLOSE InventoryCursor;
						DEALLOCATE InventoryCursor;

						--DELETE FROM [SWIFT_INVENTORY]
						--WHERE SKU = @lSKU AND LOCATION = @pBARCODE_LOC AND SERIAL_NUMBER = @pSERIE
					END

					BEGIN TRY
						INSERT INTO [SONDA].[SWIFT_TXNS](
								[SAP_REFERENCE]
							   ,[TASK_SOURCE_ID]
							   ,[HEADER_REFERENCE]
							   ,[TXN_CATEGORY]
							   ,[TXN_TYPE]
							   ,[TXN_DESCRIPTION]
							   ,[TXN_CREATED_STAMP]
							   ,[TXN_OPERATOR_ID]
							   ,[TXN_OPERATOR_NAME]
							   ,[TXN_CODE_SKU]
							   ,[TXN_DESCRIPTION_SKU]
							   ,[TXN_QTY]
							   ,[TXN_SERIE]
							   )
					SELECT ST.SAP_REFERENCE
						,ST.TASK_ID
						,ST.PICKING_NUMBER
						,'MPC01'
						,'PICKING'
						,'PICKING PARA ' + ST.TASK_COMMENTS
						,GETDATE()
						,@pLOGIN_ID
						,@NAME_USER
						,@pSKU
						,VS.DESCRIPTION_SKU
						,@pQTY
						,@pSERIE
					FROM [SONDA].SWIFT_TASKS AS ST
					INNER JOIN  [SONDA].SWIFT_VIEW_SKU AS VS ON (
						VS.CODE_SKU = @pSKU
					)
					WHERE ST.TASK_ID = @pTASK_ID

					SELECT @pTXN_ID = SCOPE_IDENTITY();	

					END TRY
					BEGIN CATCH
						DECLARE @ERROR VARCHAR(1000)= ERROR_MESSAGE()
						SELECT @pResult = @ERROR
					END CATCH
				  
			--RETURN 0
            END TRY
            BEGIN CATCH
				SELECT @pResult = ERROR_MESSAGE()
				--RETURN -99999
            END CATCH
END
