function AndorIssueWarning(code, msg)
% Converts the code returned by the SDK into an error message dialog
% AndorIssueWarning(code)
% Arguments
%     code: the return code from the SDK
%     msg: custom message to tell user where warning occured.
% Returns:
%     None

  switch(code)
    case 20001
      uiwait(warndlg(['Andor SDK returned Error: DRV_ERROR_CODES [20001] during: ', msg], "Warning"));
    case 20002
      return
    case 20003
      uiwait(warndlg(['Andor SDK returned Error: DRV_VXD_NOT_INSTALLED [20003] during: ', msg], "Warning"));
    case 20004
      uiwait(warndlg(['Andor SDK returned Error: DRV_ERROR_SCAN [20004] during: ', msg],"Warning"));
    case 20005
      uiwait(warndlg(['Andor SDK returned Error: DRV_ERROR_CHECK_SUM [20005] during: ', msg],"Warning"));
    case 20006
      uiwait(warndlg(['Andor SDK returned Error: DRV_ERROR_FILELOAD [20006] during: ', msg],"Warning"));
    case 20007
      uiwait(warndlg(['Andor SDK returned Error: DRV_UNKNOWN_FUNCTION [20007] during: ', msg],"Warning"));
    case 20008
      uiwait(warndlg(['Andor SDK returned Error: DRV_ERROR_VXD_INIT [20008] during: ', msg],"Warning"));
    case 20009
      uiwait(warndlg(['Andor SDK returned Error: DRV_ERROR_ADDRESS [20009] during: ', msg],"Warning"));
    case 20010
      uiwait(warndlg(['Andor SDK returned Error: DRV_ERROR_PAGELOCK [20010] during: ', msg],"Warning"));
    case 20011
      uiwait(warndlg(['Andor SDK returned Error: DRV_ERROR_PAGEUNLOCK [20011] during: ', msg],"Warning"));
    case 20012
      uiwait(warndlg(['Andor SDK returned Error: DRV_ERROR_BOARDTEST [20012] during: ', msg],"Warning"));
    case 20013
      uiwait(warndlg(['Andor SDK returned Error: DRV_ERROR_ACK [20013] during: ', msg],"Warning"));
    case 20014
      uiwait(warndlg(['Andor SDK returned Error: DRV_ERROR_UP_FIFO [20014] during: ', msg],"Warning"));
    case 20015
      uiwait(warndlg(['Andor SDK returned Error: DRV_ERROR_PATTERN [20015] during: ', msg],"Warning"));
    case 20017
      uiwait(warndlg(['Andor SDK returned Error: DRV_ACQUISITION_ERRORS [20017] during: ', msg],"Warning"));
    case 20018
      uiwait(warndlg(['Andor SDK returned Error: DRV_ACQ_BUFFER [20018] during: ', msg],"Warning"));
    case 20019
      uiwait(warndlg(['Andor SDK returned Error: DRV_ACQ_DOWNFIFO_FULL [20019] during: ', msg],"Warning"));
    case 20020
      uiwait(warndlg(['Andor SDK returned Error: DRV_PROC_UNKONWN_INSTRUCTION [20020] during: ', msg],"Warning"));
    case 20021
      uiwait(warndlg(['Andor SDK returned Error: DRV_ILLEGAL_OP_CODE [20021] during: ', msg],"Warning"));
    case 20022
      uiwait(warndlg(['Andor SDK returned Error: DRV_KINETIC_TIME_NOT_MET [20022] during: ', msg],"Warning"));
    case 20023
      uiwait(warndlg(['Andor SDK returned Error: DRV_ACCUM_TIME_NOT_MET [20023] during: ', msg],"Warning"));
    case 20024
      uiwait(warndlg(['Andor SDK returned Error: DRV_NO_NEW_DATA [20024] during: ', msg],"Warning"));
    case 20025
      uiwait(warndlg(['Andor SDK returned Error: DRV_PCI_DMA_FAIL [20025] during: ', msg],"Warning"));
    case 20026
      uiwait(warndlg(['Andor SDK returned Error: DRV_SPOOLERROR [20026] during: ', msg],"Warning"));
    case 20027
      uiwait(warndlg(['Andor SDK returned Error: DRV_SPOOLSETUPERROR [20027] during: ', msg],"Warning"));
    case 20028
      uiwait(warndlg(['Andor SDK returned Error: DRV_FILESIZELIMITERROR [20028] during: ', msg],"Warning"));
    case 20029
      uiwait(warndlg(['Andor SDK returned Error: DRV_ERROR_FILESAVE [20029] during: ', msg],"Warning"));
    case 20033
      uiwait(warndlg(['Andor SDK returned Error: DRV_TEMPERATURE_CODES [20033] during: ', msg],"Warning"));
    case 20034
      uiwait(warndlg(['Andor SDK returned Error: DRV_TEMPERATURE_OFF [20034] during: ', msg],"Warning"));
    case 20035
      uiwait(warndlg(['Andor SDK returned Error: DRV_TEMPERATURE_NOT_STABILIZED [20035] during: ', msg],"Warning"));
    case 20036
      uiwait(warndlg(['Andor SDK returned Error: DRV_TEMPERATURE_STABILIZED [20036] during: ', msg],"Warning"));
    case 20037
      uiwait(warndlg(['Andor SDK returned Error: DRV_TEMPERATURE_NOT_REACHED [20037] during: ', msg],"Warning"));
    case 20038
      uiwait(warndlg(['Andor SDK returned Error: DRV_TEMPERATURE_OUT_RANGE [20038] during: ', msg],"Warning"));
    case 20039
      uiwait(warndlg(['Andor SDK returned Error: DRV_TEMPERATURE_NOT_SUPPORTED [20039] during: ', msg],"Warning"));
    case 20040
      uiwait(warndlg(['Andor SDK returned Error: DRV_TEMPERATURE_DRIFT [20040] during: ', msg],"Warning"));
    case 20049
      uiwait(warndlg(['Andor SDK returned Error: DRV_GENERAL_ERRORS [20049] during: ', msg],"Warning"));
    case 20050
      uiwait(warndlg(['Andor SDK returned Error: DRV_INVALID_AUX [20050] during: ', msg],"Warning"));
    case 20051
      uiwait(warndlg(['Andor SDK returned Error: DRV_COF_NOTLOADED [20051] during: ', msg],"Warning"));
    case 20052
      uiwait(warndlg(['Andor SDK returned Error: DRV_FPGAPROG [20052] during: ', msg],"Warning"));
    case 20053
      uiwait(warndlg(['Andor SDK returned Error: DRV_FLEXERROR [20053] during: ', msg],"Warning"));
    case 20054
      uiwait(warndlg(['Andor SDK returned Error: DRV_GPIBERROR [20054] during: ', msg],"Warning"));
    case 20055
      uiwait(warndlg(['Andor SDK returned Error: DRV_EEPROMVERSIONERROR [20055] during: ', msg],"Warning"));
    case 20064
      uiwait(warndlg(['Andor SDK returned Error: DRV_DATATYPE [20064] during: ', msg],"Warning"));
    case 20065
      uiwait(warndlg(['Andor SDK returned Error: DRV_DRIVER_ERRORS [20065] during: ', msg],"Warning"));
    case 20066
      uiwait(warndlg(['Andor SDK returned Error: DRV_P1INVALID [20066] during: ', msg],"Warning"));
    case 20067
      uiwait(warndlg(['Andor SDK returned Error: DRV_P2INVALID [20067] during: ', msg],"Warning"));
    case 20068
      uiwait(warndlg(['Andor SDK returned Error: DRV_P3INVALID [20068] during: ', msg],"Warning"));
    case 20069
      uiwait(warndlg(['Andor SDK returned Error: DRV_P4INVALID [20069] during: ', msg],"Warning"));
    case 20070
      uiwait(warndlg(['Andor SDK returned Error: DRV_INIERROR [20070] during: ', msg],"Warning"));
    case 20071
      uiwait(warndlg(['Andor SDK returned Error: DRV_COFERROR [20071] during: ', msg],"Warning"));
    case 20072
      uiwait(warndlg(['Andor SDK returned Error: DRV_ACQUIRING [20072] during: ', msg],"Warning"));
    case 20073
      uiwait(warndlg(['Andor SDK returned Error: DRV_IDLE [20073] during: ', msg],"Warning"));
    case 20074
      uiwait(warndlg(['Andor SDK returned Error: DRV_TEMPCYCLE [20074] during: ', msg],"Warning"));
    case 20075
      uiwait(warndlg(['Andor SDK returned Error: DRV_NOT_INITIALIZED [20075] during: ', msg],"Warning"));
    case 20076
      uiwait(warndlg(['Andor SDK returned Error: DRV_P5INVALID [20076] during: ', msg],"Warning"));
    case 20077
      uiwait(warndlg(['Andor SDK returned Error: DRV_P6INVALID [20077] during: ', msg],"Warning"));
    case 20078
      uiwait(warndlg(['Andor SDK returned Error: DRV_INVALID_MODE [20078] during: ', msg],"Warning"));
    case 20079
      uiwait(warndlg(['Andor SDK returned Error: DRV_INVALID_FILTER [20079] during: ', msg],"Warning"));
    case 20080
      uiwait(warndlg(['Andor SDK returned Error: DRV_I2CERRORS [20080] during: ', msg],"Warning"));
    case 20081
      uiwait(warndlg(['Andor SDK returned Error: DRV_I2CDEVNOTFOUND [20081] during: ', msg],"Warning"));
    case 20082
      uiwait(warndlg(['Andor SDK returned Error: DRV_I2CTIMEOUT [20082] during: ', msg],"Warning"));
    case 20083
      uiwait(warndlg(['Andor SDK returned Error: DRV_P7INVALID [20083] during: ', msg],"Warning"));
    case 20084
      uiwait(warndlg(['Andor SDK returned Error: DRV_P8INVALID [20084] during: ', msg],"Warning"));
    case 20085
      uiwait(warndlg(['Andor SDK returned Error: DRV_P9INVALID [20085] during: ', msg],"Warning"));
    case 20086
      uiwait(warndlg(['Andor SDK returned Error: DRV_P10INVALID [20086] during: ', msg],"Warning"));
    case 20087
      uiwait(warndlg(['Andor SDK returned Error: DRV_P11INVALID [20087] during: ', msg],"Warning"));
    case 20089
      uiwait(warndlg(['Andor SDK returned Error: DRV_USBERROR [20089] during: ', msg],"Warning"));
    case 20090
      uiwait(warndlg(['Andor SDK returned Error: DRV_IOCERROR [20090] during: ', msg],"Warning"));
    case 20091
      uiwait(warndlg(['Andor SDK returned Error: DRV_VRMVERSIONERROR [20091] during: ', msg],"Warning"));
    case 20092
      uiwait(warndlg(['Andor SDK returned Error: DRV_GATESTEPERROR [20092] during: ', msg],"Warning"));
    case 20093
      uiwait(warndlg(['Andor SDK returned Error: DRV_USB_INTERRUPT_ENDPOINT_ERROR [20093] during: ', msg],"Warning"));
    case 20094
      uiwait(warndlg(['Andor SDK returned Error: DRV_RANDOM_TRACK_ERROR [20094] during: ', msg],"Warning"));
    case 20095
      uiwait(warndlg(['Andor SDK returned Error: DRV_INVALID_TRIGGER_MODE [20095] during: ', msg],"Warning"));
    case 20096
      uiwait(warndlg(['Andor SDK returned Error: DRV_LOAD_FIRMWARE_ERROR [20096] during: ', msg],"Warning"));
    case 20097
      uiwait(warndlg(['Andor SDK returned Error: DRV_DIVIDE_BY_ZERO_ERROR [20097] during: ', msg],"Warning"));
    case 20098
      uiwait(warndlg(['Andor SDK returned Error: DRV_INVALID_RINGEXPOSURES [20098] during: ', msg],"Warning"));
    case 20099
      uiwait(warndlg(['Andor SDK returned Error: DRV_BINNING_ERROR [20099] during: ', msg],"Warning"));
    case 20100
      uiwait(warndlg(['Andor SDK returned Error: DRV_INVALID_AMPLIFIER [20100] during: ', msg],"Warning"));
    case 20101
      uiwait(warndlg(['Andor SDK returned Error: DRV_INVALID_COUNTCONVERT_MODE [20101] during: ', msg],"Warning"));
    case 20990
      uiwait(warndlg(['Andor SDK returned Error: DRV_ERROR_NOCAMERA [20990] during: ', msg],"Warning"));
    case 20991
      uiwait(warndlg(['Andor SDK returned Error: DRV_NOT_SUPPORTED [20991] during: ', msg],"Warning"));
    case 20992
      uiwait(warndlg(['Andor SDK returned Error: DRV_NOT_AVAILABLE [20992] during: ', msg],"Warning"));
    case 20115
      uiwait(warndlg(['Andor SDK returned Error: DRV_ERROR_MAP [20115] during: ', msg],"Warning"));
    case 20116
      uiwait(warndlg(['Andor SDK returned Error: DRV_ERROR_UNMAP [20116] during: ', msg],"Warning"));
    case 20117
      uiwait(warndlg(['Andor SDK returned Error: DRV_ERROR_MDL [20117] during: ', msg],"Warning"));
    case 20118
      uiwait(warndlg(['Andor SDK returned Error: DRV_ERROR_UNMDL [20118] during: ', msg],"Warning"));
    case 20119
      uiwait(warndlg(['Andor SDK returned Error: DRV_ERROR_BUFFSIZE [20119] during: ', msg],"Warning"));
    case 20121
      uiwait(warndlg(['Andor SDK returned Error: DRV_ERROR_NOHANDLE [20121] during: ', msg],"Warning"));
    case 20130
      uiwait(warndlg(['Andor SDK returned Error: DRV_GATING_NOT_AVAILABLE [20130] during: ', msg],"Warning"));
    case 20131
      uiwait(warndlg(['Andor SDK returned Error: DRV_FPGA_VOLTAGE_ERROR [20131] during: ', msg],"Warning"));
    case 20150
      uiwait(warndlg(['Andor SDK returned Error: DRV_OW_CMD_FAIL [20150] during: ', msg],"Warning"));
    case 20151
      uiwait(warndlg(['Andor SDK returned Error: DRV_OWMEMORY_BAD_ADDR [20151] during: ', msg],"Warning"));
    case 20152
      uiwait(warndlg(['Andor SDK returned Error: DRV_OWCMD_NOT_AVAILABLE [20152] during: ', msg],"Warning"));
    case 20153
      uiwait(warndlg(['Andor SDK returned Error: DRV_OW_NO_SLAVES [20153] during: ', msg],"Warning"));
    case 20154
      uiwait(warndlg(['Andor SDK returned Error: DRV_OW_NOT_INITIALIZED [20154] during: ', msg],"Warning"));
    case 20155
      uiwait(warndlg(['Andor SDK returned Error: DRV_OW_ERROR_SLAVE_NUM [20155] during: ', msg],"Warning"));
    case 20156
      uiwait(warndlg(['Andor SDK returned Error: DRV_MSTIMINGS_ERROR [20156] during: ', msg],"Warning"));
    case 20173
      uiwait(warndlg(['Andor SDK returned Error: DRV_OA_NULL_ERROR [20173] during: ', msg],"Warning"));
    case 20174
      uiwait(warndlg(['Andor SDK returned Error: DRV_OA_PARSE_DTD_ERROR [20174] during: ', msg],"Warning"));
    case 20175
      uiwait(warndlg(['Andor SDK returned Error: DRV_OA_DTD_VALIDATE_ERROR [20175] during: ', msg],"Warning"));
    case 20176
      uiwait(warndlg(['Andor SDK returned Error: DRV_OA_FILE_ACCESS_ERROR [20176] during: ', msg],"Warning"));
    case 20177
      uiwait(warndlg(['Andor SDK returned Error: DRV_OA_FILE_DOES_NOT_EXIST [20177] during: ', msg],"Warning"));
    case 20178
      uiwait(warndlg(['Andor SDK returned Error: DRV_OA_XML_INVALID_OR_NOT_FOUND_ERROR [20178] during: ', msg],"Warning"));
    case 20179
      uiwait(warndlg(['Andor SDK returned Error: DRV_OA_PRESET_FILE_NOT_LOADED [20179] during: ', msg],"Warning"));
    case 20180
      uiwait(warndlg(['Andor SDK returned Error: DRV_OA_USER_FILE_NOT_LOADED [20180] during: ', msg],"Warning"));
    case 20181
      uiwait(warndlg(['Andor SDK returned Error: DRV_OA_PRESET_AND_USER_FILE_NOT_LOADED [20181] during: ', msg],"Warning"));
    case 20182
      uiwait(warndlg(['Andor SDK returned Error: DRV_OA_INVALID_FILE [20182] during: ', msg],"Warning"));
    case 20183
      uiwait(warndlg(['Andor SDK returned Error: DRV_OA_FILE_HAS_BEEN_MODIFIED [20183] during: ', msg],"Warning"));
    case 20184
      uiwait(warndlg(['Andor SDK returned Error: DRV_OA_BUFFER_FULL [20184] during: ', msg],"Warning"));
    case 20185
      uiwait(warndlg(['Andor SDK returned Error: DRV_OA_INVALID_STRING_LENGTH [20185] during: ', msg],"Warning"));
    case 20186
      uiwait(warndlg(['Andor SDK returned Error: DRV_OA_INVALID_CHARS_IN_NAME [20186] during: ', msg],"Warning"));
    case 20187
      uiwait(warndlg(['Andor SDK returned Error: DRV_OA_INVALID_NAMING [20187] during: ', msg],"Warning"));
    case 20188
      uiwait(warndlg(['Andor SDK returned Error: DRV_OA_GET_CAMERA_ERROR [20188] during: ', msg],"Warning"));
    case 20189
      uiwait(warndlg(['Andor SDK returned Error: DRV_OA_MODE_ALREADY_EXISTS [20189] during: ', msg],"Warning"));
    case 20190
      uiwait(warndlg(['Andor SDK returned Error: DRV_OA_STRINGS_NOT_EQUAL [20190] during: ', msg],"Warning"));
    case 20191
      uiwait(warndlg(['Andor SDK returned Error: DRV_OA_NO_USER_DATA [20191] during: ', msg],"Warning"));
    case 20192
      uiwait(warndlg(['Andor SDK returned Error: DRV_OA_VALUE_NOT_SUPPORTED [20192] during: ', msg],"Warning"));
    case 20193
      uiwait(warndlg(['Andor SDK returned Error: DRV_OA_MODE_DOES_NOT_EXIST [20193] during: ', msg],"Warning"));
    case 20194
      uiwait(warndlg(['Andor SDK returned Error: DRV_OA_CAMERA_NOT_SUPPORTED [20194] during: ', msg],"Warning"));
    case 20195
      uiwait(warndlg(['Andor SDK returned Error: DRV_OA_FAILED_TO_GET_MODE [20195] during: ', msg],"Warning"));
    case 20211
      uiwait(warndlg(['Andor SDK returned Error: DRV_PROCESSING_FAILED [20211] during: ', msg],"Warning"));
    otherwise
      code_msg = sprintf('Andor SDK Returned Error: UNKNOWN WARNING [%d] during: ',code);
      uiwait(warndlg([code_msg, msg], "Warning"));
  end
end
