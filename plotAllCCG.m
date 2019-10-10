function [out] = plotAllCCG(ccg,t)

ccg(:,2,1) = ccg(:,1);
ccg(:,2,2) = ccg(:,1);
ccg(:,1,2) = ccg(:,1);


plotCount = 1;
    figure
    for idx_hMFR = 1:size(ccg,2)
        for iPair = 1:size(ccg,2)
            subplot(size(ccg,2),size(ccg,2),plotCount)
            plotCount = plotCount+1;
            if idx_hMFR == iPair
                bar(t,ccg(:,idx_hMFR,iPair),'k')
            else
                bar(t,ccg(:,idx_hMFR,iPair))
            end
        end
    end
    
out = 1
    
end
