﻿CREATE PROCEDURE [SONDA].[SONDA_SP_VOID_INVOICE] 
	@pINVOICE_NUM varchar(50),
	@pVOID_REASON varchar(25),
	@pVOID_NOTES varchar(250),
	@pAUTH varchar(50),
	@pAUTH_SERIE varchar(50),
	
	@pResult varchar(250) OUTPUT
AS

SELECT @pResult = 'OK' 
return 0

/*
	DECLARE @ErrorMessage NVARCHAR(4000);
	DECLARE @ErrorSeverity INT;
	DECLARE @ErrorState INT;
	DECLARE @pNewID INT;
	
	DECLARE @pSKU	 VARCHAR(50); 
	DECLARE @pSERIE  VARCHAR(50);
	DECLARE @pCOMBO_REFERENCE	VARCHAR(50);
	
	--SELECT @pNewID = ISNULL((SELECT TOP 1 AUTH_CURRENT_DOC FROM [SONDA].SONDA_POS_RES_SAT WHERE AUTH_ID = @pAUTH AND AUTH_SERIE = @pAUTH_SERIE AND AUTH_STATUS = '1' AND AUTH_DOC_TYPE='NOTA_CREDITO'),0)+1
			
		BEGIN TRY
		
		-- COPY HEADER
		INSERT INTO [SONDA].[SONDA].[SONDA_POS_INVOICE_HEADER]
           (INVOICE_ID--1
           ,[TERMS]--3
           ,[POSTED_DATETIME]--4
           ,[CLIENT_ID]--5
           ,[POS_TERMINAL]--6
           ,[GPS_URL]--7
           ,[TOTAL_AMOUNT]--8
           ,[STATUS]--9
           ,[POSTED_BY]--10
           ,[IMAGE_1]--11
           ,[IMAGE_2]--12
           ,[IMAGE_3]--13
           ,[IS_POSTED_OFFLINE]--14
           ,[INVOICED_DATETIME]--15
           ,[DEVICE_BATTERY_FACTOR]--16
           ,[CDF_DOCENTRY]--17
           ,[CDF_SERIE]--18
           ,[CDF_NIT]--19
           ,[CDF_NOMBRECLIENTE]--20
           ,[CDF_RESOLUCION]--21
           ,[CDF_POSTED_ERP]--22
           ,[IS_CREDIT_NOTE]--23
           ,[VOID_DATETIME]--24
           ,[CDF_PRINTED_COUNT]--25
           ,[VOID_REASON]--26
           ,[VOID_NOTES]--27
           ,VOIDED_INVOICE)--28
     SELECT @pINVOICE_NUM--1
           ,[TERMS]--3
           ,[POSTED_DATETIME]--4
           ,[CLIENT_ID]--5
           ,[POS_TERMINAL]--6
           ,[GPS_URL]--7
           ,[TOTAL_AMOUNT]--8
           ,'1'--9
           ,[POSTED_BY]--10
           ,NULL--11
           ,NULL--12
           ,NULL--13
           ,[IS_POSTED_OFFLINE]--14
           ,CURRENT_TIMESTAMP--15
           ,[DEVICE_BATTERY_FACTOR]--16
           ,[CDF_DOCENTRY]--17
           ,@pAUTH_SERIE--18
           ,[CDF_NIT]--19
           ,[CDF_NOMBRECLIENTE]--20
           ,@pAUTH--21
           ,[CDF_POSTED_ERP]--22
           ,1--23
           ,CURRENT_TIMESTAMP--24
           ,[CDF_PRINTED_COUNT]--25
           ,@pVOID_REASON--26
           ,@pVOID_NOTES--27
           ,INVOICE_ID--28
      FROM [SONDA].SONDA_POS_INVOICE_HEADER WHERE INVOICE_ID = @pINVOICE_NUM

UPDATE [SONDA].SONDA_POS_INVOICE_HEADER SET STATUS = 3, VOID_REASON = @pVOID_REASON, VOID_NOTES = @pVOID_REASON, VOIDED_INVOICE = @pNewID
WHERE INVOICE_ID = @pINVOICE_NUM

UPDATE [SONDA].SONDA_POS_RES_SAT SET AUTH_CURRENT_DOC = AUTH_CURRENT_DOC+1
WHERE AUTH_DOC_TYPE='NOTA_CREDITO' AND AUTH_STATUS = '1'


			SELECT @pResult = 'OK';	
		END TRY
		BEGIN CATCH
			SELECT	@pResult	= ERROR_MESSAGE()
		END CATCH




DECLARE inv_detail_cursor CURSOR 
FOR SELECT SKU, SERIE, COMBO_REFERENCE FROM  [SONDA].SONDA_POS_INVOICE_DETAIL WHERE INVOICE_ID = @pINVOICE_NUM
FOR READ ONLY;

OPEN inv_detail_cursor

FETCH NEXT FROM inv_detail_cursor 
INTO @pSKU, @pSERIE, @pCOMBO_REFERENCE

	WHILE @@FETCH_STATUS = 0 BEGIN

		UPDATE [SONDA].SONDA_POS_SKUS SET ON_HAND = ON_HAND + 1 
		WHERE SKU = @pSKU AND PARENT_SKU = @pCOMBO_REFERENCE AND ROUTE_ID = (SELECT POS_TERMINAL FROM [SONDA].SONDA_POS_INVOICE_HEADER WHERE INVOICE_ID = @pINVOICE_NUM);


		FETCH NEXT FROM inv_detail_cursor 
		INTO @pSKU, @pSERIE, @pCOMBO_REFERENCE
	END 
	
	CLOSE inv_detail_cursor;
DEALLOCATE inv_detail_cursor;
*/
