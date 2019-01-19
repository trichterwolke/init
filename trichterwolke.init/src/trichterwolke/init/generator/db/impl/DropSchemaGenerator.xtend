package trichterwolke.init.generator.db.impl

import com.google.inject.Inject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import trichterwolke.init.generator.GeneratorBase
import trichterwolke.init.generator.IModelHelper
import trichterwolke.init.generator.db.IDbGenerator
import trichterwolke.init.generator.db.IDropSchemaGenerator
import trichterwolke.init.init.Entity

class DropSchemaGenerator extends GeneratorBase implements IDropSchemaGenerator {
		
	@Inject
	extension IDbGenerator		
	
	@Inject
	extension IModelHelper	
					
	override doGenerate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context) {
		super.doGenerate(input, fsa, context);
		
		var entities = input.allContents.filter(Entity).toList;
		var content = generateContent(entities);
	    this.fsa.generateFile('db/drop_schema.sql', content);	
	}
		
	def generateContent(Iterable<Entity> entities)'''		
		«generateForeignKeys(entities)»
		
		«generateTables(entities)»
	'''
		
	def generateTables(Iterable<Entity> entities)'''
		«FOR entity : entities SEPARATOR '\n'»
			«generateTable(entity)»
		«ENDFOR» 
	'''
	
	def generateTable(Entity entity)'''
		DROP TABLE «entity.toTableName.quote»;
	'''

	
	def generateForeignKeys(Iterable<Entity> entities)'''
		«FOR entity : entities»	
			«generateForeignKey(entity)»
		«ENDFOR»
	'''
	
	def generateForeignKey(Entity entity)'''	
		«FOR attribute : entity.attributes.filter(a | isReference(a))»
			ALTER TABLE «entity.toTableName.quote»
			DROP CONSTRAINT «entity.toTableName»_«attribute.toAttributeName»_fkey;
			
		«ENDFOR»
	'''
}
