CREATE TABLE [GEN].[Plantilla] (
    [unqGenPlantillaKey] UNIQUEIDENTIFIER DEFAULT (newsequentialid()) NOT NULL,
    [vchDescripcion]     VARCHAR (30)     NOT NULL,
    [vchPathPlantilla]   VARCHAR (255)    NOT NULL,
    [bitActivo]          BIT              NULL,
    [xmlHistorial]       XML              NULL,
    CONSTRAINT [PK_unqGenPlantillaKey] PRIMARY KEY CLUSTERED ([unqGenPlantillaKey] ASC)
);

