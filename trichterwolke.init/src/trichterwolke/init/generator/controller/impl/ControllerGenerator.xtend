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
		using Microsoft.AspNetCore.Mvc;
		using Trichterwolke.Sisyphus.Entities;
		using Trichterwolke.Sisyphus.Services;
		
		namespace «this.namespace».Controller 
		{   
			[Route("api/[controller]")]
			[ApiController]
			public class «entity.name»Controller : ControllerBase
			{
				public «entity.name»Controller(I«entity.name»Service «entity.name.toFirstLower»Service)
				{
				    «entity.name»Service = «entity.name.toFirstLower»Service;
				}

				private I«entity.name»Service «entity.name»Service { get; }
		
				[HttpGet]
				public async Task<ActionResult<IEnumerable<«entity.name»>>> FindAll()
				{
					var result = await «entity.name»Service.FindAllAsync();
				    return Ok(result);
				}
		
				// GET api/values/5
				[HttpGet("«generateHttpParameters(entity)»")]
				public async Task<ActionResult<«entity.name»>> Find(«generateParametersDeclaration(entity)»)
				{
					var result = await «entity.name»Service.FindAsync(«generateParameters(entity)»);
					
					if (result == null)
					{
					    return NotFound();
					}
					else
					{
					    return Ok(result);
					}
				}
		
				// POST api/values
				[HttpPost]
				public async Task<ActionResult«IF !entity.hasCustomKey»<int?>«ENDIF»> Insert([FromBody] «entity.name» «entity.toParameterName»)
				{
					await «entity.name»Service.InsertAsync(«entity.toParameterName»);
				    return Ok(«IF !entity.hasCustomKey»«entity.toParameterName».ID«ENDIF»);
				}
		
				// PUT api/values/5
				[HttpPut("«generateHttpParameters(entity)»")]
				public async Task<ActionResult> Update(«generateParametersDeclaration(entity)», [FromBody] «entity.name» «entity.toParameterName»)
				{
					«generatePropertyAssignment(entity)»

				    await «entity.name»Service.UpdateAsync(«entity.toParameterName»);
				    return Ok();
				}

				// DELETE api/values/5
				[HttpDelete("«generateHttpParameters(entity)»")]
				public async Task<ActionResult> Delete(«generateParametersDeclaration(entity)»)
				{
				    await «entity.name»Service.DeleteAsync(«generateParameters(entity)»);
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
					«entity.name.toFirstLower».«attribute.name»ID = «attribute.name.toFirstLower»ID;
				«ELSE»
					«entity.name.toFirstLower».«attribute.name» = «attribute.name.toFirstLower»;
				«ENDIF»				
			«ENDFOR»
		«ELSE»
			«entity.toParameterName».ID = id;
		«ENDIF»
	'''
	
	def generateStartup(Iterable<Entity> entities)'''
		using Microsoft.Extensions.DependencyInjection;
		using Trichterwolke.Sisyphus.Dal;
		using Trichterwolke.Sisyphus.Dal.Dapper;
		using Trichterwolke.Sisyphus.Services;
		using Trichterwolke.Sisyphus.Services.EntityFramework;
		
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
		        services.AddTransient<I«entity.name»Service, «entity.name»Service>();
		        «ENDFOR»
		    }
		}'''	
}
