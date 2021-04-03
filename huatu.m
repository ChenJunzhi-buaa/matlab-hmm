% SUMMARY:  �Բɼ��������ֹ켣������ͼ����ɫΪ4��ѵ�����ֹ켣����ɫΪ�������ֹ켣
% ����ͼƬ������������������1�ر�������᷶Χ�����˴���ʹ�ø���1
% Created:  1-4-2021
close all
clear 
clc
Data_train = cell(10,4); % Data_train{i,j}װ������i-1�ĵ�j������
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

for i= 0:9
    X = Data_test{i+1};
    figure;hold on;
    scatter(X(:,1), X(:,2), '.','r');
    for j = 1:4
        X = Data_train{i+1,j};
        scatter(X(:,1), X(:,2), '.','b');
    end
    saveas(gcf,[num2str(i),'.jpg'])
 
    close;
end

i=1
X = Data_test{i+1};
    figure;hold on;
    scatter(X(:,1), X(:,2), '.','r');
    for j = 1:4
        X = Data_train{i+1,j};
        ylim([-0.06,+0.06]);
        scatter(X(:,1), X(:,2), '.','b');
    end
    saveas(gcf,['1_xiuzheng.jpg'])
 
    close;
