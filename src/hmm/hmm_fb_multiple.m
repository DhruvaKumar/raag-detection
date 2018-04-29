function [alpha_multiple, beta_multiple, c_alpha_multiple, log_p_O_model]...
    = hmm_fb_multiple(pi_prev, A_prev, B_prev, O_multiple)

% ==================== Description ==========================
% 
% Author: Dhruva Kumar
% 
% This is the E step of the Baum Welch algorithm to learn 
% the HMM model parameters {pi, A, B} for multiple observations
% 
% Input:
% pi [N x 1]: initial state distribution P(qi = st(1))
% A [N x N]: transition matrix P(S(t+1) | S(t))
% B [M x N]: emission matrix P(O(t) | S(t))
% O_multiple {L x 1}: cell of discretized observation sequence
%           each sequence: [1 x T]
% PS: N - number of states | M - number of discrete observations
%         
% Output:
% alpha_multiple {L x 1}: alpha of ever sequence
% beta_multiple {L x 1}: beta of every sequence
% c_alpha_multiple {L x 1}: c_alpha of every sequence
% log_p_O_model [1]: of all the sequences combined
%
% Every sequence:
%   alpha [N x T]: forward variable | P(O(1...t),S(i) | lambda)
%   beta [N x T]: backward variable | P(O(t+1...T),S(i) | lambda)
%   c_alpha [1 x T]: scaling coefficients of alpha
%   p_O_model [1 x T]: P(O | lambda) from forward step
% 
%
% ==============================================================

L = length(O_multiple);
log_p_O_model_multiple = zeros(L,1);
alpha_multiple = cell(L,1);
beta_multiple = cell(L,1);
c_alpha_multiple = cell(L,1);

for l = 1:L
    [alpha_multiple{l}, beta_multiple{l}, c_alpha_multiple{l}, ...
        log_p_O_model_multiple(l)] = hmm_fb(pi_prev, A_prev, B_prev, O_multiple{l});
end

log_p_O_model = sum(log_p_O_model_multiple);





















end