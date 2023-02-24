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
    properties (Access = public)
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
       CCDCooled  % if 1 then CCD is cooled else bot cooled to set temp
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
            AndorIssueError(ret, "AndorInitialize");
            
            % get allowable temp range for CCD
            [ret, obj.minTemp, obj.maxTemp] = GetTemperatureRange();
            AndorIssueWarning(ret, "GetTemperatureRange");
            obj.SetCCDTemp(CCDTemp)   

            % start cooling CCD
            obj.CoolCCD();
            
            % setup spectrometer variables
            [ret]=SetAcquisitionMode(obj.AquistionMode);
            AndorIssueWarning(ret, "SetAcquisitionMode");

            [ret]=SetExposureTime(obj.ExposureTime);                  %   Set exposure time in seconds
            AndorIssueWarning(ret, "SetExposureTime");

            [ret]=SetReadMode(obj.ReadMode);                         
            AndorIssueWarning(ret, "SetReadMode");

            [ret]=SetTriggerMode(obj.TriggerMode);                      
            AndorIssueWarning(ret, "SetTriggerMode");

            [ret, obj.XPixels, obj.YPixels]=GetDetector();         %   Get the CCD size
            AndorIssueWarning(ret, "GetDetector");

            [ret]=SetImage(1, 1, 1, obj.XPixels, 1, obj.YPixels); %   Set the image size
            AndorIssueWarning(ret, "SetImage");
            
            obj.setupShamrock();            
        end

        function obj = setupShamrock(obj)
           % setup shamrock grating

            [ret] = ShamrockInitialize('');
            ShamrockIssueError(ret, "ShamrockInitialize");     
            
            % get device
            % TODO check device numbers
            [ret, deviceCount] = ShamrockGetNumberDevices();
            ShamrockIssueWarning(ret, "ShamrockGetNumberDevices");
            if ret == Shamrock.SHAMROCK_SUCCESS
                if deviceCount >1 %== 2 %strange in lab 106, return deviceCount 3!!!!increased from 2 to 3 in 22/04/2019
                    obj.shamrockDev = 0;
                else
                    obj.shamrockDev = deviceCount-1;
                end
            end
            
            [ret, obj.numbGratings] = ShamrockGetNumberGratings(obj.shamrockDev);
            ShamrockIssueWarning(ret, "ShamrockGetNumberGratings");
            
            [ret, obj.CurrentGrating] = ShamrockGetGrating(obj.shamrockDev);
            ShamrockIssueWarning(ret, "ShamrockGetGrating");
            [ret, lines, blaze, home, offset] = ShamrockGetGratingInfo(obj.shamrockDev, obj.CurrentGrating);
            ShamrockIssueWarning(ret, "ShamrockGetGratingInfo");
            
            obj.setSlitWidth(obj.SlitWidth);

            obj.setCentralWavelength(obj.CentralWavelength);

            [ret, NumberPixels] = ShamrockGetNumberPixels(obj.shamrockDev);
            ShamrockIssueWarning(ret, "ShamrockGetNumberPixels");
            [ret, obj.AxisWavelength] = ShamrockGetCalibration(obj.shamrockDev, NumberPixels);
            ShamrockIssueWarning(ret, "ShamrockGetCalibration");
        end
        
        function obj = setSlitWidth(obj, width)
            obj.SlitWidth = width;
            [ret] = ShamrockSetSlit(obj.shamrockDev, obj.SlitWidth);
            ShamrockIssueWarning(ret, "ShamrockSetSlit");
        end
        
        function obj = setCentralWavelength(obj, wavelength)
            
            obj.CentralWavelength = wavelength;
            [ret] = ShamrockSetWavelength(obj.shamrockDev, obj.CentralWavelength);
            ShamrockIssueWarning(ret, "ShamrockSetWavelength");
            
        end
        function obj = setExposureTime(obj, time)

            obj.ExposureTime = time;
            [ret]=SetExposureTime(obj.ExposureTime);
            AndorIssueWarning(ret, "SetExposureTime");
            
        end
        function obj = ShutDownSafe(obj)
            [ret, iCoolerStatus] = IsCoolerOn();
            AndorIssueWarning(ret);
            if iCoolerStatus
                ret = CoolerOFF();
                AndorIssueWarning(ret, "CoolerOFF");
            end
           
            [ret, temp] = GetTemperature();
            AndorIssueWarning(ret, "GetTemperature");

            while temp < -20
                [ret, temp] = GetTemperature();
                AndorIssueWarning(ret, "GetTemperature");
                pause(1.0);
            end
            [ret]=AndorShutDown();
            AndorIssueWarning(ret, "AndorShutDown");
        end
        
        function [waves, spectra] = AquireSpectra(obj)
           
            [ret] = PrepareAcquisition();
            AndorIssueWarning(ret, "PrepareAcquisition");
            
            [ret]=SetShutter(1, 1, 0, 0); %   Open Shutter
            AndorIssueWarning(ret, "SetShutter Open");
        
            disp('Starting Acquisition');
            [ret] = StartAcquisition();                  
            AndorIssueWarning(ret, "StartAcquisition");
           
            gstatus = 0;
            while(gstatus ~= atmcd.DRV_IDLE)                
                [ret,gstatus]=AndorGetStatus;
                AndorIssueWarning(ret, "AndorGetStatus during Acquisition wait loop");                
            end
            disp("acquired");
            
            [ret, imageData] = GetMostRecentImage(obj.XPixels);
            AndorIssueWarning(ret, "GetMostRecentImage");

            if ret == atmcd.DRV_SUCCESS
               spectra = imageData;
               waves = linspace(0,3000, length(spectra))';
            else
                spectra = zeros(3000, 1);
                waves = linspace(0, 3000, length(spectra))';
            end
            [ret]=SetShutter(1, 2, 1, 1); %close shutter
            AndorIssueWarning(ret, "SetShutter Close");
        end
        
        function obj = CoolCCD(obj)
            
            % turn on cooler
            [ret] = CoolerON();
            AndorIssueWarning(ret, "CoolerON");
           
            % wait for CCD to cool         
            ret = SetTemperature(obj.CCDTemp);
            AndorIssueWarning(ret, "SetTemperature");
            [ret, temp] = GetTemperature();
            msg = ["Current CCD temperature ", num2str(temp) 'C'];

            h = msgbox(msg, "Cooling CCD");
            while ret ~= atmcd.DRV_TEMP_STABILIZED
                msg = ["Current CCD temperature ", num2str(temp) 'C'];
                set(findobj(h,'Tag','MessageBox'),'String',msg);
                pause(1);
                [ret, temp] = GetTemperature();

                if ret == atmcd.DRV_NOT_INITIALIZED || ret == atmcd.DRV_ACQUIRING || ret == atmcd.DRV_ERROR_ACK || ret == atmcd.DRV_TEMPERATURE_OFF
                    AndorIssueWarning(ret, "During Cooling loop");
                    break;
                end
            end
            obj.CCDCooled = 1;
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