** model_2b_replication_do_file.do
* Description: Cuervo-Cazurra and Genc (2008) replication - model 2b
* Author: Andrew Kent Johnston
* Date: May 31, 2024

* Clear the workspace
clear all
set more off

* ----- Data Import -----
import delimited using "main_dataset.csv", clear

* ----- Data Cleaning and Filtering -----
* Renaming variables
rename c1 voice_and_accountability
rename c2 pol_stab_abs_violence
rename c3 government_effectiveness
rename c4 regulatory_quality
rename c5 rule_of_law
rename c6 control_of_corruption

* Dropping entities with incomplete observations for both years
egen row_missing = rowmiss(perc_emnes_excl_nat_res voice_and_accountability pol_stab_abs_violence government_effectiveness regulatory_quality rule_of_law control_of_corruption gni_per_capita roads_paved_pct phones_per_1000 geographic_proximity colonial_link)
bysort country: egen total_missing = total(row_missing)
drop if total_missing > 0

* Generating a numeric ID for countries
egen country_id = group(country)

* ----- Data Analysis -----
* Declaring the data as panel data using the new country ID
xtset country_id year

* Running a random effects panel Tobit model with bounds
capture log close
log using model_2b_re_tobit_model.log, replace
xttobit perc_emnes_excl_nat_res voice_and_accountability pol_stab_abs_violence government_effectiveness regulatory_quality rule_of_law control_of_corruption gni_per_capita roads_paved_pct phones_per_1000 geographic_proximity colonial_link, ll(0) ul(100) re
log close

* Store the results of the random effects model
estimates store re_model

* Estimating a pooled Tobit model
capture log close
log using model_2b_pooled_tobit_model.log, replace
tobit perc_emnes_excl_nat_res voice_and_accountability pol_stab_abs_violence government_effectiveness regulatory_quality rule_of_law control_of_corruption gni_per_capita roads_paved_pct phones_per_1000 geographic_proximity colonial_link, ll(0) ul(100)
log close

* Store the results of the pooled Tobit model for later comparison
estimates store pooled_model

* ----- Summary Statistics and Correlation Matrix -----
* Log the summary statistics and correlation matrix
capture log close
log using model_2b_summary_stats_and_corr_matrix.log, replace
summarize perc_emnes_excl_nat_res voice_and_accountability pol_stab_abs_violence government_effectiveness regulatory_quality rule_of_law control_of_corruption gni_per_capita roads_paved_pct phones_per_1000 geographic_proximity colonial_link
pwcorr perc_emnes_excl_nat_res voice_and_accountability pol_stab_abs_violence government_effectiveness regulatory_quality rule_of_law control_of_corruption gni_per_capita roads_paved_pct phones_per_1000 geographic_proximity colonial_link, star(0.05)
log close

* End of do-file