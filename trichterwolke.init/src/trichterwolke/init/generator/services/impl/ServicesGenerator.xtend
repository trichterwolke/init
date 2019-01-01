package trichterwolke.init.generator.services.impl

import com.google.inject.Inject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import trichterwolke.init.generator.GeneratorBase
import trichterwolke.init.generator.ICSharpGenerator
import trichterwolke.init.generator.IModelHelper
import trichterwolke.init.generator.services.IServicesGenerator
import trichterwolke.init.init.Entity

class ServicesGenerator extends GeneratorBase implements IServicesGenerator {
	
	@Inject
	extension IModelHelper
	
	@Inject
	extension ICSharpGenerator
						
	override doGenerate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context) {
		super.doGenerate(input, fsa, context);
		
		var entities = input.allContents.filter(Entity).toList();	
		
		this.fsa.generateFile('''«this.namespace».Services/ICrudService.cs''', generateICrudDalContent());
		this.fsa.generateFile('''«this.namespace».Services/EntityFramework/CrudService.cs''', generateCrudServiceContent());	
		this.fsa.generateFile('''«this.namespace».Services/EntityFramework/EntityContext.cs''', generateEntityContextContent(entities));		
		
		entities.forEach[generateFile];
	}
	
	def generateFile(Entity entity) {
		this.fsa.generateFile('''«this.namespace».Services/I«entity.name»Service.cs''', generateServiceInterfaceContent(entity));
		this.fsa.generateFile('''«this.namespace».Services/EntityFramework/«entity.name»Service.cs''', generateServiceContent(entity));
	}
				
	def generateServiceInterfaceContent(Entity entity)'''
		using System;
		using «namespace».Entities;
		
		namespace «this.namespace».Services
		{			
			public interface I«entity.name»Service : ICrudService<«entity.name»>
			{
			}
		}'''	
 	
	def generateServiceContent(Entity entity)'''
		using System;
		using System.Collections.Generic;
		using System.Linq;
		using System.Text;
		using Microsoft.EntityFrameworkCore;
		using Trichterwolke.Sisyphus.Entities;
		
		namespace «this.namespace».Services.EntityFramework
		{
		    public class «entity.name»Service : CrudService<«entity.name»>, I«entity.name»Service
		    {
		        public «entity.name»Service(EntityContext context) 
		            : base(context)
		        {
		        }
		    }
		}'''
		
	def generateCrudServiceContent()'''
		using System;
		using System.Collections.Generic;
		using System.Threading.Tasks;
		using Microsoft.EntityFrameworkCore;
		
		namespace «this.namespace».Services.EntityFramework
		{
			public class CrudService<T> : ICrudService<T>
			    where T: class
			{
			    public CrudService(EntityContext context)
			    {
			        Context = context;
			    }

			    protected EntityContext Context { get; }

			    public virtual async Task DeleteAsync(params int[] keyValues)
			    {
			        var entity = await Context.FindAsync<T>(keyValues);
			        Context.Remove(entity);
			        await Context.SaveChangesAsync();           
			    }

			    public virtual async Task<IEnumerable<T>> FindAllAsync()
			    {
			        return await Context.Set<T>().ToListAsync();
			    }

			    public virtual async Task<T> FindAsync(int[] keyValues)
			    {
			        return await Context.FindAsync<T>(keyValues);
			    }

			    public virtual async Task InsertAsync(T entity)
			    {
			        await Context.AddAsync(entity);
			        await Context.SaveChangesAsync();                
			    }

			    public virtual async Task UpdateAsync(T entity)
			    {
			        Context.Update(entity);
			        await Context.SaveChangesAsync();
			    }
			}
		}
		'''

	def generateICrudDalContent()'''
		using System.Collections.Generic;
		using System.Threading.Tasks;
		
		namespace «this.namespace».Services
		{
		    public interface ICrudService<T>
		    {
				Task DeleteAsync(params int[] keyValues);
				Task<IEnumerable<T>> FindAllAsync();
				Task<T> FindAsync(params int[] keyValues);
				Task InsertAsync(T entity);
				Task UpdateAsync(T entity);
		    }
		}'''
		
	def generateEntityContextContent(Iterable<Entity> entities)'''
		using Microsoft.EntityFrameworkCore;
		using «this.namespace».Entities;
		
		namespace «this.namespace».Services.EntityFramework
		{
		    public class EntityContext : DbContext
		    {
		        public EntityContext(DbContextOptions<EntityContext> options)
		            : base(options)
		        { }

		        «FOR entity : entities»
		        public DbSet<«entity.name»> «entity.name»s { get; set; }
		        «ENDFOR»
		        
		        protected override void OnModelCreating(ModelBuilder modelBuilder)
		        {
		        	«FOR entity : entities.withCompositeKey»
		        	modelBuilder.Entity<«entity.name»>()
		        		.HasKey(«entity.toShortName» => new { «FOR attribute : entity.key SEPARATOR ", "»«entity.toShortName».«attribute.toPropertyName»«ENDFOR» });
		            «ENDFOR»
		        }
		    }
		}'''
}