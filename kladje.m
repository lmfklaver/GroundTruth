% postproccessing? (diff/downsample/findpeaks?)
% downsample 
% FsNew = 1250;
% [P,Q] = rat(FsNew/Fs);
% dataResampled = resample(double(data), P,Q);


% diffX = diff(data)
% diffXStd =std(diffX);,findDiffXStd = find(diffX>3*diffXStd);,figure,plot(diffX(1:10000)),hold on, plot(findDiffXStd,repmat(0,1,length(findDiffXStd)),'*');
% intiial threshold with a std and then findpeaks?
