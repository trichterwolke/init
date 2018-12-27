package trichterwolke.init.generator

import trichterwolke.init.init.Entity
import trichterwolke.init.init.Attribute
import trichterwolke.init.init.Type

interface IDbGenerator {
	def CharSequence toTableName(Entity type)
	def CharSequence toAttributeName(Attribute attribute)
	def CharSequence toDbType(Type type)
	def CharSequence quote(CharSequence name)
	
}