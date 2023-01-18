function c_out=red_blue_colormap(thr)

c = [103    0       31;
    178     24      43;
    214     96      77;
    244     165     130;
    253     219     199;
    247     247     247;
    209     229     240;
    146     197     222;
    67      147     195;
    33      102     172;
    5       48      97];


[num, dem] = rat(thr);
num=num;
dem=dem*2;


base=[repelem(round((floor(dem/2)-num)/5),3),ceil((floor(dem/2)-num)/5),floor((floor(dem/2)-num)/5)];
wht=num*2;
top=[repelem(round((ceil(dem/2)-num)/5),3),ceil((ceil(dem/2-num))/5),floor((ceil(dem/2-num))/5)];


c_out=single([repelem(c(1:5,:),base,1);repelem(c(6,:),wht,1);repelem(c(7:end,:),top,1)]);

c_out = flipud(c_out/255);








