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

		this.fsa.generateFile('''src/«this.namespace».Entities/EntityBase.cs''', generateEntityBase);		
	    input.allContents.filter(Entity).forEach[generateFiles];		    		  
	}
	
	def generateFiles(Entity entity) {
		generateFile(entity)
		for(many : entity.entitiesFromMany) {
			generateFile(many)
		}
	}
	
	def generateFile(Entity entity) {
		this.fsa.generateFile('''src/«this.namespace».Entities/«entity.name».cs''', generateContent(entity));
	}
				
	def generateContent(Entity entity)'''
		using System;
		using System.ComponentModel.DataAnnotations;
		using System.ComponentModel.DataAnnotations.Schema;
		
		namespace «this.namespace».Entities
		{
		    /// <summary>
		    /// Represents the «entity.name.toNaturalName» entity
		    /// </summary>
			«FOR key : entity.key»
			/// <param name="«key.toParameterName»">Primary key of the «entity.name.toNaturalName»</param>
			«ENDFOR»
			[Table("«entity.toTableName»")]
			public class «entity.name» : «IF entity.hasCustomKey»IEquatable<«entity.name»>«ELSE»EntityBase<«entity.name», «getKeyType(entity).toType»>«ENDIF»
			{
				«IF !entity.hasCustomKey»
					/// <summary>
					/// Creates a new instance.
					/// </summary>
					public «entity.name»()
					{
					}
					
					/// <summary>
					/// Creates a new instance.
					/// </summary>
					/// <param name="id">primary key</param>
					public «entity.name»(«getKeyType(entity).toType» id)
						: base(id)
					{
					}

				«ELSE»
					/// <summary>
					/// Creates a new instance.
					/// </summary>
					public «entity.name»(«entity.generateParametersDeclaration»)
					{
						«FOR attribute : entity.key»
							«attribute.name»Id = «attribute.name.toFirstLower»Id;				
						«ENDFOR»
					}

				«ENDIF»		
				«FOR attribute : entity.attributes SEPARATOR '\n'»
					«generateProperty(attribute)»
				«ENDFOR»
				«IF entity.hasCustomKey»

					/// <summary>
					/// Indicates whether this instance and another entity of the same type have the same primary key.
					/// </summary>
					/// <param name="obj">An entity to compare with this entity</param>
					/// <returns>true if the current entity is equal to the other parameter; otherwise, false.</returns>
					public override bool Equals(object obj)
					{
					    return Equals(obj as «entity.name»);
					}

					/// <summary>
					/// Indicates whether this instance and another entity of the same type have the same primary key.
					/// </summary>
					/// <param name="obj">An entity to compare with this entity</param>
					/// <returns>true if the current entity is equal to the other parameter; otherwise, false.</returns>
					public virtual bool Equals(«entity.name» other)
					{
						if (other == null)
						{
						    return false;
						}
					
						return «generateEqualsExpression(entity)»;
					}
					
					/// <summary>
					/// Retunrn the hash values of the primary key
					/// </summary>
					/// <returns>Hash values of the primary key</returns>
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
	
	def generateProperty(Attribute attribute)		
	 '''«IF attribute.isReference»
			/// <summary>
			/// Gets or sets foreign key «attribute.name.toNaturalName» id.
			/// </summary>
			«generateRequired(attribute)»
			[Column("«attribute.toAttributeName»_id")]
			public «getKeyType(attribute.referencedEntity).toType»«IF attribute.type.nullable»?«ENDIF» «attribute.name»Id { get; set; }
			
			/// <summary>
			/// Gets or sets the navigation property «attribute.name.toNaturalName».
			/// </summary>
			[Column("«attribute.toAttributeName»_id")]
			public «attribute.type.toType» «attribute.name» { get; set; }
		«ELSE»
			/// <summary>
			/// Gets or sets the «attribute.name.toNaturalName».
			/// </summary>
			«generateRequired(attribute)»
			«generateStringLenghtAttribute(attribute)»
			[Column("«attribute.toAttributeName»")]
			public «attribute.type.toType» «attribute.name» { get; set; }
		«ENDIF»'''
	
    def generateRequired(Attribute attribute) {
		if (attribute.isKey){
			'''[Key]'''}
		else if (!attribute.type.isNullable) {			
			'''[Required]'''			
		}
    }
	
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
		
		namespace «this.namespace».Entities
		{
		    /// <summary>
		    /// Base class for an entity with an non composit primary key
		    /// </summary>
		    /// <typeparam name="T">Type of the derived class</typeparam>
		    /// <typeparam name="TKey">Type of the primary key</typeparam>
		    public class EntityBase<T, TKey> : IEquatable<T>
		        where T : EntityBase<T, TKey>
		    {
				/// <summary>
				/// Creates a new instance
				/// </summary>
				public EntityBase()
				{
				}
				
				/// <summary>
				/// Creates a new instance
				/// </summary>
				/// <param name="id">primary key</param>
				public EntityBase(TKey id)
				{
				    Id = id;
				}
		    	
		        /// <summary>
		        /// The primary key
		        /// </summary>
		    	[Key]
		    	[Column("id")]
		        public TKey Id { get; set; }
		
		        /// <summary>
		        /// Indicates whether this instance and another entity of the same type have the same Id.
		        /// </summary>
		        /// <param name="obj">An entity to compare with this entity</param>
		        /// <returns>true if the current entity is equal to the other parameter; otherwise, false.</returns>
		        public override bool Equals(object obj)
		        {
		            return Equals(obj as T);
		        }
		
		        /// <summary>
		        /// Indicates whether this instance and another entity of the same type have the same Id.
		        /// </summary>
		        /// <param name="obj">An entity to compare with this entity</param>
		        /// <returns>true if the current entity is equal to the other parameter; otherwise, false.</returns>
		        public virtual bool Equals(T other)
		        {
					if (other == null)
					{
					    return false;
					}
		
		            return other.Id.Equals(Id); 
		        }
		
		        /// <summary>
		        /// Serves the default hash function of the Id
		        /// </summary>
		        /// <returns></returns>
		        public override int GetHashCode()
		        {
		            return Id.GetHashCode();
		        }
		    }
		}'''
}
