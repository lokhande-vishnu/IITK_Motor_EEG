function fea_dwt(cnt,mrk)

%a=zeros(size(cnt,1),118);
%b=zeros(size(cnt,1),118);
a=NaN;b=NaN;
%count1=1; count2=1;
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

X=zeros(236,9); Y=zeros(236,1);
for i=1:236
    
    % using c3 as reference which is at position 52
    %temp=xcorr(pre_rxy2(:,ref),pre_rxy2(:,i));  %finding cross-corrlation
    
    
    %DWT
    if(i<=118)
        input=a(:,i);
    else
        input=b(:,i-118);
    end
    
    %input=pre_rxy2(:,i)';
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