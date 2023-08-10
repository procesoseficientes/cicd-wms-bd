-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		13-06-2016
-- Description:			    Obtiene las clasificaciones de las razones

/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].[SWIFT_GET_CLASSIFICATION_ALTERNATE]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_GET_CLASSIFICATION_ALTERNATE]
AS
BEGIN
	-- ------------------------------------------------------------------------------------
	-- Obtiene todas las clasificaciones
	-- ------------------------------------------------------------------------------------
	SELECT
		[CLASSIFICATION]
		,[NAME_CLASSIFICATION]
		,[PRIORITY_CLASSIFICATION]
		,[VALUE_TEXT_CLASSIFICATION]
		,[MPC01]
		,[GROUP_CLASSIFICATION]
	INTO #REASON
	FROM [SONDA].[SWIFT_CLASSIFICATION] [C]
	WHERE [GROUP_CLASSIFICATION] LIKE '%_REASONS%';

	-- ------------------------------------------------------------------------------------
	-- Agregar la razon sin razones
	-- ------------------------------------------------------------------------------------
	INSERT INTO [#REASON]
			(
				[NAME_CLASSIFICATION]
				,[PRIORITY_CLASSIFICATION]
				,[VALUE_TEXT_CLASSIFICATION]
				,[MPC01]
				,[GROUP_CLASSIFICATION]
			)
	VALUES
			(
				'SIN RAZONES'
				,1
				,'SIN_RAZONES'
				,NULL
				,'NO_REASONS'
			)

	-- ------------------------------------------------------------------------------------
	-- Muestra el resultado
	-- ------------------------------------------------------------------------------------
	SELECT
		[R].[CLASSIFICATION]
		,[R].[NAME_CLASSIFICATION]
		,[R].[PRIORITY_CLASSIFICATION]
		,[R].[VALUE_TEXT_CLASSIFICATION]
		,[R].[MPC01]
		,[R].[GROUP_CLASSIFICATION]
	FROM [#REASON] R
END
