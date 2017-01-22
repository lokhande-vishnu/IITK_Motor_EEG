function [pest]=halfhalf(k,r,Ip)
% Ip, In : m*k 0/1 matrix

p = ones(k,1)/k;
% p = rand(k,1);
delta=p;

maxiter=1000;
for t = 1:maxiter,
  for i = 1:k, 
    pp=repmat(p',size(r,1),1);
    qp=sum(pp.*Ip,2);
    Ipp=Ip(:,i);
    delta(i)=sum(r(Ipp)./qp(Ipp))/sum(r);
    p(i)=delta(i)*p(i);
    p = p/sum(p);
  end
  if (max(abs(delta-1)) < 0.001)
    break;
  end
end
pest=p;

