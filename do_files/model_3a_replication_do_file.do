** model_3a_replication_do_file.do
* Description: Cuervo-Cazurra and Genc (2008) replication - model 3a
* Author: Andrew Kent Johnston
* Date: May 31, 2024

* Clear the workspace
clear all
set more off

* ----- Data Import -----
import delimited using "../main_dataset.csv", clear

* ----- Data Cleaning and Filtering -----
* Dropping entities with incomplete observations for both years
egen row_missing = rowmiss(prop_emnes c1_voice_and_acc c2_pol_stability c3_gov_effectiveness c4_reg_quality c5_rule_of_law c6_control_of_corruption gni_per_capita perc_roads_paved total_phones_per_1000 geographic_proximity)
bysort country: egen total_missing = total(row_missing)
drop if total_missing > 0

* Generating a numeric ID for countries
egen country_id = group(country)

* ----- Data Analysis -----
* Declaring the data as panel data using the new country ID
xtset country_id year

* Running a random effects panel Tobit model with bounds
log using "../results/model_3a_replication.log", replace text

xttobit prop_emnes_excl_former_col_power gni_per_capita perc_roads_paved total_phones_per_1000 geographic_proximity, ll(0) ul(100) re

* Store the results of the random effects model
estimates store re_model

log close

* Estimating a pooled Tobit model
log using "../results/model_3a_replication.log", append text

tobit prop_emnes_excl_former_col_power gni_per_capita perc_roads_paved total_phones_per_1000 geographic_proximity, ll(0) ul(100)

* Store the results of the pooled Tobit model for later comparison
estimates store pooled_model

log close

* ----- Summary Statistics and Correlation Matrix -----
* Log the summary statistics and correlation matrix
log using "../results/model_3a_replication.log", append text

summarize prop_emnes_excl_former_col_power gni_per_capita perc_roads_paved total_phones_per_1000 geographic_proximity 

pwcorr prop_emnes_excl_former_col_power gni_per_capita perc_roads_paved total_phones_per_1000 geographic_proximity, star(0.05)

log close