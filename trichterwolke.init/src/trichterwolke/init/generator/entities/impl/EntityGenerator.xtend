package trichterwolke.init.generator.entities.impl

import com.google.inject.Inject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import trichterwolke.init.generator.GeneratorBase
import trichterwolke.init.generator.ICSharpGenerator
import trichterwolke.init.generator.IModelHelper
import trichterwolke.init.generator.ITypeGenerator
import trichterwolke.init.generator.db.IDbGenerator
import trichterwolke.init.generator.entities.IEntityGenerator
import trichterwolke.init.init.Attribute
import trichterwolke.init.init.Entity
import trichterwolke.init.init.CharacterType

class EntityGenerator extends GeneratorBase implements IEntityGenerator {
		
	@Inject
	extension ITypeGenerator	
					
	@Inject
	extension IDbGenerator	
	
	@Inject
	extension IModelHelper
	
	@Inject
	extension ICSharpGenerator
					
	override doGenerate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context) {
		super.doGenerate(input, fsa, context);

		this.fsa.generateFile('''«this.namespace».Entities/EntityBase.cs''', generateEntityBase);		
	    input.allContents.filter(Entity).forEach[generateFile];		  
	}
	
	def generateFile(Entity entity) {
		this.fsa.generateFile('''«this.namespace».Entities/«entity.name».cs''', generateContent(entity));
	}
				
	def generateContent(Entity entity)'''
		using System;
		using System.ComponentModel.DataAnnotations;
		using System.ComponentModel.DataAnnotations.Schema;
		
		namespace «this.namespace».Entities
		{
			[Table("«entity.toTableName»")]
			public class «entity.name» : «IF entity.hasCustomKey»IEquatable<«entity.name»>«ELSE»EntityBase<«entity.name»>«ENDIF»
			{
				«FOR attribute : entity.attributes SEPARATOR '\n'»
					«generateProperty(attribute)»
				«ENDFOR»
				«IF entity.hasCustomKey»

					public override bool Equals(object obj)
					{
					    return Equals(obj as «entity.name»);
					}

					public virtual bool Equals(«entity.name» other)
					{
						if (other == null)
						{
						    return false;
						}
					
						return «generateEqualsExpression(entity)»;
					}
					
					public override int GetHashCode()
					{
					    return «generateHashCodeExpression(entity)»;
					}
				«ENDIF»
			}
		}'''
	
	def generateEqualsExpression(Entity entity)
		'''«FOR attribute : entity.key SEPARATOR " && "»other.«attribute.toPropertyName» == «attribute.toPropertyName»«ENDFOR»'''
	
	def generateHashCodeExpression(Entity entity)
		'''«FOR attribute : entity.key SEPARATOR " ^ "»«attribute.toPropertyName».GetHashCode()«ENDFOR»'''
	
	def generateProperty(Attribute attribute)'''
		«IF attribute.isKey»
		[Key]
		«ELSEIF !attribute.type.isNullable»
		[Required]
		«ENDIF»
		«generateStringLenghtAttribute(attribute)»
		«IF attribute.isReference»
		[Column("«attribute.toAttributeName»_id")]
		public int «attribute.name»ID { get; set; }

		«ENDIF»
		[Column("«attribute.toAttributeName»")]
		public «attribute.type.toType» «attribute.name» { get; set; }
	'''
	
	def generateStringLenghtAttribute(Attribute attribute){
		var type = attribute.type
		if(type instanceof CharacterType) {
			if(type.size > 0) {
			'''[StringLength(«type.size»)]'''
			}
		}
	}	
	
	def generateEntityBase()'''
		using System;
		using System.ComponentModel.DataAnnotations;
		using System.ComponentModel.DataAnnotations.Schema;
		
		namespace Trichterwolke.Sisyphus.Entities
		{
		    public class EntityBase<T> : IEquatable<T>
		        where T : EntityBase<T>
		    {
		    	[Key]
		    	[Column("id")]
		        public int ID { get; set; }
		
		        public override bool Equals(object obj)
		        {
		            return Equals(obj as T);
		        }
		
		        public virtual bool Equals(T other)
		        {
					if (other == null)
					{
					    return false;
					}
		
		            return other.ID == ID; 
		        }
		
		        public override int GetHashCode()
		        {
		            return ID;
		        }
		    }
		}'''
}
