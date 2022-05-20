% Read each of the four datasets from cleveland, Switzerland, Hungary and
% Long-beach into memory
cleveland = readtable('cleveland.csv');
long_beach_va = readtable('long-beach-va.csv');
hungary = readtable('hungarian.csv');
switzerland = readtable('switzerland.csv');

% Remove the redundant 76th - 89th columns from the cleveland table 
cleveland = cleveland(:,[1:75 90]);

% Copy over the variable names from the hungary dataset to the cleveland 
% dataset, so it can be concatenated by accessing table properties
var_names = hungary.Properties.VariableNames;
cleveland.Properties.VariableNames = var_names;

% Combine the four tables into one using vertical concatenation
combined_dataset = [cleveland; long_beach_va; hungary; switzerland];

%Extract the nineteen independent variables
%and the target dependent variable from the table. Rename the dependent 
%variable to "diagnosis"  
column_indices =  [3 4 9 10 12:19 31 32 38 40 41 44 51 58];
combined_dataset = combined_dataset(:, column_indices);
combined_dataset = renamevars(combined_dataset, "num", "diagnosis");

%Convert all the values in the diagnosis attribute that are bigger than 1
% such as values "2" "3" and 4" to 1, to binarise the attribute
idx = combined_dataset.diagnosis > 1;
combined_dataset.diagnosis(idx) = 1;

%Convert the diagnosis dependent variable from numerical to categorical
%attribute using categorical() class
combined_dataset.diagnosis = categorical(combined_dataset.diagnosis);

%Standardize all missing values in the dataset from "-9" to "NaN"
combined_dataset = standardizeMissing(combined_dataset,-9);

%Randomly partition the combined_dataset into a test and a training set
%containing 30% and 70% of the data samples respectively
cv          = cvpartition(combined_dataset.diagnosis,'HoldOut',0.3);
training_set =  combined_dataset(cv.training,:);
test_set  =  combined_dataset(cv.test,:);

%Plot a frequency histogram to show the distrubtion of data samples for
%the binary diagnosis attribute in the test and training sets
h_train = histogram(training_set.diagnosis);
h_train.FaceColor = 'cyan';
histcounts_training = histcounts(training_set.diagnosis);
title("Frequency Histogram of Diagnosis Attribute for Training Set");
xlabel("Heart Disease Diagnosis");
ylabel("Frequency");

h_test = histogram(test_set.diagnosis);
h_test.FaceColor = '#7E2F8E';
histcounts_test = histcounts(test_set.diagnosis);
title("Frequency Histogram of Diagnosis Attribute for Test Set");
xlabel("Heart Disease Diagnosis");
ylabel("Frequency");

%Choose the number of trees and the numbers of predictors for each tree.
ntrees = 55;
npredictors = 5;

%Train a random forest classifier using the training set and diagnosis
%column as the target class attribute.  
rf = TreeBagger(ntrees, training_set,"diagnosis","Method", ...
    "classification",'OOBPrediction','on','OOBPredictorImportance','on', ...
    "NumPredictorsToSample",npredictors);

%Plot the estimated importance of each indepdent variable in a bar graph 
%and export the values in a csv file. 
predictor_importance = table(categorical(rf.PredictorNames'), ...
    rf.OOBPermutedPredictorDeltaError');
writetable(predictor_importance,'predictor_importance.csv');
bar(categorical(rf.PredictorNames), ...
    rf.OOBPermutedPredictorDeltaError);
title('Predictor Importance Estimates using Random Forest');
ylabel('Estimates');
xlabel('Predictors');

%Plot the out-of-bag error vs the no. of trees grown for random forest
errorOOB = oobError(rf);
plot(errorOOB);
title("Out of Bag Error for Random Forest Classifier");
xlabel 'Number of grown trees';
ylabel 'Out-of-bag classification error';

%Predict diagnosis for test samples and evaluate the result using rf
%Draw a ROC Performance Curve for the diagnosis class probabilites
[rf_evaluation,rf_scorer]= evaluateclassifier(rf,test_set,"Random Forest");
rocperformance(rf_scorer,test_set,"Random Forest");

%Train a decision tree model using the training set and diagnosis
%column as the target class attribute. 
dt = fitctree(training_set,"diagnosis","MaxNumSplits", 100, ...
    "SplitCriterion","gdi","Surrogate","off");

%Predict diagnosis for test samples and evaluate the result using dt
%Draw a ROC Performance Curve for the diagnosis class probabilites
[dt_evaluation,dt_scorer] = evaluateclassifier(dt,test_set,"Decision Tree");
rocperformance(dt_scorer, test_set,"Decision Tree");
