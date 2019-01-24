package trichterwolke.init.generator

import com.google.inject.Inject
import trichterwolke.init.init.Attribute
import trichterwolke.init.init.Entity

class CSharpGenerator implements ICSharpGenerator {
	@Inject
	extension IModelHelper	
	
	@Inject
	extension ITypeGenerator
   	
   	override generateParametersDeclaration(Entity entity)
   		'''«FOR key : entity.key SEPARATOR ", "»«key.toParameterType» «key.toParameterName»«ENDFOR»'''   	
   		
   	override generateParameters(Entity entity)
   		'''«FOR key : entity.key SEPARATOR ", "»«key.toParameterName»«ENDFOR»'''

	override toParameterName(Attribute attribute) {
		if ("Id".equals(attribute.name)) {
			return "id"
		}
		else if (attribute.isReference) {
			return '''«attribute.name.toFirstLower»Id'''
		}
		else {
			return attribute.name.toFirstLower;
		}
	}
	
	override toParameterDeclaration(Attribute attribute)
		'''«attribute.toParameterType» «attribute.toParameterName»'''
		
	override toPropertyName(Attribute attribute) {
		if ("Id".equals(attribute.name)) {
			return "id"
		}
		else if (attribute.isReference) {
			return '''«attribute.name»Id''' 
		}
		else {
			return attribute.name;
		}
	}	
	
	override toParameterType(Attribute attribute) {
		if ("Id".equals(attribute.name)) {
			return "int"
		}
		else if (attribute.isReference) {
			return "int"
		}
		else {
			return attribute.type.toType
		}
	}
	
	override toParameterName(Entity entity) {
		return entity.name.toFirstLower
	}
	
	override toParameterDeclaration(Entity entity)
		'''«entity.name» «entity.toParameterName»'''	
	
	
	override toFieldName(Entity entity)
		'''_«entity.name.toFirstLower»'''
	
	
	override toShortName(Entity entity){
		return entity.name.toShortName;
	}
	
	def toShortName(String text){
		text.replaceAll("([a-z]+)", "").toLowerCase();
	}
	
	override toNaturalName(String text) {
		text.replaceAll("(.)(\\p{Upper})", "$1 $2").toLowerCase();
	}
	
}