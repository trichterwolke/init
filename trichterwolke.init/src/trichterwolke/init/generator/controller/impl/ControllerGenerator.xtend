package trichterwolke.init.generator.controller.impl

import com.google.inject.Inject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import trichterwolke.init.generator.GeneratorBase
import trichterwolke.init.generator.ICSharpGenerator
import trichterwolke.init.generator.IModelHelper
import trichterwolke.init.generator.controller.IControllerGenerator
import trichterwolke.init.init.Entity

class ControllerGenerator extends GeneratorBase implements IControllerGenerator {					
	
	@Inject
	extension IModelHelper	
	
	@Inject
	extension ICSharpGenerator
					
	override doGenerate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context) {
		super.doGenerate(input, fsa, context);
		
		var startup = generateStartup(input.allContents.filter(Entity).toList);
		this.fsa.generateFile('''«this.namespace»/Startup.txt''', startup);
				
	    input.allContents.filter(Entity).forEach[generateFile];		   
	}
	
	def generateFile(Entity entity) {
		this.fsa.generateFile('''«this.namespace»/Controllers/«entity.name»Controller.cs''', generateContent(entity));
	}
				
	def generateContent(Entity entity)'''
		using System;
		using System.Collections.Generic;
		using System.Threading.Tasks;
		using Microsoft.AspNetCore.Authorization;
		using Microsoft.AspNetCore.Mvc;
		using Trichterwolke.Sisyphus.Entities;
		using Trichterwolke.Sisyphus.Managers;
		
		namespace «this.namespace».Controller 
		{   
		    /// <summary>
		    /// Rest Api controller for «entity.name.toNaturalName».
		    /// </summary>
			[Authorize]
			[ApiController]
			[Route("api/[controller]")]
			public class «entity.name»Controller : ControllerBase
			{
				private readonly I«entity.name»Manager «entity.toFieldName»Manager;

				/// <summary>
				/// Creates an instance of the class.
				/// </summary>
				/// <param name="employeeManager"></param>
				public «entity.name»Controller(I«entity.name»Manager «entity.toParameterName»Manager)
				{
				    «entity.toFieldName»Manager = «entity.toParameterName»Manager;
				}
		
				/// <summary>
		        /// Returns all «entity.name.toNaturalName»s.
		        /// </summary>
		        /// <returns>All «entity.name.toNaturalName»s.</returns>
				[HttpGet]
				public async Task<ActionResult<IEnumerable<«entity.name»>>> FindAll()
				{
					var result = await «entity.toFieldName»Manager.FindAllAsync();
				    return Ok(result);
				}
		
				/// <summary>
		        /// Returns the «entity.name.toNaturalName» with the given id.
		        /// </summary>
		        /// <param name="id">Primary key of the «entity.name.toNaturalName»</param>
		        /// <returns>The «entity.name.toNaturalName» with the given id</returns>
				[HttpGet("«generateHttpParameters(entity)»")]
				public async Task<ActionResult<«entity.name»>> Find(«generateParametersDeclaration(entity)»)
				{
					var result = await «entity.toFieldName»Manager.FindAsync(«generateParameters(entity)»);
					
					if (result == null)
					{
					    return NotFound();
					}
					else
					{
					    return Ok(result);
					}
				}
		
				/// <summary>
				/// Inserts a «entity.name.toNaturalName».
				/// </summary>
				/// <param name="«entity.toParameterName»">The «entity.name.toNaturalName» to insert</param>
				/// <returns>The id of the «entity.name.toNaturalName»</returns>
				[HttpPost]
				public async Task<ActionResult«IF !entity.hasCustomKey»<int?>«ENDIF»> Insert([FromBody] «entity.name» «entity.toParameterName»)
				{
					await «entity.toFieldName»Manager.InsertAsync(«entity.toParameterName»);
				    return Ok(«IF !entity.hasCustomKey»«entity.toParameterName».Id«ENDIF»);
				}
		
		        /// <summary>
		        /// Updates the «entity.name.toNaturalName» with the given id.
		        /// </summary>
		        /// <param name="id">Primary key of the «entity.name.toNaturalName»</param>
		        /// <param name="«entity.toParameterName»">The «entity.name.toNaturalName» to updade</param>
				[HttpPut("«generateHttpParameters(entity)»")]
				public async Task<ActionResult> Update(«generateParametersDeclaration(entity)», [FromBody] «entity.name» «entity.toParameterName»)
				{
					«generatePropertyAssignment(entity)»

				    await «entity.toFieldName»Manager.UpdateAsync(«entity.toParameterName»);
				    return Ok();
				}

		        /// <summary>
		        /// Deletes the «entity.name.toNaturalName» with the given id.
		        /// </summary>
		        /// <param name="id">Primary key of the «entity.name.toNaturalName»</param>
				[HttpDelete("«generateHttpParameters(entity)»")]
				public async Task<ActionResult> Delete(«generateParametersDeclaration(entity)»)
				{
				    await «entity.toFieldName»Manager.DeleteAsync(«generateParameters(entity)»);
				    return Ok();
				}
			}
		}'''
	
		
	def generateHttpParameters(Entity entity)
    	'''«FOR key : entity.key SEPARATOR "/"»{«key.toParameterName»}«ENDFOR»'''
	
	def generatePropertyAssignment(Entity entity)'''		
		«IF entity.hasCustomKey» 
			«FOR attribute : entity.key»	
				«IF attribute.isReference»
					«entity.name.toFirstLower».«attribute.name»Id = «attribute.name.toFirstLower»Id;
				«ELSE»
					«entity.name.toFirstLower».«attribute.name» = «attribute.name.toFirstLower»;
				«ENDIF»				
			«ENDFOR»
		«ELSE»
			«entity.toParameterName».Id = id;
		«ENDIF»
	'''
	
	def generateStartup(Iterable<Entity> entities)'''
		using Microsoft.Extensions.DependencyInjection;
		using Trichterwolke.Sisyphus.Dal;
		using Trichterwolke.Sisyphus.Dal.Dapper;
		using Trichterwolke.Sisyphus.Managers;
		using Trichterwolke.Sisyphus.Managers.EntityFramework;
		
		public class Startup
		{
		    public void ConfigureServices(IServiceCollection services)
		    {
		    	// add this ...
		        «FOR entity : entities»
		        services.AddTransient<I«entity.name»Dal, «entity.name»Dal>();
		        «ENDFOR»
		        
		        // or this to your Startup class
		        «FOR entity : entities»
		        services.AddTransient<I«entity.name»Manager, «entity.name»Manager>();
		        «ENDFOR»
		    }
		}'''	
}
