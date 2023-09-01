J = imread('doggo.png');
I = im2gray(J);
%figure,imshow(I);
%I_diff = double(I);
del_t = 0.1;
del_x = 1;
del_y = 1;

g_img = imnoise(I,'gaussian');
imp_img = imnoise(I, 'salt & pepper');
sp_img = imnoise(I, 'speckle');
noisy_images = {g_img, imp_img, sp_img};
figure;
subplot(2,2,1),imshow(J),title('Original image');
subplot(2,2,2),imshow(g_img),title('Gaussian Noise image');
subplot(2,2,3),imshow(imp_img),title('Impulse Noise image');
subplot(2,2,4),imshow(sp_img),title('Speckle Noise image');
res={};
psnrs={};
ssims={};
mses={};
for cnt=1:3
    I_diff = double(noisy_images{cnt});
    PSNR=[];
    SSIM=[];
    MSE=[];
    for iter=1:50
        prev=I_diff;
        
        for i=1+del_x:size(I ,1)- 2* del_x
            for j=1+del_y:size(I,2) - 2*del_y   
                a = double(prev(i + del_x,j));
                b = double(prev(i - del_x,j));
                c = double(prev(i,j - del_y));
                d = double(prev(i,j + del_y));
                e = double(4 * prev(i,j));
                %x =  (prev(i + del_x,j) + prev(i - del_x,j) + prev(i,j + del_y) + prev(i,j - del_y) - 4 * prev(i,j))
                %I_diff(i,j) = prev(i,j) + (del_t / (del_x ^ 2)) * (prev(i + del_x,j) + prev(i - del_x,j) + prev(i,j + del_y) + prev(i,j - del_y) - 4 * prev(i,j));
                I_diff(i,j) = prev(i,j) + (del_t / (del_x ^ 2)) * (a+b+c+d-e);
            end
        end
        PSNR(iter)=psnr(uint8(I_diff),I);
        SSIM(iter)=ssim(uint8(I_diff),I);
        MSE(iter)=immse(uint8(I_diff),I);

    end
    res{cnt}=uint8(I_diff);
    psnrs{cnt}=PSNR;
    ssims{cnt}=SSIM;
    mses{cnt}=MSE;
    %figure,imshow(uint8(I_diff))
end
figure;
subplot(2,2,1),imshow(J),title('Original image');
subplot(2,2,2),imshow(res{1}),title('Denoised Gaussian image');
subplot(2,2,3),imshow(res{2}),title('Denoised Impulse image');
subplot(2,2,4),imshow(res{3}),title('Denoised Speckle image');

figure;
hold on;
cellfun(@plot,psnrs),title('PSNR'),xlabel('Iterations'),ylabel('PSNR in dB'),legend({'Gaussian Nosie','Impulse Noise','Speckle Noise'},'Location','northeast');

figure;
hold on;
cellfun(@plot,mses),title('MSE'),xlabel('Iterations'),ylabel('MSE'),legend({'Gaussian Nosie','Impulse Noise','Speckle Noise'},'Location','northeast');

figure;
hold on;
cellfun(@plot,ssims),title('SSIM'),xlabel('Iterations'),ylabel('SSIM'),legend({'Gaussian Nosie','Impulse Noise','Speckle Noise'},'Location','northeastoutside');

% figure;
% subplot(1,3,1),plot(psnrs, 1:50),title('PSNR');
% subplot(1,3,2),plot(ssims, 1:50),title('SSIM');
% subplot(1,3,3),plot(mses, 1:50),title('MSE');