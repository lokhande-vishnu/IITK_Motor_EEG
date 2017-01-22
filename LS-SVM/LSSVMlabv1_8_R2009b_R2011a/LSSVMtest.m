function LSSVMtest( X,Y,indices )
% [gam,sig2]=tunelssvm({X,Y,'classfication',[],[],'RBF_kernel'},'gridsearch','crossvalidatelssvm',{10,'misclass'});
% while(gam>10000 || sig2>1000)
%     [gam,sig2]=tunelssvm({X,Y,'classfication',[],[],'RBF_kernel'},'gridsearch','crossvalidatelssvm',{10,'misclass'});
% end
for i = 1:10
    test = (indices == i); train = ~test;
    [alpha, b] = trainlssvm({X(train,:),Y(train,:),'classfication',1.5005,1.4236,'RBF_kernel'});
    %predicting
    Ytest = simlssvm({X(train,:),Y(train,:),'classfication',1.5005,1.4236,'RBF_kernel'},{alpha,b},X(test,:));
    error(i)=sum(Y(test,:)~=Ytest)/length(Y(test,:));
    %fprintf('error(i) %f\n',error(i));
end
accuracy=(1-error)*100;
fprintf('accuracy= %f +- %f\n',mean(accuracy),std(accuracy));
end

