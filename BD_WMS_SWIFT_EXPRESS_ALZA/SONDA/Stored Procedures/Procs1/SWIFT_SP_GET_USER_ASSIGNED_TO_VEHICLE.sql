﻿CREATE PROCEDURE [SONDA].SWIFT_SP_GET_USER_ASSIGNED_TO_VEHICLE
(
   @CODE_VEHICLE INT 
)
  AS
    SET NOCOUNT ON;

  DECLARE @ID_VEHICLE INT ;
  SET @ID_VEHICLE = ( SELECT  TOP(1) VEHICLE FROM [SONDA].SWIFT_VEHICLES WHERE CODE_VEHICLE = @CODE_VEHICLE )

  SELECT U.* , ss.SELLER_NAME 
    FROM [SONDA].USERS U  
    LEFT JOIN [SONDA].SWIFT_SELLER ss 
      ON  (U.RELATED_SELLER = ss.SELLER_CODE)
  WHERE U.TYPE_USER = 'Operador' AND
        EXISTS(SELECT 1 FROM [SONDA].SWIFT_VEHICLE_X_USER svxu WHERE U.LOGIN = svxu.LOGIN AND svxu.VEHICLE = @ID_VEHICLE )
