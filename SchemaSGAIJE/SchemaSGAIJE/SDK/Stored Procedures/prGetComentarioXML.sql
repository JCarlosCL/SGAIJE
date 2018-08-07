

/**************************************************************************************
-- Creado Por: Fernando Sanchez
-- Fecha: 2017-03-01
-- Descripción: El siguiente SP se encarga Recuperar a manera de tabla los comentarios del campo xmlComentarios
-- dinamicamente de cualquier tabla
-- Control de Versiones:
**************************************************************************************/

CREATE PROC [SDK].[prGetComentarioXML] @vchId     VARCHAR(100),
   @vchSchema VARCHAR(20),
   @vchTabla  VARCHAR(255)
AS
    BEGIN
   DECLARE @intSchemaID INT, @intObjID INT, @vchSsql VARCHAR(MAX), @vchColumnId VARCHAR(255);
--FSZ Verificamos que exsista el Schema y obtenemos el Schema_id
   IF NOT EXISTS
(
    SELECT 1
    FROM   sys.schemas AS s
    WHERE  s.name = @vchSchema
)
  BEGIN
RAISERROR('Error transaccional Schema invalido', 16, 1);
RETURN;
  END;
  ELSE
  BEGIN
SELECT @intSchemaID = schema_id
FROM   sys.schemas AS s
WHERE  s.name = @vchSchema;
  END;
     
 --FSZ verificamos que la tabla exsista en base de datos y obtebemos el Object_id
   IF NOT EXISTS
(
    SELECT 1
    FROM   sys.objects o
    WHERE  o.schema_id = @intSchemaID
AND name = @vchTabla
)
  BEGIN
RAISERROR('Error transaccional Tabla no encontrada invalido', 16, 1);
RETURN;
  END;
  ELSE
  BEGIN
SELECT @intObjID = o.object_id
FROM   sys.objects o
WHERE  o.schema_id = @intSchemaID
   AND name = @vchTabla;
  END;
 -- FSZ Verificamos que la tabla contenga el campo XMLHistorial
   IF NOT EXISTS
(
    SELECT 1
    FROM   sys.all_columns ac
    WHERE  ac.name = 'xmlhistorial'
AND ac.object_id = @intObjID
AND ac.system_type_id = '241'
)
  BEGIN
RAISERROR('Error transaccional Columna no encontrada o tipo de datos invalido', 16, 1);
RETURN;
  END;

--FSZ Obtenemos el Nombre del campo llave ya que por alguna razon no se llama ID  jeje XD
   SELECT @vchColumnId = COLUMN_NAME
   FROM   INFORMATION_SCHEMA.KEY_COLUMN_USAGE
   WHERE  OBJECTPROPERTY(OBJECT_ID(CONSTRAINT_SCHEMA+'.'+QUOTENAME(CONSTRAINT_NAME)), 'IsPrimaryKey') = 1
AND TABLE_NAME = @vchTabla
AND TABLE_SCHEMA = @vchSchema;
   IF @vchColumnId IS NULL
  BEGIN
RAISERROR('Error transaccional campo llave o tipo de datos invalido', 16, 1);
RETURN;
  END;
   DECLARE @tblHistorial AS TABLE
(vchAccion     VARCHAR(30),
 vchUsuario    VARCHAR(30),
 dtmFecha      VARCHAR(30),
 vchComentario VARCHAR(255)
);
-- FSZ Una ves concluidas todas las validaciones construimos el XQery y el CROSS APPLY hace su magia :v
   SET @vchSsql = '
SELECT x.m.value('+CHAR(39)+'Accion[1]'+CHAR(39)+', '+CHAR(39)+'varchar(30)'+CHAR(39)+') Accion,
x.m.value('+CHAR(39)+'Usuario[1]'+CHAR(39)+', '+CHAR(39)+'varchar(30)'+CHAR(39)+') Usuario,
 x.m.value('+CHAR(39)+'Fecha[1]'+CHAR(39)+', '+CHAR(39)+'varchar(30)'+CHAR(39)+') Fecha,
 x.m.value('+CHAR(39)+'Comentario[1]'+CHAR(39)+','+CHAR(39)+'varchar(255)'+CHAR(39)+') Comentario
 
FROM   '+CONCAT(@vchSchema, '.', @vchTabla)+' cf 
CROSS APPLY cf.XmlHistorial.nodes('+CHAR(39)+'/Historial/Accion'+CHAR(39)+') x(m) WHERE cf.'+@vchColumnId+' = '+CHAR(39)+@vchId+CHAR(39);
insert into @tblHistorial
   EXEC sys.sp_sqlexec
   @p1 = @vchSsql;
   select * from @tblHistorial
   PRINT @vchSsql;
    END;