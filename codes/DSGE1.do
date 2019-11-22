*DSGE初试，@David Schenck：Estimating the parameters of DSGE models，2017，
*https://blog.stata.com/2017/07/11/estimating-the-parameters-of-dsge-models/

*使用美联储数据
webuse usmacro2;

*声明模型
dsge (x = E(F.x) - (r - E(F.p) - z), unobserved) ///
       (p = {beta}*E(F.p) + {kappa}*x)             ///
       (r = 1/{beta}*p + u)                        ///
       (F.z = {rhoz}*z, state)                     ///
       (F.u = {rhou}*u, state)

*脉冲响应图
irf set dsge_irf;/*用irf set创建脉冲图文件*/
irf create model1;/*用irf create创建一系列脉冲图*/

*画出脉冲响应图
irf graph irf, impulse(u) response(x p r u) byopts(yrescale) yline(0)；
