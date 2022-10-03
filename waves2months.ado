*!Marshall Garland: garlandm@usc.edu
*!Version 1.0
capture program drop waves2months
program define waves2months, rclass
	version 9.2
	syntax varlist(max=1) , ///
		START(varlist numeric max=1 max=1) /// start variable in the UAS. Typically start_date
		END(varlist numeric min=1 max=1) /// end month variable in the UAS. Typically end_date
		WAVEMonths(string) [ /// variable name for the new wave months variable
		REPlace /// optional replace
		Xwalk(string) /// path to xwalk file
		]
//0.0: Place wave variable into a local. Also, install dependencies.
local wavevar "`varlist'"
local dep gtools
foreach d in `dep' {
	cap which `d'
	if _rc!=0 {
		ssc install `d'
	}
}

*!!!!!!!!!!!!!!!!!!
//Error checking
//0.1 Confirm Start/End variables are %td format
cap assert "`:format `start''"=="%td"
if _rc!=0 {
	di as error "Start variable must be formatted as %td. " as text "It's currently formatted as " as result "`:format `start''."
	exit 170
}
cap assert "`:format `end''"=="%td"
if _rc!=0 {
	di as error "End variable must be formatted as %td. " as text "It's currently formatted as " as result "`:format `end''."
	exit 170
}

//0.2 Confirm valid x-walk file is available.
if !mi("`xwalk'") {
	cap confirm file "`xwalk'"
	if _rc!=0 {
		di as error "Cross-walk file doesn't exist!"
		exit 170
	}
}

//0.3 Confirm xwalk file is .xlsx
//Getting complete filename
if !mi("`xwalk'") {
	_getfilename "`xwalk'"
	local one=reverse("`r(filename)'")
	local two=strpos("`one'", ".")+1
	//Extract extension
	local ext=reverse(substr("`one'", 1, `two'-2))
	cap assert "`ext'"=="xlsx"
	if _rc!=0 {
		di as error "File should be xlsx!"
		exit 170
	}
}

//0.4 Checking to see if new wavemonth variable exists.
if !mi("`replace'") {
	cap drop `wavemonths'
}

cap confirm variable `wavemonths'
if mi("`replace'") & _rc==0 {
	di as error "Variable `wavemonths' already exists. " ///
		as text "Specify option " ///
		as result "-replace-" as text " to overwrite existing variable."
	exit 170
}

*!!!!!!!!!!!!!!!!!!

*!!!!!!!!!!!!!!!!!!
//Create labels if wave-file provided.
if !mi("`xwalk'") {
	//1.0
	qui {
		preserve
			import excel using "`xwalk'", allstring clear firstrow
			drop if mi(wavecodes)
			tempvar aa
			gen `aa'="label define _wave "+wavecodes+" "+`""UAS"'+waves+`"""'+", modify"
			tempfile zzz
			keep `aa'
			outsheet using `zzz', replace noquote nonames
		restore

		do `zzz'
		label values `wavevar' _wave
	}
}

//Generate month-year range labels for each wave.
//1.1
gen `wavemonths'=`wavevar'
qui {
	glevelsof `wavevar', local(levels)
	foreach l of local levels {
		//Extract first month, last month, first year, last year from each wave value.
		//First month/year
		quietly sum `start' if `wavevar'==`l'
		local fm `:di month(`r(min)')'
		local fy `:di year(`r(min)')'
		//String month
		local fm="`:word `fm' of `c(Months)''"
		//Last month/year
		quietly sum `end' if `wavevar'==`l'
		local lm `:di month(`r(max)')'
		local ly `:di year(`r(max)')'
		//String monmth
		local lm="`:word `lm' of `c(Months)''"
		local range
		if `ly'==`fy' local range "`fm'-`lm' `ly'"
		if `ly'!=`fy' local range "`fm' `fy'-`lm' `ly'"
		label define `wavemonths' `l' "`range'", modify
	}

	label values `wavemonths' `wavemonths'
}

end
