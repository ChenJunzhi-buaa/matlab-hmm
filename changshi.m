% SUMMARY: 不同超参数模型的训练和模型参数的保存，
% 模型保存在parameter_Q*_M*.mat文件里，里面的parameter_train是个1x1的struct型数据

% Created:  2-4-2021
close all
clear 
clc

% 超参数
Q = 3;      % state num
M = 2;      % mix num
% p = 2;      % feature dim
for Q = 1:7
    for M = 1:7
        if (Q>4)||(M>4)
            %测试所耗时间
            t1 = datetime;

            % 数据加载
            Data_train = cell(10,4); % Data_train{i,j}装着数字i-1的第j组数据
            Data_test = cell(10);
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
                Data_test{i+1} = data; 
            end



            % Train Gmm-Hmm model
            p_start = cell(10);
            A = cell(10);
            phi = cell(10);
            loglik = cell(10);
            for i = 1:10
                [p_start{i}, A{i}, phi{i}, loglik{i}] = ChmmGmm(Data_train(i,:), Q, M);
            end
            %保存训练好的模型参数
            parameter_train.p_start = p_start;
            parameter_train.A = A;
            parameter_train.phi =phi;
            save(['parameter_Q',num2str(Q),'_M',num2str(M)],'parameter_train');

            t2 = datetime;
            time = t2 - t1


            clc
            clear
            % 超参数
            Q = 3;      % state num
            M = 1;      % mix num
            % p = 2;      % feature dim

            %测试所耗时间
            t1 = datetime;

            % 数据加载
            Data_train = cell(10,4); % Data_train{i,j}装着数字i-1的第j组数据
            Data_test = cell(10);
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
                Data_test{i+1} = data; 
            end



            % Train Gmm-Hmm model
            p_start = cell(10);
            A = cell(10);
            phi = cell(10);
            loglik = cell(10);
            for i = 1:10
                [p_start{i}, A{i}, phi{i}, loglik{i}] = ChmmGmm(Data_train(i,:), Q, M);
            end
            %保存训练好的模型参数
            parameter_train.p_start = p_start;
            parameter_train.A = A;
            parameter_train.phi =phi;
            save(['parameter_Q',num2str(Q),'_M',num2str(M)],'parameter_train');

            t2 = datetime;
            time = t2 - t1
        end
    end
end

