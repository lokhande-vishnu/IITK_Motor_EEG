function cc_fft(cnt,mrk,ref)

a=NaN;b=NaN;
for i=1:length(mrk.y)
    if(i~=1)
        lb=mrk.pos(i-1);
        ub=mrk.pos(i);
    else
        lb=0;
        ub=mrk.pos(i);
    end
    if(mrk.y(i)==1)
        if(isnan(a))
            a=cnt(lb+1:ub,:);
        else
            a=[a ; cnt(lb+1:ub,:)];
        end
        %count1=count1+ub-lb;
    end
    
    if(mrk.y(i)==2)
        if(isnan(b))
            b=cnt(lb+1:ub,:);
        else
            b=[b ; cnt(lb+1:ub,:)];
            %count2=count2+ub-lb;
        end
    end
end
a=double(a);b=double(b);
% save('a');
% save('b');


X=zeros(236,8); Y=zeros(236,1);
for i=1:236
    
    % using c3 as reference which is at position 52
    %temp=xcorr(pre_rxy2(:,ref),pre_rxy2(:,i));  %finding cross-corrlation
    if(i<=118)
        input=xcorr(a(:,ref),a(:,i));  %finding cross-corrlation
    else
        input=xcorr(a(:,ref),b(:,i-118));  %finding cross-corrlation
    end
    point=power(2,nextpow2(length(input)));
    point2=(point/2)/8;
    H1=fft(input,point);                % total points (power of 2)
    energy = abs(H1).^2;
    for k=1:8
        X(i,k)=sum(energy((point2*(k-1)+1):(point2*k)));
        X(i,k) = X(i,k)/sum(abs(energy));
    end
    clear H1 energy input;
    
    if(i<=118)
        Y(i,1)=0;
    else
        Y(i,1)=1;
    end
   
end
X(ref:235,:)=X(ref+1:236,:); X(236,:)=[];
Y(ref:235,:)=Y(ref+1:236,:); Y(236,:)=[];
%feature scaling
for i=1:8
    z=X(:,i);
    xhat(:,i)=(z-mean(z))/std(z);
end
X=xhat;

%Z=[X,Y];
save('X');
save('Y');
%save('Z.txt','-ascii');
end