function [f]=onevsalleq(d,r)
k = size(r,1);
f=sum((1+d-sqrt((1+d)*(1+d)-4*r*d))/2/d)-1;