function [centres, options, post, errlog] = sp_kmeans(centres, pop, options)
data = pop;
[ndata, data_dim] = size(data);
[ncentres, dim] = size(centres);

if dim ~= data_dim
  error('Data dimension does not match dimension of centres')
end

if (ncentres > ndata)
  error('More centres than data')
end

if (options(14))
  niters = options(14);
else
  niters = 100;
end

store = 0;

if (nargout > 3)
  store = 1;
  errlog = zeros(1, niters);
end

if (options(5) == 1)
  perm = randperm(ndata);
  perm = perm(1:ncentres);

  centres = data(perm, :);
end

id = eye(ncentres);

for n = 1:niters
  old_centres = centres;
  d2 = sp_dist2(data, centres);
  [minvals, index] = min(d2', [], 1);
  post = id(index,:);
  num_points = sum(post, 1);
  e = sum(minvals);
  
  if options(1) > 0
    fprintf(1, 'Cycle %4d  Error %11.6f\n', n, e);
  end

  if n > 1
    if max(max(abs(centres - old_centres))) < options(2) & ...
        abs(old_e - e) < options(3)
      options(8) = e;
      return;
    end
  end
  
  old_e = e;
end

if (options(1) >= 0)
  disp('Warning: Maximum number of iterations has been exceeded');
end
