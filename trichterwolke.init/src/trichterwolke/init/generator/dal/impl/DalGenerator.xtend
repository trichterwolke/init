package trichterwolke.init.generator.dal.impl

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import trichterwolke.init.generator.GeneratorBase
import trichterwolke.init.init.Entity

class DalGenerator extends GeneratorBase /*implements IDalGenerator*/ {					
	override doGenerate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context) {
		super.doGenerate(input, fsa, context);
				
		this.fsa.generateFile('''src/«this.namespace».Dal/ICrudDal.cs''', generateICrudDalContent());
		this.fsa.generateFile('''src/«this.namespace».Dal/Dapper/CrudDalBase.cs''', generateCrudDalBaseContent());		
		this.fsa.generateFile('''src/«this.namespace».Dal/IDbConnectionFactory.cs''', generateConnectionFactoryInterfaceContent());
		this.fsa.generateFile('''src/«this.namespace».Dal/Dapper/NpgsqlConnectionFactory.cs''', generateConnectionFactoryContent());		
		
	    input.allContents.filter(Entity).forEach[generateFile];		  
	}
	
	def generateFile(Entity entity) {
		this.fsa.generateFile('''src/«this.namespace».Dal/I«entity.name»Dal.cs''', generateDalInterfaceContent(entity));
		this.fsa.generateFile('''src/«this.namespace».Dal/Dapper/«entity.name»Dal.cs''', generateDalContent(entity));
	}
				
	def generateDalInterfaceContent(Entity entity)'''
		using System;
		using Trichterwolke.Sisyphus.Entities;
		
		namespace «this.namespace».Dal
		{			
			public interface I«entity.name»Dal : ICrudDal<«entity.name»>
			{
			}
		}'''				
				
	def generateDalContent(Entity entity)'''
		using System;
		using Trichterwolke.Sisyphus.Entities;
		
		namespace «this.namespace».Dal.Dapper
		{			
			public class «entity.name»Dal : CrudDalBase<«entity.name»>, I«entity.name»Dal
			{
		        public «entity.name»Dal(IDbConnectionFactory connectionFactory) 
		            : base(connectionFactory)
		        {
		        }
			}
		}'''
		
	def generateCrudDalBaseContent()'''
		using System.Collections.Generic;
		using System.Linq;
		using System.Threading.Tasks;
		using Dapper;
		
		namespace «this.namespace».Dal.Dapper
		{		
		    public abstract class CrudDalBase<T> : ICrudDal<T>
		    {
		    	private static readonly string TableName = GetTableName();
		    	
		        public CrudDalBase(IDbConnectionFactory connectionFactory)
		        {
		            ConnectionFactory = connectionFactory;
		        }
		
				public IDbConnectionFactory ConnectionFactory { get; }
		
		        protected virtual string FindByIDCommandText => $"SELECT * FROM {TableName} WHERE id=@id";
		
		        protected virtual string FindByAllCommandText => $"SELECT * FROM {TableName}";
		
		        protected virtual string DeleleCommandText => $"DELETE FROM {TableName} WHERE id=@id";			
		
		        public virtual async Task<T> FindByIDAsync(int id)
		        {
		            using (var connection = ConnectionFactory.Create())
		            {
		                return await connection.QueryFirstOrDefaultAsync<T>(FindByIDCommandText, new { id });
		            }
		        }
		
		        public async virtual Task<IEnumerable<T>> FindAllAsync()
		        {
		            using (var connection = ConnectionFactory.Create())
		            {
		                return await connection.QueryAsync<T>(FindByAllCommandText);
		            }
		        }
		
		        public virtual async Task<int?> InsertAsync(T entity)
		        {
		            using (var connection = ConnectionFactory.Create())
		            {
		                return await connection.InsertAsync(entity);
		            }
		        }
		
		        public virtual async Task UpdateAsync(T entity)
		        {
		            using (var connection = ConnectionFactory.Create())
		            {
		                await connection.UpdateAsync(entity);
		            }
		        }
		
		        public virtual async Task DeleteAsync(int id)
		        {
		            using (var connciton = ConnectionFactory.Create())
		            {
		                await connciton.ExecuteAsync(DeleleCommandText, new { id });
		            }
		        }
		        
				private static string GetTableName()
				{
				    var attributes = typeof(T).GetCustomAttributes(typeof(TableAttribute), false);
				
				    if (attributes.Any())
				    {
				        return ((TableAttribute)attributes.First()).Name;
				    }
				
				    return "(TableAttribute not found)";
				}
		    }
		}'''
	
	def generateICrudDalContent()'''
		using System.Collections.Generic;
		using System.Threading.Tasks;
		
		namespace «this.namespace».Dal
		{
		    public interface ICrudDal<T>
		    {
		        Task DeleteAsync(int id);
		        Task<IEnumerable<T>> FindAllAsync();
		        Task<T> FindByIDAsync(int id);
		        Task<int?> InsertAsync(T entity);
		        Task UpdateAsync(T entity);
		    }
		}'''
	
	def generateConnectionFactoryInterfaceContent()'''
		using System.Data;
		
		namespace «this.namespace».Dal
		{
		    public interface IDbConnectionFactory
		    {
		        IDbConnection Create();
		    }
		}'''
	
	def generateConnectionFactoryContent()'''
		using Dapper;
		using Npgsql;
		using System.Data;
		
		namespace «this.namespace».Dal.Dapper
		{
		    public class NpgsqlConnectionFactory : IDbConnectionFactory
		    {
		        private readonly string _connectionString;  
		
		        static NpgsqlConnectionFactory()
		        {
		            DefaultTypeMap.MatchNamesWithUnderscores = true;
		            SimpleCRUD.SetDialect(SimpleCRUD.Dialect.PostgreSQL);
		        }
		
		        public NpgsqlConnectionFactory(string connectionString)
		        {
		            _connectionString = connectionString;
		        }
		
		        public IDbConnection Create()
		        {
		            return new NpgsqlConnection(_connectionString);
		        }
		    }
		}'''
}