-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	04-04-2016
-- Description:			obtiene los operadores

--Modificado 23-05-2016
--          rudi.garcia
--          Se agrego el left join con la tabla de vehiculoas, para obtener el vehiuclo asociado del usuario.
/*
-- Ejemplo de Ejecucion:
        USE SWIFT_EXPRESS
        GO
        --
        EXEC [SONDA].[SWIFT_SP_GET_ROUTE_AND_SELLER]
			@LOGIN = 'OPER202@SONDA'
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_GET_ROUTE_AND_SELLER
	@LOGIN VARCHAR(50) = NULL
AS
BEGIN
	SELECT
		U.LOGIN
    ,ISNULL(V.CODE_VEHICLE, 'Sin Vehiculo')CODE_VEHICLE
		,R.CODE_ROUTE
		,R.NAME_ROUTE
		,S.SELLER_CODE
		,S.SELLER_NAME
	FROM [SONDA].[USERS] U
	INNER JOIN [SONDA].[SWIFT_ROUTES] R ON (U.SELLER_ROUTE = R.CODE_ROUTE)
	INNER JOIN [SONDA].[SWIFT_VIEW_ALL_SELLERS] S ON (U.RELATED_SELLER = S.SELLER_CODE)
  LEFT JOIN [SONDA].SWIFT_VEHICLE_X_USER VU ON (U.LOGIN = VU.LOGIN)
  LEFT JOIN SWIFT_EXPRESS.[SONDA].SWIFT_VEHICLES V ON (VU.VEHICLE = V.VEHICLE)
	WHERE @LOGIN IS NULL OR U.LOGIN = @LOGIN
END
