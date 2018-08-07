/*===============================================================================================================
**Autor: FERNANDO SANCHEZ ZAVALA 
**Descripcion: Get de DetalleCotizacion
**version: 1.0.0.0
**Ejemplo: 


*=================================================================================================================*/

CREATE PROC [CTZ].[prGetDetalleCotizacion] @unqCtzDetalleCotizacionKey UNIQUEIDENTIFIER = NULL
AS
SELECT unqCtzDetalleCotizacionKey,
   unqCtzMastCotizacionLink,
   unqGenArticuloLink,
   intCantidad,
   decValorUnitario,
   decDescuento,
   decIVA,
   decMontoTotal

FROM   Ctz.DetalleCotizacion
WHERE  bitActivo = 1
  AND ISNULL(@unqCtzDetalleCotizacionKey, unqCtzDetalleCotizacionKey) = @unqCtzDetalleCotizacionKey
