/*
 * generated by Xtext 2.15.0
 */
package trichterwolke.init

import com.google.inject.Binder
import trichterwolke.init.generator.CSharpTypeGenerator
import trichterwolke.init.generator.IEnumerationGenerator
import trichterwolke.init.generator.IModelHelper
import trichterwolke.init.generator.ITypeGenerator
import trichterwolke.init.generator.ModelHelper
import trichterwolke.init.generator.controller.IControllerGenerator
import trichterwolke.init.generator.controller.impl.ControllerGenerator
import trichterwolke.init.generator.dal.IDalGenerator
import trichterwolke.init.generator.dal.impl.DalGenerator
import trichterwolke.init.generator.db.ICreateSchemaGenerator
import trichterwolke.init.generator.db.IDbGenerator
import trichterwolke.init.generator.db.IDropSchemaGenerator
import trichterwolke.init.generator.db.impl.CreateSchemaGenerator
import trichterwolke.init.generator.db.impl.DropSchemaGenerator
import trichterwolke.init.generator.db.impl.PostgresGenerator
import trichterwolke.init.generator.entities.IEntityGenerator
import trichterwolke.init.generator.entities.impl.EntityGenerator
import trichterwolke.init.generator.entities.impl.EnumerationGenerator

/**
 * Use this class to register components to be used at runtime / without the Equinox extension registry.
 */
class InitRuntimeModule extends AbstractInitRuntimeModule {
	
	override configure(Binder binder) {
		super.configure(binder);
		binder.bind(typeof(IModelHelper)).to(typeof(ModelHelper));
		
		binder.bind(typeof(IEntityGenerator)).to(typeof(EntityGenerator));
		binder.bind(typeof(IDalGenerator)).to(typeof(DalGenerator));
		binder.bind(typeof(ITypeGenerator)).to(typeof(CSharpTypeGenerator));
		binder.bind(typeof(IEnumerationGenerator)).to(typeof(EnumerationGenerator));
		binder.bind(typeof(IControllerGenerator)).to(typeof(ControllerGenerator));
		
		binder.bind(typeof(ICreateSchemaGenerator)).to(typeof(CreateSchemaGenerator));
		binder.bind(typeof(IDropSchemaGenerator)).to(typeof(DropSchemaGenerator));
		binder.bind(typeof(IDbGenerator)).to(typeof(PostgresGenerator));
	}	
}
