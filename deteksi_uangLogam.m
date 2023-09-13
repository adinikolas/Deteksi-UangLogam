function varargout = deteksi_uangLogam(varargin)
%DETEKSI_UANGLOGAM MATLAB code file for deteksi_uangLogam.fig
%      DETEKSI_UANGLOGAM, by itself, creates a new DETEKSI_UANGLOGAM or raises the existing
%      singleton*.
%
%      H = DETEKSI_UANGLOGAM returns the handle to a new DETEKSI_UANGLOGAM or the handle to
%      the existing singleton*.
%
%      DETEKSI_UANGLOGAM('Property','Value',...) creates a new DETEKSI_UANGLOGAM using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to deteksi_uangLogam_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      DETEKSI_UANGLOGAM('CALLBACK') and DETEKSI_UANGLOGAM('CALLBACK',hObject,...) call the
%      local function named CALLBACK in DETEKSI_UANGLOGAM.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help deteksi_uangLogam

% Last Modified by GUIDE v2.5 12-Oct-2022 15:17:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @deteksi_uangLogam_OpeningFcn, ...
                   'gui_OutputFcn',  @deteksi_uangLogam_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before deteksi_uangLogam is made visible.
function deteksi_uangLogam_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to deteksi_uangLogam (see VARARGIN)
 
% Choose default command line output for deteksi_uangLogam
handles.output = hObject;
hback = axes('unit','normalized','position',[0 0 1 1]);
uistack(hback,'bottom');
[back map]=imread('light-color-12.jpg');
image(back)
colormap(map)
set(hback,'handlevisibility','off','visible','off')
 
% Update handles structure
guidata(hObject, handles);
movegui(hObject,'center');
 
% UIWAIT makes deteksi_uangLogam wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = deteksi_uangLogam_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% menampilkan menu browse file
[filename, pathname] = uigetfile('*.jpg');
 
% jika ada file yang dipilih maka akan menjalankan perintah di bawahnya
if ~isequal(filename,0)
    % mereset button2
    set(handles.pushbutton2,'Enable','on')
    set(handles.uitable1,'Data',[])
    axes(handles.axes1)
    cla reset
    set(gca,'XTick',[])
    set(gca,'YTick',[])
    axes(handles.axes2)
    cla reset
    set(gca,'XTick',[])
    set(gca,'YTick',[])
    % membaca citra rgb
    Img = imread(fullfile(pathname,filename));
    % menampilkan citra pada axes
    axes(handles.axes1)
    imshow(Img)
    title('Citra Uang Logam','FontName','Eras Demi ITC')
    % menyimpan variabel Img pada lokasi handles
    % (lokasi penyimpanan variabel) agar dapat
    % dipanggil oleh pushbutton yang lain
    handles.Img = Img;
    guidata(hObject, handles)
else
    % jika tidak ada file yang dipilih maka akan kembali
    return
end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% memanggil variabel Img yang ada di lokasi handles
Img = handles.Img;
% mengkonversi citra rgb menjadi grayscale
Img_gray = rgb2gray(Img);
% mengkonversi citra grayscale menjadi biner
bw = im2bw(Img_gray,graythresh(Img_gray));
% melakukan komplemen citra agar objek bernilai satu
% dan background bernilai nol
bw = imcomplement(bw);
% operasi morfologi untuk menyempurnakan hasil segmentasi
% 1. area opening untuk menghilangkan noise
bw = bwareaopen(bw,100);
% 2. filling holes untuk mengisi objek yang berlubang
bw = imfill(bw,'holes');
% 3. closing untuk membuat bentuk objek lebih smooth
str = strel('disk',5);
bw = imclose(bw,str);
% 4. menghilangkan objek yang menempel pada border (tepian citra)
bw = imclearborder(bw);
% pelabelan terhadap masing2 objek
[B,L] = bwlabel(bw);
% menghitung luas dan centroid objek
stats = regionprops(B,'All');
% mengkonversi citra rgb menjadi YCbCr
YCbCr = rgb2ycbcr(Img);
% mengekstrak komponen Cb (Chrominance-blue)
Cb = YCbCr(:,:,2);
 
% menampilkan citra rgb hasil identifikasi pada axes
axes(handles.axes2)
imshow(Img);
title('Hasil Identifikasi','FontName','Eras Demi ITC')
hold on
 
% membaca value dari masing2 checkbox
val1 = get(handles.checkbox1,'Value');
val2 = get(handles.checkbox2,'Value');
val3 = get(handles.checkbox3,'Value');
val4 = get(handles.checkbox4,'Value');
val5 = get(handles.checkbox5,'Value');
 
% jika deteksi dilakukan pada semua uang logam
if val1==1
    % menginisialisasi variabel data_koin
    data_koin = zeros(L,1);
    % membuat boundary pada koin yang terdeteksi
    Boundaries = bwboundaries(bw,'noholes');
    % untuk n = 1 s.d n = jumlah objek
    for n = 1:L
        boundary = Boundaries{n};
        % menghitung nilai Cb dari masing2 objek
        bw_label = (B==n);
        Cb_label = immultiply(Cb,bw_label);
        Cb_label = (sum(sum(Cb_label)))/(sum(sum(bw_label)));
        % menghitung luas dan centroid masing2 objek
        Area = stats(n).Area;
        centroid = stats(n).Centroid;
        % jika nilai Cb > 120 maka dikenali sebagai koin silver
        if Cb_label>120
            % jika luas < 10000 maka dikenali sebagai koin Rp. 100
            if Area<10000
                nilai = 100;
                % jika luas < 40000 maka dikenali sebagai koin Rp. 200
            elseif Area<40000 
                nilai = 500; % jika luas > 40000 maka dikenali sebagai koin Rp. 500
            else
                nilai = 200;
            end
            % menampilkan boundary pada objek
            plot(boundary(:,2), boundary(:,1), 'y', 'LineWidth', 4)
            % menampilkan nilai koin pada centroid objek
            text(centroid(1)-100,centroid(2),num2str(nilai),...
                'Color','y','FontSize',20,'FontWeight','bold');
            % jika nilai Cb < 120 maka dikenali sebagai koin kuning
        else
            % jika luas < 70000 maka dikenali sebagai koin Rp. 500
            if Area<70000 
                nilai = 500; % jika luas > 70000 maka dikenali sebagai koin Rp. 1000
            else
                nilai = 1000;
            end
            % menampilkan boundary pada objek
            plot(boundary(:,2), boundary(:,1), 'c', 'LineWidth', 4)
            % menampilkan nilai koin pada centroid objek
            text(centroid(1)-100,centroid(2),num2str(nilai),...
                'Color','c','FontSize',20,'FontWeight','bold');
        end
        % mengisi variabel data_koin dengan nilai koin
        data_koin(n) = nilai;
    end
     
    % menghitung banyaknya masing2 koin berdasarkan nilainya
    [~,n_100] = find(data_koin==100);
    nilai_100 = numel(n_100);
     
    [~,n_200] = find(data_koin==200);
    nilai_200 = numel(n_200);
     
    [~,n_500] = find(data_koin==500);
    nilai_500 = numel(n_500);
     
    [~,n_1000] = find(data_koin==1000);
    nilai_1000 = numel(n_1000);
     
    % menghitung nilai total koin
    nilai_total = nilai_100+nilai_200+nilai_500+nilai_1000;
     
    % menghitung jumlah nilai koin
    jumlah_100 = nilai_100*100;
    jumlah_200 = nilai_200*200;
    jumlah_500 = nilai_500*500;
    jumlah_1000 = nilai_1000*1000;
    jumlah_total = jumlah_100+jumlah_200+jumlah_500+jumlah_1000;
     
    % menginisialisasi variabel cell_koin
    cell_koin = cell(5,3);
     
    % mengisi variabel cell_koin dengan data2 koin
    cell_koin{1,1} = 'Rp. 100';
    cell_koin{2,1} = 'Rp. 200';
    cell_koin{3,1} = 'Rp. 500';
    cell_koin{4,1} = 'Rp. 1000';
    cell_koin{5,1} = 'Total';
    cell_koin{1,2} = num2str(nilai_100);
    cell_koin{2,2} = num2str(nilai_200);
    cell_koin{3,2} = num2str(nilai_500);
    cell_koin{4,2} = num2str(nilai_1000);
    cell_koin{5,2} = num2str(nilai_total);
    cell_koin{1,3} = ['Rp. ',num2str(jumlah_100)];
    cell_koin{2,3} = ['Rp. ',num2str(jumlah_200)];
    cell_koin{3,3} = ['Rp. ',num2str(jumlah_500)];
    cell_koin{4,3} = ['Rp. ',num2str(jumlah_1000)];
    cell_koin{5,3} = ['Rp. ',num2str(jumlah_total)];
    % menampilkan cell_koin pada tabel
    set(handles.uitable1,'Data',cell_koin,...
        'RowName',1:4)
     
    % jika deteksi dilakukan hanya pada uang logam Rp. 100
elseif val2==1
    % menginisialisasi variabel data_koin
    data_koin = 0;
    % membuat boundary pada koin yang terdeteksi
    Boundaries = bwboundaries(bw,'noholes');
     
    % untuk n = 1 s.d n = jumlah objek
    for n = 1:L
        % menghitung nilai Cb dari masing2 objek
        bw_label = (B==n);
        Cb_label = immultiply(Cb,bw_label);
        Cb_label = (sum(sum(Cb_label)))/(sum(sum(bw_label)));
        % menghitung luas dan centroid masing2 objek
        Area = stats(n).Area;
        centroid = stats(n).Centroid;
        % jika nilai Cb > 120 maka dikenali sebagai koin silver
        if Cb_label>120
            % jika luas < 70000 maka dikenali sebagai koin Rp. 100
                if Area<70000 % menampilkan boundary pada objek boundary = Boundaries{n}; plot(boundary(:,2), boundary(:,1), 'y', 'LineWidth', 4) nilai = 100; % menampilkan nilai koin pada centroid objek text(centroid(1)-100,centroid(2),num2str(nilai),... 'Color','y','FontSize',20,'FontWeight','bold'); % mengisi variabel data_koin dengan nilai koin data_koin = [data_koin;nilai]; end end end % menghitung banyaknya koin Rp. 100 [~,n_100] = find(data_koin==100); nilai_100 = numel(n_100); % menghitung jumlah nilai koin Rp. 100 jumlah_100 = nilai_100*100; % menginisialisasi variabel cell_koin cell_koin = cell(1,3); % mengisi variabel cell_koin dengan data2 koin cell_koin{1,1} = 'Rp. 100'; cell_koin{1,2} = num2str(nilai_100); cell_koin{1,3} = ['Rp. ',num2str(jumlah_100)]; % menampilkan cell_koin pada tabel set(handles.uitable1,'Data',cell_koin,... 'RowName',1) % jika deteksi dilakukan hanya pada uang logam Rp. 200 elseif val3==1 % menginisialisasi variabel data_koin data_koin = 0; % membuat boundary pada koin yang terdeteksi Boundaries = bwboundaries(bw,'noholes'); % untuk n = 1 s.d n = jumlah objek for n = 1:L boundary = Boundaries{n}; % menghitung nilai Cb dari masing2 objek bw_label = (B==n); Cb_label = immultiply(Cb,bw_label); Cb_label = (sum(sum(Cb_label)))/(sum(sum(bw_label))); % menghitung luas dan centroid masing2 objek Area = stats(n).Area; centroid = stats(n).Centroid; % jika nilai Cb > 120 maka dikenali sebagai koin silver
            if Cb_label>120
                % jika luas > 70000 & luas < 80000 maka dikenali sebagai koin Rp. 200 if Area>70000 && Area <80000 nilai = 200; % menampilkan boundary pada objek plot(boundary(:,2), boundary(:,1), 'y', 'LineWidth', 4) % menampilkan nilai koin pada centroid objek text(centroid(1)-100,centroid(2),num2str(nilai),... 'Color','y','FontSize',20,'FontWeight','bold'); % mengisi variabel data_koin dengan nilai koin data_koin = [data_koin;nilai]; end end end % menghitung banyaknya koin Rp. 200 [~,n_200] = find(data_koin==200); nilai_200 = numel(n_200); % menghitung jumlah nilai koin jumlah_200 = nilai_200*200; % menginisialisasi variabel cell_koin cell_koin = cell(1,3); % mengisi variabel cell_koin dengan data2 koin cell_koin{1,1} = 'Rp. 200'; cell_koin{1,2} = num2str(nilai_200); cell_koin{1,3} = ['Rp. ',num2str(jumlah_200)]; % menampilkan cell_koin pada tabel set(handles.uitable1,'Data',cell_koin,... 'RowName',1) % jika deteksi dilakukan hanya pada uang logam Rp. 500 elseif val4==1 % menginisialisasi variabel data_koin data_koin = 0; % membuat boundary pada koin yang terdeteksi Boundaries = bwboundaries(bw,'noholes'); % untuk n = 1 s.d n = jumlah objek for n = 1:L boundary = Boundaries{n}; % menghitung nilai Cb dari masing2 objek bw_label = (B==n); Cb_label = immultiply(Cb,bw_label); Cb_label = (sum(sum(Cb_label)))/(sum(sum(bw_label))); % menghitung luas dan centroid masing2 objek Area = stats(n).Area; centroid = stats(n).Centroid; % jika nilai Cb > 120 maka dikenali sebagai koin silver
                if Cb_label>120
                    % jika luas > 80000 maka dikenali sebagai koin Rp. 500
                    if Area>80000
                        nilai = 500;
                        % menampilkan boundary pada objek
                        plot(boundary(:,2), boundary(:,1), 'y', 'LineWidth', 4)
                        % menampilkan nilai koin pada centroid objek
                        text(centroid(1)-100,centroid(2),num2str(nilai),...
                            'Color','y','FontSize',20,'FontWeight','bold');
                        % mengisi variabel data_koin dengan nilai koin
                        data_koin = [data_koin;nilai];
                    end
                    % jika nilai Cb < 120 maka dikenali sebagai koin kuning
                else
                    % jika luas < 70000 maka dikenali sebagai koin Rp. 500
                    if Area<70000
                        nilai = 500;
                        % menampilkan boundary pada objek
                        plot(boundary(:,2), boundary(:,1), 'c', 'LineWidth', 4)
                        % menampilkan nilai koin pada centroid objek
                        text(centroid(1)-100,centroid(2),num2str(nilai),...
                            'Color','c','FontSize',20,'FontWeight','bold');
                        % mengisi variabel data_koin dengan nilai koin
                        data_koin = [data_koin;nilai];
                    end
                end
            end
                end    
        end
    end
     
    % menghitung banyaknya koin Rp. 500
    [~,n_500] = find(data_koin==500);
    nilai_500 = numel(n_500);
     
    % menghitung jumlah nilai koin
    jumlah_500 = nilai_500*500;
     
    % menginisialisasi variabel cell_koin
    cell_koin = cell(1,3);
     
    % mengisi variabel cell_koin dengan data2 koin
    cell_koin{1,1} = 'Rp. 500';
    cell_koin{1,2} = num2str(nilai_500);
    cell_koin{1,3} = ['Rp. ',num2str(jumlah_500)];
    % menampilkan cell_koin pada tabel
    set(handles.uitable1,'Data',cell_koin,...
        'RowName',1)
     
    % jika deteksi dilakukan hanya pada uang logam Rp. 1000
elseif val5==1
    % menginisialisasi variabel data_koin
    data_koin = 0;
    % membuat boundary pada koin yang terdeteksi
    Boundaries = bwboundaries(bw,'noholes');
     
    % untuk n = 1 s.d n = jumlah objek
    for n = 1:L
        boundary = Boundaries{n};
        % menghitung nilai Cb dari masing2 objek
        bw_label = (B==n);
        Cb_label = immultiply(Cb,bw_label);
        Cb_label = (sum(sum(Cb_label)))/(sum(sum(bw_label)));
        % menghitung luas dan centroid masing2 objek
        Area = stats(n).Area;
        centroid = stats(n).Centroid;
        % jika nilai Cb < 120 maka dikenali sebagai koin kuning
        if Cb_label<120 % jika luas > 70000 maka dikenali sebagai koin Rp. 1000
            if Area>70000
                nilai = 1000;
                % membuat boundary pada objek
                plot(boundary(:,2), boundary(:,1), 'c', 'LineWidth', 4)
                % menampilkan nilai koin pada centroid objek
                text(centroid(1)-100,centroid(2),num2str(nilai),...
                    'Color','c','FontSize',20,'FontWeight','bold');
                % mengisi variabel data_koin dengan nilai koin
                data_koin = [data_koin;nilai];
            end
        end
    end
     
    % menghitung banyaknya koin Rp. 1000
    [~,n_1000] = find(data_koin==1000);
    nilai_1000 = numel(n_1000);
     
    % menghitung jumlah nilai koin
    jumlah_1000 = nilai_1000*1000;
     
    % menginisialisasi variabel cell_koin
    cell_koin = cell(1,3);
     
    % mengisi variabel cell_koin dengan data2 koin
    cell_koin{1,1} = 'Rp. 1000';
    cell_koin{1,2} = num2str(nilai_1000);
    cell_koin{1,3} = ['Rp. ',num2str(jumlah_1000)];
    % menampilkan cell_koin pada tabel
    set(handles.uitable1,'Data',cell_koin,...
        'RowName',1)
end

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% mereset button2
set(handles.pushbutton2,'Enable','off')
set(handles.uitable1,'Data',[])
set(handles.checkbox1,'Value',1)
set(handles.checkbox2,'Value',0)
set(handles.checkbox3,'Value',0)
set(handles.checkbox4,'Value',0)
set(handles.checkbox5,'Value',0)
axes(handles.axes1)
cla reset
set(gca,'XTick',[])
set(gca,'YTick',[])
axes(handles.axes2)
cla reset
set(gca,'XTick',[])
set(gca,'YTick',[])

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% menutup halaman deteksi_uangLogam
close all;


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
set(handles.checkbox1,'Value',1)
set(handles.checkbox2,'Value',0)
set(handles.checkbox3,'Value',0)
set(handles.checkbox4,'Value',0)
set(handles.checkbox5,'Value',0)

% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2
set(handles.checkbox1,'Value',0)
set(handles.checkbox2,'Value',1)
set(handles.checkbox3,'Value',0)
set(handles.checkbox4,'Value',0)
set(handles.checkbox5,'Value',0)

% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3
set(handles.checkbox1,'Value',0)
set(handles.checkbox2,'Value',0)
set(handles.checkbox3,'Value',1)
set(handles.checkbox4,'Value',0)
set(handles.checkbox5,'Value',0)

% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4
set(handles.checkbox1,'Value',0)
set(handles.checkbox2,'Value',0)
set(handles.checkbox3,'Value',0)
set(handles.checkbox4,'Value',1)
set(handles.checkbox5,'Value',0)

% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5
set(handles.checkbox1,'Value',0)
set(handles.checkbox2,'Value',0)
set(handles.checkbox3,'Value',0)
set(handles.checkbox4,'Value',0)
set(handles.checkbox5,'Value',1)
