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
		using Trichterwolke.Sisyphus.Dal;
		using Trichterwolke.Sisyphus.Entities;
		
		namespace «this.namespace».Controller 
		{   
			[Route("api/[controller]")]
			[ApiController]
			public class «entity.name»Controller : ControllerBase
			{
				private readonly I«entity.name»Dal _«entity.name.toFirstLower»Dal;
				
				public «entity.name»Controller(I«entity.name»Dal «entity.name.toFirstLower»Dal)
				{
				    _«entity.name.toFirstLower»Dal = «entity.name.toFirstLower»Dal;
				}
		
				[HttpGet]
				public async Task<ActionResult<IEnumerable<«entity.name»>>> FindAll()
				{
				    return Ok(await _«entity.name.toFirstLower»Dal.FindAllAsync());
				}
		
				// GET api/values/5
				[HttpGet("{id}")]
				public async Task<ActionResult<«entity.name»>> FindByID(int id)
				{
				    return Ok(await _«entity.name.toFirstLower»Dal.FindByIDAsync(id));
				}
		
				// POST api/values
				[HttpPost]
				public async Task<ActionResult<int?>> Insert([FromBody] «entity.name» «entity.name»)
				{
				    return Ok(await _«entity.name.toFirstLower»Dal.InsertAsync(«entity.name»));
				}
		
				// PUT api/values/5
				[HttpPut("{id}")]
				public async Task Update(int id, [FromBody] «entity.name» «entity.name»)
				{
				    await _«entity.name.toFirstLower»Dal.UpdateAsync(«entity.name»);
				}

				// DELETE api/values/5
				[HttpDelete("{id}")]
				public async Task Delete(int id)
				{
				    await _«entity.name.toFirstLower»Dal.DeleteAsync(id);
				}
			}
		}'''
	
	
	def generateStartup(Iterable<Entity> entities)'''
		using Microsoft.Extensions.DependencyInjection;
		using Trichterwolke.Sisyphus.Dal;
		using Trichterwolke.Sisyphus.Dal.Dapper;
		
		public class Startup
		{
		    public void ConfigureServices(IServiceCollection services)
		    {
		    	// add this to your Startup class
		        «FOR entity : entities»
		        services.AddTransient<I«entity.name»Dal, «entity.name»Dal>();
		        «ENDFOR»
		    }
		}'''	
}
