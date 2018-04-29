function [pi, A, B, A_num, A_den, B_num, B_den] = hmm_update (alpha, beta, c_alpha, O, A_prev, B_prev)

% ==================== Description ==========================
% 
% Author: Dhruva Kumar
% 
% This is the M step of the Baum Welch algorithm to update
% the HMM model parameters {pi, A, B} after the forward backward step
% 
% Input:
% alpha [N x T]: forward variable | P(O(1...t),S(i) | lambda)
% beta [N x T]: backward variable | P(O(t+1...T),S(i) | lambda)
% c_alpha [1 x T]: scaling coefficients of alpha
% O [T x 1]: discretized observation sequence
% A_prev [N x N]: transition matrix of prev iteration P(S(t+1) | S(t))
% B_prev [M x N]: emission matrix of prev iteration P(O(t) | S(t)
%         
% Output:
% pi [N x 1]: initial state distribution P(qi = st(1))
% A [N x N]: transition matrix P(S(t+1) | S(t))
% B [M x N]: emission matrix P(O(t) | S(t)
%
% Multiple observations:
% A_num | A_den : numerator and denominator of A for multiple sequences
% B_num | B_den : numerator and denominator of B for multiple sequences
%
% PS: N - number of states | M - number of discrete observations
%
% ==============================================================

% debugging init model: fully connected
% N = 15; M = 20;
% pi = 1/N * ones(N,1);
% A = rand(N,N); 
% A = A ./ repmat(sum(A), N,1); % normalize
% B = repmat(1/M*ones(M,1), 1,N);
% O = quantizedObs(1).X_gesture_quant{1};
% 
% A_prev = A; B_prev = B;
% [alpha, beta, c_alpha] = hmm_fb (pi, A, B, O);

[N, T] = size(alpha);
[M, ~] = size(B_prev);

%% pi [N x 1]

pi = alpha(:,1) .* beta(:,1);
pi = pi / sum(pi);

%% A [N x N]

%A = zeros(N,N);
A_num = zeros(N,N);
A_den = zeros(N,N);
for i = 1:N
    num = repmat(alpha(i, 1:T-1), N,1) .* repmat(A_prev(:,i),1,T-1)  .* B_prev(O(2:T), :)' .* beta(:,2:T);
    A_num(:,i) = sum(num,2);
    den = alpha(i, 1:T-1) .* beta(i, 1:T-1) ./ c_alpha(1:T-1);
    A_den(:,i) = repmat(sum(den), N,1);
end
A = A_num ./ A_den; 
% normalize: not needed. gets normalized automatically!
% A = A ./ repmat(sum(A), N,1);

%% B [M x N]

%B = zeros(M,N);
B_num = zeros(M,N);
B_den = zeros(M,N);
for j = 1:N
    for k = 1:M
        ind = (O==k);
        num = alpha(j, ind) .* beta(j, ind) ./ c_alpha(ind);
        B_num(k,j) = sum(num);
    end
    den = alpha(j, 1:T) .* beta(j, 1:T) ./ c_alpha(1:T);
    B_den(:,j) = repmat(sum(den), M,1);
end
B = B_num ./ B_den; 
% normalize: not needed. gets normalized automatically!
% B = B ./ repmat(sum(B), M,1);






















