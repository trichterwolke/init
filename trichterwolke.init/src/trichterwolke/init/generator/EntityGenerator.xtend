package trichterwolke.init.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import org.eclipse.xtext.generator.AbstractGenerator
import trichterwolke.init.init.Entity
import trichterwolke.init.init.DomainModel
import trichterwolke.init.init.CharacterType
import trichterwolke.init.init.FloatingpointType
import trichterwolke.init.init.IntegerType
import trichterwolke.init.init.OtherType
import trichterwolke.init.init.DefinedType

class EntityGenerator extends AbstractGenerator {
	
	String namespace;			
	IFileSystemAccess2 fsa;
				
	override doGenerate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context) {
		this.namespace = input.allContents.filter(DomainModel).head().namespace;
		this.fsa = fsa;
		
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
			«FOR attribute : entity.attributs SEPARATOR '\n'»
			public «encode(attribute.type)» «attribute.name» { get; set; }
			«ENDFOR»
		}
	}
	'''
	
	def dispatch encode(DefinedType type)
		'''«type.type.name»''' 
	
	def dispatch encode(CharacterType type) {
		if (type.size == 1)
	   		'char'
	   	else
	   		'string'
	}
		
	def dispatch encode(FloatingpointType type) {
		switch type.keyword {
			case DOUBLE:
				'''double'''			
			case SINGLE:
				'''single'''
			case DECIMAL:
			    '''decimal'''			
		}
	}
	
	def dispatch encode(IntegerType type) {
		switch type.keyword {
			case BYTE:
				'''byte'''			
			case SHORT:
				'''short'''
			case INT:
			    '''int'''	
			case LONG:
			    '''long'''			
		}
	}
		 
	def dispatch encode(OtherType type){
		switch type.keyword {
			case DATETIME:
				'''DateTime'''			
			case BOOL:
				'''bool'''
			case GUID:
			    '''Guid'''			
		}
	}	
}