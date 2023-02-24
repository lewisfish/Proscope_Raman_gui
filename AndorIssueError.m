function AndorIssueError(code, msg)
% Converts the code returned by the SDK into an error message dialog
% AndorIssueError(code)
% Arguments
%     code: the return code from the SDK
%     msg: custom message to tell user where error occured.
% Returns:
%     None

  switch(code)
    case 20001
      uiwait(errordlg(['Andor SDK returned Error: DRV_ERROR_CODES [20001] during: ', msg], "Error"));
    case 20002
      return
    case 20003
      uiwait(errordlg(['Andor SDK returned Error: DRV_VXD_NOT_INSTALLED [20003] during: ', msg], "Error"));
    case 20004
      uiwait(errordlg(['Andor SDK returned Error: DRV_ERROR_SCAN [20004] during: ', msg],"Error"));
    case 20005
      uiwait(errordlg(['Andor SDK returned Error: DRV_ERROR_CHECK_SUM [20005] during: ', msg],"Error"));
    case 20006
      uiwait(errordlg(['Andor SDK returned Error: DRV_ERROR_FILELOAD [20006] during: ', msg],"Error"));
    case 20007
      uiwait(errordlg(['Andor SDK returned Error: DRV_UNKNOWN_FUNCTION [20007] during: ', msg],"Error"));
    case 20008
      uiwait(errordlg(['Andor SDK returned Error: DRV_ERROR_VXD_INIT [20008] during: ', msg],"Error"));
    case 20009
      uiwait(errordlg(['Andor SDK returned Error: DRV_ERROR_ADDRESS [20009] during: ', msg],"Error"));
    case 20010
      uiwait(errordlg(['Andor SDK returned Error: DRV_ERROR_PAGELOCK [20010] during: ', msg],"Error"));
    case 20011
      uiwait(errordlg(['Andor SDK returned Error: DRV_ERROR_PAGEUNLOCK [20011] during: ', msg],"Error"));
    case 20012
      uiwait(errordlg(['Andor SDK returned Error: DRV_ERROR_BOARDTEST [20012] during: ', msg],"Error"));
    case 20013
      uiwait(errordlg(['Andor SDK returned Error: DRV_ERROR_ACK [20013] during: ', msg],"Error"));
    case 20014
      uiwait(errordlg(['Andor SDK returned Error: DRV_ERROR_UP_FIFO [20014] during: ', msg],"Error"));
    case 20015
      uiwait(errordlg(['Andor SDK returned Error: DRV_ERROR_PATTERN [20015] during: ', msg],"Error"));
    case 20017
      uiwait(errordlg(['Andor SDK returned Error: DRV_ACQUISITION_ERRORS [20017] during: ', msg],"Error"));
    case 20018
      uiwait(errordlg(['Andor SDK returned Error: DRV_ACQ_BUFFER [20018] during: ', msg],"Error"));
    case 20019
      uiwait(errordlg(['Andor SDK returned Error: DRV_ACQ_DOWNFIFO_FULL [20019] during: ', msg],"Error"));
    case 20020
      uiwait(errordlg(['Andor SDK returned Error: DRV_PROC_UNKONWN_INSTRUCTION [20020] during: ', msg],"Error"));
    case 20021
      uiwait(errordlg(['Andor SDK returned Error: DRV_ILLEGAL_OP_CODE [20021] during: ', msg],"Error"));
    case 20022
      uiwait(errordlg(['Andor SDK returned Error: DRV_KINETIC_TIME_NOT_MET [20022] during: ', msg],"Error"));
    case 20023
      uiwait(errordlg(['Andor SDK returned Error: DRV_ACCUM_TIME_NOT_MET [20023] during: ', msg],"Error"));
    case 20024
      uiwait(errordlg(['Andor SDK returned Error: DRV_NO_NEW_DATA [20024] during: ', msg],"Error"));
    case 20025
      uiwait(errordlg(['Andor SDK returned Error: DRV_PCI_DMA_FAIL [20025] during: ', msg],"Error"));
    case 20026
      uiwait(errordlg(['Andor SDK returned Error: DRV_SPOOLERROR [20026] during: ', msg],"Error"));
    case 20027
      uiwait(errordlg(['Andor SDK returned Error: DRV_SPOOLSETUPERROR [20027] during: ', msg],"Error"));
    case 20028
      uiwait(errordlg(['Andor SDK returned Error: DRV_FILESIZELIMITERROR [20028] during: ', msg],"Error"));
    case 20029
      uiwait(errordlg(['Andor SDK returned Error: DRV_ERROR_FILESAVE [20029] during: ', msg],"Error"));
    case 20033
      uiwait(errordlg(['Andor SDK returned Error: DRV_TEMPERATURE_CODES [20033] during: ', msg],"Error"));
    case 20034
      uiwait(errordlg(['Andor SDK returned Error: DRV_TEMPERATURE_OFF [20034] during: ', msg],"Error"));
    case 20035
      uiwait(errordlg(['Andor SDK returned Error: DRV_TEMPERATURE_NOT_STABILIZED [20035] during: ', msg],"Error"));
    case 20036
      uiwait(errordlg(['Andor SDK returned Error: DRV_TEMPERATURE_STABILIZED [20036] during: ', msg],"Error"));
    case 20037
      uiwait(errordlg(['Andor SDK returned Error: DRV_TEMPERATURE_NOT_REACHED [20037] during: ', msg],"Error"));
    case 20038
      uiwait(errordlg(['Andor SDK returned Error: DRV_TEMPERATURE_OUT_RANGE [20038] during: ', msg],"Error"));
    case 20039
      uiwait(errordlg(['Andor SDK returned Error: DRV_TEMPERATURE_NOT_SUPPORTED [20039] during: ', msg],"Error"));
    case 20040
      uiwait(errordlg(['Andor SDK returned Error: DRV_TEMPERATURE_DRIFT [20040] during: ', msg],"Error"));
    case 20049
      uiwait(errordlg(['Andor SDK returned Error: DRV_GENERAL_ERRORS [20049] during: ', msg],"Error"));
    case 20050
      uiwait(errordlg(['Andor SDK returned Error: DRV_INVALID_AUX [20050] during: ', msg],"Error"));
    case 20051
      uiwait(errordlg(['Andor SDK returned Error: DRV_COF_NOTLOADED [20051] during: ', msg],"Error"));
    case 20052
      uiwait(errordlg(['Andor SDK returned Error: DRV_FPGAPROG [20052] during: ', msg],"Error"));
    case 20053
      uiwait(errordlg(['Andor SDK returned Error: DRV_FLEXERROR [20053] during: ', msg],"Error"));
    case 20054
      uiwait(errordlg(['Andor SDK returned Error: DRV_GPIBERROR [20054] during: ', msg],"Error"));
    case 20055
      uiwait(errordlg(['Andor SDK returned Error: DRV_EEPROMVERSIONERROR [20055] during: ', msg],"Error"));
    case 20064
      uiwait(errordlg(['Andor SDK returned Error: DRV_DATATYPE [20064] during: ', msg],"Error"));
    case 20065
      uiwait(errordlg(['Andor SDK returned Error: DRV_DRIVER_ERRORS [20065] during: ', msg],"Error"));
    case 20066
      uiwait(errordlg(['Andor SDK returned Error: DRV_P1INVALID [20066] during: ', msg],"Error"));
    case 20067
      uiwait(errordlg(['Andor SDK returned Error: DRV_P2INVALID [20067] during: ', msg],"Error"));
    case 20068
      uiwait(errordlg(['Andor SDK returned Error: DRV_P3INVALID [20068] during: ', msg],"Error"));
    case 20069
      uiwait(errordlg(['Andor SDK returned Error: DRV_P4INVALID [20069] during: ', msg],"Error"));
    case 20070
      uiwait(errordlg(['Andor SDK returned Error: DRV_INIERROR [20070] during: ', msg],"Error"));
    case 20071
      uiwait(errordlg(['Andor SDK returned Error: DRV_COFERROR [20071] during: ', msg],"Error"));
    case 20072
      uiwait(errordlg(['Andor SDK returned Error: DRV_ACQUIRING [20072] during: ', msg],"Error"));
    case 20073
      uiwait(errordlg(['Andor SDK returned Error: DRV_IDLE [20073] during: ', msg],"Error"));
    case 20074
      uiwait(errordlg(['Andor SDK returned Error: DRV_TEMPCYCLE [20074] during: ', msg],"Error"));
    case 20075
      uiwait(errordlg(['Andor SDK returned Error: DRV_NOT_INITIALIZED [20075] during: ', msg],"Error"));
    case 20076
      uiwait(errordlg(['Andor SDK returned Error: DRV_P5INVALID [20076] during: ', msg],"Error"));
    case 20077
      uiwait(errordlg(['Andor SDK returned Error: DRV_P6INVALID [20077] during: ', msg],"Error"));
    case 20078
      uiwait(errordlg(['Andor SDK returned Error: DRV_INVALID_MODE [20078] during: ', msg],"Error"));
    case 20079
      uiwait(errordlg(['Andor SDK returned Error: DRV_INVALID_FILTER [20079] during: ', msg],"Error"));
    case 20080
      uiwait(errordlg(['Andor SDK returned Error: DRV_I2CERRORS [20080] during: ', msg],"Error"));
    case 20081
      uiwait(errordlg(['Andor SDK returned Error: DRV_I2CDEVNOTFOUND [20081] during: ', msg],"Error"));
    case 20082
      uiwait(errordlg(['Andor SDK returned Error: DRV_I2CTIMEOUT [20082] during: ', msg],"Error"));
    case 20083
      uiwait(errordlg(['Andor SDK returned Error: DRV_P7INVALID [20083] during: ', msg],"Error"));
    case 20084
      uiwait(errordlg(['Andor SDK returned Error: DRV_P8INVALID [20084] during: ', msg],"Error"));
    case 20085
      uiwait(errordlg(['Andor SDK returned Error: DRV_P9INVALID [20085] during: ', msg],"Error"));
    case 20086
      uiwait(errordlg(['Andor SDK returned Error: DRV_P10INVALID [20086] during: ', msg],"Error"));
    case 20087
      uiwait(errordlg(['Andor SDK returned Error: DRV_P11INVALID [20087] during: ', msg],"Error"));
    case 20089
      uiwait(errordlg(['Andor SDK returned Error: DRV_USBERROR [20089] during: ', msg],"Error"));
    case 20090
      uiwait(errordlg(['Andor SDK returned Error: DRV_IOCERROR [20090] during: ', msg],"Error"));
    case 20091
      uiwait(errordlg(['Andor SDK returned Error: DRV_VRMVERSIONERROR [20091] during: ', msg],"Error"));
    case 20092
      uiwait(errordlg(['Andor SDK returned Error: DRV_GATESTEPERROR [20092] during: ', msg],"Error"));
    case 20093
      uiwait(errordlg(['Andor SDK returned Error: DRV_USB_INTERRUPT_ENDPOINT_ERROR [20093] during: ', msg],"Error"));
    case 20094
      uiwait(errordlg(['Andor SDK returned Error: DRV_RANDOM_TRACK_ERROR [20094] during: ', msg],"Error"));
    case 20095
      uiwait(errordlg(['Andor SDK returned Error: DRV_INVALID_TRIGGER_MODE [20095] during: ', msg],"Error"));
    case 20096
      uiwait(errordlg(['Andor SDK returned Error: DRV_LOAD_FIRMWARE_ERROR [20096] during: ', msg],"Error"));
    case 20097
      uiwait(errordlg(['Andor SDK returned Error: DRV_DIVIDE_BY_ZERO_ERROR [20097] during: ', msg],"Error"));
    case 20098
      uiwait(errordlg(['Andor SDK returned Error: DRV_INVALID_RINGEXPOSURES [20098] during: ', msg],"Error"));
    case 20099
      uiwait(errordlg(['Andor SDK returned Error: DRV_BINNING_ERROR [20099] during: ', msg],"Error"));
    case 20100
      uiwait(errordlg(['Andor SDK returned Error: DRV_INVALID_AMPLIFIER [20100] during: ', msg],"Error"));
    case 20101
      uiwait(errordlg(['Andor SDK returned Error: DRV_INVALID_COUNTCONVERT_MODE [20101] during: ', msg],"Error"));
    case 20990
      uiwait(errordlg(['Andor SDK returned Error: DRV_ERROR_NOCAMERA [20990] during: ', msg],"Error"));
    case 20991
      uiwait(errordlg(['Andor SDK returned Error: DRV_NOT_SUPPORTED [20991] during: ', msg],"Error"));
    case 20992
      uiwait(errordlg(['Andor SDK returned Error: DRV_NOT_AVAILABLE [20992] during: ', msg],"Error"));
    case 20115
      uiwait(errordlg(['Andor SDK returned Error: DRV_ERROR_MAP [20115] during: ', msg],"Error"));
    case 20116
      uiwait(errordlg(['Andor SDK returned Error: DRV_ERROR_UNMAP [20116] during: ', msg],"Error"));
    case 20117
      uiwait(errordlg(['Andor SDK returned Error: DRV_ERROR_MDL [20117] during: ', msg],"Error"));
    case 20118
      uiwait(errordlg(['Andor SDK returned Error: DRV_ERROR_UNMDL [20118] during: ', msg],"Error"));
    case 20119
      uiwait(errordlg(['Andor SDK returned Error: DRV_ERROR_BUFFSIZE [20119] during: ', msg],"Error"));
    case 20121
      uiwait(errordlg(['Andor SDK returned Error: DRV_ERROR_NOHANDLE [20121] during: ', msg],"Error"));
    case 20130
      uiwait(errordlg(['Andor SDK returned Error: DRV_GATING_NOT_AVAILABLE [20130] during: ', msg],"Error"));
    case 20131
      uiwait(errordlg(['Andor SDK returned Error: DRV_FPGA_VOLTAGE_ERROR [20131] during: ', msg],"Error"));
    case 20150
      uiwait(errordlg(['Andor SDK returned Error: DRV_OW_CMD_FAIL [20150] during: ', msg],"Error"));
    case 20151
      uiwait(errordlg(['Andor SDK returned Error: DRV_OWMEMORY_BAD_ADDR [20151] during: ', msg],"Error"));
    case 20152
      uiwait(errordlg(['Andor SDK returned Error: DRV_OWCMD_NOT_AVAILABLE [20152] during: ', msg],"Error"));
    case 20153
      uiwait(errordlg(['Andor SDK returned Error: DRV_OW_NO_SLAVES [20153] during: ', msg],"Error"));
    case 20154
      uiwait(errordlg(['Andor SDK returned Error: DRV_OW_NOT_INITIALIZED [20154] during: ', msg],"Error"));
    case 20155
      uiwait(errordlg(['Andor SDK returned Error: DRV_OW_ERROR_SLAVE_NUM [20155] during: ', msg],"Error"));
    case 20156
      uiwait(errordlg(['Andor SDK returned Error: DRV_MSTIMINGS_ERROR [20156] during: ', msg],"Error"));
    case 20173
      uiwait(errordlg(['Andor SDK returned Error: DRV_OA_NULL_ERROR [20173] during: ', msg],"Error"));
    case 20174
      uiwait(errordlg(['Andor SDK returned Error: DRV_OA_PARSE_DTD_ERROR [20174] during: ', msg],"Error"));
    case 20175
      uiwait(errordlg(['Andor SDK returned Error: DRV_OA_DTD_VALIDATE_ERROR [20175] during: ', msg],"Error"));
    case 20176
      uiwait(errordlg(['Andor SDK returned Error: DRV_OA_FILE_ACCESS_ERROR [20176] during: ', msg],"Error"));
    case 20177
      uiwait(errordlg(['Andor SDK returned Error: DRV_OA_FILE_DOES_NOT_EXIST [20177] during: ', msg],"Error"));
    case 20178
      uiwait(errordlg(['Andor SDK returned Error: DRV_OA_XML_INVALID_OR_NOT_FOUND_ERROR [20178] during: ', msg],"Error"));
    case 20179
      uiwait(errordlg(['Andor SDK returned Error: DRV_OA_PRESET_FILE_NOT_LOADED [20179] during: ', msg],"Error"));
    case 20180
      uiwait(errordlg(['Andor SDK returned Error: DRV_OA_USER_FILE_NOT_LOADED [20180] during: ', msg],"Error"));
    case 20181
      uiwait(errordlg(['Andor SDK returned Error: DRV_OA_PRESET_AND_USER_FILE_NOT_LOADED [20181] during: ', msg],"Error"));
    case 20182
      uiwait(errordlg(['Andor SDK returned Error: DRV_OA_INVALID_FILE [20182] during: ', msg],"Error"));
    case 20183
      uiwait(errordlg(['Andor SDK returned Error: DRV_OA_FILE_HAS_BEEN_MODIFIED [20183] during: ', msg],"Error"));
    case 20184
      uiwait(errordlg(['Andor SDK returned Error: DRV_OA_BUFFER_FULL [20184] during: ', msg],"Error"));
    case 20185
      uiwait(errordlg(['Andor SDK returned Error: DRV_OA_INVALID_STRING_LENGTH [20185] during: ', msg],"Error"));
    case 20186
      uiwait(errordlg(['Andor SDK returned Error: DRV_OA_INVALID_CHARS_IN_NAME [20186] during: ', msg],"Error"));
    case 20187
      uiwait(errordlg(['Andor SDK returned Error: DRV_OA_INVALID_NAMING [20187] during: ', msg],"Error"));
    case 20188
      uiwait(errordlg(['Andor SDK returned Error: DRV_OA_GET_CAMERA_ERROR [20188] during: ', msg],"Error"));
    case 20189
      uiwait(errordlg(['Andor SDK returned Error: DRV_OA_MODE_ALREADY_EXISTS [20189] during: ', msg],"Error"));
    case 20190
      uiwait(errordlg(['Andor SDK returned Error: DRV_OA_STRINGS_NOT_EQUAL [20190] during: ', msg],"Error"));
    case 20191
      uiwait(errordlg(['Andor SDK returned Error: DRV_OA_NO_USER_DATA [20191] during: ', msg],"Error"));
    case 20192
      uiwait(errordlg(['Andor SDK returned Error: DRV_OA_VALUE_NOT_SUPPORTED [20192] during: ', msg],"Error"));
    case 20193
      uiwait(errordlg(['Andor SDK returned Error: DRV_OA_MODE_DOES_NOT_EXIST [20193] during: ', msg],"Error"));
    case 20194
      uiwait(errordlg(['Andor SDK returned Error: DRV_OA_CAMERA_NOT_SUPPORTED [20194] during: ', msg],"Error"));
    case 20195
      uiwait(errordlg(['Andor SDK returned Error: DRV_OA_FAILED_TO_GET_MODE [20195] during: ', msg],"Error"));
    case 20211
      uiwait(errordlg(['Andor SDK returned Error: DRV_PROCESSING_FAILED [20211] during: ', msg],"Error"));
    otherwise
      code_msg = sprintf('Andor SDK Returned Error: UNKNOWN ERROR [%d] during: ',code);
      uiwait(errordlg([code_msg, msg], "Error"));
  end
end
