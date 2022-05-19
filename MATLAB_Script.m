%% DATA PREPROCESSING
% Read each of the four datasets from cleveland, Switzerland, Hungary and
% Long-beach into a table using readtable() function
cleveland = readtable('cleveland.csv');
long_beach_va = readtable('long-beach-va.csv');
hungary = readtable('hungarian.csv');
switzerland = readtable('switzerland.csv');

% Remove the redundant 76th - 89th columns from the cleveland table 
cleveland = cleveland(:, [1:75 90]);

% Copy over the Variable Names from hungary dataset to the cleveland 
% dataset, so it can be concatenated by accessing table properties
varnames = hungary.Properties.VariableNames;
cleveland.Properties.VariableNames = varnames;

% Combine the 4 tables into one using vertical concatenation
combined_dataset = [cleveland; long_beach_va; hungary; switzerland];

%Feature Selection: Extract the 19 Independent Variables
%and the Target Dependent Variable (Diagnosis) from the table 
column_indices =  [3 4 9 10 12:19 31 32 38 40 41 44 51 58];
combined_dataset = combined_dataset(:, column_indices);
combined_dataset = renamevars(combined_dataset, "num", "diagnosis");

%Binarisaton: Convert all non-null values > 1 i.e. 2,3,4 to 1 in the
%dependent variable using logical indexing
idx = combined_dataset.diagnosis > 1;
combined_dataset.diagnosis(idx) = 1;

%Convert the diagnosis dependent variable from numerical to categorical
%attribute using categorical() class
combined_dataset.diagnosis = categorical(combined_dataset.diagnosis);

%Missing Values: Standardize all missing values in the dataseti.e. -9 to NaN
combined_dataset = standardizeMissing(combined_dataset, -9);

%Randomly partition the combined_dataset into a test and training sets
%containing 30% and 70% of the data samples respectively using cvpartition
cv          = cvpartition(combined_dataset.diagnosis,'HoldOut',0.3);
training_set =  combined_dataset(cv.training,:);
test_set  =  combined_dataset(cv.test,:);

%%Frequency Histogram to show distrubtion of data samples for
%%the binary diagnosis attribute in the test and training sets
h = histogram(training_set.diagnosis);
h.FaceColor = 'cyan';
histcounts_training = histcounts(training_set.diagnosis);
title("Frequency Histogram of Diagnosis Attribute for Training Set");
xlabel("Binary Class");
ylabel("Frequency");

h = histogram(test_set.diagnosis);
h.FaceColor = 	'#7E2F8E';
histcounts_test = histcounts(test_set.diagnosis);
title("Frequency Histogram of Diagnosis Attribute for Test Set");
xlabel("Binary Class");
ylabel("Frequency");

%% Build The Random Forest Classifier
%Choose the number of trees 
numTrees = 55;

%Train a random forest classifier using the training set and diagnosis
%column as the target attribute with TreeBagger function. The additional  
random_forest = TreeBagger(numTrees, training_set, "diagnosis", "Method", "classification", 'OOBPrediction', 'on', 'OOBPredictorImportance','on', "NumPredictorsToSample",5);
figure;
bar(categorical(random_forest.PredictorNames), random_forest.OOBPermutedPredictorDeltaError);
title('Predictor Importance Estimates using Random Forest');
ylabel('Estimates');
xlabel('Predictors');
%Plot the no. of out-of-bag samples have been classified incorrectly vs the no. of
%trees grown in the random forest
errorOOB = oobError(random_forest);
plot(errorOOB);
title("Out of Bag Error for Random Forest Classifier");
xlabel 'Number of grown trees';
ylabel 'Out-of-bag classification error';

%% Predict and Evaluate the Classifier
%Extract the first 19 indepenedent variables in the test set which will be
%used as the predictors.
test_set_features = test_set(:,1:19);

%predict the diagnosis of each sample in the test_set using the
%trained random classifier
[prediction,scorer] = random_forest.predict(test_set_features);
prediction = categorical(prediction);

%Compute the Accuracy by comparing the diagnosis values predicted by the model to the actual
%diagnosis values
accuracy = sum(test_set.diagnosis == prediction) / numel(test_set.diagnosis);

%Create a confusion matrix using confusionchart()
confusionchart(test_set.diagnosis, prediction);
title('Confusion Chart using Random Forest Classifier');

%calculate f1-score, precision and recall from the values in the 2x2 confusion
%matrix (TN, TP, FP, FN)
confusion_values = confusionmat(test_set.diagnosis, prediction);
precision = confusion_values(1,1)./(confusion_values(1,1) + confusion_values(1,2));
recall = confusion_values(1,1)./(confusion_values(1,1) + confusion_values(2,1));
f1_score = 2.*confusion_values(1,1)./(2.*confusion_values(1,1) + confusion_values(2,1) + confusion_values(1,2));

%Plot a ROC performance curve and compute the area under the curve for the
%'0'  and '1' categories in the diagnosis class 
[X0,Y0,~,AUC0] = perfcurve(test_set.diagnosis, scorer(:,1), '0');
[X1,Y1,~,AUC1] = perfcurve(test_set.diagnosis, scorer(:,2), '1');
plot(X0,Y0);
hold on;
plot(X1,Y1);
legend((sprintf("Area under curve for '0' class is: %.2f", AUC0)), ...
(sprintf("Area under curve for '1' class is: %.2f", AUC1)), "Location","southeast");
title('ROC for Classification using Random Forest');
xlabel('False Positive rate');
ylabel('True Positive rate');
hold off;

%% Build The Decision Tree Classifier
%Train a k nearest neighbour classifier using the training set and diagnosis
%column as the target attribute with fitcknn function. The additional  
decision_tree = fitctree(training_set, "diagnosis","MaxNumSplits", 100, "SplitCriterion", "gdi", "Surrogate","off" );
%% Predict and Evaluate the Classifier
%Extract the first 19 indepenedent variables in the test set which will be
%used as the predictors.
test_set_features = test_set(:,1:19);

%predict the diagnosis of each sample in the test_set using the
%trained random classifier
[prediction,scorer] = decision_tree.predict(test_set_features);
prediction = categorical(prediction);

%Compute the Accuracy by comparing the diagnosis values predicted by the model to the actual
%diagnosis values
accuracy = sum(test_set.diagnosis == prediction) / numel(test_set.diagnosis);

%Create a confusion matrix using confusionchart()
confusionchart(test_set.diagnosis, prediction);
title('Confusion Chart using Decision Tree Classifier');

%calculate f1-score, precision and recall from the values in the 2x2 confusion
%matrix (TN, TP, FP, FN)
confusion_values = confusionmat(test_set.diagnosis, prediction);
precision = confusion_values(1,1)./(confusion_values(1,1) + confusion_values(1,2));
recall = confusion_values(1,1)./(confusion_values(1,1) + confusion_values(2,1));
f1_score = 2.*confusion_values(1,1)./(2.*confusion_values(1,1) + confusion_values(2,1) + confusion_values(1,2));

%Plot a ROC performance curve and compute the area under the curve for the
%'0'  and '1' categories in the diagnosis class 
[X0,Y0,~,AUC0] = perfcurve(test_set.diagnosis, scorer(:,1), '0');
[X1,Y1,~,AUC1] = perfcurve(test_set.diagnosis, scorer(:,2), '1');
plot(X0,Y0);
hold on;
plot(X1,Y1);
legend((sprintf("Area under curve for '0' class is: %.2f", AUC0)), ...
(sprintf("Area under curve for '1' class is: %.2f", AUC1)), "Location","southeast");
title('ROC for Classification using Decision Tree Classifier');
xlabel('False Positive rate');
ylabel('True Positive rate');
hold off;
