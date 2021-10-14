%% Stacked Bar Ommissions Commissions for each session:
% sessions = {'m14_190326_155432', ...
%             'm14_190326_160710_cell1' ...
%             'm15_190315_145422',...
%             'm15_190315_150831_cell1',...
%             'm15_190315_152315_cell1',...
%             };
%%
[m_n] = [];
[o_n] = [];
[c_n] = [];

for iSess = 1 %:length(sessions)
    cd(fullfile('D:\Data\GroundTruth\',sessions{iSess}))
    
    basepath = cd;
    basename = bz_BasenameFromBasepath(basepath);
    
    % load juxtas
    % load extras
    % this needs to be generalized in GetJuxtaExtraSpikes
    
    % find match
    [highestChannelCorr,  lfp_juxta, lfp_extra, bestCluster,spikesJCEC] = ...
        gt_LoadJuxtaCorrExtra_new(basepath) 
   
    % calculate _cco
    
    [cco_timevector, cco_indexvector, num_CorrComOm] = ...
        gt_GetCorrCommOm_new(spikesJCEC.times{end}, spikesJCEC.times(1:end-1), bestCluster, lfp_extra,lfp_juxta, opts, sessions, iSess); 

    % save _cco indices + times
    save([basename '.cco.mat'],'cco_timevector','cco_indexvector','num_CorrComOm','highestChannelCorr','bestCluster');
    
    
    % calculate fraction of matches, om and com
    m = length(cco_indexvector.matches);
    o = length(cco_indexvector.om);
    c = length(cco_indexvector.com);
    
% %     m_n = m/ (m+o); 
% %     o_n = o/ (m+o); % m_n and o_n add up to 1 in a stacked bar chart
% %     c_n = c/ (m+c+o); % everything over 1 would be the percentage of commissions 
% %   
if ~isempty(dir('*.jSpkTimes*'))
   a = dir('*.jSpkTimes*');
   if length(a) == 1
       load(a.name)
   else 
       return
   end
   load([basename '.juxtaSpikes.mat']);
    juxtaSpikes.times = {jSpkTimes};
    juxtaSpikes.ts = {jSpkTimes/30000};
else
    load([basename '.juxtaSpikes.mat']);
end

    
    total_true_jc = length(juxtaSpikes.times{1});
    total_true_m_o = m + o;
%     if total_true_jc == total_true_m_o
        m_n = [m_n; m/total_true_m_o];
        o_n = [o_n; o/total_true_m_o];
        c_n = [c_n; c/(total_true_m_o + c)];
        sess{iSess} = basename;
%     else
%         disp('true doesn''t match number of JC spikes')
%     end
    
    
end

% save([basename 'moc.mat'], 'm_n', 'o_n','c_n')
%%
figure,
ba = bar([m_n, o_n, c_n],'stacked');
ba(1).FaceColor = [0.4660 0.6740 0.1880]; %green
ba(2).FaceColor = [0.9290 0.6940 0.1250]	; %yellow
ba(3).FaceColor = [0.8500 0.3250 0.0980]; %red

hold on
xl=get(gca,'Xlim');
plot([xl(1) xl(2)],[1 1],'k--')

xticklabels(sess)
set(gca,'XTickLabelRotation',45)
legend({'Correct detection','False negative','False positive'})
