*! version 1.5.0 08oct2016
program define fisid
	syntax varlist [if] [in], [Missok Show]
	loc show = ("`show'" != "")
	loc missok = ("`missok'" != "")

	marksample touse, novar

	if (!`missok') {
		qui cou if `touse'
		loc N = r(N)
		markout `touse' `varlist', strok
		qui cou if `touse'
		if r(N) < `N' {
			local n : word count `varlist'
			local var = cond(`n'==1, "variable", "variables")
			di as err "`var' `varlist' should never be missing"
			exit 459
		}
	}

	mata: fisid("`varlist'", "`touse'", `missok')

	if (!`ok') {
	        loc n : word count `varlist'
	        loc var  = cond(`n'==1, "variable", "variables")
	        loc does = cond(`n'==1, "does", "do")
	        loc msg `var' `varlist' `does' not ///
	        	uniquely identify the observations
	        di as err "`msg'"
	        exit 459
	}
end

mata:
void fisid(string rowvector varnames,
         | string scalar touse,
           real scalar show)
{
	class Factor scalar		F
	real scalar				ok

	F = factor(varnames, touse, 0, "", 0, 1)
	ok = (max(F.counts) == 1)
	st_local("ok", strofreal(ok))
}
end

ftools check
exit
