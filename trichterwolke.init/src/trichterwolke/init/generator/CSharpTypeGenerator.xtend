package trichterwolke.init.generator

import trichterwolke.init.init.Type
import trichterwolke.init.init.OtherType
import trichterwolke.init.init.IntegerType
import trichterwolke.init.init.DefinedType
import trichterwolke.init.init.CharacterType
import trichterwolke.init.init.FloatingpointType

class CSharpTypeGenerator implements ITypeGenerator {	
	override toType(Type type) {
		var result = type.encode
		if(!type.nullable || type instanceof DefinedType || (type instanceof CharacterType && (type as CharacterType).size > 1))
			result
		else 
			result + '?'	
	} 
		
	def dispatch encode(DefinedType type)						
		'''«type.type.name»'''
		
	def dispatch encode(CharacterType type) {
		if (type.size == 1)
	   		'char'
	   	else
	   		'string'
	}
		
	def dispatch encode(FloatingpointType type) {		
		switch type.keyword {
			case DOUBLE:
				'''double'''
			case SINGLE:
				'''float'''
			case DECIMAL:
			    '''decimal'''			
		}
	}
	
	def dispatch encode(IntegerType type) {
		switch type.keyword {
			case BYTE:
				'''byte'''			
			case SHORT:
				'''short'''
			case INT:
			    '''int'''	
			case LONG:
			    '''long'''			
		}
	}
		 
	def dispatch encode(OtherType type) {
		switch type.keyword {
			case DATETIME:
				'''DateTime'''
			case TIMESTAMP:
				'''DateTimeOffset'''			
			case BOOL:
				'''bool'''
			case GUID:
			    '''Guid'''				
		}
	}
}