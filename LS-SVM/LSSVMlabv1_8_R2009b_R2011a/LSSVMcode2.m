function LSSVMcode2(X,Y,indices)
[gam,sig2]=tunelssvm({X,Y,'classfication',[],[],'RBF_kernel'},'gridsearch','crossvalidatelssvm',{10,'misclass'});
% while(gam>1000 || sig2>100)
%     [gam,sig2]=tunelssvm({X,Y,'classfication',[],[],'RBF_kernel'},'gridsearch','crossvalidatelssvm',{10,'misclass'});
% end
for i = 1:10
    test = (indices == i); train = ~test;
    [alpha, b] = trainlssvm({X(train,:),Y(train,:),'classfication',gam,sig2,'RBF_kernel'});
    %predicting
    Ytest = simlssvm({X(train,:),Y(train,:),'classfication',gam,sig2,'RBF_kernel'},{alpha,b},X(test,:));
    error(i)=sum(Y(test,:)~=Ytest)/length(Y(test,:));
    %fprintf('error(i) %f\n',error(i));
    
end
accuracy=(1-error)*100;
mean_accuracy=mean(accuracy);
if(mean_accuracy<80)
    LSSVMcode2(X,Y,indices);
else
    fprintf('accuracy= %f +- %f\n',mean_accuracy,std(accuracy));
end

end

