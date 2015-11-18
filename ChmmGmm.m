% SUMMARY:  Train Gauss-HMM model
% AUTHOR:   QIUQIANG KONG
% Created:  17-11-2015
% Modified: - 
% -----------------------------------------------------------
% input:
%   Data        cell of data
%   state_num   state num
%   mix_num     multinominal num
% varargin input:
%   p_start0    p(z1), size: Q*1
%   A           p(zn|zn-1), transform matrix, size: Q*Q
%   phi0:       emission probability para 
%       B         size: M*Q
%       mu        size: p*M*Q
%       Sigma     size: p*p*M*Q
%   iter_num    how many time the EM should run (default: 100)
%   converge    (default: 1+1e-4)
% output
%   p_start  p(z1), dim 1: Q
%   A        p(zn|zn-1), transform matrix, size: Q*Q
%   phi0:       emission probability para 
%       B         size: M*Q
%       mu        size: p*M*Q
%       Sigma     size: p*p*M*Q
% ===========================================================
function [p_start, A, phi, loglik] = ChmmGmm(Data, state_num, mix_num, varargin)
% Init Paras
Q = state_num;
M = mix_num;
p = size(Data{1},2);
for i1 = 1:2:length(varargin)
    switch varargin{i1}
        case 'p_start0'
            p_start = varargin{i1+1};
        case 'A0'
            A = varargin{i1+1};
        case 'B0'
            B = varargin{i1+1};
        case 'phi0'
            phi = phi0;
        case 'cov_type'
            cov_type = varargin{i1+1};
        case 'cov_thresh'
            cov_thresh = varargin{i1+1};
        case 'iter_num'
            iter_num = varargin{i1+1};
        case 'converge'
            converge = varargin{i1+1};
    end
end
if (~exist('p_start'))
    tmp = rand(1,Q);
    p_start = tmp / sum(tmp);
end
if (~exist('A'))
    tmp = rand(Q,Q);
    A = bsxfun(@rdivide, tmp, sum(tmp,2));
end
if (~exist('phi'))
    Xall = cell2mat(Data');
    [prior_, mu_, Sigma_] = Gmm(Xall, M*Q, 'diag');
    tmp = reshape(prior_,M,Q);
    phi.B = bsxfun(@rdivide, tmp, sum(tmp, 1));
    phi.mu = reshape(mu_,p,M,Q);
    phi.Sigma = reshape(Sigma_,p,p,M,Q);
end
if (~exist('iter_num'))
    iter_num = 100;          % the maximum of EM iteration
end
if (~exist('cov_type'))
    cov_type = 'diag';      % 'full' or 'diag'
end
if (~exist('cov_thresh'))
    cov_thresh = 1e-4;      % the thresh of cov
end
if (~exist('converge'))
    converge = 1 + 1e-4;
end

pre_ll = -inf;
obj_num = length(Data);
for k = 1:iter_num
    % E STEP
    for r = 1:obj_num
        p_xn_given_zn = Gmm_p_xn_given_zn(Data{r}, phi);
        [Gamma{r}, Ksi{r}, Loglik{r}] = ForwardBackward(p_xn_given_zn, p_start, A);
        p_xn_given_vn = Get_p_xn_given_vn(Data{r}, phi);
        Ita{r} = CalculateIta(p_xn_given_vn, p_start, A, phi);
    end
    
    % M STEP common
    [p_start, A] = M_step_common(Gamma, Ksi);
    
    % M STEP for Gmm
    % update B
    B_nomer = zeros(M,Q);
    B_denom = zeros(1,Q);
    for r = 1:obj_num
        B_nomer = B_nomer + reshape(sum(Ita{r},1), M, Q);
        B_denom = B_denom + reshape(sum(sum(Ita{r},2),1), 1, Q);
    end
    phi.B = bsxfun(@rdivide, B_nomer, B_denom);
    
    % update mu, Sigma
    mu_numer = zeros(p,M,Q);
    mu_denom = zeros(M,Q);
    for q = 1:Q
        for m = 1:M
            mu_numer = zeros(p,1);
            mu_denom = 0;
            for r = 1:obj_num
                mu_numer = mu_numer + Data{r}' * Ita{r}(:,m,q);
                mu_denom = mu_denom + sum(Ita{r}(:,m,q));
            end
            phi.mu(:,m,q) = mu_numer / mu_denom;
            
            Sigma_numer = zeros(p,p);
            for r = 1:obj_num
                x_diff_mu = bsxfun(@minus, Data{r}, phi.mu(:,m,q)');
                Sigma_numer = Sigma_numer + bsxfun(@times, Ita{r}(:,m,q), x_diff_mu)' * x_diff_mu;
            end
            phi.Sigma(:,:,m,q) = Sigma_numer / mu_denom;
            
            if (cov_type=='diag')
                phi.Sigma(:,:,m,q) = diag(diag(phi.Sigma(:,:,m,q)));
            end
            if max(max(phi.Sigma(:,:,m,q))) < cov_thresh    % prevent cov from being too small
                phi.Sigma(:,:,m,q) = cov_thresh * eye(p);
            end
        end
    end
    
    % loglik
    loglik = 0;
    for r = 1:obj_num
        loglik = loglik + Loglik{r};
    end
    if (loglik-pre_ll<log(converge)) break;
    else pre_ll = loglik; end
end

end

% output: p(xn|vn), size: N*M*Q
function p_xn_given_vn = Get_p_xn_given_vn(X, phi)
    [N,p] = size(X);
    [M,Q] = size(phi.B);
    p_xn_given_vn = zeros(N,M,Q);
    for q = 1:Q
        for m = 1:M
            p_xn_given_vn(:,m,q) = mvnpdf(X, phi.mu(:,m,q)', phi.Sigma(:,:,m,q));
        end
    end
end

% output: p(vn|xn), size: N*M*Q
function ita = CalculateIta(p_xn_given_vn, p_start, A, phi)
    % reserve space
    [N,M,Q] = size(p_xn_given_vn);
    ita = zeros(N,M,Q);
    alpha = zeros(N,M,Q);
    beta = zeros(N,M,Q);
    c = zeros(N,1);
    
    % calculate alpha
    p_v1_z1_x1 = bsxfun(@times, reshape(p_xn_given_vn(1,:,:),M,Q) .* phi.B, p_start);
    c(1) = sum(p_v1_z1_x1(:));
    alpha(1,:,:) = p_v1_z1_x1 / c(1);
    
    for n = 2:N
        Tmp3 = zeros(M,Q);
        for m = 1:M
            for q = 1:Q
                tmp = bsxfun(@times, reshape(alpha(n-1,:,:),M,Q), A(:,q)');
                Tmp3(m,q) = p_xn_given_vn(n,m,q) * phi.B(m,q) * sum(tmp(:));
            end
        end
        c(n) = sum(Tmp3(:));
        alpha(n,:,:) = Tmp3 / c(n);
    end
    
    % calculate beta
    beta(N,:,:) = 1;
    for n = N-1:-1:1
        Tmp3 = zeros(M,Q);
        for m = 1:M
            for q = 1:Q
                tmp = bsxfun(@times, reshape(beta(n+1,:,:),M,Q) .* reshape(p_xn_given_vn(n+1,:,:),M,Q) .* phi.B, A(q,:));
                Tmp3(m,q) = sum(tmp(:));
            end
        end
        beta(n,:,:) = Tmp3 / c(n+1);
    end
    
    % calculate ita
    ita = alpha .* beta;
end