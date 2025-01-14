function [loss,dldx] = l2_loss(x,y)
    loss = abs(x - y).^2;
    dldx = (x - y);

    loss = sum(loss,'all');
end