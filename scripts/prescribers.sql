--1a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
SELECT SUM(total_claim_count) AS claim_total, npi
FROM prescription
GROUP by npi
ORDER BY claim_total DESC
--Answer: NPI:1881634483 Claim_Total:99707

--1b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.
SELECT SUM(total_claim_count) AS claim_count, 
		prescriber.npi,
		nppes_provider_first_name, 
		nppes_provider_last_org_name,  
		specialty_description
FROM prescriber
INNER JOIN prescription
ON prescription.npi=prescriber.npi
GROUP BY
		prescriber.nppes_provider_first_name, 
		prescriber.nppes_provider_last_org_name,  
		prescriber.specialty_description,
		prescriber.npi
ORDER BY claim_count DESC;
--Answer: 99707	"BRUCE"	"PENDLEY"	"Family Practice"

--2a. Which specialty had the most total number of claims (totaled over all drugs)?
SELECT SUM(total_claim_count) AS claim_count, 
	prescriber.specialty_description
FROM prescriber
INNER JOIN prescription
ON prescription.npi=prescriber.npi
GROUP BY  prescriber.specialty_description
ORDER BY claim_count DESC;
--Answer: Claim Count:9752347	Specialty:"Family Practice"

--2b. Which specialty had the most total number of claims for opioids?
SELECT SUM(total_claim_count) AS claim_count,
	p.specialty_description
FROM prescriber AS p
INNER JOIN prescription AS script
ON p.npi=script.npi
INNER JOIN drug as d
ON script.drug_name=d.drug_name
WHERE d.opioid_drug_flag = 'Y' OR d.long_acting_opioid_drug_flag = 'Y'
GROUP BY  p.specialty_description
ORDER BY claim_count DESC;
--Answer: 900845	"Nurse Practitioner"

--2c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?
--2d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

--3a. Which drug (generic_name) had the highest total drug cost?
SELECT SUM(total_drug_cost) AS drug_cost,
		d.generic_name
FROM prescription AS p
INNER JOIN drug as d
ON p.drug_name=d.drug_name
GROUP BY d.generic_name
ORDER BY drug_cost DESC;
--Answer: Cost: 104264066.35	"INSULIN GLARGINE,HUM.REC.ANLOG"

--3b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**
SELECT ROUND(p.total_drug_cost/30,2) AS cost_per_day, d.generic_name
FROM prescription AS p
INNER JOIN drug as d
ON p.drug_name=d.drug_name
GROUP BY d.generic_name, p.total_drug_cost, p.total_30_day_fill_count
ORDER BY cost_per_day DESC;
--Answer: Cost:94305.81	"PIRFENIDONE"


--4a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. **Hint:** You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/ 

SELECT 
drug_name,
CASE WHEN opioid_drug_flag= 'Y' THEN 'opioid' 
	  WHEN antibiotic_drug_flag ='Y' THEN 'antibiotic'
	 ELSE 'null' END AS drug_type
FROM drug;

--4b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
SELECT
	p.drug_name,
	p.total_drug_cost
CASE WHEN opioid_drug_flag= 'Y' THEN 'opioid' 
	  WHEN antibiotic_drug_flag ='Y' THEN 'antibiotic'
	 ELSE 'null' END AS drug_type
FROM prescription AS p
INNER JOIN drug as d
ON d.drug_name=p.drug_name
GROUP BY d.drug_name, d.total_drug_cost;


--5a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
SELECT COUNT(f.state) AS state_count
FROM cbsa as c
INNER JOIN fips_county as f
ON c.fipscounty=f.fipscounty
WHERE f.state='TN';
--Answer=42

--5b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
SELECT COUNT (p.population) AS pop_count, c.cbsaname
FROM cbsa AS c
INNER JOIN population AS p
ON c.fipscounty=p.fipscounty
GROUP BY c.cbsaname
ORDER BY pop_count ASC;
--Answer:
	--Largest: 14	"Nashville-Davidson--Murfreesboro--Franklin, TN"
	--Smallest: 1	"Clarksville, TN-KY"
--5c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
SELECT p.population,
c.fipscounty AS cbsa_county, p.fipscounty AS p_county, c.cbsaname, f.county
FROM population AS p
LEFT JOIN cbsa AS c
ON p.fipscounty=c.fipscounty
LEFT JOIN fips_county as f
ON p.fipscounty=f.fipscounty
GROUP BY c.fipscounty, p.fipscounty,p.population, c.cbsaname, f.county
ORDER BY p.population DESC;
--Answer: Shelby

--6a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
SELECT 
		drug_name, total_claim_count
FROM prescription
WHERE total_claim_count >=3000;

--6b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
SELECT 
		d.drug_name, p.total_claim_count
FROM prescription as p
LEFT JOIN drug as d
ON p.drug_name=d.drug_name
WHERE p.total_claim_count >=3000 AND d.opioid_drug_flag='Y'
GROUP BY d.drug_name, p.total_claim_count

--6c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
SELECT 
		d.drug_name, p.total_claim_count, pres.nppes_provider_first_name, pres.nppes_provider_last_org_name
FROM prescription as p
LEFT JOIN drug as d
ON p.drug_name=d.drug_name
LEFT JOIN prescriber as pres
ON pres.npi=p.npi
WHERE p.total_claim_count >=3000 AND d.opioid_drug_flag='Y'
GROUP BY d.drug_name, p.total_claim_count, pres.nppes_provider_first_name, pres.nppes_provider_last_org_name;

--7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.
--7a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.
SELECT
	p.specialty_description,
	p.npi,
	p.nppes_provider_city,
	d.opioid_drug_flag
FROM prescriber AS p
LEFT JOIN prescription AS script
	ON p.npi=script.npi
LEFT JOIN drug as d
	ON script.drug_name=d.drug_name
WHERE p.specialty_description = 'Pain Management' 
		AND p.nppes_provider_city = 'NASHVILLE' 
		AND d.opioid_drug_flag = 'Y'

--7b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).
--7c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.

 
