train_set=[data_preF(1:800,:); data_preN(1:800,:); data_preO(1:800,:); data_preS(1:800,:); data_preZ(1:800,:)];
test_set=[data_preF(801:1600,:); data_preN(801:1600,:); data_preO(801:1600,:); data_preS(801:1600,:); data_preZ(801:1600,:)];
a = [1 0 0 0 0]';
b = [0 1 0 0 0]';
c = [0 0 1 0 0]';
d = [0 0 0 1 0]';
e = [0 0 0 0 1]';
% T = [repmat(a,1,800) repmat(b,1,800) repmat(c,1,800) repmat(d,1,800) repmat(e,1,800)];
% inputs = train_set';
% test_inputs=test_set';
% targets = T;

Target = [repmat(a,1,1600) repmat(b,1,1600) repmat(c,1,1600) repmat(d,1,1600) repmat(e,1,1600)];
Input = [data_preF; data_preN; data_preO; data_preS; data_preZ];
Input=Input';

y2=ones(4000,1);ind=ones(4000,1);
    y2(1:800,:)=1;
    y2(800+1:800+800,:)=2;
    y2(800*2+1:800*2+800,:)=3;
    y2(800*3+1:800*3+800,:)=4;
    y2(800*4+1:800*4+800,:)=5;

% Create a Fitting Network
%Number of hidden layes have already been fixed as per the paper. 
%If the number of hidden layers were not mentioned then use a different algorithm 
hiddenLayerSize = 30;
net = fitnet(hiddenLayerSize);


% Setup Division of Data for Training, Validation, Testing
net.divideParam.trainRatio = 100/100;
net.divideParam.valRatio = 0/100;
net.divideParam.testRatio = 0/100;


% Train the Network
[net,tr] = train(net,inputs,targets);

% Test the Network over the test subset
outputs = net(test_inputs);
outputs2=outputs;
outputs2(outputs2>=0)=1;
outputs2(outputs2<0)=-1;

for j=1:4000
    
        hamm(1)= sum(outputs2(:,j)~= a);
        hamm(2)= sum(outputs2(:,j)~= b);
        hamm(3)= sum(outputs2(:,j)~= c);
        hamm(4)= sum(outputs2(:,j)~= d);
        hamm(5)= sum(outputs2(:,j)~= e);
    
    ind(j)=find(hamm==min(hamm),1,'first');
    if(ind(j)== floor((j-1)/800)+1)
        correct(j)=1;
    else
        correct(j)=0;
    end
end

cmat = confusionmat(y2,ind);
acc = 100*sum(diag(cmat))./sum(cmat(:));
fprintf('SVM \naccuracy = %.2f%%\n', acc);
fprintf('Confusion Matrix:\n'), disp(cmat)


%fprintf('accuracy = %d\n',(sum(correct)/4000)*100);

% View the Network
view(net)

% Plots
% Uncomment these lines to enable various plots.
%figure, plotperform(tr)
%figure, plottrainstate(tr)
%figure, plotfit(net,inputs,targets)
%figure, plotregression(targets,outputs)
%figure, ploterrhist(errors)
