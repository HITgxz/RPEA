function n2 = sp_dist2(x, c)
% DIST2 Calculates squared distance between two sets of points.
%%在原有dist函数基础上的修改版本，用来计算数据与指定中心之间距离的%%


[ndata, dimx] = size(x);
[ncentres, dimc] = size(c);
if dimx ~= dimc
    error('Data dimension does not match dimension of centres')
end

n2 = (ones(ncentres, 1) * sum((x.^2)', 1))' + ...
  ones(ndata, 1) * sum((c.^2)',1) - ...
  2.*(x*(c'));

% 舍入误差有时会导致n2中的负数项
if any(any(n2<0))
  n2(n2<0) = 0;
end
