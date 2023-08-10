-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	21-Mar-17 @ A-TEAM Sprint Fenyang
-- Description:			SP que valida las ordenes de venta para enviar

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_VALIDATE_SO_READY_TO_SEND]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_VALIDATE_SO_READY_TO_SEND]
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @RESUTL TABLE(
		[DOC_SERIE] VARCHAR(50)
		,[DOC_NUM] INT
		,[IS_POSTED_ERP] INT
		,[QTY] INT
	)
	--
	DECLARE 
		@DATETIME DATETIME = DATEADD(DAY,-2,GETDATE())
		,@QTY INT = 0;
	--
	INSERT INTO @RESUTL
	(
		[DOC_SERIE]
		,[DOC_NUM]
		,[IS_POSTED_ERP]
		,[QTY]
		
	)
	SELECT
		[SO].[DOC_SERIE]
		,[SO].[DOC_NUM]
		,[SO].[IS_POSTED_ERP]
		,COUNT([SO].[DOC_NUM]) [QTY]		
	FROM [SONDA].[SONDA_SALES_ORDER_HEADER] (NOLOCK) [SO]
	WHERE [SO].[SALES_ORDER_ID] > 0
		AND [SO].[IS_READY_TO_SEND] = 1
		AND [SO].[POSTED_DATETIME] > @DATETIME
	GROUP BY [DOC_SERIE]
		,[DOC_NUM]
		,[SO].[IS_POSTED_ERP]
	HAVING COUNT([DOC_NUM]) > 1;
	--
	SET @QTY = @@ROWCOUNT
	--
	IF @QTY > 0
	BEGIN
		-- ---------------------------------------------------------------
		-- Envia alerta
		-- ---------------------------------------------------------------
		DECLARE
		  @DEFAULT_PROFILE_NAME VARCHAR(250) = 'SoporteMobility'
		  ,@DEFAULT_RECIPIENTS VARCHAR(250) = 'alex.carrillo@mobilityscm.com;jose.garcia@mobilityscm.com;'
		  ,@DEFAULT_RECIPIENTS_CC VARCHAR(250) = ''--fabrizio.rivera@mobilityscm.com;juanfrancisco.gonzalez@mobilityscm.com;'
		  ,@DEFAULT_RECIPIENTS_CCO VARCHAR(250) = ''
		  ,@BODY VARCHAR(MAX) = ''

		-- ------------------------------------------------------------------------------------
		-- Forma el html del correo
		-- ------------------------------------------------------------------------------------
		SET @BODY += '<style>
		  table {
			border-collapse: collapse;
			width: 100%;
		  }

		  th, td {
			padding: 8px;
			text-align: left;
		  }
		  tr:nth-child(even){background-color: #f2f2f2  }
		</style>'
		SET @BODY += '<p>Buen día, </p>'
		SET @BODY += '<p>En ARIUM en el servidor ' + @@SERVERNAME + ' con la IP ' + CAST(CONNECTIONPROPERTY('local_net_address') AS VARCHAR) + ',' + CAST(CONNECTIONPROPERTY('local_tcp_port') AS VARCHAR) + ' se han encontrado las siguientes ordenes de venta repetidas :</p>'
		SET @BODY += '<table>'
		SET @BODY += '<tr>'
		SET @BODY += '<th>DOC_SERIE</th>'
		SET @BODY += '<th>DOC_NUM</th>'
		SET @BODY += '<th>IS_POSTED_ERP</th>'
		SET @BODY += '<th>CANTIDAD</th>'
		SET @BODY += '</tr>'
		--
		SELECT 
		  @BODY += '<tr>'
			+ '<td>' + [T].[DOC_SERIE] + '</td>'
			+ '<td>' + CONVERT(VARCHAR,[T].[DOC_NUM]) + '</td>'
			+ '<td>' + CASE CONVERT(VARCHAR,[T].[QTY]) WHEN '0' THEN 'SI' ELSE 'NO' END + '</td>'
			+ '<td>' + CONVERT(VARCHAR,[T].[QTY]) + '</td>'
			+ '</tr>'
		FROM @RESUTL [T]
		--
		SET @BODY += '</table>'
		SET @BODY += '<p>Saludos, Equipo de soporte de Mobility.</p><br>'
		SET @BODY += '<img src="http://mobilityscm.com/img/mobility_colors.png" alt="MobilitySCM.com" style="width: 550px;height:150px;">'
		--
		PRINT '@BODY: ' + @BODY

		-- ------------------------------------------------------------------------------------
		-- Envia el correo
		-- ------------------------------------------------------------------------------------
		EXEC msdb.dbo.sp_send_dbmail  
		  @profile_name = @DEFAULT_PROFILE_NAME
		  ,@recipients = @DEFAULT_RECIPIENTS
		  ,@copy_recipients = @DEFAULT_RECIPIENTS_CC
		  ,@blind_copy_recipients = @DEFAULT_RECIPIENTS_CCO
		  ,@subject = 'ALERTA! Ordenes de Venta'
		  ,@body_format = 'HTML'
		  ,@body = @BODY;
	END
END;
