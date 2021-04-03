% SUMMARY:  获取训练出来的所有的模型（Q和M值不同）的识别结果
% 输入
% 输出：一个7x7的cell，cell{i,j}里装Q=i，M=j时训练出来的模型的识别效果
% 每个cell里是一个10x5的矩阵，前四列是对训练数据的识别结果，第5列是对测试数据的识别效果
% Created:  2-4-2021

index = cell(7,7);
for Q = 1:7
    for M = 1:7
        
        if exist(['parameter_Q',num2str(Q),'_M',num2str(M),'.mat'])
            parameter = load(['parameter_Q',num2str(Q),'_M',num2str(M),'.mat']);
            parameter = parameter.parameter_train;
            for i = 0:9
                X = Data_test{i+1};
                %figure;
                %scatter(X(:,1), X(:,2), '.');
                for j = 0:9
                    logp_xn_given_zn{j+1} = Gmm_logp_xn_given_zn(X, parameter.phi{j+1});
                    [~,~, logliktest(j+1)] = LogForwardBackward(logp_xn_given_zn{j+1}, parameter.p_start{j+1}, parameter.A{i+1});
                end
                [~,lik_max] = max(logliktest);
                index{Q,M}(i+1,5) = lik_max-1;

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
                    index{Q,M}(i+1,n) = lik_max-1;
                end
            end
        end
    end
end