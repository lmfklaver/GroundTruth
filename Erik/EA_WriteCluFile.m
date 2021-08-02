function EA_WriteCluFile(basename, additionalNaming, filetype, data)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

%   dependencies
%   basename, additionalNaming, filetype, data 

fid=fopen([basename, additionalNaming, filetype],'wt+');
    fprintf(fid,'%.0f\n',data);
    fclose(fid);
    clear fid  
end

