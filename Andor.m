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
       % properties used internally
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
       shamrockDev       % shamrock grating device number
       SlitWidth         % in um
       CurrentGrating    % current grating 
       CentralWavelength % in nm
       maxWavelength     % in nm. max wavelength for wmrs
       minWavlength      % in nm. min wavelength for wmrs
       AxisWavelength
       numbGratings
       CCDCooled         % if 1 then CCD is cooled else not cooled to set temp
       wavelength_LUT    % 1D interpolation for current to wavelength conversion
       power_LUT         % 1D interpolation for heater current to power conversion
       abortSignal       % if 1 then abort aquistion
    end
    properties (Access = private)
        MINWAVE % min tuning wavelength. in nm
        MAXWAVE % max tuning wavelength. in nm
    end
   
    methods
        function obj = Andor(CCDTemp, AquistionMode, ExposureTime, ReadMode, TriggerMode, PreAmpGain, slitWidth, centralWavelength, fig)
            arguments
                CCDTemp = -70.0
                AquistionMode = 1 % single scan
                ExposureTime = 0.1 % seconds
                ReadMode = 0 % FVB
                TriggerMode = 0 % internal
                PreAmpGain = 1 % 1x
                slitWidth = 150 % um
                centralWavelength = 785.0; % nm
                fig = 0
            end        

            % set variables for spectrometer
            obj.AquistionMode = AquistionMode;
            obj.ExposureTime = ExposureTime;
            obj.ReadMode = ReadMode;
            obj.TriggerMode = TriggerMode;
            obj.PreAmpGain = PreAmpGain;
            obj.abortSignal = false;
            obj.CentralWavelength = centralWavelength;
            obj.SlitWidth = slitWidth;

            ret = AndorInitialize('');
            AndorIssueError(ret, "AndorInitialize");
            
            % get allowable temp range for CCD
            [ret, obj.minTemp, obj.maxTemp] = GetTemperatureRange();
            AndorIssueWarning(ret, "GetTemperatureRange");
            obj.SetCCDTemp(CCDTemp)   

            % start cooling CCD
            obj.CoolCCD(fig);
            
            d = uiprogressdlg(fig, "Title", 'Setup Spectrometer', 'Message', "Setting up spectrometer", 'Indeterminate','on');
            drawnow

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
            close(d);
            % set up LUT
            T = readtable("FHM_laser_LUT_heatercurrent_vs_wavelength.csv"); % read in look up table
            obj.wavelength_LUT = griddedInterpolant(T.current, T.wavelength);
            obj.MINWAVE = min(T.wavelength);
            obj.MAXWAVE = max(T.wavelength);
        end

        function obj = setupShamrock(obj)
           % setup shamrock grating

            [ret] = ShamrockInitialize('');
            ShamrockIssueError(ret, "ShamrockInitialize");
            
            % get device
            [ret, deviceCount] = ShamrockGetNumberDevices();
            ShamrockIssueWarning(ret, "ShamrockGetNumberDevices");
            if ret == Shamrock.SHAMROCK_SUCCESS
                obj.shamrockDev = deviceCount-1;
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
            % set central wavelength for WMRS
            % this is also the wavelength for single spectra mode
            obj.CentralWavelength = wavelength;
            [ret] = ShamrockSetWavelength(obj.shamrockDev, obj.CentralWavelength);
            ShamrockIssueWarning(ret, "ShamrockSetWavelength");
        end
        
        function obj = setMaxWavelength(obj, wavelength)
            % set max wavelength for WMRS
            if wavelength < obj.MAXWAVE
                obj.maxWavlength = obj.MAXWAVE;
            else
                obj.maxWavelength = wavelength;
            end
        end
  
        function obj = setMinWavelength(obj, wavelength)
            % set min wavelength for WMRS
            if wavelength < obj.MINWAVE
                obj.minWavlength = obj.MINWAVE;
            else
                obj.minWavelength = wavelength;
            end
        end
        
        function obj = setExposureTime(obj, time)

            obj.ExposureTime = time;
            [ret]=SetExposureTime(obj.ExposureTime);
            AndorIssueWarning(ret, "SetExposureTime");
            
        end
        function obj = ShutDownSafe(obj, fig)
            [ret, iCoolerStatus] = IsCoolerOn();
            AndorIssueWarning(ret);
            if iCoolerStatus
                ret = CoolerOFF();
                AndorIssueWarning(ret, "CoolerOFF");
            end
           
            [ret, temp] = GetTemperature();
            if ret ~= atmcd.DRV_TEMP_OFF
                AndorIssueWarning(ret, "GetTemperature");
            end
            
            d = uiprogressdlg(fig, "Title", 'CCD warming', 'Message', "CCD Currently warming", 'Indeterminate','on');
            drawnow

            while temp < -20
                [ret, temp] = GetTemperature();
                disp(ret)
                if ret ~= atmcd.DRV_TEMP_OFF
                    AndorIssueWarning(ret, "GetTemperature Loop");
                end
                d.Message = sprintf('Current Temperature %d C', temp);
                pause(1.0);
            end

            close(d);

            [ret]=AndorShutDown();
            AndorIssueWarning(ret, "AndorShutDown");

            [ret]=ShamrockClose();
            ShamrockIssueWarning(ret, "ShamrockClose");
        end
        
        function [waves, spectra] = AquireSpectra(obj, fig)

            [ret] = PrepareAcquisition();
            AndorIssueWarning(ret, "PrepareAcquisition");
            
            [ret]=SetShutter(1, 1, 0, 0); %   Open Shutter
            AndorIssueWarning(ret, "SetShutter Open");
        
            disp('Starting Acquisition');
            [ret] = StartAcquisition();                  
            AndorIssueWarning(ret, "StartAcquisition");
           
            d = uiprogressdlg(fig, "Title", 'Acquiring spectra', 'Message', "Acquiring spectra", 'Indeterminate','on');
            drawnow
            
            gstatus = 0;
            while(gstatus ~= atmcd.DRV_IDLE)
                [ret,gstatus]=AndorGetStatus;
                AndorIssueWarning(ret, "AndorGetStatus during Acquisition wait loop");
                if obj.abortSignal == true
                   [ret]=AbortAcquisition();
                   AndorIssueWarning(ret, "AbortAcquistion");
                   break;
                end
            end
            
            close(d);
            
            if obj.abortSignal == true
                obj.abortSignal = false;
                uiwait(msgbox('Acquistion aborted!', 'Aborted!',"warn", "modal"));
            else
                [ret, imageData] = GetMostRecentImage(obj.XPixels);
                AndorIssueWarning(ret, "GetMostRecentImage");

                if ret == atmcd.DRV_SUCCESS
                   spectra = imageData;
                   waves = linspace(0,3000, length(spectra))';
                else
                    spectra = zeros(3000, 1);
                    waves = linspace(0, 3000, length(spectra))';
                end
            end
            [ret]=SetShutter(1, 2, 1, 1); %close shutter
            AndorIssueWarning(ret, "SetShutter Close");
        end
        
        function obj = CoolCCD(obj, fig)
            obj.CCDCooled = 0;
            % turn on cooler
            [ret] = CoolerON();
            AndorIssueWarning(ret, "CoolerON");
           
            % wait for CCD to cool         
            ret = SetTemperature(obj.CCDTemp);
            AndorIssueWarning(ret, "SetTemperature");
            [ret, temp] = GetTemperature();

            d = uiprogressdlg(fig, "Title", 'CCD Cooling', 'Message', "CCD Currently Cooling", 'Indeterminate','on');
            drawnow

            while ret ~= atmcd.DRV_TEMP_STABILIZED
                d.Message = sprintf('Current Temperature %d C', temp);
                pause(1);
                [ret, temp] = GetTemperature();

                if ret == atmcd.DRV_NOT_INITIALIZED || ret == atmcd.DRV_ACQUIRING || ret == atmcd.DRV_ERROR_ACK || ret == atmcd.DRV_TEMPERATURE_OFF
                    AndorIssueWarning(ret, "During Cooling loop");
                    break;
                end
            end
            close(d)
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