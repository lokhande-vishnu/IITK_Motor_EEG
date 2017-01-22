train_set=[data_preF(1:800,:); data_preN(1:800,:); data_preO(1:800,:); data_preS(1:800,:); data_preZ(1:800,:)];
test_set=[data_preF(801:1600,:); data_preN(801:1600,:); data_preO(801:1600,:); data_preS(801:1600,:); data_preZ(801:1600,:)];

matrix=[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1;0 0 0 0 0 0 0 0 1 1 1 1 1 1 1; 0 0 0 0 1 1 1 1 0 0 0 0 1 1 1; 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1; 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0];

for i=1:15
    y=ones(4000,1);
    y(1:800,:)=matrix(1,i);
    y(800+1:800+800,:)=matrix(2,i);
    y(800*2+1:800*2+800,:)=matrix(3,i);
    y(800*3+1:800*3+800,:)=matrix(4,i);
    y(800*4+1:800*4+800,:)=matrix(5,i);
    options = optimset('maxiter', 2500, 'largescale','off'); %options settings for SVMTRAIN
    fea(i)=svmtrain(test_set,y,'boxconstraint',80,'kernel_function','rbf','method','QP','rbf_sigma',0.3,'quadprog_opts', options);
    
end

save('fea');


%testing 
for j=1:4000
    for k=1:15
        vector(k)=svmclassify(fea(k),test_set(j,:));
    end
    for k=1:5
        hamm(k)= sum(vector~=matrix(k,:));
    end
    ind=find(hamm==min(hamm));
    if(ind== floor((j-1)/800)+1)
        correct(j)=1;
    else
        correct(j)=0;
    end
end

save('correct');
fprintf('accuracy = %d\n',(sum(correct)*100)/4000);