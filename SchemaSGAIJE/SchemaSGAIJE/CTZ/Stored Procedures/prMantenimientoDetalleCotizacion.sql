/*===============================================================================================================
**Autor: Jose Carlos Camacho Lopez
**Descripcion: Alta Baja y Cambios del Detalle de la Cotizacion
**version: 1.0.0
**Ejemplo: exec CTZ.prMantenimientoDetalleCotizacion 'B51FB583-1FF4-4FB6-8F5A-BE2A9A419C03','B51FB583-1FF4-4FB6-8F5A-BE2A9A419C01','B51FB583-1FF4-4FB6-8F5A-BE2A9A419C04',1,10,0,10,1

**Control de cambios: FSZ 1.0.0 (21022018) inicial
*=================================================================================================================*/

CREATE PROC [CTZ].[prMantenimientoDetalleCotizacion] 
			   @unqCtzDetalleCotizacionKey UNIQUEIDENTIFIER = NULL,
			   @unqCtzMastCotizacionLink UNIQUEIDENTIFIER,
			   @unqGenArticuloLink UNIQUEIDENTIFIER,
			   @intCantidad INT,
			   @decValorUnitario DECIMAL(16,2),
			   @decDescuento DECIMAL(16,2),
			   @decMontoTotal DECIMAL(16,2),
			   @intTop			    INT

AS
DECLARE @tblKeyOut AS TABLE
                            (
                            unqCtzDetalleCotizacionKey UNIQUEIDENTIFIER
                            );
BEGIN TRY

/*================================================================================================================================================================
FSZ: Validamos que no exista el tipo de articulo
================================================================================================================================================================*/
    IF EXISTS
    (
	   SELECT
			1
	   FROM CTZ.DetalleCotizacion
	   WHERE unqCtzDetalleCotizacionKey = @unqCtzDetalleCotizacionKey
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
		  INSERT INTO CTZ.DetalleCotizacion
			    (
			    unqCtzDetalleCotizacionKey,
			    unqCtzMastCotizacionLink,
			    unqGenArticuloLink,
			    intCantidad,
			    decValorUnitario,
			    decDescuento,
			    decMontoTotal,
			    bitActivo
			    )
		  OUTPUT
			    inserted.unqCtzDetalleCotizacionKey
			    INTO @tblKeyOut
		  VALUES
			    (
			    @unqCtzDetalleCotizacionKey,
			    @unqCtzMastCotizacionLink,
			    @unqGenArticuloLink,
			    @intCantidad,
			    @decValorUnitario,
			    @decDescuento,
			    @decMontoTotal,
			    1
			    );

/*================================================================================================================================================================
FSZ: mandamos al select el id que se genero durante el insert
================================================================================================================================================================*/

		  SELECT
			    unqCtzDetalleCotizacionKey
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
		  FROM CTZ.DetalleCotizacion
		  WHERE unqCtzDetalleCotizacionKey = @unqCtzDetalleCotizacionKey
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
		  UPDATE CTZ.DetalleCotizacion
		    SET
			    unqCtzDetalleCotizacionKey = @unqCtzDetalleCotizacionKey,
			    unqCtzMastCotizacionLink = @unqCtzMastCotizacionLink,
			    unqGenArticuloLink = @unqGenArticuloLink,
			    intCantidad = @intCantidad,
			    decValorUnitario = @decValorUnitario,
			    decDescuento = @decDescuento,
			    decMontoTotal = @decMontoTotal
		  WHERE
			   unqCtzDetalleCotizacionKey = @unqCtzDetalleCotizacionKey;

		  SELECT
			    @unqCtzDetalleCotizacionKey AS unqCtzDetalleCotizacionKey;
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
		  FROM CTZ.DetalleCotizacion
		  WHERE unqCtzDetalleCotizacionKey = @unqCtzDetalleCotizacionKey
			   AND bitActivo = 0
	   )
				BEGIN
				    RAISERROR('El registro ya habia sido eliminado',16,1);
				    RETURN;
				END
		  END;

	   BEGIN
		  EXEC SDK.prValidaReferencias
			  @unqCtzDetalleCotizacionKey,
			  'DetalleCotizacion',
			  'CTZ';
		  UPDATE CTZ.DetalleCotizacion
		    SET
			   bitActivo = 0
		  WHERE
			   unqCtzDetalleCotizacionKey = @unqCtzDetalleCotizacionKey;
		  SELECT
			    @unqCtzDetalleCotizacionKey AS unqCtzDetalleCotizacionKey;
		  RETURN;
	   END;

END TRY 
BEGIN CATCH
    THROW;
END CATCH;