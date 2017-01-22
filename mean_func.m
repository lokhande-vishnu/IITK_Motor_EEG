function score=mean_func(healthy,faulty,thresh_ratio,score)

feature=size(healthy,2);

  for i=1:feature
        if(score(1,i)~=0)
            meanh=mean(healthy(:,i));
            meanf=mean(faulty(:,i));
        else
            continue;
        end
        if(meanh>meanf)
            upper=healthy(:,i);
            lower=faulty(:,i);
        else
            upper=faulty(:,i);
            lower=healthy(:,i);
        end
        
        if(abs((mean(upper)/mean(lower)))<thresh_ratio)       %threshold for separation
            score(1,i)=0;
        end
        
  end
    
end