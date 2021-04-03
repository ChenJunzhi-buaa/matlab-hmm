% SUMMARY:  对采集到的数字轨迹进行作图，蓝色为4条训练数字轨迹，红色为测试数字轨迹
% 并将图片保存下来，其中数字1特别对坐标轴范围进行了处理，使得更像1
% Created:  1-4-2021
close all
clear 
clc
Data_train = cell(10,4); % Data_train{i,j}装着数字i-1的第j组数据
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
