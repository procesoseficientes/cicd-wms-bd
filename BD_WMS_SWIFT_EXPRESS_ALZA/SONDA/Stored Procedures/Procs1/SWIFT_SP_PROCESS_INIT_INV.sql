
CREATE PROCEDURE [SONDA].[SWIFT_SP_PROCESS_INIT_INV]
@pLOCATION_ID	  VARCHAR(50),
@pSKU             VARCHAR(75),
@pBARCODE_SERIE   VARCHAR(150),

@pQTY NUMERIC(18,2),

@pLOGIN_ID        VARCHAR(50),

@pResult varchar(250) OUTPUT
AS
      DECLARE @lSKU          VARCHAR(75);
      DECLARE @lWAREHOUSE    VARCHAR(50);
      DECLARE @lSKU_DESC	 VARCHAR(150);
      
      DECLARE @ErrorMessage NVARCHAR(4000);
      DECLARE @ErrorSeverity INT;
      DECLARE @ErrorState INT;
      DECLARE @lERP_INTERFACE_TYPE VARCHAR(50);
	  DECLARE @len int ;    
            BEGIN TRY

				select @len= LEN(@pBARCODE_SERIE)
				IF (@len<=8 OR  @len>=40) BEGIN
					SELECT @pResult ='Error, La serie ' + @pBARCODE_SERIE + ' No es valida' 
					RETURN -3
				END 
                  
                  SELECT @lSKU = ISNULL((SELECT TOP 1 UPPER(CODE_SKU) FROM SWIFT_VIEW_SKU  WHERE CODE_SKU = UPPER(@pSKU) OR BARCODE_SKU = UPPER(@pSKU)),'NF');

				  IF @lSKU = 'NF' BEGIN
					SELECT      @pResult    = 'ERROR, SKU ' + @pSKU + ' NO EXISTE' 
					RETURN -1
				  END

				  IF EXISTS(SELECT 1 FROM SWIFT_VIEW_SKU  WHERE (CODE_SKU = @pBARCODE_SERIE OR BARCODE_SKU = @pBARCODE_SERIE)) BEGIN
					SELECT      @pResult    = 'ERROR, SERIE INVALIDA, CONTENIDA EN SKUS'
					RETURN -1
				  END

				  SELECT @lWAREHOUSE	=	(SELECT CODE_WAREHOUSE  FROM SWIFT_LOCATIONS WHERE CODE_LOCATION = UPPER(@pLOCATION_ID));
				  SELECT @lSKU_DESC		=	(SELECT DESCRIPTION_SKU FROM SWIFT_VIEW_SKU  WHERE (CODE_SKU = @lSKU OR BARCODE_SKU = @lSKU))
				  
				  IF EXISTS(SELECT 1 FROM 
						[SWIFT_TXNS_SERIES] WHERE
						TXN_CODE_SKU = @lSKU AND
						TXN_SERIE = @pBARCODE_SERIE
					) BEGIN
					
					SELECT      @pResult    = 'ERROR, SERIE ' + @pBARCODE_SERIE + ' YA EXISTE' 
					RETURN -2
				  END

				  DELETE FROM
				  [SWIFT_INVENTORY] WHERE
				  [LOCATION] = UPPER(@pLOCATION_ID) AND
				  SKU = @lSKU AND
				  [SERIAL_NUMBER] = @pBARCODE_SERIE

				  DELETE FROM
				  [SWIFT_TXNS_SERIES] WHERE
				  TXN_CODE_SKU = @lSKU AND
				  TXN_SERIE = @pBARCODE_SERIE

				  INSERT INTO SWIFT_TXNS_SERIES
				  		   ([TXN_ID]
				  		   ,[TXN_CODE_SKU]
						   ,[TXN_DESCRIPTION_SKU]
				  		   ,[TXN_SERIE])
					 VALUES
				  		   (99999999
						   ,@lSKU
				  		   ,@lSKU_DESC
				  		   ,@pBARCODE_SERIE)

                  IF @@ROWCOUNT = 0 BEGIN
					SELECT      @pResult    = 'ERROR, NO SE PUDO CREAR LA SERIE'
					RETURN -0
				  END
				  
                  INSERT INTO [SWIFT_INVENTORY]
							 ([SERIAL_NUMBER]
							 ,[WAREHOUSE]
							 ,[LOCATION]
							 ,[SKU]
							 ,[SKU_DESCRIPTION]
							 ,[ON_HAND]
							 ,[BATCH_ID]
							 ,[LAST_UPDATE]
							 ,[LAST_UPDATE_BY])
					VALUES
							 (@pBARCODE_SERIE
							 ,@lWAREHOUSE
							 ,UPPER(@pLOCATION_ID)
							 ,@lSKU
							 ,@lSKU_DESC
							 ,@pQTY
							 ,NULL
							 ,CURRENT_TIMESTAMP
							 ,@pLOGIN_ID)
							 
							 IF @@ROWCOUNT = 0 BEGIN
								SELECT      @pResult    = 'ERROR, NO SE PUDO CREAR EL INVENTARIO'
								RETURN -0
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
							   ,[TXN_QTY]
							   ,[TXN_SERIE]
							   ,[TXN_BATCH])
					  VALUES
							   ('N/A'
							   ,99999999
							   ,0
							   ,0
							   ,'INIT'
							   ,'INICIALIZACION '
							   ,CURRENT_TIMESTAMP
							   ,@pLOGIN_ID
							   ,(SELECT NAME_USER FROM dbo.SWIFT_USER WHERE LOGIN = @pLOGIN_ID)
							   ,@lSKU
							   ,(SELECT DESCRIPTION_SKU FROM SWIFT_VIEW_SKU WHERE CODE_SKU = @lSKU)
							   ,@pQTY
							   ,@pBARCODE_SERIE
							   ,NULL)

                  SELECT      @pResult    = 'OK';
                  RETURN 0
                  
            END TRY
            BEGIN CATCH
                  SELECT      @pResult    = ERROR_MESSAGE()
                  RETURN -9999
            END CATCH
