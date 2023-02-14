classdef Andor < handle
    properties (Access = private, Constant)
        % private properties used internally so that "magic numbers" are removed
        % Read Modes
        FVB         = 0
        MultiTrack  = 1
        RandomTrack = 2
        SingleTrack = 3
        Image       = 4
        % Acquisition Modes
        SingleScan   = 1
        Accumulate   = 2
        Kinetics     = 3
        FastKinetics = 4
        RunTillAbort = 5
        % Trigger Modes
        Internal = 0
        External = 1
        ExternalStart = 6
        ExternalExposure = 7
        ExternalFVBEM = 9
        Software = 10
        ExternalChargeShifting = 12
    end
    properties (Access = private)
       % private properties used internally
       minTemp          % min temp CCD can go to
       maxTemp          % max temp CDD can go to
       CCDTemp          % current CCD temp
       AquistionMode
       ExposureTime     % in seconds
       ReadMode
       TriggerMode
       PreAmpGain
       XPixels
       YPixels
       shamrockDev      % shamrock grating device number
       SlitWidth        % in um
       CurrentGrating   % current grating 
       CentralWavelength% in nm
       AxisWavelength
       numbGratings
    end
    properties
      abortSignal       % if 1 then abort aquistion
    end
   
    methods
        function obj = Andor(CCDTemp, AquistionMode, ExposureTime, ReadMode, TriggerMode, PreAmpGain, slitWidth, centralWavelength)
            arguments
                CCDTemp = -70.0
                AquistionMode = 1 % single scan
                ExposureTime = 0.01 % seconds
                ReadMode = 0 % FVB
                TriggerMode = 0 % internal
                PreAmpGain = 1 % 1x
                slitWidth = 150 % um
                centralWavelength = 785.0; % nm
            end        
%             addpath('C:\Program Files\MATLAB\R2021a\toolbox\Andor')

            % set variables for spectrometer
            obj.AquistionMode = AquistionMode;
            obj.ExposureTime = ExposureTime;
            obj.ReadMode = ReadMode;
            obj.TriggerMode = TriggerMode;
            obj.PreAmpGain = PreAmpGain;
            obj.abortSignal = 0;
            obj.CentralWavelength = centralWavelength;
            obj.SlitWidth = slitWidth;

             ret = AndorInitialize('');
            CheckError(ret);
            
            % get allowable temp range for CCD
            [ret, obj.minTemp, obj.maxTemp] = GetTemperatureRange();
            CheckWarning(ret);
            obj.SetCCDTemp(CCDTemp)           
            
            % setup spectrometer variables
            [ret]=SetAcquisitionMode(obj.AquistionMode);
            CheckWarning(ret);
            [ret]=SetExposureTime(obj.ExposureTime);                  %   Set exposure time in seconds
            CheckWarning(ret);
            [ret]=SetReadMode(obj.ReadMode);                         
            CheckWarning(ret);
            [ret]=SetTriggerMode(obj.TriggerMode);                      
            CheckWarning(ret);

            [ret, obj.XPixels, obj.YPixels]=GetDetector();         %   Get the CCD size
            CheckWarning(ret);
            [ret]=SetImage(1, 1, 1, obj.XPixels, 1, obj.YPixels); %   Set the image size
            CheckWarning(ret);
            
            obj.setupShamrock();
            
        end

        function obj = setupShamrock(obj)
           % setup shamrock grating

            [ret] = ShamrockInitialize('');
            ShamrockCheckError(ret);
            if ret == Shamrock.SHAMROCK_SUCCESS
                fprintf('done!\nShamrock has been initialized successfully!\n');
            else
                disp('Error occurred during Shamrock initialization!')
            end           
            
            % get device
            % TODO check device numbers
            [ret, deviceCount] = ShamrockGetNumberDevices();
            ShamrockCheckWarning(ret);
            if ret == Shamrock.SHAMROCK_SUCCESS
                if deviceCount >1 %== 2 %strange in lab 106, return deviceCount 3!!!!increased from 2 to 3 in 22/04/2019
                    obj.shamrockDev = 0;
                else
                    obj.shamrockDev = deviceCount-1;
                end
            end    

            [ret, obj.numbGratings] = ShamrockGetNumberGratings(Andor.ShamrockDev);
            ShamrockCheckWarning(ret);
            
            [ret, obj.CurrentGrating] = ShamrockGetGrating(obj.shamrockDev);
            ShamrockCheckWarning(ret);
            [ret, lines, blaze, home, offset] = ShamrockGetGratingInfo(obj.shamrockDev, obj.CurrentGrating);
            ShamrockCheckWarning(ret);
            
            obj.setSlitWidth(obj, obj.SlitWidth);

            obj.setCentralWavelength(obj, obj.CentralWavelength);

            [ret, NumberPixels] = ShamrockGetNumberPixels(obj.shamrockDev);
            ShamrockCheckWarning(ret);
            [ret, obj.AxisWavelength] = ShamrockGetCalibration(obj.shamrockDev, NumberPixels);
            ShamrockCheckWarning(ret);
        end
        
        function obj = setSlitWidth(obj, width)
            obj.SlitWidth = width;
            [ret] = ShamrockSetSlit(obj.shamrockDev, obj.SlitWidth);
            ShamrockCheckWarning(ret);
        end
        
        function obj = setCentralWavelength(obj, wavelength)
            
            obj.CentralWavelength = wavelength;
            [ret] = ShamrockSetWavelength(obj.shamrockDev, obj.CentralWavelength);
            ShamrockCheckWarning(ret);
            
        end
        
        function obj = ShutDownSafe(obj)
            [ret, iCoolerStatus] = IsCoolerOn();
            CheckWarning(ret);
            if iCoolerStatus
                ret = CoolerOFF();
                CheckWarning(ret);
            end
            %[ret] = SetCoolerMode(1); % keep cooler on;
            %CheckWarning(ret);
           
            [ret]=AndorShutDown();
            CheckWarning(ret);
        end
        
        function [waves, spectra] = AquireSpectra(obj)
           
            [ret]=SetShutter(1, 1, 0, 0); %   Open Shutter
            CheckWarning(ret);
        
            disp('Starting Acquisition');
            [ret] = StartAcquisition();                  
            CheckWarning(ret);

            [ret,gstatus]=AndorGetStatus;
            CheckWarning(ret);
            while(gstatus ~= atmcd.DRV_IDLE)
                if obj.abortSignal == 1
                    ret = AbortAcquisition();
                    CheckWarning(ret);
                    obj.abortSignal = 0;
                    break
                end
              pause(1.0);
              disp('Acquiring');
              [ret,gstatus]=AndorGetStatus;
              CheckWarning(ret);
            end

            [ret, imageData] = GetMostRecentImage(obj.XPixels);
            CheckWarning(ret);

            if ret == atmcd.DRV_SUCCESS
               spectra = imageData;
               waves = linspace(0,3000, length(spectra))';
%                 plot(spectra);
            else
                spectra = zeros(3000, 1);
                waves = linspace(0, 3000, length(spectra))';
            end
%            spectra =rand(3000, 1);
%            waves = linspace(0,3000, 3000)';
            [ret]=SetShutter(1, 2, 1, 1); %close shutter
            CheckWarning(ret);
        end
        
        function obj = CoolCCD(obj)
            
            % turn on cooler
            [ret] = CoolerON();
            CheckWarning(ret);
           
            % wait for CCD to cool         
            ret = SetTemperature(obj.CCDTemp);
            CheckWarning(ret);
            [ret, temp] = GetTemperature();
            while ret ~= atmcd.DRV_TEMP_STABILIZED
                msg = num2str(temp);
                fprintf(msg);
                pause(1);
                [ret, temp] = GetTemperature();
                if ret == atmcd.DRV_NOT_INITIALIZED || ret == atmcd.DRV_ACQUIRING || ret == atmcd.DRV_ERROR_ACK || ret == atmcd.DRV_TEMPERATURE_OFF
                    warning('Error setting Temperature!')
                    break;
                end
            end
        end 

        function SetCCDTemp(obj, temp)
            
            if temp < obj.minTemp || temp > obj.maxTemp
                obj.CCDTemp = -70.0;
            else
               obj.CCDTemp = temp;
            end
        end
    end
end