package trichterwolke.init.generator.db.impl

import trichterwolke.init.generator.db.IDbGenerator
import trichterwolke.init.init.Attribute
import trichterwolke.init.init.CharacterType
import trichterwolke.init.init.DefinedType
import trichterwolke.init.init.Entity
import trichterwolke.init.init.FloatingpointType
import trichterwolke.init.init.IntegerType
import trichterwolke.init.init.OtherType
import trichterwolke.init.init.Type

class PostgresGenerator implements IDbGenerator {	
	override toTableName(Entity type) {
		type.name.toSnakeCase
	}
	
	override toAttributeName(Attribute attribute)	
		'''«attribute.name.toSnakeCase»'''
			
	override toDbType(Type type) {
		type.encode
	}
	
	override quote(String name) {			
		switch(name) {
			case "end",
			case "begin":
				return '''"«name»"'''
			default:
				return name
		}
	}
		
	def toSnakeCase(String text){
		text.replaceAll("(.)(\\p{Upper})", "$1_$2").toLowerCase();
	}
				
	def dispatch encode(DefinedType type)
		'''«type.type.toString»''' 
	
	def dispatch encode(CharacterType type) {
		if (type.size == 0)
			'TEXT'
		else if (type.size == 1)
	   		'CHAR(1)'
	   	else
	   		'''VARCHAR(«type.size»)'''
	}
		
	def dispatch encode(FloatingpointType type) {
		switch type.keyword {
			case DOUBLE:
				'''FLOAT'''			
			case SINGLE:
				'''REAL'''
			case DECIMAL:
			    '''NUMERIC'''			
		}
	}
	
	def dispatch encode(IntegerType type) {
		switch type.keyword {
			case BYTE,			
			case SHORT:
				'''SMALLINT'''
			case INT:
			    '''INT'''	
			case LONG:
			    '''BIGINT'''			
		}
	}
		 
	def dispatch encode(OtherType type) {
		switch type.keyword {
			case DATETIME:
				'''TIMESTAMP'''			
			case BOOL:
				'''BOOL'''
			case GUID:
			    '''UUID'''			
		}
	}	
}
