#DATASPOT-TERADATA

CREATE TABLE Mi_temp.BC_krediet_info AS
      (
       SELECT B.Fac_Bc_nr (INTEGER) AS Business_contact_nr,
              MAX(CASE WHEN A.Ind_Bijzonder_beheer = 1 AND A.Ind_OOE = 1 AND B.Bijzonder_beheer_type LIKE '%Lindorff%' THEN 1 ELSE 0 END) AS Bc_Lindorff_ind,
              MAX(CASE WHEN A.Ind_Bijzonder_beheer = 1 AND A.Ind_OOE = 1 AND TRIM(B.Bijzonder_beheer_type) = 'Restructuring' THEN 1 ELSE 0 END) AS Bc_FRR_restructuring_ind,
              MAX(CASE WHEN A.Ind_Bijzonder_beheer = 1 AND A.Ind_OOE = 1 AND TRIM(B.Bijzonder_beheer_type) = 'Recovery' THEN 1 ELSE 0 END) AS Bc_FRR_recovery_ind,
              MIN(CASE WHEN B.Datum_revisie > DATE THEN B.Datum_revisie ELSE NULL END) AS Bc_datum_kredietrevisie,
              MAX(CASE
                  WHEN B.FAC_BC_UCR = '0'        THEN '01 0'
                  WHEN B.FAC_BC_UCR = '1'        THEN '02 1'
                  WHEN B.FAC_BC_UCR = '2+'       THEN '03 2+'
                  WHEN B.FAC_BC_UCR = '2'        THEN '04 2'
                  WHEN B.FAC_BC_UCR = '2-'       THEN '05 2-'
                  WHEN B.FAC_BC_UCR = '3+'       THEN '06 3+'
                  WHEN B.FAC_BC_UCR = '3'        THEN '07 3'
                  WHEN B.FAC_BC_UCR = '3-'       THEN '08 3-'
                  WHEN B.FAC_BC_UCR = '4+'       THEN '09 4+'
                  WHEN B.FAC_BC_UCR = '4'        THEN '10 4'
                  WHEN B.FAC_BC_UCR = '4-'       THEN '11 4-'
                  WHEN B.FAC_BC_UCR = '5+'       THEN '12 5+'
                  WHEN B.FAC_BC_UCR = '5'        THEN '13 5'
                  WHEN B.FAC_BC_UCR = '5-'       THEN '14 5-'
                  WHEN B.FAC_BC_UCR = '6+'       THEN '15 6+'
                  WHEN B.FAC_BC_UCR = '6'        THEN '16 6'
                  WHEN B.FAC_BC_UCR = '6-'       THEN '17 6-'
                  WHEN B.FAC_BC_UCR = '7'        THEN '18 7'
                  WHEN B.FAC_BC_UCR = '8'        THEN '19 8'
                  WHEN B.FAC_BC_UCR = 'S'        THEN '20 S'
                  WHEN B.FAC_BC_UCR = 'X'        THEN '21 X'
                  WHEN B.FAC_BC_UCR = 'Y'        THEN '22 Y'
                  WHEN B.FAC_BC_UCR = '-1'       THEN '23 -1'
                  WHEN B.FAC_BC_UCR = 'Onbekend' THEN NULL
                  WHEN B.FAC_BC_UCR IS NULL      THEN NULL
                  END) AS Bc_UCR_gecodeerd,
              SUBSTR(Bc_UCR_gecodeerd, 4, 2) (VARCHAR(3)) AS Bc_UCR
         FROM (SELECT XA.Master_faciliteit_ID,
                      XA.Maand_nr,
                      MAX(XA.Bijzonder_beheer_ind) AS Ind_Bijzonder_beheer,
                      MAX(CASE WHEN ZEROIFNULL(XA.OOE) <> 0 THEN 1 ELSE 0 END) AS Ind_OOE
                 FROM Mi_cmb.vCIF_complex XA
                WHERE XA.Fac_actief_ind = 1
                  AND XA.Maand_nr = (SELECT MAX(XXA.Maand_nr) AS Maand_nr FROM Mi_cmb.vCIF_complex XXA)
                GROUP BY 1, 2) AS A
         JOIN Mi_cmb.vCIF_Complex B
           ON A.Maand_nr = B.Maand_nr
          AND A.Master_faciliteit_ID = B.Master_faciliteit_ID
          AND B.Fac_actief_ind = 1
        GROUP BY 1
      ) WITH DATA
UNIQUE PRIMARY INDEX ( Business_contact_nr );

INSERT INTO Mi_temp.VVB_selectie_basis
SELECT A.Business_contact_nr,
       XA.Datum_gegevens,
       'CB' AS Selectie,
       A.Klant_nr,
       CASE WHEN A.Klant_nr IS NOT NULL THEN A.Klant_nr ELSE A.Business_contact_nr END AS Klant_nr_update,
       CASE WHEN A.Klant_nr IS NOT NULL THEN A.Leidend_business_contact_nr ELSE A.Business_contact_nr END AS Leidend_business_contact_nr_update,
       A.Aantal_bcs,
       NULL AS Aantal_bcs_in_scope,
       CASE
       WHEN SUBSTR(B.Structuur, 1, 4) = '3340' THEN 'CB'
       WHEN SUBSTR(B.Structuur, 1, 4) = '3345' THEN 'C&IB'
       WHEN SUBSTR(B.Structuur, 1, 4) = '3330' THEN 'RB'
       WHEN SUBSTR(B.Structuur, 1, 4) = '3325' THEN 'PB'
       ELSE NULL
       END AS Bo_business_line
  FROM Mi_cmb.vMia_businesscontacts A
  JOIN Mi_vm_ldm.vBo_mi_part_zak B
    ON A.Bc_bo_nr = B.Party_id
  JOIN (SELECT MAX(XA.Datum_gegevens) AS Datum_gegevens FROM Mi_cmb.vMia_week XA) AS XA
    ON 1 = 1
 WHERE A.Bc_validatieniveau IN ( 3, 4 )
   AND (A.Bc_klantlevenscyclus NE 'REJECTED' OR A.Bc_klantlevenscyclus IS NULL)
   AND SUBSTR(B.Structuur, 1, 4) = '3340';

INSERT INTO Mi_temp.VVB_selectie_basis
SELECT A.Business_contact_nr,
       XA.Datum_gegevens,
       'CB' AS Selectie,
       A.Klant_nr,
       CASE WHEN A.Klant_nr IS NOT NULL THEN A.Klant_nr ELSE A.Business_contact_nr END AS Klant_nr_update,
       CASE WHEN A.Klant_nr IS NOT NULL THEN A.Leidend_business_contact_nr ELSE A.Business_contact_nr END AS Leidend_business_contact_nr_update,
       A.Aantal_bcs,
       NULL AS Aantal_bcs_in_scope,
       CASE
       WHEN SUBSTR(B.Structuur, 1, 4) = '3340' THEN 'CB'
       WHEN SUBSTR(B.Structuur, 1, 4) = '3345' THEN 'C&IB'
       WHEN SUBSTR(B.Structuur, 1, 4) = '3330' THEN 'RB'
       WHEN SUBSTR(B.Structuur, 1, 4) = '3325' THEN 'PB'
       ELSE NULL
       END AS Bo_business_line
  FROM Mi_cmb.vMia_businesscontacts A
  JOIN Mi_vm_ldm.vBo_mi_part_zak B
    ON A.Bc_bo_nr = B.Party_id
  JOIN (SELECT MAX(XA.Datum_gegevens) AS Datum_gegevens FROM Mi_cmb.vMia_week XA) AS XA
    ON 1 = 1
 WHERE A.Bc_validatieniveau IN ( 3, 4 )
   AND (A.Bc_klantlevenscyclus NE 'REJECTED' OR A.Bc_klantlevenscyclus IS NULL)
   AND A.Klant_nr IN (SELECT XA.Klant_nr
                        FROM Mi_temp.VVB_selectie_basis XA
                       GROUP BY 1)
   AND A.Business_contact_nr NOT IN (SELECT XA.Business_contact_nr
                                       FROM Mi_temp.VVB_selectie_basis XA
                                      GROUP BY 1);

INSERT INTO Mi_temp.VVB_selectie_aantal_bcs_in_scope
SELECT A.Klant_nr_update,
       COUNT(*) AS Aantal_bcs_in_scope
  FROM Mi_temp.VVB_selectie_basis A
 GROUP BY 1;

INSERT INTO Mi_cb_vvb.VVB_selectie
SELECT B.Business_contact_nr,
       A.Bc_naam AS Bc_naam,
       B.Datum_gegevens,
       B.Selectie,
       B.Klant_nr,
       B.Klant_nr_update,
       B.Leidend_business_contact_nr_update,
       C.Bc_naam AS Leidend_BC_naam_update,
       B.Aantal_bcs,
       B.Aantal_bcs_in_scope,
       B.Bo_business_line,
       A.Bc_bo_nr AS Bc_bo_nr,
       A.Bc_bo_naam AS BC_bo_naam,
       A.Bc_cca_am AS Bc_cca_am,
       E.Naamregel_1 AS BC_cca_am_naam,
   	CASE WHEN A.Org_niveau3 = 'Onbekend' AND A.Bc_bo_nr = 530240 THEN 'Assepoester' ELSE A.Org_niveau3 END AS Org_niveau3,
	CASE WHEN A.Org_niveau2 = 'Onbekend' AND A.Bc_bo_nr = 530240 THEN 'Assepoester' ELSE A.Org_niveau2 END AS Org_niveau2,
	CASE WHEN A.Org_niveau1 = 'Onbekend' AND A.Bc_bo_nr = 530240 THEN 'Assepoester' ELSE A.Org_niveau1 END AS Org_niveau1,
	A.Bc_startdatum AS Bc_startdatum,
       A.Bc_validatieniveau AS Bc_validatieniveau,
       A.Bc_verschijningsvorm AS Bc_verschijningsvorm,
       A.Bc_verschijningsvorm_oms AS Bc_verschijningsvorm_oms,
       A.Bc_relatiecategorie AS Bc_relatiecategorie,
       XW.Segment_oms AS Bc_relatiecategorie_oms,
       A.Bc_clientgroep AS Bc_clientgroep,
       XX.Segment_oms AS Bc_clientgroep_oms,
       F.Bc_land_code AS Bc_land_code,
       A.Bc_sbi_code_BCDB AS Bc_sbi_code_BCDB,
       XA.Sbi_oms AS Bc_sbi_oms_BCDB,
       A.CMB_sector AS CMB_sector,
-- NOG WIJZIGEN ALS IN Mia_busisscontacts
       CASE WHEN XS.Party_id IS NOT NULL THEN 'Ja' ELSE NULL END AS Bc_sub_ind,
-- NOG WIJZIGEN ALS IN Mia_busisscontacts
       XS.Party_id AS Bc_sub_eigenaar,
       A.Bc_klantlevenscyclus AS Bc_klantlevenscyclus,
       A.Bc_contracten AS Bc_contracten,
       CASE
       WHEN A.Bc_ringfence IS NOT NULL THEN 1
       ELSE 0
       END AS Bc_ringfence_ind,
       A.Bc_ringfence AS Bc_ringfence,
       A.Bc_Risico_score AS Bc_Risico_score,
       XU.Datum_risico_score AS Datum_bc_risico_score,
       XU.Revisie_datum AS Datum_revisie_bc_risico_score,

       A.Bc_crg AS Bc_CRG,
       D.Bc_UCR AS Bc_UCR,
       D.Bc_datum_kredietrevisie AS Bc_datum_Kredietrevisie,
       ZEROIFNULL(D.Bc_FRR_restructuring_ind) AS Bc_FRenR_Restructuring_ind,
       ZEROIFNULL(D.Bc_FRR_recovery_ind) AS Bc_FRenR_Recovery_ind,
       ZEROIFNULL(D.Bc_Lindorff_ind) AS Bc_Lindorff_ind,
       A.Bc_SEC_US_Person_oms AS Bc_SEC_US_Person_oms,
       A.Bc_FATCA_US_Person_class AS Bc_FATCA_US_Person_class,
       ZEROIFNULL(G.Bc_UBO_ind) AS Bc_UBO_ind,
       CASE WHEN H.Bc_factoring_ind = 1 THEN 'Ja' WHEN I.Gbc_factoring_ind = 1 THEN 'Ja, via GBC' ELSE NULL END AS Factoring_oms,
       CASE WHEN H.Bc_lease_ind = 1 THEN 'Ja' WHEN I.Gbc_lease_ind = 1 THEN 'Ja, via GBC' ELSE NULL END AS Lease_oms,
       CASE WHEN H.Bc_buitenland_ind = 1 THEN 'Ja' WHEN I.Gbc_buitenland_ind = 1 THEN 'Ja, via GBC' ELSE NULL END AS Buitenland_oms,-- VRAAG: wat doet men hier mee? verwijderen?
       CASE WHEN A.Bc_bo_nr = 542347 THEN 1 ELSE 0 END AS KYC_dochter_ind

  FROM Mi_cmb.vMia_businesscontacts A
  JOIN Mi_temp.VVB_selectie_basis B
    ON A.Business_contact_nr = B.Business_contact_nr
  LEFT OUTER JOIN Mi_cmb.vMia_businesscontacts C
    ON B.Leidend_business_contact_nr_update = C.Business_contact_nr
  LEFT OUTER JOIN Mi_temp.Bc_krediet_info D
    ON A.Business_contact_nr = D.Business_contact_nr
  LEFT OUTER JOIN Mi_vm_ldm.aParty_naam E
    ON A.Bc_cca_am = E.Party_id
   AND E.Party_sleutel_type = 'AM'

  LEFT OUTER JOIN (SELECT XA.Party_id AS Business_contact_nr,
                          XA.Land_geogr_id AS Bc_land_code
                     FROM Mi_vm_ldm.aParty_post_adres XA
                    WHERE XA.Party_sleutel_type = 'bc'
                  QUALIFY ROW_NUMBER() OVER (PARTITION BY XA.Party_id
                                                 ORDER BY (CASE WHEN XA.Party_adres_status_code = 'IG' THEN 1 ELSE 0 END) DESC,
                                                          (CASE WHEN XA.Adres_gebruik_type_code = 'AV' THEN 1 ELSE 0 END) DESC) = 1) AS F
    ON A.Business_contact_nr = F.Business_contact_nr

  LEFT OUTER JOIN (SELECT XA.Gerelateerd_party_id AS Business_contact_nr,
                          1 AS Bc_UBO_ind
                     FROM Mi_vm_ldm.aParty_party_relatie XA
                    WHERE XA.Party_sleutel_type = 'bc'
                      AND XA.Party_relatie_type_code = 'UBOOND'
                    GROUP BY 1) AS G
    ON A.Business_contact_nr = G.Business_contact_nr

  LEFT OUTER JOIN (SELECT XA.Party_id AS Business_contact_nr,
                          MAX(ZEROIFNULL(CASE WHEN XA.Xref_herkomst LIKE ANY ('%AAL%', '%LCA%') THEN  1 ELSE 0 END)) AS Bc_lease_ind,
                          MAX(ZEROIFNULL(CASE WHEN XA.Xref_herkomst LIKE ('%CF%') THEN 1 ELSE 0 END)) AS Bc_factoring_ind,
                          MAX(ZEROIFNULL(CASE WHEN XA.Xref_herkomst LIKE ANY ('%T24%', '%SAB%') THEN 1 ELSE 0 END)) AS Bc_buitenland_ind
                     FROM Mi_vm_nzdb.vGbc_crossref XA
                    WHERE XA.Party_sleutel_type = 'bc'
                      AND XA.Maand_nr = (SELECT MAX(XXA.Maand_nr) FROM mi_vm_nzdb.vGBC_CROSSREF XXA)
                    GROUP BY 1) AS H
    ON A.Business_contact_nr = H.Business_contact_nr

  LEFT OUTER JOIN (SELECT XA.Party_id AS Bc_gbc_nr,
                          MAX(ZEROIFNULL(CASE WHEN XA.Xref_herkomst LIKE ANY ('%AAL%', '%LCA%') THEN  1 ELSE 0 END)) AS Gbc_lease_ind,
                          MAX(ZEROIFNULL(CASE WHEN XA.Xref_herkomst LIKE ('%CF%') THEN 1 ELSE 0 END)) AS Gbc_factoring_ind,
                          MAX(ZEROIFNULL(CASE WHEN XA.Xref_herkomst LIKE ANY ('%T24%', '%SAB%') THEN 1 ELSE 0 END)) AS Gbc_buitenland_ind
                     FROM Mi_vm_nzdb.vGbc_crossref XA
                    WHERE XA.Party_sleutel_type = 'gb'
                      AND XA.Maand_nr = (SELECT MAX(XXA.Maand_nr) FROM mi_vm_nzdb.vGBC_CROSSREF XXA)
                    GROUP BY 1) AS I
    ON A.Bc_GBC_nr = I.Bc_gbc_nr

  LEFT OUTER JOIN Mi_cmb.vMia_sector XA
    ON A.Bc_sbi_code_BCDB = XA.Sbi_code
  LEFT OUTER JOIN Mi_vm_ldm.aParty_party_relatie XS
    ON A.Business_contact_nr = XS.Party_id
   AND XS.Party_sleutel_type = 'bc'
   AND XS.Party_relatie_type_code = 'SBCTBC'
  LEFT OUTER JOIN MI_SAS_AA_MB_C_MB.CGC_BASIS XT
    ON A.Bc_clientgroep = XT.Clientgroep
  LEFT OUTER JOIN Mi_vm_ldm.aKlant_prospect XU
    ON A.Business_contact_nr = XU.Party_id
   AND XU.Party_sleutel_type = 'bc'
  LEFT OUTER JOIN Mi_vm_ldm.aSegment XW
    ON A.Bc_relatiecategorie = XW.Segment_id
   AND XW.Segment_type_code = 'Relcat'
  LEFT OUTER JOIN Mi_vm_ldm.aSegment XX
    ON A.Bc_clientgroep = XX.Segment_id
   AND XX.Segment_type_code = 'CG';



CREATE TABLE Mi_cb_vvb.VVB_selectie_OLD AS
  (SELECT * FROM Mi_cb_vvb.VVB_selectie); WITH NO DATA AND STATS;

CREATE TABLE Mi_cb_vvb.vVVB_selectie_CB_mendix AS
      (SELECT A.Leidend_business_contact_nr_update AS LBC_nr,
              A.Leidend_BC_naam_update AS LBC_name,
              A.Business_contact_nr AS BC_nr,
              A.Bc_naam AS BC_naam,
              A.BC_cca_am_naam AS RM,
              A.CMB_sector AS Sector,
              A.Aantal_bcs_in_scope AS #BCs,
              A.Datum_revisie_bc_risico_score AS Review_date,
              A.Bc_factoring_oms AS Shared_client_ABF,
              A.Bc_lease_oms AS Shared_client_Lease,
              A.Bc_buitenland_oms AS Shared_client_International,
              A.Bc_Risico_score AS Risk_score
         FROM Mi_cb_vvb.vVVB_selectie_CB A
      ) WITH DATA
UNIQUE PRIMARY INDEX ( BC_nr )
INDEX ( LBC_nr );


INSERT INTO Mi_temp.VVB_mutaties
SELECT Vervallen.Business_contact_nr, A.Datum_gegevens, 'D' AS Mutatie
  FROM (SELECT A.Business_contact_nr FROM Mi_cb_vvb.VVB_selectie_OLD A
         MINUS
        SELECT B.Business_contact_nr FROM Mi_cb_vvb.VVB_selectie B) AS Vervallen
  JOIN Mi_cmb.vMia_periode A
    ON 1 = 1
join (SELECT A.Business_contact_nr FROM Mi_cb_vvb.VVB_selectie A
         MINUS
        SELECT B.Business_contact_nr FROM Mi_cb_vvb.VVB_selectie_OLD B) AS Toegevoegd
ON 1=1
  JOIN Mi_cmb.vMia_periode A
    ON 1 = 1
join (SELECT A.Business_contact_nr,
               A.Bc_naam,
               A.Leidend_business_contact_nr_update,
               A.Leidend_BC_naam_update,
               A.Aantal_bcs_in_scope,
               A.BC_cca_am_naam,
               A.Org_niveau2,
               A.Bc_Risico_score,
               A.Datum_revisie_bc_risico_score,
               A.Bc_factoring_oms,
               A.Bc_lease_oms,
               A.Bc_buitenland_oms
          FROM Mi_cb_vvb.VVB_selectie A
          LEFT OUTER JOIN (SELECT A.Business_contact_nr FROM Mi_cb_vvb.VVB_selectie A
                            MINUS
                           SELECT B.Business_contact_nr FROM Mi_cb_vvb.VVB_selectie_OLD B) AS Toegevoegd
            ON A.Business_contact_nr = Toegevoegd.Business_contact_nr
         join Mi_cb_vvb.VVB_selectie_OLD A
         on 1=1) Gewijzigd
on 1=1
  JOIN Mi_cmb.vMia_periode A
    ON 1 = 1;


CREATE TABLE Mi_cb_vvb.VVB_mutaties_hist  AS Mi_cb_vvb.VVB_mutaties_hist WITH DATA
UNIQUE PRIMARY INDEX ( Business_contact_nr, Datum_gegevens );


DELETE FROM Mi_cb_vvb.VVB_mutaties_hist
 WHERE Datum_gegevens IN (SELECT MAX(X.Datum_gegevens) AS Datum_gegevens FROM Mi_cb_vvb.VVB_selectie X);


INSERT INTO Mi_cb_vvb.VVB_mutaties_hist
SELECT A.* FROM Mi_temp.VVB_mutaties A;



INSERT INTO Mi_cb_vvb.DQ_VVB_CB
SELECT DATE AS Datum_aanlevering,
       A.Datum_gegevens AS Datum_gegevens,
       COUNT(*) AS Aantal,
       COUNT(DISTINCT Klant_nr_update) AS Aantal_klantnummers,
       SUM(CASE WHEN Bo_Business_line = 'CB' THEN 1 ELSE 0 END) AS Aantal_businessline_CB,
       SUM(CASE WHEN Bo_Business_line = 'C&IB' THEN 1 ELSE 0 END) AS Aantal_businessline_CIB,
       SUM(CASE WHEN NOT Bo_Business_line LIKE ANY ('CB', 'C&IBC') THEN 1 ELSE 0 END) AS Aantal_businessline_overig,
       SUM(BC_contracten) AS Aantal_BC_met_contracten,
       SUM(CASE WHEN ZEROIFNULL(BC_cca_am) <> 0 THEN 1 ELSE 0 END) AS Aantal_BC_met_CCA,
       SUM(ZEROIFNULL(A.Bc_FRenR_Restructuring_ind)) AS Aantal_BCs_FRenR_Restructuring,
       SUM(ZEROIFNULL(A.Bc_FRenR_Recovery_ind)) AS Aantal_BCs_FRenR_Recovery,
       SUM(ZEROIFNULL(A.Bc_Lindorff_ind)) AS Aantal_BCs_Lindorff,
       SUM(CASE WHEN Klant_nr IS NULL THEN 1 ELSE 0 END) AS Aantal_BCs_zonder_klantnummer,
       SUM(CASE WHEN BC_validatieniveau <> 4 THEN 1 ELSE 0 END) AS Aantal_BCs_valniveau_ongelijk_4,
       SUM(CASE WHEN BC_relatiecategorie = 20 THEN 1 ELSE 0 END) AS Aantal_BCs_relcat_gelijk_20,
       SUM(CASE WHEN Org_niveau1 = 'Onbekend' OR Org_niveau1 IS NULL THEN 1 ELSE 0 END) AS Aantal_BCs_organisatie_onbekend
  FROM Mi_cb_vvb.vVVB_selectie_CB A
 GROUP BY 1, 2;


	UPDATE MI_SAS_AA_MB_C_MB.VVB_Workflow
	FROM (SELECT bcnumber ,route FROM MI_SAS_AA_MB_C_MB.VVB_Workflow_stat)  b
	SET VVB_scope_stat = b.route
	WHERE bc_nr = b.bcnumber;



	UPDATE MI_SAS_AA_MB_C_MB.VVB_Workflow
	FROM (SELECT BC_Nummer , MAX(Risico_indicator_relatiemanager) AS Risico_indicator_relatiemanager FROM MI_SAS_AA_MB_C_MB.VVB_RM_risico_score GROUP BY 1)  b
	SET Risico_indicator_relatiemanager = b.Risico_indicator_relatiemanager
	WHERE bc_nr = b.BC_nummer;



	UPDATE MI_SAS_AA_MB_C_MB.VVB_Workflow
	SET Status_sequence_nr =
	  CASE
        	WHEN Status_unit  = 'Not_niet_in_behandeling' THEN 1
		WHEN Status_unit  = 'Niet_gestart' THEN 2
	       	WHEN Status_unit  = 'Klaar_voor_Unit' THEN  3
       		WHEN Status_unit  = 'In_behandeling_Unit' THEN 4
         	WHEN Status_unit  = 'In_behandeling_regisseur' THEN 5
		WHEN Status_unit  = 'Klaar_voor_analist' THEN 6
	    	WHEN Status_unit  = 'In_behandeling_analist' THEN 7
	       	WHEN Status_unit  = 'Toewijzen_Aan_Andere_Analist' THEN 8
	    	WHEN Status_unit  = 'Toewijzen_Andere_Analist_ivm_Full_RAF' THEN 9
	      	WHEN Status_unit  = 'In_behandeling_analist_full_RAF' THEN 10
	        WHEN Status_unit  = 'Informatie_opgevraggd' THEN 11
	     	WHEN Status_unit  = 'Advices_Compliance_Opgevraagd' THEN  12
 	    	WHEN Status_unit  = 'Klaar_voor_CARC' THEN 13
 	 	WHEN Status_unit  = 'Fiatteren_CARC' THEN 14
		WHEN Status_unit  = 'Klaar_voor_QC' THEN 15
  	    	WHEN Status_unit  = 'Kwaliteitscheck_RAF' THEN 16
         	WHEN Status_unit  = 'Klaar_voor_fiatteur' THEN 17
      		WHEN Status_unit  = 'Fiatteren' THEN 18
           	WHEN Status_unit  = 'Klaar_voor_RM' THEN 19
      		WHEN Status_unit  = 'Herstel_voorbereiding_RM' THEN  20
      		WHEN Status_unit  = 'Valideren_RM' THEN 21
       		WHEN Status_unit  = 'Terug_Naar_Analist_Door_RM' THEN 22
        	WHEN Status_unit  = 'Klaar_voor_administratieve_afhandeling' THEN 23
        	WHEN Status_unit  = 'In_administratieve_afhandeling_regisseur' THEN 24
       		WHEN Status_unit  = 'Afgehandeld' THEN 25
      		WHEN Status_unit  = 'Afgebroken' THEN 26
     		WHEN Status_unit  = 'Onbekend' THEN 0
       		WHEN Status_unit  IS NULL THEN 0
       		ELSE 0
	END ;




DELETE
FROM MI_SAS_AA_MB_C_MB.VVB_Selectie_Workflow_Hist
WHERE maand_nr = (SEL Maand_nr FROM MI_SAS_AA_MB_C_MB.Mia_periode GROUP BY 1) OR maand_nr is null
;


INSERT INTO MI_SAS_AA_MB_C_MB.VVB_Selectie_Workflow_Hist
SELECT A.Business_contact_nr,
       C.Maand_nr AS Maand_nr,Selectie,
       A.Bc_naam, A.Datum_gegevens,
       A.Klant_nr, Klant_nr_update, Leidend_business_contact_nr_update,
       Leidend_BC_naam_update, A.Aantal_bcs, Aantal_bcs_in_scope, Bo_business_line,
       A.Bc_bo_nr, A.Bc_bo_naam, A.Bc_cca_am, A.BC_cca_am_naam, A.Org_niveau3,
       A.Org_niveau2, A.Org_niveau1, A.Bc_startdatum, A.Bc_validatieniveau,
       A.Bc_verschijningsvorm, A.Bc_verschijningsvorm_oms, A.Bc_relatiecategorie,
       A.Bc_relatiecategorie_oms, A.Bc_clientgroep, Bc_clientgroep_oms,
       Bc_land_code, A.Bc_sbi_code_BCDB, A.Bc_sbi_oms_BCDB, A.CMB_sector,
       Bc_sub_ind, Bc_sub_eigenaar, A.Bc_klantlevenscyclus, A.Bc_contracten,
       A.Bc_ringfence_ind, A.Bc_ringfence, A.Bc_Risico_score,
     	C.BC_Risico_klasse_oms,
       XA.Risico_indicator_relatiemanager AS Bc_risico_score_herziend_oms,
       Datum_bc_risico_score,
       Datum_revisie_bc_risico_score, A.Bc_CRG, Bc_UCR, Bc_datum_Kredietrevisie,
       Bc_FRenR_Restructuring_ind, Bc_FRenR_Recovery_ind, A.Bc_Lindorff_ind,
       A.Bc_SEC_US_Person_oms, A.Bc_FATCA_US_Person_class, A.Bc_UBO_ind, A.Bc_factoring_oms,
	XA.VVB_scope_stat
  FROM MI_CB_VVB.VVB_selectie A
  LEFT OUTER JOIN ( SELECT  BC_nr,  MAX(Risico_indicator_relatiemanager) AS Risico_indicator_relatiemanager ,MAX( VVB_scope_stat) AS VVB_scope_stat, MAX(Status_unit ) AS Status_unit , MAX(Datum_status_aangepast) AS Datum_status_aangepast , MAX(Status_sequence_nr) AS Status_sequence_nr
			FROM MI_SAS_AA_MB_C_MB.VVB_Workflow
			GROUP BY 1) XA
	  	ON ( A.Business_contact_nr = XA.BC_nr)
   LEFT OUTER JOIN Mi_cmb.vMia_businesscontacts C
    ON A.Business_contact_nr = C.Business_contact_nr;

REPLACE VIEW MI_CMB.vVVB_Selectie_Workflow_Hist
AS SELECT A.*
FROM MI_SAS_AA_MB_C_MB.VVB_Selectie_Workflow_Hist A;