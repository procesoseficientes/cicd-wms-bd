CREATE PROCEDURE [SONDA].[SWIFT_SP_PROCESS_PUTAWAY_SKU_SERIE]
@pTXN_ID		  INT,
@pBARCODE_SERIE   VARCHAR(150),
@pLOCATION_ID	  VARCHAR(50),
@pSKU             VARCHAR(75),
@pLAST_INVENTORY_KY INT,

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
					RETURN -2
				END 
                  SELECT @lSKU			=	UPPER(@pSKU);
				  SELECT @lWAREHOUSE	=	(SELECT CODE_WAREHOUSE  FROM SWIFT_LOCATIONS WHERE CODE_LOCATION = UPPER(@pLOCATION_ID));
				  SELECT @lSKU_DESC		=	(SELECT DESCRIPTION_SKU FROM SWIFT_VIEW_SKU  WHERE (CODE_SKU = @lSKU OR BARCODE_SKU = @lSKU))
				  
				  IF EXISTS(SELECT 1 FROM SWIFT_VIEW_SKU  WHERE (CODE_SKU = @pBARCODE_SERIE OR BARCODE_SKU = @pBARCODE_SERIE)) BEGIN
					SELECT      @pResult    = 'ERROR, SERIE INVALIDA, CONTENIDA EN SKUS'
					RETURN -1
				  END


				  INSERT INTO SWIFT_TXNS_SERIES
				  		   ([TXN_ID]
				  		   ,[TXN_CODE_SKU]
						   ,[TXN_DESCRIPTION_SKU]
				  		   ,[TXN_SERIE])
					 VALUES
				  		   (@pTXN_ID
						   ,@pSKU
				  		   ,@lSKU_DESC
				  		   ,@pBARCODE_SERIE)
                  IF @@ROWCOUNT = 0 BEGIN
					SELECT      @pResult    = 'ERROR, NO SE PUDO CREAR LA SERIE'
					RETURN -20
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
							 ,1
							 ,NULL
							 ,CURRENT_TIMESTAMP
							 ,@pLOGIN_ID)
							 
							 IF @@ROWCOUNT = 0 BEGIN
								SELECT      @pResult    = 'ERROR, NO SE PUDO CREAR EL INVENTARIO'
								RETURN -19
							 END
              
				  
                  UPDATE [SWIFT_INVENTORY]
					SET  [ON_HAND]			= [ON_HAND] - 1
						,[LAST_UPDATE]		= CURRENT_TIMESTAMP
                        ,[LAST_UPDATE_BY]	= @pLOGIN_ID 
					WHERE	
						INVENTORY = @pLAST_INVENTORY_KY
                        
                   IF @@ROWCOUNT = 0 BEGIN
						SELECT      @pResult    = 'ERROR, NO SE PUDO ACTUALIZAR EL INVENTARIO ORIGEN '
						RETURN -18
				   END
                  
                  SELECT      @pResult    = 'OK';
                  RETURN 0
                  
            END TRY
            BEGIN CATCH
                  SELECT      @pResult    = ERROR_MESSAGE()
                  RETURN -9999
            END CATCH
