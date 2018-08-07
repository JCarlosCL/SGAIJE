/*===============================================================================================================
**Autor: FERNANDO SANCHEZ ZAVALA 
**Descripcion: Get de Tipo Cliente
**version: 1.0.0
**Ejemplo: 


*=================================================================================================================*/

CREATE PROC [GEN].[prGetTipoCliente] @unqGenTipoClienteKey UNIQUEIDENTIFIER = NULL
AS
SELECT unqGenTipoClienteKey,
vchDescripcion,
decDescuento
FROM   Gen.TipoCliente
WHERE  bitActivo = 1
  AND ISNULL(@unqGenTipoClienteKey, unqGenTipoClienteKey) = @unqGenTipoClienteKey