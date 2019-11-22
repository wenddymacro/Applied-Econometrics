*首先，画出结果变量与参考变量之间的关系图，选择带宽为0.01，共100个区间

keep if margin<=0.5 & margin>=-0.5  //限制样本范围
local h =0.01 //改变带宽
egen group =cut(margin),at(-.5(0.01).5)//根据参考变量，划分相同距离区间
collapse(count) n=vote (mean) vote margin,by(group)//安区间计算平均值，并计算每个区间中的个体数
gen x=-.5+1/_N*_n-1/(_N*2)//参考变量区间的中间点
gen x2=x^2
gen x3=x^3
gen x4=x^4

*利用4阶多项式拟合
reg vote x x2 x3 x4 if x<0
predict votel if e(sample)
reg vote x x2 x3 x4 if x>=0
predict voter if e(sample)

*画出结果变量vote与参考变量margin的关系图
sc vote x,xline(0) ||line votel x || line voter x,legend(off)




*然后，画出参考变量的分布图，以判断个体是否能够精确控制断点
replace n=n/4900*100//换算成概率分布
reg n x x2 x3 x4 if x<0
predict nl if e(sample)
reg n x x2 x3 x4 if x>=0
predict nr if e(sample)
*画出参考变量的分布图
sc n x,xline(0) ||line nl x || line nr x,legend(off)

*下面，我们利用局部平均值法和局部线性回归法估计RDD
keep if margin>=-.28 & margin<=.28
gen d=margin>0
eststo m1:reg vote 1.d,vce(robust)
eststo m2:reg vote d# #c.margin,vce(robust)
esttab m1 m2 using llr.rtf,star(* 0.10 ** 0.05 *** 0.01) nogap nonumber replace

*全样本，利用多项式重新估计RDD
keep if margin>=-.5 & margin<=.5
gen d=margin>0
gen x=margin
gen x2=x^2
gen x3=x^3
gen x4=x^4
eststo m1:reg vote d# #c.x,vce(robust)
eststo m2:reg vote d# #c.(x x2),vce(robust)
eststo m3:reg vote d# #c.(x x2 x3),vce(robust)
eststo m4:reg vote d# #c.(x x2 x4),vce(robust)
esttab m1 m2 m3 m4 using lpr.rtf,star(* 0.10 ** 0.05 *** 0.01) nogap nonumber replace

*下面进行相关稳健性检验
*伪断点检验
rdplot vote margin if margin<0,c(-.25) graph_options(legend(off) title("") xlabel(-.5(.1)0))
rdplot vote margin if margin>=0,c(.25) graph_options(legend(off) title("") xlabel(0(.1).5))



