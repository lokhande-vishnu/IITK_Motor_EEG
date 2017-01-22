clear all
warning off MATLAB:fzero:UndeterminedSyntax

filenames=['figa.d'; 'figb.d'; 'figc.d'];
filenamesmse=['figamse.d'; 'figbmse.d'; 'figcmse.d'];
filenames1=['figa.eps'; 'figb.eps'; 'figc.eps'];
filenames2=['figamse.eps'; 'figbmse.eps'; 'figcmse.eps'];

numsim=500;
%numsim=1;
logkrange=2:1:6;
% logkrange=2:1:2;
krange=ceil(2.^logkrange);
s = 1.5;
epsilon=1.0e-7;
randfact=0.1;
mu=0.001;

for f=1:3,
  fid = fopen(filenames(f,:),'w');
  fidmse = fopen(filenamesmse(f,:),'w');
  fprintf(fid,'  \n');


  total=[];
  msetotal=[];
  p=[];
  for k=krange,
    if f==1,
      p(1,1) = s/k;
      p(2:k,1) = (1-s/k)/(k-1);
    elseif f==2,
      a = ceil(k/2);
      p(1,1) = 0.95 * s/a;
      p(2:a,1) = (0.95-p(1,1))/(a-1);
      p(a+1:k,1) = (0.05)/(k-a);
    elseif f==3,
      p(1,1) = 0.95 * s/2;
      p(2,1) = 0.95 -p(1,1);
      p(3:k,1) = (0.05)/(k-2);
    end

    accuracy=[]; mse=[];

    % for halfhalf
    maxrho=0;
    for t=1:100,
      Ip1=[];
      for i =1:round(10*log2(k))
	rp=randperm(k);
	ip=zeros(1,k); ip(rp(1:floor(k/2)))=1;
	Ip1=[Ip1; ip];
      end
      PandN=logical(Ip1); PandN=PandN-~PandN;
      PandN=PandN'*PandN; PandN=PandN-diag(diag(PandN));
      rho=min(min(size(Ip1,1)-PandN));
      if (rho > maxrho)
	Ip=Ip1;
      end
    end
    Ipsym=[Ip; ~Ip; eye(k)]; Ipsym=logical(Ipsym);
    Ip=logical([Ip; eye(k)]); 
    
    
    % the approach in ZB01a
    maxrho=0;
    for t=1:100,
      IpZB=[]; InZB=[];IZB=[]; rZB=[]; 
      for i =1:round(15*log2(k))
	while (1)
	  rp=rand(1,k);
	  if (sum(p(rp>=0.75)) >0 & sum(p(rp<=0.25))>0)
	    break;
	  end
	end
	IpZB=[IpZB; rp>=0.75]; 	InZB=[InZB; rp<=0.25]; 
	IZB=[IZB; rp>=0.75 | rp <=0.25];
      end
      PandN=IpZB-InZB;
      PandN=PandN'*PandN; PandN=PandN-diag(diag(PandN));
      rho=min(min(size(IpZB,1)-PandN));
      if (rho > maxrho)
	IpZBm=IpZB; InZBm=InZB; IZBm=IZB; rZBm=rZB;
      end
    end
    IpZBsym=[IpZBm; InZBm]; IZBsym=[IZB; IZB];

    for iter=1:numsim
      r1vs1=zeros(k,k);
      for i =1:k
	r1vs1(i,i+1:k) = p(i) ./ (p(i)+p(i+1:k,1)');
      end
      r1vs1=triu(min(max(epsilon,r1vs1.*(1+randfact*randn(k,k))),1-epsilon));
      r1vs1=r1vs1+tril(1-r1vs1')-diag(diag(1-r1vs1'));

      % half
      tmp=repmat(p',size(Ip,1),1);
      rhalf=sum(tmp.*Ip,2);
      rhalf=rhalf(1:size(rhalf,1)-k);
      rhalf = min(max(epsilon,rhalf.*(1+randfact*randn(size(rhalf,1),1))),1-epsilon);
      rhalfsym=[rhalf; 1-rhalf; mu*ones(k,1)];
      rhalf=[rhalf; mu*ones(k,1)];

      % r for ZB01a
      tmp=repmat(p',size(IZBm,1),1); % remove the last segment
      rZBm=sum(tmp.*IpZBm,2)./sum(tmp.*IZBm,2);
      rZBm=min(max(epsilon,rZBm.*(1+randfact*randn(size(rZBm,1),1))),1-epsilon);
      rZBsym=[rZBm; 1-rZBm];
      
      r1vsall=min(max(epsilon,p.*(1+randfact*randn(k,1))),1-epsilon); ...     
% $$$       generalprob2([rZBsym;mu*ones(k,1)],logical([IpZBsym; ...
% $$$ 		    eye(k)]),logical([IZBsym;ones(k,k)]));
      result = [pairwise(r1vs1)  onevsalliter(r1vsall) ...
		halfhalf(k,rhalfsym,Ipsym) ...
		generalprob([rZBsym;mu*ones(k,1)],logical([IpZBsym; ...
		    eye(k)]),logical([IZBsym;ones(k,k)])) ...	       
%		halfhalfZB(k,rhalfsym,Ipsym) ...
%		generalprobZB([rZBsym;mu*ones(k,1)],logical([IpZBsym; ...
%		    eye(k)]),logical([IZBsym;ones(k,k)])) ...	       
	       ]; 
%		generalprob(rhalfsym,Ipsym,logical(ones(size(Ipsym)))) ...
%		generalprobZB(rhalfsym,Ipsym,logical(ones(size(Ipsym)))) ...
%               onevsallpos(r1vsall) ...
%               halfhalf(k,rhalf,Ip) ...		
%		generalprob([rZBm;mu*ones(k,1)],logical([IpZBm;eye(k)]), logical([IZBm;ones(k,k)])), 
      
      
      
%      [sort(result(:,2)) sort(result(:,3))]
      pp=repmat(p,1,size(result,2));
      tmp=([result]-pp);
      mse=[mse; sum(tmp.*tmp,1)./sum(pp.*pp,1)];
      accuracy=[accuracy; max(result(2:k,:),[],1) < result(1,:)];
    end
    total=[total; sum(accuracy,1)/numsim];
    msetotal=[msetotal; mean(mse,1)];
  end

  total
  msetotal
  fprintf(fid,'%5.4f %5.4f %5.4f %5.4f %5.4f %5.4f\n', total');
  fprintf(fidmse,'%5.4f %5.4f %5.4f %5.4f %5.4f %5.4f\n', msetotal');

  figure(f+3)
  plot(...
      logkrange, msetotal(:,1), 'k--s',...	%1vs1
      logkrange, msetotal(:,2), 'k-x',...	%1vsall_s
      logkrange, msetotal(:,3), 'k:o',...	%1vsall_ns
      logkrange, msetotal(:,4), 'k-.d'); 	%random
%      logkrange, msetotal(:,5), 'k-.d'); ,...	%half_s
%      logkrange, msetotal(:,6), 'k--^');        %half_ns  
%      logkrange, msetotal(:,7), 'k--d');	%prod      
  set(gca, 'fontsize', 18) ; 
  set(findobj('Type', 'line'), 'markersize', 12)  
  set(findobj('Type', 'line'), 'LineWidth', 3)  
  xlabel('log_2 k');
  ylabel('MSE');
  print('-deps',filenames2(f,:))

  figure(f);
  plot(...
      logkrange, total(:,1), 'k--s',...	%1vs1	   
      logkrange, total(:,2), 'k-x',...	%1vsall_s  
      logkrange, total(:,3), 'k:o',...	%1vsall_ns 
      logkrange, total(:,4), 'k-.d');	%random	   
%      logkrange, total(:,5), 'k-.d'); ,...	%half_s	   
%      logkrange, total(:,6), 'k--^')	%half_ns   
%      logkrange, total(:,7), 'k--d');	%prod      
  fclose(fid);
  %axis([logkrange(1) logkrange(size(logkrange,2)) 0.6 1.05]);
  set(gca, 'fontsize', 18) ; 
  set(findobj('Type', 'line'), 'markersize', 12)  
  set(findobj('Type', 'line'), 'LineWidth', 3)  
  xlabel('log_2 k');
  ylabel('Test error');
%  title(strcat('P(Class 1)=',num2str(s),'/K'))
  print('-deps',filenames1(f,:))
end

