#DATASPOT-TERADATA

INSERT INTO MI_CMB_UIA.A_MSTR_LU_Internat_segm
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_Internat_segm
;

DELETE FROM MI_CMB_UIA.A_MSTR_LU_Internat_segm
WHERE Maand_nr = (SELECT Maand_nr FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr WHERE N_maanden_terug = 0)
;



INSERT INTO  MI_CMB_UIA.A_MSTR_LU_Internat_segm
SELECT  a.Maand_nr
		    ,b.Internat_segm_nr
		    ,b.Internat_segm_oms
FROM MI_VM_SAS_AA_MB_C_MB.vMia_week    a

INNER  JOIN MI_CMB_UIA.A_MSTR_LU_Internat_segm  b
        ON b.Internat_segm_oms = a.internationaal_segment

GROUP BY 1,2,3
;


INSERT INTO  MI_CMB_UIA.A_MSTR_LU_Internat_segm
SELECT a.maand_nr
	,CSUM(1, a.Internat_segm_oms DESC) + a.Max_Internat_segm_nr  Internat_segm_nr
    ,a.Internat_segm_oms
FROM
     (
     SELECT    a.maand_nr,
     		a.Internationaal_segment  Internat_segm_oms
            ,c.Max_Internat_segm_nr
     FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_hist    a

     LEFT OUTER JOIN (SELECT  Internat_segm_nr
                           ,Internat_segm_oms
                       FROM MI_CMB_UIA.A_MSTR_LU_Internat_segm
                       GROUP BY 1,2
                       ) b
        ON TRIM(BOTH FROM (COALESCE(b.Internat_segm_oms, '')) )  = TRIM(BOTH FROM (COALESCE(a.Internationaal_segment, '')) )

     INNER JOIN (SELECT MAX(Internat_segm_nr)  Max_Internat_segm_nr
                  FROM MI_CMB_UIA.A_MSTR_LU_Internat_segm
                 ) c
        ON 1=1
     WHERE a.Maand_nr = (SELECT MAX(Maand_nr)  Maand_nr FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_hist)
       AND NOT a.Internationaal_segment IS NULL
       AND b.Internat_segm_nr IS NULL
     GROUP BY 1,2,3
     ) a
;



INSERT INTO  MI_CMB_UIA.A_MSTR_LU_Internat_segm
SELECT     a.Maand_nr
		       ,-101
		       ,'Onbekend'
FROM MI_VM_SAS_AA_MB_C_MB.vMia_week    a
GROUP BY 1,2,3;



INSERT INTO MI_CMB_UIA.A_MSTR_LU_Segment
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_Segment;



COLLECT STATISTICS MI_CMB_UIA.A_MSTR_LU_Segment COLUMN (PARTITION);




DELETE FROM MI_CMB_UIA.A_MSTR_LU_Segment
WHERE Maand_nr = (SELECT Maand_nr FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr WHERE N_maanden_terug = 0)
;



INSERT INTO  MI_CMB_UIA.A_MSTR_LU_Segment
SELECT  a.Maand_nr
    ,b.Segment_nr
    ,b.Segment
FROM MI_VM_SAS_AA_MB_C_MB.vMia_week    a

INNER  JOIN MI_CMB_UIA.A_MSTR_LU_Segment  b
        ON b.Segment = a.Segment

GROUP BY 1,2,3;




INSERT INTO  MI_CMB_UIA.A_MSTR_LU_Segment
SELECT  a.Maand_nr
    ,CSUM(1, a.Segment DESC) + a.Max_Segment_nr  Segment_nr
    ,a.Segment
FROM
     (
     SELECT     a.Maand_nr
            ,a.Segment
            ,c.Max_Segment_nr
     FROM MI_VM_SAS_AA_MB_C_MB.vMia_week    a

     LEFT OUTER JOIN (SELECT  Segment_nr
                           ,Segment
                       FROM MI_CMB_UIA.A_MSTR_LU_Segment
                       GROUP BY 1,2
                       ) b
        ON b.Segment = a.Segment

     INNER JOIN (SELECT MAX(Segment_nr)  Max_Segment_nr
                  FROM MI_CMB_UIA.A_MSTR_LU_Segment
                 ) c
        ON 1=1
     WHERE NOT a.Segment IS NULL
       AND b.Segment_nr IS NULL
     GROUP BY 1,2,3
     ) a;


INSERT INTO  MI_CMB_UIA.A_MSTR_LU_Segment
SELECT     a.Maand_nr
		       ,-101  Segment_nr
		       ,'Onbekend'
FROM MI_VM_SAS_AA_MB_C_MB.vMia_week    a
GROUP BY 1;


INSERT INTO MI_CMB_UIA.A_MSTR_LU_Business_line
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_Business_line;


DELETE FROM MI_CMB_UIA.A_MSTR_LU_Business_line
WHERE Maand_nr = (SELECT Maand_nr FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr WHERE N_maanden_terug = 0)
;




INSERT INTO  MI_CMB_UIA.A_MSTR_LU_Business_line
SELECT  a.Maand_nr
    ,b.Business_line_nr
    ,b.Business_line
FROM  MI_VM_SAS_AA_MB_C_MB.vMia_week    a

INNER JOIN MI_CMB_UIA.A_MSTR_LU_Business_line  b
   ON b.Business_line = a.Business_line

GROUP BY 1,2,3;


INSERT INTO  MI_CMB_UIA.A_MSTR_LU_Business_line
SELECT  a.Maand_nr
	    ,CSUM(1, a.Business_line DESC) + a.Max_Business_line_nr  Business_line_nr
	    ,a.Business_line
		FROM
			(SELECT     a.Maand_nr
			        ,a.Business_line
			        ,c.Max_Business_line_nr
			FROM MI_VM_SAS_AA_MB_C_MB.vMia_week    a

			LEFT  JOIN MI_CMB_UIA.A_MSTR_LU_Business_line b
			ON b.Business_line = a.Business_line

			INNER JOIN (SELECT MAX(Business_line_nr)  Max_Business_line_nr
			            FROM MI_CMB_UIA.A_MSTR_LU_Business_line
			            ) c
			ON 1=1
			WHERE NOT a.Business_line IS NULL
			AND b.Business_line_nr IS NULL
			GROUP BY 1,2,3
			) a	;


INSERT INTO  MI_CMB_UIA.A_MSTR_LU_Business_line
SELECT     a.Maand_nr
       ,-101  Business_line_nr
       ,'Onbekend'
FROM MI_VM_SAS_AA_MB_C_MB.vMia_week    a
GROUP BY 1;



INSERT INTO MI_CMB_UIA.A_MSTR_LU_Clientgroep
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_Clientgroep;

DELETE FROM MI_CMB_UIA.A_MSTR_LU_Clientgroep
WHERE Maand_nr = (SELECT Maand_nr FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr WHERE N_maanden_terug = 0);


INSERT INTO MI_CMB_UIA.A_MSTR_LU_Clientgroep
SELECT
     Mia.Maand_nr
    ,Mia.Clientgroep (INTEGER)  ClientGroepCode_nr
    ,Mia.Clientgroep  ClienGroepCode
    ,COALESCE(CGC.segment_oms, 'Onbekend')  Subgroep

FROM (
      SELECT  Mia.Maand_nr
          ,Mia.Clientgroep (INTEGER)  ClientGroepCode_nr
          ,Mia.Clientgroep  Clientgroep
     FROM MI_VM_SAS_AA_MB_C_MB.vMia_week Mia
      JOIN  MI_SAS_AA_MB_C_MB.Mia_businesscontacts Mia
      ON 1=1
      GROUP BY 1,2,3
      )  Mia

 LEFT OUTER JOIN Mi_vm_ldm.aSegment CGC
 ON CGC.Segment_id = Mia.Clientgroep AND CGC. Segment_type_code = 'CG'
WHERE NOT Mia.Clientgroep IS NULL
GROUP BY 1,2,3,4;


INSERT INTO  MI_CMB_UIA.A_MSTR_LU_Clientgroep
SELECT     a.Maand_nr
       ,-101  ClientGroepCode_nr
       ,'-101'
       ,'Onbekend'
FROM MI_VM_SAS_AA_MB_C_MB.vMia_week    a
GROUP BY 1;




INSERT INTO MI_CMB_UIA.A_MSTR_LU_RM
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_RM
;


DELETE FROM MI_CMB_UIA.A_MSTR_LU_RM
WHERE Maand_nr = (SELECT Maand_nr FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr WHERE N_maanden_terug = 0)
  AND Adviseur_type = 'CLTADV'
;

INSERT INTO MI_CMB_UIA.A_MSTR_LU_RM
SELECT
     Mia.Maand_nr
    ,'CLTADV'                              Adviseur_type
    ,Mia.CCA  (INTEGER)   Adviseur_nr
    ,MAX(CASE WHEN Mia.CCA = 1 THEN 'Meerdere RM''s'
              WHEN Mia.CCA = 0 THEN 'Geen (geldige) RM'
              WHEN Mia.Relatiemanager IS NULL THEN 'Onbekend' ELSE Mia.Relatiemanager END)          Adviseur_naam

FROM MI_VM_SAS_AA_MB_C_MB.vMia_week    Mia
WHERE NOT Mia.CCA IS NULL
  AND Mia.CCA <> -101
GROUP BY 1,2,3
;


INSERT INTO MI_CMB_UIA.A_MSTR_LU_RM
SELECT     Mia.Maand_nr
       ,'CLTADV'                              Adviseur_type
       ,-101  Adviseur_nr
       ,'Onbekend'
FROM MI_VM_SAS_AA_MB_C_MB.vMia_week    Mia
GROUP BY 1,2,3,4
;



INSERT INTO MI_CMB_UIA.A_MSTR_LU_Omzetklasse
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_Omzetklasse;

DELETE FROM MI_CMB_UIA.A_MSTR_LU_Omzetklasse
WHERE Maand_nr = (SELECT Maand_nr FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr WHERE N_maanden_terug = 0);

INSERT INTO  MI_CMB_UIA.A_MSTR_LU_Omzetklasse
SELECT  a.Maand_nr
    ,b.Omzetklasse_nr
    ,b.Omzetklasse_id
    ,b.Omzetklasse_oms
FROM MI_VM_SAS_AA_MB_C_MB.vMia_week    a

INNER JOIN MI_CMB_UIA.A_MSTR_LU_Omzetklasse  b
   ON b.Omzetklasse_id = a.Omzetklasse_id
  AND TRIM(BOTH FROM (COALESCE(b.Omzetklasse_oms, '')) )  = TRIM(BOTH FROM (COALESCE(a.Omzetklasse_oms, '')) )
WHERE NOT a.Omzetklasse_id IS NULL
GROUP BY 1,2,3,4;


INSERT INTO  MI_CMB_UIA.A_MSTR_LU_Omzetklasse
SELECT  a.Maand_nr
    ,CSUM(1, a.Omzetklasse_id DESC, a.Omzetklasse_oms DESC) + a.Max_Omzetklasse_nr  Omzetklasse_nr
    ,a.Omzetklasse_id
    ,a.Omzetklasse_oms
FROM
     (
     SELECT     a.Maand_nr
            ,a.Omzetklasse_id
            ,a.Omzetklasse_oms
            ,c.Max_Omzetklasse_nr
     FROM MI_VM_SAS_AA_MB_C_MB.vMia_week    a

     LEFT OUTER JOIN (SELECT  Omzetklasse_nr
                           ,Omzetklasse_id
                           ,Omzetklasse_oms
                       FROM MI_CMB_UIA.A_MSTR_LU_Omzetklasse
                       GROUP BY 1,2,3
                       ) b
        ON b.Omzetklasse_id = a.Omzetklasse_id
       AND TRIM(BOTH FROM (COALESCE(b.Omzetklasse_oms, '')) )  = TRIM(BOTH FROM (COALESCE(a.Omzetklasse_oms, '')) )

     INNER JOIN (SELECT MAX(Omzetklasse_nr)  Max_Omzetklasse_nr
                  FROM MI_CMB_UIA.A_MSTR_LU_Omzetklasse
                 ) c
        ON 1=1
     WHERE NOT a.Omzetklasse_id IS NULL
       AND b.Omzetklasse_nr IS NULL
     GROUP BY 1,2,3,4
     ) a;

INSERT INTO  MI_CMB_UIA.A_MSTR_LU_Omzetklasse
SELECT     a.Maand_nr
       ,-101  Omzetklasse_nr
       ,-101
       ,'Onbekend'
FROM MI_VM_SAS_AA_MB_C_MB.vMia_week    a
GROUP BY 1;


INSERT INTO MI_CMB_UIA.A_MSTR_LU_SBI
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_SBI;

DELETE FROM MI_CMB_UIA.A_MSTR_LU_SBI
WHERE Maand_nr = (SELECT MAX(Maand_nr)  Maand_nr FROM MI_VM_SAS_AA_MB_C_MB.vMia_week);



INSERT INTO MI_CMB_UIA.A_MSTR_LU_SBI
SELECT
	a.maand_nr				 Maand_nr
    ,a.SBI_Code              SBI_Code
    ,CASE WHEN a.SBI_oms IS NULL THEN 'Onbekend' ELSE  a.SBI_oms END           SBI_oms
    ,CASE WHEN a.Agic_oms IS NULL THEN 'Onbekend' ELSE 	a.Agic_oms END			 Agic_oms
    ,CASE WHEN a.Subsector_code IS NULL THEN -101 ELSE 	a.Subsector_code END	 Subsector_code
    ,CASE WHEN a.Subsector_oms IS NULL THEN 'Onbekend' ELSE 	a.Subsector_oms END	 Subsector_oms
	,CASE WHEN a.CMB_Sector  IS NULL THEN 'Onbekend' ELSE  a.CMB_Sector END      CMB_Sector
    ,CASE WHEN a.Sectorcluster  IS NULL THEN 'Onbekend' ELSE  a.Sectorcluster END    Sectorcluster

FROM MI_VM_SAS_AA_MB_C_MB.vMia_week        a
WHERE NOT a.SBI_code IS NULL
GROUP BY 1,2,3,4,5,6,7,8;



INSERT INTO MI_CMB_UIA.A_MSTR_LU_SBI
SELECT   Mia.maand_nr
        ,'-101'
        ,'Onbekend'
        ,'Onbekend'
		,-101
		,'Onbekend'
        ,'Onbekend'
		,'Onbekend'
FROM MI_VM_SAS_AA_MB_C_MB.vMia_week Mia
GROUP BY 1;

INSERT INTO  MI_CMB_UIA.A_MSTR_LU_BO_Org_niv5
SEL
	Mia.Maand_nr
   ,COALESCE(Mia.Org_niveau5_bo_nr,	-101)  Org_niveau5_bo_nr
   ,COALESCE(Mia.Org_niveau5, 'Onbekend')  Org_niveau5
   ,COALESCE(Mia.Org_niveau4_bo_nr,	-101)  Org_niveau4_bo_nr

FROM MI_VM_SAS_AA_MB_C_MB.vMia_hist		Mia
WHERE Mia.Maand_nr >= 201606
GROUP BY 1,2,3,4;


INSERT INTO  MI_CMB_UIA.A_MSTR_LU_BO_Org_niv4
SELECT
	Mia.Maand_nr
FROM MI_VM_SAS_AA_MB_C_MB.vMia_hist		Mia
WHERE Mia.Maand_nr >= 201606
GROUP BY 1,2,3,4;



INSERT INTO  MI_CMB_UIA.A_MSTR_LU_BO_Org_niv3
SELECT
	Mia.Maand_nr
   ,COALESCE(Mia.Org_niveau3_bo_nr,	-101)  Org_niveau3_bo_nr
   ,COALESCE(CASE WHEN mia.Org_niveau3_bo_nr < 0 OR mia.Org_niveau3_bo_nr IS NULL THEN 'Onbekend' ELSE Mia.Org_niveau3 end, 'Onbekend')  Org_niveau3
   ,COALESCE(Mia.Org_niveau2_bo_nr,	-101)  Org_niveau2_bo_nr

FROM MI_VM_SAS_AA_MB_C_MB.vMia_hist		Mia
WHERE Mia.Maand_nr >= 201606
GROUP BY 1,2,3,4;



INSERT INTO  MI_CMB_UIA.A_MSTR_LU_BO_Org_niv2
SELECT
	Mia.Maand_nr
   ,COALESCE(Mia.Org_niveau2_bo_nr,	-101)  Org_niveau2_bo_nr
   ,COALESCE(Mia.Org_niveau2, 'Onbekend')  Org_niveau2
   ,COALESCE(Mia.Org_niveau1_bo_nr,	-101)  Org_niveau1_bo_nr

FROM MI_VM_SAS_AA_MB_C_MB.vMia_hist		Mia
WHERE Mia.Maand_nr >= 201606
GROUP BY 1,2,3,4;


INSERT INTO  MI_CMB_UIA.A_MSTR_LU_BO_Org_niv1
SELECT
	Mia.Maand_nr
   ,COALESCE(Mia.Org_niveau1_bo_nr,	-101)  Org_niveau1_bo_nr
   ,COALESCE(CASE WHEN mia.Org_niveau1_bo_nr < 0 OR mia.Org_niveau1_bo_nr IS NULL THEN 'Onbekend' ELSE Mia.Org_niveau1 end, 'Onbekend')  Org_niveau1
   ,COALESCE(Mia.Org_niveau0_bo_nr,	-101)  Org_niveau0_bo_nr
FROM MI_VM_SAS_AA_MB_C_MB.vMia_hist		Mia
WHERE Mia.Maand_nr >= 201606
GROUP BY 1,2,3,4;



INSERT INTO  MI_CMB_UIA.A_MSTR_LU_BO_Org_niv0
SELECT
	Mia.Maand_nr
   ,COALESCE(Mia.Org_niveau0_bo_nr,	-101)  Org_niveau0_bo_nr
   ,COALESCE(CASE WHEN mia.Org_niveau0_bo_nr < 0 OR mia.Org_niveau0_bo_nr IS NULL THEN 'Onbekend' ELSE Mia.Org_niveau0 end, 'Onbekend')  Org_niveau0
FROM MI_VM_SAS_AA_MB_C_MB.vMia_hist		Mia
WHERE Mia.Maand_nr >= 201606
GROUP BY 1,2,3;


INSERT INTO MI_CMB_UIA.A_MSTR_LU_Subsegment
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_Subsegment;


DELETE FROM MI_CMB_UIA.A_MSTR_LU_Subsegment
WHERE Maand_nr = (SELECT Maand_nr FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr WHERE N_maanden_terug = 0);


INSERT INTO  MI_CMB_UIA.A_MSTR_LU_Subsegment
SELECT   a.Maand_nr
		    ,b.Subsegment_nr
		    ,b.Subsegment
FROM MI_VM_SAS_AA_MB_C_MB.vMia_week    a

INNER JOIN MI_CMB_UIA.A_MSTR_LU_Subsegment  b
   ON b.Subsegment = a.Subsegment
GROUP BY 1,2,3
;


INSERT INTO  MI_CMB_UIA.A_MSTR_LU_Subsegment
SELECT  a.Maand_nr
    ,CSUM(1, a.Subsegment DESC) + a.Max_Subsegment_nr  Subsegment_nr
    ,a.Subsegment
FROM
     (
     SELECT     a.Maand_nr
	            ,a.Subsegment
	            ,c.Max_Subsegment_nr
     FROM MI_VM_SAS_AA_MB_C_MB.vMia_week    a

     LEFT OUTER JOIN (SELECT  Subsegment_nr
						                           ,Subsegment
                       FROM MI_CMB_UIA.A_MSTR_LU_Subsegment
                       GROUP BY 1,2
                       ) b
        ON b.Subsegment = a.Subsegment

     INNER JOIN (SELECT MAX(Subsegment_nr)  Max_Subsegment_nr
                  FROM MI_CMB_UIA.A_MSTR_LU_Subsegment
                 ) c
        ON 1=1
     WHERE NOT a.Subsegment IS NULL
     AND b.Subsegment_nr IS NULL
     GROUP BY 1,2,3
     ) a;

INSERT INTO MI_CMB_UIA.A_MSTR_LU_Subsegment
SELECT     a.Maand_nr
	       ,-101
	       ,'Onbekend'
FROM MI_VM_SAS_AA_MB_C_MB.vMia_week    a
GROUP BY 1,2,3;


INSERT INTO MI_CMB_UIA.A_MSTR_LU_Contract_soort
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_Contract_soort;


DELETE FROM MI_CMB_UIA.A_MSTR_LU_Contract_soort
WHERE Maand_nr = (SELECT Maand_nr FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr WHERE N_maanden_terug = 0);

INSERT INTO MI_CMB_UIA.A_MSTR_LU_Contract_soort
SELECT b.maand_nr
		  ,a.Contract_soort_code
          ,CASE
		  WHEN a.Contract_soort_oms_lang = '' OR a.Contract_soort_oms_lang IS NULL THEN 'soortcode ' || TRIM(BOTH FROM  Contract_soort_code)
           ELSE  a.Contract_soort_oms_lang
     END  Contract_soort_oms
FROM Mi_vm_ldm.vContract_soort    a

LEFT JOIN (
SELECT Maand_nr FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr WHERE N_maanden_terug = 0
)  B
ON 1=1

WHERE a.Contract_soort_edat IS NULL
QUALIFY RANK (a.Contract_soort_sdat DESC) = 1
GROUP BY 1,2,3;


INSERT INTO MI_CMB_UIA.A_MSTR_LU_Contract_soort
SELECT     a.Maand_nr
       ,-101
       ,'Onbekend'
FROM MI_VM_SAS_AA_MB_C_MB.vMia_week    a
GROUP BY 1,2,3;


CREATE TABLE mi_temp.tb_maand_nr_scope
AS
(
SELECT 	  maand_nr
		, ROW_NUMBER() OVER (ORDER BY maand_nr DESC) - 1  mnd_trg
FROM mi_cmb.TB_Baten
GROUP BY 1
QUALIFY ROW_NUMBER() OVER (ORDER BY maand_nr DESC) <= 25
) WITH DATA UNIQUE PRIMARY INDEX(maand_nr);


CREATE TABLE mi_temp.CIB_fin_maand_nr  AS (
SELECT a.maand
				,ROW_NUMBER() OVER (ORDER BY maand ASC) *-1  mnd_trg
from 		Mi_vm_nzdb.vlu_maand a
WHERE maand GT ( SELECT Rapportage_maand FROM MI_CMB_UIA.FIN_CIB_brondata_niet_mappen GROUP BY 1))
WITH DATA UNIQUE PRIMARY INDEX(maand);


INSERT INTO  MI_CMB_UIA.A_MSTR_LU_periode
SELECT
mnd.maand  maand_nr
FROM
(select a.*, B.laatste_maand_ind, lopende_maand_ind, c.maand_naam  maand_naamx
  FROM Mi_vm_nzdb.vLu_maand A
    LEFT JOIN  Mi_vm_nzdb.vLu_maand_runs B
    ON a.maand = b.maand_nr
	AND B.Lopende_maand_ind = 1
  LEFT JOIN  Mi_vm_nzdb.vLu_maand C
    ON A.JAAR = c.jaar
	and a.maand_nr = c.maand_nr
	where A.jaar between 2014 AND 2030 )
 mnd
LEFT JOIN MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr N
ON N.maand_nr = mnd.maand
LEFT JOIN (SELECT Maand, Maand_Startdatum, Maand_einddatum FROM Mi_vm_nzdb.vlu_maand)					    E1
ON E1.maand = mnd.Maand_L1
LEFT OUTER JOIN (SELECT Maand_nr, MAX(Datum_gegevens)  Datum_gegevens FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_hist GROUP BY 1) MiaK
     ON miaK.Maand_nr = mnd.maand
LEFT OUTER JOIN (SELECT Maand_nr, MAX(Datum_baten)  Datum_baten FROM MI_SAS_AA_MB_C_MB.CIAA_Cube_Baten_hist GROUP BY 1) MiaB
    ON miaB.Maand_nr = mnd.maand
LEFT OUTER JOIN (
SELECT mnd.maand,
-1 * ROW_NUMBER ( )  OVER (  ORDER BY mnd.maand ASC )   maanden_toekomst
FROM
(select a.*, B.laatste_maand_ind, lopende_maand_ind
  FROM Mi_vm_nzdb.vLu_maand A
    LEFT JOIN  Mi_vm_nzdb.vLu_maand_runs B
    ON a.maand = b.maand_nr
	AND B.Lopende_maand_ind = 1
	where A.jaar between 2012 AND 2030 )
 mnd
LEFT JOIN MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr N
ON N.maand_nr = mnd.maand
WHERE N.maand_nr is null and mnd.maand > (
select b.maand_nr from Mi_vm_nzdb.vLu_maand_runs B
where lopende_maand_ind = 1 ) )
 M_toekomst
ON M_toekomst.maand = mnd.maand
LEFT JOIN ( SELECT *
from 		Mi_vm_nzdb.vlu_maand												a
cross join 	(select max(maand_nr)  maand_nrX from mi_temp.tb_maand_nr_scope)	b		)  TB
ON TB.maand = mnd.maand
LEFT JOIN mi_temp.CIB_fin_maand_nr  CIB
ON CIB.maand = mnd.maand;

INSERT INTO  MI_CMB_UIA.A_MSTR_LU_periode_ytd
SELECT
		   a.maand_nr
         , b.maand_nr  maand_nr_ytd
FROM mi_cmb_uia.A_MSTR_LU_periode a
JOIN mi_cmb_uia.A_MSTR_LU_periode b ON a.jaar = b.jaar
WHERE b.maand_nr <= a.maand_nr;

INSERT INTO MI_CMB_UIA.A_MSTR_LU_Rel_cat
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_Rel_cat;

DELETE FROM MI_CMB_UIA.A_MSTR_LU_Rel_cat
WHERE Maand_nr = (SELECT MAX(Maand_nr) FROM MI_SAS_AA_MB_C_MB.Mia_businesscontacts);

INSERT INTO  MI_CMB_UIA.A_MSTR_LU_Rel_cat
SELECT
    a.Maand_nr
    , a.Bc_relatiecategorie
   ,TRIM(segment_oms)
FROM  MI_SAS_AA_MB_C_MB.Mia_businesscontacts a
LEFT JOIN Mi_vm_ldm.aSegment b
	ON a.Bc_relatiecategorie = b.segment_id
   AND b.Segment_type_code = 'RELCAT'
WHERE  b.Segment_type_code = 'RELCAT'
AND NOT Bc_relatiecategorie IS NULL
GROUP BY 1,2,3;

INSERT INTO   MI_CMB_UIA.A_MSTR_LU_Rel_cat
SELECT
		a.Maand_nr
        ,-101
       ,'Onbekend'
FROM MI_SAS_AA_MB_C_MB.Mia_businesscontacts a
GROUP BY 1;


INSERT INTO MI_CMB_UIA.A_MSTR_Mia_hist
SELECT
     Mia.Klant_nr                                        Klant_nr
	,COALESCE(e.consultant_nr, -101)	  	  Consultant_TB_nr
FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_hist                 Mia

LEFT OUTER JOIN  MI_CMB_UIA.A_MSTR_LU_Business_line BL
ON BL.Maand_nr = Mia.Maand_nr
AND TRIM(BOTH FROM BL.Business_line) = TRIM(BOTH FROM Mia.Business_line)

LEFT OUTER JOIN MI_CMB_UIA.A_MSTR_LU_Segment SGM
   ON SGM.Maand_nr = Mia.Maand_nr
  AND TRIM(BOTH FROM SGM.Segment) = TRIM(BOTH FROM Mia.Segment)

LEFT OUTER JOIN MI_CMB_UIA.A_MSTR_LU_Subsegment SUBSGM
   ON SUBSGM.Maand_nr = Mia.Maand_nr
  AND TRIM(BOTH FROM SUBSGM.Subsegment) = TRIM(BOTH FROM Mia.Subsegment)

LEFT OUTER JOIN MI_CMB_UIA.A_MSTR_LU_RM    RM
   ON RM.Maand_nr = Mia.Maand_nr
  AND RM.Adviseur_nr = COALESCE(Mia.CCA,-101)
  AND TRIM(BOTH FROM RM.Adviseur_type) = 'CLTADV'

LEFT OUTER JOIN MI_CMB_UIA.A_MSTR_LU_Omzetklasse   OMZK
   ON OMZK.Maand_nr = Mia.Maand_nr
  AND OMZK.Omzetklasse_id = COALESCE(Mia.Omzetklasse_id, -101)
  AND TRIM(BOTH FROM (COALESCE(OMZK.Omzetklasse_oms, 'Onbekend    ')) )  = TRIM(BOTH FROM (COALESCE(Mia.Omzetklasse_oms, 'Onbekend')) )

LEFT OUTER JOIN MI_CMB_UIA.A_MSTR_LU_SBI SBI
   ON SBI.Sbi_code = COALESCE(Mia.Sbi_code, -101)
	AND SBI.Maand_nr = MIA.Maand_nr

 LEFT OUTER JOIN MI_CMB_UIA.A_MSTR_LU_Internat_segm ISGM
   ON TRIM(BOTH FROM (COALESCE(ISGM.Internat_segm_oms, '')) )  = TRIM(BOTH FROM (COALESCE(Mia.Internationaal_segment, '')) )
   AND ISGM.Maand_nr = Mia.Maand_nr
LEFT JOIN	MI_SAS_AA_MB_C_MB.Siebel_CST_Member_hist			d
ON Mia.klant_nr = d.klant_nr and Mia.maand_nr = d.maand_nr
and d.tb_consultant = 'y'

LEFT JOIN	MI_CMB_UIA.TB_LU_consultant				e
ON d.naam = e.consultant_naam

WHERE mia.maand_nr >= 201501;

INSERT INTO MI_CMB_UIA.A_MSTR_Mia_hist
SELECT
    -101            Klant_nr
FROM Mi_vm_sas_aa_mb_c_mb.vMia_hist    a
WHERE maand_nr >= 201501
GROUP BY 2,4;

INSERT INTO MI_CMB_UIA.A_MSTR_Groepkoppeling_hist
SELECT * FROM  MI_CMB_UIA.A_MSTR_Groepkoppeling_hist;


DELETE FROM  MI_CMB_UIA.A_MSTR_Groepkoppeling_hist
WHERE Maand_nr = (SELECT Maand_nr FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr WHERE N_maanden_terug = 0)
;

INSERT INTO  MI_CMB_UIA.A_MSTR_Groepkoppeling_hist
SELECT
Groep_nr,
Maand_nr,
Klant_nr,
Leidende_klant_ind,
Koppeling_id_CC,
Koppeling_id_CG
FROM  MI_SAS_AA_MB_C_MB.Mia_groepkoppelingen_hist
WHERE Maand_nr = (SELECT Maand_nr FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr WHERE N_maanden_terug = 0)
;


INSERT INTO  MI_CMB_UIA.A_MSTR_Groepkoppeling_hist
SELECT
        -101
		,a.Maand_nr
        ,-101
       ,0
       ,-101
       ,-101
FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr a
WHERE a.N_maanden_terug = 0
GROUP BY 1,2,3,4,5,6;

INSERT INTO MI_CMB_UIA.A_MSTR_LU_CS_Product
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_CS_Product;



DELETE FROM  MI_CMB_UIA.A_MSTR_LU_CS_Product
WHERE Maand_nr = (SELECT Maand_nr FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr WHERE N_maanden_terug = 0);


INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CS_Product
SELECT
Maand_nr,
CS_product_gebied_id,
CS_product_gebied_oms
FROM mi_vm_nzdb.vCS_product_gebied
WHERE Maand_nr = (SELECT Maand_nr FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr WHERE N_maanden_terug = 0 );

INSERT INTO MI_CMB_UIA.A_MSTR_Mia_CS_hist
SELECT * FROM MI_CMB_UIA.A_MSTR_Mia_CS_hist;



/* WEEKCIJFERS VERWIJDEREN INDIEN MAAND REEDS AANWEZIG VAN VORIGE WEEK */
DELETE FROM  MI_CMB_UIA.A_MSTR_Mia_CS_hist
WHERE CS_Maand_nr = (SELECT Maand_nr FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr WHERE N_maanden_terug = 0);



/*      WEKELIJKS bestaande codes die in deze maand aanwezig zijn overnemen */
INSERT INTO MI_CMB_UIA.A_MSTR_Mia_CS_hist
SELECT a.cc_nr  Klant_nr ,
				a.maand_nr,
				a.cs_product_gebied_id,
				1  CS_ind
FROM  Mi_vm_nzdb.vCross_sell A
LEFT JOIN MI_CMB_UIA.A_MSTR_LU_CS_product B
ON a.cs_product_gebied_id = b.cs_product_gebied_id AND a.maand_nr = b.maand_nr
WHERE A.Maand_nr = (SELECT Maand_nr FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr WHERE N_maanden_terug = 0 );



/*Dummyvelden inlezen*/
INSERT INTO MI_CMB_UIA.A_MSTR_Mia_CS_hist
SELECT
        -101
		,a.CS_Maand_nr
        ,-101
		,0
FROM MI_CMB_UIA.A_MSTR_Mia_CS_hist a
GROUP BY 2;


INSERT INTO MI_CMB_UIA.A_MSTR_Baten_hist
SELECT
        bat.Klant_nr
FROM MI_SAS_AA_MB_C_MB.CIAA_Cube_Baten_hist bat;


INSERT INTO MI_CMB_UIA.A_MSTR_Baten_hist
SELECT
        -101  Klant_nr
      FROM MI_SAS_AA_MB_C_MB.CIAA_Cube_Baten_hist bat
GROUP BY 2;


INSERT INTO MI_CMB_UIA.A_MSTR_Part_zak
SELECT
        pz.Klant_nr
       ,pz.Maand_nr
       ,pz.Klantstatus
       ,pz.Klant_ind
       ,pz.N_FHH
       ,pz.N_FHH_UBO
       ,pz.N_FHH_Bestuurder
       ,pz.N_FHH_O_en_O
       ,pz.N_FHH_Eenmanszaak
       ,pz.N_FHH_Comm_Venn
       ,pz.N_FHH_VOF
       ,pz.N_FHH_Maatschap
       ,pz.N_FHH_BV_NV_opricht
       ,pz.N_FHH_Part_zak
       ,pz.N_FHH_gemachtigde
       ,pz.N_act_FHH
       ,pz.N_act_FHH_UBO
       ,pz.N_act_FHH_Bestuurder
       ,pz.N_act_FHH_O_en_O
       ,pz.N_act_FHH_Eenmanszaak
       ,pz.N_act_FHH_Comm_Venn
       ,pz.N_act_FHH_VOF
       ,pz.N_act_FHH_Maatschap
       ,pz.N_act_FHH_BV_NV_opricht
       ,pz.N_act_FHH_Part_zak
       ,pz.N_act_FHH_gemachtigde
       ,pz.Max_Betalprobl_curatele
       ,pz.Sum_Baten_12mnd

FROM MI_SAS_AA_MB_C_MB.CIAA_Part_zak  pz;



/*  Dummyregel  */
INSERT INTO MI_CMB_UIA.A_MSTR_Part_zak
SELECT
        -101  Klant_nr
       ,pz.Maand_nr
       ,-101  Klantstatus
       ,0  Klant_ind
       ,0  N_FHH
       ,0  N_FHH_UBO
       ,0  N_FHH_Bestuurder
       ,0  N_FHH_O_en_O
       ,0  N_FHH_Eenmanszaak
       ,0  N_FHH_Comm_Venn
       ,0  N_FHH_VOF
       ,0  N_FHH_Maatschap
       ,0  N_FHH_BV_NV_opricht
       ,0  N_FHH_Part_zak
       ,0  N_FHH_gemachtigde
       ,0  N_act_FHH
       ,0  N_act_FHH_UBO
       ,0  N_act_FHH_Bestuurder
       ,0  N_act_FHH_O_en_O
       ,0  N_act_FHH_Eenmanszaak
       ,0  N_act_FHH_Comm_Venn
       ,0  N_act_FHH_VOF
       ,0  N_act_FHH_Maatschap
       ,0  N_act_FHH_BV_NV_opricht
       ,0  N_act_FHH_Part_zak
       ,0  N_act_FHH_gemachtigde
       ,0  Max_Betalprobl_curatele
       ,0  Sum_Baten_12mnd

FROM MI_SAS_AA_MB_C_MB.CIAA_Part_zak  pz
GROUP BY 2;


INSERT INTO MI_CMB_UIA.A_MSTR_LU_Baten_product
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_Baten_product;



/* WEEKCIJFERS VERWIJDEREN INDIEN MAAND REEDS AANWEZIG VAN VORIGE WEEK */
DELETE FROM MI_CMB_UIA.A_MSTR_LU_Baten_product
WHERE Baten_maand_nr = (SELECT Maand_nr FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr WHERE N_maanden_terug = 0);

 INSERT INTO MI_CMB_UIA.A_MSTR_LU_Baten_Product
 SELECT 	Maand_nr,	cube_product_id, cube_product_oms, specialist_oms
 FROM MI_SAS_AA_MB_C_MB.CUBe_producten B
 LEFT JOIN  MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr
 ON 1=1
 WHERE N_maanden_terug = 0
 GROUP BY 1,2,3,4	;


INSERT INTO MI_CMB_UIA.A_MSTR_Baten_Prod_hist
SELECT * FROM MI_CMB_UIA.A_MSTR_Baten_Prod_hist;



/* WEEKCIJFERS VERWIJDEREN INDIEN MAAND REEDS AANWEZIG VAN VORIGE WEEK */
DELETE FROM MI_CMB_UIA.A_MSTR_Baten_Prod_hist
WHERE Bat_maand_nr = (SELECT Maand_nr FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr WHERE N_maanden_terug = 0);



-- Alleen laatste maand wordt toegevoegd:
INSERT INTO MI_CMB_UIA.A_MSTR_Baten_Prod_hist
SELECT  klant_nr,
maand_nr,
cube_product_id,
baten,
lichtbeheer,
baten_benchmark,
penetratie,
baten_potentieel
FROM Mi_temp.Mia_baten_benchmarken_005 A;



INSERT INTO MI_CMB_UIA.A_MSTR_LU_Verschijningsvrm
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_Verschijningsvrm
;



COLLECT STATISTICS MI_CMB_UIA.A_MSTR_LU_Verschijningsvrm COLUMN (PARTITION);



/* WEEKCIJFERS VERWIJDEREN INDIEN MAAND REEDS AANWEZIG VAN VORIGE WEEK */
DELETE FROM MI_CMB_UIA.A_MSTR_LU_Verschijningsvrm
WHERE Maand_nr = (SELECT Maand_nr FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr WHERE N_maanden_terug = 0)
;



INSERT INTO MI_CMB_UIA.A_MSTR_LU_Verschijningsvrm
SEL
    Maand_nr
    , Bc_verschijningsvorm
   ,TRIM(Bc_verschijningsvorm_oms)

FROM  MI_SAS_AA_MB_C_MB.Mia_businesscontacts
WHERE  NOT Bc_verschijningsvorm IS NULL
GROUP BY 1,2,3
;



INSERT INTO  MI_CMB_UIA.A_MSTR_LU_Verschijningsvrm
SELECT
	a.Maand_nr
        ,-101
       ,'Onbekend'
FROM  MI_SAS_AA_MB_C_MB.Mia_businesscontacts a
GROUP BY 1
;


/* Historie overnemen */
INSERT INTO MI_CMB_UIA.A_MSTR_LU_BC_GSRI_goedgek
SELECT B.maand_nr
					,A.BC_GSRI_goedgekeurd_nr
					,A.BC_GSRI_goedgekeurd
FROM MI_CMB_UIA.A_MSTR_LU_BC_GSRI_goedgek A

LEFT JOIN (
SELECT Maand_nr FROM MI_CMB.vMia_businesscontacts GROUP BY 1
)  B
ON 1=1;



INSERT INTO  MI_CMB_UIA.A_MSTR_LU_BC_GSRI_goedgek
SELECT  a.Maand_nr
    ,CSUM(1, a.BC_GSRI_goedgekeurd DESC) + a.max_BC_GSRI_goedgekeurd_nr  BC_GSRI_goedgekeurd_nr
    ,a.BC_GSRI_goedgekeurd  BC_GSRI_goedgekeurd
FROM
     (
     SELECT     a.Maand_nr
		            ,a.BC_GSRI_goedgekeurd
		            ,c.max_BC_GSRI_goedgekeurd_nr

		FROM MI_CMB.vMia_businesscontacts a

     LEFT OUTER JOIN (SELECT  BC_GSRI_goedgekeurd_nr
                           ,BC_GSRI_goedgekeurd
                       FROM MI_CMB_UIA.A_MSTR_LU_BC_GSRI_goedgek
                       GROUP BY 1,2
                       ) b
        ON TRIM(a.BC_GSRI_goedgekeurd)  = TRIM(b.BC_GSRI_goedgekeurd )

     INNER JOIN (SELECT MAX(BC_GSRI_goedgekeurd_nr)  max_BC_GSRI_goedgekeurd_nr
                  FROM MI_CMB_UIA.A_MSTR_LU_BC_GSRI_goedgek
				  WHERE BC_GSRI_goedgekeurd_nr IS NOT NULL
                 ) c
        ON 1=1
     WHERE NOT a.BC_GSRI_goedgekeurd IS NULL
       AND b.BC_GSRI_goedgekeurd_nr IS NULL
     GROUP BY 1,2,3
     ) a;



/* Dummy regel invoegen */
INSERT INTO MI_CMB_UIA.A_MSTR_LU_BC_GSRI_goedgek
SELECT A.maand_nr
					,-101  BC_GSRI_goedgekeurd_nr
					,'Onbekend'  BC_GSRI_goedgekeurd
FROM MI_CMB.vMia_businesscontacts A
GROUP BY 1,2,3;

INSERT INTO MI_CMB_UIA.A_MSTR_LU_BC_GSRI_result
SELECT B.maand_nr
					,A.BC_GSRI_Assessment_resultaatnr
					,A.BC_GSRI_Assessment_resultaat
FROM MI_CMB_UIA.A_MSTR_LU_BC_GSRI_result A

LEFT JOIN (
SELECT Maand_nr FROM MI_CMB.vMia_businesscontacts GROUP BY 1
)  B
ON 1=1;


INSERT INTO  MI_CMB_UIA.A_MSTR_LU_BC_GSRI_result
SELECT  a.Maand_nr
    ,CSUM(1, a.BC_GSRI_Assessment_resultaat DESC) + a.max_BC_GSRI_Assessment_resultaatnr  BC_GSRI_Assessment_resultaatnr
    ,a.BC_GSRI_Assessment_resultaat  BC_GSRI_Assessment_resultaat
FROM
     (
     SELECT     a.Maand_nr
		            ,a.BC_GSRI_Assessment_resultaat
		            ,c.max_BC_GSRI_Assessment_resultaatnr

		FROM MI_CMB.vMia_businesscontacts a

     LEFT OUTER JOIN (SELECT  BC_GSRI_Assessment_resultaatnr
                           ,BC_GSRI_Assessment_resultaat
                       FROM MI_CMB_UIA.A_MSTR_LU_BC_GSRI_result
                       GROUP BY 1,2
                       ) b
        ON TRIM(b.BC_GSRI_Assessment_resultaat)  = TRIM(a.BC_GSRI_Assessment_resultaat )

     INNER JOIN (SELECT MAX(BC_GSRI_Assessment_resultaatnr)  max_BC_GSRI_Assessment_resultaatnr
                  FROM MI_CMB_UIA.A_MSTR_LU_BC_GSRI_result
                 ) c
        ON 1=1
     WHERE NOT a.BC_GSRI_Assessment_resultaat IS NULL
       AND b.BC_GSRI_Assessment_resultaatnr IS NULL
     GROUP BY 1,2,3
     ) a;


INSERT INTO MI_CMB_UIA.A_MSTR_LU_BC_GSRI_result
SELECT A.maand_nr
					,-101  BC_GSRI_Assessment_resultaatnr
					,'Onbekend'  BC_GSRI_Assessment_resultaat
FROM MI_CMB.vMia_businesscontacts A
GROUP BY 1,2,3;


INSERT INTO MI_CMB_UIA.A_MSTR_LU_BC_Business_segm
SELECT B.maand_nr
					,A.BC_Business_segment_nr
					,A.Bc_Business_segment
FROM MI_CMB_UIA.A_MSTR_LU_BC_Business_segm A

LEFT JOIN (
SELECT Maand_nr FROM MI_CMB.vMia_businesscontacts GROUP BY 1
)  B
ON 1=1;



INSERT INTO  MI_CMB_UIA.A_MSTR_LU_BC_Business_segm
SELECT  a.Maand_nr
		    ,CSUM(1, a.Bc_Business_segment DESC) + a.max_Bc_Business_segment_nr  Bc_Business_segment_nr
		    ,a.Bc_Business_segment  Bc_Business_segment
FROM
     (
     SELECT     a.Maand_nr
		            ,a.Bc_Business_segment
		            ,c.max_Bc_Business_segment_nr

		FROM MI_CMB.vMia_businesscontacts a

     LEFT OUTER JOIN (SELECT  Bc_Business_segment_nr
                           ,Bc_Business_segment
                       FROM MI_CMB_UIA.A_MSTR_LU_BC_Business_segm
                       GROUP BY 1,2
                       ) b
        ON TRIM(b.Bc_Business_segment)  = TRIM(a.Bc_Business_segment )

     INNER JOIN (SELECT MAX(Bc_Business_segment_nr)  max_Bc_Business_segment_nr
                  FROM MI_CMB_UIA.A_MSTR_LU_BC_Business_segm
                 ) c
        ON 1=1
     WHERE NOT a.Bc_Business_segment IS NULL
       AND b.Bc_Business_segment_nr IS NULL
     GROUP BY 1,2,3
     ) a;

/* Historie overnemen */
INSERT INTO MI_CMB_UIA.A_MSTR_LU_BC_Business_line
SELECT B.maand_nr
					,A.Bc_Business_line_nr
					,A.Bc_Business_line
FROM MI_CMB_UIA.A_MSTR_LU_BC_Business_line A

LEFT JOIN (
SELECT Maand_nr FROM MI_CMB.vMia_businesscontacts GROUP BY 1
)  B
ON 1=1;


/*      WEKELIJKS eventueel nieuwe codes met een nieuw nummer wegschrijven (max hist nr + CSUMnieuwe)  */
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_BC_Business_line
SELECT  a.Maand_nr
		    ,CSUM(1, a.Bc_Business_line DESC) + a.max_Bc_Business_line_nr  Bc_Business_line_nr
		    ,a.Bc_Business_line  Bc_Business_line
FROM
     (
     SELECT     a.Maand_nr
		            ,a.Bc_Business_line
		            ,c.max_Bc_Business_line_nr

		FROM MI_CMB.vMia_businesscontacts a

     LEFT OUTER JOIN (SELECT  Bc_Business_line_nr
                           ,Bc_Business_line
                       FROM MI_CMB_UIA.A_MSTR_LU_BC_Business_line
                       GROUP BY 1,2
                       ) b
        ON TRIM(b.Bc_Business_line)  = TRIM(a.Bc_Business_line )

     INNER JOIN (SELECT MAX(Bc_Business_line_nr)  max_Bc_Business_line_nr
                  FROM MI_CMB_UIA.A_MSTR_LU_BC_Business_line
                 ) c
        ON 1=1
     WHERE NOT a.Bc_Business_line IS NULL
       AND b.Bc_Business_line_nr IS NULL
     GROUP BY 1,2,3
     ) a;

INSERT INTO MI_CMB_UIA.A_MSTR_LU_BC_Segment
SELECT B.maand_nr
					,A.Bc_Segment_nr
					,A.Bc_Segment
FROM MI_CMB_UIA.A_MSTR_LU_BC_Segment A

LEFT JOIN (
SELECT Maand_nr FROM MI_CMB.vMia_businesscontacts GROUP BY 1
)  B
ON 1=1;



INSERT INTO  MI_CMB_UIA.A_MSTR_LU_BC_Segment
SELECT  a.Maand_nr
		    ,CSUM(1, a.Bc_Segment DESC) + a.max_Bc_Segment_nr  Bc_Segment_nr
		    ,a.Bc_Segment  Bc_Segment
FROM
     (
     SELECT     a.Maand_nr
		            ,a.Bc_Segment
		            ,c.max_Bc_Segment_nr

		FROM MI_CMB.vMia_businesscontacts a

     LEFT OUTER JOIN (SELECT  Bc_Segment_nr
                           ,Bc_Segment
                       FROM MI_CMB_UIA.A_MSTR_LU_BC_Segment
                       GROUP BY 1,2
                       ) b
        ON TRIM(b.Bc_Segment)  = TRIM(a.Bc_Segment )

     INNER JOIN (SELECT MAX(Bc_Segment_nr)  max_Bc_Segment_nr
                  FROM MI_CMB_UIA.A_MSTR_LU_BC_Segment
                 ) c
        ON 1=1
     WHERE NOT a.Bc_Segment IS NULL
       AND b.Bc_Segment_nr IS NULL
     GROUP BY 1,2,3
     ) a;




INSERT INTO MI_CMB_UIA.A_MSTR_Mia_businesscontact
SELECT
        A.Business_contact_nr
FROM MI_CMB.vMia_businesscontacts A

LEFT JOIN A_MSTR_LU_BC_GSRI_goedgek B
ON TRIM(A.BC_GSRI_goedgekeurd) = TRIM(B.BC_GSRI_goedgekeurd)

LEFT JOIN MI_CMB_UIA.A_MSTR_LU_BC_GSRI_result C
ON TRIM(A.BC_GSRI_Assessment_resultaat) = TRIM(C.BC_GSRI_Assessment_resultaat)

LEFT JOIN MI_CMB_UIA.A_MSTR_LU_BC_Business_segm D
ON TRIM(A.Bc_Business_segment) = TRIM(D.Bc_Business_segment)

LEFT JOIN MI_CMB_UIA.A_MSTR_LU_BC_Business_line E
ON TRIM(A.Bc_Business_line) = TRIM(E.Bc_Business_line)

LEFT JOIN MI_CMB_UIA.A_MSTR_LU_BC_Segment F
ON TRIM(A.Bc_Segment) = TRIM(F.Bc_Segment)

-- toegevoegd TB 18dec18
LEFT JOIN	mi_vm_ldm.aParty_party_relatie	i
ON  a.business_contact_nr = i.party_id
				  	AND i.party_sleutel_type = 'BC'
				  	AND i.party_relatie_type_code = 'LDPCNL'

LEFT JOIN MI_SAS_AA_MB_C_MB.Siebel_CST_Member_hist			G
on a.klant_nr = G.klant_nr and a.maand_nr = G.maand_nr and G.tb_consultant = 'y'

LEFT JOIN	MI_CMB_UIA.TB_LU_consultant				H
ON G.naam = H.consultant_naam
;




/* Dummy regel tvm met de koppeling aan de KTO tabellen */
INSERT INTO MI_CMB_UIA.A_MSTR_Mia_businesscontact
SELECT
        -101   Business_contact_nr
FROM MI_SAS_AA_MB_C_MB.Mia_businesscontacts A
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,57,58,59,60,61;



INSERT INTO MI_CMB_UIA.A_MSTR_Mia_Klantkop
SELECT
      Klant_nr ,
      Maand_nr,
      Business_contact_nr ,
      COALESCE(Koppeling_id_CC, -101),
      COALESCE(Koppeling_id_CE, -101)
FROM MI_SAS_AA_MB_C_MB.Mia_klantkoppelingen_hist
 WHERE maand_nr >= 201401;

 /* Dummy regel tvm NULL waarden */

 INSERT INTO MI_CMB_UIA.A_MSTR_Mia_Klantkop
SELECT -101,
Maand_nr,
-101,
-101,
-101
FROM MI_SAS_AA_MB_C_MB.Mia_klantkoppelingen_hist
 WHERE maand_nr >= 201401
GROUP BY 2;



INSERT INTO Mi_cmb_uia.A_MSTR_LU_kto_id
SELECT A.*
  FROM Mi_cmb_uia.A_MSTR_LU_KTO_ID A;



INSERT INTO Mi_cmb_uia.A_MSTR_LU_kto_id
SELECT CSUM(1, A.Kto_id DESC) + A.Max_kto_id_nr  Kto_id_nr,
       A.Kto_id
  FROM (SELECT XA.Kto_id  Kto_id,
               XC.Max_kto_id_nr
          FROM Mi_cmb.Mia_kto_klant_nw21 XA
          LEFT OUTER JOIN (SELECT XXA.Kto_id_nr,
                                  XXA.Kto_id
                             FROM Mi_cmb_uia.A_MSTR_LU_kto_id XXA
                            GROUP BY 1, 2)  XB
            ON TRIM(XA.Kto_id) = TRIM(XB.Kto_id)
          JOIN (SELECT MAX(XXA.Kto_id_nr)  Max_kto_id_nr
                  FROM Mi_cmb_uia.A_MSTR_LU_kto_id XXA)  XC
            ON 1 = 1
         WHERE XB.Kto_id_nr IS NULL
         GROUP BY 1, 2)  A;



INSERT INTO Mi_cmb_uia.A_MSTR_LU_kto_id
SELECT -101  Kto_id_nr,
       'Onbekend'  Kto_id
  FROM Mi_cmb.vMia_week
 GROUP BY 1, 2;


INSERT INTO Mi_cmb_uia.A_MSTR_LU_kto_onderzoek
SELECT A.*
  FROM Mi_cmb_uia.A_MSTR_LU_Kto_onderzoek A;


INSERT INTO Mi_cmb_uia.A_MSTR_LU_kto_onderzoek
SELECT CSUM(1, A.Onderzoek DESC) + A.Max_Onderzoek_nr  Onderzoek_nr,
       TRIM(A.Onderzoek)
  FROM (SELECT XA.Kto_id  Onderzoek,
               XC.Max_onderzoek_nr
          FROM Mi_cmb.Mia_kto_klant_nw21 XA
          LEFT OUTER JOIN (SELECT XXA.Kto_onderzoek_nr,
                                  XXA.Kto_onderzoek
                             FROM Mi_cmb_uia.A_MSTR_LU_kto_onderzoek XXA
                            GROUP BY 1,2)  XB
            ON TRIM(XB.Kto_Onderzoek) = TRIM(XA.KTO_ID)
          JOIN (SELECT MAX(XXA.Kto_onderzoek_nr)  Max_onderzoek_nr
                  FROM Mi_cmb_uia.A_MSTR_LU_kto_onderzoek XXA)  XC
            ON 1 = 1
         WHERE NOT XA.Kto_id IS NULL
           AND XB.Kto_onderzoek_nr IS NULL
	         AND XA.Maand_nr >= 201401
         GROUP BY 1, 2) A;







INSERT INTO Mi_cmb_uia.A_MSTR_kto_onderzoek_vraag
SELECT B.Kto_Onderzoek_nr,
       A.Vraag_ID,
       COALESCE(A.Vraag_oms_kort, 'Geen'),
       A.Vraag_oms,
       A.KTV_sdat,
       A.KTV_edat
  FROM Mi_cmb.Mia_kto_onderzoek_vraag_nw21 A
  JOIN Mi_cmb_uia.A_MSTR_LU_kto_onderzoek B
   ON TRIM(B.Kto_onderzoek) = TRIM(COALESCE(A.KTO_ID, 'Onbekend'));








INSERT INTO Mi_cmb_uia.A_MSTR_kto_antwoord
SELECT B.Kto_onderzoek_nr,
       A.Interview_nr,
       TRIM(A.Vraag_ID)  Vraag_ID,
       A.Vraag_optie_ID
  FROM Mi_cmb.Mia_kto_antwoord_nw21 A
  JOIN Mi_cmb_uia.A_MSTR_LU_kto_onderzoek B
    ON TRIM(b.Kto_Onderzoek) = TRIM(COALESCE(a.KTO_ID, 'Onbekend'));



INSERT INTO MI_CMB_UIA.A_MSTR_kto_klanten_antwoord
SELECT OREPLACE(TRIM(A.interview_nr)||TRIM(A.Vraag_id), '.', '')  Interview_vraag_id,
       E.Maand_nr,
       A.Interview_nr,
       A.Vraag_id,
       CASE
       WHEN A.Vraag_id IN( 'Q7A', 'Q1' ) THEN COALESCE(A.Vraag_optie_id, 0)
       ELSE COALESCE(A.Vraag_optie_id, 0)
       END
        Vraag_optie_id,
       COALESCE(CAST(NULL  VARCHAR(10000)), 'Geen')  Vraag_antwoord_open,
       B.Kto_id_nr,
       C.NPS_categorie,
       C.NPS_type,
       F.Vtype  Vraag_type,
       F.Cat  Vraag_categorie,
       F.Vraag_optie_oms  Vraag_omschrijving,
       COALESCE(E.periode, 000)  Rapp_periode,
       COALESCE(E.periode_oms, 'Andere periode')  Rapp_periode_oms
  FROM Mi_cmb.Mia_kto_antwoord_nw21 A
  LEFT OUTER JOIN MI_CMB_UIA.A_MSTR_LU_kto_id B
    ON TRIM(A.Kto_id) = TRIM(B.Kto_id)
  LEFT OUTER JOIN (SELECT XA.Vraag_id,
                          XA.Kto_id,
                          XA.Interview_nr,
                          XA.Vraag_optie_id,
                          CASE
                          WHEN XA.Vraag_id = 'Q7A' OR XA.Vraag_id = 'RM_NPS' THEN 'RM NPS'
                          WHEN XA.Vraag_id = 'Q1' OR XA.Vraag_id = 'V1117001' OR XA.Vraag_id = 'AA_NPS' THEN 'AA NPS'
                          WHEN XA.Vraag_id = 'Q9D1' OR XA.Vraag_id = 'Q9D2' OR XA.Vraag_id = 'Q9D3' THEN 'Concurrentie'
                          ELSE 'Geen NPS vraag'
                          END
                           NPS_Categorie,
                          CASE
                          WHEN NPS_Categorie <> 'Geen NPS vraag' THEN (CASE
                                                                       WHEN (XA.Vraag_optie_ID BETWEEN 0 AND 6) THEN 'Detractors'
                                                                       WHEN (XA.Vraag_optie_ID BETWEEN 7 AND 8) THEN 'Passives'
                                                                       WHEN (XA.Vraag_optie_ID BETWEEN 9 AND 10) THEN 'Promotors'
                                                                       WHEN (XA.Vraag_optie_ID NOT BETWEEN 0 AND 10) THEN 'Onbeantwoord'
                                                                       WHEN (XA.Vraag_optie_ID IS NULL) THEN 'Onbeantwoord'
                                                                       ELSE 'Geen NPS vraag'
                                                                       END)
                          ELSE 'Nvt'
                          END  NPS_Type
                     FROM Mi_cmb.Mia_kto_antwoord_nw21 XA)  C
    ON A.Interview_nr = C.Interview_nr
   AND A.Vraag_id = C.Vraag_id
  LEFT OUTER JOIN (SELECT XA.Maand_nr, XA.Interview_nr, XA.Kto_id, XA.Periode, XA.Periode_oms
                     FROM Mi_cmb.Mia_kto_klant_nw21 XA
                    GROUP BY 1, 2, 3, 4, 5)  E
    ON A.Interview_nr = E.Interview_nr
   AND A.Kto_id = E.Kto_id
  LEFT OUTER JOIN (SELECT XA.Vraag_ID, XA.Vtype, XA.Cat, XA.Vraag_optie_ID, XA.Vraag_optie_oms
                     FROM Mi_cmb.Mia_NPS_cat_type_optie XA
                    GROUP BY 1, 2, 3, 4, 5)  F
    ON F.Vraag_ID = A.Vraag_ID
   AND F.Vraag_optie_ID = A.Vraag_optie_id
join Mi_cmb.Mia_kto_antwoord_open_nw21 A
on 1=1
  LEFT OUTER JOIN MI_CMB_UIA.A_MSTR_LU_KTO_ID B
    ON TRIM(A.Kto_id) = TRIM(B.Kto_id)
  LEFT OUTER JOIN (SELECT XA.Vraag_id,
                          XA.Kto_id,
                          XA.Interview_nr,
                          XA.Vraag_optie_id,
                          CASE
                          WHEN XA.Vraag_id = 'Q7A' OR XA.Vraag_id = 'RM_NPS' THEN 'RM NPS'
                          WHEN XA.Vraag_id = 'Q1' OR XA.Vraag_id = 'V1117001' OR XA.Vraag_id = 'AA_NPS' THEN 'AA NPS'
                          WHEN XA.Vraag_id = 'Q9D1' OR XA.Vraag_id = 'Q9D2' OR XA.Vraag_id = 'Q9D3' THEN 'Concurrentie'
                          ELSE 'Geen NPS vraag'
                          END
                           NPS_Categorie,
                          CASE
                          WHEN NPS_Categorie <> 'Geen NPS vraag' THEN (CASE
                                                                       WHEN (XA.Vraag_optie_ID BETWEEN 0 AND 6) THEN 'Detractors'
                                                                       WHEN (XA.Vraag_optie_ID BETWEEN 7 AND 8) THEN 'Passives'
                                                                       WHEN (XA.Vraag_optie_ID BETWEEN 9 AND 10) THEN 'Promotors'
                                                                       WHEN (XA.Vraag_optie_ID NOT BETWEEN 0 AND 10) THEN 'Onbeantwoord'
                                                                       WHEN (XA.Vraag_optie_ID IS NULL) THEN 'Onbeantwoord'
                                                                       ELSE 'Geen NPS vraag'
                                                                       END)
                          ELSE 'Nvt'
                          END  NPS_Type
                     FROM Mi_cmb.Mia_kto_antwoord_nw21 XA)  C
    ON A.Interview_nr = C.Interview_nr
   AND A.Vraag_id = C.Vraag_id
  LEFT OUTER JOIN (SELECT XA.Maand_nr, XA.Interview_nr, XA.Kto_id, XA.Periode, XA.Periode_oms
                     FROM Mi_cmb.Mia_kto_klant_nw21 XA
                    GROUP BY 1, 2, 3, 4, 5)  E
    ON A.Interview_nr = E.Interview_nr
   AND A.Kto_id = E.Kto_id
 WHERE B.Kto_id_nr IS NOT NULL;








INSERT INTO Mi_cmb_uia.A_MSTR_kto_klanten
SELECT A.Maand_nr
  FROM Mi_cmb.Mia_kto_klant_nw21 A
  LEFT OUTER JOIN Mi_cmb_uia.A_MSTR_kto_antwoord B
    ON A.Interview_nr = B.Interview_nr
  LEFT OUTER JOIN Mi_cmb_uia.A_MSTR_LU_CRM_contact_methode C
    ON TRIM(A.Contactmethode) = TRIM(C.Contact_methode)
  LEFT OUTER JOIN Mi_cmb_uia.A_MSTR_LU_kto_id D
    ON A.Kto_id = D.Kto_id
  LEFT OUTER JOIN MI_SAS_AA_MB_C_MB.Mia_NPS_periode E
    ON A.Periode = E.Periode
  LEFT OUTER JOIN (SELECT DISTINCT(XA.Interview_nr), XB.Klant_nr, XC.Org_niveau1_bo_nr, XC.Org_niveau2_bo_nr, XC.Org_niveau3_bo_nr
                     FROM Mi_cmb.Mia_kto_klant_nw21 XA
                     JOIN Mi_cmb.vMia_klantkoppelingen XB
                       ON XA.Business_contact_nr = XB.Business_contact_nr
                     JOIN Mi_cmb.vMia_week XC
                       ON XB.Klant_nr = XC.Klant_nr AND XB.Maand_nr = XC.Maand_nr
                    WHERE XC.Org_niveau3_bo_nr IS NOT NULL)  Klant_nu
    ON A.Interview_nr = Klant_nu.Interview_nr
  LEFT OUTER JOIN (SELECT DISTINCT(XA.Interview_nr), XB.Klant_nr, XC.Org_niveau1_bo_nr, XC.Org_niveau2_bo_nr, XC.Org_niveau3_bo_nr
                     FROM Mi_cmb.Mia_kto_klant_nw21 XA
                     JOIN Mi_cmb.vMia_klantkoppelingen_hist XB
                       ON XA.Business_contact_nr = XB.Business_contact_nr
                     JOIN Mi_cmb.vMia_hist XC
                       ON XB.Klant_nr = XC.Klant_nr AND XB.Maand_nr = XC.Maand_nr
                    WHERE XC.Org_niveau3_bo_nr IS NOT NULL
                  QUALIFY RANK() OVER (PARTITION BY XA.Interview_nr ORDER BY XB.Maand_nr DESC) = 1)  Klant_hist
    ON A.Interview_nr = Klant_hist.Interview_nr
  LEFT OUTER JOIN (SELECT DISTINCT(XA.Interview_nr), XA.CCA, XB.Org_niveau1_bo_nr, XB.Org_niveau2_bo_nr, XB.Org_niveau3_bo_nr
                     FROM Mi_cmb.Mia_kto_klant_nw21 XA
                     JOIN (SELECT XXA.CCA, XXA.Org_niveau1_bo_nr, XXA.Org_niveau2_bo_nr, XXA.Org_niveau3_bo_nr, COUNT(*)  Aantal_klanten, SUM(XXA.Businessvolume)  Som_volume, SUM(XXA.Business_contact_nr)  Som_bc
                             FROM Mi_cmb.vMia_week XXA
                            WHERE XXA.CCA IS NOT NULL
                              AND XXA.Org_niveau3_bo_nr IS NOT NULL
                              AND XXA.Org_niveau3_bo_nr NOT IN (-101, -103)
                          QUALIFY RANK() OVER (PARTITION BY XXA.CCA ORDER BY Aantal_klanten DESC, Som_volume DESC, Som_bc DESC) = 1
                            GROUP BY 1, 2, 3, 4)  XB
                       ON XA.CCA = XB.CCA)  CCA_nu
    ON A.Interview_nr = CCA_nu.Interview_nr
  LEFT OUTER JOIN (SELECT DISTINCT(XA.Interview_nr), XA.CCA, XB.Org_niveau1_bo_nr, XB.Org_niveau2_bo_nr, XB.Org_niveau3_bo_nr
                     FROM Mi_cmb.Mia_kto_klant_nw21 XA
                     JOIN (SELECT XXA.CCA, XXA.Maand_nr, XXA.Org_niveau1_bo_nr, XXA.Org_niveau2_bo_nr, XXA.Org_niveau3_bo_nr, COUNT(*)  Aantal_klanten, SUM(XXA.Businessvolume)  Som_volume, SUM(XXA.Business_contact_nr)  Som_bc
                             FROM Mi_cmb.vMia_hist XXA
                            WHERE XXA.CCA IS NOT NULL
                              AND XXA.CCA NOT IN (0, -101)
                              AND XXA.Org_niveau3_bo_nr IS NOT NULL
                              AND XXA.Org_niveau3_bo_nr NOT IN (-101, -103)
                            GROUP BY 1, 2, 3, 4, 5)  XB
                       ON XA.CCA = XB.CCA
                  QUALIFY RANK() OVER (PARTITION BY XB.CCA ORDER BY XB.Maand_nr DESC, XB.Aantal_klanten DESC, XB.Som_volume DESC, XB.Som_bc DESC) = 1)  CCA_hist
    ON A.Interview_nr = CCA_hist.Interview_nr;





INSERT INTO Mi_cmb_uia.A_MSTR_Mia_hist
SELECT A.Klant_nr,
       -101,
       'Anoniem',
       0,
       A.Maand_nr,
       A.CCA,
       A.Org_niveau1_bo_nr,
       A.Org_niveau2_bo_nr,
       A.Org_niveau3_bo_nr
  FROM Mi_cmb_uia.A_MSTR_kto_klanten A
 WHERE A.Klant_nr < 0
 GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9;





INSERT INTO Mi_cmb_uia.A_MSTR_Mia_Klantkop
SELECT Klant_nr,
       Maand_nr,
       -101
  FROM Mi_cmb_uia.A_MSTR_kto_klanten
 WHERE Klant_nr < 0
 GROUP BY 1, 2, 3;



INSERT INTO Mi_cmb_uia.A_MSTR_kto_invites
SELECT B.Kto_onderzoek_nr  KTO_ID,
       A.Selectie_id,
       A.Maand_nr,
       A.Maildatum,
       A.Business_contact_nr,
       A.Sbt_id_mdw_1,
       A.Mdw_naam_1,
       A.Mdw_email_1,
       A.Sbt_id_leidingg_mdw_1,
       A.Leidingg_naam_mdw_1,
       A.Leidingg_email_mdw_1,
       A.Flag,
       A.Export_date
  FROM Mi_export.Ipsos_nps A
  LEFT OUTER JOIN Mi_cmb_uia.A_MSTR_LU_kto_onderzoek B
    ON A.KTO_ID = B.Kto_onderzoek;





CREATE TABLE MI_CMB_UIA.A_MSTR_LU_Kto_GTO_proces AS (select * from MI_CMB_UIA.A_MSTR_LU_Kto_GTO_proces) WITH DATA AND STATS;


CREATE TABLE Mi_cmb_uia.A_MSTR_kto_vraag_optie AS (select * from Mi_cmb_uia.A_MSTR_kto_vraag_optie) WITH DATA AND STATS;


CREATE TABLE MI_CMB_UIA.A_MSTR_LU_Kto_Klantgroep AS (select * from MI_CMB_UIA.A_MSTR_LU_Kto_Klantgroep) WITH DATA AND STATS;


CREATE TABLE MI_CMB_UIA.A_MSTR_LU_Kto_Medewerker  AS (select * from MI_CMB_UIA.A_MSTR_LU_Kto_Medewerker) WITH DATA AND STATS;


CREATE TABLE MI_CMB_UIA.A_MSTR_LU_Kto_Medium  AS (select * from MI_CMB_UIA.A_MSTR_LU_Kto_Medium) WITH DATA AND STATS;


CREATE TABLE MI_CMB_UIA.A_MSTR_LU_Kto_Regio AS (select * from MI_CMB_UIA.A_MSTR_LU_Kto_Regio) WITH DATA AND STATS;


CREATE TABLE MI_CMB_UIA.A_MSTR_LU_Kto_Soort_onderz AS (select * from MI_CMB_UIA.A_MSTR_LU_Kto_Soort_onderz) WITH DATA AND STATS;


CREATE TABLE MI_CMB_UIA.A_MSTR_kto_antwoord_open AS (select * from MI_CMB_UIA.A_MSTR_kto_antwoord_open) WITH DATA AND STATS;


CREATE TABLE MI_cmb_uia.A_MSTR_kto_klant AS (select * from MI_CMB_UIA.A_MSTR_kto_klant) WITH DATA AND STATS;




/* Historie overnemen */
INSERT INTO MI_CMB_UIA.A_MSTR_LU_CRM_Selling_type
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_CRM_Selling_type;


/* WEEKCIJFERS VERWIJDEREN INDIEN MAAND REEDS AANWEZIG VAN VORIGE WEEK */
DELETE FROM MI_CMB_UIA.A_MSTR_LU_CRM_Selling_type
WHERE Maand_nr = (SELECT Maand_nr FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr WHERE N_maanden_terug = 0);



/*      WEKELIJKS bestaande codes die in deze maand aanwezig zijn overnemen */
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_Selling_type
SELECT  a.Maand_nr
    ,b.selling_type_nr
    ,b.selling_type
FROM MI_CMB.vCRM_Verkoopkans_week  a
INNER JOIN MI_CMB_UIA.A_MSTR_LU_CRM_Selling_type  b
   ON TRIM(b.selling_type)  = TRIM(a.selling_type)
WHERE a.selling_type IS NOT NULL
GROUP BY 1,2,3
;

/*      WEKELIJKS eventueel nieuwe codes met een nieuw nummer wegschrijven (max hist nr + CSUMnieuwe)  */
INSERT INTO MI_CMB_UIA.A_MSTR_LU_CRM_Selling_type
SELECT  a.Maand_nr
    ,CSUM(1, a.selling_type DESC) + a.Max_selling_type_nr  selling_type_nr
    ,a.selling_type
FROM
     (
     SELECT     a.Maand_nr
            ,a.selling_type
            ,c.Max_selling_type_nr
     FROM MI_CMB.vCRM_Verkoopkans_week     a

     LEFT OUTER JOIN (SELECT  selling_type_nr
                           ,selling_type
                       FROM MI_CMB_UIA.A_MSTR_LU_CRM_Selling_type
                       GROUP BY 1,2
                       ) b
        ON b.selling_type = a.selling_type

     INNER JOIN (SELECT MAX(selling_type_nr)  Max_selling_type_nr
                  FROM MI_CMB_UIA.A_MSTR_LU_CRM_Selling_type
                 ) c
        ON 1=1
     WHERE b.selling_type_nr IS NULL
	 	 AND a.selling_type IS NOT NULL
     GROUP BY 1,2,3
     ) a;



-- Dummy regel voor NULL waardes
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_Selling_type
SELECT     a.Maand_nr
       ,-101  selling_type_nr
       ,'Onbekend'
FROM MI_CMB.vCRM_Verkoopkans_week     a
GROUP BY 1;



INSERT INTO MI_CMB_UIA.A_MSTR_LU_CRM_status_verk
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_CRM_status_verk;



COLLECT STATISTICS MI_CMB_UIA.A_MSTR_LU_CRM_status_verk COLUMN (PARTITION);



/* WEEKCIJFERS VERWIJDEREN INDIEN MAAND REEDS AANWEZIG VAN VORIGE WEEK */
DELETE FROM MI_CMB_UIA.A_MSTR_LU_CRM_status_verk
WHERE Maand_nr = (SELECT Maand_nr FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr WHERE N_maanden_terug = 0);



/*      WEKELIJKS bestaande codes die in deze maand aanwezig zijn overnemen */
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_status_verk
SELECT  a.Maand_nr
    ,b.status_nr
    ,TRIM(b.status)  status
FROM MI_CMB.vCRM_Verkoopkans_week  a

INNER JOIN MI_CMB_UIA.A_MSTR_LU_CRM_status_verk  b
    ON TRIM(b.status)  = TRIM(a.status)
WHERE a.status IS NOT NULL
GROUP BY 1,2,3;

/*      WEKELIJKS eventueel nieuwe codes met een nieuw nummer wegschrijven (max hist nr + CSUMnieuwe)  */
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_status_verk
SELECT  a.Maand_nr
    ,CSUM(1, a.status DESC) + a.Max_status_nr  status_nr
    ,a.status
FROM
     (
     SELECT     a.Maand_nr
            ,TRIM(a.status)  status
            ,c.Max_status_nr
     FROM MI_CMB.vCRM_Verkoopkans_week     a

     LEFT OUTER JOIN (SELECT  status_nr
                           ,status
                       FROM MI_CMB_UIA.A_MSTR_LU_CRM_status_verk
                       GROUP BY 1,2
                       ) b
        ON TRIM(b.status) = TRIM(a.status)

     INNER JOIN (SELECT MAX(status_nr)  Max_status_nr
                  FROM MI_CMB_UIA.A_MSTR_LU_CRM_status_verk
                 ) c
        ON 1=1
     WHERE b.status_nr IS NULL
	 AND a.status IS NOT NULL
     GROUP BY 1,2,3
     ) a;



-- Dummy regel voor NULL waardes
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_status_verk
SELECT     a.Maand_nr
       ,-101  status_nr
       ,'Onbekend'
FROM MI_CMB.vCRM_Verkoopkans_week     a
GROUP BY 1;





/* Historie overnemen */
INSERT INTO MI_CMB_UIA.A_MSTR_LU_CRM_stat_prod
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_CRM_stat_prod;



COLLECT STATISTICS MI_CMB_UIA.A_MSTR_LU_CRM_stat_prod COLUMN (PARTITION);



/* WEEKCIJFERS VERWIJDEREN INDIEN MAAND REEDS AANWEZIG VAN VORIGE WEEK */
DELETE FROM MI_CMB_UIA.A_MSTR_LU_CRM_stat_prod
WHERE Maand_nr = (SELECT Maand_nr FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr WHERE N_maanden_terug = 0);



/*      WEKELIJKS bestaande codes die in deze maand aanwezig zijn overnemen */
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_stat_prod
SELECT  a.Maand_nr
    ,b.status_product_nr
    ,TRIM(b.status_product)  status_product
FROM MI_CMB.vCRM_Verkoopkans_product_week  a

INNER JOIN MI_CMB_UIA.A_MSTR_LU_CRM_stat_prod  b
   ON TRIM(b.status_product )  = TRIM(a.status)
WHERE TRIM(a.status) IS NOT NULL AND TRIM(a.status) <> ''
GROUP BY 1,2,3;

/*      WEKELIJKS eventueel nieuwe codes met een nieuw nummer wegschrijven (max hist nr + CSUMnieuwe)  */
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_stat_prod
SELECT  a.Maand_nr
    ,CSUM(1, a.status_product DESC) + a.Max_status_product_nr  status_product_nr
    ,TRIM(a.status_product)  status_product
FROM
     (
     SELECT     a.Maand_nr
            ,TRIM(a.status)  status_product
            ,c.Max_status_product_nr
     FROM MI_CMB.vCRM_Verkoopkans_product_week     a

     LEFT OUTER JOIN (SELECT  status_product_nr
                           ,status_product
                       FROM MI_CMB_UIA.A_MSTR_LU_CRM_stat_prod
                       GROUP BY 1,2
                       ) b
        ON b.status_product = a.status

     INNER JOIN (SELECT MAX(status_product_nr)  Max_status_product_nr
                  FROM MI_CMB_UIA.A_MSTR_LU_CRM_stat_prod
                 ) c
        ON 1=1
     WHERE b.status_product_nr IS NULL
	 AND TRIM(a.status) IS NOT NULL AND TRIM(a.status) <> ''
     GROUP BY 1,2,3
     ) a;



-- Dummy regel voor NULL waardes
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_stat_prod
SELECT     a.Maand_nr
       ,-101  status_product_nr
       ,'Onbekend'
FROM MI_CMB.vCRM_Verkoopkans_product_week     a
GROUP BY 1;

/* Historie overnemen */
INSERT INTO MI_CMB_UIA.A_MSTR_LU_CRM_substat_prod
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_CRM_substat_prod;






/* WEEKCIJFERS VERWIJDEREN INDIEN MAAND REEDS AANWEZIG VAN VORIGE WEEK */
DELETE FROM MI_CMB_UIA.A_MSTR_LU_CRM_substat_prod
WHERE Maand_nr = (SELECT Maand_nr FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr WHERE N_maanden_terug = 0);



/*      WEKELIJKS bestaande codes die in deze maand aanwezig zijn overnemen */
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_substat_prod
SELECT  a.Maand_nr
    ,b.substatus_product_nr
    ,TRIM(b.substatus_product)  substatus_product
FROM MI_CMB.vCRM_Verkoopkans_product_week  a

INNER JOIN MI_CMB_UIA.A_MSTR_LU_CRM_substat_prod  b
   ON TRIM(b.substatus_product)  = TRIM(a.substatus)
WHERE TRIM(a.substatus) IS NOT NULL AND TRIM(a.substatus) <> ''
GROUP BY 1,2,3
;

/*      WEKELIJKS eventueel nieuwe codes met een nieuw nummer wegschrijven (max hist nr + CSUMnieuwe)  */
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_substat_prod
SELECT  a.Maand_nr
    ,CSUM(1, a.substatus_product DESC) + a.Max_substatus_product_nr  substatus_product_nr
    ,a.substatus_product
FROM
     (
     SELECT     a.Maand_nr
            ,TRIM(a.substatus)  Substatus_product
            ,c.Max_substatus_product_nr
     FROM MI_CMB.vCRM_Verkoopkans_product_week     a

     LEFT OUTER JOIN (SELECT  substatus_product_nr
                           ,TRIM(substatus_product)  substatus_product
                       FROM MI_CMB_UIA.A_MSTR_LU_CRM_substat_prod
                       GROUP BY 1,2
                       ) b
        ON TRIM(b.substatus_product) = TRIM(a.substatus)

     INNER JOIN (SELECT MAX(substatus_product_nr)  Max_substatus_product_nr
                  FROM MI_CMB_UIA.A_MSTR_LU_CRM_substat_prod
                 ) c
        ON 1=1
     WHERE b.substatus_product_nr IS NULL
	 AND TRIM(a.substatus) IS NOT NULL AND TRIM(a.substatus) <> ''
     GROUP BY 1,2,3
     ) a
;



-- Dummy regel voor NULL waardes
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_substat_prod
SELECT     a.Maand_nr
       ,-101  substatus_product_nr
       ,'Onbekend'
FROM MI_CMB.vCRM_Verkoopkans_product_week     a
GROUP BY 1
;



/* Historie overnemen */
INSERT INTO MI_CMB_UIA.A_MSTR_LU_CRM_Product
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_CRM_Product;




/* WEEKCIJFERS VERWIJDEREN INDIEN MAAND REEDS AANWEZIG VAN VORIGE WEEK */
DELETE FROM MI_CMB_UIA.A_MSTR_LU_CRM_Product
WHERE Maand_nr = (SELECT Maand_nr FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr WHERE N_maanden_terug = 0)
;



/*      WEKELIJKS bestaande codes die in deze maand aanwezig zijn overnemen */
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_Product
SELECT  a.Maand_nr
    ,b.Product_nr
    ,TRIM(b.Product_naam)
FROM MI_CMB.vCRM_Verkoopkans_product_week  a

INNER JOIN MI_CMB_UIA.A_MSTR_LU_CRM_Product  b
   ON  TRIM(b.Product_naam)  = TRIM(a.Productnaam)
WHERE NOT TRIM(a.Productnaam) IS NULL
GROUP BY 1,2,3;

/*      WEKELIJKS eventueel nieuwe codes met een nieuw nummer wegschrijven (max hist nr + CSUMnieuwe)  */
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_Product
SELECT  a.Maand_nr
    ,CSUM(1, a.Product_naam DESC) + a.Max_Product_nr  Product_nr
    ,TRIM(a.Product_naam)  Product_naam
FROM
     (
     SELECT     a.Maand_nr
            ,TRIM(a.Productnaam)  Product_naam
            ,c.Max_Product_nr
     FROM MI_CMB.vCRM_Verkoopkans_product_week  a

     LEFT OUTER JOIN (SELECT  Product_nr
                           ,TRIM(Product_naam)  Product_naam
                       FROM MI_CMB_UIA.A_MSTR_LU_CRM_Product
                       GROUP BY 1,2
                       ) b
        ON TRIM(b.Product_naam)  = TRIM(a.Productnaam)

     INNER JOIN (SELECT MAX(Product_nr)  Max_Product_nr
                  FROM MI_CMB_UIA.A_MSTR_LU_CRM_Product
                 ) c
        ON 1=1
     WHERE b.Product_nr IS NULL
		AND  TRIM(a.Productnaam) IS NOT NULL
	 GROUP BY 1,2,3
     ) a;

    -- Dummy regel voor NULL waardes
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_Product
SELECT     a.Maand_nr
       ,-101  Product_nr
       ,'Onbekend'
FROM MI_CMB.vCRM_Verkoopkans_product_week  a
GROUP BY 1
;


/* Historie overnemen */
INSERT INTO MI_CMB_UIA.A_MSTR_LU_CRM_Productgroep
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_CRM_Productgroep
;


/* WEEKCIJFERS VERWIJDEREN INDIEN MAAND REEDS AANWEZIG VAN VORIGE WEEK */
DELETE FROM MI_CMB_UIA.A_MSTR_LU_CRM_Productgroep
WHERE Maand_nr = (SELECT Maand_nr FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr WHERE N_maanden_terug = 0)
;



/*      WEKELIJKS bestaande codes die in deze maand aanwezig zijn overnemen */
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_Productgroep
SELECT  b.Maand_nr
    ,a.product_groep_nr
    ,TRIM(a.product_groep)  product_groep
FROM MI_CMB_UIA.A_MSTR_LU_CRM_Productgroep a

INNER JOIN
(
	SELECT DISTINCT maand_nr  maand_nr, TRIM(productgroep)  product_groep FROM MI_CMB.vCRM_Verkoopkans_product_week
	JOIN Mi_cmb.vCRM_Activiteit_week
	on 1=1
	WHERE TRIM(product_groep) IS NOT NULL AND product_groep <> ''
	GROUP BY 1,2
)  B
   ON  TRIM(BOTH FROM (COALESCE(b.product_groep, '')) )  = TRIM(BOTH FROM (COALESCE(a.product_groep, '')) )
   AND NOT TRIM(b.product_groep) IS NULL AND NOT TRIM(a.product_groep) IS NULL
WHERE NOT TRIM(a.product_groep) IS NULL
GROUP BY 1,2,3;

/*      WEKELIJKS eventueel nieuwe codes met een nieuw nummer wegschrijven (max hist nr + CSUMnieuwe)  */
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_Productgroep
SELECT  a.Maand_nr
    ,CSUM(1, a.product_groep DESC) + a.Max_product_groep_nr  product_groep_nr
    ,TRIM(a.product_groep)  Product_groep
FROM
     (
     SELECT     a.Maand_nr
            ,TRIM(a.product_groep)  product_groep
            ,c.Max_product_groep_nr
     FROM
     (
    SELECT DISTINCT maand_nr  maand_nr, TRIM(productgroep)  product_groep FROM MI_CMB.vCRM_Verkoopkans_product_week
	JOIN MI_CMB.vCRM_Activiteit_week
	on 1=1
	WHERE TRIM(product_groep) IS NOT NULL AND product_groep <> ''
	GROUP BY 1,2
	)  A
LEFT OUTER JOIN (SELECT  product_groep_nr
                           ,TRIM(product_groep)  product_groep
                       FROM MI_CMB_UIA.A_MSTR_LU_CRM_Productgroep
                       GROUP BY 1,2
                       ) b
   ON  TRIM(b.product_groep)  = TRIM(a.product_groep)
		AND NOT TRIM(b.product_groep) IS NULL AND NOT TRIM(a.product_groep) IS NULL
     INNER JOIN (SELECT MAX(product_groep_nr)  Max_product_groep_nr
                  FROM MI_CMB_UIA.A_MSTR_LU_CRM_Productgroep
                 ) c
        ON 1=1
     WHERE NOT TRIM(a.product_groep) IS NULL
       AND b.product_groep_nr IS NULL
     GROUP BY 1,2,3
     ) a;

    -- Dummy regel voor NULL waardes
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_Productgroep
SELECT     a.Maand_nr
       ,-101  product_groep_nr
       ,'Onbekend'
FROM MI_CMB.vCRM_Verkoopkans_product_week  a
GROUP BY 1
;



/* Historie overnemen */
INSERT INTO MI_CMB_UIA.A_MSTR_LU_CRM_Type_contact
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_CRM_Type_contact
;


COLLECT STATISTICS MI_CMB_UIA.A_MSTR_LU_CRM_Type_contact COLUMN (PARTITION);



/* WEEKCIJFERS VERWIJDEREN INDIEN MAAND REEDS AANWEZIG VAN VORIGE WEEK */
DELETE FROM MI_CMB_UIA.A_MSTR_LU_CRM_Type_contact
WHERE Maand_nr = (SELECT Maand_nr FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr WHERE N_maanden_terug = 0)
;



/*      WEKELIJKS bestaande codes die in deze maand aanwezig zijn overnemen */
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_Type_contact
SELECT  a.Maand_nr
    ,b.Type_contact_nr
    ,TRIM(b.Type_contact)  type_contact
FROM MI_CMB.vCRM_Activiteit_week a

INNER JOIN MI_CMB_UIA.A_MSTR_LU_CRM_Type_contact  b
   ON  TRIM(BOTH FROM (COALESCE(b.Type_contact, '')) )  = TRIM(BOTH FROM (COALESCE(a.Activiteit_type, '')) )
WHERE NOT TRIM(a.Activiteit_type) IS NULL AND TRIM(a.Activiteit_type) <> ''
GROUP BY 1,2,3
;

/*      WEKELIJKS eventueel nieuwe codes met een nieuw nummer wegschrijven (max hist nr + CSUMnieuwe)  */
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_Type_contact
SELECT  a.Maand_nr
    ,CSUM(1, a.Type_contact DESC) + a.Max_Type_contact_nr  Type_contact_nr
    ,TRIM(a.Type_contact)  type_contact
FROM
     (
     SELECT     a.Maand_nr
            , TRIM(a.Activiteit_type)  type_contact
            ,c.Max_Type_contact_nr
FROM MI_CMB.vCRM_Activiteit_week a

     LEFT OUTER JOIN (SELECT  Type_contact_nr
                           ,TRIM(Type_contact)  Type_contact
                       FROM MI_CMB_UIA.A_MSTR_LU_CRM_Type_contact
                       GROUP BY 1,2
                       ) b
   ON  TRIM(b.Type_contact )  = TRIM(a.Activiteit_type)

     INNER JOIN (SELECT MAX(Type_contact_nr)  Max_Type_contact_nr
                  FROM MI_CMB_UIA.A_MSTR_LU_CRM_Type_contact
                 ) c
        ON 1=1
     WHERE NOT TRIM(a.Activiteit_type) IS NULL AND TRIM(a.Activiteit_type) <> ''
       AND b.Type_contact_nr IS NULL
     GROUP BY 1,2,3
     ) a
;

	-- Dummy regel voor NULL waardes
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_Type_contact
SELECT     a.Maand_nr
       ,-101  Type_contact_nr
       ,'Onbekend'
FROM MI_CMB.vCRM_Activiteit_week a
GROUP BY 1
;


/* Historie overnemen */
INSERT INTO MI_CMB_UIA.A_MSTR_LU_CRM_contact_methode
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_CRM_contact_methode
;



/*      WEKELIJKS eventueel nieuwe codes met een nieuw nummer wegschrijven (max hist nr + CSUMnieuwe)  */
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_contact_methode
SELECT CSUM(1, a.contact_methode DESC) + a.Max_contact_methode_nr  contact_methode_nr
    ,TRIM(a.contact_methode)  contact_methode
FROM
     (
     SELECT  TRIM(a.contact_methode)  contact_methode
            ,c.Max_contact_methode_nr
FROM Mi_cmb.vCRM_Activiteit_week  a

     LEFT OUTER JOIN (SELECT  contact_methode_nr
                           ,TRIM(contact_methode)  contact_methode
                       FROM MI_CMB_UIA.A_MSTR_LU_CRM_contact_methode
                       GROUP BY 1,2
                       ) b
        ON TRIM(b.contact_methode)  = TRIM(a.contact_methode )


     INNER JOIN (SELECT MAX(contact_methode_nr)  Max_contact_methode_nr
                  FROM MI_CMB_UIA.A_MSTR_LU_CRM_contact_methode
                 ) c
        ON 1=1
     WHERE NOT TRIM(a.contact_methode) IS NULL AND TRIM(a.contact_methode) <> ''
       AND b.contact_methode_nr IS NULL
     GROUP BY 1,2
     ) a;

    -- Dummy regel voor NULL waardes
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_contact_methode
SELECT  -101  contact_methode_nr
       ,'Onbekend'
FROM MI_SAS_AA_MB_C_MB.Siebel_Activiteit  a
GROUP BY 1,2;



COLLECT STATISTICS MI_CMB_UIA.A_MSTR_LU_CRM_Contact_methode COLUMN (PARTITION);
COLLECT STATISTICS MI_CMB_UIA.A_MSTR_LU_CRM_Contact_methode COLUMN (Contact_methode_nr);
COLLECT STATISTICS MI_CMB_UIA.A_MSTR_LU_CRM_Contact_methode COLUMN (Contact_methode);
COLLECT STATISTICS MI_CMB_UIA.A_MSTR_LU_CRM_Contact_methode COLUMN (Contact_methode, Contact_methode_nr );



/* Historie overnemen */
INSERT INTO MI_CMB_UIA.A_MSTR_LU_CRM_contactmeth
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_CRM_contactmeth
;


COLLECT STATISTICS MI_CMB_UIA.A_MSTR_LU_CRM_contactmeth COLUMN (PARTITION);



/* WEEKCIJFERS VERWIJDEREN INDIEN MAAND REEDS AANWEZIG VAN VORIGE WEEK */
DELETE FROM MI_CMB_UIA.A_MSTR_LU_CRM_contactmeth
WHERE Maand_nr = (SELECT Maand_nr FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr WHERE N_maanden_terug = 0)
;



/*      WEKELIJKS bestaande codes die in deze maand aanwezig zijn overnemen */
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_contactmeth
SELECT  a.Maand_nr
    ,b.contactmethode_nr
    ,TRIM(b.contactmethode)  contactmethode
FROM MI_CMB.vCRM_Activiteit_week a

INNER JOIN MI_CMB_UIA.A_MSTR_LU_CRM_contactmeth  b
   ON  TRIM(b.contactmethode)  = TRIM(a.contact_methode)
WHERE NOT TRIM(a.contact_methode) IS NULL AND TRIM(a.contact_methode) <> ''
GROUP BY 1,2,3;

/*      WEKELIJKS eventueel nieuwe codes met een nieuw nummer wegschrijven (max hist nr + CSUMnieuwe)  */
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_contactmeth
SELECT  a.Maand_nr
    ,CSUM(1, a.contactmethode DESC) + a.Max_contactmethode_nr  contactmethode_nr
    ,TRIM(a.contactmethode)  contactmethode
FROM
     (
     SELECT     a.Maand_nr
            ,TRIM(a.contact_methode)  contactmethode
            ,c.Max_contactmethode_nr
FROM MI_CMB.vCRM_Activiteit_week a

     LEFT OUTER JOIN (SELECT  contactmethode_nr
                           ,TRIM(contactmethode)  contactmethode
                       FROM MI_CMB_UIA.A_MSTR_LU_CRM_contactmeth
                       GROUP BY 1,2
                       ) b
        ON TRIM(b.contactmethode)  = TRIM(a.contact_methode )

     INNER JOIN (SELECT MAX(contactmethode_nr)  Max_contactmethode_nr
                  FROM MI_CMB_UIA.A_MSTR_LU_CRM_contactmeth
                 ) c
        ON 1=1
     WHERE NOT TRIM(a.contact_methode) IS NULL AND TRIM(a.contact_methode) <> ''
       AND b.contactmethode_nr IS NULL
     GROUP BY 1,2,3
     ) a;

    -- Dummy regel voor NULL waardes
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_contactmeth
SELECT     a.Maand_nr
       ,-101  contactmethode_nr
       ,'Onbekend'
FROM MI_CMB.vCRM_Activiteit_week a
GROUP BY 1;



/* Historie overnemen */
INSERT INTO MI_CMB_UIA.A_MSTR_LU_CRM_act_status
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_CRM_act_status
;


COLLECT STATISTICS MI_CMB_UIA.A_MSTR_LU_CRM_act_status COLUMN (PARTITION);



/*      Eventueel nieuwe codes met een nieuw nummer wegschrijven (max hist nr + CSUMnieuwe)  */
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_act_status
SELECT  CSUM(1, a.act_status DESC) + 1  act_status_nr
    ,TRIM(a.act_status)  act_status
FROM
     (
     SELECT TRIM(a.Status)  act_status
            ,c.Max_act_status_nr
FROM Mi_cmb.vCRM_Activiteit_week  a

     LEFT OUTER JOIN (SELECT  act_status_nr
                           ,TRIM(act_status)  act_status
                       FROM MI_CMB_UIA.A_MSTR_LU_CRM_act_status
                       GROUP BY 1,2
                       ) b
        ON TRIM(b.act_status)  = TRIM(a.status )

     INNER JOIN (SELECT MAX(act_status_nr)  Max_act_status_nr
                  FROM MI_CMB_UIA.A_MSTR_LU_CRM_act_status
                 ) c
        ON 1=1
     WHERE NOT TRIM(a.status) IS NULL AND TRIM(a.status) <> ''
       AND b.act_status_nr IS NULL
     GROUP BY 1,2
     ) a;




/* Historie overnemen */
INSERT INTO MI_CMB_UIA.A_MSTR_LU_CRM_act_sub_type
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_CRM_act_sub_type
;


COLLECT STATISTICS MI_CMB_UIA.A_MSTR_LU_CRM_act_sub_type COLUMN (PARTITION);



/*      Eventueel nieuwe codes met een nieuw nummer wegschrijven (max hist nr + CSUMnieuwe)  */
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_act_sub_type
SELECT   CSUM(1, a.act_sub_type DESC) + a.Max_act_sub_type_nr  act_sub_type_nr
    ,TRIM(a.act_sub_type)  act_sub_type
FROM
     (
     SELECT TRIM(a.sub_type)  act_sub_type
            ,c.Max_act_sub_type_nr
FROM Mi_cmb.vCRM_Activiteit_week  a

     LEFT OUTER JOIN (SELECT  act_sub_type_nr
                           ,TRIM(act_sub_type)  act_sub_type
                       FROM MI_CMB_UIA.A_MSTR_LU_CRM_act_sub_type
                       GROUP BY 1,2
                       ) b
        ON TRIM(b.act_sub_type)  = TRIM(a.sub_type )

     INNER JOIN (SELECT MAX(act_sub_type_nr)  Max_act_sub_type_nr
                  FROM MI_CMB_UIA.A_MSTR_LU_CRM_act_sub_type
                 ) c
        ON 1=1
     WHERE NOT TRIM(a.sub_type) IS NULL AND TRIM(a.sub_type) <> ''
       AND b.act_sub_type_nr IS NULL
     GROUP BY 1,2
     ) a;






/* Historie overnemen */
INSERT INTO MI_CMB_UIA.A_MSTR_LU_CRM_Activiteit_type
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_CRM_Activiteit_type
;




/*      WEKELIJKS eventueel nieuwe codes met een nieuw nummer wegschrijven (max hist nr + CSUMnieuwe)  */
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_Activiteit_type
SELECT  CSUM(1, a.Activiteit_type DESC) + a.Max_Activiteit_type_nr  Activiteit_type_nr
    ,TRIM(a.Activiteit_type)  Activiteit_type
FROM
     (
     SELECT   TRIM(a.Activiteit_type)  Activiteit_type
            ,c.Max_Activiteit_type_nr
FROM Mi_cmb.vCRM_Activiteit_week  a

     LEFT OUTER JOIN (SELECT  Activiteit_type_nr
                           ,TRIM(Activiteit_type)  Activiteit_type
                       FROM MI_CMB_UIA.A_MSTR_LU_CRM_Activiteit_type
                       GROUP BY 1,2
                       ) b
  -- ON  TRIM(BOTH FROM (COALESCE(b.Activiteit_type, '')) )  = TRIM(BOTH FROM (COALESCE(a.Activiteit_type, '')) )
   ON  TRIM(b.Activiteit_type )  = TRIM(a.Activiteit_type)

     INNER JOIN (SELECT COALESCE(MAX(Activiteit_type_nr), 0)  Max_Activiteit_type_nr
                  FROM MI_CMB_UIA.A_MSTR_LU_CRM_Activiteit_type
                 ) c
        ON 1=1
     WHERE NOT TRIM(a.Activiteit_type) IS NULL AND TRIM(a.Activiteit_type) <> ''
       AND b.Activiteit_type_nr IS NULL
     GROUP BY 1,2
     ) a
;


  /* Data invoegen */
INSERT INTO MI_CMB_UIA.A_MSTR_CRM_Verkoopkans
SELECT
   VK.Klant_nr												AS	Klant_nr
,	VK.Maand_nr											AS	Maand_nr
,	VK.Datum_gegevens							AS	Datum_gegevens
,	VK.Business_contact_nr						AS	Business_contact_nr
,	VK.Siebel_verkoopkans_id					AS	Siebel_verkoopkans_id
,   VK.Naam_verkoopkans							 Naam_verkoopkans
,	COALESCE(ST.Selling_type_nr, -101)	AS	Selling_type_nr
,	COALESCE(SU.Status_nr, -101)			AS	Status_nr

,	VK.Deal_captain_mdw_sbt_id				AS	Deal_captain_mdw_sbt_id
,	CASE WHEN (VK.Deal_captain_mdw_sbt_id LIKE 'U@%' AND VK.Naam_deal_captain_mdw IS NULL) THEN 'BATCH'
				WHEN (VK.Deal_captain_mdw_sbt_id NOT LIKE 'U@%'  AND VK.Naam_deal_captain_mdw IS NULL)THEN 'ONBEKEND'
				ELSE VK.Naam_deal_captain_mdw END		AS	Naam_deal_captain_mdw

,	VK.Sbt_id_mdw_aangemaakt_door		AS	Sbt_id_mdw_aangemaakt_door
,	CASE WHEN (VK.Sbt_id_mdw_aangemaakt_door LIKE 'U@%' AND VK.Naam_mdw_aangemaakt_door IS NULL) THEN 'BATCH'
				WHEN (VK.Sbt_id_mdw_aangemaakt_door NOT LIKE 'U@%' AND VK.Naam_mdw_aangemaakt_door IS NULL)THEN 'ONBEKEND'
				ELSE VK.Naam_mdw_aangemaakt_door END		AS	Naam_mdw_aangemaakt_door

,	VK.Sbt_id_mdw_bijgewerkt_door		AS	Sbt_id_mdw_bijgewerkt_door
,	CASE WHEN (VK.Sbt_id_mdw_bijgewerkt_door LIKE 'U@%' AND VK.Naam_mdw_bijgewerkt_door IS NULL) THEN 'BATCH'
				WHEN (VK.Sbt_id_mdw_bijgewerkt_door NOT LIKE 'U@%' AND VK.Naam_mdw_bijgewerkt_door IS NULL)THEN 'ONBEKEND'
				ELSE VK.Naam_mdw_bijgewerkt_door END		AS	Naam_mdw_bijgewerkt_door

,	ZEROIFNULL(VK.Vertrouwelijk_ind)	 AS	Vertrouwelijk_ind
,	ZEROIFNULL(VK.Aantal_producten)		AS	Aantal_producten
,	ZEROIFNULL(VK.Aantal_succesvol)		AS	Aantal_succesvol
,	ZEROIFNULL(VK.Aantal_niet_succesvol)	AS	Aantal_niet_succesvol
,	ZEROIFNULL(VK.Aantal_in_behandeling)	AS	Aantal_in_behandeling
,	ZEROIFNULL(VK.Aantal_nieuw)					AS	Aantal_nieuw
,	VK.Datum_aangemaakt									AS	Datum_aangemaakt
,  ((EXTRACT(YEAR FROM VK.Datum_aangemaakt)*100)+(EXTRACT (MONTH FROM VK.Datum_aangemaakt)))  Maand_aangemaakt
,	VK.Datum_start									   AS	Datum_start
,	VK.Datum_afgehandeld						AS	Datum_afgehandeld
,	VK.Lead_uuid									   AS	Lead_uuid
,	VK.Country_primary								 AS	Country_primary
,	COALESCE(VK.Siebel_verkoopkans_deal_id ,-101)	AS	Siebel_verkoopkans_deal_id
,	VK.Client_level										AS	Client_level

 FROM MI_CMB.vCRM_verkoopkans_week  VK

 LEFT OUTER JOIN MI_CMB_UIA.A_MSTR_LU_CRM_Selling_type ST
 ON ST.Maand_nr = VK.Maand_nr AND ST.selling_type = COALESCE(VK.selling_type,-101)

 LEFT OUTER JOIN MI_CMB_UIA.A_MSTR_LU_CRM_status_verk SU
 ON SU.Maand_nr = VK.Maand_nr AND TRIM(BOTH FROM SU.status) = TRIM(BOTH FROM VK.status);



/* DUMMY regel*/
INSERT INTO MI_CMB_UIA.A_MSTR_CRM_Verkoopkans
SEL
-101  Klant_nr
,Maand_nr	  Maand_nr
,Datum_gegevens  Datum_gegevens
,-101  Business_contact_nr
,-101  Siebel_verkoopkans_id
,NULL  Naam_verkoopkans
,-101  Selling_type_nr
,-101  Status_nr
,-101  Deal_captain_mdw_sbt_id
,NULL  Naam_deal_captain_mdw
,-101  Sbt_id_mdw_aangemaakt_door
,NULL  Naam_mdw_aangemaakt_door
,-101  Sbt_id_mdw_bijgewerkt_door
,NULL  Naam_mdw_bijgewerkt_door
,0  Vertrouwelijk_ind
,0  Aantal_producten
,0  Aantal_succesvol
,0  Aantal_niet_succesvol
,0  Aantal_in_behandeling
,0  Aantal_nieuw
,NULL  Datum_aangemaakt
,NULL  Maand_aangemaakt
,NULL  Datum_start
,NULL  Datum_afgehandeld
,NULL  Lead_uuid
,NULL  Country_primary
,-101  Siebel_verkoopkans_deal_id
,NULL  Client_level
 FROM MI_CMB.vCRM_Verkoopkans_week  VK
 GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28;


INSERT INTO MI_CMB_UIA.A_MSTR_CRM_Verkoopkans_prd
SELECT
VP.	Klant_nr                      	 	Klant_nr
,VP.	Client_level                  	 	Client_level

 FROM MI_CMB.vCRM_verkoopkans_product_week   VP

 LEFT OUTER JOIN MI_CMB_UIA.A_MSTR_LU_CRM_stat_prod ST
   ON ST.Maand_nr = VP.Maand_nr AND ST.Status_product = COALESCE(VP.Status,-101)

  LEFT OUTER JOIN MI_CMB_UIA.A_MSTR_LU_CRM_substat_prod  SP
   ON SP.Maand_nr = VP.Maand_nr   AND TRIM(BOTH FROM SP.substatus_product) = TRIM(BOTH FROM VP.Substatus)

  LEFT OUTER JOIN MI_CMB_UIA.A_MSTR_LU_CRM_Product PN
   ON PN.Maand_nr = VP.Maand_nr   AND TRIM(BOTH FROM PN.product_naam) = TRIM(BOTH FROM VP.productnaam)

 LEFT OUTER JOIN MI_CMB_UIA.A_MSTR_LU_CRM_Productgroep  PG
   ON PG.Maand_nr = VP.Maand_nr   AND TRIM(BOTH FROM PG.product_groep) = TRIM(BOTH FROM VP.productgroep)

 LEFT JOIN  (
		  SELECT XA.Siebel_verkoopkans_product_id
			  	,CASE
				WHEN ((EXTRACT(YEAR FROM XA.	Start_baten)*100)+(EXTRACT (MONTH FROM XA.	Start_baten))) LT 201401 THEN 201401
				WHEN ((EXTRACT(YEAR FROM XA.	Start_baten)*100)+(EXTRACT (MONTH FROM XA.	Start_baten))) GT 203012 THEN 203012
				WHEN ((EXTRACT(YEAR FROM XA.	Start_baten)*100)+(EXTRACT (MONTH FROM XA.	Start_baten))) IS NULL THEN 203012
				ELSE ((EXTRACT(YEAR FROM XA.	Start_baten)*100)+(EXTRACT (MONTH FROM XA.	Start_baten))) END  Mnd_start_baten
				,XB.N_maanden_terug
			FROM    MI_CMB.vCRM_verkoopkans_product_week XA
			LEFT JOIN MI_CMB_UIA.A_MSTR_LU_periode  XB
 			 ON XB.Maand_nr = Mnd_start_baten
  			GROUP BY 1,2,3
	   )  per
 ON per.Siebel_verkoopkans_product_id = VP.Siebel_verkoopkans_product_id;


INSERT INTO MI_CMB_UIA.A_MSTR_CRM_Verkoopkans_prd
SELECT
-101  Klant_nr
,Maand_nr  Maand_nr
,Datum_gegevens  Datum_gegevens
,-101  Business_contact_nr
,-101  Siebel_verkoopkans_product_id
,-101  Siebel_verkoopkans_id
,-101  Product_naam_nr
,-101  Product_groep_nr
,-101  Pnc_contract_nummer
,NULL  Aantal
,NULL  Omzet
,NULL  Baten_eenmalig
,NULL  Baten_terugkerend
,NULL  Baten_totaal_1ste_12mnd
,-101  Status_product_nr
,-101  Substatus_product_nr
,NULL  Reden
,NULL  Slagingskans
,'Onbekend'   Slagingskans_cat
,NULL asStart_baten
,NULL  Maand_start_baten
,1  Maand_start_baten_1
,0  Maand_start_Nmnd_terug
,NULL asEind_baten
,NULL  Maand_eind_baten
,NULL asLooptijd_mnd
,0 Vertrouwelijk_ind
,-101  Sbt_id_mdw_eigenaar
,NULL  Naam_mdw_eigenaar
,NULL asSbt_id_mdw_aangemaakt_door
,NULL  Naam_mdw_aangemaakt_door
,NULL  Datum_aangemaakt
,NULL  Maand_aangemaakt
,NULL  Datum_laatst_gewijzigd
,NULL   Maand_laatst_gewijzigd
,NULL   Datum_nieuw
,NULL   Maand_nieuw
,NULL   Datum_in_behandeling
,NULL   Maand_in_behandeling
,NULL   Datum_gesl_succesvol
,NULL   Maand_gesl_succesvol
,NULL   Datum_gesl_niet_succesvol
,NULL   Maand_gesl_niet_succesvol
,NULL   Client_level

FROM MI_CMB.vCRM_verkoopkans_product_week  VP

GROUP BY  1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43;

INSERT INTO MI_CMB_UIA.A_MSTR_CRM_Activiteit
SELECT
Klant_nr ,
A.Maand_nr ,
A.Datum_gegevens,
A.Business_contact_nr	,
COALESCE(S.Act_status_nr, -101)	,
COALESCE(C.Activiteit_type_nr, -101)	,
COALESCE(ST.Act_sub_type_nr, -101)	,
COALESCE(PG.Product_groep_nr, -101)	,
A.Onderwerp	,
A.korte_omschrijving ,
COALESCE(CO.Contact_methode_nr, -101)	,
A.Vertrouwelijk_ind	,
A.Datum_start	,
A.Maand_nr_start	,
A.Datum_verval	,
A.Maand_nr_verval	,
A.Datum_eind	,
A.Maand_nr_eind	,
A.Siebel_verkoopkans_id	,
COALESCE(A.Sbt_id_mdw_eigenaar,-101)	,
A.Naam_mdw_eigenaar	,
COALESCE(A.Gespreksrapport_id, -101)	,
A.Datum_aangemaakt	,
A.Maand_nr_aangemaakt	,
A.Aantal_contactpersonen	,
A.Aantal_medewerkers	,
0		AS	Aantal_medewerkers_GM,
Siebel_activiteit_id	,
A.Client_level
 FROM Mi_cmb.vCRM_Activiteit_week  A
 LEFT OUTER JOIN MI_CMB_UIA.A_MSTR_LU_CRM_Activiteit_type C
 ON C.Activiteit_type = COALESCE(A.Activiteit_type, -101)
 LEFT OUTER JOIN MI_CMB_UIA.A_MSTR_LU_CRM_contact_methode CO
 ON TRIM(BOTH FROM CO.contact_methode) = TRIM(BOTH FROM A.contact_methode)
 LEFT OUTER JOIN MI_CMB_UIA.A_MSTR_LU_CRM_Productgroep PG
 ON PG.Maand_nr = A.Maand_nr
 AND TRIM(BOTH FROM PG.product_groep) = TRIM(BOTH FROM A.product_groep)
 LEFT OUTER JOIN MI_CMB_UIA.A_MSTR_LU_CRM_act_sub_type ST
 ON TRIM(BOTH FROM ST.act_sub_type) = TRIM(BOTH FROM A.sub_type)
 LEFT OUTER JOIN MI_CMB_UIA.A_MSTR_LU_CRM_act_status 	S
 ON TRIM(BOTH FROM S.act_Status) = TRIM(BOTH FROM A.Status)
 WHERE A.Maand_nr = (SELECT max(maand_nr) FROM MI_SAS_AA_MB_C_MB.Siebel_Activiteit );



INSERT INTO MI_CMB_UIA.A_MSTR_CRM_Activiteit
SELECT DISTINCT
		-101																AS	Klant_nr
,		A.Maand_nr																AS	Maand_nr
,		A.Datum_gegevens													AS	Datum_gegevens
,		-101											AS	Business_contact_nr
, 		-101										 Status
, 		-101										 Activiteit_type
, 		-101										 Sub_type
, 		-101										 Product_groep
, 		NULL										 Onderwerp
, 		NULL										 Korte_omschrijving
, 		-101										 Contact_methode
, 		0										 Vertrouwelijk
,	NULL		Datum_start
,	NULL		Maand_nr_start
,	NULL		Datum_verval
,	NULL		Maand_nr_verval
,	NULL		Datum_eind
,	NULL		Maand_nr_eind
,	-101		Siebel_verkoopkans_id
,	-101		Sbt_id_mdw_eigenaar
,	NULL		Naam_mdw_eigenaar
,	-101		Gespreksrapport_id
,	NULL		Datum_aangemaakt
,	NULL		Maand_nr_aangemaakt
,	0		Aantal_contactpersonen
,	0		Aantal_medewerkers
,	0		Aantal_GM
,	-101		Siebel_activiteit_id
,	NULL		Client_level


 FROM MI_SAS_AA_MB_C_MB.Siebel_Activiteit A;



INSERT INTO MI_CMB_UIA.A_MSTR_LU_CRM_actdeelnemer
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_CRM_actdeelnemer
;


COLLECT STATISTICS MI_CMB_UIA.A_MSTR_LU_CRM_actdeelnemer COLUMN (PARTITION);



/* WEEKCIJFERS VERWIJDEREN INDIEN MAAND REEDS AANWEZIG VAN VORIGE WEEK */
DELETE FROM MI_CMB_UIA.A_MSTR_LU_CRM_actdeelnemer
WHERE Maand_nr = (SELECT Maand_nr FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr WHERE N_maanden_terug = 0)
;



/*      WEKELIJKS bestaande codes die in deze maand aanwezig zijn overnemen */
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_actdeelnemer
SELECT a.maand_nr
		,b.Type_deelnemer_nr
		,TRIM(b.Type_deelnemer_oms)  Type_deelnemer_oms

FROM MI_CMB.vCRM_Activiteit_Participants_week a

INNER JOIN MI_CMB_UIA.A_MSTR_LU_CRM_actdeelnemer  b
   ON  TRIM(b.Type_deelnemer_oms)  = TRIM(a.Type_deelnemer)
WHERE NOT TRIM(a.Type_deelnemer) IS NULL AND TRIM(a.type_deelnemer) <> ''
GROUP BY 1,2,3;

/*      WEKELIJKS eventueel nieuwe codes met een nieuw nummer wegschrijven (max hist nr + CSUMnieuwe)  */
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_actdeelnemer
SELECT  a.Maand_nr
    ,CSUM(1, a.Type_deelnemer DESC) + a.Max_Type_deelnemer_nr  Type_deelnemer_nr
    ,TRIM(a.Type_deelnemer)  Type_deelnemer_oms
FROM
     (
     SELECT     a.Maand_nr
            ,TRIM(a.Type_deelnemer)  type_deelnemer
            ,c.Max_Type_deelnemer_nr
		FROM MI_CMB.vCRM_Activiteit_Participants_week a

     LEFT OUTER JOIN (SELECT  Type_deelnemer_nr
                           ,Type_deelnemer_oms
                       FROM MI_CMB_UIA.A_MSTR_LU_CRM_actdeelnemer
                       GROUP BY 1,2
                       ) b
        ON TRIM(b.Type_deelnemer_oms)  = TRIM(a.Type_deelnemer)

     INNER JOIN (SELECT MAX(Type_deelnemer_nr)  Max_Type_deelnemer_nr
                  FROM MI_CMB_UIA.A_MSTR_LU_CRM_actdeelnemer
                 ) c
        ON 1=1
     WHERE NOT TRIM(a.Type_deelnemer) IS NULL AND TRIM(a.type_deelnemer) <> ''
       AND b.Type_deelnemer_nr IS NULL
     GROUP BY 1,2,3
     ) a;

    -- Dummy regel voor NULL waardes
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_actdeelnemer
SELECT     a.Maand_nr
       ,-101
       ,'Onbekend'
FROM MI_CMB.vCRM_Activiteit_Participants_week a
GROUP BY 1;


INSERT INTO MI_CMB_UIA.A_MSTR_LU_CRM_Functie
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_CRM_Functie;



DELETE FROM MI_CMB_UIA.A_MSTR_LU_CRM_Functie
WHERE Maand_nr = (SELECT Maand_nr FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr WHERE N_maanden_terug = 0)
;



/*      WEKELIJKS bestaande codes die in deze maand aanwezig zijn overnemen */
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_Functie
SELECT  b.Maand_nr
    ,a.Functie_nr
    ,TRIM(a.Functie)  Functie
FROM MI_CMB_UIA.A_MSTR_LU_CRM_Functie a

INNER JOIN
(
    SELECT DISTINCT maand_nr  maand_nr, TRIM(Functie)  Functie FROM MI_CMB.VCRM_Employee_week
    join  MI_CMB.VCRM_Verkoopteam_Member_week
    on 1=1
    WHERE TRIM(Functie) IS NOT NULL AND TRIM(Functie) <> '' AND LOWER(TRIM(Functie)) <> 'onbekend'

)  B
   ON  TRIM(BOTH FROM (COALESCE(b.Functie, '')) )  = TRIM(BOTH FROM (COALESCE(a.Functie, '')) )
   AND NOT TRIM(b.Functie) IS NULL AND NOT TRIM(a.Functie) IS NULL
WHERE NOT TRIM(a.Functie) IS NULL
GROUP BY 1,2,3;

/*      WEKELIJKS eventueel nieuwe codes met een nieuw nummer wegschrijven (max hist nr + CSUMnieuwe)  */
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_Functie
SELECT  a.Maand_nr
    ,CSUM(1, a.Functie DESC) + a.Max_Functie_nr  Functie_nr
    ,TRIM(a.Functie)  Functie
FROM
     (
     SELECT     a.Maand_nr
            ,TRIM(a.Functie)  Functie
            ,c.Max_Functie_nr
     FROM
     (
    SELECT DISTINCT maand_nr  maand_nr, TRIM(Functie)  Functie
    FROM MI_CMB.VCRM_Employee_week

    join ROM MI_CMB.VCRM_Verkoopteam_Member_week
    on 1=1
    WHERE TRIM(Functie) IS NOT NULL AND TRIM(Functie) <> ''  AND LOWER(TRIM(Functie)) <> 'onbekend'

GROUP BY 1,2
	)  A
LEFT OUTER JOIN (SELECT  Functie_nr
                        							   ,TRIM(Functie)  Functie
                      						 FROM MI_CMB_UIA.A_MSTR_LU_CRM_Functie
                      						 GROUP BY 1,2
                     						  ) b
    ON TRIM(BOTH FROM (COALESCE(b.Functie, '')) )  = TRIM(BOTH FROM (COALESCE(a.Functie, '')) )
    AND NOT TRIM(b.Functie) IS NULL AND NOT TRIM(a.Functie) IS NULL AND TRIM(a.functie) <> ''
    INNER JOIN (SELECT MAX(Functie_nr)  Max_Functie_nr
                  FROM MI_CMB_UIA.A_MSTR_LU_CRM_Functie
                 ) c
        ON 1=1
     WHERE NOT TRIM(a.Functie) IS NULL AND TRIM(a.functie) <> ''
       AND b.Functie_nr IS NULL
     GROUP BY 1,2,3
     ) a;

    -- Dummy regel voor NULL waardes
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_Functie
SELECT     a.Maand_nr
		       ,-101  Functie_nr
		       ,'Onbekend'
FROM MI_CMB.VCRM_Employee_week a
GROUP BY 1;


INSERT INTO MI_CMB_UIA.A_MSTR_LU_CRM_Rol
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_CRM_Rol
;

DELETE FROM MI_CMB_UIA.A_MSTR_LU_CRM_Rol
WHERE Maand_nr = (SELECT Maand_nr FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr WHERE N_maanden_terug = 0);


INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_Rol
SELECT b.maand_nr
		,a.Rol_nr
		,TRIM(a.Rol)  Rol

FROM MI_CMB_UIA.A_MSTR_LU_CRM_Rol a

INNER JOIN
(
   SELECT DISTINCT maand_nr  maand_nr, TRIM(Sbl_cst_deelnemer_rol)  rol FROM MI_CMB.vCRM_CST_Member_week  -- nieuwe tabel zelfde naam?
    WHERE TRIM(Sbl_cst_deelnemer_rol) IS NOT NULL AND TRIM(Sbl_cst_deelnemer_rol) <> '' AND LOWER(TRIM(Sbl_cst_deelnemer_rol)) <> 'onbekend'
)  B
   ON  TRIM(b.Rol)  = TRIM(a.Rol)
WHERE NOT TRIM(a.Rol) IS NULL
GROUP BY 1,2,3;



/*      WEKELIJKS eventueel nieuwe codes met een nieuw nummer wegschrijven (max hist nr + CSUMnieuwe)  */
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_Rol
SELECT  a.Maand_nr
    ,CSUM(1, a.Rol DESC) + a.Max_Rol_nr  Rol_nr
    ,TRIM(a.Rol)  Rol
FROM
     (
     SELECT     a.Maand_nr
            ,TRIM(a.Rol)  Rol
            ,c.Max_Rol_nr
     FROM
     (
	    SELECT DISTINCT maand_nr  maand_nr, TRIM(Sbl_cst_deelnemer_rol)  Rol FROM MI_CMB.VCRM_CST_Member_week
	    WHERE TRIM(Sbl_cst_deelnemer_rol) IS NOT NULL AND TRIM(Sbl_cst_deelnemer_rol) <> '' AND LOWER(TRIM(Sbl_cst_deelnemer_rol)) <> 'onbekend'
		GROUP BY 1,2
		)  A
LEFT OUTER JOIN (SELECT  Rol_nr
                           ,TRIM(Rol)  Rol
                       FROM MI_CMB_UIA.A_MSTR_LU_CRM_Rol
                       GROUP BY 1,2
                       ) b
        ON TRIM(b.Rol)  = TRIM(a.Rol)
        AND NOT TRIM(b.Rol) IS NULL AND NOT TRIM(a.Rol) IS NULL AND TRIM(a.Rol) <> ''
     INNER JOIN (SELECT MAX(Rol_nr)  Max_Rol_nr
                  FROM MI_CMB_UIA.A_MSTR_LU_CRM_Rol
                 ) c
        ON 1=1
     WHERE NOT TRIM(a.Rol) IS NULL AND TRIM(a.Rol) <> ''
       AND b.Rol_nr IS NULL
     GROUP BY 1,2,3
     ) a;



    -- Dummy regel voor NULL waardes
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_Rol
SELECT a.Maand_nr
       ,-101
       ,'Onbekend'
FROM MI_CMB.vCRM_CST_Member_week a
GROUP BY 1;


INSERT INTO MI_CMB_UIA.A_MSTR_LU_CRM_Functie_Part
SELECT DISTINCT Functie_Part_nr, Functie_Part FROM MI_CMB_UIA.A_MSTR_LU_CRM_Functie_Part
;



INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_Functie_Part
SELECT  CSUM(1, a.Functie_Part DESC) + a.Max_Functie_Part_nr  Functie_Part_nr
    ,TRIM(a.Functie_Part)  Functie_Part
FROM
     (
     SELECT   TRIM(a.Functie_Part)  Functie_Part
            ,c.Max_Functie_Part_nr
     FROM
     (
	    SELECT TRIM(Functie)  Functie_Part   FROM MI_CMB.vCRM_Activiteit_Participants_week
	    WHERE TRIM(Functie) IS NOT NULL AND TRIM(Functie) <> '' AND LOWER(TRIM(Functie)) <> 'onbekend'
		GROUP BY 1
		)  A
LEFT OUTER JOIN (SELECT  Functie_Part_nr
                           ,TRIM(Functie_Part)  Functie_Part
                       FROM MI_CMB_UIA.A_MSTR_LU_CRM_Functie_Part
                       GROUP BY 1,2
                       )  b
        ON TRIM(b.Functie_Part)  = TRIM(a.Functie_Part)
        AND NOT TRIM(b.Functie_Part) IS NULL AND NOT TRIM(a.Functie_Part) IS NULL AND TRIM(a.Functie_Part) <> ''
     INNER JOIN (SELECT MAX(Functie_Part_nr)  Max_Functie_Part_nr
                  FROM MI_CMB_UIA.A_MSTR_LU_CRM_Functie_Part
                 ) c
        ON 1=1
     WHERE NOT TRIM(a.Functie_Part) IS NULL AND TRIM(a.Functie_Part) <> ''
       AND b.Functie_Part_nr IS NULL
     GROUP BY 1,2
     )  a;


INSERT INTO MI_CMB_UIA.A_MSTR_CRM_Act_Participant
SELECT
	AP.Siebel_activiteit_id				AS	Siebel_activiteit_id
,	AP.Maand_nr							AS	Maand_nr
,	AP.Datum_gegevens				AS	Datum_gegevens
,	COALESCE (DLNR.Type_deelnemer_nr, -101)		AS	Type_deelnemer_nr
,	CASE WHEN TRIM(AP.Naam)	IS NULL OR TRIM(AP.Naam) = '' THEN 'Onbekend' ELSE AP.Naam END	AS	Naam
,   COALESCE(FNCTP.Functie_Part_nr, -101) AS	Functie_Part_nr
,	COALESCE(AP.SBT_ID,-101)		AS	SBT_ID
,	COALESCE(AP.Siebel_Contactpersoon_id,-101)					AS	Siebel_Contactpersoon_id

FROM  Mi_cmb.vCRM_Activiteit_participants_week  AP

LEFT JOIN  MI_CMB_UIA.A_MSTR_LU_CRM_actdeelnemer DLNR
ON TRIM(AP.Type_deelnemer)   = TRIM (DLNR.Type_deelnemer_oms)

LEFT JOIN  MI_CMB_UIA.A_MSTR_LU_CRM_Functie_Part FNCTP
ON TRIM(AP.functie) = TRIM(FNCTP.functie_part) /*AND AP.maand_nr = FNCTP.Maand_nr*/

INNER JOIN MI_CMB_UIA.A_MSTR_CRM_Activiteit ACT
ON TRIM(AP.Siebel_activiteit_id) = TRIM(ACT.Siebel_activiteit_id) AND AP.maand_nr = ACT.Maand_nr
;

INSERT INTO MI_CMB_UIA.A_MSTR_CRM_Act_Participant
SELECT
	-101				AS	Siebel_activiteit_id
,	AP.Maand_nr							AS	Maand_nr
,	AP.Datum_gegevens				AS	Datum_gegevens
,	-101		AS	Type_deelnemer
,	'Onbekend'									AS	Naam
,	-101								AS	Functie_Part_nr
,	-101								AS	SBT_ID
,	-101					AS	Siebel_Contactpersoon_id
FROM MI_CMB.vCRM_Activiteit_participants_week  AP
GROUP BY 1,2,3,4,5,6,7,8;


INSERT INTO  MI_CMB_UIA.A_MSTR_CRM_Act_Participant_key
SELECT distinct a.siebel_activiteit_id, COALESCE(b.sbt_id, '-101')  sbt_id,
a.siebel_activiteit_id || COALESCE(b.sbt_id, '-101')  Key_SBT_act
FROM MI_CMB_UIA.A_MSTR_CRM_Activiteit a
LEFT JOIN MI_CMB_UIA.A_MSTR_CRM_Act_Participant b
ON a.siebel_activiteit_id = b.siebel_activiteit_id
AND b.type_deelnemer_nr = 1;



INSERT INTO MI_CMB_UIA.A_MSTR_LU_CRM_AM_Specialism
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_CRM_AM_Specialism
;

INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_AM_Specialism
SELECT CSUM(1, a.AM_Specialism DESC) + a.Max_AM_Specialism_nr  AM_Specialism_nr
    ,TRIM(a.AM_Specialism)  AM_Specialism
FROM
     (
     SELECT TRIM(a.AM_Specialism)  AM_Specialism
            ,c.Max_AM_Specialism_nr
     FROM
     (
	    SELECT TRIM(Account_Management_Specialism)  AM_Specialism FROM Mi_cmb.vCRM_Employee_week
	    WHERE TRIM(Account_Management_Specialism) IS NOT NULL AND TRIM(Account_Management_Specialism) <> ''
		GROUP BY 1
		)  A
		LEFT OUTER JOIN (SELECT  AM_Specialism_nr
		                          					 ,TRIM(AM_Specialism)  AM_Specialism
		                     						  FROM MI_CMB_UIA.A_MSTR_LU_CRM_AM_Specialism
		                      						 GROUP BY 1,2
		                       )  B
		        ON TRIM(b.AM_Specialism)  = TRIM(a.AM_Specialism)
		        AND NOT TRIM(b.AM_Specialism) IS NULL AND NOT TRIM(a.AM_Specialism) IS NULL AND TRIM(a.AM_Specialism) <> ''
     INNER JOIN (SELECT MAX(AM_Specialism_nr)  Max_AM_Specialism_nr
                  FROM MI_CMB_UIA.A_MSTR_LU_CRM_AM_Specialism
                 ) c
        ON 1=1
     WHERE NOT TRIM(a.AM_Specialism) IS NULL AND TRIM(a.AM_Specialism) <> ''
       AND b.AM_Specialism_nr IS NULL
     GROUP BY 1,2
     )  a;


INSERT INTO MI_CMB_UIA.A_MSTR_LU_CRM_AM_segment
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_CRM_AM_segment;


INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_AM_segment
SELECT CSUM(1, a.AM_segment DESC) + a.Max_AM_segment_nr   AM_segment_nr
    ,TRIM(a.AM_segment)  AM_segment
FROM
     (
     SELECT TRIM(a.AM_segment)  AM_segment
            ,c.Max_AM_segment_nr
     FROM
     (
	    SELECT TRIM(Account_Management_segment)  AM_segment FROM Mi_cmb.vCRM_Employee_week
	    WHERE TRIM(Account_Management_segment) IS NOT NULL AND TRIM(Account_Management_segment) <> ''
		GROUP BY 1
		)  A
		LEFT OUTER JOIN (SELECT  AM_segment_nr
		                          					 ,TRIM(AM_segment)  AM_segment
		                     						  FROM MI_CMB_UIA.A_MSTR_LU_CRM_AM_segment
		                      						 GROUP BY 1,2
		                       )  B
		        ON TRIM(b.AM_segment)  = TRIM(a.AM_segment)
		        AND NOT TRIM(b.AM_segment) IS NULL AND NOT TRIM(a.AM_segment) IS NULL AND TRIM(a.AM_segment) <> ''
     INNER JOIN (SELECT MAX(AM_segment_nr)  Max_AM_segment_nr
                  FROM MI_CMB_UIA.A_MSTR_LU_CRM_AM_segment
                 ) c
        ON 1=1
     WHERE NOT TRIM(a.AM_segment) IS NULL AND TRIM(a.AM_segment) <> ''
       AND b.AM_segment_nr IS NULL
     GROUP BY 1,2
     )  a;


INSERT INTO MI_CMB_UIA.A_MSTR_LU_CRM_CP_functietitel
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_CRM_CP_functietitel
;



INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_CP_functietitel
SELECT CSUM(1, a.functietitel_CP DESC) + a.Max_functietitel_nr   functietitel_CP_nr
    ,TRIM(a.functietitel_CP)  functietitel_CP
FROM
     (
     SELECT TRIM(a.functietitel_CP)  functietitel_CP
            ,c.Max_functietitel_nr
     FROM
     (
	    SELECT TRIM(contactpersoon_functietitel)  functietitel_CP FROM Mi_cmb.vCRM_Contactpersoon_week
	    WHERE TRIM(contactpersoon_functietitel) IS NOT NULL AND TRIM(contactpersoon_functietitel) <> ''
		GROUP BY 1
		)  A
		LEFT OUTER JOIN (SELECT  functietitel_CP_nr
		                          					 ,TRIM(functietitel_CP)  functietitel_CP
		                     						  FROM MI_CMB_UIA.A_MSTR_LU_CRM_CP_functietitel
		                      						 GROUP BY 1,2
		                       )  B
		        ON TRIM(b.functietitel_CP)  = TRIM(a.functietitel_CP)
		        AND NOT TRIM(b.functietitel_CP) IS NULL AND NOT TRIM(a.functietitel_CP) IS NULL AND TRIM(a.functietitel_CP) <> ''
     INNER JOIN (SELECT MAX(functietitel_CP_nr)  Max_functietitel_nr
                  FROM MI_CMB_UIA.A_MSTR_LU_CRM_CP_functietitel
                 ) c
        ON 1=1
     WHERE NOT TRIM(a.functietitel_CP) IS NULL AND TRIM(a.functietitel_CP) <> ''
       AND b.functietitel_CP_nr IS NULL
     GROUP BY 1,2
     )  a;

INSERT INTO MI_CMB_UIA.A_MSTR_CRM_Employee
SELECT
	E.Maand_nr					AS	Maand_nr
,	E.Datum_gegevens		AS	Datum_gegevens
,	TRIM(E.SBT_ID)						AS	SBT_ID
,	CASE WHEN TRIM(E.Naam)	IS NULL OR TRIM(E.Naam) = '' THEN 'Onbekend' ELSE E.Naam END AS	Naam
,	COALESCE(E.Soort_mdw,-101)			AS	Soort_mdw
,	COALESCE(FNCT.Functie_nr,-101)			AS	Functie_nr
,	COALESCE(TRIM(E.BO_nr_mdw), -101)		AS	BO_nr_mdw
,   COALESCE(E.CCA,-101)					  AS	CCA
,  	COALESCE(E.GM_ind, 0)			 GM_ind
,   COALESCE(SP.AM_Specialism_nr, 3)			AS	AM_Specialism_nr
,   COALESCE(SEG.AM_Segment_nr,1)			AS	AM_Segment_nr

FROM Mi_cmb.vCRM_Employee_week  E

LEFT JOIN MI_CMB_UIA.A_MSTR_LU_CRM_Functie FNCT
ON TRIM(E.Functie) = TRIM(FNCT.Functie) AND E.maand_nr = FNCT.maand_nr

LEFT JOIN MI_CMB_UIA.A_MSTR_LU_CRM_AM_Specialism SP
ON TRIM(E.Account_Management_Specialism) = TRIM(SP.AM_Specialism)

LEFT JOIN MI_CMB_UIA.A_MSTR_LU_CRM_AM_segment SEG
ON TRIM(E.Account_Management_segment) = TRIM(SEG.AM_segment)

WHERE E.maand_nr >= 201701
;



INSERT INTO MI_CMB_UIA.A_MSTR_CRM_Employee
SELECT
Maand_nr		Maand_nr	,
Datum_gegevens		Datum_gegevens	,
-101		SBT_ID	,
'Onbekend'    		Naam	,
'Onbekend'    		Soort_mdw	,
-101		Functie	,
-101		BO_nr_mdw	,
-101		CCA	,
0		     GM_ind	,
-101		Account_Management_Specialism_NR	,
-101		Account_Management_Segment_NR
FROM Mi_cmb.vCRM_Employee_week  E
WHERE E.maand_nr >= 201701
GROUP BY 1,2,3,4,5,6,7,8,9,10,11;




UPDATE MI_CMB_UIA.A_MSTR_CRM_Activiteit
FROM
(
				SELECT
					XA.siebel_activiteit_id,
                	SUM(XB.GM_ind)  Aantal_Medewerkers_GM

				FROM  MI_CMB_UIA.A_MSTR_CRM_Act_Participant XA
                INNER JOIN MI_CMB_UIA.A_MSTR_CRM_Employee XB
				ON  XA.SBT_ID = XB.SBT_ID  AND XB.GM_ind = 1 AND XA.Type_Deelnemer_nr = 1
				GROUP BY 1
	) a
SET
Aantal_Medewerkers_GM = A.Aantal_Medewerkers_GM
WHERE MI_CMB_UIA.A_MSTR_CRM_Activiteit .siebel_activiteit_id = A.siebel_activiteit_id ;





/*      WEKELIJKS alle data overnemen */
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_BO_mdw
SELECT maand_nr
		,BO_nr_mdw
		,COALESCE(BO_naam_mdw, 'ONBEKEND')  BO_naam_mdw
FROM MI_CMB.vCRM_Employee_week
WHERE BO_nr_mdw IS NOT NULL
GROUP BY 1,2,3;



    /* Dummy regel voor NULL waardes  */
INSERT INTO MI_CMB_UIA.A_MSTR_LU_BO_mdw
SELECT        Maand_nr
		       ,-101            BO_nr_mdw
		       ,'ONBEKEND'    BO_naam_mdw
FROM  MI_CMB.vCRM_Employee_week
GROUP BY 1,2,3;



COLLECT STATISTICS MI_CMB_UIA.A_MSTR_LU_BO_mdw COLUMN (PARTITION);
COLLECT STATISTICS MI_CMB_UIA.A_MSTR_LU_BO_mdw COLUMN (BO_nr_mdw);
COLLECT STATISTICS MI_CMB_UIA.A_MSTR_LU_BO_mdw COLUMN (Maand_nr, BO_nr_mdw);


/* Historie overnemen */
INSERT INTO MI_CMB_UIA.A_MSTR_LU_CRM_Rol_CP
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_CRM_Rol_CP
;


COLLECT STATISTICS MI_CMB_UIA.A_MSTR_LU_CRM_Rol_CP COLUMN (PARTITION);



/* WEEKCIJFERS VERWIJDEREN INDIEN MAAND REEDS AANWEZIG VAN VORIGE WEEK */
DELETE FROM MI_CMB_UIA.A_MSTR_LU_CRM_Rol_CP
WHERE Maand_nr = (SELECT Maand_nr FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr WHERE N_maanden_terug = 0);



/*      WEKELIJKS bestaande codes die in deze maand aanwezig zijn overnemen */
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_Rol_CP
SELECT b.maand_nr
		,a.Rol_CP_nr
		,TRIM(a.Rol_CP)  Rol_CP

FROM MI_CMB_UIA.A_MSTR_LU_CRM_Rol_CP a

INNER JOIN (
   SELECT maand_nr, TRIM(contactpersoon_functietitel)  Rol FROM MI_CMB.vCRM_contactpersoon_week
    WHERE TRIM(contactpersoon_functietitel) IS NOT NULL AND TRIM(contactpersoon_functietitel) <> ''
	GROUP BY 1,2
)  B
   ON  TRIM(b.Rol)  = TRIM(a.Rol_CP)
WHERE NOT TRIM(a.Rol_CP) IS NULL
GROUP BY 1,2,3;



/*      WEKELIJKS eventueel nieuwe codes met een nieuw nummer wegschrijven (max hist nr + CSUMnieuwe)  */
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_Rol_CP
SELECT  a.Maand_nr
    ,CSUM(1, a.Rol_CP DESC) + a.Max_Rol_nr  Rol_CP_nr
    ,TRIM(a.Rol_CP)  Rol_CP
FROM
     (
     SELECT a.Maand_nr
            ,TRIM(a.Rol_CP)  Rol_CP
            ,c.Max_Rol_nr
     FROM
     (
	    SELECT maand_nr, TRIM(contactpersoon_functietitel)  Rol_CP FROM MI_CMB.vCRM_contactpersoon_week
	    WHERE TRIM(contactpersoon_functietitel) IS NOT NULL AND TRIM(contactpersoon_functietitel) <> ''
		GROUP BY 1,2
		)  A
		LEFT OUTER JOIN (SELECT  Rol_CP_nr
		                          					 ,TRIM(Rol_CP)  Rol_CP
		                     						  FROM MI_CMB_UIA.A_MSTR_LU_CRM_Rol_CP
		                      						 GROUP BY 1,2
		                       )  B
		        ON TRIM(b.Rol_CP)  = TRIM(a.Rol_CP)
		        AND NOT TRIM(b.Rol_CP) IS NULL AND NOT TRIM(a.Rol_CP) IS NULL AND TRIM(a.Rol_CP) <> ''
     INNER JOIN (SELECT MAX(Rol_CP_nr)  Max_Rol_nr
                  FROM MI_CMB_UIA.A_MSTR_LU_CRM_Rol_CP
                 ) c
        ON 1=1
     WHERE NOT TRIM(a.Rol_CP) IS NULL AND TRIM(a.Rol_CP) <> ''
       AND b.Rol_CP_nr IS NULL
     GROUP BY 1,2,3
     )  a;



    -- Dummy regel voor NULL waardes
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_Rol_CP
SELECT a.Maand_nr
       ,-101
       ,'Onbekend'
FROM MI_CMB.vCRM_contactpersoon_week a
GROUP BY 1;



/* Historie overnemen */
INSERT INTO MI_CMB_UIA.A_MSTR_LU_CRM_CP_onderdeel
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_CRM_CP_onderdeel
;


COLLECT STATISTICS MI_CMB_UIA.A_MSTR_LU_CRM_CP_onderdeel COLUMN (PARTITION);



/*      WEKELIJKS eventueel nieuwe codes met een nieuw nummer wegschrijven (max hist nr + CSUMnieuwe)  */
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_CP_onderdeel
SELECT CSUM(1, a.onderdeel_CP DESC) +  a.Max_onderdeel_nr  onderdeel_CP_nr
    ,TRIM(a.onderdeel_CP)  onderdeel_CP
FROM
     (
     SELECT TRIM(a.onderdeel_CP)  onderdeel_CP
            ,c.Max_onderdeel_nr
     FROM
     (
	    SELECT TRIM(contactpersoon_onderdeel)  onderdeel_CP FROM Mi_cmb.vCRM_Contactpersoon_week
	    WHERE TRIM(contactpersoon_onderdeel) IS NOT NULL AND TRIM(contactpersoon_onderdeel) <> ''
		GROUP BY 1
		)  A
		LEFT OUTER JOIN (SELECT  onderdeel_CP_nr
		                          					 ,TRIM(onderdeel_CP)  onderdeel_CP
		                     						  FROM MI_CMB_UIA.A_MSTR_LU_CRM_CP_onderdeel
		                      						 GROUP BY 1,2
		                       )  B
		        ON TRIM(b.onderdeel_CP)  = TRIM(a.onderdeel_CP)
		        AND NOT TRIM(b.onderdeel_CP) IS NULL AND NOT TRIM(a.onderdeel_CP) IS NULL AND TRIM(a.onderdeel_CP) <> ''
     INNER JOIN (SELECT MAX(onderdeel_CP_nr)  Max_onderdeel_nr
                  FROM MI_CMB_UIA.A_MSTR_LU_CRM_CP_onderdeel
                 ) c
        ON 1=1
     WHERE NOT TRIM(a.onderdeel_CP) IS NULL AND TRIM(a.onderdeel_CP) <> ''
       AND b.onderdeel_CP_nr IS NULL
     GROUP BY 1,2
     )  a;




INSERT INTO MI_CMB_UIA.A_MSTR_CRM_Contactpersoon
SELECT
	siebel_contactpersoon_id
,	achternaam
,	tussenvoegsel
,	achtervoegsel
,	contactpersoon_titel
,	initialen
,	voornaam
,	postcode
,	plaats
,	telefoonnummer
,	land
,	email
,	COALESCE(email_net, -101)
,	COALESCE(email_bruikbaar,-101)
,	OND.onderdeel_cp_nr
,	FT.functietitel_cp_nr
,	COALESCE(actief_ind, -101)
,	COALESCE(niet_bellen_ind, -101)
,	COALESCE(niet_mailen_ind, -101)
,	COALESCE(geen_marktonderzoek_ind, -101)
,	COALESCE(geen_events_ind, -101)
,	COALESCE(primair_contact_persoon_ind, -101)
,	Klant_nr
,	Maand_nr
,	Datum_gegevens
,	Business_contact_nr
,	Client_level

FROM Mi_cmb.vCRM_Contactpersoon_week  a

LEFT JOIN  MI_CMB_UIA.A_MSTR_LU_CRM_CP_onderdeel OND
ON OND.onderdeel_cp = a.contactpersoon_onderdeel

LEFT JOIN MI_CMB_UIA.A_MSTR_LU_CRM_CP_functietitel FT
ON FT.functietitel_cp = a.contactpersoon_functietitel;



/*Dummy waarde */
INSERT INTO MI_CMB_UIA.A_MSTR_CRM_Contactpersoon
SELECT
-101	AS	    siebel_contactpersoon_id
,    'Onbekend'    	AS	    achternaam
,    ''	AS	    tussenvoegsel
,    ''	AS	    achtervoegsel
,    'Onbekend'    	AS	    contactpersoon_titel
,    ''	AS	    initialen
,    ''	AS	    voornaam
,    'Onbekend'    	AS	    postcode
,    'Onbekend'    	AS	    plaats
, -101	AS	    telefoonnummer
,    'Onbekend'    	AS	    land
,    'Onbekend'    	AS	    email
,-101	AS	    email_net
,-101	AS	    email_bruikbaar
,-101	AS	    cp_onderdeel_nr
,-101	AS	    cp_functietitel_nr
,-101	AS	    actief_ind
,-101	AS	    niet_bellen_ind
,-101	AS	    niet_mailen_ind
,-101	AS	    geen_marktonderzoek_ind
,-101	AS	    geen_events_ind
,-101	AS	    primair_contact_persoon_ind
,-101	AS	    Klant_nr
,    Maand_nr	AS	    Maand_nr
,    Datum_gegevens	AS	    Datum_gegevens
,-101	AS	    Business_contact_nr
,-101	AS	    client_level
FROM Mi_cmb.vCRM_Contactpersoon_week  a
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27;


 INSERT INTO MI_CMB_UIA.A_MSTR_CRM_CST_Member
 SELECT
 	CSTM.Klant_nr					AS	Klant_nr
,   CSTM.Business_contact_nr     Business_contact_nr
,    CSTM.Client_level				 Client_level
,	CSTM.Maand_nr				AS	Maand_nr
,   CSTM.Datum_gegevens	AS	Datum_gegevens
,	COALESCE (TRIM(CSTM.SBT_ID), 'Onbekend')					AS	SBT_ID
,	CASE WHEN TRIM(CSTM.Naam) IS NULL OR TRIM(CSTM.Naam) = '' THEN  'Onbekend' ELSE TRIM(CSTM.Naam)		END					AS	Naam
,	COALESCE(ROL.rol_nr, -101)    AS	Sbl_cst_deelnemer_rol_nr
,	COALESCE(TRIM(CSTM.SBL_gedelegeerde_ind), -101)		AS	SBL_gedelegeerde_ind
,	CSTM.TB_Consultant							AS	TB_Consultant
FROM Mi_cmb.vCRM_CST_member_week  CSTM

LEFT JOIN MI_CMB_UIA.A_MSTR_LU_CRM_Rol ROL
ON TRIM(CSTM.Sbl_cst_deelnemer_rol) = TRIM(ROL.Rol) AND CSTM.maand_nr = ROL.maand_nr

WHERE CSTM.klant_nr IS NOT NULL;




/* dummyvelden inzlezen*/
 INSERT INTO MI_CMB_UIA.A_MSTR_CRM_CST_Member
 SELECT
 	-101					AS	Klant_nr
, -101						 Business_contact_nr
,	NULL							AS	Client_level
,	Maand_nr				AS	Maand_nr
,	Datum_gegevens	AS	Datum_gegevens
,	-101					AS	SBT_ID
,	'Onbekend'						AS	Naam
,	-101							AS	Sbl_cst_deelnemer_rol_nr
,	0							AS	SBL_gedelegeerde_ind
,	'N'							AS	TB_Consultant
FROM MI_CMB.vCRM_CST_member_week   A
GROUP BY 1,2,3,4,5,6,7,8,9,10;





INSERT INTO MI_CMB_UIA.A_MSTR_CRM_Verkoopteam
SELECT
	  VMBR.Klant_nr
   ,   VMBR.Maand_nr
   ,   VMBR.Datum_gegevens
   ,   COALESCE (VMBR.Business_contact_nr,-101)  Business_contact_nr
   ,   VMBR.siebel_verkoopkans_id
   	,  COALESCE(VMBR.SBT_ID,-101)     SBT_ID
	,	CASE WHEN TRIM(VMBR.Naam) IS NULL OR TRIM(VMBR.Naam) = '' THEN  'Onbekend' ELSE TRIM(VMBR.Naam)		END					AS	Naam
    ,  COALESCE(VMBR.BO_nr_mdw,-101)  BO_nr
	,	COALESCE(FNCT.Functie_nr, -101)	AS	Functie_nr
    ,  VMBR.primary_ind
    ,  VMBR.Client_level

FROM Mi_cmb.vCRM_Verkoopteam_member_week  VMBR

LEFT JOIN MI_CMB_UIA.A_MSTR_LU_CRM_Functie FNCT
ON TRIM(VMBR.Functie) = TRIM(FNCT.Functie) AND VMBR.maand_nr = FNCT.maand_nr

WHERE VMBR.Klant_nr IS NOT NULL
AND VMBR.siebel_verkoopkans_id IS NOT NULL;



INSERT INTO MI_CMB_UIA.A_MSTR_CRM_Verkoopteam
SELECT
	  -101
   ,   Maand_nr
   ,   NULL  Datum_gegevens
   ,   -101  Business_contact_nr
   ,   -101  siebel_verkoopkans_id
   ,  -101    SBT_ID
   ,   'Onbekend'  Naam
    ,  -101  BO_nr
	,  -101  Functie_nr
    ,  NULL  primary_ind
    ,  NULL  Client_level
FROM Mi_cmb.vCRM_Verkoopteam_member_week
GROUP BY 1,2,3,4,5,6,7,8,9,10,11;


INSERT INTO MI_CMB_UIA.A_MSTR_CRM_verkoopkans_CP
SELECT
klant_nr	,
maand_nr	,
datum_gegevens	,
business_contact_nr	,
siebel_verkoopkans_id	,
primary_ind	,
siebel_contactpersoon_id	,
Client_level
FROM Mi_cmb.vCRM_Verkoopkans_contactpersoon_week
WHERE klant_nr IS NOT NULL AND siebel_verkoopkans_id IS NOT NULL AND siebel_contactpersoon_id IS NOT NULL;



INSERT INTO MI_CMB_UIA.A_MSTR_CRM_verkoopkans_CP
SELECT
-101		 Klant_nr,
maand_nr	,
datum_gegevens	,
-101		 business_contact_nr,
-101 		 siebel_verkoopkans_id	,
0			  primary_ind	,
-101		 siebel_contactpersoon_id	,
-101		 Client_level
FROM Mi_cmb.vCRM_Verkoopkans_contactpersoon_week ;





/* Historie overnemen */
INSERT INTO MI_CMB_UIA.A_MSTR_LU_CRM_Deal_selling_type
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_CRM_Deal_selling_type;



COLLECT STATISTICS MI_CMB_UIA.A_MSTR_LU_CRM_Deal_selling_type COLUMN (PARTITION);



/*      WEKELIJKS eventueel nieuwe codes met een nieuw nummer wegschrijven (max hist nr + CSUMnieuwe)  */
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_Deal_selling_type
SELECT CSUM(1, a.selling_type DESC) + a.Max_Deal_selling_type_nr  Deal_selling_type_nr
    ,a.selling_type
FROM
     (
     SELECT  a.selling_type
            ,c.Max_Deal_selling_type_nr
     FROM MI_SAS_AA_MB_C_MB.Siebel_Deal   a

     LEFT OUTER JOIN (SELECT  Deal_selling_type_nr
                           ,Deal_selling_type
                       FROM MI_CMB_UIA.A_MSTR_LU_CRM_Deal_selling_type
                       GROUP BY 1,2
                       ) b
        ON b.Deal_selling_type = a.selling_type

     INNER JOIN (SELECT MAX(Deal_selling_type_nr)  Max_Deal_selling_type_nr
                  FROM MI_CMB_UIA.A_MSTR_LU_CRM_Deal_selling_type
                 ) c
        ON 1=1
     WHERE b.Deal_selling_type_nr IS NULL
	 	 AND a.selling_type IS NOT NULL
     GROUP BY 1,2
     ) a;


/* Historie overnemen */
INSERT INTO MI_CMB_UIA.A_MSTR_LU_CRM_Deal_status
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_CRM_Deal_status;




/*      WEKELIJKS eventueel nieuwe codes met een nieuw nummer wegschrijven (max hist nr + CSUMnieuwe)  */
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_Deal_status
SELECT CSUM(1, a.status DESC) + a.Max_Deal_status_nr  Deal_status_nr
    ,a.status
FROM
     (
     SELECT  a.status
            ,c.Max_Deal_status_nr
     FROM MI_SAS_AA_MB_C_MB.Siebel_Deal   a

     LEFT OUTER JOIN (SELECT  Deal_status_nr
                           ,Deal_status
                       FROM MI_CMB_UIA.A_MSTR_LU_CRM_Deal_status
                       GROUP BY 1,2
                       ) b
        ON b.Deal_status = a.status

     INNER JOIN (SELECT MAX(Deal_status_nr)  Max_Deal_status_nr
                  FROM MI_CMB_UIA.A_MSTR_LU_CRM_Deal_status
                 ) c
        ON 1=1
     WHERE b.Deal_status_nr IS NULL
	 	 AND a.status IS NOT NULL
     GROUP BY 1,2
     ) a;




/* Historie overnemen */
INSERT INTO MI_CMB_UIA.A_MSTR_LU_CRM_Deal_productgroep
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_CRM_Deal_productgroep;






/*      WEKELIJKS eventueel nieuwe codes met een nieuw nummer wegschrijven (max hist nr + CSUMnieuwe)  */
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_Deal_productgroep
SELECT CSUM(1, a.productgroep DESC) + a.Max_Deal_productgroep_nr  Deal_productgroep_nr
    ,a.productgroep
FROM
     (
     SELECT  a.productgroep
            ,c.Max_Deal_productgroep_nr
     FROM MI_SAS_AA_MB_C_MB.Siebel_Deal   a

     LEFT OUTER JOIN (SELECT  Deal_productgroep_nr
                           ,Deal_productgroep
                       FROM MI_CMB_UIA.A_MSTR_LU_CRM_Deal_productgroep
                       GROUP BY 1,2
                       ) b
        ON b.Deal_productgroep = a.productgroep

     INNER JOIN (SELECT MAX(Deal_productgroep_nr)  Max_Deal_productgroep_nr
                  FROM MI_CMB_UIA.A_MSTR_LU_CRM_Deal_productgroep
                 ) c
        ON 1=1
     WHERE b.Deal_productgroep_nr IS NULL
	 	 AND a.productgroep IS NOT NULL
     GROUP BY 1,2
     ) a;



/* Historie overnemen */
INSERT INTO MI_CMB_UIA.A_MSTR_LU_CRM_Deal_herkomst
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_CRM_Deal_herkomst;




/*      WEKELIJKS eventueel nieuwe codes met een nieuw nummer wegschrijven (max hist nr + CSUMnieuwe)  */
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_Deal_herkomst
SELECT CSUM(1, a.herkomst DESC) + a.Max_Deal_herkomst_nr  Deal_herkomst_nr
    ,a.herkomst
FROM
     (
     SELECT  a.herkomst
            ,c.Max_Deal_herkomst_nr
     FROM MI_SAS_AA_MB_C_MB.Siebel_Deal   a

     LEFT OUTER JOIN (SELECT  Deal_herkomst_nr
                           ,Deal_herkomst
                       FROM MI_CMB_UIA.A_MSTR_LU_CRM_Deal_herkomst
                       GROUP BY 1,2
                       ) b
        ON b.Deal_herkomst = a.herkomst

     INNER JOIN (SELECT MAX(Deal_herkomst_nr)  Max_Deal_herkomst_nr
                  FROM MI_CMB_UIA.A_MSTR_LU_CRM_Deal_herkomst
                 ) c
        ON 1=1
     WHERE b.Deal_herkomst_nr IS NULL
	 	 AND a.herkomst IS NOT NULL
     GROUP BY 1,2
     ) a;




/* Historie overnemen */
INSERT INTO MI_CMB_UIA.A_MSTR_LU_CRM_Deal_soort
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_CRM_Deal_soort;


/*      WEKELIJKS eventueel nieuwe codes met een nieuw nummer wegschrijven (max hist nr + CSUMnieuwe)  */
INSERT INTO  MI_CMB_UIA.A_MSTR_LU_CRM_Deal_soort
SELECT CSUM(1, a.soort DESC) + a.Max_Deal_soort_nr  Deal_soort_nr
    ,a.soort
FROM
     (
     SELECT  a.soort
            ,c.Max_Deal_soort_nr
     FROM MI_SAS_AA_MB_C_MB.Siebel_Deal   a

     LEFT OUTER JOIN (SELECT  Deal_soort_nr
                           ,Deal_soort
                       FROM MI_CMB_UIA.A_MSTR_LU_CRM_Deal_soort
                       GROUP BY 1,2
                       ) b
        ON b.Deal_soort = a.soort

     INNER JOIN (SELECT MAX(Deal_soort_nr)  Max_Deal_soort_nr
                  FROM MI_CMB_UIA.A_MSTR_LU_CRM_Deal_soort
                 ) c
        ON 1=1
     WHERE b.Deal_soort_nr IS NULL
	 	 AND a.soort IS NOT NULL
     GROUP BY 1,2
     ) a;




INSERT INTO MI_CMB_UIA.A_MSTR_CRM_Deal
SELECT
D.Klant_nr,
D.Maand_nr,
D.Datum_gegevens,
D.Business_contact_nr,
D.Siebel_deal_id,
D.Naam_verkoopkans,
COALESCE(A.deal_Selling_type_nr, -101),
COALESCE(B.deal_Status_nr, -101),
COALESCE(C.deal_Soort_nr,-101),
COALESCE(E.deal_Productgroep_nr, -101),
COALESCE(D.Campaign_code_primary, -101),
COALESCE(F.deaL_Herkomst_nr,-101),
COALESCE(D.Deal_captain_mdw_sbt_id, -101),
COALESCE(D.Naam_deal_captain_mdw, 'Onbekend'),
COALESCE(D.Sbt_id_mdw_aangemaakt_door, -101),
COALESCE(D.Naam_mdw_aangemaakt_door, 'Onbekend' ),
COALESCE(D.Sbt_id_mdw_bijgewerkt_door, -101),
COALESCE(D.Naam_mdw_bijgewerkt_door, 'Onbekend'),
COALESCE(D.Vertrouwelijk_ind, -101),
D.Aantal_producten,
D.Aantal_succesvol,
D.Aantal_niet_succesvol,
D.Aantal_in_behandeling,
D.Aantal_Nieuw,
((EXTRACT(YEAR FROM D.Datum_aangemaakt)*100)+(EXTRACT (MONTH FROM D.Datum_aangemaakt)))  Maand_aangemaakt  ,
D.Datum_aangemaakt,
((EXTRACT(YEAR FROM D.Datum_start)*100)+(EXTRACT (MONTH FROM D.Datum_start)))  Maand_start,
D.Datum_start,
((EXTRACT(YEAR FROM D.Datum_afgehandeld)*100)+(EXTRACT (MONTH FROM D.Datum_afgehandeld)))  Maand_afgehandeld,
D.Datum_afgehandeld,
((EXTRACT(YEAR FROM D.datum_start_baten)*100)+(EXTRACT (MONTH FROM D.datum_start_baten)))  Maand_start_baten,
D.Datum_start_baten,
D.Lead_uuid,
D.Client_level,
COALESCE(D.Country_primary, -101),
COALESCE(D.Contactpersoon_primary_siebel_id, -101)
FROM MI_SAS_AA_MB_C_MB.Siebel_Deal D
LEFT JOIN MI_CMB_UIA.A_MSTR_LU_CRM_Deal_selling_type A
ON D.selling_type = A.deal_selling_type
LEFT JOIN MI_CMB_UIA.A_MSTR_LU_CRM_Deal_status B
ON D.status = B.deal_status
LEFT JOIN MI_CMB_UIA.A_MSTR_LU_CRM_Deal_productgroep E
ON E.deal_productgroep = D.productgroep
LEFT JOIN MI_CMB_UIA.A_MSTR_LU_CRM_Deal_soort C
ON D.soort = C.Deal_soort
LEFT JOIN MI_CMB_UIA.A_MSTR_LU_CRM_Deal_herkomst F
ON D.herkomst = F.Deal_herkomst;



INSERT INTO MI_CMB_UIA.A_MSTR_LU_migr_Bediening
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_migr_Bediening;

INSERT INTO  MI_CMB_UIA.A_MSTR_LU_Migr_Bediening
SELECT  CSUM(1, a.Migr_Bediening DESC) + a.Max_Migr_Bediening_nr  Migr_Bediening_nr
   		 ,TRIM(a.Migr_Bediening)  Migr_Bediening
FROM
     (
     SELECT TRIM(a.Migr_Bediening)  Migr_Bediening
            ,c.Max_Migr_Bediening_nr
     FROM
     (
     SELECT DISTINCT TRIM(bediening_begin)  Migr_Bediening FROM Mi_sas_aa_mb_c_mb.Mia_migratie_hist
	JOIN Mi_sas_aa_mb_c_mb.Mia_migratie_hist
	On 1=1
	WHERE TRIM(bediening_eind) IS NOT NULL AND bediening_eind <> ''
	GROUP BY 1
	)  A

	LEFT OUTER JOIN (SELECT  Migr_Bediening_nr
                           ,TRIM(Migr_Bediening)  Migr_Bediening
                       FROM MI_CMB_UIA.A_MSTR_LU_Migr_Bediening
                       GROUP BY 1,2
                       ) b
   ON  TRIM(b.Migr_Bediening)  = TRIM(a.Migr_Bediening)

	 INNER JOIN (SELECT MAX(Migr_Bediening_nr)  Max_Migr_Bediening_nr
                  FROM MI_CMB_UIA.A_MSTR_LU_Migr_Bediening
                 ) c
        ON 1=1
     WHERE NOT TRIM(a.Migr_Bediening) IS NULL
       AND b.Migr_Bediening_nr IS NULL
     GROUP BY 1,2
     ) a;


 INSERT INTO MI_CMB_UIA.A_MSTR_LU_Migr_Sub_cat
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_Migr_Sub_cat;



INSERT INTO  MI_CMB_UIA.A_MSTR_LU_Migr_Sub_cat
SELECT  CSUM(1, a.Sub_categorie DESC) + a.Max_Sub_categorie_nr  Sub_categorie_nr
   		 ,TRIM(a.Sub_categorie)  Sub_categorie
FROM
     (
     SELECT TRIM(a.Sub_categorie)  Sub_categorie
            ,c.Max_Sub_categorie_nr
     FROM
     (
     SELECT DISTINCT TRIM(van_sub)  sub_categorie FROM Mi_sas_aa_mb_c_mb.Mia_migratie_hist
	JOIN Mi_sas_aa_mb_c_mb.Mia_migratie_hist
	ON 1=1
	WHERE TRIM(naar_sub) IS NOT NULL
	GROUP BY 1
	)  A

	LEFT OUTER JOIN (SELECT  Sub_categorie_nr
						                           ,TRIM(Sub_categorie)  Sub_categorie
						                       FROM MI_CMB_UIA.A_MSTR_LU_Migr_Sub_cat
						                       GROUP BY 1,2
                       ) b
   ON  TRIM(b.Sub_categorie)  = TRIM(a.Sub_categorie)

	 INNER JOIN (SELECT MAX(Sub_categorie_nr)  Max_Sub_categorie_nr
                  FROM MI_CMB_UIA.A_MSTR_LU_Migr_Sub_cat
                 ) c
        ON 1=1
     WHERE NOT TRIM(a.Sub_categorie) IS NULL
       AND b.Sub_categorie_nr IS NULL
     GROUP BY 1,2
     ) a;


/* Historie overnemen */
 INSERT INTO MI_CMB_UIA.A_MSTR_LU_Migr_Kop_cat
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_Migr_Kop_cat;


INSERT INTO  MI_CMB_UIA.A_MSTR_LU_Migr_Kop_cat
SELECT  CSUM(1, a.Kop_categorie DESC) + a.Max_Kop_categorie_nr  Kop_categorie_nr
   		 ,TRIM(a.Kop_categorie)  Kop_categorie
FROM
     (
     SELECT TRIM(a.Kop_categorie)  Kop_categorie
              ,c.Max_Kop_categorie_nr
     FROM
     (
     SELECT DISTINCT TRIM(van_kop)  Kop_categorie FROM Mi_sas_aa_mb_c_mb.Mia_migratie_hist
	JOIN i_sas_aa_mb_c_mb.Mia_migratie_hist
	ON 1=1
	WHERE TRIM(naar_kop) IS NOT NULL
	GROUP BY 1
	)  A

	LEFT OUTER JOIN (SELECT  Kop_categorie_nr
						                           ,TRIM(Kop_categorie)  Kop_categorie
						                       FROM MI_CMB_UIA.A_MSTR_LU_Migr_Kop_cat
						                       GROUP BY 1,2
    )  B
   ON  TRIM(b.Kop_categorie)  = TRIM(a.Kop_categorie)

	 INNER JOIN (SELECT MAX(Kop_categorie_nr)  Max_Kop_categorie_nr
                  FROM MI_CMB_UIA.A_MSTR_LU_Migr_Kop_cat
                 ) c
        ON 1=1
     WHERE NOT TRIM(a.Kop_categorie) IS NULL
       AND b.Kop_categorie_nr IS NULL
     GROUP BY 1,2
     )  A;


 INSERT INTO MI_CMB_UIA.A_MSTR_LU_Migr_Categorie
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_Migr_Categorie;



INSERT INTO  MI_CMB_UIA.A_MSTR_LU_Migr_Categorie
SELECT CSUM(1, a.Migr_Categorie DESC) + a.Max_Migr_Categorie_nr  Migr_Categorie_nr
    	,TRIM(a.Migr_Categorie)
FROM(SELECT TRIM(a.Migr_Categorie)  Migr_Categorie
	 		 ,c.Max_Migr_Categorie_nr
	FROM (SELECT DISTINCT in_uitstroom  migr_categorie
FROM  Mi_sas_aa_mb_c_mb.Mia_migratie_hist A
JOIN  Mi_sas_aa_mb_c_mb.Mia_migratie_hist A
on 1=1
JOIN MI_CMB_UIA.A_MSTR_LU_Migr_Categorie
 ON TRIM(b.Migr_Categorie) = TRIM(a.Migr_Categorie)
INNER JOIN (SELECT MAX(Migr_Categorie_nr)  Max_Migr_Categorie_nr
			 FROM MI_CMB_UIA.A_MSTR_LU_Migr_Categorie)  C
        ON 1=1
     WHERE NOT A.Migr_Categorie IS NULL
       AND b.Migr_Categorie_nr IS NULL
     GROUP BY 1,2
     )  A);


INSERT INTO MI_CMB_UIA.A_MSTR_LU_migr_Businessline
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_migr_Businessline;



INSERT INTO  MI_CMB_UIA.A_MSTR_LU_Migr_businessline
SELECT  CSUM(1, a.Migr_businessline DESC) + a.Max_Migr_businessline_nr  Migr_businessline_nr
   		 ,TRIM(a.Migr_businessline)  Migr_businessline
FROM
     (
     SELECT TRIM(a.Migr_businessline)  Migr_businessline
            ,c.Max_Migr_businessline_nr
     FROM
     (
     SELECT DISTINCT TRIM(business_line)  Migr_businessline FROM Mi_sas_aa_mb_c_mb.Mia_migratie_hist
	WHERE TRIM(business_line) IS NOT NULL AND business_line <> ''
	GROUP BY 1
	)  A

	LEFT OUTER JOIN (SELECT  Migr_businessline_nr
                           ,TRIM(Migr_businessline)  Migr_businessline
                       FROM MI_CMB_UIA.A_MSTR_LU_Migr_businessline
                       GROUP BY 1,2
                       ) b
   ON  TRIM(b.Migr_businessline)  = TRIM(a.Migr_businessline)

	 INNER JOIN (SELECT MAX(Migr_businessline_nr)  Max_Migr_businessline_nr
                  FROM MI_CMB_UIA.A_MSTR_LU_Migr_businessline
                 ) c
        ON 1=1
     WHERE NOT TRIM(a.Migr_businessline) IS NULL
       AND b.Migr_businessline_nr IS NULL
     GROUP BY 1,2
     ) a;


INSERT INTO MI_CMB_UIA.A_MSTR_LU_migr_periode
SELECT * FROM MI_CMB_UIA.A_MSTR_LU_migr_periode;


INSERT INTO  MI_CMB_UIA.A_MSTR_LU_Migr_periode
SELECT  CSUM(1, a.Migr_periode DESC) + a.Max_Migr_periode_nr  Migr_periode_nr
   		 ,TRIM(a.Migr_periode)  Migr_periode
FROM
     (
     SELECT TRIM(a.Migr_periode)  Migr_periode
            ,c.Max_Migr_periode_nr
     FROM
     (
     SELECT DISTINCT TRIM(periode)  Migr_periode FROM Mi_sas_aa_mb_c_mb.Mia_migratie_hist
	WHERE TRIM(periode) IS NOT NULL AND periode <> ''
	)  A

	LEFT OUTER JOIN (SELECT  Migr_periode_nr
                           ,TRIM(Migr_periode)  Migr_periode
                       FROM MI_CMB_UIA.A_MSTR_LU_Migr_periode
                       GROUP BY 1,2
                       ) b
   ON  TRIM(b.Migr_periode)  = TRIM(a.Migr_periode)

	 INNER JOIN (SELECT MAX(Migr_periode_nr)  Max_Migr_periode_nr
                  FROM MI_CMB_UIA.A_MSTR_LU_Migr_periode
                 ) c
        ON 1=1
     WHERE NOT TRIM(a.Migr_periode) IS NULL
       AND b.Migr_periode_nr IS NULL
     GROUP BY 1,2
     ) a;





INSERT INTO MI_CMB_UIA.A_MSTR_Mia_migratie
SELECT a.maand_nr,
a.maand_nr_begin
FROM Mi_sas_aa_mb_c_mb.Mia_migratie_hist A
LEFT JOIN Mi_sas_aa_mb_c_mb.CIAA_Mia_hist KL
ON KL.klant_nr = klant_nrX
AND KL.maand_nr = Maand_nr_Koppel_Mia_hist
LEFT JOIN MI_CMB_UIA.A_MSTR_Mia_businesscontact BC		-- voor koppeling naar overstapservice
ON BC.klant_nr = klant_nrX
AND BC.maand_nr = Maand_nr_Koppel_Mia_hist
LEFT JOIN MI_CMB_UIA.A_MSTR_LU_migr_Bediening B
ON A.bediening_begin = b.migr_bediening
LEFT JOIN MI_CMB_UIA.A_MSTR_LU_migr_Bediening C
ON A.bediening_eind = c.migr_bediening
LEFT JOIN MI_CMB_UIA.A_MSTR_LU_Migr_Categorie D
ON 	A.in_uitstroom = D.migr_categorie
LEFT JOIN MI_CMB_UIA.A_MSTR_LU_Migr_Categorie X
ON 	A.categorie1 = X.migr_categorie
LEFT JOIN MI_CMB_UIA.A_MSTR_LU_Migr_Categorie Z
ON 	A.categorie2 = Z.migr_categorie
LEFT JOIN MI_CMB_UIA.A_MSTR_LU_Migr_Sub_cat E
ON E.sub_categorie = A.van_sub
LEFT JOIN MI_CMB_UIA.A_MSTR_LU_Migr_Sub_cat F
ON F.sub_categorie = A.naar_sub
LEFT JOIN MI_CMB_UIA.A_MSTR_LU_Migr_Kop_cat G
ON G.kop_categorie = A.van_kop
LEFT JOIN MI_CMB_UIA.A_MSTR_LU_Migr_Kop_cat H
ON H.kop_categorie = A.naar_kop
LEFT JOIN MI_CMB_UIA.A_MSTR_LU_Migr_periode I
ON I.migr_periode = A.periode
LEFT JOIN MI_CMB_UIA.A_MSTR_LU_Migr_businessline J
ON J.migr_businessline = A.business_line
left join (
select party_id  BC,  datum_ingang_gewenst, andere_bank, vertrekkend
from MI_VM_Ldm.acontract_overstap a
qualify row_number() OVER (PARTITION BY party_id ORDER BY datum_ingang_gewenst DESC, iban_nr) = 1
)  CO
ON BC.business_contact_nr = co.BC
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25;

INSERT INTO mi_cmb.TB_Revisiedatum
SELECT
F.Naam  eigenaar,
A.datum_bijgewerkt  Laatste_wijziging_datum,
G.Naam  Laatste_wijziging_door,
A.datum_eind  einddatum,
A.siebel_activiteit_id  siebel_activiteit_id
FROM mi_vm_ldm.aACTIVITEIT A
LEFT JOIN (
SELECT MAX(maand_nr)  maand_nr FROM MI_CMB_UIA.TB_Businesscontacts)
 M
ON 1=1
LEFT JOIN  mi_cmb_uia.TB_businesscontacts B
ON B.business_contact_nr = A.party_id_rechtspersoon_bc
AND b.maand_nr = M.maand_nr
LEFT JOIN mi_cmb.vCRM_Employee_week F
ON TRIM(F.sbt_id) = TRIM(sbt_id_mdw_eigenaar)
LEFT JOIN mi_cmb.vCRM_Employee_week G
ON TRIM(G.sbt_id) = TRIM(sbt_id_mdw_bijgewerkt_door)
LEFT JOIN ( -- ophalen maximale revisiedatum voor revisie_actueel

SELECT  b.klant_nr  klant_z, siebel_activiteit_id, datum_start
FROM  mi_vm_ldm.aACTIVITEIT A
LEFT JOIN
(SELECT MAX(maand_nr)  maand_nr FROM MI_CMB_UIA.TB_Businesscontacts)
 M
ON 1=1
LEFT JOIN  mi_cmb_uia.TB_businesscontacts B
ON B.business_contact_nr = A.party_id_rechtspersoon_bc
AND b.maand_nr = M.maand_nr
LEFT JOIN mi_cmb.vCRM_Employee_week F
ON TRIM(F.sbt_id) = TRIM(sbt_id_mdw_eigenaar)
LEFT JOIN mi_cmb.vCRM_Employee_week G
ON TRIM(G.sbt_id) = TRIM(sbt_id_mdw_bijgewerkt_door)
WHERE onderwerp = 'Revision / maintenance'
AND productgroep = 'Betalen & Contant geld'
AND activiteit_type = 'Task'
AND Korte_omschrijving = 'TB revisie'
AND Status NE 'Cancelled'
AND sdat >= date'2017-09-02'
QUALIFY ROW_NUMBER () OVER (PARTITION BY klant_z ORDER BY datum_verval DESC, datum_start DESC, siebel_activiteit_id DESC) = 1)  C
ON C.klant_z = klant_nr_x
AND C.siebel_activiteit_id = A.siebel_activiteit_id
WHERE onderwerp = 'Revision / maintenance'
AND productgroep = 'Betalen & Contant geld'
AND activiteit_type = 'Task'
AND Korte_omschrijving = 'TB revisie'
AND Status NE 'Cancelled'
AND sdat >= date'2017-09-02';


INSERT INTO MI_CMB_UIA.TB_LU_revisie_productgroep

SELECT 		a.revisie_productgroep_nr, a.revisie_productgroep
FROM 			mi_cmb_uia.tb_lu_revisie_productgroep	a
;


INSERT INTO MI_CMB_UIA.TB_LU_revisie_productgroep
SELECT
CASE WHEN a.productgroep IS NOT NULL THEN ROW_NUMBER() OVER (ORDER BY COALESCE(a.productgroep, 'ZZZ'))
				+ (SELECT MAX (revisie_productgroep_nr)  FROM  mi_cmb_uia.tb_lu_revisie_productgroep) ELSE -101 end  revisie_productgroep_nr
		, COALESCE(a.productgroep, 'Onbekend')  revisie_productgroep
FROM 	mi_cmb.TB_Revisiedatum
WHERE a.productgroep NOT IN (SELECT revisie_productgroep FROM  mi_cmb_uia.tb_lu_revisie_productgroep)
GROUP BY   a.productgroep,2
;



INSERT INTO MI_CMB_UIA.TB_LU_revisie_status

SELECT  a.revisie_status_nr, a.revisie_status
FROM 		mi_cmb_uia.tb_lu_revisie_status	a
;


INSERT INTO MI_CMB_UIA.TB_LU_revisie_status
SELECT	 CASE WHEN a.status IS NOT NULL THEN ROW_NUMBER() OVER (ORDER BY COALESCE(a.status, 'ZZZ'))
				+ (SELECT MAX (revisie_status_nr)  FROM  mi_cmb_uia.tb_lu_revisie_status) ELSE -101 end  revisie_status_nr
		, COALESCE(a.status, 'Onbekend')  revisie_status
FROM 		mi_cmb.TB_Revisiedatum
WHERE a.status NOT IN (SELECT revisie_status FROM  mi_cmb_uia.tb_lu_revisie_status)
GROUP BY  a.status, 2
;


INSERT INTO MI_CMB_UIA.TB_LU_revisie_onderwerp
SELECT a.revisie_onderwerp_nr, a.revisie_onderwerp
FROM mi_cmb_uia.tb_lu_revisie_onderwerp
;

INSERT INTO MI_CMB_UIA.TB_LU_revisie_onderwerp
SELECT	CASE WHEN a.onderwerp IS NOT NULL THEN ROW_NUMBER() OVER (ORDER BY COALESCE(a.onderwerp, 'ZZZ'))
			+ (SELECT MAX (revisie_onderwerp_nr)  FROM  mi_cmb_uia.tb_lu_revisie_onderwerp) ELSE -101 end  revisie_onderwerp_nr
		, COALESCE(a.onderwerp, 'Onbekend')  revisie_onderwerp
FROM 	mi_cmb.TB_Revisiedatum
WHERE a.onderwerp NOT IN (SELECT revisie_onderwerp FROM  mi_cmb_uia.tb_lu_revisie_onderwerp)
GROUP BY  a.onderwerp, 2
;



INSERT INTO MI_CMB_UIA.TB_Revisiedatum
SELECT
a.klant_nr,
a.maand_nr,
a.revisie_datum,
a.revisie_actueel_ind,
c.revisie_status_nr,
b.revisie_subtype_nr,
d.revisie_productgroep_nr,
e.revisie_onderwerp_nr,
a.korte_omschrijving,
a.opmerking,
a.vertrouwelijk_ind,
a.startdatum,
a.eigenaar,
a.Laatste_wijziging_datum,
a.Laatste_wijziging_door,
a.einddatum,
a.siebel_activiteit_id,
CURRENT_DATE
FROM mi_cmb.TB_Revisiedatum
LEFT JOIN MI_CMB_UIA.TB_LU_revisie_subtype B
ON A.subtype = b.revisie_subtype
LEFT JOIN MI_CMB_UIA.TB_LU_revisie_status C
ON A.status = C.revisie_status
LEFT JOIN MI_CMB_UIA.TB_LU_revisie_productgroep D
ON A.productgroep = D.revisie_productgroep
LEFT JOIN MI_CMB_UIA.TB_LU_revisie_onderwerp
ON A.onderwerp = E.revisie_onderwerp
;



UPDATE mi_cmb_uia.TB_Businesscontacts
FROM (SELECT klant_nr, revisie_datum
FROM mi_cmb_uia.TB_Revisiedatum
WHERE Revisie_actueel_ind = 1) A
 revisiedatum = COALESCE(A.revisie_datum, NULL)
WHERE mi_cmb_uia.TB_Businesscontacts.klant_nr = A.klant_nr;




INSERT INTO mi_cmb_uia.Z_digital_forms
select a.processid
from MI_VM_LDM.vbackbase_main A
inner join mi_vm_ldm.vBackbase_fact F
ON F.processid = A.processid
AND COALESCE(TRIM(a.party_id),-101) <>  2008593428
and (COALESCE(TRIM(a.party_id),-101) <>  2015898816)
left join mi_cmb.vmia_businesscontacts D
on TRIM(SUBSTR ( d.kvk_nr, 2 , 12 )) = CASE WHEN LENGTH(f.fieldvalue) = 11 THEN TRIM(LPAD(f.fieldvalue, 12, '0' ))
WHEN LENGTH(f.fieldvalue) = 8 THEN TRIM(RPAD(f.fieldvalue, 12, '0' ))
ELSE TRIM(f.fieldvalue) END
left join mi_cmb.vmia_klantkoppelingen B
on d.business_contact_nr = b.business_contact_nr
left join mi_cmb.vmia_week C
on b.klant_nr = c.klant_nr
where (formid like 'c%' or formid like 'b%' )
and EXTRACT(year FROM startdatetime) in ( 2017, 2018, 2019 )
and (COALESCE(TRIM(a.party_id),-101) <>  2008593428)
and (COALESCE(TRIM(a.party_id),-101) <>  2015898816)
and formid NOT IN ('BAC',
'COXusabilitytest',
'CPRkredietofferteABTest')
and fieldname in (
'OrganisationChamberOfCommerce', 'OrganisationAccountNumber')
and party_id IS NULL
)  G
ON a.processid = g.processid
where (formid like 'c%' or formid like 'b%' )
and EXTRACT(year FROM startdatetime) in ( 2017, 2018, 2019 )
and (COALESCE(TRIM(a.party_id),-101) <>  2008593428)
and (COALESCE(TRIM(a.party_id),-101) <>  2015898816)
and (COALESCE(TRIM(a.party_id),-101) <>  502568070)
and formid NOT IN ('BAC',
'COXusabilitytest',
'CPRkredietofferteABTest');



INSERT INTO MI_CMB_UIA.Z_digital_klantstructuur_details
select
c.bc_login_type
from
(select	*
from mi_vm_ldm.aBC_CONTRACT
where contract_soort_code=101
)  a
left join
(select	*
from mi_vm_ldm.aBC_CONTRACT
where contract_soort_code=5
and  contract_status_code<>3
)  b
on a.business_contact_nr=b.business_contact_nr
left join
(select
business_contact_nr,
segment_id,
case when segment_id  between 1150 and 1280 then 'commercieel' else 'retail and commercieel' end  bc_login_type
from mi_vm_ldm.aBC_SEGMENT_KLANT
where segment_type_code='CG')  c
on a.business_contact_nr=c.business_contact_nr
left join
(select
 a.business_contact_nr,
 a.contract_nr,
 b.segment_id,
 'Y'  Commercieel_entiteit
from mi_vm_ldm.aBC_CONTRACT  a
join mi_vm_ldm.aBC_segment_klant  b
on a.business_contact_nr=b.business_contact_nr
where contract_soort_code=101
and contract_status_code<>4
and Segment_Type_Code='CG'
and Segment_id between 1150 and 1280)  d
on a.contract_nr=d.contract_nr
left join
(select	*
from mi_vm_ldm.aBC_CONTRACT_CARD
where status_code=0
)  e
on b.contract_nr=e.contract_nr
left join
(select *
from mi_cmb.vMia_klantkoppelingen)  f
on d.business_contact_nr=f.business_contact_nr
where d.commercieel_entiteit='Y'
and f.klant_nr is not null
group by
a.Business_contact_nr,
a.commercieel_contract_nr,
a.contract_status_code,
b.contract_nr,
b.herkomst_administratie_key,
e.card_id,
e.card_type_code,
e.onpersoonlijke_pas_ind,
b.contract_soort_code,
d.Commercieel_entiteit,
d.business_contact_nr,
f.klant_nr,
d.segment_id,
c.segment_id,
c.bc_login_type)  ot
on client.commercieel_complex_id=ot.klant_nr
and commercieel_entiteit_id=commercieel_entiteit_bc_id
where client.klant_ind=1
)z
on 1=1
left join
(select *
from mi_vm_ldm.aCGC_Hierarchie) cgc
on z.clientgroep=cgc.cg_code
left join
(select *
from mi_vm_ldm.aGeldvorm)  grv
on z.geldvorm=grv.geldvorm
left join
(select *
from mi_vm_ldm.acard_type)  card_type
on z.Card_Type_Code=card_type.Card_Type_Code;



INSERT INTO Mi_temp.Kred_rapportage_moment
SEL
     lm.maand
    ,lm.maand_sdat
    ,lm.maand_edat
FROM Mi_vm.vlu_maand                      lm
WHERE lm.maand = (SELECT MAX(maand_nr) FROM mi_cmb.cif_complex)
;


INSERT INTO MI_CMB_UIA.Z_MSTR_KemPricAnal
SELECT
    x.maand_nr  Maand_nr
    , x.datum  Datum_gegevens
FROM MI_SAS_AA_MB_C_MB.KEM_pijplijn  a

LEFT OUTER JOIN (
  SELECT Max(maand_nr)  Maand_nr, Max(Maand_edat)  Maand_edat , Current_Date  datum
  FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr
)  X ON 1=1

LEFT OUTER JOIN MI_SAS_AA_MB_C_MB.KEM_aanvraag_det  b
   ON b.fk_aanvr_wkmid = a.fk_aanvr_wkmid
  AND b.fk_aanvr_versie = a.fk_aanvr_versie
  AND b.voorstel_type IN ('NIEUW', 'WIJZIGING')

LEFT OUTER JOIN (
  SELECT
    b.fk_aanvr_wkmid
    , b.fk_aanvr_versie
    , 'Client'  RARORAC_Type
    , 'geaccepteerd'  aanvraag_fase
    , b.Client_RARORAC_geaccepteerd  RARORAC
  FROM MI_SAS_AA_MB_C_MB.KEM_aanvraag_det  b
) b2
  ON b2.fk_aanvr_wkmid = b.fk_aanvr_wkmid
 AND b2.fk_aanvr_versie = b.fk_aanvr_versie

LEFT OUTER JOIN mi_vm_ldm.aParty_naam c
  ON c.Party_id = b.Voorstel_BCnr_hfdrek_nr
 AND c.Party_sleutel_type = 'BC'

LEFT OUTER JOIN (
    SELECT
        a.fk_aanvr_wkmid
       , a.fk_aanvr_versie
       , Max(CASE WHEN Status_nr = 38 THEN a.Date_created_stap ELSE NULL END)  Offerte_geaccepteerd

     FROM MI_SAS_AA_MB_C_MB.KEM_pijplijn a
     WHERE a.Soort_pijplijn = 'KEM'
      GROUP BY 1,2
   ) d
  ON a.fk_aanvr_wkmid = d.fk_aanvr_wkmid
 AND a.fk_aanvr_versie = d.fk_aanvr_versie

LEFT OUTER JOIN MI_VM_ldm.vBO_MI_Part_Zak     e
  ON e.bo_nr = b.Voorstel_Kantoor_BOnr

LEFT OUTER JOIN mi_vm_ldm.aSegment_klant   f
  ON f.Party_id = b.Voorstel_BCnr_hfdrek_nr
 AND f.Party_sleutel_type = 'BC'
 AND f.Segment_type_code = 'CG'

INNER JOIN mi_cmb.vCGC_BASIS    g
   ON g.Clientgroep = f.Segment_id

LEFT OUTER JOIN Mi_cmb.vMia_klantkoppelingen_hist    h
  ON h.business_contact_nr =  b.Voorstel_BCnr_hfdrek_nr
 AND h.Maand_nr = a.Maand_nr

LEFT OUTER JOIN mi_cmb.vmia_hist    i
  ON i.klant_nr = h.klant_nr
 AND i.maand_nr = h.maand_nr

LEFT OUTER JOIN mi_vm_ldm.aSegment_klant   m
  ON m.Party_id = b.Voorstel_BCnr_hfdrek_nr
 AND m.Party_sleutel_type = 'BC'
 AND m.Segment_type_code = 'SBI'

LEFT OUTER JOIN MI_VM_Nzdb.vKVK_branche                 m2
  ON m2.KVK_branche_code = m.Segment_id
 AND m2.maand_nr = a.Maand_nr

WHERE a.Soort_pijplijn = 'KEM'
  AND a.Volgnr_chrono _old = 1
  AND d.Offerte_geaccepteerd BETWEEN 1130101 AND (SELECT ultimomaand_eind_datum_tee FROM Mi_temp.Kred_rapportage_moment)  -- laatste dag van voorgaande kalendermaand
  AND B.doelgroep <> 'PAR';



INSERT INTO MI_CMB_UIA.Z_MSTR_AHK
SELECT
    a.maand_nr  maandnr
    , current_date  datum_gegevens
    , a.contract_nr
    , a.bc_nr
    , a.valuta_krediet
    , a.kredietsoort
    , a.kred_lim
    , a.avg_pos
    , a.gem_obligopositie
    , a.laagste_uitnutting
    , a.hoogste_uitnutting
    , c.klant_nr cluster_nr
    , c.verkorte_naam cluster_naam
    , c.business_line
    , c.segment
    , c.clientgroep
    , c.bo_nr
    , c.bo_naam
    , c.relatiemanager bediening_naam
    , c.org_niveau1
    , c.org_niveau2
    , c.org_niveau3
    , c.sbi_oms
    , c.agic_oms
    , c.cmb_sector
    , c.subsector_oms
    , MAVG(a.avg_pos, 12, maandnr)  gem_voorg_12mnd
FROM mi_cmb.ahk_basis a

JOIN mi_cmb.vmia_businesscontacts b
  ON a.bc_nr=b.business_contact_nr
 AND b.lopende_maand_ind EQ 1

JOIN mi_cmb.vmia_hist c
  ON b.klant_nr=c.klant_nr
 AND b.maand_nr=c.maand_nr;



INSERT INTO mi_temp.krd051_t1
    SELECT a.party_id  franchise_nemer_bc_nr
      , b.naam  franchise_nemer_naam
      , a.gerelateerd_party_id  franchise_gever_bc_nr
      , c.naam  franchise_gever_naam
       , ROW_NUMBER()  OVER (PARTITION BY a.party_id ORDER BY a.party_party_relatie_sdat)   DQ_indien_groter_dan_een

    FROM mi_VM_ldm.aPARTY_PARTY_RELATIE                                                                         a

    LEFT JOIN mi_vm_ldm.aparty_naam                                                                                         b
     ON a.party_id = b.party_id
    AND a.party_sleutel_type = b.party_sleutel_type

    LEFT JOIN mi_vm_ldm.aparty_naam                                                                                         c
     ON a.gerelateerd_party_id = c.party_id
    AND a.party_sleutel_type = c.party_sleutel_type

    LEFT JOIN Mi_cmb.vMia_klantkoppelingen                                                                                    d
  ON d.business_contact_nr = a.party_id

    WHERE a.party_relatie_type_code = 'FRNCSE'
  ;




INSERT INTO MI_CMB_UIA.Z_MSTR_FranchiseClients
SELECT
  a2.maand_nr
  , CURRENT_DATE
  , a.franchise_gever_bc_nr
  , a.franchise_gever_naam
  , a.franchise_nemer_bc_nr
  , a.franchise_nemer_naam
  , CASE
              WHEN a.klant_nr IS NULL THEN -101
            ELSE a.klant_nr END  klant_nr
            , COALESCE(c.business_line,'Onbekend')  business_line
   , COALESCE(c.segment, 'Onbekend')  segment
   , COALESCE(c.cross_sell, 0)
   , COALESCE(CCA, 0)
   , COALESCE(Relatiemanager, 'Onbekend')
  , c.baten totale_klant_baten_12mnd
  , c.kredieten_baten kredieten_baten_12mnd
  , c.creditgelden_baten creditgelden_baten_12mnd
  , c.domestic_cash_baten domestic_cash_baten_12mnd
  , CASE WHEN e.contract_nr IS NULL THEN -101 ELSE e.contract_nr END  contract_nr
  , CASE WHEN e.kredietsoort_isk_ind = 1 THEN RIGHT(e.fac_product_adm_id,3)
         ELSE COALESCE(RIGHT(e.fac_product_adm_id, 2),'Onbekend') END  krediet_soort
  , COALESCE(e.pl_npl_type, 'Onbekend')  pl_npl_type
  , COALESCE(e.fiat_instantie_code, 'Onbekend')  fiat_instantie_code
  , COALESCE(e.fiat_instantie_oms, 'Onbekend')  fiat_instantie_oms
  , e.OOE
  , e.limiet_krediet
  , e.doorlopend_saldo  krediet_positie
  , e.debet_volume
  , e.fac_bc_crg  CRG
  , COALESCE(e.fac_bc_ucr,'-')  UCR
  , CASE WHEN a.DQ_indien_groter_dan_een > 1  THEN 'Gekoppeld aan meerdere franchisegevers' ELSE NULL END  DQ_issue_1
  , CASE WHEN e.DQ_issue_indien_ongelijk_1 > 1 THEN 'ACBS probleem: meerdere masterfaciliteiten' ELSE NULL END  DQ_issue_2
FROM mi_temp.krd051_t1                                                                                                                              a
INNER JOIN (
    SELECT MAX(Maand_nr)  Maand_nr FROM Mi_cmb.vMia_klantkoppelingen_hist)                                                                                                                                                                 a2
  ON (1=1)
LEFT JOIN (
SELECT
c.maand_nr,
c.baten,
kredieten_baten,
creditgelden_baten,
domestic_cash_baten,
business_contact_nr,
business_line,
segment,
cross_sell,
CCA,
Relatiemanager

FROM Mi_cmb.vCUBe_baten_hist                                                                                                               c
LEFT JOIN mi_cmb.vmia_week                                                                                                                                     f--d
ON c.klant_nr = f.klant_nr
AND c.maand_nr = f.maand_nr
WHERE f.klant_nr IS NOT NULL
)                                                                                                                                      C
  ON c.business_contact_nr=a.franchise_nemer_bc_nr

LEFT JOIN (
  SELECT
      d.bc_nr
    , e.maand_nr
    , e.fac_cif_ind
    , e.contract_nr
    , e.master_faciliteit_id
    , e.faciliteit_id
    , e.fac_bo_nr_beheer_acbs
    , e.pl_npl_type
    , e.fac_bc_nr
    , e.fac_bc_ucr
    , e.fac_bc_crg
    , e.kredietsoort_isk_ind
    , e.kredietsoort_bsk_ind
    , e.fac_product_adm_oms
    , e.fac_product_adm_id
    , e.fiat_instantie_code
    , e.fiat_instantie_oms
    , e.muntcode
    , e.OOE
    , e.limiet_krediet
    , e.doorlopend_saldo
    , e.Saldo_ML
    , e.debet_volume
    , e.datum_revisie
    , e.DQ_issue_indien_ongelijk_1

  FROM (

      SELECT a.master_faciliteit_id, a.faciliteit_id, a.maand_nr, a.fac_bc_nr  bc_nr
      FROM mi_cmb.cif_complex                                                                                                                                                             a
      JOIN mi_cmb.cif_drawing
      On 1=1                                                                                                                                                            a
      GROUP BY 1,2,3,4
      WHERE a.draw_actief_ind = 1

  )                                                                                                                                                                                                             d

  INNER JOIN (

    SELECT a.*
    FROM (
        SELECT
          a.maand_nr
          , a.fac_cif_ind
          , CAST(TO_NUMBER(a.hoofdrekening, '9999999999')  DECIMAL(11,0))  contract_nr
          , a.master_faciliteit_id
          , a.faciliteit_id
          , a.fac_bo_nr_beheer_acbs
          , a.pl_npl_type
          , a.fac_bc_nr
          , a.fac_bc_ucr
          , a.fac_bc_crg
          , a.kredietsoort_isk_ind
          , a.kredietsoort_bsk_ind
          , a.fac_product_adm_oms
          , a.fac_product_adm_id
          , a.fiat_instantie_code
          , a.fiat_instantie_oms
          , a.muntcode
          , a.OOE
          , a.doorlopend_limiet  limiet_krediet
          , a.doorlopend_saldo
          , a.aflopend_saldo  Saldo_ML
          , a.aflopend_saldo + a.doorlopend_saldo  debet_volume
          , a.datum_revisie
          , ROW_NUMBER() OVER (PARTITION BY a.maand_nr, a.hoofdrekening ORDER BY OOE)  DQ_issue_indien_ongelijk_1
        FROM mi_cmb.cif_complex                                                                                                                                                                                 a

        WHERE a.Fac_actief_ind = 1
        AND (a.verwachte_verval_datum IS NULL OR (EXTRACT(YEAR FROM a.verwachte_verval_datum)*100 + EXTRACT(MONTH FROM a.verwachte_verval_datum) >= a.maand_nr))
        AND a.limiet_type = 'Overall limit'
        AND a.ooe <> 0
        AND a.Maand_nr = (SELECT MAX(Maand_nr)  Maand_nr FROM mi_cmb.CIF_complex)
    )                                                                                                                                                                                                                                 a
    QUALIFY ROW_NUMBER() OVER (PARTITION BY a.maand_nr, a.contract_nr ORDER BY DQ_issue_indien_ongelijk_1 DESC) = 1

  )                                                                                                                                                                                                                                 e
  ON d.master_faciliteit_id = e.master_faciliteit_id
  AND d.faciliteit_id = e.faciliteit_id
  AND d.maand_nr = e.maand_nr

)                                                                                                                                                                                                                                     e
ON a.franchise_nemer_bc_nr = e.bc_nr
AND e.maand_nr = (SELECT MAX(Maand_nr)  Maand_nr FROM mi_cmb.CIF_complex)

GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29;



INSERT INTO MI_CMB_UIA.Z_MSTR_EIBKredieten_NE
SELECT
      a.maand_nr
    , current_date
    , a.contract_nr
    , a.hoofdrekening  ACBS_hfd_rek
    , a.fac_bc_nr
    , a.datum_ingang  datum_acceptatie_offerte
    , a.verwachte_verval_datum  einddatum
    , a.datum_uiterste_opname
    , j.datum_renteherziening
    , a.muntcode
    , case when a.fac_product_adm_id <> '-1' then right(a.fac_product_adm_id,3) else null end  krediet_soort_code
    , coalesce(a.fac_product_adm_oms, a.fac_product_oms)  EIB_omschrijving
    , coalesce(c.klant_nr, -101)  klant_nr
    , c.bc_naam  clientnaam
    , c.clientgroep  cgc
    , c.segment  segment
    , c.CCA
    , coalesce(c.Relatiemanager, 'Onbekend')  Relatiemanager
    , coalesce(c.org_niveau2, 'Onbekend')  org_niveau2
    , coalesce(c.org_niveau1, 'Onbekend')  org_niveau1
    , a.oorspronkelijk_leenbedrag
    , a.aflopend_opgenomen
    , j.referentie_tarief_id
    , j.referentie_tarief_oms
    , j.rente_var_type
    , j.rente_pct
    , j.basis_pct
    , j.opslag_pct
FROM (
  select
      a.maand_nr
    , a.master_faciliteit_id
    , a.faciliteit_id
    , a.fac_cif_ind
    , CAST(to_number(a.hoofdrekening, '9999999999')  DECIMAL(11,0))  hoofdrekening
    , CAST(to_number(a.contract_nr, '9999999999')  DECIMAL(11,0))  contract_nr
    , a.fac_bo_nr_beheer_acbs
    , a.pl_npl_type
    , a.fac_bc_nr
    , a.fac_bc_ucr
    , a.fac_bc_crg
    , a.fac_product_adm_oms
    , a.fac_product_adm_id
    , a.fac_product_oms
    , a.fac_product_id
    , a.fiat_instantie_code
    , a.fiat_instantie_oms
    , a.muntcode
    , a.OOE
    , a.doorlopend_limiet  krediet_limiet
    , a.doorlopend_saldo  KR_positie
    , a.aflopend_saldo  Saldo_ML
    , a.datum_revisie
    , a.datum_ingang
    , a.verwachte_verval_datum
    , a.datum_uiterste_opname
    ,a.oorspronkelijk_leenbedrag
    ,a.aflopend_opgenomen
  from mi_cmb.cif_complex a

  WHERE a.Fac_actief_ind = 1
    and a.ooe <> 0
    AND a.Maand_nr = (SELECT MAX(Maand_nr)  Maand_nr FROM mi_cmb.vCIF_complex)
    and (a.fac_product_adm_oms like '%EIB%' OR a.fac_product_oms like '%EIB%')
) a

LEFT JOIN mi_cmb.vmia_businesscontacts  c
ON c.business_contact_nr=a.fac_bc_nr
AND c.lopende_maand_ind=1

LEFT JOIN mi_vm_ldm.aSegment_klant   d
   ON d.Party_id = a.fac_bc_nr
  AND d.Party_sleutel_type = 'BC'
  AND d.Segment_type_code = 'CG'

LEFT JOIN (
  SELECT
        a.maand_nr
      , a.contract_nr
      , a.master_faciliteit_id
      , a.faciliteit_id
      , max(case when b.ind_special = 0 then a.datum_renteherziening else null end)  datum_renteherziening
      , max(case when b.ind_special = 0 then a.rente_pct else null end)  rente_pct
      , max(case when b.ind_special = 0 then a.basis_pct else null end)  basis_pct
      , max(case when b.ind_special = 0 then a.opslag_pct else null end)  opslag_pct
      , max(case when b.ind_special = 0 then a.rente_var_type
                 when b.aantal_verschillende_rente_types > 1 and max_aantal_zelfde_rente_type > 1 then 'gemengde rente types + bandbreedtes'
                 when b.aantal_verschillende_rente_types > 1 then 'gemengde rente types'
                 when b.max_aantal_zelfde_rente_type > 1 then 'bandbreedtes'
                 else null end)  rente_var_type
      , max(case when b.ind_special = 0 then a.rente_herzienings_freq else null end)  rente_herzienings_freq
      , max(case when b.ind_special = 0 then a.referentie_tarief_id else null end)  referentie_tarief_id
      , max(case when b.ind_special = 0 then a.referentie_tarief_oms else null end)  referentie_tarief_oms

  from mi_cmb.cif_interest a

  left join (
    select
          a.maand_nr, a.contract_nr, a.master_faciliteit_id, a.faciliteit_id
        , case when a.aantal_verschillende_rente_types > 1 or a.max_aantal_zelfde_rente_type > 1 then 1 else 0 end  ind_special
        , a.aantal_verschillende_rente_types
        , a.max_aantal_zelfde_rente_type
    from (
      select maand_nr, contract_nr, master_faciliteit_id, faciliteit_id, count(*)  aantal_verschillende_rente_types, max(aantal_zelfde_rente_type)  max_aantal_zelfde_rente_type
      from (
        select maand_nr, contract_nr, master_faciliteit_id, faciliteit_id, rente_var_type, count(*)  aantal_zelfde_rente_type
        from mi_cmb.cif_interest h
        where h.actief_ind = 1
        group by 1,2,3,4,5
      ) a
      group by 1,2,3,4
    ) a
  ) b
  on a.master_faciliteit_id = b.master_faciliteit_id
  and a.faciliteit_id = b.faciliteit_id
  and a.maand_nr = b.maand_nr
  where a.actief_ind = 1
  group by 1,2,3,4
) j
 on a.maand_nr = j.maand_nr and a.master_faciliteit_id = j.master_faciliteit_id and a.faciliteit_id = j.faciliteit_id

GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28;




INSERT INTO MI_CMB_UIA.Z_MSTR_IC_RekeningOverzicht
SELECT
        a.maand_nr
FROM  mi_cmb.vmia_businesscontacts    a
LEFT JOIN   mi_cmb.vCRM_CST_Member_week       z
  ON z.Klant_nr = a.Klant_nr
INNER JOIN mi_vm_ldm.aparty_Contract    d
   ON d.party_id=a.business_contact_nr
  AND d.party_sleutel_type='BC'
  AND d.contract_soort_code=5
  AND d.party_contract_rol_code='C'
JOIN mi_vm_ldm.aContract  dd
  ON dd.contract_nr=d.contract_nr
 AND dd.contract_hergebruik_volgnr=d.contract_hergebruik_volgnr
 AND dd.Contract_soort_code=d.contract_soort_code
 AND dd.Contract_status_code <> 3
 AND dd.herkomst_admin_key_soort_code='GRV'
LEFT JOIN
  (
     SELECT
       contract_nr
       , MAX(iban)  IBAN
     FROM mi_vm_ldm.acontract_iban
     GROUP BY 1
   ) E
  ON d.contract_nr=e.contract_nr
LEFT JOIN (
  select
     CAST(to_number(a.hoofdrekening, '9999999999')  DECIMAL(11,0))  hoofdrekening
     , CAST(to_number(b.draw_contract_nr , '9999999999')  DECIMAL(11,0))  contract_nr
  FROM mi_cmb.cif_complex a
  left join mi_cmb.cif_drawing b
  on a.faciliteit_id = b.faciliteit_id
  and a.maand_nr = b.maand_nr
  where (1=1)
    and a.maand_nr = (SELECT max(maand_nr) from mi_cmb.cif_complex)
    and a.limiet_type = 'Non Loan Limit'
    and a.fac_actief_ind = 1
  group by 1,2
) F
ON f.contract_nr = d.contract_nr
LEFT JOIN Mi_vm_ldm.aPARTY_POST_ADRES h
  ON a.business_contact_nr=h.party_id
 AND h.party_sleutel_type='BC'
LEFT JOIN
(
  SELECT a.party_id  bc_nr, TRIM(TRIM(a.Naamregel_1) || ' ' || TRIM(a.Naamregel_2) || ' ' || TRIM(a.Naamregel_3))  naam
  FROM MI_vm_ldm.aparty_naam a
  WHERE a.party_sleutel_type='BC'
) i
ON a.business_contact_nr=i.bc_nr
LEFT JOIN mi_vm_ldm.arente_comp_koppeling               L
  ON l.contract_nr=d.contract_nr
LEFT JOIN mi_vm_ldm.arente_comp_koppeling               M
  ON m.hoofdrekeningnr=l.hoofdrekeningnr
 AND m.code_compensatie=5
LEFT JOIN
  (
    SELECT
      contract_nr
      , MAX(iban)  IBAN_hfd_rek
    FROM mi_vm_ldm.acontract_iban
    GROUP BY 1
  ) O
ON f.hoofdrekening=o.contract_nr

LEFT JOIN mi_vm_ldm.acrc_account     Q
ON d.contract_nr=q.contract_nr
and d.contract_soort_code = q.contract_soort_code

LEFT JOIN mi_cmb.mia_kredieten_LD052_BO_IC   x
  ON a.bc_bo_nr=x.BO_Number

LEFT JOIN mi_cmb.vmia_week y
on a.maand_nr = y.maand_nr
and a.klant_nr = y.klant_nr

LEFT JOIN (
    select w.contract_nr, v.sequence_id, v.target_account, v.main_account, w.product_id, x.product_naam_extern
    from mi_vm_ldm.acontract w

    left join mi_vm_ldm.aproduct x
    on w.product_id = x.product_id

    left join mi_vm_ldm.adz_balance_rule v
    on w.contract_nr = v.contract_nr

    where v.contract_soort_code = 135
    and v.version = 'A' and v.status = 'E'
    -- and x.product_id in (669, 2888)
    and w.contract_status_code <> 3
        and current_date between v.start_date and v.end_date
    group by 1,2,3,4,5,6
) v
on d.contract_nr = v.target_account

WHERE a.lopende_maand_ind=1
and ((coalesce(a.business_line,a.bc_business_line) = 'CIB')
      or (x.BO_number IS NOT NULL)
      or (a.bc_clientgroep = 2116))

GROUP BY 1,2,3,4,5,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25, 26 ,27,28 ,29,30,31,32,33,34,35,36,37,38;


INSERT INTO MI_CMB_UIA.Z_MSTR_RENTEHERZ
SELECT
a.Maand_nr
, current_date  datum_gegevens
, coalesce(e.klant_nr, -101)  klant_nr
, coalesce(e.verkorte_naam, 'Onbekend')  naam_klant
, 4  signaal_nr
, (coalesce(b.datum_renteherziening, b.einddatum_lening) - current_date) MONTH(4)  verschil
, case verschil when 2 then 'groen' when 1 then 'oranje' else 'rood' end  signaal
, 0  solved
, a.Fac_BO_nr_beheer_acbs  BO_nr_beheer_ACBS
, c.bo_naam
, e.business_line
, e.org_niveau1
, e.org_niveau2
,  e.org_niveau3 --  case when e.org_niveau1 = 'SME' then f.org_niveau3 else e.org_niveau3 end  org_niveau3
, e.CCA
, e.relatiemanager
, a.bijzonder_beheer_ind
, a.fiat_instantie_code
, a.hoofdrekening
, b.contract_nr
, coalesce(a.fac_product_adm_oms, a.fac_product_oms)  krediet_soort_oms
, a.muntcode  valuta
, a.oorspronkelijk_leenbedrag
, coalesce(b.datum_renteherziening, b.einddatum_lening)  datum_renteherziening
, a.verwachte_verval_datum  einddatum
FROM mi_cmb.cif_complex a
INNER JOIN (
	SELECT 	a.*, b.description  fixed_ref_tarief_oms, c.description  variable_ref_tarief_oms
	from (
		SELECT b.maand_nr, b.master_faciliteit_id , b.faciliteit_id , b.contract_nr
		, MIN(b.datum_renteherziening)  datum_renteherziening, MIN(b.einddatum_lening)  einddatum_lening
		, MAX(case when b.rente_var_type = 'Fixed Rate' then 1 else 0 end)  fixed_part
		, MAX(case when b.rente_var_type = 'Variable Rate' then 1 else 0 end)  variable_part
		, MAX(case when b.rente_var_type = 'Fixed Rate' then b.referentie_tarief_id end)  fixed_ref_tarief_id
		, MAX(case when b.rente_var_type = 'Variable Rate' then b.referentie_tarief_id end)  variable_ref_tarief_id
		FROM mi_cmb.cif_Interest b
		where b.Actief_ind = 1
		GROUP BY 1,2,3,4
	) a
	LEFT JOIN mi_cmb.cif_lu_interestRate b
	on a.fixed_ref_tarief_id = b.code
	LEFT JOIN mi_cmb.cif_lu_interestRate c
	on a.variable_ref_tarief_id = c.code
	) b
	on a.maand_nr = b.maand_nr and a.master_faciliteit_id = b.master_faciliteit_id and a.faciliteit_id = b.faciliteit_id
LEFT JOIN MI_VM_LDM.vBO_MI_Part_Zak c
ON a.Fac_BO_nr_beheer_acbs = c.bo_nr
LEFT JOIN mi_cmb.vmia_klantkoppelingen_hist d
ON d.Business_contact_nr=a.fac_bc_nr AND d.maand_nr=a.maand_nr
LEFT JOIN mi_cmb.vmia_hist e
ON e.klant_nr=d.klant_nr AND e.maand_nr=d.maand_nr
LEFT JOIN Mi_cmb.vPc_commercial_banking f
ON left(e.postcode,4) = f.pc4 (FORMAT '9999')(CHAR(4))
WHERE  (1=1)
AND a.maand_nr = (select max(maand_nr) from mi_cmb.cif_complex)
AND a.verwachte_verval_datum> current_date
AND (coalesce(b.datum_renteherziening, b.einddatum_lening) <=  add_months(current_date, 3) )
AND a.fac_actief_ind  = 1
and a.ooe <> 0
and (not a.fac_product_adm_oms like any ('%roll%', '%revolv%' ,'%eur%')	or a.fac_product_adm_oms is null)
and b.fixed_part = 1
and b.variable_part = 0;

INSERT INTO MI_CMB_UIA.Z_MSTR_AFLOPENDE_LENINGEN
SELECT
b.Maand_nr
, current_date  datum_gegevens
, coalesce(c.klant_nr, -101)  klant_nr
, coalesce(c.verkorte_naam, 'Onbekend')  naam_klant
, 5  signaal_nr
, (a.verwachte_verval_datum - current_date) MONTH(4)  verschil
, case when verschil > 4 then 'groen'
       when verschil > 2 then 'oranje'
       else 'rood' end  signaal
, 0  solved
, CAST(to_number(a.contract_nr , '9999999999')  DECIMAL(11,0))  lening_nr
, a.aflossing_type
, CAST(to_number(a.hoofdrekening, '9999999999')  DECIMAL(11,0))   hoofdrekening
, CAST(to_number(a.fac_bc_nr, '999999999999')  DECIMAL(12,0))  bc_nr
, b.bc_naam  naam
, coalesce(d.segment, d.business_segment)  segment_klant
, coalesce(c.cca, b.Bc_cca_am, b.Bc_cca_rm) cca
, coalesce(c.relatiemanager,xa.naam_volledig) nca
, COALESCE(c.bo_nr,b1.bo_nr) -- bo_nr
, COALESCE(c.bo_naam,b1.bo_naam) -- bo_naam
, c.org_niveau1  --  org_niveau1
, c.org_niveau2
, c.org_niveau3
, a.muntcode

, case when h.datum_renteherziening is not null then h.datum_renteherziening else a.verwachte_verval_datum end (FORMAT'yyyymm') (CHAR(6))  maand_RH
, case when h.datum_renteherziening is not null then h.datum_renteherziening else a.verwachte_verval_datum end  datum_renteherziening
, a.datum_ingang  startdatum
, a.verwachte_verval_datum  einddatum_contract
, coalesce(a.fac_product_adm_oms, fac_product_oms) lening_oms

, h.rente_pct
, h.basis_pct
, h.opslag_pct
, h.rente_var_type
, h.rente_herzienings_freq

, h.referentie_tarief_id
, h.referentie_tarief_oms

, e.periode_sdat  aflosdatum
, e.aflos_gepland_volume
, a.oorspronkelijk_leenbedrag
, a.aflopend_opgenomen
, a.aflopend_opgenomen - SUM(e.aflos_gepland_volume) OVER (PARTITION BY a.contract_nr, RENTE_VAR_TYPE ORDER BY h.rente_var_type, e.periode_sdat ROWS UNBOUNDED PRECEDING)  pro_resto

FROM mi_cmb.cif_complex a

LEFT JOIN mi_cmb.vmia_businesscontacts b
ON a.fac_bc_nr=b.business_contact_nr

LEFT JOIN mi_vm_ldm.vbo_mi_part_zak b1
ON a.fac_bo_nr_beheer_acbs=b1.bo_nr

LEFT JOIN mi_cmb.vmia_hist c
ON b.klant_nr=c.klant_nr AND b.maand_nr=c.maand_nr

LEFT JOIN mi_cmb.vCGC_BASIS d
ON b.bc_clientgroep = d.Clientgroep

LEFT JOIN mi_vm_nzdb.vmedewerker xa
on coalesce(c.cca, b.Bc_cca_am, b.Bc_cca_rm) = xa.Adviseur
and xa.maand=(SELECT MAX(maand)  huidige_maand
FROM mi_vm_nzdb.vmedewerker)

LEFT JOIN mi_cmb.cif_loan_positie e
on a.hoofdrekening = e.hoofdrekening
and a.master_faciliteit_id = e.master_faciliteit_id
and a.faciliteit_id = right(e.faciliteit_id,10)
and extract(year from (e.periode_sdat + 3)) * 100 + extract(month from (e.periode_sdat+3)) > (SELECT MAX(maand_nr) FROM mi_cmb.cif_complex)

LEFT JOIN (
	SELECT
	a.maand_nr
	, a.contract_nr
	, a.master_faciliteit_id
	, a.faciliteit_id
	, max(case when b.ind_special = 0 then a.datum_renteherziening else null end)  datum_renteherziening
	, max(case when b.ind_special = 0 then a.rente_pct else null end)  rente_pct
	, max(case when b.ind_special = 0 then a.basis_pct else null end)  basis_pct
	, max(case when b.ind_special = 0 then a.opslag_pct else null end)  opslag_pct
	, max(case when b.ind_special = 0 then a.rente_var_type
	           when b.aantal_verschillende_rente_types > 1 and max_aantal_zelfde_rente_type > 1 then 'gemengde rente types + bandbreedtes'
			   when b.aantal_verschillende_rente_types > 1 then 'gemengde rente types'
			   when b.max_aantal_zelfde_rente_type > 1 then 'bandbreedtes'
			   else null end)  rente_var_type
	, max(case when b.ind_special = 0 then a.rente_herzienings_freq else null end)  rente_herzienings_freq
	, max(case when b.ind_special = 0 then a.referentie_tarief_id else null end)  referentie_tarief_id
	, max(case when b.ind_special = 0 then a.referentie_tarief_oms else null end)  referentie_tarief_oms
	from mi_cmb.cif_interest a
	left join (
		select a.maand_nr, a.contract_nr, a.master_faciliteit_id, a.faciliteit_id
		, case when a.aantal_verschillende_rente_types > 1 or a.max_aantal_zelfde_rente_type > 1 then 1 else 0 end  ind_special
		, a.aantal_verschillende_rente_types
		, a.max_aantal_zelfde_rente_type
		from (
			select maand_nr, contract_nr, master_faciliteit_id, faciliteit_id, count(*)  aantal_verschillende_rente_types, max(aantal_zelfde_rente_type)  max_aantal_zelfde_rente_type
			from (
				select maand_nr, contract_nr, master_faciliteit_id, faciliteit_id, rente_var_type, count(*)  aantal_zelfde_rente_type
				from mi_cmb.cif_interest h
				where h.actief_ind = 1
				group by 1,2,3,4,5
			) a
			group by 1,2,3,4
		) a
	) b
	on a.master_faciliteit_id = b.master_faciliteit_id
	and a.faciliteit_id = b.faciliteit_id
	and a.maand_nr = b.maand_nr
	where a.actief_ind = 1
	group by 1,2,3,4
) h
on a.maand_nr = h.maand_nr and a.master_faciliteit_id = h.master_faciliteit_id and a.faciliteit_id = h.faciliteit_id

WHERE
 (a.aflopend_saldo NE 0 OR a.fac_actief_ind EQ 1)
AND b.bc_clientgroep LT 1299
AND a.limiet_type = 'Loan limit'
AND a.verwachte_verval_datum LT (ADD_MONTHS(DATE,12) - (EXTRACT(DAY FROM DATE)-1))
AND a.verwachte_verval_datum GT CURRENT_DATE
AND a.maand_nr=(SELECT MAX(maand_nr) FROM mi_cmb.cif_complex)
and (a.fac_product_adm_oms is not null)
AND a.contract_nr is not null;


INSERT INTO MI_CMB_UIA.Z_UITFASEREN_CHEQUE
select
		a.clientnummer,
		a.BC_number,
		a.Billing_Period  maand_nr,
		a.chequeType,
		a.cheque_munt_orig,
	    COALESCE(b.Klant_nr, -101 )  Klant_nr,
		CASE WHEN b.Bc_Business_segment IN ('Retail', 'PB') THEN b.bc_naam ELSE b.Klant_naam END  Klant_naam,
		b.Business_contact_nr,
		b.Bc_Business_segment,

		CASE WHEN b.Bc_Business_segment = 'Retail' THEN 'Retail'
					WHEN b.Bc_Business_segment = 'PB' THEN 'PB'
					ELSE b.Business_line END,

		CASE WHEN b.Bc_Business_segment = 'Retail' THEN 'Retail'
					WHEN b.Bc_Business_segment = 'PB' THEN 'PB'
		ELSE b.Segment END,

		CASE WHEN b.Bc_Business_segment = 'Retail' THEN 'Retail'
					WHEN b.Bc_Business_segment = 'PB' THEN 'PB'
		ELSE b.Org_niveau1 END,
		CASE WHEN b.Bc_Business_segment = 'Retail' THEN 'Retail'
				WHEN b.Bc_Business_segment = 'PB' THEN 'PB'
		ELSE b.Org_niveau2 END,

		cASE WHEN b.Bc_Business_segment = 'Retail' THEN 'Retail'
					WHEN b.Bc_Business_segment = 'PB' THEN 'PB'
		ELSE b.Org_niveau3 END,

		COALESCE( c.Naam, 'Onbekend')  Consultant,
		A.ISOLNDCODE_DEB ,
		count(*)  Tot_Aantal,
		sum(a.bedrag_in_EUR)  Tot_Bedrag_EUR,
		sum(a.cheque_bedrag_orig)  Tot_bedrag_orig,
		sum(a.prov_werkelijk)  Tot_Provisie

from MI_cmb.TB_Cheques a
left join mi_cmb.vmia_businesscontacts b on (a.BC_number = b.Business_contact_nr)
left join MI_SAS_AA_MB_C_MB.Siebel_CST_Member_hist c
		on b.Klant_nr= c.klant_nr
			and c.maand_nr = b.Maand_nr
			and c.tb_consultant = 'y'

where b.Bc_Business_segment is not null
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16;



COLLECT STATISTICS  MI_CMB_UIA.Z_UITFASEREN_CHEQUE COLUMN (maand_nr, clientnummer);
COLLECT STATISTICS  MI_CMB_UIA.Z_UITFASEREN_CHEQUE COLUMN (Maand_nr, BC_number);
COLLECT STATISTICS  MI_CMB_UIA.Z_UITFASEREN_CHEQUE COLUMN (Maand_nr, chequeType);
COLLECT STATISTICS  MI_CMB_UIA.Z_UITFASEREN_CHEQUE COLUMN (clientnummer);
COLLECT STATISTICS  MI_CMB_UIA.Z_UITFASEREN_CHEQUE COLUMN (BC_number);
COLLECT STATISTICS  MI_CMB_UIA.Z_UITFASEREN_CHEQUE COLUMN (chequeType);




INSERT INTO MI_CMB_UIA.Z_DIS_BSS
select
TRIM(a.party_id)
,TRIM(b.bc_validatieniveau)
, TRIM(b.Bc_bo_nr)
,TRIM(d.naw_regel1), TRIM(d.naw_regel2), TRIM(d.naw_regel3), TRIM(d.naw_regel4), TRIM(d.naw_regel5), TRIM(d.naw_regel6), TRIM(d.Land_geogr_id)
,TRIM(c.naw_regel1), TRIM(c.naw_regel2), TRIM(c.naw_regel3), TRIM(c.naw_regel4), TRIM(c.naw_regel5), TRIM(c.naw_regel6), TRIM(c.Land_geogr_id)
,TRIM(NULL)  Tax
,TRIM(Bc_verschijningsvorm), TRIM(Bc_verschijningsvorm_oms), TRIM(Bc_clientgroep),
TRIM(Bc_kvk_nr), TRIM(Bc_relatiecategorie)  relatiecategorie, TRIM(b.Sbi_code),
TRIM(kvk_branche_code), TRIM(Bc_Risico_score),
TRIM(f.revisie_datum), TRIM(cca),
TRIM(AK.Segment_id)  ringfence_code,
TRIM(Bc_ringfence),
TRIM(a.party_start_datum),
TRIM(b.Trust_complex_nr)  trust_complex_leider,
TRIM(b.Leidend_business_contact_nr), TRIM(B.koppeling_id_CE),
TRIM(B.klant_nr)
from mi_vm_ldm.aparty a
inner join mi_cmb.vmia_businesscontacts b
on a.party_id = b.business_contact_nr
and a.party_sleutel_type = 'BC'
left join MI_VM_Ldm.aPARTY_POST_ADRES  c
on c.party_id = a.party_id
and a.party_sleutel_type = c.party_sleutel_type
and a.party_hergebruik_volgnr = c.party_hergebruik_volgnr
and a.party_sleutel_type = 'BC'
left join MI_VM_Ldm.aParty_officieel_adres  d
on d.party_id = a.party_id
and a.party_sleutel_type = d.party_sleutel_type
and a.party_hergebruik_volgnr = d.party_hergebruik_volgnr
and a.party_sleutel_type = 'BC'
left join MI_VM_Ldm.	aKLANT_PROSPECT            f
on f.party_id = a.party_id
and a.party_sleutel_type = f.party_sleutel_type
and a.party_hergebruik_volgnr = f.party_hergebruik_volgnr
and a.party_sleutel_type = 'BC'
left join Mi_vm_nzdb.vCoci_denorm XC
on b.bc_kvk_nr = XC.kvk_nr
and XC.maand_nr = b.maand_nr
LEFT OUTER JOIN (SELECT XA.Party_id, XA.Party_sleutel_type, party_hergebruik_volgnr, XA.Segment_id, XB.Segment_oms
                     FROM Mi_vm_ldm.aSegment_klant XA
                     LEFT OUTER JOIN Mi_vm_ldm.aSegment XB
                       ON XA.Segment_Id = XB.Segment_Id
                      AND XA.Segment_Type_Code = XB.Segment_Type_Code
                    WHERE XA.Segment_type_code = 'RIFENC'
					) AK
     ON A.Party_id = AK.Party_id
    AND A.Party_sleutel_type = AK.Party_sleutel_type
	and a.party_hergebruik_volgnr = AK.party_hergebruik_volgnr
where b.bc_bo_nr IN (542316,542388,542326,542373,534690,539014,534692,542347)
and a.party_sleutel_type = 'BC'
and relatiecategorie <> 20
;

INSERT INTO  MI_CMB_UIA.Z_vVVB_selectie_CB
SELECT
    Business_contact_nr
FROM MI_CMB.vVVB_Selectie_Workflow_Hist;
CREATE TABLE Mi_temp.ALM_periode_Rap
AS
(
SELECT
     a.Maand_actueel
    ,a.Maand_voorgaand
    ,b.Maand_edat  Maand_actueel_edat
    ,c.Maand_edat  Maand_voorgaand_edat
    ,a.MaandNrL3m   MaandNrL3m

    ,b.MaandNrLY   MaandNrL12m
FROM
     (
     SEL
          MAX(CASE WHEN Maand_1 = 1 THEN Maand_nr ELSE NULL END)  Maand_actueel
         ,MAX(CASE WHEN Maand_2 = 1 THEN Maand_nr ELSE NULL END)  Maand_voorgaand
         ,MAX(CASE WHEN Maand_3 = 1 THEN Maand_nr ELSE NULL END)  MaandNrL3m
     FROM
          (SEL
                maand_nr
               ,CASE WHEN RANK() OVER (ORDER BY maand_nr DESC) = 1 THEN 1 ELSE 0 END  Maand_1
               ,CASE WHEN RANK() OVER (ORDER BY maand_nr DESC) = 2 THEN 1 ELSE 0 END  Maand_2
               ,CASE WHEN RANK() OVER (ORDER BY maand_nr DESC) = 3 THEN 1 ELSE 0 END  Maand_3
          FROM Mi_cmb.vALM_contract
          GROUP BY 1
          ) a
     ) a

INNER JOIN  Mi_vm.vlu_maand  b
   ON b.Maand = a.Maand_actueel

INNER JOIN  Mi_vm.vlu_maand  c
   ON c.Maand = a.Maand_voorgaand

) WITH DATA
UNIQUE PRIMARY INDEX (Maand_actueel)
INDEX (Maand_voorgaand)
INDEX (Maand_actueel, Maand_voorgaand);


INSERT INTO MI_CMB_UIA.Z_Lending_ALM
SELECT
a.Klant_nr,
a.Maand_nr,
a.BC_nr,
COALESCE(a.Contract_nr,-101),
COALESCE(a.Contract_volgnr,-101),
COALESCE(a.Debet_credit_ind,0),
COALESCE(a.Rentevast_periode_sdat, DATE '1900-01-01'),
COALESCE(a.Rentevast_periode_edat, DATE '1900-01-01'),
COALESCE(a.Rentevast_periode,-101),
COALESCE(a.Contract_Ingang_datum, DATE '1900-01-01'),
COALESCE(a.Ind_lening_1e_opname_na_ingang,0),
COALESCE(a.Contract_Eind_datum,DATE '1900-01-01'),
a.Limiet_bedrag,
COALESCE(a.Limiet_sdat,DATE '1900-01-01'),
COALESCE(a.Administratie,'Onb'),
COALESCE(a.Eigenaar,'Onbekend'),
COALESCE(a.Product,'Onbekend'),
COALESCE(a.Report,'Onbekend'),
COALESCE(a.Soort,'Onbekend'),
COALESCE(a.Label,'Onbekend')
FROM mi_sas_aa_mb_c_mb.ALM_contract                                                                                                                         a
LEFT JOIN mi_cmb.vmia_hist                                                                                                                                                 b
ON a.maand_nr = b.maand_nr
AND a.klant_nr = b.klant_nr
LEFT JOIN  MI_CMB.Z_Lending_ALM_hulpMSTR                                                                                                             c
ON a.Maand_nr = c.maand_nr
AND COALESCE(a.Contract_nr,-101) = c.contract_nr
LEFT JOIN
(SELECT Maand_nr, contract_nr, limiet_type, fac_product_adm_id, fac_product_adm_oms, fac_product_oms, fiat_instantie_code, MAX(CIF_Complex.Kredietsoort_ISK_ind)  Kredietsoort_ISK_ind-- purpose_code
, MAX(CIF_Complex.Kredietsoort_BSK_ind)  Kredietsoort_BSK_ind, MAX(fac_bc_ucr)  fac_bc_ucr
FROM mi_cmb.CIF_Complex
WHERE LENGTH(TRIM(contract_nr)) = 10
AND TRIM(contract_nr) IS NOT NULL
GROUP BY 1,2,3,4,5,6,7)                                                                                                                                                                  D    -- extra kolommen toegevoegd door Victor
ON D.contract_nr = a.contract_nr
AND D.maand_nr = a.maand_nr
LEFT JOIN
(SELECT contract_nr, herkomst_administratie_key  GRV
FROM MI_VM_Ldm.aCONTRACT
WHERE herkomst_admin_key_soort_code = 'GRV'
)                                                                                                                                                                                                     e
ON a.contract_nr = e.contract_nr
LEFT OUTER JOIN (
          SELECT contract_nr
              ,CASE WHEN referentie_tarief_id = '' THEN NULL
                  WHEN referentie_tarief_id IN ('RI003', 'RI004', 'RI005', 'RI006', 'RI007', 'RI008', 'RI009', 'RI010') THEN 'MLL_var_3-mnd_fix'
                  WHEN referentie_tarief_id IN ('RI012', 'RI013') THEN 'MLL_Flex_Rente'
                  ELSE 'MLL_var_Overig' END  label_plus_1
            ,CASE WHEN referentie_tarief_id IN ('RI003', 'RI004', 'RI005', 'RI006') THEN 'met demping'
                  WHEN referentie_tarief_id IN ('RI007', 'RI008', 'RI009', 'RI010') THEN 'zonder demping' ELSE NULL END  Label_plus_2
                , NULL  Label_plus_3
--            ,CASE WHEN referentie_tarief_id IN ('RI003', 'RI004', 'RI005', 'RI006', 'RI007', 'RI008', 'RI009', 'RI010') THEN referentie_tarief_id || ' - ' || referentie_tarief_oms ELSE NULL END  code
                ,referentie_tarief_id || ' - ' || referentie_tarief_oms  Code
            ,CASE WHEN aantal > 1 THEN
                  CASE WHEN ind_several_tarief_ids > 1 AND ind_several_rente_var_types > 1 THEN ind_several_tarief_ids || ' tarieven,' || ind_several_rente_var_types || ' rente types'
                   WHEN ind_several_tarief_ids > 1 THEN ind_several_tarief_ids || ' tarieven'
                   WHEN ind_several_rente_var_types > 1 THEN ind_several_rente_var_types || ' rente types'
                   ELSE 'Niet gecategoriseerd issue' END
             ELSE NULL END  ind_DQ_issue
          FROM
          (
                 SELECT a.maand_nr, a.contract_nr, a.referentie_tarief_id, a.referentie_tarief_oms
                 , b.aantal
                 , b.ind_several_tarief_ids
                 , b.ind_several_rente_var_types
             FROM (
                  SELECT Maand_nr, contract_nr, referentie_tarief_id, referentie_tarief_oms
                  FROM mi_cmb.CIF_Interest a
                  INNER JOIN Mi_temp.ALM_periode_Rap mnd
                  ON mnd.Maand_actueel = a.Maand_nr
                  WHERE Actief_ind = 1
                              AND LEFT(TRIM(referentie_tarief_id),2) = 'RI'
                  QUALIFY RANK() OVER (PARTITION BY contract_nr ORDER BY referentie_tarief_id) = 1

                  GROUP BY 1,2,3,4
             )                                                                                                                                                                                                 a
             INNER JOIN
                         (
                  SELECT Maand_nr, contract_nr
                  , COUNT(*)  aantal
                  , COUNT(DISTINCT referentie_tarief_id)  ind_several_tarief_IDs
                  , COUNT(DISTINCT rente_var_type)  ind_several_rente_var_types
                  FROM
                  (
                  SELECT Maand_nr, contract_nr
                  , CASE WHEN LEFT(TRIM(referentie_tarief_id),2) = 'RI' THEN referentie_tarief_id
                         ELSE NULL END  referentie_tarief_id
                  , CASE WHEN rente_var_type = '' THEN NULL
                         WHEN rente_var_type IS NOT NULL THEN rente_var_type
                         ELSE NULL END  rente_var_type
                  FROM
                  mi_cmb.CIF_Interest a
                  WHERE Actief_ind = 1
                  GROUP BY 1,2,3,4
                   ) a
                   INNER JOIN Mi_temp.ALM_periode_Rap mnd
                       ON mnd.Maand_actueel = a.Maand_nr
                   GROUP BY 1,2
              ) b
              ON a.contract_nr = b.contract_nr
              AND a.maand_nr = b.maand_nr
          ) a
      ) a2
      ON a.Contract_nr = a2.contract_nr
      LEFT OUTER JOIN (
             SELECT contract_nr
              ,CASE     WHEN rentecode_RC IS NULL THEN NULL
                        WHEN rentecode_RC IN (1,12) THEN 'Fix'
                        WHEN rentecode_RC IN (8,9,11,13) THEN 'Pakket'
                        WHEN rentecode_RC IN (21,23,26,27,28,35, 22,24,33,34, 2,6,10, 29,30, 31,32) THEN 'Rentebasis icm generieke toeslag'
                        ELSE 'Rentebasis zonder generieke toeslag' END  Label_plus_1
              ,CASE     WHEN rentecode_RC IN (29,30) THEN 'USD'
                        WHEN rentecode_RC IN (31,32) THEN 'GBP'
                        WHEN rentecode_RC IN (21,23,26,27,28,35, 22,24,33,34, 2,6,10) THEN 'Eur'
                        WHEN rentecode_RC IN (3,7,17,18,25,4) THEN 'EUR'
                        WHEN rentecode_RC IS NOT NULL THEN
                             CASE WHEN valuta NOT IN ('USD', 'GBP') THEN 'Other' ELSE valuta END
                        ELSE NULL end  Label_plus_2
              ,CASE     WHEN rentecode_RC IS NULL THEN NULL
                        WHEN rentecode_RC IN (21,23,26,27,28,35) THEN 'Euribor+'
                        WHEN rentecode_RC IN (22,24,33,34) THEN 'Eonia+'
                        WHEN rentecode_RC IN (2,6,10) THEN 'AAEBR'
                        WHEN rentecode_RC IN (29,30) THEN 'Libor+ USD'
                        WHEN rentecode_RC IN  (31,32) THEN 'Libor+ GBP'
                        WHEN rentecode_RC IN (3,7,17,18,25) THEN 'Euribor - kaal'
                        WHEN rentecode_RC IN (4) THEN 'Eonia - kaal'
                        WHEN valuta = 'USD' THEN 'Libor USD - kaal'
                        WHEN valuta = 'GBP' THEN 'Libor GBP - kaal'
                        ELSE 'Libor-other - kaal' END  Label_plus_3
            , rentecode_RC || ' - ' || ( CASE WHEN b.Description IS NULL THEN 'Onbekend' ELSE b.Description END )  Code
            , CASE WHEN aantal > 1 THEN 'meerdere rentecodes' END  ind_DQ_issue
             FROM
             (                 SELECT contract_nr
                    , MAX(valuta)  valuta
                    , MAX(rentecode_RC)  rentecode_RC
                    , COUNT(DISTINCT rentecode_RC)  aantal
                FROM MI_SAS_AA_MB_C_MB.ALM_contract    a
                INNER JOIN Mi_temp.ALM_periode_Rap mnd
                ON mnd.Maand_actueel = a.Maand_nr
                WHERE NOT (rentecode_RC IS NULL)
                AND a.soort = 'assets'
                AND a.usedforvalidation = 1
                GROUP BY 1
             ) a
             LEFT JOIN Mi_temp.LU_Rentecode_ALM b
             ON a.rentecode_RC = b.Code
            ) a3
      ON a.Contract_nr = a3.contract_nr
QUALIFY DENSE_RANK() OVER ( ORDER BY a.maand_nr DESC) <= 13;



INSERT INTO MI_CMB_UIA.Z_MSTR_AGRC_MCT
SELECT
Draaidatum
,Maand_nr
,Volgnummer
,Value_Chain
,Control_Responsible_2nd_LoD
, OREPLACE(Business_Structures , '>', '')  Business_Structures -- MOETEN WE AANPASSEN
,Business_Structure_Category
,Business_Structure_Cat_II
,Country_Code
,Control_Name
,Control_ID
,Monitor_Status
,Monitor_Status_Max
,Monitor_Status_Max_II
,Monitor_Status_Due
,Monitor_Status_EndofRep
, CASE   WHEN RAG_Monitor IS NULL THEN 'Open'
                ELSE RAG_Monitor
  END  RAG_Monitor
,Tester_Status
, CASE   WHEN RAG_Tester IS NULL THEN 'Overdue or Open'
                ELSE RAG_Tester
  END  RAG_Tester
,Monitoring_End_of_Reporting
,Monitoring_End_of_Reporting_Q
,MCT_Filter_Qmin2
,Monitor_Due_Date
,Monitor_Answer_Date
,Monitored_by
,Tester_Due_Date
,Tester_Answer_Date
,Tested_by
,CM_Conduct_driver_applicable_
,vMaxCTMDueDate
,vTestStatusNew
,vMonitorStatus
,vMonitorStatusNew
FROM MI_CMB.AGRC_MCT ;


INSERT INTO MI_CMB_UIA.Z_MSTR_AGRC_REM
SELECT
Draaidatum
,Maand_nr
,Volgnummer
,Event_Type
,Event_Type_Cat_1
,Event_Type_Cat_2
,Event_ID
,Input_Date
,Total_Gross_Loss_Plus_EUR
,Total_Net_Loss_Plus_bef_Insur
,Exposure_Amount_EUR
,Business_Structure_Name
,Business_Structure_Category
,Business_Structure_Cat_II
,Geography
,Event_Category
,Cause_category_1
,Workflow_status
,Number_of_incidents
,Short_description
,Long_description
,Steps_Taken
,Event_Creator
,Process
,Product
,Date_of_rec
,Date_of_rec_Year
,Date_of_rec_Month
,Date_of_rec_Quarte_
,Accounting_Date
,Acc_date_Year
,Acc_date_Month
,Acc_date_Quarter
,Provision_Date
,Financial_Status
,Date_of_Discovery
FROM MI_CMB.AGRC_REM
;

INSERT INTO MI_CMB_UIA.Z_MSTR_AGRC_IMAT
SELECT
Draaidatum
,Maand_nr
,Volgnummer
,Business_Structure
,Business_Structure_Category
,Business_Structure_Cat_II
,Level2
,Level3
,Country_Code
,Issue_ID
,Due_in_days
,Due_category
,Level_of_Concern
,Current_Workflow_Step
,Issue_Title
,Issue_Description
,Issue_business_owner
,Risk_Area
,Issue_created_date
,Issue_reg_date_AGRC
,Issue_Revised_Compl_Date
,Action_Plan_ID
,Action_Plan_Name
,Action_plan_desc
,Action_plan_creation_date
,Issue_target_Compl_Review
,Issue_Source
FROM MI_CMB.AGRC_IMAT
;



INSERT INTO MI_CMB_UIA.Z_CTRACK_PORTFOLIO
SELECT
      A.Portfolio_Id ,
      A.Maand_nr ,
	  A.Maand_nr_delivery,
      A.Maand_nr_reporting ,
      A.Business_contact_nr ,
      A.Contract_nr ,
      A.Klant_nr ,
      A.BRR_ID ,
      A.Borrower ,
      A.Borrower_Id ,
      A.ACMA_Naam ,
      A.ACMA_Id ,
      A.Watch_Code ,
      A.Credit_Review_Date ,
      A.CRG_code ,
      A.Prob_Color_Last_month ,
      A.Prob_Color_Last_month_final ,
      A.Proposed_Color_Last_Month ,
      A.Probe_Color ,
      A.OOE ,
      A.Outstanding ,
      A.Portfolio_ind ,
      A.System_Name ,
      A.BO_Nr ,
      A.Business_Unit ,
      A.Business_Unit_Name ,
      A.Business_Line ,
      A.Proposed_Color ,
      A.Final_Color ,
      A.Probe_Del_Date ,
      A.Last_Comment_Date ,
      A.Action ,
      A.Trigger_Remarks ,
      A.Comment_Remarks ,
      A.Action_Remarks ,
      A.Other_Involved ,
      A.Orange_Overdue_Date ,
      A.Basel_Revision_Date ,
      A.Feb_SME_orgnl_ind ,
      A.Orange_TRA_comment_date ,
      A.Comm_ACC_reject ,
      A.TRA_flag ,
      A.Kredietklanten ,
      A.Kleurverlichting_voorgesteld ,
      A.Kleurverlichting_goedgekeurd ,
      A.Kleurverzwaring_handmatig ,
      A.Final_Oranje ,
      A.Final_Rood ,
	  A.Revisieplichtig,
      A.Revisieplichtig_achterstand ,
	  A.Revisies_tijdig ,
      A.UCR_vervallen ,
      A.TRA_in_achterstand ,
      A.Watchbeeindiging_mogelijk ,
      A.Limietoverschrijding ,
	  A.Overdispositie,
      A.Acties_totaal ,
      A.Acties_achterstand
FROM MI_CMB.vCTrack_Portfolio_Hist A
INNER JOIN MI_CMB.vMia_week B   --  born bevat retailklanten. met deze innerjoin de aantallen klanten in ljin brengen met de Mia_week
ON A.klant_nr = B.klant_nr ;




INSERT INTO MI_CMB_UIA.A_Medewerker_Security
SELECT
Datum_gegevens
,SBT_id
,Naam_mdw
,Soort_mdw
,BO_nr_mdw
,BO_naam_mdw
,GM_ind
,Mdw_sdat
,Org_niveau3
,Org_niveau3_bo_nr
,Org_niveau2
,Org_niveau2_bo_nr
,Org_niveau1
,Org_niveau1_bo_nr
,Org_niveau0
,Org_niveau0_bo_nr
FROM MI_CMB.vMedewerker_Security;



INSERT INTO MI_CMB_UIA.Z_KEM_Process_Contracting
SELECT
  COALESCE(fk_aanvr_wkmid, -101)
, COALESCE(fk_aanvr_versie, -101)
, COALESCE(dossier_nummer, -101)
, COALESCE(volg_nr_status, -101)
, COALESCE(Dossier_Type, 'onbekend')
, COALESCE(Request_Type, 'onbekend')
, COALESCE(Date_aanvraag, DATE '1900-01-01')
, COALESCE(Volume_bestaand, -101)
, COALESCE(Volume_gevraagd, -101)
, COALESCE((Volume_gevraagd - Volume_bestaand),-101)  Mutatie_volume
, COALESCE(totaal_one_obligor, -101)  fiat_obligo
, COALESCE(MIN(Status) OVER (PARTITION BY a.fk_aanvr_wkmid, a.fk_aanvr_versie  ORDER BY volg_nr_status ASC ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING) , 'onbekend')   Status_van
, COALESCE(MIN(CASE WHEN Date_created_stap    < Date_aanvraag THEN Date_aanvraag ELSE Date_created_stap END) OVER (PARTITION BY fk_aanvr_wkmid, fk_aanvr_versie  ORDER BY volg_nr_status ASC ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING) , DATE

'1900-01-01')   Datum_van
, COALESCE(MIN(CASE WHEN Date_created_stap    < Date_aanvraag THEN Timestamp_aanvraag ELSE Timestamp_created End (TIMESTAMP(6))) OVER (PARTITION BY fk_aanvr_wkmid, fk_aanvr_versie  ORDER BY volg_nr_status ASC ROWS BETWEEN 1 PRECEDING AND

1 PRECEDING) , TIMESTAMP '1900-01-01 00:00:00.000') (TIMESTAMP(6))   Timestamp_van
, COALESCE(status, 'onbekend')  Status_naar
, CASE WHEN Date_created_stap    < Date_aanvraag THEN COALESCE(Date_aanvraag,DATE '1900-01-01')  ELSE COALESCE(Date_created_stap, DATE '1900-01-01') END  Datum_naar
, CASE WHEN Date_created_stap    < Date_aanvraag THEN Timestamp_aanvraag ELSE Timestamp_created End (TIMESTAMP(6))  Timestamp_naar
, CASE
    WHEN Status_van = 'onbekend' THEN 0
    ELSE COALESCE(CAST(Timestamp_naar  DATE) - CAST(Timestamp_van  DATE), -101)  END  doorlooptijd_dagen
, COALESCE((doorlooptijd_dagen *24) + (EXTRACT(HOUR FROM Timestamp_naar) - EXTRACT(HOUR FROM Timestamp_van)), -101)  Doorlooptijd_uren
, COALESCE(actuele_status, 'onbekend')  Eindstatus
, COALESCE(datum_eindstatus, DATE '1900-01-01')
, COALESCE(hoofdrekening_numm, -101)
, COALESCE(doelgroep, 'onbekend')
, COALESCE(Klant_Segment, 'onbekend')
, COALESCE(kantoor_bo_nummer, -101)
, COALESCE(kantoor_bo_naam, 'onbekend')
, COALESCE(userid_creator, 'onbekend')
, COALESCE(RM_UserID, 'onbekend')
, COALESCE(ACBS_Contract_nr, -101)
, COALESCE(ACBS_BC_nr, -101)
, COALESCE(Datum_KEM_gegevens, DATE '1900-01-01')
FROM (
            SELECT
              c.fk_aanvr_wkmid
FROM mi_cmb.vkem_pijplijn    c
LEFT JOIN     mi_cmb.vkem_aanvraag_det   d
ON    c.fk_aanvr_wkmid = d.fk_aanvr_wkmid
    AND c.fk_aanvr_versie = d.fk_aanvr_versie
        LEFT JOIN
        (SEL
            fk_aanvr_wkmid,
            Status  actuele_status,
            date_created_stap  datum_eindstatus
            FROM mi_cmb.vkem_pijplijn
            WHERE     Volgnr_chrono _old  = 1
            AND Soort_pijplijn = 'KEM'
            )     e
        ON    c.fk_aanvr_wkmid = e.fk_aanvr_wkmid
            WHERE c.Soort_pijplijn = 'KEM'
)    A
WHERE Date_aanvraag BETWEEN 1180101 AND CURRENT_DATE
;



INSERT INTO MI_CMB_UIA.Z_MSTR_GSRI
SELECT
			A.party_id
			,B.maand_nr
			, A.party_gsri_resultaat
			, A.party_gsri_voorgesteld
			, A.party_gsri_goedgekeurd
			, CASE WHEN A.party_agic_code is not null then A.party_agic_code else -101  end   party_agic_code
			, A.industrie_risico_lvl
			, CASE WHEN A.party_landnaam is not null then A.party_landnaam else 'LEEG' end  party_landnaam
			, A.landelijk_risico_lvl
			, A.gsri_goedkeuring_dat
			, A.gsri_expiratie_datum
			, A.gsri_expert_categorie
			, A.duurzaam_bankieren_advies
			, CASE WHEN trim(A.party_assessment_resultaat) = '' then 'LEEG' WHEN trim(A.party_assessment_resultaat) = '--' then 'LEEG'  else A.party_assessment_resultaat end   party_assessment_resultaat
			, CASE WHEN trim(A.gsri_capaciteit) = '' then 'LEEG'  WHEN trim(A.gsri_capaciteit) = '--' then 'LEEG'  else A.gsri_capaciteit end   gsri_capaciteit
			, CASE WHEN trim(A.gsri_commitment) = '' then 'LEEG'  WHEN trim(A.gsri_commitment) = '--' then 'LEEG'   else A.gsri_commitment end   gsri_commitment
			, CASE WHEN trim(A.gsri_compliance) = '' then -101 WHEN trim(A.gsri_compliance) = '--' then -101  else A.gsri_compliance end   gsri_compliance
			, CASE WHEN trim(A.gsri_reputatie) = '' then 'LEEG' WHEN trim(A.gsri_reputatie) = '--' then 'LEEG'  else A.gsri_reputatie end   gsri_reputatie
			, A.party_gsri_sdat
			, A.party_gsri_edat
FROM Mi_vm_ldm.aPARTY_GSRI A
			 LEFT JOIN ( SELECT Maand_nr FROM MI_CMB.vMia_week GROUP BY 1)  B
			 ON 1=1;




INSERT INTO MI_CMB_UIA.Z_KEM_Lending
SELECT
     Coalesce(a.fk_aanvr_wkmid,-101)                                                                                              Aanvraag_nr
    ,Coalesce(a.fk_aanvr_versie,-101)                                                                                              Aanvraag_versie
    ,Coalesce(b.Voorstel_dossier_nr,-101)                                                                                          Dossier_nummer
    ,Coalesce(b.Voorstel_Klant_nr,-101)                                                                                          Klant_nr
    ,Coalesce(b.Voorstel_BCnr_hfdrek_nr,-101)                                                                                      BC_nr
    ,Coalesce(b.Voorstel_type_instroom,'onbekend')                                                                                  Type_instroom
    ,Coalesce(a.Date_aanvraag,DATE '1900-01-01')                                                                                  Datum_aanvraag
    ,Coalesce(per.Jaar,-101)                                                                                                                         Jaar
    ,Coalesce(Extract(YEAR From a.Date_aanvraag),-101)                                                                                                                         Jaar_van_aanvraag                --toegevoegd 11022019
    ,Coalesce('Q' || Substr(Trim(per.Kwartaal),5,1),'onbekend')                                                                  Kwartaal
    ,Coalesce(Trim( 'Q'|| Cast(((((Cast(Extract(MONTH From Datum_aanvraag)  BYTEINT)-1)/3)+1))  VARCHAR(5))  ),'onbekend')   Kwartaal_van_aanvraag     --toegevoegd 11022019
    ,Coalesce(a.Status_nr,-101)
    ,Coalesce(a.Status,'onbekend')
    ,Coalesce(a.date_created_stap,DATE '1900-01-01')                                                                              Datum_status
    ,Coalesce(c.Business_line,'onbekend')
    ,Coalesce(a.Date_voorg_stap,DATE '1900-01-01')                                                                                  Datum_vorige_stap
    ,Coalesce(a.Status_nr_voorg_stap,-101)                                                                                          Status_vorige_stap_nr
    ,Coalesce(a.Status_voorg_stap,'onbekend')                                                                                      Status_vorige_stap
   ,Coalesce(a.dlt_stap,-101)                                                                                                      Doorlooptijd_dagen
    ,Coalesce(a.dlt_cumulatief,-101)                                                                                              Doorlooptijd_cumulatief_dagen
     ,CASE WHEN b.NPL_ind = 1 THEN 'XL' WHEN b.NPL_ind = 0 THEN 'PL' ELSE 'onbekend' END      Dossier_Type
    ,Coalesce(b.Voorstel_Hoofdrekening_nr,-101)                                                                                   Hoofdrekening_nr
    ,Coalesce(b.doelgroep,'onbekend')                                                                                              Doelgroep
    ,Coalesce(b.Voorstel_Classificatie,'onbekend')                                                                                  Klant_Segment
    ,Coalesce(b.Voorstel_Kantoor_BOnr,-101)                                                                                      Kantoor_bo_nummer
    ,Coalesce(b.Voorstel_Kantoor_naam,'onbekend')                                                                                  Kantoor_bo_naam
    ,Coalesce(b.UserID_laatste_stap,'onbekend')                                                                                  Userid_creator
    ,Coalesce(b.RM_UserID,'onbekend')
    ,Coalesce(b.ACBS_Contract_nr,-101)
    ,Coalesce(b.ACBS_BC_nr,-101)
    ,Coalesce(b.FRR_ind,-101)
    ,Coalesce(b.FI_code_oud,'onbekend')
    ,Coalesce(b.FI_code ,'onbekend')
    ,Coalesce(a.Datum_KEM_gegevens,DATE '1900-01-01')                                                   Datum
    ,Coalesce(d.funnel_stap_nr_2,-101)   Status_korte_pijplijn_nr
FROM                      mi_cmb.vkem_pijplijn                                                                                                                                              a

INNER JOIN  mi_vm.vlu_maand                                                                                                                                        per
ON a.date_created_stap BETWEEN per.Maand_sdat AND per.Maand_edat

LEFT OUTER JOIN  MI_cmb.vKEM_aanvraag_det                                                                                                              b
ON b.fk_aanvr_wkmid = a.fk_aanvr_wkmid
AND b.fk_aanvr_versie = a.fk_aanvr_versie

LEFT OUTER JOIN mi_cmb.vCGC_BASIS                                                                                                                            c
ON b.Voorstel_bc_cgc = c.Clientgroep

LEFT JOIN  mi_cmb.vKEM_LU_funnel                                                                                                                                    d
ON     a.Status_nr = d.Kem_status_nr

WHERE date_created_stap  > 1170101
AND soort_pijplijn = 'funnel'
AND a.Volgnr_chrono _old = 1
;


INSERT INTO MI_TEMP.mstr_mdw_hulp
SELECT
 A.SBT_userid   SBT_userid
,B.Naam  Naam
,CASE WHEN C.sbt_userid_manager IS NULL THEN 0 ELSE 1 END  manager
,B.bo_nr_mdw  bo_nr_mdw
,B.bo_naam_mdw   bo_naam_mdw
,A.sbt_userid_manager    sbt_userid_manager

FROM  MI_VM_LDM.aACCOUNT_MANAGEMENT A
Left join 	mi_cmb.vcrm_employee_week B
on TRIM(A.sbt_userid)=TRIM(B.sbt_id)
LEFT JOIN (
		-- SBTs van alle managers
		SELECT sbt_userid_manager
		FROM MI_VM_LDM.aACCOUNT_MANAGEMENT
		GROUP BY 1
)  C
ON  A.SBT_userid = C.sbt_userid_manager
WHERE A.party_sleutel_type = 'MW';


CREATE TABLE MI_TEMP.mstr_mdw_hierarchie_hulp  AS (
SELECT
A.Naam					 Naam_lvl1
,A.SBT_userid         SBT_ID_lvl1
,A.manager             Manager_lvl1

,B.Naam					 Naam_lvl2
,B.SBT_userid        SBT_ID_lvl2
,B.manager             Manager_lvl2

,C.Naam					 Naam_lvl3
,C.SBT_userid        SBT_ID_lvl3
,C.manager             Manager_lvl3

,CASE WHEN D.Naam IS NULL THEN Naam_lvl3 ELSE D.Naam END  Naam_lvl4
,CASE WHEN D.SBT_userid IS NULL THEN SBT_ID_lvl3 ELSE D.SBT_userid END  SBT_ID_lvl4
,CASE WHEN D.manager IS NULL THEN 0 ELSE D.manager END  Manager_lvl4

,CASE WHEN E.Naam IS NULL THEN Naam_lvl4 ELSE E.Naam END  Naam_lvl5
,CASE WHEN E.SBT_userid IS NULL THEN SBT_ID_lvl4 ELSE E.SBT_userid END  SBT_ID_lvl5
,CASE WHEN E.manager IS NULL THEN 0 ELSE E.manager END  Manager_lvl5

,CASE WHEN F.Naam IS NULL THEN Naam_lvl5 ELSE F.Naam END  Naam_lvl6
,CASE WHEN F.SBT_userid IS NULL THEN SBT_ID_lvl5 ELSE F.SBT_userid END  SBT_ID_lvl6
,CASE WHEN F.manager IS NULL THEN 0 ELSE F.manager END  Manager_lvl6

,CASE WHEN G.Naam IS NULL THEN Naam_lvl6 ELSE G.Naam END  Naam_lvl7
,CASE WHEN G.SBT_userid IS NULL THEN SBT_ID_lvl6 ELSE G.SBT_userid END  SBT_ID_lvl7
,CASE WHEN G.manager IS NULL THEN 0 ELSE G.manager END   Manager_lvl7

,CASE WHEN H.Naam IS NULL THEN Naam_lvl7 ELSE H.Naam END  Naam_lvl8
,CASE WHEN H.SBT_userid IS NULL THEN SBT_ID_lvl7 ELSE H.SBT_userid END  SBT_ID_lvl8
,CASE WHEN H.manager IS NULL THEN 0 ELSE H.manager END  Manager_lvl8

,CASE WHEN I.Naam IS NULL THEN Naam_lvl8 ELSE I.Naam END  Naam_lvl9
,CASE WHEN I.SBT_userid IS NULL THEN SBT_ID_lvl8 ELSE I.SBT_userid END  SBT_ID_lvl9
,CASE WHEN I.manager IS NULL THEN 0 ELSE I.manager END  Manager_lvl9

FROM MI_TEMP.mstr_mdw_hulp  A

LEFT JOIN MI_TEMP.mstr_mdw_hulp B
ON B.sbt_userid_manager = A.SBT_userid

LEFT JOIN MI_TEMP.mstr_mdw_hulp C
ON C.sbt_userid_manager = B.SBT_userid

LEFT JOIN MI_TEMP.mstr_mdw_hulp D
ON D.sbt_userid_manager = C.SBT_userid

LEFT JOIN MI_TEMP.mstr_mdw_hulp E
ON E.sbt_userid_manager = D.SBT_userid

LEFT JOIN MI_TEMP.mstr_mdw_hulp F
ON F.sbt_userid_manager = E.SBT_userid

LEFT JOIN MI_TEMP.mstr_mdw_hulp G
ON G.sbt_userid_manager = F.SBT_userid

LEFT JOIN MI_TEMP.mstr_mdw_hulp H
ON H.sbt_userid_manager = G.SBT_userid

LEFT JOIN MI_TEMP.mstr_mdw_hulp I
ON I.sbt_userid_manager = H.SBT_userid

WHERE A.SBT_userid = 'DI3923'   -- C. VAN DIJKHUIZEN

GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27
) WITH DATA PRIMARY INDEX (SBT_ID_lvl9);



INSERT INTO MI_TEMP.mstr_mdw_hierarchie
SELECT * FROM MI_TEMP.mstr_mdw_hierarchie_hulp;



INSERT INTO MI_TEMP.mstr_mdw_hierarchie
SELECT
A.Naam_lvl1
,A.SBT_ID_lvl1
,A.Manager_lvl1

,A.Naam_lvl1  Naam_lvl2
,A.SBT_ID_lvl1   SBT_ID_lvl2
,A.Manager_lvl1   Manager_lvl2

,A.Naam_lvl1  Naam_lvl3
,A.SBT_ID_lvl1   SBT_ID_lvl3
,A.Manager_lvl1   Manager_lvl3

,A.Naam_lvl1  Naam_lvl4
,A.SBT_ID_lvl1   SBT_ID_lvl4
,A.Manager_lvl1   Manager_lvl4

,A.Naam_lvl1  Naam_lvl5
,A.SBT_ID_lvl1   SBT_ID_lvl5
,A.Manager_lvl1   Manager_lvl5

,A.Naam_lvl1  Naam_lvl6
,A.SBT_ID_lvl1   SBT_ID_lvl6
,A.Manager_lvl1   Manager_lvl6

,A.Naam_lvl1  Naam_lvl7
,A.SBT_ID_lvl1   SBT_ID_lvl7
,A.Manager_lvl1   Manager_lvl7

,A.Naam_lvl1  Naam_lvl8
,A.SBT_ID_lvl1   SBT_ID_lvl8
,A.Manager_lvl1   Manager_lvl8

,A.Naam_lvl1  Naam_lvl9
,A.SBT_ID_lvl1   SBT_ID_lvl9
,A.Manager_lvl1   Manager_lvl9

FROM MI_TEMP.mstr_mdw_hierarchie_hulp A

LEFT JOIN (
		SELECT sbt_userid_manager
		FROM MI_VM_LDM.aACCOUNT_MANAGEMENT
		GROUP BY 1
)  C
ON  A.SBT_ID_lvl1 = C.sbt_userid_manager

WHERE A.Manager_lvl1 = 1
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27;


INSERT INTO MI_TEMP.mstr_mdw_hierarchie
SELECT
A.Naam_lvl1
,A.SBT_ID_lvl1
,A.Manager_lvl1

,A.Naam_lvl2
,A.SBT_ID_lvl2
,A.Manager_lvl2

,A.Naam_lvl2  Naam_lvl3
,A.SBT_ID_lvl2   SBT_ID_lvl3
,A.Manager_lvl2   Manager_lvl3

,A.Naam_lvl2  Naam_lvl4
,A.SBT_ID_lvl2   SBT_ID_lvl4
,A.Manager_lvl2   Manager_lvl4

,A.Naam_lvl2  Naam_lvl5
,A.SBT_ID_lvl2   SBT_ID_lvl5
,A.Manager_lvl2   Manager_lvl5

,A.Naam_lvl2  Naam_lvl6
,A.SBT_ID_lvl2   SBT_ID_lvl6
,A.Manager_lvl2   Manager_lvl6

,A.Naam_lvl2  Naam_lvl7
,A.SBT_ID_lvl2   SBT_ID_lvl7
,A.Manager_lvl2   Manager_lvl7

,A.Naam_lvl2  Naam_lvl8
,A.SBT_ID_lvl2   SBT_ID_lvl8
,A.Manager_lvl2   Manager_lvl8

,A.Naam_lvl2  Naam_lvl9
,A.SBT_ID_lvl2   SBT_ID_lvl9
,A.Manager_lvl2   Manager_lvl9

FROM MI_TEMP.mstr_mdw_hierarchie_hulp A

LEFT JOIN (
		-- SBTs van alle managers
		SELECT sbt_userid_manager
		FROM MI_VM_LDM.aACCOUNT_MANAGEMENT
		GROUP BY 1
)  C
ON  A.SBT_ID_lvl1 = C.sbt_userid_manager

WHERE A.Manager_lvl2 = 1
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27;



-- managers level 3 toevoegen tot op laagste niveau
INSERT INTO MI_TEMP.mstr_mdw_hierarchie
SELECT
A.Naam_lvl1
,A.SBT_ID_lvl1
,A.Manager_lvl1

,A.Naam_lvl2
,A.SBT_ID_lvl2
,A.Manager_lvl2

,A.Naam_lvl3
,A.SBT_ID_lvl3
,A.Manager_lvl3

,A.Naam_lvl3  Naam_lvl4
,A.SBT_ID_lvl3   SBT_ID_lvl4
,A.Manager_lvl3   Manager_lvl4

,A.Naam_lvl3  Naam_lvl5
,A.SBT_ID_lvl3   SBT_ID_lvl5
,A.Manager_lvl3   Manager_lvl5

,A.Naam_lvl3  Naam_lvl6
,A.SBT_ID_lvl3   SBT_ID_lvl6
,A.Manager_lvl3   Manager_lvl6

,A.Naam_lvl3  Naam_lvl7
,A.SBT_ID_lvl3   SBT_ID_lvl7
,A.Manager_lvl3   Manager_lvl7

,A.Naam_lvl3  Naam_lvl8
,A.SBT_ID_lvl3   SBT_ID_lvl8
,A.Manager_lvl3   Manager_lvl8

,A.Naam_lvl3  Naam_lvl9
,A.SBT_ID_lvl3   SBT_ID_lvl9
,A.Manager_lvl3   Manager_lvl9

FROM MI_TEMP.mstr_mdw_hierarchie_hulp A

LEFT JOIN (
		SELECT sbt_userid_manager
		FROM MI_VM_LDM.aACCOUNT_MANAGEMENT
		GROUP BY 1
)  C
ON  A.SBT_ID_lvl1 = C.sbt_userid_manager

WHERE A.Manager_lvl3 = 1
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27;



INSERT INTO MI_TEMP.mstr_mdw_hierarchie
SELECT
A.Naam_lvl1
,A.SBT_ID_lvl1
,A.Manager_lvl1

,A.Naam_lvl2
,A.SBT_ID_lvl2
,A.Manager_lvl2

,A.Naam_lvl3
,A.SBT_ID_lvl3
,A.Manager_lvl3

,A.Naam_lvl4
,A.SBT_ID_lvl4
,A.Manager_lvl4

,A.Naam_lvl4  Naam_lvl5
,A.SBT_ID_lvl4   SBT_ID_lvl5
,A.Manager_lvl4   Manager_lvl5

,A.Naam_lvl4  Naam_lvl6
,A.SBT_ID_lvl4   SBT_ID_lvl6
,A.Manager_lvl4   Manager_lvl6

,A.Naam_lvl4  Naam_lvl7
,A.SBT_ID_lvl4   SBT_ID_lvl7
,A.Manager_lvl4   Manager_lvl7

,A.Naam_lvl4  Naam_lvl8
,A.SBT_ID_lvl4   SBT_ID_lvl8
,A.Manager_lvl4   Manager_lvl8

,A.Naam_lvl4  Naam_lvl9
,A.SBT_ID_lvl4   SBT_ID_lvl9
,A.Manager_lvl4   Manager_lvl9

FROM MI_TEMP.mstr_mdw_hierarchie_hulp A

LEFT JOIN (
		SELECT sbt_userid_manager
		FROM MI_VM_LDM.aACCOUNT_MANAGEMENT
		GROUP BY 1
)  C
ON  A.SBT_ID_lvl1 = C.sbt_userid_manager

WHERE A.Manager_lvl4 = 1
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27;


INSERT INTO MI_TEMP.mstr_mdw_hierarchie
SELECT
A.Naam_lvl1
,A.SBT_ID_lvl1
,A.Manager_lvl1

,A.Naam_lvl2
,A.SBT_ID_lvl2
,A.Manager_lvl2

,A.Naam_lvl3
,A.SBT_ID_lvl3
,A.Manager_lvl3

,A.Naam_lvl4
,A.SBT_ID_lvl4
,A.Manager_lvl4

,A.Naam_lvl5
,A.SBT_ID_lvl5
,A.Manager_lvl5

,A.Naam_lvl5  Naam_lvl6
,A.SBT_ID_lvl5   SBT_ID_lvl6
,A.Manager_lvl5   Manager_lvl6

,A.Naam_lvl5  Naam_lvl7
,A.SBT_ID_lvl5   SBT_ID_lvl7
,A.Manager_lvl5   Manager_lvl7

,A.Naam_lvl5  Naam_lvl8
,A.SBT_ID_lvl5   SBT_ID_lvl8
,A.Manager_lvl5   Manager_lvl8

,A.Naam_lvl5  Naam_lvl9
,A.SBT_ID_lvl5   SBT_ID_lvl9
,A.Manager_lvl5   Manager_lvl9

FROM MI_TEMP.mstr_mdw_hierarchie_hulp A

LEFT JOIN (
		SELECT sbt_userid_manager
		FROM MI_VM_LDM.aACCOUNT_MANAGEMENT
		GROUP BY 1
)  C
ON  A.SBT_ID_lvl1 = C.sbt_userid_manager

WHERE A.Manager_lvl5 = 1
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27;

INSERT INTO MI_TEMP.mstr_mdw_hierarchie
SELECT
A.Naam_lvl1
,A.SBT_ID_lvl1
,A.Manager_lvl1

,A.Naam_lvl2
,A.SBT_ID_lvl2
,A.Manager_lvl2

,A.Naam_lvl3
,A.SBT_ID_lvl3
,A.Manager_lvl3

,A.Naam_lvl4
,A.SBT_ID_lvl4
,A.Manager_lvl4

,A.Naam_lvl5
,A.SBT_ID_lvl5
,A.Manager_lvl5

,A.Naam_lvl6
,A.SBT_ID_lvl6
,A.Manager_lvl6

,A.Naam_lvl6  Naam_lvl7
,A.SBT_ID_lvl6   SBT_ID_lvl7
,A.Manager_lvl6   Manager_lvl7

,A.Naam_lvl6  Naam_lvl8
,A.SBT_ID_lvl6   SBT_ID_lvl8
,A.Manager_lvl6   Manager_lvl8

,A.Naam_lvl6  Naam_lvl9
,A.SBT_ID_lvl6   SBT_ID_lvl9
,A.Manager_lvl6   Manager_lvl9

FROM MI_TEMP.mstr_mdw_hierarchie_hulp A

LEFT JOIN (
		SELECT sbt_userid_manager
		FROM MI_VM_LDM.aACCOUNT_MANAGEMENT
		GROUP BY 1
)  C
ON  A.SBT_ID_lvl1 = C.sbt_userid_manager

WHERE A.Manager_lvl6 = 1
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27;


INSERT INTO MI_TEMP.mstr_mdw_hierarchie
SELECT
A.Naam_lvl1
,A.SBT_ID_lvl1
,A.Manager_lvl1

,A.Naam_lvl2
,A.SBT_ID_lvl2
,A.Manager_lvl2

,A.Naam_lvl3
,A.SBT_ID_lvl3
,A.Manager_lvl3

,A.Naam_lvl4
,A.SBT_ID_lvl4
,A.Manager_lvl4

,A.Naam_lvl5
,A.SBT_ID_lvl5
,A.Manager_lvl5

,A.Naam_lvl6
,A.SBT_ID_lvl6
,A.Manager_lvl6

,A.Naam_lvl7
,A.SBT_ID_lvl7
,A.Manager_lvl7

,A.Naam_lvl7  Naam_lvl8
,A.SBT_ID_lvl7   SBT_ID_lvl8
,A.Manager_lvl7   Manager_lvl8

,A.Naam_lvl7  Naam_lvl9
,A.SBT_ID_lvl7   SBT_ID_lvl9
,A.Manager_lvl7   Manager_lvl9

FROM MI_TEMP.mstr_mdw_hierarchie_hulp A

LEFT JOIN (
		SELECT sbt_userid_manager
		FROM MI_VM_LDM.aACCOUNT_MANAGEMENT
		GROUP BY 1
)  C
ON  A.SBT_ID_lvl1 = C.sbt_userid_manager

WHERE A.Manager_lvl7 = 1
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27;

INSERT INTO MI_TEMP.mstr_mdw_hierarchie
SELECT
A.Naam_lvl1
,A.SBT_ID_lvl1
,A.Manager_lvl1

,A.Naam_lvl2
,A.SBT_ID_lvl2
,A.Manager_lvl2

,A.Naam_lvl3
,A.SBT_ID_lvl3
,A.Manager_lvl3

,A.Naam_lvl4
,A.SBT_ID_lvl4
,A.Manager_lvl4

,A.Naam_lvl5
,A.SBT_ID_lvl5
,A.Manager_lvl5

,A.Naam_lvl6
,A.SBT_ID_lvl6
,A.Manager_lvl6

,A.Naam_lvl7
,A.SBT_ID_lvl7
,A.Manager_lvl7

,A.Naam_lvl8
,A.SBT_ID_lvl8
,A.Manager_lvl8

,A.Naam_lvl8  Naam_lvl9
,A.SBT_ID_lvl8   SBT_ID_lvl9
,A.Manager_lvl8   Manager_lvl9

FROM MI_TEMP.mstr_mdw_hierarchie_hulp A

LEFT JOIN (
		SELECT sbt_userid_manager
		FROM MI_VM_LDM.aACCOUNT_MANAGEMENT
		GROUP BY 1
)  C
ON  A.SBT_ID_lvl1 = C.sbt_userid_manager

WHERE A.Manager_lvl8 = 1
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27;

INSERT INTO mi_cmb_uia.A_MSTR_LU_CRM_EMP_hrchy
SELECT
A.Maand_nr
,A.Datum_gegevens
,COALESCE(B.Naam_lvl1,'Onbekend')
,COALESCE(B.SBT_ID_lvl1,'Onbekend')
,COALESCE(B.Manager_lvl1,0)
,COALESCE(B.Naam_lvl2,'Onbekend')
,COALESCE(B.SBT_ID_lvl2,'Onbekend')
,COALESCE(B.Manager_lvl2,0)
,COALESCE(B.Naam_lvl3,'Onbekend')
,COALESCE(B.SBT_ID_lvl3,'Onbekend')
,COALESCE(B.Manager_lvl3,0)
,COALESCE(B.Naam_lvl4,'Onbekend')
,COALESCE(B.SBT_ID_lvl4,'Onbekend')
,COALESCE(B.Manager_lvl4,0)
,COALESCE(B.Naam_lvl5,'Onbekend')
,COALESCE(B.SBT_ID_lvl5,'Onbekend')
,COALESCE(B.Manager_lvl5,0)
,COALESCE(B.Naam_lvl6,'Onbekend')
,COALESCE(B.SBT_ID_lvl6,'Onbekend')
,COALESCE(B.Manager_lvl6,0)
,COALESCE(B.Naam_lvl7,'Onbekend')
,COALESCE(B.SBT_ID_lvl7,'Onbekend')
,COALESCE(B.Manager_lvl7,0)
,COALESCE(B.Naam_lvl8,'Onbekend')
,COALESCE(B.SBT_ID_lvl8,'Onbekend')
,COALESCE(B.Manager_lvl8,0)
,COALESCE(B.Naam_lvl9,'Onbekend')
,COALESCE(B.SBT_ID_lvl9,'Onbekend')
,COALESCE(B.Manager_lvl9,0)
,A.SBT_ID
FROM Mi_cmb.vCRM_Employee_week A
LEFT JOIN  MI_TEMP.mstr_mdw_hierarchie B
ON A.SBT_ID = B.SBT_ID_lvl9;


CREATE TABLE mi_temp.TB_businesscontacts_scope
AS
(
SELECT	  a.Business_contact_nr
		, a.maand_nr
		, b.datum_gegevens
		, coalesce(a.klant_nr, i.gerelateerd_party_id, -101)  klant_nr
		, a.Bc_naam
		, a.Klant_naam
		, COALESCE(a.Clientgroep, a.bc_clientgroep)  clientgroep
		, CASE WHEN ind_pb = 1 THEN 'PB' ELSE COALESCE(a.business_line, a.Bc_Business_line) end  Business_line
		, CASE WHEN ind_pb = 1 THEN 'PB' ELSE COALESCE(a.segment, a.Bc_Segment) end  Segment
		, COALESCE(a.Bo_nr, a.bc_bo_nr)  bo_nr
		, COALESCE(a.Bo_naam, a.bc_bo_naam)  bo_naam
		, case when ind_pb = 1 then j.party_id else a.CCA end  CCA
		, case when ind_pb = 1 then k.naamregel_1 else a.Relatiemanager end  relatiemanager
		, b.org_niveau3_bo_nr  team_bo_nr
		, b.org_niveau3  team
		, b.org_niveau2_bo_nr  unit_bo_nr
		, b.org_niveau2  unit
		, b.org_niveau1_bo_nr  regio_bo_nr
		, b.org_niveau1  regio
		, COALESCE(a.Kvk_nr, a.bc_kvk_nr)  kvk_nr
		, b.Sbi_code
		, b.Sbi_oms
		, b.agic_oms
		, b.subsector_code
		, b.subsector_oms
		, b.CMB_sector
		, coalesce	(	a.Leidend_business_contact_nr
					, 	MIN( CASE WHEN i.party_deelnemer_rol = 1 THEN a.Business_Contact_nr end ) OVER ( PARTITION BY i.gerelateerd_party_id )
					, 	MIN( CASE WHEN i.party_deelnemer_rol = 2 THEN a.Business_Contact_nr end ) OVER ( PARTITION BY i.gerelateerd_party_id )
					, -101
					) 	 	Leidend_business_contact_nr
		, a.Bc_postcode
		, a.Leidend_bc_ind
		, CASE WHEN a.klant_nr IS NULL
					AND 	(a.BC_clientgroep IN ( 	'0425', '0428', '0430', '0431', '0433', '0434', '0435', '0422', '0439', '0444', '0446', '0447', '0487')
							OR a.BC_bo_nr IN (523610, 523612, 523613, 523614 ,523619 ,523620 , 523621, 523622, 523623, 523624, 515901 ,515902 )) THEN 1 ELSE 0 end  ind_pb
FROM 		mi_cmb.vmia_businesscontacts 	a
LEFT JOIN	mi_cmb.vmia_week				b	ON a.klant_nr = b.klant_nr
LEFT JOIN	mi_vm_ldm.aParty_party_relatie	i 	ON  a.business_contact_nr = i.party_id
											  	AND i.party_sleutel_type = 'BC'
											  	AND i.party_relatie_type_code = 'LDPCNL'
LEFT JOIN mi_vm_ldm.aparty_party_relatie 	j 	ON  a.Business_Contact_nr = j.party_id
											  	AND j.party_sleutel_type = 'BC'
											  	AND j.gerelateerd_party_sleutel_type = 'AM'
											  	AND j.party_relatie_type_code = 'PRVBNK'
LEFT JOIN	mi_vm_ldm.aparty_naam			k	ON  j.gerelateerd_party_id = k.party_id
												and j.gerelateerd_party_sleutel_type = k.party_sleutel_type
)
WITH DATA
UNIQUE PRIMARY INDEX (business_contact_nr);


INSERT INTO MI_CMB_UIA.A_MSTR_Mia_hist
SELECT DISTINCT
    a.klant_nr            Klant_nr
FROM mi_temp.TB_businesscontacts_scope  a
LEFT JOIN MI_SAS_AA_MB_C_MB.CIAA_Mia_hist                 Mia
ON a.klant_nr = Mia.klant_nr
AND a.maand_nr = mia.maand_nr

LEFT JOIN MI_CMB_UIA.A_MSTR_Mia_hist X
ON a.klant_nr = X.klnt_klant_nr
AND a.maand_nr = X.klnt_maand_nr

LEFT JOIN	MI_SAS_AA_MB_C_MB.Siebel_CST_Member_hist			d
ON a.klant_nr = d.klant_nr and a.maand_nr = d.maand_nr
and d.tb_consultant = 'y'

LEFT JOIN	MI_CMB_UIA.TB_LU_consultant			e
ON d.naam = e.consultant_naam

WHERE Mia.klant_nr IS NULL and a.klant_nr <> -101
QUALIFY ROW_NUMBER() OVER (PARTITION BY a.klant_nr ORDER BY a.leidend_bc_ind, postcode DESC ) = 1;

UPDATE MI_CMB_UIA.A_MSTR_Mia_hist
FROM (SELECT klant_nr, revisie_datum
FROM MI_CMB_UIA.TB_Revisiedatum
WHERE Revisie_actueel_ind = 1) A
 Revisiedatum_TB = COALESCE(A.revisie_datum, NULL)
WHERE MI_CMB_UIA.A_MSTR_Mia_hist .klnt_klant_nr = A.klant_nr;


INSERT INTO MI_CMB_UIA.A_MSTR_Mia_Klantkop
SELECT
a.klant_nr
,a.Maand_nr
,a.business_contact_nr
,-101
,-101
FROM mi_temp.TB_businesscontacts_scope  a
LEFT JOIN MI_SAS_AA_MB_C_MB.CIAA_Mia_hist                 Mia
ON a.klant_nr = Mia.klant_nr
AND a.maand_nr = mia.maand_nr
LEFT JOIN MI_CMB_UIA.A_MSTR_Mia_hist X
ON a.klant_nr = X.klnt_klant_nr
AND a.maand_nr = X.klnt_maand_nr
WHERE Mia.klant_nr IS NULL and a.klant_nr <> -101;

INSERT INTO mi_cmb_uia. A_MSTR_LU_RM
SELECT    a.maand_nr  maand_nr
        , 'CCA'   adviseur_type
        , CASE WHEN a.cca IS NULL THEN -101 ELSE a.cca end    adviseur_nr
        , CASE WHEN a.cca IS NULL THEN 'Onbekend' ELSE a.relatiemanager end   adviseur_naam
FROM  mi_temp.TB_businesscontacts_scope     a
left join mi_cmb_uia. A_MSTR_LU_RM b
on a.cca=b.adviseur_nr and a.maand_nr = b.maand_nr
INNER JOIN
(SELECT Klnt_CCA
FROM MI_CMB_UIA.A_MSTR_Mia_hist
GROUP BY 1)  C
ON c.Klnt_CCA = a.cca
where b.adviseur_nr is null
group by 1, 2, 3,4;