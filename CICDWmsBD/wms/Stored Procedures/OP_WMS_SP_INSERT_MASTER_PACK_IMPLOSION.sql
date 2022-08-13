-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	9/19/2017 @ NEXUS-Team Sprint DuckHunt
-- Description:			Inserta en la tabla MASTER_PACK_HEADER y MASTER_PACK_DETAIL

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_INSERT_MASTER_PACK_IMPLOSION]		
					@MASTER_PACK_CODE = 'autovanguard/VAD1001', -- varchar(50)
				    @QTY = 2, -- decimal
				    @LOGIN = 'ADMIN' -- varchar(50)
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_INSERT_MASTER_PACK_IMPLOSION]
    (
      @MASTER_PACK_CODE VARCHAR(50) ,
      @QTY DECIMAL ,
      @LOGIN VARCHAR(50)
    )
AS
    BEGIN
        SET NOCOUNT ON;
		--
        DECLARE @ID INT ,
            @FECHA DATETIME = GETDATE() ,
            @CLIENT_CODE VARCHAR(25) ,
            @ACUERDO_COMERCIAL VARCHAR(50) ,
            @CODIGO_POLIZA VARCHAR(50) ,
            @LICENSE_ID INT ,
            @RESULTADO VARCHAR(250);
	
        DECLARE @OPERACION TABLE
            (
              [RESULTADO] INT ,
              [MENSAJE] VARCHAR(250) ,
              [CODIGO] INT ,
              [DB_DATA] VARCHAR(50)
            );

        BEGIN TRY
			--
            SELECT  @CLIENT_CODE = [CLIENT_OWNER]
            FROM    [wms].[OP_WMS_MATERIALS]
            WHERE   [MATERIAL_ID] = @MASTER_PACK_CODE;
			--
            SELECT TOP 1
                    @ACUERDO_COMERCIAL = [ACUERDO_COMERCIAL]
            FROM    [wms].[OP_WMS_ACUERDOS_X_CLIENTE]
            WHERE   [CLIENT_ID] = @CLIENT_CODE;
			-- ------------------------------------------------------------------------------------
			-- Inserta la poliza
			-- ------------------------------------------------------------------------------------
            INSERT  INTO @OPERACION
                    ( [RESULTADO] ,
                      [MENSAJE] ,
                      [CODIGO] ,
                      [DB_DATA]
		            )
                    EXEC [wms].[OP_WMS_SP_INSERT_POLIZA_HEADER] @DOC_ID = 0, -- int
                        @FECHA_LLEGADA = @FECHA, -- datetime
                        @LAST_UPDATED_BY = @LOGIN, -- varchar(25)
                        @LAST_UPDATED = @FECHA, -- datetime
                        @CLIENT_CODE = @CLIENT_CODE, -- varchar(25)
                        @FECHA_DOCUMENTO = @FECHA, -- datetime
                        @TIPO = 'INGRESO', -- varchar(25)
                        @CODIGO_POLIZA = '0', -- varchar(25)
                        @ACUERDO_COMERCIAL = @ACUERDO_COMERCIAL, -- varchar(50)
                        @STATUS = 'CREATED'; -- varchar(15)
			-- ------------------------------------------------------------------------------------
			-- Obtiene el codigo de poliza
			-- ------------------------------------------------------------------------------------
            SELECT TOP 1
                    @CODIGO_POLIZA = [DB_DATA]
            FROM    @OPERACION;
			--
            DELETE  @OPERACION;
			-- ------------------------------------------------------------------------------------
			-- Inserta la licencia
			-- ------------------------------------------------------------------------------------
			INSERT  INTO @OPERACION
                    ( [RESULTADO] ,
                      [MENSAJE] ,
                      [CODIGO] ,
                      [DB_DATA]
		            )
            EXEC [wms].[OP_WMS_SP_CREA_LICENCIA] @pCODIGO_POLIZA = @CODIGO_POLIZA, -- varchar(25)
                @pLOGIN = @LOGIN, -- varchar(25)
                @pLICENCIA_ID = @LICENSE_ID OUT, -- numeric
                @pCLIENT_OWNER = @CLIENT_CODE, -- varchar(25)
                @pREGIMEN = 'GENERAL', -- varchar(50)
                @pResult = @RESULTADO OUT;-- varchar(250)
		
			-- ------------------------------------------------------------------------------------
			-- Inserta en MASTER_PACK_HEADER
			-- ------------------------------------------------------------------------------------
            INSERT  INTO [wms].[OP_WMS_MASTER_PACK_HEADER]
                    ( [LICENSE_ID] ,
                      [MATERIAL_ID] ,
                      [POLICY_HEADER_ID] ,
                      [LAST_UPDATED] ,
                      [LAST_UPDATE_BY] ,
                      [EXPLODED] ,
                      [EXPLODED_DATE] ,
                      [RECEPTION_DATE] ,
                      [IS_AUTHORIZED] ,
                      [ATTEMPTED_WITH_ERROR] ,
                      [IS_POSTED_ERP] ,
                      [POSTED_ERP] ,
                      [POSTED_RESPONSE] ,
                      [ERP_REFERENCE] ,
                      [ERP_REFERENCE_DOC_NUM] ,
                      [QTY] ,
                      [IS_IMPLOSION]
		            )
            VALUES  ( @LICENSE_ID , -- LICENSE_ID - int
                      @MASTER_PACK_CODE , -- MATERIAL_ID - varchar(50)
                      @CODIGO_POLIZA , -- POLICY_HEADER_ID - numeric
                      GETDATE() , -- LAST_UPDATED - datetime
                      @LOGIN , -- LAST_UPDATE_BY - varchar(50)
                      0 , -- EXPLODED - int
                      GETDATE() , -- EXPLODED_DATE - datetime
                      GETDATE() , -- RECEPTION_DATE - datetime
                      0 , -- IS_AUTHORIZED - int
                      0 , -- ATTEMPTED_WITH_ERROR - int
                      0 , -- IS_POSTED_ERP - int
                      NULL , -- POSTED_ERP - datetime
                      NULL , -- POSTED_RESPONSE - varchar(500)
                      NULL , -- ERP_REFERENCE - varchar(50)
                      NULL , -- ERP_REFERENCE_DOC_NUM - varchar(200)
                      @QTY , -- QTY - int
                      1  -- IS_IMPLOSION - int
		            );
			--
            SET @ID = SCOPE_IDENTITY();
			-- ------------------------------------------------------------------------------------
			-- Inserta en MASTER_PACK_DETAIL
			-- ------------------------------------------------------------------------------------
            INSERT  INTO [wms].[OP_WMS_MASTER_PACK_DETAIL]
                    ( [MASTER_PACK_HEADER_ID] ,
                      [MATERIAL_ID] ,
                      [QTY] ,
                      [BATCH] ,
                      [DATE_EXPIRATION]
		            )
                    SELECT  @ID ,
                            [COMPONENT_MATERIAL] ,
                            [QTY],
                            NULL ,
                            NULL
                    FROM    [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK]
                    WHERE   [MASTER_PACK_CODE] = @MASTER_PACK_CODE;
			-- ------------------------------------------------------------------------------------
			-- Despliega el resultado final
			-- ------------------------------------------------------------------------------------
            SELECT  1 AS Resultado ,
                    'Proceso Exitoso' Mensaje ,
                    0 Codigo ,
                    CAST(@LICENSE_ID AS VARCHAR) DbData;
        END TRY
        BEGIN CATCH
            SELECT  -1 AS Resultado ,
                    ERROR_MESSAGE() Mensaje ,
                    @@ERROR Codigo,
					'' DbData; 
        END CATCH;
    END;