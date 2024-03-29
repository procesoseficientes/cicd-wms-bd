﻿CREATE TABLE [SONDA].[SWIFT_PRIVILEGES_X_ROLE] (
    [ROLE_ID]      NUMERIC (18) NOT NULL,
    [PRIVILEGE_ID] NUMERIC (18) NOT NULL,
    CONSTRAINT [PK_SWIFT_PRIVILEGES_X_ROLE] PRIMARY KEY CLUSTERED ([ROLE_ID] ASC, [PRIVILEGE_ID] ASC),
    CONSTRAINT [FK_SWIFT_PRIVILEGES_X_ROLE_SWIFT_ROLE] FOREIGN KEY ([ROLE_ID]) REFERENCES [SONDA].[SWIFT_ROLE] ([ROLE_ID])
);


GO
CREATE NONCLUSTERED INDEX [IDX_SWIFT_PRIVILEGES_X_ROLE_ROLE_ID]
    ON [SONDA].[SWIFT_PRIVILEGES_X_ROLE]([ROLE_ID] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_SWIFT_PRIVILEGES_X_ROLE_PRIVILEGE_ID]
    ON [SONDA].[SWIFT_PRIVILEGES_X_ROLE]([PRIVILEGE_ID] ASC);

