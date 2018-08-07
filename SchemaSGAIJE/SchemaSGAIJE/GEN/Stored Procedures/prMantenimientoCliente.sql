/*===============================================================================================================
**Autor: Jose Carlos Camacho Lopez
**Descripcion: Alta Baja y Cambios de Cliente
**version: 1.0.0
**Ejemplo: exec Gen.prMantenimientoCliente 'B51FB583-1FF4-4FB6-8F5A-BE2A9A419C03','NULL','Carlos','Camacho','Lopez','NINGUNO','','','','','','',1

**Control de cambios: FSZ 1.0.0 (21022018) inicial
*=================================================================================================================*/

CREATE PROC [GEN].[prMantenimientoCliente] 
			 @unqGenClienteKey		UNIQUEIDENTIFIER = NULL,
			 @unqGenTipoClienteLink	UNIQUEIDENTIFIER = NULL,
			 @vchNombre			VARCHAR(50),
			 @vchApellidoP			VARCHAR(50),
			 @vchApellidoM			VARCHAR(50),
			 @vchRFC				VARCHAR(20),
			 @vchCalle			VARCHAR(30),
			 @vchNoExterior		VARCHAR(15),
			 @vchColonia			VARCHAR(30),
			 @vchCodigoPostal		VARCHAR(15),
			 @vchTelefono			VARCHAR(30),
			 @vchCorreo			VARCHAR(50),
			 @intTop				INT



AS

DECLARE @tblKeyOut AS TABLE
                            (
                            unqGenClienteKey UNIQUEIDENTIFIER
                            );
BEGIN TRY


/*limpiamos de posibles espacios en blanco de la Descripcion*/


SET @vchNombre = LTRIM(RTRIM(@vchNombre));

SET @vchApellidoP = LTRIM(RTRIM(@vchApellidoP));

SET @vchApellidoM = LTRIM(RTRIM(@vchApellidoM));

SET @vchRFC = LTRIM(RTRIM(@vchRFC));

SET @vchNoExterior = LTRIM(RTRIM(@vchNoExterior));

SET @vchColonia = LTRIM(RTRIM(@vchColonia));

SET @vchCodigoPostal = LTRIM(RTRIM(@vchCodigoPostal));

SET @vchTelefono = LTRIM(RTRIM(@vchTelefono));

SET @vchCorreo = LTRIM(RTRIM(@vchCorreo));


/*================================================================================================================================================================
FSZ: Validamos que no exista el tipo de articulo
================================================================================================================================================================*/
    IF EXISTS
    (
	   SELECT
			1
	   FROM Gen.Cliente
	   WHERE vchNombre = @vchNombre
		    AND bitActivo = 1
		    AND unqGenClienteKey <> @unqGenClienteKey
    )
	  AND (@intTop = 1
		  OR @intTop = 2)

	   BEGIN
		  RAISERROR('EL registro %s ya se encuentra en base de datos',16,1,@vchNombre);
		  RETURN;
	   END; 

/*================================================================================================================================================================
FSZ: en caso de que no exista se da el alta de un nuevo Tipo de Articulo
================================================================================================================================================================*/
    


    IF @intTop = 1
	   BEGIN
		  INSERT INTO Gen.Cliente
			    (
			    unqGenTipoClienteLink
			   ,vchNombre
			   ,vchApellidoP
			   ,vchApellidoM
			   ,vchRFC
			   ,vchCalle
			   ,vchNoExterior
			   ,vchColonia
			   ,vchCodigoPostal
			   ,vchTelefono
			   ,vchCorreo
			   ,bitActivo
			    )
		  OUTPUT
			    inserted.unqGenClienteKey
			    INTO @tblKeyOut
		  VALUES
			    (
			    @unqGenTipoClienteLink,
			    @vchNombre,
			    @vchApellidoP,
			    @vchApellidoM,
			    @vchRFC,
			    @vchCalle,
			    @vchNoExterior,
			    @vchColonia,
			    @vchCodigoPostal,
			    @vchTelefono,
			    @vchCorreo,
			    1
			    );

/*================================================================================================================================================================
FSZ: mandamos al select el id que se genero durante el insert
================================================================================================================================================================*/

		  SELECT
			    unqGenClienteKey
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
		  FROM Gen.Cliente
		  WHERE unqGenClienteKey = @unqGenClienteKey
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
		  UPDATE Gen.Cliente
		    SET
			   unqGenTipoClienteLink = @unqGenTipoClienteLink,
			   vchNombre = @vchNombre,
			   vchApellidoP = @vchApellidoP,
			   vchApellidoM = @vchApellidoM,
			   vchRFC = @vchRFC,
			   vchCalle = @vchCalle,
			   vchNoExterior = @vchNoExterior,
			   vchColonia = @vchColonia,
			   vchCodigoPostal = @vchCodigoPostal,
			   vchTelefono = @vchTelefono,
			   vchCorreo = @vchCorreo
		  WHERE
			   unqGenClienteKey = @unqGenClienteKey;

		  SELECT
			    @unqGenClienteKey AS unqGenClienteKey;
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
		  FROM Gen.Cliente
		  WHERE unqGenClienteKey = @unqGenClienteKey
			   AND bitActivo = 0
	   )
				BEGIN
				    RAISERROR('El registro ya habia sido eliminado',16,1);
				    RETURN;
				END
		  END;

	   BEGIN
		  EXEC SDK.prValidaReferencias
			  @unqGenClienteKey,
			  'Cliente',
			  'Gen';
		  UPDATE Gen.Cliente
		    SET
			   bitActivo = 0
		  WHERE
			   unqGenClienteKey = @unqGenClienteKey;
		  SELECT
			    @unqGenClienteKey AS unqGenClienteKey;
		  RETURN;
	   END;

END TRY 
BEGIN CATCH
    THROW;
END CATCH;