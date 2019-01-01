package trichterwolke.init.generator

import trichterwolke.init.init.Attribute
import trichterwolke.init.init.Entity

interface IModelHelper {
	def Boolean isReference(Attribute attribute) 
	
	def Entity getReferencedEntity(Attribute attribute) 
	
	def boolean hasCustomKey(Entity entity)
	
	def Iterable<Attribute> getKey(Entity entity)
	
	def Iterable<Entity> withCompositeKey(Iterable<Entity> entities)
}