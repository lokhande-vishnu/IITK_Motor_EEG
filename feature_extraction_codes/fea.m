function fea(cnt,mrk)

pre_rxy2=zeros(size(cnt,1),236);
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
        pre_rxy2(count1:count1+ub-lb-1,1:118)=cnt(lb+1:ub,:);
        count1=count1+ub-lb;
    end
    
    if(mrk.y(i)==2)
        pre_rxy2(count2:count2+ub-lb-1,119:236)=cnt(lb+1:ub,:);
        count2=count2+ub-lb;
    end
end
save('pre_rxy2');

X=zeros(236,9); Y=zeros(236,1);
for i=1:236
    
    % using c3 as reference which is at position 52
    %temp=xcorr(pre_rxy2(:,ref),pre_rxy2(:,i));  %finding cross-corrlation
    
    %DWT
    input=pre_rxy2(:,i)';
    [C,L] = wavedec(input,6,'db4');          % All wavelet coefficients here and respe.length
    cA6 = appcoef(C,L,'db4',6);
    [cD1,cD2,cD3,cD4,cD5,cD6] = detcoef(C,L,[1,2,3,4,5,6]);
    
    % Autocorrelation(AC)
    [ACF4, Lags4] = autocorr(cD4, length(cD4)-1);
    [ACF5, Lags5] = autocorr(cD5, length(cD5)-1);
    [ACF6, Lags6] = autocorr(cD6, length(cD6)-1);
    
    var_AC4=sum((ACF4-mean(ACF4)).^2)/(length(ACF4)-1);
    var_AC5=sum((ACF5-mean(ACF5)).^2)/(length(ACF5)-1);
    var_AC6=sum((ACF6-mean(ACF6)).^2)/(length(ACF6)-1);
    
    % Moving Average Filter
    l1=length(cD1);
    l2=length(cD2);
    l3=length(cD3);
    m=5;                                    % 'm' must be odd for symmetrical arrangments
    sum1=0;
    
    % Moving average for cD1
    for k = 1:l1
        if k<=m || k>(l1-m)
            arr(k)=0;                    % leaving initial and last samples
        else
            sum1=0;
            for l=(k-m):(k+m-1)
                sum1=sum1+abs(cD1(l));
            end
            sum1=sum1/(2*m);
            S1(k-m)=sum1;
        end
    end
    clear arr l1 k sum1;
    
    % Moving average for cD2
    for k = 1:l2
        if k<=m || k>(l2-m)
            arr(k)=0;
        else
            sum1=0;
            for l = (k-m):(k+m-1)
                sum1=sum1+abs(cD2(l));
            end
            sum1=sum1/(2*m);
            S2(k)=sum1;
        end
    end
    
    clear arr l2 k sum1;
    sum1=0;
    
    % Moving average for cD3
    for k = 1:l3
        if k<=m || k>(l3-m)
            arr(k)=0;
        else
            for l=(k-m):(k+m-1)
                sum1=sum1+abs(cD3(l));
            end
            sum1=sum1/(2*m);
            S3(k-m)=sum1;
            sum1=0;
        end
    end
    clear k l3 arr sum1;
    
    % Following variance provide power of high-frequency vibrations
    
    var_1=sum((cD1-mean(cD1)).^2)/(length(cD1)-1);X(i,1)
    var_2=sum((cD2-mean(cD2)).^2)/(length(cD2)-1);X(i,2)
    var_3=sum((cD3-mean(cD3)).^2)/(length(cD3)-1);X(i,3)
    
    % Sample Mean & Quotient provides maximum local extent of high frequencyvibrations
    M_S1=mean(S1);
    M_S2=mean(S2);
    M_S3=mean(S3);
    X(i,1)=var_1;X(i,2)=var_2;X(i,3)=var_3;X(i,4)=var_AC4;X(i,5)=var_AC5;X(i,6)=var_AC6;X(i,7)=M_S1;X(i,8)=M_S2;X(i,9)=M_S3;
    
    clear cA6 cD1 cD2 cD3 cD4 cD5 cD6;
    clear ACF4 ACF5 ACF6 Lags4 Lags5 Lags6;
    clear var_1 var_2 var_3 var_AC4 var_AC5 var_AC6 M_S1 M_S2 M_S3;
    clear C L m S1 S2 S3;
    
%     %S- transform
%     s = st(temp');                    % function of S-Tranform has been implemented over the downsampled data
%     s = abs(s);
%     m2 = max(s');                          % max values has been found out from the transformed data  corresponding to every frequency .
%     % Rajat decided with these bins because of better plots
%     for j=1:36
%         X(i,j) = sum(abs(m2((100*(j-1)+1):(100*j))));     % bins formation step
%         X(i,j) = X(i,j)/sum(abs(m2));% single bin energy is divided by total energy
%     end
%     
    
    
    %         %updated morlet trasform
    %         a=16; b=0.02; b1=0.5; a1=0.9;
    %         for t=1:200
    %             umorl(t)=exp(-b1.^2*(t-b).^2/a^2)*(sin(pi*(t-b)/a).^2);   %updated morlet transform function(known as 'umorl' function).
    %         end
    %         umorc=conv(pre_rxy2(:,i)',umorl);   %convolution of data and umorl function has been done
    %         X(i,1)=std(umorc);          % Standard Deviation
    %         X(i,2)=entropy(umorc);      % Wavelet Entropy
    %         X(i,3)=kurtosis(umorc);     % Kurtosis
    %         X(i,4)=skewness(umorc);     % Skewness
    %         X(i,5)=std(umorc).^2;       % Variance = (STD DEV)^2
    
    %     %winger-ville
    %     tf = tfrwv(temp');                 % function of WVD has been implemented over the downsampled data
    %     n1 = max(tf');                          % max values has been found out from the transformed data  corresponding to every frequency .
    %     points = floor(100/(72*2*5));
    %
    %     for j=1:72
    %         X(i,j) = sum(abs(n1((points*(j-1)+1):(points*j))));    % bins formation step
    %         X(i,j)=  X(i,j)/sum(abs(n1));% single bin energy is divided by total energy
    %     end
    
    %     %auto-correlation
    %     AC = autocorr(temp,length(temp)-1);         %autocorrelation function has been apllied
    %     var_AC = sum((AC-mean(AC)).^2)/(length(AC)-1);  %variance has been calculated for the above solved autocorrelated array
    %     X(i,1) = var_AC;
    %
    
    %     %discrete wavelet transform
    %     dc = dct(temp);
    %     points = floor(100/(6*2));                               % 8 bins & half points are the Mirror image
    %     for j=1:6
    %         %     ret(i)=sum(abs(dc((2756*(i-1)+1):(2756*i))));        % Rajat's bin formation step
    %         X(i,j)=sum(abs(dc((points*(j-1)+1):(points*j))));    % bin formation step
    %         X(i,j)=X(i,j)/sum(abs(dc));% single bin energy is divided by total energy
    %     end
    
    %     %fft feature selection
    %     H1=fft(pre_rxy2(:,i),524288);                % total points (power of 2)
    %     energy = abs(H1).^2;
    %     for j=1:8
    %         X(i,j)=sum(energy((32768*(j-1)+1):(32768*j)));
    %         X(i,j)=X(i,j)/sum(abs(energy));
    %     end
    
    %
    %     %statistical feature extraction2
    %     X(i,1)=sum(abs(temp))/length(temp);                % Absolute Mean
    %     X(i,2)=max(abs(temp));                               % Max Peak
    %     X(i,3)=sqrt((sum(temp.^2))/length(temp));              % Rms Value
    %     X(i,4)=sum((temp-mean(temp)).^2)/(length(temp)-1);   % Variance
    %     X(i,5)=kurtosis(temp);                                  % Kurtosis
    %     X(i,6)=X(i,2)/X(i,3);                                      % Crest Factor
    %     X(i,7)=X(i,3)/abs(mean(temp));                               % Shape Factor
    %     X(i,8)= skewness(temp);                                 % Skewness
    
    
    %     %statistical feature extraction
    %     X(i,1)=mean(temp);
    %     X(i,2)=median(temp);
    %     X(i,3)=max(hist(temp));
    %     X(i,4)=std(temp);
    %     X(i,5)=max(temp);
    %     X(i,6)=min(temp);
    %
    if(i<=118)
        Y(i,1)=0;
    else
        Y(i,1)=1;
    end
end
% X(ref:235,:)=X(ref+1:236,:); X(236,:)=[];
% Y(ref:235,:)=Y(ref+1:236,:); Y(236,:)=[];
%feature scaling
for i=1:9
    z=X(:,i);
    xhat(:,i)=(z-mean(z))/std(z);
end
X=xhat;

%Z=[X,Y];
save('X');
save('Y');

end