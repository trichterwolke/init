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
		if (attribute.name.equals("ID")) {
			return "id"
		}
		else if (attribute.isReference) {
			return '''«attribute.name.toFirstLower»ID'''
		}
		else {
			return attribute.name.toFirstLower;
		}
	}
	
	override toPropertyName(Attribute attribute) {
		if (attribute.name.equals("ID")) {
			return "id"
		}
		else if (attribute.isReference) {
			return '''«attribute.name»ID''' 
		}
		else {
			return attribute.name;
		}
	}	
	
	override toParameterType(Attribute attribute) {
		if (attribute.name.equals("ID")) {
			return "int"
		}
		else if (attribute.isReference) {
			return "int"
		}
		else {
			return attribute.type.toType
		}
	}
	
	override toParameterName(Entity entity){
		return entity.name.toFirstLower
	}	
	
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