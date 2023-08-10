-- =============================================
-- Autor:				alberto.ruiz	
-- Fecha de Creacion: 	01-12-2015
-- Description:			Reubica un sku en otra locacion

-- Modificado:			10-03-2016
--						diego.as
--						Se modifico la Insercion de la Transaccion
--						de manera que funcione con un Insert - Select
--						permitiendo la lectura tanto del SKU  
--						como la de BARCODE_SKU al momento de la reubicacion.

/*
-- Ejemplo de Ejecucion:
				exec [SONDA].[SWIFT_SP_PROCESS_REALLOC]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_PROCESS_REALLOC]
@pBARCODE_LOC_SOURCE	VARCHAR(75),
@pBARCODE_LOC_TARGET	VARCHAR(75),
@pBARCODE_SKU			VARCHAR(75),
@pSOURCE_SERIE			VARCHAR(150),
@pQTY					NUMERIC(18,2),

@pLOGIN_ID				VARCHAR(50),

@pResult varchar(250) OUTPUT
AS
      DECLARE @lSKU     VARCHAR(75);
      DECLARE @lBARCODE	VARCHAR(75);
      DECLARE @lWAREHOUSE VARCHAR(75);
      DECLARE @lHANDLE_SERIES INT;
      
      
      DECLARE @ErrorMessage NVARCHAR(4000);
      DECLARE @ErrorSeverity INT;
      DECLARE @ErrorState INT;
      
      DECLARE @lDebugLine INT
				,@pSKU VARCHAR(50)
      
	  SET @lDebugLine = 0;

            BEGIN TRY
              SELECT @pSKU = CODE_SKU FROM [SONDA].SWIFT_VIEW_SKU AS SVS WHERE SVS.BARCODE_SKU = @pBARCODE_SKU OR SVS.CODE_SKU = @pBARCODE_SKU

			   --TARGET AND SOURCE SHOULD BE DIFFERENT
			   IF UPPER(@pBARCODE_LOC_SOURCE) = UPPER(@pBARCODE_LOC_TARGET) BEGIN
					SELECT      @pResult    = 'ERROR, UBICACION ORIGEN Y DESTINO NO PUEDEN SER LA MISMA';
					RETURN -5
			   END
                  
               SET @lDebugLine = 1;    
              --CHECK FOR SKU DATA MASTER
              SELECT @lBARCODE	= UPPER(@pBARCODE_SKU);
                                
              SELECT @lSKU = ISNULL((SELECT CODE_SKU FROM SWIFT_VIEW_SKU  WHERE (CODE_SKU = @lBARCODE OR BARCODE_SKU = @lBARCODE)),'N/F')
              
			  IF @lSKU = 'N/F' BEGIN
                SELECT      @pResult    = 'ERROR, SKU: ' +@lBARCODE+ ', NO EXISTE';
                RETURN -4
              END
                  
		      SELECT @lHANDLE_SERIES = ISNULL((SELECT Z.HANDLE_SERIAL_NUMBER FROM SWIFT_VIEW_SKU Z WHERE Z.CODE_SKU = @lSKU OR BARCODE_SKU = @lBARCODE),0)
              
              --CHECK FOR SOURCE LOCATION
              --CAMBIO
			  --SELECT @lBARCODE	= UPPER(@pBARCODE_LOC_SOURCE);
			  SELECT @lBARCODE	= UPPER(@pBARCODE_LOC_TARGET);
              IF NOT EXISTS(SELECT 1 FROM SWIFT_LOCATIONS WHERE UPPER(CODE_LOCATION) = @lBARCODE) BEGIN
                SELECT      @pResult    = 'ERROR, UBICACION: ' +@lBARCODE+ ', NO EXISTE';
                RETURN -2
              END
                  
              SELECT @lWAREHOUSE = 
              ISNULL((SELECT CODE_WAREHOUSE FROM SWIFT_LOCATIONS WHERE UPPER(CODE_LOCATION) = @lBARCODE),'N/A');
              
              --CHECK FOR SOURCE LOCATION
              SELECT @lBARCODE	= UPPER(@pBARCODE_LOC_TARGET);
              IF NOT EXISTS(SELECT 1 FROM SWIFT_LOCATIONS WHERE UPPER(CODE_LOCATION) = @lBARCODE) BEGIN
                SELECT      @pResult    = 'ERROR, UBICACION: ' +@lBARCODE+ ', NO EXISTE';
                
                RETURN -3
              END

			  SET @lDebugLine = 2;    
			  SELECT @lBARCODE	= UPPER(@pBARCODE_SKU);
              
              --CHECK FOR SKU ON SOURCE LOCATION
              IF NOT EXISTS(
					SELECT 1 FROM SWIFT_INVENTORY
					WHERE SKU = (SELECT CODE_SKU 
									FROM	SWIFT_VIEW_SKU  
									WHERE	CODE_SKU = @lBARCODE OR 
									BARCODE_SKU = @lBARCODE) AND
									LOCATION = UPPER(@pBARCODE_LOC_SOURCE)) 
				BEGIN
					SELECT      @pResult    = 'ERROR, SKU: ' + @pSKU + ', NO EXISTE EN UBICACION DE ORIGEN '+UPPER(@pBARCODE_LOC_SOURCE);
					RETURN -2
              END

			  SET @lDebugLine = 3;    
              --CHECK FOR SKU INVENTORY ON SOURCE LOCATION
              IF NOT EXISTS(
					SELECT 1 FROM SWIFT_INVENTORY
					WHERE SKU = (SELECT CODE_SKU 
									FROM	SWIFT_VIEW_SKU  
									WHERE	CODE_SKU = @lBARCODE OR 
									BARCODE_SKU = @lBARCODE
								)	AND LOCATION = UPPER(@pBARCODE_LOC_SOURCE)
									AND ON_HAND >= @pQTY
									) 
				BEGIN
					SELECT      @pResult    = 'ERROR, SKU:' +@lBARCODE+ ', EXISTENCIA INSUFICIENTE EN UBICACION ORIGEN '+UPPER(@pBARCODE_LOC_SOURCE);
					RETURN -1
              END
                  
              --CHECK IF SKU REQUERIES SERIAL NUMBER, IF TRUE VERIFY THAT SERIAL # IS HOSTED ON SOURCE LOCATION
              IF(@lHANDLE_SERIES=1) BEGIN
				SET @lDebugLine = 4;    
				
				IF NOT EXISTS(
					SELECT 1 FROM SWIFT_INVENTORY
					WHERE SKU = @pSKU
					AND LOCATION = UPPER(@pBARCODE_LOC_SOURCE)
					AND ON_HAND >= 1 AND SERIAL_NUMBER = @pSOURCE_SERIE
				) 
				BEGIN
					SELECT      @pResult    = 'ERROR, SKU:' +@pSKU+ ', CON SERIE ' + @pSOURCE_SERIE + ' NO EXISTE EN UBICACION ORIGEN '+UPPER(@pBARCODE_LOC_SOURCE);
					RETURN -6
				 END
                  
              END
				  
			  SET @lDebugLine = 5;    

              BEGIN TRANSACTION
              
				  --INSERT TXN
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
						SELECT 0
							,NULL
							,NULL
							,NULL
							,'REALLOC'
							,'REUBICAR ' + @pSKU + ' DE ' +UPPER(@pBARCODE_LOC_SOURCE) + ' HACIA ' + UPPER(@pBARCODE_LOC_TARGET)
							,GETDATE()
							,SU.[LOGIN]
							,SU.[NAME_USER]
							,SVS.CODE_SKU
							,SVS.DESCRIPTION_SKU
							,(CASE SVS.HANDLE_SERIAL_NUMBER  
								WHEN 0 THEN
									@pQTY
								WHEN 1 THEN
									1
							END)
						FROM [SONDA].SWIFT_VIEW_SKU AS SVS
						INNER JOIN dbo.SWIFT_USER AS SU ON(
							SU.[LOGIN] = @pLOGIN_ID
						)
						WHERE SVS.CODE_SKU = @pBARCODE_SKU OR
								SVS.BARCODE_SKU = @pBARCODE_SKU

						SELECT @pResult = SCOPE_IDENTITY()     
                  
					--UPDATE TARGET INVENTORY
                    UPDATE [SWIFT_INVENTORY]
                    SET [LOCATION] = UPPER(@pBARCODE_LOC_TARGET) 
						,[LAST_UPDATE] = GETDATE()
						,[LAST_UPDATE_BY] = UPPER(REPLACE(@pLOGIN_ID,' ',''))
						,[RELOCATED_DATE] = GETDATE()
						,[IS_SCANNED] = 1
                    WHERE SKU = UPPER(@pSKU)
						AND	LOCATION = UPPER(@pBARCODE_LOC_SOURCE) AND
						SERIAL_NUMBER = (
								CASE @lHANDLE_SERIES 
									WHEN 0 THEN
										NULL
									WHEN 1 THEN
										UPPER(@pSOURCE_SERIE)
								END
						)
								
					IF(@@ROWCOUNT <> 1)
                        BEGIN
						SELECT      @pResult    = 'ERROR, AL REUBICAR LA SERIE';
						ROLLBACK TRANSACTION;
						RETURN -9
                    END
                            
                  SELECT      @pResult    = 'OK';
                  COMMIT TRANSACTION;
                  RETURN 0
                  
            END TRY
            BEGIN CATCH
                  SELECT      @pResult    = 'LINEA: ' + CONVERT(VARCHAR(10), @lDebugLine) + ' ' +ERROR_MESSAGE()
                  RETURN -9999
            END CATCH
