CREATE TABLE [dbo].[MINVE01] (
    [CVE_ART]         VARCHAR (16) NOT NULL,
    [ALMACEN]         INT          NOT NULL,
    [NUM_MOV]         INT          NOT NULL,
    [CVE_CPTO]        INT          NOT NULL,
    [FECHA_DOCU]      DATETIME     NULL,
    [TIPO_DOC]        VARCHAR (1)  NULL,
    [REFER]           VARCHAR (20) NULL,
    [CLAVE_CLPV]      VARCHAR (10) NULL,
    [VEND]            VARCHAR (5)  NULL,
    [CANT]            FLOAT (53)   NULL,
    [CANT_COST]       FLOAT (53)   NULL,
    [PRECIO]          FLOAT (53)   NULL,
    [COSTO]           FLOAT (53)   NULL,
    [AFEC_COI]        VARCHAR (1)  NULL,
    [CVE_OBS]         INT          NULL,
    [REG_SERIE]       INT          NULL,
    [UNI_VENTA]       VARCHAR (10) NULL,
    [E_LTPD]          INT          NULL,
    [EXIST_G]         FLOAT (53)   NULL,
    [EXISTENCIA]      FLOAT (53)   NULL,
    [TIPO_PROD]       VARCHAR (1)  NULL,
    [FACTOR_CON]      FLOAT (53)   NULL,
    [FECHAELAB]       DATETIME     NULL,
    [CTLPOL]          INT          NULL,
    [CVE_FOLIO]       VARCHAR (9)  NULL,
    [SIGNO]           INT          NULL,
    [COSTEADO]        VARCHAR (1)  NULL,
    [COSTO_PROM_INI]  FLOAT (53)   NULL,
    [COSTO_PROM_FIN]  FLOAT (53)   NULL,
    [COSTO_PROM_GRAL] FLOAT (53)   NULL,
    [DESDE_INVE]      VARCHAR (1)  NULL,
    [MOV_ENLAZADO]    INT          NULL
);




GO
CREATE NONCLUSTERED INDEX [IDX_MINVE101]
    ON [dbo].[MINVE01]([CVE_ART] ASC, [ALMACEN] ASC, [NUM_MOV] ASC, [CVE_CPTO] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_MINVE201]
    ON [dbo].[MINVE01]([ALMACEN] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_MINVE301]
    ON [dbo].[MINVE01]([FECHA_DOCU] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_MINVE401]
    ON [dbo].[MINVE01]([CVE_CPTO] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_MINVE501]
    ON [dbo].[MINVE01]([NUM_MOV] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_MINVE601]
    ON [dbo].[MINVE01]([E_LTPD] ASC);


GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO
CREATE NONCLUSTERED INDEX [IDX_MINVE701]
    ON [dbo].[MINVE01]([CVE_CPTO] ASC, [REFER] ASC, [CVE_ART] ASC, [REG_SERIE] ASC);


GO
-- =============================================
-- Author:		<Author,		Brayan Isidro>
-- Create date: <Create Date,	Octubre 10 -2019>
-- Description:	<Description,	Para bloquear Pedidos de Estado Revision
--				 Req. by Diego E., Ricardo M., Joel V.>
--				 Al ingresar un pedido desde SONDA Bloqueado, CAMPLIB23 = 'REVISION', se actualizara campo en FACTP01
--				 Para que no permita remitir hasta que se apruebe.
-- =============================================
CREATE TRIGGER [dbo].[Tri_Control_DocumentoSAR] 
   ON [dbo].[MINVE01]
   AFTER INSERT	
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	DECLARE @Recepcion		  VARCHAR(30)
	DECLARE @Cuerpo			  VARCHAR(2500)
	DECLARE @Inserta		  INT = 0
	--
	DECLARE	@CorreoDestinatario  VARCHAR(50)= 'brayan.isidro@grupoalza.com;nestor.oliva@grupoalza.com;alex.gonzalez@grupoalza.com'
	DECLARE	@NombreDestinatario VARCHAR(50)= 'BRAYAN'
	DECLARE @Asunto  VARCHAR(50) = 'Reporte de Documento de la SAR Proximos a Vencer'
	DECLARE @Cabecera VARCHAR(50) = @Asunto

	SELECT  @Recepcion = TRIM(REFER)
	FROM INSERTED

	--SET @Cuerpo = 'Se ha ingresado el Pedido: ' + @Recepcion + '. Por favor ingresar al modulo de Cobranza para revisar. '
		

			--	SELECT * FROM Reportes.dbo.vControl_Documentos_SAR_Alza WHERE DisponibilidadDeDocumentos <= 1000 OR DiasDisponible <= 300
	
              IF( (SELECT COUNT(*) FROM Reportes.dbo.vControl_Documentos_SAR_Alza WHERE DisponibilidadDeDocumentos <= 5 OR DiasDisponible <= 5 AND Estado = 1) > 0   )
              BEGIN

			  
				  IF((SELECT COUNT(1) FROM AlzaWeb.dbo.NotificacionesCAI WHERE Empresa = 'Alza' ) = 0)	
					BEGIN
						SELECT @Inserta = 1	
					END
				  IF((SELECT TOP(1)IIF(DATEDIFF(HOUR,FechaEnvio,GETDATE())>2,0,1)FechaEnvio FROM AlzaWeb.dbo.NotificacionesCAI WHERE Empresa = 'Alza' ORDER BY Id DESC) = 0 )	
					BEGIN
						SELECT @Inserta = 1		
					END
				  Else
					BEGIN
						SELECT @Inserta = 0
					END
				

				  IF (@Inserta = 1)
					BEGIN
						INSERT INTO AlzaWeb.dbo.NotificacionesCai (FechaEnvio, Empresa) VALUES(GETDATE(), 'Alza')
						SET @Cuerpo = '</br>' + 
									N'<H3>Reporte de Documento de la SAR Proximos a Vencer Grupo Alimenticio</H3>' +
									N'<table border="1" style="background-color: #E6E6E6; border-color: #43AFDF; text-align: center; font-size: smaller;">' +
									N'<tr><th>Empresa</th><th>TipoDocumento</th><th>Serie</th><th>FolioInicial</th><th>FolioFinal</th><th>FechaLimiteEmision</th><th>UltimoDocumentoSAE</th><th>UltimoDocumentoIT</th><th>DisponibilidadDeDocumentos</th><th>DiasDisponible</th>' +

						CAST (
								 (
										SELECT 
										TD = Empresa, '',
										TD = TipoDocumento, '',
										TD = Serie, '',
										TD = FolioInicial, '',
										TD = FolioFinal, '',
										TD = FechaLimiteEmision, '',
										TD = UltimoDocumentoSAE, '',
										TD = UltimoDocumentoIT, '',
										TD = DisponibilidadDeDocumentos, '',
										TD = DiasDisponible,''
										FROM Reportes.dbo.vControl_Documentos_SAR_Alza WHERE DisponibilidadDeDocumentos <= 5 OR DiasDisponible <= 5 AND Estado = 1

									FOR XML PATH('tr'), TYPE
									) AS NVARCHAR(MAX)
							   )+ '</b>' +
									N'</table>' +
								  N'<H3>El presente mail solo indica CAI Vencidos</H3>';
						---ENVIO DEL EMAIL	
							 EXEC msdb.dbo.sp_send_dbmail     
							 @recipients = 'brayan.isidro@grupoalza.com;nestor.oliva@grupoalza.com;alex.gonzalez@grupoalza.com;evelin.hernandez@grupoalza.com;maria.reyes@grupoalza.com',  
							 @subject = @Asunto,  
							 @body = @Cuerpo,  
							 @body_format = 'HTML',  
							 @profile_name = 'sqlAlert';	
					  END
					ELSE
					 BEGIN
					   PRINT('YA SE ENVIO UNA NOTIFICACION')
					 END

              END
			  ELSE IF((SELECT COUNT(*) FROM Reportes.dbo.vControl_Documentos_SAR_Alza WHERE DisponibilidadDeDocumentos <= 5 OR DiasDisponible <= 5 AND Estado = 1 ) = 0 )
			  BEGIN



					PRINT('NO SE ENCONTRARON DOCUMENTOS VENCIDOS')

			  END

			  	 DECLARE @NumeroCAI INT = (SELECT Id FROM Reportes.dbo.vControl_Documentos_SAR_Alza WHERE DisponibilidadDeDocumentos < 0 OR DiasDisponible < 0 AND Estado = 1);
				 PRINT @NumeroCAI

				UPDATE CONTROL_DOCUMENTOS
				SET    Estado = 0 , FechaBaja = GETDATE()
				WHERE  (Id = @NumeroCAI AND Estado = 1)
			   

END