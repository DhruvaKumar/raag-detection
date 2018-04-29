function [pitch_quant, pitch, t_pitch] = getPitchVec(filename, tonicFreq, pitchFreq, T)

% ========================== Description ============================ 
% 
% Author: Dhruva Kumar
% 
% reads in the filename, gets the predicted pitch frequencies for the file,
% quantizes it according to the chromatic scale, shifts to the tonic
% frequency specified and returns the quantized, normalized pitch vector
%
% i/p:  - filename: filepath to the pitch listing
%       - tonicFreq: tonic frequency for the vector to be shifted relative
%       to it
%       - pitchFreq {36 x 2}: pitch -> frequency mapping
%       - T(table): name of file -> the tonic frequency
%
% o/p:  - pitch_quant [T x 1]: quantized, normalized pitch vector
%       - pitch [T x 1]: unquantized, raw, pitch vector 
%           (PLEASE NOTE: THIS IS NOT NORMALIZED!)
%
% ===================================================================

    % .txt -> vector
    fID = fopen(filename);
    pitch_file = textscan(fID, '%f %f');
    fclose(fID);
     t_pitch = pitch_file{1};
    pitch = pitch_file{2};
    % what to do about 0s? remove them? or extend the previous note?
    % option1: replace with C - tonic frequency
    pitch(pitch==0) = nan;  
%     % option2: replace with last non zero value
%       pitch(find(pitch==0)' == 1:length(find(pitch==0))) = [];
%       for i=2:length(pitch)
%             if (pitch(i)==0)
%                 pitch(i) = pitch(i-1);
%             end
%       end
%     % option3: remove those values
%     pitch(pitch==0) = [];
    
    % quantize pitch
    pitch_quant= quantPitch(pitch, pitchFreq);
    
    % shift relative to tonic frequency
    % get tonic freq from .csv file
%     name = regexprep(filename,'\..*$', '');
    [~,name,~] = fileparts(filename);
    tf = T.TonicFrequency(strcmp(T.Filename,strcat(name,'.wav')));
    % shift
    shift = quantPitch(tonicFreq,pitchFreq) - quantPitch(tf,pitchFreq);
    pitch_quant = pitch_quant + shift;
    pitch_quant(pitch_quant<=0) = pitch_quant(pitch_quant<=0) + 12;
    % handle nan
    pitch_quant(isnan(pitch)) = 1;



end