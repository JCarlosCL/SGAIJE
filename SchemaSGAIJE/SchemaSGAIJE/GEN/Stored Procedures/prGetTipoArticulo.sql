/*===============================================================================================================
**Autor: FERNANDO SANCHEZ ZAVALA 
**Descripcion: Get de Tipo Articulo
**version: 1.0.0
**Ejemplo: 


*=================================================================================================================*/

CREATE PROC [GEN].[prGetTipoArticulo] @unqGenTipoArticuloKey UNIQUEIDENTIFIER = NULL
AS
SELECT unqGenTipoArticuloKey,
vchDescripcion
FROM   Gen.TipoArticulo
WHERE  bitActivo = 1
  AND ISNULL(@unqGenTipoArticuloKey, unqGenTipoArticuloKey) = @unqGenTipoArticuloKey