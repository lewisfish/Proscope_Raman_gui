classdef Raman_GUI_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        RamanModuleUIFigure            matlab.ui.Figure
        TabGroup                       matlab.ui.container.TabGroup
        CalibrationTab                 matlab.ui.container.Tab
        GridLayout4                    matlab.ui.container.GridLayout
        PanelCalibration               matlab.ui.container.Panel
        GridLayout5                    matlab.ui.container.GridLayout
        PatientIDEditFieldLabel        matlab.ui.control.Label
        PatientIDEditField             matlab.ui.control.NumericEditField
        SetSavePathButton              matlab.ui.control.Button
        CalibrateButton                matlab.ui.control.Button
        CalibrationAxes                matlab.ui.control.UIAxes
        MainTab                        matlab.ui.container.Tab
        GridLayout                     matlab.ui.container.GridLayout
        PanelDisplay                   matlab.ui.container.Panel
        GridLayout1                    matlab.ui.container.GridLayout
        TimeTakenEditField             matlab.ui.control.EditField
        TimeTakenEditFieldLabel        matlab.ui.control.Label
        SpectraAcquiredEditField       matlab.ui.control.NumericEditField
        SpectraAcquiredEditFieldLabel  matlab.ui.control.Label
        PanelEngineering               matlab.ui.container.Panel
        GridLayout2                    matlab.ui.container.GridLayout
        CCDTempEditFieldLabel          matlab.ui.control.Label
        CCDTempEditField               matlab.ui.control.NumericEditField
        SlitWidthEditFieldLabel        matlab.ui.control.Label
        SlitWidthEditField             matlab.ui.control.NumericEditField
        MaxRamanShiftEditField         matlab.ui.control.NumericEditField
        MaxRamanShiftEditFieldLabel    matlab.ui.control.Label
        MinRamanShiftEditField         matlab.ui.control.NumericEditField
        MinRamanShiftEditFieldLabel    matlab.ui.control.Label
        PanelMain                      matlab.ui.container.Panel
        GridLayout3                    matlab.ui.container.GridLayout
        SingleRamanButton              matlab.ui.control.Button
        ClinicalModeButton             matlab.ui.control.Button
        SavePathButton                 matlab.ui.control.Button
        LaserShutterButton             matlab.ui.control.Button
        TuningStepsEditField           matlab.ui.control.NumericEditField
        TuningStepsEditFieldLabel      matlab.ui.control.Label
        LaserPowerEditField            matlab.ui.control.NumericEditField
        LaserPowerEditFieldLabel       matlab.ui.control.Label
        MinWavelengthEditField         matlab.ui.control.NumericEditField
        MinWavelengthEditFieldLabel    matlab.ui.control.Label
        MaxWavelengthEditField         matlab.ui.control.NumericEditField
        MaxWavelengthEditFieldLabel    matlab.ui.control.Label
        CentralWavelengthEditField     matlab.ui.control.NumericEditField
        CentralWavelengthEditFieldLabel  matlab.ui.control.Label
        EngineeringModeButton          matlab.ui.control.Button
        ExitButton                     matlab.ui.control.Button
        WMRSButton                     matlab.ui.control.Button
        AbortButton                    matlab.ui.control.Button
        AcquireButton                  matlab.ui.control.Button
        AquireAxes                     matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        CalibrationSaveDir % Calibration directory
        SpectraSaveDir % Patient data directory
        SpectraAcquired = 0 % Number of spectra acquired
        PatientID % user defined Patient Id + current time/data
        dateTime % store date time at startup
        tmr % Timer class
        LaserHandle % Laser class
        spectrometerHandle % spectrometer class
        CalibrationDone = false % Flag set to true if calibration has be carried out.
        WMRS = false % Flag set to true if WRMS mode is active.
        steps =5% number of spectra to take for WRMS mode.
        abortSignal = false % abort acquistion
    end
    properties (Access = public)
        time = 0 % start time. Must be public as passed to outside function.
    end
    methods (Access = private)
        
        function saveData(app, colA, colB, dirPath, name)
            if ~exist('name','var')
                filename = join([dirPath, app.PatientID], "\");
            else
                name = join([name app.PatientID], "_");
                filename = join([dirPath, name], "\");
            end
            varNames = {'Raman Shift/cm^-1', 'Counts/arb.'};
            T = table(colA, colB, 'VariableNames',varNames);
            writetable(T, join([filename ".csv"], ""));
        end
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % Check free space on disk
            free_bytes = java.io.File(".").getFreeSpace();
            free_Gbytes = free_bytes / (1024^3);
            if free_Gbytes < 10
                if free_Gbytes < 5
                    uialert(app.RamanModuleUIFigure, "Not Enough Memory on Hard Drive!","Memory Error");
                    delete(app);
                end
                uialert(app.RamanModuleUIFigure, "Warning, less than 10Gb of disk space free!","Memory Warning",'Icon','warning');
            end
            
            % Set up timer
            % https://www.mathworks.com/matlabcentral/fileexchange/24861-41-complete-gui-examples
            app.tmr = timer('TimerFcn',{@updater, app},...
                            'Period',1,...  % Update the time every 60 seconds.
                            'StartDelay',0,... % In seconds.
                            'TasksToExecute',inf,...  % number of times to update
                            'ExecutionMode','fixedSpacing');
            app.LaserHandle = Laser();
            app.LaserHandle.enableLaserHeaterPower();
            
            %add spectrometer setup here
            app.spectrometerHandle = Andor(-70.0, 1, 1.00, 0, 0, 1, 150, 785.0, app.RamanModuleUIFigure);
            
            %set up spectra viewer
            app.AquireAxes.XLim = [app.MinRamanShiftEditField.Value, app.MaxRamanShiftEditField.Value];
            
            % add time to patientID
            app.dateTime = string(datetime('now','TimeZone','local','Format','dd-MM-yyyy''T''HHmmss'));
        end

        % Button pushed function: SetSavePathButton
        function SetSavePathButtonPushed(app, event)
            if isempty(app.PatientID)
                uialert(app.RamanModuleUIFigure, "PatientID not Entered!","Calibration Warning");
            else
                app.CalibrationSaveDir = uigetdir("", "Patient data Folder");
                %stop app losing focus
                app.RamanModuleUIFigure.Visible = 'off';
                app.RamanModuleUIFigure.Visible = 'on';
                app.CalibrateButton.Visible = "on";
            end
        end

        % Button pushed function: CalibrateButton
        function CalibrateButtonPushed(app, event)
            if app.spectrometerHandle.CCDCooled == 1
                app.CalibrationDone = true;
                %integration time is 1s, rest is standard
                expTime = app.spectrometerHandle.ExposureTime;
                app.spectrometerHandle.setExposureTime(1.0);
                [w, s] = app.spectrometerHandle.AquireSpectra();
                saveData(app, w, s, app.CalibrationSaveDir, 'calibration');
                plot(app.CalibrationAxes, w, s, 'r-');
                app.spectrometerHandle.setExposureTime(expTime);
            else
                uialert(app.RamanModuleUIFigure, "CCD not fully cooled!","Calibration Warning","Icon","warning");
            end
        end

        % Callback function: ExitButton, RamanModuleUIFigure
        function UIFigureCloseRequest(app, event)
            answer = questdlg("Do you want to shutdown the software?");
            if answer == "Yes"
                app.spectrometerHandle.ShutDownSafe(app.RamanModuleUIFigure);
                app.LaserHandle.switchOff();
                stop(app.tmr);
                delete(app.tmr);
                delete(app);
            end       
        end

        % Button pushed function: AcquireButton
        function AcquireButtonPushed(app, event)
            app.AcquireButton.Enable = false;
            drawnow;% force update of UI
            if app.CalibrationDone
                if exist(app.SpectraSaveDir)
                    if app.time == 0
                        start(app.tmr);
                    end
                    if app.WMRS
                        %WRMS mode
                        wavelengthStep = (app.spectrometerHandle.maxWavelength - app.spectrometerHandle.minWavelength) / (app.steps-1); % nm
                        wavelength = app.spectrometerHandle.minWavelength;
                        spectrums = [];
                        for i=1:app.steps-1
                            if app.spectrometerHandle.abortSignal == true
                                break;
                            end
                            % convert wavelength to current
                            current = app.spectrometerHandle.wavelength_LUT(wavelength);
                            %set current
                            app.LaserHandle.setHeaterCurrent(current);
                            % write current to laser
                            app.LaserHandle.writeHeaterCurrent();
                            if app.abortSignal
                                break
                            end
                            % get new spectra
                            [w, s] = app.spectrometerHandle.AquireSpectra();
                            spectrums = [spectrums s];
                            %increment wavelength
                            wavelength = wavelength + wavelengthStep;
                            
                            app.SpectraAcquired = app.SpectraAcquired + 1;
                            app.SpectraAcquiredEditField.Value = app.SpectraAcquired;

                        end
                        if app.abortSignal
                            %plot flat line
                            plot(app.AquireAxes,linspace(0, 3000, 3000)',zeros(3000, 1),'r-');
                            app.abortSignal = false;
                        else
                            % calculate WMRS
                            v1 = calculateWMRspec(spectrums, 785);
                            plot(app.AquireAxes, w, v1, 'r-');
                        end
                    else
%                       single spectra mode
                        [w, s] = app.spectrometerHandle.AquireSpectra();
                        saveData(app, w, s, app.SpectraSaveDir);
                        plot(app.AquireAxes, w, s, 'r-');
                        
                        app.SpectraAcquired = app.SpectraAcquired + 1;
                        app.SpectraAcquiredEditField.Value = app.SpectraAcquired;
                    end
                else
                    uialert(app.RamanModuleUIFigure, "Save path for spectra not set!", "Path not set")
                end
            else
                uialert(app.RamanModuleUIFigure, "Calibration Data not taken!","Calibration Warning");
            end
            app.AcquireButton.Enable = true;
        end

        % Button pushed function: WMRSButton
        function WMRSButtonPushed(app, event)
            app.WMRSButton.Visible = "off";
            app.WMRS = true;
            app.SingleRamanButton.Visible = "on";
            title(app.AquireAxes, 'WMR Spectra');
        end

        % Button pushed function: EngineeringModeButton
        function EngineeringModeButtonPushed(app, event)
            answer = inputdlg("Enter Password");
            if answer == "proscope2023"
                app.LaserShutterButton.Visible = 'on';

                app.CentralWavelengthEditField.Visible = 'on';
                app.CentralWavelengthEditFieldLabel.Visible = 'on';
    
                app.CCDTempEditField.Visible = 'on';
                app.CCDTempEditFieldLabel.Visible = 'on';
                
                app.MinRamanShiftEditField.Visible = 'on';
                app.MinRamanShiftEditFieldLabel.Visible = 'on';
    
                app.MaxRamanShiftEditField.Visible = 'on';
                app.MaxRamanShiftEditFieldLabel.Visible = 'on';
    
                app.MinWavelengthEditField.Visible = 'on';
                app.MinWavelengthEditFieldLabel.Visible = 'on';
    
                app.MaxWavelengthEditField.Visible = 'on';
                app.MaxWavelengthEditFieldLabel.Visible = 'on';
    
                app.LaserPowerEditField.Visible = "on";
                app.LaserPowerEditFieldLabel.Visible = "on";
                
                app.SlitWidthEditField.Visible = "on";
                app.SlitWidthEditFieldLabel.Visible = "on";
                
                app.TuningStepsEditField.Visible = "on";
                app.TuningStepsEditFieldLabel.Visible = "on";
                
                app.EngineeringModeButton.Visible = "off";
                app.ClinicalModeButton.Visible = "on";
            else
                uialert(app.RamanModuleUIFigure, "Wrong Password!","Security Error");
            end 
        end

        % Button pushed function: SavePathButton
        function SavePathButtonPushed(app, event)
            app.SpectraSaveDir = uigetdir("", "Patient Data Folder");
            %stop app losing focus
            app.RamanModuleUIFigure.Visible = 'off';
            app.RamanModuleUIFigure.Visible = 'on';
        end

        % Value changed function: PatientIDEditField
        function PatientIDEditFieldValueChanged(app, event)
            value = app.PatientIDEditField.Value;
            value_length = ceil(log10(abs(double(fix(value)))+1));
            if value_length ~= 6
                uialert(app.RamanModuleUIFigure, "PatientID must be 6 digits long!","User Error");
                return
            end
            strs = [string(value), app.dateTime];
            app.PatientID = join(strs, "_");
        end

        % Button pushed function: SingleRamanButton
        function SingleRamanButtonPushed(app, event)
            if app.WMRS == true
                app.WMRS = false;
                % reset wavelength of laser back to default.
                wavelength = app.spectrometerHandle.CentralWavelength;
                current = app.spectrometerHandle.wavelength_LUT(wavelength);
                app.LaserHandle.setHeaterCurrent(current);
                app.LaserHandle.writeHeaterCurrent();
            end
            app.WMRSButton.Visible = "on";
            app.SingleRamanButton.Visible = "off";
            title(app.AquireAxes, 'Raman Spectra');
        end

        % Button pushed function: ClinicalModeButton
        function ClinicalModeButtonPushed(app, event)
            app.LaserShutterButton.Visible = 'off';

            app.CentralWavelengthEditField.Visible = 'off';
            app.CentralWavelengthEditFieldLabel.Visible = 'off';

            app.CCDTempEditField.Visible = 'off';
            app.CCDTempEditFieldLabel.Visible = 'off';
            
            app.MinRamanShiftEditField.Visible = 'off';
            app.MinRamanShiftEditFieldLabel.Visible = 'off';

            app.MaxRamanShiftEditField.Visible = 'off';
            app.MaxRamanShiftEditFieldLabel.Visible = 'off';

            app.MinWavelengthEditField.Visible = 'off';
            app.MinWavelengthEditFieldLabel.Visible = 'off';

            app.MaxWavelengthEditField.Visible = 'off';
            app.MaxWavelengthEditFieldLabel.Visible = 'off';

            app.LaserPowerEditField.Visible = "off";
            app.LaserPowerEditFieldLabel.Visible = "off";
            
            app.SlitWidthEditField.Visible = "off";
            app.SlitWidthEditFieldLabel.Visible = "off";
            
            app.TuningStepsEditField.Visible = "off";
            app.TuningStepsEditFieldLabel.Visible = "off";
            
            app.EngineeringModeButton.Visible = "on";
            app.ClinicalModeButton.Visible = "off";
        end

        % Value changed function: MinRamanShiftEditField
        function MinRamanShiftEditFieldValueChanged(app, event)
            value = app.MinRamanShiftEditField.Value;
            app.AquireAxes.XLim = [value, app.MaxRamanShiftEditField.Value];
        end

        % Value changed function: MaxRamanShiftEditField
        function MaxRamanShiftEditFieldValueChanged(app, event)
            value = app.MaxRamanShiftEditField.Value;
            app.AquireAxes.XLim = [app.MinRamanShiftEditField.Value, value];
        end

        % Button pushed function: AbortButton
        function abortButtonPushed(app, event)
            app.abortSignal = true;
            app.spectrometerHandle.Abort();
            uialert(app.RamanModuleUIFigure, 'Acquisition aborted!', 'Warning','Icon','warning');
            app.AcquireButton.Enable = true;
        end

        % Value changed function: SlitWidthEditField
        function changeSlitWidth(app, event)
            value = app.SlitWidthEditField.Value;
            app.spectrometerHandle.setSlitWidth(value);
        end

        % Value changed function: CentralWavelengthEditField
        function changeCentralWavelength(app, event)
            value = app.CentralWavelengthEditField.Value;
            app.spectrometerHandle.setCentralWavelength(value);
        end

        % Value changed function: CCDTempEditField
        function CCDTempEditFieldValueChanged(app, event)
            value = app.CCDTempEditField.Value;
            app.spectrometerHandle.SetCCDTemp(value);
        end

        % Value changed function: MaxWavelengthEditField
        function MaxWavelengthEditFieldValueChanged(app, event)
            value = app.MaxWavelengthEditField.Value;
            app.spectrometerHandle.setMaxWavelength(value);
        end

        % Value changed function: MinWavelengthEditField
        function MinWavelengthEditFieldValueChanged(app, event)
            value = app.MinWavelengthEditField.Value;
            app.spectrometerHandle.setMinWavelength(value);
        end

        % Value changed function: TuningStepsEditField
        function TuningStepsEditFieldValueChanged(app, event)
            value = app.TuningStepsEditField.Value;
            app.steps = value;
        end

        % Value changed function: LaserPowerEditField
        function LaserPowerEditFieldValueChanged(app, event)
            value = app.LaserPowerEditField.Value;
            %this is heater current in FBH parlance...
            app.LaserHandle.setCurrentViaPower(value);
        end

        % Key press function: RamanModuleUIFigure
        function RamanModuleUIFigureKeyPress(app, event)
            key = event.Key;
            switch key
                case 'a' % aquire
                    app.AcquireButtonPushed();
                case 's' %stop
                    app.abortButtonPushed();
            end
        end

        % Size changed function: RamanModuleUIFigure
        function RamanModuleUIFigureSizeChanged(app, event)
            position = app.RamanModuleUIFigure.Position;
%             position = app.MainTab.Position;
            if position(3) < 1024 || position(4) < 768
                uialert(app.RamanModuleUIFigure, 'Too small a window!', 'Warning','Icon','warning');
                app.RamanModuleUIFigure.Position = [position(1),position(2),1024,768];
            else
                app.TabGroup.Position = [2,1,position(3),position(4)];
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create RamanModuleUIFigure and hide until all components are created
            app.RamanModuleUIFigure = uifigure('Visible', 'off');
            app.RamanModuleUIFigure.AutoResizeChildren = 'off';
            app.RamanModuleUIFigure.Position = [100 100 1024 768];
            app.RamanModuleUIFigure.Name = 'Raman Module';
            app.RamanModuleUIFigure.Icon = 'logo.jpeg';
            app.RamanModuleUIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);
            app.RamanModuleUIFigure.SizeChangedFcn = createCallbackFcn(app, @RamanModuleUIFigureSizeChanged, true);
            app.RamanModuleUIFigure.KeyPressFcn = createCallbackFcn(app, @RamanModuleUIFigureKeyPress, true);

            % Create TabGroup
            app.TabGroup = uitabgroup(app.RamanModuleUIFigure);
            app.TabGroup.Position = [2 1 1024 768];

            % Create CalibrationTab
            app.CalibrationTab = uitab(app.TabGroup);
            app.CalibrationTab.Title = 'Calibration';

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.CalibrationTab);
            app.GridLayout4.ColumnWidth = {'1x', '0.75x'};
            app.GridLayout4.RowHeight = {'1x'};

            % Create CalibrationAxes
            app.CalibrationAxes = uiaxes(app.GridLayout4);
            title(app.CalibrationAxes, 'Calibration Spectrum')
            xlabel(app.CalibrationAxes, 'Wavenumber/cm^{-1}')
            ylabel(app.CalibrationAxes, 'Raman Intensity/arb.')
            zlabel(app.CalibrationAxes, 'Z')
            app.CalibrationAxes.FontSize = 18;
            app.CalibrationAxes.Layout.Row = 1;
            app.CalibrationAxes.Layout.Column = 1;

            % Create PanelCalibration
            app.PanelCalibration = uipanel(app.GridLayout4);
            app.PanelCalibration.BorderType = 'none';
            app.PanelCalibration.Layout.Row = 1;
            app.PanelCalibration.Layout.Column = 2;

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.PanelCalibration);
            app.GridLayout5.ColumnWidth = {'1x', '1x', '1x', '1x'};
            app.GridLayout5.RowHeight = {'1x', '1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout5.ColumnSpacing = 5;
            app.GridLayout5.RowSpacing = 5;
            app.GridLayout5.Padding = [1 1 1 1];

            % Create CalibrateButton
            app.CalibrateButton = uibutton(app.GridLayout5, 'push');
            app.CalibrateButton.ButtonPushedFcn = createCallbackFcn(app, @CalibrateButtonPushed, true);
            app.CalibrateButton.FontSize = 18;
            app.CalibrateButton.Visible = 'off';
            app.CalibrateButton.Layout.Row = 5;
            app.CalibrateButton.Layout.Column = [2 3];
            app.CalibrateButton.Text = 'Calibrate';

            % Create SetSavePathButton
            app.SetSavePathButton = uibutton(app.GridLayout5, 'push');
            app.SetSavePathButton.ButtonPushedFcn = createCallbackFcn(app, @SetSavePathButtonPushed, true);
            app.SetSavePathButton.FontSize = 18;
            app.SetSavePathButton.Layout.Row = 4;
            app.SetSavePathButton.Layout.Column = [2 3];
            app.SetSavePathButton.Text = 'Set Save Path';

            % Create PatientIDEditField
            app.PatientIDEditField = uieditfield(app.GridLayout5, 'numeric');
            app.PatientIDEditField.Limits = [0 999999];
            app.PatientIDEditField.RoundFractionalValues = 'on';
            app.PatientIDEditField.ValueDisplayFormat = '%.0f';
            app.PatientIDEditField.ValueChangedFcn = createCallbackFcn(app, @PatientIDEditFieldValueChanged, true);
            app.PatientIDEditField.HorizontalAlignment = 'center';
            app.PatientIDEditField.FontSize = 18;
            app.PatientIDEditField.Layout.Row = 3;
            app.PatientIDEditField.Layout.Column = 3;

            % Create PatientIDEditFieldLabel
            app.PatientIDEditFieldLabel = uilabel(app.GridLayout5);
            app.PatientIDEditFieldLabel.HorizontalAlignment = 'right';
            app.PatientIDEditFieldLabel.FontSize = 18;
            app.PatientIDEditFieldLabel.Layout.Row = 3;
            app.PatientIDEditFieldLabel.Layout.Column = 2;
            app.PatientIDEditFieldLabel.Text = 'PatientID';

            % Create MainTab
            app.MainTab = uitab(app.TabGroup);
            app.MainTab.Title = 'Main';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.MainTab);
            app.GridLayout.ColumnWidth = {'1x', '0.75x'};
            app.GridLayout.RowHeight = {'0.2x', '1x'};
            app.GridLayout.ColumnSpacing = 5;
            app.GridLayout.RowSpacing = 5;

            % Create AquireAxes
            app.AquireAxes = uiaxes(app.GridLayout);
            title(app.AquireAxes, 'Raman Spectra')
            xlabel(app.AquireAxes, 'Wavenumber/cm^{-1}')
            ylabel(app.AquireAxes, 'Raman Intensity/arb.')
            zlabel(app.AquireAxes, 'Z')
            app.AquireAxes.FontSize = 18;
            app.AquireAxes.Layout.Row = 2;
            app.AquireAxes.Layout.Column = 1;

            % Create PanelMain
            app.PanelMain = uipanel(app.GridLayout);
            app.PanelMain.BorderType = 'none';
            app.PanelMain.Layout.Row = 2;
            app.PanelMain.Layout.Column = 2;

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.PanelMain);
            app.GridLayout3.ColumnWidth = {'1x', '1x', '1x', '1x'};
            app.GridLayout3.RowHeight = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};

            % Create AcquireButton
            app.AcquireButton = uibutton(app.GridLayout3, 'push');
            app.AcquireButton.ButtonPushedFcn = createCallbackFcn(app, @AcquireButtonPushed, true);
            app.AcquireButton.BackgroundColor = [0.0745 0.6235 1];
            app.AcquireButton.FontSize = 18;
            app.AcquireButton.Layout.Row = 7;
            app.AcquireButton.Layout.Column = [1 2];
            app.AcquireButton.Text = 'Acquire';

            % Create AbortButton
            app.AbortButton = uibutton(app.GridLayout3, 'push');
            app.AbortButton.ButtonPushedFcn = createCallbackFcn(app, @abortButtonPushed, true);
            app.AbortButton.BackgroundColor = [0.851 0.3255 0.098];
            app.AbortButton.FontSize = 18;
            app.AbortButton.Layout.Row = 7;
            app.AbortButton.Layout.Column = [3 4];
            app.AbortButton.Text = 'Abort';

            % Create WMRSButton
            app.WMRSButton = uibutton(app.GridLayout3, 'push');
            app.WMRSButton.ButtonPushedFcn = createCallbackFcn(app, @WMRSButtonPushed, true);
            app.WMRSButton.BackgroundColor = [0 1 0];
            app.WMRSButton.FontSize = 18;
            app.WMRSButton.Layout.Row = 8;
            app.WMRSButton.Layout.Column = [1 2];
            app.WMRSButton.Text = 'WMRS';

            % Create ExitButton
            app.ExitButton = uibutton(app.GridLayout3, 'push');
            app.ExitButton.ButtonPushedFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);
            app.ExitButton.BackgroundColor = [1 0.4118 0.1608];
            app.ExitButton.FontSize = 18;
            app.ExitButton.Layout.Row = 8;
            app.ExitButton.Layout.Column = [3 4];
            app.ExitButton.Text = 'Exit';

            % Create EngineeringModeButton
            app.EngineeringModeButton = uibutton(app.GridLayout3, 'push');
            app.EngineeringModeButton.ButtonPushedFcn = createCallbackFcn(app, @EngineeringModeButtonPushed, true);
            app.EngineeringModeButton.BackgroundColor = [0.9294 0.6941 0.1255];
            app.EngineeringModeButton.FontSize = 18;
            app.EngineeringModeButton.Layout.Row = 9;
            app.EngineeringModeButton.Layout.Column = [3 4];
            app.EngineeringModeButton.Text = 'Engineering Mode';

            % Create CentralWavelengthEditFieldLabel
            app.CentralWavelengthEditFieldLabel = uilabel(app.GridLayout3);
            app.CentralWavelengthEditFieldLabel.HorizontalAlignment = 'right';
            app.CentralWavelengthEditFieldLabel.FontSize = 18;
            app.CentralWavelengthEditFieldLabel.Visible = 'off';
            app.CentralWavelengthEditFieldLabel.Layout.Row = 1;
            app.CentralWavelengthEditFieldLabel.Layout.Column = [2 3];
            app.CentralWavelengthEditFieldLabel.Text = 'Central Wavelength';

            % Create CentralWavelengthEditField
            app.CentralWavelengthEditField = uieditfield(app.GridLayout3, 'numeric');
            app.CentralWavelengthEditField.Limits = [0 Inf];
            app.CentralWavelengthEditField.ValueDisplayFormat = '%.2f nm';
            app.CentralWavelengthEditField.ValueChangedFcn = createCallbackFcn(app, @changeCentralWavelength, true);
            app.CentralWavelengthEditField.FontSize = 18;
            app.CentralWavelengthEditField.Visible = 'off';
            app.CentralWavelengthEditField.Layout.Row = 1;
            app.CentralWavelengthEditField.Layout.Column = 4;
            app.CentralWavelengthEditField.Value = 785;

            % Create MaxWavelengthEditFieldLabel
            app.MaxWavelengthEditFieldLabel = uilabel(app.GridLayout3);
            app.MaxWavelengthEditFieldLabel.HorizontalAlignment = 'right';
            app.MaxWavelengthEditFieldLabel.FontSize = 18;
            app.MaxWavelengthEditFieldLabel.Visible = 'off';
            app.MaxWavelengthEditFieldLabel.Layout.Row = 2;
            app.MaxWavelengthEditFieldLabel.Layout.Column = [2 3];
            app.MaxWavelengthEditFieldLabel.Text = 'Max Wavelength';

            % Create MaxWavelengthEditField
            app.MaxWavelengthEditField = uieditfield(app.GridLayout3, 'numeric');
            app.MaxWavelengthEditField.Limits = [0 Inf];
            app.MaxWavelengthEditField.ValueDisplayFormat = '%.2f nm';
            app.MaxWavelengthEditField.ValueChangedFcn = createCallbackFcn(app, @MaxWavelengthEditFieldValueChanged, true);
            app.MaxWavelengthEditField.FontSize = 18;
            app.MaxWavelengthEditField.Visible = 'off';
            app.MaxWavelengthEditField.Layout.Row = 2;
            app.MaxWavelengthEditField.Layout.Column = 4;
            app.MaxWavelengthEditField.Value = 785.5;

            % Create MinWavelengthEditFieldLabel
            app.MinWavelengthEditFieldLabel = uilabel(app.GridLayout3);
            app.MinWavelengthEditFieldLabel.HorizontalAlignment = 'right';
            app.MinWavelengthEditFieldLabel.FontSize = 18;
            app.MinWavelengthEditFieldLabel.Visible = 'off';
            app.MinWavelengthEditFieldLabel.Layout.Row = 3;
            app.MinWavelengthEditFieldLabel.Layout.Column = [2 3];
            app.MinWavelengthEditFieldLabel.Text = 'Min Wavelength';

            % Create MinWavelengthEditField
            app.MinWavelengthEditField = uieditfield(app.GridLayout3, 'numeric');
            app.MinWavelengthEditField.Limits = [0 Inf];
            app.MinWavelengthEditField.ValueDisplayFormat = '%.2f nm';
            app.MinWavelengthEditField.ValueChangedFcn = createCallbackFcn(app, @MinWavelengthEditFieldValueChanged, true);
            app.MinWavelengthEditField.FontSize = 18;
            app.MinWavelengthEditField.Visible = 'off';
            app.MinWavelengthEditField.Layout.Row = 3;
            app.MinWavelengthEditField.Layout.Column = 4;
            app.MinWavelengthEditField.Value = 784.5;

            % Create LaserPowerEditFieldLabel
            app.LaserPowerEditFieldLabel = uilabel(app.GridLayout3);
            app.LaserPowerEditFieldLabel.HorizontalAlignment = 'right';
            app.LaserPowerEditFieldLabel.FontSize = 18;
            app.LaserPowerEditFieldLabel.Visible = 'off';
            app.LaserPowerEditFieldLabel.Layout.Row = 4;
            app.LaserPowerEditFieldLabel.Layout.Column = [2 3];
            app.LaserPowerEditFieldLabel.Text = 'Laser Power';

            % Create LaserPowerEditField
            app.LaserPowerEditField = uieditfield(app.GridLayout3, 'numeric');
            app.LaserPowerEditField.Limits = [0 Inf];
            app.LaserPowerEditField.ValueDisplayFormat = '%.2f mW';
            app.LaserPowerEditField.ValueChangedFcn = createCallbackFcn(app, @LaserPowerEditFieldValueChanged, true);
            app.LaserPowerEditField.FontSize = 18;
            app.LaserPowerEditField.Visible = 'off';
            app.LaserPowerEditField.Layout.Row = 4;
            app.LaserPowerEditField.Layout.Column = 4;
            app.LaserPowerEditField.Value = 50.5;

            % Create TuningStepsEditFieldLabel
            app.TuningStepsEditFieldLabel = uilabel(app.GridLayout3);
            app.TuningStepsEditFieldLabel.HorizontalAlignment = 'right';
            app.TuningStepsEditFieldLabel.FontSize = 18;
            app.TuningStepsEditFieldLabel.Visible = 'off';
            app.TuningStepsEditFieldLabel.Layout.Row = 5;
            app.TuningStepsEditFieldLabel.Layout.Column = [2 3];
            app.TuningStepsEditFieldLabel.Text = 'Tuning Steps';

            % Create TuningStepsEditField
            app.TuningStepsEditField = uieditfield(app.GridLayout3, 'numeric');
            app.TuningStepsEditField.Limits = [0 Inf];
            app.TuningStepsEditField.RoundFractionalValues = 'on';
            app.TuningStepsEditField.ValueDisplayFormat = '%.0f';
            app.TuningStepsEditField.ValueChangedFcn = createCallbackFcn(app, @TuningStepsEditFieldValueChanged, true);
            app.TuningStepsEditField.HorizontalAlignment = 'center';
            app.TuningStepsEditField.FontSize = 18;
            app.TuningStepsEditField.Visible = 'off';
            app.TuningStepsEditField.Layout.Row = 5;
            app.TuningStepsEditField.Layout.Column = 4;
            app.TuningStepsEditField.Value = 5;

            % Create LaserShutterButton
            app.LaserShutterButton = uibutton(app.GridLayout3, 'push');
            app.LaserShutterButton.FontSize = 18;
            app.LaserShutterButton.Visible = 'off';
            app.LaserShutterButton.Layout.Row = 9;
            app.LaserShutterButton.Layout.Column = [1 2];
            app.LaserShutterButton.Text = 'Laser Shutter';

            % Create SavePathButton
            app.SavePathButton = uibutton(app.GridLayout3, 'push');
            app.SavePathButton.ButtonPushedFcn = createCallbackFcn(app, @SavePathButtonPushed, true);
            app.SavePathButton.FontSize = 18;
            app.SavePathButton.Layout.Row = 6;
            app.SavePathButton.Layout.Column = [3 4];
            app.SavePathButton.Text = 'Save Path';

            % Create ClinicalModeButton
            app.ClinicalModeButton = uibutton(app.GridLayout3, 'push');
            app.ClinicalModeButton.ButtonPushedFcn = createCallbackFcn(app, @ClinicalModeButtonPushed, true);
            app.ClinicalModeButton.BackgroundColor = [0.0588 1 1];
            app.ClinicalModeButton.FontSize = 18;
            app.ClinicalModeButton.Visible = 'off';
            app.ClinicalModeButton.Layout.Row = 9;
            app.ClinicalModeButton.Layout.Column = [3 4];
            app.ClinicalModeButton.Text = 'Clinical Mode';

            % Create SingleRamanButton
            app.SingleRamanButton = uibutton(app.GridLayout3, 'push');
            app.SingleRamanButton.ButtonPushedFcn = createCallbackFcn(app, @SingleRamanButtonPushed, true);
            app.SingleRamanButton.BackgroundColor = [0 1 0];
            app.SingleRamanButton.FontSize = 18;
            app.SingleRamanButton.Visible = 'off';
            app.SingleRamanButton.Layout.Row = 8;
            app.SingleRamanButton.Layout.Column = [1 2];
            app.SingleRamanButton.Text = 'Single Raman';

            % Create PanelEngineering
            app.PanelEngineering = uipanel(app.GridLayout);
            app.PanelEngineering.BorderType = 'none';
            app.PanelEngineering.Layout.Row = 1;
            app.PanelEngineering.Layout.Column = 1;
            app.PanelEngineering.FontSize = 18;

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.PanelEngineering);
            app.GridLayout2.ColumnWidth = {'1x', '0.65x', '1x', '0.5x'};

            % Create MinRamanShiftEditFieldLabel
            app.MinRamanShiftEditFieldLabel = uilabel(app.GridLayout2);
            app.MinRamanShiftEditFieldLabel.HorizontalAlignment = 'right';
            app.MinRamanShiftEditFieldLabel.FontSize = 18;
            app.MinRamanShiftEditFieldLabel.Visible = 'off';
            app.MinRamanShiftEditFieldLabel.Layout.Row = 1;
            app.MinRamanShiftEditFieldLabel.Layout.Column = 3;
            app.MinRamanShiftEditFieldLabel.Text = 'Min. Raman Shift';

            % Create MinRamanShiftEditField
            app.MinRamanShiftEditField = uieditfield(app.GridLayout2, 'numeric');
            app.MinRamanShiftEditField.ValueDisplayFormat = '%11.4g nm';
            app.MinRamanShiftEditField.ValueChangedFcn = createCallbackFcn(app, @MinRamanShiftEditFieldValueChanged, true);
            app.MinRamanShiftEditField.FontSize = 18;
            app.MinRamanShiftEditField.Visible = 'off';
            app.MinRamanShiftEditField.Layout.Row = 1;
            app.MinRamanShiftEditField.Layout.Column = 4;

            % Create MaxRamanShiftEditFieldLabel
            app.MaxRamanShiftEditFieldLabel = uilabel(app.GridLayout2);
            app.MaxRamanShiftEditFieldLabel.HorizontalAlignment = 'right';
            app.MaxRamanShiftEditFieldLabel.FontSize = 18;
            app.MaxRamanShiftEditFieldLabel.Visible = 'off';
            app.MaxRamanShiftEditFieldLabel.Layout.Row = 2;
            app.MaxRamanShiftEditFieldLabel.Layout.Column = 3;
            app.MaxRamanShiftEditFieldLabel.Text = 'Max. Raman Shift';

            % Create MaxRamanShiftEditField
            app.MaxRamanShiftEditField = uieditfield(app.GridLayout2, 'numeric');
            app.MaxRamanShiftEditField.Limits = [0 Inf];
            app.MaxRamanShiftEditField.ValueDisplayFormat = '%11.4g nm';
            app.MaxRamanShiftEditField.ValueChangedFcn = createCallbackFcn(app, @MaxRamanShiftEditFieldValueChanged, true);
            app.MaxRamanShiftEditField.FontSize = 18;
            app.MaxRamanShiftEditField.Visible = 'off';
            app.MaxRamanShiftEditField.Layout.Row = 2;
            app.MaxRamanShiftEditField.Layout.Column = 4;
            app.MaxRamanShiftEditField.Value = 3000;

            % Create SlitWidthEditField
            app.SlitWidthEditField = uieditfield(app.GridLayout2, 'numeric');
            app.SlitWidthEditField.Limits = [0 Inf];
            app.SlitWidthEditField.ValueDisplayFormat = '%.2f um';
            app.SlitWidthEditField.ValueChangedFcn = createCallbackFcn(app, @changeSlitWidth, true);
            app.SlitWidthEditField.FontSize = 18;
            app.SlitWidthEditField.Visible = 'off';
            app.SlitWidthEditField.Layout.Row = 2;
            app.SlitWidthEditField.Layout.Column = 2;
            app.SlitWidthEditField.Value = 150;

            % Create SlitWidthEditFieldLabel
            app.SlitWidthEditFieldLabel = uilabel(app.GridLayout2);
            app.SlitWidthEditFieldLabel.HorizontalAlignment = 'right';
            app.SlitWidthEditFieldLabel.FontSize = 18;
            app.SlitWidthEditFieldLabel.Visible = 'off';
            app.SlitWidthEditFieldLabel.Layout.Row = 2;
            app.SlitWidthEditFieldLabel.Layout.Column = 1;
            app.SlitWidthEditFieldLabel.Text = 'Slit Width';

            % Create CCDTempEditField
            app.CCDTempEditField = uieditfield(app.GridLayout2, 'numeric');
            app.CCDTempEditField.ValueDisplayFormat = '%11.4g C';
            app.CCDTempEditField.ValueChangedFcn = createCallbackFcn(app, @CCDTempEditFieldValueChanged, true);
            app.CCDTempEditField.FontSize = 18;
            app.CCDTempEditField.Visible = 'off';
            app.CCDTempEditField.Layout.Row = 1;
            app.CCDTempEditField.Layout.Column = 2;
            app.CCDTempEditField.Value = -70;

            % Create CCDTempEditFieldLabel
            app.CCDTempEditFieldLabel = uilabel(app.GridLayout2);
            app.CCDTempEditFieldLabel.HorizontalAlignment = 'right';
            app.CCDTempEditFieldLabel.FontSize = 18;
            app.CCDTempEditFieldLabel.Visible = 'off';
            app.CCDTempEditFieldLabel.Layout.Row = 1;
            app.CCDTempEditFieldLabel.Layout.Column = 1;
            app.CCDTempEditFieldLabel.Text = 'CCD Temp';

            % Create PanelDisplay
            app.PanelDisplay = uipanel(app.GridLayout);
            app.PanelDisplay.BorderType = 'none';
            app.PanelDisplay.Layout.Row = 1;
            app.PanelDisplay.Layout.Column = 2;

            % Create GridLayout1
            app.GridLayout1 = uigridlayout(app.PanelDisplay);
            app.GridLayout1.ColumnWidth = {'1x', '0.4x'};

            % Create SpectraAcquiredEditFieldLabel
            app.SpectraAcquiredEditFieldLabel = uilabel(app.GridLayout1);
            app.SpectraAcquiredEditFieldLabel.HorizontalAlignment = 'right';
            app.SpectraAcquiredEditFieldLabel.FontSize = 18;
            app.SpectraAcquiredEditFieldLabel.Layout.Row = 1;
            app.SpectraAcquiredEditFieldLabel.Layout.Column = 1;
            app.SpectraAcquiredEditFieldLabel.Text = 'Spectra Acquired';

            % Create SpectraAcquiredEditField
            app.SpectraAcquiredEditField = uieditfield(app.GridLayout1, 'numeric');
            app.SpectraAcquiredEditField.HorizontalAlignment = 'center';
            app.SpectraAcquiredEditField.FontSize = 18;
            app.SpectraAcquiredEditField.Layout.Row = 1;
            app.SpectraAcquiredEditField.Layout.Column = 2;

            % Create TimeTakenEditFieldLabel
            app.TimeTakenEditFieldLabel = uilabel(app.GridLayout1);
            app.TimeTakenEditFieldLabel.HorizontalAlignment = 'right';
            app.TimeTakenEditFieldLabel.FontSize = 18;
            app.TimeTakenEditFieldLabel.Layout.Row = 2;
            app.TimeTakenEditFieldLabel.Layout.Column = 1;
            app.TimeTakenEditFieldLabel.Text = 'Time Taken';

            % Create TimeTakenEditField
            app.TimeTakenEditField = uieditfield(app.GridLayout1, 'text');
            app.TimeTakenEditField.HorizontalAlignment = 'center';
            app.TimeTakenEditField.FontSize = 18;
            app.TimeTakenEditField.Placeholder = '00:00:00';
            app.TimeTakenEditField.Layout.Row = 2;
            app.TimeTakenEditField.Layout.Column = 2;

            % Show the figure after all components are created
            app.RamanModuleUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Raman_GUI_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.RamanModuleUIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.RamanModuleUIFigure)
        end
    end
end