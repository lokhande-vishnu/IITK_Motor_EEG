%function DWT( input )
data_preZ=zeros(1600,9);w=1;   %keep note of data_pre number
for i=1:100
    for j=0:15
        if(j~=15)
            input=data_mat(i,1+256*j:256+256*j);
        else
            input=data_mat(i,3841:4098);
        end
        
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
        
        var_1=sum((cD1-mean(cD1)).^2)/(length(cD1)-1);
        var_2=sum((cD2-mean(cD2)).^2)/(length(cD2)-1);
        var_3=sum((cD3-mean(cD3)).^2)/(length(cD3)-1);
        
        % Sample Mean & Quotient provides maximum local extent of high frequencyvibrations
        M_S1=mean(S1);
        M_S2=mean(S2);
        M_S3=mean(S3);
        data_preZ(w,1)=var_1;
        data_preZ(w,2)=var_2;
        data_preZ(w,3)=var_3;
        data_preZ(w,4)=var_AC4;
        data_preZ(w,5)=var_AC5;
        data_preZ(w,6)=var_AC6;
        data_preZ(w,7)=M_S1;
        data_preZ(w,8)=M_S2;
        data_preZ(w,9)=M_S3;
        
        
        
        %         [C,L] = wavedec(input,4,'db2');          % All wavelet coefficients here and respe.length
        %         A = appcoef(C,L,'db2',4);
        %         [D1,D2,D3,D4] = detcoef(C,L,[1,2,3,4]);
        %         data_preZ(k,1)=max(D1);
        %         data_preZ(k,2)=min(D1);
        %         data_preZ(k,3)=mean(D1);
        %         data_preZ(k,4)=std(D1);
        %
        %         data_preZ(k,5)=max(D2);
        %         data_preZ(k,6)=min(D2);
        %         data_preZ(k,7)=mean(D2);
        %         data_preZ(k,8)=std(D2);
        %
        %         data_preZ(k,9)=max(D3);
        %         data_preZ(k,10)=min(D3);
        %         data_preZ(k,11)=mean(D3);
        %         data_preZ(k,12)=std(D3);
        %
        %         data_preZ(k,13)=max(D4);
        %         data_preZ(k,14)=min(D4);
        %         data_preZ(k,15)=mean(D4);
        %         data_preZ(k,16)=std(D4);
        %
        %         data_preZ(k,17)=max(A);
        %         data_preZ(k,18)=min(A);
        %         data_preZ(k,19)=mean(A);
        %         data_preZ(k,20)=std(A);
        
        w=w+1;
    end
    
end
save('data_preZ');
