function varargout = guirecorder(varargin)
% GUIRECORDER MATLAB code for guirecorder.fig
%      GUIRECORDER, by itself, creates a new GUIRECORDER or raises the existing
%      singleton*.
%
%% 
%% 
%      H = GUIRECORDER returns the handle to a new GUIRECORDER or the handle to
%      the existing singleton*.
%
%      GUIRECORDER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIRECORDER.M with the given input arguments.
%
%      GUIRECORDER('Property','Value',...) creates a new GUIRECORDER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guirecorder_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guirecorder_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help guirecorder

% Last Modified by GUIDE v2.5 14-Nov-2016 15:32:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guirecorder_OpeningFcn, ...
                   'gui_OutputFcn',  @guirecorder_OutputFcn, ...
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


% --- Executes just before guirecorder is made visible.
function guirecorder_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guirecorder (see VARARGIN)

% Choose default command line output for guirecorder
global sampleNo
global sampleCounter
sampleNo = '-1';
sampleCounter = 0;

handles.output = hObject;
handles.kinectStatus=false;
handles.recording=false;
handles.save=false;
handles.LCM=0;
handles.folder = '.';
addpath('Mex');
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes guirecorder wait for user response (see UIRESUME)
% uiwait(handles.recorder);


% --- Outputs from this function are returned to the command line.
function varargout = guirecorder_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user attempts to close recorder.
function recorder_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to recorder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles.k2.delete;
handles.kinectStatus=false;
% Update handles structure
guidata(hObject, handles);
% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in startStopKinectButton.
function startStopKinectButton_Callback(hObject, eventdata, handles)
% hObject    handle to startStopKinectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
depthdata=[];
if ~(handles.kinectStatus)
     set(handles.startStopKinectButton,'string','Stop Kinect')
     set(handles.startStopKinectButton,'ForegroundColor','red')
    
     handles.sampleNo = '-1';
     handles.sampleCounter = 0;

    handles.k2 = Kin2('color','depth','body');
    guidata(hObject, handles);
    % images sizes
    d_width = 512; d_height = 424; outOfRange = 4000;
    c_width = 512; c_height = 424;
    
    % Color image is to big, let's scale it down
    COL_SCALE = 1.0;
    
    % Create matrices for the images
    depth = zeros(d_height,d_width,'uint16');
    color = zeros(c_height*COL_SCALE,c_width*COL_SCALE,3,'uint8');
    
    
    handles.kinectStatus=true;
    guidata(hObject,handles);  %Update the GUI data
    c.ax=handles.showarea;
    handles = guidata(hObject);
    while (handles.kinectStatus)
        drawnow;  %# Give the button callback a chance to interrupt the opening function
        % Get s from Kinect and save them on underlying buffer
        handles = guidata(hObject);
        if ~(handles.kinectStatus)
            break;
        end
        validData =  handles.k2.updateData;
        f=matleap_frame;
        % Before processing the data, we need to make sure that a valid
        % frame was acquired.
        if validData
            % Copy data to Matlab matrices
            depth =  handles.k2.getDepth;
            color =  handles.k2.getColor;
%             color = fliplr(color);
            % update depth figure
% %             depth8u = uint8(depth*(255/outOfRange));
% %             depth8uc3 = repmat(depth8u,[1 1 3]);
% depth8=reshape( typecast(depth(:),'uint8'),  d_height,d_width,2);
% depth8uc3 = cat(3,zeros(d_height,d_width),depth8);
%             depth8uc3 = fliplr(depth8uc3);
            %         d.im = imshow(depth8uc3, 'Parent', d.ax);
            
            %set(d.im,'CData',depth8uc3);
            
            % update color figure
%             color = imresize(color,COL_SCALE);
            %, 'Parent', c.ax);
            
            %set(c.im,'CData',color);
            
            % Get 3D bodies joints
            % getBodies returns a structure array.
            % The structure array (bodies) contains 6 bodies at most
            % Each body has:
            % -Position: 3x25 matrix containing the x,y,z of the 25 joints in
            %   camera space coordinates
            % -TrackingState: state of each joint. These can be:
            %   NotTracked=0, Inferred=1, or Tracked=2
            % -LeftHandState: state of the left hand
            % -RightHandState: state of the right hand
            bodies =  handles.k2.getBodies('Quat');
            
            % Number of bodies detected
            numBodies = size(bodies,2);
            %         disp(['Bodies Detected: ' num2str(numBodies)])
            
            % first body info:
            %disp(bodies(1).TrackingState)
            %disp(bodies(1).RightHandState)
            %disp(bodies(1).LeftHandState)
            
            % To get the joints on depth image space, you can use:
            %pos2D = k2.mapCameraPoints2Depth(bodies(1).Position');
            
            %To get the joints on color image space, you can use:
            if(numBodies>=1)
            Cpos2D = handles.k2.mapCameraPoints2Color(bodies(1).Position');
            Dpos2D = handles.k2.mapCameraPoints2Depth(bodies(1).Position');
            bod= bodies(1);
            bod.Cpos2D=Cpos2D;
            bod.Dpos2D=Dpos2D;
            end
            handles = guidata(hObject);
            % record vide
            if (handles.save)
                skelfilename = [handles.colorfilename,'_s'];
                LcMfilename = [handles.colorfilename,'_lcm'];
                depthfilename =  replace(handles.colorfilename,'_c','_d');
                %             body=handles.b;
                save(skelfilename,'body');
                save(LcMfilename,'LcmData');
                save(depthfilename,'depthdata','-v7.3');
                handles.save=false;
                clear body;
                 depthdata=[];
                 clear LcmData;
                guidata(hObject, handles);
            end
            handles = guidata(hObject);
            if (handles.recording)
%                 disp('recording');
                writeVideo(handles.cv,color);
%                 writeVideo(handles.dv,depth8uc3);
                %class( bodies(1))
                depthdata=cat(3, depthdata, depth);
                LcmData(handles.count) = f;
                body(handles.count) =  bod;
                handles.count = handles.count+1;
                guidata(hObject, handles);
                
            else
            c.im = imshow(color);
            % Draw bodies on depth image
            % Parameters:
            % 1) image axes
            % 2) bodies structure
            % 3) Destination image (depth or color)
            % 4) Joints' size (circle raddii)
            % 5) Bones' Thickness
            % 6) Hands' Size
            %         k2.drawBodies(d.ax,bodies,'depth',5,3,15);
            
            % Draw bodies on color image
            handles.k2.drawBodies(c.ax,bodies,'color',10,6,30);
            end
        end
        
        %     pause(0.02)
        handles = guidata(hObject);  %# Get the newest GUI data
    end
    
else
    handles.kinectStatus=false;
    guidata(hObject, handles);
    handles.k2.delete;
    guidata(hObject,handles);  %Update the GUI data
    drawnow;
    set(handles.startStopKinectButton,'string','Start Kinect')
     set(handles.startStopKinectButton,'ForegroundColor','blue')
    return;
end


% --- Executes on button press in recordButton.
function recordButton_Callback(hObject, eventdata, handles)
% hObject    handle to recordButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% filename=fullfile(handles.folder,['c_',datestr(now,'dd_mm_yy_'),datestr(now,'hh_MM_ss')]);
singerNo=num2str(str2num(get(handles.singerID,'string')),'%02d'); 
sentNo = num2str(str2num(get(handles.sentenceID,'string')),'%04d');
cat= num2str(get(handles.Sentcat,'value'),'%02d'); 
global sampleNo
global sampleCounter
%if (strcmp(get(handles.stopRecordingButton,'enable'),'off'))    
    filePath=fullfile(handles.folder,cat,sentNo, singerNo);
    mkdir(filePath);
    filename= fullfile(filePath,strcat(singerNo,'_',cat,'_',sentNo,'_(',datestr(now,'dd_mm_yy_'),datestr(now,'hh_MM_ss'),')'));

    %handles.colorfilename = fullfile(handles.folder,['c_',datestr(now,'dd_mm_yy_'),datestr(now,'hh_MM_ss')]);
    % handles.colorfilename = fullfile(handles.folder,[singerNo,'_',cat,'_',sentNo,'_',datestr(now,'dd_mm_yy_'),datestr(now,'hh_MM_ss')]);
    handles.colorfilename = [filename,'_c'];

    handles.cv = VideoWriter(handles.colorfilename,'MPEG-4');

%     depthfilename = [filename,'_d'];
%     handles.dv = VideoWriter(depthfilename,'MPEG-4');
    handles.cv.FrameRate = 30;
%     handles.dv.FrameRate = 30;
    open(handles.cv);
%     open(handles.dv);
    % handles.b=[];
    handles.count=1;
    handles.recording = true;
    guidata(hObject,handles);  %Update the GUI data
    drawnow;
    set(handles.stopRecordingButton,'enable','on');
    set(handles.recordButton,'enable','off');
    if strcmp(sampleNo, sentNo)
        sampleCounter = sampleCounter + 1 ;
    else
        sampleNo = sentNo;
        sampleCounter = 1;
    end
    set(handles.counterTxt,'string',sampleCounter)
%end 
    

% --- Executes on button press in stopRecordingButton.
function stopRecordingButton_Callback(hObject, eventdata, handles)
% hObject    handle to stopRecordingButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%if (strcmp(get(handles.stopRecordingButton,'enable'),'off'))    

handles.recording = false;
handles.save=true;
guidata(hObject,handles); 
close(handles.cv);
% close(handles.dv);
disp('stoped');
guidata(hObject,handles);  %Update the GUI data
drawnow;
set(handles.stopRecordingButton,'enable','off');
set(handles.recordButton,'enable','on');

% end


% --- Executes on button press in selDir.
function selDir_Callback(hObject, eventdata, handles)
% hObject    handle to selDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.folder = uigetdir('D:\sign language\Records\');% data set directory 
disp(handles.folder);
guidata(hObject,handles)



function singerID_Callback(hObject, eventdata, handles)
% hObject    handle to singerID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of singerID as text
%        str2double(get(hObject,'String')) returns contents of singerID as a double


% --- Executes during object creation, after setting all properties.
function singerID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to singerID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sentenceID_Callback(hObject, eventdata, handles)
% hObject    handle to sentenceID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sentenceID as text
%        str2double(get(hObject,'String')) returns contents of sentenceID as a double


% --- Executes during object creation, after setting all properties.
function sentenceID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sentenceID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Sentcat.
function Sentcat_Callback(hObject, eventdata, handles)
% hObject    handle to Sentcat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Sentcat contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Sentcat


% --- Executes during object creation, after setting all properties.
function Sentcat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sentcat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in handness.
function handness_Callback(hObject, eventdata, handles)
% hObject    handle to handness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns handness contents as cell array
%        contents{get(hObject,'Value')} returns selected item from handness


% --- Executes during object creation, after setting all properties.
function handness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to handness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in temp_btn.
function temp_btn_Callback(hObject, eventdata, handles)
% hObject    handle to temp_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
   
