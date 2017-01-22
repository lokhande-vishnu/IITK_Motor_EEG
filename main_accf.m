function main_accf(brej_healthy,brej_faulty,dataset,maxreject)

feature=size(brej_healthy,2);           % feature_old=number of features
datawidth=size(brej_healthy,1)/dataset; % datawidth_old=number of samples in 1 dataset


% brej_healthy=healthy data
% brej_faulty=faulty data
% dataset=number of datasets
% maxreject=maximun number of datasets that can be rejected

%this program uses 4 threshold values which can be changed by the user
thresh_zcr=0;           %threshold value for zcr
thresh_separation=10;   %threshold value for sepation
thresh_ratio=2;       %threshold value for ratio of means
thresh_std=2;         %threshold value for standard deviation of means of datasets
%In order to looosen the thresholds,the user is advised to change the...
%...threshold values from bottom to top i.e., do for std then move to zcr

score=ones(1,feature);dataset_counter=zeros(1,dataset);
healthy=brej_healthy;faulty=brej_faulty;
rejected_datasets=0;

% score array maintains which features are to be passed
% ...for selected features score is 1 and for the rejected ones it is 0

for p=maxreject:-1:1
    %this function finds which dataset has to be rejected(if at all)
    
    k=rej_func(healthy,faulty,feature,datawidth,dataset,thresh_zcr,thresh_separation,thresh_ratio,thresh_std);
    % k is the dataset that is to be rejected.It is 0 if no dataset is found as bad 
    if(k~=0)
        if(rejected_datasets==0)
            dataset_counter(1,k)=1;
        fprintf('Dataset rejected = %d\n',k);
        else
            fprintf('Dataset rejected = %d\n',datasetfind(dataset_counter,k,dataset_old));
            dataset_counter(datasetfind(dataset_counter,k,dataset_old))=1;
        end
        
        % the above code finds what is the value of the rejected dataset relative
        % ...to the "before rejection" data since the value of the rejected
        % ...dataset is to be printed relative to the "brej" data. the
        % ...function "datasetfind" helps in this
        
        rejected_datasets=rejected_datasets+1;
    else
        fprintf('No Dataset rejected\n');
    end
    if(k==0)
        break;
    end
    
    %if k is non zero,then some dataset has to be rejected.The removal of that particular dataset is below
    
    if(k~=0)
        healthy=remove_dataset(healthy,dataset,datawidth,feature,k);
        faulty=remove_dataset(faulty,dataset,datawidth,feature,k);
        dataset=dataset-1;        
    end
    
    % the remove_dataset function removes the dataset numbered "k" from the
    % ...data passed to it.
    
end
    score=feature_select(healthy,faulty,dataset,thresh_zcr,thresh_separation,thresh_ratio,thresh_std,score);
    
    % after all the rejections are made the above function feature_select
    % ...filters the bad features and the code below sorts "score" and
    % ...prints the good features

for i=1:feature;
    if(score(i)~=0)
        fprintf('feature%d\n',i);
    end
end

    % the plot_vib function below plots
    % ...them. The data passed to the plotting function shall be the
    % ..."before rejection" data and not the modifyed one. 
    
    plot_acc(brej_healthy,brej_faulty,feature,dataset+rejected_datasets,datawidth,score)

end
