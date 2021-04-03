
%test
%选用训练好的的模型参数
parameter = load('parameter_Q3_M3.mat');
parameter = parameter.parameter_train;
index = zeros(10,5);

for i = 0:9
    X = Data_test{i+1};
    %figure;
    %scatter(X(:,1), X(:,2), '.');
    for j = 0:9
        logp_xn_given_zn{j+1} = Gmm_logp_xn_given_zn(X, parameter.phi{j+1});
        [~,~, logliktest(j+1)] = LogForwardBackward(logp_xn_given_zn{j+1}, parameter.p_start{j+1}, parameter.A{i+1});
    end
    [~,lik_max] = max(logliktest);
    index(i+1,5) = lik_max-1;

end
for i = 0:9
    for n = 1:4
        X = Data_train{i+1,n};
        %figure;
        %scatter(X(:,1), X(:,2), '.');
        for j = 0:9
            logp_xn_given_zn{j+1} = Gmm_logp_xn_given_zn(X, parameter.phi{j+1});
            [~,~, logliktest(j+1)] = LogForwardBackward(logp_xn_given_zn{j+1}, parameter.p_start{j+1}, parameter.A{i+1});
        end
        [~,lik_max] = max(logliktest);
        index(i+1,n) = lik_max-1
    end
end