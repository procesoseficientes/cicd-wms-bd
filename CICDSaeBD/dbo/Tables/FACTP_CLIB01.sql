CREATE TABLE [dbo].[FACTP_CLIB01] (
    [CLAVE_DOC] VARCHAR (20)  NOT NULL,
    [CAMPLIB1]  VARCHAR (25)  NULL,
    [CAMPLIB2]  VARCHAR (10)  NULL,
    [CAMPLIB3]  FLOAT (53)    NULL,
    [CAMPLIB4]  VARCHAR (30)  NULL,
    [CAMPLIB5]  VARCHAR (30)  NULL,
    [CAMPLIB6]  VARCHAR (30)  NULL,
    [CAMPLIB7]  VARCHAR (30)  NULL,
    [CAMPLIB8]  DATETIME      NULL,
    [CAMPLIB9]  VARCHAR (20)  NULL,
    [CAMPLIB10] VARCHAR (20)  NULL,
    [CAMPLIB11] DATETIME      NULL,
    [CAMPLIB12] VARCHAR (30)  NULL,
    [CAMPLIB13] VARCHAR (30)  NULL,
    [CAMPLIB14] VARCHAR (30)  NULL,
    [CAMPLIB15] VARCHAR (50)  NULL,
    [CAMPLIB16] VARCHAR (20)  NULL,
    [CAMPLIB17] VARCHAR (60)  NULL,
    [CAMPLIB18] VARCHAR (60)  NULL,
    [CAMPLIB19] VARCHAR (20)  NULL,
    [CAMPLIB20] VARCHAR (1)   NULL,
    [CAMPLIB21] VARCHAR (100) NULL,
    [CAMPLIB22] INT           NULL,
    [CAMPLIB23] VARCHAR (40)  NULL,
    [CAMPLIB24] VARCHAR (250) NULL,
    CONSTRAINT [PK_FACTP_CLIB01] PRIMARY KEY CLUSTERED ([CLAVE_DOC] ASC)
);



GO
-- =============================================
-- Author:		<Author,		Diego Espinoza>
-- Create date: <Create Date,	Octubre 10 -2019>
-- Description:	<Description,	Para bloquear Pedidos de Estado Revision
--				 Req. by Diego E., Ricardo M., Joel V.>
--				 Al ingresar un pedido desde SONDA Bloqueado, CAMPLIB23 = 'REVISION', se actualizara campo en FACTP01
--				 Para que no permita remitir hasta que se apruebe.
-- =============================================
CREATE TRIGGER [dbo].[Tri_BloquedoPedidos] 
   ON [dbo].[FACTP_CLIB01]  
   AFTER INSERT	
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	DECLARE @CAMPLIB23	  VARCHAR(30)
	DECLARE @Pedido		  VARCHAR(30)
	DECLARE @Cuerpo		  VARCHAR(2000)

	--Variables para validacion desde SAE de Creditos y Cobranza. DEM. Nov. 8th -2019
	DECLARE	@LIMCRED		AS NUMERIC(18,2)
	--DECLARE	@Saldo			AS NUMERIC(18,2)
	DECLARE	@Disponible		AS NUMERIC(18,2)
	DECLARE	@Importe		AS NUMERIC(18,2)
	DECLARE @CodigoCliente	AS VARCHAR(30)
	DECLARE @Cliente		AS VARCHAR(30)

	DECLARE @DiasVencidos	AS INTEGER
	DECLARE @ValidarClientCode	AS INTEGER
	DECLARE @BODEGUITA AS INTEGER
	DECLARE @PEDIDITO AS INTEGER

	
	SELECT @CAMPLIB23 = CAMPLIB23, @Pedido = LTRIM(CLAVE_DOC)
	FROM INSERTED

	SET @Cuerpo = 'Se ha ingresado el Pedido: ' + @Pedido + '. Por favor ingresar al modulo de Cobranza para revisar. '


	--DEM Septiembre 28-2020. Redireccionar Almacen para Clientes de TGU. 
	--Problema reportado en TGU por Luis G. Visto con Laudy C. para hacer direccion automatica segun cliente.

	SELECT @Cliente = REPLACE(LTRIM(CVE_CLPV), ' ', '') FROM SAE70EMPRESA01.dbo.FACTP01
	WHERE REPLACE(LTRIM(CVE_DOC), ' ', '') = LTRIM(REPLACE(@Pedido, ' ',''))

	--Esto valida si el codido de cliente lleva texto
	SELECT @ValidarClientCode = ISNUMERIC(@Cliente)

	--Si cliente es TGU, actualizar Almacen
	IF @ValidarClientCode = 1
			--IF( CONVERT(INT, REPLACE(REPLACE(@Cliente, '2388|', 0), 'MOSTR', 0) ) > 5000 )
			--	BEGIN

			--		UPDATE SAE70EMPRESA01.dbo.FACTP01
			--		SET NUM_ALMA = 4
			--		WHERE REPLACE(LTRIM(CVE_DOC), ' ', '') = LTRIM(REPLACE(@Pedido, ' ',''))	

			--		UPDATE SAE70EMPRESA01.dbo.PAR_FACTP01
			--		SET NUM_ALM = 4
			--		WHERE REPLACE(LTRIM(CVE_DOC), ' ', '') = LTRIM(REPLACE(@Pedido, ' ',''))	
			--	END
				BEGIN
				 
				SELECT @BODEGUITA = CAMPLIB46 FROM SAE70EMPRESA01.dbo.CLIE_CLIB01 WHERE TRIM(CVE_CLIE) = TRIM(@Cliente)
					
					UPDATE SAE70EMPRESA01.dbo.FACTP01
					SET NUM_ALMA = @BODEGUITA
					WHERE REPLACE(LTRIM(CVE_DOC), ' ', '') = LTRIM(REPLACE(@Pedido, ' ',''))	

					UPDATE SAE70EMPRESA01.dbo.PAR_FACTP01
					SET NUM_ALM = @BODEGUITA
					WHERE REPLACE(LTRIM(CVE_DOC), ' ', '') = LTRIM(REPLACE(@Pedido, ' ',''))	

				END
			
	ELSE
	      BEGIN
				UPDATE SAE70EMPRESA01.dbo.FACTP01
				SET NUM_ALMA = 1
				WHERE REPLACE(LTRIM(CVE_DOC), ' ', '') = LTRIM(REPLACE(@Pedido, ' ',''))	

				UPDATE SAE70EMPRESA01.dbo.PAR_FACTP01
				SET NUM_ALM = 1
				WHERE REPLACE(LTRIM(CVE_DOC), ' ', '') = LTRIM(REPLACE(@Pedido, ' ',''))	
				
			END
	    
	   	  
	
	--Nota DEM. Nov. 8 -2019. Esto viene automatico de SONDA y funciona solo para SONDA. se hara otro if para pedidos ingresados
	--desde SAE. Req. by Joel V., Ricardo M.
	-- Si esta en revision, evnviar correo a Creditos. 
	--Nov. 11 - 2019. Notas DEM: 
	IF( ISNULL(@CAMPLIB23, '') = 'REVISION' )
	BEGIN

			UPDATE SAE70EMPRESA01.dbo.FACTP01
			SET TIP_DOC_SIG = 'R', STATUS = 'C'
			WHERE REPLACE(LTRIM(CVE_DOC), ' ', '') = LTRIM(REPLACE(@Pedido, ' ',''))

			EXEC msdb.dbo.sp_send_dbmail @profile_name	= 'SqlAlert', 
									 @recipients		= 'liliam.suazo@grupoalza.com', 
									 @copy_recipients	= 'diego.espinoza@grupoalza.com', 
									 @subject			= 'Pedido por Aprobar', 
									 @body				=  @Cuerpo, 
									 @body_format		= 'text'

									 									 

	END
	ELSE BEGIN

		--Nota DEM. Nov. 8 -2019. Veriricar al crear pedido si el mismo pasara OK a remisiones o si caera en Aprobacion de
		--Creditos y Cobranza. Esto para pedidos aun ingresados desde SAE / Telemarketing. 
		--Limite de Credito excedido y Saldo vencido con dias de holgura otorgados por Finazas.

		--1)	Verificar si excede limite de credito.
		SELECT @Importe = IMPORTE, @CodigoCliente = CVE_CLPV  FROM SAE70EMPRESA01.dbo.FACTP01
		--WHERE CVE_DOC = @Pedido
		WHERE REPLACE(LTRIM(CVE_DOC), ' ', '') = LTRIM(REPLACE(@Pedido, ' ',''))

		--SELECT @LIMCRED = LIMCRED, @Saldo = SALDO, @Disponible = (LIMCRED - SALDO - 0)
		SELECT @Disponible = (LIMCRED - SALDO - @Importe), @LIMCRED = LIMCRED
		FROM SAE70EMPRESA01.dbo.CLIE01
		WHERE LTRIM(CLAVE) = LTRIM(@CodigoCliente)

		--DiasVencidos con saldo
		SELECT @DiasVencidos = CASE WHEN MAX(CAMPLIB38) = 'CREDITO' THEN MIN(Dias) + 0 
					WHEN MAX(CAMPLIB38) = 'CONTADO' THEN MIN(Dias) + 7
				ELSE MIN(Dias)
				END 
		FROM AlzaWeb.dbo.vAntiguedadClientes Antiguedad
			LEFT JOIN SAE70EMPRESA01.dbo.CLIE_CLIB01 Campos 
				ON Antiguedad.CLAVE = Campos.CVE_CLIE
		WHERE LTRIM(CLAVE) = LTRIM(@CodigoCliente)

		--Tiene limite de Credito mayor a 0 establecido en SAE y segun saldo y total de pedido, lo excede. Tiene saldo vencido incluyendo los dias de gracia.
		--Enviar a Bandeja de Creditos y Cobranza, Colocar pedido cancelado hasta que sea aprobado o rechazado.
		
		--Aca tienen quer ir los condigos de los consumidores finales
		IF NOT EXISTS( SELECT 1 FROM SAE70EMPRESA01.dbo.CLIE01 WHERE LTRIM(@CodigoCliente) = LTRIM(CLAVE) AND NOMBRE LIKE '%CONSUMIDOR%' )
		BEGIN
 
			IF( @Disponible < 0 AND @LIMCRED > 0 OR (@DiasVencidos < 0) )
			BEGIN
				
				UPDATE SAE70EMPRESA01.dbo.FACTP01
				SET TIP_DOC_SIG = 'R', STATUS = 'C'
				WHERE REPLACE(LTRIM(CVE_DOC), ' ', '') = LTRIM(REPLACE(@Pedido, ' ',''))

				UPDATE SAE70EMPRESA01.dbo.FACTP_CLIB01
				SET CAMPLIB23 = 'REVISION'
				WHERE REPLACE(LTRIM(CLAVE_DOC), ' ', '') = LTRIM(REPLACE(@Pedido, ' ',''))

				EXEC msdb.dbo.sp_send_dbmail @profile_name	= 'SqlAlert', 
										 @recipients		= 'liliam.suazo@grupoalza.com', 
										 @copy_recipients	= 'diego.espinoza@grupoalza.com', 
										 @subject			= 'Pedido por Aprobar', 
										 @body				=  @Cuerpo, 
										 @body_format		= 'text'

			END

		END
					
	END



END