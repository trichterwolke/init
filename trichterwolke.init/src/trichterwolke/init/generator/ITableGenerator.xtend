package trichterwolke.init.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext

interface ITableGenerator {
	def void doGenerate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context);
}