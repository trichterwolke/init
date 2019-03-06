package trichterwolke.init.generator.entities.impl

import com.google.inject.Inject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import trichterwolke.init.generator.GeneratorBase
import trichterwolke.init.generator.ICSharpGenerator
import trichterwolke.init.generator.ITypeGenerator
import trichterwolke.init.generator.entities.IEnumerationGenerator
import trichterwolke.init.init.Enumeration

class EnumerationGenerator extends GeneratorBase implements IEnumerationGenerator {
	
	@Inject
	extension ITypeGenerator	
	
	@Inject
	extension ICSharpGenerator
					
	override doGenerate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context) {
		super.doGenerate(input, fsa, context);
		
	    input.allContents.filter(Enumeration).forEach[generateFile];		  
	}
	
	def generateFile(Enumeration enumeration) {
		this.fsa.generateFile('''src/«this.namespace».Entities/«enumeration.name».cs''', generateContent(enumeration));
	}
				
	def generateContent(Enumeration enumeration)'''
	using System;
	using System.ComponentModel.DataAnnotations.Schema;
	
	namespace «this.namespace».Entities
	{
	    /// <summary>
	    /// Represents «enumeration.name.toNaturalName»s 
	    /// </summary>
		public enum «enumeration.name» : «enumeration.superType.toType»
		{
			«FOR enumeral : enumeration.enumerals SEPARATOR ","»

				/// <summary>
				/// «enumeral.name.toNaturalName» Value: «enumeral.value»
				/// </summary>
				«enumeral.name» = «enumeral.value»
			«ENDFOR»
		}
	}'''
}
