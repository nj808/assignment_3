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
