function [pi, A, B] = hmm_update_multiple...
    (alpha_multiple, beta_multiple, c_alpha_multiple, O_multiple, A_prev, B_prev)

% ==================== Description ==========================
% 
% Author: Dhruva Kumar
% 
% This is the M step of the Baum Welch algorithm to update
% the HMM model parameters {pi, A, B} after the forward backward step
% FOR MULTIPLE SEQUENCES
% 
% Input:
% alpha_multiple {L x 1}: alpha of ever sequence
% beta_multiple {L x 1}: beta of every sequence
% c_alpha_multiple {L x 1}: c_alpha of every sequence
% O_multiple {L x 1}: cell of discretized observation sequence
% A_prev [N x N]: transition matrix of prev iteration P(S(t+1) | S(t))
% B_prev [M x N]: emission matrix of prev iteration P(O(t) | S(t)
%         
% Output:
% pi [N x 1]: initial state distribution P(qi = st(1))
% A [N x N]: transition matrix P(S(t+1) | S(t))
% B [M x N]: emission matrix P(O(t) | S(t)
%
% PS: N - number of states | M - number of discrete observations
%
% ==============================================================

L = length(O_multiple);
[M,N] = size(B_prev);
num_A_multiple = zeros(N,N);
den_A_multiple = zeros(N,N);
num_B_multiple = zeros(M,N);
den_B_multiple = zeros(M,N);
pi_multiple = zeros(N,L);

for l = 1:L
    [pi_multiple(:,l), ~, ~, num_A, den_A, num_B, den_B] = ...
        hmm_update (alpha_multiple{l}, beta_multiple{l}, ...
                    c_alpha_multiple{l}, O_multiple{l}, A_prev, B_prev);
                
    num_A_multiple = num_A_multiple + num_A;
    den_A_multiple = den_A_multiple + den_A;
    num_B_multiple = num_B_multiple + num_B;
    den_B_multiple = den_B_multiple + den_B;    
end

% combine
pi = sum(pi_multiple,2);
A = num_A_multiple ./ den_A_multiple;
B = num_B_multiple ./ den_B_multiple;
%normalize
pi = pi/sum(pi);
A = A ./ repmat(sum(A), N,1);
B = B ./ repmat(sum(B), M,1);

    
    
    
    
    
    
    
    
    
    
    
    