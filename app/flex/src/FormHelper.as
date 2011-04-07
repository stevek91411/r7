package {
	import flash.display.DisplayObject;
	
	import mx.controls.TextInput;
	import mx.core.UIComponent;
	import mx.events.ValidationResultEvent;
	import mx.events.FlexEvent
	import flash.events.FocusEvent 
	import flash.events.Event

	import mx.managers.IFocusManager;
	import mx.validators.Validator;

	
	// see http://www.adobe.com/devnet/flex/quickstart/validating_data/
	
	[Bindable]
	public class FormHelper
	{
		
		[Bindable]
        public var formIsValid:Boolean = false;
        
        // Holds a reference to the currently focussed control on the form.
        private var focussedFormControl:DisplayObject;
        
		private var fieldHelpers:Array = new Array()
		private var focusManager:IFocusManager
		
		public function FormHelper(  _focusManager:IFocusManager ):void {
			focusManager = _focusManager
		}
		
		public function addValidator( ffh:FormFieldHelper ):void {
			fieldHelpers.push( ffh ) 
			ffh.validator.source.addEventListener( FlexEvent.ENTER, nextField);
		//	ffh.validator.source.addEventListener( Event.CHANGE, validateForm);

			var disObj:UIComponent = ffh.getUIComponent()
    		if ( disObj is TextInput ) {
    			disObj.addEventListener( FocusEvent.FOCUS_OUT, validateFormOnFocusOut);		
    		}
    		
   			if ( disObj is TextInput ) {
    			disObj.addEventListener( Event.CHANGE, validateFormOnFocusOut);		
    		}			
		}
		
		
		private function ValidateFormOnChange( event:Event ):void{
			// check the form when a user change the value of a field, the result may be that
			// the form is now valid  
			validateAllFields()
		}
				
		public function validateFormOnFocusOut( event:Event ):void{
			               
            // check the form when a user clicks out of a field   
 			for (var i:int = 0; i < fieldHelpers.length; ++i){
    			var ffh:FormFieldHelper = fieldHelpers[i];
    			var disObj:UIComponent = ffh.getUIComponent()
    			if ( disObj is TextInput ) {
					if ( TextInput(disObj).length > 0 && 
					!validate(ffh.validator )  )   					  						
						TextInput(disObj).setStyle( "backgroundColor", "0xff6c00" )
					else
					    TextInput(disObj).setStyle( "backgroundColor", "0xFFFFFF" )
    			} 						
    		}
    			  			
			validateAllFields() 
		}

		public function nextField( event:Event  ):void{
			   focusManager.setFocus( focusManager.getNextFocusManagerComponent())           
		}
				
		
		public function validateAllFields():Boolean {
			
			var foundInvalidField:Boolean =  false
			// Run each validator in turn, using the isValid() 
            // helper method and update the value of formIsValid
            // accordingly.
            for (var i:int = 0; i < fieldHelpers.length; ++i){
    			var ffh:FormFieldHelper = fieldHelpers[i];
    			if ( !validate(ffh.validator ) ) {
    				if ( !foundInvalidField ) {
    					foundInvalidField = true
    					formIsValid = false
   					} 				
    			}
    		}
    		
    		formIsValid = !foundInvalidField
    		return formIsValid
		}
		
		public function reset():void {
			for (var i:int = 0; i < fieldHelpers.length; ++i){
    			var ffh:FormFieldHelper = fieldHelpers[i];
    			var disObj:UIComponent = ffh.getUIComponent()
    			if ( disObj is TextInput ) {
					    TextInput(disObj).setStyle( "backgroundColor", "0xFFFFFF" )
					    TextInput(disObj).text = ffh.defaultValue
    			} 						
    		}
    		
			fieldHelpers = new Array()		
   		}
		
		
		// Helper method. Performs validation on a passed Validator instance.
         // Validator is the base class of all Flex validation classes so 
         // you can pass any validation class to this method.  
         private function validate(validator:Validator):Boolean
         {                
            // Get a reference to the component that is the source of the validator.
             var validatorSource:DisplayObject = validator.source as DisplayObject;
            
            // Suppress events if the current control being validated is not
            // the currently focussed control on the form. This stops the user
            // from receiving visual validation cues on other form controls.
            var suppressEvents:Boolean = false; //= (validatorSource != focussedFormControl);
            
            // Carry out validation. Returns a ValidationResultEvent.
            // Passing null for the first parameter makes the validator 
            // use the property defined in the property tag of the
            // <mx:Validator> tag.
            var event:ValidationResultEvent = validator.validate(null, suppressEvents); 
                            
            // Check if validation passed and return a boolean value accordingly.
             var currentControlIsValid:Boolean = (event.type == ValidationResultEvent.VALID);
             
             // Update the formIsValid flag
             formIsValid = formIsValid && currentControlIsValid;
             
             return currentControlIsValid;
          }
	}
}