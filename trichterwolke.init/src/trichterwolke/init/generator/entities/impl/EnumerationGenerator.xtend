package trichterwolke.init.generator.entities.impl

import com.google.inject.Inject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import trichterwolke.init.init.Enumeration

class EnumerationGenerator extends trichterwolke.init.generator.GeneratorBase implements trichterwolke.init.generator.IEnumerationGenerator {
	
	@Inject
	extension trichterwolke.init.generator.ITypeGenerator
					
	override doGenerate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context) {
		super.doGenerate(input, fsa, context);
		
	    input.allContents.filter(Enumeration).forEach[generateFile];		  
	}
	
	def generateFile(Enumeration enumeration) {
		this.fsa.generateFile('''«this.namespace».Entities/«enumeration.name».cs''', generateContent(enumeration));
	}
				
	def generateContent(Enumeration enumeration)'''
	using System;
	using System.ComponentModel.DataAnnotations.Schema;
	
	namespace «this.namespace».Entities
	{
		public enum «enumeration.name» : «enumeration.superType.toType»
		{
			«FOR enumeral : enumeration.enumerals SEPARATOR ","»
				«enumeral.name» = «enumeral.value»
			«ENDFOR»
		}
	}'''
}
