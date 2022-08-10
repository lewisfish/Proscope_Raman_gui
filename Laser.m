classdef Laser
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

%       Error codes:
%           NO_ERROR                        0
%           ERROR_TIMEOUT_BEFORE_1st_BYTE   1
%           ERROR_TIMEOUT_BEFORE_2nd_BYTE   2
%           ERROR_NOT_ENOUGH_BYTES          3
%           ERROR_WRONG_CMD                 4
%           ERROR_CHECKSUM                  7

    properties
        temperature {mustBeNumeric} % 25 C
        current {mustBeNumeric} % 40 mA
        heater_current {mustBeNumeric} % 550mA
    end
    properties %(Access = private)
       sport
       digital_temperature {mustBeNumeric}
       digital_current {mustBeNumeric}
       digital_heater_current0 {mustBeNumeric}
       digital_heater_current1 {mustBeNumeric}
       errors = ["NO_ERROR", "ERROR_TIMEOUT_BEFORE_1st_BYTE", "ERROR_TIMEOUT_BEFORE_2nd_BYTE","ERROR_NOT_ENOUGH_BYTES","ERROR_WRONG_CMD","","","ERROR_CHECKSUM"]
    end
    methods
        function obj = Laser(temperature, current, heater_current)
            arguments
                temperature = 25
                current = 40
                heater_current = 550
            end
            obj.temperature = temperature;
            obj.current = current;
            obj.heater_current = heater_current;
            obj.digital_temperature = (obj.temperature * 1140) - 3207;
            obj.digital_current = obj.current * 134.5;
            obj.digital_heater_current0 = 218 * (obj.heater_current / 2.);
            obj.digital_heater_current1 = 218 * (obj.heater_current / 2.);

            %obj.sport = serialport('COM6', 38400, 'DataBits', 8);
            obj.set_temp();
            %obj.set_current();
            %obj.set_heater_current();
        end
        function obj = set_temp(obj)
            msg = [0x2a, 0x06, 0x35];
            bytes_vector = obj.dec2bytes(obj.digital_temperature);
            msg = [msg, bytes_vector];
            msg = [msg, obj.get_checksum(msg)];
            %write(obj.sport, msg,'uint8');
            data = read(obj.sport,4,"uint8");
        end
        
        
        
        function obj = get_error(obj, error_code)
            error(obj.errors(error_code+1));
        end
    end
    methods (Static)
        function out = dec2bytes(val)
%             https://uk.mathworks.com/matlabcentral/answers/391490-how-can-i-represent-a-hexadecimal-string-in-a-128-bit-format-in-matlab
            hexstr = dec2hex(val);
            byte_hex = string(permute(reshape(hexstr, 2, 2),[2 1]))';
            out = uint8(hex2dec(byte_hex));
        end
        function checksum = get_checksum(msg)
            checksum = bitxor(msg(1), msg(2));
            for n = 3:length(msg)
                checksum = bitxor(checksum, msg(n));
            end
        end
    end
end
