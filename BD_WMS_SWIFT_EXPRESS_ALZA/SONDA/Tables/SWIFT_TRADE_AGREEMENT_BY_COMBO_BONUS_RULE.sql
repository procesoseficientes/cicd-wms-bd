﻿CREATE TABLE [SONDA].[SWIFT_TRADE_AGREEMENT_BY_COMBO_BONUS_RULE] (
    [TRADE_AGREEMENT_BONUS_RULE_BY_COMBO_ID] INT          IDENTITY (1, 1) NOT NULL,
    [COMBO_ID]                               INT          NOT NULL,
    [BONUS_TYPE]                             VARCHAR (50) DEFAULT ('UNIQUE') NULL,
    [BONUS_SUB_TYPE]                         VARCHAR (50) NULL,
    [IS_BONUS_BY_LOW_PURCHASE]               INT          DEFAULT ((0)) NOT NULL,
    [IS_BONUS_BY_COMBO]                      INT          DEFAULT ((1)) NOT NULL,
    [LOW_QTY]                                INT          NOT NULL,
    PRIMARY KEY CLUSTERED ([TRADE_AGREEMENT_BONUS_RULE_BY_COMBO_ID] ASC),
    CONSTRAINT [FK__SWIFT_TRA__COMBO__5E0D488B] FOREIGN KEY ([COMBO_ID]) REFERENCES [SONDA].[SWIFT_COMBO] ([COMBO_ID])
);


GO
CREATE NONCLUSTERED INDEX [IN_SWIFT_TRADE_AGREEMENT_BY_COMBO_BONUS_RULE_COMBO_ID]
    ON [SONDA].[SWIFT_TRADE_AGREEMENT_BY_COMBO_BONUS_RULE]([COMBO_ID] ASC);

