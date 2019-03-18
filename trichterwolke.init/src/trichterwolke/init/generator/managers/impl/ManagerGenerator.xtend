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
		this.fsa.generateFile('''src/«this.namespace».Managers/ValidationResultExtensions.cs''', generateValidationResultExtensions());	
		
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
					Task<IEnumerable<ValidationResult>> ValidateCreateAsync(«entity.toParameterDeclaration»);

				«ENDIF»
				«IF entity.isReferenced»
				    /// <summary>
				    /// Validates the deletion of the given entity in the persistence store.
				    /// </summary>
				    /// <param name="«entity.toParameterName»">The entity to validate</param>
				    /// <returns>List of validation errors</returns>
				    Task<IEnumerable<ValidationResult>> ValidateDeleteAsync(«entity.toParameterDeclaration»);

				«ENDIF»
				«IF entity.hasUnique»
				    /// <summary>
				    /// Validates the update of the given entity in the persistence store.
				    /// </summary>
				    /// <param name="«entity.toParameterName»">The entity to validate</param>
				    /// <returns>List of validation errors</returns>
				    Task<IEnumerable<ValidationResult>> ValidateUpdateAsync(«entity.toParameterDeclaration»);
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
				/// Initializes a new instance of the class
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
					public Task<IEnumerable<ValidationResult>> ValidateCreateAsync(«entity.toParameterDeclaration»)
					{
						return ValidateUpdateAsync(«entity.toParameterName»);
					}

				«ENDIF»
				«IF isReferenced(entity)»
					/// <summary>
					/// Validates the deletion of the given entity in the persistence store.
					/// </summary>
					/// <param name="«entity.toParameterName»">The entity to validate</param>
					/// <returns>List of validation errors</returns>
					public async Task<IEnumerable<ValidationResult>> ValidateDeleteAsync(«entity.toParameterDeclaration»)
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
					public async Task<IEnumerable<ValidationResult>> ValidateUpdateAsync(«entity.toParameterDeclaration»)
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
		        public virtual async Task<T> FindByIdAsync(object[] keyValues)
			    {
			        return await Context.FindAsync<T>(keyValues);
			    }
		
		        /// <summary>
		        /// Removes the given entity from storage.
		        /// </summary>
		        /// <param name="entity">The entity to remove</param>
		        /// <returns>false if the entity was not found</returns>
		        public virtual async Task<bool> DeleteAsync(T entity)
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
		        Task CreateAsync(T entity);
		
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
		        Task<T> FindByIdAsync(params object[] keyValues);
		
		        /// <summary>
		        /// Removes the given entity from storage.
		        /// </summary>
		        /// <param name="entity">The entity to remove</param>
		        /// <returns>false if the entity was not found</returns>
		        Task<bool> DeleteAsync(T entity);
		
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
			/// <summary>
			/// A EntityContext instance represents a session with the database and can be used to
			/// query and save instances of your entities.
			/// </summary>			
		    public class EntityContext : CustomIdentityDbContext
		    {
				/// <summary>
				/// Initializes a new instance of the entity context.
				/// </summary>
				/// <param name="options">The options to be used by a DbContext.</param>
		        public EntityContext(DbContextOptions<EntityContext> options)
		            : base(options)
		        {
		        }
				«FOR entity : entities»

					/// <summary>
					/// Provides access to the «entity.name.toNaturalName» table.
					/// </summary>
					public DbSet<«entity.name»> «entity.name»s { get; set; }
				«ENDFOR»
		
				/// <summary>
				/// Configures the context for the database schema.
				/// </summary>
				/// <param name="modelBuilder">The builder being used to construct the model for this context.</param>
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
		
	def generateValidationResultExtensions()'''
		using System;
		using System.Collections.Generic;
		using System.ComponentModel.DataAnnotations;
		using System.Text;
		
		namespace «this.namespace».Managers.EntityFramework
		{
		    /// <summary>
		    /// Extension methods for a ValidationResult collection
		    /// </summary>
		    public static class ValidationResultExtentions
		    {
		        /// <summary>
		        /// Adds error messages the ValidationResult collection
		        /// </summary>
		        /// <param name="validationResults">Collection to which the elements are to be added.</param>
		        /// <param name="errorMessage">The error messessage to be added.</param>
		        /// <param name="memberNames">The collection of member names that indicate which fields have validation errors.</param>
		        public static void Add(this ICollection<ValidationResult> validationResults, string errorMessage, params string[] memberNames)
		        {
		            validationResults.Add(new ValidationResult(errorMessage, memberNames));
		        }
		    }
		}'''	
}