CREATE TABLE [CTZ].[MastCotizacion] (
    [unqCtzMastCotizacionKey] UNIQUEIDENTIFIER CONSTRAINT [DF__MastCotiz__unqCt__31EC6D26] DEFAULT (newsequentialid()) NOT NULL,
    [unqGenClienteLink]       UNIQUEIDENTIFIER CONSTRAINT [DF__MastCotiz__unqGe__32E0915F] DEFAULT (newsequentialid()) NOT NULL,
    [unqGenPlantillaLink]     UNIQUEIDENTIFIER CONSTRAINT [DF__MastCotiz__unqGe__33D4B598] DEFAULT (newsequentialid()) NOT NULL,
    [intNoFolio]              INT              IDENTITY (1, 1) NOT NULL,
    [vchComentarios]          VARCHAR (200)    NULL,
    [decImporteTotal]         DECIMAL (18, 2)  NULL,
    [bitAceptada]             BIT              NULL,
    [bitIVA]                  BIT              NULL,
    [bitActivo]               BIT              NULL,
    [xmlHistorial]            XML              NULL,
    CONSTRAINT [PK_unqCtzMastCotizacionKey] PRIMARY KEY CLUSTERED ([unqCtzMastCotizacionKey] ASC),
    CONSTRAINT [FK_Cliente_Cotizacion] FOREIGN KEY ([unqGenClienteLink]) REFERENCES [GEN].[Cliente] ([unqGenClienteKey]),
    CONSTRAINT [FK_Plantilla_Cotizacion] FOREIGN KEY ([unqGenPlantillaLink]) REFERENCES [GEN].[Plantilla] ([unqGenPlantillaKey])
);

