package trichterwolke.init.generator.db.impl

import com.google.inject.Inject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import trichterwolke.init.generator.GeneratorBase
import trichterwolke.init.generator.IModelHelper
import trichterwolke.init.generator.db.ICreateSchemaGenerator
import trichterwolke.init.generator.db.IDbGenerator
import trichterwolke.init.init.Attribute
import trichterwolke.init.init.DefinedType
import trichterwolke.init.init.Entity
import trichterwolke.init.init.Enumeration
import trichterwolke.init.init.Type

class CreateSchemaGenerator extends GeneratorBase implements ICreateSchemaGenerator {
		
	@Inject
	extension IDbGenerator	
	
	@Inject
	extension IModelHelper 
					
	override doGenerate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context) {
		super.doGenerate(input, fsa, context);
		
		var entities = input.allContents.filter(Entity).toList;
		var content = generateContent(entities);
	    this.fsa.generateFile('db/create_schema.sql', content);	
	}
		
	def generateContent(Iterable<Entity> entities)'''	
	«generateTables(entities)»
	
	«generateIndicesOnForeignKeys(entities)»'''
		
	def generateTables(Iterable<Entity> entities)'''
		«FOR entity : entities SEPARATOR '\n'»
			«generateTable(entity)»
		«ENDFOR» 
	'''
	
	def generateTable(Entity entity)'''
		CREATE TABLE «entity.toTableName.quote» (
			«IF !entity.hasCustomKey»id «getKeyType(entity).toSerialType» PRIMARY KEY,«ENDIF»
			«FOR attribute : entity.attributes SEPARATOR ','»
				«generateAttribute(attribute)»
			«ENDFOR»
			«IF entity.hasCustomKey»
				«generateCustomPrimaryKey(entity)»
			«ENDIF»
			«generateForeignKeys(entity)»
		);'''
	
	/*
	def generateForeignKeys(Iterable<Entity> entities)'''
		«FOR entity : entities»	
			«generateAddForeignKey(entity)»
		«ENDFOR»
	'''
	
	def generateAddForeignKey(Entity entity)'''	
		«FOR attribute : entity.attributes.filter(a | isReference(a))»
			ALTER TABLE «entity.toTableName.quote»
			ADD CONSTRAINT «entity.toTableName»_«attribute.toAttributeName»_fkey FOREIGN KEY («attribute.toAttributeName»_id) REFERENCES «attribute.referencedEntity.toTableName.quote» (id);					
			CREATE INDEX «entity.toTableName»_«attribute.toAttributeName»_idx ON «entity.toTableName.quote» («attribute.toAttributeName»_id);

		«ENDFOR»								
	'''	
	*/
		
	def generateForeignKeys(Entity entity)'''
		«FOR attribute : entity.attributes.filter(a | isReference(a))»
			, CONSTRAINT «entity.toTableName»_«attribute.toAttributeName»_fkey FOREIGN KEY («attribute.toAttributeName»_id) REFERENCES «attribute.referencedEntity.toTableName.quote» (id)
		«ENDFOR»
	'''
	
	def generateIndicesOnForeignKeys(Iterable<Entity> entities)'''
		«FOR entity : entities»	
			«FOR attribute : entity.attributes.filter(a | isReference(a))»
				CREATE INDEX «entity.toTableName»_«attribute.toAttributeName»_id_idx ON «entity.toTableName.quote» («attribute.toAttributeName»_id);
			«ENDFOR»
		«ENDFOR»
	'''
	
	def generateCustomPrimaryKey(Entity entity)		
		''', PRIMARY KEY («FOR attribute : entity.key SEPARATOR ", "»«attribute.toAttributeName»«IF attribute.isReference»_id«ENDIF»«ENDFOR»)'''
		
	def generateAttribute(Attribute attribute)
		'''«generateAttributeInner(attribute)»«generateUnique(attribute)»'''
		
	def generateAttributeInner(Attribute attribute) {		
		if(attribute.type instanceof DefinedType) {		
			generateDefinedTypeAttribute(attribute);
		}
		else {
			'''«attribute.toAttributeName.quote» «attribute.type.toDbType» «generateNullable(attribute.type)»'''
		}	
	}
	
	def generateUnique(Attribute attribute){
		if(attribute.isUnique){
			return ''' UNIQUE'''
		}
	}
						
	def generateNullable(Type type)
		'''«IF !type.nullable»NOT «ENDIF»NULL'''
		
	def generateDefinedTypeAttribute(Attribute attribute){
		var type = attribute.type
		if(type instanceof DefinedType) {
			var ref = type.type
			if(ref instanceof Entity) {
				'''«attribute.toAttributeName»_id «ref.keyType.toDbType» «generateNullable(attribute.type)»'''
			}
			else if(ref instanceof Enumeration) {
				'''«attribute.toAttributeName» «ref.superType.toDbType»'''
			}			
		}
	}	
}