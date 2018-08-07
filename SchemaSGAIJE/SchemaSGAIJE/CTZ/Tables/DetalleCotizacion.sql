CREATE TABLE [CTZ].[DetalleCotizacion] (
    [unqCtzDetalleCotizacionKey] UNIQUEIDENTIFIER CONSTRAINT [DF__DetalleCo__unqCt__2F10007B] DEFAULT (newsequentialid()) NOT NULL,
    [unqCtzMastCotizacionLink]   UNIQUEIDENTIFIER CONSTRAINT [DF__DetalleCo__unqCt__300424B4] DEFAULT (newsequentialid()) NOT NULL,
    [unqGenArticuloLink]         UNIQUEIDENTIFIER CONSTRAINT [DF__DetalleCo__unqGe__30F848ED] DEFAULT (newsequentialid()) NOT NULL,
    [intCantidad]                INT              NULL,
    [decValorUnitario]           DECIMAL (18, 2)  NULL,
    [decDescuento]               DECIMAL (18, 2)  NULL,
    [decMontoTotal]              DECIMAL (18, 2)  NULL,
    [bitActivo]                  BIT              NULL,
    [xmlHistorial]               XML              NULL,
    [decIVA]                     DECIMAL (18, 2)  NULL,
    CONSTRAINT [PK_unqCtzDetalleCotizacionKey] PRIMARY KEY CLUSTERED ([unqCtzDetalleCotizacionKey] ASC),
    CONSTRAINT [FK_Articulo_DetalleCotizacion] FOREIGN KEY ([unqGenArticuloLink]) REFERENCES [GEN].[Articulo] ([unqGenArticuloKey]),
    CONSTRAINT [FK_MastCotizacion_DetalleCotizacion] FOREIGN KEY ([unqCtzMastCotizacionLink]) REFERENCES [CTZ].[MastCotizacion] ([unqCtzMastCotizacionKey])
);

