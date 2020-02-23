classdef weatherAnalysisApp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                   matlab.ui.Figure
        ShowmethedataButton        matlab.ui.control.Button
        WeatherDataJan012019Jan012020Panel  matlab.ui.container.Panel
        Label_10                   matlab.ui.control.Label
        AnalysingWeatherDataLabel  matlab.ui.control.Label
        HumidityandTemperaturevsTimePanel  matlab.ui.container.Panel
        UIAxes                     matlab.ui.control.UIAxes
        SmoothTemperatureandRawTempertaurevsTimePanel  matlab.ui.container.Panel
        UIAxes2                    matlab.ui.control.UIAxes
        TemperaturewithlocalminimaandmaximaPanel  matlab.ui.container.Panel
        UIAxes4                    matlab.ui.control.UIAxes
        SmootherTemperatureandRawTemperaturevsTimePanel  matlab.ui.container.Panel
        UIAxes3                    matlab.ui.control.UIAxes
        LocalExtremaPanel          matlab.ui.container.Panel
        UIAxes5                    matlab.ui.control.UIAxes
        ChangePanel                matlab.ui.container.Panel
        UIAxes6                    matlab.ui.control.UIAxes
        NormaliseddatagraphTemperatureHumidityPanel  matlab.ui.container.Panel
        UIAxes7                    matlab.ui.control.UIAxes
        Task1and2Label             matlab.ui.control.Label
        Task3Label                 matlab.ui.control.Label
        Task4Label                 matlab.ui.control.Label
        Task5Label                 matlab.ui.control.Label
        Task67Label                matlab.ui.control.Label
        Task8Label                 matlab.ui.control.Label
        Task9Label                 matlab.ui.control.Label
        Task101112Label            matlab.ui.control.Label
        Label_2                    matlab.ui.control.Label
        Label_3                    matlab.ui.control.Label
        Label_4                    matlab.ui.control.Label
        Label_5                    matlab.ui.control.Label
        Label_6                    matlab.ui.control.Label
        Label_7                    matlab.ui.control.Label
        Label_8                    matlab.ui.control.Label
        Label_9                    matlab.ui.control.Label
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: ShowmethedataButton
        function ShowmethedataButtonPushed(app, event)
            cd '/MATLAB Drive/MathWorksHackathonChallenge/EASY_AnalyseWeatherData';

            From = datetime("JAN 01, 2019");
            To = datetime("JAN 01, 2020");

            chID = 12397
            weather = thingSpeakRead(chID,...
                "DateRange",[From,To],...
                "OutputFormat", "timetable" ); 
            weather.Properties.VariableNames = ["WindDir","WindSpeed",...
                "Humidity","TempF","Rain","Pressure","Power","Intensity"];          
            stackedplot(app.WeatherDataJan012019Jan012020Panel, weather)
            
            
            %  the humidity temp graph
            wdata = retime(weather, 'minutely', 'spline');
            humidity = wdata.Humidity;
            temp = wdata.TempF;
            plot(app.UIAxes,wdata.Timestamps, humidity);
            hold(app.UIAxes, 'on')
            plot(app.UIAxes,wdata.Timestamps, temp);
            hold(app.UIAxes, 'off')
            
            % smoothening humidity and temp
            SmoothNoise=true;
            if SmoothNoise
                smdata = smoothdata(wdata);
                   % Include plot to compare your wdata and the smdata
                plot(app.UIAxes2, temp)
                hold(app.UIAxes2, 'on')
                plot(app.UIAxes2, smdata.TempF)
                hold(app.UIAxes2, 'off')
            end
            
            % the smoother humidity temp graph
            smoothedTemp = smoothdata(smdata.TempF,'movmean','SmoothingFactor',0.25,...
                'SamplePoints',smdata.Timestamps);
            plot(app.UIAxes3, smdata.Timestamps,smdata.TempF,'Color',[109 185 226]/255,...
                'DisplayName','Input data')
            hold(app.UIAxes3, 'on')
            plot(app.UIAxes3, smdata.Timestamps,smoothedTemp,'Color',[0 114 189]/255,'LineWidth',1.5,...
                'DisplayName','Smoothed data')
            hold(app.UIAxes3, 'off')
            
            % find local minima and maxima
            locmin = islocalmin(smdata.TempF)
            locmax = islocalmax(smdata.TempF)
            plot(app.UIAxes4, smdata.Timestamps, smdata.TempF, smdata.Timestamps(locmin), smdata.TempF(locmin), "r*")
            hold(app.UIAxes4, 'on')
            plot(app.UIAxes4, smdata.Timestamps, smdata.TempF, smdata.Timestamps(locmax), smdata.TempF(locmax), "bo")
            hold(app.UIAxes4, 'off')
            
            % find local extrema tool
            maxIndices = islocalmax(smdata.TempF,'SamplePoints',smdata.Timestamps);
            minIndices = islocalmin(smdata.TempF,'SamplePoints',smdata.Timestamps);
            plot(app.UIAxes5, smdata.Timestamps,smdata.TempF,'Color',[109 185 226]/255,...
                'DisplayName','Input data')
            hold(app.UIAxes5, 'on')
            plot(app.UIAxes5, smdata.Timestamps(maxIndices),smdata.TempF(maxIndices),'^',...
                'Color',[217 83 25]/255,'MarkerFaceColor',[217 83 25]/255,...
                'DisplayName','Local maxima')
            plot(app.UIAxes5, smdata.Timestamps(minIndices),smdata.TempF(minIndices),'v',...
                'Color',[237 177 32]/255,'MarkerFaceColor',[237 177 32]/255,...
                'DisplayName','Local minima')
            hold(app.UIAxes5, 'off')
            title(app.UIAxes5, ['Number of extrema: ' num2str(nnz(maxIndices)+nnz(minIndices))])
            
            % find changes
            changes = ischange(wdata.TempF,"linear",...
                "Threshold",100);
            plot(app.UIAxes6, wdata.Timestamps,wdata.TempF)
            hold(app.UIAxes6, 'on')
            plot(app.UIAxes6, wdata.Timestamps(changes),wdata.TempF(changes),"r*")
            hold(app.UIAxes6, 'off')
            title(app.UIAxes6, "Change Points")
            
            %normalise and rescale data
            weatherNorm = normalize(weather)
            humidityNorm = rescale(weather.Humidity)
            temperatureNorm = rescale(weather.TempF)
            plot(app.UIAxes7, humidityNorm)
            hold(app.UIAxes7, 'on')
            plot(app.UIAxes7, temperatureNorm)
            hold(app.UIAxes7, 'off')
     

        end

        % Callback function
        function TextAreaValueChanged(app, event)
            
        end

        % Callback function
        function UITableDisplayDataChanged(app, event)
            app.UITable.Data = weather
            newDisplayData = app.UITable.DisplayData;
            
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0.7059 0.8275 0.8784];
            app.UIFigure.Position = [100 100 1013 1163];
            app.UIFigure.Name = 'UI Figure';

            % Create ShowmethedataButton
            app.ShowmethedataButton = uibutton(app.UIFigure, 'push');
            app.ShowmethedataButton.ButtonPushedFcn = createCallbackFcn(app, @ShowmethedataButtonPushed, true);
            app.ShowmethedataButton.BackgroundColor = [0.5608 0.6863 0.7412];
            app.ShowmethedataButton.FontColor = [0.8471 0.898 0.9216];
            app.ShowmethedataButton.Position = [440 1088 116 22];
            app.ShowmethedataButton.Text = 'Show me the data!';

            % Create WeatherDataJan012019Jan012020Panel
            app.WeatherDataJan012019Jan012020Panel = uipanel(app.UIFigure);
            app.WeatherDataJan012019Jan012020Panel.Title = 'Weather Data Jan 01, 2019 - Jan 01, 2020';
            app.WeatherDataJan012019Jan012020Panel.BackgroundColor = [0.8314 0.8902 0.9216];
            app.WeatherDataJan012019Jan012020Panel.FontAngle = 'italic';
            app.WeatherDataJan012019Jan012020Panel.Position = [42 929 303 181];

            % Create Label_10
            app.Label_10 = uilabel(app.WeatherDataJan012019Jan012020Panel);
            app.Label_10.Position = [3 11 25 136];
            app.Label_10.Text = {'.'; '.'; '.'; '.'; '.'; '.'; '.'; '.'; '.'; '.'; ''};

            % Create AnalysingWeatherDataLabel
            app.AnalysingWeatherDataLabel = uilabel(app.UIFigure);
            app.AnalysingWeatherDataLabel.HorizontalAlignment = 'center';
            app.AnalysingWeatherDataLabel.FontSize = 25;
            app.AnalysingWeatherDataLabel.FontWeight = 'bold';
            app.AnalysingWeatherDataLabel.FontAngle = 'italic';
            app.AnalysingWeatherDataLabel.FontColor = [0.2196 0.4196 0.502];
            app.AnalysingWeatherDataLabel.Position = [350 1126 295 31];
            app.AnalysingWeatherDataLabel.Text = 'Analysing Weather Data';

            % Create HumidityandTemperaturevsTimePanel
            app.HumidityandTemperaturevsTimePanel = uipanel(app.UIFigure);
            app.HumidityandTemperaturevsTimePanel.Title = 'Humidity and Temperature vs Time';
            app.HumidityandTemperaturevsTimePanel.BackgroundColor = [0.8314 0.8902 0.9216];
            app.HumidityandTemperaturevsTimePanel.FontAngle = 'italic';
            app.HumidityandTemperaturevsTimePanel.Position = [41 697 304 221];

            % Create UIAxes
            app.UIAxes = uiaxes(app.HumidityandTemperaturevsTimePanel);
            title(app.UIAxes, '')
            xlabel(app.UIAxes, 'Time')
            ylabel(app.UIAxes, '% , F')
            app.UIAxes.Position = [3 18 300 185];

            % Create SmoothTemperatureandRawTempertaurevsTimePanel
            app.SmoothTemperatureandRawTempertaurevsTimePanel = uipanel(app.UIFigure);
            app.SmoothTemperatureandRawTempertaurevsTimePanel.Title = 'Smooth Temperature and Raw Tempertaure vs Time';
            app.SmoothTemperatureandRawTempertaurevsTimePanel.BackgroundColor = [0.8314 0.8902 0.9216];
            app.SmoothTemperatureandRawTempertaurevsTimePanel.FontAngle = 'italic';
            app.SmoothTemperatureandRawTempertaurevsTimePanel.Position = [358 697 304 221];

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.SmoothTemperatureandRawTempertaurevsTimePanel);
            title(app.UIAxes2, '')
            xlabel(app.UIAxes2, 'Time')
            ylabel(app.UIAxes2, 'F')
            app.UIAxes2.Position = [1 18 300 185];

            % Create TemperaturewithlocalminimaandmaximaPanel
            app.TemperaturewithlocalminimaandmaximaPanel = uipanel(app.UIFigure);
            app.TemperaturewithlocalminimaandmaximaPanel.Title = 'Temperature with local minima and maxima';
            app.TemperaturewithlocalminimaandmaximaPanel.BackgroundColor = [0.8314 0.8902 0.9216];
            app.TemperaturewithlocalminimaandmaximaPanel.FontAngle = 'italic';
            app.TemperaturewithlocalminimaandmaximaPanel.Position = [36 356 304 221];

            % Create UIAxes4
            app.UIAxes4 = uiaxes(app.TemperaturewithlocalminimaandmaximaPanel);
            title(app.UIAxes4, '')
            xlabel(app.UIAxes4, 'Time')
            ylabel(app.UIAxes4, 'F')
            app.UIAxes4.Position = [3 17 300 185];

            % Create SmootherTemperatureandRawTemperaturevsTimePanel
            app.SmootherTemperatureandRawTemperaturevsTimePanel = uipanel(app.UIFigure);
            app.SmootherTemperatureandRawTemperaturevsTimePanel.Title = 'Smoother Temperature and Raw Temperature vs Time';
            app.SmootherTemperatureandRawTemperaturevsTimePanel.BackgroundColor = [0.8314 0.8902 0.9216];
            app.SmootherTemperatureandRawTemperaturevsTimePanel.FontAngle = 'italic';
            app.SmootherTemperatureandRawTemperaturevsTimePanel.Position = [677 697 304 221];

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.SmootherTemperatureandRawTemperaturevsTimePanel);
            title(app.UIAxes3, '')
            xlabel(app.UIAxes3, 'Time')
            ylabel(app.UIAxes3, 'F')
            app.UIAxes3.Position = [1 18 300 185];

            % Create LocalExtremaPanel
            app.LocalExtremaPanel = uipanel(app.UIFigure);
            app.LocalExtremaPanel.Title = 'Local Extrema';
            app.LocalExtremaPanel.BackgroundColor = [0.8314 0.8902 0.9216];
            app.LocalExtremaPanel.FontAngle = 'italic';
            app.LocalExtremaPanel.Position = [357 356 300 221];

            % Create UIAxes5
            app.UIAxes5 = uiaxes(app.LocalExtremaPanel);
            title(app.UIAxes5, 'Title')
            xlabel(app.UIAxes5, 'Time')
            ylabel(app.UIAxes5, 'F')
            app.UIAxes5.Position = [0 17 299 186];

            % Create ChangePanel
            app.ChangePanel = uipanel(app.UIFigure);
            app.ChangePanel.Title = 'Change';
            app.ChangePanel.BackgroundColor = [0.8314 0.8902 0.9216];
            app.ChangePanel.FontAngle = 'italic';
            app.ChangePanel.Position = [674 356 304 221];

            % Create UIAxes6
            app.UIAxes6 = uiaxes(app.ChangePanel);
            title(app.UIAxes6, 'Title')
            xlabel(app.UIAxes6, 'X')
            ylabel(app.UIAxes6, 'Y')
            app.UIAxes6.Position = [3 16 300 185];

            % Create NormaliseddatagraphTemperatureHumidityPanel
            app.NormaliseddatagraphTemperatureHumidityPanel = uipanel(app.UIFigure);
            app.NormaliseddatagraphTemperatureHumidityPanel.Title = 'Normalised data graph - Temperature, Humidity';
            app.NormaliseddatagraphTemperatureHumidityPanel.BackgroundColor = [0.8314 0.8902 0.9216];
            app.NormaliseddatagraphTemperatureHumidityPanel.FontAngle = 'italic';
            app.NormaliseddatagraphTemperatureHumidityPanel.Position = [38 18 572 221];

            % Create UIAxes7
            app.UIAxes7 = uiaxes(app.NormaliseddatagraphTemperatureHumidityPanel);
            title(app.UIAxes7, '')
            xlabel(app.UIAxes7, 'Time')
            ylabel(app.UIAxes7, '%, F')
            app.UIAxes7.Position = [60 8 452 185];

            % Create Task1and2Label
            app.Task1and2Label = uilabel(app.UIFigure);
            app.Task1and2Label.FontWeight = 'bold';
            app.Task1and2Label.FontAngle = 'italic';
            app.Task1and2Label.FontColor = [0.2196 0.4196 0.502];
            app.Task1and2Label.Position = [363 1038 77 22];
            app.Task1and2Label.Text = 'Task 1 and 2';

            % Create Task3Label
            app.Task3Label = uilabel(app.UIFigure);
            app.Task3Label.FontWeight = 'bold';
            app.Task3Label.FontAngle = 'italic';
            app.Task3Label.FontColor = [0.2196 0.4196 0.502];
            app.Task3Label.Position = [48 665 43 22];
            app.Task3Label.Text = 'Task 3';

            % Create Task4Label
            app.Task4Label = uilabel(app.UIFigure);
            app.Task4Label.FontWeight = 'bold';
            app.Task4Label.FontAngle = 'italic';
            app.Task4Label.FontColor = [0.2196 0.4196 0.502];
            app.Task4Label.Position = [363 665 43 22];
            app.Task4Label.Text = 'Task 4';

            % Create Task5Label
            app.Task5Label = uilabel(app.UIFigure);
            app.Task5Label.FontWeight = 'bold';
            app.Task5Label.FontAngle = 'italic';
            app.Task5Label.FontColor = [0.2196 0.4196 0.502];
            app.Task5Label.Position = [677 668 43 22];
            app.Task5Label.Text = 'Task 5';

            % Create Task67Label
            app.Task67Label = uilabel(app.UIFigure);
            app.Task67Label.FontWeight = 'bold';
            app.Task67Label.FontAngle = 'italic';
            app.Task67Label.FontColor = [0.2196 0.4196 0.502];
            app.Task67Label.Position = [38 335 64 22];
            app.Task67Label.Text = 'Task 6 & 7';

            % Create Task8Label
            app.Task8Label = uilabel(app.UIFigure);
            app.Task8Label.FontWeight = 'bold';
            app.Task8Label.FontAngle = 'italic';
            app.Task8Label.FontColor = [0.2196 0.4196 0.502];
            app.Task8Label.Position = [363 335 43 22];
            app.Task8Label.Text = 'Task 8';

            % Create Task9Label
            app.Task9Label = uilabel(app.UIFigure);
            app.Task9Label.FontWeight = 'bold';
            app.Task9Label.FontAngle = 'italic';
            app.Task9Label.FontColor = [0.2196 0.4196 0.502];
            app.Task9Label.Position = [676 335 43 22];
            app.Task9Label.Text = 'Task 9';

            % Create Task101112Label
            app.Task101112Label = uilabel(app.UIFigure);
            app.Task101112Label.FontWeight = 'bold';
            app.Task101112Label.FontAngle = 'italic';
            app.Task101112Label.FontColor = [0.2196 0.4196 0.502];
            app.Task101112Label.Position = [661 181 88 22];
            app.Task101112Label.Text = 'Task 10, 11, 12';

            % Create Label_2
            app.Label_2 = uilabel(app.UIFigure);
            app.Label_2.FontAngle = 'italic';
            app.Label_2.Position = [380 965 455 54];
            app.Label_2.Text = {'Retrieve weather data (01/01/2019 - 01/01/2020) from MathWorks headquarters in '; 'Natick, MA using the ThingSpeak platform service.'; ''; 'Visualise the weather data in a stacked plot '; ''};

            % Create Label_3
            app.Label_3 = uilabel(app.UIFigure);
            app.Label_3.FontAngle = 'italic';
            app.Label_3.Position = [90 595 196 68];
            app.Label_3.Text = {'Resample the Humidity and '; 'Temperature data so the times and '; 'data are uniformly spaced on the '; 'minute using linear interpolation. '; 'Plot both on the same graph.'; ''};

            % Create Label_4
            app.Label_4 = uilabel(app.UIFigure);
            app.Label_4.FontAngle = 'italic';
            app.Label_4.Position = [380 609 233 41];
            app.Label_4.Text = {'Smooth the noisy data using the MATLAB '; 'function smoothdata, plot the raw '; 'temperature and smoothened temperature'; ''};

            % Create Label_5
            app.Label_5 = uilabel(app.UIFigure);
            app.Label_5.FontAngle = 'italic';
            app.Label_5.Position = [732 565 245 122];
            app.Label_5.Text = {'Use the Smooth Data tool available in the '; 'Live Editor Task to smooth the data.'; ''; 'Smoothing methods: Moving mean, '; 'Gaussian filter, Linear/Quadratic regression, '; 'Savitzky-Golay polynomial filter'; 'Smoothing factor/ Moving window = 0.25'; ''; ''; ''};

            % Create Label_6
            app.Label_6 = uilabel(app.UIFigure);
            app.Label_6.FontAngle = 'italic';
            app.Label_6.Position = [53 245 244 82];
            app.Label_6.Text = {'Detect local maxima and minima in the '; 'smoothed data to determine drastic '; 'temperature changes using islocalmin() and '; 'islocalmax(). Visualise these points on the '; 'graph of smoothed data'; ''; ''};

            % Create Label_7
            app.Label_7 = uilabel(app.UIFigure);
            app.Label_7.FontAngle = 'italic';
            app.Label_7.Position = [407 238 254 109];
            app.Label_7.Text = {'Find the local minima and maxima in the data '; 'using the Find Local Extrema Live Editor Task.'; ''; 'Max num extrema = 8096'; 'Min prominence = 0'; 'Min separation = 0'; 'Prominence window = Centered 100 (Days)'; ''; ''};

            % Create Label_8
            app.Label_8 = uilabel(app.UIFigure);
            app.Label_8.FontAngle = 'italic';
            app.Label_8.Position = [703 286 246 41];
            app.Label_8.Text = {'Use ischange() to capture both minimas and '; 'maximas in the graph. Include the change in '; 'linear regime with a threshold of 100'; ''};

            % Create Label_9
            app.Label_9 = uilabel(app.UIFigure);
            app.Label_9.FontAngle = 'italic';
            app.Label_9.Position = [657 101 267 54];
            app.Label_9.Text = {'Normalise the numeric data in the weather data. '; 'Rescale the new weather variables between 0 '; 'and 1. Plot the normalised and rescaled '; 'temperature and humidity data.'; ''};

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = weatherAnalysisApp

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
