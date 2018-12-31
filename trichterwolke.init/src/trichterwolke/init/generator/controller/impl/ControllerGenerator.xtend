package trichterwolke.init.generator.controller.impl

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import trichterwolke.init.generator.GeneratorBase
import trichterwolke.init.generator.controller.IControllerGenerator
import trichterwolke.init.init.Entity

class ControllerGenerator extends GeneratorBase implements IControllerGenerator {					
					
	override doGenerate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context) {
		super.doGenerate(input, fsa, context);
		
		var startup = generateStartup(input.allContents.filter(Entity).toList);
		this.fsa.generateFile('''«this.namespace»/Startup.copyandpaste.cs''', startup);
				
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
				[HttpGet("{id}")]
				public async Task<ActionResult<«entity.name»>> FindByID(int id)
				{
					var result = await «entity.name»Service.FindByIDAsync(id);
					
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
				public async Task<ActionResult<int?>> Insert([FromBody] «entity.name» «entity.name»)
				{
					await «entity.name»Service.InsertAsync(«entity.name»);
				    return Ok(«entity.name».ID);
				}
		
				// PUT api/values/5
				[HttpPut("{id}")]
				public async Task<ActionResult> Update(int id, [FromBody] «entity.name» «entity.name»)
				{
					«entity.name».ID = id;
				    await «entity.name»Service.UpdateAsync(«entity.name»);
				    return Ok();
				}

				// DELETE api/values/5
				[HttpDelete("{id}")]
				public async Task<ActionResult> Delete(int id)
				{
				    await «entity.name»Service.DeleteAsync(id);
				    return Ok();
				}
			}
		}'''
	
	
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
