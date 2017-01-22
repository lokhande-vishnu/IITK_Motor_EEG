function LR( X,y,indices)
%y(y==-1)=0;
%X=[ones(size(X,1),1) X];
disp(size(X,2));
%indices = crossvalind('Kfold',y,10);
for i = 1:10
    test = (indices == i); train = ~test;
    b = glmfit(X(train,:),y(train),'binomial','logit');
    y_hat= glmval(b,X(test,:),'logit');
    y_hat2(y_hat>=0.5)=1;  y_hat2(y_hat<0.5)=0;
    y_true=y(test,:);
    error(i)=mean(abs(y_true-y_hat2'));
    y_hat2=NaN;
end
%testing using glmval
accuracy=(1-error)*100;
fprintf('accuracy= %f +- %f\n',mean(accuracy),std(accuracy));
end

