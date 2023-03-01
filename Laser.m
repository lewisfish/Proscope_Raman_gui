classdef Laser
% class to control FBH diode laser for driving the Raman Spectroscopy measurements.
%
%  To talk to the laser we use the following packet protocol:
%       0th byte: The first bit sets whether to read (1) or write (0). The following 7 bits set the address
%       1st byte: This transmits the length of the packet being sent.
%       2nd byte: This transmits the command to be executed.
%       3rd and follwoing bytes: This transmits databytes. 
%       Final byte: Checksum byte (bitwise XOR of all other bytes).
%
%       Command bytes:
%                            No. of data bytes
%           command     byte   write  read      content
%    UART_ERROR         0x00     0      1       Error code
%    UART_SETUP_NO      0x03     1      1       reads or writes one of the four setup numbers
%    UART_SAVE_SETUP    0x04     0      /       Save settings into non-volitile of the module
%    UART_DEVICE_STATE  0x05     /      1       off=0, heating=1, ready=2, on=3, overtemp=4
%    UART_LASER_CURRENT 0x13     2      2       Set the laser current
%    UART_EN_HEAT_PWR   0x20     1      1       Switch on the voltage regulator for the supply of theheater current (off=0, on=1)
%    UART_I_HEAT0       0x22     2      2       Set the heater current for driver 0
%    UART_I_HEAT1       0x23     2      2       Set the heater current for driver 1
%    UART_EN_TEC        0x30     1      1       Switch on Peltier element (off=0, on=1)
%    UART_TMP           0x34     /      2       Read the actual laser temperature
%    UART_TMP_SET       0x35     2      2       Set target temperature
%
%       Error codes:
%           NO_ERROR                        0
%           ERROR_TIMEOUT_BEFORE_1st_BYTE   1
%           ERROR_TIMEOUT_BEFORE_2nd_BYTE   2
%           ERROR_NOT_ENOUGH_BYTES          3
%           ERROR_WRONG_CMD                 4
%           ERROR_CHECKSUM                  7

    properties
        Temperature {mustBeNumeric} % Target temperature of the laser. Default value is 25 C
        Current {mustBeNumeric} % Laser current. Default value is 40 mA
        HeaterCurrent {mustBeNumeric} % Current for the laser heater drivers. This value is split evenly between the two drivers. Default value is 550mA
    end
    properties (Access = private, Constant)
        % private properties used internally so that "magic numbers" are removed
        UART_ERROR        = (0x00)
        UART_SETUP_NO     = (0x03)
        UART_SAVE_SETUP   = (0x04)
        UART_DEVICE_STATE = (0x05)
        UART_LASER_CURRENT= (0x13)
        UART_EN_HEAT_PWR  = (0x20)
        UART_I_HEAT0      = (0x22)
        UART_I_HEAT1      = (0x23)
        UART_EN_TEC       = (0x30)
        UART_TMP          = (0x34)
        UART_TMP_SET      = (0x35)
        OFF               = ('00')
        ON                = ('01')
    end
    properties (Access = private)
       % private properties used internally
       SerialPort % serial port
       DigitalTemperature {mustBeNumeric}
       DigitalCurrent {mustBeNumeric}
       DigitalHeaterCurrent0 {mustBeNumeric}
       DigitalHeaterCurrent1 {mustBeNumeric}
       Errors = ["NO_ERROR", "ERROR_TIMEOUT_BEFORE_1st_BYTE", "ERROR_TIMEOUT_BEFORE_2nd_BYTE","ERROR_NOT_ENOUGH_BYTES","ERROR_WRONG_CMD","","","ERROR_CHECKSUM"]
    end
    methods
        function obj = Laser(temperature, current, heater_current)
            % Init laser. Converts input variables into "digital" variables and communicates all
            % values to the laser. Finally turns on laser.
            arguments
                % default arguments
                temperature = 25
                current = 40
                heater_current = 550
            end
            obj.Temperature = temperature;
            obj.Current = current;
            obj.HeaterCurrent = heater_current;
            % convert analogue to "digital". Conversions taken from documentation.
            obj.DigitalTemperature = (obj.Temperature * 1140) - 3207;
            obj.DigitalCurrent = obj.Current * 134.5;
            obj.DigitalHeaterCurrent0 = 218 * (obj.HeaterCurrent / 2.);
            obj.DigitalHeaterCurrent1 = 218 * (obj.HeaterCurrent / 2.);
    

            devices = IDSerialComs();
            deviceNames = devices[:, 1];
            COMPort = devices[:, 2];
            
            % open communication to the laser and set variables on device
            obj.SerialPort = serialport('COM4', 38400, 'DataBits', 8);
            % check if it is always com4 if not to write code to check for siliconlabs as per
            % datasheet
            obj.setTemperature();
            obj.setCurrent();
            obj.setHeaterCurrent();
            obj.enableTEC();
            obj.checkReady();
            obj.enableLaserHeaterPower();
        end
        function obj = setTemperature(obj)
            % Set target temperature of laser in Celcius
            msg = [0x2a, 0x06, obj.UART_TMP_SET];
            bytes_vector = obj.dec2Bytes(obj.DigitalTemperature);
            msg = [msg, bytes_vector];
            msg = [msg, obj.getChecksum(msg)];
            write(obj.SerialPort, msg,'uint8');
            data = read(obj.SerialPort,4,"uint8"); % message recieved should be 0x2a 0x04 0x35 0x1b

%             data = [0x2a, 0x05, 0x00, 0x01, 0x2a]; % dummy data with wrong checksum
%             data = [0x2a, 0x05, 0x00, 0x01, 0x2e]; % dummy data with an error code. Need to check this is actually what is produced.
%             data = [0x2a, 0x04, 0x35, 0x1b]; % dummy data
            obj.checkError(data, obj.UART_TMP_SET, 'set temperature');
        end
        
        function obj = setCurrent(obj)
            % Set the the laser current in mA
            msg = [0x2a, 0x06, obj.UART_LASER_CURRENT];
            bytes_vector = obj.dec2Bytes(obj.DigitalCurrent);
            msg = [msg, bytes_vector];
            msg = [msg, obj.getChecksum(msg)];
            write(obj.SerialPort, msg, 'uint8');
            data = read(obj.SerialPort,4,'uint8'); % message recieved should be 0x2a 0x04 0x13 0x3d
%             data = [0x2a, 0x04, 0x13, 0x3d];  % dummy data
            obj.checkError(data, obj.UART_LASER_CURRENT, 'set current');
        end
        
        function obj = setHeaterCurrent(obj)
            % Set the heater current for driver 0 and 1 in mA
            % ultimately sets the laser wavelength.
            msg = [0x2a, 0x6, obj.UART_I_HEAT0];
            bytes_vector0 = obj.dec2Bytes(obj.DigitalHeaterCurrent0);
            msg = [msg, bytes_vector0];
            msg = [msg, obj.getChecksum(msg)];
            write(obj.SerialPort, msg, 'uint8');
            data = read(obj.SerialPort,4,'uint8'); % message recieved should be 0x2a 0x04 0x22 0x0c
%             data = [0x2a, 0x04, 0x22, 0x0c];  % dummy data
            obj.checkError(data, obj.UART_I_HEAT0, 'set heater current 0');
            
   
            msg = [0x2a, 0x6, obj.UART_I_HEAT1];
            bytes_vector1 = obj.dec2Bytes(obj.DigitalHeaterCurrent1);
            msg = [msg, bytes_vector1];
            msg = [msg, obj.getChecksum(msg)];
            write(obj.SerialPort, msg, 'uint8');
            data = read(obj.SerialPort,4,'uint8'); % message recieved should be 0x2a 0x04 0x23 0x0d
%             data = [0x2a, 0x04, 0x23, 0x0d];  % dummy data
            obj.checkError(data, obj.UART_I_HEAT1, 'set heater current 1');
        end
        
        function obj = enableTEC(obj)
            % Turn on the peltier element
            msg = [0x2a, 0x05, obj.UART_EN_TEC];
            bytes = uint8(hex2dec(obj.ON));
            msg = [msg, bytes];
            msg = [msg, obj.getChecksum(msg)];
            write(obj.SerialPort, msg, 'uint8');
            data = read(obj.SerialPort,4,'uint8'); % message recieved should be 0x2a 0x04 0x30 0x1e
%             data = [0x2a, 0x04, 0x30, 0x1e]; % dummy data
            obj.checkError(data, obj.UART_EN_TEC, 'enable TEC');
        end
        
        function obj = checkReady(obj)
            % Check device is ready to be turned on. Waits until confirmation message is recieved.
            msg = [0xaa, 0x05, obj.UART_DEVICE_STATE];
            msg = [msg, obj.getChecksum(msg)];
            while 1
                write(obj.SerialPort, msg, 'uint8');
                data = read(obj.SerialPort,5,'uint8'); % message recieved should be 0xaa 0x05 0x05 0x02 0xa8
%                 data = [0xaa, 0x05, 0x05, 0x02, 0xa8]; % dummy data
                obj.checkError(data, obj.UART_DEVICE_STATE, 'check ready');

                %check message returns 0x02 at position data(4)
                if data(4) == 0x02
                    break
                end
            end
        end
                
        function obj = enableLaserHeaterPower(obj)
            % Turn on the laser heater
            msg = [0x2a, 0x05, obj.UART_EN_HEAT_PWR];
            bytes = uint8(hex2dec(obj.ON));
            msg = [msg, bytes];
            msg = [msg, obj.getChecksum(msg)];
            write(obj.SerialPort, msg, 'uint8');
            data = read(obj.SerialPort,4,'uint8'); % message recieved should be 0x2a 0x04 0x20 0x0e
%             data = [0x2a, 0x04, 0x20, 0x0e];  % dummy data
            obj.checkError(data, obj.UART_EN_HEAT_PWR, 'enable laser heater power');
        end
        
        function obj = switchOff(obj)
            % Turn off laser and heater
            msg = [0x2a, 0x05, obj.UART_EN_HEAT_PWR];
            bytes = uint8(hex2dec(obj.OFF));
            msg = [msg, bytes];
            msg = [msg, obj.getChecksum(msg)];
            write(obj.SerialPort, msg, 'uint8');
            data = read(obj.SerialPort,4,'uint8'); % message recieved should be 0x2a 0x04 0x20 0x0e
%             data = [0x2a, 0x04, 0x20, 0x0e]; % dummy data
            obj.checkError(data, obj.UART_EN_HEAT_PWR, 'disable laser heater power');

            msg = [0x2a, 0x05, obj.UART_EN_TEC];
            bytes = uint8(hex2dec(obj.OFF));
            msg = [msg, bytes];
            msg = [msg, obj.getChecksum(msg)];
            write(obj.SerialPort, msg, 'uint8');
            data = read(obj.SerialPort,4,'uint8'); % message recieved should be 0x2a 0x04 0x30 0x1e
%             data = [0x2a, 0x04, 0x30, 0x1e]; % dummy data
            obj.checkError(data, obj.UART_EN_TEC, 'disable TEC');
        end
        
        function out = getError(obj, error_code)
            % Retreive error code message
            out = obj.errors(error_code+1);
        end
        
        function obj = checkError(obj, msg, cmd, location)
           if obj.getChecksum(msg(1:length(msg)-1)) ~= msg(end)
               err_msg = sprirtf('Checksum recieved after %s is wrong',location);
               uiwait(errordlg(err_msg, "Error"));
            end
            % check if error is raised
            if msg(3) ~= cmd
                err_code = obj.get_error(msg(4));
                err_msg = sprirtf('In %s, device returned the following error: %s',location,err_code);
                uiwait(errordlg(err_msg, "Error"));
            end
        end
        
    end
    methods (Static)
        function out = dec2Bytes(val)
            % Convert decimal to hexstring then to uint8 vector
%             https://uk.mathworks.com/matlabcentral/answers/391490-how-can-i-represent-a-hexadecimal-string-in-a-128-bit-format-in-matlab
            hexstr = dec2hex(val);
            byte_hex = string(permute(reshape(hexstr, 2, 2),[2 1]))';
            out = uint8(hex2dec(byte_hex));
        end
        function checksum = getChecksum(msg)
            % Compute the checksum of a message. Carries out bitwise XOR of message e.g a^b^c^d for message msg = [a, b, c, d]
            checksum = bitxor(msg(1), msg(2));
            for n = 3:length(msg)
                checksum = bitxor(checksum, msg(n));
            end
        end
        function devices = IDSerialComs()
            % taken from here: https://uk.mathworks.com/matlabcentral/fileexchange/45675-identify-serial-com-devices-by-friendly-name-in-windows
            % IDSerialComs identifies Serial COM devices on Windows systems by friendly name
            % Searches the Windows registry for serial hardware info and returns devices,
            % a cell array where the first column holds the name of the device and the
            % second column holds the COM number. Devices returns empty if nothing is found.

            devices = [];

            Skey = 'HKEY_LOCAL_MACHINE\HARDWARE\DEVICEMAP\SERIALCOMM';
            [~, list] = dos(['REG QUERY ' Skey]);
            if ischar(list) && strcmp('ERROR',list(1:5))
                disp('Error: IDSerialComs - No SERIALCOMM registry entry')
                return;
            end
            list = strread(list,'%s','delimiter',' '); %#ok<FPARK> requires strread()
            coms = 0;
            for i = 1:numel(list)
                if strcmp(list{i}(1:3),'COM')
                    if ~iscell(coms)
                        coms = list(i);
                    else
                        coms{end+1} = list{i}; %#ok<AGROW> Loop size is always small
                    end
                end
            end
            key = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\USB\';
            [~, vals] = dos(['REG QUERY ' key ' /s /f "FriendlyName" /t "REG_SZ"']);
            if ischar(vals) && strcmp('ERROR',vals(1:5))
                disp('Error: IDSerialComs - No Enumerated USB registry entry')
                return;
            end
            vals = textscan(vals,'%s','delimiter','\t');
            vals = cat(1,vals{:});
            out = 0;
            for i = 1:numel(vals)
                if strcmp(vals{i}(1:min(12,end)),'FriendlyName')
                    if ~iscell(out)
                        out = vals(i);
                    else
                        out{end+1} = vals{i}; %#ok<AGROW> Loop size is always small
                    end
                end
            end

            for i = 1:numel(coms)
                match = strfind(out,[coms{i},')']);
                ind = 0;
                for j = 1:numel(match)
                    if ~isempty(match{j})
                        ind = j;
                    end
                end
                if ind ~= 0
                    com = str2double(coms{i}(4:end));
                    if com > 9
                        length = 8;
                    else
                        length = 7;
                    end
                    devices{i,1} = out{ind}(27:end-length); %#ok<AGROW>
                    devices{i,2} = com; %#ok<AGROW> Loop size is always small
                end
            end
        end
    end
end
