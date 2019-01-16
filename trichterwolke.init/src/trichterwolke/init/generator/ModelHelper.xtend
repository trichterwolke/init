package trichterwolke.init.generator

import trichterwolke.init.init.Attribute
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
   		entity.attributes.exists(a | a.isKey)
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
}