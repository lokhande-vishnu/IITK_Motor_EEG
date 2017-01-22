function [pest]=onevsalliter(r)

% use iter; slow
k = size(r,1);

rp=1-r;
p = ones(k,1)/k;
delta=zeros(k,1);

maxiter=1000;
for t = 1:maxiter,
  for i = 1:k, 
    delta(i) = (sum(rp./(1-p))-(1-r(i))/(1-p(i))+r(i)/p(i))/k;
    %[delta*k p(i)*(delta-1) sum(rp./(1-p+p(i)*(delta-1)))-(rp(i))/(1-p(i)+p(i)*(delta-1))+r(i)/(p(i)*delta)];
    p(i)=delta(i)*p(i);
    p = p/sum(p);
  end
  if (max(abs(delta-1)) < 0.001)
    break;
  end
end
pest=p;

% use equality
% $$$ d=fzero('onevsalleq',0.1,[],r);
% $$$ p1 = (1+d-sqrt((1+d)*(1+d)-4*r*d))/2/d;
% $$$ pest= p1;
