# waves2months

`waves2months` encodes the calendar months associated with each Understanding America Study wave in which an education module was administered, beginning with UAS235. The months of administration are derived from the `start_date` and `end_date` variables contained in each wave file, though users are allowed to pass their own date variables to the program. The dates **must** be in `%td` format. Users must also provide a wave crosswalk file with the UAS administration identifier for each included wave collection. A crosswalk file (through UAS479) is included as an ancillary file in the `waves2months` package (`wavecodes.xlsx`).

# Installation
`net install waves2months, from(https://raw.githubusercontent.com/marshallwg/waves2months/main/)`

# Syntax

## Main
You must supply a variable containing the name of the variable containing the survey wave code. Typically, this variable is named `wave` in UAS data files.

## Options (required)
### `start`
Variable containing the survey start date for each respondent.
### `end`
Variable containing the survey end date for each respondent.
### `wavemonths`
New variable with the calendar months in which each wave was administered attached. The value label adopts the same name as the new variable.
## Options (optional)
### `replace`
Option to replace the `wavemonths` variable if it exists.
### `xwalk`
File name (or path and file name) of the wave crosswalk file. This file is used to attach UAS wave identifiers to the sequential wave counter (e.g., UA479 to wave 29). The file must be in .xlsx format, and the three-digit UAS wave identifier must be stored in a variable named `waves` and the wave counter must be stored in a variable named `wavecodes`. Note that this replaces any existing labels attached to the `wave` variable. 

# Usage
To affix calendar month administration windows to the UAS waves in your current working file:

```
waves2months wave, start(start_date) end(end_date) wavemonths(new) ///
	xwalk(wavecodes.xlsx)
```
