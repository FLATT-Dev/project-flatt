/*******************************************************************************
 * LazyLoadingDataDescriptor.as
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
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ICollectionView;
	import mx.controls.treeClasses.DefaultDataDescriptor;
	
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

	/**
	 * DataDescriptor class that's optimized to work with
	 * LazyLoading Objects
	 */
	public class LazyLoadingDataDescriptor extends DefaultDataDescriptor 
	{

		public function LazyLoadingDataDescriptor()
		{
			super();
		}
		override public function getChildren(node:Object, model:Object=null):ICollectionView {
			if (node is LazyLoading) {
				var nl:LazyLoading = node as LazyLoading;
				if (!nl.childrenLoaded && nl.hasChildren) {
					nl.loadChildren();
				}
				return nl.children;
			} else {
				return super.getChildren(node, model);
			}
		}
		//when the node is a LazyLoading, use the hasChildren property read from the data source
		override public function hasChildren(node:Object, model:Object=null):Boolean {
			if (node is LazyLoading) {
				return (node as LazyLoading).hasChildren;
			} else {
				return super.hasChildren(node, model);
			}
		}
		override public function isBranch(node:Object, model:Object=null):Boolean {
			if (node is LazyLoading) {
				return (node as LazyLoading).hasChildren;
			} else {
				return super.isBranch(node, model);
			}
		}
		
	}//end class
}
