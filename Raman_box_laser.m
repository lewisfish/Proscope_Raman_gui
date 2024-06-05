classdef Raman_box_laser < handle
    properties (Access = private)
        SerialPort
        Current_mesg
    end
    properties (Access = private, Constant)
        % private properties used internally so that "magic numbers" are removed
        % operation mode statuses returned by the MCM command.
        APC_CM_MODE        = 30
        ACC_CM_MODE        = 10
        MODULATION_CM_MODE = 11
        LASER_OFF_OP_MODE  = 40
        LASER_ON_OP_MODE   = 10
        % Monitoring Commands
        ALARM_STAT                 = "MAL"  % integer value. convert to binary. only 7 bits?
        OPERATION_MODE_STAT        = "MCM"  % operating mode of laser. in format [CM_mode][OP_mode]
        OUTPUT_POWER               = "MPO"  % actual optical power in integer mW
        REF_OUTPUT_POWER           = "MPR"  % laser output power in integer mW
        LASER_BIAS                 = "MBC"  % actual laser current in integer mA
        LASER_TEMP                 = "MTT"  % actual laser temp expressed as XX.X degC
        CASE_TEMP                  = "MCT"  % actual case temp expressed as XX.X degC
        MAX_OPTICAL_PWR            = "MPOH" % max optical power in integer mW
        MIN_OPTICAL_PWR            = "MPOL" % min optical power in integer mW
        REF_BIAS                   = "MBR"  % bias current set point lof laser in integer mA (only used in ACC mode)
        REF_LASER_TEMP             = "MTR"  % set point temp of laser in XX.X degC
        LASER_TEC_LOW_TEMP_ALARM   = "MATL" % low temp alarm set point of the laser TEV in XX.X degC (temp below this shuts laser down)
        LASER_TEC_HIGH_TEMP_ALARM  = "MATH" % high temp alarm set point of the laser TEV in XX.X degC (temp above this shuts laser down)
        LASER_TEC_TEMP_ALARM_DELTA = "MADT" % alarm delta temperature of the laser TEC in XX.X degC (if laser temp deviates by this amount it causes an alarm)
        PD_CURRENT                 = "MPD"  % laser photo diode current in uA.
        % Settings commands
        ACC_MODE          = "SACC"
        APC_MODE          = "SAPC"
        LASER_ON          = "SALO"
        LASER_OFF         = "SALS"
        MODLATION_ON      = "SAMN"
        MODULATION_OFF    = "SAMF"
        OPTICAL_REF_POWER = "SPRXXX"  % integer power in mW
        REF_BIAS_CURRENT  = "SBRXXXX" % integer mA
        ALARM_TEMP_DELTA  = "SADTXX.X" % XX.X degC
    end
    
    methods
        function obj = Raman_box_laser()
            
           obj.connect_to_laser();
           % set mode to APC
           obj.send_cmd(obj.APC_MODE);
           % set power
           obj.set_power(100) % mW

           % turn on laser
           obj.send_cmd(obj.LASER_ON);

           pause(10);
           obj.read_power();

           % turn off laser
           obj.turn_off();
        end
       
        function obj = connect_to_laser(obj)
            % get all serial devices
            devices = obj.IDSerialComs();
            deviceNames = devices(:, 1);
            COMPorts = devices(:, 2);

            % loop over devices and get the correct COM Port
            for i = 1:size(deviceNames)
                name = deviceNames{i};
                if name == "Silicon Labs CP210x USB to UART Bridge"
                    id = i;
                    break
                end
            end

            COMPort = sprintf('COM%d', COMPorts{id});

            obj.SerialPort = serialport(COMPort, 9600, "DataBits", 8, "FlowControl", "software", "Parity", "none", "StopBits", 1);
            % Send <CR> to laser to check connection
            % TODO check it actually returns the valid message e.g "\r\n>"
            write(obj.SerialPort, char(13), "char");
            pause(100/1000);
            disp(obj.SerialPort.NumBytesAvailable);
            data = read(obj.SerialPort, obj.SerialPort.NumBytesAvailable, "char");
        end 

        function obj = turn_off(obj)

            obj.send_cmd(obj.LASER_OFF);
            clear obj.SerialPort;
        end

        function obj = set_power(obj, power)
            msg = replace(obj.OPTICAL_REF_POWER, "XXX", num2str(power, "%3i"));
            obj.send_cmd(msg);
            
        end
        
        function obj = read_power(obj)
            msg = obj.OUTPUT_POWER;
            obj.send_cmd(msg);
            data = read(obj.SerialPort, obj.SerialPort.NumBytesAvailable, "char");
            disp(data);
        end

        function obj = check_error(obj, msg)

            tf = contains(msg, "E0");
            if(tf)
                uiwait(errordlg("Command not recogonised!", "Error"));
            end

            tf = contains(msg, "E1");
            if(tf)
                err_msg = sprirtf('Out of range setting! %s', msg);
                uiwait(errordlg(err_msg, "Error"));
            end
        end
       
        function obj = send_cmd(obj, msg)
            for i = 1:length(msg)
                write(obj.SerialPort, msg(i), "char");
                pause(100/1000);
                if obj.SerialPort.NumBytesAvailable < 1
                    % TODO make a loop here that waits for bytes to be available
                    % add a timeout?
                    disp("fuck!");
                end
                data = read(obj.SerialPort, obj.SerialPort.NumBytesAvailable, "char");
                if data ~= msg(i)
                    err_msg = "Laser did not recieve expected command. Please try again.";
                    uiwait(errordlg(err_msg, "Error"))
                    return              
                end
            end
            write(obj.SerialPort, char(13), "char");
            pause(100/1000);
            data = read(obj.SerialPort, obj.SerialPort.NumBytesAvailable, "char");
            disp(data);
            %TODO check this msg
        end

    end
    methods (Static)

        function devices = IDSerialComs()
            % taken from here: https://uk.mathworks.com/matlabcentral/fileexchange/45675-identify-serial-com-devices-by-friendly-name-in-windows
            % IDSerialComs identifies Serial COM devices on Windows systems by friendly name
            % Searches the Windows registry for serial hardware info and returns devices,
            % a cell array where the first column holds the name of the device and the
            % second column holds the COM number. Devices returns empty if nothing is found.

            devices = [];

            Skey = 'HKEY_LOCAL_MACHINE\HARDWARE\DEVICEMAP\SERIALCOMM';
            [~, list] = dos(['REG QUERY ' Skey]);
            if size(list,2) == 1
               return 
            end
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