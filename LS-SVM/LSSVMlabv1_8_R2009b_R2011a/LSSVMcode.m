function LSSVMcode( X,Y )
[gam,sig2]=tunelssvm({X,Y,'classfication',[],[],'RBF_kernel'},'gridsearch','crossvalidatelssvm',{10,'misclass'});
%fprintf('gam- %f sig -%f\n',gam,sig2);

[alpha, b] = trainlssvm({X,Y,'classfication',gam,sig2,'RBF_kernel'});

%fprintf('alpha- %f b -%f\n',alpha,b);
[cost, costs] = crossvalidate({X,Y,'classfication',gam,sig2,'RBF_kernel'},10, 'misclass', 'mean');
%disp(costs);
%fprintf('cost- %f \n',cost);
fprintf('accuracy %f +- %f\n',(1-cost)*100,std((1-costs)*100));


% %predicting
% Ytest = simlssvm({X,Y,'classfication',gam,sig2,'RBF_kernel'},{alpha,b},X);

%plotting
plotlssvm({X,Y,'classfication',gam,sig2,'RBF_kernel'},{alpha,b},500,[1 2 3 4 5 6]);
end

