function [alpha, beta, c_alpha, log_p_O_model] = hmm_fb (pi, A, B, O)

% ==================== Description ==========================
% 
% Author: Dhruva Kumar
% 
% This is the E step of the Baum Welch algorithm to learn 
% the HMM model parameters {pi, A, B}
% 
% Input:
% pi [N x 1]: initial state distribution P(qi = st(1))
% A [N x N]: transition matrix P(S(t+1) | S(t))
% B [M x N]: emission matrix P(O(t) | S(t))
% O [T x 1]: discretized observation sequence
% PS: N - number of states | M - number of discrete observations
%         
% Output:
% alpha [N x T]: forward variable | P(O(1...t),S(i) | lambda)
% beta [N x T]: backward variable | P(O(t+1...T),S(i) | lambda)
% c_alpha [1 x T]: scaling coefficients of alpha
% log_p_O_model [1 x T]: P(O | lambda) from forward step
%%% Deprecated::
%%% gamma [N x T]: fb | P(S(i) | O, lambda)
%%% zeta [N x N x T-1]: pair of states | P(S(i), S(j) | O, lambda)
%%% 
% 
%
% ==============================================================

% debugging init model: fully connected
% N = 15; M = 20;
% pi = 1/N * ones(N,1);
% A = rand(N,N); 
% A = A ./ repmat(sum(A), N,1); % normalize
% B = repmat(1/M*ones(M,1), 1,N);
% O = quantizedObs(1).X_gesture_quant{1};

[~,N] = size(B);
T = length(O);

%% alpha [N x T]: forward step

alpha = zeros(N,T);
c_alpha = zeros(1,T); % scaling coefficients
% init
alpha(:,1) = pi .*  B(O(1), :)';
c_alpha(1) = 1/sum(alpha(:,1));
alpha(:,1) = alpha(:,1) .* c_alpha(1);
% induction
for t = 2:T
    alpha(:,t) = (alpha(:,t-1)' * A')' .* B(O(t), :)';
   % scaling
   c_alpha(t) = 1/sum(alpha(:,t));
   alpha(:,t) = alpha(:,t) .* c_alpha(t);
end
% termination
log_p_O_model = -sum(log(c_alpha));

%% beta [N x T]: backward step 
beta = ones(N,T);
% init
beta(:,T) = beta(:,T) * c_alpha(T);
% induction
for t = T-1:-1:1
    beta(:,t) = ((B(O(t+1), :)' .* beta(:, t+1))' * A)';
    % scaling
    beta(:,t) = beta(:,t) .* c_alpha(t);
end

% %% gamma [N x T]: fb (don't need it for the em procedure)
%  
% gamma = alpha .* beta;
% % normalize columns (every time instant)
% gamma = gamma ./ repmat(sum(gamma), N,1);
% 
% %% zeta [N x N x T-1] : pair of states (don't need it for the em procedure)
% 
% zeta = zeros(N,N,T-1);
% 
% for t = 1:T-1
%    for i = 1:N
%        zeta(:,i) = alpha(i, t) * ( A(:,i) .* B(O(t+1), :)' .* beta(:, t+1)) ;
%    end
%    zeta(:,:,t) = zeta(:,:,t) / sum(sum(zeta(:,:,t)));
% end

% gamma = [];
% zeta = [];




























