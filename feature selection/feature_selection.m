function feature_selection(cnt,mrk)

pre_rxy=zeros(298458,236);
count1=1; count2=1;
for i=1:length(mrk.y)
    if(i~=1)
     lb=mrk.pos(i-1);
     ub=mrk.pos(i);
    else
        lb=0;
        ub=mrk.pos(i);
    end
    if(mrk.y(i)==1)
    pre_rxy(count1:count1+ub-lb-1,1:118)=cnt(lb+1:ub,:);
    count1=count1+ub-lb;
    end
    
    if(mrk.y(i)==2)
    pre_rxy(count2:count2+ub-lb-1,119:236)=cnt(lb+1:ub,:);
    count2=count2+ub-lb;
    end
end
save('pre_rxy');

rxy=struct('r',{},'mean',{},'median',{},'mode',{},'std',{},'max',{},'min',{});

for i=2:236
    rxy(i-1).r=xcorr(pre_rxy(:,1),pre_rxy(:,i));
    rxy(i-1).mean=mean(rxy(i-1).r);
    rxy(i-1).median=median(rxy(i-1).r);
    rxy(i-1).mode=mode(rxy(i-1).r);
    rxy(i-1).std=std(rxy(i-1).r);
    rxy(i-1).max=max(rxy(i-1).r);
    rxy(i-1).min=min(rxy(i-1).r);
    
end
save('rxy');
end