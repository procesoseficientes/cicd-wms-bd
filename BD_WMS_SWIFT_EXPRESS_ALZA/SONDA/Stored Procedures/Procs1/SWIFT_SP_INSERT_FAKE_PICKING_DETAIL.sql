
-- =============================================
-- Autor:				pablo.aguilar
-- Fecha de Creacion: 	17-Oct-16 @ A-TEAM Sprint 
-- Description:			SP que obtiene el detalle de las consignaciones filtrado por fecha.

/*
-- Ejemplo de Ejecucion:
	EXEC [SONDA].[SWIFT_SP_INSERT_FAKE_PICKING_DETAIL] 	@PICKING_HEADER = 3155
														,@CODE_SKU = 'PRUEBA'
														,@DESCRIPTION_SKU = 'PRUEBA'
														,@QUANTITY = 50.0

SELECT * FROM [SONDA].[SWIFT_PICKING_DETAIL] [spd] ORDER BY [spd].[PICKING_HEADER] DESC 														
*/
-- =============================================

CREATE PROCEDURE [SONDA].[SWIFT_SP_INSERT_FAKE_PICKING_DETAIL]
@PICKING_HEADER INT
, @CODE_SKU VARCHAR (50)
, @DESCRIPTION_SKU VARCHAR (300)
, @QUANTITY AS FLOAT


AS
BEGIN TRY
	DECLARE @ID INT


	INSERT INTO [SONDA].[SWIFT_PICKING_DETAIL] ([PICKING_HEADER], [CODE_SKU], [DESCRIPTION_SKU], [DISPATCH], [SCANNED], [LAST_UPDATE], [LAST_UPDATE_BY], [DIFFERENCE], [RESULT] )
	VALUES (@PICKING_HEADER, @CODE_SKU, @DESCRIPTION_SKU,@QUANTITY   ,@QUANTITY ,GETDATE() ,'FAKE_PICKING', 0, 0)

	SELECT
		@ID = SCOPE_IDENTITY()

	IF @@error = 0
	BEGIN
		SELECT
			1 AS Resultado
			,'Proceso Exitoso' Mensaje
			,0 Codigo
			,CONVERT(VARCHAR(16), @ID) DbData
	END
	ELSE
	BEGIN
		SELECT
			-1 AS Resultado
			,ERROR_MESSAGE() Mensaje
			,@@error Codigo
			,CONVERT(VARCHAR(16), '0') DbData
	END
END TRY
BEGIN CATCH
	SELECT
		-1 AS Resultado
		,ERROR_MESSAGE() Mensaje
		,@@error Codigo
		,CONVERT(VARCHAR(16), '0') DbData
END CATCH
