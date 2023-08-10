-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		04-Apr-17 @ A-Team Sprint Garai
-- Description:			    Genera validacion de ordenes de venta que se intentarion enviar al ERP

/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].[SWIFT_SP_VALIDATE_SALES_ORDER_READY_TO_SEND] 
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_VALIDATE_SALES_ORDER_READY_TO_SEND]
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @RESUTL TABLE(
		[SALES_ORDER_ID] INT
		,[DOC_SERIE] VARCHAR(50)
		,[DOC_NUM] INT
		,[LAST_UPDATE_IS_SENDING] DATETIME
	)
	--
	DECLARE 
		@DATETIME DATETIME = DATEADD(MINUTE,-30,GETDATE())
		,@QTY INT = 0;
	--
	INSERT INTO @RESUTL
	(
		[SALES_ORDER_ID]
		,[DOC_SERIE]
		,[DOC_NUM]
		,[LAST_UPDATE_IS_SENDING]
	)
	SELECT
		[SO].[SALES_ORDER_ID]
		,[SO].[DOC_SERIE]
		,[SO].[DOC_NUM]
		,[SO].[LAST_UPDATE_IS_SENDING]
	FROM [SONDA].[SONDA_SALES_ORDER_HEADER] (NOLOCK) [SO]
	WHERE [SO].[SALES_ORDER_ID] > 0
		AND [SO].[IS_READY_TO_SEND] = 1
		AND [SO].[IS_SENDING] = 1
		AND [SO].[LAST_UPDATE_IS_SENDING] <= @DATETIME
	ORDER BY [SO].[SALES_ORDER_ID]
	--
	SET @QTY = @@ROWCOUNT
	--
	IF @QTY > 0
	BEGIN
		-- ---------------------------------------------------------------
		-- Envia alerta
		-- ---------------------------------------------------------------
		DECLARE
			@DEFAULT_PROFILE_NAME VARCHAR(250) = ''
			,@DEFAULT_RECIPIENTS VARCHAR(250) = ''
			,@DEFAULT_RECIPIENTS_CC VARCHAR(250) = ''
			,@DEFAULT_RECIPIENTS_CCO VARCHAR(250) = ''
			,@BODY VARCHAR(MAX) = ''

		-- ------------------------------------------------------------------------------------
		-- Obtiene los parametros para el correo
		-- ------------------------------------------------------------------------------------
		SELECT
			@DEFAULT_PROFILE_NAME = [SONDA].[SWIFT_FN_GET_PARAMETER]('VALIDATION_MAIL' , 'DEFAULT_PROFILE_NAME')
			,@DEFAULT_RECIPIENTS = [SONDA].[SWIFT_FN_GET_PARAMETER]('VALIDATION_MAIL' , 'DEFAULT_RECIPIENTS')
			,@DEFAULT_RECIPIENTS_CC = [SONDA].[SWIFT_FN_GET_PARAMETER]('VALIDATION_MAIL' , 'DEFAULT_RECIPIENTS_CC')
			,@DEFAULT_RECIPIENTS_CCO = [SONDA].[SWIFT_FN_GET_PARAMETER]('VALIDATION_MAIL' , 'DEFAULT_RECIPIENTS_CCO')
			,@BODY = ''

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
		SET @BODY += '<p>En ARIUM en el servidor ' + @@SERVERNAME + ' con la IP ' + CAST(CONNECTIONPROPERTY('local_net_address') AS VARCHAR) + ',' + CAST(CONNECTIONPROPERTY('local_tcp_port') AS VARCHAR) + ' se han encontrado las siguientes ordenes de venta las cuales no fue posible enviarlas al ERP:</p>'
		SET @BODY += '<table>'
		SET @BODY += '<tr>'
		SET @BODY += '<th>DOC_RESOLUTION</th>'
		SET @BODY += '<th>DOC_SERIE</th>'
		SET @BODY += '<th>DOC_NUM</th>'
		SET @BODY += '<th>LAST_UPDATE_IS_SENDING</th>'
		SET @BODY += '</tr>'
		--
		SELECT 
		  @BODY += '<tr>'
			+ '<td>' + CONVERT(VARCHAR,[T].[SALES_ORDER_ID]) + '</td>'
			+ '<td>' + [T].[DOC_SERIE] + '</td>'
			+ '<td>' + CONVERT(VARCHAR,[T].[DOC_NUM]) + '</td>'
			+ '<td>' + CONVERT(VARCHAR,[T].[LAST_UPDATE_IS_SENDING], 121) + '</td>'
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
		  ,@subject = 'ALERTA! Ordenes de venta'
		  ,@body_format = 'HTML'
		  ,@body = @BODY;
	END
END;
