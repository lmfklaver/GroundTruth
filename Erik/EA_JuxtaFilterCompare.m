function EA_JuxtaFilterCompare(dJuxtadata,sampFreq,hpFreq,firOrder,buttOrder,filCompInt)
%EA_JuxtaFilterCompare compares a snapshot of the three different filters
%together
%   Detailed explanation goes here

%     filCompInt = [1000000, 2000000];

    fOrigJux = figure('Name','Unfiltered_Juxta'); 
    plot(dJuxtadata)
    xlim(filCompInt);

 
    %  filter 1: butterworth
    [b,a] = butter(buttOrder,hpFreq/(sampFreq/2),'high'); % Butterworth filter of order
    filtJuxtaButt = zscore(filter(b,a,dJuxtadata)); % Will be the filtered signal
    fbutt = figure('Name','Butterworth_Juxta') 
    plot(filtJuxtaButt)
    xlim(filCompInt);
 
    % filter 2: built-in highpass
    filtJuxtaHp = highpass(dJuxtadata,hpFreq,sampFreq);
    fHp = figure('Name','HighPassOnly_Juxta') 
    plot(filtJuxtaHp)
    xlim(filCompInt);
 
    % filter 3: filtfilt
    [b2,a2] = fir1(firOrder,hpFreq/(sampFreq/2),'high');
    filtJuxtaFir = zscore(filtfilt(b2,a2,dJuxtadata));
    fFir1 = figure('Name','Fir1_Juxta') 
    plot(filtJuxtaFir)
    xlim(filCompInt);
    
       

end

