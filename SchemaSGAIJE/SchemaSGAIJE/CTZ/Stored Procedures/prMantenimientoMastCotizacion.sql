/*===============================================================================================================
**Autor: Jose Carlos Camacho Lopez
**Descripcion: Alta Baja y Cambios de la Cotizacion
**version: 1.0.0
**Ejemplo: exec CTZ.prMantenimientoMastCotizacion 'B51FB583-1FF4-4FB6-8F5A-BE2A9A419C03',NULL,NULL,'Proveedor Especial',1000,0,0,1

**Control de cambios: FSZ 1.0.0 (21022018) inicial
*=================================================================================================================*/

CREATE PROC [CTZ].[prMantenimientoMastCotizacion] 
			   @unqCtzMastCotizacionKey  UNIQUEIDENTIFIER = NULL,
			   @unqGenClienteLink	    UNIQUEIDENTIFIER = NULL,
			   @unqGenPlantillaLink	    UNIQUEIDENTIFIER = NULL,
			   @vchComentarios		    VARCHAR(200),
			   @decImporteTotal		    DECIMAL(16,2),
			   @bitAceptada		    BIT,
			   @bitIVA			    BIT,
			   @intTop			    INT

AS

DECLARE @tblKeyOut AS TABLE
                            (
                            unqCtzMastCotizacionKey UNIQUEIDENTIFIER
                            );
BEGIN TRY


/*limpiamos de posibles espacios en blanco de la Descripcion*/

SET @vchComentarios = LTRIM(RTRIM(@vchComentarios));

/*================================================================================================================================================================
FSZ: Validamos que no exista el tipo de articulo
================================================================================================================================================================*/
    IF EXISTS
    (
	   SELECT
			1
	   FROM CTZ.MastCotizacion
	   WHERE unqCtzMastCotizacionKey = @unqCtzMastCotizacionKey
		    AND bitActivo = 1
		  
    )
	  AND (@intTop = 1
		  OR @intTop = 2)

	   BEGIN
		  RAISERROR('EL registro %s ya se encuentra en base de datos',16,1);
		  RETURN;
	   END; 

/*================================================================================================================================================================
FSZ: en caso de que no exista se da el alta de un nuevo Tipo de Articulo
================================================================================================================================================================*/
    


    IF @intTop = 1
	   BEGIN
		  INSERT INTO CTZ.MastCotizacion
			    (
			    unqGenClienteLink,
			    unqGenPlantillaLink,
			    vchComentarios,
			    decImporteTotal,
			    bitAceptada,
			    bitIVA,
			    bitActivo
			    )
		  OUTPUT
			    inserted.unqCtzMastCotizacionKey
			    INTO @tblKeyOut
		  VALUES
			    (
			    @unqGenClienteLink,
			    @unqGenPlantillaLink,
			    @vchComentarios,
			    @decImporteTotal,
			    @bitAceptada,
			    @bitIVA,
			    1
			    );

/*================================================================================================================================================================
FSZ: mandamos al select el id que se genero durante el insert
================================================================================================================================================================*/

		  SELECT
			    unqCtzMastCotizacionKey
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
		  FROM CTZ.MastCotizacion
		  WHERE unqCtzMastCotizacionKey = @unqCtzMastCotizacionKey
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
		  UPDATE CTZ.MastCotizacion
		    SET
			    unqGenClienteLink = @unqGenClienteLink,
			    unqGenPlantillaLink = @unqGenPlantillaLink,
			    vchComentarios = @vchComentarios,
			    decImporteTotal = @decImporteTotal,
			    bitAceptada = @bitAceptada,
			    @bitIVA = @bitIVA
		  WHERE
			   unqCtzMastCotizacionKey = @unqCtzMastCotizacionKey;

		  SELECT
			    @unqCtzMastCotizacionKey AS unqCtzMastCotizacionKey;
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
		  FROM CTZ.MastCotizacion
		  WHERE unqCtzMastCotizacionKey = @unqCtzMastCotizacionKey
			   AND bitActivo = 0
	   )
				BEGIN
				    RAISERROR('El registro ya habia sido eliminado',16,1);
				    RETURN;
				END
		  END;

	   BEGIN
		  EXEC SDK.prValidaReferencias
			  @unqCtzMastCotizacionKey,
			  'MastCotizacion',
			  'CTZ';
		  UPDATE CTZ.MastCotizacion
		    SET
			   bitActivo = 0
		  WHERE
			   unqCtzMastCotizacionKey = @unqCtzMastCotizacionKey;
		  SELECT
			    @unqCtzMastCotizacionKey AS unqCtzMastCotizacionKey;
		  RETURN;
	   END;

END TRY 
BEGIN CATCH
    THROW;
END CATCH;