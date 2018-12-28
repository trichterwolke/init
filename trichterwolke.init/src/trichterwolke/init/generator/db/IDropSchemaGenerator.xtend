package trichterwolke.init.generator.db

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext

interface IDropSchemaGenerator {
	def void doGenerate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context);
}
