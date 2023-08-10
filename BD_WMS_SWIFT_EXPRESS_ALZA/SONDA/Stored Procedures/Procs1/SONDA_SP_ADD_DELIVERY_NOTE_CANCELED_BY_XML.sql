-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	12/12/2017 @ Reborn-TEAM Sprint Pannen
-- Description:			SP que agrega las Notas De Entrega que hayan sido canceladas en el movil

/*
-- Ejemplo de Ejecucion:
		EXEC [SONDA].[SONDA_SP_ADD_DELIVERY_NOTE_CANCELED_BY_XML]
		@XML = '
			<Data>
				<notasDeEntrega>
					<docSerie>Nota De Entrega</docSerie>
					<docNum>48</docNum>
					<isCanceled>1</isCanceled>
					<reasonCancel>Factura En Mal Estado</reasonCancel>
				</notasDeEntrega>
				<notasDeEntrega>
					<docSerie>Nota De Entrega</docSerie>
					<docNum>50</docNum>
					<isCanceled>1</isCanceled>
					<reasonCancel>Producto En Mal Estado</reasonCancel>
				</notasDeEntrega>
				<dbuser>USONDA</dbuser>
				<dbuserpass>SONDAServer1237710</dbuserpass>
				<routeid>46</routeid>
				<loginId>Adolfo@SONDA</loginId>
			</Data>
		'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_ADD_DELIVERY_NOTE_CANCELED_BY_XML](
	@XML XML
)
AS
BEGIN
	--
	SET NOCOUNT ON;

	--
	BEGIN TRY
		--
		DECLARE @DELIVERY_NOTE_CANCELED TABLE (
			[DOC_SERIE] VARCHAR(250)
			, [DOC_NUM] INT
			, [IS_CANCELED] INT
			, [REASON_CANCEL] VARCHAR(250)
			, PRIMARY KEY NONCLUSTERED ([DOC_NUM])
		);
		--

		-- ------------------------------------------------------------------------------
		-- Se obtienen las notas de entrega canceladas
		-- ------------------------------------------------------------------------------
		INSERT	INTO @DELIVERY_NOTE_CANCELED
				(
					[DOC_SERIE]
					,[DOC_NUM]
					,[IS_CANCELED]
					,[REASON_CANCEL]
				)
		SELECT
			[x].[Rec].[query]('./docSerie').[value]('.' ,'varchar(250)')
			,[x].[Rec].[query]('./docNum').[value]('.' ,'int')
			,CASE [x].[Rec].[query]('./isCanceled').[value]('.' ,'varchar(50)')
				WHEN 'NULL' THEN 0
				WHEN 'UNDEFINED' THEN 0
				ELSE [x].[Rec].[query]('./isCanceled').[value]('.' ,'int')
				END
			,CASE [x].[Rec].[query]('./reasonCancel').[value]('.' ,'varchar(250)')
				WHEN 'NULL' THEN NULL
				WHEN 'UNDEFINED' THEN NULL
				ELSE [x].[Rec].[query]('./reasonCancel').[value]('.' , 'varchar(250)')
				END
		FROM
			@XML.[nodes]('Data/notasDeEntrega') AS [x] ([Rec]); 
		
		-- ------------------------------------------------------------------------------
		-- Se actualizan las entregas segun los datos obtenidos
		-- ------------------------------------------------------------------------------
		UPDATE [DN]
			SET [DN].[IS_CANCELED] = [DC].[IS_CANCELED]
			,[DN].[REASON_CANCEL] = [DC].[REASON_CANCEL]
		FROM [SONDA].[SONDA_DELIVERY_NOTE_HEADER] AS [DN]
		INNER JOIN @DELIVERY_NOTE_CANCELED AS [DC]
		ON([DN].[DOC_SERIE] = [DC].[DOC_SERIE]
			AND [DN].[DOC_NUM] = [DC].[DOC_NUM]
			)
		WHERE [DC].[DOC_NUM] > 0
		--
		SELECT  1 as [Resultado] , 'Proceso Exitoso' [Mensaje] ,  0 [Codigo], CAST(0 AS VARCHAR) [DbData]
	END TRY
	BEGIN CATCH
		SELECT  -1 as [Resultado]
		,ERROR_MESSAGE() [Mensaje] 
		,@@ERROR [Codigo] 
	END CATCH
END
