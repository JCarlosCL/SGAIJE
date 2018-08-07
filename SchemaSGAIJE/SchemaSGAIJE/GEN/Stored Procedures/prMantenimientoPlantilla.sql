
/*===============================================================================================================
**Autor: Fernando Sanchez Zavala
**Descripcion: Alta Baja y Cambios de Plantilla
**version: 1.0.0
**Ejemplo: exec Gen.prMantenimientoPlantilla 'B51FB583-1FF4-4FB6-8F5A-BE2A9A419C03','Prueba','Prueba',1

**Control de cambios: FSZ 1.0.0 (21022018) inicial
*=================================================================================================================*/




CREATE PROC [Gen].[prMantenimientoPlantilla] 

@unqGenPlantillaKey UNIQUEIDENTIFIER = NULL,
@vchDescripcion VARCHAR(100) = NULL,
@vchPathPlantilla VARCHAR (255) = NULL,
@intTop INT



AS
DECLARE @tblKeyOut AS Table(unqGenPlantillaKey UNIQUEIDENTIFIER)
BEGIN TRY


/*limpiamos de posibles espacios en blanco de la Descripcion*/
SET @vchDescripcion = LTRIM(RTRIM(@vchDescripcion));
  /*limpiamos de posibles espacios en blanco de la Ruta*/
SET @vchPathPlantilla = LTRIM(RTRIM(@vchPathPlantilla));

/*================================================================================================================================================================
FSZ: Validamos que no exista la plantilla
================================================================================================================================================================*/


IF EXISTS 
( 
SELECT 1
FROM Gen.Plantilla
WHERE vchDescripcion = @vchDescripcion
AND bitActivo = 1 AND 
    unqGenPlantillaKey <> @unqGenPlantillaKey


)AND (@intTop = 1 
   OR @intTop = 2)

BEGIN 
RAISERROR('EL registro %s ya se encuentra en base de datos',16,1,@vchDescripcion)
RETURN;
END 

/*================================================================================================================================================================
FSZ: en caso de que no exista se da el alta de una nueva Plantilla
================================================================================================================================================================*/


IF @intTop = 1 
BEGIN 
  INSERT INTO Gen.Plantilla
(
vchDescripcion,
vchPathPlantilla,
bitActivo
) 
OUTPUT inserted.unqGenPlantillaKey
  INTO @tblKeyOut 
VALUES 

(
@vchDescripcion,
@vchPathPlantilla,
1
);

/*================================================================================================================================================================
FSZ: mandamos al select el id que se genero durante el insert
================================================================================================================================================================*/


SELECT unqGenPlantillaKey 
FROM @tblKeyOut 
RETURN;
END;

/*================================================================================================================================================================
FSZ: Validamos si vamos a borrar o actualizar que exista el registro
================================================================================================================================================================*/

IF @intTop IN (2,3)
AND NOT EXISTS
( 
SELECT 1 
FROM Gen.Plantilla
WHERE unqGenPlantillaKey = @unqGenPlantillaKey

)

BEGIN
RAISERROR('El registro no existe, error transaccional',16,1);
RETURN;
END;

/*================================================================================================================================================================
FSZ: Opcion actualizar 
================================================================================================================================================================*/
 

IF @intTop = 2 
BEGIN 
  UPDATE Gen.Plantilla
   SET
vchDescripcion = @vchDescripcion
 
WHERE unqGenPlantillaKey = @unqGenPlantillaKey;
SELECT @unqGenPlantillaKey AS unqGenPlantillaKey;
RETURN;
END


/*================================================================================================================================================================
Opcion Eliminar TODO: agregar Validacion de Borrado Cascada
================================================================================================================================================================*/


IF @intTop = 3 
IF EXISTS(SELECT 1 FROM Gen.Plantilla WHERE unqGenPlantillaKey = @unqGenPlantillaKey AND bitActivo = 0)
BEGIN
RAISERROR('El registro ya habia sido eliminado',16,1) 
RETURN
END
BEGIN 
  EXEC SDK.prValidaReferencias
  @unqGenPlantillaKey,
  'Plantilla',
  'Gen';
UPDATE Gen.Plantilla
SET bitActivo = 0 
  WHERE unqGenPlantillaKey = @unqGenPlantillaKey;
   SELECT @unqGenPlantillaKey AS unqGenPlantillaKey;
   RETURN;
END

END TRY 
  BEGIN CATCH
   THROW;
    END CATCH;