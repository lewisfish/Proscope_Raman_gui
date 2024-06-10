classdef main_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        RamanControlUIFigure           matlab.ui.Figure
        GridLayout                     matlab.ui.container.GridLayout
        PanelDisplay                   matlab.ui.container.Panel
        GridLayout4                    matlab.ui.container.GridLayout
        TimeTakenEditField             matlab.ui.control.EditField
        TimeTakenEditFieldLabel        matlab.ui.control.Label
        SpectraAcquiredEditField       matlab.ui.control.NumericEditField
        SpectraAcquiredEditFieldLabel  matlab.ui.control.Label
        PanelEngineering               matlab.ui.container.Panel
        GridLayout2                    matlab.ui.container.GridLayout
        MaxRamanShiftEditField         matlab.ui.control.NumericEditField
        MaxRamanShiftEditFieldLabel    matlab.ui.control.Label
        MinRamanShiftEditField         matlab.ui.control.NumericEditField
        MinRamanShiftEditFieldLabel    matlab.ui.control.Label
        SlitWidthEditField             matlab.ui.control.NumericEditField
        SlitWidthEditFieldLabel        matlab.ui.control.Label
        CCDTempEditField               matlab.ui.control.NumericEditField
        CCDTempEditFieldLabel          matlab.ui.control.Label
        PanelMain                      matlab.ui.container.Panel
        GridLayout3                    matlab.ui.container.GridLayout
        ClinicalModeButton             matlab.ui.control.Button
        AbortButton                    matlab.ui.control.Button
        AcquireButton                  matlab.ui.control.Button
        ExitButton                     matlab.ui.control.Button
        EngineeringModeButton          matlab.ui.control.Button
        SavePathButton                 matlab.ui.control.Button
        LaserPowerEditField            matlab.ui.control.NumericEditField
        LaserPowerEditFieldLabel       matlab.ui.control.Label
        AquireAxes                     matlab.ui.control.UIAxes
    end

    properties (Access = private)
        CalibrationApp % handle for calibration window
        SpectraSaveDir % Patient data directory
        SpectraAcquired = 0 % Number of spectra acquired
        tmr % Timer class
        LaserHandle % Laser class
        spectrometerHandle % spectrometer class
%         WMRS = false % Flag set to true if WRMS mode is active.
        steps =5% number of spectra to take for WRMS mode.
        abortSignal = false % abort acquistion
    end
    properties (Access = public)
        % these Must be public as passed to outside function.
        time = 0 % start time. 
        PatientID % user defined Patient Id + current time/data
        CalibrationDone = false % Flag set to true if calibration has be carried out.
        CalibrationSaveDir % Calibration directory
        dateTime % store date time at startup
    end
    methods (Access = public)
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
                    uialert(app.RamanControlUIFigure, "Not Enough Memory on Hard Drive!","Memory Error");
                    delete(app);
                end
                uialert(app.RamanControlUIFigure, "Warning, less than 10Gb of disk space free!","Memory Warning",'Icon','warning');
            end
            
            % Set up timer
            % https://www.mathworks.com/matlabcentral/fileexchange/24861-41-complete-gui-examples
            app.tmr = timer('TimerFcn',{@updater, app},...
                            'Period',1,...  % Update the time every 60 seconds.
                            'StartDelay',0,... % In seconds.
                            'TasksToExecute',inf,...  % number of times to update
                            'ExecutionMode','fixedSpacing');
% old
%             app.LaserHandle = Laser();
%             app.LaserHandle.enableLaserHeaterPower();
% new
%             app.LaserHandle = Raman_box_laser();
%             app.LaserHandle.turn_on();
            
            %add spectrometer setup here
%             app.spectrometerHandle = Andor(-70.0, 1, 1.00, 0, 0, 1, 150, 785.0, app.RamanControlUIFigure);
            
            %set up spectra viewer
            app.AquireAxes.XLim = [app.MinRamanShiftEditField.Value, app.MaxRamanShiftEditField.Value];
            
            % add time to patientID
            app.dateTime = string(datetime('now','TimeZone','local','Format','dd-MM-yyyy''T''HHmmss'));
            
            app.CalibrationApp = calibration(app);
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
%                       single spectra mode
%                         [w, s] = app.spectrometerHandle.AquireSpectra();
%                         saveData(app, w, s, app.SpectraSaveDir);
%                         plot(app.AquireAxes, w, s, 'r-');
                          plot(app.AquireAxes,linspace(0, 3000, 3000)',randn(3000, 1),'r-');

                        app.SpectraAcquired = app.SpectraAcquired + 1;
                        app.SpectraAcquiredEditField.Value = app.SpectraAcquired;
                else
                    uialert(app.RamanControlUIFigure, "Save path for spectra not set!", "Path not set")
                end
            else
                uialert(app.RamanControlUIFigure, "Calibration Data not taken!","Calibration Warning");
            end
            app.AcquireButton.Enable = true;
        end

        % Button pushed function: AbortButton
        function AbortButtonPushed(app, event)
            app.abortSignal = true;
            app.spectrometerHandle.Abort();
            uialert(app.RamanControlUIFigure, 'Acquisition aborted!', 'Warning','Icon','warning');
            app.AcquireButton.Enable = true;
        end

        % Button pushed function: EngineeringModeButton
        function EngineeringModeButtonPushed(app, event)
            answer = inputdlg("Enter Password");
            if answer == "proscope2023"
                app.CCDTempEditField.Visible = 'on';
                app.CCDTempEditFieldLabel.Visible = 'on';
                
                app.MinRamanShiftEditField.Visible = 'on';
                app.MinRamanShiftEditFieldLabel.Visible = 'on';
    
                app.MaxRamanShiftEditField.Visible = 'on';
                app.MaxRamanShiftEditFieldLabel.Visible = 'on';
    
                app.LaserPowerEditField.Visible = "on";
                app.LaserPowerEditFieldLabel.Visible = "on";
                
                app.SlitWidthEditField.Visible = "on";
                app.SlitWidthEditFieldLabel.Visible = "on";
   
                app.EngineeringModeButton.Visible = "off";
                app.ClinicalModeButton.Visible = "on";
            else
                uialert(app.RamanControlUIFigure, "Wrong Password!","Security Error");
            end 
        end

        % Button pushed function: ClinicalModeButton
        function ClinicalModeButtonPushed(app, event)

            app.CCDTempEditField.Visible = 'off';
            app.CCDTempEditFieldLabel.Visible = 'off';
            
            app.MinRamanShiftEditField.Visible = 'off';
            app.MinRamanShiftEditFieldLabel.Visible = 'off';

            app.MaxRamanShiftEditField.Visible = 'off';
            app.MaxRamanShiftEditFieldLabel.Visible = 'off';

            app.LaserPowerEditField.Visible = "off";
            app.LaserPowerEditFieldLabel.Visible = "off";
            
            app.SlitWidthEditField.Visible = "off";
            app.SlitWidthEditFieldLabel.Visible = "off";
                    
            app.EngineeringModeButton.Visible = "on";
            app.ClinicalModeButton.Visible = "off";
        end

        % Button pushed function: SavePathButton
        function SavePathButtonPushed(app, event)
            app.SpectraSaveDir = uigetdir("", "Patient Data Folder");
            %stop app losing focus
%             app.RamanControlUIFigure.Visible = 'off';
%             app.RamanControlUIFigure.Visible = 'on';
        end

        % Callback function: ExitButton, RamanControlUIFigure
        function UIFigureCloseRequest(app, event)
            answer = questdlg("Do you want to shutdown the software?");
            if answer == "Yes"
%                 app.spectrometerHandle.ShutDownSafe(app.RamanControlUIFigure);
%                 app.LaserHandle.switchOff();
%               app.LaserHandle.turn_off();
                stop(app.tmr);
                delete(app.tmr);
                delete(app.CalibrationApp);
                delete(app);
            end      
        end

        % Size changed function: RamanControlUIFigure
        function RamanControlUIFigureSizeChanged(app, event)
            position = app.RamanControlUIFigure.Position;
            if position(3) < 1024 || position(4) < 768
                uialert(app.RamanControlUIFigure, 'Too small a window!', 'Warning','Icon','warning');
                app.RamanControlUIFigure.Position = [position(1),position(2),1024,768];
            else
                app.RamanControlUIFigure.Position = [2,1,position(3),position(4)];
            end
        end

        % Key press function: RamanControlUIFigure
        function RamanControlUIFigureKeyPress(app, event)
            key = event.Key;
            switch key
                case 'space' % acquire
                    app.AcquireButtonPushed();
                case 's' %stop
                    app.abortButtonPushed();
            end
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

        % Value changed function: CCDTempEditField
        function CCDTempEditFieldValueChanged(app, event)
            value = app.CCDTempEditField.Value;
            app.spectrometerHandle.SetCCDTemp(value);
        end

        % Value changed function: SlitWidthEditField
        function SlitWidthEditFieldValueChanged(app, event)
            value = app.SlitWidthEditField.Value;
            app.spectrometerHandle.setSlitWidth(value);
        end

        % Callback function
        function LaserPowerEditFieldValueChanged(app, event)
            value = app.LaserPowerEditField.Value;
            %this is heater current in FBH parlance...
            app.LaserHandle.setCurrentViaPower(value);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create RamanControlUIFigure and hide until all components are created
            app.RamanControlUIFigure = uifigure('Visible', 'off');
            app.RamanControlUIFigure.AutoResizeChildren = 'off';
            app.RamanControlUIFigure.Position = [100 100 1024 768];
            app.RamanControlUIFigure.Name = 'Raman Control';
            app.RamanControlUIFigure.Icon = 'logo.jpeg';
            app.RamanControlUIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);
            app.RamanControlUIFigure.SizeChangedFcn = createCallbackFcn(app, @RamanControlUIFigureSizeChanged, true);
            app.RamanControlUIFigure.KeyPressFcn = createCallbackFcn(app, @RamanControlUIFigureKeyPress, true);
            app.RamanControlUIFigure.WindowState = 'maximized';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.RamanControlUIFigure);
            app.GridLayout.ColumnWidth = {'1x', '0.75x'};
            app.GridLayout.RowHeight = {'0.2x', '1x'};

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
            app.PanelMain.AutoResizeChildren = 'off';
            app.PanelMain.Layout.Row = 2;
            app.PanelMain.Layout.Column = 2;

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.PanelMain);
            app.GridLayout3.ColumnWidth = {'1x', '1x', '1x', '1x'};
            app.GridLayout3.RowHeight = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};

            % Create LaserPowerEditFieldLabel
            app.LaserPowerEditFieldLabel = uilabel(app.GridLayout3);
            app.LaserPowerEditFieldLabel.HorizontalAlignment = 'right';
            app.LaserPowerEditFieldLabel.FontSize = 18;
            app.LaserPowerEditFieldLabel.Visible = 'off';
            app.LaserPowerEditFieldLabel.Layout.Row = 5;
            app.LaserPowerEditFieldLabel.Layout.Column = [2 3];
            app.LaserPowerEditFieldLabel.Text = 'Laser Power';

            % Create LaserPowerEditField
            app.LaserPowerEditField = uieditfield(app.GridLayout3, 'numeric');
            app.LaserPowerEditField.Limits = [0 Inf];
            app.LaserPowerEditField.ValueDisplayFormat = '%.2f mW';
            app.LaserPowerEditField.FontSize = 18;
            app.LaserPowerEditField.Visible = 'off';
            app.LaserPowerEditField.Layout.Row = 5;
            app.LaserPowerEditField.Layout.Column = 4;
            app.LaserPowerEditField.Value = 50.5;

            % Create SavePathButton
            app.SavePathButton = uibutton(app.GridLayout3, 'push');
            app.SavePathButton.ButtonPushedFcn = createCallbackFcn(app, @SavePathButtonPushed, true);
            app.SavePathButton.FontSize = 18;
            app.SavePathButton.Layout.Row = 6;
            app.SavePathButton.Layout.Column = [3 4];
            app.SavePathButton.Text = 'Save Path';

            % Create EngineeringModeButton
            app.EngineeringModeButton = uibutton(app.GridLayout3, 'push');
            app.EngineeringModeButton.ButtonPushedFcn = createCallbackFcn(app, @EngineeringModeButtonPushed, true);
            app.EngineeringModeButton.BackgroundColor = [0.9294 0.6902 0.1294];
            app.EngineeringModeButton.FontSize = 18;
            app.EngineeringModeButton.Layout.Row = 9;
            app.EngineeringModeButton.Layout.Column = [3 4];
            app.EngineeringModeButton.Text = 'Engineering Mode';

            % Create ExitButton
            app.ExitButton = uibutton(app.GridLayout3, 'push');
            app.ExitButton.ButtonPushedFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);
            app.ExitButton.BackgroundColor = [1 0.4118 0.1608];
            app.ExitButton.FontSize = 18;
            app.ExitButton.Layout.Row = 8;
            app.ExitButton.Layout.Column = [3 4];
            app.ExitButton.Text = 'Exit';

            % Create AcquireButton
            app.AcquireButton = uibutton(app.GridLayout3, 'push');
            app.AcquireButton.ButtonPushedFcn = createCallbackFcn(app, @AcquireButtonPushed, true);
            app.AcquireButton.BackgroundColor = [0.0706 0.6196 1];
            app.AcquireButton.FontSize = 18;
            app.AcquireButton.Layout.Row = 7;
            app.AcquireButton.Layout.Column = [1 2];
            app.AcquireButton.Text = 'Acquire';

            % Create AbortButton
            app.AbortButton = uibutton(app.GridLayout3, 'push');
            app.AbortButton.ButtonPushedFcn = createCallbackFcn(app, @AbortButtonPushed, true);
            app.AbortButton.BackgroundColor = [0.851 0.3294 0.102];
            app.AbortButton.FontSize = 18;
            app.AbortButton.Layout.Row = 7;
            app.AbortButton.Layout.Column = [3 4];
            app.AbortButton.Text = 'Abort';

            % Create ClinicalModeButton
            app.ClinicalModeButton = uibutton(app.GridLayout3, 'push');
            app.ClinicalModeButton.ButtonPushedFcn = createCallbackFcn(app, @ClinicalModeButtonPushed, true);
            app.ClinicalModeButton.BackgroundColor = [0.0588 1 1];
            app.ClinicalModeButton.FontSize = 18;
            app.ClinicalModeButton.Visible = 'off';
            app.ClinicalModeButton.Layout.Row = 9;
            app.ClinicalModeButton.Layout.Column = [3 4];
            app.ClinicalModeButton.Text = 'Clinical Mode';

            % Create PanelEngineering
            app.PanelEngineering = uipanel(app.GridLayout);
            app.PanelEngineering.AutoResizeChildren = 'off';
            app.PanelEngineering.Layout.Row = 1;
            app.PanelEngineering.Layout.Column = 1;

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.PanelEngineering);
            app.GridLayout2.ColumnWidth = {'1x', '0.65x', '1x', '0.5x'};

            % Create CCDTempEditFieldLabel
            app.CCDTempEditFieldLabel = uilabel(app.GridLayout2);
            app.CCDTempEditFieldLabel.HorizontalAlignment = 'right';
            app.CCDTempEditFieldLabel.FontSize = 18;
            app.CCDTempEditFieldLabel.Visible = 'off';
            app.CCDTempEditFieldLabel.Layout.Row = 1;
            app.CCDTempEditFieldLabel.Layout.Column = 1;
            app.CCDTempEditFieldLabel.Text = 'CCD Temp';

            % Create CCDTempEditField
            app.CCDTempEditField = uieditfield(app.GridLayout2, 'numeric');
            app.CCDTempEditField.ValueDisplayFormat = '%11.4g C';
            app.CCDTempEditField.ValueChangedFcn = createCallbackFcn(app, @CCDTempEditFieldValueChanged, true);
            app.CCDTempEditField.FontSize = 18;
            app.CCDTempEditField.Visible = 'off';
            app.CCDTempEditField.Layout.Row = 1;
            app.CCDTempEditField.Layout.Column = 2;
            app.CCDTempEditField.Value = -70;

            % Create SlitWidthEditFieldLabel
            app.SlitWidthEditFieldLabel = uilabel(app.GridLayout2);
            app.SlitWidthEditFieldLabel.HorizontalAlignment = 'right';
            app.SlitWidthEditFieldLabel.FontSize = 18;
            app.SlitWidthEditFieldLabel.Visible = 'off';
            app.SlitWidthEditFieldLabel.Layout.Row = 2;
            app.SlitWidthEditFieldLabel.Layout.Column = 1;
            app.SlitWidthEditFieldLabel.Text = 'Slit Width';

            % Create SlitWidthEditField
            app.SlitWidthEditField = uieditfield(app.GridLayout2, 'numeric');
            app.SlitWidthEditField.Limits = [0 Inf];
            app.SlitWidthEditField.ValueDisplayFormat = '%.2f um';
            app.SlitWidthEditField.ValueChangedFcn = createCallbackFcn(app, @SlitWidthEditFieldValueChanged, true);
            app.SlitWidthEditField.FontSize = 18;
            app.SlitWidthEditField.Visible = 'off';
            app.SlitWidthEditField.Layout.Row = 2;
            app.SlitWidthEditField.Layout.Column = 2;
            app.SlitWidthEditField.Value = 150;

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
            app.MinRamanShiftEditField.Limits = [0 Inf];
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

            % Create PanelDisplay
            app.PanelDisplay = uipanel(app.GridLayout);
            app.PanelDisplay.AutoResizeChildren = 'off';
            app.PanelDisplay.Layout.Row = 1;
            app.PanelDisplay.Layout.Column = 2;

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.PanelDisplay);
            app.GridLayout4.ColumnWidth = {'1x', '0.4x'};

            % Create SpectraAcquiredEditFieldLabel
            app.SpectraAcquiredEditFieldLabel = uilabel(app.GridLayout4);
            app.SpectraAcquiredEditFieldLabel.HorizontalAlignment = 'right';
            app.SpectraAcquiredEditFieldLabel.FontSize = 18;
            app.SpectraAcquiredEditFieldLabel.Layout.Row = 1;
            app.SpectraAcquiredEditFieldLabel.Layout.Column = 1;
            app.SpectraAcquiredEditFieldLabel.Text = 'Spectra Acquired';

            % Create SpectraAcquiredEditField
            app.SpectraAcquiredEditField = uieditfield(app.GridLayout4, 'numeric');
            app.SpectraAcquiredEditField.Limits = [0 Inf];
            app.SpectraAcquiredEditField.HorizontalAlignment = 'center';
            app.SpectraAcquiredEditField.FontSize = 18;
            app.SpectraAcquiredEditField.Layout.Row = 1;
            app.SpectraAcquiredEditField.Layout.Column = 2;

            % Create TimeTakenEditFieldLabel
            app.TimeTakenEditFieldLabel = uilabel(app.GridLayout4);
            app.TimeTakenEditFieldLabel.HorizontalAlignment = 'right';
            app.TimeTakenEditFieldLabel.FontSize = 18;
            app.TimeTakenEditFieldLabel.Layout.Row = 2;
            app.TimeTakenEditFieldLabel.Layout.Column = 1;
            app.TimeTakenEditFieldLabel.Text = 'Time Taken';

            % Create TimeTakenEditField
            app.TimeTakenEditField = uieditfield(app.GridLayout4, 'text');
            app.TimeTakenEditField.HorizontalAlignment = 'center';
            app.TimeTakenEditField.FontSize = 18;
            app.TimeTakenEditField.Placeholder = '00:00:00';
            app.TimeTakenEditField.Layout.Row = 2;
            app.TimeTakenEditField.Layout.Column = 2;

            % Show the figure after all components are created
            app.RamanControlUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = main_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.RamanControlUIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.RamanControlUIFigure)
        end
    end
end