% Playground file
clc;
clearvars;
close all;

%%%
% files: pXmYdZ where
%     X - number of person
%     Y - type of move
%     Z - index of demonstration
%%%

dataFolder  = './jedi_master_train/';
files       = dir([dataFolder,'*.mat']);
samplesNumber = length(files);
dataStruct  = cell(samplesNumber, 1);
dataClasses = ones(1, samplesNumber);
maxLength   = 0;

% Load data
for i = 1:samplesNumber
    tokens = regexp(files(i).name, 'p(\d+)m(\d+)d(\d+).mat', 'tokens');
    dataClasses(i) = str2double(tokens{1}{2}); 
    moveTrace = load([dataFolder,files(i).name], '-ascii');
    dataStruct{i} = moveTrace;
    maxLength = max(size(moveTrace, 1), maxLength);
end

% Normalize data
timePointDimensions = size(dataStruct{1}, 2);
sampleDimensions = maxLength*timePointDimensions;
data = zeros(sampleDimensions, samplesNumber);
for i = 1:samplesNumber
    l = size(dataStruct{i}, 1);
    sample = zeros(maxLength, timePointDimensions);
    sample(1:l, :) = dataStruct{i};
    data(:, i) = sample(:);
end

% Plotting original and expanded data.
sampleToPlot = randi(samplesNumber);
plot3(dataStruct{sampleToPlot}(:,1), dataStruct{sampleToPlot}(:,2),...
    dataStruct{sampleToPlot}(:,3));
title(sprintf('Sample: %d\nLabel: %d', sampleToPlot,...
    dataClasses(sampleToPlot)));

% Generate training and testing sets.
randomSampleOrder  = randperm(samplesNumber);
trainingSamplesIDs = randomSampleOrder(1:end/2);
testingSamplesIDs  = randomSampleOrder(end/2+1:end);
trainingData = data(:,trainingSamplesIDs);
trainingClasses = dataClasses(trainingSamplesIDs);
testingData = data(:,testingSamplesIDs);
testingClasses = dataClasses(testingSamplesIDs);
testingSize = length(testingClasses);

% Classify with knn.
resultingClasses = knn(trainingClasses, trainingData, testingData, 1);
disp('Error rate, %:');
disp(length(find(resultingClasses ~= testingClasses))/testingSize*100);