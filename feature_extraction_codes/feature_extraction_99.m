function feature_extraction_99(cnt,mrk,ref)

% pre_rxy2=zeros(size(cnt,1),236);
% count1=1; count2=1;
% for i=1:length(mrk.y)
%     if(i~=1)
%         lb=mrk.pos(i-1);
%         ub=mrk.pos(i);
%     else
%         lb=0;
%         ub=mrk.pos(i);
%     end
%     if(mrk.y(i)==1)
%         pre_rxy2(count1:count1+ub-lb-1,1:118)=cnt(lb+1:ub,:);
%         count1=count1+ub-lb;
%     end
%
%     if(mrk.y(i)==2)
%         pre_rxy2(count2:count2+ub-lb-1,119:236)=cnt(lb+1:ub,:);
%         count2=count2+ub-lb;
%     end
% end
% save('pre_rxy2');

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
%X=zeros(235,6); Y=zeros(235,1);
X=zeros(235,9); Y=zeros(235,1);
for i=1:236
    
    % using c3 as reference which is at position 52
    %temp=xcorr(pre_rxy2(:,ref),pre_rxy2(:,i));  %finding cross-corrlation
    
    if(i<=118)
        temp=xcorr(a(:,ref),a(:,i));  %finding cross-corrlation
    else
        temp=xcorr(a(:,ref),b(:,i-118));  %finding cross-corrlation
    end    
    %statistical feature extraction
    X(i,1)=mean(temp);
    X(i,2)=median(temp);
    X(i,3)=max(hist(temp));
    X(i,4)=std(temp);
    X(i,5)=max(temp);
    X(i,6)=min(temp);
    X(i,7)=iqr(temp);
    X(i,8)=prctile(temp,25);
    X(i,9)=prctile(temp,75);
    
    if(i<=118)
        Y(i,1)=0;
    else
        Y(i,1)=1;
    end
end
X(ref:235,:)=X(ref+1:236,:); X(236,:)=[];
Y(ref:235,:)=Y(ref+1:236,:); Y(236,:)=[];
%feature scaling
for i=1:9
    z=X(:,i);
    xhat(:,i)=(z-mean(z))/std(z);
end
X=xhat;

save('X');
save('Y');
% indices = crossvalind('Kfold',Y,10);
% save('indices');
end