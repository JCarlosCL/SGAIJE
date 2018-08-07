/*===============================================================================================================
**Autor: FERNANDO SANCHEZ ZAVALA 
**Descripcion: Get de Cliente
**version: 1.0.0
**Ejemplo: 


*=================================================================================================================*/

CREATE PROC [GEN].[prGetCliente] @unqGenClienteKey UNIQUEIDENTIFIER = NULL
AS
SELECT unqGenClienteKey,
       unqGenTipoClienteLink,
       vchNombre,
       vchApellidoP,
       vchApellidoM,
       vchRFC,
       vchCalle,
       vchNoExterior,
       vchColonia,
       vchCodigoPostal,
       vchTelefono,
       vchCorreo

FROM   Gen.Cliente
WHERE  bitActivo = 1
  AND ISNULL(@unqGenClienteKey, unqGenClienteKey) = @unqGenClienteKey