function rasterPlot(LB,UB,Juxta_bz, Extra_bz, selecClust, wrongClust, wrongClust2, wrongClust3)
%selecClus - 1 ?

JuxtaID = find(Juxta_bz.shankID == 2);
JuxtaSpikesTimes = Juxta_bz.times(JuxtaID);

ExtraID = find(Extra_bz.shankID == 1);
ExtraSpikesTimes = Extra_bz.times(ExtraID);

for iJuxta = 1:length(JuxtaSpikesTimes{1})
    if JuxtaSpikesTimes{1}(iJuxta) > LB && JuxtaSpikesTimes{1}(iJuxta) < UB
    line([JuxtaSpikesTimes{1}(iJuxta) JuxtaSpikesTimes{1}(iJuxta)],[2.8 3.8]),
    hold on
    end
end
for iExtra = 1:length(ExtraSpikesTimes{selecClust})
    if ExtraSpikesTimes{selecClust}(iExtra) > LB && ExtraSpikesTimes{selecClust}(iExtra) < UB
        line([ExtraSpikesTimes{selecClust}(iExtra) ExtraSpikesTimes{selecClust}(iExtra)],[.8 1.8],'Color','red'),
    hold on
    end
end
for iExtra = 1:length(ExtraSpikesTimes{wrongClust})
    if ExtraSpikesTimes{wrongClust}(iExtra) > LB && ExtraSpikesTimes{wrongClust}(iExtra) < UB
        line([ExtraSpikesTimes{wrongClust}(iExtra) ExtraSpikesTimes{wrongClust}(iExtra)],[-.2 -1.2],'Color','red'),
    hold on
    end
end
for iExtra = 1:length(ExtraSpikesTimes{wrongClust2})
    if ExtraSpikesTimes{wrongClust2}(iExtra) > LB && ExtraSpikesTimes{wrongClust2}(iExtra) < UB
        line([ExtraSpikesTimes{wrongClust2}(iExtra) ExtraSpikesTimes{wrongClust2}(iExtra)],[-2.2 -3.2],'Color','red'),
    hold on
    end
end
for iExtra = 1:length(ExtraSpikesTimes{wrongClust3})
    if ExtraSpikesTimes{wrongClust3}(iExtra) > LB && ExtraSpikesTimes{wrongClust3}(iExtra) < UB
        line([ExtraSpikesTimes{wrongClust3}(iExtra) ExtraSpikesTimes{wrongClust3}(iExtra)],[-4.2 -5.2],'Color','red'),
    hold on
    end
end
ylim([-6 4])
end