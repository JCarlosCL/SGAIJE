
/*===============================================================================================================
**Autor: Fernando Sanchez Zavala
**Descripcion: Alta Baja y Cambios de Tipos de Articulos
**version: 1.0.0
**Ejemplo: exec Gen.prMantenimientoTipoArticulo 'B51FB583-1FF4-4FB6-8F5A-BE2A9A419C03','Prueba',1

**Control de cambios: FSZ 1.0.0 (21022018) inicial
*=================================================================================================================*/




CREATE PROC [GEN].[prMantenimientoTipoArticulo] 

@unqGenTipoArticuloKey UNIQUEIDENTIFIER = NULL,
@vchDescripcion VARCHAR(100) = NULL,
@intTop INT



AS
DECLARE @tblKeyOut AS Table(unqGenTipoArticuloKey UNIQUEIDENTIFIER)
BEGIN TRY


/*limpiamos de posibles espacios en blanco de la Descripcion*/
SET @vchDescripcion = LTRIM(RTRIM(@vchDescripcion));


/*================================================================================================================================================================
FSZ: Validamos que no exista el tipo de articulo
================================================================================================================================================================*/


IF EXISTS 
( 
SELECT 1
FROM Gen.TipoArticulo
WHERE vchDescripcion = @vchDescripcion
AND bitActivo = 1 AND 
    unqGenTipoArticuloKey <> @unqGenTipoArticuloKey


)AND (@intTop = 1 
   OR @intTop = 2)

BEGIN 
RAISERROR('EL registro %s ya se encuentra en base de datos',16,1,@vchDescripcion)
RETURN;
END 

/*================================================================================================================================================================
FSZ: en caso de que no exista se da el alta de un nuevo Tipo de Articulo
================================================================================================================================================================*/


IF @intTop = 1 
BEGIN 
  INSERT INTO Gen.TipoArticulo
(
vchDescripcion,
bitActivo
) 
OUTPUT inserted.unqGenTipoArticuloKey
  INTO @tblKeyOut 
VALUES 

(
@vchDescripcion,
1
);

/*================================================================================================================================================================
FSZ: mandamos al select el id que se genero durante el insert
================================================================================================================================================================*/


SELECT unqGenTipoArticuloKey 
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
FROM Gen.TipoArticulo
WHERE unqGenTipoArticuloKey = @unqGenTipoArticuloKey

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
  UPDATE Gen.TipoArticulo
   SET
vchDescripcion = @vchDescripcion
 
WHERE unqGenTipoArticuloKey = @unqGenTipoArticuloKey;
SELECT @unqGenTipoArticuloKey AS unqGenTipoArticuloKey;
RETURN;
END


/*================================================================================================================================================================
Opcion Eliminar TODO: agregar Validacion de Borrado Cascada
================================================================================================================================================================*/


IF @intTop = 3 
IF EXISTS(SELECT 1 FROM Gen.TipoArticulo WHERE unqGenTipoArticuloKey = @unqGenTipoArticuloKey AND bitActivo = 0)
BEGIN
RAISERROR('El registro ya habia sido eliminado',16,1) 
RETURN
END
BEGIN 
  EXEC SDK.prValidaReferencias
  @unqGenTipoArticuloKey,
  'Tipo Articulo',
  'Gen';
UPDATE Gen.TipoArticulo
SET bitActivo = 0 
  WHERE unqGenTipoArticuloKey = @unqGenTipoArticuloKey;
   SELECT @unqGenTipoArticuloKey AS unqGenTipoArticuloKey;
   RETURN;
END

END TRY 
  BEGIN CATCH
   THROW;
    END CATCH;