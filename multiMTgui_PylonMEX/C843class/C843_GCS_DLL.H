/////////////////////////////////////////////////////////////////////////////
// This is a part of the PI-Software Sources
// Copyright (C) 1995-2002 PHYSIK INSTRUMENTE GmbH
// All rights reserved.
//
// This source code belongs to the Dll for the C-843 system

///////////////////////////////////////////////////////////////////////////// 
// Program: c843-Control DLL
//
// Developer: JKa
//  
// File: C843_GCS_DLL.h : main header file for the C-843 DLL
/////////////////////////////////////////////////////////////////////////////

#ifdef __USE_STDAFX_H
#include "stdafx.h"
#else
#include <windows.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef WIN32
#include <stdint.h>

#undef C843_FUNC_DECL
#ifdef C843_DLL_EXPORTS
#define C843_FUNC_DECL __declspec(dllexport) WINAPI
#else
#define C843_FUNC_DECL __declspec(dllimport) WINAPI
#endif
		#ifndef pi_uint64
			#define	pi_uint64	unsigned _int64
		#endif
		
		#ifndef pi_uint32
			#define	pi_uint32	unsigned _int32
		#endif

		#ifndef pi_uint16
			#define	pi_uint16	unsigned _int16
		#endif

		#ifndef pi_uint8
			#define	pi_uint8	unsigned _int8
		#endif
		
		#ifndef pi_int64
			#define	pi_int64	_int64
		#endif
		
		#ifndef pi_int32
			#define	pi_int32	_int32
		#endif
		
		#ifndef pi_int16
			#define	pi_int16	_int16
		#endif

		#ifndef pi_int8
			#define	pi_int8	_int8
		#endif
#else
	#ifndef BOOL
    	#define BOOL int
	#endif
	
#define C843_FUNC_DECL
#ifndef TRUE
    #define TRUE 1
#endif

#ifndef FALSE
    #define FALSE 0
#endif
#ifndef pi_uint64
	#define	pi_uint64	u_int64_t
#endif

#ifndef pi_uint8
	#define	pi_uint8	u_int8_t
#endif

#ifndef pi_uint16
	#define	pi_uint16	u_int16_t
#endif

#ifndef pi_uint32
	#define	pi_uint32	u_int32_t
#endif

#ifndef pi_int64
	#define	pi_int64	int64_t
#endif

#ifndef pi_int32
	#define	pi_int32	int32_t
#endif

#ifndef _int32
	#define _int32 int32_t
#endif

#ifndef _int64
	#define _int64 int64_t
#endif

#endif
/////////////////////////////////////////////////////////////////////////////
// DLL initialization and comm functions
long		C843_FUNC_DECL	C843_Connect(long iBoardNumber);
BOOL	C843_FUNC_DECL	C843_IsConnected(long iID);
BOOL	C843_FUNC_DECL  C843_ListPCI(char* szIDList,long maxlen);
void	C843_FUNC_DECL	C843_CloseConnection(long iID);
long		C843_FUNC_DECL	C843_GetError(long iID);
BOOL	C843_FUNC_DECL	C843_SetErrorCheck(long iID, BOOL bErrorCheck);
BOOL	C843_FUNC_DECL	C843_TranslateError(long errNr, char* szBuffer, long maxlen);
long		C843_FUNC_DECL	C843_GetCurrentBoardId(long iBoardNumber);




/////////////////////////////////////////////////////////////////////////////
// general

BOOL C843_FUNC_DECL C843_qHLP(const long iID, char* buffer, long maxlen);
BOOL C843_FUNC_DECL C843_qHPA(const long iID, char* buffer, long maxlen);
BOOL C843_FUNC_DECL C843_qHDR(const long iID, char* buffer, long maxlen);
BOOL C843_FUNC_DECL C843_qERR(long iID, long* pnError);
BOOL C843_FUNC_DECL C843_qIDN(long iID, char* buffer, long maxlen);
BOOL C843_FUNC_DECL C843_qVER(long iID, char* buffer, long maxlen);
BOOL C843_FUNC_DECL C843_INI(long iID, const char* szAxes);
BOOL C843_FUNC_DECL C843_CLR(long iID, const char* szAxes);

/////////////////////////////////////////////////////////////////////////////
// motion, monitoring
BOOL C843_FUNC_DECL C843_MOV(long iID, const char* szAxes, const double* pdValarray);
BOOL C843_FUNC_DECL C843_qMOV(long iID, const char* szAxes, double* pdValarray);
BOOL C843_FUNC_DECL C843_MVR(long iID, const char* szAxes, const double* pdValarray);
BOOL C843_FUNC_DECL C843_MVE(long iID, const char* szAxes, const double* pdValarray);
BOOL C843_FUNC_DECL C843_IsMoving(long iID, const char* szAxes, BOOL* pbValarray);
BOOL C843_FUNC_DECL C843_IsUserProfileActive(long iID, const char* szAxes, BOOL* pbValarray);
BOOL C843_FUNC_DECL C843_qONT(long iID, const char* szAxes, BOOL* pbValarray);

BOOL C843_FUNC_DECL C843_qPOS(long iID, const char* szAxes, double* pdValarray);
BOOL C843_FUNC_DECL C843_POS(long iID, const char* szAxes, const double* pdValarray);

BOOL C843_FUNC_DECL C843_DFF(long iID, const char* szAxes, const double* pdValarray);
BOOL C843_FUNC_DECL C843_qDFF(long iID, const char* szAxes, double* pdValarray);

BOOL C843_FUNC_DECL C843_DFH(long iID, const char* szAxes);
BOOL C843_FUNC_DECL C843_qDFH(long iID, const char* szAxes, double* pdValarray);
BOOL C843_FUNC_DECL C843_GOH(long iID, const char* szAxes);

BOOL C843_FUNC_DECL C843_HLT(long iID, const char* szAxes);
BOOL C843_FUNC_DECL C843_STP(long iID);

BOOL C843_FUNC_DECL C843_SVO(long iID, const char* szAxes, const BOOL* pbValarray);
BOOL C843_FUNC_DECL C843_qSVO(long iID, const char* szAxes, BOOL* pbValarray);

BOOL C843_FUNC_DECL C843_SMO(long iID, const char* szAxes, const long* pnValarray);
BOOL C843_FUNC_DECL C843_qSMO(long iID, const char* szAxes, long* pnValarray);

BOOL C843_FUNC_DECL C843_VEL(long iID, const char* szAxes, const double* pdValarray);
BOOL C843_FUNC_DECL C843_qVEL(long iID, const char* szAxes, double* pdValarray);
BOOL C843_FUNC_DECL C843_ACC(long iID, const char* szAxes, const double* pdValarray);
BOOL C843_FUNC_DECL C843_qACC(long iID, const char* szAxes, double* pdValarray);
BOOL C843_FUNC_DECL C843_DEC(long iID, const char* szAxes, const double* pdValarray);
BOOL C843_FUNC_DECL C843_qDEC(long iID, const char* szAxes, double* pdValarray);

BOOL C843_FUNC_DECL C843_qSRG(long iID, const char* szAxes, const long* iCmdarray, long* iValarray);

BOOL C843_FUNC_DECL C843_BRA(long iID, const char* szAxes, const BOOL* pbValarray);
BOOL C843_FUNC_DECL C843_qBRA(long iID, char* szBuffer, const long maxlen);

/////////////////////////////////////////////////////////////////////////////
// stages assignment, parameters
BOOL C843_FUNC_DECL C843_qCST(long iID, const char* szAxes, char* names,  long maxlen);
BOOL C843_FUNC_DECL C843_CST(long iID, const char* szAxes, const char* names);
BOOL C843_FUNC_DECL C843_qVST(long iID, char* buffer,  long maxlen);
BOOL C843_FUNC_DECL C843_qTVI(long iID, char* axes,  long maxlen);
BOOL C843_FUNC_DECL C843_SAI(long iID, const char* szOldAxes, const char* szNewAxes);
BOOL C843_FUNC_DECL C843_qSAI(long iID, char* axes,  long maxlen);
BOOL C843_FUNC_DECL C843_qSAI_ALL(long iID, char* axes,  long maxlen);
BOOL C843_FUNC_DECL C843_SPA(long iID, const char* szAxes, const long* iCmdarray, const double* dValarray, const char* szStageNames);
BOOL C843_FUNC_DECL C843_qSPA(long iID, const char* szAxes, const long* iCmdarray, double* dValarray, char* szStageNames, long iMaxNameSize);

/////////////////////////////////////////////////////////////////////////////
// Trigger Output
BOOL C843_FUNC_DECL C843_CTO(long iID, const long* iTriggerLinesArray, const long* iParamIDArray,  const char* szValues, long iArraySize);
BOOL C843_FUNC_DECL C843_qCTO(long iID, const long* iTriggerLinesArray, const long* pParamIDArray, char* szBuffer, long iArraySize, long iBufferMaxlen);
BOOL C843_FUNC_DECL C843_TRO(long iID,  const long* iTriggerLinesArray, const BOOL* pbValarray, long iArraySize);
BOOL C843_FUNC_DECL C843_qTRO(long iID, const long* iTriggerLinesArray, BOOL* pbValarray, long iArraySize);

/////////////////////////////////////////////////////////////////////////////
// Digital I/O
BOOL C843_FUNC_DECL C843_GetInputChannelNames(long iID, char* szBuffer, const long maxlen);
BOOL C843_FUNC_DECL C843_GetOutputChannelNames(long iID, char* szBuffer, const long maxlen);
BOOL C843_FUNC_DECL C843_DIO(long iID, const char* szChannels, const BOOL* pbValarray);
BOOL C843_FUNC_DECL C843_qDIO(long iID, const char* szChannels, BOOL* pbValarray);
BOOL C843_FUNC_DECL C843_qTIO(long iID, long* pINr, long* pONr);


/////////////////////////////////////////////////////////////////////////////
// String commands
#ifdef WIN32
BOOL C843_FUNC_DECL C843_C843Commandset(long iID, const char* szCommand, char* szAwnser, long iMaxSize);
#endif
BOOL C843_FUNC_DECL C843_GcsCommandset(long iID, const char* szCommand);
BOOL C843_FUNC_DECL C843_GcsGetAnswer(long iID, char* szAnswer, long bufsize);
BOOL C843_FUNC_DECL C843_GcsGetAnswerSize(long iID, long* iAnswerSize);



/////////////////////////////////////////////////////////////////////////////
// QMC commands.
BOOL C843_FUNC_DECL C843_SetQMC(long iID, pi_uint8 bCmd, pi_uint8 bAxis, pi_int32 Param);
BOOL C843_FUNC_DECL C843_GetQMC(long iID, pi_uint8 bCmd, pi_uint8 bAxis, pi_int32* pResult);
BOOL C843_FUNC_DECL C843_SetQMCA(long iID, pi_uint8 bCmd, pi_uint8 bAxis, pi_uint16 Param1, pi_int32 lParam2);
BOOL C843_FUNC_DECL C843_GetQMCA(long iID, pi_uint8 bCmd, pi_uint8 bAxis, pi_uint16 lParam, pi_int32* pResult);


/////////////////////////////////////////////////////////////////////////////
// limits, referencing
BOOL C843_FUNC_DECL C843_MNL(long iID,  const char* szAxes);
BOOL C843_FUNC_DECL C843_MPL(long iID,  const char* szAxes);
BOOL C843_FUNC_DECL C843_REF(long iID, const char* szAxes);
BOOL C843_FUNC_DECL C843_FRF(long iID, const char* szAxes);
BOOL C843_FUNC_DECL C843_FPL(long iID, const char* szAxes);
BOOL C843_FUNC_DECL C843_FNL(long iID, const char* szAxes);
BOOL C843_FUNC_DECL C843_FED(long iID, const char* szAxes, const long* iEdgeIDArray, const long* iParArray);
BOOL C843_FUNC_DECL C843_qFED(long iID, const char* szAxes, long* iEdgeIDArray, long* iParArray);
BOOL C843_FUNC_DECL C843_qFES(long iID, const char* szAxes, BOOL* pbValarray);
BOOL C843_FUNC_DECL C843_qREF(long iID, const char* szAxes, BOOL* pbValarray);
BOOL C843_FUNC_DECL C843_qFRF(long iID, const char* szAxes, BOOL* pbValarray);
BOOL C843_FUNC_DECL C843_qLIM(long iID, const char* szAxes, BOOL* pbValarray);
BOOL C843_FUNC_DECL C843_IsReferencing(long iID, const char* szAxes, BOOL* pbValarray);
BOOL C843_FUNC_DECL C843_IsControllerReady(const long ID, long* piControllerReady);
BOOL C843_FUNC_DECL C843_GetRefResult(long iID, const char* szAxes, BOOL* pbValarray);
BOOL C843_FUNC_DECL C843_IsReferenceOK(long iID, const char* szAxes, BOOL* pbValarray);
BOOL C843_FUNC_DECL C843_qTMN(long iID, const char* szAxes, double* pdValarray);
BOOL C843_FUNC_DECL C843_qTMX(long iID, const char* szAxes, double* pdValarray);
BOOL C843_FUNC_DECL C843_RON(long iID, const char* szAxes, const BOOL* pbValarray);
BOOL C843_FUNC_DECL C843_qRON(long iID, const char* szAxes, BOOL* pbValarray);


/////////////////////////////////////////////////////////////////////////////
// User Profile Mode
BOOL C843_FUNC_DECL C843_UPB(long iID, const char* szClusters, const long* iCmdarray, const long* iPararray, const long* iValarray);
BOOL C843_FUNC_DECL C843_UPD(long iID, const char* szClusters, const long* iCmdarray, const long* iPararray, const double* dValarray);
BOOL C843_FUNC_DECL C843_UPC(long iID, const char* szAxes,	const char* szClusters, const long* iCmdarray, const long* iPararray);
BOOL C843_FUNC_DECL C843_UPA(long iID, const char* szClusters, const long* iCmdarray);
BOOL C843_FUNC_DECL C843_UPR(long iID, const char* szAxes,	const char* szClusters, const long* iCmdarray);
BOOL C843_FUNC_DECL C843_qUPB(long iID,const char* szClusters, const long* iCmdarray, const long* iPararray, long* iValarray);
BOOL C843_FUNC_DECL C843_qUPD(long iID,const char* szClusters, const long* iCmdarray, const long* iPararray, double* dValarray);
BOOL C843_FUNC_DECL C843_qUPC(long iID,char* szClusters,char* szAxes, long* iCmdarray, long* iPararray);
BOOL C843_FUNC_DECL C843_qUPA(long iID,const char* szClusters, const long* iCmdarray, long* iPararray);


//////////////////////////////////////////////////////////////////////////////
// Trace
BOOL C843_FUNC_DECL C843_STE(long iID, char cAxis, double dOffset);
BOOL C843_FUNC_DECL C843_qSTE(long iID, char cAxis, long iOffset, long nrValues, double* pdValarray);
BOOL C843_FUNC_DECL C843_DRC(long iID, const long* iRecTableId, const char* sRecSourceId, const long* iRecOption, const long* TriggerOption);
BOOL C843_FUNC_DECL C843_qDRC(long iID, const long* iRecTableId, char* sRecSourceId, long* iRecOption, long* TriggerOption, long iArraySize);
BOOL C843_FUNC_DECL C843_qDRL(long iID, long* nrValues);
BOOL C843_FUNC_DECL C843_DRT(long iID, const long* iRecTableId, const long* TriggerOption, const char* sValue, long iArrayLength);
BOOL C843_FUNC_DECL C843_qDRT(long iID, const long* iRecTableId,  long* TriggerOption, char* sValue, long iArraySize, long iValueBufferLength);
BOOL C843_FUNC_DECL C843_qDRR_SYNC(long iID, long iRecTableId, long iOffset, long nrValues, double* pdValArray);
BOOL C843_FUNC_DECL C843_qDRR(long iID, const long* piRecTableIds, long iNumberOfRecChannels, long iOffset, long nrValues, double** pdValArray, char* szGcsArrayHeader, long iGcsArrayHeaderMaxSize);
long C843_FUNC_DECL C843_GetAsyncBufferIndex(long iID);
BOOL C843_FUNC_DECL	C843_GetAsyncBuffer(long iID, double** pdValueArray);
BOOL C843_FUNC_DECL C843_qTNR(long iID, long* iNrOfTables);
BOOL C843_FUNC_DECL C843_RTR(long iID, long iRecordTableRate);
BOOL C843_FUNC_DECL C843_qRTR(long iID, long* iRecordTableRate);

/////////////////////////////////////////////////////////////////////////////
// Special
BOOL	C843_FUNC_DECL	C843_AddStage(long iID, const char* szAxes);
BOOL	C843_FUNC_DECL	C843_RemoveStage(long iID, const char* szStageName);
BOOL	C843_FUNC_DECL C843_OpenUserStagesEditDialog(long iID);
BOOL	C843_FUNC_DECL C843_OpenPiStagesEditDialog(long iID);

/////////////////////////////////////////////////////////////////////////////
// Joystick
BOOL C843_FUNC_DECL C843_JON(long iId,const long* iJoystickIDsArray, const BOOL* pbValueArray, long iArraySize);
BOOL C843_FUNC_DECL C843_qJON(long iID, const long* iJoystickIDsArray, BOOL* pbValueArray, long iArraySize);
BOOL C843_FUNC_DECL C843_qJAX(long iId, const long* iJoystickIDsArray, const long* iAxesIDsArray, long iArraySize, char* szAxesBuffer, long iBufferSize);
BOOL C843_FUNC_DECL C843_JAX(long iID,  long iJoystickID,  long iAxesID, const char* szAxesBuffer);

/////////////////////////////////////////////////////////////////////////////
// electronic gearing commands
BOOL C843_FUNC_DECL C843_SRA(long iID, const char* szAxes, double* dValArray);
BOOL C843_FUNC_DECL C843_qSRA(long iID, const char* szAxes, double* dValArray);
BOOL C843_FUNC_DECL C843_EGE(long iID, const char* szAxes, BOOL* bValueArray);
BOOL C843_FUNC_DECL C843_qEGE(long iID, const char* szAxes, BOOL* bValueArray);
BOOL C843_FUNC_DECL C843_MAS(long iID, const char* szAxes, const char* szMasters);
BOOL C843_FUNC_DECL C843_qMAS(long iID, const char* szAxes, char* szMasters);

///////////////////////////////////////////////////////////////////////////////
// for internal use
BOOL C843_FUNC_DECL C843_DisableSingleStagesDatFiles(long iID,BOOL bDisable);
BOOL C843_FUNC_DECL C843_DisableUserStagesDatFiles(long iID,BOOL bDisable);

#ifdef __cplusplus
}
#endif
