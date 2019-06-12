#DATASPOT-TERADATA

CREATE TABLE MI_TEMP.SYS_CALENDAR as(
		select calendar_date,
					year_of_calendar,
					quarter_of_year
		from sys_calendar.CALENDAR) with data and stats;

CREATE TABLE mi_temp.AA_contracten AS
		(
		SELECT
			A.maand_nr
			, A.klant_nr
			, a.cmb_sector
			, a.business_line
			, a.segment
			, a.verkorte_naam
			, relatiemanager
			, a.bo_naam
			, a.org_niveau3
			, a.org_niveau2
			, a.org_niveau1
			, B.cbc_oid AS business_contact_nr
			, B.contract_nr
			, B.contract_oid
			, B.contract_soort_code
			, C.contract_hergebruik_volgnr
			, XA.maand_startdatum , XA.maand_einddatum
		 , b.contract_ingang_datum , b.contract_vervallen_datum

		FROM mi_cmb.vmia_hist A

		JOIN mi_vm_nzdb.vLU_Maand XA
		ON A.maand_nr = XA.maand

		JOIN mi_vm_nzdb.vcontract B
		ON A.maand_nr = B.maand_nr
		AND A.klant_nr = B.cc_nr
		AND B.contract_soort_code IN (5)

		JOIN mi_vm_ldm.vcontract C
		ON B.contract_nr = C.contract_nr
		AND B.contract_soort_code = C.contract_soort_code

		AND C.contract_sdat LE XA.maand_einddatum
		AND (C.contract_edat GT XA.maand_einddatum OR C.contract_edat IS NULL)
		AND c.vervallen_datum IS NULL

		WHERE A.maand_nr = (SELECT MAX(MAAND_NR) FROM mi_cmb.vmia_hist)
		AND A.klantstatus = 'C'
		AND A.klant_ind = 1
		AND A.business_line IN ('CBC', 'SME')

) WITH DATA
PRIMARY INDEX(klant_nr,business_contact_nr,contract_nr) INDEX(business_contact_nr) INDEX(contract_nr);



CREATE TABLE mi_temp.AA_klantnummers AS
		(
		SELECT DISTINCT klant_nr
		FROM mi_temp.AA_contracten
		)
WITH DATA
PRIMARY INDEX (klant_nr)
;



CREATE TABLE mi_temp.AA_alle_contracten AS
		(
		SELECT
			A.maand_nr
			, A.klant_nr
			, a.cmb_sector
			, a.business_line
			, a.segment
			, a.verkorte_naam
			, relatiemanager
			, a.bo_naam
			, a.org_niveau3
			, a.org_niveau2
			, a.org_niveau1
			, B.cbc_oid AS business_contact_nr
			, B.contract_nr
			, B.contract_oid
			, B.contract_soort_code
			, C.contract_hergebruik_volgnr
			, XA.maand_startdatum , XA.maand_einddatum
		 , b.contract_ingang_datum , b.contract_vervallen_datum

		FROM mi_cmb.vmia_hist A

		JOIN mi_vm_nzdb.vLU_Maand XA
		ON A.maand_nr = XA.maand

		JOIN mi_vm_nzdb.vcontract B
		ON A.maand_nr = B.maand_nr
		AND A.klant_nr = B.cc_nr

		JOIN mi_vm_ldm.vcontract C
		ON B.contract_nr = C.contract_nr
		AND B.contract_soort_code = C.contract_soort_code

		AND C.contract_sdat LE XA.maand_einddatum
		AND (C.contract_edat GT XA.maand_einddatum OR C.contract_edat IS NULL)

/*DE TUSSENTABELLEN WORDEN GECREEERD VOOR ALLE KLANTEN IN CC ÉN YBB VOOR DE LAATSTE MAAND IN VMIA_HIST*/
		WHERE A.maand_nr = (SELECT MAX(MAAND_NR) FROM mi_cmb.vmia_hist)
		AND A.klantstatus = 'C'
		AND A.klant_ind = 1
		AND A.business_line IN ('CBC', 'SME')

) WITH DATA
PRIMARY INDEX(klant_nr,business_contact_nr,contract_nr) INDEX(business_contact_nr) INDEX(contract_nr);




CREATE  TABLE mi_temp.AA_subset_mia_hist AS
		(
		SELECT a.*
		FROM mi_cmb.vmia_hist a
		INNER JOIN mi_temp.AA_klantnummers  b ON a.klant_nr = b.klant_nr
		WHERE maand_nr > 201201
		)
WITH DATA
PRIMARY INDEX (klant_nr, maand_nr);




INSERT INTO Mi_temp.AA_OK_maanden
SELECT
     maand
    ,maand_sdat
    ,maand_edat
FROM Mi_vm.vlu_maand                      lm
WHERE lm.maand BETWEEN 201501 AND  (SELECT MAX(Maand_nr) FROM mi_cmb.vcif_complex_MF)
;





CREATE TABLE mi_temp.AA_OK_kredieten_t1 AS
		(
		SELECT  mnd.maand_nr AS maand
		    ,mnd.Ultimomaand_eind_datum_tee AS datum
		    ,a.contract_soort_code
		    ,CASE WHEN a.contract_soort_code = 5 THEN 'RC'
		          WHEN a.contract_soort_code = 13 THEN 'Mahuko'
		         ELSE a.contract_soort_code
		     END Contract_soort
		    ,a.Contract_hergebruik_volgnr
		    ,a.contract_nr
		    ,a.ingang_datum
		    ,a.expiratie_datum
		    ,a.vervallen_datum

		    ,a.product_id

		    ,c.business_contact_nr AS BC
		    ,d.limiet_bedrag
		    ,e.saldo
		    ,CASE WHEN b.limiet_eis_ind = 1 THEN ZEROIFNULL(d.limiet_bedrag)
		          WHEN ZEROIFNULL(e.Saldo) < 0 THEN -e.Saldo
		          ELSE 0
		     END AS OOE
		    ,CASE WHEN b.Aflopend_krediet_ind = 0 AND e.Saldo < 0 THEN e.Saldo
		          WHEN b.Aflopend_krediet_ind = 1 THEN NULL
		          ELSE 0
		     END     AS Doorlopend_opgenomen
		    ,CASE WHEN b.Aflopend_krediet_ind = 0 AND ZEROIFNULL(e.Saldo) < 0 AND ZEROIFNULL(d.Limiet_bedrag) > 0
		                THEN (((-Doorlopend_opgenomen (FLOAT)) / ( NULLIFZERO(d.Limiet_bedrag) (FLOAT)))* (100 (FLOAT)) )
		          WHEN b.Aflopend_krediet_ind = 0 AND e.Saldo >= 0 THEN 0
		           ELSE NULL
		      END  AS Doorlopend_uitnutt_perc
		    ,CASE WHEN b.Aflopend_krediet_ind = 1 THEN e.Saldo ELSE NULL END     AS Saldo_MIDL
		    ,a.Valuta_code_oorspronkelijk

		FROM Mi_vm_ldm.hContract  a

		INNER JOIN Mi_temp.AA_OK_Maanden    Mnd
   				ON a.maand = mnd.maand_nr

		INNER JOIN Mi_cmb.Kredieten_OK_GRV    b
		   ON b.GRV = a.herkomst_administratie_key
		  AND b.OK_GRV_sdat <= Mnd.Ultimomaand_eind_datum_tee
		  AND (b.OK_GRV_edat IS NULL OR b.OK_GRV_edat >= Mnd.Ultimomaand_eind_datum_tee)

		  INNER JOIN mi_temp.AA_contracten c
		  		ON c.contract_nr = a.contract_nr

		LEFT OUTER JOIN mi_vm_ldm.hlening_contract_limiet       d
		   ON d.Contract_nr = a.Contract_nr
		  AND d.Contract_soort_code = a.Contract_soort_code
		  AND d.Contract_hergebruik_volgnr = a.Contract_hergebruik_volgnr
		  AND d.maand = mnd.maand_nr

		LEFT OUTER JOIN mi_vm_ldm.hgeld_contract_samenv    e
		   ON e.Contract_nr = a.Contract_nr
		  AND e.Contract_soort_code = a.Contract_soort_code
		  AND e.Contract_hergebruik_volgnr = a.Contract_hergebruik_volgnr
		  AND e.Periode_code = 'M'
		  AND e.maand = mnd.maand_nr

		WHERE a.herkomst_admin_key_soort_code = 'GRV'
				  AND a.Contract_sdat <= Mnd.Ultimomaand_eind_datum_tee
				  AND (a.Contract_edat   IS NULL OR a.Contract_edat   >= Mnd.Ultimomaand_eind_datum_tee)
				  AND a.contract_status_code <> 3

				  AND (b.limiet_eis_ind = 0 OR (b.limiet_eis_ind = 1 AND ZEROIFNULL(d.limiet_bedrag) <> 0 ))
				  AND (b.saldo_eis_ind  = 0 OR (b.saldo_eis_ind  = 1 AND ZEROIFNULL(e.saldo) < 0 )))
WITH DATA
PRIMARY INDEX (contract_nr, bc)
;


CREATE TABLE mi_temp.AA_kredietoverzicht_mnd_oud AS
		(
		SELECT b.Klant_nr
				, a.maand_nr
				, SUM(CASE WHEN saldo_doorlopend < 0 THEN saldo_doorlopend ELSE 0 END ) AS doorlopend_opgenomen
				, SUM(a.limiet_krediet) AS limiet_krediet
				, SUM(CASE WHEN saldo_doorlopend < 0 THEN saldo_doorlopend ELSE 0 END ) / SUM(NULLIFZERO(-a.limiet_krediet)) AS doorlopend_uitn_perc
				, SUM(saldo_aflopend) AS saldo_aflopend

		FROM mi_cmb.vmia_kredieten_hfd  a

		INNER JOIN mi_temp.aa_contracten b ON a.contract_nr = b.contract_nr
		INNER JOIN mi_cmb.vmia_week c ON c.klant_nr = b.klant_nr


		WHERE a.maand_nr <= 201412
				AND (a.contract_soort_code <> 5 OR  (a.contract_soort_code = 5 AND a.krediet_categorie_risk = 'OK') )

		GROUP BY 1,2
		)
WITH DATA
PRIMARY INDEX (klant_nr, maand_nr);


CREATE TABLE mi_temp.AA_kredietoverzicht_mnd_nw AS
		(
		SELECT b.klant_nr
				, a.maand_nr
				, SUM(doorlopend_opgenomen) AS doorlopend_opgenomen
				, SUM(limiet_krediet) AS limiet
				, SUM(a.doorlopend_opgenomen) / SUM(NULLIFZERO(a.limiet_krediet)) AS doorlopend_uitn_perc
				, SUM(saldo_aflopend) AS saldo_aflopend

		FROM
				(
				SELECT
						(a.contract_nr (BIGINT))
						, a.maand_nr AS maand_nr
						, SUM(a.doorlopend_opgenomen) AS doorlopend_opgenomen
						, SUM(a.doorlopend_limiet) AS limiet_krediet
						, SUM(a.doorlopend_opgenomen) / SUM(NULLIFZERO(a.doorlopend_limiet)) AS doorlopend_uitn_perc
						, SUM(doorlopend_saldo)  AS saldo_doorlopend
						, SUM(aflopend_saldo) AS saldo_aflopend
						, NULL AS debetvolume

				FROM mi_cmb.vCIF_complex_MF a
				JOIN mi_temp.AA_OK_kredieten_t1 a
				ON 1=1
				GROUP BY 1,2

				) a

		LEFT JOIN mi_temp.AA_contracten b ON b.contract_nr = a.contract_nr

		INNER JOIN mi_cmb.vmia_week c ON c.klant_nr = b.klant_nr


		WHERE a.maand_nr > 201412

		GROUP BY 1,2
		)
WITH DATA
PRIMARY INDEX (klant_nr, maand_nr);


CREATE TABLE mi_temp.AA_kredietverleden_klant_M AS
(SELECT
				a.klant_nr
				, a.maand_nr
				, (SUBSTR(TRIM(a.maand_nr), 1, 4) (INT)) AS jaar
				, ((SUBSTR(TRIM(a.Maand_nr), 5, 2) (INT)) - 1) / 3 + 1 AS kwartaal
				, (TRIM((SUBSTR(TRIM(a.maand_nr), 1, 4) (INT))) || TRIM(((SUBSTR(TRIM(a.Maand_nr), 5, 2) (INT)) - 1) / 3 + 1) (INT)) AS kwartaal_nr
				, b.doorlopend_opgenomen
				, b.limiet_krediet
				, b.doorlopend_uitn_perc
				, b.saldo_aflopend
				, ZEROIFNULL(Saldo_aflopend - SUM(saldo_aflopend) OVER (PARTITION BY b.Klant_nr ORDER BY b.klant_nr, b.Maand_nr ROWS BETWEEN 1 FOLLOWING AND 1 FOLLOWING)) AS aflossing_afl_lening
				, ZEROIFNULL(CASE WHEN SUM(limiet_krediet) OVER (PARTITION BY b.Klant_nr ORDER BY b.klant_nr, b.Maand_nr ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING) < limiet_krediet THEN 1 ELSE 0 END) AS 			verhoging_limiet
				, ZEROIFNULL(CASE WHEN SUM(saldo_aflopend) OVER (PARTITION BY b.Klant_nr ORDER BY b.klant_nr, b.Maand_nr ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING) > saldo_aflopend THEN 1 ELSE 0 END) AS	 verhoging_aflopend

		FROM mi_cmb.vmia_hist a

		INNER JOIN
				(
				SELECT *
				FROM mi_temp.AA_kredietoverzicht_mnd_oud
				JOIN mi_temp.AA_kredietoverzicht_mnd_nw
				ON 1=1) b ON a.klant_nr = b.klant_nr AND a.maand_nr = b.maand_nr

		INNER JOIN mi_temp.AA_klantnummers c ON a.klant_nr = c.klant_nr)
WITH DATA
PRIMARY INDEX (klant_nr, maand_nr);

CREATE TABLE mi_temp.AA_kredietverleden_klant_Q AS
		(
		SELECT a.klant_nr
				, (SUBSTR(TRIM(a.maand_nr), 1, 4) (INT)) AS jaar
				, ((SUBSTR(TRIM(a.Maand_nr), 5, 2) (INT)) - 1) / 3 + 1 AS kwartaal
				, (TRIM((SUBSTR(TRIM(a.maand_nr), 1, 4) (INT))) || TRIM(((SUBSTR(TRIM(a.Maand_nr), 5, 2) (INT)) - 1) / 3 + 1) (INT)) AS kwartaal_nr
				, c.kwartaal_startdatum
				, AVG(doorlopend_opgenomen)   AS  doorlopend_opgenomen
				, AVG(limiet_krediet)  AS  limiet_krediet
				, AVG(doorlopend_uitn_perc)  AS  doorlopend_uitn_perc
				, AVG(saldo_aflopend)  AS  saldo_aflopend
		FROM mi_temp.AA_kredietverleden_klant_M a

		INNER JOIN  mi_temp.sys_calendar SYS ON TO_DATE(TRIM(a.maand_nr) || '01',   'yyyyMMdd') = sys.calendar_date

		LEFT JOIN
				(
				SELECT kwartaal
						, MIN(maand_startdatum) AS kwartaal_startdatum
				FROM mi_vm_nzdb.vLU_maand c
				GROUP BY 1
				) c ON  (TRIM(SYS.year_of_calendar) || TRIM(SYS.quarter_of_year) (INT))  = c.kwartaal

		GROUP BY 1,2,3,4,5
		)
WITH DATA
PRIMARY INDEX (klant_nr, kwartaal_nr);


CREATE TABLE mi_temp.AA_kredietverleden_klant_Y AS
		(
		SELECT a.klant_nr
				, (SUBSTR(TRIM(a.maand_nr), 1, 4) (INT)) AS jaar
				, AVG(doorlopend_opgenomen)   AS   doorlopend_opgenomen
				, AVG(limiet_krediet)   AS   limiet_krediet
				, AVG(doorlopend_uitn_perc)   AS   doorlopend_uitn_perc
				, AVG(saldo_aflopend)   AS   saldo_aflopend
		FROM mi_temp.AA_kredietverleden_klant_M a
		GROUP BY 1,2
		)
WITH DATA
PRIMARY INDEX (klant_nr, jaar);


CREATE TABLE mi_temp.AA_kredietverleden_klant AS
		(
		SELECT
				xa.*
			, CASE WHEN gr_doorl_opgen_Q_vorig_jr > 0 THEN 1
						WHEN gr_doorl_opgen_Q_vorig_jr < 0 THEN -1
						ELSE 0 END	 AS 																		gr_doorl_opgen_Q_ind
				, CASE WHEN gr_limiet_krediet_Q_vorig_jr > 0 THEN 1
						WHEN gr_limiet_krediet_Q_vorig_jr < 0 THEN -1
						ELSE 0 END AS 																		gr_limiet_krediet_Q_ind
				, CASE WHEN gr_doorl_uitn_perc_Q_vorig_jr > 0 THEN 1
						WHEN gr_doorl_uitn_perc_Q_vorig_jr < 0 THEN -1
						ELSE 0 END AS  																		gr_doorl_uitn_perc_Q_ind
				, CASE WHEN gr_saldo_aflopend_Q_vorig_jr > 0 THEN 1
						WHEN gr_saldo_aflopend_Q_vorig_jr < 0 THEN -1
						ELSE 0 END AS 																		 gr_saldo_aflopend_Q_ind
				, CASE WHEN gr_doorl_opgen_Y_vorig_jr > 0 THEN 1
						WHEN gr_doorl_opgen_Y_vorig_jr < 0 THEN -1
						ELSE 0 END	 AS 																		gr_doorl_opgen_Y_ind
				, CASE WHEN gr_limiet_krediet_Y_vorig_jr > 0 THEN 1
						WHEN gr_limiet_krediet_Y_vorig_jr < 0 THEN -1
						ELSE 0 END AS 																		gr_limiet_krediet_Y_ind
				, CASE WHEN gr_doorl_uitn_perc_Y_vorig_jr > 0 THEN 1
						WHEN gr_doorl_uitn_perc_Y_vorig_jr < 0 THEN -1
						ELSE 0 END AS  																		gr_doorl_uitn_perc_Y_ind
				, CASE WHEN gr_saldo_aflopend_Y_vorig_jr > 0 THEN 1
						WHEN gr_saldo_aflopend_Y_vorig_jr < 0 THEN -1
						ELSE 0 END AS 																		 gr_saldo_aflopend_Y_ind

		FROM
				(
				SELECT
						x.klant_nr
						, x.maand_nr
						, x.kwartaal_nr
						, x.jaar
						, x.doorlopend_opgenomen

				FROM mi_temp.AA_kredietverleden_klant_M x
				LEFT JOIN mi_temp.AA_kredietverleden_klant_Q ON x.kwartaal_nr = a.kwartaal_nr AND a.klant_nr = x.klant_nr
				LEFT JOIN mi_temp.AA_kredietverleden_klant_Q ON a.kwartaal = b.kwartaal AND a.klant_nr = b.klant_nr AND a.jaar - 1 = b.jaar

				LEFT JOIN mi_temp.AA_kredietverleden_klant_Y ON x.klant_nr = c.klant_nr AND x.jaar = c.jaar

				LEFT JOIN mi_temp.AA_kredietverleden_klant_Y ON d.klant_nr = c.klant_nr AND d.jaar = c.jaar-1) xa)
WITH DATA PRIMARY INDEX (klant_nr , maand_nr);


CREATE TABLE mi_temp.AA_verleden_business_volume_M AS
		(
		SELECT a.klant_nr
				, a.maand_nr
				, (SUBSTR(TRIM(a.maand_nr), 1, 4) (INT)) AS jaar
				, ((SUBSTR(TRIM(a.Maand_nr), 5, 2) (INT)) - 1) / 3 + 1 AS kwartaal
				, (TRIM((SUBSTR(TRIM(a.maand_nr), 1, 4) (INT))) || TRIM(((SUBSTR(TRIM(a.Maand_nr), 5, 2) (INT)) - 1) / 3 + 1) (INT)) AS kwartaal_nr
				, a.creditvolume
				, a.debetvolume

		FROM mi_temp.AA_subset_mia_hist a

		INNER JOIN mi_temp.AA_klantnummers c ON a.klant_nr = c.klant_nr
		)
WITH DATA
PRIMARY INDEX (klant_nr, maand_nr);


CREATE TABLE mi_temp.AA_verleden_business_volume_Q AS
		(
		SELECT a.klant_nr
				, (SUBSTR(TRIM(a.maand_nr), 1, 4) (INT)) AS jaar
				, ((SUBSTR(TRIM(a.Maand_nr), 5, 2) (INT)) - 1) / 3 + 1 AS kwartaal
				, (TRIM((SUBSTR(TRIM(a.maand_nr), 1, 4) (INT))) || TRIM(((SUBSTR(TRIM(a.Maand_nr), 5, 2) (INT)) - 1) / 3 + 1) (INT)) AS kwartaal_nr
				, c.kwartaal_startdatum
				, AVG(creditvolume) AS creditvolume
				, AVG(debetvolume) AS debetvolume
		FROM mi_temp.AA_verleden_business_volume_M a

		INNER JOIN  mi_temp.sys_calendar SYS ON TO_DATE(TRIM(a.maand_nr) || '01',   'yyyyMMdd') = sys.calendar_date

		LEFT JOIN
				(
				SELECT kwartaal
						, MIN(maand_startdatum) AS kwartaal_startdatum
				FROM mi_vm_nzdb.vLU_maand c
				GROUP BY 1
				) c ON  (TRIM(SYS.year_of_calendar) || TRIM(SYS.quarter_of_year) (INT))  = c.kwartaal

		GROUP BY 1,2,3,4,5
		)
WITH DATA
PRIMARY INDEX (klant_nr , kwartaal_nr);

CREATE TABLE mi_temp.AA_verleden_business_volume_Y AS
		(
		SELECT  a.klant_nr
				, (SUBSTR(TRIM(a.maand_nr), 1, 4) (INT)) AS jaar
				, AVG(creditvolume) AS creditvolume
				, AVG(debetvolume) AS debetvolume
		FROM mi_temp.AA_verleden_business_volume_M a
		GROUP BY 1,2
		)
WITH DATA
PRIMARY INDEX (klant_nr, jaar);

CREATE TABLE mi_temp.AA_verleden_business_volume AS
		(
		SELECT x.klant_nr
				, x.maand_nr
				, x.kwartaal_nr
				, x.jaar
				, x.creditvolume
				, x.debetvolume
				, a.creditvolume AS Q_gem_creditvolume
				, a.debetvolume AS Q_gem_debetvolume
				, b.creditvolume AS Y_gem_creditvolume
				, b.debetvolume AS Y_gem_debetvolume

				, ((a.debetvolume (FLOAT)) - (c.debetvolume (FLOAT)))  AS 										  gr_debetvolume_Q_vorig_jr
				, ((a.creditvolume (FLOAT)) - (c.creditvolume (FLOAT)))  AS 										  gr_creditvolume_Q_vorig_jr

		FROM mi_temp.AA_verleden_business_volume_M x
		LEFT JOIN mi_temp.AA_verleden_business_volume_Q a ON x.kwartaal_nr = a.kwartaal_nr AND a.klant_nr = x.klant_nr

		LEFT JOIN mi_temp.AA_verleden_business_volume_Q c ON a.kwartaal = c.kwartaal AND a.klant_nr = c.klant_nr AND a.jaar - 1 = c.jaar

		LEFT JOIN mi_temp.AA_verleden_business_volume_Y b ON x.jaar = b.jaar AND b.klant_nr = x.klant_nr
		)
WITH DATA
PRIMARY INDEX (klant_nr, maand_nr);


CREATE  TABLE mi_temp.AA_transactie_gegevens_M AS
		(
		SELECT xa.*
		FROM
				(
				SELECT
					B.klant_nr
				FROM mi_vm_ldm.vgeld_contract_event A

				JOIN mi_temp.AA_contracten B
						ON A.contract_nr = B.contract_nr
						AND A.contract_hergebruik_volgnr = B.contract_hergebruik_volgnr
						AND A.contract_soort_code = B.contract_soort_code
						AND (EXTRACT(YEAR FROM A.boek_datum) || TRIM(EXTRACT(MONTH FROM A.boek_datum) (FORMAT '99')) (INT)) > 201201

				LEFT JOIN MI_SAS_AA_MB_C_MB.lease_concurrenten  c ON CAST(a.tegenrekening_nr AS VARCHAR(25)) = '0'||(TRIM(c.contract_nr (FORMAT 'Z(25)9')))

				LEFT JOIN sys_calendar.CALENDAR SYS ON A.boek_datum = SYS.calendar_date

				LEFT JOIN mi_temp.AA_alle_contracten d ON a.tegenrekening_nr_num = d.contract_nr AND b.klant_nr = d.klant_nr
				WHERE a.mutatie_soort_code NOT IN (491,551,554,556,558,559,561,562,564,566, 133, 524, 159,885)
						AND d.contract_nr IS NULL AND d.klant_nr IS NULL
				GROUP BY 1,2,3,4,5,6
				) xa)
WITH DATA
PRIMARY INDEX(klant_nr , maand_nr);


 CREATE TABLE mi_temp.AA_transactiegegevens_Q AS
 		(
		SELECT
			B.klant_nr
		FROM mi_vm_ldm.vgeld_contract_event A

		JOIN mi_temp.AA_contracten B
		ON A.contract_nr = B.contract_nr
		AND A.contract_hergebruik_volgnr = B.contract_hergebruik_volgnr
		AND A.contract_soort_code = B.contract_soort_code
	AND (EXTRACT(YEAR FROM A.boek_datum) || TRIM(EXTRACT(MONTH FROM A.boek_datum) (FORMAT '99')) (INT)) GE 201201

		LEFT JOIN mi_temp.sys_calendar SYS
		ON A.boek_datum = SYS.calendar_date

		LEFT JOIN
				(
				SELECT kwartaal
						, MIN(maand_startdatum) AS kwartaal_startdatum
				FROM mi_vm_nzdb.vLU_maand c
				GROUP BY 1
				) c ON  (TRIM(SYS.year_of_calendar) || TRIM(SYS.quarter_of_year) (INT))  = c.kwartaal

		LEFT JOIN mi_temp.AA_alle_contracten d ON a.tegenrekening_nr_num = d.contract_nr AND b.klant_nr = d.klant_nr
		WHERE a.mutatie_soort_code NOT IN (491,551,554,556,558,559,561,562,564,566, 133, 524, 159,885)
				AND d.contract_nr IS NULL AND d.klant_nr IS NULL

		GROUP BY 1,2,3,4,5
		)
WITH DATA
PRIMARY INDEX (klant_nr , kwartaal_nr);

CREATE TABLE mi_temp.AA_transactiegegevens_Y AS
 		(
		SELECT
			B.klant_nr
		FROM mi_vm_ldm.vgeld_contract_event A

		JOIN mi_temp.AA_contracten B
		ON A.contract_nr = B.contract_nr
		AND A.contract_hergebruik_volgnr = B.contract_hergebruik_volgnr
		AND A.contract_soort_code = B.contract_soort_code
		AND (EXTRACT(YEAR FROM A.boek_datum) || TRIM(EXTRACT(MONTH FROM A.boek_datum) (FORMAT '99')) (INT)) > 201201

		LEFT JOIN sys_calendar.CALENDAR SYS
		ON A.boek_datum = SYS.calendar_date

		LEFT JOIN
				(
				SELECT kwartaal
						, MIN(maand_startdatum) AS kwartaal_startdatum
				FROM mi_vm_nzdb.vLU_maand c
				GROUP BY 1
				) c ON  (TRIM(SYS.year_of_calendar) || TRIM(SYS.quarter_of_year) (INT))  = c.kwartaal

		LEFT JOIN mi_temp.AA_alle_contracten d ON a.tegenrekening_nr_num = d.contract_nr AND b.klant_nr = d.klant_nr
		WHERE a.mutatie_soort_code NOT IN (491,551,554,556,558,559,561,562,564,566, 133, 524, 159,885)
				AND d.contract_nr IS NULL AND d.klant_nr IS NULL

		GROUP BY 1,2
		)
WITH DATA
PRIMARY INDEX (klant_nr , Y);

CREATE TABLE mi_temp.AA_transactie_gegevens AS
		(
		SELECT xa.*
		FROM( SELECT x.klant_nr
				FROM mi_temp.AA_transactie_gegevens_M x

				LEFT JOIN mi_temp.AA_transactiegegevens_Q a ON x.kwartaal_nr = a.kwartaal_nr AND a.klant_nr = x.klant_nr

				LEFT JOIN mi_temp.AA_transactiegegevens_Q b ON ADD_MONTHS(a.kwartaal_startdatum, -12) = b.kwartaal_startdatum AND a.klant_nr = b.klant_nr

				LEFT JOIN mi_temp.AA_transactiegegevens_Y c ON x.klant_nr = c.klant_nr AND x.Y = c.Y

				LEFT JOIN mi_temp.AA_transactiegegevens_Y d ON d.klant_nr = c.klant_nr AND d.Y = c.Y-1
				) xa)
WITH DATA
PRIMARY INDEX (klant_nr, maand_nr);

CREATE  TABLE mi_temp.AA_maanden AS
		(
		SELECT DISTINCT a.klant_nr
				, b.maand_nr
				, c.maand_startdatum
		FROM mi_temp.AA_contracten a
		INNER JOIN mi_cmb.vmia_hist b ON a.klant_nr = b.klant_nr
		INNER JOIN mi_vm_nzdb.vLU_Maand c ON b.maand_nr = c.maand
		WHERE b.maand_nr > (EXTRACT(YEAR FROM ADD_MONTHS(a.maand_startdatum, -36)) || TRIM(EXTRACT(MONTH FROM ADD_MONTHS(a.maand_startdatum, -36)) (FORMAT '99')) (INT)) )
WITH DATA
PRIMARY INDEX (klant_nr, maand_nr);


CREATE TABLE mi_temp.AA_adv_analytics_basistabel_tussen AS
		(
		SELECT a.klant_nr

		, a.maand_nr AS maand_nr
		, a.maand_startdatum
		, a.maand_einddatum

		, xa.verkorte_naam
		, xa.business_line
		, xa.segment
		, xa.cca
		, xa.relatiemanager
		FROM mi_temp.AA_maanden a

		LEFT JOIN mi_cmb.vmia_hist xa ON a.klant_nr = xa.klant_nr AND a.maand_nr = xa.maand_nr
		LEFT JOIN mi_temp.AA_subset_mia_hist ON a.klant_nr = tt.klant_nr AND  a.M18 = tt.maand_nr
		LEFT JOIN mi_temp.AA_transactie_gegevens ON a.klant_nr = ttt.klant_nr AND  a.M18 = ttt.maand_nr
		LEFT JOIN mi_temp.AA_verleden_business_volume ON a.klant_nr = tttt.klant_nr AND a.M18 = tttt.maand_nr)
WITH DATA
PRIMARY INDEX(klant_nr, maand_nr);

CREATE TABLE MI_SAS_AA_MB_C_MB.verloop_trx_en_kred_gebruik AS
		(
		SELECT a.*
		FROM mi_temp.AA_adv_analytics_basistabel_tussen a
		LEFT JOIN
				(
				SELECT a.klant_nr
						, a.maand_nr
						, a.maand_startdatum
						, CASE WHEN AVG(b.doorlopend_opgenomen) - AVG( c.doorlopend_opgenomen) > 0 THEN 1 ELSE 0 END AS		gr_doorl_opgen_12mnd
						, CASE WHEN AVG(b.limiet_krediet) - AVG(c.limiet_krediet 				) > 0 THEN 1 ELSE 0 END AS  						gr_limiet_krediet_12mnd
						, CASE WHEN AVG(b.doorlopend_uitn_perc) - AVG(c.doorlopend_uitn_perc ) > 0 THEN 1 ELSE 0 END AS				gr_doorl_uitn_perc_12mnd
						, CASE WHEN AVG(b.saldo_aflopend) - AVG(c.saldo_aflopend ) > 0 THEN 1 ELSE 0 END AS									gr_saldo_aflopend_12mnd


				FROM mi_temp.AA_adv_analytics_basistabel_tussen a
				LEFT JOIN mi_temp.AA_kredietverleden_klant b ON a.klant_nr = b.klant_nr
						AND	b.maand_nr BETWEEN  (TRIM(EXTRACT(YEAR FROM ADD_MONTHS(a.maand_startdatum, -12))) || TRIM(EXTRACT(MONTH FROM ADD_MONTHS(a.maand_startdatum, -12)) (FORMAT '99')) (INT))
								AND  (TRIM(EXTRACT(YEAR FROM ADD_MONTHS(a.maand_startdatum, -1))) || TRIM(EXTRACT(MONTH FROM ADD_MONTHS(a.maand_startdatum, -1)) (FORMAT '99')) (INT))

				LEFT JOIN mi_temp.AA_kredietverleden_klant c ON b.klant_nr = c.klant_nr
						AND	c.maand_nr 	=  (EXTRACT(YEAR FROM ADD_MONTHS(TO_DATE(TRIM(b.maand_nr) || '01',   'yyyyMMdd'), -12)) || (EXTRACT(MONTH FROM ADD_MONTHS(TO_DATE(TRIM(b.maand_nr) || '01',   'yyyyMMdd'), -12)) (FORMAT '99')) (INT))


				GROUP BY 1,2,3

				) www ON www.klant_nr = a.klant_nr AND a.maand_nr = www.maand_nr
		LEFT JOIN
				(
				SELECT a.klant_nr
				FROM mi_temp.AA_adv_analytics_basistabel_tussen a
				LEFT JOIN mi_temp.AA_transactie_gegevens b ON a.klant_nr = b.klant_nr
						AND	b.maand_nr BETWEEN  (TRIM(EXTRACT(YEAR FROM ADD_MONTHS(a.maand_startdatum, -12))) || TRIM(EXTRACT(MONTH FROM ADD_MONTHS(a.maand_startdatum, -12)) (FORMAT '99')) (INT))
								AND  (TRIM(EXTRACT(YEAR FROM ADD_MONTHS(a.maand_startdatum, -1))) || TRIM(EXTRACT(MONTH FROM ADD_MONTHS(a.maand_startdatum, -1)) (FORMAT '99')) (INT))

				LEFT JOIN mi_temp.AA_transactie_gegevens c ON b.klant_nr = c.klant_nr
						AND	c.maand_nr 	=  (EXTRACT(YEAR FROM ADD_MONTHS(TO_DATE(TRIM(b.maand_nr) || '01',   'yyyyMMdd'), -12)) || (EXTRACT(MONTH FROM ADD_MONTHS(TO_DATE(TRIM(b.maand_nr) || '01',   'yyyyMMdd'), -12)) (FORMAT '99')) (INT))

				LEFT JOIN mi_temp.AA_kredietverleden_klant d ON a.klant_nr = d.klant_nr
						AND	d.maand_nr 	= b.maand_nr

				GROUP BY 1,2,3

				) vvv ON vvv.klant_nr = a.klant_nr AND vvv.maand_nr = a.maand_nr
		LEFT JOIN
				(
				SELECT
						b.klant_nr
						, b.maand_nr
						, NULLIFZERO(CASE  WHEN  MAX(xAsRegr)  <  6 THEN 0 ELSE REGR_SLOPE(b.totaal_aantal_transacties, xAsRegr) end) 			AS regr12mnd_totaal_N_transacties
						, NULLIFZERO(CASE  WHEN  MAX(xAsRegr)  <  6 THEN 0 ELSE REGR_SLOPE(b.aantal_debet_trx, xAsRegr) end) 					  AS regr12mnd_aantal_debet_trx
						, NULLIFZERO(CASE  WHEN  MAX(xAsRegr)  <  6 THEN 0 ELSE REGR_SLOPE(b.volume_debet_trx, xAsRegr) end) 					AS regr12mnd_volume_debet_trx
						, NULLIFZERO(CASE  WHEN  MAX(xAsRegr)  <  6 THEN 0 ELSE REGR_SLOPE(b.gem_debet_bedrag, xAsRegr) end) 				 AS regr12mnd_gem_debet_bedrag
						, NULLIFZERO(CASE  WHEN  MAX(xAsRegr)  <  6 THEN 0 ELSE REGR_SLOPE(b.aantal_credit_trx, xAsRegr) end) 					  AS regr12mnd_aantal_credit_trx
						, NULLIFZERO(CASE  WHEN  MAX(xAsRegr)  <  6 THEN 0 ELSE REGR_SLOPE(b.volume_credit_trx, xAsRegr) end) 					 AS regr12mnd_volume_credit_trx
						, NULLIFZERO(CASE  WHEN  MAX(xAsRegr)  <  6 THEN 0 ELSE REGR_SLOPE(b.gem_credit_bedrag, xAsRegr) end) 				  AS regr12mnd_gem_credit_bedrag
						, NULLIFZERO(CASE  WHEN  MAX(xAsRegr)  <  6 THEN 0 ELSE REGR_SLOPE(b.saldo_gem, xAsRegr) end) 				 				   AS regr12mnd_saldo_gem
						, NULLIFZERO(CASE  WHEN  MAX(xAsRegr)  <  6 THEN 0 ELSE REGR_SLOPE(b.saldo_min, xAsRegr) end) 								    AS regr12mnd_saldo_min
						, NULLIFZERO(CASE  WHEN  MAX(xAsRegr)  <  6 THEN 0 ELSE REGR_SLOPE(b.saldo_max, xAsRegr) end) 				 				   AS regr12mnd_saldo_max

				FROM
						(
						 SELECT a.klant_nr
								, (TRIM(EXTRACT(YEAR FROM a.maand_startdatum)) || TRIM(EXTRACT(MONTH FROM a.maand_startdatum) (FORMAT '99')) (INT)) AS maand_nr
								, a.maand_startdatum
								, b.maand_nr AS maand_nr_regr
								, ((b.totaal_aantal_transacties - AVG(b.totaal_aantal_transacties) OVER (PARTITION BY a.klant_nr)) / NULLIFZERO(STDDEV_POP(b.totaal_aantal_transacties) OVER (PARTITION BY a.klant_nr)) (DECIMAL(8,4))) AS totaal_aantal_transacties
								, ((b.aantal_debet_trx - AVG(b.aantal_debet_trx) OVER (PARTITION BY a.klant_nr)) / NULLIFZERO(STDDEV_POP(b.aantal_debet_trx) OVER (PARTITION BY a.klant_nr)) (DECIMAL(8,4))) AS aantal_debet_trx
								, ((b.volume_debet_trx - AVG(b.volume_debet_trx) OVER (PARTITION BY a.klant_nr)) / NULLIFZERO(STDDEV_POP(b.volume_debet_trx) OVER (PARTITION BY a.klant_nr)) (DECIMAL(8,4))) AS volume_debet_trx
								, ((b.gem_debet_bedrag - AVG(b.gem_debet_bedrag) OVER (PARTITION BY a.klant_nr)) / NULLIFZERO(STDDEV_POP(b.gem_debet_bedrag) OVER (PARTITION BY a.klant_nr)) (DECIMAL(8,4))) AS gem_debet_bedrag
								, ((b.aantal_credit_trx - AVG(b.aantal_credit_trx) OVER (PARTITION BY a.klant_nr)) / NULLIFZERO(STDDEV_POP(b.aantal_credit_trx) OVER (PARTITION BY a.klant_nr)) (DECIMAL(8,4))) AS aantal_credit_trx
								, ((b.volume_credit_trx - AVG(b.volume_credit_trx) OVER (PARTITION BY a.klant_nr)) / NULLIFZERO(STDDEV_POP(b.volume_credit_trx) OVER (PARTITION BY a.klant_nr)) (DECIMAL(8,4))) AS volume_credit_trx
								, ((b.gem_credit_bedrag - AVG(b.gem_credit_bedrag) OVER (PARTITION BY a.klant_nr)) / NULLIFZERO(STDDEV_POP(b.gem_credit_bedrag) OVER (PARTITION BY a.klant_nr)) (DECIMAL(8,4))) AS gem_credit_bedrag
								, ((b.saldo_gem - AVG(b.saldo_gem) OVER (PARTITION BY a.klant_nr)) / NULLIFZERO(STDDEV_POP(b.saldo_gem) OVER (PARTITION BY a.klant_nr)) (DECIMAL(8,4))) AS saldo_gem
								, ((b.saldo_min - AVG(b.saldo_min) OVER (PARTITION BY a.klant_nr)) / NULLIFZERO(STDDEV_POP(b.saldo_min) OVER (PARTITION BY a.klant_nr)) (DECIMAL(8,4))) AS saldo_min
								, ((b.saldo_max - AVG(b.saldo_max) OVER (PARTITION BY a.klant_nr)) / NULLIFZERO(STDDEV_POP(b.saldo_max) OVER (PARTITION BY a.klant_nr)) (DECIMAL(8,4))) AS saldo_max

								, RANK() OVER (PARTITION BY a.klant_nr, a.maand_nr ORDER BY b.maand_nr) AS xAsRegr
						FROM mi_temp.AA_adv_analytics_basistabel_tussen a
						LEFT JOIN mi_temp.AA_transactie_gegevens b ON a.klant_nr = b.klant_nr
								AND	b.maand_nr BETWEEN  (TRIM(EXTRACT(YEAR FROM ADD_MONTHS(a.maand_startdatum, -12))) || TRIM(EXTRACT(MONTH FROM ADD_MONTHS(a.maand_startdatum, -12)) (FORMAT '99')) (INT))
										AND  (TRIM(EXTRACT(YEAR FROM ADD_MONTHS(a.maand_startdatum, -1))) || TRIM(EXTRACT(MONTH FROM ADD_MONTHS(a.maand_startdatum, -1)) (FORMAT '99')) (INT))
						) b
				GROUP BY 1,2
				) uuu ON uuu.klant_nr = a.klant_nr AND uuu.maand_nr = a.maand_nr
		LEFT JOIN
				(
				SELECT
						b.klant_nr
						, b.maand_nr
						, NULLIFZERO(CASE  WHEN  MAX(xAsRegr)  <  6 THEN 0 ELSE REGR_SLOPE(b.debetvolume, xAsRegr) end) 	AS regr12mnd_debetvolume
						, NULLIFZERO(CASE  WHEN  MAX(xAsRegr)  <  6 THEN 0 ELSE REGR_SLOPE(b.creditvolume, xAsRegr) end) 	AS regr12mnd_creditvolume
				FROM
						(
						 SELECT a.klant_nr
								, (TRIM(EXTRACT(YEAR FROM a.maand_startdatum)) || TRIM(EXTRACT(MONTH FROM a.maand_startdatum) (FORMAT '99')) (INT)) AS maand_nr
								, a.maand_startdatum
								, b.maand_nr AS maand_nr_regr
								, ((b.creditvolume - AVG(b.creditvolume) OVER (PARTITION BY a.klant_nr)) / NULLIFZERO(STDDEV_POP(b.creditvolume) OVER (PARTITION BY a.klant_nr)) (DECIMAL(8,4))) AS creditvolume
								, ((b.debetvolume - AVG(b.debetvolume) OVER (PARTITION BY a.klant_nr)) / NULLIFZERO(STDDEV_POP(b.debetvolume) OVER (PARTITION BY a.klant_nr)) (DECIMAL(8,4))) AS debetvolume
								, RANK() OVER (PARTITION BY b.klant_nr, a.maand_nr ORDER BY b.maand_nr) AS xAsRegr
						FROM mi_temp.AA_adv_analytics_basistabel_tussen a
						LEFT JOIN mi_cmb.vmia_hist b ON a.klant_nr = b.klant_nr
								AND	b.maand_nr BETWEEN  (TRIM(EXTRACT(YEAR FROM ADD_MONTHS(a.maand_startdatum, -12))) || TRIM(EXTRACT(MONTH FROM ADD_MONTHS(a.maand_startdatum, -12)) (FORMAT '99')) (INT))
										AND  (TRIM(EXTRACT(YEAR FROM ADD_MONTHS(a.maand_startdatum, -1))) || TRIM(EXTRACT(MONTH FROM ADD_MONTHS(a.maand_startdatum, -1)) (FORMAT '99')) (INT))
						) b
				GROUP BY 1,2
				) uu ON uu.klant_nr = a.klant_nr AND uu.maand_nr = a.maand_nr
		LEFT JOIN
				(
				SELECT
						b.klant_nr
						, b.maand_nr
						, NULLIFZERO(CASE WHEN MAX(xAsRegr) < 6 THEN 0 ELSE REGR_SLOPE(b.doorlopend_opgenomen, xAsRegr) end) 	AS regr12mnd_doorlopend_opgenomen
						, NULLIFZERO(CASE WHEN MAX(xAsRegr) < 6 THEN 0 ELSE REGR_SLOPE(b.limiet_krediet, xAsRegr) end) 					AS regr12mnd_limiet_krediet
						, NULLIFZERO(CASE WHEN MAX(xAsRegr) < 6 THEN 0 ELSE REGR_SLOPE(b.doorlopend_uitn_perc, xAsRegr) end) 		AS regr12mnd_doorlopend_uitn_perc
						, NULLIFZERO(CASE WHEN MAX(xAsRegr) < 6 THEN 0 ELSE REGR_SLOPE(b.saldo_aflopend, xAsRegr) end) 				AS regr12mnd_saldo_aflopend
						, NULLIFZERO(CASE WHEN MAX(xAsRegr) < 6 THEN 0 ELSE REGR_SLOPE(b.aflossing_afl_lening, xAsRegr) end)			 AS regr12mnd_aflossing_afl_lening

				FROM
						(
						 SELECT a.klant_nr
								, (TRIM(EXTRACT(YEAR FROM a.maand_startdatum)) || TRIM(EXTRACT(MONTH FROM a.maand_startdatum) (FORMAT '99')) (INT)) AS maand_nr
								, a.maand_startdatum
								, b.maand_nr AS maand_nr_regr
								, ((b.doorlopend_opgenomen - AVG(b.doorlopend_opgenomen) OVER (PARTITION BY a.klant_nr)) / NULLIFZERO(STDDEV_POP(b.doorlopend_opgenomen) OVER (PARTITION BY a.klant_nr)) (DECIMAL(8,4))) AS doorlopend_opgenomen
								, ((b.limiet_krediet - AVG(b.limiet_krediet) OVER (PARTITION BY a.klant_nr)) / NULLIFZERO(STDDEV_POP(b.limiet_krediet) OVER (PARTITION BY a.klant_nr)) (DECIMAL(8,4))) AS limiet_krediet
								, ((b.doorlopend_uitn_perc - AVG(b.doorlopend_uitn_perc) OVER (PARTITION BY a.klant_nr)) / NULLIFZERO(STDDEV_POP(b.doorlopend_uitn_perc) OVER (PARTITION BY a.klant_nr)) (DECIMAL(8,4))) AS doorlopend_uitn_perc
								, ((b.saldo_aflopend - AVG(b.saldo_aflopend) OVER (PARTITION BY a.klant_nr)) / NULLIFZERO(STDDEV_POP(b.saldo_aflopend) OVER (PARTITION BY a.klant_nr)) (DECIMAL(8,4))) AS saldo_aflopend
								, ((b.aflossing_afl_lening - AVG(b.aflossing_afl_lening) OVER (PARTITION BY a.klant_nr)) / NULLIFZERO(STDDEV_POP(b.aflossing_afl_lening) OVER (PARTITION BY a.klant_nr)) (DECIMAL(8,4))) AS aflossing_afl_lening
								, RANK() OVER (PARTITION BY b.klant_nr, a.maand_nr ORDER BY b.maand_nr) AS xAsRegr
						FROM mi_temp.AA_adv_analytics_basistabel_tussen a
						LEFT JOIN mi_temp.AA_kredietverleden_klant b ON a.klant_nr = b.klant_nr
								AND	b.maand_nr BETWEEN  (TRIM(EXTRACT(YEAR FROM ADD_MONTHS(a.maand_startdatum, -12))) || TRIM(EXTRACT(MONTH FROM ADD_MONTHS(a.maand_startdatum, -12)) (FORMAT '99')) (INT))
										AND  (TRIM(EXTRACT(YEAR FROM ADD_MONTHS(a.maand_startdatum, -1))) || TRIM(EXTRACT(MONTH FROM ADD_MONTHS(a.maand_startdatum, -1)) (FORMAT '99')) (INT))
						) b
				GROUP BY 1,2
				) u ON u.klant_nr = a.klant_nr AND u.maand_nr = a.maand_nr)
WITH DATA
PRIMARY INDEX (klant_nr , maand_nr);