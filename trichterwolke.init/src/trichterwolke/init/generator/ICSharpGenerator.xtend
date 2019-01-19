package trichterwolke.init.generator;

import trichterwolke.init.init.Attribute
import trichterwolke.init.init.Entity

interface ICSharpGenerator {		
	def CharSequence generateParametersDeclaration(Entity entity);
	
	def CharSequence generateParameters(Entity entity);
		
	def CharSequence toParameterName(Attribute attribute);
	
	def CharSequence toPropertyName(Attribute attribute);
	
	def CharSequence toParameterType(Attribute attribute);
	
	def CharSequence toParameterName(Entity entity);
	
	def CharSequence toParameterDeclaration(Entity entity);
	
	def CharSequence toFieldName(Entity entity);
	
	def CharSequence toShortName(Entity entity);
	
	def CharSequence toNaturalName (String text);
}
