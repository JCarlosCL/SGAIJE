
/**************************************************************************************
** Creado Por: Fernando Sanchez
** Fecha: 2017-03-01
** Descripción: Valida de manera dinamica que no existan referencias de dato hacia un registro que se intenta borrar de la tabla
** por temas de integridad referencial en borrado logico
** Control de Versiones:
**************************************************************************************/

--SEG.prValidaReferencias 'A32D5FCD-C55C-4249-894C-A03BA255A600','Categoria','gen' 
CREATE PROC [SDK].[prValidaReferencias] @unqKey     uniqueidentifier, 
                                   @vchTabla  AS VARCHAR(255), 
                                   @vchSchema AS VARCHAR(255)
AS 
  BEGIN TRY 
      DECLARE @intSchemaID AS INT; 
      DECLARE @ssql AS VARCHAR(max)='' 
/***********************************************************************************************************************************************
Obtenemos el id del schema que estamos utilizando y validamos que exista
***********************************************************************************************************************************************/
      SELECT @intSchemaID = schema_id 
      FROM   sys.schemas 
      WHERE  NAME = @vchSchema 

      IF @intSchemaID IS NULL 
        BEGIN; 
            THROW 50003, 'Schema incorrecto', 1; 

            RETURN 
        END 
   /***********************************************************************************************************************************************
Validamos que la tabla exista en verdad
***********************************************************************************************************************************************/
   IF not exists( select 1 from sys.objects where name = @vchTabla and type = 'u' and schema_id = @intSchemaID)
        BEGIN; 
            THROW 50003, 'nombre de tabla incorrecto', 1; 

            RETURN 
        END 
  
  /***********************************************************************************************************************************************
Obtenemos todas las referencias hacia esa tabla
***********************************************************************************************************************************************/
      DECLARE @tblFKSearch AS TABLE 
        ( 
           vchtable  VARCHAR(255), 
           vchschema VARCHAR(255), 
           vchcolumn VARCHAR(255) 
        ) 

      INSERT INTO @tblFKSearch 
      SELECT t.NAME  AS vchTable, 
             s.NAME  AS vchSchema, 
             c. NAME AS vchColumn 
      FROM   sys.foreign_key_columns AS fk 
             INNER JOIN sys.tables AS t 
                     ON fk.parent_object_id = t.object_id 
             INNER JOIN sys.columns AS c 
                     ON fk.parent_object_id = c.object_id 
                        AND fk.parent_column_id = c.column_id 
             JOIN sys.schemas s 
               ON t.schema_id = s.schema_id 
      WHERE  fk.referenced_object_id = (SELECT object_id 
                                        FROM   sys.tables 
                                        WHERE  NAME = @vchTabla 
                                               AND schema_id = @intSchemaID) 
      ORDER  BY vchtable, 
                vchschema 

      IF NOT EXISTS(SELECT TOP 1 1 
                    FROM   @tblFKSearch) 
        BEGIN 
            RETURN 
        END 

   /***********************************************************************************************************************************************
buscamos uno a uno el valor en las referencias de manera dinamica en la base de datos y en caso de existir marca error referencial
***********************************************************************************************************************************************/

      SELECT @ssql = COALESCE( 
             @ssql 
             + Concat('IF exists( SELECT 1 FROM  ', t.vchschema, 
             '.', 
             t.vchtable 
                    , 
                            ' WHERE ',t. vchcolumn, ' = ', Char( 39 
             ) + 
             Cast( 
                    @unqKey 
                            AS VARCHAR(36) ) + Char(39) + Char(13 
             ), 
                            'AND bitActivo = 1 ) BEGIN; THROW 50002,' 
             +Char( 
                    39), 
                            'existen referencias hacia este dato en la tabla ', 
                            t.vchschema, '.', t.vchtable, 
             ' verifique su informacion'+ 
                            Char(39), ' , 1; RETURN END; '), '') 
      FROM   @tblFKSearch t 
print @ssql
      EXEC(@ssql ) 
  

  END TRY 

  BEGIN CATCH 
  
      THROW; 
  END CATCH