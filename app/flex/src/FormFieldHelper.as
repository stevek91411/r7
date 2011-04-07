package {
	import mx.validators.Validator;
	import flash.display.DisplayObject;
	import mx.core.UIComponent 

	public class FormFieldHelper
	{
		public var id:String
		public var  validator:Validator
		public var defaultValue:String
		
		public function FormFieldHelper( _id:String, _validator:Validator, _defaultValue:String= "" ) {
			id = _id
			validator = _validator
			defaultValue =_defaultValue	
		}
		
		public function getUIComponent():UIComponent {
			return validator.source as UIComponent			
		}

	}
}