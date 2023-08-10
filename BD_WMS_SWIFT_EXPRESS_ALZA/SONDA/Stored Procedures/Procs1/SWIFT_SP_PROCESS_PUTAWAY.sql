CREATE PROCEDURE [SONDA].[SWIFT_SP_PROCESS_PUTAWAY]
@pTASK_ID         INT,
@pBARCODE_LOC     VARCHAR(75),
@pSKU             VARCHAR(75),
@pQTY             NUMERIC(18,2),
@pLOGIN_ID        VARCHAR(50),
@pTXN_ID		 INT OUTPUT,
@pINV_ID		 INT OUTPUT,

@pResult varchar(250) OUTPUT
AS
	 DECLARE @lTXN_ID		 INT
	 SET @lTXN_ID = @pTXN_ID
      DECLARE @lSKU           VARCHAR(75);
      DECLARE @lTASK_COMMENTS VARCHAR(250);
      DECLARE @lWAREHOUSE     VARCHAR(50);
      
      DECLARE @lSAP_REFERENCE VARCHAR(50);
      DECLARE @lHEADER_REFERENCE INT;
      DECLARE @ErrorMessage NVARCHAR(4000);
      DECLARE @ErrorSeverity INT;
      DECLARE @ErrorState INT;
      DECLARE @lERP_INTERFACE_TYPE VARCHAR(50);

            BEGIN TRY
                  
                  SELECT @lSKU = @pSKU;
                  
                  IF NOT EXISTS(SELECT CODE_WAREHOUSE FROM SWIFT_LOCATIONS WHERE CODE_LOCATION = UPPER(@pBARCODE_LOC)) BEGIN
                        SELECT      @pResult    = 'ERROR, UBICACION: ' +@pBARCODE_LOC+ ', NO EXISTE';
                        RETURN -8
                  END
                  
                  SELECT @lSAP_REFERENCE = ISNULL((SELECT SAP_REFERENCE FROM SWIFT_TASKS WHERE TASK_ID = @pTASK_ID),'N/F')
                  IF(@lSAP_REFERENCE = 'N/F') BEGIN
                        SELECT      @pResult    = 'ERROR, TAREA: ' +convert(varchar(10), @pTASK_ID)+ ', NO TIENE DOCUMENTO ERP';
                        RETURN -9
                  END
                  
                  SELECT @lHEADER_REFERENCE = ISNULL((SELECT RECEPTION_NUMBER FROM SWIFT_TASKS WHERE TASK_ID = @pTASK_ID),-9999)
                  IF(@lHEADER_REFERENCE = -9999) BEGIN
                        SELECT      @pResult    = 'ERROR, TAREA: ' +convert(varchar(10), @pTASK_ID)+ ', NO TIENE DOCUMENTO ERP';
                        RETURN -9
                  END
                  
                  SELECT @lERP_INTERFACE_TYPE = ISNULL((SELECT TYPE_RECEPTION FROM SWIFT_RECEPTION_HEADER WHERE RECEPTION_HEADER = @lHEADER_REFERENCE),'NF')
                  IF(@lERP_INTERFACE_TYPE = 'NF') BEGIN
                        SELECT      @pResult    = 'ERROR, TIPO DE RECEPCION NO TIENE INTERFAZ EN SAP: ' +@lERP_INTERFACE_TYPE;
                        RETURN -9
                  END
                  
                  SELECT @lTASK_COMMENTS = (SELECT TASK_COMMENTS FROM SWIFT_TASKS WHERE TASK_ID = @pTASK_ID)
                  
                  SELECT @lWAREHOUSE = (SELECT CODE_WAREHOUSE FROM SWIFT_LOCATIONS WHERE CODE_LOCATION = UPPER(@pBARCODE_LOC))
                  
                  UPDATE      SWIFT_RECEPTION_HEADER SET 
                              LAST_UPDATE       = CURRENT_TIMESTAMP, 
                              LAST_UPDATE_BY    = @pLOGIN_ID 
                  WHERE 
                              RECEPTION_HEADER = @lHEADER_REFERENCE
                              IF(@@ROWCOUNT <> 1)
                              BEGIN
								SELECT      @pResult    = 'ERROR, NO SE PUDO ACTUALIZAR ENCABEZADO ' + @lSAP_REFERENCE;
								RETURN -10
                              END
                              
                              
                  IF EXISTS(  SELECT 1 FROM SWIFT_RECEPTION_DETAIL 
                                    WHERE RECEPTION_HEADER = @lHEADER_REFERENCE 
                                    AND CODE_SKU = @lSKU) BEGIN
                        UPDATE [SWIFT_RECEPTION_DETAIL]
                           SET ALLOCATED        = ISNULL(ALLOCATED,0)+@pQTY
                                ,[LAST_UPDATE]  = CURRENT_TIMESTAMP
                                ,[LAST_UPDATE_BY] = @pLOGIN_ID
                        WHERE      [RECEPTION_HEADER] = @lHEADER_REFERENCE AND 
                                    CODE_SKU = @lSKU
                        
                        
                        
                  END
                  
                  INSERT INTO [SWIFT_TXNS]
                           ([SAP_REFERENCE]
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
                           ,[TXN_QTY])
                  VALUES
                           (@lSAP_REFERENCE
                           ,@pTASK_ID
                           ,@lHEADER_REFERENCE
                           ,@lERP_INTERFACE_TYPE
                           ,CASE 
								WHEN @lERP_INTERFACE_TYPE = 'RT' THEN 'RETURN'
								WHEN @lERP_INTERFACE_TYPE = 'PO' THEN 'PUTAWAY'
								WHEN @lERP_INTERFACE_TYPE = 'RR' THEN 'RETURN'
							END	 
                           ,'ALMACENAJE DESDE ' + @lTASK_COMMENTS
                           ,CURRENT_TIMESTAMP
                           ,@pLOGIN_ID
                           ,(SELECT NAME_USER FROM dbo.SWIFT_USER WHERE LOGIN = @pLOGIN_ID)
                           ,@lSKU
                           ,(SELECT DESCRIPTION_SKU FROM SWIFT_VIEW_SKU WHERE CODE_SKU = @lSKU)
                           ,@pQTY)
							IF(@@ROWCOUNT <> 1)
                              BEGIN
								SELECT      @pResult    = 'ERROR, NO SE PUDO CREAR TRANSACCION ' + @pTASK_ID;
								RETURN -11
                              END ELSE BEGIN
								SELECT @pTXN_ID = @@IDENTITY;
								
                              END
							 
                  IF NOT EXISTS(SELECT SKU FROM SWIFT_INVENTORY WHERE SKU = @lSKU AND LOCATION = @pBARCODE_LOC AND TXN_ID = @lTXN_ID) BEGIN
                        INSERT INTO [SWIFT_INVENTORY]
                                 ([SERIAL_NUMBER]
                                 ,[WAREHOUSE]
                                 ,[LOCATION]
                                 ,[SKU]
                                 ,[SKU_DESCRIPTION]
                                 ,[ON_HAND]
                                 ,[BATCH_ID]
                                 ,[LAST_UPDATE]
                                 ,[LAST_UPDATE_BY]
								,[TXN_ID])
                        VALUES
                                 (NULL
                                 ,@lWAREHOUSE
                                 ,@pBARCODE_LOC
                                 ,@lSKU
                                 ,(SELECT DESCRIPTION_SKU FROM SWIFT_VIEW_SKU WHERE CODE_SKU = @lSKU)
                                 ,@pQTY
                                 ,NULL
                                 ,CURRENT_TIMESTAMP
                                 ,@pLOGIN_ID
								,@pTXN_ID)
                                 
                        IF(@@ROWCOUNT <> 1)
                          BEGIN
							SELECT @pResult    = 'ERROR, NO SE PUDO CREAR INVENTARIO ' + @pTASK_ID;
							RETURN -12
                        END ELSE BEGIN
								SELECT @pINV_ID = @@IDENTITY;
							END
                        
                  END ELSE BEGIN
                        UPDATE [SWIFT_INVENTORY]
                           SET [ON_HAND] = [ON_HAND] + @pQTY
                                ,[LAST_UPDATE] = CURRENT_TIMESTAMP
                                ,[LAST_UPDATE_BY] = @pLOGIN_ID 
                         WHERE SKU = @lSKU AND LOCATION = @pBARCODE_LOC AND SERIAL_NUMBER IS NULL AND TXN_ID = @lTXN_ID
						SELECT @pINV_ID = (SELECT [INVENTORY] FROM  [SWIFT_INVENTORY] WHERE SKU = @lSKU AND LOCATION = @pBARCODE_LOC AND SERIAL_NUMBER IS NULL AND TXN_ID = @lTXN_ID);
                  END
                        
                  SELECT      @pResult    = 'OK';
                  RETURN 0
                  
            END TRY
            BEGIN CATCH
                  SELECT      @pResult    = ERROR_MESSAGE()
                  RETURN -0
            END CATCH
