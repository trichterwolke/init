package trichterwolke.init.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import trichterwolke.init.init.DomainModel
import org.eclipse.xtext.generator.AbstractGenerator

class GeneratorBase extends AbstractGenerator {
	
	protected String namespace;			
	protected IFileSystemAccess2 fsa;
	
	override doGenerate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context) {
		this.namespace = input.allContents.filter(DomainModel).head().namespace;
		this.fsa = fsa;
	}	
}