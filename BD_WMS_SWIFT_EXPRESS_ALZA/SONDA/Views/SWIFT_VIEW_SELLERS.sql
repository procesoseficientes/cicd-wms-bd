﻿CREATE VIEW [SONDA].[SWIFT_VIEW_SELLERS]
AS
SELECT CORRELATIVE, [LOGIN], NAME_USER FROM [SONDA].USERS WHERE TYPE_USER = 'Vendedor'
