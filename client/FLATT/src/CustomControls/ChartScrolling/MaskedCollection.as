package CustomControls.ChartScrolling
{
	import flash.events.EventDispatcher;
	
	import mx.collections.IList;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;

	[Event(name="collectionChange", type="mx.events.CollectionEvent")]

	// TODO: Doesn't sort properly, since it does not extend ListCollectionView. Perhaps use ListCollectionView as a wrapper (since it accepts IList in the constructor)?
	[Bindable]
	public class MaskedCollection extends EventDispatcher implements IList
	{
		private var _startOffset : Number;
		private var _wrappedCollection : IList;
		private var _pageSize : int;
		
		public function MaskedCollection(list : IList = null)
		{
			wrappedCollection = list;
			
			startOffset = 0;
			
			if (wrappedCollection)
			{
				pageSize = wrappedCollection.length;
			}
		}
		
		/**
		 * Assigns a new collection to be wrapped.
		 * 
		 * <p>
		 * In this case, if the new collection is small enough that the pageSize and startOffset in the
		 * mask would extend beyond the bounds of the wrapped collection, then the startOffset
		 * is modified to avoid range over-extension. Effort is taken to keep the startOffset as close to
		 * its original value as possible.
		 * </p>
		 * 
		 * <p>
		 * This object is smart enough that the <code>length()</code> getter will never return a value longer than the
		 * size of the collection. In the case that the size of the wrapped collection is less than the
		 * pageSize, then the <code>length()</code> is reported to be the length of the wrapped collection. 
		 * </p>
		 * 
		 * <p>
		 * In the case of a collection with a length of 0 items coming in to this method, the startOffset is set
		 * to zero. 
		 * </p>
		 */
		public function set wrappedCollection(newCollection : IList) : void
		{
			if (_wrappedCollection)
			{
				_wrappedCollection.removeEventListener(CollectionEvent.COLLECTION_CHANGE, onWrappedCollectionChange);
			}
			
			_wrappedCollection = newCollection;
			
			if (_wrappedCollection)
			{
				_wrappedCollection.addEventListener(CollectionEvent.COLLECTION_CHANGE, onWrappedCollectionChange);
			}
		}
		
		/**
		 * Echoes all events that the wrapped collection broadcasts, saving us the effort.
		 */
		private function onWrappedCollectionChange(event : CollectionEvent) : void
		{
			dispatchEvent(event);
		}
		
		public function refresh() : void
		{
			dispatchRefreshEvent();
		}
		
		private function dispatchRefreshEvent() : void
		{
			dispatchEvent(
				new CollectionEvent(CollectionEvent.COLLECTION_CHANGE,
									false,
									false,
									CollectionEventKind.REFRESH)
			);
		}

		/**
		 * Sets the start offset. If a value less than 0 is given, then the startOffset is set to 0.
		 */
		public function set startOffset(newStartOffset : Number) : void
		{
			// The start offset can't go any lower than 0
			if (newStartOffset < 0)
			{
				newStartOffset = 0;
			}
			
			_startOffset = newStartOffset;
			dispatchRefreshEvent();
		}
		
		public function get startOffset() : Number
		{
			var offsetToReturn : Number = _startOffset;
			
			if (wrappedCollection)
			{
				// Stops the start offset from being pushed so high that the pageSize would push the total over the length of the underlying collection. We
				// attempt to preserve the pageSize at all costs so that the available viewing area remains constant as the underlying collection changes.
				if ((offsetToReturn + this.length) > wrappedCollection.length)
				{
					// Shift the offset back from the end of the visible by the size of the page
					offsetToReturn = (wrappedCollection.length - pageSize);
				}
			}

			// The start offset can never be less than 0
			if (offsetToReturn < 0)
			{
				offsetToReturn = 0;
			}
			
			return offsetToReturn;
		}
		
		public function set pageSize(newPageSize : int) : void
		{
			_pageSize = newPageSize;
			dispatchRefreshEvent();
		}
		
		public function addItemAt(item : Object, index : int):void
		{
			wrappedCollection.addItemAt(item, (index + startOffset));
		}
		
		public function getItemAt(index : int, prefetch : int = 0) : Object
		{
			var adjustedIndex : int = (index + startOffset);
			
			if (index >= pageSize)
			{
				throw new RangeError("Index " + index + " specified is out of bounds");
			}
			
			if (adjustedIndex > wrappedCollection.length)
			{
				throw new RangeError("Adjusted index " + adjustedIndex + " specified is out of bounds");
			}

			return wrappedCollection.getItemAt(adjustedIndex, prefetch);
		}
		
		public function getItemIndex(item : Object) : int
		{
			var originalItemIndex : int = wrappedCollection.getItemIndex(item);
			var adjustedItemIndex : int = (originalItemIndex - startOffset);
			
			var itemBelowZero : Boolean = (adjustedItemIndex < 0);
			var itemBeyondPageSize : Boolean = (adjustedItemIndex >= pageSize);
			if (itemBelowZero || itemBeyondPageSize)
			{
				adjustedItemIndex = -1;
			}
			
			return adjustedItemIndex;
		}
		
		public function toArray() : Array
		{
			return wrappedCollection.toArray().slice(startOffset, startOffset + pageSize);
		}
		
		public function get wrappedCollection() : IList
		{
			return _wrappedCollection;
		}
		
		public function get pageSize() : int
		{
			return _pageSize;
		}

		[Bindable(event="collectionChange")]
		public function get length() : int
		{
			var lengthToReturn : int = 0;
			
			if (wrappedCollection)
			{
				lengthToReturn = Math.min(pageSize, wrappedCollection.length);	
			}
			
			return lengthToReturn;
		}
		
		
		
		
		// ===========================================================================
		// ======= DELEGATED DOWN TO WRAPPED COLLECTION WITHOUT MODIFICATION =========
		// ===========================================================================
		
		public function addItem(item : Object) : void
		{
			wrappedCollection.addItem(item);
		}
		
		public function itemUpdated(item : Object, property : Object = null, oldValue : Object = null, newValue : Object = null) : void
		{
			wrappedCollection.itemUpdated(item, property, oldValue, newValue);
		}
		
		public function removeAll() : void
		{
			wrappedCollection.removeAll();
		}
		
		public function removeItemAt(index : int) : Object
		{
			return wrappedCollection.removeItemAt(index);
		}
		
		public function setItemAt(item : Object, index : int) : Object
		{
			return wrappedCollection.setItemAt(item, index);
		}
	}
}