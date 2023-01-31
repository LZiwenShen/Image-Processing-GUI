function varargout = ip_hw(varargin)
% IP_HW MATLAB code for ip_hw.fig
%      IP_HW, by itself, creates a new IP_HW or raises the existing
%      singleton*.
%
%      H = IP_HW returns the handle to a new IP_HW or the handle to
%      the existing singleton*.
%
%      IP_HW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IP_HW.M with the given input arguments.
%
%      IP_HW('Property','Value',...) creates a new IP_HW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ip_hw_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ip_hw_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ip_hw

% Last Modified by GUIDE v2.5 07-Jun-2022 00:31:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ip_hw_OpeningFcn, ...
                   'gui_OutputFcn',  @ip_hw_OutputFcn, ...
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


% --- Executes just before ip_hw is made visible.
function ip_hw_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ip_hw (see VARARGIN)

% Choose default command line output for ip_hw
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ip_hw wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ip_hw_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in ip_methods.
function ip_methods_Callback(hObject, eventdata, handles)
% hObject    handle to ip_methods (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ip_methods contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ip_methods
global I;
global k;
k = str2num(get(handles.scale,'string'));
global sigma;
sigma = str2num(get(handles.sigma,'string'));
method = get(handles.ip_methods,'value');
switch method
    case 1
        kernel = ones(k, k, 'uint8');
        x = ip_filter(I,kernel,'average');
    case 2
        kernel = zeros(k, k, 'uint8');
        x = ip_filter(I,kernel,'cross');
    case 3
        kernel = zeros(k, k, 'uint8');
        c = (k - 1) /2;
        s = 2*sigma^2;
        for i = 1 : k
            for j = 1 : k
                x = i-c;
                y = j-c;
                kernel(i,j) = exp(-(x^2+y^2)/s);
            end
        end
        x = ip_filter(I,kernel,'gaussian');
    case 4
        kernel = zeros(3, 3, 'uint8');
        x = ip_filter(I,kernel,'Roberts');
    case 5
        kernel = [0,1,0;1,-4,1;0,1,0];
        x = ip_filter(I,kernel,'Laplacian');
    case 6
        kernel = zeros(3, 3, 'uint8');
        x = ip_filter(I,kernel,'Prewitt');
    case 7
        kernel = zeros(k, k, 'uint8');
        c = (k - 1) /2;
        s = 2*sigma^2;
        for i = 1 : k
            for j = 1 : k
                x = i-c;
                y = j-c;
                kernel(i,j) = exp(-(x^2+y^2)/s);
            end
        end
        x = ip_filter(I,kernel,'gaussian');
        x = ip_filter(I,kernel,'canny');
end
imwrite(x,'ip.bmp','bmp');
axes(handles.axes2);           %将X在第二个轴中显示
imshow(x);

% --- Executes during object creation, after setting all properties.
function ip_methods_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ip_methods (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function scale_Callback(hObject, eventdata, handles)
% hObject    handle to scale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scale as text
%        str2double(get(hObject,'String')) returns contents of scale as a double


% --- Executes during object creation, after setting all properties.
function scale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sigma_Callback(hObject, eventdata, handles)
% hObject    handle to sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sigma as text
%        str2double(get(hObject,'String')) returns contents of sigma as a double


% --- Executes during object creation, after setting all properties.
function sigma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in input.
function input_Callback(hObject, eventdata, handles)
% hObject    handle to input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global I;
[filename,filepath] = uigetfile({'*.bmp'},'选择图像');
image = [filepath, filename];
I = imread(image);
axes(handles.axes1);              %在第一个轴中显示
imshow(I);