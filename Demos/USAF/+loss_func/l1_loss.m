function [loss,dldx] = l1_loss(x,y)
loss = abs(x - y);
dldx = sign(x - y);

loss = sum(loss,'all');
end