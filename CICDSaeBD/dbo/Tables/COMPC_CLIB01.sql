CREATE TABLE [dbo].[COMPC_CLIB01] (
    [CLAVE_DOC] VARCHAR (20) NOT NULL,
    [CAMPLIB1]  VARCHAR (50) NULL,
    [CAMPLIB2]  DATETIME     NULL,
    [CAMPLIB3]  VARCHAR (50) NULL,
    [CAMPLIB4]  VARCHAR (1)  NULL,
    [CAMPLIB5]  VARCHAR (1)  NULL,
    [CAMPLIB6]  VARCHAR (1)  NULL,
    [CAMPLIB7]  VARCHAR (1)  NULL,
    [CAMPLIB8]  FLOAT (53)   NULL,
    [CAMPLIB9]  FLOAT (53)   NULL,
    [CAMPLIB10] FLOAT (53)   NULL,
    [CAMPLIB11] VARCHAR (40) NULL,
    [CAMPLIB12] VARCHAR (50) NULL,
    [CAMPLIB13] DATETIME     NULL,
    [CAMPLIB14] VARCHAR (1)  NULL,
    [CAMPLIB15] VARCHAR (20) NULL,
    [CAMPLIB16] FLOAT (53)   NULL,
    [CAMPLIB17] FLOAT (53)   NULL,
    [CAMPLIB18] FLOAT (53)   NULL,
    [CAMPLIB19] FLOAT (53)   NULL,
    [CAMPLIB20] FLOAT (53)   NULL,
    CONSTRAINT [PK_COMPC_CLIB01] PRIMARY KEY CLUSTERED ([CLAVE_DOC] ASC)
);




GO
-- =============================================
-- Author:		<Author,		Brayan Isidro>
-- Create date: <Create Date,	2022-12-16>
-- Description:	<Description,	Para tener alertas via correo cuando un documento de la SAR que este en el sistema SAE este proximo a vencer
-- =============================================
CREATE TRIGGER [dbo].[Tri_CAI_Proveedores] 
   ON [dbo].[COMPC_CLIB01]
   AFTER INSERT	
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	DECLARE @CAI			  VARCHAR(50)
	DECLARE @Recepcion		  VARCHAR(30)
	DECLARE @Cuerpo			  VARCHAR(2000)
	DECLARE @CodigoProveedor  VARCHAR(30)
	DECLARE @FechaLimite	  DATE
	DECLARE @FacturaSerie	  VARCHAR(50)
	DECLARE @FacturaFolio	  VARCHAR(50)
	DECLARE @Vencimiento	  INT = 0
	--
	DECLARE	@CorreoDestinatario  VARCHAR(50)= 'brayan.isidro@grupoalza.com'
	DECLARE	@NombreDestinatario VARCHAR(50)= 'BRAYAN'
	DECLARE @Asunto  VARCHAR(50) = 'Reporte de CAI de Proveedores Vencidos Grupo Alimenticio'
	DECLARE @Cabecera VARCHAR(50) = @Asunto

	SELECT  @Recepcion = TRIM(CLAVE_DOC)
	FROM INSERTED

	--SET @Cuerpo = 'Se ha ingresado el Pedido: ' + @Recepcion + '. Por favor ingresar al modulo de Cobranza para revisar. '
		

				
	
              IF( (SELECT COUNT(*) FROM AlzaWeb.dbo.CAI_RecepcionProveedores WHERE FLimiteEmision <= CONVERT(DATE,GETDATE()) AND Estado = 1 AND Empresa = 'GRUPO ALZA') > 0   )
              BEGIN

				SET @Cuerpo = '</br>' + 
							N'<H3>Reporte de CAI Vencido en la tabla de CAI Proveedores en Grupo Alimenticio</H3>' +
							N'<table border="1" style="background-color: #E6E6E6; border-color: #43AFDF; text-align: center; font-size: smaller;">' +
							N'<tr><th>CodigoProveedor</th><th>CAI</th><th>FLimiteEmision</th><th>RangoInicial</th><th>RangoFinal</th>' +

				CAST (
						 (
							SELECT 
							TD = CodigoProveedor, '',
							TD = CAI, '',
							TD = FLimiteEmision, '',
							TD = RangoInicial, '',
							TD = RangoFinal, ''
							FROM AlzaWeb.dbo.CAI_RecepcionProveedores
							WHERE FLimiteEmision <= CONVERT(DATE,GETDATE()) AND Estado = 1 AND Empresa = 'GRUPO ALZA'

							FOR XML PATH('tr'), TYPE
							) AS NVARCHAR(MAX)
					   )+ '</b>' +
							N'</table>' +
						  N'<H3>El presente mail solo indica CAI Vencidos</H3>';
				---ENVIO DEL EMAIL	
					 EXEC msdb.dbo.sp_send_dbmail     
					 @recipients = 'brayan.isidro@grupoalza.com;alex.gonzalez@grupoalza.com;evelin.hernandez@grupoalza.com;maria.reyes@grupoalza.com',  
					 @subject = @Asunto,  
					 @body = @Cuerpo,  
					 @body_format = 'HTML',  
					 @profile_name = 'sqlAlert';	

						 UPDATE       AlzaWeb.dbo.CAI_RecepcionProveedores
						SET                Estado = 0, FBaja = GETDATE()
						WHERE        (FLimiteEmision <= CONVERT(DATE, GETDATE())) AND Estado = 1

              END
			  ELSE IF((SELECT COUNT(*) FROM AlzaWeb.dbo.CAI_RecepcionProveedores WHERE FLimiteEmision <= CONVERT(DATE,GETDATE()) AND Estado = 1 AND Empresa = 'GRUPO ALZA') = 0 )
			  BEGIN



					SELECT @CodigoProveedor = TRIM(CVE_CLPV), @FacturaSerie = LEFT(SU_REFER,11), @FacturaFolio = RIGHT(SU_REFER,8) FROM SAE70EMPRESA01.dbo.COMPC01 WHERE TRIM(CVE_DOC) = TRIM(@Recepcion)

					SELECT @CAI = CAI, @FechaLimite = FLimiteEmision FROM AlzaWeb.dbo.CAI_RecepcionProveedores 
					WHERE CodigoProveedor = @CodigoProveedor AND Estado = 1 AND Serie = @FacturaSerie  AND UltimoDocumento < @FacturaFolio AND Empresa = 'GRUPO ALZA'

						
						UPDATE       AlzaWeb.dbo.CAI_RecepcionProveedores
						SET                Estado = 0, FBaja = GETDATE()
						WHERE   CodigoProveedor = @CodigoProveedor AND Estado = 1 AND Serie = @FacturaSerie  AND UltimoDocumento < @FacturaFolio AND Empresa = 'GRUPO ALZA'

					PRINT @CAI
					PRINT @FechaLimite
					PRINT @FacturaSerie
					PRINT @FacturaFolio

			  END
			  ELSE
			  BEGIN

			  
					SELECT @CodigoProveedor = TRIM(CVE_CLPV), @FacturaSerie = LEFT(SU_REFER,11), @FacturaFolio = RIGHT(SU_REFER,8) FROM SAE70EMPRESA01.dbo.COMPC01 WHERE TRIM(CVE_DOC) = TRIM(@Recepcion)

					SELECT @CAI = CAI, @FechaLimite = FLimiteEmision FROM AlzaWeb.dbo.CAI_RecepcionProveedores 
					WHERE CodigoProveedor = @CodigoProveedor AND Estado = 1 AND Serie = @FacturaSerie  AND UltimoDocumento >= @FacturaFolio AND Empresa = 'GRUPO ALZA'

					UPDATE SAE70EMPRESA01.dbo.COMPC_CLIB01
					SET    CAMPLIB1 = @CAI, CAMPLIB11 = @FechaLimite
					WHERE TRIM(CLAVE_DOC) = @Recepcion

					PRINT @CAI
					PRINT @FechaLimite
					PRINT @FacturaSerie
					PRINT @FacturaFolio

			  END								 								

END