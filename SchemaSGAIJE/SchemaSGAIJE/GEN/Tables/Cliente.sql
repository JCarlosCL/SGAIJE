CREATE TABLE [GEN].[Cliente] (
    [unqGenClienteKey]      UNIQUEIDENTIFIER DEFAULT (newsequentialid()) NOT NULL,
    [unqGenTipoClienteLink] UNIQUEIDENTIFIER DEFAULT (newsequentialid()) NULL,
    [vchNombre]             VARCHAR (50)     NOT NULL,
    [vchApellidoP]          VARCHAR (50)     NOT NULL,
    [vchApellidoM]          VARCHAR (50)     NULL,
    [vchRFC]                VARCHAR (20)     NOT NULL,
    [vchCalle]              VARCHAR (30)     NULL,
    [vchNoExterior]         VARCHAR (15)     NULL,
    [vchColonia]            VARCHAR (30)     NULL,
    [vchCodigoPostal]       VARCHAR (15)     NULL,
    [vchTelefono]           VARCHAR (30)     NOT NULL,
    [vchCorreo]             VARCHAR (50)     NOT NULL,
    [bitActivo]             BIT              NULL,
    [xmlHistorial]          XML              NULL,
    CONSTRAINT [PK_unqGenClienteKey] PRIMARY KEY CLUSTERED ([unqGenClienteKey] ASC),
    CONSTRAINT [FK_TipoCliente_Cliente] FOREIGN KEY ([unqGenTipoClienteLink]) REFERENCES [GEN].[TipoCliente] ([unqGenTipoClienteKey])
);

