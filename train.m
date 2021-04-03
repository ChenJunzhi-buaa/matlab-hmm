% SUMMARY: ģ�͵�ѵ����ģ�Ͳ����ı��棬
% ģ�ͱ�����parameter_Q*_M*.mat�ļ�������parameter_train�Ǹ�1x1��struct������

% Created:  2-4-2021


close all
clear 
clc

% ������
Q = 3;      % state num
M = 3;      % mix num
% p = 2;      % feature dim

%��������ʱ��
t1 = datetime;

% ���ݼ���
Data_train = cell(10,4); % Data_train{i,j}װ������i-1�ĵ�j������
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
%����ѵ���õ�ģ�Ͳ���
parameter_train.p_start = p_start;
parameter_train.A = A;
parameter_train.phi =phi;
save(['parameter_Q',num2str(Q),'_M',num2str(M)],'parameter_train');

t2 = datetime;
time = t2 - t1

%test
%ѡ��ѵ���õĵ�ģ�Ͳ���
parameter = load('parameter_Q3_M3.mat');
parameter = parameter.parameter_train;
index = zeros(10,5);

% ���ݼ���
Data_train = cell(10,4); % Data_train{i,j}װ������i-1�ĵ�j������
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

% ����
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


            

% ����ʶ��׼ȷ��
sum = 0;
for i = 1:10
    for j = 1:5
        if index(i,j) == i-1
            sum = sum+1;
        end
    end
end
accuracy = sum/50