function pitch_quant = quantPitch(pitch, pitchFreq)

% ========================== Description ============================ 
% 
% Author: Dhruva Kumar
% 
% given the 'pitch' (the frequency detected by the algorithm used (praat?)),
% find the nearest pitch frequency 'pitchFreq' according to the 12
% chromatic pitch notes
%
% i/p:  - pitch [T x 1]: frequencies from pitch detection algo
%       - pitchFreq [M x 1]: chromatic scale pitch frequencies
%
% o/p:  - pitch_quant [T x 1]: quantized pitch frequencies
%
% ===================================================================

extra = length(pitchFreq); %36
% consider lower pitches < C3 (=130Hz). Tranform scale 1&2 to 3
n = 4:27;
f_extra = 2.^((n-49)/12) .* 440;

norm_pitch = pdist2(pitch, [pitchFreq; f_extra']);
[~, pitch_quant] = min(norm_pitch,[], 2);

pitch_quant(pitch_quant>extra) = mod(pitch_quant(pitch_quant>extra),12);
pitch_quant(pitch_quant==0) = 12;

end