function TEMKLR( X,y )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


%y(y==-1)=0;
indices = crossvalind('Kfold',y,10);


for i = 1:10
    test = (indices == i); train = ~test;
    
    nClasses=2;
    nInstances=size(X(train,:),1);
    nVars=6;
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
    fprintf('>>>>>>>>>>>>>yhat  %f\n',yhat);
    
    %[junk, yhat] = max(Krbf*uRBF,[],2);
    error(i)=sum(y(test)~=yhat)/length(y(test));
    fprintf('>>>>>>>>>>>>>error  %f\n',error(i));

% rbfScale = 1;
% Krbf = kernelRBF(X,X,rbfScale);
% funObj = @(u)SoftmaxLoss2(u,Krbf,y,nClasses);
% fprintf('Training kernel(rbf) multinomial logistic regression model...\n');
% uRBF = minFunc(@penalizedL2,randn(nInstances*(nClasses-1),1),options,funObj,lambda);
% %uRBF = minFunc(@penalizedKernelL2_matrix,randn(nInstances*(nClasses-1),1),options,Krbf,nClasses-1,funObj,lambda);
% uRBF = reshape(uRBF,[nInstances nClasses-1]);
% uRBF = [uRBF zeros(nInstances,1)];
%fprintf('>>>>>>>>>>>>> %d ....uRBF  %f\n',i,uRBF);
end
accuracy=(1-error)*100;
fprintf('accuracy= %f +- %f\n',mean(accuracy),std(accuracy));

end




