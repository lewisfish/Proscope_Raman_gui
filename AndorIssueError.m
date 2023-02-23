function AndorIssueError(code)
% Converts the code returned by the SDK into an error message dialog
% CheckError(code)
% Arguments
%     code: the return code from the SDK
% Returns:
%     None

  switch(code)
    case 20001
      uiwait(errordlg('Andor SDK returned Error: DRV_ERROR_CODES [20001]',"Error"));
    case 20002
      return
    case 20003
      uiwait(errordlg('Andor SDK returned Error: DRV_VXD_NOT_INSTALLED [20003]',"Error"));
    case 20004
      uiwait(errordlg('Andor SDK returned Error: DRV_ERROR_SCAN [20004]',"Error"));
    case 20005
      uiwait(errordlg('Andor SDK returned Error: DRV_ERROR_CHECK_SUM [20005]',"Error"));
    case 20006
      uiwait(errordlg('Andor SDK returned Error: DRV_ERROR_FILELOAD [20006]',"Error"));
    case 20007
      uiwait(errordlg('Andor SDK returned Error: DRV_UNKNOWN_FUNCTION [20007]',"Error"));
    case 20008
      uiwait(errordlg('Andor SDK returned Error: DRV_ERROR_VXD_INIT [20008]',"Error"));
    case 20009
      uiwait(errordlg('Andor SDK returned Error: DRV_ERROR_ADDRESS [20009]',"Error"));
    case 20010
      uiwait(errordlg('Andor SDK returned Error: DRV_ERROR_PAGELOCK [20010]',"Error"));
    case 20011
      uiwait(errordlg('Andor SDK returned Error: DRV_ERROR_PAGEUNLOCK [20011]',"Error"));
    case 20012
      uiwait(errordlg('Andor SDK returned Error: DRV_ERROR_BOARDTEST [20012]',"Error"));
    case 20013
      uiwait(errordlg('Andor SDK returned Error: DRV_ERROR_ACK [20013]',"Error"));
    case 20014
      uiwait(errordlg('Andor SDK returned Error: DRV_ERROR_UP_FIFO [20014]',"Error"));
    case 20015
      uiwait(errordlg('Andor SDK returned Error: DRV_ERROR_PATTERN [20015]',"Error"));
    case 20017
      uiwait(errordlg('Andor SDK returned Error: DRV_ACQUISITION_ERRORS [20017]',"Error"));
    case 20018
      uiwait(errordlg('Andor SDK returned Error: DRV_ACQ_BUFFER [20018]',"Error"));
    case 20019
      uiwait(errordlg('Andor SDK returned Error: DRV_ACQ_DOWNFIFO_FULL [20019]',"Error"));
    case 20020
      uiwait(errordlg('Andor SDK returned Error: DRV_PROC_UNKONWN_INSTRUCTION [20020]',"Error"));
    case 20021
      uiwait(errordlg('Andor SDK returned Error: DRV_ILLEGAL_OP_CODE [20021]',"Error"));
    case 20022
      uiwait(errordlg('Andor SDK returned Error: DRV_KINETIC_TIME_NOT_MET [20022]',"Error"));
    case 20023
      uiwait(errordlg('Andor SDK returned Error: DRV_ACCUM_TIME_NOT_MET [20023]',"Error"));
    case 20024
      uiwait(errordlg('Andor SDK returned Error: DRV_NO_NEW_DATA [20024]',"Error"));
    case 20025
      uiwait(errordlg('Andor SDK returned Error: DRV_PCI_DMA_FAIL [20025]',"Error"));
    case 20026
      uiwait(errordlg('Andor SDK returned Error: DRV_SPOOLERROR [20026]',"Error"));
    case 20027
      uiwait(errordlg('Andor SDK returned Error: DRV_SPOOLSETUPERROR [20027]',"Error"));
    case 20028
      uiwait(errordlg('Andor SDK returned Error: DRV_FILESIZELIMITERROR [20028]',"Error"));
    case 20029
      uiwait(errordlg('Andor SDK returned Error: DRV_ERROR_FILESAVE [20029]',"Error"));
    case 20033
      uiwait(errordlg('Andor SDK returned Error: DRV_TEMPERATURE_CODES [20033]',"Error"));
    case 20034
      uiwait(errordlg('Andor SDK returned Error: DRV_TEMPERATURE_OFF [20034]',"Error"));
    case 20035
      uiwait(errordlg('Andor SDK returned Error: DRV_TEMPERATURE_NOT_STABILIZED [20035]',"Error"));
    case 20036
      uiwait(errordlg('Andor SDK returned Error: DRV_TEMPERATURE_STABILIZED [20036]',"Error"));
    case 20037
      uiwait(errordlg('Andor SDK returned Error: DRV_TEMPERATURE_NOT_REACHED [20037]',"Error"));
    case 20038
      uiwait(errordlg('Andor SDK returned Error: DRV_TEMPERATURE_OUT_RANGE [20038]',"Error"));
    case 20039
      uiwait(errordlg('Andor SDK returned Error: DRV_TEMPERATURE_NOT_SUPPORTED [20039]',"Error"));
    case 20040
      uiwait(errordlg('Andor SDK returned Error: DRV_TEMPERATURE_DRIFT [20040]',"Error"));
    case 20049
      uiwait(errordlg('Andor SDK returned Error: DRV_GENERAL_ERRORS [20049]',"Error"));
    case 20050
      uiwait(errordlg('Andor SDK returned Error: DRV_INVALID_AUX [20050]',"Error"));
    case 20051
      uiwait(errordlg('Andor SDK returned Error: DRV_COF_NOTLOADED [20051]',"Error"));
    case 20052
      uiwait(errordlg('Andor SDK returned Error: DRV_FPGAPROG [20052]',"Error"));
    case 20053
      uiwait(errordlg('Andor SDK returned Error: DRV_FLEXERROR [20053]',"Error"));
    case 20054
      uiwait(errordlg('Andor SDK returned Error: DRV_GPIBERROR [20054]',"Error"));
    case 20055
      uiwait(errordlg('Andor SDK returned Error: DRV_EEPROMVERSIONERROR [20055]',"Error"));
    case 20064
      uiwait(errordlg('Andor SDK returned Error: DRV_DATATYPE [20064]',"Error"));
    case 20065
      uiwait(errordlg('Andor SDK returned Error: DRV_DRIVER_ERRORS [20065]',"Error"));
    case 20066
      uiwait(errordlg('Andor SDK returned Error: DRV_P1INVALID [20066]',"Error"));
    case 20067
      uiwait(errordlg('Andor SDK returned Error: DRV_P2INVALID [20067]',"Error"));
    case 20068
      uiwait(errordlg('Andor SDK returned Error: DRV_P3INVALID [20068]',"Error"));
    case 20069
      uiwait(errordlg('Andor SDK returned Error: DRV_P4INVALID [20069]',"Error"));
    case 20070
      uiwait(errordlg('Andor SDK returned Error: DRV_INIERROR [20070]',"Error"));
    case 20071
      uiwait(errordlg('Andor SDK returned Error: DRV_COFERROR [20071]',"Error"));
    case 20072
      uiwait(errordlg('Andor SDK returned Error: DRV_ACQUIRING [20072]',"Error"));
    case 20073
      uiwait(errordlg('Andor SDK returned Error: DRV_IDLE [20073]',"Error"));
    case 20074
      uiwait(errordlg('Andor SDK returned Error: DRV_TEMPCYCLE [20074]',"Error"));
    case 20075
      uiwait(errordlg('Andor SDK returned Error: DRV_NOT_INITIALIZED [20075]',"Error"));
    case 20076
      uiwait(errordlg('Andor SDK returned Error: DRV_P5INVALID [20076]',"Error"));
    case 20077
      uiwait(errordlg('Andor SDK returned Error: DRV_P6INVALID [20077]',"Error"));
    case 20078
      uiwait(errordlg('Andor SDK returned Error: DRV_INVALID_MODE [20078]',"Error"));
    case 20079
      uiwait(errordlg('Andor SDK returned Error: DRV_INVALID_FILTER [20079]',"Error"));
    case 20080
      uiwait(errordlg('Andor SDK returned Error: DRV_I2CERRORS [20080]',"Error"));
    case 20081
      uiwait(errordlg('Andor SDK returned Error: DRV_I2CDEVNOTFOUND [20081]',"Error"));
    case 20082
      uiwait(errordlg('Andor SDK returned Error: DRV_I2CTIMEOUT [20082]',"Error"));
    case 20083
      uiwait(errordlg('Andor SDK returned Error: DRV_P7INVALID [20083]',"Error"));
    case 20084
      uiwait(errordlg('Andor SDK returned Error: DRV_P8INVALID [20084]',"Error"));
    case 20085
      uiwait(errordlg('Andor SDK returned Error: DRV_P9INVALID [20085]',"Error"));
    case 20086
      uiwait(errordlg('Andor SDK returned Error: DRV_P10INVALID [20086]',"Error"));
    case 20087
      uiwait(errordlg('Andor SDK returned Error: DRV_P11INVALID [20087]',"Error"));
    case 20089
      uiwait(errordlg('Andor SDK returned Error: DRV_USBERROR [20089]',"Error"));
    case 20090
      uiwait(errordlg('Andor SDK returned Error: DRV_IOCERROR [20090]',"Error"));
    case 20091
      uiwait(errordlg('Andor SDK returned Error: DRV_VRMVERSIONERROR [20091]',"Error"));
    case 20092
      uiwait(errordlg('Andor SDK returned Error: DRV_GATESTEPERROR [20092]',"Error"));
    case 20093
      uiwait(errordlg('Andor SDK returned Error: DRV_USB_INTERRUPT_ENDPOINT_ERROR [20093]',"Error"));
    case 20094
      uiwait(errordlg('Andor SDK returned Error: DRV_RANDOM_TRACK_ERROR [20094]',"Error"));
    case 20095
      uiwait(errordlg('Andor SDK returned Error: DRV_INVALID_TRIGGER_MODE [20095]',"Error"));
    case 20096
      uiwait(errordlg('Andor SDK returned Error: DRV_LOAD_FIRMWARE_ERROR [20096]',"Error"));
    case 20097
      uiwait(errordlg('Andor SDK returned Error: DRV_DIVIDE_BY_ZERO_ERROR [20097]',"Error"));
    case 20098
      uiwait(errordlg('Andor SDK returned Error: DRV_INVALID_RINGEXPOSURES [20098]',"Error"));
    case 20099
      uiwait(errordlg('Andor SDK returned Error: DRV_BINNING_ERROR [20099]',"Error"));
    case 20100
      uiwait(errordlg('Andor SDK returned Error: DRV_INVALID_AMPLIFIER [20100]',"Error"));
    case 20101
      uiwait(errordlg('Andor SDK returned Error: DRV_INVALID_COUNTCONVERT_MODE [20101]',"Error"));
    case 20990
      uiwait(errordlg('Andor SDK returned Error: DRV_ERROR_NOCAMERA [20990]',"Error"));
    case 20991
      uiwait(errordlg('Andor SDK returned Error: DRV_NOT_SUPPORTED [20991]',"Error"));
    case 20992
      uiwait(errordlg('Andor SDK returned Error: DRV_NOT_AVAILABLE [20992]',"Error"));
    case 20115
      uiwait(errordlg('Andor SDK returned Error: DRV_ERROR_MAP [20115]',"Error"));
    case 20116
      uiwait(errordlg('Andor SDK returned Error: DRV_ERROR_UNMAP [20116]',"Error"));
    case 20117
      uiwait(errordlg('Andor SDK returned Error: DRV_ERROR_MDL [20117]',"Error"));
    case 20118
      uiwait(errordlg('Andor SDK returned Error: DRV_ERROR_UNMDL [20118]',"Error"));
    case 20119
      uiwait(errordlg('Andor SDK returned Error: DRV_ERROR_BUFFSIZE [20119]',"Error"));
    case 20121
      uiwait(errordlg('Andor SDK returned Error: DRV_ERROR_NOHANDLE [20121]',"Error"));
    case 20130
      uiwait(errordlg('Andor SDK returned Error: DRV_GATING_NOT_AVAILABLE [20130]',"Error"));
    case 20131
      uiwait(errordlg('Andor SDK returned Error: DRV_FPGA_VOLTAGE_ERROR [20131]',"Error"));
    case 20150
      uiwait(errordlg('Andor SDK returned Error: DRV_OW_CMD_FAIL [20150]',"Error"));
    case 20151
      uiwait(errordlg('Andor SDK returned Error: DRV_OWMEMORY_BAD_ADDR [20151]',"Error"));
    case 20152
      uiwait(errordlg('Andor SDK returned Error: DRV_OWCMD_NOT_AVAILABLE [20152]',"Error"));
    case 20153
      uiwait(errordlg('Andor SDK returned Error: DRV_OW_NO_SLAVES [20153]',"Error"));
    case 20154
      uiwait(errordlg('Andor SDK returned Error: DRV_OW_NOT_INITIALIZED [20154]',"Error"));
    case 20155
      uiwait(errordlg('Andor SDK returned Error: DRV_OW_ERROR_SLAVE_NUM [20155]',"Error"));
    case 20156
      uiwait(errordlg('Andor SDK returned Error: DRV_MSTIMINGS_ERROR [20156]',"Error"));
    case 20173
      uiwait(errordlg('Andor SDK returned Error: DRV_OA_NULL_ERROR [20173]',"Error"));
    case 20174
      uiwait(errordlg('Andor SDK returned Error: DRV_OA_PARSE_DTD_ERROR [20174]',"Error"));
    case 20175
      uiwait(errordlg('Andor SDK returned Error: DRV_OA_DTD_VALIDATE_ERROR [20175]',"Error"));
    case 20176
      uiwait(errordlg('Andor SDK returned Error: DRV_OA_FILE_ACCESS_ERROR [20176]',"Error"));
    case 20177
      uiwait(errordlg('Andor SDK returned Error: DRV_OA_FILE_DOES_NOT_EXIST [20177]',"Error"));
    case 20178
      uiwait(errordlg('Andor SDK returned Error: DRV_OA_XML_INVALID_OR_NOT_FOUND_ERROR [20178]',"Error"));
    case 20179
      uiwait(errordlg('Andor SDK returned Error: DRV_OA_PRESET_FILE_NOT_LOADED [20179]',"Error"));
    case 20180
      uiwait(errordlg('Andor SDK returned Error: DRV_OA_USER_FILE_NOT_LOADED [20180]',"Error"));
    case 20181
      uiwait(errordlg('Andor SDK returned Error: DRV_OA_PRESET_AND_USER_FILE_NOT_LOADED [20181]',"Error"));
    case 20182
      uiwait(errordlg('Andor SDK returned Error: DRV_OA_INVALID_FILE [20182]',"Error"));
    case 20183
      uiwait(errordlg('Andor SDK returned Error: DRV_OA_FILE_HAS_BEEN_MODIFIED [20183]',"Error"));
    case 20184
      uiwait(errordlg('Andor SDK returned Error: DRV_OA_BUFFER_FULL [20184]',"Error"));
    case 20185
      uiwait(errordlg('Andor SDK returned Error: DRV_OA_INVALID_STRING_LENGTH [20185]',"Error"));
    case 20186
      uiwait(errordlg('Andor SDK returned Error: DRV_OA_INVALID_CHARS_IN_NAME [20186]',"Error"));
    case 20187
      uiwait(errordlg('Andor SDK returned Error: DRV_OA_INVALID_NAMING [20187]',"Error"));
    case 20188
      uiwait(errordlg('Andor SDK returned Error: DRV_OA_GET_CAMERA_ERROR [20188]',"Error"));
    case 20189
      uiwait(errordlg('Andor SDK returned Error: DRV_OA_MODE_ALREADY_EXISTS [20189]',"Error"));
    case 20190
      uiwait(errordlg('Andor SDK returned Error: DRV_OA_STRINGS_NOT_EQUAL [20190]',"Error"));
    case 20191
      uiwait(errordlg('Andor SDK returned Error: DRV_OA_NO_USER_DATA [20191]',"Error"));
    case 20192
      uiwait(errordlg('Andor SDK returned Error: DRV_OA_VALUE_NOT_SUPPORTED [20192]',"Error"));
    case 20193
      uiwait(errordlg('Andor SDK returned Error: DRV_OA_MODE_DOES_NOT_EXIST [20193]',"Error"));
    case 20194
      uiwait(errordlg('Andor SDK returned Error: DRV_OA_CAMERA_NOT_SUPPORTED [20194]',"Error"));
    case 20195
      uiwait(errordlg('Andor SDK returned Error: DRV_OA_FAILED_TO_GET_MODE [20195]',"Error"));
    case 20211
      uiwait(errordlg('Andor SDK returned Error: DRV_PROCESSING_FAILED [20211]',"Error"));
    otherwise
      msg = sprintf('Andor SDK Returned Error: UNKNOWN ERROR [%d]',code);
      uiwait(warndlg(msg, "Warning"));
  end
end
