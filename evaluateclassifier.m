%This function predicts the diagnosis values for an input test set using 
%the input model. The comparison between the predicted and actual diagnosis
%values are used to produce evaluation measures in which the function will 
% return as a table. The function also will return a scorer which
%can be used to draw the ROC performance curve. 
function [evaluation,scorer] = evaluateclassifier(mdl,test_set,name)

%Extract the first 19 independent variables in the test set which will be
%used as the predictors.
test_set_features = test_set(:,1:19);

%Predict the diagnosis of each sample in the test_set using the input model
[prediction,scorer] = mdl.predict(test_set_features);
prediction = categorical(prediction);

%Compute the accuracy by comparing the diagnosis values predicted by the mdl 
% to the actual diagnosis values for all test samples.
comparison = test_set.diagnosis==prediction;
evaluation.accuracy = sum(comparison)/numel(test_set.diagnosis);

%Create a confusion matrix for the prediction
confusionchart(test_set.diagnosis, prediction);
title(sprintf('Confusion Chart using %s Classifier',name));

%Calculate f1-score, precision and recall from the 2x2 confusion
%matrix containing the TN, TP, FP and FN values
cm = confusionmat(test_set.diagnosis, prediction);
evaluation.precision = cm(1,1)./(cm(1,1) + cm(1,2));
evaluation.recall = cm(1,1)./(cm(1,1) + cm(2,1));
evaluation.f1_score = 2.*cm(1,1)./(2.*cm(1,1) + cm(2,1) + cm(1,2));
end