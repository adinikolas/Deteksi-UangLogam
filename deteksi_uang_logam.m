clc; clear; close all; warning off all;
 
% membaca citra rgb
Img = imread('uang.jpg');
figure, imshow(Img);

% mengkonversi citra rgb menjadi grayscale
Img_gray = rgb2gray(Img);
figure, imshow(Img_gray);

% mengkonversi citra grayscale menjadi biner
bw = im2bw(Img_gray,graythresh(Img_gray));
% melakukan komplemen citra agar objek bernilai satu dan background bernilai nol
bw = imcomplement(bw);
figure, imshow(bw);

% operasi morfologi untuk menyempurnakan hasil segmentasi
% area opening untuk menghilangkan noise
bw = bwareaopen(bw,100);
% filling holes untuk mengisi objek yang berlubang
bw = imfill(bw,'holes');
% closing untuk membuat bentuk objek lebih smooth
str = strel('disk',5);
bw = imclose(bw,str);
% menghilangkan objek yang menempel pada border (tepian citra)
bw = imclearborder(bw);

% pelabelan terhadap masing2 objek
[B,L] = bwlabel(bw);
% menghitung luas dan centroid objek
stats = regionprops(B,'All');
% mengkonversi citra rgb menjadi YCbCr
YCbCr = rgb2ycbcr(Img);
% mengekstrak komponen Cb (Chrominance-blue)
Cb = YCbCr(:,:,2);
 
% menampilkan citra rgb
figure, imshow(Img);
hold on
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
        % jika luas < 70000 maka dikenali sebagai koin 100
        if Area<70000
            nilai = 100;
            % jika luas < 80000 maka dikenali sebagai koin 200
        elseif Area<80000 nilai = 200; % jika luas > 80000 maka dikenali sebagai koin 500
        else
            nilai = 500;
        end
        % menampilkan boundary pada objek
        plot(boundary(:,2), boundary(:,1), 'y', 'LineWidth', 4)
        % menampilkan nilai koin pada centroid objek
        text(centroid(1)-50,centroid(2),num2str(nilai),...
            'Color','y','FontSize',20,'FontWeight','bold');
        % jika nilai Cb < 120 maka dikenali sebagai koin kuning
    else
        % jika luas < 70000 maka dikenali sebagai koin 500
        if Area<70000 nilai = 500; % jika luas > 70000 maka dikenali sebagai koin 1000
        else
            nilai = 1000;
        end
        % menampilkan boundary pada objek
        plot(boundary(:,2), boundary(:,1), 'c', 'LineWidth', 4)
        % menampilkan nilai koin pada centroid objek
        text(centroid(1)-50,centroid(2),num2str(nilai),...
            'Color','c','FontSize',20,'FontWeight','bold');
    end
end