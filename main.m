% ========================== Description ============================ 
% 
% Author: Dhruva Kumar
% 
% For testing, please run only the last section !
%
% - Training data processing:
%       - Pitch contours are extracted from the mp3 files in the 'train' dir 
%       - It's quantized to the nearest chromatic scale pitch
%       - It's normalized based on the tonic frequency provided in 
%         'models/GTraagDB.csv'
%       - The result is stored in 'models/data'
%       - It consists of 5 raag classes and 3 sequences in each
% - Learning:
%       - Baum welch is applied to learn the model based on the qunatized
%       pitch vectors for different raag classes. 
%       - Parameters used: N = 36 | M = 36 | fully connected structure
%       - convergence criteria: difference of log likelihood of 
%           P(O|lambda) < 0.1
%       - Model saved in 'models/model.mat'
% - Testing: 
%       - The forward backward procedure is applied to test each test
%       sequence in the directory 'test' based on the model generated. 
%       - Results and confusion matrix is generated
%
% :: Vectorization:
%       - Unvectorized Baum welch for 5 sequences & for 1 iteration
%        4.514 seconds
%       - Vectorized Baum welch for 5 sequences & for 1 iteration
%       0.86 seconds
%
% ===================================================================

% please change the absolute path accordingly!
addpath(genpath('/home/dhruva/Documents/Learning in Robotics/6-Raag'));

%% Data preprocessing
% - convert .mp3 -> .txt [time, pitch] 
% - save all .txt in .mat
% - quantize pitch frequencies
% - shift relative to tonic frequency
% - data: [raag, pitch, pitch_quant]

% dataProcessing
load models/data

%% Learning the model{pi,A,B}: EM Baum Welch 

model = struct('raag', {}, 'pi', {}, 'A', {}, 'B', {}, ...
        'costFunction', {});
    
fprintf ('Learning model... \n');
for c = 1:length(data)
    model(c).raag = data(c).raag;
    fprintf('Raag %d: %s \n',c, model(c).raag);
    
    % init model {pi_prev, A_prev, B_prev}
    % fully connected model
    N = 36; M = 36;
    pi_prev = 1/N * ones(N,1);
    A_prev = rand(N,N); 
    A_prev = A_prev ./ repmat(sum(A_prev), N,1); % normalize
    B_prev = rand(M,N); 
    B_prev = B_prev ./ repmat(sum(B_prev), M,1); % normalize
    
    % init
    log_p_prev = 1;
    costFunc = zeros(50,1);
    O_multiple = data(c).pitch_quant; % {Lx1}
    
    iter = 200;
    for i = 1:iter
        % E step: forward backward
        [alpha, beta, c_alpha_multiple, log_p] = ...
            hmm_fb_multiple(pi_prev, A_prev, B_prev, O_multiple);
        % M step: update step
        [pi, A, B] = hmm_update_multiple (alpha, beta, c_alpha_multiple,...
                                            O_multiple, A_prev, B_prev);
    
        % convergence: max (log_p_O_model) 
        costFunc(i) = log_p;
        changeLog2 = abs(log_p - log_p_prev) / (1+abs(log_p_prev));
        changeLog = abs(log_p - log_p_prev);
        fprintf('Iteration %d: %f | changeLog: %f | changeLog2: %f \n', ...
            i, log_p, changeLog, changeLog2);

        if (changeLog < 0.1)
            % use the previous values
            pi = pi_prev;
            A = A_prev;
            B = B_prev;
            break;
        end
        log_p_prev = log_p;
        pi_prev = pi;
        A_prev = A;
        B_prev = B;
    end % em iteration
    
    % update model
    model(c).pi = pi;
    model(c).A = A;
    model(c).B = B;
    model(c).costFunction = costFunc;
    
    fprintf('---------------------------------------------\n');
end % raag /class
    
save ('models/model.mat', 'model');
    
    
%% test 

% 1. bihag | 2. darbari | 3. desh | 4. gMalhar | 5. yaman
% 00  : 1 2 4 1 2 3 5   1 1 2 2 3 3 5 5 2 3 4 3
% 36  : 4 4 4 4 4 4 4   1 1 2 2 4 4 5 5 4 4 4 3 | 9 v(1/3) i(8/9)
% 36  : 5 2 3 5 2 3 5   4 3   4 3 3 4 1 1 1 3 4
% 36  : 1 3 5 1 3 5 3   5 4   3 2 2 3 3 3 3 1 5 |    v(6) i(3)

% vocal = v | instrument = i
%        v v v  i i i i i i i i i i     v   i i
% true0: 4 2 3  1 1 2 2 5 5 3 4 3 2     4   4 5
% test1: 4 4 4  1 1 2 2 5 5 4 4 3 2     4   4 5
% test2: 3 2 3  4 3 4 4 4 1 1 3 4 4     3   3 4
% test3: 5 3 5  5 4 3 3 3 3 3 1 5 3     2   1 3

% results: 81.25% || 13/16 || v: 2/4 || i: 11/12 
% within 2nd or 3rd gets all correct
addpath(genpath('/home/dhruva/Documents/Learning in Robotics/6-Raag'));

true = [4 2 3 1 1 2 2 5 5 3 4 3 2 4 4 5]; 

% load models
load models/model;

% load pitch-freq mapping
load models/pitch_freq;
pitchFreq = zeros(length(pitch_freq),1);
for i = 1:length(pitch_freq)
    pitchFreq(i) = pitch_freq(i).frequency;
end

% read csv file: tonic frequency
T = readtable('models/GTraagDB.csv');
tonicFreq = 261.625565300599;

testDir = dir('test/*.txt');

log_p_all = zeros(length(model),length(testDir));
for i = 1:length(testDir)
    
    % get the quantized, normalized pitch vector from the text file
    filename = strcat('test/',testDir(i).name);
    pitch_quant = getPitchVec(filename, tonicFreq, pitchFreq, T);
    
    % compute likelihood of test vector with each raag class in model
    % forward-backward
    log_p = zeros(length(model),1);
    for c = 1:length(model)
        [~, ~, ~, log_p(c)] = hmm_fb (model(c).pi, model(c).A,...
                                            model(c).B, pitch_quant);
    end
    log_p_all(:,i) = log_p; 
    fprintf('%s \n', testDir(i).name);
end


[~, ind] = max(log_p_all)

temp = log_p_all;
linInd = sub2ind(size(log_p_all), ind,1:size(log_p_all,2));
temp(linInd)=nan;
[~, second] = max(temp)
linInd = sub2ind(size(log_p_all), second,1:size(log_p_all,2));
temp(linInd) = nan;
[~, third] = max(temp)
fprintf('Accuracy: %d / %d \n',sum(ind==true), length(ind));

confusion = zeros(length(model));
for i=1:length(ind)
    confusion(true(i), ind(i)) = confusion(true(i), ind(i)) + 1;
end

%% confusion matrix

% raag = {'bihag', 'darbari', 'desh', 'gaud_malhar', 'yaman'};
% bihag = confusion(:,1);
% darbari = confusion(:,2);
% desh = confusion(:,3);
% gaud_malhar = confusion(:,4);
% yaman = confusion(:,5);
% tt = table(bihag, darbari, desh, gaud_malhar, yaman, 'RowNames', raag);
% 
% raag = {'bihag', 'darbari', 'desh', 'gaud_malhar', 'yaman'};
% imagesc(confusion), title('Confusion matrix'),
% set(gca, 'XTick', 1:5)
% set(gca, 'XTickLabel', raag)
% set(gca, 'YTick', 1:5)
% set(gca, 'YTickLabel', raag)

%% bar plots
% raag = {'', 'bihag', 'darbari', 'desh', 'gaud_malhar', 'yaman'};
% log_p = log_p_all(:,2);
% log_p(isnan(log_p)) = -5*10^4;
%     % normalize negative values
%     temp =  log_p + abs(min(log_p));
%     acc = temp / norm(temp);
%     hf = figure(i); 
%     hold on, bar(acc), bar(acc.*(acc==max(acc)), 'g'),
%     hold off;
%     title('Normalized log(P(O|lambda))'), 
% %     set(gca, 'XTick', 1:5)
%     set(gca, 'XTickLabel', raag)
%     %saveas(hf,strcat('results/multiple_',num2str(i),'.png'));
% 


%%

% pitch_str = {'C3','C#3','D3','D#3','E3','F3','F#3','G3','G#3','A3','A#3','B3','C','C#', 'D','D#','E','F','F#','G','G#','A','A#','B','C5','C#5','D5','D#5','E5','F5','F#5','G5','G#5','A5','A#5','B5'};
% % plot(data(2).pitch_quant{1}, '.')
% % set(gca, 'YTick', 1:36)
% % set(gca, 'YTickLabel', pitch_str)
% % % ax.YTickLabel = pitch_str;
% 
% 
% plot(pitch_quant, '.')
% set(gca, 'YTick', 1:36)
% set(gca, 'YTickLabel', pitch_str)



    
    
    