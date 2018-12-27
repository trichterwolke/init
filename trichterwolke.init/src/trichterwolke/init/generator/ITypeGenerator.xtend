package trichterwolke.init.generator

import trichterwolke.init.init.Type

interface ITypeGenerator {
	def CharSequence toType(Type type);
}