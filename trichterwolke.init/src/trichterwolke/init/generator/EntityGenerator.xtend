package trichterwolke.init.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import trichterwolke.init.init.Entity
import com.google.inject.Inject

class EntityGenerator extends GeneratorBase implements IEntityGenerator {
		
	@Inject
	extension ITypeGenerator	
					
	override doGenerate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context) {
		super.doGenerate(input, fsa, context);
		
	    input.allContents.filter(Entity).forEach[generateFile];		  
	}
				
	def generateFile(Entity entity) {
		this.fsa.generateFile('''«this.namespace».Entities/«entity.name».cs''', generateContent(entity));
	}
				
	def generateContent(Entity entity)'''
	using System;
	
	namespace «this.namespace».Entities
	{
		public class «entity.name»
		{
			«FOR attribute : entity.attributes SEPARATOR '\n'»
			public «attribute.type.toType» «attribute.name» { get; set; }
			«ENDFOR»
		}
	}
	'''	
}