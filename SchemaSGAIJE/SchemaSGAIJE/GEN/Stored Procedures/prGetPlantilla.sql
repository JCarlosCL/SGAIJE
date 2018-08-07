/*===============================================================================================================
**Autor: FERNANDO SANCHEZ ZAVALA 
**Descripcion: Get de Plantilla
**version: 1.0.0
**Ejemplo: 


*=================================================================================================================*/

CREATE PROC [GEN].[prGetPlantilla] @unqGenPlantillaKey UNIQUEIDENTIFIER = NULL
AS
SELECT unqGenPlantillaKey,
   vchDescripcion,
   vchPathPlantilla   

FROM   Gen.Plantilla
WHERE  bitActivo = 1
  AND ISNULL(@unqGenPlantillaKey, unqGenPlantillaKey) = @unqGenPlantillaKey