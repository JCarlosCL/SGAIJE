/*===============================================================================================================
**Autor: Jose Carlos Camacho Lopez
**Descripcion: Alta Baja y Cambios de Articulos
**version: 1.0.0
**Ejemplo: exec Gen.prMantenimientoArticulo 'B51FB583-1FF4-4FB6-8F5A-BE2A9A419C03',NULL,'0001','Caja',0.05,10,5,15,1

**Control de cambios: FSZ 1.0.0 (21022018) inicial
*=================================================================================================================*/

CREATE PROC [GEN].[prMantenimientoArticulo] 
			 @unqGenArticuloKey		UNIQUEIDENTIFIER = NULL,
			 @unqGenTipoArticuloLink	UNIQUEIDENTIFIER = NULL,
			 @vchCodigoArticulo		VARCHAR(50),
			 @vchDescripcion		VARCHAR(50),
			 @decPrecio			DECIMAL(18,2),
			 @decDescuento			DECIMAL(18,2),
			 @intExistencia		INT,
			 @intCantidadMaxima		INT,
			 @intCantidadMinima		INT,
			 @intTop				INT



AS
    DECLARE @tblKeyOut AS Table(unqGenArticuloKey UNIQUEIDENTIFIER)
BEGIN TRY


/*limpiamos de posibles espacios en blanco de la Descripcion*/

    SET @vchCodigoArticulo = LTRIM(RTRIM(@vchCodigoArticulo));


/*================================================================================================================================================================
FSZ: Validamos que no exista el tipo de articulo
================================================================================================================================================================*/
    IF EXISTS
    (
	   SELECT
			1
	   FROM Gen.Articulo
	   WHERE vchCodigoArticulo = @vchCodigoArticulo
		    AND bitActivo = 1
		    AND unqGenArticuloKey <> @unqGenArticuloKey
    )
	  AND (@intTop = 1
		  OR @intTop = 2)

	   BEGIN
		  RAISERROR('EL registro %s ya se encuentra en base de datos',16,1,@vchCodigoArticulo);
		  RETURN;
	   END; 

/*================================================================================================================================================================
FSZ: en caso de que no exista se da el alta de un nuevo Tipo de Articulo
================================================================================================================================================================*/
    
    IF @intTop = 1
	   BEGIN
		  INSERT INTO Gen.Articulo
			    (
			   unqGenTipoArticuloLink
			   ,vchCodigoArticulo
			   ,vchDescripcion
			   ,decPrecio
			   ,decDescuento
			   ,intExistencia
			   ,intCantidadMaxima
			   ,intCantidadMinima
			   ,bitActivo
			    )
		  OUTPUT
			    inserted.unqGenArticuloKey
			    INTO @tblKeyOut
		  VALUES
			    (
			    @unqGenTipoArticuloLink,
			    @vchCodigoArticulo,
			    @vchDescripcion,
			    @decPrecio,
			    @decDescuento,
			    @intExistencia,
			    @intCantidadMaxima,
			    @intCantidadMinima,
			    1
			    );

/*================================================================================================================================================================
FSZ: mandamos al select el id que se genero durante el insert
================================================================================================================================================================*/

		  SELECT
			    unqGenArticuloKey
		  FROM @tblKeyOut;
		  RETURN;
	   END;

/*================================================================================================================================================================
FSZ: Validamos si vamos a borrar o actualizar que exista el registro
================================================================================================================================================================*/

	   IF @intTop IN(2,3)
		 AND NOT EXISTS
	   (
		  SELECT
			    1
		  FROM Gen.Articulo
		  WHERE unqGenArticuloKey = @unqGenArticuloKey
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
			 UPDATE Gen.Articulo
			   SET
				  unqGenTipoArticuloLink = @unqGenTipoArticuloLink,
				  vchCodigoArticulo = @vchCodigoArticulo,
				  vchDescripcion = @vchDescripcion,
				  decPrecio = @decPrecio,
				  decDescuento = @decDescuento,
				  intExistencia = @intExistencia,
				  intCantidadMaxima = @intCantidadMaxima,
				  intCantidadMinima = @intCantidadMinima
			 WHERE
				  unqGenArticuloKey = @unqGenArticuloKey;

			 SELECT
				   @unqGenArticuloKey AS unqGenArticuloKey;
			 RETURN;
		  END;

/*================================================================================================================================================================
Opcion Eliminar TODO: agregar Validacion de Borrado Cascada
================================================================================================================================================================*/

	   IF @intTop = 3
		  BEGIN
			 IF EXISTS
	   (
		  SELECT
			    1
		  FROM Gen.Articulo
		  WHERE unqGenArticuloKey = @unqGenArticuloKey
			   AND bitActivo = 0
	   )
				BEGIN
				    RAISERROR('El registro ya habia sido eliminado',16,1);
				    RETURN;
				END
		  END;

	   BEGIN
		  EXEC SDK.prValidaReferencias
			  @unqGenArticuloKey,
			  'Articulo',
			  'Gen';
		  UPDATE Gen.Articulo
		    SET
			   bitActivo = 0
		  WHERE
			   unqGenArticuloKey = @unqGenArticuloKey;
		  SELECT
			    @unqGenArticuloKey AS unqGenArticuloKey;
		  RETURN;
	   END;

END TRY 
BEGIN CATCH
    THROW;
END CATCH;