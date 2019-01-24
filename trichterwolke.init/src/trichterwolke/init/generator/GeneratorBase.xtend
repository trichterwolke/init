package trichterwolke.init.generator

import com.google.inject.Inject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import trichterwolke.init.init.DomainModel
import trichterwolke.init.init.Entity
import trichterwolke.init.init.InitFactory
import trichterwolke.init.init.IntegerKeyword
import trichterwolke.init.init.IntegerType
import trichterwolke.init.init.Attribute;

class GeneratorBase extends AbstractGenerator {
	
	@Inject
	extension IModelHelper	
	
	protected Resource input;
	protected IntegerType defaultKeyType;
	protected String namespace;			
	protected IFileSystemAccess2 fsa;
		
	override doGenerate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context) {
		this.input = input;
		var domainModel =  input.allContents.filter(DomainModel).head(); 
		this.namespace = domainModel.namespace;	
		this.defaultKeyType = domainModel.defaultKeyType;
		if (this.defaultKeyType === null) {
			var intType =  InitFactory.eINSTANCE.createIntegerType;
			intType.keyword = IntegerKeyword.INT; 
			this.defaultKeyType = intType;
		}
		
		this.fsa = fsa;
	}	
	
	def protected getKeyType(Entity entity) {
		if(entity.overrideKeyType === null) {
			return defaultKeyType
		}
		else{
			return entity.overrideKeyType;
		} 
	} 
	/* 
	def protected isReferenced(Entity entity) {
		input.allContents
			.filter(Entity)
			.exists(e | e.attributes.exists(a | a.reference && a.referencedEntity == entity))
	}	
	*/
	def protected isReferenced(Entity entity) {
		input.allContents
			.filter(Attribute)
			.exists(a | a.reference && a.referencedEntity == entity)
	}
	
	def protected getReferencingEntities(Entity entity) {
		input.allContents
			.filter(Entity)
			.filter(e | e.attributes.exists(a | a.reference && a.referencedEntity == entity))
			.toIterable
	}
	 
	def protected getReferencingAttributes(Entity entity) {
		input.allContents
			.filter(Attribute)
			.filter(a | a.reference && a.referencedEntity == entity)
			.toIterable
	}
	
	def protected getEntity(Attribute attribute) {
		input.allContents
			.filter(Entity)
			.findFirst(e | e.attributes.exists(a | a == attribute))
	}
}