#ifndef UVC_H
#define UVC_H

#include <fx2types.h>

//----------------------------------------------------------------------------
//	UVC definitions
//----------------------------------------------------------------------------
#define GET_CUR  		(0x81) // 1
#define GET_MIN  		(0x82) //
#define GET_MAX  		(0x83) // 2

BOOL handleUVCCommand(BYTE cmd);

#endif // UVC_H
