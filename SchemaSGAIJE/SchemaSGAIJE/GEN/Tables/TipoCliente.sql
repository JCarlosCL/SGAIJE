CREATE TABLE [GEN].[TipoCliente] (
    [unqGenTipoClienteKey] UNIQUEIDENTIFIER DEFAULT (newsequentialid()) NOT NULL,
    [vchDescripcion]       VARCHAR (100)    NULL,
    [decDescuento]         DECIMAL (18, 2)  NULL,
    [bitActivo]            BIT              NULL,
    [xmlHistorial]         XML              NULL,
    CONSTRAINT [PK_unqGenTipoClienteKey] PRIMARY KEY CLUSTERED ([unqGenTipoClienteKey] ASC)
);

