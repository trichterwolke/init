package trichterwolke.init.generator.entities.impl

import com.google.inject.Inject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import trichterwolke.init.generator.GeneratorBase
import trichterwolke.init.generator.ITypeGenerator
import trichterwolke.init.generator.db.IDbGenerator
import trichterwolke.init.generator.entities.IEntityGenerator
import trichterwolke.init.init.Entity

class EntityGenerator extends GeneratorBase implements IEntityGenerator {
		
	@Inject
	extension ITypeGenerator	
					
	@Inject
	extension IDbGenerator
					
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
		using System.ComponentModel.DataAnnotations.Schema;
		
		namespace «this.namespace».Entities
		{
			[Table("«entity.toTableName»")]
			public class «entity.name» : EntityBase<«entity.name»>
			{
				«FOR attribute : entity.attributes SEPARATOR '\n'»
					[Column("«attribute.toAttributeName»")]
					public «attribute.type.toType» «attribute.name» { get; set; }
				«ENDFOR»
			}
		}'''
	
	def generateEntityBase()'''
		using System;
		
		namespace Trichterwolke.Sisyphus.Entities
		{
		    public class EntityBase<T> : IEquatable<T>
		        where T : EntityBase<T>
		    {
		    	[Column("id")]
		        public int ID { get; set; }
		
		        public override bool Equals(object obj)
		        {
		            return Equals(obj as T);
		        }
		
		        public virtual bool Equals(T other)
		        {
		            if(ReferenceEquals(this, other))
		            {
		                return true;
		            }
		
		            if(ReferenceEquals(null, other))
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
