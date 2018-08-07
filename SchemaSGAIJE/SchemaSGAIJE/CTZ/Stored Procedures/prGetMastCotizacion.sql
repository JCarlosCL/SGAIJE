/*===============================================================================================================
**Autor: FERNANDO SANCHEZ ZAVALA 
**Descripcion: Get de MastCotizacion
**version: 1.0.0
**Ejemplo: 


*=================================================================================================================*/

CREATE PROC [CTZ].[prGetMastCotizacion] @unqCtzMastCotizacionKey UNIQUEIDENTIFIER = NULL
AS
SELECT  unqCtzMastCotizacionKey,
unqGenClienteLink,
unqGenPlantillaLink,
intNoFolio,
vchComentarios,
decImporteTotal,
bitAceptada,
bitIVA

FROM   Ctz.MastCotizacion
WHERE  bitActivo = 1
  AND ISNULL(@unqCtzMastCotizacionKey, unqCtzMastCotizacionKey) = @unqCtzMastCotizacionKey