load([basename '.ripples.events.mat'])
rippleChan      = ripples.detectorinfo.detectionchannel;
noRippleChan    = 13; %0based
rippleband      = [130 200];
FsLFP           = 1250;
intan_to_uV    = 0.195;

lfp_r       = bz_GetLFP(rippleChan );
[b,a]       = butter(1,rippleband(1)/(FsLFP/2),'high');
lfp_r_f     = filter(b,a,double(lfp_r.data));
[b,a]       = butter(1,rippleband(2)/(FsLFP/2),'low');
lfp_r_f     = filter(b,a,lfp_r_f);
lfp_r.data = lfp_r_f;


lfp_nr      = bz_GetLFP(noRippleChan); 
[b,a]       = butter(1,rippleband(1)/(FsLFP/2),'high');
lfp_nr_f    = filter(b,a,double(lfp_nr.data));
[b,a]       = butter(1,rippleband(2)/(FsLFP/2),'low');
lfp_nr_f    = filter(b,a,lfp_nr_f);
lfp_nr.data = lfp_nr_f;

%%

numSamp = 50;
offset  = 200;

for iRip = 1:length(ripples.peaks)
    
    pkInd   = find(lfp_r.timestamps==ripples.peaks(iRip));
    selInds = pkInd-numSamp:pkInd+numSamp;
    t       = lfp_r.timestamps(selInds)/FsLFP;
    
    figure
    plot(t,lfp_nr.data(selInds)*intan_to_uV -offset,'r')
    hold on
    plot(t,lfp_r.data(selInds)*intan_to_uV, 'k', 'LineWidth',3)
    
    title(['Ripple Number' num2str(iRip)])
    xlabel('time (s)')
    ylabel('amp (uV)')
        
    pause
    % manually jot down the non-rip-indices
    close
    
end
   