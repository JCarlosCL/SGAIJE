CREATE TABLE [GEN].[Articulo] (
    [unqGenArticuloKey]      UNIQUEIDENTIFIER DEFAULT (newsequentialid()) NOT NULL,
    [unqGenTipoArticuloLink] UNIQUEIDENTIFIER DEFAULT (newsequentialid()) NULL,
    [vchCodigoArticulo]      VARCHAR (50)     NOT NULL,
    [vchDescripcion]         VARCHAR (50)     NOT NULL,
    [decPrecio]              DECIMAL (18, 2)  NOT NULL,
    [decDescuento]           DECIMAL (18, 2)  NULL,
    [intExistencia]          INT              NULL,
    [intCantidadMaxima]      INT              NULL,
    [intCantidadMinima]      INT              NULL,
    [bitActivo]              BIT              NULL,
    [xmlHistorial]           XML              NULL,
    CONSTRAINT [PK_unqGenArticuloKey] PRIMARY KEY CLUSTERED ([unqGenArticuloKey] ASC),
    CONSTRAINT [FK_TipoArticulo_Articulo] FOREIGN KEY ([unqGenTipoArticuloLink]) REFERENCES [GEN].[TipoArticulo] ([unqGenTipoArticuloKey])
);

