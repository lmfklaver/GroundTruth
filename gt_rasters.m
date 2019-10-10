
selecChan = 23;
lowSec = 0;
highSec = inf;

figure, 
for iJuxta = 1:length(JuxtaSpikesTimes)
    if JuxtaSpikesTimes(iJuxta) > lowSec && JuxtaSpikesTimes(iJuxta) <highSec
    line([JuxtaSpikesTimes(iJuxta) JuxtaSpikesTimes(iJuxta)],[0.2 1]),
    hold on
    end
end

for iExtra = 1:length(ExtraSpikesTimes{selecChan})
    if ExtraSpikesTimes{selecChan}(iExtra)>lowSec && ExtraSpikesTimes{selecChan}(iExtra) <highSec
        line([ExtraSpikesTimes{selecChan}(iExtra) ExtraSpikesTimes{selecChan}(iExtra)],[-1 -0.2],'Color','red'),
    hold on
    end
end

ylim([-2 2])