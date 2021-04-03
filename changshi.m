% SUMMARY: ��ͬ������ģ�͵�ѵ����ģ�Ͳ����ı��棬
% ģ�ͱ�����parameter_Q*_M*.mat�ļ�������parameter_train�Ǹ�1x1��struct������

% Created:  2-4-2021
close all
clear 
clc

% ������
Q = 3;      % state num
M = 2;      % mix num
% p = 2;      % feature dim
for Q = 1:7
    for M = 1:7
        if (Q>4)||(M>4)
            %��������ʱ��
            t1 = datetime;

            % ���ݼ���
            Data_train = cell(10,4); % Data_train{i,j}װ������i-1�ĵ�j������
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
            %����ѵ���õ�ģ�Ͳ���
            parameter_train.p_start = p_start;
            parameter_train.A = A;
            parameter_train.phi =phi;
            save(['parameter_Q',num2str(Q),'_M',num2str(M)],'parameter_train');

            t2 = datetime;
            time = t2 - t1


            clc
            clear
            % ������
            Q = 3;      % state num
            M = 1;      % mix num
            % p = 2;      % feature dim

            %��������ʱ��
            t1 = datetime;

            % ���ݼ���
            Data_train = cell(10,4); % Data_train{i,j}װ������i-1�ĵ�j������
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
            %����ѵ���õ�ģ�Ͳ���
            parameter_train.p_start = p_start;
            parameter_train.A = A;
            parameter_train.phi =phi;
            save(['parameter_Q',num2str(Q),'_M',num2str(M)],'parameter_train');

            t2 = datetime;
            time = t2 - t1
        end
    end
end

