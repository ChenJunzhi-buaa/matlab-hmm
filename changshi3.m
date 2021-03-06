% SUMMARY: 模型的训练和模型参数的保存，
% 模型保存在parameter_Q*_M*.mat文件里，里面的parameter_train是个1x1的struct型数据

% Created:  2-4-2021
accuracy = 0;
while accuracy ~= 1
    close all
    clear 
    clc

    % 超参数
    Q = 3;      % state num
    M = 3;      % mix num
    % p = 2;      % feature dim

    %测试所耗时间
    t1 = datetime;

    % 数据加载
    Data_train = cell(10,4); % Data_train{i,j}装着数字i-1的第j组数据
    Data_test = cell(10,1);
    for i = 0:9
        for j = 1:4
            path = [ '.\trajectories\',num2str(i),'-',num2str(j),'.mat'];
            data = load(path);
            data = data.simout.signals.values;
            data = [data(:,1), data(:,2)];
            Data_train{i+1,j} = data; 
        end
        j = 5;
        path = [ '.\trajectories\',num2str(i),'-',num2str(j),'.mat'];
        data = load(path);
        data = data.simout.signals.values;
        data = [data(:,1), data(:,2)];
        Data_test{i+1,1} = data; 
    end



    % Train Gmm-Hmm model
    p_start = cell(10,1);
    A = cell(10,1);
    phi = cell(10,1);
    loglik = cell(10,1);
    for i = 1:10
        [p_start{i,1}, A{i,1}, phi{i,1}, loglik{i,1}] = ChmmGmm(Data_train(i,:), Q, M);
    end
    %保存训练好的模型参数
    parameter_train.p_start = p_start;
    parameter_train.A = A;
    parameter_train.phi =phi;
    save(['parameter_Q',num2str(Q),'_M',num2str(M)],'parameter_train');

    t2 = datetime;
    time = t2 - t1

    %test
    %选用训练好的的模型参数
    parameter = load('parameter_Q3_M3.mat');
    parameter = parameter.parameter_train;
    index = zeros(10,5);

    % 数据加载
    Data_train = cell(10,4); % Data_train{i,j}装着数字i-1的第j组数据
    Data_test = cell(10,1);
    for i = 0:9
        for j = 1:4
            path = [ '.\trajectories\',num2str(i),'-',num2str(j),'.mat'];
            data = load(path);
            data = data.simout.signals.values;
            data = [data(:,1), data(:,2)];
            Data_train{i+1,j} = data; 
        end
        j = 5;
        path = [ '.\trajectories\',num2str(i),'-',num2str(j),'.mat'];
        data = load(path);
        data = data.simout.signals.values;
        data = [data(:,1), data(:,2)];
        Data_test{i+1,1} = data; 
    end

    % 测试
    for i = 0:9
        X = Data_test{i+1,1};
        %figure;
        %scatter(X(:,1), X(:,2), '.');
        for j = 0:9
            logp_xn_given_zn{j+1} = Gmm_logp_xn_given_zn(X, parameter.phi{j+1,1});
            [~,~, logliktest(j+1)] = LogForwardBackward(logp_xn_given_zn{j+1}, parameter.p_start{j+1,1}, parameter.A{i+1,1});
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
                logp_xn_given_zn{j+1} = Gmm_logp_xn_given_zn(X, parameter.phi{j+1,1});
                [~,~, logliktest(j+1)] = LogForwardBackward(logp_xn_given_zn{j+1}, parameter.p_start{j+1,1}, parameter.A{i+1,1});
            end
            [~,lik_max] = max(logliktest);
            index(i+1,n) = lik_max-1
        end
    end




    % 计算识别准确率
    sum = 0;
    for i = 1:10
        for j = 1:5
            if index(i,j) == i-1
                sum = sum+1;
            end
        end
    end
    accuracy = sum/50
end