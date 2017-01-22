function temp_FV=new_func_FEATURE_EXTRACTION_MODULE(smnorm,fs,FEA_choice)
tic

% FEATURE EXTRACTION
% A) Time domain-------------------------------------------------
if FEA_choice==1 || FEA_choice==286|| FEA_choice==578
   fprintf('Feature Extraction of Time domain features is in progress...\n');
   absmean=sum(abs(smnorm))/length(smnorm);                % Absolute Mean
   maxpeak=max(abs(smnorm));                               % Max Peak
   rms=sqrt((sum(smnorm.^2))/length(smnorm));              % Rms Value
   var=sum((smnorm-mean(smnorm)).^2)/(length(smnorm)-1);   % Variance
   kurt=kurtosis(smnorm);                                  % Kurtosis
   crfac=maxpeak/rms;                                      % Crest Factor
   sf=rms/abs(mean(smnorm));                               % Shape Factor
   skew= skewness(smnorm);                                 % Skewness
   FV_time(1:8) = [absmean maxpeak rms var kurt crfac sf skew];
   clear absmean maxpeak rms var crfac sf skew;
else
   FV_time(1:8) = zeros(1,8);
end


% B) Frequency domain--------------------------------------------
 fprintf('Feature Extraction of Frequency domain features is in progress...\n');
 if FEA_choice==2 || FEA_choice==286|| FEA_choice==578
     H1=fft(smnorm,65536);                % total points (power of 2)
     energy = abs(H1).^2;
     for i=1:8
        HH(i)=sum(energy((4096*(i-1)+1):(4096*i)));
     end
     FV_freq = HH/sum(abs(energy));
     clear H1 HH i energy;
 else
     FV_freq = zeros(1,8);
 end
 
 
% C) Time-Frequency Domain-------------------------------
     if FEA_choice==3 || FEA_choice==286|| FEA_choice==578
%   a. continous wavlet domain  
        fprintf('Feature Extraction of Wavelet features is in progress...\n');
        a=16; b=0.02; b1=0.5;
        for t=1:200
            morl(t)=exp(-b1.^2*(t-b).^2/a.^2)*cos(pi*(t-b)/a);
        end
        morc=conv(smnorm,morl);    % convolve data signal with morlet coefficients
        clear morl t a b;
        FV_cwt(1)=std(morc);          % Standard Deviation
        FV_cwt(2)=entropy(morc);      % Wavelet Entropy
        FV_cwt(3)=kurtosis(morc);     % Kurtosis
        FV_cwt(4)=skewness(morc);     % Skewness
        FV_cwt(5)=std(morc).^2;       % Variance = (STD DEV)^2
        FV_cwt(6)=max(morc)+min(morc);   % Sum of Peaks
        % Calculate Zero crossing rate
        c=0;temp=0;
        if(morc(1)>0) 
            temp=1;
        elseif(morc(1)==0)
            temp=5;
        elseif(morc(1)<0)
            temp=-1;
        end    
        count = 0;
        for i = 2:length(morc)
            if(morc(i)>0)
                count=1;
            elseif(morc(i)==0)
                c=c+1; count=0;
            elseif(morc(i)<0)
                count=-1;
            end
            if((temp+count)==0)
                c=c+1;
                temp=count;
            end
        end
        c=c+rem(c,2);
        FV_cwt(7)=c/2;                % Zero crossing rate
        clear morc i  count temp;

    % b. Discrete Wavelet Transform(DWT)
    input=smnorm;
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
    FV_dwt=[var_1,var_2,var_3, var_AC4,var_AC5,var_AC6, M_S1,M_S2,M_S3];

    clear cA6 cD1 cD2 cD3 cD4 cD5 cD6;
    clear ACF4 ACF5 ACF6 Lags4 Lags5 Lags6; 
    clear var_1 var_2 var_3 var_AC4 var_AC5 var_AC6 M_S1 M_S2 M_S3;
    clear C L m S1 S2 S3;

% c. Wavelet Packet Transform - WPT (Vibration Signal Features)

    % Wavelet Packet Analysis
     input=smnorm;
     level=7;
     wpt=wpdec(input,level,'db4','shannon');
     % plot(wpt)
      
     % computing wavelet packet coefficients of all nodes
     total_node = 2^(level+1)-2;
     packet = cell(1,total_node);
     packet_length = 0;
     wavelet_energy = 0;
      
     for node=1:total_node
     wptcoef = wpcoef(wpt,node);        % Wavelet coefficients of all nodes
     packet{1,node}=wptcoef;
     clear wptcoef;
     end

    % Wavelet Node Energy
    for x=1:total_node
        packet_length(1,x)=length(packet{1,x});
    end
    clear x;
        
    for y=1:total_node
        L=packet_length(1,y);
        s=0;
        node_vec=packet{1,y};
            for z=1:L
                s=s+node_vec(1,z)^2;        
            end
        wavelet_energy(1,y) = s;
        clear L z node_vec s; 
    end

    FV_wpt = wavelet_energy; 
    clear length packet_length packet node total_node wavelet_energy y level 

  else
   FV_cwt(1:7) = zeros(1,7);   % Creating null vector having size as of respective features
   FV_dwt(1:9) = zeros(1,9);
   FV_wpt(1:254) = zeros(1,254);
end
% 

%D)  DCT (Discrete Cosine Transform)-------------------------------
   if FEA_choice==5 ||  FEA_choice==292|| FEA_choice==578 
      fprintf('Feature Extraction using DCT is in progress...\n'); 
      dc = dct(smnorm);       
      points = floor(fs/(8*2));                                % 8 bins & half points are the Mirror image 
      
      for i=1:8
    %     ret(i)=sum(abs(dc((2756*(i-1)+1):(2756*i))));        % Rajat's bin formation step
          ret(i)=sum(abs(dc((points*(i-1)+1):(points*i))));    % bin formation step
      end    
      
      FV_dct = ret/sum(abs(dc));               % single bin energy is divided by total energy
      clear dc ret tot_points points;
      
    else
       FV_dct = zeros(1,8);
    end


%E) Wigner-Ville Distribution-----------------------------------
    if FEA_choice==6 ||  FEA_choice==292|| FEA_choice==578
        fprintf('Feature Extraction using WVD is in progress...\n');
        data_samp = downsample(smnorm,5);         % downsampling of the data
        tf = tfrwv(data_samp');                 % function of WVD has been implemented over the downsampled data  
        n1 = max(tf');                          % max values has been found out from the transformed data  corresponding to every frequency .
        points = floor(fs/(72*2*5));   
    
        for i=1:72
            gf(i) = sum(abs(n1((points*(i-1)+1):(points*i))));    % bins formation step
        end
    
        d2 = gf/sum(abs(n1));                   % single bin energy is divided by total energy
        FV_wvd = d2;
        clear tf n1 gf d2 data_samp points;
    else
        FV_wvd = zeros(1,72);
    end


% F) Autocorrelation----------------------------------------------
    if FEA_choice==7 || FEA_choice==292 || FEA_choice==578
    fprintf('Feature Extraction using Autocorrelation is in progress...\n');
    AC = autocorr(smnorm,length(smnorm)-1);         %autocorrelation function has been apllied 
    var_AC = sum((AC-mean(AC)).^2)/(length(AC)-1);  %variance has been calculated for the above solved autocorrelated array
    FV_autocor = var_AC; 
    clear AC var_AC; 
    
    else
        FV_autocor=0;
    end
       

%G) Updated Morlet Transform---------------------------------
    if FEA_choice==8 ||  FEA_choice==292 || FEA_choice==578
        fprintf('Feature Extraction using MORLET TRANSFORM Sine is in progress...\n');
        a=16; b=0.02; b1=0.5; a1=0.9;
        
        for t=1:200
            umorl(t)=exp(-b1.^2*(t-b).^2/a^2)*(sin(pi*(t-b)/a).^2);   %updated morlet transform function(known as 'umorl' function).        
        end
        
        umorc=conv(smnorm,umorl);   %convolution of data and umorl function has been done
        uvf(1)=std(umorc);          % Standard Deviation
        uvf(2)=entropy(umorc);      % Wavelet Entropy
        uvf(3)=kurtosis(umorc);     % Kurtosis
        uvf(4)=skewness(umorc);     % Skewness
        uvf(5)=std(umorc).^2;       % Variance = (STD DEV)^2
        FV_umorl = uvf;
        clear a b a1 t b1 uvf umorl umorc ;
    else
        FV_umorl=zeros(1,5);
    end


%H) Convolution by sin --------------------------------------------
    if FEA_choice==9 ||  FEA_choice==292 || FEA_choice==578
        fprintf('Feature Extraction using CONVOLUTION SIN is in progress...\n');
        a=20; b=0.05;
        for t=1:200
            sirl(t)=sin(pi*(t-b)/a);                              %transformed sin function
        end
  
        smorc=conv(smnorm,sirl);   % convolution of transformed sine and input data
        sf(1)=std(smorc);          % Standard Deviation
        sf(2)=entropy(smorc);      % Wavelet Entropy
        sf(3)=kurtosis(smorc);     % Kurtosis
        sf(4)=skewness(smorc);     % Skewness
        sf(5)=std(smorc).^2;       % Variance = (STD DEV)^2    
        FV_sine = sf;
        clear a b t sf smorc sirl;
    else
        FV_sine = zeros(1,5);
    end
    
    
%I)Pseudo Wigner-Ville Distribution---------------------------------
    if FEA_choice==10 ||  FEA_choice==292 || FEA_choice==578
        data_samp=downsample(smnorm,5);                % downsampling of the data
        tfrp = tfrpwv(data_samp');                     % function of PWVD has been implemented over the downsampled data 
        m1 = max(tfrp);                              % max values has been found out from the transformed data  corresponding to every frequency .
        points = floor(fs/(72*2*5)); 
 
        for i=1:72
            hf(i)=sum(abs(m1((points*(i-1)+1):(points*i))));       % bins formation step
        end
        
        FV_pwd = hf/sum(abs(m1));
        clear data_samp trfp c2 hf
    else
        FV_pwd = zeros(1,72);
    end

    
%J) S-Transform---------------------------------
    if FEA_choice==11 || FEA_choice==292  || FEA_choice==578
        fprintf('Feature Extraction using S TRANSFORM is in progress...\n');   
        data_samp = downsample(smnorm,5);        % downsampling of the data
        s = st(data_samp');                    % function of S-Tranform has been implemented over the downsampled data 
        s = abs(s);                            
        m2 = max(s');                          % max values has been found out from the transformed data  corresponding to every frequency .         
        
        % Rajat decided with these bins because of better plots
        for i=1:36
            hg(i) = sum(abs(m2((100*(i-1)+1):(100*i))));     % bins formation step
        end
        
        FV_st = hg/sum(abs(m2));                    % single bin energy is divided by total energy
        clear data_samp s m2
    else
        FV_st(1:36) = zeros(1,36);
    end


%K) Choi-William Distribution---------------------------------
 if FEA_choice==12 || FEA_choice==101  || FEA_choice==578
        fprintf('Feature Extraction using Choi-William Distribution is in progress...\n');
        data_samp=downsample(smnorm,10);       % downsampling of the data
        tfcp = tfrcw(data_samp');              % function of CWD has been implemented over the downsampled data 
        tfcp = abs(tfcp); 
        l1 = max(tfcp');                       % max values has been found out from the transformed data  corresponding to every frequency .
        
        for i=1:36
            hcf(i)=sum(abs(l1((100*(i-1)+1):(100*i))));   % bins formation step
        end
        
        FV_cwd = hcf/sum(abs(l1));  % single bin energy is divided by total energy 
        clear cw2 hcf data_samp tfcp l1;
 else
     FV_cwd=zeros(1,36);
 end
 
 
%L) Short Time Fourier Transform---------------------------------
 if FEA_choice==13 || FEA_choice==292  || FEA_choice==578
     fprintf('Feature Extraction using Short Time Fourier Transform is in progress...\n');
        data_samp=downsample(smnorm,5);         % downsampling of the data
        tfsp = tfrstft(data_samp');            % function of STFT has been implemented over the downsampled data
        tfsp = abs(tfsp);
        ls1 = max(tfsp');                      % max values has been found out from the transformed data  corresponding to every frequency 
        points = floor(fs/(72*2*5)); 
        
        for i=1:72
            hsf(i)=sum(abs(ls1((points*(i-1)+1):(points*i))));         % bin formation step
        end
        
        FV_swd = hsf/sum(abs(ls1)); % single bin energy is divided by total energy
        clear data_samp tfsp ls1 hsf;
 else
     FV_swd(1:72)= zeros(1,72);
 end

 
%M) Born jordan Distribution---------------------------------
 if FEA_choice==14  || FEA_choice==292  || FEA_choice==578
     fprintf('Feature Extraction using Born jordan Distribution is in progress...\n');
     data_samp = downsample(smnorm,10);            % downsampling of the data
     tfbp = tfrbj(data_samp');                   % function of Born-Jordan Distribution has been implemented over the downsampled data
     lb1 = max(tfbp');                          % max values has been found out from the transformed data  corresponding to every frequency
     points = floor(length(lb1)/(2*36));
     
     for i=1:36
         hbf(i) = sum(abs(lb1((points*(i-1)+1):(points*i))));      % bin formation step
     end
     
     FV_bwd = hbf/sum(abs(lb1));
  
 else
     FV_bwd(1:36)=zeros(1,36);
 end
% --------------------------------------------------------------

temp_FV=[FV_time,FV_freq,FV_cwt,FV_dwt,FV_wpt,FV_dct,FV_wvd,FV_autocor,FV_umorl,FV_sine,FV_pwd,FV_st,FV_cwd,FV_swd,FV_bwd];   % argument to be returned.
clear FV_time FV_freq FV_cwt FV_dwt FV_wpt FV_dct FV_wvd FV_autocor FV_umorl FV_sine FV_pwd FV_st FV_cwd FV_swd FV_bwd
toc;
end