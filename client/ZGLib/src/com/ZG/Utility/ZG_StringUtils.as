/*******************************************************************************
 * ZG_StringUtils.as
 * 
 * Copyright 2010-2013 Andrew Marder
 * heelcurve5@gmail.com
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
******************************************************************************/
package com.ZG.Utility
{
	import flash.utils.ByteArray;
	
	import mx.utils.*;
	
	public class ZG_StringUtils
	{
		public function ZG_StringUtils()
		{
		}
	
		/* Stolen from  the net
			http://www.koders.com/actionscript/fidB62CE65873479F421CC03AD1D0343F080F22A2D0.aspx 
		*/	
		
		public static function Sprintf( format: String, ... args ): String
		{
			var output: String = '';
			var byte: String;
			var list: Array = args;
						
			var i: int = 0;
			var n: int = format.length;
			var errorStart: int;
			var p:*;
			
			while ( i < n )
			{
				byte = format.charAt( i );
				
				if ( byte == '%' )
				{
					byte = format.charAt( ++i );
					
					if ( byte == '%' )
					{
						output += '%';
					}
					else
					{
						//-- reset locals
						p = null;
						
						//Format: %[flags][width][.precision][length]specifier  
						
						//-- flags
						var flagJustifyLeft	: Boolean = false;
						var flagSignForce	: Boolean = false;
						var flagSignSpace	: Boolean = false;
						var flagExtended	: Boolean = false;
						var flagPadZero		: Boolean = false;
						
						while (
								byte == '-'
							||	byte == '+'
							||	byte == ' '
							||  byte == '#'
							||	byte == '0'
						)
						{
							     if ( byte == '-' ) flagJustifyLeft	= true;
							else if ( byte == '+' ) flagSignForce	= true;
							else if ( byte == ' ' ) flagSignSpace	= true;
							else if ( byte == '#' ) flagExtended	= true;
							else if ( byte == '0' ) flagPadZero		= true;
	
							byte = format.charAt( ++i );
						}
						
						//-- width
						var widthFromArgument: Boolean = false;
						var widthString: String = '';
						
						if ( byte == '*' )
						{
							widthFromArgument = true;
							byte = format.charAt( ++i );
						}
						else
						{
							while (
									byte == '1' || byte == '2'
								||	byte == '3' || byte == '4'
								||	byte == '5' || byte == '6'
								||	byte == '7' || byte == '8'
								||	byte == '9' || byte == '0'
							)
							{
								widthString += byte;
								byte = format.charAt( ++i );
							}
						}
						
						//-- precision
						var precisionFromArgument: Boolean = false;
						var precisionString: String = '';
						
						if ( byte == '.' )
						{
							byte = format.charAt( ++i );
							
							if ( byte == '*' )
							{
								precisionFromArgument = true;
								byte = format.charAt( ++i );
							}
							else
							{
								while (
										byte == '1' || byte == '2'
									||	byte == '3' || byte == '4'
									||	byte == '5' || byte == '6'
									||	byte == '7' || byte == '8'
									||	byte == '9' || byte == '0'
								)
								{
									precisionString += byte;
									byte = format.charAt( ++i );
								}
							}
						}
						
						//-- length
						var lenh: Boolean = false;
						var lenl: Boolean = false;
						var lenL: Boolean = false;
						
						while (
								byte == 'h'
							||	byte == 'l'
							||	byte == 'L'
						)
						{
							     if ( byte == 'h' ) lenh = true;
							else if ( byte == 'l' ) lenl = true;
							else if ( byte == 'L' ) lenL = true;
							
							byte = format.charAt( ++i );
						}
						
						//-- specifier
						var value: String;
						var width: int = int( widthString );
						var precision: int = int( p = precisionString );
						var padChar: String = ( flagPadZero ) ? '0' : ' ';
						
						if ( precisionFromArgument )
						{
							precision = int( p = list.shift() );
						}
							
						if ( widthFromArgument )
						{
							width = int( list.shift() );
						}
								
						switch ( byte )
						{
							case 'c':
								value = String.fromCharCode( int( list.shift() ) & 0xff );
									
								if ( width != 0 )
								{
									value = pad( value, width, flagJustifyLeft, padChar );
								}
								break;
								
							case 'd':
							case 'i':
							case 'o':
								var intValue: int = int( list.shift() );
	
								if ( lenh ) intValue &= 0xffff;
								
								if ( byte == 'o' )
								{
									value = intValue.toString( 8 );
								}
								else
								{
									value = intValue.toString();
								}
								
								if ( precision != 0 )
								{
									value = pad( value, precision, false, '0' );
								}
								
								if ( intValue > 0 )
								{
									if ( flagSignForce )
									{
										value = '+' + value;
									}
									else
									if ( flagSignSpace )
									{
										value = ' ' + value;
									}
								}
								
								if ( flagExtended && intValue != 0 && byte == 'o' )
								{
									value = '0' + value;
								}
									
								if ( width != 0 )
								{
									value = pad( value, width, flagJustifyLeft, padChar );
								}
								
								if ( intValue == 0 )
								{	
									if ( p != null && p != undefined && p != '' )
									{
										if ( precision == 0 )
										{
											value = '';
										}
									}
								}
								break;
								
							case 'u':
							case 'x':
							case 'X':
								var uintValue: uint = uint( list.shift() );
								
								if ( lenh ) uintValue &= 0xffff;
								
								p = precisionString;
								
								if ( byte == 'x' )
								{
									value = uintValue.toString( 16 );
								}
								else
								if ( byte == 'X' )
								{
									value = uintValue.toString( 16 ).toUpperCase();
								}
								else
								{
									value = uintValue.toString();
								}
								
								if ( precision != 0 )
								{
									value = pad( value, precision, false, '0' );
								}
								
								if ( uintValue > 0 )
								{
									if ( flagSignForce )
										value = '+' + value;
									else if ( flagSignSpace )
										value = ' ' + value;
								}
								
								if ( uintValue != 0 )
								{
									if ( flagExtended )
									{
										if ( byte == 'x' )
										{
											value = '0x' + value;
										}
										else if ( byte == 'X' )
										{
											value = '0X' + value;
										}
									}
								}
									
								if ( width != 0 )
								{
									value = pad( value, width, flagJustifyLeft, padChar );
								}
								
								if ( uintValue == 0 )
								{	
									if ( p != null && p != undefined && p != '' )
									{
										if ( precision == 0 )
										{
											value = '';
										}
									}
								}
								break;
								
							case 'e':
							case 'E':
								var sciVal: Number = Number( list.shift() );
	
								if ( precision != 0 )
								{
									value = sciVal.toExponential( Math.min( precision, 20 ) );
								}
								else
								{
									value = sciVal.toExponential( 6 );
								}
	
								if ( flagExtended )
								{
									if ( value.indexOf( '.' ) == -1 )
									{
										value = value.substring( 0, value.indexOf( 'e' ) ) + '.000000' + value.substring( value.indexOf( 'e' ) + 1 );
									}
								}
																
								if ( byte == 'E' )
									value = value.toUpperCase();
									
								if ( width != 0 )
								{
									value = pad( value, width, flagJustifyLeft, padChar );
								}
								break;
								
							case 'f':
								var floatValue: Number = Number( list.shift() );
								
								if ( precision != 0 )
								{
									value = floatValue.toPrecision( precision );
								}
								else
								{
									value = floatValue.toPrecision( 6 );
								}
								
								if ( flagExtended )
								{
									if ( value.indexOf( '.' ) == -1 )
									{
										value += '.000000';
									}
								}
									
								if ( width != 0 )
								{
									value = pad( value, width, flagJustifyLeft, padChar );
								}
								break;
								
							case 'g':
							case 'G':
								var flags: String = '';
								var precs: String = '';
								var len: String = '';
								
								if ( flagJustifyLeft ) flags += '-';
								if ( flagSignForce ) flags += '+';
								if ( flagSignSpace ) flags += ' ';
								if ( flagExtended ) flags += '#';
								if ( flagPadZero ) flags += '0';
						
								if ( p != null && p != undefined && p != '' )
								{
									precs = '.' + precision.toString();
								}
								
								if ( lenh ) len += 'h';
								if ( lenl ) len += 'l';
								if ( lenL ) len += 'L';
								
								var compValue: Number = Number( list.shift() );
								
								var v0: String = Sprintf( '%' + flags + precs + len + 'f', compValue );
								var v1: String = Sprintf( '%' + flags + precs + len + ( ( byte == 'G' ) ? 'E' : 'e' ), compValue );
								
								value = ( v0.length < v1.length ) ? v0 : v1;
								break;
								
							case 's':
								value = String( list.shift() );
								
								if ( precision != 0 )
								{
									value = value.substring( 0, precision );
								}
									
								if ( width != 0 )
								{
									value = pad( value, width, flagJustifyLeft, padChar );
								}
								break;
							
							case 'p':
							case 'n':
								break;
								
							default:
								throw new Error(
									'Malformed format string "' + format + '" at "'
									+ format.substring( errorStart, i + 1 ) + '"'
								);
						}
						
						output += value;
					}
				}
				else
				{
					output += byte;
				}
					
				errorStart = ++i;
			}
			
			return output;
		}
	
	
		private static function pad( string: String, length: int, padRight: Boolean, char: String ): String
		{
			var i: int = string.length;
			
			if ( padRight )
			{
				while ( i++ < length )
				{
					string += char;
				}
			}
			else
			{
				while ( i++ < length )
				{
					string = char + string;
				}
			}
			
			return string;
		}
		
		//-------------------------------------
		// Get the value either to the right or to the left of the separator
		public static function GetTokenSeparatedValue(inString:String,separator:String,getRightSide:Boolean):String
		{
			var ret:String = inString;
			
			var arr:Array = inString.split(separator);
			if( arr && arr.length > 0 )
			{
				ret = StringUtil.trim(arr[getRightSide? 1 : 0]);
			}
			return ret;
			
		}
		//-------------------------------------
		// Cleans up spaces from a string. Mostly used to deal with numbers in  the form 1 234
		public static function CleanupSpaces(insStr:String):String
		{
			
			var newString:String = "";
			
			for( var i:int= 0; i < insStr.length;++i)
			{
				var curChar:String = insStr.charAt(i);
				if(!StringUtil.isWhitespace(curChar))
				{
					newString+=curChar;
				}
			}
			return newString;
		}
		
		//----------------------------------------------------------
		// convert string to number - make sure that input is a valid number string
		public static function StringToNum(str:String, precision:int = 0):Number
		{						
			return new Number(str)		
		}
		//----------------------------------------------------------
		// check if the string is valid befor converting to number
		public static function StringToNumEx(str:String):Number
		{
			var num:Number;
			var strFixedNum:String = "";
			
			if( str!=null && str.length > 0 )
			{
				if(IsValidNumber(str))
				{
					return new Number(str);	
				}
				// clean up string and make it a valid number
				for( var i:int = 0; i < str.length;++i )
				{
					
					var cur:String = str.charAt(i);
					if(IsValidNumber(cur))
					{
						strFixedNum+=cur;
					}
				}			
			}
			num = new Number((strFixedNum.length > 0 )? strFixedNum :-1);
			return num;
			
		}
				
		
		//-----------------------------------------------------------
		// check strings for equality ( optionally case sensitive)
		public static function EqualString(str1:String, str2:String,caseSensitive:Boolean):Boolean
		{
			return ( caseSensitive? 
					 (str1==str2) :(str1.toLocaleLowerCase() == str2.toLocaleLowerCase()));
			
		}
		
		//-------------------------------------------------------	
		/* Various string utility functions */
		public static function IsUpperCase(value : String) : Boolean 
		{
			return IsValidAsciiCode(value, 65, 90);
		}
		//-------------------------------------------------------	
		public static function IsLowerCase(value : String) : Boolean 
		{
			return IsValidAsciiCode(value, 97, 122);
		}
		//-------------------------------------------------------	
		public static function IsValidNumber(value:String):Boolean
		{
			// a valid number may contain a dot character or a minus sign
			if ((value == null) || (StringUtil.trim(value).length < 1))
			{
				return false;
			}
	
			for (var i : int=value.length-1;i >= 0; i--) 
			{
				var code : Number = value.charCodeAt(i);
				
				if ((code < 48) || (code > 57))
				{
					// allow minus sign as first char
					if(i==0 && code == 45)
					{
						continue;
					}
					if(code!=46)
					{
						return false;
					}					
				}
			}
			return true;
		
		}
		//-------------------------------------------------------		
		public static function IsDigit(value : String) : Boolean 
		{
			
			return IsValidAsciiCode(value, 48, 57);
		}
		//-------------------------------------------------------	
		public static function IsLetter(value : String) : Boolean
	 	{
			return (IsLowerCase(value) || IsUpperCase(value));
		}
		//-------------------------------------------------------	
		private static function IsValidAsciiCode(value : String, 
												minCode : Number, 
												maxCode : Number) : Boolean
												
		{
			if ((value == null) || (StringUtil.trim(value).length < 1))
			{
				return false;
			}
	
			for (var i : int=value.length-1;i >= 0; i--) 
			{
				var code : Number = value.charCodeAt(i);
				
				if ((code < minCode) || (code > maxCode))
				{
					return false;					
				}
			}
			return true;
		}
		
		//--------------------------------------------------------------
		public static function Base64Encode(str:String):String
		{
			var b64Encoder:Base64Encoder = new Base64Encoder();
			b64Encoder.insertNewLines =false;
			b64Encoder.encode(str);	
			
			return  (b64Encoder.toString());
		}
		//--------------------------------------------------------------
		public static function Base64Decode(str:String):String
		{
			var b64decoder:Base64Decoder = new Base64Decoder();
			b64decoder.decode(str);
			var ba:ByteArray = b64decoder.toByteArray();
			
			var ret:String  = ba.toString();
			return  ret;
		}
		//--------------------------------------------------------------
		// convert to unix line endings
		public static function Dos2Unix(str:String):String
		{
			var pat:RegExp = /\r/g;
			return str.replace(pat,"\n");
		}
		//--------------------------------------------------------------
		// and back
		public static function Unix2Dos(str:String):String
		{
			var pat:RegExp = /\n/g;
			return str.replace(pat,"\r");
		}
		//--------------------------------------------------------------
		// find all occurences of pattern in the string and remove them
		// return string without removed chars
		public static function RemoveSubstring(src:String,pattern:String):String
		{
			return src.replace(pattern,"");
		}
		//---------------------------------------------------------------
		// Strip extension from file name
		public static function StripFileExtension(src:String):String
		{
			var ret:String  = src;
			var arr:Array = src.split(".");
			if(arr.length > 0 )
			{
				ret = arr[0];
			}
			return ret;			
		}
		//--------------------------------------------
		// replace newline chars in a string  to HTML line breaks
		public static function ConvertToHtmlLineBreaks(data:String):String
		{
			return((data.indexOf("\n")!=-1)? data.replace(/\n/g, "<br>"):data);		
		}
		//----------------------------------------------------------------
		// Searches src string from beginning for pattern
		public static function PartialStringMatch(src:String, 
												  pattern:String, 
												  caseSensitive:Boolean=false):Boolean
		{
			var pos:int  = -1;
			var searchStr:String = src;
			
			// if not case sensitive - convert everything to lowercase
			if(!caseSensitive)
			{
				pattern = pattern.toLowerCase();
				searchStr = searchStr.toLowerCase();
			}
			
			pos = searchStr.indexOf(pattern);
			
			/*if(pos!=-1)
			{
				trace("PartialStringMatch: pattern="+pattern+"\n,src="+searchStr);
			}*/
			return(pos!=-1);
		}
		//-------------------------------------------------------
		// Replace html open and close tags with their character entities
		public static function  CleanupHtmlTags(data:String):String
		{
			var ret:String = data.replace(/</g, "&lt;");
			return(ret.replace(/>/g, "&gt;"));
		}
		//-------------------------------------------
		public static function IsValidString(val:String):Boolean
		{
			return(val!=null && val.length > 0)
		}
		//------------------------------------------------------
		// Assumes a valid IP address in dotted decimal notation
		public static function IpToHex(strIP:String):uint
		{
			var res:uint = 0;
			var octets:Array = strIP.split(".");
		    var bytes:Array = new Array();
			
			
			// enforce syntax
			if(octets.length !=4)
			{
				return 0;
			}
			for(var i :int =0; i < octets.length;++i)
			{
				bytes[i] = StringToNumEx(octets[i]);
			}
			
			var  octet1:int = (bytes[0] & 0xFF) << 24;
			var  octet2:int = (bytes[1] & 0xFF) << 16;
			var  octet3:int = (bytes[2] & 0xFF) << 8;
			var  octet4:int = bytes[3] & 0xFF;
			
			res = octet1 | octet2 | octet3 | octet4;
			return res;
		}
		//---------------------------------
		public static function StripQuotes(str:String):String
		{			
			var ret:String  = str;
			
			if( ret.indexOf("\"")  == 0 || ret.indexOf("'") == 0)
			{
				ret = ret.substring(1,ret.length);
			}		
			if(ret.lastIndexOf("\"") == ret.length-1 || ret.lastIndexOf("'") == ret.length-1)
			{
				ret = ret.substring(0,ret.length-1);
			}
			return ret;
			
		}
		
	}// class
} // package
