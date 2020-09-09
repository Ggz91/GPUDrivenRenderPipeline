#pragma once

#define  GRPAppBegin namespace GRPApp{
#define  GRPAppEnd }

#define  DELETE_PTR(ptr) if(nullptr != ptr)\
						{\
							delete ptr;\
							ptr = nullptr;\
						}