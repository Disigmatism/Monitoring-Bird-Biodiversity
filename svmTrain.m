function [svmModel] = svmTrain(trainBirds,type)
%     N = size(trainMatrix,2);

    trainBCIDs = [trainBirds.BirdCodeID];
    if(type == "Features")
        trainMatrix = [trainBirds.Features];
    end
    if(type == "Spectograms")
        trainMatrix = [trainBirds.Spectogram];

    end
    svmModel = cell(1,6);
    svmTrainData = trainMatrix';

    rng(1);
    Y = trainBCIDs;
    classes = unique(Y);
    for j = 1:numel(classes)
        index = (Y == classes(j));
        svmModel{j} = fitcsvm(svmTrainData,index,"ClassNames",[false true],...
            "Standardize",true);%,"KernelFunction","rbf","BoxConstraint",1)
    end
end