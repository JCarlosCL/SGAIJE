
/*===============================================================================================================
**Autor: Fernando Sanchez Zavala
**Descripcion: Alta Baja y Cambios de Tipos de Clientes
**version: 1.0.0
**Ejemplo: exec Gen.prMantenimientoTipoClientes

**Control de cambios: FSZ 1.0.0 (21022018) inicial
*=================================================================================================================*/




CREATE PROC [GEN].[prMantenimientoTipoCliente] 
@unqGenTipoClienteKey UNIQUEIDENTIFIER = NULL,
@vchDescripcion VARCHAR(100) = NULL,
@decDescuento DECIMAL(18,2) = NULL,
@intTop INT



AS
DECLARE @tblKeyOut AS Table(unqGenTipoClienteKey UNIQUEIDENTIFIER)
BEGIN TRY


/*limpiamos de posibles espacios en blanco de la Descripcion*/
SET @vchDescripcion = LTRIM(RTRIM(@vchDescripcion));


/*================================================================================================================================================================
FSZ: Validamos que no exista el tipo de cliente
================================================================================================================================================================*/


IF EXISTS 
( 
SELECT 1
FROM Gen.TipoCliente
WHERE vchDescripcion = @vchDescripcion
AND bitActivo = 1 AND 
    unqGenTipoClienteKey <> @unqGenTipoClienteKey


)AND (@intTop = 1 
   OR @intTop = 2)

BEGIN 
RAISERROR('EL registro %s ya se encuentra en base de datos',16,1,@vchDescripcion)
RETURN;
END 

/*================================================================================================================================================================
FSZ: en caso de que no exista se da el alta de un nuevo Tipo de Cliente
================================================================================================================================================================*/


IF @intTop = 1 
BEGIN 
  INSERT INTO Gen.TipoCliente 
(
vchDescripcion,
decDescuento,
bitActivo
) 
OUTPUT inserted.unqGenTipoClienteKey
  INTO @tblKeyOut 
VALUES 

(
@vchDescripcion,
@decDescuento,
1
);

/*================================================================================================================================================================
FSZ: mandamos al select el id que se genero durante el insert
================================================================================================================================================================*/


SELECT unqGenTipoClienteKey 
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
FROM Gen.TipoCliente
WHERE unqGenTipoClienteKey = @unqGenTipoClienteKey

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
  UPDATE Gen.TipoCliente
   SET
vchDescripcion = @vchDescripcion,
decDescuento = @decDescuento
WHERE unqGenTipoClienteKey = @unqGenTipoClienteKey;
SELECT @unqGenTipoClienteKey AS unqGenTipoClienteKey;
RETURN;
END


/*================================================================================================================================================================
Opcion Eliminar TODO: agregar Validacion de Borrado Cascada
================================================================================================================================================================*/


IF @intTop = 3 
IF EXISTS(SELECT 1 FROM Gen.TipoCliente WHERE unqGenTipoClienteKey = @unqGenTipoClienteKey AND bitActivo = 0)
BEGIN
RAISERROR('El registro ya habia sido eliminado',16,1) 
RETURN
END
BEGIN 
  EXEC SDK.prValidaReferencias
  @unqGenTipoClienteKey,
  'Tipo Cliente',
  'Gen';
UPDATE Gen.TipoCliente
SET bitActivo = 0 
  WHERE unqGenTipoClienteKey = @unqGenTipoClienteKey;
   SELECT @unqGenTipoClienteKey AS unqGenTipoClienteKey;
   RETURN;
END

END TRY 
  BEGIN CATCH
   THROW;
    END CATCH;