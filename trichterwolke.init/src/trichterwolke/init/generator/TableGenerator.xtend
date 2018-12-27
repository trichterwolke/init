package trichterwolke.init.generator

import org.eclipse.xtext.generator.IGeneratorContext
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess2
import com.google.inject.Inject
import trichterwolke.init.init.Entity
import trichterwolke.init.init.Attribute
import trichterwolke.init.init.DefinedType
import trichterwolke.init.init.StandardType
import trichterwolke.init.init.Enumeration

class TableGenerator extends GeneratorBase implements ITableGenerator {
		
	@Inject
	extension IDbGenerator	
					
	override doGenerate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context) {
		super.doGenerate(input, fsa, context);
		
		var entities = input.allContents.filter(Entity).toList;
		var content = generateContent(entities);
	    this.fsa.generateFile('schema.sql', content);	
	}
		
	def generateContent(Iterable<Entity> entities)'''	
		�generateTables(entities)�
		
		�generateForeignKeys(entities)�'''
		
	def generateTables(Iterable<Entity> entities)'''
		�FOR entity : entities SEPARATOR '\n'�
		�generateTable(entity)�
		�ENDFOR� 
	'''
	
	def generateTable(Entity entity)'''
	CREATE TABLE �entity.toTableName.quote� (
		id SERIAL PRIMARY KEY,
		�FOR attribute : entity.attributes SEPARATOR ','�
			�generateAttribute(attribute)�
		�ENDFOR�
	)�IF entity.superType !== null� INHERITS (�entity.superType.toTableName�)�ENDIF�;'''

	
	def generateForeignKeys(Iterable<Entity> entities)'''
		�FOR entity : entities�	
		�generateForeignKey(entity)�
		�ENDFOR�
	'''
	
	def generateForeignKey(Entity entity)'''	
		�FOR attribute : entity.attributes.filter(a | isReference(a))�
		ALTER TABLE �entity.toTableName.quote�
		ADD CONSTRAINT �attribute.toAttributeName�_fkey FOREIGN KEY (�attribute.toAttributeName�_id) REFERENCES �attribute.referencedEntity.toTableName.quote� (id);		
		
		�ENDFOR�
	'''
	
	def isReference(Attribute attribute) {
		var type = attribute.type		
		if(type instanceof DefinedType) {
			return type.type instanceof Entity		
		}
		
	    return false;	    
	}
	
	def getReferencedEntity(Attribute attribute) {
		(attribute.type as DefinedType).type as Entity
	}
	
	def generateAttribute(Attribute attribute) {
		if(attribute.type instanceof DefinedType) {		
			generateDefinedTypeAttribute(attribute);
		}
		else {
			'''�attribute.toAttributeName.quote� �attribute.type.toDbType� �generateNullable(attribute.type)�'''
		}	
	}
			
	def dispatch generateNullable(StandardType type)
		'''�IF !type.nullable�NOT�ENDIF� NULL'''
		
	def dispatch generateNullable(DefinedType type) {
		switch type.cardinality {
			case ONE,
	        case ONE_OR_MANY:
	            '''NOT NULL'''
	    	case ZERO_OR_ONE,
	    	case ZERO_OR_MANY:
	    		'''NULL'''
		}
	}
	
	def generateDefinedTypeAttribute(Attribute attribute){
		var type = attribute.type
		if(type instanceof DefinedType) {
			var ref = type.type
			if(ref instanceof Entity) {
				'''�attribute.toAttributeName�_id INT �generateNullable(attribute.type)�'''
			}
			else if(ref instanceof Enumeration) {
				'''�attribute.toAttributeName� �ref.superType.toDbType�'''
			}			
		}
	}	
}