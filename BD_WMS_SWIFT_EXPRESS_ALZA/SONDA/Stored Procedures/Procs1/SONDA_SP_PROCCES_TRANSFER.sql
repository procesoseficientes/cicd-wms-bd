-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	01-02-2016
-- Description:			

/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].[SONDA_SP_PROCCES_TRANSFER]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_PROCCES_TRANSFER]

AS
BEGIN
	SET NOCOUNT ON;	
	--
	BEGIN TRAN
	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Obtiene las bodegas de los vendedores regionales
		-- ------------------------------------------------------------------------------------
		SELECT U.DEFAULT_WAREHOUSE
		INTO #WAREHOUSE
		FROM [SONDA].USERS U
		INNER JOIN [SONDA].SWIFT_REGIONAL_USER R ON (U.LOGIN = R.LOGIN)
		--
		PRINT 'Cantidad de bodegas: ' + CAST(@@rowcount AS VARCHAR)

		-- ------------------------------------------------------------------------------------
		-- Obtiene las transferencias
		-- ------------------------------------------------------------------------------------
		SELECT 
			T.DOCENTRY DOC_ENTRY
			,T.TOWHSCODE COLLATE DATABASE_DEFAULT CODE_WAREHOUSE
			,CONVERT(DATE,T.DOCDATE) DOC_DATE
			,T2.ITEMCODE COLLATE DATABASE_DEFAULT CODE_SKU
			,T2.QUANTITY QTY
		INTO #TRANSFER
		FROM [ERP_SERVER].PRUEBA.DBO.OWTR T
		LEFT JOIN [SONDA].[SONDA_TRANSFER_TO_WH_MOBILE] M ON (T.DOCENTRY = M.DOC_ENTRY)
		INNER JOIN [ERP_SERVER].PRUEBA.DBO.WTR1 T2 ON (T.DOCENTRY = T2.DOCENTRY)
		INNER JOIN #WAREHOUSE W ON (T.TOWHSCODE COLLATE DATABASE_DEFAULT = W.DEFAULT_WAREHOUSE)
		WHERE 
			M.DOC_ENTRY IS NULL
			AND T.DOCDATE = CONVERT(DATE,DATEADD(DAY,-1,GETDATE()))
			AND T.TOWHSCODE COLLATE DATABASE_DEFAULT LIKE 'V%'
		--
		PRINT 'Cantidad de transferencias: ' + CAST(@@rowcount AS VARCHAR)

		-- ------------------------------------------------------------------------------------
		-- Realiza merge en el inventario
		-- ------------------------------------------------------------------------------------
		PRINT 'Merge inventario'
		--
		MERGE [SONDA].[SWIFT_INVENTORY] I
		USING (
			SELECT 
				T.CODE_SKU
				,MAX(S.DESCRIPTION_SKU) AS SKU_DESCRIPTION
				,MAX(T.CODE_WAREHOUSE) AS WAREHOUSE
				,MAX(T.CODE_WAREHOUSE) AS LOCATION
				,'BULK_DATA' AS LAST_UPDATE_BY
				,SUM(T.QTY) AS QTY
			FROM #TRANSFER T
			INNER JOIN [SONDA].SWIFT_VIEW_ALL_SKU S ON (T.CODE_SKU = S.CODE_SKU)
			GROUP BY T.CODE_SKU
		) T 
		ON (
			I.[WAREHOUSE] = T.[WAREHOUSE]
			AND I.[LOCATION] = T.[LOCATION]
			AND I.[SKU] = T.CODE_SKU
		) 
		WHEN MATCHED THEN 
			UPDATE 
			SET   
			   I.[ON_HAND] = (I.[ON_HAND] + T.QTY)
			  ,I.[LAST_UPDATE] = GETDATE()
			  ,I.[LAST_UPDATE_BY] = T.LAST_UPDATE_BY
			  ,I.[RELOCATED_DATE] = GETDATE()
		WHEN NOT MATCHED THEN 
		INSERT (      
			[WAREHOUSE]
			,[LOCATION]
			,[SKU]
			,[SKU_DESCRIPTION]
			,[ON_HAND]
			,[LAST_UPDATE]
			,[LAST_UPDATE_BY]
			,[IS_SCANNED]
			,[RELOCATED_DATE] ) 
		VALUES (
			   T.WAREHOUSE
			  ,T.LOCATION
			  ,T.CODE_SKU
			  ,T.SKU_DESCRIPTION
			  ,T.QTY
			  ,GETDATE()
			  ,T.LAST_UPDATE_BY
			  ,1
			  ,GETDATE()
		);
		--
		PRINT 'TERMINA MERGE'

		-- ------------------------------------------------------------------------------------
		-- Inserta los documentos transferidos
		-- ------------------------------------------------------------------------------------
		INSERT INTO [SONDA].[SONDA_TRANSFER_TO_WH_MOBILE]
		SELECT
			DOC_ENTRY
			,CODE_WAREHOUSE
			,DOC_DATE
			,CODE_SKU
			,QTY
		FROM #TRANSFER

		PRINT 'COMMIT'
		COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK
		DECLARE @ERROR VARCHAR(1000) = ERROR_MESSAGE()
		PRINT 'CATCH: ' + @ERROR
		RAISERROR (@ERROR,16,1)
	END CATCH
END
