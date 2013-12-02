package CustomControls
{
	import HostConfiguration.*;
	
	import com.ZG.Utility.*;
	
	import mx.managers.ToolTipManager;
	import mx.validators.*;
	
	import spark.components.TextInput;
	
	public class FT_HostConfigNameValidator extends Validator
	{
		protected var _itemName:String;
		protected var _savedState:Boolean = true;
		
		public function FT_HostConfigNameValidator()
		{
			super();
			
		}
		//------------------------------------------------
		override protected function doValidation(value:Object):Array
		{
			// create an array to return.
			var validatorResults:Array = new Array();
			// Call base class doValidation().
			validatorResults = super.doValidation(value);  
			var strVal:String = value as String;
			// Return if there are errors.
			if (validatorResults.length > 0)
			{
				return validatorResults;
			}
			
			if (strVal.length == 0)
			{
				return validatorResults;
			}
			
			// see if the name is valid
			
			if (ContainsInvalidCharacter(strVal))
			{
				validatorResults.push(new ValidationResult(true, null, "Error",
									"Name contains invalid characters. Please choose another name"));
			}
			else
			{		
				//see if the name is taken
				var configItem:FT_HostConfig = FT_HostConfigManager.GetInstance().FindByName(strVal);
				if(configItem!=null && configItem.name!=itemName)
				{
					
					validatorResults.push(new ValidationResult(true, null, "Error",
										"This name is already taken. Please choose another name"));
				}
			}
			
			return validatorResults;
		}
		//-------------------------------
		//Brain dead replacement to regexp.
		private function ContainsInvalidCharacter(strVal:String):Boolean
		{
			return (strVal.indexOf("/")>=0 ||
					strVal.indexOf("\\")>=0 ||
					strVal.indexOf(":")>=0 ||
					strVal.indexOf("@")>=0 ||
					strVal.indexOf("?")>=0 ||
					strVal.indexOf("*")>=0 ||
					strVal.indexOf(">")>=0 ||
					strVal.indexOf("<")>=0 ||
					strVal.indexOf("|")>=0 ||
					strVal.indexOf("\"")>=0 );				
		}
		//------------------------------------------------
		public function get itemName():String
		{
			return _itemName;
		}
		//------------------------------------------------
		public function set itemName(value:String):void
		{
			_itemName = value;
		}

		public function get savedState():Boolean
		{
			return _savedState;
		}

		public function set savedState(value:Boolean):void
		{
			_savedState = value;
		}


	}
	//-------------------------------------------------------
}