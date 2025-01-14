function [wavefront1,wavefront2,...
                        data_cube,...
                        pratio,Pupil0,kc] = perpare_trainingdata(path,...
                                                             rect,...
                                                             color_index,...
                                                             pix,...
                                                             num_leds,...
                                                             batch_size)

global upsamp
% load loc_pos.mat
imRaw_new = zeros(pix,pix,num_leds^2);

% Load data, crop image
for num_of_image = 1:num_leds^2
    clc
    disp(num_of_image);
    img = double(imread([path{color_index},num2str(num_of_image),'.tif'],...
        'PixelRegion',{[rect(2),rect(2)+pix-1], ...
                       [rect(1),rect(1)+pix-1]}));

    % clear img_full;
    imRaw_new(:,:,num_of_image) = mean(img,3);
end

close all

imRaw_new = imRaw_new - min(imRaw_new(:));
imRaw_new = imRaw_new / max(imRaw_new(:));
imRaw_new = gpuArray(single(sqrt(imRaw_new)));


[f_pos_set_true,ord_isum,...
                ord_jsum,pratio,Pupil0,kc,k] = init_environment_rgb(color_index,...
                                                      pix, ...
                                                      num_leds);
imRaw_num = 0 * imRaw_new;

for led_num = 1:num_leds^2
    ii = ord_isum(led_num);
    jj = ord_jsum(led_num);
    uo(led_num) = f_pos_set_true(ii,jj,1);
    vo(led_num) = f_pos_set_true(ii,jj,2);
    imRaw_num(:,:,led_num) = imRaw_new(:,:,k(ii,jj));
end

led_pos  = [vo',uo'];

clear imRaw_new
fpm_cube = combine(arrayDatastore(led_pos, 'IterationDimension',1),...
                   arrayDatastore(imRaw_num, 'IterationDimension',3));

% (0~225) set mini-batch size a total of 225 images for FPM recon
data_cube = minibatchqueue(fpm_cube,...
            'MiniBatchSize',     batch_size,...
            'MiniBatchFormat',   ["",""],...
            'OutputEnvironment', {'gpu'},...
            'OutputAsDlarray',   false,...
            'OutputCast',        'single');

wavefront1 = gpuArray(single(imresize(imRaw_num(:,:,1),pratio * upsamp))); 
wavefront2 = gpuArray(single(Pupil0));       

end



function [ledpos_true,ord_isum,...
                      ord_jsum,pratio,Pupil0,kc,k] = init_environment_rgb(color_index, ...
                                                               pix, ...
                                                               led_num)

global upsamp

%% parameters
lambda = [0.532,0.532,0.532];
% color_index = 1;
% pix = 2048
lamuda = lambda(color_index);%wavelength um
D_led = 8.0*1000;%Distance between neighboring LED elements
h0 = 85;
h = h0 * 1000;%Distance between LED and sample

ledMM = led_num;
ledNN = led_num;%LED array

ledM=ledMM;ledN=ledNN;
k_lamuda=2*pi/lamuda;%wave number

if upsamp > 1
    pixel_size = 6.9/ upsamp;   %Camera pixel size
else
    pixel_size = 6.9;           %Camera pixel size
end
mag  = 5;       %Magnification
NA = 0.14;      %Objective lens numerical aperture

M = pix * upsamp;
N = pix * upsamp;%Image size captured by CCD
kc = [-M/2,-1+M/2,-N/2,-1+N/2];

D_pixel=pixel_size/mag;%Image plane pixel size
kmax=NA*k_lamuda;%Maximum wave number corresponding to the numerical aperture of the objective lens

Rcam = lamuda / NA*mag / 2 /pixel_size;
RLED = NA*sqrt(D_led^2 + h^2)/D_led;
Roverlap = 1/pi*(2*acos(1/2/RLED)-1/RLED*sqrt(1-(1/2/RLED)^2));


%Magnification of the reconstructed image compared to the original image
MAGimg = 5;%ceil(1+2*D_pixel*3*D_led/sqrt((3*D_led)^2+h^2)/lamuda);%Magnification of the reconstructed image compared to the original image
MM=M*MAGimg;NN=N*MAGimg;%Image size after reconstruction
Niter1 = 50;%Number of iterations
x=-0;
objdx=x*D_pixel;%Location of the small area selected in the sample.As this area becomes larger, the vignetting becomes more pronounced
y=-0;
objdy=y*D_pixel;%
pratio = MAGimg;
%% 频域坐标

[Fx1,Fy1]=meshgrid(-(N/2):(N/2-1),-(M/2):(M/2-1));
Fx1=Fx1./(N*D_pixel).*(2*pi);%Frequency domain coordinates of the original image
Fy1=Fy1./(M*D_pixel).*(2*pi);%Frequency domain coordinates of the original image
Fx2=Fx1.*Fx1;
Fy2=Fy1.*Fy1;
Fxy2=Fx2+Fy2;
Pupil0=zeros(M,N);
Pupil0(Fxy2<=(kmax^2))=1;%Aperture of the objective lens in the frequency domain
[Fxx1,Fyy1]=meshgrid(-(NN/2):(NN/2-1),-(MM/2):(MM/2-1));
Fxx1=Fxx1(1,:)./(N*D_pixel).*(2*pi);%Reconstructing the frequency domain coordinates of an image
Fyy1=Fyy1(:,1)./(M*D_pixel).*(2*pi);%Reconstructing the frequency domain coordinates of an image
%%
% dist = 0;
% kx = pi/D_pixel*(-1:2/M:1-2/M);
% ky = pi/D_pixel*(-1:2/N:1-2/N);
% [KX,KY] = meshgrid(kx,ky);
% 
% k = 2*pi/lamuda;   % wave number
% KX_m = KX;
% KY_m = KY;
% ind = (KX.^2+KY.^2 >= k^2);
% KX_m(ind) = 0;
% KY_m(ind) = 0;
%  % transfer function
% global prop
% prop = exp(-1i*dist*sqrt(k^2-KX_m.^2-KY_m.^2));


%% 每个LED在频域对应的像素坐标
lit_cenv = (ledMM-1)/2;
lit_cenh = (ledMM-1)/2;
vled = (0:ledMM-1) - lit_cenv;
hled = (0:ledMM-1) - lit_cenh;
[hhled,vvled] = meshgrid(hled,vled);
% rrled = sqrt(hhled.^2+vvled.^2);
% LitCoord = rrled<dia_led/2;

k=zeros(ledMM,ledNN);% index of LEDs used in the experiment
for i=1:ledMM
    for j=1:ledNN
        k(i,j)=j+(i-1)*ledNN;
    end
end

% Nled = sum(LitCoord(:));% total number of LEDs used in the experiment

% corresponding angles for each LEDs
% v = (-vvled*D_led+objdx)./sqrt((-vvled*D_led+objdx).^2+(-hhled*D_led+objdy).^2+h.^2);%
% u = (-hhled*D_led+objdy)./sqrt((-vvled*D_led+objdx).^2+(-hhled*D_led+objdy).^2+h.^2);%

u = (vvled*D_led)./sqrt((vvled*D_led).^2+(hhled*D_led).^2 + h.^2);%
v = (hhled*D_led)./sqrt((vvled*D_led).^2+(hhled*D_led).^2 + h.^2);%


NAillu=sqrt(u.^2+v.^2);

ledpos_true=zeros(ledMM,ledNN,2);

for i=1:ledMM
    for j=1:ledNN
        Fx1_temp=abs(Fxx1-k_lamuda*u(i,j));
        ledpos_true(i,j,1)=find(Fx1_temp==min(Fx1_temp));
        Fy1_temp=abs(Fyy1-k_lamuda*v(i,j));
        ledpos_true(i,j,2)=find(Fy1_temp==min(Fy1_temp));
    end
end


%% Generate an iterative sequence from the center around the circle outward
ord_ijsum=zeros(ledMM,ledNN);
ord_isum=zeros(1,ledM*ledN);
ord_jsum=zeros(1,ledM*ledN);
ord_ii=(ledMM+1)/2;
ord_jj=(ledNN+1)/2;
ord_isum(1,1)=ord_ii;
ord_jsum(1,1)=ord_jj;
ord_ijsum(ord_ii,ord_jj)=1;
led_num=1;
direction=0;
while (min(min(ord_ijsum))==0)
    led_num=led_num+1;
    direction2=direction+1;
    ord_ii2=round(ord_ii+sin(pi/2*direction2));
    ord_jj2=round(ord_jj+cos(pi/2*direction2));
    if (ord_ijsum(ord_ii2,ord_jj2)==0)
        direction=direction2;
    end
    ord_ii=round(ord_ii+sin(pi/2*direction));
    ord_jj=round(ord_jj+cos(pi/2*direction));
    ord_isum(1,led_num)=ord_ii;
    ord_jsum(1,led_num)=ord_jj;
    ord_ijsum(ord_ii,ord_jj)=1;
end

end
