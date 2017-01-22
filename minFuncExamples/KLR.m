function KLR( X,y,indices )
cd minFunc;
addpath(genpath(pwd));
cd ..;
cd lossFuncs;
addpath(genpath(pwd));
cd ..;
cd misc;
addpath(genpath(pwd));
cd ..;
mexAll;

% indices = crossvalind('Kfold',y,10);
% 
% xhat=X; 
% for i=1:6
% 
% z=X(:,i);
% xhat(:,i)=(z-mean(z))/std(z);
% end
%X=xhat;
y(y==0)=-1;
for i = 1:10
    test = (indices == i); train = ~test;
    
    nClasses=2;
    nInstances=size(X(train,:),1);
    nVars=size(X(train,:),2);
    options.Method = 'newton0';
    options.Display = 'none';
    lambda = 1e-2;
    
    %training using train sample examples
    rbfScale = 1;
    Krbf = kernelRBF(X(train,:),X(train,:),rbfScale);
    funObj = @(u)LogisticLoss(u,Krbf,y(train,:));
    fprintf('Training kernel(rbf) logistic regression model...\n');
    uRBF = minFunc(@penalizedKernelL2,zeros(nInstances,1),options,Krbf,funObj,lambda);
    
    %testing using test samples
    Krbf2 = kernelRBF(X(train,:),X(test,:),rbfScale);
    yhat=sign(Krbf2'*uRBF);
    %fprintf('>>>>>>>>>>>>>yhat  %f\n',yhat);
    
    %[junk, yhat] = max(Krbf*uRBF,[],2);
    error(i)=sum(y(test)~=yhat)/length(y(test));
    fprintf('>>>>>>>>>>>>>error  %f\n',error(i));
    
end
%for testing create a new Krbf2

accuracy=(1-error)*100;
fprintf('accuracy= %f +- %f\n',mean(accuracy),std(accuracy));

end

