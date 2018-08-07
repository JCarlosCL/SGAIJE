/*===============================================================================================================
**Autor: FERNANDO SANCHEZ ZAVALA 
**Descripcion: Get de Articulos
**version: 1.0.0
**Ejemplo: 


*=================================================================================================================*/

CREATE PROC [GEN].[prGetArticulo] @unqGenArticuloKey UNIQUEIDENTIFIER = NULL
AS
SELECT unqGenArticuloKey,
   unqGenTipoArticuloLink,
   vchCodigoArticulo,
   vchDescripcion,
   decPrecio,
   decDescuento,
   intExistencia,
   intCantidadMaxima,
   intCantidadMinima
   

FROM   Gen.Articulo
WHERE  bitActivo = 1
  AND ISNULL(@unqGenArticuloKey, unqGenArticuloKey) = @unqGenArticuloKey