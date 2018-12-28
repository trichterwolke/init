package trichterwolke.init.generator.db

import trichterwolke.init.init.Attribute
import trichterwolke.init.init.Entity
import trichterwolke.init.init.Type

interface IDbGenerator {
	def String toTableName(Entity type)
	def String toAttributeName(Attribute attribute)
	def CharSequence toDbType(Type type)
	def CharSequence quote(String name)	
}