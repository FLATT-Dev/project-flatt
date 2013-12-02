package CustomControls
{
	
	import com.ZG.Utility.*;
	
	import mx.validators.*;
	
	import spark.components.TextInput;
	
	public class FT_IpAddressValidator extends Validator
	{
		private var m_IpStart:TextInput;
		private var m_IpEnd:TextInput;
	
		
		public function FT_IpAddressValidator()
		{
			
			super();
		}
		//-------------------------
		public function SetIpAddrInput(addrStart:TextInput,addrEnd:TextInput):void
		{
			m_IpStart = addrStart;
			m_IpEnd = addrEnd;
		}
		//---------------------------------------
		// Class should override the doValidation() method.
		//doValidation method should accept an Object type parameter
		override protected function doValidation(value:Object):Array {
			// create an array to return.
			var validatorResults:Array = new Array();
			// Call base class doValidation().
			validatorResults = super.doValidation(value);       
			// Return if there are errors.
			if (validatorResults.length > 0)
			{
				return validatorResults;
			}
			
			if (String(value).length == 0)
			{
				return validatorResults;
			}
		
			// easy cases 
			
			
			if(!ZG_URLValidator.ValidIP(String(value)))
			{
				validatorResults.push(new ValidationResult(true, null, "Error",
														  "Please enter a valid dotted decimal IP Address"));
			}
			else
			{
				// address is valid - check if start < end
				var startIP: uint = ZG_StringUtils.IpToHex(m_IpStart.text);
				var endIP:uint =  ZG_StringUtils.IpToHex(m_IpEnd.text);
				
				if(startIP > endIP)
				{
					validatorResults.push(new ValidationResult(true, null, "Error",
															"End IP address must be greater than start IP"));
				}
				
			}
			return validatorResults;
		}
	}
}