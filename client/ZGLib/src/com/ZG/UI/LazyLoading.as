/*******************************************************************************
 * LazyLoading.as
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
package com.ZG.UI
{
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	/*
	This component is made available by Magnolia Multimedia
	http://www.magnoliamultimedia.com
	under a creative commons license
	http://creativecommons.org/licenses/by/3.0/
	
	You are free:
	to Share — to copy, distribute and transmit the work to Remix — to adapt the work 
	Under the following conditions:
	Attribution. You must attribute the work in the manner specified by the author or 
	licensor (but not in any way that suggests that they endorse you or your use of the work). 
	
	Attribute this work:
    Leave this comment at the top of the file
    */
		
	public interface LazyLoading extends IEventDispatcher
	{
		function get children():ArrayCollection;
		function get hasChildren():Boolean;
		function get childrenLoaded():Boolean;
		function loadChildren():void;
	}
}
