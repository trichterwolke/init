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

class ManagerGenerator extends GeneratorBase implements IManagersGenerator {
	
	@Inject
	extension IModelHelper
	
	@Inject
	extension ICSharpGenerator
						
	override doGenerate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context) {
		super.doGenerate(input, fsa, context);
		
		var entities = input.allContents.filter(Entity).toList();	
		  
		this.fsa.generateFile('''src/«this.namespace».Managers/IManagerBase.cs''', generateIManagerBaseContent());
		this.fsa.generateFile('''src/«this.namespace».Managers/EntityFramework/ManagerBase.cs''', generateManagerBaseContent());	
		this.fsa.generateFile('''src/«this.namespace».Managers/EntityFramework/EntityContext.cs''', generateEntityContextContent(entities));		
		this.fsa.generateFile('''src/«this.namespace».Managers/DependencyInjectionSetup.cs''', generateDependencyInjectionSetup(entities));		
		
		entities.forEach[generateFile];
	}
	
	def generateFile(Entity entity) {
		this.fsa.generateFile('''src/«this.namespace».Managers/I«entity.name»Manager.cs''', generateManagerInterfaceContent(entity));
		this.fsa.generateFile('''src/«this.namespace».Managers/EntityFramework/«entity.name»Manager.cs''', generateManagerContent(entity));
	}
				
	def generateManagerInterfaceContent(Entity entity)'''
		using System;
		using System.Collections.Generic;
		using System.ComponentModel.DataAnnotations;
		using System.Threading.Tasks;
		using «namespace».Entities;
		
		namespace «this.namespace».Managers
		{
			/// <summary>
			/// Provides the APIs for managing «entity.name.toNaturalName» in a persistence store.
			/// </summary>
			public interface I«entity.name»Manager : IManagerBase<«entity.name»>
			{
				«FOR attribute : entity.attributes.filter(a | a.unique)»
					/// <summary>
					/// Returns a single «entity.name.toNaturalName» with the given «attribute.name.toNaturalName»
					/// </summary>
					/// <param name="«attribute.toParameterName»">«attribute.name.toNaturalName» of the «entity.name.toNaturalName»</param>
					/// <returns>A «entity.name.toNaturalName»</returns>
					Task<«entity.name»> FindBy«attribute.toPropertyName»Async(«attribute.toParameterDeclaration»);

				«ENDFOR»
				«IF entity.hasUnique»
					/// <summary>
					/// Validates the insertion of the given entity in the persistence store.
					/// </summary>
					/// <param name="«entity.toParameterName»">The entity to validate</param>
					/// <returns>List of validation errors</returns>
					Task<IEnumerable<ValidationResult>> ValidateAdd(«entity.toParameterDeclaration»);

				«ENDIF»
				«IF entity.isReferenced»
				    /// <summary>
				    /// Validates the deletion of the given entity in the persistence store.
				    /// </summary>
				    /// <param name="«entity.toParameterName»">The entity to validate</param>
				    /// <returns>List of validation errors</returns>
				    Task<IEnumerable<ValidationResult>> ValidateRemove(«entity.toParameterDeclaration»);

				«ENDIF»
				«IF entity.hasUnique»
				    /// <summary>
				    /// Validates the update of the given entity in the persistence store.
				    /// </summary>
				    /// <param name="«entity.toParameterName»">The entity to validate</param>
				    /// <returns>List of validation errors</returns>
				    Task<IEnumerable<ValidationResult>> ValidateUpdate(«entity.toParameterDeclaration»);
				«ENDIF»
			}
		}'''	
 	
	def generateManagerContent(Entity entity)'''
		using System;
		using System.Collections.Generic;
		using System.ComponentModel.DataAnnotations;
		using System.Linq;
		using System.Text;
		using System.Threading.Tasks;
		using Microsoft.EntityFrameworkCore;
		using Microsoft.Extensions.Logging;
		using «this.namespace».Entities;
		
		namespace «this.namespace».Managers.EntityFramework
		{
		    /// <summary>
		    /// Provides the APIs for managing «entity.name.toNaturalName» in a persistence store.
		    /// </summary>
		    public class «entity.name»Manager : ManagerBase<«entity.name»>, I«entity.name»Manager
		    {
				/// <summary>
				/// Creates an instance.
				/// </summary>
				/// <param name="context">Access to entity storage</param>
				/// <param name="logger">Logging interface</param>
		        public «entity.name»Manager(EntityContext context, ILogger<«entity.name»Manager> logger) 
		            : base(context, logger)
		        {
		        }

				«FOR attribute : entity.attributes.filter(a | a.unique)»
					/// <summary>
					/// Returns a single «entity.name.toNaturalName» with the given «attribute.name.toNaturalName»
					/// </summary>
					/// <param name="«attribute.toParameterName»">«attribute.name.toNaturalName» of the «entity.name.toNaturalName»</param>
					/// <returns>A «entity.name.toNaturalName»</returns>
					public async Task<«entity.name»> FindBy«attribute.toPropertyName»Async(«attribute.toParameterDeclaration»)
					{
					    return await Context.«entity.name»s
					        .Where(«entity.toShortName» => «entity.toShortName».«attribute.toPropertyName» == «attribute.toParameterName»)
					        .SingleOrDefaultAsync();
					}

				«ENDFOR»
				«IF entity.hasUnique»
					/// <summary>
					/// Validates the insertion of the given entity in the persistence store.
					/// </summary>
					/// <param name="«entity.toParameterName»">The entity to validate</param>
					/// <returns>List of validation errors</returns>
					public Task<IEnumerable<ValidationResult>> ValidateAdd(«entity.toParameterDeclaration»)
					{
						return ValidateUpdate(«entity.toParameterName»);
					}

				«ENDIF»
				«IF isReferenced(entity)»
					/// <summary>
					/// Validates the deletion of the given entity in the persistence store.
					/// </summary>
					/// <param name="«entity.toParameterName»">The entity to validate</param>
					/// <returns>List of validation errors</returns>
					public async Task<IEnumerable<ValidationResult>> ValidateRemove(«entity.toParameterDeclaration»)
					{
						var results = new List<ValidationResult>();
					
						«FOR attribute : getReferencingAttributes(entity)»
							«var referencing = getEntity(attribute)»	
							if (await Context.«referencing.name»s.AnyAsync(«referencing.toShortName» => «referencing.toShortName».«attribute.name»Id == «entity.toParameterName».Id))
							{
							    results.Add("This «entity.name.toNaturalName» is referenced by a «referencing.name.toNaturalName»");
							}
							
						«ENDFOR»
						return results;
					}

				«ENDIF»
				«IF entity.hasUnique»
					/// <summary>
					/// Validates the update of the given entity in the persistence store.
					/// </summary>
					/// <param name="«entity.toParameterName»">The entity to validate</param>
					/// <returns>List of validation errors</returns>
					public async Task<IEnumerable<ValidationResult>> ValidateUpdate(«entity.toParameterDeclaration»)
					{
					    var results = new List<ValidationResult>();
					
						«FOR attribute : entity.attributes.filter(a | a.unique)»
							if (await Context.«entity.name»s.AnyAsync(«entity.toShortName» => «entity.toShortName».«attribute.toPropertyName» == «entity.toParameterName».«attribute.toPropertyName» && «entity.toShortName».Id != «entity.toParameterName».Id))
							{
							    results.Add("A «entity.name.toNaturalName» with the same «attribute.name.toNaturalName» already exists.", "«attribute.toPropertyName»");
							}
							
						«ENDFOR»
						return results;
					}
				«ENDIF»
		    }
		}'''
		
	def generateManagerBaseContent()'''
		using System;
		using System.Collections.Generic;
		using System.Threading.Tasks;
		using Microsoft.EntityFrameworkCore;
		using Microsoft.Extensions.Logging;
		
		namespace «this.namespace».Managers.EntityFramework
		{
		    /// <summary>
		    /// Provides basic APIs for managing the entity T in a persistence store.
		    /// </summary>
		    /// <typeparam name="T">The entity type to manage</typeparam>
		    public class ManagerBase<T> : IManagerBase<T>
			    where T: class
			{
		        /// <summary>
		        /// Creates a new instance.
		        /// </summary>
		        /// <param name="context"></param>
		        /// <param name="logger"></param>
			    public ManagerBase(EntityContext context, ILogger logger)
			    {
			        Context = context;
		            Logger = logger;
			    }
		
		        /// <summary>
		        /// Gets the entity context
		        /// </summary>
		        protected EntityContext Context { get; }
		
		        /// <summary>
		        /// Gets the logger
		        /// </summary>
		        protected ILogger Logger { get; }
		
		        /// <summary>
		        /// Adds the given entity to storage.
		        /// </summary>
		        /// <param name="entity">The entity to add.</param>
		        public virtual async Task AddAsync(T entity)
		        {
		            await Context.AddAsync(entity);
		            await Context.SaveChangesAsync();
		        }
		
		        /// <summary>
		        /// Returns all entities from storage.
		        /// </summary>
		        /// <returns>all entities, empty list if nothing found</returns>
		        public virtual async Task<IEnumerable<T>> FindAllAsync()
			    {
			        return await Context.Set<T>().ToListAsync();
			    }
		
		        /// <summary>
		        /// Finds an entity with the given primary key values.
		        /// </summary>
		        /// <param name="keyValues">The values of the primary key for the entity to be found.</param>
		        /// <returns>the found entity, null otherwise</returns>
		        public virtual async Task<T> FindAsync(object[] keyValues)
			    {
			        return await Context.FindAsync<T>(keyValues);
			    }
		
		        /// <summary>
		        /// Removes the given entity from storage.
		        /// </summary>
		        /// <param name="entity">The entity to remove</param>
		        /// <returns>false if the entity was not found</returns>
		        public virtual async Task<bool> RemoveAsync(T entity)
			    {
			        Context.Remove(entity);
		
		            try
		            {
		                await Context.SaveChangesAsync();
		            }
		            catch (DbUpdateConcurrencyException ex)
		            {
		                Logger.LogError(ex, ex.Message);
		
		                return false;
		            }
		
		            return true;
			    }
		
		        /// <summary>
		        /// Updates the given entity in storage.
		        /// </summary>
		        /// <param name="entity">The entity to update</param>
		        /// <returns>false if the entity was not found</returns>
		        public virtual async Task<bool> UpdateAsync(T entity)
			    {            
			        Context.Update(entity);
		
		            try
		            {
		                await Context.SaveChangesAsync();
		            }
		            catch (DbUpdateConcurrencyException ex)
		            {
		                Logger.LogError(ex, ex.Message);
		
		                return false;
		            }

		            return true;
			    }
			}
		}
		'''

	def generateIManagerBaseContent()'''
		using System.Collections.Generic;
		using System.Threading.Tasks;
		
		namespace «this.namespace».Managers
		{
		    /// <summary>
		    /// Provides basic APIs for managing entites.
		    /// </summary>
		    /// <typeparam name="T"></typeparam>
		    public interface IManagerBase<T>
		    {
		        /// <summary>
		        /// Adds the given entity to storage.
		        /// </summary>
		        /// <param name="entity">The entity to add.</param>
		        Task AddAsync(T entity);
		
		        /// <summary>
		        /// Returns all entities from storage.
		        /// </summary>
		        /// <returns>all entities, empty list if nothing found</returns>
				Task<IEnumerable<T>> FindAllAsync();
		
		        /// <summary>
		        /// Finds an entity with the given primary key values.
		        /// </summary>
		        /// <param name="keyValues">The values of the primary key for the entity to be found.</param>
		        /// <returns>the found entity, null otherwise</returns>
		        Task<T> FindAsync(params object[] keyValues);
		
		        /// <summary>
		        /// Removes the given entity from storage.
		        /// </summary>
		        /// <param name="entity">The entity to remove</param>
		        /// <returns>false if the entity was not found</returns>
		        Task<bool> RemoveAsync(T entity);
		
		        /// <summary>
		        /// Updates the given entity in storage.
		        /// </summary>
		        /// <param name="entity">The entity to update</param>
		        /// <returns>false if the entity was not found</returns>
				Task<bool> UpdateAsync(T entity);
		    }
		}'''
		
	def generateEntityContextContent(Iterable<Entity> entities)'''
		using Microsoft.EntityFrameworkCore;
		using «this.namespace».Entities;
		
		namespace «this.namespace».Managers.EntityFramework
		{
		    public class EntityContext : MyIdentityDbContext
		    {
		        public EntityContext(DbContextOptions<EntityContext> options)
		            : base(options)
		        { }

		        «FOR entity : entities»
		        public DbSet<«entity.name»> «entity.name»s { get; set; }
		        «ENDFOR»
		        
		        protected override void OnModelCreating(ModelBuilder modelBuilder)
		        {
		        	base.OnModelCreating(modelBuilder);
		        	
		        	«FOR entity : entities.withCompositeKey»
		        	modelBuilder.Entity<«entity.name»>()
		        		.HasKey(«entity.toShortName» => new { «FOR attribute : entity.key SEPARATOR ", "»«entity.toShortName».«attribute.toPropertyName»«ENDFOR» });
		            «ENDFOR»
		        }
		    }
		}'''
		
	def generateDependencyInjectionSetup(Iterable<Entity> entities)'''
		using Microsoft.Extensions.DependencyInjection;
		using «this.namespace».Managers.EntityFramework;
		
		namespace «this.namespace».Managers
		{
		    /// <summary>
		    /// Adds services the dependency injection
		    /// </summary>
		    public static class DependencyInjectionSetup
		    {
		        /// <summary>
		        /// Add entity managers to the dependency injection
		        /// </summary>
		        /// <param name="services">service collection</param>
		        /// <returns>service collection</returns>
		        public static IServiceCollection AddEntityManagers(this IServiceCollection services)
		        {
			        «FOR entity : entities»
			        services.AddTransient<I«entity.name»Manager, «entity.name»Manager>();
			        «ENDFOR»

				    return services;
				}
			}
		}'''
}