﻿create PROCEDURE [SONDA].[DEPRECATED_SWIFT_UPDATE_HEADER_MANIFEST]

@MANIFEST_HEADER INT,

@CODE_DRIVER VARCHAR(50),

@CODE_VEHICLE VARCHAR(50),

@COMMENTS VARCHAR(50),

@CODE_ROUTE VARCHAR(50),

@CODE_MANIFEST_HEADER VARCHAR(50)

AS

UPDATE [SONDA].SWIFT_MANIFEST_HEADER SET CODE_DRIVER = @CODE_DRIVER,

CODE_VEHICLE=@CODE_VEHICLE,COMMENTS=@COMMENTS,CODE_ROUTE=@CODE_ROUTE ,CODE_MANIFEST_HEADER = @CODE_MANIFEST_HEADER

WHERE MANIFEST_HEADER = @MANIFEST_HEADER
