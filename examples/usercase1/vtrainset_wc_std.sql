#DATASPOT-TERADATA

/*SEL * FROM mi_prod.automodelling;*/


SHOW VIEW mi_vm_bmd.vtrainset_wc_std;

/* nu op klant-nivo */

-- REPLACE VIEW Mi_vm_bmd.vtrainset_wc_std AS (
create table Mi_vm_bmd.vtrainset_wc_std AS (

SELECT		y.*
						, x.model_id
                                                , x.response_dt 
						, x.TARGET
FROM 

/* target-bepaling */

(
SELECT	a.business_contact_nr
,a.model_id
,a.response_dt
,CASE WHEN b.business_contact_nr IS NOT NULL THEN 1 ELSE 0 END AS TARGET
		FROM	( /* Get all views from the past 90 days (3 months) */
		SELECT	business_contact_nr
			,external_response_info_id1 AS model_id
			,response_dt
			FROM mi_vm_retail_1op1.vreport_response_online a
			WHERE response_dt >= DATE - 90
			AND response_cd = 'U22'
			AND model_id IS NOT NULL
			) a
		LEFT JOIN ( /* Get all clicks from the same 90-day period, check if the day of a view also has a click */
			SELECT	business_contact_nr
			,external_response_info_id1 AS model_id
			,response_dt
			FROM  mi_vm_retail_1op1.vreport_response_online a
			WHERE response_dt >= DATE - 90
			AND response_cd='U24'
			AND model_id IS NOT NULL
			) b
		ON a.business_contact_nr = b.business_contact_nr
		AND a.model_id = b.model_id
		AND b.response_dt = a.response_dt
qualify row_number() over (partition by a.business_contact_nr, a.model_id 
                     order by case when b.business_contact_nr is not null then 1 else 0 end desc,a.response_dt asc)=1
) x


/***********************/
/* profiel theia_basis */
/***********************/
INNER JOIN	(SELECT	b.bc AS party_id, 'BC' AS party_sleutel_type
			,b.maand
                        ,a.draai_datum
			,CASE WHEN a.max_leeftijd < 25				THEN	1 
			WHEN	a.max_leeftijd < 35				THEN	2
			WHEN	a.max_leeftijd < 45				THEN	3
			WHEN	a.max_leeftijd < 55				THEN	4 
			WHEN	a.max_leeftijd < 65				THEN	5 
     			ELSE								6 			END																			AS Leeftijd
			,CASE WHEN ZeroIfNull(a.voeding_min_3mnd) = 0		THEN	1 
			WHEN	a.voeding_min_3mnd < 500 			THEN	2
			WHEN	a.voeding_min_3mnd < 1500			THEN	3 
			WHEN	a.voeding_min_3mnd < 2500			THEN	4
			WHEN	a.voeding_min_3mnd < 4000			THEN	5
			WHEN	a.voeding_min_3mnd < 6000			THEN	6
			ELSE								7			END																			AS Voeding
			,CASE WHEN ZeroIfNull(a.credit_volume) < 100		THEN	1
			WHEN	a.credit_volume < 2500				THEN	2
			WHEN	a.credit_volume < 10000				THEN	3 
			WHEN	a.credit_volume < 25000				THEN	4
			WHEN	a.credit_volume < 50000				THEN	5
			WHEN	a.credit_volume < 100000			THEN	6
			ELSE								7 			END																			AS Creditvolume
			,ZeroIfNull(a.geohh_inkomen_code) AS Inkomen
			,ZeroIfNull(a.geohh_opleiding_code) AS Opleiding
			,ZeroIfNull(a.n_schade) AS Schade_Verzekeren
			,CASE WHEN a.n_bereikt_trigger_digitaal_laatste_12mnd+a.n_bereikt_eenmalig_digitaal_laatste_12mnd=0 THEN 1
			WHEN a.n_bereikt_trigger_digitaal_laatste_12mnd+a.n_bereikt_eenmalig_digitaal_laatste_12mnd<=3 THEN 2
			WHEN a.n_bereikt_trigger_digitaal_laatste_12mnd+a.n_bereikt_eenmalig_digitaal_laatste_12mnd<=5 THEN 3
			WHEN a.n_bereikt_trigger_digitaal_laatste_12mnd+a.n_bereikt_eenmalig_digitaal_laatste_12mnd<=10 THEN 4
			WHEN a.n_bereikt_trigger_digitaal_laatste_12mnd+a.n_bereikt_eenmalig_digitaal_laatste_12mnd<=25 THEN 5
			WHEN a.n_bereikt_trigger_digitaal_laatste_12mnd+a.n_bereikt_eenmalig_digitaal_laatste_12mnd>25 THEN 6
			ELSE 9 end AS Bereikt_Digitaal
			,CASE WHEN a.ndagen_laatste_productafname<=180 THEN 1
			WHEN a.ndagen_laatste_productafname<=360 THEN 2
			WHEN a.ndagen_laatste_productafname<=1800 THEN 3
			ELSE 9 end AS Laatste_Productafname
			,CASE WHEN a.Ndagen_Roodstand_Laatste_Mnd=0 THEN 0 ELSE 1 end AS Roodstand
                        ,CASE WHEN ZeroIfNull(a.Ndagen_Click_Gedrag_Laatste_Mnd)=0 THEN 1 
			WHEN ZeroIfNull(a.Ndagen_Click_Gedrag_Laatste_Mnd)<5 THEN 2
			WHEN ZeroIfNull(a.Ndagen_Click_Gedrag_Laatste_Mnd)<15 THEN 3
			WHEN ZeroIfNull(a.Ndagen_Click_Gedrag_Laatste_Mnd)<25 THEN 4
			ELSE 5 end AS Click_Gedrag_Laatste_Mnd
			,CASE WHEN ZeroIfNull(a.Ndagen_Click_Gedrag_Laatste_12Mnd)=0 THEN 1 
			WHEN ZeroIfNull(a.Ndagen_Click_Gedrag_Laatste_12Mnd)<50 THEN 2
			WHEN ZeroIfNull(a.Ndagen_Click_Gedrag_Laatste_12Mnd)<150 THEN 3
			WHEN ZeroIfNull(a.Ndagen_Click_Gedrag_Laatste_12Mnd)<250 THEN 4
			ELSE 5 end AS Click_Gedrag
			,Case when N_Debet_Trx_Kinderen_Laatste_Mnd+N_Credit_Trx_Kinderen_Laatste_Mnd>20 then 1 
			when N_Debet_Trx_Kinderen_Laatste_Mnd+N_Credit_Trx_Kinderen_Laatste_Mnd>10 then 2
			when N_Debet_Trx_Kinderen_Laatste_Mnd+N_Credit_Trx_Kinderen_Laatste_Mnd>5 then 3
			when N_Debet_Trx_Kinderen_Laatste_Mnd+N_Credit_Trx_Kinderen_Laatste_Mnd>0 then 4
			else 5 end as Trx_Kinderen,
			case when n_debet_trx_laatste_mnd>100 then 1	
			when n_debet_trx_laatste_mnd> 50 then 2	
			when n_debet_trx_laatste_mnd>30 then 3	
			when n_debet_trx_laatste_mnd>20  then 4	
			when n_debet_trx_laatste_mnd>10  then 5	
			when n_debet_trx_laatste_mnd>5 then 6	
			when n_debet_trx_laatste_mnd>0 then 7 else 8 end as N_Debet_Trx,
			Case when zeroifnull(c.ce_score)=0 then 1 else 0 end as CE_Nul,
			Case when zeroifnull(c.ce_score)=3 then 1 else 0 end as CE_Minimum,
			Case when zeroifnull(c.ce_score)=4 then 1 else 0 end as CE_Laag,
			Case when zeroifnull(c.ce_score)>4 then ce_score-4 else 0 end as CE,
			Overlijdens_Risico_Verzekering as ORV, 
                        Wallet  
			FROM	Mi_vm_info.vlu_bc b
			JOIN	Mi_vm_bmd.vtheia_basis a
				ON b.fhh=a.fhh
				AND b.maand=a.maand
			LEFT OUTER JOIN MI_vm_bmd.vcustomer_engagement_scores c
                                ON b.bc=c.bc
                                AND b.maand=c.maand
			/** Select only months that are relevant */
			WHERE b.maand IN (SELECT DISTINCT maand_nr FROM mi_vm.vkalender WHERE datum BETWEEN Add_Months(DATE - 90, -1) AND DATE)
			) y
				ON x.business_contact_nr=y.party_id
                                AND x.response_dt>y.draai_datum + 2 

qualify row_number() over (partition by x.business_contact_nr,x.model_id order by y.draai_datum desc)=1
);