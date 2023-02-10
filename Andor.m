classdef Andor
    
    properties
    
    end
    properties (Access = private, Constant)
        % private properties used internally so that "magic numbers" are removed
        % Read Modes
        FVB         = 1
        MultiTrack  = 2
        RandomTrack = 3
        SingleTrack = 4
        Image       = 5
        % Acquisition Modes
        SingleScan   = 1
        Accumulate   = 2
        Kinetics     = 3
        FastKinetics = 4
        RunTillAbort = 5
        % Trigger Modes
        Internal = 1
        External = 2
        ExternalStart = 3
        ExternalExposure = 4
        ExternalFVBEM = 5
        Software = 6
    end
    properties (Access = private)
       % private properties used internally
       CCDTemp
       AquistionMode
       ExposureTime
       ReadMode
       TriggerMode
       PreAmpGain
    end
    
    methods
        function obj = Andor(CCDTemp, AquistionMode, ExposureTime, ReadMode, TriggerMode, PreAmpGain)
            arguments
                CCDTemp = -70.0
                AquistionMode = 1
                ExposureTime = 5 %seconds
                ReadMode = 0 % FVB
                TriggerMode = 1
                PreAmpGain = 1
            end
            addpath("Andor/");
            
            obj.AquistionMode = AquistionMode;
            obj.ExposureTime = ExposureTime;
            obj.ReadMode = ReadMode;
            obj.TriggerMode = TriggerMode;
            obj.PreAmpGain = PreAmpGain;

            ret = AndorInitialize('');
            CheckError(ret);
            
            [ret] = CoolerON();
            CheckWarning(ret);
            
            [ret, minTemp, maxTemp] = GetTemperatureRange();
            CheckWarning(ret);
            if obj.CCDTemp < minTemp || obj.CCDTemp > maxTemp
                obj.CCDTemp = -70.0;
            else
                obj.CCDTemp = CCDTemp;
            end
            % make this seperate function
            ret = setTemperarture(obj.CCDTemp);
            CheckWarning(ret);
            [ret, temp] = GetTemperature();
            while ret ~= atmcd.DRV_TEMPERATURE_STABALIZED
                msg = num2str(temp);
                fprintf(msg);
                pause(1);
                [ret, temp] = GetTemperature();
                if ret == atmcd.DRV_NOT_INITIALIZED || ret == atmcd.DRV_ACQUIRING || ret == atmcd.DRV_ERROR_ACK || ret == atmcd.DRV_TEMPERATURE_OFF
                    warning('Temperature setting error occured!')
                    break;
                end
            end

            % make function(s) for aquisition loop
            % make function for shutdown
            % check for crash hadling in matlab
                % try catch exits so use this.
            
            [ret]=SetAcquisitionMode(obj.AquistionMode);                  %   Set acquisition mode; 1 for Single Scan
            CheckWarning(ret);
            [ret]=SetExposureTime(obj.ExposureTime);                  %   Set exposure time in second
            CheckWarning(ret);
            [ret]=SetReadMode(obj.ReadMode);                         %   Set read mode; 4 for FVB
            CheckWarning(ret);
            [ret]=SetTriggerMode(obj.TriggerMode);                      %   Set internal trigger mode
            CheckWarning(ret);
            [ret]=SetShutter(1, 1, 0, 0);                 %   Open Shutter
            CheckWarning(ret);
            [ret,XPixels, YPixels]=GetDetector();         %   Get the CCD size
            CheckWarning(ret);
            [ret]=SetImage(1, 1, 1, XPixels, 1, YPixels); %   Set the image size
            CheckWarning(ret);

            
            disp('Starting Acquisition');
            [ret] = StartAcquisition();                   
            CheckWarning(ret);

            [ret,gstatus]=AndorGetStatus;
            CheckWarning(ret);
            while(gstatus ~= atmcd.DRV_IDLE)
              pause(1.0);
              disp('Acquiring');
              [ret,gstatus]=AndorGetStatus;
              CheckWarning(ret);
            end


            [ret, imageData] = GetMostRecentImage(XPixels);
            CheckWarning(ret);

            if ret == atmcd.DRV_SUCCESS
                plot(imageData);
            end

            
            [ret]=SetShutter(1, 2, 1, 1); %close shutter
            CheckWarning(ret);
            [ret, iCoolerStatus] = IsCoolerOn();
            CheckWarning(ret);
            if iCoolerStatus
                ret = CoolerOFF();
                CheckWarning(ret);
            end
            %[ret] = SetCoolerMode(1); % keep cooler on;
            %CheckWarning(ret);
            
            [ret]=AndorShutDown;
            CheckWarning(ret);

        end
    end
end