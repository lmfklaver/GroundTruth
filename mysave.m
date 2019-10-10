function mysave()
%getfilename = input('Entire Filename');
getfilename = ('fullpath');
%mypath = 'C:\Data\'+ getfilename;
myData = saveas(getfilename);
myData;
end



