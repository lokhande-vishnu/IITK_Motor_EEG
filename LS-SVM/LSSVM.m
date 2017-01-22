function LSSVMcode( X,Y )
[gam,sig2]=tunelssvm({X,Y,'classfication',[],[],'RBF_kernel'},'gridsearch','crossvalidatelssvm',{10,'misclass'});

[alpha, b] = trainlssvm({X,Y,'classfication',gam,sig2,'RBF_kernel'});


[cost, costs] = crossvalidate({X,Y,'classfication',gam,sig2,'RBF_kernel'},L, 'misclass', 'mean');



sprintf('%f +- %f',(1-cost)*100,std((1-costs)*100));

end

