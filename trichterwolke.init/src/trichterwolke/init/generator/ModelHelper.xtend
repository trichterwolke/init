package trichterwolke.init.generator

import trichterwolke.init.init.Attribute
import trichterwolke.init.init.DefinedType
import trichterwolke.init.init.Entity

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
}