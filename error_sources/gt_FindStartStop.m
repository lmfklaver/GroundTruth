b = [ 1 2 3 4 5 5 5 6 6 6 7 6 6 6 5 5 4 3 2 1]

threshold = 4.5

a = b>threshold

startIndex = 1
stopindx =1

rest_start=[]
rest_stop =[]

for indx = 2:length(a)-1,
    if a(indx-1) == a(indx),
        continue,
    else
        if b(indx)>threshold
        rest_start(startIndex) = indx,
        startIndex = startIndex+1;
        elseif b(indx)<threshold
        rest_stop(stopindx) = indx,
        stopindx = stopindx+1;
        end
    end
end