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
       minTemp
       maxTemp
       CCDTemp
       AquistionMode
       ExposureTime
       ReadMode
       TriggerMode
       PreAmpGain
       XPixels
       YPixels
       shamrockDev
       SlitWidth
       CurrentGrating
       CentralWavelength
       AxisWavelength
       numbGratings
       
    end
    properties
      abortSignal
    end
   
    methods
        function obj = Andor(CCDTemp, AquistionMode, ExposureTime, ReadMode, TriggerMode, PreAmpGain)
            arguments
                CCDTemp = -70.0
                AquistionMode = 1 % single scan
                ExposureTime = 0.01 % seconds
                ReadMode = 0 % FVB
                TriggerMode = 0 % internal
                PreAmpGain = 1 % 1x
            end        
%             addpath('C:\Program Files\MATLAB\R2021a\toolbox\Andor')

            % set variables for spectrometer
            obj.AquistionMode = AquistionMode;
            obj.ExposureTime = ExposureTime;
            obj.ReadMode = ReadMode;
            obj.TriggerMode = TriggerMode;
            obj.PreAmpGain = PreAmpGain;
            obj.abortSignal = 0;

            [ret, obj.minTemp, obj.maxTemp] = GetTemperatureRange();
            CheckWarning(ret);
            obj.SetCCDTemp(CCDTemp)
            
            ret = AndorInitialize('');
            CheckError(ret);
            
            % use catch exits so use this.
           
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
            
            
            % setup shamrock grating
            [ret] = ShamrockInitialize('');
            ShamrockCheckError(ret);
            if ret == Shamrock.SHAMROCK_SUCCESS
                fprintf('done!\nShamrock has been initialized successfully!\n');
            else
                disp('Error occurred during Shamrock initialization!')
            end           
            
            [ret, obj.numbGratings] = ShamrockGetNumberGratings(Andor.ShamrockDev);
            ShamrockCheckWarning(ret);
            
            [ret, obj.CurrentGrating] = ShamrockGetGrating(obj.shamrockDev);
            ShamrockCheckWarning(ret);
            [ret, lines, blaze, home, offset] = ShamrockGetGratingInfo(obj.shamrockDev, obj.CurrentGrating);
            ShamrockCheckWarning(ret);
            obj.SlitWidth = 150; % um
            obj.CentralWavelength = 924.1050; % nm
            [ret] = ShamrockSetSlit(obj.shamrockDev, obj.SlitWidth);
            ShamrockCheckWarning(ret);

            [ret] = ShamrockSetWavelength(obj.shamrockDev, obj.CentralWavelength);
            ShamrockCheckWarning(ret);

            [ret, NumberPixels] = ShamrockGetNumberPixels(obj.shamrockDev);
            ShamrockCheckWarning(ret);
            [ret, obj.AxisWavelength] = ShamrockGetCalibration(obj.shamrockDev, NumberPixels);
            ShamrockCheckWarning(ret);

            
            fprintf('Grating Info: %d lines/mm,SlitWidth: %dum, Central Wavelength: %fnm\n',lines,obj.SlitWidth, obj.CentralWavelength);

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