function [IDX]=kMeansOnWF(spikes, params)
% dependent on Umberto's waveform_features
% spikes e.g. juxtaSpikes.spk
%% Kmeans clustering on waveform

for iSpk = 1:length(spikes)
    [iw(iSpk),ahp(iSpk),pr(iSpk),ppd(iSpk),slope(iSpk),had(iSpk)]=waveforms_features(spikes(iSpk,:),params.sampFreq);
end

K = 3;
X = [iw; ppd;had;ahp;pr;slope]';
[IDX] = kmeans(X, K); % partitions the points in the N-by-P data matrix X into K clusters.

% plot kmeans
figure
hold on
for i=1:K
    colors = 'brgy';
    app=find(IDX==i);
    
    for j = 1:length(app)
        plot(spikes(app(j),:), colors(i))
        hold on
    end
    
end

figure,
hold on
for i=1:K
    app =find(IDX ==i);
    colors = 'brgy';
    
    subplot(4,4,1)
    hold on
    plot(X(app,1),X(app,2),[colors(i),'.']);
    title('1 vs 2')
    subplot(4,4,2)
    hold on
    plot(X(app,1),X(app,3),[colors(i),'.']);
    title('1 vs 3')
    subplot(4,4,3)
    hold on
    plot(X(app,1),X(app,4),[colors(i),'.']);
    title('1 vs 4')
    subplot(4,4,4)
    hold on
    plot(X(app,1),X(app,5),[colors(i),'.']);
    title('1 vs 5')
    subplot(4,4,5)
    hold on
    plot(X(app,1),X(app,6),[colors(i),'.']);
    title('1 vs 6')
    subplot(4,4,6)
    hold on
    plot(X(app,2),X(app,1),[colors(i),'.']);
    title('2 vs 1')
    subplot(4,4,7)
    hold on
    plot(X(app,2),X(app,3),[colors(i),'.']);
    title('2 vs 3')
    subplot(4,4,8)
    hold on
    plot(X(app,2),X(app,4),[colors(i),'.']);
    title('2 vs 4')
    subplot(4,4,9)
    hold on
    plot(X(app,2),X(app,5),[colors(i),'.']);
    title('2 vs 5')
    subplot(4,4,10)
    hold on
    plot(X(app,2),X(app,6),[colors(i),'.']);
    title('2 vs 6')
    subplot(4,4,11)
    hold on
    plot(X(app,3),X(app,1),[colors(i),'.']);
    title('3 vs 1')
    subplot(4,4,12)
    hold on
    plot(X(app,3),X(app,2),[colors(i),'.']);
    title('3 vs 2')
    subplot(4,4,13)
    hold on
    plot(X(app,3),X(app,4),[colors(i),'.']);
    title('3 vs 4')
    subplot(4,4,14)
    hold on
    plot(X(app,3),X(app,5),[colors(i),'.']);
    title('3 vs 5')
    subplot(4,4,15)
    hold on
    plot(X(app,3),X(app,6),[colors(i),'.']);
    title('3 vs 6')
    
end
