data_preF=zeros(1600,4);w=1;   %keep note of data_pre number
for u=1:100
    for v=0:15
        if(v~=15)
            x=data_mat(u,1+256*v:256+256*v)';
        else
            x=data_mat(u,3841:4098)';
        end
        
        [ndata nvars]=size(x);
        
        N2 = floor(ndata/2);
        N4 = floor(ndata/4);
        TOL = 1.0e-6;
        
        exponent = zeros(N4+1,1);
        
        for p=N4:N2  % second quartile of data should be sufficiently evolved
            dist = norm(x(p+1,:)-x(p,:));
            indx = p+1;
            for j=1:ndata-5
                if (p ~= j) && norm(x(p,:)-x(j,:))<dist
                    dist = norm(x(p,:)-x(j,:));
                    indx = j; % closest point!
                end
            end
            expn = 0.0; % estimate local rate of expansion (i.e. largest eigenvalue)
            for k=1:5
                if norm(x(p+k,:)-x(indx+k,:))>TOL && norm(x(p,:)-x(indx,:))>TOL
                    expn = expn + (log(norm(x(p+k,:)-x(indx+k,:)))-log(norm(x(p,:)-x(indx,:))))/k;
                end
            end
            exponent(p-N4+1)=expn/5;
        end
        
                %statistical feature extraction
                data_preF(w,1)=max(exponent);
                data_preF(w,2)=min(exponent);
                data_preF(w,3)=mean(exponent);
                data_preF(w,4)=std(exponent);
        
%         data_preZ(w,1)=sum(abs(exponent))/length(exponent);                % Absolute Mean
%         data_preZ(w,2)=max(abs(exponent));                               % Max Peak
%         data_preZ(w,3)=sqrt((sum(exponent.^2))/length(exponent));              % Rms Value
%         data_preZ(w,4)=sum((exponent-mean(exponent)).^2)/(length(exponent)-1);   % Variance
%         data_preZ(w,5)=kurtosis(exponent);                                  % Kurtosis
%         data_preZ(w,6)=data_preZ(w,2)/data_preZ(w,3);                                      % Crest Nactor
%         data_preZ(w,7)=data_preZ(w,3)/abs(mean(exponent));                               % Shape Factor
%         data_preZ(w,8)= skewness(exponent);
        w=w+1;
    end
    
end
save('data_preF');
