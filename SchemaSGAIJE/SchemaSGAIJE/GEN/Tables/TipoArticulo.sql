CREATE TABLE [GEN].[TipoArticulo] (
    [unqGenTipoArticuloKey] UNIQUEIDENTIFIER DEFAULT (newsequentialid()) NOT NULL,
    [vchDescripcion]        VARCHAR (100)    NULL,
    [bitActivo]             BIT              NULL,
    [xmlHistorial]          XML              NULL,
    CONSTRAINT [PK_unqGenTipoArticuloKey] PRIMARY KEY CLUSTERED ([unqGenTipoArticuloKey] ASC)
);

