function varargout = Project_1(varargin)
% PROJECT_1 MATLAB code for Project_1.fig
%      PROJECT_1, by itself, creates a new PROJECT_1 or raises the existing
%      singleton*.
%
%      H = PROJECT_1 returns the handle to a new PROJECT_1 or the handle to
%      the existing singleton*.
%f
%      PROJECT_1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROJECT_1.M with the given input arguments.
%
%      PROJECT_1('Property','Value',...) creates a new PROJECT_1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Project_1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Project_1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% Edit the above text to modify the response to help Project_1
% Last Modified by GUIDE v2.5 14-Apr-2025 23:07:07

% Begin initialization code - DO NOT EDIT

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Project_1_OpeningFcn, ...
                   'gui_OutputFcn',  @Project_1_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before Project_1 is made visible.
function Project_1_OpeningFcn(hObject, eventdata, handles, varargin)
bg = imread('Background.jpeg');
axes(handles.axes6);
imshow(bg, 'Parent', handles.axes6);
set(handles.axes6, 'XTick', [], 'YTick', []);
set(gcf, 'Color', [0.0627, 0.0941, 0.1255]);
set(handles.uitable1, 'BackgroundColor', [0.0627, 0.0941, 0.1255]);

handles.output = hObject;

% Initialize application data in handles structure
handles.f = 0; % Sampling Frequency
handles.t1 = 0; % Global Start Time
handles.t2 = 0; % Global End Time (Optional, useful for final plot range)
handles.n = 0; % Number of Breakpoints
handles.numSegments = 0; % Number of segments (n+1)
handles.TimePoints = []; % Stores all time points [t_start, bp1, bp2, ..., t_end]
handles.SegmentData = {}; % Cell array to store signal data for each segment
handles.SegmentTime = {}; % Cell array to store time vector for each segment
handles.currentSegment = 1; % Index for the segment being defined
handles.tableData = {}; % Data for the uitable

% Set default values or disable controls until setup
set(handles.End_Point, 'Enable', 'off');
set(handles.popupmenu4, 'Enable', 'off'); % Assuming popupmenu4 is the 'DC signal' dropdown
set(handles.Amplitude, 'Enable', 'off');
set(handles.Amplitudes, 'Enable', 'off');
set(handles.slope, 'Enable', 'off'); 
set(handles.intercept, 'Enable', 'off');
set(handles.Power, 'Enable', 'off');
set(handles.frequency, 'Enable', 'off');
set(handles.Phase, 'Enable', 'off');
set(handles.exponent, 'Enable', 'off');
set(handles.pushbutton4, 'Enable', 'off'); % 'Add' button
set(handles.pushbutton3, 'Enable', 'off'); % 'Generate' button
set(handles.pushbutton5, 'Enable', 'off');
set(handles.pushbutton6, 'Enable', 'off');
set(handles.pushbutton7, 'Enable', 'off');
set(handles.radiobutton1, 'Enable', 'off');
set(handles.radiobutton1, 'Enable', 'off');
set(handles.AmplitudeScaling, 'Enable', 'off');
set(handles.ExpandingCompressing, 'Enable', 'off');
set(handles.TimeShift, 'Enable', 'off');
set(handles.radiobutton2, 'Enable', 'off');
set(handles.uitable1, 'Data', {}); % Clear table

% Update handles structure
guidata(hObject, handles);
% UIWAIT makes Project_1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = Project_1_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

% --- Executes on button press in pushbutton2 ("Set_BreakPoints").
function pushbutton2_Callback(hObject, eventdata, handles)
% --- This is the "Set_BreakPoints" Button Callback ---

% --- Get User Inputs ---
f_str = get(handles.Sampling_Frequency, 'string');
t1_str = get(handles.Start_Time, 'string');
t2_str = get(handles.End_Time, 'string'); % Get global end time
n_str = get(handles.Breakpoints, 'string');

% --- Validate Inputs ---
f = str2double(f_str);
t1 = str2double(t1_str);
t2 = str2double(t2_str);
n = str2double(n_str);

if isnan(f) || f <= 0 || isnan(t1) || isnan(t2) || t2 <= t1 || isnan(n) || n < 0 || floor(n) ~= n
    errordlg('Invalid input(s). Fs > 0, Start < End, Breakpoints >= 0 (integer).', 'Input Error');
    return;
end

% --- Store Initial Values ---
handles.f = f;
handles.t1 = t1;
handles.t2 = t2; % Store the global end time
handles.n = n;
handles.numSegments = n + 1;
handles.TimePoints = t1; % Initialize time points with the start time
handles.SegmentData = cell(1, handles.numSegments); % Pre-allocate cell arrays
handles.SegmentTime = cell(1, handles.numSegments);
handles.currentSegment = 1; % Reset segment counter

% --- Setup Table ---
columnNames = {'Segment', 'Function', 'Start Time', 'End Time', 'Amp', 'Slope' , 'exponent' , 'intercept' , 'freq' , 'Power' , 'Phase' };
handles.tableData = cell(handles.numSegments, 11); % Initialize table data storage
for i = 1:handles.numSegments
    handles.tableData{i, 1} = i; % Segment number
    if i == 1
        handles.tableData{i, 3} = handles.t1; % Start time for first segment
    elseif i == handles.numSegments
        handles.tableData{i, 4} = handles.t2;
    end
end
set(handles.uitable1, 'Data', handles.tableData, ...
                      'ColumnName', columnNames, ...
                      'ColumnEditable', [false, true, false, false, true, true, true]); % Make function/params editable if desired

% --- Enable Controls for First Segment Definition ---
set(handles.End_Point, 'Enable', 'on');
set(handles.popupmenu4, 'Enable', 'on');
set(handles.Amplitude, 'Enable', 'on');
set(handles.pushbutton4, 'Enable', 'on'); % 'Add' button
set(handles.pushbutton3, 'Enable', 'off'); % Disable 'Generate' until all segments are added
set(handles.Sampling_Frequency, 'Enable', 'off'); % Disable initial setup fields
set(handles.Start_Time, 'Enable', 'off');
set(handles.End_Time, 'Enable', 'off');
set(handles.Breakpoints, 'Enable', 'off');
set(handles.pushbutton2, 'Enable', 'off'); % Disable 'Set_BreakPoints' itself
set(handles.pushbutton5, 'Enable', 'off');
set(handles.pushbutton6, 'Enable', 'off');
set(handles.pushbutton7, 'Enable', 'off');
set(handles.radiobutton1, 'Enable', 'off');
set(handles.radiobutton1, 'Enable', 'off');
set(handles.AmplitudeScaling, 'Enable', 'off');
set(handles.ExpandingCompressing, 'Enable', 'off');
set(handles.TimeShift, 'Enable', 'off');
set(handles.radiobutton2, 'Enable', 'off');

guidata(hObject, handles); % Save the updated handles structure
disp(['Setup complete. Defining Segment 1 from t = ', num2str(handles.t1)]);

% --- Executes on button press in pushbutton4 ("Add").
function pushbutton4_Callback(hObject, eventdata, handles)
% --- This is the "Add" Button Callback ---

% --- Check if all segments are defined ---
if handles.currentSegment > handles.numSegments
    msgbox('All segments have been defined.', 'Info');
    set(handles.pushbutton4, 'Enable', 'off'); % Disable Add button
    
    return;
end

% --- Get Current Segment Parameters ---
segmentIdx = handles.currentSegment;
t_start = handles.TimePoints(end); % Start time is the last added time point

% Get End Point for this segment
t_end_str = get(handles.End_Point, 'String');
t_end = str2double(t_end_str);
t2= handles.t2 ;
% Validate End Point
if isnan(t_end) || t_end <= t_start
    errordlg(['End Point for segment ', num2str(segmentIdx), ' must be greater than ', num2str(t_start)], 'Input Error');
    return;
elseif t_end > t2
    errordlg(['End Point for segment ', num2str(segmentIdx), ' must be less than ', num2str(t2)], 'Input Error');
    return;
end

% Optional: Check if t_end exceeds global t2 if enforcing a strict global end
% if t_end > handles.t2
%     errordlg(['End Point cannot exceed global End Time (', num2str(handles.t2), ')'], 'Input Error');
%     return;
% end


% Get Signal Type
val = get(handles.popupmenu4, 'value');
str_list = get(handles.popupmenu4, 'string');
signalType = str_list{val};

% Get Signal Parameters (Read ALL relevant parameters here)
A_str = get(handles.Amplitude, 'string');
As_str = get(handles.Amplitudes, 'string');
slope_str = get(handles.slope, 'string'); % Slope
intercept_str = get(handles.intercept, 'string'); % Intercept
power_str = get(handles.Power, 'string'); % Power/Exponent/Frequency - Meaning depends on type
F_str=get(handles.frequency, 'string');
P_str=get(handles.Phase, 'string');
e_str=get(handles.exponent, 'string');

% Add more gets if needed (e.g., Phase for Sinusoidal)

% Convert parameters (Add error checking!)
A = str2double(A_str);
As_str = strrep(As_str, '[', '');
As_str = strrep(As_str, ']', '');
As = [];
As = str2num(As_str);
slope = str2double(slope_str);
intercept = str2double(intercept_str);
Power = str2double(power_str);
F = str2double(F_str);
P = str2double(P_str);
e = str2double(e_str);
% phase = ... % If needed

% --- Generate Signal Segment ---
f = handles.f;
Duration = t_end - t_start;
% Ensure at least 2 samples for linspace, even for very short durations
Number_of_Samples = max(round(Duration * f), 2);
% Create time vector for THIS segment (excluding the end point for concatenation)
t_segment = linspace(t_start, t_end, Number_of_Samples);

y_segment = zeros(1, Number_of_Samples); % Preallocate

validParams = true;
switch signalType
    case 'DC signal'
        if isnan(A)
            validParams = false; errordlg('Invalid Amplitude for DC Signal.', 'Input Error');
        else
            y_segment = A * ones(1, Number_of_Samples);
            handles.tableData{segmentIdx, 5} = A; % Store Amp in Amp
            handles.tableData{segmentIdx, 6} = slope;
            handles.tableData{segmentIdx, 7} = e;
            handles.tableData{segmentIdx, 8} = intercept;
            handles.tableData{segmentIdx, 9} = F;
            handles.tableData{segmentIdx, 10} = Power;
            handles.tableData{segmentIdx, 11} = P;
        end
    case 'Ramp signal'
        if isnan(slope) || isnan(intercept)
             validParams = false; errordlg('Invalid Slope or Intercept for Ramp Signal.', 'Input Error');
        else
            y_segment = slope * t_segment + intercept;
            handles.tableData{segmentIdx, 5} = A; % Store Amp in Amp
            handles.tableData{segmentIdx, 6} = slope;
            handles.tableData{segmentIdx, 7} = e;
            handles.tableData{segmentIdx, 8} = intercept;
            handles.tableData{segmentIdx, 9} = F;
            handles.tableData{segmentIdx, 10} = Power;
            handles.tableData{segmentIdx, 11} = P;
        end
    case 'General order polynomial'
        if isempty(As) || isnan(intercept) || isnan(Power) || Power <= 1
            validParams = false; errordlg('Invalid Amps or Intercept or Power for General order Polynomial Signal.', 'Input Error');
        else
            for i = 1 : Power
                y_segment = y_segment + As(i) * t_segment.^(i);
            end
            y_segment = y_segment + intercept;
            handles.tableData{segmentIdx, 5} = A; % Store Amp in Amp
            handles.tableData{segmentIdx, 6} = slope;
            handles.tableData{segmentIdx, 7} = e;
            handles.tableData{segmentIdx, 8} = intercept;
            handles.tableData{segmentIdx, 9} = F;
            handles.tableData{segmentIdx, 10} = Power;
            handles.tableData{segmentIdx, 11} = P;
        end
        
    case 'Exponential signal'
        if isnan(A) || isnan(e)
            validParams = false; errordlg('Invalid Amplitude or Exponent for Exponential Signal.', 'Input Error');
        else
            y_segment = A * exp(e * (t_segment - t_start)); % Shift time for exponent start
            handles.tableData{segmentIdx, 5} = A; % Store Amp in Amp
            handles.tableData{segmentIdx, 6} = slope;
            handles.tableData{segmentIdx, 7} = e;
            handles.tableData{segmentIdx, 8} = intercept;
            handles.tableData{segmentIdx, 9} = F;
            handles.tableData{segmentIdx, 10} = Power;
            handles.tableData{segmentIdx, 11} = P;
        end
    case 'Sinusoidal signal'
         if isnan(A) || isnan(F) || isnan(P)
            validParams = false; errordlg('Invalid Amplitude, Frequency, or Phase for Sinusoidal Signal.', 'Input Error');
         else
            frequency = F;
            phase = P; % Using intercept field for phase
            y_segment = A * sin(2 * pi * frequency * (t_segment - t_start) + phase); % Shift time for phase start
            handles.tableData{segmentIdx, 5} = A; % Store Amp in Amp
            handles.tableData{segmentIdx, 6} = slope;
            handles.tableData{segmentIdx, 7} = e;
            handles.tableData{segmentIdx, 8} = intercept;
            handles.tableData{segmentIdx, 9} = F;
            handles.tableData{segmentIdx, 10} = Power;
            handles.tableData{segmentIdx, 11} = P;
         end
    otherwise
        errordlg('Unknown signal type selected.', 'Error'); validParams = false;
end

if ~validParams
    return; % Stop if parameters were invalid
end

% --- Store Segment Data ---
% Store time vector WITH endpoint, store signal data
handles.SegmentTime{segmentIdx} = t_segment;
handles.SegmentData{segmentIdx} = y_segment;
handles.TimePoints = [handles.TimePoints, t_end]; % Add the end point to the list

% --- Update Table ---
handles.tableData{segmentIdx, 2} = signalType; % Function Name
handles.tableData{segmentIdx, 3} = t_start;   % Start Time (already set for segment 1)
handles.tableData{segmentIdx, 4} = t_end;     % End Time
set(handles.uitable1, 'Data', handles.tableData); % Update the displayed table

% --- Prepare for Next Segment or Finalize ---
handles.currentSegment = handles.currentSegment + 1;

if handles.currentSegment <= handles.numSegments
    % Update GUI for next segment
    set(handles.End_Point, 'String', ''); % Clear End Point field
    set(handles.Amplitude, 'String', '');
    set(handles.Amplitudes, 'String', '');% Clear parameters
    set(handles.intercept, 'String', '');
    set(handles.slope, 'String', '');
    set(handles.Power, 'String', '');
    set(handles.Phase, 'String', '');
    set(handles.frequency, 'String', '');
    set(handles.exponent, 'String', '');
    % Update Start Time display in table for next row (visual aid)
    handles.tableData{handles.currentSegment, 3} = t_end;
    set(handles.uitable1, 'Data', handles.tableData);
    disp(['Segment ', num2str(segmentIdx), ' added. Defining Segment ', num2str(handles.currentSegment), ' from t = ', num2str(t_end)]);

else
    % All segments defined
    disp('All segments defined. Ready to Generate.');
    set(handles.End_Point, 'Enable', 'off');
    set(handles.popupmenu4, 'Enable', 'off');
    set(handles.Amplitude, 'Enable', 'off');
    set(handles.Amplitudes, 'Enable', 'off');
    set(handles.intercept, 'Enable', 'off');
    set(handles.slope, 'Enable', 'off');
    set(handles.Power, 'Enable', 'off');
    set(handles.Phase, 'Enable', 'off');
    set(handles.frequency, 'Enable', 'off');
    set(handles.exponent, 'Enable', 'off');
    set(handles.pushbutton4, 'Enable', 'off'); % Disable 'Add'
    set(handles.pushbutton3, 'Enable', 'on'); % Enable 'Generate'
    % Optional: Set final End_Point to global t2 if needed
    % handles.TimePoints(end) = handles.t2;
end

guidata(hObject, handles); % Save handles


% --- Executes on button press in pushbutton3 ("Generate").
function pushbutton3_Callback(hObject, eventdata, handles)
% --- This is the "Generate" Button Callback ---

if handles.currentSegment <= handles.numSegments
    warndlg('Not all segments have been added yet.', 'Warning');
    return;
end

% --- Concatenate Segments ---
Final_Signal = [];
Final_Time = [];

for i = 1:handles.numSegments
    t_seg = handles.SegmentTime{i};
    y_seg = handles.SegmentData{i};

    if i < handles.numSegments
        % Append segment excluding the last point to avoid duplication
        Final_Time = [Final_Time, t_seg(1:end-1)];
        Final_Signal = [Final_Signal, y_seg(1:end-1)];
    else
        % Append the last segment completely
        Final_Time = [Final_Time, t_seg];
        Final_Signal = [Final_Signal, y_seg];
    end
end

% --- Plotting ---
% Plot on upper axes (axes1)
x = Final_Time;
y = Final_Signal;
handles.y = y;
handles.x = x;
handles.Final_Signal = Final_Signal;
handles.Final_Time = Final_Time;
axes(handles.axes1);
plot(Final_Time, Final_Signal, 'Color', [0, 1, 0.8353], 'LineWidth', 2);
grid on;
set(gca, 'GridColor', [0 0 0], 'GridAlpha', 1, 'GridLineStyle', '-');
set(handles.axes1, 'XColor', [1 1 1], 'YColor', [1 1 1]);
xlabel('Time', 'Color', 'w');
ylabel('Amplitude', 'Color', 'w');
title('Original Signal', 'Color', 'w');
set(handles.pushbutton5, 'Enable', 'on');
set(handles.pushbutton6, 'Enable', 'on');
set(handles.pushbutton7, 'Enable', 'on');
set(handles.radiobutton1, 'Enable', 'on');
set(handles.AmplitudeScaling, 'Enable', 'on');
set(handles.ExpandingCompressing, 'Enable', 'on');
set(handles.TimeShift, 'Enable', 'on');
set(handles.radiobutton2, 'Enable', 'on');
% Adjust x-axis limits if desired (e.g., to handles.t1 and handles.t2)
% xlim([handles.t1, handles.t2]);

% Optional: Plot on lower axes (axes2) - e.g., derivative, spectrum?
% axes(handles.axes2);
% plot(...) % Plot something else if needed
% grid on;

disp('Signal Generated and Plotted.');

% --- Re-enable Setup for New Signal Generation? ---
% Decide if you want to allow generating a new signal without restarting
% If yes, re-enable setup controls and disable 'Generate'
 set(handles.Sampling_Frequency, 'Enable', 'on');
 set(handles.Start_Time, 'Enable', 'on');
 set(handles.End_Time, 'Enable', 'on');
 set(handles.Breakpoints, 'Enable', 'on');
 set(handles.pushbutton2, 'Enable', 'on'); % 'Set_BreakPoints'
 set(handles.pushbutton3, 'Enable', 'off'); % Disable 'Generate'
 %set(handles.uitable1, 'Data', {}); % Clear table
 % Reset internal state
 None = 0;
 handles.None = None;
 handles.TimePoints = [];
 handles.SegmentData = {};
 handles.SegmentTime = {};
 handles.currentSegment = 1;
 handles.tableData = {};
 
 guidata(hObject, handles);


% --- Executes on selection change in popupmenu4 (Signal Type Dropdown).
function popupmenu4_Callback(hObject, eventdata, handles)
% --- Get selected type ---
contents = cellstr(get(hObject,'String'));
signalType = contents{get(hObject,'Value')};

% --- Enable/Disable Parameter Fields Based on Type ---
% Disable all first, then enable specifics
set(handles.Amplitude, 'Enable', 'off');
set(handles.Amplitudes, 'Enable', 'off');
set(handles.slope, 'Enable', 'off'); % Slope
set(handles.intercept, 'Enable', 'off'); % Intercept
set(handles.Power, 'Enable', 'off');
set(handles.frequency, 'Enable', 'off');
set(handles.Phase, 'Enable', 'off');
set(handles.exponent, 'Enable', 'off');% Power/Freq/Exp

switch signalType
    case 'DC signal'
        set(handles.Amplitude, 'Enable', 'on');
        % Update labels or tooltips if needed
        % set(handles.text_Amplitude_label, 'String', 'Amplitude:');

    case 'Ramp signal'
        set(handles.slope, 'Enable', 'on'); % Slope
        set(handles.intercept, 'Enable', 'on'); % Intercept
        % Update labels
        % set(handles.text_Slope_label, 'String', 'Slope:');
        % set(handles.text_Intercept_label, 'String', 'intercept:');

    case 'General order polynomial'
        set(handles.Amplitudes, 'Enable', 'on');
        set(handles.intercept, 'Enable', 'on');
        set(handles.Power, 'Enable', 'on'); % Example: Use Power field for "[c2 c1 c0]"
        % set(handles.text_Power_label, 'String', 'Coeffs [cN..c0]:');

    case 'Exponential signal'
        set(handles.Amplitude, 'Enable', 'on');
        set(handles.exponent, 'Enable', 'on'); % Use Power for Exponent
        % set(handles.text_Amplitude_label, 'String', 'Amplitude:');
        % set(handles.text_Power_label, 'String', 'Exponent:');


    case 'Sinusoidal signal'
        set(handles.Amplitude, 'Enable', 'on');
        set(handles.Phase, 'Enable', 'on'); % Use Power for Frequency
        set(handles.frequency, 'Enable', 'on'); % Use Intercept for Phase (example)
         % set(handles.text_Amplitude_label, 'String', 'Amplitude:');
         % set(handles.text_Power_label, 'String', 'Frequency:');
         % set(handles.text_Intercept_label, 'String', 'Phase (rad):');

end
guidata(hObject, handles); % Save changes if any


% --- CreateFcns for controls (Mostly boilerplate) ---

function Start_Time_Callback(hObject, eventdata, handles)
function Start_Time_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function End_Time_Callback(hObject, eventdata, handles)
function End_Time_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Breakpoints_Callback(hObject, eventdata, handles)
function Breakpoints_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Sampling_Frequency_Callback(hObject, eventdata, handles)
function Sampling_Frequency_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function End_Point_Callback(hObject, eventdata, handles)
function End_Point_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function popupmenu1_Callback(hObject, eventdata, handles) % This seems unused?
function popupmenu1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function listbox1_Callback(hObject, eventdata, handles) % This seems unused?
function listbox1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function uitable1_CellEditCallback(hObject, eventdata, handles)
% Optional: Add logic here if you want actions to happen immediately
% when the user edits the table (e.g., validation, re-plotting).
% For now, we use the table mainly for display and parameter storage.
% handles.tableData = get(handles.uitable1, 'Data'); % Update internal data if edited
% guidata(hObject, handles);


function popupmenu4_CreateFcn(hObject, eventdata, handles) % Signal Type Dropdown
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Populate Popup Menu options here ---
set(hObject, 'String', {'DC signal', 'Ramp signal', 'General order polynomial', 'Exponential signal', 'Sinusoidal signal'});


function Amplitude_Callback(hObject, eventdata, handles)
function Amplitude_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function slope_Callback(hObject, eventdata, handles) % Slope Edit Field
function slope_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function intercept_Callback(hObject, eventdata, handles) % Intercept/Phase Edit Field
function intercept_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Power_Callback(hObject, eventdata, handles) % Power/Exponent/Frequency/Coeffs Edit Field
function Power_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Unused variable initialization from original code (can be removed) ---
% function pushbutton3_Callback_unused_variables(handles)
%     A_list = []; M_list = []; C_list = []; exponent_list = []; freq_list = []; theta_list = []; function_kind_list = [];
% end



function exponent_Callback(hObject, eventdata, handles)
% hObject    handle to exponent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of exponent as text
%        str2double(get(hObject,'String')) returns contents of exponent as a double


% --- Executes during object creation, after setting all properties.
function exponent_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exponent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function frequency_Callback(hObject, eventdata, handles)
% hObject    handle to frequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frequency as text
%        str2double(get(hObject,'String')) returns contents of frequency as a double


% --- Executes during object creation, after setting all properties.
function frequency_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Phase_Callback(hObject, eventdata, handles)
% hObject    handle to Phase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Phase as text
%        str2double(get(hObject,'String')) returns contents of Phase as a double


% --- Executes during object creation, after setting all properties.
function Phase_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Phase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Amplitudes_Callback(hObject, eventdata, handles)
% hObject    handle to Amplitudes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Amplitudes as text
%        str2double(get(hObject,'String')) returns contents of Amplitudes as a double


% --- Executes during object creation, after setting all properties.
function Amplitudes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Amplitudes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
y = handles.y;
x = handles.x;

x = 0 - x;
axes(handles.axes2);
plot(x, y, 'Color', [0, 1, 0.8353], 'LineWidth', 2);
grid on;
set(gca, 'GridColor', [0 0 0], 'GridAlpha', 1, 'GridLineStyle', '-');
set(handles.axes2, 'XColor', [1 1 1], 'YColor', [1 1 1]);
xlabel('Time', 'Color', 'w');
ylabel('Amplitude', 'Color', 'w');
title('Modified Signal', 'Color', 'w');
% Adjust x-axis limits if desired (e.g., to handles.t1 and handles.t2)
% xlim([handles.t1, handles.t2]);

% Optional: Plot on lower axes (axes2) - e.g., derivative, spectrum?
% axes(handles.axes2);
% plot(...) % Plot something else if needed
% grid on;

disp('Signal Generated and Plotted.');

handles.y = y;
handles.x = x;

 guidata(hObject, handles);
function AmplitudeScaling_Callback(hObject, eventdata, handles)
% hObject    handle to AmplitudeScaling (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AmplitudeScaling as text
%        str2double(get(hObject,'String')) returns contents of AmplitudeScaling as a double


% --- Executes during object creation, after setting all properties.
function AmplitudeScaling_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AmplitudeScaling (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ExpandingCompressing_Callback(hObject, eventdata, handles)
% hObject    handle to ExpandingCompressing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ExpandingCompressing as text
%        str2double(get(hObject,'String')) returns contents of ExpandingCompressing as a double


% --- Executes during object creation, after setting all properties.
function ExpandingCompressing_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ExpandingCompressing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TimeShift_Callback(hObject, eventdata, handles)
% hObject    handle to TimeShift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TimeShift as text
%        str2double(get(hObject,'String')) returns contents of TimeShift as a double


% --- Executes during object creation, after setting all properties.
function TimeShift_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeShift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
None = handles.None;
if None == 0

y = handles.Final_Signal;
x = handles.Final_Time;

axes(handles.axes2);
plot(x, y, 'Color', [0, 1, 0.8353], 'LineWidth', 2);
grid on;
set(gca, 'GridColor', [0 0 0], 'GridAlpha', 1, 'GridLineStyle', '-');
set(handles.axes2, 'XColor', [1 1 1], 'YColor', [1 1 1]);
xlabel('Time', 'Color', 'w');
ylabel('Amplitude', 'Color', 'w');
title('Modified Signal', 'Color', 'w');
% Adjust x-axis limits if desired (e.g., to handles.t1 and handles.t2)
% xlim([handles.t1, handles.t2]);

% Optional: Plot on lower axes (axes2) - e.g., derivative, spectrum?
% axes(handles.axes2);
% plot(...) % Plot something else if needed
% grid on;

disp('Signal Generated and Plotted.');

handles.y = y;
handles.x = x;
currVal = get(handles.radiobutton1, 'Value');
if currVal
    set(handles.radiobutton1, 'Value', ~currVal);
end
set(handles.radiobutton1, 'Enable', 'off');
set(handles.AmplitudeScaling, 'Enable', 'off');
set(handles.ExpandingCompressing, 'Enable', 'off');
set(handles.TimeShift, 'Enable', 'off');
set(handles.pushbutton5, 'Enable', 'off');
set(handles.pushbutton6, 'Enable', 'off');
set(handles.pushbutton7, 'Enable', 'off');
else
    set(handles.radiobutton1, 'Enable', 'on');
    set(handles.AmplitudeScaling, 'Enable', 'on');
    set(handles.ExpandingCompressing, 'Enable', 'on');
    set(handles.TimeShift, 'Enable', 'on');
    set(handles.pushbutton5, 'Enable', 'on');
    set(handles.pushbutton6, 'Enable', 'on');
    set(handles.pushbutton7, 'Enable', 'on');
end

None = 1 - None;
handles.None = None;
 guidata(hObject, handles);
function pushbutton5_Callback(hObject, eventdata, handles)
y = handles.y;
x = handles.x;

AmpScaling_str = get(handles.AmplitudeScaling, 'string');

% --- Validate Inputs ---
AmpScaling= str2double(AmpScaling_str);
if isnan(AmpScaling)
    errordlg(['Please enter a valid Amplitude Scaling'], 'Input Error');
    return;
end
y = AmpScaling * y;
axes(handles.axes2);
plot(x, y, 'Color', [0, 1, 0.8353], 'LineWidth', 2);
grid on;
set(gca, 'GridColor', [0 0 0], 'GridAlpha', 1, 'GridLineStyle', '-');
set(handles.axes2, 'XColor', [1 1 1], 'YColor', [1 1 1]);
xlabel('Time', 'Color', 'w');
ylabel('Amplitude', 'Color', 'w');
title('Modified Signal', 'Color', 'w');
% Adjust x-axis limits if desired (e.g., to handles.t1 and handles.t2)
% xlim([handles.t1, handles.t2]);

% Optional: Plot on lower axes (axes2) - e.g., derivative, spectrum?
% axes(handles.axes2);
% plot(...) % Plot something else if needed
% grid on;

disp('Signal Modified and Plotted.');

handles.y = y;
handles.x = x;

 guidata(hObject, handles);


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
y = handles.y;
x = handles.x;

ExpandingCompressing_str = get(handles.ExpandingCompressing, 'string');

% --- Validate Inputs ---
ExpandingCompressing= str2double(ExpandingCompressing_str);

if isnan(ExpandingCompressing)
    errordlg(['Please enter a valid Time Scale'], 'Input Error');
    return;
end

x = (1/ExpandingCompressing) * x;
axes(handles.axes2);
plot(x, y, 'Color', [0, 1, 0.8353], 'LineWidth', 2);
grid on;
set(gca, 'GridColor', [0 0 0], 'GridAlpha', 1, 'GridLineStyle', '-');
set(handles.axes2, 'XColor', [1 1 1], 'YColor', [1 1 1]);
xlabel('Time', 'Color', 'w');
ylabel('Amplitude', 'Color', 'w');
title('Modified Signal', 'Color', 'w');
% Adjust x-axis limits if desired (e.g., to handles.t1 and handles.t2)
% xlim([handles.t1, handles.t2]);

% Optional: Plot on lower axes (axes2) - e.g., derivative, spectrum?
% axes(handles.axes2);
% plot(...) % Plot something else if needed
% grid on;

disp('Signal Generated and Plotted.');

handles.y = y;
handles.x = x;

 guidata(hObject, handles);

% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
y = handles.y;
x = handles.x;

TimeShift_str = get(handles.TimeShift, 'string');

% --- Validate Inputs ---
TimeShift= 0 - str2double(TimeShift_str);
if isnan(TimeShift)
    errordlg(['Please enter a valid Shift'], 'Input Error');
    return;
end
x = x + TimeShift;
axes(handles.axes2);
plot(x, y, 'Color', [0, 1, 0.8353], 'LineWidth', 2);
grid on;
set(gca, 'GridColor', [0 0 0], 'GridAlpha', 1, 'GridLineStyle', '-');
set(handles.axes2, 'XColor', [1 1 1], 'YColor', [1 1 1]);
set(handles.axes2, 'GridColor', [0 0 0]);
xlabel('Time', 'Color', 'w');
ylabel('Amplitude', 'Color', 'w');
title('Modified Signal', 'Color', 'w');
% Adjust x-axis limits if desired (e.g., to handles.t1 and handles.t2)
% xlim([handles.t1, handles.t2]);

% Optional: Plot on lower axes (axes2) - e.g., derivative, spectrum?
% axes(handles.axes2);
% plot(...) % Plot something else if needed
% grid on;

disp('Signal Generated and Plotted.');

handles.y = y;
handles.x = x;

 guidata(hObject, handles);



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to intercept (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of intercept as text
%        str2double(get(hObject,'String')) returns contents of intercept as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to intercept (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




