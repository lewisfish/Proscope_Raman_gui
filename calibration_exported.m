classdef calibration_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        CalibrationUIFigure      matlab.ui.Figure
        GridLayout               matlab.ui.container.GridLayout
        CalibrationPanel         matlab.ui.container.GridLayout
        PatientIDEditField       matlab.ui.control.NumericEditField
        PatientIDEditFieldLabel  matlab.ui.control.Label
        CalibrateButton          matlab.ui.control.Button
        SetSavePathButton        matlab.ui.control.Button
        CalibrationAxes          matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        CallingApp = []; % Main App
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, caller)
            app.CallingApp = caller;
        end

        % Button pushed function: CalibrateButton
        function CalibrateButtonPushed(app, event)
%             if app.spectrometerHandle.CCDCooled == 1
                app.CallingApp.CalibrationDone = true;
                %integration time is 1s, rest is standard
%                 expTime = app.CallingApp.spectrometerHandle.ExposureTime;
%                 app.CallingApp.spectrometerHandle.setExposureTime(1.0);
%                 [w, s] = app.CallingApp.spectrometerHandle.AquireSpectra();
%                 saveData(app.CallingApp, w, s, app.CallingApp.CalibrationSaveDir, 'calibration');
%                 plot(app.CalibrationAxes, w, s, 'r-');
                  plot(app.CalibrationAxes,linspace(0, 3000, 3000)',zeros(3000, 1),'r-');

%                 app.CallingApp.spectrometerHandle.setExposureTime(expTime);
%             else
%                 uialert(app.CalibrationUIFigure, "CCD not fully cooled!","Calibration Warning","Icon","warning");
%             end
        end

        % Button pushed function: SetSavePathButton
        function SetSavePathButtonPushed(app, event)
            if isempty(app.CallingApp.PatientID)
                uialert(app.CalibrationUIFigure, "PatientID not Entered!","Calibration Warning");
            else
                app.CallingApp.CalibrationSaveDir = uigetdir("", "Patient data Folder");
                %stop app losing focus
%                 app.RamanControlUIFigure.Visible = 'off';
%                 app.RamanControlUIFigure.Visible = 'on';
                app.CalibrateButton.Enable = "on";
            end
        end

        % Value changed function: PatientIDEditField
        function PatientIDEditFieldValueChanged(app, event)
            value = app.PatientIDEditField.Value;
            value_length = ceil(log10(abs(double(fix(value)))+1));
            if value_length ~= 6
                uialert(app.CalibrationUIFigure, "PatientID must be 6 digits long!","User Error");
                return
            end
            strs = [string(value), app.CallingApp.dateTime];
            app.CallingApp.PatientID = join(strs, "_");
            disp(app.CallingApp.PatientID);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create CalibrationUIFigure and hide until all components are created
            app.CalibrationUIFigure = uifigure('Visible', 'off');
            app.CalibrationUIFigure.Position = [100 100 1024 768];
            app.CalibrationUIFigure.Name = 'Raman Calibration';
            app.CalibrationUIFigure.Icon = 'logo.jpeg';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.CalibrationUIFigure);
            app.GridLayout.ColumnWidth = {'1x', '0.75x'};
            app.GridLayout.RowHeight = {'1x'};

            % Create CalibrationAxes
            app.CalibrationAxes = uiaxes(app.GridLayout);
            title(app.CalibrationAxes, 'Calibration Spectrum')
            xlabel(app.CalibrationAxes, 'Wavenumber/cm^{-1}')
            ylabel(app.CalibrationAxes, 'Raman Intensity/arb.')
            zlabel(app.CalibrationAxes, 'Z')
            app.CalibrationAxes.FontSize = 18;
            app.CalibrationAxes.Layout.Row = 1;
            app.CalibrationAxes.Layout.Column = 1;

            % Create CalibrationPanel
            app.CalibrationPanel = uigridlayout(app.GridLayout);
            app.CalibrationPanel.ColumnWidth = {'1x', '1x', '1x', '1x'};
            app.CalibrationPanel.RowHeight = {'1x', '1x', '1x', '1x', '1x', '1x', '1x'};
            app.CalibrationPanel.Layout.Row = 1;
            app.CalibrationPanel.Layout.Column = 2;

            % Create SetSavePathButton
            app.SetSavePathButton = uibutton(app.CalibrationPanel, 'push');
            app.SetSavePathButton.ButtonPushedFcn = createCallbackFcn(app, @SetSavePathButtonPushed, true);
            app.SetSavePathButton.FontSize = 18;
            app.SetSavePathButton.Layout.Row = 4;
            app.SetSavePathButton.Layout.Column = [2 3];
            app.SetSavePathButton.Text = 'Set Save Path';

            % Create CalibrateButton
            app.CalibrateButton = uibutton(app.CalibrationPanel, 'push');
            app.CalibrateButton.ButtonPushedFcn = createCallbackFcn(app, @CalibrateButtonPushed, true);
            app.CalibrateButton.FontSize = 18;
            app.CalibrateButton.Enable = 'off';
            app.CalibrateButton.Layout.Row = 5;
            app.CalibrateButton.Layout.Column = [2 3];
            app.CalibrateButton.Text = 'Calibrate';

            % Create PatientIDEditFieldLabel
            app.PatientIDEditFieldLabel = uilabel(app.CalibrationPanel);
            app.PatientIDEditFieldLabel.HorizontalAlignment = 'right';
            app.PatientIDEditFieldLabel.FontSize = 18;
            app.PatientIDEditFieldLabel.Layout.Row = 3;
            app.PatientIDEditFieldLabel.Layout.Column = 2;
            app.PatientIDEditFieldLabel.Text = 'PatientID';

            % Create PatientIDEditField
            app.PatientIDEditField = uieditfield(app.CalibrationPanel, 'numeric');
            app.PatientIDEditField.Limits = [0 999999];
            app.PatientIDEditField.RoundFractionalValues = 'on';
            app.PatientIDEditField.ValueDisplayFormat = '%0.0f';
            app.PatientIDEditField.ValueChangedFcn = createCallbackFcn(app, @PatientIDEditFieldValueChanged, true);
            app.PatientIDEditField.HorizontalAlignment = 'center';
            app.PatientIDEditField.FontSize = 18;
            app.PatientIDEditField.Layout.Row = 3;
            app.PatientIDEditField.Layout.Column = 3;

            % Show the figure after all components are created
            app.CalibrationUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = calibration_exported(varargin)

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.CalibrationUIFigure)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.CalibrationUIFigure)
        end
    end
end