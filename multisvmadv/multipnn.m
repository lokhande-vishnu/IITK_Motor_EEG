train_set=[data_preF(1:800,:); data_preN(1:800,:); data_preO(1:800,:); data_preS(1:800,:); data_preZ(1:800,:)];
test_set=[data_preF(801:1600,:); data_preN(801:1600,:); data_preO(801:1600,:); data_preS(801:1600,:); data_preZ(801:1600,:)];


Tc=ones(4000,1);
Tc(801:1600)=2*Tc(801:1600);
Tc(1601:2400)=3*Tc(1601:2400);
Tc(2401:3200)=4*Tc(2401:3200);
Tc(3201:4000)=5*Tc(3201:4000);

T = ind2vec(Tc');
net=newpnn(train_set',T,0.05);
 Y = sim(net,test_set');
Yc = vec2ind(Y);

cmat = confusionmat(Tc,Yc');
acc = 100*sum(diag(cmat))./sum(cmat(:));
fprintf('SVM \naccuracy = %.2f%%\n', acc);
fprintf('Confusion Matrix:\n'), disp(cmat)


% perf = perform(net,Tc',Yc)
% result=sum(Tc'~=Yc)/4000;
% disp((1-result)*100);