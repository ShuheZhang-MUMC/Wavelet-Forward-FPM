function [loss,dldx] = wavelet_loss(x,y,level,wave_name)

dldx = x - y;
loss = 0;

for channel = 1:size(dldx,3)
    [c,s] = wavedec2(dldx(:,:,channel),level,wave_name);
    loss = loss + sum(abs(c),'all');
    dldx(:,:,channel) = waverec2(sign(c),s,wave_name); 
end

end