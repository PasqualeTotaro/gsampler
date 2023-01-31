/*================================================================================================*/
/*
 *	Copyright 2015, 2018 by Avid Technology, Inc.
 *	All rights reserved.
 *
 *	CONFIDENTIAL: This document contains confidential information.  Do not 
 *	read or examine this document unless you are an Avid Technology employee
 *	or have signed a non-disclosure agreement with Avid Technology which protects
 *	the	confidentiality of this document.  DO NOT DISCLOSE ANY INFORMATION 
 *	CONTAINED IN THIS DOCUMENT TO ANY THIRD-PARTY WITHOUT THE PRIOR WRITTEN	CONSENT 
 *	OF Avid Technology, INC.
 *
 */

/**	
 *  \file AAX_IPointerQueue.h
 *
 *	\brief Abstract interface for a basic FIFO queue of pointers-to-objects
 *
 */
/*================================================================================================*/
/// @cond ignore
#ifndef AAX_IPOINTERQUEUE_H
#define AAX_IPOINTERQUEUE_H
/// @endcond

// AAX Includes
#include "AAX_IContainer.h"


/** Abstract interface for a basic FIFO queue of pointers-to-objects
 */
template <typename T>
class AAX_IPointerQueue : public AAX_IContainer
{
public:
	virtual ~AAX_IPointerQueue() {}
	
public:
	typedef T template_type; ///< The type used for this template instance
	typedef T* value_type; ///< The type of values stored in this queue
	
public: // AAX_IContainer
	/** @copybrief AAX_IContainer::Clear()
	 
		@note This operation is NOT atomic
		@note This does NOT call the destructor for any pointed-to elements; it only clears
		      the pointer values in the queue
	 */
	virtual void Clear() = 0;
	
public: // AAX_IPointerQueue
	/** Push an element onto the queue
		
		Call from: Write thread
		
		@return \ref AAX_IContainer::eStatus_Success if the push succeeded
	 */
	virtual AAX_IContainer::EStatus Push(value_type inElem) = 0;
	/** Pop the front element from the queue
		
		Call from: Read thread
		
		@return \c NULL if no element is available
	 */
	virtual value_type Pop() = 0;
	/** Get the current top element without popping it off of the queue
		
		Call from: Read thread
		
		@note This value will change if another thread calls \ref Pop()
	 */
	virtual value_type Peek() const = 0;
};


/// @cond ignore
#endif /* defined(AAX_IPOINTERQUEUE_H) */
/// @endcond