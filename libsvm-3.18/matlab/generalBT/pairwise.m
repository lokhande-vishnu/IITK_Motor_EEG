function [pest]=pairwise(r)
k = size(r,1);


pest = sum(r,2)*2/k/(k-1);

maxiter=1000;
pest = pest / sum(pest);
mu=zeros(k,k);
for i =1:k
  mu(i,i+1:k) = pest(i) ./ (pest(i)+pest(i+1:k)') ;
  mu(i+1:k,i) = 1 - mu(i,i+1:k)';
end

for t=1:maxiter,
  for i = 1:k,
    alpha =  sum(r(i,:)) / sum(mu(i,:)) ;      
    pest(i) = pest(i)*alpha;
    noti=[1:i-1,i+1:k];
    mu(i,noti) = alpha*mu(i,noti) ./ (alpha*mu(i,noti)+ mu(noti,i)'); 
    mu(noti,i) = 1 - mu(i,noti)'; 
  end
  pest = pest ./ sum(pest);
  if (max(abs(sum(r,2)./sum(mu,2)-1)) < 0.001)
    return;
  end
end
fprintf(1, 'max iteration\b');

