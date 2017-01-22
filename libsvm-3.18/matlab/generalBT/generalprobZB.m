function [pest]=generalprobZB(r,Ip,I)
k = size(Ip,2);
% Ip, m*k 0/1 matrix

p = ones(k,1)/k;
% p = rand(k,1);
delta=zeros(k,1);

maxiter=100;
for t = 1:maxiter,
  for i = 1:k, 
    pp=repmat(p',size(r,1),1);
    qp=sum(pp.*Ip,2);
    Ipp=Ip(:,i);
    q=sum(pp.*I,2);
    Ii= I(:,i);
    delta(i)=sum(r(Ipp))/sum(qp(Ipp)./q(Ipp));
    if (isnan(delta(i)))
      p
      delta
      qp(Ipp)
      q(Ii)
      exit(1);
    end
    p(i)=delta(i)*p(i);
    p = p/sum(p);
  end
  if (max(abs(delta-1)) < 0.05)
    separate=t*k;
    break;
  end
end
pest=p;

