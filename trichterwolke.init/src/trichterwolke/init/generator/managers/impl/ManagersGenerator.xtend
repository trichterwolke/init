package trichterwolke.init.generator.managers.impl

import com.google.inject.Inject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import trichterwolke.init.generator.GeneratorBase
import trichterwolke.init.generator.ICSharpGenerator
import trichterwolke.init.generator.IModelHelper
import trichterwolke.init.generator.managers.IManagersGenerator
import trichterwolke.init.init.Entity

class ManagersGenerator extends GeneratorBase implements IManagersGenerator {
	
	@Inject
	extension IModelHelper
	
	@Inject
	extension ICSharpGenerator
						
	override doGenerate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context) {
		super.doGenerate(input, fsa, context);
		
		var entities = input.allContents.filter(Entity).toList();	
		
		this.fsa.generateFile('''«this.namespace».Managers/ICrudManager.cs''', generateICrudDalContent());
		this.fsa.generateFile('''«this.namespace».Managers/EntityFramework/CrudManager.cs''', generateCrudManagerContent());	
		this.fsa.generateFile('''«this.namespace».Managers/EntityFramework/EntityContext.cs''', generateEntityContextContent(entities));		
		
		entities.forEach[generateFile];
	}
	
	def generateFile(Entity entity) {
		this.fsa.generateFile('''«this.namespace».Managers/I«entity.name»Manager.cs''', generateManagerInterfaceContent(entity));
		this.fsa.generateFile('''«this.namespace».Managers/EntityFramework/«entity.name»Manager.cs''', generateManagerContent(entity));
	}
				
	def generateManagerInterfaceContent(Entity entity)'''
		using System;
		using «namespace».Entities;
		
		namespace «this.namespace».Managers
		{			
			public interface I«entity.name»Manager : ICrudManager<«entity.name»>
			{
			}
		}'''	
 	
	def generateManagerContent(Entity entity)'''
		using System;
		using System.Collections.Generic;
		using System.Linq;
		using System.Text;
		using Microsoft.EntityFrameworkCore;
		using Trichterwolke.Sisyphus.Entities;
		
		namespace «this.namespace».Managers.EntityFramework
		{
		    public class «entity.name»Manager : CrudManager<«entity.name»>, I«entity.name»Manager
		    {
		        public «entity.name»Manager(EntityContext context) 
		            : base(context)
		        {
		        }
		    }
		}'''
		
	def generateCrudManagerContent()'''
		using System;
		using System.Collections.Generic;
		using System.Threading.Tasks;
		using Microsoft.EntityFrameworkCore;
		
		namespace «this.namespace».Managers.EntityFramework
		{
			public class CrudManager<T> : ICrudManager<T>
			    where T: class
			{
			    public CrudManager(EntityContext context)
			    {
			        Context = context;
			    }

			    protected EntityContext Context { get; }

			    public virtual async Task DeleteAsync(object[] keyValues)
			    {
			        var entity = await Context.FindAsync<T>(keyValues);
			        Context.Remove(entity);
			        await Context.SaveChangesAsync();           
			    }

			    public virtual async Task<IEnumerable<T>> FindAllAsync()
			    {
			        return await Context.Set<T>().ToListAsync();
			    }

			    public virtual async Task<T> FindAsync(object[] keyValues)
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
		
		namespace «this.namespace».Managers
		{
		    public interface ICrudManager<T>
		    {
				Task DeleteAsync(params object[] keyValues);
				Task<IEnumerable<T>> FindAllAsync();
				Task<T> FindAsync(params object[] keyValues);
				Task InsertAsync(T entity);
				Task UpdateAsync(T entity);
		    }
		}'''
		
	def generateEntityContextContent(Iterable<Entity> entities)'''
		using Microsoft.EntityFrameworkCore;
		using «this.namespace».Entities;
		
		namespace «this.namespace».Managers.EntityFramework
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