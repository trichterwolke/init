package trichterwolke.init.generator

import java.util.ArrayList
import trichterwolke.init.init.Attribute
import trichterwolke.init.init.Declaration
import trichterwolke.init.init.DefinedType
import trichterwolke.init.init.Entity
import trichterwolke.init.init.InitFactory

class ModelHelper implements IModelHelper {
		
	override isReference(Attribute attribute) {
		var type = attribute.type		
		if(type instanceof DefinedType) {
			return type.type instanceof Entity		
		}
		
	    return false;
	}
	
	override getReferencedEntity(Attribute attribute) {
		(attribute.type as DefinedType).type as Entity
	}
	
   	override hasCustomKey(Entity entity) {   		
   		entity.attributes.exists(a | a.key)
	}   	
	
	override hasUnique(Entity entity) {   		
   		entity.attributes.exists(a | a.unique)
	}
		
	override getKey(Entity entity) {
		var key = entity.attributes.filter(a | a.isKey).toList() 	
		
		if(key.size == 0) {
			var attribute = InitFactory.eINSTANCE.createAttribute();
			attribute.name = "Id";
			key.add(attribute);
		}
		
		return key; 
	}
	
	override withCompositeKey(Iterable<Entity> entities) {
		entities.filter(e | e.key.size > 1)
	}
	
	override Iterable<Entity> getEntitiesFromMany(Entity entity) {
		
		var result = new ArrayList<Entity>();
		for(many : entity.manies) {			
			var newEntity = InitFactory.eINSTANCE.createEntity();
			newEntity.name = entity.name + many.name
			newEntity.getAttributes().add(createAttribute(entity))
			newEntity.getAttributes().add(createAttribute(many.type.type))
					
		    var newAttributes = newEntity.attributes;							 
			for(attribute : many.attributes) {				
				newAttributes.add(attribute.clone)
			}
			
			result.add(newEntity);				
		}
		
		return result;
	}
	
	def Attribute clone(Attribute attribute) {
		var result = InitFactory.eINSTANCE.createAttribute()
		result.name = attribute.name
		result.type = InitFactory.eINSTANCE.createType()

		return result;		
	}
	
	def Attribute createAttribute(Declaration entity){
		var attribute = InitFactory.eINSTANCE.createAttribute()
		attribute.name = entity.name
		var type = InitFactory.eINSTANCE.createDefinedType()
		type.type = entity
		attribute.type = type
		attribute.key = true
		return attribute;
	}		
}