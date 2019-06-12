/* #DATASPOT-TERADATA
*/

INSERT INTO MI_TEMP.AACMB_Datum
VALUES
    (
  CURRENT_DATE
    )
;

CREATE TABLE Mi_temp.BC_bijzonder_beheer_ind
AS
(
SEL
     a.Bc_nr (INTEGER) AS Bc_nr
    ,MAX(Ind_soort_bijz_beheer) AS Ind_soort_bijz_beheer
FROM ( -- faciliteiten
      SEL
           b.Fac_Bc_nr (INTEGER) AS Bc_nr
          ,MAX(CASE WHEN b.Bijzonder_beheer_type LIKE '%Lindorff%' THEN 1 ELSE 2 END) AS Ind_soort_bijz_beheer
      FROM
           (    -- actieve Master faciliteiten met OOE ongelijk aan €0,- waarbij minimaal 1 onderliggende actieve faciliteit onder bijzonder beheer valt
            SEL
                 Master_faciliteit_ID
                ,Maand_nr
                ,MAX(Bijzonder_beheer_ind) AS Ind_Bijzonder_beheer
                ,MAX(CASE WHEN ZEROIFNULL(OOE) <> 0 THEN 1 ELSE 0 END) AS Ind_OOE
            FROM mi_cmb.vCIF_complex
            WHERE Fac_actief_ind = 1
              AND Maand_nr = (SEL MAX(Maand_nr) AS Maand_nr FROM mi_cmb.vCIF_complex)
            GROUP BY 1,2
            HAVING Ind_Bijzonder_beheer = 1 AND Ind_OOE = 1
           ) a

      INNER JOIN Mi_cmb.vCIF_Complex  b
         ON b.Maand_nr = a.Maand_nr
        AND b.Master_faciliteit_ID = a.Master_faciliteit_ID
        AND b.Fac_actief_ind = 1

      GROUP BY 1

      UNION

      SEL
           c.Draw_Bc_nr (INTEGER) AS Bc_nr
          ,MAX(CASE WHEN b.Bijzonder_beheer_type LIKE '%Lindorff%' THEN 1 ELSE 2 END) AS Ind_soort_bijz_beheer
      FROM
        (
            SEL
                 Master_faciliteit_ID
                ,Maand_nr
                ,MAX(Bijzonder_beheer_ind) AS Ind_Bijzonder_beheer
                ,MAX(CASE WHEN ZEROIFNULL(OOE) <> 0 THEN 1 ELSE 0 END) AS Ind_OOE
            FROM mi_cmb.vCIF_complex
            WHERE Fac_actief_ind = 1
              AND Maand_nr = (SEL MAX(Maand_nr) AS Maand_nr FROM mi_cmb.vCIF_complex)
            GROUP BY 1,2
            HAVING Ind_Bijzonder_beheer = 1 AND Ind_OOE = 1
           ) a

      INNER JOIN Mi_cmb.vCIF_Complex  b
         ON b.Maand_nr = a.Maand_nr
        AND b.Master_faciliteit_ID = a.Master_faciliteit_ID
        AND b.Fac_actief_ind = 1

      INNER JOIN mi_cmb.vcif_drawing c
         ON c.Master_faciliteit_id = b.Master_faciliteit_id
        AND c.Faciliteit_id = b.Faciliteit_id
        AND c.maand_nr = b.maand_nr
        AND c.draw_actief_ind = 1

      GROUP BY 1
     ) a
GROUP BY 1
) WITH DATA
UNIQUE PRIMARY INDEX (Bc_nr)
;

INSERT INTO Mi_temp.Mia_bc_info
SELECT A.Gerelateerd_party_id AS Klant_nr,
       A.Party_id AS Business_contact_nr,
       CAST(A.koppeling_id AS CHAR(15)) AS Koppeling_id_CC,
       CAST(M.koppeling_id AS CHAR(15)) AS Koppeling_id_CE,
       CAST(N.koppeling_id AS CHAR(15)) AS Koppeling_id_CG,
       A.Party_deelnemer_rol AS Deelnemer_rol,
       B.Segment_id AS Clientgroep,
       C.Segment_id AS Crg,
       D.Gerelateerd_party_id AS Bo_nr,
       J.Bu_code AS Bo_bu_code,
       J.Bu_decode_mi AS Bo_bu_decode_mi,
       E.Klant_validatie_niveau AS Validatie_niveau,
       CASE
       WHEN Clientgroep BETWEEN 1100 AND 1199 OR Clientgroep IN (1200, 1201, 1202, 1204, 1232) THEN F1.Gerelateerd_party_id
       WHEN Clientgroep BETWEEN 1200 AND 1299 THEN F2.Gerelateerd_party_id
       END AS Cca,
       CASE
       WHEN Clientgroep BETWEEN 1100 AND 1199 OR Clientgroep IN (1200, 1201, 1202, 1204, 1232) THEN F1.Bu_code
       WHEN Clientgroep BETWEEN 1200 AND 1299 THEN F2.Bu_code
       END AS Cca_bu_code,
       CASE
       WHEN Clientgroep BETWEEN 1100 AND 1199 OR Clientgroep IN (1200, 1201, 1202, 1204, 1232) THEN F1.Bu_decode_mi
       WHEN Clientgroep BETWEEN 1200 AND 1299 THEN F2.Bu_decode_mi
       END AS Cca_bu_decode_mi,
       G.Segment_id AS Relatiecategorie,
       H.Segment_id AS Verschijningsvorm,
       CASE WHEN J.Bu_code IN ('1R', '1C') THEN 1 ELSE 0 END AS DB_ind,
       CASE WHEN J.Bo_naam LIKE ('%LINDORFF%')   OR ZEROIFNULL(K.Ind_soort_bijz_beheer) = 1 THEN 1 ELSE 0 END Solveon_ind,
       CASE WHEN J.Bo_naam LIKE ('%BIJZ.%KRED%') OR ZEROIFNULL(K.Ind_soort_bijz_beheer) = 2 THEN 1 ELSE 0 END FRenR_ind,
       CASE
       WHEN L.surseance_ind = 'J' THEN 1
       WHEN L.surseance_ind = 'N' THEN 0
       ELSE NULL END
       AS Surseance_ind,
       CASE
       WHEN L.faillisement_ind = 'J' THEN 1
       WHEN L.faillisement_ind = 'N' THEN 0
       ELSE NULL END
       AS Faillissement_ind,
       CASE WHEN A.Party_deelnemer_rol = 1 THEN 1 ELSE 0 END AS Leidend_bc_ind,
       CASE WHEN I.Party_id IS NOT NULL THEN 1 ELSE 0 END AS In_nzdb,
       ZEROIFNULL(O.Xref_ind) AS Xref_ind,
       ZEROIFNULL(P.CMS_ind) AS CMS_ind,
       Q.GSRI_Goedgekeurd,
       Q.GSRI_goedgekeurd_lvl,
       Q.GSRI_Assessment_resultaat,
       Q.GSRI_Assessment_resultaat_lvl
  FROM Mi_vm_ldm.aParty_party_relatie A
  LEFT OUTER JOIN Mi_vm_ldm.aSegment_klant B
    ON A.Party_id = B.Party_id
   AND A.Party_sleutel_type = B.Party_sleutel_type
   AND B.Segment_type_code = 'cg'
  LEFT OUTER JOIN Mi_vm_ldm.aSegment_klant C
    ON A.Party_id = C.Party_id
   AND A.Party_sleutel_type = C.Party_sleutel_type
   AND C.Segment_type_code = 'crg'
  LEFT OUTER JOIN Mi_vm_ldm.aParty_party_relatie D
    ON A.Party_id = D.Party_id
   AND A.Party_sleutel_type = D.Party_sleutel_type
   AND D.Party_relatie_type_code = 'bobehr'
  LEFT OUTER JOIN Mi_vm_ldm.aKlant_prospect E
    ON A.Party_id = E.Party_id
   AND A.Party_sleutel_type = E.Party_sleutel_type
  LEFT OUTER JOIN (SELECT F.Party_id
                         ,F.Party_sleutel_type
                         ,F.Party_relatie_type_code
                         ,F.Gerelateerd_party_id
                         ,X.Bu_code
                         ,X.Bu_decode_mi
                     FROM Mi_vm_ldm.aParty_party_relatie F
                     LEFT OUTER JOIN Mi_vm_ldm.vBo_mi_part_zak X
                                 ON SUBSTR(F.Gerelateerd_party_id, 7, 6) = X.Party_id
                    WHERE F.Party_relatie_type_code = 'cltadv'
                    GROUP BY 1,2,3
                  QUALIFY RANK (F.Party_party_relatie_sdat DESC) = 1) F1
    ON A.Party_id = F1.Party_id
   AND A.Party_sleutel_type = F1.Party_sleutel_type
   AND F1.Party_relatie_type_code = 'cltadv'
  LEFT OUTER JOIN (SELECT F.Party_id
                         ,F.Party_sleutel_type
                         ,F.Party_relatie_type_code
                         ,F.Gerelateerd_party_id
                         ,X.Bu_code
                         ,X.Bu_decode_mi
                     FROM Mi_vm_ldm.aParty_party_relatie F
                     LEFT OUTER JOIN Mi_vm_ldm.vBo_mi_part_zak X
                                 ON SUBSTR(F.Gerelateerd_party_id, 7, 6) = X.Party_id
                    WHERE F.Party_relatie_type_code = 'relman'
                    GROUP BY 1,2,3
                  QUALIFY RANK (F.Party_party_relatie_sdat DESC) = 1) F2
    ON A.Party_id = F2.Party_id
   AND A.Party_sleutel_type = F2.Party_sleutel_type
   AND F2.Party_relatie_type_code = 'relman'
  LEFT OUTER JOIN Mi_vm_ldm.aSegment_klant G
    ON A.Party_id = G.Party_id
   AND G.Segment_type_code = 'relcat'
   AND A.Party_sleutel_type = G.Party_sleutel_type
  LEFT OUTER JOIN Mi_vm_ldm.aSegment_klant H
    ON A.Party_id = H.Party_id
   AND H.Segment_type_code = 'apptyp'
   AND A.Party_sleutel_type = H.Party_sleutel_type
  LEFT OUTER JOIN (SELECT A.Cbc_nr AS Party_id
                     FROM Mi_vm_nzdb.vCommercieel_business_contact A
                     JOIN Mi_vm_nzdb.vLU_Maand_Runs XX
                       ON A.Maand_nr = XX.Maand_nr AND XX.Lopende_maand_ind = 1) AS I
    ON A.Party_id = I.Party_id
  LEFT OUTER JOIN Mi_vm_ldm.vBo_mi_part_zak J
    ON D.Gerelateerd_party_id = J.Party_id
  LEFT OUTER JOIN Mi_temp.BC_bijzonder_beheer_ind K
    ON K.Bc_nr = A.Party_id

  LEFT OUTER JOIN  mi_vm_ldm.aExterne_Organisatie L
    ON A.party_id = L.party_id
   AND A.party_sleutel_type = L.party_sleutel_type
  LEFT OUTER JOIN (SELECT XA.Party_id,
                          XA.koppeling_id,
                          MAX(CASE WHEN XA.Party_deelnemer_rol = 1 THEN 1 ELSE NULL END) AS Party_deelnemer_rol
                   FROM Mi_vm_ldm.aParty_party_relatie XA
                   WHERE XA.Party_sleutel_type = 'BC'
                     AND XA.Party_relatie_type_code = 'CBCTCE'
                 QUALIFY RANK() OVER (PARTITION BY XA.Party_id ORDER BY XA.Koppeling_id) = 1
                   GROUP BY 1,2) AS M
    ON A.Party_id = M.Party_id
  LEFT OUTER JOIN (SELECT XA.Party_id,
                          XA.koppeling_id,
                          MAX(CASE WHEN XA.Party_deelnemer_rol = 1 THEN 1 ELSE NULL END) AS Party_deelnemer_rol
                   FROM Mi_vm_ldm.aParty_party_relatie XA
                   WHERE XA.Party_sleutel_type = 'CC'
                     AND XA.Party_relatie_type_code = 'CCTCG'
                 QUALIFY RANK() OVER (PARTITION BY XA.Party_id ORDER BY XA.Koppeling_id) = 1
                   GROUP BY 1,2) AS N
    ON A.Gerelateerd_party_id = N.Party_id
  LEFT OUTER JOIN  (SELECT party_id, 1 AS xref_ind
               FROM mi_vm_NZDB.vGBC_CROSSREF
               WHERE maand_nr = (SEL maand_nr FROM MI_SAS_AA_MB_C_MB.Mia_periode_NEW)
               AND xref_herkomst IN ('BCTT24','BCTSAB','BCTLCA','BCTCF2','BCTCF3','BCTCF4','BCTCF5')
               AND party_sleutel_type = 'BC'
               GROUP BY 1,2) O
    ON A.Party_id = O.party_id
   LEFT OUTER JOIN (SEL bc_nr, MAX(
                    CASE WHEN product_group_code = 'FXO' AND ZEROIFNULL(margin) <> 0 THEN 1
                    WHEN product_group_code <> 'FXO' AND product_group_code IS NOT NULL THEN 1
                    ELSE 0 END) AS CMS_ind
                FROM mi_cmb.smr_transaction
                WHERE maand_nr BETWEEN  (SEL maand_nr -100 FROM MI_SAS_AA_MB_C_MB.Mia_periode_NEW) AND (SEL maand_nr FROM MI_SAS_AA_MB_C_MB.Mia_periode_NEW)
                AND product_group_code IN ('MM Taken','FXO','FX','MM Given','IRD') -- voor deze producten is de  data gevalideerd, later aan te vullen met overige productgroepen uit de SMR transaction tabel

                GROUP BY 1) P
    ON A.Party_id = P.bc_nr
  LEFT JOIN
        (SELECT  Party_id
        ,CASE WHEN LENGTH(TRIM(Party_GSRI_goedgekeurd)) = 0 THEN NULL
                        ELSE TRIM(Party_GSRI_goedgekeurd) END AS GSRI_Goedgekeurd
        ,CASE WHEN GSRI_Goedgekeurd = 'HIGH' THEN 1
              WHEN GSRI_Goedgekeurd = 'MEDIUM' THEN 2
              WHEN GSRI_Goedgekeurd = 'LOW' THEN 3
              END AS GSRI_goedgekeurd_lvl
        ,CASE WHEN LENGTH(TRIM(Party_Assessment_resultaat)) = 0 THEN NULL
                        ELSE TRIM(Party_Assessment_resultaat) END AS GSRI_Assessment_resultaat
        ,CASE WHEN GSRI_Assessment_resultaat = 'ABOVE PAR' THEN 1
              WHEN GSRI_Assessment_resultaat = 'ON PAR' THEN 2
              WHEN GSRI_Assessment_resultaat = 'BELOW PAR' THEN 3
              END AS GSRI_Assessment_resultaat_lvl
        FROM MI_VM_LDM.aparty_gsri
     QUALIFY RANK() OVER (PARTITION BY Party_id ORDER BY Party_gsri_SDAT DESC, Gsri_expiratie_datum DESC) = 1) Q
    ON A.Party_id = Q.Party_id
 WHERE A.Party_sleutel_type = 'bc'
   AND A.Party_relatie_type_code = 'CBCTCC'
QUALIFY RANK() OVER (PARTITION BY A.Party_id ORDER BY A.Party_party_relatie_sdat DESC, A.Koppeling_id) = 1;

INSERT INTO Mi_temp.Mia_klant_info
SELECT A.Cc_nr AS Klant_nr,
       XX.Maand_nr AS Maand_nr,
       XX.Datum_gegevens AS Datum_gegevens,
       A.Cc_client_groep_code AS Clientgroep,
       E.Business_line,
       CASE
       WHEN E.business_line <> 'CIB' AND C.Mkb_klant_ind = 1 THEN 'C'
       WHEN Max_valniveau IN (1, 2) THEN 'S'
       WHEN Max_valniveau IN (3, 4) THEN 'C'
       ELSE NULL
       END AS Klantstatus,
       CASE WHEN E.business_line <> 'CIB' THEN ZEROIFNULL(C.Mkb_klant_ind)
       ELSE (CASE WHEN b.Xref_ind = 1 OR b.CMS_ind = 1 OR C.Mkb_klant_ind = 1 THEN 1 ELSE 0 END) END AS Klant_ind,
       B.Aantal_bcs,
       B.Aantal_bcs_in_scope,
       CASE WHEN B.Solveon_ind + B.FRenR_ind > 0 THEN 1 ELSE 0 END AS Bijzonder_beheer_ind,
       B.Surseance_ind,
       B.Faillissement_ind,
       B.GSRI_goedgekeurd_lvl,
       B.GSRI_Assessment_resultaat_lvl,
       B.Leidend_bc_ind,
       A.Leidend_cbc_oid AS Leidend_bc_nr,
       D.Cca
  FROM Mi_vm_nzdb.vCommercieel_cluster A
  JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW XX
    ON A.Maand_nr = XX.Maand_nr AND XX.Lopende_maand_ind = 1
  JOIN (SELECT XA.Klant_nr,
               MAX(XA.Validatieniveau) AS Max_valniveau,
               COUNT(*) AS Aantal_bcs,
               SUM(XA.In_nzdb) AS Aantal_bcs_in_scope,
               MAX(XA.Solveon_ind) AS Solveon_ind,
               MAX(XA.FRenR_ind) AS FRenR_ind,
               MAX(XA.Surseance_ind) AS Surseance_ind,
               MAX(XA.Faillissement_ind) AS Faillissement_ind,
               MAX(XA.Leidend_bc_ind) AS Leidend_bc_ind,
               MAX(XA.Xref_ind) AS Xref_ind,
               MAX(XA.CMS_ind) AS CMS_ind,
          MAX(GSRI_goedgekeurd_lvl) AS GSRI_goedgekeurd_lvl,
          MAX(GSRI_Assessment_resultaat_lvl) AS GSRI_Assessment_resultaat_lvl
          FROM Mi_temp.Mia_bc_info XA
         GROUP BY 1) AS B
    ON A.Cc_nr = B.Klant_nr
  LEFT OUTER JOIN Mi_vm_nzdb.vCross_sell_cc C
    ON A.Cc_nr = C.CC_nr AND A.Maand_nr = C.Maand_nr
  LEFT OUTER JOIN Mi_temp.Mia_bc_info D
    ON A.Leidend_cbc_oid = D.Business_contact_nr
  LEFT OUTER JOIN MI_SAS_AA_MB_C_MB.CGC_BASIS E
    ON A.Cc_client_groep_code = E.Clientgroep;

INSERT INTO Mi_temp.Mia_klantkoppelingen
SELECT A.Klant_nr,
       A.Maand_nr,
       B.Business_contact_nr,
       B.Koppeling_id_CC,
       B.Koppeling_id_CE,
       CASE
       WHEN A.Aantal_bcs = 1 OR A.Leidend_bc_ind = 1 THEN RANK( B.In_nzdb DESC, B.Leidend_bc_ind DESC, B.Business_contact_nr ASC ) - 1
       ELSE RANK( B.In_nzdb DESC, B.Leidend_bc_ind DESC, B.Business_contact_nr ASC )
       END AS Volgorde
  FROM Mi_temp.Mia_klant_info A
  LEFT OUTER JOIN Mi_temp.Mia_bc_info B
    ON A.Klant_nr = B.Klant_nr
   AND B.In_nzdb = 1
 GROUP BY 1, 2;

INSERT INTO Mi_temp.Mia_groepkoppelingen
SELECT
 A.Gerelateerd_party_id AS Groep_nr
,B.Maand_nr
,B.Klant_nr
,ZEROIFNULL(A.Party_deelnemer_rol) AS Leidende_klant_ind
,C.Koppeling_id_CC
,A.koppeling_id AS Koppeling_id_CG
FROM
(SELECT XA.Party_id,
                         XA.Gerelateerd_party_id,
                         XA.koppeling_id,
                          MAX(CASE WHEN XA.Party_deelnemer_rol = 1 THEN 1 ELSE NULL END) AS Party_deelnemer_rol
                   FROM Mi_vm_ldm.aParty_party_relatie XA
                   WHERE XA.Party_sleutel_type = 'CC'
                     AND XA.Party_relatie_type_code = 'CCTCG'
                     AND XA.Gerelateerd_party_id IS NOT NULL
                 QUALIFY RANK() OVER (PARTITION BY XA.Party_id ORDER BY XA.Koppeling_id) = 1
                   GROUP BY 1,2,3) AS A
INNER JOIN Mi_temp.Mia_klant_info B
ON A.Party_id = B.Klant_nr
LEFT OUTER JOIN Mi_temp.Mia_bc_info C
   ON A.Party_id = C.Klant_nr
   AND C.In_nzdb = 1
   AND C.Leidend_bc_ind = 1;

INSERT INTO Mi_temp.Mia_alle_bcs
SELECT X.Party_id AS Business_contact_nr,
       YY.Klant_nr,
       YY.Maand_nr,
       M.Naam AS Bc_naam,
       X.Party_start_datum AS Bc_startdatum,
       B.Segment_id AS Bc_clientgroep,
       C.Segment_id AS Bc_crg,
       D.Gerelateerd_party_id AS Bc_bo_nr,
       J.Bo_naam AS Bc_bo_naam,
       J.Bu_code AS Bc_bo_bu_code,
       J.Bu_decode_mi AS Bc_bo_bu_decode,
       E.Klant_validatie_niveau AS Bc_validatieniveau,
       F.Gerelateerd_party_id AS Bc_am,
       S.Gerelateerd_party_id AS Bc_rm,
       F.Bu_code AS Bc_cca_am_bu_code,
       F.Bu_decode_mi AS Bc_cca_am_bu_decode,
       S.Bu_code AS Bc_cca_rm_bu_code,
       S.Bu_decode_mi AS Bc_cca_rm_bu_decode,
       AO.Gerelateerd_party_id AS  Bc_cca_pb,
       G.Segment_id AS Bc_relatiecategorie,
       H.Segment_id AS Bc_verschijningsvorm,
       CAST(CAST(K.Gerelateerd_party_id AS FORMAT'-9(12)') AS CHAR(12)) AS Bc_kvk_nr,
       CASE WHEN SUBSTR(N.Post_adres_id, 1, 2) = 'NL' THEN SUBSTR(N.Post_adres_id, 3, 6) ELSE NULL END AS Bc_postcode,
       P.Segment_id AS Bc_SBI_code_bcdb,
       Q.Branche_code AS Bc_sbi_code_kvk,
       CASE WHEN O.Aantal_rekeningen > 0 THEN 1 ELSE 0 END AS Bc_contracten,
       AJ.Segment_oms AS Bc_klantlevenscyclus,
       CASE WHEN T.Party_deelnemer_rol = 1 THEN 1 ELSE 0 END AS Leidend_bc_ind,
      CASE WHEN AP.Party_deelnemer_rol = 1 THEN 1 ELSE 0 END AS Leidend_bc_pb_ind ,
	   A.Cc_nr,
       T.Koppeling_id AS Koppeling_id_CC,
       Y.Koppeling_id AS Koppeling_id_CE,
       Z.Koppeling_id AS Koppeling_id_CG,
       A.Fhh_nr,
       A.Pcnl_nr,
       CASE WHEN J.Bo_naam LIKE ('%LINDORFF%')   OR ZEROIFNULL(R.Ind_soort_bijz_beheer) = 1 THEN 1 ELSE 0 END Bc_Lindorff_ind,
       CASE WHEN J.Bo_naam LIKE ('%BIJZ.%KRED%') OR ZEROIFNULL(R.Ind_soort_bijz_beheer) = 2 THEN 1 ELSE 0 END FRenR_ind,
       CASE WHEN I.Party_id IS NOT NULL THEN 1 ELSE 0 END AS Bc_in_nzdb,
       CASE WHEN J.Bu_code IN ('1R', '1C') THEN 1 ELSE 0 END AS DB_ind,
       CASE WHEN M.Naam =  'RBS_KLANT' THEN 1 ELSE 0 END AS RBS_ind,
       CASE
       WHEN U.Segment_Id  IN ('02','03','06','07') THEN 0
       WHEN U.Segment_Id  IN ('01','04','05') THEN 1
       ELSE NULL END AS Bc_SEC_US_Person_ind,
       TRIM(V.Segment_Oms) AS Bc_SEC_US_Person_oms,
       CASE
       WHEN AG.fatca_status_code_party_oms IS NULL THEN 0
       WHEN AG.fatca_status_code_party = '09' THEN 0
       ELSE 1 END AS Bc_FATCA_US_Person_ind,
       TRIM(AG.fatca_status_code_party_oms) AS Bc_FATCA_US_Person_class,
       W.Klant_risico_score AS Bc_Risico_score,
	CASE
	WHEN lower(Bc_Risico_score) = '?' then 'Risicomodel niet nodig'
        WHEN lower(Bc_Risico_score) = '00' then 'Geen hit'
        WHEN lower(Bc_Risico_score) is null then 'Leeg'
        WHEN lower(Bc_Risico_score) in ('2c','1c') then 'Neutraal risico'
        WHEN lower(Bc_Risico_score) in ('1b','2b','3b','4b','5b','9b')  then 'Verhoogd risico'
        WHEN lower(Bc_Risico_score) in ('1a','2a','10','20') then 'Onacceptabel risico'
        ELSE 'CHECK'
    	END AS BC_Risico_klasse_oms,
       AA.Segment_oms AS Bc_WtClas,
       AB.Segment_oms AS Bc_AAClas,
       CASE WHEN TRIM(AD.Segment_oms) = 'Geen' THEN 'No' ELSE  SUBSTR(AD.Segment_oms,11,1) END AS Bc_Rente_drv,
       CASE WHEN TRIM(AC.Segment_oms) = 'Geen' THEN 'No' ELSE  SUBSTR(AC.Segment_oms,11,1) END AS Bc_Comm_drv,
       CASE WHEN TRIM(AE.Segment_oms) = 'Geen' THEN 'No' ELSE  SUBSTR(AE.Segment_oms,11,1) END AS Bc_Valuta_drv,
       CASE
       WHEN  AF.Segment_oms IS NULL THEN NULL
       WHEN SUBSTR(AF.Segment_oms,1,4) = 'Geen' THEN 'N' ELSE  'Y' END AS Bc_Overig_cms,
       AH.BC_GSRI_Goedgekeurd AS BC_GSRI_Goedgekeurd, --tijdelijk op NULL ivm foutieve informatie LDM
       AH.BC_GSRI_Assessment_resultaat AS BC_GSRI_Assessment_resultaat, --tijdelijk op NULL ivm foutieve informatie LDM
       AI.GBC_nr AS BC_GBC_nr,
       AI.GBC_Naam AS BC_GBC_Naam,
       AI.ULP_BC_nr AS BC_ULP_nr,
       AI.ULP_Naam AS BC_ULP_Naam,
			 AL.CCA as BC_CCA_TB,
			 CASE WHEN AM.Naam IS NULL OR AM.Naam = '' THEN 'Geen naam'
            ELSE ((CASE WHEN TRIM(AM.Voorletters) LIKE ANY ('', '-') THEN '' ELSE TRIM(AM.Voorletters)||' ' END)||
                  (CASE WHEN TRIM(AM.Voorvoegsels) = '' THEN '' ELSE TRIM(AM.Voorvoegsels)||' ' END)|| TRIM(AM.Naam))
            END AS BC_CCA_TB_NAAM,
       AN.Bo_naam AS BC_CCA_TB_TEAM,
       TR.Trust_complex_nr,
       FR.Franchise_complex_nr
  FROM Mi_vm_ldm.aParty X
  LEFT OUTER JOIN (SELECT XA.Party_id,
                          XA.Party_sleutel_type,
                          MAX(CASE WHEN XA.Party_relatie_type_code = 'CBCTCC' THEN XA.Gerelateerd_party_id END) AS Cc_nr,
                          MAX(CASE WHEN XA.Party_relatie_type_code = 'LIDFHH' THEN XA.Gerelateerd_party_id END) AS Fhh_nr,
                          MAX(CASE WHEN XA.Party_relatie_type_code = 'LDPCNL' THEN XA.Gerelateerd_party_id END) AS Pcnl_nr
                     FROM Mi_vm_ldm.aParty_party_relatie XA
                    WHERE XA.Party_sleutel_type = 'bc'
                      AND XA.Party_relatie_type_code IN ('CBCTCC', 'LIDFHH', 'LDPCNL')
                    GROUP BY 1, 2) AS A
    ON X.Party_id = A.Party_id
   AND X.Party_sleutel_type = A.Party_sleutel_type
  LEFT OUTER JOIN Mi_vm_ldm.aSegment_klant B
    ON X.Party_id = B.Party_id
   AND X.Party_sleutel_type = B.Party_sleutel_type
   AND B.Segment_type_code = 'cg'
  LEFT OUTER JOIN Mi_vm_ldm.aSegment_klant C
    ON X.Party_id = C.Party_id
   AND X.Party_sleutel_type = C.Party_sleutel_type
   AND C.Segment_type_code = 'crg'
  LEFT OUTER JOIN Mi_vm_ldm.aParty_party_relatie D
    ON X.Party_id = D.Party_id
   AND X.Party_sleutel_type = D.Party_sleutel_type
   AND D.Party_relatie_type_code = 'bobehr'
  LEFT OUTER JOIN Mi_vm_ldm.aKlant_prospect E
    ON X.Party_id = E.Party_id
   AND X.Party_sleutel_type = E.Party_sleutel_type
  LEFT OUTER JOIN (SELECT XA.Party_id,
                          XA.Party_sleutel_type,
                          XA.Party_relatie_type_code,
                          XA.Gerelateerd_party_id,
                          XB.Bu_code,
                          XB.Bu_decode_mi
                     FROM Mi_vm_ldm.aParty_party_relatie XA
                     LEFT OUTER JOIN Mi_vm_ldm.vBo_mi_part_zak XB
                       ON SUBSTR(XA.Gerelateerd_party_id, 7, 6) = XB.Party_id
                    WHERE XA.Party_relatie_type_code = 'cltadv'
                    GROUP BY 1,2,3
                  QUALIFY RANK (XA.Party_party_relatie_sdat DESC) = 1) F
    ON X.Party_id = F.Party_id
   AND X.Party_sleutel_type = F.Party_sleutel_type
   AND F.Party_relatie_type_code = 'cltadv'
  LEFT OUTER JOIN Mi_vm_ldm.aSegment_klant G
    ON X.Party_id = G.Party_id
   AND X.Party_sleutel_type = G.Party_sleutel_type
   AND G.Segment_type_code = 'relcat'
  LEFT OUTER JOIN Mi_vm_ldm.aSegment_klant H
    ON X.Party_id = H.Party_id
   AND X.Party_sleutel_type = H.Party_sleutel_type
   AND H.Segment_type_code = 'apptyp'
  LEFT OUTER JOIN (SELECT XA.Cbc_nr AS Party_id
                     FROM Mi_vm_nzdb.vCommercieel_business_contact XA
                     JOIN Mi_vm_nzdb.vLU_Maand_Runs XX
                       ON XA.Maand_nr = XX.Maand_nr AND XX.Lopende_maand_ind = 1) AS I
    ON X.Party_id = I.Party_id
  LEFT OUTER JOIN Mi_vm_ldm.vBo_mi_part_zak J
    ON D.Gerelateerd_party_id = J.Party_id

  LEFT OUTER JOIN (SELECT Party_id, Gerelateerd_party_id,  Party_sleutel_type, PARTY_PARTY_RELATIE_SDAT
                     FROM mi_vm_ldm.aParty_party_relatie
                     WHERE Party_relatie_type_code = 'kvkreg'
                     GROUP BY 1,2,3,4
                     QUALIFY RANK () OVER (PARTITION BY PARTY_ID ORDER BY PARTY_PARTY_RELATIE_SDAT, GERELATEERD_PARTY_ID DESC) = 1) k
    ON X.Party_id = K.Party_id
   AND X.Party_sleutel_type = K.Party_sleutel_type
  LEFT OUTER JOIN Mi_vm_ldm.aParty_naam M
    ON X.Party_id = M.Party_id
   AND X.Party_sleutel_type = M.Party_sleutel_type
  LEFT OUTER JOIN Mi_vm_ldm.aParty_post_adres N
    ON X.Party_id = N.Party_id
   AND X.Party_sleutel_type = N.Party_sleutel_type
   LEFT OUTER JOIN (SELECT XA.Party_id,
                          COUNT(*) AS Aantal_rekeningen
                     FROM Mi_vm_ldm.aParty_contract XA
                     JOIN Mi_vm_ldm.aContract XB
                       ON XA.Contract_nr = XB.Contract_nr
                      AND XA.Contract_soort_code = XB.Contract_soort_code
                      AND XA.Contract_hergebruik_volgnr = XB.Contract_hergebruik_volgnr
                      AND XA.Party_sleutel_type = 'bc'
                      AND XB.Contract_status_code NE 3
                      AND XA.Party_contract_rol_code = 'C'
                      AND XB.Product_id > 1
                      AND XB.Product_id NE 1259 /* Outputcontract */
                    GROUP BY 1) AS O
    ON X.Party_id = O.Party_id
  LEFT OUTER JOIN Mi_vm_ldm.aSegment_klant P
    ON X.Party_id = P.Party_id
   AND X.Party_sleutel_type = P.Party_sleutel_type
   AND P.Segment_type_code = 'sbi'
  LEFT OUTER JOIN (SELECT party_id, Party_sleutel_type, branche_code, ext_org_branche_sdat
                     FROM Mi_vm_ldm.vExterne_organisatie_bik
                     WHERE ext_org_branche_edat IS  NULL
                     AND Primary_branche_ind = 1
                     QUALIFY RANK() OVER (PARTITION BY party_id ORDER BY ext_org_branche_sdat, branche_code) = 1)  Q
    ON X.Party_id = Q.Party_id
   AND X.Party_sleutel_type = Q.Party_sleutel_type
  LEFT OUTER JOIN Mi_temp.BC_bijzonder_beheer_ind R
    ON X.Party_id = R.Bc_nr
  LEFT OUTER JOIN (SELECT XA.Party_id,
                          XA.Party_sleutel_type,
                          XA.Party_relatie_type_code,
                          XA.Gerelateerd_party_id,
                          XB.Bu_code,
                          XB.Bu_decode_mi
                     FROM Mi_vm_ldm.aParty_party_relatie XA
                     LEFT OUTER JOIN Mi_vm_ldm.vBo_mi_part_zak XB
                       ON SUBSTR(XA.Gerelateerd_party_id, 7, 6) = XB.Party_id
                    WHERE XA.Party_relatie_type_code = 'relman'
                    GROUP BY 1,2,3
                  QUALIFY RANK (XA.Party_party_relatie_sdat DESC) = 1) S
    ON X.Party_id = S.Party_id
   AND X.Party_sleutel_type = S.Party_sleutel_type
   AND S.Party_relatie_type_code = 'relman'
  LEFT OUTER JOIN Mi_temp.Mia_klantkoppelingen YY
    ON X.Party_id = YY.Business_contact_nr
  LEFT OUTER JOIN (
                   SELECT XA.Party_id,
                          XA.koppeling_id,
                          MAX(CASE WHEN XA.Party_deelnemer_rol = 1 THEN 1 ELSE NULL END) AS Party_deelnemer_rol
                     FROM Mi_vm_ldm.aParty_party_relatie XA
                    WHERE XA.Party_sleutel_type = 'BC'
                      AND XA.Party_relatie_type_code = 'CBCTCC'
                  QUALIFY RANK() OVER (PARTITION BY XA.Party_id ORDER BY XA.Koppeling_id) = 1
                    GROUP BY 1,2
                  ) AS T
  ON X.Party_id = T.Party_id
  LEFT OUTER JOIN (SELECT XA.Party_id,
                          XA.koppeling_id,
                          MAX(CASE WHEN XA.Party_deelnemer_rol = 1 THEN 1 ELSE NULL END) AS Party_deelnemer_rol
                   FROM Mi_vm_ldm.aParty_party_relatie XA
                   WHERE XA.Party_sleutel_type = 'BC'
                     AND XA.Party_relatie_type_code = 'CBCTCE'
                 QUALIFY RANK() OVER (PARTITION BY XA.Party_id ORDER BY XA.Koppeling_id) = 1
                   GROUP BY 1,2) AS Y
  ON X.Party_id = Y.Party_id
 LEFT OUTER JOIN (SELECT XA.Party_id,
                          XA.koppeling_id,
                          MAX(CASE WHEN XA.Party_deelnemer_rol = 1 THEN 1 ELSE NULL END) AS Party_deelnemer_rol
                   FROM Mi_vm_ldm.aParty_party_relatie XA
                   WHERE XA.Party_sleutel_type = 'CC'
                     AND XA.Party_relatie_type_code = 'CCTCG'
                 QUALIFY RANK() OVER (PARTITION BY XA.Party_id ORDER BY XA.Koppeling_id) = 1
                   GROUP BY 1,2) AS Z
 ON A.CC_NR = Z.Party_id
  LEFT OUTER JOIN Mi_vm_ldm.aSegment_klant U
     ON X.Party_id = U.Party_id
    AND X.Party_sleutel_type = U.Party_sleutel_type
    AND U.Segment_Type_Code = 'USPERS'
  LEFT OUTER JOIN Mi_vm_ldm.aSegment V
     ON U.Segment_Id = V.Segment_Id
    AND U.Segment_Type_Code = V.Segment_Type_Code
  LEFT OUTER JOIN mi_vm_ldm.aparty_fatca AG
     ON X.party_id = AG.party_id
    AND X.party_sleutel_type = AG.party_sleutel_type
  LEFT OUTER JOIN Mi_vm_ldm.aklant_prospect W
     ON X.party_id = W.party_id
    AND X.party_sleutel_type = W.party_sleutel_type
  LEFT OUTER JOIN (SELECT a.Party_id, a.Party_sleutel_type, b.Segment_oms
                   FROM Mi_vm_ldm.aSegment_klant a
                   LEFT OUTER JOIN Mi_vm_ldm.aSEGMENT b
                   ON a.Segment_Id= b.Segment_Id
                   AND a.Segment_Type_Code = b.Segment_Type_Code
                   WHERE  a.segment_type_code IN ('wtclas')
                   ) AA
     ON X.Party_id = AA.Party_id
    AND X.Party_sleutel_type = AA.Party_sleutel_type
  LEFT OUTER JOIN (SELECT a.Party_id, a.Party_sleutel_type, b.Segment_oms
                   FROM Mi_vm_ldm.aSegment_klant a
                   LEFT OUTER JOIN Mi_vm_ldm.aSEGMENT b
                   ON a.Segment_Id= b.Segment_Id
                   AND a.Segment_Type_Code = b.Segment_Type_Code
                   WHERE  a.segment_type_code IN ('aaclas')
                   ) AB
     ON X.Party_id = AB.Party_id
    AND X.Party_sleutel_type = AB.Party_sleutel_type
  LEFT OUTER JOIN (SELECT a.Party_id, a.Party_sleutel_type, b.Segment_oms
                   FROM Mi_vm_ldm.aSegment_klant a
                   LEFT OUTER JOIN Mi_vm_ldm.aSEGMENT b
                   ON a.Segment_Id= b.Segment_Id
                   AND a.Segment_Type_Code = b.Segment_Type_Code
                   WHERE  a.segment_type_code IN ('rntdrv')
                   ) AD
     ON X.Party_id = AD.Party_id
    AND X.Party_sleutel_type = AD.Party_sleutel_type
  LEFT OUTER JOIN (SELECT a.Party_id, a.Party_sleutel_type, b.Segment_oms
                   FROM Mi_vm_ldm.aSegment_klant a
                   LEFT OUTER JOIN Mi_vm_ldm.aSEGMENT b
                   ON a.Segment_Id= b.Segment_Id
                   AND a.Segment_Type_Code = b.Segment_Type_Code
                   WHERE  a.segment_type_code IN ('comdrv')
                   ) AC
     ON X.Party_id = AC.Party_id
    AND X.Party_sleutel_type = AC.Party_sleutel_type
  LEFT OUTER JOIN (SELECT a.Party_id, a.Party_sleutel_type, b.Segment_oms
                   FROM Mi_vm_ldm.aSegment_klant a
                   LEFT OUTER JOIN Mi_vm_ldm.aSEGMENT b
                   ON a.Segment_Id= b.Segment_Id
                   AND a.Segment_Type_Code = b.Segment_Type_Code
                   WHERE  a.segment_type_code IN ('valdrv')
                   ) AE
     ON X.Party_id = AE.Party_id
    AND X.Party_sleutel_type = AE.Party_sleutel_type
  LEFT OUTER JOIN (SELECT a.Party_id, a.Party_sleutel_type, b.Segment_oms
                   FROM Mi_vm_ldm.aSegment_klant a
                   LEFT OUTER JOIN Mi_vm_ldm.aSEGMENT b
                   ON a.Segment_Id= b.Segment_Id
                   AND a.Segment_Type_Code = b.Segment_Type_Code
                   WHERE  a.segment_type_code IN ('ovmkpr')
                   ) AF
     ON X.Party_id = AF.Party_id
    AND X.Party_sleutel_type = AF.Party_sleutel_type
  LEFT JOIN
        (SELECT  Party_id
        ,CASE WHEN LENGTH(TRIM(Party_GSRI_goedgekeurd)) = 0 THEN NULL ELSE TRIM(Party_GSRI_goedgekeurd) END AS BC_GSRI_Goedgekeurd
        ,CASE WHEN LENGTH(TRIM(Party_Assessment_resultaat)) = 0 THEN NULL ELSE TRIM(Party_Assessment_resultaat) END AS BC_GSRI_Assessment_resultaat
        FROM MI_VM_LDM.aparty_gsri
       QUALIFY RANK() OVER (PARTITION BY Party_id ORDER BY Party_gsri_SDAT DESC, Gsri_expiratie_datum DESC) = 1) AH
    ON X.Party_id = AH.Party_id
   AND x.Party_sleutel_type = 'BC'

  LEFT OUTER JOIN (SELECT a.party_id, a.GBC_nr, b.GBC_naam, c.ULP_BC_nr, d.ULP_naam
                   FROM
                    (SELECT XA.Party_id, XA.gerelateerd_party_id AS GBC_nr
                     FROM Mi_vm_ldm.aParty_party_relatie XA
                     WHERE XA.Party_sleutel_type = 'BC'
                     AND XA.Party_relatie_type_code = 'CBCGBC'
                     GROUP BY 1,2
                    ) A
                  LEFT OUTER JOIN
                    (SELECT party_id, TRIM(Naamregel_1)||TRIM(Naamregel_2)||TRIM(Naamregel_3) AS GBC_naam
                    FROM Mi_vm_ldm.aParty_naam
                    WHERE Party_sleutel_type = 'BC'
                    ) B
                  ON A.GBC_nr = B.party_id
                  LEFT OUTER JOIN
                    (SELECT  XA.Party_id, XA.gerelateerd_party_id AS ULP_BC_nr
                     FROM Mi_vm_ldm.aParty_party_relatie XA
                     WHERE XA.Party_relatie_type_code = 'GBCUP'
                     AND Party_sleutel_type = 'GB'
                     GROUP BY 1,2
                    ) C
                  ON A.GBC_nr = C.party_id
                  LEFT OUTER JOIN
                    (SELECT party_id, TRIM(Naamregel_1)||TRIM(Naamregel_2)||TRIM(Naamregel_3) AS ULP_naam
                     FROM Mi_vm_ldm.aParty_naam
                     WHERE Party_sleutel_type = 'BC'
                    ) D
                  ON C.ULP_BC_nr = D.PARTY_ID
  ) AS AI
  ON X.Party_id = AI.Party_id
  LEFT OUTER JOIN (SELECT XA.Party_id, XA.Party_sleutel_type, XA.Segment_id, XB.Segment_oms
                     FROM Mi_vm_ldm.aSegment_klant XA
                     LEFT OUTER JOIN Mi_vm_ldm.aSegment XB
                       ON XA.Segment_Id = XB.Segment_Id
                      AND XA.Segment_Type_Code = XB.Segment_Type_Code
                    WHERE XA.Segment_type_code = 'CULICY') AJ
     ON X.Party_id = AJ.Party_id
    AND X.Party_sleutel_type = AJ.Party_sleutel_type
  LEFT OUTER JOIN (SELECT XA.Party_id, XA.Party_sleutel_type, XA.Segment_id, XB.Segment_oms
                     FROM Mi_vm_ldm.aSegment_klant XA
                     LEFT OUTER JOIN Mi_vm_ldm.aSegment XB
                       ON XA.Segment_Id = XB.Segment_Id
                      AND XA.Segment_Type_Code = XB.Segment_Type_Code
                    WHERE XA.Segment_type_code = 'RIFENC') AK
     ON X.Party_id = AK.Party_id
    AND X.Party_sleutel_type = AK.Party_sleutel_type
  LEFT OUTER JOIN (SELECT XA.Party_id AS Business_contact_nr,
                                  XA.Gerelateerd_party_id AS CCA
                             FROM Mi_vm_ldm.aParty_party_relatie XA
                            WHERE XA.Party_relatie_type_code = 'CTSCT'
                              AND XA.Gerelateerd_party_sleutel_type = 'AM'
                           QUALIFY RANK () OVER (PARTITION BY XA.Party_id ORDER BY XA.Gerelateerd_party_id DESC) = 1) AL
    ON X.Party_id = AL.Business_contact_nr
  LEFT OUTER JOIN Mi_vm_ldm.aParty_naam AM
    ON AL.CCA = AM.Party_id AND AM.Party_sleutel_type = 'AM'
  LEFT OUTER JOIN Mi_vm_ldm.vBo_mi_part_zak AN
    ON SUBSTR(AL.CCA, 7, 6) = AN.Party_id
  LEFT JOIN (SELECT  R.party_id,
        R.Gerelateerd_party_id AS Trust_complex_nr
        FROM MI_VM_LDM.aPARTY_PARTY_RELATIE R
        WHERE   R.party_relatie_type_code  = 'DVNTTK') AS TR
   ON TR.party_id = X.Party_id
   LEFT JOIN (SELECT  R.party_id,
        R.Gerelateerd_party_id AS Franchise_complex_nr
        FROM MI_VM_LDM.aPARTY_PARTY_RELATIE R
        WHERE   R.party_relatie_type_code = 'FRNCSE') AS FR
   ON FR.party_id = X.Party_id
LEFT OUTER JOIN (SELECT XA.Party_id,
                          XA.Party_sleutel_type,
                          XA.Party_relatie_type_code,
                          XA.Gerelateerd_party_id AS Gerelateerd_party_id
                     FROM Mi_vm_ldm.aParty_party_relatie XA
                     WHERE XA.Party_relatie_type_code = 'PRVBNK'
                    GROUP BY 1,2,3
                  QUALIFY RANK (XA.Party_party_relatie_sdat DESC) = 1)  AO
    ON X.Party_id = AO.Party_id
   AND X.Party_sleutel_type = AO.Party_sleutel_type
  LEFT OUTER JOIN (
                   SELECT XA.Party_id,
                          XA.koppeling_id,
                          MAX(CASE WHEN XA.Party_deelnemer_rol = 1 THEN 1 ELSE NULL END) AS Party_deelnemer_rol
                     FROM Mi_vm_ldm.aParty_party_relatie XA
                    WHERE XA.Party_sleutel_type = 'BC'
                      AND XA.Party_relatie_type_code = 'LDPCNL'
                  QUALIFY RANK() OVER (PARTITION BY XA.Party_id ORDER BY XA.Koppeling_id) = 1
                    GROUP BY 1,2
                  ) AS AP
  ON X.Party_id = AP.Party_id
 WHERE X.Party_sleutel_type = 'BC';

INSERT INTO Mi_temp.Mia_baten_product
SELECT A.Party_id,
       A.Party_sleutel_type,
       A.Maand_nr,
       A.Banktype,
       A.Combiproductlevel,
       A.Prod_naam,
       A.Baten
  FROM Mi_cmb.baten_product A
  JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW X
    ON A.Maand_nr >= X.Maand_begin_jaar_ervoor AND A.Maand_nr <= X.Maand_einde_jaar;

INSERT INTO Mi_temp.Mia_baten_detail
SELECT A.Klant_nr,
       A.Maand_nr,
       D.CUBe_product_id,
       E.Maand_nr AS Baten_maand,
       F.Volgorde,
       G.Maand_SDAT AS Datum_baten,
       SUM(E.Baten) AS Baten_totaal
  FROM Mi_temp.Mia_klant_info A
  JOIN MI_SAS_AA_MB_C_MB.CUBe_productdetail B
    ON 1 = 1
  JOIN Mi_temp.Mia_klantkoppelingen C
    ON A.Klant_nr = C.Klant_nr AND A.Maand_nr = C.Maand_nr
  JOIN MI_SAS_AA_MB_C_MB.CUBe_productdetail D
    ON B.CUBe_product_id = D.CUBe_product_id
  JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW X
    ON A.Maand_nr = X.Maand_nr
  JOIN Mi_temp.Mia_baten_product E
    ON C.Business_contact_nr = E.Party_id /* AND E.Party_sleutel_type = 'BC' */ AND E.Combiproductlevel = B.Productlevel2code AND E.Combiproductlevel = D.Productlevel2code
   AND E.Maand_nr > X.Maand_begin_jaar_ervoor AND E.Maand_nr <= X.Maand_einde_jaar
  LEFT OUTER JOIN (SELECT Maand AS Maand_nr,
                          RANK(Maand DESC) AS Volgorde
                     FROM Mi_vm.vLu_maand A
                     JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW B
                       ON A.Maand > B.Maand_begin_jaar_ervoor AND A.Maand <= B.Maand_einde_jaar) AS F
    ON E.Maand_nr = F.Maand_nr
  LEFT OUTER JOIN Mi_vm.vLu_maand G
    ON E.Maand_nr = G.Maand
 GROUP BY 1, 2, 3, 4, 5, 6;

INSERT INTO Mi_temp.Mia_baten
SELECT A.Klant_nr,
       A.Maand_nr,
       B.CUBe_product_id,
       SUM(CASE WHEN C.Volgorde >= 13 THEN 0.00 ELSE ZEROIFNULL(C.Baten_totaal) END) AS Baten,
       SUM(CASE WHEN C.Volgorde <= 12 THEN 0.00 ELSE ZEROIFNULL(C.Baten_totaal) END) AS Baten_ervoor,
       SUM(CASE WHEN C.Volgorde = 24 THEN C.Baten_totaal ELSE 0 END) AS Baten_mnd24,
       SUM(CASE WHEN C.Volgorde = 23 THEN C.Baten_totaal ELSE 0 END) AS Baten_mnd23,
       SUM(CASE WHEN C.Volgorde = 22 THEN C.Baten_totaal ELSE 0 END) AS Baten_mnd22,
       SUM(CASE WHEN C.Volgorde = 21 THEN C.Baten_totaal ELSE 0 END) AS Baten_mnd21,
       SUM(CASE WHEN C.Volgorde = 20 THEN C.Baten_totaal ELSE 0 END) AS Baten_mnd20,
       SUM(CASE WHEN C.Volgorde = 19 THEN C.Baten_totaal ELSE 0 END) AS Baten_mnd19,
       SUM(CASE WHEN C.Volgorde = 18 THEN C.Baten_totaal ELSE 0 END) AS Baten_mnd18,
       SUM(CASE WHEN C.Volgorde = 17 THEN C.Baten_totaal ELSE 0 END) AS Baten_mnd17,
       SUM(CASE WHEN C.Volgorde = 16 THEN C.Baten_totaal ELSE 0 END) AS Baten_mnd16,
       SUM(CASE WHEN C.Volgorde = 15 THEN C.Baten_totaal ELSE 0 END) AS Baten_mnd15,
       SUM(CASE WHEN C.Volgorde = 14 THEN C.Baten_totaal ELSE 0 END) AS Baten_mnd14,
       SUM(CASE WHEN C.Volgorde = 13 THEN C.Baten_totaal ELSE 0 END) AS Baten_mnd13,
       SUM(CASE WHEN C.Volgorde = 12 THEN C.Baten_totaal ELSE 0 END) AS Baten_mnd12,
       SUM(CASE WHEN C.Volgorde = 11 THEN C.Baten_totaal ELSE 0 END) AS Baten_mnd11,
       SUM(CASE WHEN C.Volgorde = 10 THEN C.Baten_totaal ELSE 0 END) AS Baten_mnd10,
       SUM(CASE WHEN C.Volgorde =  9 THEN C.Baten_totaal ELSE 0 END) AS Baten_mnd09,
       SUM(CASE WHEN C.Volgorde =  8 THEN C.Baten_totaal ELSE 0 END) AS Baten_mnd08,
       SUM(CASE WHEN C.Volgorde =  7 THEN C.Baten_totaal ELSE 0 END) AS Baten_mnd07,
       SUM(CASE WHEN C.Volgorde =  6 THEN C.Baten_totaal ELSE 0 END) AS Baten_mnd06,
       SUM(CASE WHEN C.Volgorde =  5 THEN C.Baten_totaal ELSE 0 END) AS Baten_mnd05,
       SUM(CASE WHEN C.Volgorde =  4 THEN C.Baten_totaal ELSE 0 END) AS Baten_mnd04,
       SUM(CASE WHEN C.Volgorde =  3 THEN C.Baten_totaal ELSE 0 END) AS Baten_mnd03,
       SUM(CASE WHEN C.Volgorde =  2 THEN C.Baten_totaal ELSE 0 END) AS Baten_mnd02,
       SUM(CASE WHEN C.Volgorde =  1 THEN C.Baten_totaal ELSE 0 END) AS Baten_mnd01
  FROM Mi_temp.Mia_klant_info A
  JOIN MI_SAS_AA_MB_C_MB.CUBe_producten B
    ON 1 = 1
  LEFT OUTER JOIN Mi_temp.Mia_baten_detail C
    ON A.Klant_nr = C.Klant_nr AND B.CUBe_product_id = C.CUBe_product_id
 GROUP BY 1, 2, 3;

INSERT INTO Mi_temp.Mia_klantbaten
SELECT A.Klant_nr,
       A.Maand_nr,
       SUM(A.Baten) AS BatenX,
       SUM(A.Baten_jaar_ervoor) AS Baten_jaar_ervoor,
       SUM(A.Baten_mnd24) AS Baten_mnd24X,
       SUM(A.Baten_mnd23) AS Baten_mnd23X,
       SUM(A.Baten_mnd22) AS Baten_mnd22X,
       SUM(A.Baten_mnd21) AS Baten_mnd21X,
       SUM(A.Baten_mnd20) AS Baten_mnd20X,
       SUM(A.Baten_mnd19) AS Baten_mnd19X,
       SUM(A.Baten_mnd18) AS Baten_mnd18X,
       SUM(A.Baten_mnd17) AS Baten_mnd17X,
       SUM(A.Baten_mnd16) AS Baten_mnd16X,
       SUM(A.Baten_mnd15) AS Baten_mnd15X,
       SUM(A.Baten_mnd14) AS Baten_mnd14X,
       SUM(A.Baten_mnd13) AS Baten_mnd13X,
       SUM(A.Baten_mnd12) AS Baten_mnd12X,
       SUM(A.Baten_mnd11) AS Baten_mnd11X,
       SUM(A.Baten_mnd10) AS Baten_mnd10X,
       SUM(A.Baten_mnd09) AS Baten_mnd09X,
       SUM(A.Baten_mnd08) AS Baten_mnd08X,
       SUM(A.Baten_mnd07) AS Baten_mnd07X,
       SUM(A.Baten_mnd06) AS Baten_mnd06X,
       SUM(A.Baten_mnd05) AS Baten_mnd05X,
       SUM(A.Baten_mnd04) AS Baten_mnd04X,
       SUM(A.Baten_mnd03) AS Baten_mnd03X,
       SUM(A.Baten_mnd02) AS Baten_mnd02X,
       SUM(A.Baten_mnd01) AS Baten_mnd01X,
       CASE
       WHEN Baten_mnd12X NE 0.00 THEN 12
       WHEN Baten_mnd11X NE 0.00 THEN 11
       WHEN Baten_mnd10X NE 0.00 THEN 10
       WHEN Baten_mnd09X NE 0.00 THEN 9
       WHEN Baten_mnd08X NE 0.00 THEN 8
       WHEN Baten_mnd07X NE 0.00 THEN 7
       WHEN Baten_mnd06X NE 0.00 THEN 6
       WHEN Baten_mnd05X NE 0.00 THEN 5
       WHEN Baten_mnd04X NE 0.00 THEN 4
       WHEN Baten_mnd03X NE 0.00 THEN 3
       WHEN Baten_mnd02X NE 0.00 THEN 2
       WHEN Baten_mnd01X NE 0.00 THEN 1
       ELSE 12
       END AS N_maanden_baten,
       BatenX*(12.0000/N_maanden_baten) AS Baten_gecorrigeerd
  FROM Mi_temp.Mia_baten A
 GROUP BY 1, 2;

CREATE TABLE Mi_temp.Complex_prod_GKDB_12mnd
AS
(
SEL
      a.Party_id                                       AS BC_nr
     ,b.Code_complex_product
     ,'GKDB - ' || TRIM(BOTH FROM b.Product_naam) (VARCHAR(40)) AS Product_naam
     ,SUM(ZEROIFNULL(a.Baten))                       AS Baten
     ,SUM(ZEROIFNULL(a.Baten_12mnd))                 AS Baten_12mnd
     ,a.Maand_nr                                     AS Maand_baten

FROM mi_cmb.baten_product_12mnd a

INNER JOIN (SELECT  combiproductlevel
                   ,Code_complex_product
                   ,MAX(ProductLevel2Description) AS Product_naam
            FROM MI_SAS_AA_MB_C_MB.LU_Complexe_producten
            GROUP BY 1,2
           ) b
   ON a.combiproductlevel = b.combiproductlevel

WHERE a.Party_sleutel_type = 'BC'
  AND a.Maand_nr = (SELECT MAX(Maand_nr) FROM mi_cmb.baten_product_12mnd)
  AND (ZEROIFNULL(a.Baten_12mnd) (DECIMAL(18,2)) ) <> 0                /* baten zijn in FLOAT, hele kleine bedragen er tussen */
GROUP BY 1,2,3,6
) WITH DATA
PRIMARY INDEX(BC_nr)
;

CREATE TABLE Mi_temp.Complex_prod_MIND
AS
(
SEL   b.Party_id AS BC_nr
     ,CASE
          WHEN a.Product_id = 1602          THEN 'E'
        END AS Code_complex_product
     ,CASE
          WHEN a.Product_id = 1602          THEN c.Product_naam_extern /*AOL*/
        END (VARCHAR(40)) AS Product_naam
     ,COUNT(DISTINCT a.Contract_nr) AS N_contracten
     ,MAX(a.Contract_nr)            AS MAX_contract_nr
FROM Mi_vm_ldm.aContract    a

INNER JOIN Mi_vm_ldm.aParty_contract    b
   ON b.Contract_nr = a.Contract_nr
  AND b.contract_soort_code = a.contract_soort_code
  AND b.contract_hergebruik_volgnr = a.contract_hergebruik_volgnr
  AND b.Party_sleutel_type = 'BC'
  AND b.Party_contract_rol_code = 'C'

LEFT OUTER JOIN mi_vm_ldm.aProduct  c
   ON c.product_id = a.Product_id

WHERE a.contract_status_code <> 3
  AND a.Product_id IN (1602)
GROUP BY 1,2,3
) WITH DATA
PRIMARY INDEX(BC_nr)
;

CREATE TABLE Mi_temp.Complex_GRV102030
AS
(
SEL   b.Party_id AS BC_nr
     ,'J'        AS Code_complex_product
     ,CASE
          WHEN a.Herkomst_admin_key_soort_code = 'GRV' AND TRIM(a.Herkomst_administratie_key) = '10' THEN 'GRV 010'
        END (VARCHAR(40)) AS Product_naam
     ,NULL AS Ind_krediet
     ,COUNT(DISTINCT a.Contract_nr) AS N_contracten
     ,MAX(a.Contract_nr)            AS MAX_contract_nr
FROM Mi_vm_ldm.aContract    a
INNER JOIN Mi_vm_ldm.aParty_contract    b
   ON b.Contract_nr = a.Contract_nr
  AND b.contract_soort_code = a.contract_soort_code
  AND b.contract_hergebruik_volgnr = a.contract_hergebruik_volgnr
  AND b.Party_sleutel_type = 'BC'
  AND b.Party_contract_rol_code = 'C'
WHERE a.contract_status_code <> 3
  AND a.Herkomst_admin_key_soort_code = 'GRV'
  AND TRIM(a.Herkomst_administratie_key) = '10'        /* particulier RC altijd als complex beschouwen */

GROUP BY 1,2,3
) WITH DATA
PRIMARY INDEX(BC_nr)
;

CREATE TABLE Mi_temp.Complex_prod_Kred
AS
(
SEL
      TO_NUMBER(a.Fac_BC_nr)  (INTEGER)             AS BC_nr
     ,'B'                                           AS Code_complex_product
     ,'Maatwerk Krediet'              (VARCHAR(40)) AS Product_naam
     ,COUNT(DISTINCT a.Fac_Contract_nr)             AS N_contracten
     ,MAX(TO_NUMBER(a.Fac_Contract_nr) (INTEGER))   AS MAX_contract_nr
     ,a.Maand_nr                                    AS Maand_Kredieten
FROM Mi_cmb.vCIF_complex a
WHERE a.Fac_actief_ind = 1
  AND NOT a.Fac_BC_nr IS NULL
  AND NOT a.Fac_Contract_nr IS NULL
  AND SUBSTR(TRIM(PL_NPL_type),1,3) = 'NPL'
  AND ZEROIFNULL(OOE) > 0
  AND a.Maand_nr = (SEL MAX(Maand_nr) AS Maand_nr FROM Mi_cmb.vCIF_complex)
GROUP BY 1,2,3,6
) WITH DATA
PRIMARY INDEX(BC_nr)
;

CREATE TABLE Mi_temp.Complex_prod_beleggen
AS
(
SEL
      a.cBC_nr                                      AS BC_nr
     ,'L'                                           AS Code_complex_product
     ,'Beleggen met advies'           (VARCHAR(40)) AS Product_naam
     ,COUNT(DISTINCT a.Contract_nr)                 AS N_contracten
     ,MAX(a.Contract_nr)                            AS MAX_contract_nr

FROM mi_vm_nzdb.vEff_Contract_Feiten_Periode   a
WHERE NOT a.Service_concept_naam LIKE '%ZELF%'
  AND NOT a.Service_concept_naam = 'EXECUTION ONLY'
  AND a.Maand_nr = (SEL MAX(Maand_nr) AS Maand_nr FROM mi_vm_nzdb.vEff_Contract_Feiten_Periode)
  AND a.Standaard_contract_ind = 1
GROUP BY 1,2,3
) WITH DATA
PRIMARY INDEX(BC_nr)
;
.IF ERRORCODE <> 0 THEN .GOTO EOP

INSERT INTO Mi_temp.CIAA_TRC_REK_COURANT
SELECT
       0
      ,Maand_nr
      ,Contract_nr
      ,Ind_EURIBOR_rente
      ,Ind_rentecompensatie
FROM MI_SAS_AA_MB_C_MB.CIAA_TRC_REK_COURANT
;

INSERT INTO MI_temp.CIAA_TRC_REK_COURANT
SELECT
       1
      ,Maand_nr
      ,Contract_nr
      ,Ind_EURIBOR_rente
      ,Ind_rentecompensatie
FROM MI_cmb.TRC_REK_COURANT
;

INSERT INTO MI_SAS_AA_MB_C_MB.CIAA_TRC_REK_COURANT
SEL
       Maand_nr
      ,Contract_nr
      ,Ind_EURIBOR_rente
      ,Ind_rentecompensatie
FROM MI_temp.CIAA_TRC_REK_COURANT
QUALIFY RANK (Mi_cmb_ind DESC) = 1
;

CREATE TABLE Mi_temp.Complex_prod_RC
AS
(
SEL
      b.Party_id                                     AS BC_nr
     ,'H'                                           AS Code_complex_product
     ,'RC EURIBOR rente'              (VARCHAR(40)) AS Product_naam
     ,COUNT(DISTINCT a.Contract_nr)                 AS N_contracten
     ,MAX(a.Contract_nr)                            AS MAX_contract_nr
FROM MI_SAS_AA_MB_C_MB.CIAA_TRC_REK_COURANT a
INNER JOIN mi_vm_ldm.aParty_contract    b
   ON b.Contract_nr = a.Contract_nr
  AND b.Party_sleutel_type = 'BC'
  AND b.Party_contract_rol_code = 'C'
INNER JOIN  Mi_vm_ldm.aContract    c
    ON b.Contract_nr = c.Contract_nr
  AND b.contract_soort_code = c.contract_soort_code
  AND b.contract_hergebruik_volgnr = c.contract_hergebruik_volgnr
WHERE a.Ind_EURIBOR_rente = 1
  AND c.contract_status_code <> 3
  AND b.contract_soort_code = 5
GROUP BY 1,2,3
) WITH DATA
PRIMARY INDEX(BC_nr)
;

INSERT INTO Mi_temp.Complex_prod_RC
SEL
      b.Party_id                                     AS BC_nr
     ,'F'                                           AS Code_complex_product
     ,'RC rentecompensatie'           (VARCHAR(40)) AS Product_naam
     ,COUNT(DISTINCT a.Contract_nr)                 AS N_contracten
     ,MAX(a.Contract_nr)                            AS MAX_contract_nr
FROM MI_SAS_AA_MB_C_MB.CIAA_TRC_REK_COURANT a

INNER JOIN mi_vm_ldm.aParty_contract    b
   ON b.Contract_nr = a.Contract_nr
  AND b.Party_sleutel_type = 'BC'
  AND b.Party_contract_rol_code = 'C'

INNER JOIN  Mi_vm_ldm.aContract    c
    ON b.Contract_nr = c.Contract_nr
  AND b.contract_soort_code = c.contract_soort_code
  AND b.contract_hergebruik_volgnr = c.contract_hergebruik_volgnr

WHERE a.Ind_rentecompensatie = 1
  AND c.contract_status_code <> 3
  AND b.contract_soort_code = 5
GROUP BY 1,2,3
;

CREATE TABLE Mi_temp.Complex_prod_RC_mtwrk
AS
(
SEL BC_number                        AS BC_nr
     ,'I'                                                   AS Code_complex_product
     ,'Maatwerk tarifering betalingsverkeer'  (VARCHAR(40)) AS Product_naam

FROM Mi_cmb.Tb_offers A  /* bestand wordt periodiek door Peter ververst (afkomstig op aanvraag uit GT)
                              1. BCnr waarbij Bankreknr NIET is gevuld dan maarwerk op ALLE betaalcontracten van het BC
                              2. Is het Banknr wel gevuld dan zijn het maatwerkafspraken specifiek voor het desbetreffende contract
                              Zowel 1. als 2. kunnen gelijktijdig voorkomen (alles onder maarwerk met afwijkende maatwerkafspraken voor specifieke contract(en)
                            */
LEFT OUTER JOIN  mi_cmb.pvdv_offer_oms B
ON A.offer_code = B.offer_code
WHERE COALESCE (offer_oms, 'x') NOT LIKE 'PIN-in-1%'
GROUP BY 1,2,3
) WITH DATA
PRIMARY INDEX(BC_nr)
;

CREATE TABLE Mi_temp.Complex_product
AS
(
SEL  a.Klant_nr
    ,a.Maand_nr
    ,b.BC_nr
    ,b.Code_complex_product (CHAR(1)) AS Code_complex_product
    ,b.Product_naam   (CHAR(30)) AS Product_naam

FROM Mi_temp.Mia_klantkoppelingen    a

INNER JOIN Mi_temp.Complex_prod_GKDB_12mnd         b
  ON b.BC_nr = a.Business_Contact_nr

GROUP BY 1,2,3,4,5
) WITH DATA
PRIMARY INDEX (Klant_nr, Maand_nr)
;

INSERT INTO Mi_temp.Complex_product
SEL  a.Klant_nr
    ,a.Maand_nr
    ,b.BC_nr
    ,b.Code_complex_product (CHAR(1)) AS Code_complex_product
    ,b.Product_naam

FROM Mi_temp.Mia_klantkoppelingen    a

INNER JOIN Mi_temp.Complex_prod_MIND        b
  ON b.BC_nr = a.Business_Contact_nr

GROUP BY 1,2,3,4,5
;

INSERT INTO Mi_temp.Complex_product
SEL  a.Klant_nr
    ,a.Maand_nr
    ,b.BC_nr
    ,b.Code_complex_product (CHAR(1)) AS Code_complex_product
    ,b.Product_naam

FROM Mi_temp.Mia_klantkoppelingen    a

INNER JOIN Mi_temp.Complex_GRV102030    b
  ON b.BC_nr = a.Business_Contact_nr

GROUP BY 1,2,3,4,5
;

INSERT INTO Mi_temp.Complex_product
SEL  a.Klant_nr
    ,a.Maand_nr
    ,b.BC_nr
    ,b.Code_complex_product (CHAR(1)) AS Code_complex_product
    ,b.Product_naam

FROM Mi_temp.Mia_klantkoppelingen    a

INNER JOIN Mi_temp.Complex_prod_Kred         b
  ON b.BC_nr = a.Business_Contact_nr

GROUP BY 1,2,3,4,5
;

INSERT INTO Mi_temp.Complex_product
SEL  a.Klant_nr
    ,a.Maand_nr
    ,b.BC_nr
    ,b.Code_complex_product (CHAR(1)) AS Code_complex_product
    ,b.Product_naam

FROM Mi_temp.Mia_klantkoppelingen    a

INNER JOIN Mi_temp.Complex_prod_RC        b
  ON b.BC_nr = a.Business_Contact_nr

GROUP BY 1,2,3,4,5
;

INSERT INTO Mi_temp.Complex_product
SEL  a.Klant_nr
    ,a.Maand_nr
    ,b.BC_nr
    ,b.Code_complex_product (CHAR(1)) AS Code_complex_product
    ,b.Product_naam

FROM Mi_temp.Mia_klantkoppelingen a

INNER JOIN Mi_temp.Complex_prod_beleggen b
  ON b.BC_nr = a.Business_Contact_nr

GROUP BY 1,2,3,4,5
;

INSERT INTO Mi_temp.Complex_product
SEL  a.Klant_nr
    ,a.Maand_nr
    ,b.BC_nr
    ,b.Code_complex_product (CHAR(1)) AS Code_complex_product
    ,b.Product_naam

FROM Mi_temp.Mia_klantkoppelingen a

INNER JOIN Mi_temp.Complex_prod_RC_mtwrk b
  ON b.BC_nr = a.Business_Contact_nr

GROUP BY 1,2,3,4,5
;

INSERT INTO Mi_temp.Complexe_producten
SEL
      a.Klant_nr
     ,a.Maand_nr
     ,TRIM(BOTH FROM a.Code_A) ||
      TRIM(BOTH FROM a.Code_B) ||
      TRIM(BOTH FROM a.Code_C) ||
      TRIM(BOTH FROM a.Code_D) ||
      TRIM(BOTH FROM a.Code_E) ||
      TRIM(BOTH FROM a.Code_F) ||
      TRIM(BOTH FROM a.Code_G) ||
      TRIM(BOTH FROM a.Code_H) ||
      TRIM(BOTH FROM a.Code_I) ||
      TRIM(BOTH FROM a.Code_J) ||
      TRIM(BOTH FROM a.Code_K) ||
      TRIM(BOTH FROM a.Code_L) ||
      TRIM(BOTH FROM a.Code_M) ||
      TRIM(BOTH FROM a.Code_N) ||
      TRIM(BOTH FROM a.Code_O) ||
      TRIM(BOTH FROM a.Code_P) ||
      TRIM(BOTH FROM a.Code_Q) ||
      TRIM(BOTH FROM a.Code_R) ||
      TRIM(BOTH FROM a.Code_S) ||
      TRIM(BOTH FROM a.Code_T) ||
      TRIM(BOTH FROM a.Code_U) ||
      TRIM(BOTH FROM a.Code_V) ||
      TRIM(BOTH FROM a.Code_W) ||
      TRIM(BOTH FROM a.Code_X) ||
      TRIM(BOTH FROM a.Code_Y) ||
      TRIM(BOTH FROM a.Code_Z) ||
      TRIM(BOTH FROM a.Code_0) ||
      TRIM(BOTH FROM a.Code_1) ||
      TRIM(BOTH FROM a.Code_2) ||
      TRIM(BOTH FROM a.Code_3) ||
      TRIM(BOTH FROM a.Code_4) ||
      TRIM(BOTH FROM a.Code_5) ||
      TRIM(BOTH FROM a.Code_6) ||
      TRIM(BOTH FROM a.Code_7) ||
      TRIM(BOTH FROM a.Code_8) ||
      TRIM(BOTH FROM a.Code_9) AS Complexe_producten
     ,a.Aantal_complexe_producten
FROM (
      SEL
           a.Klant_nr
          ,a.Maand_nr
          ,MAX(CASE WHEN a.Code_complex_product = 'A' THEN a.Code_complex_product ELSE '' END) AS Code_A
          ,MAX(CASE WHEN a.Code_complex_product = 'B' THEN a.Code_complex_product ELSE '' END) AS Code_B
          ,MAX(CASE WHEN a.Code_complex_product = 'C' THEN a.Code_complex_product ELSE '' END) AS Code_C
          ,MAX(CASE WHEN a.Code_complex_product = 'D' THEN a.Code_complex_product ELSE '' END) AS Code_D
          ,MAX(CASE WHEN a.Code_complex_product = 'E' THEN a.Code_complex_product ELSE '' END) AS Code_E
          ,MAX(CASE WHEN a.Code_complex_product = 'F' THEN a.Code_complex_product ELSE '' END) AS Code_F
          ,MAX(CASE WHEN a.Code_complex_product = 'G' THEN a.Code_complex_product ELSE '' END) AS Code_G
          ,MAX(CASE WHEN a.Code_complex_product = 'H' THEN a.Code_complex_product ELSE '' END) AS Code_H
          ,MAX(CASE WHEN a.Code_complex_product = 'I' THEN a.Code_complex_product ELSE '' END) AS Code_I
          ,MAX(CASE WHEN a.Code_complex_product = 'J' THEN a.Code_complex_product ELSE '' END) AS Code_J
          ,MAX(CASE WHEN a.Code_complex_product = 'K' THEN a.Code_complex_product ELSE '' END) AS Code_K
          ,MAX(CASE WHEN a.Code_complex_product = 'L' THEN a.Code_complex_product ELSE '' END) AS Code_L
          ,MAX(CASE WHEN a.Code_complex_product = 'M' THEN a.Code_complex_product ELSE '' END) AS Code_M
          ,MAX(CASE WHEN a.Code_complex_product = 'N' THEN a.Code_complex_product ELSE '' END) AS Code_N
          ,MAX(CASE WHEN a.Code_complex_product = 'O' THEN a.Code_complex_product ELSE '' END) AS Code_O
          ,MAX(CASE WHEN a.Code_complex_product = 'P' THEN a.Code_complex_product ELSE '' END) AS Code_P
          ,MAX(CASE WHEN a.Code_complex_product = 'Q' THEN a.Code_complex_product ELSE '' END) AS Code_Q
          ,MAX(CASE WHEN a.Code_complex_product = 'R' THEN a.Code_complex_product ELSE '' END) AS Code_R
          ,MAX(CASE WHEN a.Code_complex_product = 'S' THEN a.Code_complex_product ELSE '' END) AS Code_S
          ,MAX(CASE WHEN a.Code_complex_product = 'T' THEN a.Code_complex_product ELSE '' END) AS Code_T
          ,MAX(CASE WHEN a.Code_complex_product = 'U' THEN a.Code_complex_product ELSE '' END) AS Code_U
          ,MAX(CASE WHEN a.Code_complex_product = 'V' THEN a.Code_complex_product ELSE '' END) AS Code_V
          ,MAX(CASE WHEN a.Code_complex_product = 'W' THEN a.Code_complex_product ELSE '' END) AS Code_W
          ,MAX(CASE WHEN a.Code_complex_product = 'X' THEN a.Code_complex_product ELSE '' END) AS Code_X
          ,MAX(CASE WHEN a.Code_complex_product = 'Y' THEN a.Code_complex_product ELSE '' END) AS Code_Y
          ,MAX(CASE WHEN a.Code_complex_product = 'Z' THEN a.Code_complex_product ELSE '' END) AS Code_Z
          ,MAX(CASE WHEN a.Code_complex_product = '0' THEN a.Code_complex_product ELSE '' END) AS Code_0
          ,MAX(CASE WHEN a.Code_complex_product = '1' THEN a.Code_complex_product ELSE '' END) AS Code_1
          ,MAX(CASE WHEN a.Code_complex_product = '2' THEN a.Code_complex_product ELSE '' END) AS Code_2
          ,MAX(CASE WHEN a.Code_complex_product = '3' THEN a.Code_complex_product ELSE '' END) AS Code_3
          ,MAX(CASE WHEN a.Code_complex_product = '4' THEN a.Code_complex_product ELSE '' END) AS Code_4
          ,MAX(CASE WHEN a.Code_complex_product = '5' THEN a.Code_complex_product ELSE '' END) AS Code_5
          ,MAX(CASE WHEN a.Code_complex_product = '6' THEN a.Code_complex_product ELSE '' END) AS Code_6
          ,MAX(CASE WHEN a.Code_complex_product = '7' THEN a.Code_complex_product ELSE '' END) AS Code_7
          ,MAX(CASE WHEN a.Code_complex_product = '8' THEN a.Code_complex_product ELSE '' END) AS Code_8
          ,MAX(CASE WHEN a.Code_complex_product = '9' THEN a.Code_complex_product ELSE '' END) AS Code_9
          ,COUNT(DISTINCT a.Code_complex_product) AS Aantal_complexe_producten
     FROM  Mi_temp.Complex_product  a
     GROUP BY 1,2
     ) a
;

CREATE TABLE Mi_temp.Internationaal_maanden
AS
(
SEL Maand_nr
FROM
      (
      SEL
          sni.Maand_nr
         ,RANK(sni.Maand_nr) AS Maand_teller
      FROM
          /* Maanden SNU */
            (
            SEL Maand_nr
            FROM (
                  SEL boekdatum, COUNT(*) AS Aantal
                  FROM mi_cmb.Snu a
                  GROUP BY 1
                  ) a

            INNER JOIN
                      (
                      SEL  a.Datum
                          ,a.Maand_werkdag_nr
                          ,b.*
                      FROM  mi_vm.vKalender a
                      INNER JOIN
                                 (
                                 SEL
                                     Maand_nr
                                    ,MAX(Maand_werkdag_nr) AS Laatste_maand_werkdag_nr
                                 FROM mi_vm.vKalender
                                 WHERE NOT Maand_werkdag_nr IS NULL
                                 GROUP BY 1
                                 ) b
                         ON b.Maand_nr = a.Maand_nr
                      ) b
               ON b.datum = a.boekdatum

            WHERE Maand_werkdag_nr >= (Laatste_maand_werkdag_nr - 2)  /* veiligheidsmarge van 2 werkdagen */
            GROUP BY 1
            ) snu
          /* Maanden SNI */
      INNER JOIN
           (
           SEL Maand_nr
           FROM (
                 SEL boekdatum, COUNT(*) AS Aantal
                 FROM mi_cmb.Sni a
                 GROUP BY 1
                 ) a

           INNER JOIN
                     (
                     SEL  a.Datum
                         ,a.Maand_werkdag_nr
                         ,b.*
                     FROM  mi_vm.vKalender a
                     INNER JOIN
                                (
                                SEL
                                    Maand_nr
                                   ,MAX(Maand_werkdag_nr) AS Laatste_maand_werkdag_nr
                                FROM mi_vm.vKalender
                                WHERE NOT Maand_werkdag_nr IS NULL
                                GROUP BY 1
                                ) b
                        ON b.Maand_nr = a.Maand_nr
                     ) b
              ON b.datum = a.Boekdatum

           WHERE Maand_werkdag_nr >= (Laatste_maand_werkdag_nr - 2)
           GROUP BY 1
           ) sni
         ON sni.Maand_nr = snu.Maand_nr
      ) a
WHERE Maand_teller <= 12
) WITH DATA
UNIQUE PRIMARY INDEX (maand_nr)
;

CREATE TABLE mi_temp.Internationaal_snisnu AS
(
SELECT
    COALESCE(A.bc_nr,B.bc_nr)       AS BC_nr,
    COALESCE(A.maand_nr,B.maand_nr) AS Maand_nr,
    SUM(A.N_snu_trx)                AS N_snu_trx,
    SUM(a.amount_snu)               AS amount_snu,
    SUM(B.N_sni_trx)                AS N_sni_trx,
    SUM(b.amount_sni)               AS amount_sni
FROM
    (
    SELECT
           b.party_id                                                         AS BC_nr,
           EXTRACT( YEAR FROM boekdatum)*100+ EXTRACT (MONTH FROM boekdatum)  AS Maand_nr,
           COUNT(*)                                                           AS N_snu_trx,
           SUM((c.valuta_koers (FLOAT)) * bedragvv)                           AS Amount_snu
    FROM mi_cmb.Snu a

    INNER JOIN Mi_temp.Internationaal_maanden Mnd
       ON Mnd.Maand_nr = EXTRACT( YEAR FROM a.boekdatum)*100+ EXTRACT (MONTH FROM a.boekdatum)

    JOIN mi_vm_ldm.aClient_koppeling b
      ON a.client_nr = b.client_nr
     AND b.party_sleutel_type = 'BC'
    LEFT JOIN mi_vm_ldm.vWissel_koers        c
      ON a.iso_mnt=c.valuta_code
     AND  c.Wissel_koers_sdat <= a.boekdatum
     AND (c.Wissel_koers_edat >= a.boekdatum OR c.Wissel_koers_edat IS NULL)

    GROUP BY 1,2
    ) A
FULL OUTER JOIN
   (
   SELECT
          b.party_id                                                         AS BC_nr,
          EXTRACT( YEAR FROM boekdatum)*100+ EXTRACT (MONTH FROM boekdatum)  AS Maand_nr,
          COUNT(*)                                                           AS N_sni_trx,
          SUM((c.valuta_koers (FLOAT)) * bedragvv)                           AS Amount_sni
   FROM mi_cmb.Sni a

   INNER JOIN Mi_temp.Internationaal_maanden Mnd
       ON Mnd.Maand_nr = EXTRACT( YEAR FROM a.boekdatum)*100+ EXTRACT (MONTH FROM a.boekdatum)

   JOIN mi_vm_ldm.aClient_koppeling b
     ON a.client_nr = b.client_nr
    AND b.party_sleutel_type = 'BC'

    LEFT JOIN mi_vm_ldm.vWissel_koers        c
      ON a.iso_mnt=c.valuta_code
     AND  c.Wissel_koers_sdat <= a.boekdatum
     AND (c.Wissel_koers_edat >= a.boekdatum OR c.Wissel_koers_edat IS NULL)

   GROUP BY 1,2
   ) B
   ON A.bc_nr = B.bc_nr
  AND A.Maand_nr = B.Maand_nr

GROUP BY 1,2
) WITH DATA
UNIQUE PRIMARY INDEX (Maand_nr, BC_nr)
;

CREATE TABLE mi_temp.Internationaal_trx_bc AS
(
SEL
     cbc_oid AS BC_nr
    ,c.Maand_nr
    ,COUNT(DISTINCT c.contract_oid)         AS N_contracten
    ,SUM(c.CS_N_CR_trx)                     AS CS_N_CR_trx
    ,SUM(c.CS_CR_bedrag_trx)                AS CS_CR_bedrag_trx
    ,SUM(c.CS_N_CR_buitenlandse_trx)        AS CS_N_CR_buitenlandse_trx
    ,SUM(c.CS_CR_bedrag_buitenlandse_trx)   AS CS_CR_bedrag_buitenl_trx
    ,SUM(c.CS_N_DT_trx)                     AS CS_N_DT_trx
    ,SUM(c.CS_DT_bedrag_trx)                AS CS_DT_bedrag_trx
    ,SUM(c.CS_N_DT_buitenlandse_trx)        AS CS_N_DT_buitenlandse_trx
    ,SUM(c.CS_DT_bedrag_buitenlandse_trx)   AS CS_DT_bedrag_buitenl_trx

FROM mi_vm_nzdb.vCS_geld_contr_feiten_periode c

INNER JOIN Mi_temp.Internationaal_maanden Mnd
   ON Mnd.Maand_nr = c.Maand_nr

GROUP BY 1,2
)WITH DATA
UNIQUE PRIMARY INDEX (Maand_nr, BC_nr)
;

CREATE TABLE mi_temp.Internationaal_trx_tabel AS
(
SEL
     a.bc_nr
    ,a.maand_nr
    ,ZEROIFNULL(a.CS_N_CR_trx        )                    AS CS_N_CR_trx
    ,ZEROIFNULL(a.CS_CR_bedrag_trx        )               AS CS_CR_bedrag_trx
    ,ZEROIFNULL(a.CS_N_CR_buitenlandse_trx  )             AS CS_N_CR_buitenlandse_trx
    ,ZEROIFNULL(a.CS_CR_bedrag_buitenl_trx  )             AS CS_CR_bedrag_buitenl_trx
    ,ZEROIFNULL(a.CS_N_DT_trx        )                    AS CS_N_DT_trx
    ,ZEROIFNULL(a.CS_DT_bedrag_trx        )               AS CS_DT_bedrag_trx
    ,ZEROIFNULL(a.CS_N_DT_buitenlandse_trx  )             AS CS_N_DT_buitenlandse_trx
    ,ZEROIFNULL(a.CS_DT_bedrag_buitenl_trx  )             AS CS_DT_bedrag_buitenl_trx
    ,ZEROIFNULL(b.N_sni_trx                 )             AS N_sni_trx
    ,ZEROIFNULL(b.amount_sni                )             AS amount_sni
    ,ZEROIFNULL(b.N_snu_trx                 )             AS N_snu_trx
    ,ZEROIFNULL(b.amount_snu                )             AS amount_snu

FROM mi_temp.Internationaal_trx_bc        a

LEFT JOIN mi_temp.Internationaal_snisnu    b
  ON a.bc_nr=b.bc_nr
 AND a.maand_nr=b.maand_nr

GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14
)WITH DATA
UNIQUE PRIMARY INDEX (Maand_nr, BC_nr)
;

CREATE TABLE mi_temp.Internationaal_1 AS
(
SELECT
         bc_nr
        ,maand_nr
        ,CS_N_CR_trx
        ,CS_CR_bedrag_trx
        ,CS_N_CR_buitenlandse_trx
        ,CS_CR_bedrag_buitenl_trx
        ,CS_N_DT_trx
        ,CS_DT_bedrag_trx
        ,CS_N_DT_buitenlandse_trx
        ,CS_DT_bedrag_buitenl_trx
        ,N_sni_trx
        ,amount_sni
        ,N_snu_trx
        ,amount_snu
        ,CS_N_CR_trx+CS_N_CR_buitenlandse_trx+N_sni_trx                 AS N_CR_transacties
        ,CS_N_CR_buitenlandse_trx+N_sni_trx                             AS N_CR_btl_transacties
        ,CS_CR_bedrag_trx+CS_CR_bedrag_buitenl_trx+amount_sni           AS sum_CR_transacties
        ,CS_CR_bedrag_buitenl_trx+amount_sni                            AS sum_CR_btl_transacties

        ,a.CS_N_DT_trx+a.CS_N_DT_buitenlandse_trx+N_snu_trx             AS N_DT_transacties
        ,a.CS_N_DT_buitenlandse_trx+N_snu_trx                           AS N_DT_btl_transacties
        ,a.CS_DT_bedrag_trx+a.CS_DT_bedrag_buitenl_trx+amount_snu       AS sum_DT_transacties
        ,a.CS_DT_bedrag_buitenl_trx+amount_snu                          AS sum_DT_btl_transacties

FROM mi_temp.Internationaal_trx_tabel a

) WITH DATA
UNIQUE PRIMARY INDEX (Maand_nr, BC_nr)
;

CREATE TABLE mi_temp.Internationaal_2 AS
(
SELECT
        a.klant_nr
       ,a.maand_nr
       ,SUM(b.N_CR_transacties)        AS N_CR_transacties
       ,SUM(b.N_CR_btl_transacties)    AS N_CR_btl_transacties
       ,SUM(b.sum_CR_transacties)      AS sum_CR_transacties
       ,SUM(b.sum_CR_btl_transacties)  AS sum_CR_btl_transacties

       ,SUM(b.N_DT_transacties)        AS N_DT_transacties
       ,SUM(b.N_DT_btl_transacties)    AS N_DT_btl_transacties
       ,SUM(b.sum_DT_transacties)      AS sum_DT_transacties
       ,SUM(b.sum_DT_btl_transacties)  AS sum_DT_btl_transacties

FROM Mi_temp.Mia_klantkoppelingen a

LEFT OUTER JOIN mi_temp.Internationaal_1 b
   ON a.business_contact_nr = b.bc_nr

WHERE a.maand_nr = (SELECT MAX(Maand_nr) FROM MI_SAS_AA_MB_C_MB.Mia_periode_NEW Mnd)
GROUP BY 1,2
) WITH DATA
PRIMARY INDEX(Klant_nr,maand_nr)
;

CREATE TABLE mi_temp.Internationaal_3 AS
(
SELECT
        a.maand_nr
       ,a.klant_nr
       ,b.business_line

       ,a.N_CR_transacties
       ,a.N_CR_btl_transacties
       ,a.sum_CR_transacties
       ,a.sum_CR_btl_transacties

       ,a.N_DT_transacties
       ,a.N_DT_btl_transacties
       ,a.sum_DT_transacties
       ,a.sum_DT_btl_transacties

       ,(a.N_CR_btl_transacties (FLOAT))   / NULLIFZERO(a.N_CR_transacties(FLOAT))   AS btl_cr_prc
       ,(a.sum_CR_btl_transacties (FLOAT)) / NULLIFZERO(a.sum_CR_transacties(FLOAT)) AS btl_cr_prc_volume
       ,(a.N_DT_btl_transacties (FLOAT))   / NULLIFZERO(a.N_DT_transacties(FLOAT))   AS btl_dt_prc
       ,(a.sum_DT_btl_transacties(FLOAT))  / NULLIFZERO(a.sum_DT_transacties(FLOAT)) AS btl_dt_prc_volume
       ,(a.N_CR_btl_transacties + a.N_DT_btl_transacties (FLOAT)) / NULLIFZERO(a.N_CR_transacties + a.N_DT_transacties) AS btl_prc
       ,(a.sum_CR_btl_transacties  + a.sum_DT_btl_transacties (FLOAT)) / NULLIFZERO(a.sum_CR_transacties + a.sum_DT_transacties) AS btl_prc_volume

FROM mi_temp.Internationaal_2        a

INNER JOIN Mi_temp.Mia_klant_info b
   ON b.Klant_nr = a.Klant_nr
  AND b.Maand_nr = a.Maand_nr

WHERE b.Klantstatus = 'C'
  AND b.Klant_ind = 1
  AND b.Business_line in ('CBC', 'SME')
) WITH DATA
PRIMARY INDEX(Klant_nr);

CREATE TABLE Mi_temp.Internationale AS (
SELECT
     A.Maand_nr
    ,A.Business_line
    ,A.Klant_nr
    ,CASE
        WHEN ZEROIFNULL(btl_cr_prc_volume) = 0 THEN '0.nvt'
        WHEN ZEROIFNULL(btl_cr_prc_volume) LT 0.10 THEN '<10%'
        WHEN btl_cr_prc_volume LT 0.40 THEN '<40%'
        WHEN btl_cr_prc_volume LT 0.70 THEN '<70%'
        ELSE '>70%'
      END AS credit_percentage_buitenland
    ,CASE
        WHEN ZEROIFNULL(btl_dt_prc_volume) = 0 THEN '0.nvt'
        WHEN ZEROIFNULL(btl_dt_prc_volume) LT 0.10 THEN '<10%'
        WHEN btl_dt_prc_volume LT 0.40 THEN '<40%'
        WHEN btl_dt_prc_volume LT 0.70 THEN '<70%'
        ELSE '>70%'
      END AS debet_percentage_buitenland
    ,CASE
        WHEN a.Business_line in ('CBC', 'SME')        AND ZEROIFNULL(btl_cr_prc_volume) LT 0.10    AND ZEROIFNULL(btl_dt_prc_volume) LT 0.10 THEN 'Nationaal'
        WHEN a.Business_line in ('CBC', 'SME')        AND ZEROIFNULL(btl_cr_prc_volume) LT 0.40    AND ZEROIFNULL(btl_dt_prc_volume) LT 0.40 THEN 'Int.Light'
        WHEN a.Business_line in ('CBC', 'SME')        AND ZEROIFNULL(btl_cr_prc_volume) LT 0.70    AND ZEROIFNULL(btl_dt_prc_volume) LT 0.70 THEN 'Int.Medium'
        WHEN a.Business_line in ('CBC', 'SME')        AND ZEROIFNULL(btl_cr_prc_volume) GE 0.70    OR ZEROIFNULL(btl_dt_prc_volume)  GE 0.70 THEN 'Int.Heavy'
        ELSE 'tbd'
     END AS Int_Klasse

FROM mi_temp.Internationaal_3 A
) WITH DATA
UNIQUE PRIMARY INDEX(Klant_nr, Maand_nr)
;

INSERT INTO MI_SAS_AA_MB_C_MB.Siebel_Employee_NEW
SELECT
 XA.Maand_nr
,XA.Datum_gegevens
,XA.SBT_id
,XA.Naam
,XA.Soort_mdw
,XA.Functie
,XA.BO_nr_mdw
,XA.BO_naam_mdw
,XA.CCA
,MAX(CASE WHEN RANG = 2 THEN XA.CCA ELSE NULL END) OVER (PARTITION BY sbt_id) AS CCA2
,MAX(CASE WHEN RANG = 3 THEN XA.CCA ELSE NULL END) OVER (PARTITION BY sbt_id) AS CCA3
,XA.GM_ind
,XA.Account_Management_Specialism
,XA.Account_Management_Segment
,XA.Mdw_sdat

FROM
(
SELECT
 f.maand_nr AS Maand_nr
,f.datum_gegevens AS Datum_gegevens
,a.sbt_id AS SBT_id
,b.Naam AS Naam
,a.party_sleutel_type AS Soort_mdw
,a.Functie AS Functie
,c.bo_nr AS BO_nr_mdw
,TRIM(d.BO_naam) AS BO_naam_mdw
,gm.GM_ind
,a.CCA
,Account_Management_Specialism
,Account_Management_Segment
,a.Mdw_sdat
,a.party_sleutel_type
,e.N_bcs
,RANK () OVER (PARTITION BY a.sbt_id ORDER BY a.party_sleutel_type ASC, e.N_bcs DESC, a.Mdw_sdat DESC, a.cca DESC) AS Rang

FROM (SEL party_id,
                      CASE WHEN party_sleutel_type = 'AM' THEN party_id ELSE NULL END AS
                      CCA,
                      CASE WHEN LENGTH(TRIM(COALESCE(Account_Management_Functie, account_management_sbl_functietitel))) > 0
                      THEN TRIM(COALESCE(Account_Management_Functie, account_management_sbl_functietitel, 'ONBEKEND')) ELSE 'ONBEKEND' end
                      AS Functie,
                      party_sleutel_type,
                      TRIM(sbt_userid) AS sbt_id,
                      COALESCE(CASE WHEN LENGTH(TRIM(account_management_specialism)) > 1 THEN TRIM(account_management_specialism) ELSE NULL END, 'Onbekend')
                      AS Account_Management_Specialism,
                      COALESCE(CASE WHEN LENGTH(TRIM(account_management_segment)) > 1 THEN TRIM(account_management_segment) ELSE NULL END, 'Onbekend')
                      AS Account_Management_Segment,
                      account_management_sdat AS Mdw_sdat
                      FROM MI_VM_LDM.aaccount_management
                WHERE sbt_id IS NOT NULL
                AND sbt_id  <> 'UI0319' -- dummy id tbv migratie, niet selecteren
                AND TRIM(FUNCTIE) NOT IN ('Zelst. Verm. Beh.', 'zelfst.Verm.Beh') --uitsluiten zelfstandig vermogensbeheerders (externe partijen)
                AND LENGTH(TRIM(sbt_id)) > 0
) a
INNER JOIN (SEL party_id,
                               party_sleutel_type,
                               CASE WHEN party_sleutel_type = 'MW' THEN UPPER(TRIM(Naam)) ELSE UPPER(TRIM(Naamregel_1)) END AS
                               Naam
                      FROM mi_vm_ldm.aparty_naam
                      WHERE party_sleutel_type IN ('MW', 'AM')
) b
ON a.party_id = b.party_id
AND a.party_sleutel_type = b.party_sleutel_type
INNER JOIN (SEL party_id,
                               party_sleutel_type,
                               gerelateerd_party_id AS bo_nr
                       FROM mi_vm_ldm.aPARTY_PARTY_RELATIE
                       WHERE party_relatie_type_code IN ('AMBO', 'MWBO')
) c
ON a.party_id = c.party_id
AND a.party_sleutel_type = c.party_sleutel_type
LEFT JOIN  (SEL party_id AS bo_nr,
                                naam AS bo_naam
                        FROM mi_vm_ldm.aparty_naam
                        WHERE party_sleutel_type = 'BO'
) d
ON c.bo_nr = d.bo_nr
LEFT JOIN (SEL Party_id as bo_nr,
                               Structuur,
                               Case when substr(Structuur,1,6) = '334524' then 1 else 0 end as GM_ind
                               FROM  mi_vm_ldm.aParty_BO)  gm
on c.bo_nr = gm.bo_nr
LEFT JOIN (SEL gerelateerd_party_id, gerelateerd_party_sleutel_type, COUNT(party_id) AS N_bcs
                        FROM mi_vm_ldm.aparty_party_relatie
                        WHERE party_relatie_type_code IN ('relman','cltadv')
                        GROUP BY 1,2) e
ON a.party_id = e.gerelateerd_party_id
AND a.party_sleutel_type = e.gerelateerd_party_sleutel_type

LEFT JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW f
ON 1=1

) XA
QUALIFY RANK () OVER (PARTITION BY XA.sbt_id ORDER BY XA.party_sleutel_type ASC, ZEROIFNULL(XA.N_bcs) DESC, XA.Mdw_sdat DESC, XA.cca DESC) = 1;

INSERT INTO MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW
SELECT
BC.klant_nr AS Klant_nr
, B. maand_nr
, B. datum_gegevens
, TRIM(A.party_id_rechtspersoon_bc) AS Business_contact_nr
, TRIM(A.Status)
, TRIM(A.Activiteit_type)
, TRIM(A.Sub_type)
, TRIM(A.Productgroep)
, TRIM(A.Onderwerp)
, TRIM(A.Korte_omschrijving)
, TRIM(A.Contact_methode)
, TRIM(A.Vertrouwelijk_ind)
, TRIM(A.Datum_start)
, EXTRACT(YEAR FROM A.Datum_start) * 100 + EXTRACT(MONTH FROM A.Datum_start)
, TRIM(A.Datum_verval)
, EXTRACT(YEAR FROM A.Datum_verval) * 100 + EXTRACT(MONTH FROM A.Datum_verval)
, TRIM(A.Datum_eind)
, EXTRACT(YEAR FROM A.Datum_eind) * 100 + EXTRACT(MONTH FROM A.Datum_eind)
, TRIM(A.Siebel_verkoopkans_id)
, TRIM(A.Sbt_id_mdw_eigenaar)
, COALESCE(TRIM(SBT.Naam), 'Onbekend') AS Naam_mdw_eigenaar
, TRIM(A.Siebel_gespreksrapport_id) AS Gespreksrapport_ID
, TRIM(A.Datum_aangemaakt)
, EXTRACT(YEAR FROM A.Datum_aangemaakt) * 100 + EXTRACT(MONTH FROM A.Datum_aangemaakt)
, COALESCE(CN.Aantal_CN, 0) AS Aantal_Contactpersonen -- Wordt later in het script geupdate
, COALESCE(MDW.Aantal_MDW, 0) AS Aantal_Medewerkers  -- Wordt later in het script geupdate
, TRIM(A.Siebel_activiteit_id)
, COALESCE(TRIM(sleutel_type_commercieel_cluster), TRIM(sleutel_type_rechtspersoon_bc)) AS Client_level
, A.Sdat
, A.Edat

FROM mi_vm_ldm.aACTIVITEIT_cb A
LEFT JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW B
ON 1=1
INNER JOIN Mi_temp.Mia_klantkoppelingen BC
ON a.party_id_rechtspersoon_bc = BC.Business_contact_nr
LEFT JOIN MI_SAS_AA_MB_C_MB.Siebel_Employee_NEW SBT
ON SBT.SBT_ID = A.Sbt_id_mdw_eigenaar
LEFT JOIN
( SELECT siebel_activiteit_id, COUNT(DISTINCT party_id_contactpersoon) AS Aantal_CN FROM mi_vm_ldm.aActiviteit_Contactpersoon_cb GROUP BY 1 ) CN
ON CN.siebel_activiteit_id = A.siebel_activiteit_id
LEFT JOIN
( SELECT siebel_activiteit_id, COUNT(DISTINCT party_id_mdw) AS Aantal_MDW FROM mi_vm_ldm.aActiviteit_Medewerker_cb GROUP BY 1 ) MDW
ON MDW.siebel_activiteit_id = A.siebel_activiteit_id
;

INSERT INTO MI_SAS_AA_MB_C_MB.Siebel_Activiteit_TB_revisies_NEW
SELECT COALESCE(BC.Klant_nr, BC.Pcnl_nr) AS Klant_nr,
       B.Maand_nr,
       B.Datum_gegevens,
       TRIM(A.party_id_rechtspersoon_bc) AS Business_contact_nr,
       TRIM(A.Status),
       TRIM(A.Activiteit_type),
       TRIM(A.Sub_type),
       TRIM(A.Productgroep),
       TRIM(A.Onderwerp),
       TRIM(A.Korte_omschrijving),
       TRIM(A.Contact_methode),
       TRIM(A.Vertrouwelijk_ind),
       TRIM(A.Datum_start),
       EXTRACT(YEAR FROM A.Datum_start) * 100 + EXTRACT(MONTH FROM A.Datum_start),
       TRIM(A.Datum_verval),
       EXTRACT(YEAR FROM A.Datum_verval) * 100 + EXTRACT(MONTH FROM A.Datum_verval),
       TRIM(A.Datum_eind),
       EXTRACT(YEAR FROM A.Datum_eind) * 100 + EXTRACT(MONTH FROM A.Datum_eind),
       TRIM(A.Siebel_verkoopkans_id),
       TRIM(A.Sbt_id_mdw_eigenaar),
       COALESCE(TRIM(SBT_EIG.Naam), 'Onbekend') AS Naam_mdw_eigenaar,
       TRIM(A.Siebel_gespreksrapport_id) AS Gespreksrapport_ID,
       TRIM(A.Datum_aangemaakt),
       EXTRACT(YEAR FROM A.Datum_aangemaakt) * 100 + EXTRACT(MONTH FROM A.Datum_aangemaakt),
       COALESCE(CN.Aantal_CN, 0) AS Aantal_Contactpersonen, -- Wordt later in het script geupdate
       COALESCE(MDW.Aantal_MDW, 0) AS Aantal_Medewerkers,  -- Wordt later in het script geupdate
       TRIM(A.Siebel_activiteit_id),
       COALESCE(TRIM(sleutel_type_commercieel_cluster), TRIM(sleutel_type_rechtspersoon_bc)) AS Client_level,
       A.datum_bijgewerkt AS Datum_bijgewerkt,
       TRIM(A.Sbt_id_mdw_bijgewerkt_door) AS Sbt_id_mdw_bijgewerkt,
       COALESCE(TRIM(SBT_BIJ.Naam), 'Onbekend') AS Naam_mdw_bijgewerkt,
       CASE
       WHEN RANK () OVER (PARTITION BY COALESCE(BC.Klant_nr, BC.Pcnl_nr) ORDER BY A.Datum_verval DESC, A.Datum_start DESC, A.Siebel_activiteit_id DESC) = 1 THEN 1
       ELSE 0
       END AS TB_revisie_actueel_ind,
       A.Sdat,
       A.Edat
  FROM Mi_vm_ldm.aACTIVITEIT A
  LEFT JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW B
    ON 1 = 1
  JOIN Mi_temp.Mia_alle_bcs BC
    ON A.party_id_rechtspersoon_bc = BC.Business_contact_nr
  LEFT JOIN MI_SAS_AA_MB_C_MB.Siebel_Employee_NEW SBT_EIG
    ON SBT_EIG.SBT_ID = A.Sbt_id_mdw_eigenaar
  LEFT OUTER JOIN (SELECT Siebel_activiteit_id, COUNT(DISTINCT Party_id_contactpersoon) AS Aantal_CN
                     FROM Mi_vm_ldm.aActiviteit_Contactpersoon_cb
                    GROUP BY 1) CN
    ON CN.siebel_activiteit_id = A.siebel_activiteit_id
  LEFT OUTER JOIN (SELECT Siebel_activiteit_id, COUNT(DISTINCT Party_id_mdw) AS Aantal_MDW
                     FROM Mi_vm_ldm.aActiviteit_Medewerker_cb
                    GROUP BY 1) MDW
    ON MDW.siebel_activiteit_id = A.siebel_activiteit_id
  LEFT JOIN MI_SAS_AA_MB_C_MB.Siebel_Employee_NEW SBT_BIJ
    ON SBT_BIJ.SBT_ID = A.Sbt_id_mdw_bijgewerkt_door
 WHERE A.Onderwerp = 'Revision / maintenance'
   AND A.Productgroep = 'Betalen & Contant geld'
   AND A.Activiteit_type = 'Task'
   AND A.Korte_omschrijving = 'TB revisie'
   AND A.Status NE 'Cancelled'
   AND A.Sdat >=  DATE '2017-09-02';

INSERT INTO MI_SAS_AA_MB_C_MB.Siebel_Contactpersoon_NEW
SELECT
  A.siebel_contactpersoon_id
, A.achternaam
, A.tussenvoegsel
, A.achtervoegsel
, A.contactpersoon_titel /* hier loopt ook nog een vraag/issue op */
, A.initialen
, A.voornaam
, A.primary_adres
, A.primary_postcode
, A.primary_plaats
, A.primary_telefoonnummer
, A.primary_land
, A.primary_email
, TRIM( BOTH ' ' FROM TRIM(BOTH '#' FROM TRIM( BOTH '+' FROM TRIM( BOTH '-' FROM TRIM( BOTH ';' FROM TRIM( BOTH ':' FROM TRIM( BOTH '.' FROM TRIM( BOTH ',' FROM TRIM( BOTH '*' FROM TRIM( BOTH '''' FROM TRIM( BOTH '"' FROM TRIM( BOTH FROM TRIM(BOTH '09'xc FROM TRIM(BOTH '0D'xc FROM TRIM(BOTH '0A'xc FROM (TRIM(BOTH FROM (lower(A.primary_email))))))))))))))))))) as email_net
, case
        when email_net = '' then 0
        when email_net IS NULL then 0
        else 1
    end as email_bruikbaar

, A.contactpersoon_onderdeel
, A.contactpersoon_functietitel
, A.actief_ind
, A.academische_titel
, A.niet_bellen_ind
, A.niet_mailen_ind
, A.geen_marktonderzoek_ind
, A.geen_events_ind

, case when B1.party_deelnemer_rol = 1 then 1 else 0 end as primair_contact_persoon_ind

, coalesce(B1.cc_contactpersoon , B3.party_id ,  BX.gerelateerd_party_id ) as Klant_nr
, B.Maand_nr
, B.Datum_gegevens
, coalesce( B1.bc_contactpersoon , B2.party_id , B4.party_id ) as Business_contact_nr

, A.client_levelx as client_level

, A.contactpersoon_sdat as Sdat
, A.contactpersoon_edat as Edat

FROM (
    SELECT
        XA.*
        , case
            when XA.client_level = 'Bussines Contact'   then 'BC'
            when XA.client_level  = 'Commercial Complex' then 'CC'
            when XA.client_level  = 'Commercial Entity'  then 'CE'
            when XA.client_level  = 'Commercial Group'   then 'CG'
            when XA.client_level  = 'Ext. Local Ref.'    then 'XR'
            else 'XX'
          end as client_levelx

    FROM mi_vm_ldm.acontact_persoon_cb XA
    QUALIFY rank() over(partition by XA.siebel_contactpersoon_id , XA.party_id order by XA.contactpersoon_sdat desc) =1
 ) A
LEFT JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW B
ON 1=1
LEFT JOIN (
    select
        party_sleutel_type
        , gerelateerd_party_id as cn
        , party_relatie_type_code
        , case when party_sleutel_type = 'BC' then party_id else null end as bc_contactpersoon
        , case when party_sleutel_type = 'CE' then party_id else null end as ce_contactpersoon
        , case when party_sleutel_type = 'CC' then party_id else null end as cc_contactpersoon
        , case when party_sleutel_type = 'CG' then party_id else null end as cg_contactpersoon

        , party_deelnemer_rol            /* primair=1 , anders=2 */

    from mi_vm_ldm.aparty_party_relatie A
    where A.gerelateerd_party_sleutel_type = 'CN' and A.party_relatie_type_code like '%TCN%'
) B1
ON A.party_id = B1.cn
AND client_levelx = B1.party_sleutel_type
LEFT JOIN mi_vm_ldm.aparty_party_relatie B2
ON B1.ce_contactpersoon = B2.gerelateerd_party_id
AND B2.gerelateerd_party_sleutel_type = 'CE'
AND B2.party_sleutel_type = 'BC'
AND B2.party_relatie_type_code = 'CBCTCE'
LEFT JOIN mi_vm_ldm.aparty_party_relatie B3
ON B1.cg_contactpersoon = B3.gerelateerd_party_id
AND B3.gerelateerd_party_sleutel_type = 'CG'
AND B3.party_sleutel_type = 'CC'
AND B3.party_relatie_type_code = 'CCTCG'
LEFT JOIN mi_vm_ldm.aparty_party_relatie B4
ON coalesce(B1.cc_contactpersoon , B3.party_id ) = B4.gerelateerd_party_id
AND B4.gerelateerd_party_sleutel_type = 'CC'
AND B4.party_sleutel_type = 'BC'
AND B4.party_relatie_type_code = 'CBCTCC'
AND B4.party_deelnemer_rol =1
LEFT JOIN mi_vm_ldm.aparty_party_relatie BX
ON coalesce( B1.bc_contactpersoon , B2.party_id , B4.party_id ) = BX.party_id
AND BX.party_sleutel_type = 'BC'
AND BX.gerelateerd_party_sleutel_type = 'CC'
AND BX.party_relatie_type_code = 'CBCTCC'
WHERE a.client_levelx not in ( 'XR' , 'XX' )
  AND klant_nr is not NULL;

CREATE TABLE mi_temp.crm_email_updates AS (
    SELECT
        siebel_contactpersoon_id
        , email
        , email_net

        , lower(
                        substr( Email_net
                                    ,    case
                                        when position('<' in Email_net) > 0 then position('<' in Email_net) + 1
                                        when position('" ' in Email_net) > 0 then position('" ' in Email_net) + 2
                                        else 1
                                        end
                                    ,     case
                                        when position('>' in Email_net) > 0 then position('>' in Email_net)
                                        else length(trim(Email_net))+1
                                        end
                                        -
                                        case
                                        when position('<' in Email_net) > 0 then position('<' in Email_net) + 1
                                        when position('" ' in Email_net) > 0 then position('" ' in Email_net) + 2
                                        else 1
                                        end
                                        )
                    ) as email_netter
        , TRIM( BOTH ' ' FROM TRIM( BOTH '#' FROM TRIM( BOTH '+' FROM TRIM( BOTH ';' FROM TRIM( BOTH ':' FROM TRIM( BOTH '-' FROM TRIM( BOTH '.' FROM TRIM( BOTH ',' FROM TRIM( BOTH '*' FROM TRIM( BOTH '''' FROM TRIM( BOTH '"' FROM TRIM( BOTH FROM TRIM(BOTH '09'xc FROM TRIM(BOTH '0D'xc FROM TRIM(BOTH '0A'xc FROM (TRIM(BOTH FROM (email_netter)))))))))))))))))) as email_netst

    FROM MI_SAS_AA_MB_C_MB.Siebel_Contactpersoon_NEW A
    WHERE email ne ''
    AND email_net <> email_netst
) WITH DATA PRIMARY INDEX(siebel_contactpersoon_id);

INSERT INTO MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_NEW
SELECT
 mia.Klant_nr
,B.Maand_nr
,B.Datum_gegevens
,a.party_id_rechtspersoon_bc AS business_contact_nr
,a.Siebel_verkoopkans_id
,a.Naam_verkoopkans
,a.Selling_type
,a.Status
,a.Siebel_verkoopkans_deal_id
,a.Soort
,a.Productgroep
,a.Campaign_code_primary
,a.Herkomst
,a.Deal_captain_mdw_sbt_id
,emp1.Naam AS Naam_deal_captain_mdw
,a.Sbt_id_mdw_aangemaakt_door
,emp2.Naam AS Naam_mdw_aangemaakt_door
,a.Sbt_id_mdw_bijgewerkt_door
,emp3.Naam AS Naam_mdw_bijgewerkt_door
,a.Vertrouwelijk_ind
,prod.Aantal_producten
,prod.Aantal_succesvol
,prod.Aantal_niet_succesvol
,prod.Aantal_in_behandeling
,prod.Aantal_Nieuw
,a.Datum_aangemaakt
,a.Datum_start
,a.Datum_afgehandeld
,a.Datum_start_baten
,a.Lead_uuid
,CASE WHEN a.Client_level = 'Commercial Group' THEN 'CG'
             WHEN a.Client_level = 'Commercial Complex' THEN 'CC'
             WHEN a.Client_level = 'Commercial Entity' THEN 'CE'
             WHEN a.Client_level = 'Bussines Contact' THEN 'BC'
END AS Clientlevel
,a.Country_primary
,a.contactpersoon_primary_siebel_id
,a.verkoopkans_sdat AS Sdat
,a.verkoopkans_edat AS Edat

FROM mi_vm_ldm.aVerkoopkans_cb a
LEFT JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW B
ON 1=1
LEFT JOIN (SELECT siebel_verkoopkans_id
                                       ,COUNT(siebel_verkoopkans_product_id) AS Aantal_producten
                                       ,SUM(CASE WHEN TRIM(status) = 'Closed Successfully' THEN 1 ELSE 0 end) AS Aantal_succesvol
                                       ,SUM(CASE WHEN TRIM(status) = 'Closed Unsuccessfully' THEN 1 ELSE 0 end) AS Aantal_niet_succesvol
                                       ,SUM(CASE WHEN TRIM(status) = 'In Progress' THEN 1 ELSE 0 end) AS Aantal_in_behandeling
                                       ,SUM(CASE WHEN TRIM(status) = 'New' THEN 1 ELSE 0 end) AS Aantal_Nieuw
                      FROM mi_vm_ldm.aVerkoopkansProduct_cb A
                      GROUP BY 1
) prod
ON a.siebel_verkoopkans_id= prod.siebel_verkoopkans_id
INNER JOIN mi_temp.mia_klantkoppelingen mia
ON a.party_id_rechtspersoon_bc = mia.business_contact_nr

LEFT JOIN MI_SAS_AA_MB_C_MB.Siebel_Employee_NEW emp1
ON a.Deal_captain_mdw_sbt_id = emp1.sbt_id
AND b.maand_nr = emp1.maand_nr

LEFT JOIN MI_SAS_AA_MB_C_MB.Siebel_Employee_NEW emp2
ON a.Sbt_id_mdw_aangemaakt_door = emp2.sbt_id
AND b.maand_nr = emp2.maand_nr

LEFT JOIN MI_SAS_AA_MB_C_MB.Siebel_Employee_NEW emp3
ON a.Sbt_id_mdw_bijgewerkt_door = emp3.sbt_id
AND b.maand_nr = emp3.maand_nr

WHERE Soort <> 'deal' or Soort IS NULL
;

INSERT INTO MI_SAS_AA_MB_C_MB.Siebel_Deal_NEW
SELECT
 mia.Klant_nr
,B.Maand_nr
,B.Datum_gegevens
,a.party_id_rechtspersoon_bc AS business_contact_nr
,a.Siebel_verkoopkans_id AS Siebel_deal_id
,a.Naam_verkoopkans
,a.Selling_type
,a.Status
,a.Soort
,a.Productgroep
,a.Campaign_code_primary
,a.Herkomst
,a.Deal_captain_mdw_sbt_id
,emp1.Naam AS Naam_deal_captain_mdw
,a.Sbt_id_mdw_aangemaakt_door
,emp2.Naam AS Naam_mdw_aangemaakt_door
,a.Sbt_id_mdw_bijgewerkt_door
,emp3.Naam AS Naam_mdw_bijgewerkt_door
,a.Vertrouwelijk_ind
,prod.Aantal_producten
,prod.Aantal_succesvol
,prod.Aantal_niet_succesvol
,prod.Aantal_in_behandeling
,prod.Aantal_Nieuw
,a.Datum_aangemaakt
,a.Datum_start
,a.Datum_afgehandeld
,a.Datum_start_baten
,a.Lead_uuid
,CASE WHEN a.Client_level = 'Commercial Group' THEN 'CG'
             WHEN a.Client_level = 'Commercial Complex' THEN 'CC'
             WHEN a.Client_level = 'Commercial Entity' THEN 'CE'
             WHEN a.Client_level = 'Bussines Contact' THEN 'BC'
END AS Clientlevel
,a.Country_primary
,a.contactpersoon_primary_siebel_id
,a.verkoopkans_sdat AS Sdat
,a.verkoopkans_edat AS Edat
FROM mi_vm_ldm.aVerkoopkans_cb a
LEFT JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW B
ON 1=1
LEFT JOIN (SELECT siebel_verkoopkans_id
                                       ,COUNT(siebel_verkoopkans_product_id) AS Aantal_producten
                                       ,SUM(CASE WHEN TRIM(status) = 'Closed Successfully' THEN 1 ELSE 0 end) AS Aantal_succesvol
                                       ,SUM(CASE WHEN TRIM(status) = 'Closed Unsuccessfully' THEN 1 ELSE 0 end) AS Aantal_niet_succesvol
                                       ,SUM(CASE WHEN TRIM(status) = 'In Progress' THEN 1 ELSE 0 end) AS Aantal_in_behandeling
                                       ,SUM(CASE WHEN TRIM(status) = 'New' THEN 1 ELSE 0 end) AS Aantal_Nieuw
                      FROM mi_vm_ldm.aVerkoopkansProduct_cb A
                      GROUP BY 1
) prod
ON a.siebel_verkoopkans_id= prod.siebel_verkoopkans_id
INNER JOIN mi_temp.mia_klantkoppelingen mia
ON a.party_id_rechtspersoon_bc = mia.business_contact_nr

LEFT JOIN MI_SAS_AA_MB_C_MB.Siebel_Employee_NEW emp1
ON a.Deal_captain_mdw_sbt_id = emp1.sbt_id
AND b.maand_nr = emp1.maand_nr

LEFT JOIN MI_SAS_AA_MB_C_MB.Siebel_Employee_NEW emp2
ON a.Sbt_id_mdw_aangemaakt_door = emp2.sbt_id
AND b.maand_nr = emp2.maand_nr

LEFT JOIN MI_SAS_AA_MB_C_MB.Siebel_Employee_NEW emp3
ON a.Sbt_id_mdw_bijgewerkt_door = emp3.sbt_id
AND b.maand_nr = emp3.maand_nr

WHERE Soort = 'deal'
;

INSERT INTO MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_Product_NEW
SEL
B.klant_nr
,B.Maand_nr
,B.Datum_gegevens
,B.Business_contact_nr
,A.siebel_verkoopkans_product_id
,A.siebel_verkoopkans_id
,C.omschrijving -- Product_naam
,D.omschrijving --product_groep_naam
,A.pnc_contract_nummer
,A.aantal
,A.Omzet
,A.Baten_eenmalig
,A.Baten_terugkerend
,ZEROIFNULL(A.Baten_eenmalig) + ZEROIFNULL(A.Baten_terugkerend) AS Baten_totaal_1ste_12mnd -- baten over de eerste twaalf maanden, ongeacht de startdatum
,CASE     WHEN ZEROIFNULL(A.looptijd_mnd) <= 12
                 THEN ZEROIFNULL(A.Baten_eenmalig) + ZEROIFNULL(A.Baten_terugkerend)
                  ELSE ZEROIFNULL(A.Baten_eenmalig) + (ZEROIFNULL(A.Baten_terugkerend)* (ZEROIFNULL(A.looptijd_mnd)/12) )
 END AS Baten_totaal_looptijd -- baten over de gehele looptijd, ongeacht de startdatum
,A.status
,A.Substatus
,A.Reden
,A.Slagingskans
,A.Start_baten
,CAST(ADD_MONTHS(A.Start_baten, CAST(CASE WHEN A.looptijd_mnd > 9999 THEN 9999 ELSE A.looptijd_mnd END AS INTEGER)) AS DATE FORMAT 'yyyy-mm-dd')  AS Eind_Baten
,A.looptijd_mnd
,B.vertrouwelijk_ind
,A.sbt_id_mdw_eigenaar
,COALESCE(E.Naam, 'Onbekend') as Naam_mdw_eigenaar
,A.sbt_id_mdw_aangemaakt_door
,COALESCE(F.Naam, 'Onbekend') as naam_mdw_aangemaakt_door
,A.aangemaakt_op as Datum_aangemaakt
,A.bijgewerkt_op as Datum_laatst_gewijzigd
,XD.Datum_nieuw
,XE.Datum_in_behandeling
,XF.Datum_gesl_succesvol
,XG.Datum_gesl_niet_succesvol
,B.client_level
,A.verkoopkans_product_sdat
,A.verkoopkans_product_edat

FROM  MI_VM_LDM.aVerkoopkansproduct_CB A
INNER JOIN MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_NEW B
ON A.siebel_verkoopkans_id = B.siebel_verkoopkans_id

LEFT JOIN MI_VM_Ldm.aProduct_cb C
ON A.siebel_product_id = C.siebel_product_id

LEFT JOIN  MI_VM_Ldm.aProductGroep_cb D
ON A.siebel_productgroep_id = D.siebel_productgroep_id

LEFT JOIN MI_SAS_AA_MB_C_MB.Siebel_Employee_NEW E
ON A.sbt_id_mdw_eigenaar = E.SBT_ID AND E.Maand_nr = (SEL maand_nr FROM MI_SAS_AA_MB_C_MB.Mia_periode_NEW)

LEFT JOIN MI_SAS_AA_MB_C_MB.Siebel_Employee_NEW F
ON A.sbt_id_mdw_aangemaakt_door = F.SBT_ID AND F.Maand_nr = (SEL maand_nr FROM MI_SAS_AA_MB_C_MB.Mia_periode_NEW)

LEFT JOIN (
    SEL siebel_verkoopkans_product_id,MIN(bijgewerkt_op) as Datum_nieuw
    FROM  MI_VM_LDM.vVerkoopkansproduct_CB
    WHERE status = 'New'
    GROUP BY 1
) AS XD
ON A.siebel_verkoopkans_product_id = XD.siebel_verkoopkans_product_id

LEFT JOIN (
    SEL siebel_verkoopkans_product_id,MIN(bijgewerkt_op) as Datum_in_behandeling
    FROM  MI_VM_LDM.vVerkoopkansproduct_CB
    WHERE status = 'In Progress'
    GROUP BY 1
) AS XE
ON A.siebel_verkoopkans_product_id = XE.siebel_verkoopkans_product_id

LEFT JOIN (
    SEL siebel_verkoopkans_product_id,MIN(bijgewerkt_op) as Datum_gesl_succesvol
    FROM  MI_VM_LDM.vVerkoopkansproduct_CB
    WHERE status = 'Closed Successfully'
    GROUP BY 1
) AS XF
ON A.siebel_verkoopkans_product_id = XF.siebel_verkoopkans_product_id

LEFT JOIN (
    SEL siebel_verkoopkans_product_id,MIN(bijgewerkt_op) as Datum_gesl_niet_succesvol
    FROM  MI_VM_LDM.vVerkoopkansproduct_CB
    WHERE status = 'Closed Unsuccessfully'
    GROUP BY 1
) AS XG
ON A.siebel_verkoopkans_product_id = XG.siebel_verkoopkans_product_id
;

INSERT INTO MI_SAS_AA_MB_C_MB.Siebel_act_participants_NEW
SELECT
TRIM(A.Siebel_activiteit_id) as Siebel_activiteit_id
,B.Maand_nr
,B.datum_gegevens
,'Medewerker' as Type_deelnemer
,E.Naam
,E.Functie
,E.sbt_id
,NULL as Siebel_Contactpersoon_id

FROM MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW A

LEFT JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW   B
ON 1=1

INNER JOIN mi_vm_ldm.aActiviteit_Medewerker_cb C
ON   A.siebel_activiteit_id = C.siebel_activiteit_id

LEFT JOIN mi_vm_ldm.aACCOUNT_MANAGEMENT D
ON C.sleutel_type_mdw= D.party_sleutel_type
and C.party_id_mdw = D.party_id

INNER JOIN MI_SAS_AA_MB_C_MB.Siebel_Employee_NEW E
ON D.sbt_userid = E.sbt_id
;

INSERT INTO MI_SAS_AA_MB_C_MB.Siebel_act_participants_NEW
SELECT
TRIM(A.Siebel_activiteit_id)
,b.Maand_nr
,b.datum_gegevens
,'Contactpersoon' as Type_deelnemer
,E.Naam
,E.Functie
,NULL as SBT_ID
,TRIM(E.siebel_contactpersoon_id) as siebel_contactpersoon_id

FROM MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW A

LEFT JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW   B
ON 1=1

INNER JOIN mi_vm_ldm.aActiviteit_Contactpersoon_cb C
ON A.siebel_activiteit_id = C.siebel_activiteit_id

LEFT JOIN mi_vm_ldm.acontact_persoon_cb D
on C.party_id_contactpersoon = D.party_id
AND C.sleutel_type_contactpersoon = D.party_sleutel_type

INNER JOIN (select siebel_contactpersoon_id,
                      COALESCE(trim(voornaam)||' '||trim(tussenvoegsel)||' '||trim(achternaam)||' '||trim(achtervoegsel), 'Onbekend') as Naam,
                      TRIM(contactpersoon_functietitel) AS Functie
                      from MI_SAS_AA_MB_C_MB.Siebel_Contactpersoon_NEW
                      group by 1,2,3
) E
ON D.siebel_contactpersoon_id = E.siebel_contactpersoon_id;

INSERT INTO MI_SAS_AA_MB_C_MB.Mia_sector_NEW
SELECT
       x.Maand_nr,
       SBI_Plus_Code AS Sbi_code,
       SBI_Plus_NAME_NL AS Sbi_oms,
       AGIC_Code AS Agic_code,
       AGIC_NAME_NL AS Agic_oms,
       CMB_Sector_Code AS Sector_code,
       CMB_Sector_NAME_NL AS Sector_oms,
       CB_Subsector_Code AS Subsector_code,
       CB_Subsector_NAME_NL AS Subsector_oms,
       CASE
       WHEN CMB_Sector_NAME_NL IN ('Bouw', 'Olie & Gas', 'Transport & Logistiek', 'Utilities') THEN 1
       WHEN CMB_Sector_NAME_NL IN ('Agrarisch', 'Food', 'Retail') THEN 2
       WHEN CMB_Sector_NAME_NL IN ('Financial Institutions', 'Leisure', 'Technologie, Media & Telecom', 'Zakelijke dienstverlening') THEN 3
       WHEN CMB_Sector_NAME_NL IN ('Healthcare', 'Overheid & Onderwijs', 'Real Estate') THEN 4
       WHEN CMB_Sector_NAME_NL IN ('Industrie') THEN 5
       WHEN CMB_Sector_NAME_NL IN ('Prive Personen') THEN 6
       ELSE NULL
       END AS Sectorcluster_code,
       CASE
       WHEN CMB_Sector_NAME_NL IN ('Bouw', 'Olie & Gas', 'Transport & Logistiek', 'Utilities') THEN 'Business-to-business'
       WHEN CMB_Sector_NAME_NL IN ('Agrarisch', 'Food', 'Retail') THEN 'Consumer'
       WHEN CMB_Sector_NAME_NL IN ('Financial Institutions', 'Leisure', 'Technologie, Media & Telecom', 'Zakelijke dienstverlening') THEN 'Services'
       WHEN CMB_Sector_NAME_NL IN ('Healthcare', 'Overheid & Onderwijs', 'Real Estate') THEN 'Real Estate, Public & Healthcare'
       WHEN CMB_Sector_NAME_NL IN ('Industrie') THEN 'Manufacturing'
       WHEN CMB_Sector_NAME_NL IN ('Prive Personen') THEN 'Private Individuals'
       ELSE NULL
       END AS Sectorcluster_oms
  FROM Mi_vm_ldm.vSBI_plus_industry_RollUp
  JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW X
    ON 1=1
 GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10;

CREATE TABLE mi_temp.geo_variabelen as (
select D.maand_nr,
			D.cbc_postcode as postcode,
            D.CBC_oid,
            XI.land_geogr_id AS Geo_niveau1,
              XJ.geo_locatie AS Geo_niveau2,
              case when coalesce(XK.gemnaam, XI.Stad_naam) = ' ' then null
			  			else coalesce(XK.gemnaam, XI.Stad_naam) END AS Geo_niveau3,
               XJ.Org_niveau2 as SME_regio,
            XJ.Marktgebied as SME_marktgebied
from  Mi_vm_nzdb.vCommercieel_business_contact D
left join (select a.party_id, a.land_geogr_id, a.postcode, b.stad_naam
                 from (select a.party_id, a.post_adres_id, a.land_geogr_id, huis_nr, a.postcode
                          FROM mi_vm_ldm.vPARTY_POST_ADRES a
                          where party_post_adres_edat is null
                              and party_sleutel_type = 'BC'
                    group by 1,2,3,4,5) a
         left join (select b.post_adres_id, b.postcode, b.land_geogr_id, b.stad_naam
                            from MI_VM_ldm.apost_adres b
							where post_adres_edat is null
                    group by 1,2,3,4) b
                      on a.postcode = b.postcode and a.land_geogr_id = b.land_geogr_id and a.post_adres_id = b.post_adres_id
                    group by 1,2,3,4) XI
on D.cbc_postcode = XI.postcode and D.cbc_nr = XI.party_id
left join mi_cmb.vPc_commercial_banking XJ
on to_number(substr(XI.postcode,0,5)) = XJ.pc4 and XI.land_geogr_id = 'NL'
left join (select gemnaam, pc
                             from mi_vm_ldm.ageo
							 where geo_edat is null
                            group by 1,2) XK
on D.cbc_postcode = XK.pc
where d.maand_nr = MI_SAS_AA_MB_C_MB.Mia_periode.maand_nr
group by 1,2,3,4,5,6,7,8) with data and stats
UNIQUE PRIMARY INDEX (maand_nr,postcode,cbc_oid);

INSERT INTO Mi_temp.Mia_week
SELECT MIA.Klant_nr AS Klant_nr,
       A.Maand_nr AS Maand_nr,
       MIA.Datum_gegevens AS Datum_gegevens,
       D.CBC_nr AS Business_contact_nr,
       E.Naam AS Verkorte_naam,
       MIA.Klant_ind AS Klant_ind,
       MIA.Klantstatus AS Klantstatus,
       MIA.Business_line AS Business_line,
       /* confrom afspraken met Mathon en Thomas worden klanten obv CGC naar business line ingedeeld */
       CGC.Segment AS Segmentx,
       CASE WHEN MIA.Business_line = 'CIB' and XG.Klantindeling in ('Tier 1','Tier 2','Tier 3') THEN XG.Klantindeling ELSE NULL END AS Subsegment,
       MIA.Clientgroep AS Clientgroep,
       NULL AS Clientgroep_theoretisch,
       ZEROIFNULL(A.Starters_ind) AS Starter_ind,
       ZEROIFNULL(A.CC_stichting_vereniging_ind) AS VenS_ind,
       CASE WHEN VenS_ind = 0 AND XA.N_werknemers_klasse_oms = '1' THEN 1 ELSE 0 END AS ZZP_ind,
       /*V1.90 LATER TE WIJZIGEN NAAR NIEUWE BRON */
       NULL AS Internationaal_segment,
       A.Leidend_bankshop_nr AS Bo_nr,
       AB.Bo_naam AS Bo_naam,
       MIA.CCA AS CCA,
       WORD_SUBST(CASE
                      WHEN NN.Naam IS NULL OR NN.Naam = '' THEN 'Geen naam'
                      ELSE
                      ((CASE WHEN TRIM(NN.Voorletters) LIKE ANY ('', '-') THEN '' ELSE TRIM(NN.Voorletters)||' ' END)||
                       (CASE WHEN TRIM(NN.Voorvoegsels) = '' THEN '' ELSE TRIM(NN.Voorvoegsels)||' ' END)||
                        TRIM(NN.Naam))
                      END, '''', ''
                     ) (CHAR(48)) AS Relatiemanager,
       /*Nieuwe BO Structuur*/
       NULL AS Org_niveau5, -- aanpassen zodra nieuwe structuur beschikbaar is in Mia_organisatie
       NULL AS Org_niveau5_bo_nr, -- aanpassen zodra nieuwe structuur beschikbaar is in Mia_organisatie
       NULL AS Org_niveau4, -- aanpassen zodra nieuwe structuur beschikbaar is in Mia_organisatie
       NULL AS Org_niveau4_bo_nr, -- aanpassen zodra nieuwe structuur beschikbaar is in Mia_organisatie
       CASE
       WHEN MIA.Business_line in ('CBC', 'SME') THEN COALESCE(XB.Org_niveau3, XB2.Org_niveau3/*, U.Team_naam*/, 'Onbekend')
       WHEN MIA.Business_line = 'CIB' THEN COALESCE(XB.Org_niveau3, XB1.Org_niveau3, 'Onbekend')
       END AS Org_niveau3, -- aanpassen zodra nieuwe structuur beschikbaar is in Mia_organisatie
       CASE
       WHEN MIA.Business_line in ('CBC', 'SME') THEN COALESCE(XB.Org_niveau3_bo_nr, XB2.Org_niveau3_bo_nr/*, U.Team_oid*/, -101)
       WHEN MIA.Business_line = 'CIB' THEN COALESCE(XB.Org_niveau3_bo_nr, XB1.Org_niveau3_bo_nr, -101)
       END AS Org_niveau3_bo_nr, -- aanpassen zodra nieuwe structuur beschikbaar is in Mia_organisatie
       CASE
       WHEN MIA.Business_line in ('CBC', 'SME') THEN COALESCE(XB.Org_niveau2, XB2.Org_niveau2/*, V.House_naam*/, 'Onbekend')
       WHEN MIA.Business_line = 'CIB' THEN COALESCE(XB.Org_niveau2, XB1.Org_niveau2, 'Onbekend')
       END AS Org_niveau2, -- aanpassen zodra nieuwe structuur beschikbaar is in Mia_organisatie
       CASE
       WHEN MIA.Business_line in ('CBC', 'SME') THEN COALESCE(XB.Org_niveau2_bo_nr, XB2.Org_niveau2_bo_nr/*, V.House_nr*/, -101)
       WHEN MIA.Business_line = 'CIB' THEN COALESCE(XB.Org_niveau2_bo_nr,XB1.Org_niveau2_bo_nr, -101)
       END AS Org_niveau2_bo_nr, -- aanpassen zodra nieuwe structuur beschikbaar is in Mia_organisatie
       CASE
       WHEN MIA.Business_line in ('CBC', 'SME') THEN COALESCE(XB.Org_niveau1, XB2.Org_niveau1/*, W.Regio_naam*/, 'Onbekend')
       WHEN MIA.Business_line = 'CIB' THEN COALESCE(XB.Org_niveau1,XB1.Org_niveau1, 'Onbekend')
       END AS Org_niveau1, -- aanpassen zodra nieuwe structuur beschikbaar is in Mia_organisatie
       CASE
       WHEN MIA.Business_line in ('CBC', 'SME') THEN COALESCE(XB.Org_niveau1_bo_nr, XB2.Org_niveau1_bo_nr/*, W.Regio_nr*/, -101)
       WHEN MIA.Business_line = 'CIB' THEN COALESCE(XB.Org_niveau1_bo_nr,XB1.Org_niveau1_bo_nr, -101)
       END AS Org_niveau1_bo_nr, -- aanpassen zodra nieuwe structuur beschikbaar is in Mia_organisatie
       NULL AS Org_niveau0, 		-- aanpassen zodra nieuwe structuur beschikbaar is in Mia_organisatie
       NULL AS Org_niveau0_bo_nr,	-- aanpassen zodra nieuwe structuur beschikbaar is in Mia_organisatie
       R.Tir_bank_of_origin_code AS Bank_herkomst,
       S.KvK_nr AS Kvk_nr,
       S.Kvk_branche_nr AS Kvk_branche_nr,
       S.Kvk_branche_oms AS Kvk_branche_oms,
       XA.N_werknemers_klasse_oms AS Kvk_klasse_werknemers,
       S.Sbi_code AS Sbi_code,
       T.Sbi_oms AS Sbi_oms,
       S.Sbi_bron AS Sbi_bron,
       T.Agic_oms AS Agic_oms,
       T.Sectorcluster_oms AS Sectorcluster, -- aanpassen zodra beschikbaar in MDM1721 Industry Rollup (Sprint 19)
       T.Sector_oms AS Sector,
       T.Subsector_code AS Subsector,
       T.Subsector_oms AS Subsector_oms,
       MIAB.Baten AS Baten,
       (CASE
        WHEN EXTRACT(DAY FROM A.CC_Samenvattings_datum) < EXTRACT(DAY FROM A.Afgel_onderneming_start_datum) THEN (((A.CC_Samenvattings_datum - A.Afgel_onderneming_start_datum) MONTH(4)) (INTEGER)) - 1
        ELSE (((A.CC_Samenvattings_datum - A.Afgel_onderneming_start_datum) MONTH(4)) (INTEGER))
        END) / 12 AS Aantal_jaren_bestaan,
       (CASE
        WHEN EXTRACT(DAY FROM A.CC_Samenvattings_datum) < EXTRACT(DAY FROM A.Relatie_start_datum) THEN (((A.CC_Samenvattings_datum - A.Relatie_start_datum) MONTH(4)) (INTEGER)) - 1
        ELSE (((A.CC_Samenvattings_datum - A.Relatie_start_datum) MONTH(4)) (INTEGER))
        END) / 12 AS Aantal_jaren_klant,
       (CASE
        WHEN EXTRACT(DAY FROM A.CC_Samenvattings_datum) < EXTRACT(DAY FROM A.Relatie_start_datum) THEN (((A.CC_Samenvattings_datum - A.Relatie_start_datum) MONTH(4)) (INTEGER)) - 1
        ELSE (((A.CC_Samenvattings_datum - A.Relatie_start_datum) MONTH(4)) (INTEGER))
        END) AS Aantal_maanden_klant,
       ZEROIFNULL(L.Omzet_bedrag) AS Omzet_inkomend,
       ZEROIFNULL(C.CC_gecor_geschatte_afgel_omz) AS Bedrijfsomzet,
       CASE WHEN C.Omzet_gebruikte_bron_id = 3 THEN 1 ELSE 0 END AS Bedrijfsomzet_RM_ind,
       CASE WHEN C.Omzet_gebruikte_bron_id = 3 THEN C.CC_gecor_geschatte_afgel_omz_j ELSE NULL END AS Bedrijfsomzet_jaar,
       CASE
       WHEN C.CC_gecor_geschatte_afgel_omz                             IS NULL THEN 0
       WHEN C.CC_gecor_geschatte_afgel_omz                       <     1000000 THEN 1
       WHEN C.CC_gecor_geschatte_afgel_omz  BETWEEN     1000000  AND   2500000 THEN 2
       WHEN C.CC_gecor_geschatte_afgel_omz  BETWEEN     2500000  AND   7500000 THEN 3
       WHEN C.CC_gecor_geschatte_afgel_omz  BETWEEN     7500000  AND  20000000 THEN 4
       WHEN C.CC_gecor_geschatte_afgel_omz  BETWEEN    20000000  AND 100000000 THEN 5
       WHEN C.CC_gecor_geschatte_afgel_omz  BETWEEN   100000000  AND 250000000 THEN 6
       WHEN C.CC_gecor_geschatte_afgel_omz                       >   250000000 THEN 7
       END AS Omzetklasse_idx,
       CASE
       WHEN Omzetklasse_idx = 0 THEN 'omzet onbekend'
       WHEN Omzetklasse_idx = 1 THEN 'minder dan 1 mln'
       WHEN Omzetklasse_idx = 2 THEN '1 - 2,5 mln'
       WHEN Omzetklasse_idx = 3 THEN '2,5 - 7,5 mln'
       WHEN Omzetklasse_idx = 4 THEN '7,5 - 20 mln'
       WHEN Omzetklasse_idx = 5 THEN '20 - 100 mln'
       WHEN Omzetklasse_idx = 6 THEN '100 - 250 mln'
       WHEN Omzetklasse_idx = 7 THEN 'meer dan 250 mln'
       END AS Omzetklasse_id_oms,
       CASE
       WHEN MIA.business_line in ('CBC', 'SME') THEN XD.Share_of_wallet_oms /*BdB AO wijziging*/
       ELSE NULL
       END AS SoW,
       CASE
       WHEN MIA.business_line in ('CBC', 'SME') THEN XE.Primaire_klant_kans_oms /*BdB AO wijziging*/
       ELSE NULL
       END AS Primair_categorie,
       CASE
       WHEN MIA.business_line in ('CBC', 'SME') AND A.Primaire_klant_kans_code = 'A' THEN 1 /*BdB AO wijziging*/
       WHEN MIA.business_line in ('CBC', 'SME') AND A.Primaire_klant_kans_code <> 'A' THEN 0 /*BdB AO wijziging*/
       ELSE NULL
       END AS Primair_ind,
       ZEROIFNULL(M.CC_business_volume) AS Businessvolume,
       ZEROIFNULL(M.CC_credit_volume) AS Creditvolume,
       ZEROIFNULL(-M.CC_debet_volume) AS Debetvolume,
       (ZEROIFNULL(P.Cs_beleggen) +
        ZEROIFNULL(P.Cs_betalen) +
        ZEROIFNULL(P.Cs_creditcard) +
        ZEROIFNULL(P.Cs_creditgelden) +
        ZEROIFNULL(P.Cs_digitaal_bankieren) +
        ZEROIFNULL(P.Cs_ifn) +
        ZEROIFNULL(P.Cs_kredieten) +
        ZEROIFNULL(P.Cs_lease) +
        ZEROIFNULL(P.Cs_verzekeren_ondernemer) +
        ZEROIFNULL(P.Cs_verzekeren_onderneming) +
        ZEROIFNULL(P.Cs_employee_benefits) +
        ZEROIFNULL(P.Cs_pakket_prive) +
        ZEROIFNULL(P.Cs_treasury)) AS Cross_sell,
       ZEROIFNULL(P.Cs_betalen) AS Cs_betalen,
       ZEROIFNULL(P.Cs_creditgelden) AS Cs_creditgelden,
       ZEROIFNULL(P.Cs_kredieten) AS Cs_kredieten,
       ZEROIFNULL(P.Cs_verzekeren_ondernemer) AS Cs_verzekeren_ondernemer,
       ZEROIFNULL(P.Cs_creditcard) AS Cs_creditcard,
       ZEROIFNULL(P.Cs_employee_benefits) AS Cs_employee_benefits,
       ZEROIFNULL(P.Cs_beleggen) AS Cs_beleggen,
       ZEROIFNULL(P.Cs_lease) AS Cs_lease,
       ZEROIFNULL(P.Cs_ifn) AS Cs_ifn,
       ZEROIFNULL(P.Cs_treasury) AS Cs_treasury,
       ZEROIFNULL(P.Cs_digitaal_bankieren) AS Cs_digitaal_bankieren,
       ZEROIFNULL(P.Cs_pakket_prive) AS Cs_pakket_prive,
       ZEROIFNULL(P.Cs_verzekeren_onderneming) AS Cs_verzekeren_onderneming,
       (CASE
        WHEN EXTRACT(DAY FROM A.CC_Samenvattings_datum) < EXTRACT(DAY FROM A.Datum_laatste_product_afname) THEN (((A.CC_Samenvattings_datum - A.Datum_laatste_product_afname) MONTH(4)) (INTEGER)) - 1
        ELSE (((A.CC_Samenvattings_datum - A.Datum_laatste_product_afname) MONTH(4)) (INTEGER))
        END) AS Aantal_mnd_sinds_productafname,
       ZEROIFNULL(AA.Starters_rekening) AS Startersrekening_ind,
       ZEROIFNULL(AA.Starters_pakket) AS Starterspakket_ind,
       ZEROIFNULL(AA.MKB_pakket) AS MKB_pakket_ind,
       ZEROIFNULL(AA.VenS_pakket) AS VenS_pakket_ind,
       ZEROIFNULL(AD.Aantal_complexe_producten) AS Aantal_complexe_producten,
       AD.Complexe_producten AS Complexe_producten,
       TRIM(CASE WHEN F.NAW_regel1 IS NULL THEN '' ELSE F.NAW_regel1 END) ||'~'||
       TRIM(CASE WHEN F.NAW_regel2 IS NULL THEN '' ELSE F.NAW_regel2 END) ||'~'||
       TRIM(CASE WHEN F.NAW_regel3 IS NULL THEN '' ELSE F.NAW_regel3 END) ||'~'||
       TRIM(CASE WHEN F.NAW_regel4 IS NULL THEN '' ELSE F.NAW_regel4 END) ||'~'||
       TRIM(CASE WHEN F.NAW_regel5 IS NULL THEN '' ELSE F.NAW_regel5 END) ||'~'||
       TRIM(CASE WHEN F.NAW_regel6 IS NULL THEN '' ELSE F.NAW_regel6 END) ||'~'||
       TRIM(CASE WHEN F.NAW_regel7 IS NULL THEN '' ELSE F.NAW_regel7 END) AS Naw,
       XH.Postcode AS Postcode,
       XH.Geo_niveau1,
       XH.Geo_niveau2,
       XH.Geo_niveau3,
       XH.SME_regio,
       XH.SME_marktgebied,
       CASE WHEN F.Post_adres_id IN ('NL3000DD-949', 'NL9700AC-147', 'NL9700AT-754', 'NL5600AM-515') THEN 1 ELSE 0 END AS Postretour_adres_ind,
       G.Telefoon_nr_vast  AS Telefoon_nr_vast,
       H.Telefoon_nr_mobiel AS Telefoon_nr_mobiel,
       NULL AS Contactpersoon,
       NULL AS Emailadres,
       AE.Datum_volgend_contact,
       AE.Datum_laatste_contact_pro_ftf,
       AE.Datum_laatste_contact_ftf,
       ZEROIFNULL(AE.Aantal_contact_pro_ftf) AS Aantal_contact_pro_ftf,
       ZEROIFNULL(AE.Aantal_contact_ftf) AS Aantal_contact_ftf,
       ZEROIFNULL(AE.Aantal_contact_pro_tel) AS Aantal_contact_pro_tel,
       ZEROIFNULL(AE.Aantal_contact_tel) AS Aantal_contact_tel,
       MIA.Faillissement_ind AS Faillissement_ind,
       MIA.Surseance_ind AS Surseance_ind,
       MIA.Bijzonder_beheer_ind AS Bijzonder_beheer_ind,
       O.CRG AS CRG,
       CASE WHEN MIA.GSRI_goedgekeurd_lvl = 1 THEN 'High'
            WHEN MIA.GSRI_goedgekeurd_lvl = 2 THEN 'Medium'
            WHEN MIA.GSRI_goedgekeurd_lvl = 3 THEN 'Low'
            ELSE 'ONBEKEND' END AS GSRI_goedgekeurd,
       CASE WHEN MIA.GSRI_Assessment_resultaat_lvl = 1 THEN 'ABOVE PAR'
            WHEN MIA.GSRI_Assessment_resultaat_lvl = 2 THEN 'ON PAR'
            WHEN MIA.GSRI_Assessment_resultaat_lvl = 3 THEN 'BELOW PAR'
            ELSE 'ONBEKEND' END AS GSRI_Assessment_resultaat,
       MIA.Aantal_bcs AS Aantal_bcs,
       MIA.Aantal_bcs_in_scope AS Aantal_bcs_in_scope,
       K.Leidend_bc AS Leidend_business_contact,
       MIA.Leidend_bc_ind AS Leidend_bc_ind,
       CASE WHEN MIA.Klantstatus = 'C' AND Bedrijfsomzet_jaar = 2012 THEN 'Omzetjaar 2012' ELSE NULL END AS Signaal,
       XJ.Revisie_datum AS Datum_revisie_TB,
       Bc_CCA_TB AS CCA_consultant_TB
  FROM Mi_temp.Mia_klant_info MIA
  JOIN Mi_temp.Mia_klantbaten MIAB
    ON MIA.Klant_nr = MIAB.Klant_nr AND MIA.Maand_nr = MIAB.Maand_nr
  JOIN Mi_vm_nzdb.vCommercieel_cluster A
    ON MIA.Klant_nr = A.Cc_nr AND MIA.Maand_nr = A.Maand_nr
  LEFT OUTER JOIN MI_SAS_AA_MB_C_MB.CGC_BASIS CGC
    ON MIA.Clientgroep = CGC.Clientgroep
  LEFT OUTER JOIN Mi_vm_nzdb.vCC_feiten_snapshot B
    ON MIA.Klant_nr = B.CC_nr AND MIA.Maand_nr = B.Maand_nr
  LEFT OUTER JOIN Mi_vm_nzdb.vCC_gecor_geschatte_afgel_omz C
    ON MIA.Klant_nr = C.CC_nr AND MIA.Maand_nr = C.Maand_nr
  JOIN Mi_vm_nzdb.vCommercieel_business_contact D
    ON A.Leidend_CBC_oid = D.CBC_oid AND MIA.Maand_nr = D.Maand_nr
  LEFT OUTER JOIN Mi_vm_ldm.aParty_naam E
    ON D.CBC_nr = E.Party_id AND E.Party_sleutel_type = 'bc'
  LEFT OUTER JOIN Mi_vm_ldm.aParty_post_adres F
    ON D.CBC_nr = F.Party_id AND F.Party_sleutel_type = 'bc'
  LEFT OUTER JOIN (SELECT XA.Party_id,
                          MAX(XA.Telefoon_nummer) AS Telefoon_nr_vast
                     FROM Mi_vm_ldm.aParty_telefoon_adres XA
                    WHERE XA.Party_sleutel_type = 'bc'
                      AND XA.Adres_gebruik_type_code = 'tv'
                    GROUP BY 1) AS G
    ON D.CBC_nr = G.Party_id
  LEFT OUTER JOIN (SELECT XA.Party_id,
                          MAX(XA.Telefoon_nummer) AS Telefoon_nr_mobiel
                     FROM Mi_vm_ldm.aParty_telefoon_adres XA
                    WHERE XA.Party_sleutel_type = 'bc'
                      AND XA.Adres_gebruik_type_code = 'tm'
                    GROUP BY 1) AS H
    ON D.CBC_nr = H.Party_id
  LEFT OUTER JOIN (SELECT XA.Party_id,
                          XA.Party_sleutel_type,
                          MAX(XA.Electronisch_adres_id) AS Email_adres
                     FROM Mi_vm_ldm.aParty_electronisch_adres XA
                    WHERE XA.Party_sleutel_type = 'bc'
                      AND XA.Adres_gebruik_type_code = 'em'
                    GROUP BY 1, 2) AS I
    ON D.CBC_nr = I.Party_id AND I.Party_sleutel_type = 'bc'
  LEFT OUTER JOIN (SELECT XA.CC_nr AS Cluster_nr,
                          MIN(XA.Contract_nr) AS Contract_nr
                     FROM Mi_vm_nzdb.vContract XA
                     JOIN Mi_vm_nzdb.vLU_Maand_Runs XB
                       ON XA.Maand_nr = XB.Maand_nr AND XB.Lopende_maand_ind = 1
                    WHERE XA.Contract_status_code NE 3
                      AND XA.Contract_soort_code BETWEEN 1 AND 99
                    GROUP BY 1) AS J
    ON MIA.Klant_nr = J.Cluster_nr
  LEFT OUTER JOIN (SELECT XA.Klant_nr AS Cluster_nr,
                          MAX(CASE WHEN XA.Volgorde = 0 THEN XA.Business_contact_nr ELSE NULL END) AS Leidend_bc
                     FROM Mi_temp.Mia_klantkoppelingen XA
                    GROUP BY 1) AS K
    ON MIA.Klant_nr = K.Cluster_nr
  LEFT OUTER JOIN Mi_vm_nzdb.vCC_omzet_versch_bronnen L
    ON MIA.Klant_nr = L.CC_nr AND MIA.Maand_nr = L.Maand_nr AND L.Omzet_bron_id = 5
  LEFT OUTER JOIN (SELECT XA.CC_nr,
                          XA.Maand_nr,
                          SUM(XB.Business_volume) AS CC_business_volume,
                          SUM(XB.Credit_volume) AS CC_credit_volume,
                          SUM(XB.Debet_volume) AS CC_debet_volume
                     FROM Mi_vm_nzdb.vCommercieel_business_contact XA
                     JOIN Mi_vm_nzdb.vLU_Maand_Runs XX
                       ON XA.Maand_nr = XX.Maand_nr AND XX.Lopende_maand_ind = 1
                     LEFT OUTER JOIN Mi_vm_nzdb.vContract_feiten_snapshot XB
                       ON XA.CBC_oid = XB.CBC_oid AND XA.Maand_nr = XB.Maand_nr
                    GROUP BY 1, 2) AS M
    ON MIA.Klant_nr = M.CC_nr AND MIA.Maand_nr = M.Maand_nr
  LEFT OUTER JOIN Mi_vm_nzdb.vMKB_RM_denorm N
  ON A.CC_accountmanager_oid = N.MKB_accountmanager_oid AND A.Maand_nr = N.Maand_nr
  LEFT OUTER JOIN Mi_vm_ldm.aParty_naam NN
    ON MIA.CCA = NN.Party_id AND NN.Party_sleutel_type = 'AM'
  LEFT OUTER JOIN (SELECT XA.CC_nr,
                          XA.Maand_nr,
                          MAX(XB.Segment_id) AS CRG
                     FROM Mi_vm_nzdb.vCommercieel_business_contact XA
                     JOIN Mi_vm_nzdb.vLU_Maand_Runs XX
                       ON XA.Maand_nr = XX.Maand_nr AND XX.Lopende_maand_ind = 1
                     JOIN Mi_vm_ldm.aSegment_klant XB
                       ON XA.CBC_nr = XB.Party_id AND XB.Party_sleutel_type = 'bc' AND XB.Segment_type_code = 'crg'
                    GROUP BY 1, 2) AS O
    ON MIA.Klant_nr = O.CC_nr AND MIA.Maand_nr = O.Maand_nr
  LEFT OUTER JOIN Mi_vm_nzdb.vCross_sell_cc P
    ON MIA.Klant_nr = P.CC_nr AND MIA.Maand_nr = P.Maand_nr
  LEFT OUTER JOIN (SELECT XA.Bo_nr AS NEWBank_bo_nr
                     FROM Mi_vm_ldm.vBo_mi_part_zak XA
                    WHERE (XA.Bu_code = '1R') /* AND XA.Client_beherend_bo = 'J') */
                       OR (XA.Bu_code = '1C' AND XA.Bo_nr NOT IN (988938, 988999))) AS Q
    ON A.Leidend_bankshop_nr = Q.NEWBank_bo_nr
  LEFT OUTER JOIN Mi_vm_nzdb.vTIR_cc_bank_herkomst R
    ON MIA.Klant_nr = R.Cc_nr AND MIA.Maand_nr = R.Month_nr
    LEFT OUTER JOIN (SELECT XA.Cc_nr,
                          XA.Maand_nr,
                         'H'||XC.KvK_nr (CHAR(13)) AS Kvk_nr,
                          COALESCE(CASE WHEN XB.Cbc_sbi_company_activity IN  ('000000','-101') THEN NULL ELSE XB.Cbc_sbi_company_activity END, XC.Kvk_branche_code) AS Sbi_code,
                          CASE
                          WHEN XB.Cbc_sbi_company_activity NOT IN ('000000','-101') THEN 'BCDB SBI*'
                          WHEN XC.Kvk_branche_oms IS NOT NULL THEN 'KvK'
                          ELSE NULL
                          END AS Sbi_bron,
                          XC.Kvk_branche_code AS Kvk_branche_nr,
                          XC.Kvk_branche_oms AS Kvk_branche_oms
                     FROM Mi_vm_nzdb.vCommercieel_cluster XA
                     JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW XX
                       ON XA.Maand_nr = XX.Maand_nr
                     JOIN Mi_vm_nzdb.vCommercieel_business_contact XB
                       ON XA.Leidend_CBC_oid = XB.CBC_oid AND XA.Maand_nr = XB.Maand_nr
                     LEFT OUTER JOIN Mi_vm_nzdb.vCoci_denorm XC
                       ON XA.Cc_kvk_registratie_oid = XC.Kvk_oid AND XA.Maand_nr = XC.Maand_nr) AS S
    ON A.Cc_nr = S.Cc_nr AND A.Maand_nr = S.Maand_nr
  LEFT OUTER JOIN MI_SAS_AA_MB_C_MB.Mia_sector_NEW T
    ON S.Sbi_code = T.Sbi_code
  LEFT OUTER JOIN (SELECT XA.Cc_nr AS Cluster_nr,
                          COUNT(XD.Party_id) AS N_bcs_valniv12
                     FROM Mi_vm_nzdb.vCommercieel_business_contact XA
                     JOIN Mi_vm_nzdb.vLU_Maand_Runs XX
                       ON XA.Maand_nr = XX.Maand_nr AND XX.Lopende_maand_ind = 1
                     JOIN Mi_vm_nzdb.vCommercieel_cluster XC
                       ON XA.Cc_nr = XC.Cc_nr AND XA.Maand_nr = XC.Maand_nr
                     JOIN Mi_vm_ldm.aKlant_prospect XD
                       ON XA.Cbc_nr = XD.Party_id AND XD.klant_validatie_niveau IN (1, 2) AND XD.Party_sleutel_type = 'bc'
                    GROUP BY 1) AS Z
    ON MIA.Klant_nr = Z.Cluster_nr
  LEFT OUTER JOIN (SELECT XA.CC_nr AS Cluster_nr,
                          XA.Maand_nr,
                          MAX(CASE WHEN XB.CS_product_naam_extern LIKE '%Ond%rek%starter%'                       THEN 1 ELSE 0 END) AS Starters_rekening,
                          MAX(CASE WHEN XB.CS_product_naam_intern LIKE '%Starters%pakket%'                       THEN 1 ELSE 0 END) AS Starters_pakket,
                          MAX(CASE WHEN XB.CS_product_naam_intern LIKE '%MKB%Pakket%' OR XB.CS_product_id = 1358 THEN 1 ELSE 0 END) AS MKB_pakket,
                          MAX(CASE WHEN XB.CS_product_id = 1345                                                  THEN 1 ELSE 0 END) AS VenS_pakket
                     FROM Mi_vm_nzdb.vContract XA
                     JOIN Mi_vm_nzdb.vLU_Maand_Runs XX
                       ON XA.Maand_nr = XX.Maand_nr AND XX.Lopende_maand_ind = 1
                     JOIN Mi_vm_nzdb.vCs_product XB
                       ON XA.Product_id = XB.CS_product_id AND XA.Maand_nr = XB.Maand_nr
                    WHERE (XB.CS_product_naam_intern LIKE ANY ('%Starters%pakket%', '%MKB%Pakket%') OR
                           XB.CS_product_naam_extern LIKE '%Ond%rek%starter%' OR XB.CS_product_id IN (1345, 1358))
                      AND XA.Contract_status_code NE 3
                    GROUP BY 1, 2) AS AA
    ON MIA.Klant_nr = AA.Cluster_nr
  LEFT OUTER JOIN (SELECT XA.Bo_nr,
                          XA.Bo_naam
                     FROM Mi_vm_ldm.vBo_mi_part_zak XA) AS AB
    ON A.Leidend_bankshop_nr = AB.Bo_nr
  LEFT OUTER JOIN (SELECT XA.Klant_nr,
                          XD.Naam AS Contactpersoon
                     FROM Mi_temp.Mia_klantkoppelingen XA
                     JOIN Mi_vm_ldm.aParty_party_relatie XC
                       ON XA.Business_contact_nr = XC.Party_id AND XC.Party_sleutel_type = 'bc'
                     JOIN Mi_vm_ldm.aParty_naam XD
                       ON XC.Gerelateerd_party_id = XD.Party_id AND XD.Party_sleutel_type = 'CP'
                    WHERE XC.Party_relatie_type_code = 'CTTPSN'
                  QUALIFY RANK ( XA.Volgorde ASC, XC.Party_party_relatie_SDAT DESC, XD.Party_id ASC, XD.Naam ASC ) = 1
                    GROUP BY 1) AS AC
    ON MIA.Klant_nr = AC.Klant_nr
  LEFT OUTER JOIN Mi_temp.Complexe_producten AD
    ON MIA.Klant_nr = AD.Klant_nr AND MIA.Maand_nr = AD.Maand_nr

  LEFT OUTER JOIN (SELECT A.Klant_nr,
                          C.Datum_volgend_contact,
                          B.Datum_laatste_contact_pro_ftf,
                          B.Datum_laatste_contact_ftf,
                          SUM(CASE WHEN TRIM(A.Contact_methode) = 'Face to Face' AND A.Sub_type = 'bank initiative' AND A.Datum_start BETWEEN ADD_MONTHS(D.Datum_gegevens, -12) AND D.Datum_gegevens THEN 1 ELSE 0 END) AS Aantal_contact_pro_ftf,
                          SUM(CASE WHEN TRIM(A.Contact_methode) = 'Face to Face' AND A.Datum_start BETWEEN ADD_MONTHS(D.Datum_gegevens, -12) AND D.Datum_gegevens THEN 1 ELSE 0 END) AS Aantal_contact_ftf,
                          SUM(CASE WHEN TRIM(A.Contact_methode) IN ('Telephone', 'Tel warme overdracht') AND A.Sub_type = 'bank initiative' AND A.Datum_start BETWEEN ADD_MONTHS(D.Datum_gegevens, -12) AND D.Datum_gegevens THEN 1 ELSE 0 END) AS Aantal_contact_pro_tel,
                          SUM(CASE WHEN TRIM(A.Contact_methode) IN ('Telephone', 'Tel warme overdracht') AND A.Datum_start BETWEEN ADD_MONTHS(D.Datum_gegevens, -12) AND D.Datum_gegevens THEN 1 ELSE 0 END) AS Aantal_contact_tel
                FROM MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW A
                LEFT OUTER JOIN (SELECT A.Klant_nr,
                                        MAX(A.Datum_start) AS Datum_laatste_contact_ftf,
                                        MAX(CASE WHEN A.Sub_type = 'bank initiative' THEN A.Datum_start ELSE NULL END) AS Datum_laatste_contact_pro_ftf
                                   FROM MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW A
                                   LEFT JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW B
                                     ON A.Maand_nr = B.Maand_nr
                                  WHERE A.Datum_start <= B.Datum_gegevens
                                    AND TRIM(A.Contact_methode) = 'Face to Face'
                                  GROUP BY 1) AS B
                  ON A.Klant_nr = B.Klant_nr
                LEFT OUTER JOIN (SELECT A.Klant_nr,
                                        MAX(A.Datum_start) AS Datum_volgend_contact
                                   FROM MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW A
                                   LEFT JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW B
                                     ON A.Maand_nr = B.Maand_nr
                                  WHERE A.Datum_start BETWEEN B.Datum_gegevens+1 AND ADD_MONTHS(B.Datum_gegevens, 60)
                                    AND A.Activiteit_type = 'Appointment'
                                    AND A.Sub_type = 'Customer Appointment'
                                  GROUP BY 1) AS C
                  ON A.Klant_nr = C.Klant_nr
                LEFT OUTER JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW D
                  ON A.Maand_nr = D.Maand_nr
               WHERE A.Datum_start <= D.Datum_gegevens
               GROUP BY 1, 2, 3, 4) AS AE
    ON MIA.Klant_nr = AE.Klant_nr

  LEFT OUTER JOIN Mi_vm_nzdb.vN_werknemers_klasse XA
   ON A.CC_N_werknemers_klasse_code = XA.N_werknemers_klasse_code AND A.Maand_nr = XA.Maand_nr

  LEFT JOIN (SELECT party_id, gerelateerd_party_id AS Org_niveau3_bo_nr
           FROM mi_vm_ldm.aparty_party_relatie
           WHERE party_sleutel_type = 'BO'
           AND party_relatie_type_code IN ('0HKTS5','APCTS4','APCTS5','BZTS4','BZTS5','BZTZ','CCUTS5','HFATS5','KCTS4','RFRTS4','TS5TS5', 'APCTS3', 'CCUTS4')
           AND gerelateerd_party_id NOT IN (254106)
           ) XB0
  ON A.Leidend_bankshop_nr = XB0.party_id

  LEFT OUTER JOIN MI_SAS_AA_MB_C_MB.MIA_organisatie XB
    ON a.CC_team_oid  = XB.Org_niveau3_bo_nr
    AND XB.BO_BL IN ('CBC', 'SME', 'CIB')

  LEFT OUTER JOIN MI_SAS_AA_MB_C_MB.MIA_organisatie XB1
    ON XB0.Org_niveau3_bo_nr  = XB1.Org_niveau3_bo_nr
    AND XB1.BO_BL IN ('CBC', 'SME', 'CIB')

  LEFT OUTER JOIN Mi_sas_aa_mb_c_mb.MIA_organisatie XB2
    ON A.Leidend_bankshop_nr = XB2.Org_niveau3_bo_nr AND XB2.BO_BL IN ('CBC', 'SME')

  LEFT OUTER JOIN Mi_vm_nzdb.vShare_of_wallet XD
    ON A.Share_of_wallet_code = XD.Share_of_wallet_code AND A.Maand_nr = XD.Maand_nr
  LEFT OUTER JOIN Mi_vm_nzdb.vPrimaire_klant_kans XE
    ON A.Primaire_klant_kans_code = XE.Primaire_klant_kans_code AND A.Maand_nr = XE.Maand_nr
  LEFT OUTER JOIN Mi_temp.Internationale XF
    ON MIA.Klant_nr = XF.Klant_nr
  LEFT OUTER JOIN mi_vm_ldm.aCommercieel_complex_cb XG
    ON MIA.Klant_nr = XG.Party_id
  LEFT OUTER JOIN mi_temp.geo_variabelen XH
    on A.Leidend_CBC_oid = XH.CBC_oid
  LEFT OUTER JOIN Mi_temp.Mia_alle_bcs XI
    ON A.Leidend_CBC_oid = XI.Business_contact_nr AND A.Maand_nr = XI.Maand_nr
  LEFT OUTER JOIN (SELECT XA.Klant_nr,
                          XA.Datum_verval AS Revisie_datum
                     FROM MI_SAS_AA_MB_C_MB.Siebel_Activiteit_TB_revisies_NEW XA
                    WHERE XA.TB_revisie_actueel_ind = 1) AS XJ
    ON MIA.Klant_nr = XJ.Klant_nr;

INSERT INTO Mi_temp.Mia_week_UPDATE
SELECT A.Klant_nr,
       A.Maand_nr,
       B.Cc_team_oid,
       COALESCE(XA.Org_niveau3, XB.Org_niveau3, 'Onbekend') AS Org_niveau3,
       COALESCE(XA.Org_niveau3_bo_nr, XB.Org_niveau3_bo_nr, -101) AS Org_niveau3_bo_nr,
       COALESCE(XA.Org_niveau2, XB.Org_niveau2, 'Onbekend') AS Org_niveau2,
       COALESCE(XA.Org_niveau2_bo_nr, XB.Org_niveau2_bo_nr, -101) AS Org_niveau2_bo_nr,
       COALESCE(XA.Org_niveau1, XB.Org_niveau1, 'Onbekend') AS Org_niveau1,
       COALESCE(XA.Org_niveau1_bo_nr, XB.Org_niveau1_bo_nr, -101) AS Org_niveau1_bo_nr,
       COALESCE(XA.Org_niveau0, XB.Org_niveau0, 'Onbekend') AS Org_niveau0,
       COALESCE(XA.Org_niveau0_bo_nr, XB.Org_niveau0_bo_nr, -101) AS Org_niveau0_bo_nr
  FROM Mi_temp.Mia_week A
  LEFT OUTER JOIN Mi_vm_nzdb.vCommercieel_cluster B
    ON A.Klant_nr = B.Cc_nr AND A.Maand_nr = B.Maand_nr
  LEFT OUTER JOIN Mi_sas_aa_mb_c_mb.Mia_organisatie_workaround XA
    ON SUBSTR(A.CCA, 4, 6) = XA.Bo_nr AND ((A.Business_line IN ('CBC', 'SME') AND XA.BO_BL IN ('CBC', 'SME')) OR (A.Business_line = 'CIB' AND XA.BO_BL = 'CIB'))
  LEFT OUTER JOIN Mi_sas_aa_mb_c_mb.Mia_organisatie_workaround XB
    ON A.Bo_nr = XB.Bo_nr AND ((A.Business_line IN ('CBC', 'SME') AND XB.BO_BL IN ('CBC', 'SME')) OR (A.Business_line = 'CIB' AND XB.BO_BL = 'CIB'));

INSERT INTO Mi_temp.Mia_klanten
SELECT A.Klant_nr,
       A.Maand_nr,
       A.Bank_herkomst,
       A.Business_line,
       /* v.92 Heel Commercial Clients met elkaar benchmarken, geen onderscheid naar segment */
       NULL AS Segment,
       NULL AS Subsegment,
       CASE
       /* v.127 Alleen voormalig Commercial Clients met elkaar benchmarken, geen onderscheid naar segment */
       WHEN A.Business_line in ('CBC', 'SME') AND A.Segment NE 'SME' AND A.Klantstatus = 'S' THEN 0
       WHEN A.Business_line in ('CBC', 'SME') AND A.Segment NE 'SME' THEN 1
       ELSE 0
       END AS Benchmark_ind,
       CASE
       /* v.127 Alleen voormalig Commercial Clients met elkaar benchmarken, geen onderscheid naar segment */
       WHEN A.Business_line in ('CBC', 'SME') AND A.Segment NE 'SME' AND A.Klantstatus = 'S' THEN 1
       WHEN A.Business_line in ('CBC', 'SME') AND A.Segment NE 'SME' THEN 1
       ELSE 0
       END AS Uitscoor_ind,
       A.Subsector_code AS Bedrijfstak_id,
       CASE
       /* v.127 Alleen voormalig Commercial Clients met elkaar benchmarken, geen onderscheid naar segment */
       WHEN A.Business_line in ('CBC', 'SME') AND A.Segment NE 'SME' AND A.Omzetklasse_id > 5 THEN 5
       WHEN A.Business_line in ('CBC', 'SME') AND A.Segment NE 'SME' THEN A.Omzetklasse_id
       ELSE 0
       END AS Omzetklasse_id,
       NULL AS Dimensie3_id,
       NULL AS Dimensie4_id,
       NULL AS Dimensie5_id
  FROM Mi_temp.Mia_week A
  LEFT OUTER JOIN Mi_temp.Mia_klantbaten B
    ON A.Klant_nr = B.Klant_nr AND A.Maand_nr = B.Maand_nr
 WHERE (A.Klant_ind = 1 OR A.Klantstatus = 'S');

CREATE TABLE MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr_NEW
AS
(
SEL
     a.Maand_nr
    ,b.Maand_edat
   ,(CSUM(1,maand_nr DESC) -1)  N_maanden_terug
   ,NULL ( INTEGER) AS Maand_nr_cube_baten
   ,NULL ( INTEGER) AS Maand_nr_bet_trx
   ,NULL ( INTEGER) AS Maand_nr_beleggen
   ,NULL ( INTEGER) AS Maand_nr_kredieten
   ,NULL ( INTEGER) AS Maand_nr_part_zak
   ,NULL ( INTEGER) AS Maand_nr_Cidar
FROM
     (
      SEL Maand_nr
      FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW
      GROUP BY 1
     ) a

INNER JOIN MI_vm.vlu_maand  b
   ON b.Maand = a.Maand_nr

) WITH DATA
UNIQUE PRIMARY INDEX (Maand_nr)
;

INSERT INTO MI_SAS_AA_MB_C_MB.Mia_businesscontacts_NEW
SELECT A.Business_contact_nr,
       A.Klant_nr,
       X.Maand_nr,
       X.Datum_gegevens,
       A.Bc_naam,
       A.Bc_startdatum,
       A.Bc_clientgroep,
       A.Bc_crg,
       A.Bc_bo_nr,
       A.Bc_bo_naam,
       A.Bc_bo_bu_code,
       A.Bc_bo_bu_decode,
       A.Bc_validatieniveau,
       A.Bc_cca_am,
       A.Bc_cca_rm,
       A.Bc_cca_am_bu_code,
       A.Bc_cca_am_bu_decode,
       A.Bc_cca_rm_bu_code,
       A.Bc_cca_rm_bu_decode,
       A.Bc_cca_pb,
       A.Bc_relatiecategorie,
       A.Bc_verschijningsvorm,
       B.Segment_oms AS Bc_verschijningsvorm_oms,
       A.Bc_kvk_nr,
       A.Bc_postcode,
       A.Bc_sbi_code_bcdb,
       A.Bc_sbi_code_kvk,
       A.Bc_contracten,
       A.Bc_klantlevenscyclus,
       A.Leidend_bc_ind,
       A.Leidend_bc_pb_ind,
       A.Cc_nr,
       A.Koppeling_id_CC,
       A.Koppeling_id_CE,
       A.Koppeling_id_CG,
       A.Fhh_nr,
       A.Pcnl_nr,
       A.Bc_Lindorff_ind,
       A.Bc_FRenR_ind,
       A.Bc_in_nzdb,
       A.Bc_SEC_US_Person_ind,
       A.Bc_SEC_US_Person_oms,
       A.Bc_FATCA_US_Person_ind,
       A.Bc_FATCA_US_Person_class,
       A.Bc_ringfence,
       A.Bc_Risico_score,
       A.BC_Risico_klasse_oms,
       A.Bc_WtClas,
       A.Bc_AAClas,
       A.Bc_Rente_drv,
       A.Bc_Comm_drv,
       A.Bc_Valuta_drv,
       A.Bc_Overig_cms,
       A.BC_GSRI_goedgekeurd,
       A.BC_GSRI_Assessment_resultaat,
       A.BC_GBC_nr,
       A.BC_GBC_Naam,
       A.BC_ULP_nr,
       A.BC_ULP_Naam,
       A.BC_CCA_TB,
       A.BC_CCA_TB_Naam,
       A.BC_CCA_TB_Team,
       A.Trust_complex_nr,
       A.Franchise_complex_nr
  FROM Mi_temp.Mia_alle_bcs A
  JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW X
    ON 1 = 1
  LEFT OUTER JOIN Mi_vm_ldm.aSegment B
    ON A.Bc_verschijningsvorm = B.Segment_id
   AND B.Segment_type_code = 'APPTYP'
 WHERE A.DB_ind = 0
   AND A.RBS_ind = 0
   AND A.Bc_clientgroep NOT IN ('8001', '9001');

INSERT INTO Mi_temp.Mia_week_PB
SELECT A.Pcnl_nr AS Klant_nr,
       A.Maand_nr AS Maand_nr,
       A.Datum_gegevens AS Datum_gegevens,
       A.Business_contact_nr AS Business_contact_nr,
       A.Bc_naam AS Verkorte_naam,
       0 AS Klant_ind,
       NULL AS Klantstatus,
       B.Business_line AS Business_line,
       B.Segment AS Segment,
       NULL AS Subsegment,
       A.Bc_clientgroep AS Clientgroep,
       NULL AS Clientgroep_theoretisch,
       NULL AS Starter_ind,
       NULL AS VenS_ind,
       NULL AS ZZP_ind,
       NULL AS Internationaal_segment,
       A.Bc_bo_nr AS Bo_nr,
       A.Bc_bo_naam AS Bo_naam,
       A.Bc_cca_PB AS CCA,
       WORD_SUBST(CASE
                      WHEN F.Naam IS NULL OR F.Naam = '' THEN 'Geen naam'
                      ELSE
                      ((CASE WHEN TRIM(F.Voorletters) LIKE ANY ('', '-') THEN '' ELSE TRIM(F.Voorletters)||' ' END)||
                       (CASE WHEN TRIM(F.Voorvoegsels) = '' THEN '' ELSE TRIM(F.Voorvoegsels)||' ' END)||
                        TRIM(F.Naam))
                      END, '''', ''
                     ) (CHAR(48)) AS Relatiemanager,
       NULL AS Org_niveau5,
       NULL AS Org_niveau5_bo_nr,
       NULL AS Org_niveau4,
       NULL AS Org_niveau4_bo_nr,
       NULL AS Org_niveau3,
       NULL AS Org_niveau3_bo_nr,
       NULL AS Org_niveau2,
       NULL AS Org_niveau2_bo_nr,
       NULL AS Org_niveau1,
       NULL AS Org_niveau1_bo_nr,
       'PB' AS Org_niveau0,
       /* hoogste Bo_nr in de PB hierarchie */
       309113 AS Org_niveau0_bo_nr,
       NULL AS Bank_herkomst,
       'H'||A.Bc_kvk_nr (CHAR(13)) AS Kvk_nr,
       A.Bc_SBI_code_KvK AS Kvk_branche_nr,
       E.Sbi_oms AS Kvk_branche_oms,
       NULL AS Kvk_klasse_werknemers,
       COALESCE(CASE WHEN A.Bc_SBI_code_BCDB IN  ('000000','-101') THEN NULL ELSE A.Bc_SBI_code_BCDB END, A.Bc_SBI_code_KvK) AS Sbi_codeX,
       D.Sbi_oms AS Sbi_oms,
       CASE
       WHEN A.Bc_SBI_code_BCDB NOT IN ('000000','-101') THEN 'BCDB SBI*'
       WHEN A.Bc_SBI_code_KvK IS NOT NULL THEN 'KvK'
       ELSE NULL
       END AS Sbi_bron,
       D.Agic_oms AS AGIC_oms,
       D.Sectorcluster_oms AS Sectorcluster,
       D.Sector_oms AS CMB_sector,
       D.Subsector_code AS Subsector_code,
       D.Subsector_oms AS Subsector_oms,
       NULL AS Baten,
       NULL AS Aantal_jaren_bestaan,
       NULL AS Aantal_jaren_klant,
       NULL AS Aantal_maanden_klant,
       NULL AS Omzet_inkomend,
       NULL AS Bedrijfsomzet,
       NULL AS Bedrijfsomzet_RM_ind,
       NULL AS Bedrijfsomzet_jaar,
       NULL AS Omzetklasse_id,
       NULL AS Omzetklasse_oms,
       NULL AS SoW,
       NULL AS Primair_categorie,
       NULL AS Primair_ind,
       NULL AS Businessvolume,
       NULL AS Creditvolume,
       NULL AS Debetvolume,
       NULL AS Cross_sell,
       NULL AS Cs_betalen,
       NULL AS Cs_creditgelden,
       NULL AS Cs_kredieten,
       NULL AS Cs_verzekeren_ondernemer,
       NULL AS Cs_creditcard,
       NULL AS Cs_employee_benefits,
       NULL AS Cs_beleggen,
       NULL AS Cs_lease,
       NULL AS Cs_ifn,
       NULL AS Cs_treasury,
       NULL AS Cs_digitaal_bankieren,
       NULL AS Cs_pakket_prive,
       NULL AS Cs_verzekeren_onderneming,
       NULL AS Aantal_mnd_sinds_productafname,
       NULL AS Startersrekening_ind,
       NULL AS Starterspakket_ind,
       NULL AS MKB_pakket_ind,
       NULL AS VenS_pakket_ind,
       NULL AS Aantal_complexe_producten,
       NULL AS Complexe_producten,
       NULL AS Naw,
       NULL AS Postcode,
       NULL AS Geo_niveau1,
       NULL AS Geo_niveau2,
       NULL AS Geo_niveau3,
       NULL AS SME_regio,
       NULL AS SME_marktgebied,
       NULL AS Postretour_adres_ind,
       NULL AS Telefoon_nr_vast,
       NULL AS Telefoon_nr_mobiel,
       NULL AS Contactpersoon,
       NULL AS Emailadres,
       NULL AS Datum_volgend_contact,
       NULL AS Datum_laatste_contact_pro_ftf,
       NULL AS Datum_laatste_contact_ftf,
       NULL AS Aantal_contact_pro_ftf,
       NULL AS Aantal_contact_ftf,
       NULL AS Aantal_contact_pro_tel,
       NULL AS Aantal_contact_tel,
       NULL AS Faillissement_ind,
       NULL AS Surseance_ind,
       NULL AS Bijzonder_beheer_ind,
       NULL AS CRG,
       NULL AS GSRI_goedgekeurd,
       NULL AS GSRI_Assessment_resultaat,
       NULL AS Aantal_bcs,
       NULL AS Aantal_bcs_in_scope,
       CASE WHEN A.Leidend_bc_pb_ind = 1 THEN A.Business_contact_nr ELSE NULL END AS Leidend_business_contact_nr,
       A.Leidend_bc_pb_ind AS Leidend_bc_ind,
       NULL AS Signaal,
       C.Revisie_datum AS Datum_revisie_TB,
       A.Bc_CCA_TB AS CCA_consultant_TB
  FROM MI_SAS_AA_MB_C_MB.Mia_businesscontacts_NEW A
  JOIN Mi_cmb.vCGC_basis B
    ON A.Bc_clientgroep = B.Clientgroep
  LEFT OUTER JOIN (SELECT XA.Klant_nr,
                          XA.Datum_verval AS Revisie_datum
                     FROM MI_SAS_AA_MB_C_MB.Siebel_Activiteit_TB_revisies_NEW XA
                    WHERE XA.TB_revisie_actueel_ind = 1) AS C
    ON A.Pcnl_nr = C.Klant_nr
  LEFT OUTER JOIN MI_SAS_AA_MB_C_MB.Mia_sector_NEW D
    ON Sbi_codeX = D.Sbi_code
  LEFT OUTER JOIN MI_SAS_AA_MB_C_MB.Mia_sector_NEW E
    ON A.Bc_SBI_code_KvK = E.Sbi_code
  LEFT OUTER JOIN Mi_vm_ldm.aParty_naam F
    ON A.Bc_cca_PB = F.Party_id AND F.Party_sleutel_type = 'AM'
 WHERE A.Pcnl_nr IS NOT NULL
   AND B.Business_line = 'PB'
QUALIFY ROW_NUMBER() OVER (PARTITION BY A.Pcnl_nr ORDER BY A.Leidend_bc_pb_ind, A.Business_contact_nr DESC ) = 1;


CREATE TABLE mi_temp.cst_mi_private_banking_scope
AS
(
SELECT    a.business_contact_nr
        , a.bc_naam
        , a.klant_nr
        , b.Verkorte_naam AS klant_naam
        , c.business_segment
        , a.bc_clientgroep
        , a.bc_bo_nr
        , COALESCE    (MIN( CASE WHEN i.party_deelnemer_rol = 1 THEN a.Business_Contact_nr end ) OVER ( PARTITION BY i.gerelateerd_party_id ) ,
                      MIN( CASE WHEN i.party_deelnemer_rol = 2 THEN a.Business_Contact_nr end ) OVER ( PARTITION BY i.gerelateerd_party_id ),
                        A.business_contact_nr
                    )             AS bc_leidend_bc
        , i.gerelateerd_party_id AS klant_nr_MI

FROM       Mi_temp.Mia_alle_bcs            a
LEFT OUTER JOIN mi_temp.mia_week b
      ON A.Klant_nr = B.Klant_nr
     AND A.Maand_nr = B.Maand_nr
       LEFT OUTER JOIN MI_SAS_AA_MB_C_MB.CGC_BASIS C
  ON
  (CASE WHEN B.klant_nr IS NOT NULL THEN B.clientgroep ELSE A.bc_clientgroep end) = C.clientgroep
LEFT JOIN    mi_vm_ldm.aParty_party_relatie                i     ON  a.business_contact_nr = i.party_id
                                                             AND i.party_sleutel_type = 'BC'
                                                              AND i.party_relatie_type_code = 'LDPCNL' -- ''Relatie geadministreerd bij Private Banking organisatie"
WHERE      a.BC_clientgroep LIKE ANY ('04%', '05%')         -- private banking scope: 04x, 05x
)
WITH DATA
UNIQUE PRIMARY INDEX (business_contact_nr);

INSERT INTO MI_TEMP.Siebel_CST_Member_TEMP
SELECT
 CASE WHEN A.Party_sleutel_type = 'BC' THEN COALESCE(BC.klant_nr, i.klant_nr_MI )-- direct uit businesscontacts, Bij Retail wordt klant_nr opgehaald uit party tabel (Retail heeft niet altijd een klant_nr, dus kan NULL zijn)
      WHEN A.Party_sleutel_type = 'CE' THEN CE.gerelateerd_party_id -- uit party tabel -- uit bc tabel levert dubbele regels op.
      WHEN A.Party_sleutel_type = 'CC' THEN A.party_id -- Uit partyrelatie tabel
      WHEN A.Party_sleutel_type = 'CG' THEN CG.party_id -- Uit partyrelatie tabel op deelnemersrol = 1
 ELSE NULL END AS Klant_nrX
,CASE WHEN A.Party_sleutel_type = 'BC' THEN A.party_id
       WHEN A.Party_sleutel_type <> 'BC' THEN COALESCE(E.business_contact_nr,     i.bc_leidend_bc,NULL)
       END AS Business_contact_nrX -- Leidend_BC van retail wordt opgehaald uit party tabel waarvoor hierboven tijdelijke tabel is aangemaakt. DR: i. als alias toegevoegd voor dudielijkheid
,A.party_sleutel_type AS Client_level
,COALESCE(E.business_contact_nr, CASE WHEN A.Party_sleutel_type = 'BC' THEN bc_leidend_bc ELSE NULL END) AS Leidend_BC    -- Leidend BC kolom is handig voor Retail, omdat deze niet altijd een klant_nr hebben, leidend BC kolom is wel gevuld.
,COALESCE(H.Business_segment, 'Onbekend') AS BC_Business_segment    -- Kolom waaraan je kan zien of het Retail is of niet.
,B. maand_nr
,B. datum_gegevens
,D.sbt_id_mdw
,COALESCE(F.Naam, D.sbt_id_mdw ) AS Naam
,CASE WHEN TRIM(A.sbl_cst_deelnemer_rol) LIKE ANY  ('%1%', '%2%', '%3%', '%4%', '%5%', '%6%', '%7%', '%8%', '%9%', '%0%') THEN X.weergegeven_waarde
      WHEN TRIM(A.sbl_cst_deelnemer_rol) = '' THEN 'Onbekend'
      ELSE COALESCE(TRIM(A.sbl_cst_deelnemer_rol), 'Onbekend')
      END AS SBL_cst_deelnemer_rol
,A.SBL_gedelegeerde_ind AS SBL_gedelegeerde_ind
,'N'              AS TB_Consultant -- Y/N
,A.Party_party_relatie_sdat
,A.Party_party_relatie_edat

FROM MI_VM_LDM.aPARTY_PARTY_RELATIE_cst_member A

LEFT JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW B
ON 1=1

-- klantnummer ophalen
-- Koppeling waar party_sleutel = ' BC'
LEFT JOIN Mi_temp.Mia_alle_bcs   BC
ON a.party_id = BC.Business_contact_nr

-- Koppeling waar party_sleutel = ' CE
LEFT JOIN mi_vm_ldm.aparty_party_relatie CE
ON A.Party_sleutel_type = CE.party_sleutel_type
AND A.party_id = CE.party_id
AND CE.party_hergebruik_volgnr = A.party_hergebruik_volgnr
AND CE.party_sleutel_type = 'CE'
AND CE.gerelateerd_party_sleutel_type = 'CC'

-- Koppeling waar party_sleutel = ' CG
LEFT JOIN mi_vm_ldm.aparty_party_relatie CG
ON A.Party_sleutel_type = CG.gerelateerd_party_sleutel_type
AND A.party_id = CG.gerelateerd_party_id
AND CG.gerelateerd_party_hergebruik_v = A.party_hergebruik_volgnr
AND CG.gerelateerd_party_sleutel_type = 'CG'
AND CG.party_deelnemer_rol = 1 -- Leidende klant om geen dubbelen te krijgen

-- Het ophalen van de Retailklant
LEFT JOIN  mi_temp.cst_mi_private_banking_scope             i
ON  i.business_contact_nr = a.party_id

-- Leidend BC ophalen waar client_level <>  BC
LEFT JOIN(SELECT business_contact_nr, klant_nr , clientgroep
          FROM mi_temp.mia_week
) E
ON E.klant_nr = Klant_nrX

-- Naam ophalen van medewerker
LEFT JOIN MI_VM_LDM.aPositie_cb D
ON A.gerelateerd_party_id = D.party_id
AND A.gerelateerd_party_hergebruik_v = D.party_hergebruik_volgnr
AND A.gerelateerd_party_sleutel_type = D.party_sleutel_type

LEFT JOIN MI_SAS_AA_MB_C_MB.Siebel_Employee_NEW F
ON D.sbt_id_mdw = F.sbt_id

-- Ophalen business-segment
LEFT JOIN Mi_temp.Mia_alle_bcs        G
ON Business_contact_nrX = G.business_contact_nr

LEFT OUTER JOIN MI_SAS_AA_MB_C_MB.CGC_BASIS H
ON (CASE WHEN E.klant_nr IS NOT NULL THEN E.clientgroep
         ELSE G.bc_clientgroep end) = H.clientgroep

-- Rolnamen ophalen
LEFT JOIN (SELECT DISTINCT weergegeven_waarde,
                           taal_onafhankelijke_code
           FROM MI_VM_LDM.aListOfValues_cb
           WHERE trim(lov_type) = 'AABR_RPT_TYPE'
           AND code_taal = 'NLD'
           AND actief_ind = 1
) AS X
ON A.sbl_cst_deelnemer_rol = X.taal_onafhankelijke_code

WHERE (Leidend_BC IS NOT NULL AND Business_contact_nrX IS NOT NULL);

INSERT INTO Mi_temp.Siebel_CST_Member_NEW
SELECT *
FROM (SELECT a.*
      FROM MI_TEMP.Siebel_CST_Member_TEMP a
      QUALIFY RANK () OVER (PARTITION BY Leidend_Business_contact, sbt_id, sbl_cst_deelnemer_rol ORDER BY (CASE WHEN a.client_level = 'CG' THEN 3
                                                            WHEN a.client_level = 'CC' THEN 2
                                                            WHEN a.client_level = 'CE' THEN 1
                                                            WHEN a.client_level = 'BC' THEN 0 END) DESC,
                                                      (ABS(business_contact_nr - leidend_business_contact)) ASC,
                                                       party_party_relatie_sdat DESC,
                                                       sbl_gedelegeerde_ind DESC,
                                                    business_contact_nr DESC) = 1
) AS a
QUALIFY RANK () OVER (PARTITION BY Leidend_Business_contact, sbl_cst_deelnemer_rol ORDER BY (CASE WHEN a.client_level = 'CG' THEN 3
                                                  WHEN a.client_level = 'CC' THEN 2
                                                  WHEN a.client_level = 'CE' THEN 1
                                                  WHEN a.client_level = 'BC' THEN 0 END) DESC) = 1;

CREATE TABLE MI_TEMP.Consultants_CST_member AS
(
SELECT
 Leidend_Business_contact
,a.SBL_cst_deelnemer_rol
,a.SBT_id
,CASE WHEN a.naam IS NOT NULL THEN a.naam
      ELSE a.SBT_id END AS naam
,'Y' AS TB_Consultant
FROM  mi_temp.Siebel_CST_Member_NEW        A
WHERE TRIM(A.SBL_cst_deelnemer_rol) IN ('Cash Management Consultant', 'CTS Consultant', '45')
QUALIFY RANK () OVER (PARTITION BY Leidend_Business_contact ORDER BY (CASE WHEN a.client_level = 'CG' THEN 3
                                       WHEN a.client_level = 'CC' THEN 2
                                       WHEN a.client_level = 'CE' THEN 1
                                       WHEN a.client_level = 'BC' THEN 0 END) DESC,
                                     (CASE WHEN a.SBL_cst_deelnemer_rol IN ('CTS Consultant', '45') THEN 1
                                       ELSE 0 END) DESC,
                                   A.sbt_id DESC ) = 1
GROUP BY 1,2,3,4,5, client_level, SBL_cst_deelnemer_rol
) WITH DATA;

INSERT INTO MI_SAS_AA_MB_C_MB.Siebel_Verkoopteam_Member_NEW
SELECT
 C.klant_nr
,B.maand_nr
,B.datum_gegevens
,C.business_contact_nr
,A.siebel_verkoopkans_id
,D.sbt_id_mdw as sbt_id
,E.naam
,E.bo_nr_mdw
,E.bo_naam_mdw
,E.functie
,A.primary_ind
,C.client_level
,A.salesteam_member_sdat AS sdat
,A.salesteam_member_edat AS edat

FROM mi_vm_ldm.averkoopteam_member_cb A

/* maandnummer toevoegen aan tabel */
LEFT JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW B
ON 1=1

/* toevoegen klant_nr, bc_nr en klantniveau uit verkoopkans tabel zodat als het misgaat het op één plek misgaat */
INNER JOIN MI_SAS_AA_MB_C_MB.siebel_verkoopkans_new C
ON C.siebel_verkoopkans_id = A.siebel_verkoopkans_id

/* sbt_id ophalen uit positietabel */
INNER JOIN mi_vm_ldm.apositie_cb D
ON D.siebel_positie_id = A.siebel_positie_id

/* obv sbt_id overige membergegevens ophalen via de employee tabel */
INNER JOIN MI_SAS_AA_MB_C_MB.siebel_employee_new E
ON E.sbt_id = D.sbt_id_mdw

QUALIFY RANK() OVER(PARTITION BY D.sbt_id_mdw ORDER BY A.primary_ind DESC) = 1 -- Indien sbt_id zowel primary als non-primary dan alleen primary selecteren
;

INSERT INTO MI_SAS_AA_MB_C_MB.Siebel_verkoopkans_contactpersoon_NEW
SELECT
 C.klant_nr
,B.maand_nr
,B.datum_gegevens
,C.business_contact_nr
,A.siebel_verkoopkans_id
,A.primary_ind
,D.siebel_contactpersoon_id
,C.client_level
,A.vk_ctp_sdat AS sdat
,A.vk_ctp_edat AS edat

FROM mi_vm_ldm.averkoopkans_contactpersoon_cb A

/* maandnummer en datum_gegevens toevoegen aan tabel */
LEFT JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW B
ON 1=1

/* toevoegen klant_nr, bc_nr en klantniveau uit verkoopkans tabel zodat als het misgaat het op één plek misgaat */
INNER JOIN MI_SAS_AA_MB_C_MB.siebel_verkoopkans_NEW C
ON C.siebel_verkoopkans_id = A.siebel_verkoopkans_id

/* ivm ophalen overige contactpersoongegevens uit PO's tabel eerst siebel_contactpersoon_id toevoegen*/
INNER JOIN mi_vm_ldm.acontact_persoon_cb D
ON D.party_id = A.party_id_contactpersoon
AND D.party_sleutel_type = A.sleutel_type_contactpersoon
AND D.party_hergebruik_volgnr = A.hergebruik_volgnr_contactpersoon

QUALIFY RANK() OVER(PARTITION BY D.siebel_contactpersoon_id ORDER BY A.primary_ind DESC) = 1 -- Indien siebel_contactpersoon_id zowel primary als non-primary dan alleen primary selecteren
;

INSERT INTO Mi_temp.Wegl_rapportage_moment_t1
SELECT Maand_nr
FROM Mi_temp.Mia_week
GROUP BY 1;

CREATE TABLE Mi_temp.Wegl_rapportage_moment
AS
   (
    SEL  a.*
        ,lm.Maand_sdat AS Ultimomaand_start_datum_tee
        ,lm.Maand_edat AS Ultimomaand_eind_datum_tee
        ,klndr.Jaar_week_nr AS Jaar_week
        ,lm.MaandNrLm  AS MaandNrL1m
        ,lm1.Maand_Edat AS MaandNrL1m_edat
        ,lm2.MaandNrLm AS MaandNrL2m
        ,lm2x.Maand_Edat AS MaandNrL2m_edat
        ,lm.MaandNrL3m
        ,lm3.Maand_Edat AS MaandNrL3m_edat
        ,lm.MaandNrL6m
        ,lm6.Maand_Edat AS MaandNrL6m_edat
        ,lm.MaandNrL9m
        ,lm9.Maand_Edat AS MaandNrL9m_edat
        ,lm.MaandNrLY
        ,lY.Maand_Edat AS MaandNrLY_edat
    FROM Mi_temp.Wegl_rapportage_moment_t1       a
    INNER JOIN Mi_vm.vlu_maand                      lm
       ON ((a.Maand_nr*100) +1-19000000) = lm.maand_sdat
    INNER JOIN Mi_vm.vlu_maand                      lm1
       ON lm1.maand = lm.MaandNrLm
    INNER JOIN Mi_vm.vlu_maand                      lm2
       ON lm2.maand = lm.MaandNrLm
    INNER JOIN Mi_vm.vlu_maand                      lm2x
       ON lm2x.maand = lm2.MaandNrLm
    INNER JOIN Mi_vm.vlu_maand                      lm3
       ON lm3.maand = lm.MaandNrL3m
    INNER JOIN Mi_vm.vlu_maand                      lm6
       ON lm6.maand = lm.MaandNrL6m
    INNER JOIN Mi_vm.vlu_maand                      lm9
       ON lm9.maand = lm.MaandNrL9m
    INNER JOIN Mi_vm.vlu_maand                      lY
       ON lY.maand = lm.MaandNrLY
    INNER JOIN mi_vm.vkalender  klndr
       ON klndr.Datum = DATE
   )   WITH DATA
UNIQUE PRIMARY INDEX ( Maand_nr )
;

INSERT INTO Mi_temp.Cluster_status_basis
SELECT A.Cluster_nr AS Klant_nr,
       1
FROM (SELECT XA.CC_nr AS Cluster_nr
      FROM Mi_vm_nzdb.vCommercieel_cluster XA

      INNER JOIN Mi_vm_nzdb.vCross_sell_cc   c
         ON XA.Cc_nr = c.CC_nr
        AND XA.Maand_nr = c.Maand_nr

      INNER JOIN Mi_temp.Wegl_rapportage_moment XB
         ON XA.Maand_nr = XB.Maand_nr
      WHERE c.MKB_klant_ind = 1
     ) A

        /* 12 maanden terug cluster_nr ook aanwezig als MKB klant */
INNER JOIN
     (SELECT XA.Klant_nr AS Cluster_nr

      FROM Mi_cmb.vMia_hist XA

      INNER JOIN Mi_temp.Wegl_rapportage_moment XB
         ON XA.Maand_nr = XB.MaandNrLY
      WHERE XA.Klant_ind = 1
     ) B
   ON A.Cluster_nr = B.Cluster_nr
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

CREATE TABLE Mi_temp.Wegl_act_week
AS
(
SEL
         a.Klant_nr
        ,a.Maand_nr
        ,bas.Status
        ,a.Klant_ind
        ,a.Verkorte_naam
        ,a.Business_contact_nr
        ,a.Clientgroep
        ,COALESCE(b.Segment, 'NB') AS Bediening
        ,a.CCA
        ,a.Relatiemanager
        ,a.Org_niveau2
        ,a.Org_niveau1
        ,a.Omzet_inkomend
        ,a.Businessvolume
        ,a.Creditvolume
        ,a.Debetvolume
        ,a.Cross_sell
FROM mi_temp.mia_week  a
INNER JOIN Mi_temp.Cluster_status_basis bas
  ON bas.Klant_nr = a.Klant_nr

LEFT OUTER JOIN (SELECT * FROM MI_SAS_AA_MB_C_MB.CGC_BASIS
                 QUALIFY ROW_NUMBER() OVER (PARTITION BY Clientgroep ORDER BY CASE WHEN Vervaldatum IS NULL THEN 1 ELSE 0 END DESC, Vervaldatum DESC) = 1
                ) b
   ON b.Clientgroep = a.Clientgroep

WHERE a.Aantal_jaren_klant >= 1
  AND a.business_line in ('CBC', 'SME')
) WITH DATA
UNIQUE PRIMARY INDEX (Klant_nr);

CREATE TABLE Mi_temp.Wegl_hist_volume
AS
(
SELECT XA.CC_nr AS Klant_nr,
     XA.Maand_nr,
     SUM(XB.Business_volume) AS CC_business_volume,
     SUM(XB.Credit_volume) AS CC_credit_volume,
     SUM(XB.Debet_volume) AS CC_debet_volume
FROM Mi_vm_nzdb.vCommercieel_business_contact XA

INNER JOIN Mi_temp.Wegl_act_week   a
   ON XA.CC_nr = a.Klant_nr

INNER JOIN Mi_temp.Wegl_rapportage_moment    mnd
   ON xa.Maand_nr  BETWEEN mnd.MaandNrLY AND mnd.Maand_NR

LEFT OUTER JOIN Mi_vm_nzdb.vContract_feiten_snapshot XB
   ON XA.CBC_oid = XB.CBC_oid
  AND XA.Maand_nr = XB.Maand_nr

GROUP BY 1, 2
) WITH DATA
UNIQUE PRIMARY INDEX (Maand_nr, Klant_nr);

CREATE TABLE Mi_temp.Wegl_business_vol_items
AS
(
SEL  Klant_nr
    ,MAX(CASE WHEN mnd.Maand_nr < 201308 THEN 11 ELSE 12 END) AS N_mnd_max
    ,MAX(CASE WHEN a.maand_nr = mnd.MaandNRL1m THEN ZEROIFNULL(a.cc_Business_volume) ELSE 0 END) AS Business_vol_L1m
    ,MAX(CASE WHEN a.maand_nr = Mnd.MaandNrLY  THEN ZEROIFNULL(a.cc_Business_volume) ELSE 0 END) AS Business_vol_LY
    ,MIN( ZEROIFNULL(a.cc_Business_volume))    AS Min_Business_volume
    ,MAX( ZEROIFNULL(a.cc_Business_volume))    AS Max_Business_volume
    ,COUNT(DISTINCT a.maand_nr) AS N_mnd
FROM Mi_temp.Wegl_hist_volume a
INNER JOIN Mi_temp.Wegl_rapportage_moment       mnd
   ON 1 = 1
WHERE a.maand_nr BETWEEN mnd.MaandNrLY AND mnd.MaandNRL1m
GROUP BY 1
/* IVM FOUTIEVE DATA AUGUSTUS 2012 SLECHTS 11 MAANDEN MEENEMEN */
HAVING Min_Business_volume > 0 AND N_mnd = N_mnd_max
/*HAVING Min_Business_volume > 0 AND N_mnd = 12*/
) WITH DATA
UNIQUE PRIMARY INDEX (Klant_nr);

CREATE TABLE Mi_temp.Wegl_potentieel
AS
(
SEL  a.*
    ,b.Business_vol_L1m
    ,b.Business_vol_LY
    ,b.Min_Business_volume
    ,b.Max_Business_volume
FROM  Mi_temp.Wegl_act_week     a
JOIN Mi_temp.Wegl_business_vol_items      b
ON a.Klant_nr = b.Klant_nr
WHERE ZEROIFNULL(b.Business_vol_L1m) > 100000
  AND  ZEROIFNULL(a.Businessvolume (FLOAT))/ NULLIFZERO(b.Business_vol_L1m) < 0.8    /* afgelopen maand minimaal 20% daling      */
  AND  ZEROIFNULL(a.Businessvolume (FLOAT))/ NULLIFZERO(b.Min_Business_volume) < 0.8 /* tov. laagste maandsaldo afgelopen 12 mdn */
) WITH DATA
UNIQUE PRIMARY INDEX (Klant_nr);

INSERT INTO MI_SAS_AA_MB_C_MB.Model_wegloop_hist
SELECT a.Klant_nr
      ,mnd.Maand_nr
      ,a.Businessvolume
      ,a.Businessvolume_L1m
      ,a.Businessvolume_LY
      ,a.Min_businessvolume
      ,a.Max_businessvolume
      ,1 AS Retentie_stoplicht
      ,NULL AS Week_1e_retentie_stoplicht
 FROM MI_SAS_AA_MB_C_MB.Model_wegloop_hist a
 LEFT OUTER JOIN Mi_temp.Wegl_act_week           e
   ON a.klant_nr = e.Klant_nr
 JOIN Mi_temp.Wegl_rapportage_moment         mnd
   ON a.Maand_nr  =  mnd.MaandNrL1m
LEFT OUTER JOIN
                (
                SELECT klant_nr
                FROM MI_SAS_AA_MB_C_MB.Model_wegloop_hist         a
                JOIN Mi_temp.Wegl_rapportage_moment       mnd
                  ON a.Maand_nr = mnd.Maand_nr
                GROUP BY 1
                ) b
   ON a.klant_nr = b.klant_nr

 WHERE ZEROIFNULL(week_1e_retentie_stoplicht ) > 0
   AND (CASE WHEN (SUBSTR( (TRIM(BOTH FROM a.week_1e_retentie_stoplicht) (CHAR(6))) , 1,4) (INTEGER)) = (SUBSTR( (TRIM(BOTH FROM mnd.jaar_week) (CHAR(6))) , 1,4) (INTEGER))
             THEN  (SUBSTR( (TRIM(BOTH FROM mnd.jaar_week) (CHAR(6))) , 5,2) (INTEGER)) - (SUBSTR( (TRIM(BOTH FROM a.week_1e_retentie_stoplicht) (CHAR(6))) , 5,2) (INTEGER))
             ELSE   (52 - (SUBSTR( (TRIM(BOTH FROM a.week_1e_retentie_stoplicht) (CHAR(6))) , 5,2) (INTEGER)) )  + (SUBSTR( (TRIM(BOTH FROM mnd.jaar_week) (CHAR(6))) , 5,2) (INTEGER))
             END) BETWEEN 0 AND 3
   AND ZEROIFNULL(b.Klant_nr) = 0;

.IF ERRORCODE <> 0 THEN .GOTO EOP


/* wegschrijven clusters die nog niet zijn opgenomen voor de desbetreffende maand */

INSERT INTO MI_SAS_AA_MB_C_MB.Model_wegloop_hist
SELECT a.Klant_nr
      ,a.Maand_nr
      ,Businessvolume
      ,Business_vol_L1m AS Businessvolume_L1m
      ,Business_vol_LY AS Businessvolume_LY
      ,Min_Business_volume AS Min_businessvolume
      ,Max_Business_volume AS Max_businessvolume
      ,CASE WHEN ZEROIFNULL(c.Klant_nr) = 0 THEN 1 ELSE 0 END AS Retentie_stoplicht
      ,CASE WHEN ZEROIFNULL(c.Klant_nr) = 0 THEN klndr.Jaar_week_nr  ELSE NULL END AS Week_1e_retentie_stoplicht
  FROM Mi_temp.Wegl_potentieel a
  JOIN mi_vm.vkalender  klndr
    ON klndr.Datum = DATE
/* deze maand nog niet weggeschreven */
  LEFT OUTER JOIN (SELECT Klant_nr
                     FROM MI_SAS_AA_MB_C_MB.Model_wegloop_hist        a
                     JOIN Mi_temp.Wegl_rapportage_moment       mnd
                       ON a.Maand_nr = mnd.Maand_nr
                    GROUP BY 1) b
    ON a.Klant_nr = b.Klant_nr
/* afgelopen 2 maanden niet met een stoplicht gesignaleerd dan stoplicht aan, anders uit */
  LEFT OUTER JOIN (SELECT Klant_nr
                     FROM MI_SAS_AA_MB_C_MB.Model_wegloop_hist        a
                     JOIN Mi_temp.Wegl_rapportage_moment       mnd
                       ON a.Maand_nr BETWEEN mnd.MaandNrL2m AND mnd.MaandNrL1m
                    WHERE a.Retentie_stoplicht = 1
                    GROUP BY 1) c
    ON a.Klant_nr = c.Klant_nr

  LEFT OUTER JOIN (SELECT * FROM MI_SAS_AA_MB_C_MB.CGC_BASIS
                 QUALIFY ROW_NUMBER() OVER (PARTITION BY Clientgroep ORDER BY CASE WHEN Vervaldatum IS NULL THEN 1 ELSE 0 END DESC, Vervaldatum DESC) = 1
                ) d
     ON d.Clientgroep = a.Clientgroep

 WHERE ZEROIFNULL(b.Klant_nr) = 0
   AND d.business_line in ('CBC', 'SME')
;

INSERT INTO Mi_temp.Mia_periode_CUBe
SELECT B.Maand_nr,
       D.Datum_gegevens,
       EXTRACT(YEAR FROM ADD_MONTHS(C.Maand_startdatum, -1))*100 + EXTRACT(MONTH FROM ADD_MONTHS(C.Maand_startdatum, -1)) AS Maand_nr_vm1
  FROM Mi_vm_nzdb.vLu_maand_runs B
  JOIN Mi_vm_nzdb.vLu_maand C
    ON B.Maand_nr = C.Maand
  JOIN (SELECT XA.Maand_nr,
               XA.CC_Samenvattings_datum-1 AS Datum_gegevens
          FROM Mi_vm_nzdb.vCommercieel_cluster XA
          JOIN Mi_vm_nzdb.vLU_Maand_Runs XX
            ON XA.Maand_nr = XX.Maand_nr AND XX.Lopende_maand_ind = 1
         GROUP BY 1, 2) AS D
    ON B.Maand_nr = D.Maand_nr
 WHERE B.Lopende_maand_ind = 1
;

INSERT INTO MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW
SELECT * FROM MI_SAS_AA_MB_C_MB.CUBe_leads_hist
;

INSERT INTO MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW
SEL
     a.UUID
    ,a.Klant_nr
    ,a.Business_contact_nr
    ,b.Maand_nr
    ,a.CUBe_product_id
    ,a.Bedrijfstak_id
    ,a.Omzetklasse_id
    ,a.Baten
    ,a.Baten_benchmark
    ,a.Penetratie
    ,a.Lichtbeheer
    ,a.Status
    ,a.N_mnd_status
    ,a.Lead_opvolgen
    ,a.Recordtype
    ,a.Datum_aanlevering
    ,a.Datum_terugkoppeling
    ,a.Siebel_cube_lead_ID
    ,a.Koppeling_id_CC
    ,a.Datum_bijgewerkt
    ,a.SBT_id_mdw_bijgewerkt_door
    ,a.Siebel_verkoopkans_id
    ,a.Siebel_verkoopkans_Status
    ,a.Siebel_verkoopkans_Sdat

FROM MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW a
    -- Indicatie of huidige maand aanwezig is in hist tabel
INNER JOIN (
           SEL MAX(CASE WHEN NOT UUID IS NULL THEN 1 ELSE 0 END)  AS Ind_nieuwe_mnd
           FROM MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW a

           INNER JOIN Mi_temp.Mia_periode_CUBe b
              ON a.Maand_nr = b.Maand_nr
           ) x
    ON 1 = 1
    -- gegevens van voorgaande maand selecteren
INNER JOIN Mi_temp.Mia_periode_CUBe b
   ON a.Maand_nr = b.Maand_nr_vm1

    -- niet in nieuwe maand aanwezig EN (niet verwijderd of verwijderd maar nog geen terugkoppeling)
WHERE ZEROIFNULL(x.Ind_nieuwe_mnd) = 0
  AND (a.Recordtype <> 'D' OR (a.Recordtype = 'D' AND a.Datum_terugkoppeling IS NULL))
;

UPDATE MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW
FROM
     (
     SELECT
             CASE WHEN A.UUID LIKE 'CUBE%' THEN A.UUID ELSE 'CUBE-' || TRIM(UUID) END AS UUID  -- deel van UUID zonder prefix CUBE-
            --,A.Party_id
            ,A.Commercieel_cluster_koppeling_id
            --,A.Reden
            ,A.Status
            ,A.Siebel_campagne_id
            ,A.Cube_lead_sdat
            ,A.Cube_lead_edat

            ,A.Siebel_cube_lead_id
            ,A.Siebel_verkoopkans_id
            ,A.Datum_bijgewerkt
            ,A.SBT_id_mdw_bijgewerkt_door

     FROM Mi_vm_ldm.vOutboundCUBeLead_cb  A
     -- Meest recente rij per UUID  (aView besluit niet de afgesloten rijen vandeer deze methode)
     QUALIFY ROW_NUMBER() OVER (PARTITION BY CASE WHEN A.UUID LIKE 'CUBE%' THEN A.UUID ELSE 'CUBE-' || TRIM(UUID) END
                                ORDER BY Cube_lead_sdat DESC,
                                         (CASE WHEN Cube_lead_edat IS NULL THEN 1 ELSE 0 end) DESC,
                                         Cube_lead_edat DESC
                                ) = 1
     ) A
SET
      Status                     = CASE WHEN NOT A.Cube_lead_edat IS NULL AND MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW.Koppeling_id_CC =  A.Commercieel_cluster_koppeling_id THEN 'Adm Closed - edat gevuld'
                                        WHEN NOT A.Cube_lead_edat IS NULL AND MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW.Koppeling_id_CC <> A.Commercieel_cluster_koppeling_id THEN 'Adm Closed - KopIdCC gewijzigd'
                                        ELSE A.Status
                                   END
     ,Lead_opvolgen              = CASE WHEN TRIM(A.Status) = 'Closed Successfully' AND A.Cube_lead_edat IS NULL   THEN 1
                                        ELSE 0
                                   END
     ,Datum_terugkoppeling       = CASE WHEN NOT A.Cube_lead_edat IS NULL THEN A.Cube_lead_edat ELSE A.Cube_lead_sdat END
     ,Siebel_cube_lead_id        = A.Siebel_cube_lead_id
     ,Koppeling_id_CC            = A.Commercieel_cluster_koppeling_id
     ,Datum_bijgewerkt           = A.Datum_bijgewerkt
     ,SBT_id_mdw_bijgewerkt_door = A.SBT_id_mdw_bijgewerkt_door
     ,Siebel_verkoopkans_id      = A.Siebel_verkoopkans_id
WHERE TRIM(MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW.UUID) = TRIM(A.UUID)
  AND MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW.Maand_nr = (SEL Maand_nr FROM Mi_temp.Mia_periode_CUBe GROUP BY 1)
          -- edat +1 want de edat is (soms) gevuld met de dag voorgaand aan de aanleverdag.....
  AND ((A.Cube_lead_edat + 1) >= MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW.Datum_aanlevering OR A.Cube_lead_edat IS NULL)
;

INSERT INTO Mi_temp.CUBe_benchmark_000
SELECT A.Maand_nr,
       A.Business_line,
       A.Segment,
       A.Subsegment,
       A.Bedrijfstak_id,
       A.Omzetklasse_id,
       A.Dimensie3_id,
       A.Dimensie4_id,
       A.Dimensie5_id,
       COUNT(*) AS N_klanten
  FROM Mi_temp.Mia_klanten A
 WHERE A.Benchmark_ind = 1
 GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9;

INSERT INTO Mi_temp.CUBe_benchmark_001
SELECT A.Maand_nr,
       A.Business_line,
       A.Segment,
       A.Subsegment,
       A.Bedrijfstak_id,
       A.Omzetklasse_id,
       A.Dimensie3_id,
       A.Dimensie4_id,
       A.Dimensie5_id,
       B.CUBe_product_id,

       MIN(D.Min_verhouding),
       MIN(CASE
           WHEN A.Business_line in ('CBC', 'SME') THEN D.Min_benchmark_CC
           ELSE NULL
           END) AS Min_benchmark,
       MIN(CASE
           WHEN A.Business_line in ('CBC', 'SME') THEN D.Min_penetratie_CC
           ELSE NULL
           END) AS Min_penetratie,
       MIN(D.Adresseerbaarheid),
       SUM(CASE WHEN B.Baten NE 0.00 THEN 1 ELSE 0 END) AS N_met_product,
       SUM(B.Baten) AS Baten_product,
       MAX(C.N_klanten) AS N_klanten,
       (SUM(CASE WHEN B.Baten NE 0.00 THEN 1 ELSE 0 END) (DECIMAL(18,6))) /
       (MAX(CASE WHEN A.Business_line in ('CBC', 'SME') AND A.Bedrijfstak_id IS NULL THEN NULL ELSE C.N_klanten END) (DECIMAL(18,6))) AS Penetratie
  FROM Mi_temp.Mia_klanten A
  LEFT OUTER JOIN Mi_temp.Mia_baten B
    ON A.Klant_nr = B.Klant_nr AND A.Maand_nr = B.Maand_nr
  LEFT OUTER JOIN Mi_temp.CUBe_benchmark_000 C
    ON A.Maand_nr = C.Maand_nr
   AND A.Business_line = C.Business_line
   AND ZEROIFNULL(A.Segment) = ZEROIFNULL(C.Segment)
   AND ZEROIFNULL(A.Subsegment) = ZEROIFNULL(C.Subsegment)
   AND ((A.Bedrijfstak_id = C.Bedrijfstak_id) OR (A.Bedrijfstak_id IS NULL AND C.Bedrijfstak_id IS NULL))
   AND ((A.Omzetklasse_id = C.Omzetklasse_id) OR (A.Omzetklasse_id IS NULL AND C.Omzetklasse_id IS NULL))
   AND ((A.Dimensie3_id = C.Dimensie3_id) OR (A.Dimensie3_id IS NULL AND C.Dimensie3_id IS NULL))
   AND ZEROIFNULL(A.Dimensie4_id) = ZEROIFNULL(C.Dimensie4_id)
   AND ZEROIFNULL(A.Dimensie5_id) = ZEROIFNULL(C.Dimensie5_id)
  LEFT OUTER JOIN MI_SAS_AA_MB_C_MB.CUBe_producten D
    ON B.CUBe_product_id = D.CUBe_product_id
 WHERE A.Benchmark_ind = 1
   AND B.CUBe_product_id IS NOT NULL
   AND A.Business_line in ('CBC', 'SME')
 GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10;

INSERT INTO Mi_temp.CUBe_benchmark_002
SELECT A.*,
       MIN(CASE
           WHEN D.CUBe_product_id IN ( 1, 2 ) AND D.Deciel_baten = 2 THEN D.Baten
           WHEN D.CUBe_product_id NOT IN ( 1, 2 ) AND D.Deciel_baten = 3 THEN D.Baten
           ELSE NULL
           END) AS Baten_benchmark,
       MAX(CASE
           WHEN D.CUBe_product_id IN ( 1, 2 ) AND D.Deciel_baten = 2 THEN D.Cumulatieve_baten
           WHEN D.CUBe_product_id NOT IN ( 1, 2 ) AND D.Deciel_baten = 3 THEN D.Cumulatieve_baten
           ELSE NULL
           END) AS Baten_cumulatief,
       (Baten_cumulatief (DECIMAL(18,6))) / (Baten_product (DECIMAL(18,6))) AS Percentage_cumulatief,
       MIN(CASE WHEN A.N_met_product >= 10 AND D.Deciel_baten =  1 THEN D.Baten ELSE NULL END) AS V01,
       MIN(CASE WHEN A.N_met_product >= 10 AND D.Deciel_baten =  2 THEN D.Baten ELSE NULL END) AS V02,
       MIN(CASE WHEN A.N_met_product >= 10 AND D.Deciel_baten =  3 THEN D.Baten ELSE NULL END) AS V03,
       MIN(CASE WHEN A.N_met_product >= 10 AND D.Deciel_baten =  4 THEN D.Baten ELSE NULL END) AS V04,
       MIN(CASE WHEN A.N_met_product >= 10 AND D.Deciel_baten =  5 THEN D.Baten ELSE NULL END) AS V05,
       MIN(CASE WHEN A.N_met_product >= 10 AND D.Deciel_baten =  6 THEN D.Baten ELSE NULL END) AS V06,
       MIN(CASE WHEN A.N_met_product >= 10 AND D.Deciel_baten =  7 THEN D.Baten ELSE NULL END) AS V07,
       MIN(CASE WHEN A.N_met_product >= 10 AND D.Deciel_baten =  8 THEN D.Baten ELSE NULL END) AS V08,
       MIN(CASE WHEN A.N_met_product >= 10 AND D.Deciel_baten =  9 THEN D.Baten ELSE NULL END) AS V09,
       MIN(CASE WHEN A.N_met_product >= 10 AND D.Deciel_baten = 10 THEN D.Baten ELSE NULL END) AS V10,
       MAX(CASE WHEN A.Penetratie >= A.Min_penetratie AND A.N_met_product >= 10 THEN 1 ELSE 0 END) AS Min_penetratie_en_klanten_ind
  FROM Mi_temp.CUBe_benchmark_001 A
  LEFT OUTER JOIN (SELECT A.*,
                          B.CUBe_product_id,
                          B.Baten,
                          QUANTILE( 10, B.Baten ASC, A.Klant_nr ASC) + 1 AS Deciel_baten,
                          CSUM(B.Baten, A.Maand_nr, A.Business_line, A.Segment, A.Subsegment,
                               A.Bedrijfstak_id, A.Omzetklasse_id, A.Dimensie3_id, A.Dimensie4_id,
                               A.Dimensie5_id, B.CUBe_product_id, B.Baten DESC) AS Cumulatieve_baten
                     FROM Mi_temp.Mia_klanten A
                     LEFT OUTER JOIN Mi_temp.Mia_baten B
                       ON A.Klant_nr = B.Klant_nr AND A.Maand_nr = B.Maand_nr AND B.Baten NE 0.00
                    GROUP BY A.Maand_nr, A.Business_line, A.Segment, A.Subsegment, A.Bedrijfstak_id,
                          A.Omzetklasse_id, A.Dimensie3_id, A.Dimensie4_id, A.Dimensie5_id, B.CUBe_product_id) AS D
    ON A.Maand_nr = D.Maand_nr
   AND A.Business_line = D.Business_line
   AND ((A.Segment = D.Segment) OR (A.Segment IS NULL AND D.Segment IS NULL))
   AND ((A.Subsegment = D.Subsegment) OR (A.Subsegment IS NULL AND D.Subsegment IS NULL))
   AND ((A.Bedrijfstak_id = D.Bedrijfstak_id) OR (A.Bedrijfstak_id IS NULL AND D.Bedrijfstak_id IS NULL))
   AND A.Omzetklasse_id = D.Omzetklasse_id
   AND ((A.Dimensie3_id = D.Dimensie3_id) OR (A.Dimensie3_id IS NULL AND D.Dimensie3_id IS NULL))
   AND ((A.Dimensie4_id = D.Dimensie4_id) OR (A.Dimensie4_id IS NULL AND D.Dimensie4_id IS NULL))
   AND ((A.Dimensie5_id = D.Dimensie5_id) OR (A.Dimensie5_id IS NULL AND D.Dimensie5_id IS NULL))
   AND A.CUBe_product_id = D.CUBe_product_id AND A.N_met_product >= 10
 GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18;

INSERT INTO Mi_temp.CUBe_benchmark_003
SELECT A.*,
       0 AS Overgenomen_baten_benchmark
  FROM Mi_temp.CUBe_benchmark_002 A
 WHERE A.Omzetklasse_id = 0
;INSERT INTO Mi_temp.CUBe_benchmark_003
SELECT A.*,
       0 AS Overgenomen_baten_benchmark
  FROM Mi_temp.CUBe_benchmark_002 A
 WHERE A.Omzetklasse_id = 1
   AND A.Min_penetratie_en_klanten_ind = 1
;INSERT INTO Mi_temp.CUBe_benchmark_003
SELECT A.*,
       0 AS Overgenomen_baten_benchmark
  FROM Mi_temp.CUBe_benchmark_002 A
 WHERE A.Omzetklasse_id = 2
   AND A.Min_penetratie_en_klanten_ind = 1;

INSERT INTO Mi_temp.CUBe_benchmark_003
SELECT A.Maand_nr,
       A.Business_line,
       A.Segment,
       A.Subsegment,
       A.Bedrijfstak_id,
       A.Omzetklasse_id,
       A.Dimensie3_id,
       A.Dimensie4_id,
       A.Dimensie5_id,
       A.CUBe_product_id,
       A.Min_verhouding,
       A.Min_benchmark,
       A.Min_penetratie,
       A.Adresseerbaarheid,
       A.N_met_product,
       A.Baten_product,
       A.N_klanten,
       B.Penetratie,
       1.5*B.Baten_benchmark,
       A.Baten_cumulatief,
       A.Percentage_cumulatief,
       A.D01,
       A.D02,
       A.D03,
       A.D04,
       A.D05,
       A.D06,
       A.D07,
       A.D08,
       A.D09,
       A.D10,
       A.Min_penetratie_en_klanten_ind,
       1 AS Overgenomen_baten_benchmark
  FROM Mi_temp.CUBe_benchmark_002 A
  JOIN Mi_temp.CUBe_benchmark_003 B
    ON A.Maand_nr = B.Maand_nr AND A.Business_line = B.Business_line
   AND ((A.Segment = B.Segment) OR (A.Segment IS NULL AND B.Segment IS NULL))
   AND ((A.Subsegment = B.Subsegment) OR (A.Subsegment IS NULL AND B.Subsegment IS NULL))
   AND ((A.Bedrijfstak_id = B.Bedrijfstak_id) OR (A.Bedrijfstak_id IS NULL AND B.Bedrijfstak_id IS NULL))
   AND A.Omzetklasse_id = B.Omzetklasse_id + 1
   AND ((A.Dimensie3_id = B.Dimensie3_id) OR (A.Dimensie3_id IS NULL AND B.Dimensie3_id IS NULL))
   AND ((A.Dimensie4_id = B.Dimensie4_id) OR (A.Dimensie4_id IS NULL AND B.Dimensie4_id IS NULL))
   AND ((A.Dimensie5_id = B.Dimensie5_id) OR (A.Dimensie5_id IS NULL AND B.Dimensie5_id IS NULL))
   AND A.CUBe_product_id = B.CUBe_product_id
   AND (B.Min_penetratie_en_klanten_ind = 1 OR B.Overgenomen_baten_benchmark = 1)
 WHERE A.Omzetklasse_id = 2
   AND A.Min_penetratie_en_klanten_ind = 0
;INSERT INTO Mi_temp.CUBe_benchmark_003
SELECT A.*,
       0 AS Overgenomen_baten_benchmark
  FROM Mi_temp.CUBe_benchmark_002 A
 WHERE A.Omzetklasse_id = 3
   AND A.Min_penetratie_en_klanten_ind = 1;

INSERT INTO Mi_temp.CUBe_benchmark_003
SELECT A.Maand_nr,
       A.Business_line,
       A.Segment,
       A.Subsegment,
       A.Bedrijfstak_id,
       A.Omzetklasse_id,
       A.Dimensie3_id,
       A.Dimensie4_id,
       A.Dimensie5_id,
       A.CUBe_product_id,
       A.Min_verhouding,
       A.Min_benchmark,
       A.Min_penetratie,
       A.Adresseerbaarheid,
       A.N_met_product,
       A.Baten_product,
       A.N_klanten,
       B.Penetratie,
       1.5*B.Baten_benchmark,
       A.Baten_cumulatief,
       A.Percentage_cumulatief,
       A.D01,
       A.D02,
       A.D03,
       A.D04,
       A.D05,
       A.D06,
       A.D07,
       A.D08,
       A.D09,
       A.D10,
       A.Min_penetratie_en_klanten_ind,
       1 AS Overgenomen_baten_benchmark
  FROM Mi_temp.CUBe_benchmark_002 A
  JOIN Mi_temp.CUBe_benchmark_003 B
    ON A.Maand_nr = B.Maand_nr AND A.Business_line = B.Business_line
   AND ((A.Segment = B.Segment) OR (A.Segment IS NULL AND B.Segment IS NULL))
   AND ((A.Subsegment = B.Subsegment) OR (A.Subsegment IS NULL AND B.Subsegment IS NULL))
   AND ((A.Bedrijfstak_id = B.Bedrijfstak_id) OR (A.Bedrijfstak_id IS NULL AND B.Bedrijfstak_id IS NULL))
   AND A.Omzetklasse_id = B.Omzetklasse_id + 1
   AND ((A.Dimensie3_id = B.Dimensie3_id) OR (A.Dimensie3_id IS NULL AND B.Dimensie3_id IS NULL))
   AND ((A.Dimensie4_id = B.Dimensie4_id) OR (A.Dimensie4_id IS NULL AND B.Dimensie4_id IS NULL))
   AND ((A.Dimensie5_id = B.Dimensie5_id) OR (A.Dimensie5_id IS NULL AND B.Dimensie5_id IS NULL))
   AND A.CUBe_product_id = B.CUBe_product_id
   AND (B.Min_penetratie_en_klanten_ind = 1 OR B.Overgenomen_baten_benchmark = 1)
 WHERE A.Omzetklasse_id = 3
   AND A.Min_penetratie_en_klanten_ind = 0
;INSERT INTO Mi_temp.CUBe_benchmark_003
SELECT A.*,
       0 AS Overgenomen_baten_benchmark
  FROM Mi_temp.CUBe_benchmark_002 A
 WHERE A.Omzetklasse_id = 4
   AND A.Min_penetratie_en_klanten_ind = 1;

INSERT INTO Mi_temp.CUBe_benchmark_003
SELECT A.Maand_nr,
       A.Business_line,
       A.Segment,
       A.Subsegment,
       A.Bedrijfstak_id,
       A.Omzetklasse_id,
       A.Dimensie3_id,
       A.Dimensie4_id,
       A.Dimensie5_id,
       A.CUBe_product_id,
       A.Min_verhouding,
       A.Min_benchmark,
       A.Min_penetratie,
       A.Adresseerbaarheid,
       A.N_met_product,
       A.Baten_product,
       A.N_klanten,
       B.Penetratie,
       1.5*B.Baten_benchmark,
       A.Baten_cumulatief,
       A.Percentage_cumulatief,
       A.D01,
       A.D02,
       A.D03,
       A.D04,
       A.D05,
       A.D06,
       A.D07,
       A.D08,
       A.D09,
       A.D10,
       A.Min_penetratie_en_klanten_ind,
       1 AS Overgenomen_baten_benchmark
  FROM Mi_temp.CUBe_benchmark_002 A
  JOIN Mi_temp.CUBe_benchmark_003 B
    ON A.Maand_nr = B.Maand_nr AND A.Business_line = B.Business_line
   AND ((A.Segment = B.Segment) OR (A.Segment IS NULL AND B.Segment IS NULL))
   AND ((A.Subsegment = B.Subsegment) OR (A.Subsegment IS NULL AND B.Subsegment IS NULL))
   AND ((A.Bedrijfstak_id = B.Bedrijfstak_id) OR (A.Bedrijfstak_id IS NULL AND B.Bedrijfstak_id IS NULL))
   AND A.Omzetklasse_id = B.Omzetklasse_id + 1
   AND ((A.Dimensie3_id = B.Dimensie3_id) OR (A.Dimensie3_id IS NULL AND B.Dimensie3_id IS NULL))
   AND ((A.Dimensie4_id = B.Dimensie4_id) OR (A.Dimensie4_id IS NULL AND B.Dimensie4_id IS NULL))
   AND ((A.Dimensie5_id = B.Dimensie5_id) OR (A.Dimensie5_id IS NULL AND B.Dimensie5_id IS NULL))
   AND A.CUBe_product_id = B.CUBe_product_id
   AND (B.Min_penetratie_en_klanten_ind = 1 OR B.Overgenomen_baten_benchmark = 1)
 WHERE A.Omzetklasse_id = 4
   AND A.Min_penetratie_en_klanten_ind = 0
;INSERT INTO Mi_temp.CUBe_benchmark_003
SELECT A.*,
       0 AS Overgenomen_baten_benchmark
  FROM Mi_temp.CUBe_benchmark_002 A
 WHERE A.Omzetklasse_id = 5
   AND A.Min_penetratie_en_klanten_ind = 1;

INSERT INTO Mi_temp.CUBe_benchmark_003
SELECT A.Maand_nr,
       A.Business_line,
       A.Segment,
       A.Subsegment,
       A.Bedrijfstak_id,
       A.Omzetklasse_id,
       A.Dimensie3_id,
       A.Dimensie4_id,
       A.Dimensie5_id,
       A.CUBe_product_id,
       A.Min_verhouding,
       A.Min_benchmark,
       A.Min_penetratie,
       A.Adresseerbaarheid,
       A.N_met_product,
       A.Baten_product,
       A.N_klanten,
       B.Penetratie,
       1.5*B.Baten_benchmark,
       A.Baten_cumulatief,
       A.Percentage_cumulatief,
       A.D01,
       A.D02,
       A.D03,
       A.D04,
       A.D05,
       A.D06,
       A.D07,
       A.D08,
       A.D09,
       A.D10,
       A.Min_penetratie_en_klanten_ind,
       1 AS Overgenomen_baten_benchmark
  FROM Mi_temp.CUBe_benchmark_002 A
  JOIN Mi_temp.CUBe_benchmark_003 B
    ON A.Maand_nr = B.Maand_nr AND A.Business_line = B.Business_line
   AND ((A.Segment = B.Segment) OR (A.Segment IS NULL AND B.Segment IS NULL))
   AND ((A.Subsegment = B.Subsegment) OR (A.Subsegment IS NULL AND B.Subsegment IS NULL))
   AND ((A.Bedrijfstak_id = B.Bedrijfstak_id) OR (A.Bedrijfstak_id IS NULL AND B.Bedrijfstak_id IS NULL))
   AND A.Omzetklasse_id = B.Omzetklasse_id + 1
   AND ((A.Dimensie3_id = B.Dimensie3_id) OR (A.Dimensie3_id IS NULL AND B.Dimensie3_id IS NULL))
   AND ((A.Dimensie4_id = B.Dimensie4_id) OR (A.Dimensie4_id IS NULL AND B.Dimensie4_id IS NULL))
   AND ((A.Dimensie5_id = B.Dimensie5_id) OR (A.Dimensie5_id IS NULL AND B.Dimensie5_id IS NULL))
   AND A.CUBe_product_id = B.CUBe_product_id
   AND (B.Min_penetratie_en_klanten_ind = 1 OR B.Overgenomen_baten_benchmark = 1)
 WHERE A.Omzetklasse_id = 5
   AND A.Min_penetratie_en_klanten_ind = 0
;INSERT INTO Mi_temp.CUBe_benchmark_003
SELECT A.*,
       0 AS Overgenomen_baten_benchmark
  FROM Mi_temp.CUBe_benchmark_002 A
 WHERE A.Omzetklasse_id = 6
   AND A.Min_penetratie_en_klanten_ind = 1;

INSERT INTO Mi_temp.CUBe_benchmark_003
SELECT A.Maand_nr,
       A.Business_line,
       A.Segment,
       A.Subsegment,
       A.Bedrijfstak_id,
       A.Omzetklasse_id,
       A.Dimensie3_id,
       A.Dimensie4_id,
       A.Dimensie5_id,
       A.CUBe_product_id,
       A.Min_verhouding,
       A.Min_benchmark,
       A.Min_penetratie,
       A.Adresseerbaarheid,
       A.N_met_product,
       A.Baten_product,
       A.N_klanten,
       B.Penetratie,
       1.5*B.Baten_benchmark,
       A.Baten_cumulatief,
       A.Percentage_cumulatief,
       A.D01,
       A.D02,
       A.D03,
       A.D04,
       A.D05,
       A.D06,
       A.D07,
       A.D08,
       A.D09,
       A.D10,
       A.Min_penetratie_en_klanten_ind,
       1 AS Overgenomen_baten_benchmark
  FROM Mi_temp.CUBe_benchmark_002 A
  JOIN Mi_temp.CUBe_benchmark_003 B
    ON A.Maand_nr = B.Maand_nr AND A.Business_line = B.Business_line
   AND ((A.Segment = B.Segment) OR (A.Segment IS NULL AND B.Segment IS NULL))
   AND ((A.Subsegment = B.Subsegment) OR (A.Subsegment IS NULL AND B.Subsegment IS NULL))
   AND ((A.Bedrijfstak_id = B.Bedrijfstak_id) OR (A.Bedrijfstak_id IS NULL AND B.Bedrijfstak_id IS NULL))
   AND A.Omzetklasse_id = B.Omzetklasse_id + 1
   AND ((A.Dimensie3_id = B.Dimensie3_id) OR (A.Dimensie3_id IS NULL AND B.Dimensie3_id IS NULL))
   AND ((A.Dimensie4_id = B.Dimensie4_id) OR (A.Dimensie4_id IS NULL AND B.Dimensie4_id IS NULL))
   AND ((A.Dimensie5_id = B.Dimensie5_id) OR (A.Dimensie5_id IS NULL AND B.Dimensie5_id IS NULL))
   AND A.CUBe_product_id = B.CUBe_product_id
   AND (B.Min_penetratie_en_klanten_ind = 1 OR B.Overgenomen_baten_benchmark = 1)
 WHERE A.Omzetklasse_id = 6
   AND A.Min_penetratie_en_klanten_ind = 0;

INSERT INTO Mi_temp.CUBe_benchmark_003
SELECT A.*,
       0 AS Overgenomen_baten_benchmark
  FROM Mi_temp.CUBe_benchmark_002 A
  LEFT OUTER JOIN Mi_temp.CUBe_benchmark_003 B
    ON A.Maand_nr = B.Maand_nr AND A.Business_line = B.Business_line
   AND ((A.Segment = B.Segment) OR (A.Segment IS NULL AND B.Segment IS NULL))
   AND ((A.Subsegment = B.Subsegment) OR (A.Subsegment IS NULL AND B.Subsegment IS NULL))
   AND ((A.Bedrijfstak_id = B.Bedrijfstak_id) OR (A.Bedrijfstak_id IS NULL AND B.Bedrijfstak_id IS NULL))
   AND A.Omzetklasse_id = B.Omzetklasse_id
   AND ((A.Dimensie3_id = B.Dimensie3_id) OR (A.Dimensie3_id IS NULL AND B.Dimensie3_id IS NULL))
   AND ((A.Dimensie4_id = B.Dimensie4_id) OR (A.Dimensie4_id IS NULL AND B.Dimensie4_id IS NULL))
   AND ((A.Dimensie5_id = B.Dimensie5_id) OR (A.Dimensie5_id IS NULL AND B.Dimensie5_id IS NULL))
   AND A.CUBe_product_id = B.CUBe_product_id
 WHERE A.Min_penetratie_en_klanten_ind = 0  AND ZEROIFNULL(B.Overgenomen_baten_benchmark) = 0;

INSERT INTO Mi_temp.Mia_baten_benchmarken_001
SELECT A.Klant_nr,
       A.Maand_nr,
       COALESCE(B.CUBe_product_id, C.CUBe_product_id),
       ZEROIFNULL(C.Baten),

       CASE WHEN B.Min_penetratie_en_klanten_ind + B.Overgenomen_baten_benchmark > 0 THEN B.Baten_benchmark ELSE NULL END,
       B.Penetratie,
       B.Min_verhouding,
       B.Min_benchmark,
       B.Min_penetratie,
       B.Adresseerbaarheid,
       CASE
       WHEN B.Min_penetratie_en_klanten_ind + B.Overgenomen_baten_benchmark > 0 AND
            ZEROIFNULL(C.Baten) < B.Min_verhouding*B.Baten_benchmark AND
            B.Baten_benchmark > B.Min_benchmark AND
            B.Penetratie > B.Min_penetratie THEN 1
       ELSE 0
       END AS Lichtje
FROM Mi_temp.Mia_klanten A
LEFT OUTER JOIN Mi_temp.Mia_baten C
   ON A.Maand_nr = C.Maand_nr AND A.Klant_nr = C.Klant_nr
LEFT OUTER JOIN Mi_temp.CUBe_benchmark_003 B
   ON A.Maand_nr = B.Maand_nr
  AND A.Business_line = B.Business_line
  --AND ((A.Segment = B.Segment) OR (A.Segment IS NULL AND B.Segment IS NULL))      /*NU ALTIJD NULL JOIN LATER MOGELIJK WEL NODIG VOOR SME*/
  --AND ZEROIFNULL(A.Subsegment) = ZEROIFNULL(B.Subsegment)                            /*NU ALTIJD NULL JOIN LATER MOGELIJK WEL NODIG VOOR SME*/
  AND ZEROIFNULL(A.Bedrijfstak_id) = ZEROIFNULL(B.Bedrijfstak_id)
  AND A.Omzetklasse_id = B.Omzetklasse_id
  AND ((A.Dimensie3_id = B.Dimensie3_id) OR (A.Dimensie3_id IS NULL AND B.Dimensie3_id IS NULL))
  AND ZEROIFNULL(A.Dimensie4_id) = ZEROIFNULL(B.Dimensie4_id)
  AND ZEROIFNULL(A.Dimensie5_id) = ZEROIFNULL(B.Dimensie5_id)
  AND (B.CUBe_product_id = C.CUBe_product_id OR (B.CUBe_product_id IS NULL AND C.CUBe_product_id IS NOT NULL))
WHERE A.Business_line IN ('CBC', 'SME', 'CIB')
;

INSERT INTO Mi_temp.Mia_baten_benchmarken_002
SELECT A.Klant_nr,
       A.Maand_nr,
       A.CUBe_product_id,
       A.Baten,
       A.Baten_benchmark,
       A.Penetratie,
       A.Min_verhouding,
       A.Min_benchmark,
       A.Min_penetratie,
       A.Adresseerbaarheid,
       MAX(CASE
           WHEN A.CUBe_product_id =  1 AND B.CUBe_product_id =  9 AND A.Baten_benchmark <=  3*B.Baten THEN 2
           WHEN A.CUBe_product_id = 25 AND B.CUBe_product_id =  9 AND A.Baten_benchmark <=  3*B.Baten THEN 2
           WHEN A.CUBe_product_id = 26 AND B.CUBe_product_id =  9 AND A.Baten_benchmark <= 10*B.Baten THEN 2
           WHEN A.CUBe_product_id =  9 AND B.CUBe_product_id =  1 AND A.Baten_benchmark <=  3*B.Baten THEN 2
           WHEN A.CUBe_product_id =  9 AND B.CUBe_product_id = 25 AND A.Baten_benchmark <=  3*B.Baten THEN 2
           ELSE A.Lichtbeheer
           END) AS Lichtje
  FROM Mi_temp.Mia_baten_benchmarken_001 A
  LEFT OUTER JOIN Mi_temp.Mia_baten_benchmarken_001 B
    ON A.Klant_nr = B.Klant_nr
   AND A.Maand_nr = B.Maand_nr
   AND (
        (A.CUBe_product_id =  1 AND B.CUBe_product_id =  9) OR
        (A.CUBe_product_id = 25 AND B.CUBe_product_id =  9) OR
        (A.CUBe_product_id = 26 AND B.CUBe_product_id =  9) OR
        (A.CUBe_product_id =  9 AND B.CUBe_product_id =  1) OR
        (A.CUBe_product_id =  9 AND B.CUBe_product_id = 25)
       )
 WHERE A.CUBe_product_id IN (1, 9, 25, 26)
   AND A.Lichtbeheer = 1 /* Voorwaarde: eerste donkergroen en dan pas lichtgroen */
 GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.Mia_baten_benchmarken_001 COLUMN CUBe_product_id;

.IF ERRORCODE <> 0 THEN .GOTO EOP

INSERT INTO Mi_temp.Mia_baten_benchmarken_002
SELECT A.*
  FROM Mi_temp.Mia_baten_benchmarken_001 A
 WHERE A.CUBe_product_id NOT IN (1, 9, 25, 26)
;

INSERT INTO Mi_temp.Mia_baten_benchmarken_002
SELECT A.*
  FROM Mi_temp.Mia_baten_benchmarken_001 A
 WHERE A.CUBe_product_id IN (1, 9, 25, 26)
   AND A.Lichtbeheer NE 1;

INSERT INTO Mi_temp.Mia_baten_benchmarken_003
SELECT A.Klant_nr,
       A.Maand_nr,
       25 AS CUBe_product_id,  /* Lease */
       NULL AS Baten,
       CASE
       WHEN A.Omzetklasse_id = 0 THEN 1500
       WHEN A.Omzetklasse_id = 1 THEN 1500
       WHEN A.Omzetklasse_id = 2 THEN 3000
       WHEN A.Omzetklasse_id = 3 THEN 5000
       WHEN A.Omzetklasse_id = 4 THEN 10000
       WHEN A.Omzetklasse_id >= 5 THEN 25000
       END AS Baten_benchmark,
       NULL AS Penetratie,
       NULL AS Min_verhouding,
       NULL AS Min_benchmark,
       NULL AS Min_penetratie,
       NULL AS Adresseerbaarheid,
       3 AS Lichtje
  FROM Mi_temp.Mia_klanten A
  JOIN (SELECT XC.Klant_nr
          FROM (SELECT XXA.Contract_Nr,
                       XXA.Contract_Soort_Code
                  FROM Mi_vm_ldm.vGeld_contract_event XXA
                 WHERE XXA.Tegenrekening_nr_num IN (650010744, 586814701, 235048631, 270208305, 300072651, 4504107) /* Andere lessors */
                   AND XXA.Mutatie_bedrag_DC_ind = 'D'
                   AND XXA.Valuta_Datum >= ADD_MONTHS(DATE, -12)
                 GROUP BY 1, 2) AS XA
          JOIN Mi_vm_ldm.aParty_contract XB
            ON XA.Contract_nr = XB.Contract_nr AND XA.Contract_soort_code = XB.Contract_soort_code
           AND XB.Party_sleutel_type = 'bc'
          JOIN Mi_temp.Mia_klantkoppelingen XC
            ON XB.Party_id = XC.Business_contact_nr
         GROUP BY 1) AS B
    ON A.Klant_nr = B.Klant_nr
   AND A.Klant_nr NOT IN (SELECT X.Klant_nr
                            FROM Mi_temp.Mia_baten_benchmarken_003 X
                           WHERE X.CUBe_product_id = 25)  /* Lease */
;

INSERT INTO Mi_temp.Mia_baten_benchmarken_003
SELECT A.Klant_nr,
       A.Maand_nr,
       26 AS CUBe_product_id,  /* Factoring */
       NULL AS Baten,
       CASE
       WHEN A.Omzetklasse_id = 3 THEN 20000
       WHEN A.Omzetklasse_id = 4 THEN 30000
       WHEN A.Omzetklasse_id >= 5 THEN 40000
       END AS Baten_benchmark,
       NULL AS Penetratie,
       NULL AS Min_verhouding,
       NULL AS Min_benchmark,
       NULL AS Min_penetratie,
       NULL AS Adresseerbaarheid,
       3 AS Lichtje
  FROM Mi_temp.Mia_klanten A
 WHERE A.Omzetklasse_id >= 3 /* 2,5 mln omzet of meer */
   AND A.Bedrijfstak_id IN (SELECT X.Bedrijfstak_id
                              FROM MI_SAS_AA_MB_C_MB.CUBe_bedrijfstak X
                             WHERE X.Factoring = 1)
   AND A.Klant_nr NOT IN (SELECT X.Klant_nr
                            FROM Mi_temp.Mia_baten_benchmarken_003 X
                           WHERE X.CUBe_product_id = 26)  /* Factoring */
   AND A.Business_line in ('CBC', 'SME')
;

INSERT INTO Mi_temp.Mia_baten_benchmarken_003
SELECT A.Klant_nr,
       A.Maand_nr,
       26 AS CUBe_product_id,  /* Factoring */
       NULL AS Baten,
       CASE
       WHEN A.Omzetklasse_id = 3 THEN 20000
       WHEN A.Omzetklasse_id = 4 THEN 30000
       WHEN A.Omzetklasse_id >= 5 THEN 40000
       END AS Baten_benchmark,
       NULL AS Penetratie,
       NULL AS Min_verhouding,
       NULL AS Min_benchmark,
       NULL AS Min_penetratie,
       NULL AS Adresseerbaarheid,
       4 AS Lichtje
  FROM Mi_temp.Mia_klanten A
  JOIN Mi_temp.Mia_week B
    ON A.Klant_nr = B.Klant_nr AND A.Maand_nr = B.Maand_nr
 WHERE A.Omzetklasse_id >= 3 /* 2,5 mln omzet of meer */
   AND B.CRG > 2
   AND A.Klant_nr IN (SELECT X.Klant_nr
                          FROM Mi_temp.Mia_baten_benchmarken_002 X
                         WHERE X.CUBe_product_id = 1 /* Kredieten */
                           AND X.Baten > 2*X.Baten_benchmark)
   AND A.Klant_nr NOT IN (SELECT X.Klant_nr
                              FROM Mi_temp.Mia_baten_benchmarken_003 X
                             WHERE X.CUBe_product_id = 26)  /* Factoring */
   AND A.Business_line in ('CBC', 'SME')
;

INSERT INTO Mi_temp.Mia_baten_benchmarken_003
SELECT A.Klant_nr,
       A.Maand_nr,
       12 AS CUBe_product_id,  /* International Cash Management */
       NULL AS Baten,
       CASE
       WHEN A.Omzetklasse_id = 2 THEN 250
       WHEN A.Omzetklasse_id = 3 THEN 500
       WHEN A.Omzetklasse_id = 4 THEN 750
       WHEN A.Omzetklasse_id >= 5 THEN 1500
       END AS Baten_benchmark,
       NULL AS Penetratie,
       NULL AS Min_verhouding,
       NULL AS Min_benchmark,
       NULL AS Min_penetratie,
       NULL AS Adresseerbaarheid,
       3 AS Lichtje
  FROM Mi_temp.Mia_klanten A
  JOIN Mi_temp.Mia_week B
    ON A.Klant_nr = B.Klant_nr AND A.Maand_nr = B.Maand_nr
 WHERE B.Verkorte_naam LIKE ANY ('%EUROPE%', '%EUROPA%', '%INTERNAT%', '%TRADING%', '%IMPORT%', '%EXPORT%')
   AND A.Klant_nr NOT IN (SELECT X.Klant_nr
                              FROM Mi_temp.Mia_baten_benchmarken_003 X
                             WHERE X.CUBe_product_id = 12)  /* International Cash Management */
   AND A.Omzetklasse_id > 1
   AND A.Business_line in ('CBC', 'SME');

INSERT INTO Mi_temp.Mia_baten_benchmarken_003
SELECT A.Klant_nr,
       A.Maand_nr,
       12 AS CUBe_product_id,  /* International Cash Management */
       NULL AS Baten,
       CASE
       WHEN A.Omzetklasse_id = 2 THEN 250
       WHEN A.Omzetklasse_id = 3 THEN 500
       WHEN A.Omzetklasse_id = 4 THEN 750
       WHEN A.Omzetklasse_id >= 5 THEN 1500
       END AS Baten_benchmark,
       NULL AS Penetratie,
       NULL AS Min_verhouding,
       NULL AS Min_benchmark,
       NULL AS Min_penetratie,
       NULL AS Adresseerbaarheid,
       3 AS Lichtje
  FROM Mi_temp.Mia_klanten A
  JOIN Mi_temp.Mia_week B
    ON A.Klant_nr = B.Klant_nr AND A.Maand_nr = B.Maand_nr
 WHERE A.Klant_nr IN (SELECT X.Klant_nr
                          FROM Mi_temp.Mia_baten_benchmarken_002 X
                         WHERE X.CUBe_product_id = 6 /* Valutaderivaten */
                           AND X.Baten > 1000)
   AND A.Klant_nr NOT IN (SELECT X.Klant_nr
                              FROM Mi_temp.Mia_baten_benchmarken_003 X
                             WHERE X.CUBe_product_id = 12)  /* International Cash Management */
   AND A.Omzetklasse_id > 1
   AND A.Business_line in ('CBC', 'SME')
;

INSERT INTO Mi_temp.Mia_baten_benchmarken_003
SELECT A.Klant_nr,
       A.Maand_nr,
       12 AS CUBe_product_id,  /* International Cash Management */
       NULL AS Baten,
       CASE
       WHEN A.Omzetklasse_id = 2 THEN 250
       WHEN A.Omzetklasse_id = 3 THEN 500
       WHEN A.Omzetklasse_id = 4 THEN 750
       WHEN A.Omzetklasse_id >= 5 THEN 1500
       END AS Baten_benchmark,
       NULL AS Penetratie,
       NULL AS Min_verhouding,
       NULL AS Min_benchmark,
       NULL AS Min_penetratie,
       NULL AS Adresseerbaarheid,
       3 AS Lichtje
  FROM Mi_temp.Mia_klanten A
  JOIN Mi_temp.Mia_week B
    ON A.Klant_nr = B.Klant_nr AND A.Maand_nr = B.Maand_nr
 WHERE A.Klant_nr IN (SELECT X.Klant_nr
                          FROM Mi_temp.Mia_baten_benchmarken_002 X
                         WHERE X.CUBe_product_id = 14 /* Documentary credit */
                           AND X.Baten > 100)
   AND A.Klant_nr NOT IN (SELECT X.Klant_nr
                              FROM Mi_temp.Mia_baten_benchmarken_003 X
                             WHERE X.CUBe_product_id = 12) /* International Cash Management */
   AND A.Omzetklasse_id > 1
   AND A.Business_line in ('CBC', 'SME')
;

INSERT INTO Mi_temp.Mia_baten_benchmarken_003
SELECT A.Klant_nr,
       A.Maand_nr,
       80 AS CUBe_product_id,  /* Acquisitie */
       NULL AS Baten,
       NULL AS Baten_benchmark,
       NULL AS Penetratie,
       NULL AS Min_verhouding,
       NULL AS Min_benchmark,
       NULL AS Min_penetratie,
       NULL AS Adresseerbaarheid,
       1 AS Lichtje
  FROM Mi_temp.Mia_klanten A
  JOIN Mi_temp.Mia_week B
    ON A.Klant_nr = B.Klant_nr AND A.Maand_nr = B.Maand_nr
 WHERE (A.Business_line in ('CBC', 'SME'))
   AND B.Klantstatus = 'S';

INSERT INTO Mi_temp.Mia_baten_benchmarken_003
SELECT A.Cluster_nr,
       A.Maand_nr,
       81 AS CUBe_product_id,  /* Retentie */
       NULL AS Baten,
       NULL AS Baten_benchmark,
       NULL AS Penetratie,
       NULL AS Min_verhouding,
       NULL AS Min_benchmark,
       NULL AS Min_penetratie,
       NULL AS Adresseerbaarheid,
       2 AS Lichtje /* Oranje: signaal maar niet voor het eerst */

/* bestaand -> zit dus in Mi_cmb.CUBe_leads_hist                          */
FROM Mi_cmb.CUBe_leads_hist A

 /* niet lopende maand maar max maand ingelezen leads voor het geval dat beide maanden ongelijk aan elkaar zijn */
  JOIN (SEL MAX(Maand_nr) AS Maand_nr
        FROM Mi_cmb.CUBe_leads_hist
        ) XX
    ON A.Maand_nr = XX.Maand_nr
  JOIN Mi_vm.vKalender XY
    ON XY.Datum = DATE

/* niet ouder dan 3 mnd -> week eerste signaal max 3 maanden oud tov draaidatum (DATE) */
  JOIN MI_SAS_AA_MB_C_MB.Model_wegloop_hist B
    ON A.Cluster_nr = B.Klant_nr
  JOIN Mi_vm.vKalender XZ /* dag van eerste signaal */
    ON B.Week_1e_retentie_stoplicht = XZ.Jaar_week_nr
   AND XY.Dag_naam = XZ.Dag_naam

WHERE A.CUBe_product_id = 81
   AND XZ.Datum > ADD_MONTHS(XY.Datum, -3);


INSERT INTO Mi_temp.Mia_baten_benchmarken_003
SELECT A.Klant_nr,
       A.Maand_nr,
       81 AS CUBe_product_id,  /* Retentie */
       NULL AS Baten,
       NULL AS Baten_benchmark,
       NULL AS Penetratie,
       NULL AS Min_verhouding,
       NULL AS Min_benchmark,
       NULL AS Min_penetratie,
       NULL AS Adresseerbaarheid,
       CASE
       WHEN A.Week_1e_retentie_stoplicht = XY.Jaar_week_nr THEN 1 /* Rood: deze week voor het eerst gesignaleerd */
       WHEN A.Retentie_stoplicht = 1 THEN 2 /* Oranje: signaal maar niet voor het eerst */
       ELSE 0
       END AS Lichtje

/* retentie signalen */
FROM MI_SAS_AA_MB_C_MB.Model_wegloop_hist A
  JOIN Mi_vm_nzdb.vLU_Maand_Runs XX
    ON A.Maand_nr = XX.Maand_nr
   AND XX.Lopende_maand_ind = 1
  JOIN Mi_vm.vKalender XY
    ON XY.Datum = DATE

/* nieuw -> zit dus NOG NIET in Mi_cmb.CUBe_leads_hist
   !!! eenmaal gesignaleerd, nooit meer gesignaleerd. Eenmaal gecontroleerd is klant in beeld (?); eventueel seizoenspatroon er uit gefilterd */
  LEFT OUTER JOIN (SELECT D.Cluster_nr
                   FROM Mi_cmb.CUBe_leads_hist D
                   WHERE D.CUBe_product_id = 81 GROUP BY 1
                   ) D
    ON A.Klant_nr = D.Cluster_nr
WHERE A.Retentie_stoplicht = 1
  AND D.Cluster_nr IS NULL
;

INSERT INTO Mi_temp.Mia_baten_benchmarken_004
SELECT A.Klant_nr,
       A.Maand_nr,
       A.CUBe_product_id,
       A.Baten,
       CASE
       WHEN B.CUBe_product_id IN (5, 8, 12, 25, 26) AND B.Baten_benchmark > 0 AND (A.Baten_benchmark = 0 OR A.Baten_benchmark IS NULL) THEN B.Baten_benchmark
       ELSE A.Baten_benchmark
       END AS Baten_benchmark,
       A.Penetratie,
       A.Min_verhouding,
       A.Min_benchmark,
       A.Min_penetratie,
       A.Adresseerbaarheid,
       CASE
       WHEN A.Baten >= A.Baten_benchmark*A.Min_verhouding AND B.Lichtbeheer >= 3 THEN 0
       WHEN A.Baten >= B.Baten_benchmark AND B.Lichtbeheer >= 3 THEN 0
       WHEN A.Lichtbeheer = 0 THEN ZEROIFNULL(B.Lichtbeheer)
       ELSE A.Lichtbeheer
       END AS Lichtje
  FROM Mi_temp.Mia_baten_benchmarken_002 A
  LEFT OUTER JOIN Mi_temp.Mia_baten_benchmarken_003 B
    ON A.Klant_nr = B.Klant_nr
   AND A.Maand_nr = B.Maand_nr
   AND A.CUBe_product_id = B.CUBe_product_id;

INSERT INTO Mi_temp.Mia_baten_benchmarken_005
SELECT A.Klant_nr,
       A.Maand_nr,
       A.CUBe_product_id,
       B.UUID,
       A.Baten,
       A.Baten_benchmark,
       A.Penetratie,
       A.Min_verhouding,
       A.Min_benchmark,
       A.Min_penetratie,
       A.Adresseerbaarheid,
       A.Lichtbeheer,
       CASE WHEN A.Lichtbeheer > 0 THEN A.Baten_benchmark - A.Baten
            ELSE 0
       END AS Baten_potentieel,
       Baten_potentieel * A.Adresseerbaarheid,
       B.Status,
       B.N_mnd_status
FROM Mi_temp.Mia_baten_benchmarken_004 A

LEFT OUTER JOIN (SEL * FROM MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW XA
                 QUALIFY ROW_NUMBER() OVER (PARTITION BY Klant_nr, Maand_nr, CUBe_product_id ORDER BY UUID DESC) = 1
                ) B
  ON A.Klant_nr = B.Klant_nr
 AND A.Maand_nr = B.Maand_nr
 AND A.CUBe_product_id = B.CUBe_product_id
;

INSERT INTO Mi_temp.Mia_baten_benchmarken_006
SELECT A.Klant_nr,
       SUM(A.Baten) AS Baten_totaal,
       SUM(A.Baten_potentieel) AS Baten_potentieel,

       SUM(CASE WHEN A.CUBe_product_id =  1 THEN A.Baten ELSE NULL END), /* Kredieten */
       SUM(CASE WHEN A.CUBe_product_id =  1 THEN A.Lichtbeheer ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id =  1 THEN A.N_mnd_status ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id =  1 THEN A.Baten_benchmark ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id =  1 THEN A.Penetratie ELSE NULL END),
       MAX(CASE WHEN A.CUBe_product_id <> 1 THEN NULL
                WHEN ZEROIFNULL(A.Lichtbeheer) = 0 AND (A.Status IS NULL OR A.Status =  'New') THEN 'nee'
                WHEN ZEROIFNULL(A.Lichtbeheer) > 0 AND A.Status IS NULL THEN 'ja'
                ELSE A.Status END),

       SUM(CASE WHEN A.CUBe_product_id = 25 THEN A.Baten ELSE NULL END), /* Lease */
       SUM(CASE WHEN A.CUBe_product_id = 25 THEN A.Lichtbeheer ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 25 THEN A.N_mnd_status ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 25 THEN A.Baten_benchmark ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 25 THEN A.Penetratie ELSE NULL END),
       MAX(CASE WHEN A.CUBe_product_id <> 25 THEN NULL
                WHEN ZEROIFNULL(A.Lichtbeheer) = 0 AND (A.Status IS NULL OR A.Status =  'New') THEN 'nee'
                WHEN ZEROIFNULL(A.Lichtbeheer) > 0 AND A.Status IS NULL THEN 'ja'
                ELSE A.Status END),

       SUM(CASE WHEN A.CUBe_product_id = 26 THEN A.Baten ELSE NULL END), /* Factoring */
       SUM(CASE WHEN A.CUBe_product_id = 26 THEN A.Lichtbeheer ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 26 THEN A.N_mnd_status ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 26 THEN A.Baten_benchmark ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 26 THEN A.Penetratie ELSE NULL END),
       MAX(CASE WHEN A.CUBe_product_id <> 26 THEN NULL
                WHEN ZEROIFNULL(A.Lichtbeheer) = 0 AND (A.Status IS NULL OR A.Status =  'New') THEN 'nee'
                WHEN ZEROIFNULL(A.Lichtbeheer) > 0 AND A.Status IS NULL THEN 'ja'
                ELSE A.Status END),

       SUM(CASE WHEN A.CUBe_product_id =  9 THEN A.Baten ELSE NULL END), /* Creditgelden */
       SUM(CASE WHEN A.CUBe_product_id =  9 THEN A.Lichtbeheer ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id =  9 THEN A.N_mnd_status ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id =  9 THEN A.Baten_benchmark ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id =  9 THEN A.Penetratie ELSE NULL END),
       MAX(CASE WHEN A.CUBe_product_id <> 9 THEN NULL
                WHEN ZEROIFNULL(A.Lichtbeheer) = 0 AND (A.Status IS NULL OR A.Status =  'New') THEN 'nee'
                WHEN ZEROIFNULL(A.Lichtbeheer) > 0 AND A.Status IS NULL THEN 'ja'
                ELSE A.Status END),

       SUM(CASE WHEN A.CUBe_product_id = 11 THEN A.Baten ELSE NULL END), /* Domestic_cash */
       SUM(CASE WHEN A.CUBe_product_id = 11 THEN A.Lichtbeheer ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 11 THEN A.N_mnd_status ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 11 THEN A.Baten_benchmark ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 11 THEN A.Penetratie ELSE NULL END),
       MAX(CASE WHEN A.CUBe_product_id <>  11 THEN NULL
                WHEN ZEROIFNULL(A.Lichtbeheer) = 0 AND (A.Status IS NULL OR A.Status =  'New') THEN 'nee'
                WHEN ZEROIFNULL(A.Lichtbeheer) > 0 AND A.Status IS NULL THEN 'ja'
                ELSE A.Status END),

       SUM(CASE WHEN A.CUBe_product_id = 18 THEN A.Baten ELSE NULL END), /* iDEAL */
       SUM(CASE WHEN A.CUBe_product_id = 18 THEN A.Lichtbeheer ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 18 THEN A.N_mnd_status ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 18 THEN A.Baten_benchmark ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 18 THEN A.Penetratie ELSE NULL END),
       MAX(CASE WHEN A.CUBe_product_id <> 18 THEN NULL
                WHEN ZEROIFNULL(A.Lichtbeheer) = 0 AND (A.Status IS NULL OR A.Status =  'New') THEN 'nee'
                WHEN ZEROIFNULL(A.Lichtbeheer) > 0 AND A.Status IS NULL THEN 'ja'
                ELSE A.Status END),

       SUM(CASE WHEN A.CUBe_product_id = 12 THEN A.Baten ELSE NULL END), /* International_cash */
       SUM(CASE WHEN A.CUBe_product_id = 12 THEN A.Lichtbeheer ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 12 THEN A.N_mnd_status ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 12 THEN A.Baten_benchmark ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 12 THEN A.Penetratie ELSE NULL END),
       MAX(CASE WHEN A.CUBe_product_id <> 12 THEN NULL
                WHEN ZEROIFNULL(A.Lichtbeheer) = 0 AND (A.Status IS NULL OR A.Status =  'New') THEN 'nee'
                WHEN ZEROIFNULL(A.Lichtbeheer) > 0 AND A.Status IS NULL THEN 'ja'
                ELSE A.Status END),

       SUM(CASE WHEN A.CUBe_product_id = 10 THEN A.Baten ELSE NULL END), /* Cards */
       SUM(CASE WHEN A.CUBe_product_id = 10 THEN A.Lichtbeheer ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 10 THEN A.N_mnd_status ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 10 THEN A.Baten_benchmark ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 10 THEN A.Penetratie ELSE NULL END),
       MAX(CASE WHEN A.CUBe_product_id <> 10 THEN NULL
                WHEN ZEROIFNULL(A.Lichtbeheer) = 0 AND (A.Status IS NULL OR A.Status =  'New') THEN 'nee'
                WHEN ZEROIFNULL(A.Lichtbeheer) > 0 AND A.Status IS NULL THEN 'ja'
                ELSE A.Status END),

       SUM(CASE WHEN A.CUBe_product_id = 14 THEN A.Baten ELSE NULL END), /* Documentary collection en - credit */
       SUM(CASE WHEN A.CUBe_product_id = 14 THEN A.Lichtbeheer ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 14 THEN A.N_mnd_status ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 14 THEN A.Baten_benchmark ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 14 THEN A.Penetratie ELSE NULL END),
       MAX(CASE WHEN A.CUBe_product_id <> 14 THEN NULL
                WHEN ZEROIFNULL(A.Lichtbeheer) = 0 AND (A.Status IS NULL OR A.Status =  'New') THEN 'nee'
                WHEN ZEROIFNULL(A.Lichtbeheer) > 0 AND A.Status IS NULL THEN 'ja'
                ELSE A.Status END),

       SUM(CASE WHEN A.CUBe_product_id = 13 THEN A.Baten ELSE NULL END), /* Garanties */
       SUM(CASE WHEN A.CUBe_product_id = 13 THEN A.Lichtbeheer ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 13 THEN A.N_mnd_status ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 13 THEN A.Baten_benchmark ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 13 THEN A.Penetratie ELSE NULL END),
       MAX(CASE WHEN A.CUBe_product_id <> 13 THEN NULL
                WHEN ZEROIFNULL(A.Lichtbeheer) = 0 AND (A.Status IS NULL OR A.Status =  'New') THEN 'nee'
                WHEN ZEROIFNULL(A.Lichtbeheer) > 0 AND A.Status IS NULL THEN 'ja'
                ELSE A.Status END),

       SUM(CASE WHEN A.CUBe_product_id =  2 THEN A.Baten ELSE NULL END), /* Schade */
       SUM(CASE WHEN A.CUBe_product_id =  2 THEN A.Lichtbeheer ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id =  2 THEN A.N_mnd_status ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id =  2 THEN A.Baten_benchmark ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id =  2 THEN A.Penetratie ELSE NULL END),
       MAX(CASE WHEN A.CUBe_product_id <> 2 THEN NULL
                WHEN ZEROIFNULL(A.Lichtbeheer) = 0 AND (A.Status IS NULL OR A.Status =  'New') THEN 'nee'
                WHEN ZEROIFNULL(A.Lichtbeheer) > 0 AND A.Status IS NULL THEN 'ja'
                ELSE A.Status END),

       SUM(CASE WHEN A.CUBe_product_id =  3 THEN A.Baten ELSE NULL END), /* Leven en Pensioen */
       SUM(CASE WHEN A.CUBe_product_id =  3 THEN A.Lichtbeheer ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id =  3 THEN A.N_mnd_status ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id =  3 THEN A.Baten_benchmark ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id =  3 THEN A.Penetratie ELSE NULL END),
       MAX(CASE WHEN A.CUBe_product_id <> 3 THEN NULL
                WHEN ZEROIFNULL(A.Lichtbeheer) = 0 AND (A.Status IS NULL OR A.Status =  'New') THEN 'nee'
                WHEN ZEROIFNULL(A.Lichtbeheer) > 0 AND A.Status IS NULL THEN 'ja'
                ELSE A.Status END),

       SUM(CASE WHEN A.CUBe_product_id =  4 THEN A.Baten ELSE NULL END), /* Zorg en Inkomen */
       SUM(CASE WHEN A.CUBe_product_id =  4 THEN A.Lichtbeheer ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id =  4 THEN A.N_mnd_status ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id =  4 THEN A.Baten_benchmark ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id =  4 THEN A.Penetratie ELSE NULL END),
       MAX(CASE WHEN A.CUBe_product_id <> 4 THEN NULL
                WHEN ZEROIFNULL(A.Lichtbeheer) = 0 AND (A.Status IS NULL OR A.Status =  'New') THEN 'nee'
                WHEN ZEROIFNULL(A.Lichtbeheer) > 0 AND A.Status IS NULL THEN 'ja'
                ELSE A.Status END),

       SUM(CASE WHEN A.CUBe_product_id =  5 THEN A.Baten ELSE NULL END), /* Rentederivaten */
       SUM(CASE WHEN A.CUBe_product_id =  5 THEN A.Lichtbeheer ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id =  5 THEN A.N_mnd_status ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id =  5 THEN A.Baten_benchmark ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id =  5 THEN A.Penetratie ELSE NULL END),
       MAX(CASE WHEN A.CUBe_product_id <> 5 THEN NULL
                WHEN ZEROIFNULL(A.Lichtbeheer) = 0 AND (A.Status IS NULL OR A.Status =  'New') THEN 'nee'
                WHEN ZEROIFNULL(A.Lichtbeheer) > 0 AND A.Status IS NULL THEN 'ja'
                ELSE A.Status END),

       SUM(CASE WHEN A.CUBe_product_id =  6 THEN A.Baten ELSE NULL END), /* Valutaderivaten */
       SUM(CASE WHEN A.CUBe_product_id =  6 THEN A.Lichtbeheer ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id =  6 THEN A.N_mnd_status ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id =  6 THEN A.Baten_benchmark ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id =  6 THEN A.Penetratie ELSE NULL END),
       MAX(CASE WHEN A.CUBe_product_id <> 6 THEN NULL
                WHEN ZEROIFNULL(A.Lichtbeheer) = 0 AND (A.Status IS NULL OR A.Status =  'New') THEN 'nee'
                WHEN ZEROIFNULL(A.Lichtbeheer) > 0 AND A.Status IS NULL THEN 'ja'
                ELSE A.Status END),

       SUM(CASE WHEN A.CUBe_product_id = 24 THEN A.Baten ELSE NULL END), /* Effecten */
       SUM(CASE WHEN A.CUBe_product_id = 24 THEN A.Lichtbeheer ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 24 THEN A.N_mnd_status ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 24 THEN A.Baten_benchmark ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 24 THEN A.Penetratie ELSE NULL END),
       MAX(CASE WHEN A.CUBe_product_id <> 24 THEN NULL
                WHEN ZEROIFNULL(A.Lichtbeheer) = 0 AND (A.Status IS NULL OR A.Status =  'New') THEN 'nee'
                WHEN ZEROIFNULL(A.Lichtbeheer) > 0 AND A.Status IS NULL THEN 'ja'
                ELSE A.Status END),

       SUM(CASE WHEN A.CUBe_product_id =  8 THEN A.Baten ELSE NULL END), /* Commodity */
       SUM(CASE WHEN A.CUBe_product_id =  8 THEN A.Lichtbeheer ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id =  8 THEN A.N_mnd_status ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id =  8 THEN A.Baten_benchmark ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id =  8 THEN A.Penetratie ELSE NULL END),
       MAX(CASE WHEN A.CUBe_product_id <> 8 THEN NULL
                WHEN ZEROIFNULL(A.Lichtbeheer) = 0 AND (A.Status IS NULL OR A.Status =  'New') THEN 'nee'
                WHEN ZEROIFNULL(A.Lichtbeheer) > 0 AND A.Status IS NULL THEN 'ja'
                ELSE A.Status END),

       SUM(CASE WHEN A.CUBe_product_id = 17 THEN A.Baten ELSE NULL END), /* Corporate Finance */
       SUM(CASE WHEN A.CUBe_product_id = 17 THEN A.Lichtbeheer ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 17 THEN A.N_mnd_status ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 17 THEN A.Baten_benchmark ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 17 THEN A.Penetratie ELSE NULL END),
       MAX(CASE WHEN A.CUBe_product_id <> 17 THEN NULL
                WHEN ZEROIFNULL(A.Lichtbeheer) = 0 AND (A.Status IS NULL OR A.Status =  'New') THEN 'nee'
                WHEN ZEROIFNULL(A.Lichtbeheer) > 0 AND A.Status IS NULL THEN 'ja'
                ELSE A.Status END),

       NULL, /* CBI_cmts */
       SUM(CASE WHEN A.CUBe_product_id = 70 THEN A.Baten ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 70 THEN A.Lichtbeheer ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 70 THEN A.N_mnd_status ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 70 THEN A.Baten_benchmark ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 70 THEN A.Penetratie ELSE NULL END),
       MAX(CASE WHEN A.CUBe_product_id <> 70 THEN NULL
                WHEN ZEROIFNULL(A.Lichtbeheer) = 0 AND (A.Status IS NULL OR A.Status =  'New') THEN 'nee'
                WHEN ZEROIFNULL(A.Lichtbeheer) > 0 AND A.Status IS NULL THEN 'ja'
                ELSE A.Status END),

       NULL, /* CBI_kredieten */
       SUM(CASE WHEN A.CUBe_product_id = 71 THEN A.Baten ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 71 THEN A.Lichtbeheer ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 71 THEN A.N_mnd_status ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 71 THEN A.Baten_benchmark ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 71 THEN A.Penetratie ELSE NULL END),
       MAX(CASE WHEN A.CUBe_product_id <> 71 THEN NULL
                WHEN ZEROIFNULL(A.Lichtbeheer) = 0 AND (A.Status IS NULL OR A.Status =  'New') THEN 'nee'
                WHEN ZEROIFNULL(A.Lichtbeheer) > 0 AND A.Status IS NULL THEN 'ja'
                ELSE A.Status END),
       NULL, /* CBI_treasury */
       SUM(CASE WHEN A.CUBe_product_id = 72 THEN A.Baten ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 72 THEN A.Lichtbeheer ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 72 THEN A.N_mnd_status ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 72 THEN A.Baten_benchmark ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 72 THEN A.Penetratie ELSE NULL END),
       MAX(CASE WHEN A.CUBe_product_id <> 72 THEN NULL
                WHEN ZEROIFNULL(A.Lichtbeheer) = 0 AND (A.Status IS NULL OR A.Status =  'New') THEN 'nee'
                WHEN ZEROIFNULL(A.Lichtbeheer) > 0 AND A.Status IS NULL THEN 'ja'
                ELSE A.Status END),

       NULL, /* CBI_trade */
       SUM(CASE WHEN A.CUBe_product_id = 73 THEN A.Baten ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 73 THEN A.Lichtbeheer ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 73 THEN A.N_mnd_status ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 73 THEN A.Baten_benchmark ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 73 THEN A.Penetratie ELSE NULL END),
       MAX(CASE WHEN A.CUBe_product_id <> 73 THEN NULL
                WHEN ZEROIFNULL(A.Lichtbeheer) = 0 AND (A.Status IS NULL OR A.Status =  'New') THEN 'nee'
                WHEN ZEROIFNULL(A.Lichtbeheer) > 0 AND A.Status IS NULL THEN 'ja'
                ELSE A.Status END),

       SUM(CASE WHEN A.CUBe_product_id = 80 THEN A.Baten ELSE NULL END), /* Acquisitie */
       SUM(CASE WHEN A.CUBe_product_id = 80 THEN A.Lichtbeheer ELSE NULL END),
       MAX(CASE WHEN A.CUBe_product_id = 80 AND A.Lichtbeheer > 0 THEN 'Prospect' ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 80 THEN A.Baten_benchmark ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 80 THEN A.Penetratie ELSE NULL END),
       MAX(CASE WHEN A.CUBe_product_id <> 80 THEN NULL
                WHEN ZEROIFNULL(A.Lichtbeheer) = 0 AND (A.Status IS NULL OR A.Status =  'New') THEN 'nee'
                WHEN ZEROIFNULL(A.Lichtbeheer) > 0 AND A.Status IS NULL THEN 'ja'
                ELSE A.Status END),

       SUM(CASE WHEN A.CUBe_product_id = 81 THEN A.Baten ELSE NULL END), /* Retentie */
       SUM(CASE WHEN A.CUBe_product_id = 81 THEN A.Lichtbeheer ELSE NULL END),
       MAX(CASE WHEN A.CUBe_product_id = 81 AND A.Lichtbeheer > 0 THEN 'Hoog' ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 81 THEN A.Baten_benchmark ELSE NULL END),
       SUM(CASE WHEN A.CUBe_product_id = 81 THEN A.Penetratie ELSE NULL END),
       MAX(CASE WHEN A.CUBe_product_id <> 81 THEN NULL
                WHEN ZEROIFNULL(A.Lichtbeheer) = 0 AND (A.Status IS NULL OR A.Status =  'New') THEN 'nee'
                WHEN ZEROIFNULL(A.Lichtbeheer) > 0 AND A.Status IS NULL THEN 'ja'
                ELSE A.Status END),

       MAX(CASE WHEN D.Specialist_oms = 'CM&TS' AND A.Status NOT IN ('nee', 'Nu even niet') THEN 1 ELSE 0 END), /* AANPASSEN AAN NIEUWE STATUSSEN */
       MAX(CASE WHEN D.Specialist_oms = 'Factoring' AND A.Status NOT IN ('nee', 'Nu even niet') THEN 1 ELSE 0 END), /* AANPASSEN AAN NIEUWE STATUSSEN */
       MAX(CASE WHEN D.Specialist_oms = 'Lease' AND A.Status NOT IN ('nee', 'Nu even niet') THEN 1 ELSE 0 END), /* AANPASSEN AAN NIEUWE STATUSSEN */
       MAX(CASE WHEN D.Specialist_oms = 'Markets' AND A.Status NOT IN ('nee', 'Nu even niet') THEN 1 ELSE 0 END), /* AANPASSEN AAN NIEUWE STATUSSEN */
       MAX(CASE WHEN D.Specialist_oms = 'Verzekeren' AND A.Status NOT IN ('nee', 'Nu even niet') THEN 1 ELSE 0 END), /* AANPASSEN AAN NIEUWE STATUSSEN */
       MAX(CASE WHEN D.Specialist_oms LIKE 'CBI%' AND A.Status NOT IN ('nee', 'Nu even niet') THEN 1 ELSE 0 END) /* AANPASSEN AAN NIEUWE STATUSSEN */

  FROM Mi_temp.Mia_baten_benchmarken_005 A
  LEFT OUTER JOIN MI_SAS_AA_MB_C_MB.CUBe_producten D
    ON A.CUBe_product_id = D.CUBe_product_id
 GROUP BY 1;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.Mia_week COLUMN Klant_ind;
COLLECT STATISTICS Mi_temp.Mia_week COLUMN Business_contact_nr;
COLLECT STATISTICS Mi_temp.Mia_week COLUMN (Klant_nr);
COLLECT STATISTICS Mi_temp.Mia_baten_benchmarken_006 COLUMN Klant_nr;
COLLECT STATISTICS COLUMN (MAAND_NR) ON Mi_temp.Mia_week;
COLLECT STATISTICS COLUMN (MAAND_EINDE_JAAR) ON MI_SAS_AA_MB_C_MB.Mia_periode_NEW;
COLLECT STATISTICS COLUMN (KLANT_NR) ON Mi_temp.Mia_baten_benchmarken_006;

.IF ERRORCODE <> 0 THEN .GOTO EOP

CREATE TABLE Mi_temp.CUBe_baten
      (
       Klant_nr INTEGER,
       Maand_nr INTEGER,
       Datum_gegevens DATE FORMAT 'YYYY-MM-DD',
       Datum_baten DATE FORMAT 'YYYY-MM-DD',
       Baten DECIMAL(18,2),
       Baten_potentieel DECIMAL(18,2),
       Kredieten_baten DECIMAL(18,2),
       Kredieten_stoplicht BYTEINT,
       Kredieten_bmark DECIMAL(18,2),
       Kredieten_pen DECIMAL(10,4),
       Lease_baten DECIMAL(18,2),
       Lease_stoplicht BYTEINT,
       Lease_bmark DECIMAL(18,2),
       Lease_pen DECIMAL(10,4),
       Factoring_baten DECIMAL(18,2),
       Factoring_stoplicht BYTEINT,
       Factoring_bmark DECIMAL(18,2),
       Factoring_pen DECIMAL(10,4),
       Creditgelden_baten DECIMAL(18,2),
       Creditgelden_stoplicht BYTEINT,
       Creditgelden_bmark DECIMAL(18,2),
       Creditgelden_pen DECIMAL(10,4),
       Domestic_cash_baten DECIMAL(18,2),
       Domestic_cash_stoplicht BYTEINT,
       Domestic_cash_bmark DECIMAL(18,2),
       Domestic_cash_pen DECIMAL(10,4),
       iDEAL_baten DECIMAL(18,2),
       iDEAL_stoplicht BYTEINT,
       iDEAL_bmark DECIMAL(18,2),
       iDEAL_pen DECIMAL(10,4),
       International_cash_baten DECIMAL(18,2),
       International_cash_stoplicht BYTEINT,
       International_cash_bmark DECIMAL(18,2),
       International_cash_pen DECIMAL(10,4),
       Cards_baten DECIMAL(18,2),
       Cards_stoplicht BYTEINT,
       Cards_bmark DECIMAL(18,2),
       Cards_pen DECIMAL(10,4),
       Documentary_colcred_baten DECIMAL(18,2),
       Documentary_colcred_stoplicht BYTEINT,
       Documentary_colcred_bmark DECIMAL(18,2),
       Documentary_colcred_pen DECIMAL(10,4),
       Garanties_baten DECIMAL(18,2),
       Garanties_stoplicht BYTEINT,
       Garanties_bmark DECIMAL(18,2),
       Garanties_pen DECIMAL(10,4),

       Schade_baten DECIMAL(18,2),

       Rentederivaten_baten DECIMAL(18,2),
       Rentederivaten_stoplicht BYTEINT,
       Rentederivaten_bmark DECIMAL(18,2),
       Rentederivaten_pen DECIMAL(10,4),
       Valutaderivaten_baten DECIMAL(18,2),
       Valutaderivaten_stoplicht BYTEINT,
       Valutaderivaten_bmark DECIMAL(18,2),
       Valutaderivaten_pen DECIMAL(10,4),
       Effecten_baten DECIMAL(18,2),
       Effecten_stoplicht BYTEINT,
       Effecten_bmark DECIMAL(18,2),
       Effecten_pen DECIMAL(10,4),
       Commodity_baten DECIMAL(18,2),
       Commodity_stoplicht BYTEINT,
       Commodity_bmark DECIMAL(18,2),
       Commodity_pen DECIMAL(10,4),
       Corp_finance_baten DECIMAL(18,2),
       Corp_finance_stoplicht BYTEINT,
       Corp_finance_bmark DECIMAL(18,2),
       Corp_finance_pen DECIMAL(10,4),
       Buitenland_CBI_baten DECIMAL(18,2),
       Acquisitie_stoplicht BYTEINT,
       Acquisitie_status VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
       Retentie_stoplicht BYTEINT,
       Retentie_status VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC
      )
UNIQUE PRIMARY INDEX ( Klant_nr, Maand_nr);

.IF ERRORCODE <> 0 THEN .GOTO EOP

INSERT INTO Mi_temp.CUBe_baten
SELECT A.Klant_nr,
       A.Maand_nr,
       A.Datum_gegevens,
       E.Maand_SDAT AS Datum_baten,
       B.Baten,
       B.Baten_potentieel,
       B.Kredieten_baten,
       ZEROIFNULL(B.Kredieten_stoplicht),
       B.Kredieten_bmark,
       B.Kredieten_pen,
       B.Lease_baten,
       ZEROIFNULL(B.Lease_stoplicht),
       B.Lease_bmark,
       B.Lease_pen,
       B.Factoring_baten,
       ZEROIFNULL(B.Factoring_stoplicht),
       B.Factoring_bmark,
       B.Factoring_pen,
       B.Creditgelden_baten,
       ZEROIFNULL(B.Creditgelden_stoplicht),
       B.Creditgelden_bmark,
       B.Creditgelden_pen,
       B.Domestic_cash_baten,
       ZEROIFNULL(B.Domestic_cash_stoplicht),
       B.Domestic_cash_bmark,
       B.Domestic_cash_pen,
       B.iDEAL_baten,
       ZEROIFNULL(B.iDEAL_stoplicht),
       B.iDEAL_bmark,
       B.iDEAL_pen,
       B.International_cash_baten,
       ZEROIFNULL(B.International_cash_stoplicht),
       B.International_cash_bmark,
       B.International_cash_pen,
       B.Cards_baten,
       ZEROIFNULL(B.Cards_stoplicht),
       B.Cards_bmark,
       B.Cards_pen,
       B.Documentary_colcred_baten,
       ZEROIFNULL(B.Documentary_colcred_stoplicht),
       B.Documentary_colcred_bmark,
       B.Documentary_colcred_pen,
       B.Garanties_baten,
       ZEROIFNULL(B.Garanties_stoplicht),
       B.Garanties_bmark,
       B.Garanties_pen,

       B.Schade_baten,

       B.Rentederivaten_baten,
       ZEROIFNULL(B.Rentederivaten_stoplicht),
       B.Rentederivaten_bmark,
       B.Rentederivaten_pen,
       B.Valutaderivaten_baten,
       ZEROIFNULL(B.Valutaderivaten_stoplicht),
       B.Valutaderivaten_bmark,
       B.Valutaderivaten_pen,
       B.Effecten_baten,
       ZEROIFNULL(B.Effecten_stoplicht),
       B.Effecten_bmark,
       B.Effecten_pen,
       B.Commodity_baten,
       ZEROIFNULL(B.Commodity_stoplicht),
       B.Commodity_bmark,
       B.Commodity_pen,
       B.Corp_finance_baten,
       ZEROIFNULL(B.Corp_finance_stoplicht),
       B.Corp_finance_bmark,
       B.Corp_finance_pen,
       B.CBI_cmts_baten AS Buitenland_CBI_baten,
       ZEROIFNULL(B.Acquisitie_stoplicht),
       B.Acquisitie_status,
       ZEROIFNULL(B.Retentie_stoplicht),
       B.Retentie_status

  FROM Mi_temp.Mia_week A
  LEFT OUTER JOIN Mi_temp.Mia_baten_benchmarken_006 B
    ON A.Klant_nr = B.Klant_nr
  JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW D
    ON A.Maand_nr = D.Maand_nr
  LEFT OUTER JOIN Mi_vm.vLu_maand E
    ON D.Maand_einde_jaar = E.Maand
 WHERE (A.Klant_ind = 1 OR Klantstatus = 'S');

INSERT INTO Mi_temp.CUBe_leadstatus
SELECT A.Klant_nr,
       A.Maand_nr,
       A.Datum_gegevens,
       E.Maand_SDAT AS Datum_baten,
       D.Datum_leads,
       B.Kredieten_n_mnd_lead,
       B.Kredieten_lead,
       B.Lease_n_mnd_lead,
       B.Lease_lead,
       B.Factoring_n_mnd_lead,
       B.Factoring_lead,
       B.Creditgelden_n_mnd_lead,
       B.Creditgelden_lead,
       B.Domestic_cash_n_mnd_lead,
       B.Domestic_cash_lead,
       B.iDEAL_n_mnd_lead,
       B.iDEAL_lead,
       B.International_cash_n_mnd_lead,
       B.International_cash_lead,
       B.Cards_n_mnd_lead,
       B.Cards_lead,
       B.Documentary_colcred_n_mnd_lead,
       B.Documentary_colcred_lead,
       B.Garanties_n_mnd_lead,
       B.Garanties_lead,
       B.Rentederivaten_n_mnd_lead,
       B.Rentederivaten_lead,
       B.Valutaderivaten_n_mnd_lead,
       B.Valutaderivaten_lead,
       B.Effecten_n_mnd_lead,
       B.Effecten_lead,
       B.Commodity_n_mnd_lead,
       B.Commodity_lead,
       B.Corp_finance_n_mnd_lead,
       B.Corp_finance_lead,
       B.CBI_cmts_n_mnd_lead,
       B.CBI_cmts_lead,
       B.Acquisitie_lead,
       B.Retentie_lead
  FROM Mi_temp.Mia_week A
  LEFT OUTER JOIN Mi_temp.Mia_baten_benchmarken_006 B
    ON A.Klant_nr = B.Klant_nr
  JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW D
    ON A.Maand_nr = D.Maand_nr
  LEFT OUTER JOIN Mi_vm.vLu_maand E
    ON D.Maand_einde_jaar = E.Maand
 WHERE (A.Klant_ind = 1 OR Klantstatus = 'S');

INSERT INTO MI_SAS_AA_MB_C_MB.CIAA_Cube_Baten_hist_NEW
SELECT *
  FROM Mi_temp.CUBe_baten;

INSERT INTO Mi_cmb.CUBe_leadstatus_hist
SELECT *
  FROM Mi_temp.CUBe_leadstatus;

INSERT INTO MI_SAS_AA_MB_C_MB.CUBe_model
SELECT *
  FROM Mi_temp.CUBe_benchmark_003;

INSERT INTO Mi_temp.Part_zak_periode SELECT (SELECT MAX(Maand) AS Maand_FHH FROM Mi_vm_info.vLU_FHH), (SELECT MAX(Maand) AS Maand_PBNL FROM Mi_vm_info.vLU_PBNL);

CREATE TABLE Mi_temp.Part_zak_t1_BC
AS
(
SEL  a.Maand_nr
    ,a.Klant_nr
    ,a.Klantstatus
    ,a.Klant_ind
    ,c.cbc_part_bc_relatie_type_code AS Relatie_code
    ,CASE WHEN c.cbc_part_bc_relatie_type_code = 'UBOOND' THEN '01 UBO'
          WHEN c.cbc_part_bc_relatie_type_code = 'BSTOND' THEN '02 Bestuurder'
          WHEN c.cbc_part_bc_relatie_type_code = 'OANDO'  THEN '03 O en O'
          WHEN c.cbc_part_bc_relatie_type_code = 'ENMSZK' THEN '04 Eenmanszaak'
          WHEN c.cbc_part_bc_relatie_type_code = 'VNTCOM' THEN '05 Commanditaire Vennootschap'
          WHEN c.cbc_part_bc_relatie_type_code = 'VNTVOF' THEN '06 Vennootschap Onder Firma'
          WHEN c.cbc_part_bc_relatie_type_code = 'MTSCHP' THEN '07 Maatschap'
          WHEN c.cbc_part_bc_relatie_type_code = 'BVNVOP' THEN '08 BV of NV in oprichting'
          WHEN c.cbc_part_bc_relatie_type_code = 'BCTCBC' THEN '09 Particulier-Zakelijk'
          ELSE '10 Overig'
         END AS Relatie_oms

    ,c.part_bc_oid    AS Part_BC_nr
    ,e.Segment_id       AS Part_bc_CGC
    ,f.Segment_id       AS Part_bc_RelCat
    ,i.Naam           AS Part_bc_naam
    ,g.Nationaliteit  AS Part_bc_Nationaliteit
    ,g.Geboorte_datum AS Part_bc_Geb_datum
    ,(CASE
        WHEN EXTRACT(DAY FROM A.Datum_gegevens) < EXTRACT(DAY FROM g.Geboorte_datum) THEN (((A.Datum_gegevens - g.Geboorte_datum) MONTH(4)) (INTEGER)) - 1
        ELSE (((A.Datum_gegevens - g.Geboorte_datum) MONTH(4)) (INTEGER))
        END) / 12 AS Part_bc_Leeftijd
    ,g.Overleden_ind     AS Part_bc_Overleden_ind
    ,g.Geslacht         AS Part_bc_geslacht
    ,j.Post_adres_id    AS Part_bc_Post_adres_id
    ,h.Gerelateerd_party_id AS FHH
    /*,h2.Gerelateerd_party_id AS PBNL*/
    ,h3.PBNL AS PBNL

FROM Mi_temp.Mia_week    a

INNER JOIN Mi_vm_nzdb.vCommercieel_business_contact  b
   ON b.maand_nr = a.maand_nr
  AND b.cc_nr = a.Klant_nr

INNER JOIN Mi_vm_nzdb.vCbc_part_bc_relatie c
   ON c.maand_nr = b.maand_nr
  AND c.cbc_oid = b.cbc_oid

LEFT OUTER JOIN mi_vm_ldm.aParty_relatie_type d
   ON d.Party_relatie_type_code = c.cbc_part_bc_relatie_type_code

LEFT OUTER JOIN MI_vm_ldm.aSegment_klant e
   ON e.Party_id = c.part_bc_oid
  AND e.Segment_type_code = 'CG'
  AND e.Party_sleutel_type = 'BC'

LEFT OUTER JOIN MI_vm_ldm.aSegment_klant f
   ON f.Party_id = c.part_bc_oid
  AND f.Segment_type_code = 'RELCAT'
  AND f.Party_sleutel_type = 'BC'

LEFT OUTER JOIN MI_vm_ldm.aIndividu g
   ON g.Party_id = c.part_bc_oid
  AND g.Party_sleutel_type = 'BC'

LEFT OUTER JOIN Mi_vm_ldm.aParty_party_relatie h
   ON h.Party_id = c.part_bc_oid
  AND h.Party_sleutel_type = 'BC'
  AND h.Gerelateerd_party_sleutel_type = 'FH'

LEFT OUTER JOIN Mi_vm_ldm.aParty_party_relatie h2
   ON h2.Party_id = c.part_bc_oid
  AND h2.Party_sleutel_type = 'BC'
  AND h2.Gerelateerd_party_sleutel_type = 'PC'

LEFT OUTER JOIN (
                  SELECT PBNL
                  FROM  Mi_vm_info.vLU_PBNL    a
                  INNER JOIN Mi_temp.Part_zak_periode   b
                   ON b.Maand_PBNL = a.Maand
                  /*AND Bediening_Nr > 0
                  AND NOT (Bediening_Nr BETWEEN 50820301 AND 50820306)
                  AND NOT (Prv_Bnk_Nr   BETWEEN 50820701 AND 50820702)
                  AND NOT Prv_Bnk_Nr MOD 100 IN (98,99)
                  */
                  GROUP BY 1
                ) h3
  ON h3.PBNL = h2.Gerelateerd_party_id

LEFT OUTER JOIN Mi_vm_ldm.aParty_naam i
   ON i.Party_id = c.part_bc_oid
  AND i.Party_sleutel_type = 'BC'

LEFT OUTER JOIN Mi_vm_ldm.aParty_post_adres  j
   ON j.Party_id = c.part_bc_oid
  AND j.Party_sleutel_type = 'BC'


WHERE a.Business_line in ('CBC', 'SME', 'CIB')
  AND c.cbc_part_bc_relatie_type_code <> 'FHPART'
  AND e.Segment_id BETWEEN '0100' AND '0599'
  AND TRIM(f.Segment_id) = '20'
  AND g.Geslacht IN ('M', 'V')
) WITH DATA
PRIMARY INDEX(Klant_nr)
;

INSERT INTO Mi_temp.Part_zak_t1_BC
SEL  a.Maand_nr
    ,a.Klant_nr
    ,a.Klantstatus
    ,a.Klant_ind
     ,TRIM(BOTH FROM k.Contract_soort_oms_kort) AS Relatie_code
    ,'99 Gemachtigd zakelijk contr' AS Relatie_oms
    /*
    ,c.Contract_nr
    ,c.Contract_soort_code
    ,c.Contract_hergebruik_volgnr
    */
    ,d2.Party_id AS Part_bc_nr
    ,e.Segment_id       AS Part_bc_CGC
    ,f.Segment_id       AS Part_bc_RelCat
    ,i.Naam           AS Part_bc_naam
    ,g.Nationaliteit  AS Part_bc_Nationaliteit
    ,g.Geboorte_datum AS Part_bc_Geb_datum
    ,(CASE
        WHEN EXTRACT(DAY FROM A.Datum_gegevens) < EXTRACT(DAY FROM g.Geboorte_datum) THEN (((A.Datum_gegevens - g.Geboorte_datum) MONTH(4)) (INTEGER)) - 1
        ELSE (((A.Datum_gegevens - g.Geboorte_datum) MONTH(4)) (INTEGER))
        END) / 12 AS Part_bc_Leeftijd
    ,g.Overleden_ind     AS Part_bc_Overleden_ind
    ,g.Geslacht         AS Part_bc_geslacht
    ,j.Post_adres_id    AS Part_bc_Post_adres_id
    ,h.Gerelateerd_party_id AS FHH
    /*,h2.Gerelateerd_party_id AS PBNL*/
    ,h3.PBNL AS PBNL

FROM Mi_temp.Mia_week    a

INNER JOIN Mi_vm_nzdb.vCommercieel_business_contact  b
   ON b.maand_nr = a.maand_nr
  AND b.cc_nr = a.Klant_nr

INNER JOIN mi_vm_ldm.aparty_contract        c
   ON c.Party_id = b.cBc_nr
  AND c.Party_sleutel_type = 'BC'

INNER JOIN mi_vm_ldm.aContract d
   ON c.Contract_nr = d.Contract_nr
  AND c.Contract_soort_code = d.Contract_soort_code
  AND c.Contract_hergebruik_volgnr = d.Contract_hergebruik_volgnr

INNER JOIN mi_vm_ldm.aparty_contract        d2
 ON d2.Contract_nr = c.Contract_nr
 AND d2.Contract_soort_code = c.Contract_soort_code
 AND d2.Contract_hergebruik_volgnr = c.Contract_hergebruik_volgnr
 AND d2.Party_sleutel_type = c.Party_sleutel_type

INNER JOIN MI_vm_ldm.aSegment_klant e
   ON e.Party_id = d2.Party_id
  AND e.Segment_type_code = 'CG'
  AND e.Party_sleutel_type = 'BC'

INNER JOIN MI_vm_ldm.aSegment_klant f
   ON f.Party_id = d2.Party_id
  AND f.Segment_type_code = 'RELCAT'
  AND f.Party_sleutel_type = 'BC'

LEFT OUTER JOIN MI_vm_ldm.aIndividu g
   ON g.Party_id = d2.Party_id
  AND g.Party_sleutel_type = 'BC'

LEFT OUTER JOIN Mi_vm_ldm.aParty_party_relatie h
   ON h.Party_id = d2.Party_id
  AND h.Party_sleutel_type = 'BC'
  AND h.Gerelateerd_party_sleutel_type = 'FH'

LEFT OUTER JOIN Mi_vm_ldm.aParty_party_relatie h2
   ON h2.Party_id = d2.Party_id
  AND h2.Party_sleutel_type = 'BC'
  AND h2.Gerelateerd_party_sleutel_type = 'PC'

LEFT OUTER JOIN (
                  SELECT PBNL
                  FROM  Mi_vm_info.vLU_PBNL    a
                  INNER JOIN Mi_temp.Part_zak_periode   b
                   ON b.Maand_PBNL = a.Maand
                  /*AND Bediening_Nr > 0
                  AND NOT (Bediening_Nr BETWEEN 50820301 AND 50820306)
                  AND NOT (Prv_Bnk_Nr   BETWEEN 50820701 AND 50820702)
                  AND NOT Prv_Bnk_Nr MOD 100 IN (98,99)
                  */
                  GROUP BY 1
                ) h3
  ON h3.PBNL = h2.Gerelateerd_party_id

LEFT OUTER JOIN Mi_vm_ldm.aParty_naam i
   ON i.Party_id = d2.Party_id
  AND i.Party_sleutel_type = 'BC'

LEFT OUTER JOIN Mi_vm_ldm.aParty_post_adres  j
   ON j.Party_id = d2.Party_id
  AND j.Party_sleutel_type = 'BC'

LEFT OUTER JOIN mi_vm_ldm.acontract_soort   k
   ON k.Contract_soort_code = c.Contract_soort_code

WHERE a.Business_line in ('CBC', 'SME', 'CIB')
  AND c.Party_sleutel_type = 'BC'
  AND c.Party_contract_rol_code = 'C'
  AND d2.Party_contract_rol_code = 'G'
  AND d.Contract_status_code <> 3

  AND e.Segment_id BETWEEN '0100' AND '0599'
  AND TRIM(f.Segment_id) = '20'
  AND g.Geslacht IN ('M', 'V')
;

CREATE TABLE Mi_temp.Part_zak_t2_BC
AS
(
SEL a.Part_BC_nr
        ,MAX(CASE WHEN b.Party_Contract_rol_code = 'C' AND c.Product_id > 1 /* negatief = zelf verzonnen en 1 is toegangscontract */ THEN 1 ELSE 0 END) AS Contractant_ind
        ,MAX(CASE WHEN b.Party_Contract_rol_code = 'G' THEN 1 ELSE 0 END) AS Gemachtigd_ind

FROM Mi_temp.Part_zak_t1_BC a

LEFT OUTER JOIN mi_vm_ldm.aParty_contract b
   ON b.Party_id = a.Part_BC_nr
  AND b.Party_sleutel_type = 'BC'
/*AND b.Contract_soort_code  > 0*/

LEFT OUTER JOIN mi_vm_ldm.aContract c
   ON c.Contract_nr = b.Contract_nr
  AND c.Contract_soort_code = b.Contract_soort_code
  AND c.Contract_hergebruik_volgnr = b.Contract_hergebruik_volgnr

WHERE c.Contract_status_code <> 3
/*  AND  b.Party_Contract_rol_code = 'C'*/
GROUP BY 1
) WITH DATA
PRIMARY INDEX(Part_BC_nr)
;

.IF ERRORCODE <> 0 THEN .GOTO EOP


COLLECT STATISTICS Mi_temp.Part_zak_t2_BC COLUMN (Part_BC_nr);

.IF ERRORCODE <> 0 THEN .GOTO EOP


CREATE TABLE Mi_temp.Part_zak_BC
AS
(
SEL
     a.*
    ,ZEROIFNULL(b.Contractant_ind) AS Contractant_ind
    ,ZEROIFNULL(b.Gemachtigd_ind)  AS Gemachtigd_ind

FROM Mi_temp.Part_zak_t1_BC a

LEFT OUTER JOIN Mi_temp.Part_zak_t2_BC b
  ON b.Part_BC_nr = a.Part_BC_nr
) WITH DATA
PRIMARY INDEX(Klant_nr)
;

CREATE TABLE Mi_temp.Part_zak_FHH
AS
(
SELECT
        a.Klant_nr
       ,a.Maand_nr
       ,a.Klantstatus
       ,a.Klant_ind
       ,a.FHH
       ,a.FHH_relatie_oms

       ,b.Vervallen_ind
       /*,b.Commercieel_vervallen_ind*/
       ,b.Clientgroep
       ,b.Huisbank_kleur
       ,b.Loyaliteit

       ,c.N_maanden_klant
       ,c.N_personen
       ,b.Cross_sell
       ,c.Deep_sell
       ,c.Business_volume_totaal AS Business_volume
       ,c.Credit_volume_totaal   AS Credit_volume
       ,c.Debet_volume_totaal    AS Debet_volume
       ,c.Gem_Voeding_min_6mnd
       ,c.Gem_Credit_volume_6mnd
       ,c.Datum_laatste_productafname
       ,c.Baten_12mnd

       ,CASE WHEN (b.Betalingsprobleem_ind + b.Beschikkingsmacht_ind + b.Curatele_ind) > 0 THEN 1 ELSE 0 END AS Betalprobl_curatele
FROM
      (
      SELECT  a.FHH
             ,a.Klant_nr
             ,a.Maand_nr
             ,a.Klantstatus
             ,a.Klant_ind
               ,MIN(Relatie_oms) AS FHH_relatie_oms
      FROM Mi_temp.Part_zak_t1_BC a
      WHERE a.PBNL IS NULL            /* geen PBNL */
      GROUP BY 1,2,3,4,5
      ) a

INNER JOIN Mi_temp.Part_zak_periode   per
   ON 1 = 1

INNER JOIN Mi_vm_info.vLU_Fhh       b
   ON b.Maand = per.Maand_FHH
  AND b.FHH = a.FHH

INNER JOIN Mi_vm_info.vFhh_totaal    c
   ON c.Maand = per.Maand_FHH
  AND c.FHH = a.FHH

  ) WITH DATA
PRIMARY INDEX(Klant_nr)
;

INSERT INTO Mi_temp.Part_zak_FHH
SELECT
        a.Klant_nr
       ,a.Maand_nr
       ,a.Klantstatus
       ,a.Klant_ind
       ,a.PBNL
       ,a.FHH_relatie_oms

       ,b.Vervallen_ind
       /*,b.Commercieel_vervallen_ind*/
       ,b.Clientgroep
       ,b.Huisbank_kleur
       ,b.Loyaliteit

       ,c.N_maanden_klant
       ,c.N_personen
       ,b.Cross_sell
       ,c.Deep_sell
       ,c.Business_volume_totaal AS Business_volume
       ,c.Credit_volume_totaal   AS Credit_volume
       ,c.Debet_volume_totaal    AS Debet_volume
       ,c.Gem_Voeding_min_6mnd
       ,c.Gem_Credit_volume_6mnd
       ,c.Datum_laatste_productafname
       ,c.Baten_12mnd

       ,CASE WHEN (b.Betalingsprobleem_ind + b.Beschikkingsmacht_ind + b.Curatele_ind) > 0 THEN 1 ELSE 0 END AS Betalprobl_curatele
FROM
      (
      SELECT  a.PBNL
             ,a.Klant_nr
             ,a.Maand_nr
             ,a.Klantstatus
             ,a.Klant_ind
               ,MIN(Relatie_oms) AS FHH_relatie_oms
      FROM Mi_temp.Part_zak_t1_BC a
      WHERE ZEROIFNULL(a.PBNL) > 0            /* PBNL */
      GROUP BY 1,2,3,4,5
      ) a

INNER JOIN Mi_temp.Part_zak_periode   per
   ON 1 = 1

INNER JOIN Mi_vm_info.vLU_PBNL       b
   ON b.Maand = per.Maand_PBNL
  AND b.PBNL = a.PBNL

INNER JOIN Mi_vm_info.vm_PBNL_totaal    c
   ON c.Maand = per.Maand_PBNL
  AND c.PBNL = a.PBNL
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

INSERT INTO MI_SAS_AA_MB_C_MB.CIAA_Part_zak_NEW
SEL
     Klant_nr
    ,Maand_nr
    ,Klantstatus
    ,Klant_ind

    ,COUNT(DISTINCT FHH)                                                                AS N_FHH
    ,SUM(CASE WHEN FHH_relatie_oms = '01 UBO'                        THEN 1 ELSE 0 END) AS N_FHH_UBO
    ,SUM(CASE WHEN FHH_relatie_oms = '02 Bestuurder'                 THEN 1 ELSE 0 END) AS N_FHH_Bestuurder
    ,SUM(CASE WHEN FHH_relatie_oms = '03 O en O'                     THEN 1 ELSE 0 END) AS N_FHH_O_en_O
    ,SUM(CASE WHEN FHH_relatie_oms = '04 Eenmanszaak'                THEN 1 ELSE 0 END) AS N_FHH_Eenmanszaak
    ,SUM(CASE WHEN FHH_relatie_oms = '05 Commanditaire Vennootschap' THEN 1 ELSE 0 END) AS N_FHH_Comm_Venn
    ,SUM(CASE WHEN FHH_relatie_oms = '06 Vennootschap Onder Firma'   THEN 1 ELSE 0 END) AS N_FHH_VOF
    ,SUM(CASE WHEN FHH_relatie_oms = '07 Maatschap'                  THEN 1 ELSE 0 END) AS N_FHH_Maatschap
    ,SUM(CASE WHEN FHH_relatie_oms = '08 BV of NV in oprichting'     THEN 1 ELSE 0 END) AS N_FHH_BV_NV_opricht
    ,SUM(CASE WHEN FHH_relatie_oms = '09 Particulier-Zakelijk'       THEN 1 ELSE 0 END) AS N_FHH_Part_zak
    ,SUM(CASE WHEN FHH_relatie_oms = '99 Gemachtigd zakelijk contr'  THEN 1 ELSE 0 END) AS N_FHH_gemachtigde

    ,COUNT(DISTINCT (CASE WHEN Vervallen_ind = 0 THEN FHH ELSE NULL END))               AS N_act_FHH
    ,SUM(CASE WHEN FHH_relatie_oms = '01 UBO'                          AND Vervallen_ind = 0 THEN 1 ELSE 0 END) AS N_act_FHH_UBO
    ,SUM(CASE WHEN FHH_relatie_oms = '02 Bestuurder'                   AND Vervallen_ind = 0 THEN 1 ELSE 0 END) AS N_act_FHH_Bestuurder
    ,SUM(CASE WHEN FHH_relatie_oms = '03 O en O'                       AND Vervallen_ind = 0 THEN 1 ELSE 0 END) AS N_act_FHH_O_en_O
    ,SUM(CASE WHEN FHH_relatie_oms = '04 Eenmanszaak'                  AND Vervallen_ind = 0 THEN 1 ELSE 0 END) AS N_act_FHH_Eenmanszaak
    ,SUM(CASE WHEN FHH_relatie_oms = '05 Commanditaire Vennootschap'   AND Vervallen_ind = 0 THEN 1 ELSE 0 END) AS N_act_FHH_Comm_Venn
    ,SUM(CASE WHEN FHH_relatie_oms = '06 Vennootschap Onder Firma'     AND Vervallen_ind = 0 THEN 1 ELSE 0 END) AS N_act_FHH_VOF
    ,SUM(CASE WHEN FHH_relatie_oms = '07 Maatschap'                    AND Vervallen_ind = 0 THEN 1 ELSE 0 END) AS N_act_FHH_Maatschap
    ,SUM(CASE WHEN FHH_relatie_oms = '08 BV of NV in oprichting'       AND Vervallen_ind = 0 THEN 1 ELSE 0 END) AS N_act_FHH_BV_NV_opricht
    ,SUM(CASE WHEN FHH_relatie_oms = '09 Particulier-Zakelijk'         AND Vervallen_ind = 0 THEN 1 ELSE 0 END) AS N_act_FHH_Part_zak
    ,SUM(CASE WHEN FHH_relatie_oms = '99 Gemachtigd zakelijk contr'    AND Vervallen_ind = 0 THEN 1 ELSE 0 END) AS N_act_FHH_gemachtigde

    ,MAX(ZEROIFNULL(Betalprobl_curatele)) AS Max_Betalprobl_curatele
    ,SUM(Baten_12mnd)                     AS Sum_Baten_12mnd

FROM Mi_temp.Part_zak_FHH

GROUP BY 1,2,3,4
;

CREATE TABLE MI_temp.CIAA_Beleggen_t1
AS
(
SELECT   Mnd.Maand_nr
        ,BC.Klant_nr                                        AS Klant_nr
        ,ICFP.CBC_nr                                        AS BC_nr
        ,MAX(CASE WHEN (ZEROIFNULL(MC.Statuten_afwezig_ind         ) +
                        ZEROIFNULL(MC.Statuten_niet_gecheckt_ind   ) +
                        ZEROIFNULL(MC.Jaarcijfers_afwezig_ind      ) +
                        ZEROIFNULL(MC.Jaarcijfers_niet_gecheckt_ind) +
                        ZEROIFNULL(MC.Jaarcijfers_niet_recent_ind  )  ) >= 1 THEN 1
                  ELSE 0
             END)                                           AS  Zorgplicht_signaal
        ,MAX(ZEROIFNULL(MC.Statuten_Afwezig_Ind          )) AS  Statuten_Afwezig_Ind
        ,MAX(ZEROIFNULL(MC.Statuten_Niet_Gecheckt_Ind    )) AS  Statuten_Niet_Gecheckt_Ind
        ,MAX(ZEROIFNULL(MC.Jaarcijfers_Afwezig_Ind       )) AS  Jaarcijfers_Afwezig_Ind
        ,MAX(ZEROIFNULL(MC.Jaarcijfers_Niet_Gecheckt_Ind )) AS  Jaarcijfers_Niet_Gecheckt_Ind
        ,MAX(ZEROIFNULL(MC.Jaarcijfers_Niet_Recent_Ind   )) AS  Jaarcijfers_Niet_Recent_Ind
        ,MAX(CASE WHEN ZEROIFNULL(ICFP.Totaal_belegd_vermogen) = 0 THEN 0 ELSE 1 END) AS Actie_vereist

FROM Mi_vm_nzdb.vEff_Contract_Feiten_Periode              ICFP

INNER JOIN MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr_NEW Mnd
   ON ICFP.Maand_nr = Mnd.Maand_nr
   AND Mnd.N_maanden_terug = 0

INNER JOIN mi_vm_ldm.vParty_Contract    PC
   ON PC.Party_id = ICFP.CBC_nr
  AND PC.Party_sleutel_type = 'BC'
  AND PC.Contract_soort_code = 125
  AND PC.Party_contract_sdat <= Mnd.Maand_Edat
  AND (PC.Party_contract_edat >= Mnd.Maand_Edat OR PC.Party_contract_edat IS NULL)

LEFT OUTER JOIN MI_VM_Ldm.vMifid_contract    MC
   ON MC.Contract_nr = PC.Contract_nr
  AND MC.Contract_soort_code = PC.Contract_soort_code
  AND MC.Contract_hergebruik_volgnr = PC.Contract_hergebruik_volgnr
  AND MC.Mifid_contract_sdat <= Mnd.Maand_Edat
  AND (MC.Mifid_contract_edat >= Mnd.Maand_Edat OR MC.Mifid_contract_edat IS NULL)

INNER JOIN MI_SAS_AA_MB_C_MB.Mia_klantkoppelingen_hist_NEW    BC
   ON bc.business_contact_nr = ICFP.CBC_nr
  AND BC.Maand_nr = ICFP.Maand_nr

WHERE ICFP.Standaard_contract_ind = 1
  AND (ZEROIFNULL(MC.Statuten_Afwezig_Ind          ) +
       ZEROIFNULL(MC.Statuten_Niet_Gecheckt_Ind    ) +
       ZEROIFNULL(MC.Jaarcijfers_Afwezig_Ind       ) +
       ZEROIFNULL(MC.Jaarcijfers_Niet_Gecheckt_Ind ) +
       ZEROIFNULL(MC.Jaarcijfers_Niet_Recent_Ind   )    )> 0
GROUP BY 1,2,3
) WITH DATA
UNIQUE PRIMARY INDEX ( Klant_nr ,Maand_nr, BC_nr)
;

CREATE TABLE MI_temp.CIAA_Beleggen
AS
(
SELECT
     mia.Klant_nr
    ,mia.Maand_nr
    ,COALESCE(a3.CBC_nr, MIa.Business_contact_nr)                                                                 AS BC_nr
    ,COALESCE(a6.Naam, mia.Verkorte_naam) AS Verkorte_naam
    ,mia.subsector_oms
    ,CASE WHEN MIa.clientgroep BETWEEN '1170' AND '1199' THEN ('RM - '|| SUBSTR(clntgrp.Omschrijving_subgroep,1,2))
          WHEN MIa.clientgroep BETWEEN '1150' AND '1169' THEN SUBSTR(clntgrp.Omschrijving_subgroep,1,4)
          ELSE TRIM(BOTH FROM clntgrp.Omschrijving_hoofdgroep)
     END                                                                                                          AS Segment
    ,a3.Contract_nr
    ,a.Service_Concept_naam
    ,mia.Creditvolume  AS Credit_volume
    ,(a.Totaal_belegd_vermogen/NULLIFZERO(mia.Creditvolume))                                                      AS Perc_belegd_vermogen
    /*mia.Creditvolume_0*/

    /* RISICO PROFIEL */
    ,a.Risico_profiel                                                                                             AS Gekozen_risico_profiel
    ,a.Berekend_risico_profiel
    ,CASE WHEN a.Afwijkend_risico_profiel      = 1 THEN 'ja' ELSE '' END                                          AS Afwijkend_risico_profiel
    ,CASE WHEN a.Gesignaleerd_risico_profiel   = 1 THEN 'ja' ELSE '' END                                          AS Gesignaleerd_risico_profiel

    /* ZORGPLICHT */
       /* signalen op cluster indien minimaal 1 BCnr met signaal en GEEN nul-depot */
    ,CASE WHEN (ZEROIFNULL(a.Statuten_afwezig_ind         ) +
                ZEROIFNULL(a.Statuten_niet_gecheckt_ind   ) +
                ZEROIFNULL(a.Jaarcijfers_afwezig_ind      ) +
                ZEROIFNULL(a.Jaarcijfers_niet_gecheckt_ind) +
                ZEROIFNULL(a.Jaarcijfers_niet_recent_ind  )  ) >= 1
                AND ZEROIFNULL(i.N_BC_zorgplicht) > 0 THEN 'ja'
          ELSE ''
     END                                                                                                          AS Zorgplicht_signaal
    ,CASE WHEN Zorgplicht_signaal = 'ja' AND NOT h.Klant_nr IS NULL THEN 'ja'   ELSE '' END                       AS Signaal_3mnd
    ,CASE WHEN a.Statuten_afwezig_ind          = 1 THEN 'ja' ELSE '' END                                          AS Statuten_afwezig
    ,CASE WHEN a.Statuten_niet_gecheckt_ind    = 1 THEN 'ja' ELSE '' END                                          AS Statuten_niet_gecheckt
    ,CASE WHEN a.Jaarcijfers_afwezig_ind       = 1 THEN 'ja' ELSE '' END                                          AS Jaarcijfers_afwezig
    ,CASE WHEN a.Jaarcijfers_niet_gecheckt_ind = 1 THEN 'ja' ELSE '' END                                          AS Jaarcijfers_niet_gecheckt
    ,CASE WHEN a.Jaarcijfers_niet_recent_ind   = 1 THEN 'ja' ELSE '' END                                          AS Jaarcijfers_niet_recent
    ,a.Jaarcijfers_laatste_jaar
     /* BCnrs met zorgplicht signaal EN GEEN nul-depot */
    ,i.N_BC_zorgplicht                                                                                            AS N_BC_zorgplicht
    ,i.BC_nr_zorgplicht                                                                                           AS BC_nr_zorgplicht

    /* BELEGD VERMOGEN */
    ,NULLIFZERO(a.Totaal_belegd_vermogen)                                                                         AS Tot_belegd_vermogen
    ,NULLIFZERO(b.Volume_MF)                                                                                      AS Vermogen_fondsen
    ,(Vermogen_fondsen/NULLIFZERO(Tot_belegd_vermogen))                                                           AS Perc_vermogen_fondsen
    ,NULLIFZERO(b.Volume_AA)                                                                                      AS Vermogen_klassiek
    ,(Vermogen_klassiek/NULLIFZERO(Tot_belegd_vermogen))                                                          AS Perc_vermogen_klassiek
    ,NULLIFZERO(ZEROIFNULL(b.Volume_OB) + ZEROIFNULL(b.Volume_SP)    + ZEROIFNULL(b.Volume_OV) + ZEROIFNULL(b.Volume_OP))     AS Vermogen_overig
    ,(Vermogen_overig/NULLIFZERO(Tot_belegd_vermogen))                                                            AS Perc_vermogen_overig

    /* TRANSACTIES */
    ,(ZEROIFNULL(a.N_aankoop_trx) + ZEROIFNULL(a.N_verkoop_trx))                                                  AS Totaal_n_trx
    ,NULLIFZERO(ZEROIFNULL(a.Bedrag_aankoop_trx) + ZEROIFNULL(a.Bedrag_verkoop_trx))                              AS Totaal_bedrag_trx
    ,NULLIFZERO(c.Bedrag_provisie)                                                                                AS Totaal_prov_trx
    ,(ZEROIFNULL(a.N_aankoop_trx_mat) + ZEROIFNULL(a.N_verkoop_trx_mat))                                          AS Totaal_n_trx_12mnd
    ,NULLIFZERO(ZEROIFNULL(a.Bedrag_aankoop_trx_mat) + ZEROIFNULL(a.Bedrag_verkoop_trx_mat))                      AS Totaal_bedrag_trx_12mnd
    ,NULLIFZERO(c.Bedrag_provisie_mat)                                                                            AS Totaal_prov_trx_12mnd
    ,a.Laatste_transactie_datum                                                                                   AS Laatste_transactie_datum
    ,NULLIFZERO(a.N_aankoop_trx)                                                                                  AS N_aankoop_trx
    ,NULLIFZERO(a.Bedrag_aankoop_trx)                                                                             AS Bedrag_aankoop_trx
    ,NULLIFZERO(c.Bedrag_provisie_aankoop)                                                                        AS Bedrag_provisie_aankoop
    ,NULLIFZERO(a.N_aankoop_trx_mat)                                                                              AS N_aankoop_trx_mat
    ,NULLIFZERO(a.Bedrag_aankoop_trx_mat)                                                                         AS Bedrag_aankoop_trx_mat
    ,NULLIFZERO(c.Bedrag_provisie_aankoop_mat)                                                                    AS Bedrag_provisie_aankoop_mat
    ,NULLIFZERO(a.N_verkoop_trx)                                                                                  AS N_verkoop_trx
    ,NULLIFZERO(a.Bedrag_verkoop_trx)                                                                             AS Bedrag_verkoop_trx
    ,NULLIFZERO(c.Bedrag_provisie_verkoop)                                                                        AS Bedrag_provisie_verkoop
    ,NULLIFZERO(a.N_verkoop_trx_mat)                                                                              AS N_verkoop_trx_mat
    ,NULLIFZERO(a.Bedrag_verkoop_trx_mat)                                                                         AS Bedrag_verkoop_trx_mat
    ,NULLIFZERO(c.Bedrag_provisie_verkoop_mat)                                                                    AS Bedrag_provisie_verkoop_mat

    /* TRANSACTIES PRODUCTCATEGORIE */
    ,NULLIFZERO(c.N_trx_MF           )                                                                            AS N_trx_MF
    ,NULLIFZERO(c.N_trx_mat_MF       )                                                                            AS N_trx_mat_MF
    ,NULLIFZERO(c.N_trx_AA           )                                                                            AS N_trx_AA
    ,NULLIFZERO(c.N_trx_mat_AA       )                                                                            AS N_trx_mat_AA
    ,NULLIFZERO(ZEROIFNULL(c.N_trx_OB)     + ZEROIFNULL(c.N_trx_SP)        + ZEROIFNULL(c.N_trx_OV)     + ZEROIFNULL(c.N_trx_OP))     AS N_trx_OV
    ,NULLIFZERO(ZEROIFNULL(c.N_trx_mat_OB) + ZEROIFNULL(c.N_trx_mat_SP)    + ZEROIFNULL(c.N_trx_mat_OV) + ZEROIFNULL(c.N_trx_mat_OP)) AS N_trx_mat_OV

    /* TRANSACTIES KANAAL */
    ,NULLIFZERO(c.N_trx_KNT        )                                                                              AS N_trx_KNT
    ,NULLIFZERO(c.N_trx_mat_KNT    )                                                                              AS N_trx_mat_KNT
    ,NULLIFZERO(c.N_trx_YBC        )                                                                              AS N_trx_YBC
    ,NULLIFZERO(c.N_trx_mat_YBC    )                                                                              AS N_trx_mat_YBC
    ,NULLIFZERO(c.N_trx_IB         )                                                                              AS N_trx_IB
    ,NULLIFZERO(c.N_trx_mat_IB     )                                                                              AS N_trx_mat_IB
    ,NULLIFZERO(c.N_trx_AUTO       )                                                                              AS N_trx_AUTO
    ,NULLIFZERO(c.N_trx_mat_AUTO   )                                                                              AS N_trx_mat_AUTO
    ,NULLIFZERO(c.N_trx_ONB        )                                                                              AS N_trx_ONB
    ,NULLIFZERO(c.N_trx_mat_ONB    )                                                                              AS N_trx_mat_ONB

    /* PROVISIES PRODUCTCATEGORIE */
    ,NULLIFZERO(c.N_trx_prov_MF           )                                                                       AS Product_N_trx_prov_MF
    ,NULLIFZERO(c.N_trx_prov_mat_MF       )                                                                       AS Product_N_trx_prov_mat_MF
    ,NULLIFZERO(c.N_trx_prov_AA           )                                                                       AS Product_N_trx_prov_AA
    ,NULLIFZERO(c.N_trx_prov_mat_AA       )                                                                       AS Product_N_trx_prov_mat_AA
    ,NULLIFZERO(ZEROIFNULL(c.N_trx_prov_OB)     + ZEROIFNULL(c.N_trx_prov_SP)        + ZEROIFNULL(c.N_trx_prov_OV)     + ZEROIFNULL(c.N_trx_prov_OP))     AS Product_N_trx_prov_OV
    ,NULLIFZERO(ZEROIFNULL(c.N_trx_prov_mat_OB) + ZEROIFNULL(c.N_trx_prov_mat_SP)    + ZEROIFNULL(c.N_trx_prov_mat_OV) + ZEROIFNULL(c.N_trx_prov_mat_OP)) AS Product_N_trx_prov_mat_OV

    /* PROVISIES KANAAL */
    ,NULLIFZERO(c.N_trx_prov_KNT        )                                                                          AS Kanaal_N_trx_prov_KNT
    ,NULLIFZERO(c.N_trx_prov_mat_KNT    )                                                                          AS Kanaal_N_trx_prov_mat_KNT
    ,NULLIFZERO(c.N_trx_prov_YBC        )                                                                          AS Kanaal_N_trx_prov_YBC
    ,NULLIFZERO(c.N_trx_prov_mat_YBC    )                                                                          AS Kanaal_N_trx_prov_mat_YBC
    ,NULLIFZERO(c.N_trx_prov_IB         )                                                                          AS Kanaal_N_trx_prov_IB
    ,NULLIFZERO(c.N_trx_prov_mat_IB     )                                                                          AS Kanaal_N_trx_prov_mat_IB
    ,NULLIFZERO(c.N_trx_prov_AUTO       )                                                                          AS Kanaal_N_trx_prov_AUTO
    ,NULLIFZERO(c.N_trx_prov_mat_AUTO   )                                                                          AS Kanaal_N_trx_prov_mat_AUTO
    ,NULLIFZERO(c.N_trx_prov_ONB        )                                                                          AS Kanaal_N_trx_prov_ONB
    ,NULLIFZERO(c.N_trx_prov_mat_ONB    )                                                                          AS Kanaal_N_trx_prov_mat_ONB

    /* ONTVANGSTEN & UITLEVERINGEN */
    ,NULLIFZERO(d.Bedrag_ontvangst    )                                                                            AS Bedrag_ontvangst
    ,NULLIFZERO(d.Bedrag_ontvangst_mat)                                                                            AS Bedrag_ontvangst_mat
    ,NULLIFZERO(d.Bedrag_uitl         )                                                                            AS Bedrag_uitl
    ,NULLIFZERO(d.Bedrag_uitl_mat     )                                                                            AS Bedrag_uitl_mat

    /* CONTACTEN */
    ,mia.Datum_volgend_contact
    ,NULL AS Datum_laatste_contact_pro_ftf -- proactieve contacten niet meer beschikbaar sinds introductie Siebel

    /* CONTACTGEGEVENS */
    ,mia.Telefoon_nr_vast
    ,mia.Telefoon_nr_mobiel
    ,mia.Contactpersoon  AS Contact_persoon
    ,mia.Emailadres AS Email_adres
    ,mia.Naw
    ,CASE WHEN TRIM(BOTH FROM MIa.Postcode) = '-101' THEN NULL ELSE MIa.Postcode END             AS Postcode

    /* Bediening */
    ,mia.Org_niveau0
    ,mia.Org_niveau0_bo_nr
    ,mia.Org_niveau1
    ,mia.Org_niveau1_bo_nr
    ,mia.Org_niveau2
    ,mia.Org_niveau2_bo_nr
    ,mia.Org_niveau3
    ,mia.Org_niveau3_bo_nr
    ,mia.Org_niveau4
    ,mia.Org_niveau4_bo_nr
    ,mia.Org_niveau5
    ,mia.Org_niveau5_bo_nr
    ,CASE WHEN MIa.CCA IN (32123677,21019077,21018777,21018877,21018977,40371277,40371477,40371677,40371877,40372077,53570801,53572601,53572701) THEN 'SME'
          WHEN ZEROIFNULL(MIa.CCA) BETWEEN 53000000 AND 69199999 THEN 'RM'
          ELSE 'Overig'
     END                                                                                        AS Bediening
    ,CASE WHEN MIa.CCA NE 1 THEN MIa.CCA ELSE NULL END                                          AS Bediening_nr
    ,TRIM(BOTH FROM Char_Subst(
     CASE WHEN MIa.CCA NE 1 THEN MIa.Relatiemanager ELSE 'Meerdere RM''s' END
     ,'''',''))                                                                                 AS Bediening_naam

    /* Bediening beleggen */
    ,CASE WHEN a.Bediening_beleggen <> '' THEN 1 ELSE 0 END                                     AS Ind_Bediening_beleggen

    ,CASE WHEN a.Bediening_beleggen = 'BA' THEN 'BeleggingsAdviseur'
          WHEN a.Bediening_beleggen = 'PB' THEN 'PreferredBanker'
          WHEN a.Bediening_beleggen = 'REM' THEN 'Remisier'
          WHEN a.Bediening_beleggen LIKE 'TRA%' THEN 'Trading'
          WHEN a.Bediening_beleggen = 'AM' THEN 'Overig'
          ELSE ''
     END                                                                                        AS Bediening_beleggen
    ,CASE WHEN a.Bediening_nr_beleggen = -101 THEN NULL ELSE a.Bediening_nr_beleggen END        AS Bediening_nr_beleggen
    ,TRIM(BOTH FROM Char_Subst(
     CASE WHEN  a.Bediening_nr_beleggen = -101 THEN ''
          WHEN a5.Naam = '' OR a5.Naam IS NULL THEN 'Adviseur '|| a.Bediening_nr_beleggen
                  ELSE
                       TRIM(a5.Voorletters)||' '||
                       (CASE WHEN TRIM(a5.Voorvoegsels) = '' THEN '' ELSE TRIM(a5.Voorvoegsels)||' ' END) ||
                       TRIM(a5.Naam)
     END
     ,'''',''))                                                                                AS Bediening_beleggen_naam



    ,Word_subst( (Word_subst(a.Dislocatie_naam, 'BELEGGINGSSPECIALISTEN', 'BA')) ,'BELEGGINGSSPECIALSTEN', 'BA') AS Dislocatie_beleggen

    /* Overig */
    ,mia.Datum_gegevens

    ,TRIM(BOTH FROM f.Rechtsvorm_oms) AS Rechtsvorm
    ,mia.Aantal_bcs
    ,g.Part_BC_nr

FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW     MIa

INNER JOIN MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr_NEW Mnd
   ON mnd.Maand_nr = MIa.Maand_nr

LEFT OUTER JOIN MI_vm.vClientgroep clntgrp
   ON clntgrp.Clientgroep = MIa.Clientgroep

INNER JOIN MI_vm_nzdb.vCC_Eff_Feiten_Periode       a
   ON MIa.Klant_nr = a.cc_nr
  AND MIa.Maand_nr = a.Maand_nr

INNER JOIN
            (
            SELECT
                    bc.Klant_nr AS cc_nr
                   ,bc.maand_nr
                   ,COUNT(DISTINCT(contract_oid))  AS N_stand_eff_contr
            FROM MI_vm_nzdb.vEff_Contract_Feiten_Periode a

            INNER JOIN MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr_NEW Mnd
               ON mnd.Maand_nr = a.Maand_nr
              AND mnd.N_maanden_terug = 0   /* actuele maand in Mia_hist */

            INNER JOIN MI_SAS_AA_MB_C_MB.Mia_klantkoppelingen_hist_NEW    BC
               ON bc.business_contact_nr = a.CBC_nr
              AND bc.Maand_nr = a.Maand_nr

            WHERE Standaard_contract_ind = 1
            GROUP BY 1,2
            ) a2
   ON mia.Klant_nr = a2.cc_nr
  AND MIa.Maand_nr = a2.Maand_nr

LEFT OUTER JOIN MI_vm_nzdb.vEff_Contract_Feiten_Periode        a3
   ON a3.Contract_oid = a.Beste_contract_oid
  AND a3.Maand_nr = a.Maand_nr
  AND a3.Standaard_contract_ind = 1

LEFT OUTER JOIN MI_vm_ldm.aParty_naam                          a5
   ON a5.Party_id = a.Bediening_nr_beleggen
  AND a5.Party_sleutel_type = 'AM'

LEFT OUTER JOIN Mi_vm_ldm.aParty_naam                          a6
   ON a6.Party_id = a3.CBC_nr
  AND a6.Party_sleutel_type = 'bc'

/* Volumina */
LEFT OUTER JOIN
                (
                 SEL
                      bc.Klant_nr AS cc_nr
                     ,a.maand_nr
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'MF' THEN ZEROIFNULL(a.Volume) ELSE 0 END) AS Volume_MF    /* Mutual Funds       */
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'OB' THEN ZEROIFNULL(a.Volume) ELSE 0 END) AS Volume_OB    /* Obligaties         */
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'SP' THEN ZEROIFNULL(a.Volume) ELSE 0 END) AS Volume_SP    /* Structured Products*/
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'AA' THEN ZEROIFNULL(a.Volume) ELSE 0 END) AS Volume_AA    /* Klassieke stukken  */
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'OV' THEN ZEROIFNULL(a.Volume) ELSE 0 END) AS Volume_OV    /* Overig             */
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'OP' THEN ZEROIFNULL(a.Volume) ELSE 0 END) AS Volume_OP    /* Opties             */

                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'MF' AND a.Binnenland_ind = 1 THEN ZEROIFNULL(a.Volume) ELSE 0 END) AS Volume_MF_binnenland
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'OB' AND a.Binnenland_ind = 1 THEN ZEROIFNULL(a.Volume) ELSE 0 END) AS Volume_OB_binnenland
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'SP' AND a.Binnenland_ind = 1 THEN ZEROIFNULL(a.Volume) ELSE 0 END) AS Volume_SP_binnenland
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'AA' AND a.Binnenland_ind = 1 THEN ZEROIFNULL(a.Volume) ELSE 0 END) AS Volume_AA_binnenland
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'OV' AND a.Binnenland_ind = 1 THEN ZEROIFNULL(a.Volume) ELSE 0 END) AS Volume_OV_binnenland
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'OP' AND a.Binnenland_ind = 1 THEN ZEROIFNULL(a.Volume) ELSE 0 END) AS Volume_OP_binnenland

                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'MF' AND a.Binnenland_ind = 0 THEN ZEROIFNULL(a.Volume) ELSE 0 END) AS Volume_MF_buitenland
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'OB' AND a.Binnenland_ind = 0 THEN ZEROIFNULL(a.Volume) ELSE 0 END) AS Volume_OB_buitenland
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'SP' AND a.Binnenland_ind = 0 THEN ZEROIFNULL(a.Volume) ELSE 0 END) AS Volume_SP_buitenland
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'AA' AND a.Binnenland_ind = 0 THEN ZEROIFNULL(a.Volume) ELSE 0 END) AS Volume_AA_buitenland
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'OV' AND a.Binnenland_ind = 0 THEN ZEROIFNULL(a.Volume) ELSE 0 END) AS Volume_OV_buitenland
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'OP' AND a.Binnenland_ind = 0 THEN ZEROIFNULL(a.Volume) ELSE 0 END) AS Volume_OP_buitenland

                 FROM MI_vm_nzdb.vEff_Contract_Vermogen a

                 INNER JOIN MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr_NEW Mnd
                    ON mnd.Maand_nr = a.Maand_nr
                   AND mnd.N_maanden_terug = 0   /* actuele maand in Mia_hist */

                 INNER JOIN MI_SAS_AA_MB_C_MB.Mia_klantkoppelingen_hist_NEW    BC
                    ON bc.business_contact_nr = a.CBC_nr
                   AND bc.Maand_nr = a.Maand_nr

                 WHERE a.Standaard_contract_ind = 1
                 GROUP BY 1,2
                 ) b
   ON b.Maand_nr = a.Maand_nr
  AND b.CC_nr = a.CC_nr

/* Transacties (mogelijk nog trx per beleggingscategorie) */
LEFT OUTER JOIN
                (
                 SEL
                      bc.Klant_nr AS cc_nr
                     ,a.maand_nr
                     ,SUM(CASE WHEN aankoop_verkoop_code IN ('A', 'V') THEN ZEROIFNULL(-bedrag_provisie) ELSE 0 END)     AS Bedrag_provisie
                     ,SUM(CASE WHEN aankoop_verkoop_code IN ('A', 'V') THEN ZEROIFNULL(-bedrag_provisie_mat) ELSE 0 END) AS Bedrag_provisie_MAT

                     ,SUM(CASE WHEN aankoop_verkoop_code = 'A' THEN ZEROIFNULL(-bedrag_provisie) ELSE 0 END)            AS Bedrag_provisie_aankoop
                     ,SUM(CASE WHEN aankoop_verkoop_code = 'A' THEN ZEROIFNULL(-bedrag_provisie_mat) ELSE 0 END)        AS Bedrag_provisie_aankoop_MAT

                     ,SUM(CASE WHEN aankoop_verkoop_code = 'V' THEN ZEROIFNULL(-bedrag_provisie) ELSE 0 END)            AS Bedrag_provisie_verkoop
                     ,SUM(CASE WHEN aankoop_verkoop_code = 'V' THEN ZEROIFNULL(-bedrag_provisie_mat) ELSE 0 END)        AS Bedrag_provisie_verkoop_MAT


                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'MF' THEN ZEROIFNULL(n_trx) ELSE 0 END) AS N_trx_MF    /* Mutual Funds        */
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'OB' THEN ZEROIFNULL(n_trx) ELSE 0 END) AS N_trx_OB    /* Obligaties          */
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'SP' THEN ZEROIFNULL(n_trx) ELSE 0 END) AS N_trx_SP    /* Structured Products */
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'AA' THEN ZEROIFNULL(n_trx) ELSE 0 END) AS N_trx_AA    /* Klassieke stukken   */
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'OV' THEN ZEROIFNULL(n_trx) ELSE 0 END) AS N_trx_OV    /* Overig              */
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'OP' THEN ZEROIFNULL(n_trx) ELSE 0 END) AS N_trx_OP    /* Opties              */

                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'MF' THEN ZEROIFNULL(n_trx_mat) ELSE 0 END) AS N_trx_mat_MF    /* Mutual Funds        */
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'OB' THEN ZEROIFNULL(n_trx_mat) ELSE 0 END) AS N_trx_mat_OB    /* Obligaties          */
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'SP' THEN ZEROIFNULL(n_trx_mat) ELSE 0 END) AS N_trx_mat_SP    /* Structured Products */
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'AA' THEN ZEROIFNULL(n_trx_mat) ELSE 0 END) AS N_trx_mat_AA    /* Klassieke stukken   */
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'OV' THEN ZEROIFNULL(n_trx_mat) ELSE 0 END) AS N_trx_mat_OV    /* Overig              */
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'OP' THEN ZEROIFNULL(n_trx_mat) ELSE 0 END) AS N_trx_mat_OP    /* Opties              */

                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'MF' THEN ZEROIFNULL(bedrag_trx) ELSE 0 END) AS N_trx_bedrag_MF    /* Mutual Funds        */
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'OB' THEN ZEROIFNULL(bedrag_trx) ELSE 0 END) AS N_trx_bedrag_OB    /* Obligaties          */
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'SP' THEN ZEROIFNULL(bedrag_trx) ELSE 0 END) AS N_trx_bedrag_SP    /* Structured Products */
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'AA' THEN ZEROIFNULL(bedrag_trx) ELSE 0 END) AS N_trx_bedrag_AA    /* Klassieke stukken   */
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'OV' THEN ZEROIFNULL(bedrag_trx) ELSE 0 END) AS N_trx_bedrag_OV    /* Overig              */
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'OP' THEN ZEROIFNULL(bedrag_trx) ELSE 0 END) AS N_trx_bedrag_OP    /* Opties              */

                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'MF' THEN ZEROIFNULL(bedrag_trx_mat) ELSE 0 END) AS N_trx_bedrag_mat_MF    /* Mutual Funds         */
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'OB' THEN ZEROIFNULL(bedrag_trx_mat) ELSE 0 END) AS N_trx_bedrag_mat_OB    /* Obligaties           */
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'SP' THEN ZEROIFNULL(bedrag_trx_mat) ELSE 0 END) AS N_trx_bedrag_mat_SP    /* Structured Products  */
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'AA' THEN ZEROIFNULL(bedrag_trx_mat) ELSE 0 END) AS N_trx_bedrag_mat_AA    /* Klassieke stukken    */
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'OV' THEN ZEROIFNULL(bedrag_trx_mat) ELSE 0 END) AS N_trx_bedrag_mat_OV    /* Overig               */
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'OP' THEN ZEROIFNULL(bedrag_trx_mat) ELSE 0 END) AS N_trx_bedrag_mat_OP    /* Opties               */

                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'MF' THEN ZEROIFNULL(-bedrag_provisie) ELSE 0 END) AS N_trx_prov_MF    /* Mutual Funds          */
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'OB' THEN ZEROIFNULL(-bedrag_provisie) ELSE 0 END) AS N_trx_prov_OB    /* Obligaties            */
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'SP' THEN ZEROIFNULL(-bedrag_provisie) ELSE 0 END) AS N_trx_prov_SP    /* Structured Products   */
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'AA' THEN ZEROIFNULL(-bedrag_provisie) ELSE 0 END) AS N_trx_prov_AA    /* Klassieke stukken     */
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'OV' THEN ZEROIFNULL(-bedrag_provisie) ELSE 0 END) AS N_trx_prov_OV    /* Overig                */
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'OP' THEN ZEROIFNULL(-bedrag_provisie) ELSE 0 END) AS N_trx_prov_OP    /* Opties                */

                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'MF' THEN ZEROIFNULL(-bedrag_provisie_mat) ELSE 0 END) AS N_trx_prov_mat_MF    /* Mutual Funds        */
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'OB' THEN ZEROIFNULL(-bedrag_provisie_mat) ELSE 0 END) AS N_trx_prov_mat_OB    /* Obligaties          */
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'SP' THEN ZEROIFNULL(-bedrag_provisie_mat) ELSE 0 END) AS N_trx_prov_mat_SP    /* Structured Products */
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'AA' THEN ZEROIFNULL(-bedrag_provisie_mat) ELSE 0 END) AS N_trx_prov_mat_AA    /* Klassieke stukken   */
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'OV' THEN ZEROIFNULL(-bedrag_provisie_mat) ELSE 0 END) AS N_trx_prov_mat_OV    /* Overig              */
                     ,SUM(CASE WHEN a.Beleggings_categorie_code = 'OP' THEN ZEROIFNULL(-bedrag_provisie_mat) ELSE 0 END) AS N_trx_prov_mat_OP    /* Opties              */


                     ,SUM(CASE WHEN a.Kanaal_type_code =  1            THEN ZEROIFNULL(n_trx) ELSE 0 END) AS N_trx_YBC
                     ,SUM(CASE WHEN a.Kanaal_type_code = 11            THEN ZEROIFNULL(n_trx) ELSE 0 END) AS N_trx_KNT
                     ,SUM(CASE WHEN a.Kanaal_type_code = 13            THEN ZEROIFNULL(n_trx) ELSE 0 END) AS N_trx_IB
                     ,SUM(CASE WHEN a.Kanaal_type_code = 15            THEN ZEROIFNULL(n_trx) ELSE 0 END) AS N_trx_AUTO
                     ,SUM(CASE WHEN a.Kanaal_type_code = 99            THEN ZEROIFNULL(n_trx) ELSE 0 END) AS N_trx_ONB

                     ,SUM(CASE WHEN a.Kanaal_type_code =  1            THEN ZEROIFNULL(n_trx_mat) ELSE 0 END) AS N_trx_mat_YBC
                     ,SUM(CASE WHEN a.Kanaal_type_code = 11            THEN ZEROIFNULL(n_trx_mat) ELSE 0 END) AS N_trx_mat_KNT
                     ,SUM(CASE WHEN a.Kanaal_type_code = 13            THEN ZEROIFNULL(n_trx_mat) ELSE 0 END) AS N_trx_mat_IB
                     ,SUM(CASE WHEN a.Kanaal_type_code = 15            THEN ZEROIFNULL(n_trx_mat) ELSE 0 END) AS N_trx_mat_AUTO
                     ,SUM(CASE WHEN a.Kanaal_type_code = 99            THEN ZEROIFNULL(n_trx_mat) ELSE 0 END) AS N_trx_mat_ONB

                     ,SUM(CASE WHEN a.Kanaal_type_code =  1            THEN ZEROIFNULL(bedrag_trx) ELSE 0 END) AS N_trx_bedrag_YBC
                     ,SUM(CASE WHEN a.Kanaal_type_code = 11            THEN ZEROIFNULL(bedrag_trx) ELSE 0 END) AS N_trx_bedrag_KNT
                     ,SUM(CASE WHEN a.Kanaal_type_code = 13            THEN ZEROIFNULL(bedrag_trx) ELSE 0 END) AS N_trx_bedrag_IB
                     ,SUM(CASE WHEN a.Kanaal_type_code = 15            THEN ZEROIFNULL(bedrag_trx) ELSE 0 END) AS N_trx_bedrag_AUTO
                     ,SUM(CASE WHEN a.Kanaal_type_code = 99            THEN ZEROIFNULL(bedrag_trx) ELSE 0 END) AS N_trx_bedrag_ONB

                     ,SUM(CASE WHEN a.Kanaal_type_code =  1            THEN ZEROIFNULL(bedrag_trx_mat) ELSE 0 END) AS N_trx_bedrag_mat_YBC
                     ,SUM(CASE WHEN a.Kanaal_type_code = 11            THEN ZEROIFNULL(bedrag_trx_mat) ELSE 0 END) AS N_trx_bedrag_mat_KNT
                     ,SUM(CASE WHEN a.Kanaal_type_code = 13            THEN ZEROIFNULL(bedrag_trx_mat) ELSE 0 END) AS N_trx_bedrag_mat_IB
                     ,SUM(CASE WHEN a.Kanaal_type_code = 15            THEN ZEROIFNULL(bedrag_trx_mat) ELSE 0 END) AS N_trx_bedrag_mat_AUTO
                     ,SUM(CASE WHEN a.Kanaal_type_code = 99            THEN ZEROIFNULL(bedrag_trx_mat) ELSE 0 END) AS N_trx_bedrag_mat_ONB

                     ,SUM(CASE WHEN a.Kanaal_type_code =  1            THEN ZEROIFNULL(-bedrag_provisie) ELSE 0 END) AS N_trx_prov_YBC
                     ,SUM(CASE WHEN a.Kanaal_type_code = 11            THEN ZEROIFNULL(-bedrag_provisie) ELSE 0 END) AS N_trx_prov_KNT
                     ,SUM(CASE WHEN a.Kanaal_type_code = 13            THEN ZEROIFNULL(-bedrag_provisie) ELSE 0 END) AS N_trx_prov_IB
                     ,SUM(CASE WHEN a.Kanaal_type_code = 15            THEN ZEROIFNULL(-bedrag_provisie) ELSE 0 END) AS N_trx_prov_AUTO
                     ,SUM(CASE WHEN a.Kanaal_type_code = 99            THEN ZEROIFNULL(-bedrag_provisie) ELSE 0 END) AS N_trx_prov_ONB

                     ,SUM(CASE WHEN a.Kanaal_type_code =  1            THEN ZEROIFNULL(-bedrag_provisie_mat) ELSE 0 END) AS N_trx_prov_mat_YBC
                     ,SUM(CASE WHEN a.Kanaal_type_code = 11            THEN ZEROIFNULL(-bedrag_provisie_mat) ELSE 0 END) AS N_trx_prov_mat_KNT
                     ,SUM(CASE WHEN a.Kanaal_type_code = 13            THEN ZEROIFNULL(-bedrag_provisie_mat) ELSE 0 END) AS N_trx_prov_mat_IB
                     ,SUM(CASE WHEN a.Kanaal_type_code = 15            THEN ZEROIFNULL(-bedrag_provisie_mat) ELSE 0 END) AS N_trx_prov_mat_AUTO
                     ,SUM(CASE WHEN a.Kanaal_type_code = 99            THEN ZEROIFNULL(-bedrag_provisie_mat) ELSE 0 END) AS N_trx_prov_mat_ONB

                 FROM MI_vm_nzdb.vEff_Contract_Transacties    a

                 INNER JOIN MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr_NEW Mnd
                    ON mnd.Maand_nr = a.Maand_nr
                   AND mnd.N_maanden_terug = 0   /* actuele maand in Mia_hist */

                 INNER JOIN MI_SAS_AA_MB_C_MB.Mia_klantkoppelingen_hist_NEW    BC
                    ON bc.business_contact_nr = a.CBC_nr
                   AND bc.Maand_nr = a.Maand_nr

                 WHERE a.Standaard_contract_ind = 1
                   AND a.uitlevering_ontvangst_code IS NULL
                 GROUP BY 1,2
                ) c
   ON c.Maand_nr = a.Maand_nr
  AND c.CC_nr = a.CC_nr


/* Transacties (mogelijk nog trx per beleggingscategorie) */
LEFT OUTER JOIN
                (
                 SEL
                      bc.Klant_nr AS cc_nr
                     ,a.maand_nr

                     ,SUM(CASE WHEN uitlevering_ontvangst_code = 'O' THEN ZEROIFNULL(n_trx) ELSE 0 END)                  AS N_ontvangst
                     ,SUM(CASE WHEN uitlevering_ontvangst_code = 'O' THEN ZEROIFNULL(bedrag_trx) ELSE 0 END)             AS Bedrag_ontvangst
                     ,SUM(CASE WHEN uitlevering_ontvangst_code = 'O' THEN ZEROIFNULL(-bedrag_provisie) ELSE 0 END)       AS Bedrag_provisie_ontvangst

                     ,SUM(CASE WHEN uitlevering_ontvangst_code = 'O' THEN ZEROIFNULL(n_trx_mat) ELSE 0 END)              AS N_ontvangst_MAT
                     ,SUM(CASE WHEN uitlevering_ontvangst_code = 'O' THEN ZEROIFNULL(bedrag_trx_mat) ELSE 0 END)         AS Bedrag_ontvangst_MAT
                     ,SUM(CASE WHEN uitlevering_ontvangst_code = 'O' THEN ZEROIFNULL(-bedrag_provisie_mat) ELSE 0 END)   AS Bedrag_provisie_ontvangst_MAT

                     ,SUM(CASE WHEN uitlevering_ontvangst_code = 'U' THEN ZEROIFNULL(n_trx) ELSE 0 END)                  AS N_uitlevering
                     ,SUM(CASE WHEN uitlevering_ontvangst_code = 'U' THEN ZEROIFNULL(bedrag_trx) ELSE 0 END)             AS Bedrag_uitl
                     ,SUM(CASE WHEN uitlevering_ontvangst_code = 'U' THEN ZEROIFNULL(-bedrag_provisie) ELSE 0 END)       AS Bedrag_provisie_uitl

                     ,SUM(CASE WHEN uitlevering_ontvangst_code = 'U' THEN ZEROIFNULL(n_trx_mat) ELSE 0 END)              AS N_uitlevering_MAT
                     ,SUM(CASE WHEN uitlevering_ontvangst_code = 'U' THEN ZEROIFNULL(bedrag_trx_mat) ELSE 0 END)         AS Bedrag_uitl_MAT
                     ,SUM(CASE WHEN uitlevering_ontvangst_code = 'U' THEN ZEROIFNULL(-bedrag_provisie_mat) ELSE 0 END)   AS Bedrag_provisie_uitl_MAT

                 FROM MI_vm_nzdb.vEff_Contract_Transacties    a

                 INNER JOIN MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr_NEW Mnd
                    ON mnd.Maand_nr = a.Maand_nr
                   AND mnd.N_maanden_terug = 0   /* actuele maand in Mia_hist */

                 INNER JOIN MI_SAS_AA_MB_C_MB.Mia_klantkoppelingen_hist_NEW    BC
                    ON bc.business_contact_nr = a.CBC_nr
                   AND bc.Maand_nr = a.Maand_nr

                 WHERE a.Standaard_contract_ind = 1
                   AND a.uitlevering_ontvangst_code IN ('U', 'O')
                 GROUP BY 1,2
                ) d
   ON d.Maand_nr = a.Maand_nr
  AND d.CC_nr = a.CC_nr

LEFT OUTER JOIN MI_vm_nzdb.vCommercieel_cluster  e
   ON e.Maand_nr = a.Maand_nr
  AND e.CC_nr = a.CC_nr

LEFT OUTER JOIN MI_vm_nzdb.vRechtsvorm  f
   ON f.Maand_nr = e.Maand_nr
  AND f.Rechtsvorm_code = e.CC_AAB_rechtsvorm_code

LEFT OUTER JOIN (
                SEL *
                FROM  Mi_temp.Part_zak_BC
                GROUP BY 1,2
                QUALIFY RANK (Relatie_oms ASC, Part_bc_CGC DESC, Part_BC_nr DESC) = 1
                ) g
  ON g.Klant_nr = a.CC_nr

/* zorgplicht signaal 3 maanden oud */
LEFT OUTER JOIN
                 (
                  SEL  a.Klant_nr
                  FROM MI_SAS_AA_MB_C_MB.CIAA_beleggen    a

                  INNER JOIN MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr_NEW    b
                     ON a.Maand_nr = b.Maand_nr

                  WHERE b.N_maanden_terug BETWEEN 1 AND 3
                    AND a.Zorgplicht_signaal = 'ja'
                  GROUP BY 1
                  HAVING COUNT(*) = 3
                 ) h
  ON h.Klant_nr = Mia.Klant_nr

 /* BCnrs met zorgplicht signaal EN GEEN nul-depot --> ACTIE VEREIST */
LEFT OUTER JOIN (SEL  Maand_nr
                     ,Klant_nr
                     ,COUNT(DISTINCT BC_nr) AS N_BC_zorgplicht
                     ,MAX(BC_nr)            AS BC_nr_zorgplicht
                     ,MAX(Actie_vereist)    AS Zorgplicht_Actie_vereist
                 FROM MI_temp.CIAA_Beleggen_t1
                 WHERE Actie_vereist = 1
                 GROUP BY 1,2
                 ) i
    ON i.Maand_nr = Mia.Maand_nr
   AND i.Klant_nr = Mia.Klant_nr

WHERE Mia.Klant_ind = 1
  AND Mia.Clientgroep < 1300
  AND Mnd.N_maanden_terug = 0  /* actuele maand in Mia_hist */
) WITH DATA
UNIQUE PRIMARY INDEX (Maand_nr, Klant_nr)
;

INSERT INTO Mi_temp.CIAA_TWK_3_FAC
SELECT
       0
      ,a.*
FROM MI_SAS_AA_MB_C_MB.CIAA_TWK_3_FAC a
;

INSERT INTO Mi_temp.CIAA_TWK_3_FAC
SELECT
       1
      ,DATE
      ,a.fk_aanvr_wkmid
      ,a.fk_aanvr_versie
      ,a.fk_voorstel_ver
      ,a.rc_bestaande_kredi
      ,a.rc_gewenste_kredie
      ,a.rc_bestaande_kred0
      ,a.rc_gewenste_kredi0
      ,a.bestaande_leningen
      ,a.gewenste_leningen
      ,a.bestaande_lease_aa
      ,a.gewenste_lease_aa
      ,a.bestaande_obsi_vta
      ,a.gewenste_obsi_vta
      ,a.totaal_faciliteite
      ,a.totaal_faciliteit0
      ,a.samenhang_facilite
      ,a.samenhang_facilit0
      ,a.samenhang_facilit1
      ,a.totaal_one_obligor
      ,a.totaal_one_obligo0
      ,a.ml_lening_lease_3e
      ,a.ml_lening_lease_30
      ,a.ml_lening_lease_31
      ,a.rc_bestaande_krd_t
      ,a.gewenste_extra_afl
      ,a.notatie_vorm
      ,a.date_time_created
      ,a.userid_created
      ,a.date_time_last_upd
      ,a.userid_last_update
      ,a.bsk_dekkingstekort
      ,a.max_bsk
      ,a.totaal_6_maand_afl
      ,a.totaal_kredieten_b
      ,a.totaal_kredieten_g
      ,a.bestaande_len_extr
      ,a.bestde_mddr_limiet
      ,a.gewnst_mddr_limiet

FROM mi_vm_load.vTWK_3_FACILITEITEN a
;

INSERT INTO MI_SAS_AA_MB_C_MB.CIAA_TWK_3_FAC
SEL    a.Datum_gegevens
      ,a.fk_aanvr_wkmid
      ,a.fk_aanvr_versie
      ,a.fk_voorstel_ver
      ,a.rc_bestaande_kredi
      ,a.rc_gewenste_kredie
      ,a.rc_bestaande_kred0
      ,a.rc_gewenste_kredi0
      ,a.bestaande_leningen
      ,a.gewenste_leningen
      ,a.bestaande_lease_aa
      ,a.gewenste_lease_aa
      ,a.bestaande_obsi_vta
      ,a.gewenste_obsi_vta
      ,a.totaal_faciliteite
      ,a.totaal_faciliteit0
      ,a.samenhang_facilite
      ,a.samenhang_facilit0
      ,a.samenhang_facilit1
      ,a.totaal_one_obligor
      ,a.totaal_one_obligo0
      ,a.ml_lening_lease_3e
      ,a.ml_lening_lease_30
      ,a.ml_lening_lease_31
      ,a.rc_bestaande_krd_t
      ,a.gewenste_extra_afl
      ,a.notatie_vorm
      ,a.date_time_created
      ,a.userid_created
      ,a.date_time_last_upd
      ,a.userid_last_update
      ,a.bsk_dekkingstekort
      ,a.max_bsk
      ,a.totaal_6_maand_afl
      ,a.totaal_kredieten_b
      ,a.totaal_kredieten_g
      ,a.bestaande_len_extr
      ,a.bestde_mddr_limiet
      ,a.gewnst_mddr_limiet
FROM Mi_temp.CIAA_TWK_3_FAC a
QUALIFY RANK (Recent_ind DESC) = 1
;

INSERT INTO Mi_temp.KEM_funnel_rapp_moment
SEL
     a.maand
    ,a.maand_sdat
    ,a.maand_edat
    ,( (CAST (a.maand_edat AS TIMESTAMP(6)))  + INTERVAL '1' DAY  ) - INTERVAL '1' SECOND AS Maand_edat_timestmp

    ,g.KEM_gegevens_datum
    ,( (CAST (g.KEM_gegevens_datum    AS TIMESTAMP(6)))  + INTERVAL '1' DAY  ) - INTERVAL '1' SECOND AS KEM_gegevens_timestmp

    ,a.MaandNrLM
    ,f.maand_sdat
    ,f.maand_edat

    ,a.MaandNrL3M
    ,d.maand_sdat
    ,d.maand_edat

    ,a.MaandNrL6M
    ,e.maand_sdat
    ,e.maand_edat

    ,a.MaandNrLY
    ,c.maand_sdat
    ,c.maand_edat
    ,NULL
FROM Mi_vm.vlu_maand         a

INNER JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW per
   ON a.maand = per.Maand_nr

INNER JOIN  Mi_vm.vlu_maand  c
   ON c.Maand = a.MaandNrLY

INNER JOIN  Mi_vm.vlu_maand  d
   ON d.Maand = a.MaandNrL3M

INNER JOIN  Mi_vm.vlu_maand  e
   ON e.Maand = a.MaandNrL6M

INNER JOIN  Mi_vm.vlu_maand  f
   ON f.Maand = a.MaandNrLM

INNER JOIN (SEL MAX(CAST (  SUBSTR( (TRIM(BOTH FROM (CASE WHEN SUBSTR(timestamp_created,1,4) = '0001' THEN NULL ELSE timestamp_created END) )) ,1,10) AS  DATE FORMAT 'YYYY-MM-DD')) AS KEM_gegevens_datum
            FROM mi_vm_load.vTWK_3_KRD_V_STAT
            ) g
  ON 1=1

;

CREATE TABLE Mi_temp.KEM_funnel_t1a
AS
(
SEL
      a.fk_aanvr_wkmid
     ,a.fk_aanvr_versie
     ,a.Status AS KEM_status
     ,d.KEM_status_nr
     ,d.Funnel_stap_oms AS Funnel_stap
     ,d.Funnel_stap_nr
     ,a.timestamp_created (TIMESTAMP) AS Timestamp_created_stap
     ,(CAST (  SUBSTR( (TRIM(BOTH FROM (CASE WHEN SUBSTR(timestamp_created,1,4) = '0001' THEN NULL ELSE timestamp_created END) )) ,1,10) AS  DATE FORMAT 'YYYY-MM-DD')) AS Date_created_stap
     ,RANK() OVER (PARTITION BY a.fk_aanvr_wkmid, a.fk_aanvr_versie ORDER BY a.timestamp_created ASC) AS Volgnr_chrono_old_new /* !! op timestamp gesorteerd */

FROM mi_vm_load.vTWK_3_KRD_V_STAT  a

LEFT OUTER JOIN MI_SAS_AA_MB_C_MB.KEM_LU_funnel d
   ON TRIM(a.Status) = TRIM(d.Kem_status_oms)

) WITH DATA
UNIQUE PRIMARY INDEX (fk_aanvr_wkmid, fk_aanvr_versie, KEM_status_nr)
;

CREATE TABLE Mi_temp.KEM_funnel_t1b
AS
(
SEL

     a.FK_AANVR_WKMID
    ,a.FK_AANVR_VERSIE
    ,a.KEM_status
    ,a.Kem_status_nr
    ,a.Funnel_stap
    ,a.Funnel_stap_nr
    ,CASE WHEN a.Volgnr_chrono_old_new = 1 AND b.Aanvraag_versie_sdat < a.Date_created_stap THEN   CAST(b.Aanvraag_versie_sdat AS TIMESTAMP(6))
          ELSE a.Timestamp_created_stap
     END (TIMESTAMP) AS Timestamp_created_stap
    ,CASE WHEN a.Volgnr_chrono_old_new = 1 AND b.Aanvraag_versie_sdat < a.Date_created_stap THEN b.Aanvraag_versie_sdat
          ELSE a.Date_created_stap
     END AS Date_created_stap
    ,a.Volgnr_chrono_old_new
    ,CAST(b.Aanvraag_versie_sdat AS TIMESTAMP(6))  AS Timestamp_aanvraag
    ,b.Aanvraag_versie_sdat       AS Date_aanvraag

FROM Mi_temp.KEM_funnel_t1a a

    /* eerste initiele aanvraag, DUS VAN EERSTE VERSIE , andere/eerdere datum dan die in mi_vm_load.vTWK_3_KRD_V_STAT */
LEFT OUTER JOIN
           (SELECT  wkm_id
                   /*,versie_nummer*/
                   ,MIN(CAST (  SUBSTR( (TRIM(BOTH FROM (CASE WHEN SUBSTR(DATE_TIME_CREATED,1,4) = '0001' THEN NULL ELSE DATE_TIME_CREATED END) )) ,1,10) AS  DATE FORMAT 'YYYY-MM-DD')) AS Aanvraag_versie_sdat
                   ,MAX(doelgroep_code)    AS Doelgroep
            FROM mi_vm_load.vTWK_3_KREDIET_AANV
            GROUP BY 1
            )    b
   ON a.fk_aanvr_wkmid = b.wkm_id
) WITH DATA
UNIQUE PRIMARY INDEX (fk_aanvr_wkmid, fk_aanvr_versie, KEM_status_nr)
;

CREATE TABLE Mi_temp.KEM_funnel_t1c
AS
(
SEL
      a.FK_AANVR_WKMID
     ,a.FK_AANVR_VERSIE
     ,a.KEM_status
     ,a.Kem_status_nr
     ,a.Funnel_stap
     ,a.Funnel_stap_nr
     ,a.Timestamp_created_stap
     ,a.Date_created_stap
     ,a.Volgnr_chrono_old_new
     ,RANK() OVER (PARTITION BY a.fk_aanvr_wkmid, a.fk_aanvr_versie ORDER BY a.timestamp_created_stap DESC) AS Volgnr_chrono_new_old /* !! op timestamp gesorteerd */
     ,a.Timestamp_aanvraag
     ,a.Date_aanvraag

FROM Mi_temp.KEM_funnel_t1b  a

INNER JOIN Mi_temp.KEM_funnel_rapp_moment per
   ON 1 = 1

    /* meest recente versie met datum voor eind rapportagemaand */
INNER JOIN (
            SEL  FK_AANVR_WKMID
                ,MAX(a.fk_aanvr_versie) AS Max_fk_aanvr_versie
            FROM Mi_temp.KEM_funnel_t1b a

            INNER JOIN Mi_temp.KEM_funnel_rapp_moment per
               ON 1 = 1
             /* datum voor einde rapportagemaand */
            WHERE a.Date_created_stap <= per.Maand_edat
            GROUP BY 1
            ) b
   ON a.fk_aanvr_wkmid = b.fk_aanvr_wkmid
  AND a.fk_aanvr_versie = b.Max_fk_aanvr_versie

      /* meest recente versie met datum voor eind rapportagemaand */
WHERE a.Date_created_stap <= per.Maand_edat
) WITH DATA
UNIQUE PRIMARY INDEX (fk_aanvr_wkmid, fk_aanvr_versie, KEM_status_nr)
;

CREATE TABLE Mi_temp.KEM_funnel_t1d
AS
(
SEL
     a.FK_AANVR_WKMID
    ,a.FK_AANVR_VERSIE
    ,'KEM'                (CHAR(6))     AS Soort_pijplijn
    ,a.KEM_status         (VARCHAR(40)) AS Status
    ,a.Kem_status_nr                    AS Status_nr
    ,a.Timestamp_created_stap
    ,a.Date_created_stap
    ,a.Volgnr_chrono_old_new
    ,a.Volgnr_chrono_new_old
    ,a.Timestamp_aanvraag
    ,a.Date_aanvraag
FROM Mi_temp.KEM_funnel_t1c a
) WITH DATA
UNIQUE PRIMARY INDEX (fk_aanvr_wkmid, fk_aanvr_versie, Soort_pijplijn, Status_nr)
;

INSERT INTO Mi_temp.KEM_funnel_t1d
SEL
     a.FK_AANVR_WKMID
    ,a.FK_AANVR_VERSIE
    ,'Funnel'                      AS Soort_pijplijn
    ,a.Funnel_stap
    ,a.Funnel_stap_nr
    ,MIN(a.Timestamp_created_stap) AS Timestamp_created_stapX
    ,MIN(a.Date_created_stap)      AS Date_created_stapX
    ,RANK() OVER (PARTITION BY a.fk_aanvr_wkmid, a.fk_aanvr_versie ORDER BY Timestamp_created_stapX ASC) AS Volgnr_chrono_old_new /* !! op timestamp gesorteerd */
    ,RANK() OVER (PARTITION BY a.fk_aanvr_wkmid, a.fk_aanvr_versie ORDER BY Timestamp_created_stapX DESC) AS Volgnr_chrono_new_old /* !! op timestamp gesorteerd */
    ,MIN(a.Timestamp_aanvraag)
    ,MIN(a.Date_aanvraag)
FROM Mi_temp.KEM_funnel_t1c a
GROUP BY 1,2,3,4,5
;

CREATE TABLE Mi_temp.KEM_funnel_t2
AS
(
SEL
      a.FK_AANVR_WKMID
     ,a.FK_AANVR_VERSIE
     ,per.Maand_Nr
     ,per.KEM_gegevens_datum
     ,a.Soort_pijplijn
     ,a.Status
     ,a.Status_nr
     ,a.Timestamp_created_stap
     ,a.Date_created_stap
     ,a.Volgnr_chrono_old_new
     ,a.Volgnr_chrono_new_old
     ,a.Timestamp_aanvraag
     ,a.Date_aanvraag
     ,COALESCE(MIN(a.Timestamp_created_stap) OVER (PARTITION BY a.fk_aanvr_wkmid, a.fk_aanvr_versie, a.Soort_pijplijn  ORDER BY a.Volgnr_chrono_old_new ASC ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING) , NULL) (TIMESTAMP(6)) AS  Timestmp_voorg_stap
     ,COALESCE(MIN(a.Date_created_stap) OVER (PARTITION BY a.fk_aanvr_wkmid, a.fk_aanvr_versie, a.Soort_pijplijn  ORDER BY a.Volgnr_chrono_old_new ASC ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING) , NULL) AS  Date_voorg_stapv
     ,COALESCE(MIN(a.Status) OVER (PARTITION BY a.fk_aanvr_wkmid, a.fk_aanvr_versie, a.Soort_pijplijn  ORDER BY a.Volgnr_chrono_old_new ASC ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING) , NULL) AS  Status_voorg_stap
     ,COALESCE(MIN(a.Status_nr) OVER (PARTITION BY a.fk_aanvr_wkmid, a.fk_aanvr_versie, a.Soort_pijplijn  ORDER BY a.Volgnr_chrono_old_new ASC ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING) , NULL) AS  Status_nr_voorg_stap

     ,COALESCE(MIN(a.Timestamp_created_stap) OVER (PARTITION BY a.fk_aanvr_wkmid, a.fk_aanvr_versie, a.Soort_pijplijn  ORDER BY a.Volgnr_chrono_old_new DESC ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING) , NULL) (TIMESTAMP(6)) AS  Timestmp_volg_stap
     ,COALESCE(MIN(a.Date_created_stap) OVER (PARTITION BY a.fk_aanvr_wkmid, a.fk_aanvr_versie, a.Soort_pijplijn  ORDER BY a.Volgnr_chrono_old_new DESC ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING) , NULL) AS  Date_volg_stapv
     ,COALESCE(MIN(a.Status) OVER (PARTITION BY a.fk_aanvr_wkmid, a.fk_aanvr_versie, a.Soort_pijplijn  ORDER BY a.Volgnr_chrono_old_new DESC ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING) , NULL) AS  Status_volg_stap
     ,COALESCE(MIN(a.Status_nr) OVER (PARTITION BY a.fk_aanvr_wkmid, a.fk_aanvr_versie, a.Soort_pijplijn  ORDER BY a.Volgnr_chrono_old_new DESC ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING) , NULL) AS  Status_nr_volg_stap

     ,CASE WHEN ZEROIFNULL(a.Status_nr) >= 89 THEN 0                                                                          /* 0 indien Afgesloten/Afgebroken (stap heeft geen doorlooptijd)                                */
           WHEN a.Volgnr_chrono_new_old = 1 THEN CAST((per.KEM_gegevens_timestmp - Timestamp_created_stap DAY(4)) AS INTEGER) /* meest recente versie loopt nog dus tov einde rapp.maand                                      */
           ELSE CAST((Timestmp_volg_stap - Timestamp_created_stap  DAY(4))    AS INTEGER)                                     /* indien recentere status dan het verschil nemen                                               */
      END AS DLT_stap
     ,CASE WHEN ZEROIFNULL(a.Status_nr) >= 89 THEN  CAST((Timestamp_created_stap - Timestamp_aanvraag DAY(4)) AS INTEGER)     /* afgesloten/afgebroken dan komt er niets bij sinds vorige stap (stap heeft geen doorlooptijd) */
           WHEN  a.Volgnr_chrono_new_old = 1 THEN  CAST((per.KEM_gegevens_timestmp - Timestamp_aanvraag DAY(4)) AS INTEGER)   /* meest recente versie loopt nog dus tov einde rapp.maand                                      */
           ELSE CAST((Timestmp_volg_stap - Timestamp_aanvraag DAY(4)) AS INTEGER)                                             /* indien recentere versie dan begin volgende stap - aanvraag                                   */
      END AS DLT_cumulatief
     ,0 AS Stap_actueel_ind
     ,0 AS Stap_3mnd_ind
     ,0 AS Stap_6mnd_ind
     ,0 AS Stap_12mnd_ind

FROM Mi_temp.KEM_funnel_t1d   a

INNER JOIN Mi_temp.KEM_funnel_rapp_moment per
   ON 1 = 1

) WITH DATA
UNIQUE PRIMARY INDEX (fk_aanvr_wkmid, fk_aanvr_versie, Soort_pijplijn, Status_nr)
;

INSERT INTO Mi_temp.KEM_funnel_faciliteit
SEL
     a.fk_aanvr_wkmid
    ,a.fk_aanvr_versie
    ,a.Totaal_kredieten_b  AS Faciliteit_kort_bestaand
    ,a.Totaal_kredieten_g  AS Faciliteit_kort_gevraagd
    ,a.Bestaande_obsi_vta  AS OBSI_bestaand
    ,a.Gewenste_obsi_vta   AS OBSI_gevraagd
    ,a.BESTAANDE_LEASE_AA  AS Lease_AA_bestaand
    ,a.GEWENSTE_LEASE_AA   AS Lease_AA_gevraagd
    ,a.Bestaande_leningen  AS Leningen_lang_bestaand
    ,a.Gewenste_leningen   AS Leningen_lang_gevraagd
    ,a.Totaal_faciliteite  AS Financiering_lang_bestaand
    ,a.Totaal_faciliteit0  AS Financiering_lang_gevraagd
    ,a.Totaal_one_obligo0  AS One_Obligor_lang_bestaand
    ,a.Totaal_one_obligor  AS One_Obligor_lang_gevraagd
    ,a.totaal_6_maand_afl  AS Totaal6mnds_aflossing
    ,a.MAX_BSK             AS BSK_max
    ,a.BSK_DEKKINGSTEKORT  AS BSK_dekkingstekort

FROM MI_SAS_AA_MB_C_MB.CIAA_TWK_3_FAC    a

    /* relevantie versies */
INNER JOIN (SEL
                 a.fk_aanvr_wkmid
                ,a.fk_aanvr_versie
            FROM Mi_temp.KEM_funnel_t2  a
            GROUP BY 1,2
           ) b
   ON b.FK_AANVR_WKMID = a.FK_AANVR_WKMID

GROUP BY a.fk_aanvr_wkmid, a.fk_aanvr_Versie
QUALIFY RANK (a.date_time_created DESC, a.date_time_last_upd DESC ) = 1
;

CREATE TABLE mi_temp.KEM_funnel_jaarrekening AS
(

SEL
     a.FK_AANVR_WKMID
    ,a.FK_AANVR_VERSIE
    ,(CASE WHEN SUBSTR(a.DATUM_RAPPORT,7,4) = '0001' THEN NULL
           ELSE CAST(SUBSTRING( a.DATUM_RAPPORT FROM 1 FOR 2) ||
                     SUBSTRING( a.DATUM_RAPPORT FROM 4 FOR 2) ||
                     SUBSTRING( a.DATUM_RAPPORT FROM 7 FOR 4)
                      AS DATE  FORMAT 'DDMMYYYY' )
      END) AS Date_jaarrekening
    ,c.BEDRIJFSOMZET       AS Bedrijfsomzet
    ,c.INKOOPWAARDE        AS Inkoopwaarde
    ,c.TOEGEVOEGDE_WAARDE  AS Toegevoegde_waarde
    ,c.PERSONEELSKOSTEN    AS Personeelskosten
    ,c.BEDRIJFSKOSTEN      AS Bedrijfskosten
    ,c.BRUTO_RESULTAAT     AS Bruto_resultaat
    ,c.AFSCHRIJVINGEN      AS Afschrijvingen
    ,c.RENTELASTEN         AS Rentelasten
    ,c.OVERIGE_BATEN_EN_L  AS Overige_baten_en_l
    ,c.BEDRIJFSRESULTAAT   AS Bedrijfsresultaat
    ,c.INCIDENTELE_BATEN   AS Incidentele_baten
    ,c.BELASTINGEN         AS Belastingen
    ,c.WINST_EN_VERLIES_N  AS Winst_en_verlies_n
    ,c.SALDO_UITKERING     AS Saldo_uitkering
    ,c.UITKERING           AS Uitkering
    ,c.INGEHOUDEN_WINST_E  AS Ingehouden_winst_e
    ,c.GECORR_RENTELASTEN  AS Gecorr_rentelasten

FROM mi_vm_load.vTWK_3_JAARREKENIN            a

    /* relevantie versies */
INNER JOIN (SEL
                 a.fk_aanvr_wkmid
                ,a.fk_aanvr_versie
            FROM Mi_temp.KEM_funnel_t2  a
            GROUP BY 1,2
           ) b
   ON b.FK_AANVR_WKMID = a.FK_AANVR_WKMID

LEFT OUTER JOIN mi_vm_load.vTWK_3_WV_REKENING            c
   ON  a.wkm_id = c.fk_jaarr_id

GROUP BY 1,2
QUALIFY RANK(a.FK_AANVR_WKMID, a.FK_AANVR_VERSIE, a.date_time_created  DESC, a.date_time_last_upd DESC) = 1
)WITH DATA
UNIQUE PRIMARY INDEX ( fk_aanvr_wkmid, fk_aanvr_versie )
;

INSERT INTO mi_temp.KEM_funnel_PRCDTL_KRDVS
SEL
     a.fk_aanvr_wkmid
    ,a.fk_aanvr_versie
    ,a.Credit_RARORAC_indicatief
    ,a.Credit_RARORAC_fiat
    ,a.Credit_RARORAC_offerte
    ,a.Credit_RARORAC_geaccepteerd
    ,COALESCE(Credit_RARORAC_geaccepteerd, Credit_RARORAC_offerte, Credit_RARORAC_fiat, Credit_RARORAC_indicatief) Credit_RARORAC

    ,a.Credit_EP_indicatief
    ,a.Credit_EP_fiat
    ,a.Credit_EP_offerte
    ,a.Credit_EP_geaccepteerd
    ,COALESCE(Credit_EP_geaccepteerd, Credit_EP_offerte, Credit_EP_fiat, Credit_EP_indicatief) Credit_EP

    ,a.UCR_indicatief
    ,a.UCR_fiat
    ,a.UCR_offerte
    ,a.UCR_geaccepteerd
    ,COALESCE(UCR_geaccepteerd, UCR_offerte, UCR_fiat, UCR_indicatief) UCR

    ,a.Client_RARORAC_indicatief
    ,a.Client_RARORAC_fiat
    ,a.Client_RARORAC_offerte
    ,a.Client_RARORAC_geaccepteerd
    ,a.Client_EP_indicatief
    ,a.Client_EP_fiat
    ,a.Client_EP_offerte
    ,a.Client_EP_geaccepteerd
    ,a.EC_indicatief
    ,a.EC_fiat
    ,a.EC_offerte
    ,a.EC_geaccepteerd
    ,a.Inkomsten_totaal_indicatief
    ,a.Inkomsten_totaal_fiat
    ,a.Inkomsten_totaal_offerte
    ,a.Inkomsten_totaal_geaccepteerd
    ,a.Client_AAEBREFFECT_TO_ind
    ,a.Client_AAEBREFFECT_TO_fiat
    ,a.Client_AAEBREFFECT_TO_offerte
    ,a.Client_AAEBREFFECT_TO_geacc
    ,a.Client_inkomsten_totaal_ind
    ,a.Client_inkomsten_totaal_fiat
    ,a.Client_inkomsten_totaal_off
    ,a.Client_inkomsten_totaal_geacc
    ,a.Client_optiekosten_indicatief
    ,a.Client_optiekosten_fiat
    ,a.Client_optiekosten_offerte
    ,a.Client_optiekosten_geacc
    ,a.Client_belastingen_indicatief
    ,a.Client_belastingen_fiat
    ,a.Client_belastingen_offerte
    ,a.Client_belastingen_geacc
    ,a.Client_exp_loss_indicatief
    ,a.Client_exp_loss_fiat
    ,a.Client_exp_loss_offerte
    ,a.Client_exp_loss_geaccepteerd
    ,a.Client_EC_indicatief
    ,a.Client_EC_fiat
    ,a.Client_EC_offerte
    ,a.Client_EC_geaccepteerd
    ,a.Client_oper_kosten_indicatief
    ,a.Client_oper_kosten_fiat
    ,a.Client_oper_kosten_offerte
    ,a.Client_oper_kosten_geacc
    ,a.Client_result_na_bel_ind
    ,a.Client_result_na_bel_fiat
    ,a.Client_result_na_bel_offerte
    ,a.Client_result_na_bel_geacc
FROM
     (
      SEL
          a.fk_aanvr_wkmid
         ,a.fk_aanvr_versie
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'A' THEN a.ADV_RAROC_PERCENTA ELSE NULL END) AS Credit_RARORAC_indicatief
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'A' THEN a.ADV_ECONOMIC_PROFI ELSE NULL END) AS Credit_EP_indicatief
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'A' AND TRIM(a.UCR) <> '' THEN (TRIM(a.UCR) (CHAR(2))) ELSE NULL END) AS UCR_indicatief
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'A' THEN a.ADV_CLT_RAROC_PERC ELSE NULL END) AS Client_RARORAC_indicatief
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'A' THEN a.ADV_CLT_ECON_PROF  ELSE NULL END) AS Client_EP_indicatief
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'A' THEN a.ADV_ECONOMIC_CAPIT ELSE NULL END) AS EC_indicatief
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'A' THEN a.ADV_INKOMSTEN_TOTA ELSE NULL END) AS Inkomsten_totaal_indicatief
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'A' THEN a.ADV_AAEBREFFECT_TO ELSE NULL END) AS Client_AAEBREFFECT_TO_ind
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'A' THEN a.CLT_INK_TOTAAL     ELSE NULL END) AS Client_inkomsten_totaal_ind
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'A' THEN a.CLT_OPTIEKOSTEN    ELSE NULL END) AS Client_optiekosten_indicatief
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'A' THEN a.CLT_BELASTINGEN    ELSE NULL END) AS Client_belastingen_indicatief
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'A' THEN a.CLT_EXP_LOSS       ELSE NULL END) AS Client_exp_loss_indicatief
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'A' THEN a.CLT_ECONOMIC_CAP   ELSE NULL END) AS Client_EC_indicatief
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'A' THEN a.CLT_OPER_KOSTEN    ELSE NULL END) AS Client_oper_kosten_indicatief
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'A' THEN a.CLT_RESULT_NA_BEL  ELSE NULL END) AS Client_result_na_bel_ind

         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'F' THEN a.ADV_RAROC_PERCENTA ELSE NULL END) AS Credit_RARORAC_fiat
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'F' THEN a.ADV_ECONOMIC_PROFI ELSE NULL END) AS Credit_EP_fiat
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'F' AND TRIM(a.UCR) <> '' THEN (TRIM(a.UCR) (CHAR(2))) ELSE NULL END) AS UCR_fiat
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'F' THEN a.ADV_CLT_RAROC_PERC ELSE NULL END) AS Client_RARORAC_fiat
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'F' THEN a.ADV_CLT_ECON_PROF  ELSE NULL END) AS Client_EP_fiat
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'F' THEN a.ADV_ECONOMIC_CAPIT ELSE NULL END) AS EC_fiat
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'F' THEN a.ADV_INKOMSTEN_TOTA ELSE NULL END) AS Inkomsten_totaal_fiat
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'F' THEN a.ADV_AAEBREFFECT_TO ELSE NULL END) AS Client_AAEBREFFECT_TO_fiat
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'F' THEN a.CLT_INK_TOTAAL     ELSE NULL END) AS Client_inkomsten_totaal_fiat
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'F' THEN a.CLT_OPTIEKOSTEN    ELSE NULL END) AS Client_optiekosten_fiat
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'F' THEN a.CLT_BELASTINGEN    ELSE NULL END) AS Client_belastingen_fiat
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'F' THEN a.CLT_EXP_LOSS       ELSE NULL END) AS Client_exp_loss_fiat
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'F' THEN a.CLT_ECONOMIC_CAP   ELSE NULL END) AS Client_EC_fiat
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'F' THEN a.CLT_OPER_KOSTEN    ELSE NULL END) AS Client_oper_kosten_fiat
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'F' THEN a.CLT_RESULT_NA_BEL  ELSE NULL END) AS Client_result_na_bel_fiat

         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'O' THEN a.ADV_RAROC_PERCENTA ELSE NULL END) AS Credit_RARORAC_offerte
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'O' THEN a.ADV_ECONOMIC_PROFI ELSE NULL END) AS Credit_EP_offerte
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'O' AND TRIM(a.UCR) <> '' THEN (TRIM(a.UCR) (CHAR(2))) ELSE NULL END) AS UCR_offerte
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'O' THEN a.ADV_CLT_RAROC_PERC ELSE NULL END) AS Client_RARORAC_offerte
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'O' THEN a.ADV_CLT_ECON_PROF  ELSE NULL END) AS Client_EP_offerte
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'O' THEN a.ADV_ECONOMIC_CAPIT ELSE NULL END) AS EC_offerte
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'O' THEN a.ADV_INKOMSTEN_TOTA ELSE NULL END) AS Inkomsten_totaal_offerte
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'O' THEN a.ADV_AAEBREFFECT_TO ELSE NULL END) AS Client_AAEBREFFECT_TO_offerte
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'O' THEN a.CLT_INK_TOTAAL     ELSE NULL END) AS Client_inkomsten_totaal_off
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'O' THEN a.CLT_OPTIEKOSTEN    ELSE NULL END) AS Client_optiekosten_offerte
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'O' THEN a.CLT_BELASTINGEN    ELSE NULL END) AS Client_belastingen_offerte
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'O' THEN a.CLT_EXP_LOSS       ELSE NULL END) AS Client_exp_loss_offerte
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'O' THEN a.CLT_ECONOMIC_CAP   ELSE NULL END) AS Client_EC_offerte
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'O' THEN a.CLT_OPER_KOSTEN    ELSE NULL END) AS Client_oper_kosten_offerte
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'O' THEN a.CLT_RESULT_NA_BEL  ELSE NULL END) AS Client_result_na_bel_offerte

         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'G' THEN a.ADV_RAROC_PERCENTA ELSE NULL END) AS Credit_RARORAC_geaccepteerd
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'G' THEN a.ADV_ECONOMIC_PROFI ELSE NULL END) AS Credit_EP_geaccepteerd
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'G' AND TRIM(a.UCR) <> '' THEN (TRIM(a.UCR) (CHAR(2))) ELSE NULL END) AS UCR_geaccepteerd
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'G' THEN a.ADV_CLT_RAROC_PERC ELSE NULL END) AS Client_RARORAC_geaccepteerd
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'G' THEN a.ADV_CLT_ECON_PROF  ELSE NULL END) AS Client_EP_geaccepteerd
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'G' THEN a.ADV_ECONOMIC_CAPIT ELSE NULL END) AS EC_geaccepteerd
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'G' THEN a.ADV_INKOMSTEN_TOTA ELSE NULL END) AS Inkomsten_totaal_geaccepteerd
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'G' THEN a.ADV_AAEBREFFECT_TO ELSE NULL END) AS Client_AAEBREFFECT_TO_geacc
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'G' THEN a.CLT_INK_TOTAAL     ELSE NULL END) AS Client_inkomsten_totaal_geacc
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'G' THEN a.CLT_OPTIEKOSTEN    ELSE NULL END) AS Client_optiekosten_geacc
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'G' THEN a.CLT_BELASTINGEN    ELSE NULL END) AS Client_belastingen_geacc
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'G' THEN a.CLT_EXP_LOSS       ELSE NULL END) AS Client_exp_loss_geaccepteerd
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'G' THEN a.CLT_ECONOMIC_CAP   ELSE NULL END) AS Client_EC_geaccepteerd
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'G' THEN a.CLT_OPER_KOSTEN    ELSE NULL END) AS Client_oper_kosten_geacc
         ,MAX(CASE WHEN a.AAND_ADVIES_VOORGE = 'G' THEN a.CLT_RESULT_NA_BEL  ELSE NULL END) AS Client_result_na_bel_geacc

      FROM mi_vm_load.vTWK_3_PRCDTL_KRDVS a

          /* relevantie versies */
      INNER JOIN (SEL
                       a.fk_aanvr_wkmid
                      ,a.fk_aanvr_versie
                  FROM Mi_temp.KEM_funnel_t2  a
                  GROUP BY 1,2
                 ) b
         ON b.FK_AANVR_WKMID = a.FK_AANVR_WKMID
        AND B.fk_aanvr_versie = A.fk_aanvr_versie
      GROUP BY 1,2
     ) a
;

INSERT INTO Mi_temp.KEM_funnel_KENMERK_P_KR
SEL
      a.fk_aanvr_wkmid  AS WKM_ID
     ,a.fk_aanvr_versie AS Versie_nummer
     ,TRIM(BOTH FROM a.FK_type_kenm_code )
     ,TRIM(BOTH FROM a.FK_TYPE_KENM_DLG_C)
     ,TRIM(BOTH FROM a.FK_TYPE_KENM_VST_T)
FROM mi_vm_load.vTWK_3_KENMERK_P_KR    a
    /* relevantie versies */
INNER JOIN (SEL
                 a.fk_aanvr_wkmid
                ,a.fk_aanvr_versie
            FROM Mi_temp.KEM_funnel_t2  a
            GROUP BY 1,2
           ) b
   ON b.FK_AANVR_WKMID = a.FK_AANVR_WKMID
  AND B.fk_aanvr_versie = A.fk_aanvr_versie

GROUP BY a.fk_aanvr_wkmid, a.fk_aanvr_Versie
/*QUALIFY RANK (a.date_time_created DESC, a.date_time_last_upd DESC ) = 1*/
QUALIFY RANK (CASE WHEN TRIM(BOTH FROM a.FK_type_kenm_code ) = 'XL' THEN 1 ELSE 0 END DESC, a.date_time_created DESC, a.date_time_last_upd DESC ) = 1
;

CREATE TABLE Mi_temp.KEM_funnel_t3
AS
(
SEL
     a.fk_aanvr_wkmid
    ,a.fk_aanvr_versie
    ,per.Maand_Nr
    ,c.UserID_laatste_stap
    ,c.BOnr_laatste_stap
    ,b.Doelgroep_code    AS Doelgroep
    ,(CASE WHEN SUBSTR(b.Datum_laatste_gesp ,7,4) = '0001' THEN NULL
           WHEN SUBSTR(b.Datum_laatste_gesp ,7,4) = '0001' THEN NULL
           ELSE CAST(SUBSTRING( b.Datum_laatste_gesp  FROM 1 FOR 2) ||
                     SUBSTRING( b.Datum_laatste_gesp  FROM 4 FOR 2) ||
                     SUBSTRING( b.Datum_laatste_gesp  FROM 7 FOR 4)
                      AS DATE  FORMAT 'DDMMYYYY' )
      END) AS Datum_laatste_gesp
    ,TRIM(b.NAAM_ACCOUNTMANGER) AS RM_naam
    ,TRIM(b.USERID_ACCOUNTMANA) AS RM_UserID
    /*,b.DOELGROEP_CODE AS Doelgroep_code*/
    ,(CASE WHEN SUBSTR(b.DATUM_ADVIES_SPECI ,7,4) = '0001' THEN NULL
           ELSE CAST(SUBSTRING( b.DATUM_ADVIES_SPECI  FROM 1 FOR 2) ||
                     SUBSTRING( b.DATUM_ADVIES_SPECI  FROM 4 FOR 2) ||
                     SUBSTRING( b.DATUM_ADVIES_SPECI  FROM 7 FOR 4)
                      AS DATE  FORMAT 'DDMMYYYY' )
      END) AS Specialist_advies_datum
    ,b.TYPE_SPECIALIST AS Specialist_type
    ,TRIM(b.TYPE_ADVIES_SPECIA) AS Specialist_advies_type
    ,b.BO_NUMMER_SPECIALI AS Specialist_BOnr
    ,TRIM(b.NAAM_SPECIALIST) AS Specialist_naam
    ,TRIM(b.USERID_SPECIALIST) AS Specialist_UserID

    ,d.actuele_status_num AS Voorstel_status_actueel_nr
    ,TRIM(d.actuele_status) AS Voorstel_status_actueel
    ,d.DOSSIER_NUMMER     AS Voorstel_Dossier_nr
    ,d.Klant_nr           AS Voorstel_Klant_nr
    ,d.BC_NUMMER_HFDK     AS Voorstel_BCnr_hfdrek_nr
    ,d.CGC_CODE           AS Voorstel_BC_CGC
    ,d.Voorstel_BC_CGC_einde AS Voorstel_BC_CGC_einde
    ,d.HOOFDREKENING_NUMM AS Voorstel_Hoofdrekening_nr
    ,TRIM(d.ACTUELE_SECTOR)     AS Voorstel_sector
    ,TRIM(d.dn_type_voorstel)   AS Voorstel_type_bron
    ,TRIM(CASE WHEN d.dn_type_voorstel = 'AAN' AND ZEROIFNULL(e.Financiering_lang_bestaand)  = 0 AND ZEROIFNULL(e.Financiering_lang_gevraagd) <> 0  THEN 'NIEUW'
               WHEN d.dn_type_voorstel = 'AAN' AND ZEROIFNULL(e.Financiering_lang_bestaand) <> 0 AND ZEROIFNULL(e.Financiering_lang_bestaand) < ZEROIFNULL(e.Financiering_lang_gevraagd) THEN 'WIJZIGING VERHOGING'
               WHEN d.dn_type_voorstel = 'AAN' AND ZEROIFNULL(e.Financiering_lang_bestaand) <> 0 AND ZEROIFNULL(e.Financiering_lang_bestaand) > ZEROIFNULL(e.Financiering_lang_gevraagd) THEN 'WIJZIGING VERLAGING'
               ELSE d.dn_type_voorstel
     END) AS Voorstel_type

    ,TRIM(CASE WHEN Voorstel_type='AAN'       THEN 'Aanvraag'
            WHEN Voorstel_type='ACT'       THEN 'Actualisatie '
            WHEN Voorstel_type='AFL'       THEN 'Aflossen ML'
            WHEN Voorstel_type='CRL'       THEN 'Correctie renteperc lening'
            WHEN Voorstel_type='KRB'       THEN 'Krediet beëindigen'
            WHEN Voorstel_type='MKN'       THEN 'Mutatiekredietnemer '
            WHEN Voorstel_type='NIEUW'     THEN 'Nieuw'
            WHEN Voorstel_type='OD'        THEN 'Overdispositie'
            WHEN Voorstel_type='OPS'       THEN 'Opschorten ML'
            WHEN Voorstel_type='PRC'       THEN 'Wijziging pricing RC'
            WHEN Voorstel_type='RCM'       THEN 'Saldo rentecompensatie'
            WHEN Voorstel_type='REN'       THEN 'Renteherziening'
            WHEN Voorstel_type='REV'       THEN 'Revisie'
            WHEN Voorstel_type='RHO'       THEN 'Omzetten variabele naar vaste rente'
            /*WHEN Voorstel_type='WIJZIGING' THEN 'Wijziging'*/
            WHEN Voorstel_type='WIJZIGING VERHOGING' THEN 'Wijziging - verhoging'
            WHEN Voorstel_type='WIJZIGING VERLAGING' THEN 'Wijziging - verlaging'
            WHEN Voorstel_type='VERHOGING' THEN 'Verhoging'
            WHEN Voorstel_type='VERLAGING' THEN 'Verlaging'
            ELSE NULL
        END) AS Voorstel_type_instroom    /* rapportage KRD048 KEm-instroom */

    ,TRIM(d.ACTUELE_POLICY_BEO) AS Voorstel_beoordeling_policy
    ,TRIM(d.ACTUELE_MODEL_BEOO) AS Voorstel_beoordeling_model
    ,TRIM(d.TOTAAL_BEOORDELING) AS Voorstel_beoordeling_totaal
    ,TRIM(d.KANTOOR_NAAM_BO_VR) AS Voorstel_Kantoor_naam
    ,d.KANTOOR_BO_NUMMER        AS Voorstel_Kantoor_BOnr
    ,m.BO_naam                  AS Voorstel_Kantoor_naam_act
    ,m.sbu_srt_bo_code          AS Voorstel_SBU_srt_bo_code_act
    ,m.Type_bo_nr               AS Voorstel_Type_bo_nr_act
    ,m.BU_code                  AS Voorstel_BU_code_act
    ,m.BU_decode_mi             AS Voorstel_BU_decode_mi_act
    ,m.Regio_nr                 AS Voorstel_Regio_nr_act
    ,m.Regio_naam               AS Voorstel_Regio_naam_act

    ,TRIM(CASE WHEN d.FI_CODE_OUD = '' THEN NULL ELSE d.FI_CODE_OUD END) AS FI_CODE_OUD
    ,TRIM(CASE WHEN d.FI_CODE_NEW = '' THEN NULL ELSE d.FI_CODE_NEW END) AS FI_CODE_NEW
    ,TRIM(d.CLASSIFICATIE      ) AS Voorstel_Classificatie
    ,TRIM(d.FRR_BEOORDELING    ) AS Voorstel_FRR_beoordeling
    ,TRIM(d.FRR_BEHANDELPAD    ) AS Voorstel_FRR_behandelpad
    ,TRIM(d.FRR_TE_STARTEN_DOS ) AS Voorstel_FRR_te_starten_dos
    ,TRIM(d.FRR_TARGET_FICODE  ) AS Voorstel_FRR_target_ficode
    ,TRIM(d.ARRANGEMENT_CODE   ) AS Voorstel_arrangement_code
    /*,d.DATUM_HUIDIGE_REVI AS Voorstel_huidige_revisie_dat */
    /*,d.NIEUWE_REVISIE_DAT AS Voorstel_nieuwe_revisie_dat  */
    ,(CASE WHEN SUBSTR(d.DATUM_HUIDIGE_REVI ,7,4) = '0001' THEN NULL
           ELSE CAST(SUBSTRING( d.DATUM_HUIDIGE_REVI  FROM 1 FOR 2) ||
                     SUBSTRING( d.DATUM_HUIDIGE_REVI  FROM 4 FOR 2) ||
                     SUBSTRING( d.DATUM_HUIDIGE_REVI  FROM 7 FOR 4)
                      AS DATE  FORMAT 'DDMMYYYY' )
      END) AS Voorstel_huidige_revisie_dat
    ,(CASE WHEN SUBSTR(d.NIEUWE_REVISIE_DAT ,7,4) = '0001' THEN NULL
           ELSE CAST(SUBSTRING( d.NIEUWE_REVISIE_DAT  FROM 1 FOR 2) ||
                     SUBSTRING( d.NIEUWE_REVISIE_DAT  FROM 4 FOR 2) ||
                     SUBSTRING( d.NIEUWE_REVISIE_DAT  FROM 7 FOR 4)
                      AS DATE  FORMAT 'DDMMYYYY' )
      END) AS Voorstel_nieuwe_revisie_dat
    ,TRIM(d.REK_SALDOCOMP_IND)  AS Voorstel_rek_saldocomp_ind
    ,CASE WHEN TRIM(d.AANVRAAG_GEGEVENS ) = 'J' THEN 1 WHEN TRIM(d.AANVRAAG_GEGEVENS ) = 'N' THEN 0 ELSE NULL END AS Voorstel_Aanvraag_gegevens_ind
    ,CASE WHEN TRIM(d.CLIENT_GEREED_INDI) = 'J' THEN 1 WHEN TRIM(d.CLIENT_GEREED_INDI) = 'N' THEN 0 ELSE NULL END AS Voorstel_Client_ind
    ,CASE WHEN TRIM(d.JAARREKENING_GEREE) = 'J' THEN 1 WHEN TRIM(d.JAARREKENING_GEREE) = 'N' THEN 0 ELSE NULL END AS Voorstel_Jaarrekening_ind
    ,CASE WHEN TRIM(d.KREDIET_BEHOEFTE_G) = 'J' THEN 1 WHEN TRIM(d.KREDIET_BEHOEFTE_G) = 'N' THEN 0 ELSE NULL END AS Voorstel_Kredietbehoefte_ind
    ,CASE WHEN TRIM(d.KREDIET_OPLOSSING ) = 'J' THEN 1 WHEN TRIM(d.KREDIET_OPLOSSING ) = 'N' THEN 0 ELSE NULL END AS Voorstel_Kredietoplossing_ind
    ,CASE WHEN TRIM(d.ZEKERHEDEN_GEREED ) = 'J' THEN 1 WHEN TRIM(d.ZEKERHEDEN_GEREED ) = 'N' THEN 0 ELSE NULL END AS Voorstel_zekerheden_ind
    ,CASE WHEN TRIM(d.NON_FINANCIALS_GER) = 'J' THEN 1 WHEN TRIM(d.NON_FINANCIALS_GER) = 'N' THEN 0 ELSE NULL END AS Voorstel_non_financials_ind
    ,CASE WHEN TRIM(d.AFLOSSINGSVERPL_GE) = 'J' THEN 1 WHEN TRIM(d.AFLOSSINGSVERPL_GE) = 'N' THEN 0 ELSE NULL END AS Voorstel_aflossverplicht_ind
    ,CASE WHEN TRIM(d.AANV_VRAGEN_GEREED) = 'J' THEN 1 WHEN TRIM(d.AANV_VRAGEN_GEREED) = 'N' THEN 0 ELSE NULL END AS Voorstel_aanvraag_vragen_ind
    ,CASE WHEN TRIM(d.PRICING_GEREED_IND) = 'J' THEN 1 WHEN TRIM(d.PRICING_GEREED_IND) = 'N' THEN 0 ELSE NULL END AS Voorstel_pricing_ind
    ,CASE WHEN TRIM(d.ALG_TOELICHTING_IN) = 'J' THEN 1 WHEN TRIM(d.ALG_TOELICHTING_IN) = 'N' THEN 0 ELSE NULL END AS Voorstel_alg_toelichting_ind
    ,CASE WHEN TRIM(d.REVISIE_GEREED_IND) = 'J' THEN 1 WHEN TRIM(d.REVISIE_GEREED_IND) = 'N' THEN 0 ELSE NULL END AS Voorstel_revisie_ind

    ,e.Faciliteit_kort_bestaand
    ,e.Faciliteit_kort_gevraagd
    ,e.OBSI_bestaand
    ,e.OBSI_gevraagd
    ,e.Lease_AA_bestaand
    ,e.Lease_AA_gevraagd
    ,e.Leningen_lang_bestaand
    ,e.Leningen_lang_gevraagd
    ,e.Financiering_lang_bestaand
    ,e.Financiering_lang_gevraagd
    ,e.One_Obligor_lang_bestaand
    ,e.One_Obligor_lang_gevraagd
    ,e.Totaal6mnds_aflossing
    ,e.BSK_max
    ,e.BSK_dekkingstekort

    ,f.Date_jaarrekening
    ,f.Bedrijfsomzet
    ,f.Inkoopwaarde
    ,f.Toegevoegde_waarde
    ,f.Personeelskosten
    ,f.Bedrijfskosten
    ,f.Bruto_resultaat
    ,f.Afschrijvingen
    ,f.Rentelasten
    ,f.Overige_baten_en_l
    ,f.Bedrijfsresultaat
    ,f.Incidentele_baten
    ,f.Belastingen
    ,f.Winst_en_verlies_n
    ,f.Saldo_uitkering
    ,f.Uitkering
    ,f.Ingehouden_winst_e
    ,f.Gecorr_rentelasten

    ,g.RARORAC_indicatief
    ,g.RARORAC_fiat
    ,g.RARORAC_offerte
    ,g.RARORAC_geaccepteerd
    ,g.RARORAC
    ,g.EP_indicatief
    ,g.EP_fiat
    ,g.EP_offerte
    ,g.EP_geaccepteerd
    ,g.EP
    ,g.UCR_indicatief
    ,g.UCR_fiat
    ,g.UCR_offerte
    ,g.UCR_geaccepteerd
    ,g.UCR
    ,g.Client_RARORAC_indicatief
    ,g.Client_RARORAC_fiat
    ,g.Client_RARORAC_offerte
    ,g.Client_RARORAC_geaccepteerd
    ,g.Client_EP_indicatief
    ,g.Client_EP_fiat
    ,g.Client_EP_offerte
    ,g.Client_EP_geaccepteerd
    ,g.EC_indicatief
    ,g.EC_fiat
    ,g.EC_offerte
    ,g.EC_geaccepteerd
    ,g.Inkomsten_totaal_indicatief
    ,g.Inkomsten_totaal_fiat
    ,g.Inkomsten_totaal_offerte
    ,g.Inkomsten_totaal_geaccepteerd
    ,g.Client_AAEBREFFECT_TO_ind
    ,g.Client_AAEBREFFECT_TO_fiat
    ,g.Client_AAEBREFFECT_TO_offerte
    ,g.Client_AAEBREFFECT_TO_geacc
    ,g.Client_inkomsten_totaal_ind
    ,g.Client_inkomsten_totaal_fiat
    ,g.Client_inkomsten_totaal_off
    ,g.Client_inkomsten_totaal_geacc
    ,g.Client_optiekosten_indicatief
    ,g.Client_optiekosten_fiat
    ,g.Client_optiekosten_offerte
    ,g.Client_optiekosten_geacc
    ,g.Client_belastingen_indicatief
    ,g.Client_belastingen_fiat
    ,g.Client_belastingen_offerte
    ,g.Client_belastingen_geacc
    ,g.Client_exp_loss_indicatief
    ,g.Client_exp_loss_fiat
    ,g.Client_exp_loss_offerte
    ,g.Client_exp_loss_geaccepteerd
    ,g.Client_EC_indicatief
    ,g.Client_EC_fiat
    ,g.Client_EC_offerte
    ,g.Client_EC_geaccepteerd
    ,g.Client_oper_kosten_indicatief
    ,g.Client_oper_kosten_fiat
    ,g.Client_oper_kosten_offerte
    ,g.Client_oper_kosten_geacc
    ,g.Client_result_na_bel_ind
    ,g.Client_result_na_bel_fiat
    ,g.Client_result_na_bel_offerte
    ,g.Client_result_na_bel_geacc

    ,TRIM(h.Type_krediet_code ) AS Type_krediet_code
    ,TRIM(h.Type_Doelgroep    ) AS Type_Doelgroep
    ,TRIM(h.Type_VST          ) AS Type_VST
    ,CASE WHEN h.Type_krediet_code='XL' THEN 1 ELSE 0 END AS NPL_ind
    ,CASE WHEN m.BU_decode_mi = 'FR&R' OR TRIM(d.TOTAAL_BEOORDELING) = 'FR&R' THEN 1
          ELSE 0
     END AS FRR_ind
    ,i.Contract_nr                                                                    AS ACBS_Contract_nr
    ,COALESCE(i.BC_nr                ,l.BC_nr                ,j.BC_nr                                       ) AS ACBS_BC_nr
    ,COALESCE(i.Klant_nr             ,l.Klant_nr                                     ,k.Klant_nr            ) AS ACBS_Klant_nr
    ,COALESCE(i.OOE                  ,l.OOE                  ,j.OOE                  ,k.OOE                 ) AS ACBS_OOE
    ,COALESCE(i.Limiet_krediet       ,l.Limiet_krediet       ,j.Limiet_krediet       ,k.Limiet_krediet      ) AS ACBS_Limiet_krediet
    ,-COALESCE(i.Saldo_doorlopend    ,l.Saldo_doorlopend     ,j.Saldo_doorlopend     ,k.Saldo_doorlopend    ) AS ACBS_Saldo_doorlopend
    ,COALESCE(i.Bron_ACBS_ind        ,l.Bron_ACBS_ind        ,j.Bron_ACBS_ind        ,k.Bron_ACBS_ind       ) AS ACBS_Bron_ACBS_ind
    ,COALESCE(i.Saldocompensatie_ind ,l.Saldocompensatie_ind ,j.Saldocompensatie_ind ,k.Saldocompensatie_ind) AS ACBS_Saldocompensatie_ind
    ,COALESCE(i.Ingangdatum_krediet  ,l.Ingangdatum_krediet  ,j.Ingangdatum_krediet  ,k.Ingangdatum_krediet ) AS ACBS_Ingangdatum_krediet

FROM (SELECT   a.fk_aanvr_wkmid
              ,a.fk_aanvr_versie
      FROM Mi_temp.KEM_funnel_t2 a
      GROUP BY 1,2
      ) a

INNER JOIN Mi_temp.KEM_funnel_rapp_moment per
   ON 1 = 1

/* Doelgroep */
LEFT OUTER JOIN mi_vm_load.vTWK_3_KREDIET_AANV  b
   ON a.fk_aanvr_wkmid = b.wkm_id
  AND a.fk_aanvr_versie = b.Versie_nummer

/* User laatste status */
LEFT OUTER JOIN
           (SEL
                  a.fk_aanvr_wkmid
                 ,a.fk_aanvr_versie
                 ,a.USERID_CREATOR      AS UserID_laatste_stap
                 ,a.BO_NUMMER_CREATOR   AS BOnr_laatste_stap
                /* per status een rij */
            FROM mi_vm_load.vTWK_3_KRD_V_STAT  a

            INNER JOIN Mi_temp.KEM_funnel_rapp_moment per
               ON 1 = 1
            WHERE (CAST (  SUBSTR( (TRIM(BOTH FROM (CASE WHEN SUBSTR(a.TIMESTAMP_CREATED,1,4) = '0001' THEN NULL ELSE a.TIMESTAMP_CREATED END) )) ,1,10) AS  DATE FORMAT 'YYYY-MM-DD'))  < per.Maand_sdat
            QUALIFY RANK (TIMESTAMP_CREATED DESC) = 1
            GROUP BY 1,2
            ) c
   ON a.fk_aanvr_wkmid = c.fk_aanvr_wkmid
  AND a.fk_aanvr_versie = c.fk_aanvr_versie

LEFT OUTER JOIN (
                  SEL  a.*
                      ,b.Date_aanvraag
                      ,b.date_created_stap
                      ,a.BC_NUMMER_HFDK        AS Voorstel_BCnr_hfdrek_nr
                      ,a.CGC_CODE              AS Voorstel_BC_CGC
                      ,TRIM(d.Segment_id) (INTEGER) AS Voorstel_BC_CGC_einde
                      ,a.HOOFDREKENING_NUMM    AS Voorstel_Hoofdrekening_nr
                      ,c.Gerelateerd_party_id  AS Klant_nr
                      ,c.Party_party_relatie_Sdat
                      ,c.Party_party_relatie_Edat
                  FROM mi_vm_load.vTWK_3_KRD_VOORSTEL a

                  LEFT OUTER JOIN Mi_temp.KEM_funnel_t2  b
                     ON b.fk_aanvr_wkmid = a.fk_aanvr_wkmid
                    AND b.fk_aanvr_versie = a.fk_aanvr_versie

                      /* Laatste Complexnr. binnen aanvraag periode */
                  LEFT OUTER JOIN  mi_vm_ldm.vparty_party_relatie c
                     ON c.Party_id = a.BC_NUMMER_HFDK
                    AND c.Party_sleutel_type = 'BC'
                    AND c.gerelateerd_party_sleutel_type = 'CC'
                    AND c.party_relatie_type_code IN ('CBCTCC')
                    AND c.Party_party_relatie_Sdat <= b.date_created_stap
                    AND (c.Party_party_relatie_Edat >=  b.Date_aanvraag OR c.Party_party_relatie_Edat IS NULL)

                    /* CGC van BC op laatste moment van aanvraag */
                  LEFT OUTER JOIN  mi_vm_ldm.vSegment_klant d
                     ON d.Party_id = a.BC_NUMMER_HFDK
                    AND d.Party_sleutel_type = 'BC'
                    AND d.Segment_type_code = 'CG'
                    AND d.Segment_klant_Sdat <= b.date_created_stap
                    AND (d.Segment_klant_Edat >=  b.date_created_stap OR d.Segment_klant_Edat IS NULL)

                  WHERE b.Soort_pijplijn = 'Funnel'
                    AND b.volgnr_chrono_new_old = 1
                    AND c.Party_party_relatie_Sdat <= b.date_created_stap
                    AND (c.Party_party_relatie_Edat >=  b.Date_aanvraag OR c.Party_party_relatie_Edat IS NULL)

                  QUALIFY ROW_NUMBER() OVER (PARTITION BY a.fk_aanvr_wkmid ORDER BY  CASE WHEN c.Party_party_relatie_Sdat <=  b.date_created_stap AND (c.Party_party_relatie_Edat >=  b.date_created_stap OR c.Party_party_relatie_Edat IS NULL) THEN 1 ELSE 0 END DESC, Party_party_relatie_sdat DESC) = 1
                  )    d
   ON a.fk_aanvr_wkmid = d.fk_aanvr_wkmid
  AND a.fk_aanvr_versie = d.fk_aanvr_versie

LEFT OUTER JOIN Mi_temp.KEM_funnel_faciliteit     e
   ON a.fk_aanvr_wkmid = e.fk_aanvr_wkmid
  AND a.fk_aanvr_versie = e.fk_aanvr_versie

LEFT OUTER JOIN Mi_temp.KEM_funnel_jaarrekening   f
   ON a.fk_aanvr_wkmid = f.fk_aanvr_wkmid
  AND a.fk_aanvr_versie = f.fk_aanvr_versie

LEFT OUTER JOIN Mi_temp.KEM_funnel_PRCDTL_KRDVS   g
   ON a.fk_aanvr_wkmid = g.fk_aanvr_wkmid
  AND a.fk_aanvr_versie = g.fk_aanvr_versie

LEFT OUTER JOIN Mi_temp.KEM_funnel_KENMERK_P_KR   h
   ON a.fk_aanvr_wkmid = h.fk_aanvr_wkmid
  AND a.fk_aanvr_versie = h.fk_aanvr_versie

    /* ACBS en RC krediet info koppelen op Hoofd Contract_nr */
LEFT OUTER JOIN
                (SEL
                      TO_NUMBER(d.Hoofdrekening) (INTEGER) AS Contract_nr
                     ,d.Maand_nr
                     ,MAX(TO_NUMBER(d.Fac_bc_nr)) AS BC_nr
                     ,MAX(e.Klant_nr) AS Klant_nr
                     ,SUM(ZEROIFNULL(d.OOE)) AS OOE
                     ,SUM(ZEROIFNULL(d.Doorlopend_Limiet)) AS Limiet_krediet
                     ,SUM(ZEROIFNULL(d.Doorlopend_saldo)) AS Saldo_doorlopend
                     ,1 AS Bron_ACBS_ind
                     ,MAX(ZEROIFNULL(CASE WHEN ZEROIFNULL(d.Doorlopend_debet_limiet) > 0 THEN 1 ELSE 0 END )) AS Saldocompensatie_ind
                     ,MIN(d.Datum_ingang) AS Ingangdatum_krediet
                 FROM mi_cmb.vCIF_complex_MF d

                 INNER JOIN Mi_temp.Mia_alle_bcs e
                    ON e.Business_contact_nr = TO_NUMBER(d.Fac_BC_nr)

                 INNER JOIN Mi_temp.KEM_funnel_rapp_moment per
                    ON d.Maand_nr = per.Max_maand_Mia_kred

                 WHERE d.Fac_Actief_ind = 1
                   AND ZEROIFNULL(TO_NUMBER(d.Hoofdrekening)) > 0
                 GROUP BY 1,2
                ) i
   ON i.Contract_nr = d.HOOFDREKENING_NUMM

    /* ACBS en RC krediet info koppelen op Faciliteit Contract_nr */
LEFT OUTER JOIN
                (SEL
                      TO_NUMBER(d.Contract_nr) (INTEGER) AS Contract_nr
                     ,d.Maand_nr
                     ,MAX(TO_NUMBER(d.Fac_bc_nr)) AS BC_nr
                     ,MAX(e.Klant_nr) AS Klant_nr
                     ,SUM(ZEROIFNULL(d.OOE)) AS OOE
                     ,SUM(ZEROIFNULL(d.Doorlopend_Limiet)) AS Limiet_krediet
                     ,SUM(ZEROIFNULL(d.Doorlopend_saldo)) AS Saldo_doorlopend
                     ,1 AS Bron_ACBS_ind
                     ,MAX(ZEROIFNULL(CASE WHEN ZEROIFNULL(d.Doorlopend_debet_limiet) > 0 THEN 1 ELSE 0 END )) AS Saldocompensatie_ind
                     ,MIN(d.Datum_ingang) AS Ingangdatum_krediet
                 FROM mi_cmb.vCIF_complex d

                 INNER JOIN Mi_temp.Mia_alle_bcs e
                    ON e.Business_contact_nr = TO_NUMBER(d.Fac_BC_nr)

                 INNER JOIN Mi_temp.KEM_funnel_rapp_moment per
                    ON d.Maand_nr = per.Max_maand_Mia_kred

                 WHERE d.Fac_Actief_ind = 1
                   AND ZEROIFNULL(TO_NUMBER(d.Hoofdrekening)) > 0
                   AND d.Complex_level_laagste_niv_ind =1
                 GROUP BY 1,2
                ) l
   ON l.Contract_nr = d.HOOFDREKENING_NUMM


    /* ACBS en RC krediet info koppelen op BC_nr */
LEFT OUTER JOIN
                (SEL
                      TO_NUMBER(d.Fac_bc_nr) AS BC_nr
                     ,d.Maand_nr
                     ,SUM(ZEROIFNULL(d.OOE)) AS OOE
                     ,SUM(ZEROIFNULL(d.Doorlopend_Limiet)) AS Limiet_krediet
                     ,SUM(ZEROIFNULL(d.Doorlopend_saldo)) AS Saldo_doorlopend
                     ,1 AS Bron_ACBS_ind
                     ,MAX(ZEROIFNULL(CASE WHEN ZEROIFNULL(d.Doorlopend_debet_limiet) > 0 THEN 1 ELSE 0 END )) AS Saldocompensatie_ind
                     ,MIN(d.Datum_ingang) AS Ingangdatum_krediet
                 FROM mi_cmb.vCIF_complex_MF d

                 INNER JOIN Mi_temp.Mia_alle_bcs e
                    ON e.Business_contact_nr = TO_NUMBER(d.Fac_BC_nr)

                 INNER JOIN Mi_temp.KEM_funnel_rapp_moment per
                    ON d.Maand_nr = per.Max_maand_Mia_kred

                 WHERE d.Fac_Actief_ind = 1
                   AND ZEROIFNULL(TO_NUMBER(d.Hoofdrekening)) > 0
                   AND NOT TO_NUMBER(d.Fac_bc_nr) IS NULL
                 GROUP BY 1,2
                ) j
   ON j.BC_nr = d.BC_NUMMER_HFDK

    /* ACBS en RC krediet info koppelen op Klant_nr */
LEFT OUTER JOIN
                (SEL
                      e.Klant_nr
                     ,d.Maand_nr
                     --,MAX(d.Fac_bc_nr) AS BC_nr
                     ,SUM(ZEROIFNULL(d.OOE)) AS OOE
                     ,SUM(ZEROIFNULL(d.Doorlopend_Limiet)) AS Limiet_krediet
                     ,SUM(ZEROIFNULL(d.Doorlopend_saldo)) AS Saldo_doorlopend
                     ,1 AS Bron_ACBS_ind
                     ,MAX(ZEROIFNULL(CASE WHEN ZEROIFNULL(d.Doorlopend_debet_limiet) > 0 THEN 1 ELSE 0 END )) AS Saldocompensatie_ind
                     ,MIN(d.Datum_ingang) AS Ingangdatum_krediet
                 FROM mi_cmb.vCIF_complex_MF d

                 INNER JOIN Mi_temp.Mia_alle_bcs e
                    ON e.Business_contact_nr = TO_NUMBER(d.Fac_BC_nr)

                 INNER JOIN Mi_temp.KEM_funnel_rapp_moment per
                    ON d.Maand_nr = per.Max_maand_Mia_kred

                 WHERE d.Fac_Actief_ind = 1
                   AND ZEROIFNULL(TO_NUMBER(d.Hoofdrekening)) > 0
                   AND NOT e.Klant_nr IS NULL
                 GROUP BY 1,2
                ) k
   ON k.Klant_nr = d.Klant_nr

    /* Businessline bepalen voor het Kantoor BO_nr uit het voorstel (COO tool bepaald segment obv dit kenmerk, niet op BC CGC) */
LEFT OUTER JOIN
                (SEL
                      d.Party_id as BO_nr
                     ,d.BO_naam
                     ,d.sbu_srt_bo_code
                     ,MAX(d.Type_bo_nr) AS Type_bo_nr
                     ,d.BU_code
                     ,CASE WHEN d.bu_code = '1n' AND d.bo_naam LIKE ANY ('%FR&R%', '%lindorf%') THEN 'FR&R' ELSE d.BU_decode_mi END AS BU_decode_mi
                     ,null                                                             AS Regio_nr
                     ,null AS Regio_naam
                 FROM mi_vm_ldm.vBo_mi_part_zak d
                 /*WHERE bu_code NOT IN ('1H','1C', '1R')*/
                 GROUP BY 1,2,3,5,6,7,8
                 ) m
   ON d.KANTOOR_BO_NUMMER = m.Bo_nr

) WITH DATA
UNIQUE PRIMARY INDEX ( fk_aanvr_wkmid, fk_aanvr_versie )
;

INSERT INTO MI_SAS_AA_MB_C_MB.KEM_pijplijn_NEW
SELECT
        FK_AANVR_WKMID
       ,FK_AANVR_VERSIE
       ,Maand_Nr
       ,KEM_gegevens_datum
       ,Soort_pijplijn
       ,Status
       ,Status_nr
       ,Timestamp_created_stap
       ,Date_created_stap
       ,Volgnr_chrono_old_new
       ,Volgnr_chrono_new_old
       ,Timestamp_aanvraag
       ,Date_aanvraag
       ,Timestmp_voorg_stap
       ,Date_voorg_stapv
       ,Status_voorg_stap
       ,Status_nr_voorg_stap
       ,Timestmp_volg_stap
       ,Date_volg_stapv
       ,Status_volg_stap
       ,Status_nr_volg_stap
       ,DLT_stap
       ,DLT_cumulatief
       ,Stap_actueel_ind
       ,Stap_12mnd_ind
FROM Mi_temp.KEM_funnel_t2;

INSERT INTO MI_SAS_AA_MB_C_MB.KEM_aanvraag_det_NEW
SELECT * FROM Mi_temp.KEM_funnel_t3;

INSERT INTO Mi_temp.Kred_rapportage_moment_afdtabellen
SEL
     lm.maand
    ,lm.maand_sdat
    ,lm.maand_edat
FROM Mi_vm.vlu_maand                      lm
WHERE lm.maand = (SELECT MAX(maand_nr) FROM mi_cmb.cif_complex);

INSERT INTO MI_SAS_AA_MB_C_MB.ahk_basis_NEW
SELECT * FROM MI_SAS_AA_MB_C_MB.ahk_basis;

INSERT INTO MI_SAS_AA_MB_C_MB.ahk_basis_NEW
SELECT
    char_subst(b.master_cr_facility ,'abcdefghijklmnopqrstuvwxyzÀÁÂÃÄÅÆàáâãäåæÇçÈÉÊËèéêëÌÍÎÏÒÓÔÕÖòóôõöÙÚÛÜùúûüýÿ+.,-/;:\_=','')  (DEC(12,0)) AS hoofdrekening
    , char_subst(c.klant_nr ,'abcdefghijklmnopqrstuvwxyzÀÁÂÃÄÅÆàáâãäåæÇçÈÉÊËèéêëÌÍÎÏÒÓÔÕÖòóôõöÙÚÛÜùúûüýÿ+.,-/;:\_=','') (DEC(12,0)) AS bc_nr
    , ((EXTRACT(YEAR FROM b.periode_datum) * 100) + EXTRACT(MONTH FROM b.periode_datum) ) AS maand_nr --b.periode_datum  (FORMAT 'yyyymm') (INTEGER) AS maand
    , a.original_currency_code
    , b.kredietsoort (char(2))
    , MAX(a.closing_cr_limit)*-1 (DEC(15,0))AS krediet_limiet
    , AVG(a.tot_principal_amt_outstanding)*-1 (DEC(15,0))AS gem_POS
    , AVG(a.closing_guarantee_utlz_amt)*-1 (DEC(15,0))AS gem_obligopositie
    , MIN(CASE WHEN a.tot_principal_amt_outstanding GT 0 THEN a.tot_principal_amt_outstanding  ELSE 0 END)*-1 (DEC(15,0)) AS MIN_POS
    , MAX(CASE WHEN a.tot_principal_amt_outstanding GT 0 THEN a.tot_principal_amt_outstanding ELSE 0 END)*-1  (DEC(15,0)) AS MAX_POS

FROM adw_DM_KU.vMASTER_CR_FACILITY_ANALYSE a
JOIN adw_DM_KU.vLU_MASTER_CR_FACILITY   b
  ON a.MASTER_CR_FACILITY_OID = b.MASTER_CR_FACILITY_OID
 AND a.Periode_Datum = b.Periode_Datum

JOIN adw_DM_KU.vLU_Klant c
  ON b.Klant_OID = c.Klant_OID

WHERE b.periode_datum  BETWEEN
                    (SELECT             Ultimomaand_start_datum_tee FROM MI_temp.Kred_rapportage_moment_afdtabellen)
                    AND (SELECT    Ultimomaand_eind_datum_tee FROM MI_temp.Kred_rapportage_moment_afdtabellen)
  AND b.ar_status (NOT CS)  NOT LIKE '%cancelled%'
  AND hoofdrekening GE 100000000
  AND c.klant_nr GT 0
GROUP BY 1,2,3,4,5;

INSERT INTO Mi_temp.Mia_migratie_BC_basis
SELECT A.Klant_nr,
       A.Maand_nr,
       A.Business_contact_nr,
       B.Maand_nr_begin,
       B.Maand_nr_eind,
       B.In_begin,
       B.In_eind,
       B.Klant_ind_begin,
       B.Klant_ind_eind,
       B.Klant_nr_begin,
       B.Klant_nr_eind,
       B.Klant_nr_ongewijzigd,
       B.Klant_nr_gewijzigd,
       B.Klant_nr_weg,
       B.Klant_nr_nieuw,
       0 AS Samengevoegd,
       0 AS Uiteengevallen,
       CASE WHEN XD.Party_id IS NULL AND B.Klant_nr_begin IS NULL THEN 1 ELSE 0 END AS Nieuw_BC,
       CASE WHEN XE.Party_id IS NULL AND B.Klant_nr_eind IS NULL THEN 1 ELSE 0 END AS Vervallen_BC,
       XF.Segment_id AS CGC_begin,
       XG.Segment_id AS CGC_eind,
       XH.Business_line AS Business_line_begin,
       XI.Business_line AS Business_line_eind,
       XH.Segment AS Segment_begin,
       XI.Segment AS Segment_eind
  FROM (SELECT XA.Klant_nr,
               XA.Maand_nr,
               XA.Business_contact_nr
          FROM Mi_sas_aa_mb_c_mb.Mia_klantkoppelingen_hist_NEW XA
          JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW XX
            ON 1 = 1
         WHERE (XA.Maand_nr = XX.Maand_nr OR XA.Maand_nr = XX.Maand_nr_vm1) AND XX.Lopende_maand_ind = 1
         GROUP BY 1, 2, 3) AS A
  LEFT OUTER JOIN (SELECT XA.Business_contact_nr,
               XX.Maand_nr_vm1 AS Maand_nr_begin,
               XX.Maand_nr AS Maand_nr_eind,
               MAX(CASE WHEN XA.Maand_nr = XX.Maand_nr_vm1 THEN 1 ELSE NULL END) AS In_begin,
               MAX(CASE WHEN XA.Maand_nr = XX.Maand_nr     THEN 1 ELSE NULL END) AS In_eind,
               MAX(CASE WHEN XA.Maand_nr = XX.Maand_nr_vm1 THEN XB.Klant_ind ELSE NULL END) AS Klant_ind_begin,
               MAX(CASE WHEN XA.Maand_nr = XX.Maand_nr     THEN XB.Klant_ind ELSE NULL END) AS Klant_ind_eind,
               MIN(XA.Maand_nr) AS Maand_nr,
               MAX(CASE WHEN XA.Maand_nr = XX.Maand_nr_vm1 THEN XA.Klant_nr ELSE NULL END) AS Klant_nr_begin,
               MAX(CASE WHEN XA.Maand_nr = XX.Maand_nr     THEN XA.Klant_nr ELSE NULL END) AS Klant_nr_eind,
               CASE WHEN Klant_nr_begin = Klant_nr_eind THEN 1 ELSE 0 END AS Klant_nr_ongewijzigd,
               CASE WHEN Klant_nr_begin NE Klant_nr_eind THEN 1 ELSE 0 END AS Klant_nr_gewijzigd,
               CASE WHEN Klant_nr_eind IS NULL THEN 1 ELSE 0 END AS Klant_nr_weg,
               CASE WHEN Klant_nr_begin IS NULL THEN 1 ELSE 0 END AS Klant_nr_nieuw
          FROM Mi_sas_aa_mb_c_mb.Mia_klantkoppelingen_hist_NEW XA
          LEFT OUTER JOIN Mi_sas_aa_mb_c_mb.CIAA_Mia_hist_NEW XB
            ON XA.Klant_nr = XB.Klant_nr AND XA.Maand_nr = XB.Maand_nr
          JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW XX
            ON 1 = 1
         WHERE (XA.Maand_nr = XX.Maand_nr OR XA.Maand_nr = XX.Maand_nr_vm1) AND XX.Lopende_maand_ind = 1
         GROUP BY 1, 2, 3) AS B
         ON A.Business_contact_nr = B.Business_contact_nr
  LEFT OUTER JOIN (SELECT XA.Maand_nr,
                          XA.Datum_gegevens AS Datum_begin_periode
                     FROM Mi_sas_aa_mb_c_mb.CIAA_Mia_hist_NEW XA
                     JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW XX
                       ON 1 = 1
                    WHERE XA.Maand_nr = XX.Maand_nr_vm1 AND XX.Lopende_maand_ind = 1
                    GROUP BY 1, 2) AS XB
    ON B.Maand_nr_begin = XB.Maand_nr
  LEFT OUTER JOIN (SELECT XA.Maand_nr,
                          XA.Datum_gegevens AS Datum_eind_periode
                     FROM Mi_sas_aa_mb_c_mb.CIAA_Mia_hist_NEW XA
                     JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW XX
                       ON 1 = 1
                    WHERE XA.Maand_nr = XX.Maand_nr AND XX.Lopende_maand_ind = 1
                    GROUP BY 1, 2) AS XC
    ON B.Maand_nr_eind= XC.Maand_nr

  LEFT OUTER JOIN Mi_vm_ldm.vParty XD
    ON A.Business_contact_nr = XD.Party_id AND XD.Party_sleutel_type = 'BC'
     AND XD.Party_SDAT-1 <= XB.Datum_begin_periode AND (XD.Party_EDAT IS NULL OR (XD.Party_EDAT <= XC.Datum_eind_periode AND XD.Party_EDAT >= XB.Datum_begin_periode))
  LEFT OUTER JOIN Mi_vm_ldm.vParty XE
    ON A.Business_contact_nr = XE.Party_id AND XE.Party_sleutel_type = 'BC'
   AND XE.Party_SDAT-1 <= XC.Datum_eind_periode AND (XE.Party_EDAT IS NULL OR XE.Party_EDAT > XC.Datum_eind_periode)

  LEFT OUTER JOIN Mi_vm_ldm.vSegment_klant XF
    ON A.Business_contact_nr = XF.Party_id AND XF.Party_sleutel_type = 'BC' AND XF.Segment_type_code = 'CG'
   AND XF.Segment_klant_SDAT-1 <= XB.Datum_begin_periode AND (XF.Segment_klant_EDAT IS NULL OR XF.Segment_klant_EDAT > XB.Datum_begin_periode)

  LEFT OUTER JOIN Mi_vm_ldm.vSegment_klant XG
    ON A.Business_contact_nr = XG.Party_id AND XG.Party_sleutel_type = 'BC' AND XG.Segment_type_code = 'CG'
   AND XG.Segment_klant_SDAT-1 <= XC.Datum_eind_periode AND (XG.Segment_klant_EDAT IS NULL OR XG.Segment_klant_EDAT > XC.Datum_eind_periode)

  LEFT OUTER JOIN Mi_sas_aa_mb_c_mb.Cgc_basis XH
    ON XF.Segment_id = XH.Clientgroep
  LEFT OUTER JOIN Mi_sas_aa_mb_c_mb.Cgc_basis XI
    ON XG.Segment_id = XI.Clientgroep;

INSERT INTO Mi_temp.Mia_klanten_uiteengevallen
SELECT A.Klant_nr,
       A.Maand_nr,
       MAX(A.Uiteengevallen) AS Uiteengevallen,
       MAX(B.Ook_samengevoegd) AS Ook_samengevoegd
  FROM Mi_temp.Mia_migratie_BC_basis A
  LEFT OUTER JOIN (SELECT XA.Klant_nr,
                          MAX(XA.Samengevoegd) AS Ook_samengevoegd
                     FROM Mi_temp.Mia_migratie_BC_basis XA
                    WHERE XA.Uiteengevallen = 1
                    GROUP BY 1) AS B
    ON A.Klant_nr = B.Klant_nr
 WHERE A.Uiteengevallen = 1
 GROUP BY 1, 2;

INSERT INTO Mi_temp.Mia_klanten_samengevoegd
SELECT A.Klant_nr,
       A.Maand_nr,
       MAX(A.Samengevoegd) AS Samengevoegd,
       MAX(B.Ook_uiteengevallen) AS Ook_uiteengevallen
  FROM Mi_temp.Mia_migratie_BC_basis A
  LEFT OUTER JOIN (SELECT XA.Klant_nr,
                          MAX(XA.Uiteengevallen) AS Ook_uiteengevallen
                     FROM Mi_temp.Mia_migratie_BC_basis XA
                    WHERE XA.Samengevoegd = 1
                    GROUP BY 1) AS B
    ON A.Klant_nr = B.Klant_nr
 WHERE A.Samengevoegd = 1
 GROUP BY 1, 2;

INSERT INTO Mi_temp.Mia_klanten_nieuw
SELECT *
  FROM (SELECT XA.Klant_nr,
               XA.Maand_nr,
               MAX(XA.Nieuw_BC) AS Nieuw,
               COUNT(*) AS Aantal_bcs,
               SUM(XA.Nieuw_BC) AS Aantal_bcs_nieuw
          FROM Mi_temp.Mia_migratie_BC_basis XA
         GROUP BY 1, 2) AS A
 WHERE A.Nieuw > 0;

INSERT INTO Mi_temp.Mia_klanten_weg
SELECT A.*
  FROM (SELECT XA.Klant_nr,
               XA.Maand_nr,
               MAX(XA.Vervallen_BC) AS Vervallen,
               COUNT(*) AS Aantal_bcs,
               SUM(XA.Vervallen_BC) AS Aantal_bcs_vervallen
          FROM Mi_temp.Mia_migratie_BC_basis XA
         GROUP BY 1, 2) AS A
 WHERE A.Vervallen > 0;

INSERT INTO Mi_temp.Mia_klanten_klantnr_anders
SELECT A.Klant_nr,
       A.Maand_nr,
       A.Klant_nr_eind AS Klant_nr_nieuw,
       1 AS Wijziging_klantnummer,
       CASE
       WHEN A.Business_line_begin IN ('Retail', 'PB') THEN 'R&PB'
       WHEN A.Business_line_begin IN ('CBC', 'SME') AND Ook_instroom = 1 THEN 'Nieuw'
       ELSE A.Business_line_begin
       END AS Business_line_begin,
       CASE
       WHEN A.Business_line_eind IN ('Retail', 'PB') THEN 'R&PB'
       WHEN A.Business_line_eind IN ('CBC', 'SME') AND Ook_uitstroom = 1 THEN 'Weg'
       ELSE A.Business_line_eind
       END AS Business_line_eind,
       A.Klant_ind_begin,
       A.Klant_ind_eind,
       CASE
       WHEN A.Business_line_begin NOT IN ('CBC', 'SME') AND A.Klant_ind_eind = 1 AND A.Business_line_eind IN ('CBC', 'SME') THEN 1
       WHEN A.Business_line_begin IN ('CBC', 'SME')     AND A.Klant_ind_begin = 0 AND A.Klant_ind_eind = 1 AND A.Business_line_eind IN ('CBC', 'SME') THEN 1
       ELSE 0
       END AS Ook_instroom,
       CASE
       WHEN A.Business_line_eind NOT IN ('CBC', 'SME') AND A.Klant_ind_begin = 1 AND A.Business_line_begin IN ('CBC', 'SME') THEN 1
       WHEN A.Business_line_eind IN ('CBC', 'SME')     AND A.Klant_ind_eind = 0 AND A.Klant_ind_begin = 1 AND A.Business_line_begin IN ('CBC', 'SME') THEN 1
       ELSE 0
       END AS Ook_uitstroom
  FROM (SELECT XA.Klant_nr,
               XA.Maand_nr,
               XA.Klant_nr_eind,
               MIN(XA.Business_line_begin) AS Business_line_begin,
               MIN(XA.Business_line_eind) AS Business_line_eind,
               MIN(XA.Segment_begin) AS Segment_begin,
               MIN(XA.Segment_eind) AS Segment_eind,
               MAX(XA.Klant_ind_begin) AS Klant_ind_begin,
               MAX(XA.Klant_ind_eind) AS Klant_ind_eind,
               SUM(XA.Samengevoegd) AS Samen,
               SUM(XA.Uiteengevallen) AS Uiteen,
               SUM(XA.Nieuw_BC) AS Nieuw,
               SUM(XA.Vervallen_BC) AS Vervallen
          FROM Mi_temp.Mia_migratie_BC_basis XA
          JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW XX
            ON 1 = 1
         WHERE XA.Maand_nr = XX.Maand_nr_vm1 AND XX.Lopende_maand_ind = 1
           AND XA.Klant_nr_gewijzigd = 1
         GROUP BY 1, 2, 3) AS A
 WHERE A.Samen = 0
   AND A.Uiteen = 0
   AND A.Nieuw = 0
   AND A.Vervallen = 0;

INSERT INTO Mi_temp.Mia_klanten_andere_BL
SELECT A.Klant_nr,
       A.Maand_nr,
       1 AS Andere_BL,
       CASE
       WHEN A.Business_line IN ('Retail', 'PB') THEN 'R&PB'
       ELSE A.Business_line
       END AS Business_line
  FROM (SELECT XA.Klant_nr,
               XA.Maand_nr,
               COUNT(*) AS Aantal_bcs,
               SUM(XA.Klant_nr_weg) AS Aantal_bcs_weg,
               MAX(XA.Business_line_eind) AS Business_line
          FROM Mi_temp.Mia_migratie_BC_basis XA
         WHERE XA.Vervallen_BC = 0
         GROUP BY 1, 2) AS A
 WHERE A.Aantal_bcs = A.Aantal_bcs_weg;
INSERT INTO Mi_temp.Mia_klanten_andere_BL
SELECT A.Klant_nr,
       A.Maand_nr,
       1 AS Andere_BL,
       CASE
       WHEN A.Business_line IN ('Retail', 'PB') THEN 'R&PB'
       ELSE A.Business_line
       END AS Business_line
  FROM (SELECT XA.Klant_nr,
               XA.Maand_nr,
               MAX(XA.Business_line_eind) AS Business_line
          FROM Mi_temp.Mia_migratie_BC_basis XA
         WHERE XA.Samengevoegd = 0
           AND XA.Uiteengevallen = 0
           AND XA.Nieuw_BC = 0
           AND XA.Vervallen_BC = 0
           AND XA.In_begin IS NULL
         GROUP BY 1, 2) AS A;

INSERT INTO Mi_temp.Mia_migratie_totaal
SELECT A.Klant_nr,
       A.Maand_nr_eind AS Maand_nr,
       'CB' AS Business_line,
       'M2M' AS Periode,
       A.Maand_nr_begin AS Maand_nr_begin,
       A.Maand_nr_eind AS Maand_nr_eind,
       A.In_begin,
       A.In_eind,

       A.Bediening_begin AS Bediening_begin,
       COALESCE(A.Bediening_eind, D.Segment) AS Bediening_eind,

       H5.Klant_nr_nieuw AS Klant_nr_nieuw,

       CASE
       WHEN H5.Wijziging_klantnummer = 1 AND H5.Ook_instroom  = 1 THEN 'Instroom'
       WHEN H5.Wijziging_klantnummer = 1 AND H5.Ook_uitstroom = 1 THEN 'Uitstroom'
       WHEN H5.Wijziging_klantnummer = 1 AND H5.Ook_instroom  = 0 THEN 'Normaal'
       WHEN A.In_begin = 1 AND A.In_eind = 1 THEN 'Normaal'
       WHEN A.In_begin = 1 AND A.In_eind = 0 THEN 'Uitstroom'
       WHEN A.In_begin = 0 AND A.In_eind = 1 THEN 'Instroom'
       END AS In_uitstroom,

       CASE
       WHEN ZEROIFNULL(H4.Nieuw) = 1 AND ZEROIFNULL(H3.Vervallen) = 0 AND H4.Aantal_bcs = H4.Aantal_bcs_nieuw THEN 'Nieuw'
       WHEN ZEROIFNULL(H3.Vervallen) = 1 AND ZEROIFNULL(H4.Nieuw) = 0 AND H3.Aantal_bcs = H3.Aantal_bcs_vervallen THEN 'Bestaand'
       WHEN H1.Samengevoegd = 1 AND H1.Ook_uiteengevallen = 0 AND A.In_begin = 0 THEN 'Administratief'
       WHEN H1.Samengevoegd = 1 AND H1.Ook_uiteengevallen = 0 AND A.In_eind = 0 THEN 'Bestaand'
       WHEN H2.Uiteengevallen = 1 AND H2.Ook_samengevoegd = 0 AND A.In_begin = 0 THEN 'Administratief'
       WHEN H2.Uiteengevallen = 1 AND H2.Ook_samengevoegd = 0 AND A.In_eind = 0 THEN 'Bestaand'
       WHEN ZEROIFNULL(H1.Samengevoegd) + ZEROIFNULL(H2.Uiteengevallen) > 0 AND A.In_begin = 0 THEN 'Administratief'
       WHEN ZEROIFNULL(H1.Samengevoegd) + ZEROIFNULL(H2.Uiteengevallen) > 0 AND A.In_eind = 0 THEN 'Bestaand'
       WHEN ZEROIFNULL(H1.Samengevoegd) + ZEROIFNULL(H2.Uiteengevallen) > 0 THEN 'Bestaand'
       WHEN H5.Wijziging_klantnummer = 1 AND H5.Ook_uitstroom = 1 THEN 'Bestaand'
       WHEN H5.Wijziging_klantnummer = 1 AND H5.Ook_instroom  = 1 THEN 'Nieuw'
       WHEN H5.Wijziging_klantnummer = 1 AND H5.Ook_instroom  = 0 THEN 'Bestaand'
       WHEN A.Status = 'Uitstroom' AND H6.Andere_BL = 1 THEN 'Bestaand'
       WHEN A.Status = 'Instroom' AND H6.Andere_BL = 1 AND H6.Business_line IN ('R&PB', 'CIB') THEN 'Nieuw'
       WHEN A.Status = 'Instroom' AND H6.Andere_BL = 1 AND H6.Business_line IN ('CBC', 'SME') THEN 'Administratief'

       WHEN A.Status = 'Normaal'   AND B.Klant_ind = 1 AND C.Klant_ind = 1 AND B.Business_line IN ('CBC', 'SME', 'CC', 'Retail' /* eenmalig */) AND C.Business_line IN ('CBC', 'SME') THEN 'Bestaand'
       WHEN A.Status = 'Uitstroom' AND B.Klant_ind = 1                     AND B.Business_line IN ('CBC', 'SME', 'CC', 'Retail' /* eenmalig */) AND C.Business_line = 'CIB' THEN 'Bestaand'
       WHEN A.Status = 'Instroom'                      AND C.Klant_ind = 1 AND B.Business_line = 'CIB'           AND C.Business_line IN ('CBC', 'SME') THEN 'Nieuw'
       WHEN A.Status = 'Uitstroom' AND B.Klant_ind = 1                     AND B.Business_line IN ('CBC', 'SME', 'CC', 'Retail' /* eenmalig */) AND C.Business_line = 'Retail' THEN 'Bestaand'
       WHEN A.Status = 'Instroom'                      AND C.Klant_ind = 1 AND B.Business_line = 'Retail'        AND C.Business_line IN ('CBC', 'SME') THEN 'Nieuw'
       WHEN A.Status = 'Uitstroom' AND B.Klant_ind = 1 AND C.Klant_ind = 0 AND B.Business_line IN ('CBC', 'SME', 'CC', 'Retail' /* eenmalig */) AND C.Business_line IN ('CBC', 'SME') THEN 'Bestaand'
       WHEN A.Status = 'Instroom'  AND B.Klant_ind = 0 AND C.Klant_ind = 1 AND B.Business_line IN ('CBC', 'SME', 'CC', 'Retail' /* eenmalig */) AND C.Business_line IN ('CBC', 'SME') THEN 'Nieuw'
       ELSE 'Ntb'
       END AS Van_kop,

       CASE
       WHEN ZEROIFNULL(H4.Nieuw) = 1 AND ZEROIFNULL(H3.Vervallen) = 0 AND H4.Aantal_bcs = H4.Aantal_bcs_nieuw THEN 'Nieuw'
       WHEN ZEROIFNULL(H3.Vervallen) = 1 AND ZEROIFNULL(H4.Nieuw) = 0 AND H3.Aantal_bcs = H3.Aantal_bcs_vervallen THEN A.Bediening_begin
       WHEN H1.Samengevoegd = 1 AND H1.Ook_uiteengevallen = 0 AND A.In_begin = 0 THEN 'Samen'
       WHEN H1.Samengevoegd = 1 AND H1.Ook_uiteengevallen = 0 AND A.In_eind = 0 THEN A.Bediening_begin
       WHEN H2.Uiteengevallen = 1 AND H2.Ook_samengevoegd = 0 AND A.In_begin = 0 THEN 'Uiteen'
       WHEN H2.Uiteengevallen = 1 AND H2.Ook_samengevoegd = 0 AND A.In_eind = 0 THEN A.Bediening_begin
       WHEN ZEROIFNULL(H1.Samengevoegd) + ZEROIFNULL(H2.Uiteengevallen) > 0 AND A.In_begin = 0 THEN 'SamenUiteen'
       WHEN ZEROIFNULL(H1.Samengevoegd) + ZEROIFNULL(H2.Uiteengevallen) > 0 AND A.In_eind = 0 THEN A.Bediening_begin
       WHEN ZEROIFNULL(H1.Samengevoegd) + ZEROIFNULL(H2.Uiteengevallen) > 0 THEN A.Bediening_begin
       WHEN H5.Wijziging_klantnummer = 1 AND H5.Ook_uitstroom = 1 THEN A.Bediening_begin
       WHEN H5.Wijziging_klantnummer = 1 AND H5.Ook_instroom  = 1 THEN H5.Business_line_begin
       WHEN H5.Wijziging_klantnummer = 1 AND H5.Ook_instroom  = 0 THEN A.Bediening_begin
       WHEN A.Status = 'Uitstroom' AND H6.Andere_BL = 1 THEN A.Bediening_begin
       WHEN A.Status = 'Instroom' AND H6.Andere_BL = 1 AND H6.Business_line IN ('R&PB', 'CIB') THEN H6.Business_line
       WHEN A.Status = 'Instroom' AND H6.Andere_BL = 1 AND H6.Business_line IN ('CBC', 'SME') THEN 'Nieuw'

       WHEN A.Status = 'Normaal'   AND B.Klant_ind = 1 AND C.Klant_ind = 1 AND B.Business_line IN ('CBC', 'SME', 'CC', 'Retail' /* eenmalig */) AND C.Business_line IN ('CBC', 'SME') THEN A.Bediening_begin
       WHEN A.Status = 'Uitstroom' AND B.Klant_ind = 1                     AND B.Business_line IN ('CBC', 'SME', 'CC', 'Retail' /* eenmalig */) AND C.Business_line = 'CIB' THEN A.Bediening_begin
       WHEN A.Status = 'Instroom'                      AND C.Klant_ind = 1 AND B.Business_line = 'CIB'           AND C.Business_line IN ('CBC', 'SME') THEN 'CIB'
       WHEN A.Status = 'Uitstroom' AND B.Klant_ind = 1                     AND B.Business_line IN ('CBC', 'SME', 'CC', 'Retail' /* eenmalig */) AND C.Business_line = 'Retail' THEN A.Bediening_begin
       WHEN A.Status = 'Instroom'                      AND C.Klant_ind = 1 AND B.Business_line = 'Retail'        AND C.Business_line IN ('CBC', 'SME') THEN 'R&PB'
       WHEN A.Status = 'Uitstroom' AND B.Klant_ind = 1 AND C.Klant_ind = 0 AND B.Business_line IN ('CBC', 'SME', 'CC', 'Retail' /* eenmalig */) AND C.Business_line IN ('CBC', 'SME') THEN A.Bediening_begin
       WHEN A.Status = 'Instroom'  AND B.Klant_ind = 0 AND C.Klant_ind = 1 AND B.Business_line IN ('CBC', 'SME', 'CC', 'Retail' /* eenmalig */) AND C.Business_line IN ('CBC', 'SME') THEN 'Nieuw'
       ELSE 'Ntb'
       END AS Van_sub,

       CASE
       WHEN ZEROIFNULL(H4.Nieuw) = 1 AND ZEROIFNULL(H3.Vervallen) = 0 AND H4.Aantal_bcs = H4.Aantal_bcs_nieuw THEN 'Naar'
       WHEN ZEROIFNULL(H3.Vervallen) = 1 AND ZEROIFNULL(H4.Nieuw) = 0 AND H3.Aantal_bcs = H3.Aantal_bcs_vervallen THEN 'Weg'
       WHEN H1.Samengevoegd = 1 AND H1.Ook_uiteengevallen = 0 AND A.In_begin = 0 THEN 'Naar'
       WHEN H1.Samengevoegd = 1 AND H1.Ook_uiteengevallen = 0 AND A.In_eind = 0 THEN 'Administratief'
       WHEN H2.Uiteengevallen = 1 AND H2.Ook_samengevoegd = 0 AND A.In_begin = 0 THEN 'Naar'
       WHEN H2.Uiteengevallen = 1 AND H2.Ook_samengevoegd = 0 AND A.In_eind = 0 THEN 'Administratief'
       WHEN ZEROIFNULL(H1.Samengevoegd) + ZEROIFNULL(H2.Uiteengevallen) > 0 AND A.In_begin = 0 THEN 'Naar'
       WHEN ZEROIFNULL(H1.Samengevoegd) + ZEROIFNULL(H2.Uiteengevallen) > 0 AND A.In_eind = 0 THEN 'Administratief'
       WHEN ZEROIFNULL(H1.Samengevoegd) + ZEROIFNULL(H2.Uiteengevallen) > 0 THEN 'Naar'
       WHEN H5.Wijziging_klantnummer = 1 AND H5.Ook_uitstroom = 1 THEN 'Weg'
       WHEN H5.Wijziging_klantnummer = 1 AND H5.Ook_instroom  = 1 THEN 'Naar'
       WHEN H5.Wijziging_klantnummer = 1 AND H5.Ook_instroom  = 0 THEN 'Naar'
       WHEN A.Status = 'Uitstroom' AND H6.Andere_BL = 1 AND H6.Business_line IN ('R&PB', 'CIB') THEN 'Naar'
       WHEN A.Status = 'Uitstroom' AND H6.Andere_BL = 1 AND H6.Business_line IN ('CBC', 'SME') THEN 'Administratief'
       WHEN A.Status = 'Instroom'  AND H6.Andere_BL = 1 THEN 'Naar'

       WHEN A.Status = 'Normaal'   AND B.Klant_ind = 1 AND C.Klant_ind = 1 AND B.Business_line IN ('CBC', 'SME', 'CC', 'Retail' /* eenmalig */) AND C.Business_line IN ('CBC', 'SME') THEN 'Naar'
       WHEN A.Status = 'Uitstroom' AND B.Klant_ind = 1                     AND B.Business_line IN ('CBC', 'SME', 'CC', 'Retail' /* eenmalig */) AND C.Business_line = 'CIB' THEN 'Naar'
       WHEN A.Status = 'Instroom'                      AND C.Klant_ind = 1 AND B.Business_line = 'CIB'           AND C.Business_line IN ('CBC', 'SME') THEN 'Naar'
       WHEN A.Status = 'Uitstroom' AND B.Klant_ind = 1                     AND B.Business_line IN ('CBC', 'SME', 'CC', 'Retail' /* eenmalig */) AND C.Business_line = 'Retail' THEN 'Naar'
       WHEN A.Status = 'Instroom'                      AND C.Klant_ind = 1 AND B.Business_line = 'Retail'        AND C.Business_line IN ('CBC', 'SME') THEN 'Naar'
       WHEN A.Status = 'Uitstroom' AND B.Klant_ind = 1 AND C.Klant_ind = 0 AND B.Business_line IN ('CBC', 'SME', 'CC', 'Retail' /* eenmalig */) AND C.Business_line IN ('CBC', 'SME') THEN 'Weg'
       WHEN A.Status = 'Instroom'  AND B.Klant_ind = 0 AND C.Klant_ind = 1 AND B.Business_line IN ('CBC', 'SME', 'CC', 'Retail' /* eenmalig */) AND C.Business_line IN ('CBC', 'SME') THEN 'Naar'
       ELSE 'Ntb'
       END AS Naar_kop,

       CASE
       WHEN ZEROIFNULL(H4.Nieuw) = 1 AND ZEROIFNULL(H3.Vervallen) = 0 AND H4.Aantal_bcs = H4.Aantal_bcs_nieuw THEN A.Bediening_eind
       WHEN ZEROIFNULL(H3.Vervallen) = 1 AND ZEROIFNULL(H4.Nieuw) = 0 AND H3.Aantal_bcs = H3.Aantal_bcs_vervallen THEN 'Weg'
       WHEN H1.Samengevoegd = 1 AND H1.Ook_uiteengevallen = 0 AND A.In_begin = 0 THEN A.Bediening_eind
       WHEN H1.Samengevoegd = 1 AND H1.Ook_uiteengevallen = 0 AND A.In_eind = 0 THEN 'Samen'
       WHEN H2.Uiteengevallen = 1 AND H2.Ook_samengevoegd = 0 AND A.In_begin = 0 THEN A.Bediening_eind
       WHEN H2.Uiteengevallen = 1 AND H2.Ook_samengevoegd = 0 AND A.In_eind = 0 THEN 'Uiteen'
       WHEN ZEROIFNULL(H1.Samengevoegd) + ZEROIFNULL(H2.Uiteengevallen) > 0 AND A.In_begin = 0 THEN A.Bediening_eind
       WHEN ZEROIFNULL(H1.Samengevoegd) + ZEROIFNULL(H2.Uiteengevallen) > 0 AND A.In_eind = 0 THEN 'SamenUiteen'
       WHEN ZEROIFNULL(H1.Samengevoegd) + ZEROIFNULL(H2.Uiteengevallen) > 0 THEN A.Bediening_eind
       WHEN H5.Wijziging_klantnummer = 1 AND H5.Ook_uitstroom = 1 THEN 'Weg'
       WHEN H5.Wijziging_klantnummer = 1 AND H5.Ook_instroom  = 1 THEN D.Segment
       WHEN H5.Wijziging_klantnummer = 1 AND H5.Ook_instroom  = 0 THEN D.Segment
       WHEN A.Status = 'Uitstroom' AND H6.Andere_BL = 1 AND H6.Business_line IN ('R&PB', 'CIB') THEN H6.Business_line
       WHEN A.Status = 'Uitstroom' AND H6.Andere_BL = 1 AND H6.Business_line IN ('CBC', 'SME') THEN 'Weg'
       WHEN A.Status = 'Instroom'  AND H6.Andere_BL = 1 THEN A.Bediening_eind

       WHEN A.Status = 'Normaal'   AND B.Klant_ind = 1 AND C.Klant_ind = 1 AND B.Business_line IN ('CBC', 'SME', 'CC', 'Retail' /* eenmalig */) AND C.Business_line IN ('CBC', 'SME') THEN A.Bediening_eind
       WHEN A.Status = 'Uitstroom' AND B.Klant_ind = 1                     AND B.Business_line IN ('CBC', 'SME', 'CC', 'Retail' /* eenmalig */) AND C.Business_line = 'CIB' THEN 'CIB'
       WHEN A.Status = 'Instroom'                      AND C.Klant_ind = 1 AND B.Business_line = 'CIB'           AND C.Business_line IN ('CBC', 'SME') THEN A.Bediening_eind
       WHEN A.Status = 'Uitstroom' AND B.Klant_ind = 1                     AND B.Business_line IN ('CBC', 'SME', 'CC', 'Retail' /* eenmalig */) AND C.Business_line = 'Retail' THEN 'R&PB'
       WHEN A.Status = 'Instroom'                      AND C.Klant_ind = 1 AND B.Business_line = 'Retail'        AND C.Business_line IN ('CBC', 'SME') THEN A.Bediening_eind
       WHEN A.Status = 'Uitstroom' AND B.Klant_ind = 1 AND C.Klant_ind = 0 AND B.Business_line IN ('CBC', 'SME', 'CC', 'Retail' /* eenmalig */) AND C.Business_line IN ('CBC', 'SME') THEN 'Weg'
       WHEN A.Status = 'Instroom'  AND B.Klant_ind = 0 AND C.Klant_ind = 1 AND B.Business_line IN ('CBC', 'SME', 'CC', 'Retail' /* eenmalig */) AND C.Business_line IN ('CBC', 'SME') THEN A.Bediening_eind
       ELSE 'Ntb'
       END AS Naar_sub,

       CASE
       WHEN A.Status = 'Instroom'  AND Van_kop = 'Nieuw' AND C.Klant_ind = 1   AND B.Business_line = 'CIB'           AND C.Business_line IN ('CBC', 'SME') THEN 'Van CIB'
       WHEN A.Status = 'Instroom'  AND Van_kop = 'Nieuw' AND C.Klant_ind = 1   AND B.Business_line = 'Retail'        AND C.Business_line IN ('CBC', 'SME') THEN 'Van R&PB'
       WHEN A.Status = 'Uitstroom' AND B.Klant_ind = 1   AND Naar_kop = 'Naar' AND B.Business_line IN ('CBC', 'SME', 'CC' /* eenmalig */) AND C.Business_line = 'CIB' THEN 'Naar CIB'
       WHEN A.Status = 'Uitstroom' AND B.Klant_ind = 1   AND Naar_kop = 'Naar' AND B.Business_line IN ('CBC', 'SME', 'CC' /* eenmalig */) AND C.Business_line = 'Retail' THEN 'Naar R&PB'

       WHEN In_uitstroom = 'Instroom'  AND Van_kop  = 'Administratief' THEN 'Overig-IN'
       WHEN In_uitstroom = 'Instroom'  AND Van_kop  = 'Nieuw'          THEN 'Nieuw'
       WHEN In_uitstroom = 'Uitstroom' AND Naar_kop = 'Administratief' THEN 'Overig-UIT'
       WHEN In_uitstroom = 'Uitstroom' AND Naar_kop = 'Weg'            THEN 'Weg'
       WHEN In_uitstroom = 'Uitstroom' AND Naar_kop = 'Naar'           THEN Naar_kop||' '||Naar_sub
       WHEN In_uitstroom = 'Normaal'                                   THEN 'Normaal'
       ELSE 'Ntb'
       END AS Categorie1,

       CASE
       WHEN In_uitstroom = 'Normaal'   AND Van_sub NE Naar_sub         THEN 'CB-verschuiving'
       ELSE Categorie1
       END AS Categorie2,

       CASE
       WHEN H1.Samengevoegd = 1 THEN 1
       ELSE 0
       END AS Samen,

       CASE
       WHEN H2.Uiteengevallen = 1 THEN 1
       ELSE 0
       END AS Uiteen,

       ZEROIFNULL(B.Bijzonder_beheer_ind) AS FRenR_begin,
       COALESCE(D.Bijzonder_beheer_ind, ZEROIFNULL(C.Bijzonder_beheer_ind)) AS FRenR_eind

  FROM (SELECT CASE WHEN H5.Ook_instroom = 1 THEN H5.Klant_nr ELSE A.Klant_nr END AS Klant_nr,
               XX.Maand_nr_vm1 AS Maand_nr_begin,
               XX.Maand_nr AS Maand_nr_eind,
               MAX(CASE WHEN A.Maand_nr = XX.Maand_nr_vm1 THEN 1 ELSE 0 END) AS In_begin,
               MAX(CASE WHEN A.Maand_nr = XX.Maand_nr     THEN 1 ELSE 0 END) AS In_eind,
               MIN(CASE WHEN H5.Ook_instroom = 1 THEN H5.Maand_nr ELSE A.Maand_nr END) AS Maand_nr,
               MAX(CASE
                   WHEN A.Maand_nr = XX.Maand_nr_vm1 AND A.Segment IN ('YBB', 'KB') THEN 'SME' /* eenmalig */
                   WHEN A.Maand_nr = XX.Maand_nr_vm1 AND A.Segment IN ('KZ') THEN 'SME®'/* eenmalig */
                   WHEN A.Maand_nr = XX.Maand_nr_vm1 THEN A.Segment
                   ELSE NULL
                   END) AS Bediening_begin,
               MAX(CASE WHEN A.Maand_nr = XX.Maand_nr     THEN A.Segment ELSE NULL END) AS Bediening_eind,
               CASE
               WHEN In_begin = 1 AND In_eind = 1 THEN 'Normaal'
               WHEN In_begin = 1 AND In_eind = 0 THEN 'Uitstroom'
               WHEN In_begin = 0 AND In_eind = 1 THEN 'Instroom'
               ELSE 'Onbestemd'
               END AS Status
          FROM Mi_sas_aa_mb_c_mb.CIAA_Mia_hist_NEW A
          JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW XX
            ON 1 = 1

          LEFT OUTER JOIN Mi_temp.Mia_klanten_klantnr_anders H5
            ON A.Klant_nr = H5.Klant_nr AND (H5.Business_line_begin IN ('CBC', 'SME') OR H5.Business_line_eind IN ('CBC', 'SME'))

         WHERE 1 = 1
           AND (A.Maand_nr = XX.Maand_nr OR A.Maand_nr = XX.Maand_nr_vm1) AND XX.Lopende_maand_ind = 1
           AND ((A.Klant_ind = 1
           AND A.Klantstatus = 'C'
           AND (A.Business_line IN ('CBC', 'SME', 'CC' /* eenmalig */) OR (H5.Ook_instroom = 1) OR (A.Business_line = 'Retail' AND A.Segment = 'YBB' /* eenmalig */))))

         GROUP BY 1, 2, 3) AS A

  JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW XX
    ON 1 = 1

  LEFT OUTER JOIN Mi_sas_aa_mb_c_mb.CIAA_Mia_hist_NEW B
    ON A.Klant_nr = B.Klant_nr
   AND B.Maand_nr = XX.Maand_nr_vm1

  LEFT OUTER JOIN Mi_sas_aa_mb_c_mb.CIAA_Mia_hist_NEW C
    ON A.Klant_nr = C.Klant_nr
   AND C.Maand_nr = XX.Maand_nr

  LEFT OUTER JOIN Mi_temp.Mia_klanten_samengevoegd H1
    ON A.Klant_nr = H1.Klant_nr AND A.Maand_nr = H1.Maand_nr

  LEFT OUTER JOIN Mi_temp.Mia_klanten_uiteengevallen H2
    ON A.Klant_nr = H2.Klant_nr AND A.Maand_nr = H2.Maand_nr

  LEFT OUTER JOIN Mi_temp.Mia_klanten_weg H3
    ON A.Klant_nr = H3.Klant_nr AND A.Maand_nr = H3.Maand_nr

  LEFT OUTER JOIN Mi_temp.Mia_klanten_nieuw H4
    ON A.Klant_nr = H4.Klant_nr AND A.Maand_nr = H4.Maand_nr

  LEFT OUTER JOIN Mi_temp.Mia_klanten_klantnr_anders H5
    ON A.Klant_nr = H5.Klant_nr

  LEFT OUTER JOIN Mi_temp.Mia_klanten_andere_BL H6
    ON A.Klant_nr = H6.Klant_nr AND A.Maand_nr = H6.Maand_nr

  LEFT OUTER JOIN Mi_sas_aa_mb_c_mb.CIAA_Mia_hist_NEW D
    ON H5.Klant_nr_nieuw = D.Klant_nr
   AND D.Maand_nr = XX.Maand_nr

 WHERE A.Klant_nr NOT IN (SELECT Klant_nr_nieuw FROM Mi_temp.Mia_klanten_klantnr_anders);

INSERT INTO Mi_sas_aa_mb_c_mb.Mia_migratie_hist_NEW
SELECT A.*
  FROM Mi_temp.Mia_migratie_totaal A;

INSERT INTO MI_SAS_AA_MB_C_MB.Medewerker_Security_NEW
SELECT
 XA.Datum_gegevens
,XA.SBT_id
,XA.Naam
,XA.Soort_mdw
,XA.BO_nr_mdw
,XA.BO_naam_mdw
,XA.GM_ind
,XA.Mdw_sdat
,p.org_niveau3
,p.org_niveau3_bo_nr
,p.org_niveau2
,p.org_niveau2_bo_nr
,p.org_niveau1
,p.org_niveau1_bo_nr
,p.org_niveau0
,p.org_niveau0_bo_nr

FROM ( SELECT
			f.datum_gegevens AS Datum_gegevens
			,a.sbt_id AS SBT_id
			,b.Naam AS Naam
			,a.party_sleutel_type AS Soort_mdw
			,a.Functie AS Functie
			,c.bo_nr AS BO_nr_mdw
			,TRIM(d.BO_naam) AS BO_naam_mdw
			,gm.GM_ind
			,a.CCA
			,Account_Management_Specialism
			,Account_Management_Segment
			,a.Mdw_sdat
			,a.party_sleutel_type
			,e.N_bcs
			,RANK () OVER (PARTITION BY a.sbt_id ORDER BY a.party_sleutel_type ASC, e.N_bcs DESC, a.Mdw_sdat DESC, a.cca DESC) AS Rang
			FROM (	SELECT party_id,
			                      CASE WHEN party_sleutel_type = 'AM' THEN party_id ELSE NULL END AS CCA,
			                      CASE WHEN LENGTH(TRIM(COALESCE(Account_Management_Functie, account_management_sbl_functietitel))) > 0
			                      THEN TRIM(COALESCE(Account_Management_Functie, account_management_sbl_functietitel, 'ONBEKEND')) ELSE 'ONBEKEND' end  AS Functie,
			                      party_sleutel_type,
			                      TRIM(sbt_userid) AS sbt_id,
			                      COALESCE(CASE WHEN LENGTH(TRIM(account_management_specialism)) > 1 THEN TRIM(account_management_specialism) ELSE NULL END, 'Onbekend') AS Account_Management_Specialism,
			                      COALESCE(CASE WHEN LENGTH(TRIM(account_management_segment)) > 1 THEN TRIM(account_management_segment) ELSE NULL END, 'Onbekend')       AS Account_Management_Segment,
			                      max(account_management_sdat) AS Mdw_sdat
			                FROM MI_VM_LDM.aaccount_management
			                WHERE sbt_id IS NOT NULL
			                AND sbt_id  <> 'UI0319' -- dummy id tbv migratie, niet selecteren
			                AND TRIM(FUNCTIE) NOT IN ('Zelst. Verm. Beh.', 'zelfst.Verm.Beh') --uitsluiten zelfstandig vermogensbeheerders (externe partijen)
			                AND LENGTH(TRIM(sbt_id)) > 0
			group by 1,2,3,4,5,6,7	) a
INNER JOIN (SEL party_id,
                party_sleutel_type,
                CASE WHEN party_sleutel_type = 'MW' THEN UPPER(TRIM(Naam)) ELSE UPPER(TRIM(Naamregel_1)) END AS Naam
            FROM mi_vm_ldm.aparty_naam
            WHERE party_sleutel_type IN ('MW')) b
ON a.party_id = b.party_id
AND a.party_sleutel_type = b.party_sleutel_type
INNER JOIN (SEL party_id,
             party_sleutel_type,
             gerelateerd_party_id AS bo_nr
             FROM mi_vm_ldm.aPARTY_PARTY_RELATIE
             WHERE party_relatie_type_code IN ('AMBO', 'MWBO')) c
ON a.party_id = c.party_id
AND a.party_sleutel_type = c.party_sleutel_type

-- Ophalen BO naam medewerker

LEFT JOIN  (SEL party_id AS bo_nr,
                                naam AS bo_naam
                        FROM mi_vm_ldm.aparty_naam
                        WHERE party_sleutel_type = 'BO') d
ON c.bo_nr = d.bo_nr

-- Toevoegen Global Markets Indicator

LEFT JOIN (SEL Party_id as bo_nr,
                               Structuur,
                               Case when substr(Structuur,1,6) = '334524' then 1 else 0 end as GM_ind
                               FROM  mi_vm_ldm.aParty_BO)  gm
on c.bo_nr = gm.bo_nr

-- Bepalen aantal klanten dat aan de RM is gekoppeld

LEFT JOIN (SEL gerelateerd_party_id, gerelateerd_party_sleutel_type, COUNT(party_id) AS N_bcs
                        FROM mi_vm_ldm.aparty_party_relatie
                        WHERE party_relatie_type_code IN ('relman','cltadv')
                        GROUP BY 1,2) e
ON a.party_id = e.gerelateerd_party_id
AND a.party_sleutel_type = e.gerelateerd_party_sleutel_type
LEFT JOIN MI_SAS_AA_MB_C_MB.Mia_periode f
ON 1=1 ) XA

join Mi_sas_aa_mb_c_mb.Mia_organisatie_workaround p on p.bo_nr = xa.bo_nr_mdw
;

INSERT INTO MI_SAS_AA_MB_C_MB.AGRC_MCT_NEW
                SELECT
                a.Draaidatum
                , a.Maand_nr
                , a.Volgnummer
                , trim(a.Value_Chain)
                , trim(a.Control_Responsible_2nd_LoD)
                , trim(a.Business_Structures)
                , CASE WHEN left(a.Business_Structures,16) = 'CIB AAB Clearing' then 'CIB - Clearing'
                              WHEN left(a.Business_Structures,7)   = 'CIB GM ' then 'CIB - Global Markets'
                              WHEN left(a.Business_Structures, 4)  = 'CIB ' then 'CIB - Other'
                              else 'Other (Not CIB)' end as Business_Structure_Category
                , 'Nieuw: CFF/SFF?'
                , trim(a.Country_Code)
                , trim(a.Control_Name)
                , trim(a.Control_ID)
                , trim(a.Monitor_Status)
                , CASE WHEN c.max_mon is not null then 1 else 0 end as Monitor_Status_max
                , CASE WHEN e.max_mon_II is not null then 1 else 0 end as Monitor_Status_max_II
                ,    case   when Monitor_Due_Date__calculated_  is null and Monitor_answer_date is not null then 'Due Date onbekend - Monitored'
                    when Monitor_Due_Date__calculated_  is null and Monitor_answer_date is null then 'Due Date onbekend - Open'
                    when Monitor_answer_date is null and Monitor_Due_Date__calculated_  < draaidatum then 'Open - Overdue'
                    when Monitor_answer_date is null and Monitor_Due_Date__calculated_  >= draaidatum then 'Open - Due'
                    when Monitor_answer_date <= Monitor_Due_Date__calculated_  then 'Monitored - Timely'
                    when Monitor_answer_date > Monitor_Due_Date__calculated_  then 'Monitored - Overdue'
                    else 'CHECK' end
                 , 'Moet nog'
                , trim(a.RAG_Monitor)
                , trim(a.Tester_Status)
                , trim(a.RAG_Tester)
                ,  Monitor_End_of_Reporting
	        ,EXTRACT(YEAR FROM  Monitor_End_of_Reporting )*10 + (FLOOR(2 + EXTRACT(MONTH FROM Monitor_End_of_Reporting))/3)
		, CASE WHEN EXTRACT(YEAR FROM  Monitor_End_of_Reporting )*10 + (FLOOR(2 + EXTRACT(MONTH FROM Monitor_End_of_Reporting))/3)  =
                            EXTRACT(YEAR FROM  (ADD_MONTHS(Draaidatum, -6)))*10 + (FLOOR(2 + EXTRACT(MONTH FROM  ADD_MONTHS(Draaidatum, -6 ) ))/3)
                      THEN 1 ELSE 0 END as MCT_Filter_Qmin2
			, a.Monitor_Due_Date__calculated_
                , a.Monitor_Answer_Date
                , trim(a.Monitored_by)
                , a.Tester_Due_Date__calculated_
                , a.Tester_Answer_Date
                , trim(a.Tested_by)
                , trim(a.CM_Conduct_driver_applicable_)
                , a.vMaxCTMDueDate
                , trim(a.vTestStatusNew)
                , trim(a.vMonitorStatus)
                , trim(a.vMonitorStatusNew)
                FROM MI_CMB.AGRC_MCT_bron a
                        left join (
                        select b.Business_Structures, b.Control_ID, max(b.Monitor_Due_Date__calculated_) as max_mon
                        FROM MI_CMB.AGRC_MCT_bron  b group by b.Business_Structures, b.Control_ID  ) c
                        on c.Business_Structures||c.Control_ID||c.max_mon = a.Business_Structures||a.Control_ID||a.Monitor_Due_Date__calculated_
                    left join (
                       select d.Business_Structures, d.Control_ID,
 			extract( year from(d.Monitor_Due_Date__calculated_)) as jaar
					,(FLOOR(2 + EXTRACT(MONTH FROM (d.Monitor_Due_Date__calculated_ ))/3))  as kwartaal
						, max(d.Monitor_Due_Date__calculated_) as max_mon_II
                        FROM MI_CMB.AGRC_MCT_bron  d
                        group by d.Business_Structures, d.Control_ID, jaar, kwartaal) e
                        on e.Business_Structures||e.Control_ID||e.max_mon_II = a.Business_Structures||a.Control_ID||a.Monitor_Due_Date__calculated_
;

INSERT INTO MI_SAS_AA_MB_C_MB.AGRC_REM_NEW
            select
            a.Draaidatum
            , a.Maand_nr
            , a.Volgnummer
            , trim(a.Event_Type)
            , CASE WHEN Event_Type in ('Gain','Timing Gain')  then 'Gain'
                         WHEN Event_Type LIKE '%Loss%' then 'Loss'
                         WHEN Event_Type in ('Near Miss','Operational Credit Risk') then 'Other'
                         ELSE 'CHECK' end as Event_Type_Cat_1
            , CASE WHEN Event_Type in ('Loss Resulting From Claim','Loss Resulting from Tax C') then 'Loss Resulting From Claim (incl. Tax)'
                         WHEN left(Event_Type, 11) = 'Timing Loss' then 'Timing Loss'
                         WHEN Event_Type in ('Operational Credit Loss','Operational Credit Risk') then 'Operational Credit Loss/Risk'
                         else Event_Type end as Event_Type_Cat_2
            , trim(a.Event_ID)
            , a.Input_Date
            , a.Total_Gross_Loss_Plus_EUR
            , a.Total_Net_Loss_Plus_before_Insur
            , a.Exposure_Amount_EUR
            , trim(a.Business_Structure_Name)
            , CASE WHEN left(a.Business_Structure_Name,16) = 'CIB AAB Clearing' then 'CIB - Clearing'
                         WHEN left(a.Business_Structure_Name,7)   = 'CIB GM ' then 'CIB - Global Markets'
                          WHEN left(a.Business_Structure_Name, 4)  = 'CIB ' then 'CIB - Other'
                          else 'Other (Not CIB)' end as Business_Structure_Category
            , 'Nieuw: CFF/SFF?'  -- NIEUW, bedoeld voor CFB-indeling
            , trim(a.Geography)
            , trim(a.Event_Category)
            , trim(a.Cause_category_1)
            , trim(a.Workflow_status)
            , trim(a.Number_of_incidents)
            , trim(a.Short_description)
            , trim(a.Long_description)
            , trim(a.Steps_Taken)
            , trim(a.Event_Creator)
            , trim(a.Process)
            , trim(a.Product)
            , a.Date_of_rec
            , trim(a.Date_of_rec__Year_)
            , trim(a.Date_of_rec__Month_)
            , trim(a.Date_of_rec__Quarter_)
            , a.Accounting_Date
            , trim(a.Acc_Date__Year_)
            , trim(a.Acc_Date__Month_)
            , trim(a.Acc_Date__Quarter_)
            , a.Provision_Date
            , trim(a.Financial_Status)
            , a.Date_of_Discovery
            FROM MI_CMB.AGRC_REM_bron a;

INSERT INTO MI_SAS_AA_MB_C_MB.AGRC_IMAT_NEW
            SELECT
            a.Draaidatum
            , a.Maand_nr
            , a.Volgnummer
            , trim(a. Business_Structure)
            , CASE WHEN left(a.Business_Structure,16) = 'CIB AAB Clearing' then 'CIB - Clearing'
                         WHEN left(a.Business_Structure,7)   = 'CIB GM ' then 'CIB - Global Markets'
                          WHEN left(a.Business_Structure, 4)  = 'CIB ' then 'CIB - Other'
                          else 'Other (Not CIB)' end as Business_Structure_Category
            , 'Nieuw: CFF/SFF?'  -- NIEUW, bedoeld voor CFB-indeling
            , trim(a. Level2)
            , trim(a. Level3)
            , trim(a. Country_Code)
            , trim(a. Issue_ID)
            , a. VAR9
            , a. VAR9
            , CASE  WHEN VAR9 <  -30 then 'Overdue: meer dan 30 dagen'
                          WHEN VAR9 >= -30 and VAR9 < 0 then 'Overdue: 0 tot 30 dagen'
                          WHEN VAR9 > 0 and VAR9 < 31 then 'Due: 0 tot 30 dagen'
                          WHEN VAR9 > 30 then 'Due: meer dan 30 dagen'
                          else ' Onbekend'  end as  Due_category
            , trim(a. Level_of_Concern)
            , trim(a.Current_Workflow_Step)
            , trim(a.Issue_Title)
            , trim(a.Issue_Description)
            , trim(a.Issue_business_owner)
            , trim(a.Risk_Area)
            , a.Issue_created_date
            , a.Issue_registration_date_in_AGRC
            , a.Issue_Revised_Completion_Date
            , trim(a.Action_Plan_ID)
            , trim(a.Action_Plan_Name)
            , trim(a.Action_plan_description)
            , a.Action_plan_creation_date
            , a.Issue_target_Completion___Review
            , trim(a.Issue_source)
            FROM MI_CMB.AGRC_IMAT_bron a;

create table mi_cmb.medewerkers as(
SELECT
a.party_id
, e.naam as naam_mdw
, a.sbt_userid as sbt_id
, a.account_management_sdat
, a.Account_Management_Functie
, a.account_management_sbl_functietitel as sbl_functie
,e.bo_nr_mdw
,e.bo_naam_mdw
, b.electronisch_adres_id as emailadres
, b.party_adres_status_code
, a.party_sleutel_type
, a.sbt_userid_manager as sbt_id_mgr
,d.electronisch_adres_id as emailadres_mgr
FROM
MI_VM_LDM.aACCOUNT_MANAGEMENT a
join MI_VM_LDM.aPARTY_ELECTRONISCH_ADRES_MW b
on a.party_id = b.party_id
and a.party_sleutel_type = b.party_sleutel_type
join MI_VM_LDM.aACCOUNT_MANAGEMENT c
on a.sbt_userid_manager=c.sbt_userid
join MI_VM_LDM.aPARTY_ELECTRONISCH_ADRES_MW d
on c.party_id = d.party_id
and c.party_sleutel_type = d.party_sleutel_type
join mi_cmb.vcrm_employee_week e
on a.sbt_userid=e.sbt_id) with data and stats primary index (party_id);

INSERT INTO  MI_SAS_AA_MB_C_MB.CTrack_Portfolio_Hist_NEW
SELECT Portfolio_Id
    ,B.Maand_nr
    ,EXTRACT(YEAR FROM  A.Extraction_date )*100 +EXTRACT(MONTH FROM A.Extraction_date ) as Maand_nr_delivery
    ,CASE WHEN EXTRACT(MONTH FROM  A.Extraction_date )  = 1
          THEN (EXTRACT(YEAR FROM  A.Extraction_date )-1)*100 +12
      ELSE EXTRACT(YEAR FROM  A.Extraction_date )*100 +EXTRACT(MONTH FROM A.Extraction_date )-1
     END as Maand_nr_reporting
    ,D.Business_contact_nr
    ,D.Contract_nr
    ,D.Klant_nr
    ,A.BRR_ID
    ,Borrower
    ,Borrower_Id
    ,ACMA_Naam
    ,ACMA_Id
    ,Watch_Code
    ,Credit_Review_Date
    ,CRG_code
    ,Prob_Color_Last_month
    ,Prob_Color_Last_month_final
    ,Proposed_Color_Last_Month
    ,Probe_Color
    ,OOE
    ,Outstanding
    ,Portfolio_ind
    ,System_Name
    ,BO_Nr
    ,Business_Unit
    ,Business_Unit_Name
    ,Business_Line
    ,Proposed_Color
    ,Final_Color
    ,Probe_Del_Date
    ,Last_Comment_Date
    ,TRIM(Action)
    ,TRIM(Trigger_Remarks)
    ,TRIM(Comment_Remarks)
    ,TRIM(Action_Remarks)
    ,Other_Involved
    ,Orange_Overdue_Date
    ,Basel_Revision_Date
    ,Feb_SME_orgnl_ind
    ,Orange_TRA_comment_date
    ,Comm_ACC_reject
    ,TRA_flag
    , 1 as Kredietklanten
    , case when Probe_Color = 'R' and (Prob_Color_Last_month_final <> 'R' or Prob_Color_Last_month_final is null) and Proposed_Color = 'G' then 1 else 0 end as Kleurverlichting_voorgesteld
    , case when Probe_Color = 'R' and (Prob_Color_Last_month_final <> 'R' or Prob_Color_Last_month_final is null) and Proposed_Color = 'G' and  Proposed_Color = Final_Color then 1 else 0 end as  Kleurverlichting_goedgekeurd
    , case when Probe_Color = 'G' and Final_Color = 'R' and Watch_Code is null then 1 else 0 end as Kleurverzwaring_handmatig
    , case when Final_Color = 'O' then 1 else 0 end as Final_Oranje
    , case when Final_Color = 'R' then 1 else 0 end as Final_Rood
    ,  CASE WHEN OOE > 5000000  then 1
                WHEN OOE > 250000 and Final_color in ('O','R')  then 1
                else 0 end as Revisieplichtig -- 20181106 verzoek nieuwe kolom
, CASE WHEN OOE > 5000000 and Action like ('%chterstand%') then 1
                WHEN OOE > 250000 and Final_color in ('O','R') and Action like ('%chterstand%') then 1
                WHEN Credit_Review_Date <= (add_months(per.Maand_Einddatum,3)-1 ) and Action like ('%chterstand%') then 1
                else 0 end as Revisieplichtig_achterstand   -- 20181106 verzoek aanpassing bestaande kolom
    , -101 as Revisies_tijdig -- 20181108 nieuwe kolom
	, case when Portfolio_ind = 'NPL' and Action like ('%UCR is vervallen%') and Basel_Revision_Date < Maand_startdatum -1  then 1 else 0 end as UCR_vervallen
    , case when Final_color = 'O' and Prob_Color_Last_month_final = 'G' and Last_comment_date < (Maand_Einddatum - 30) then 1
            when Final_color = 'O' and  Last_comment_date < (per.Maand_Einddatum - 90) then 1 else 0 end as TRA_in_achterstand
    , case when Watch_Code is not null and Prob_Color_Last_Month = 'G' and Probe_Color = 'G' then 1 else 0 end as Watchbeeindiging_mogelijk
    , -101 as Limietoverschrijding -- (nieuwe kolom aangevraagd in CTRACK-aanlevering....hierop baseren...)
    , -101 as Overdispositie -- (nieuwe kolom aangevraagd in CTRACK aanlevering, hierop baseren) 20181108 nieuwe kolom: overdispositie
    , CASE WHEN G.Acties_totaal IS NULL THEN 0 ELSE G.Acties_totaal END
    , CASE WHEN G.Acties_achterstand IS NULL THEN 0 ELSE G.Acties_achterstand END
FROM  MI_NEMO.CTrack_Portfolio A
LEFT OUTER JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW B ON 1 = 1
LEFT JOIN  Mi_vm_nzdb.vLU_maand per on per.Maand = Maand_nr_delivery
LEFT JOIN (SELECT DISTINCT
                             C.Party_id AS Business_contact_nr
                            , C.Contract_nr
                            , C.Cc_nr AS Klant_nr
                            FROM Mi_vm_ldm.aParty_contract C
                            WHERE C.Party_sleutel_type = 'bc'
                            AND C.Party_contract_rol_code = 'c'
                            AND C.contract_soort_code > 0
                            QUALIFY RANK() OVER (PARTITION BY C.Contract_nr ORDER BY C.Contract_soort_code DESC, C.Party_id) = 1) D
                            on A.borrower_id = D.contract_nr
   LEFT JOIN (select
                                E.relation_id
                                , EXTRACT(YEAR FROM  E.Extraction_date )*100 +EXTRACT(MONTH FROM E.Extraction_date ) as Maand_nr_delivery_dub
                                , count(*)  as Acties_totaal
                                , sum(CASE WHEN e.followup_date < perr.Maand_startdatum -1 then 1 else 0 end) as Acties_achterstand -- EB 20181106 script aangepast, gaat goed? Ter validatie voorgelegd, kolom stond al in script
                                FROM  MI_NEMO.CTrack_OpenActions E
                                LEFT JOIN  Mi_vm_nzdb.vLU_maand perr on perr.Maand  = Maand_nr_delivery_dub
                            QUALIFY RANK() OVER (PARTITION BY E.relation_id ORDER BY Maand_nr_delivery_dub DESC) = 1
                                group by 1, 2) G
                                ON A.borrower_id = G.relation_id
;

INSERT INTO MI_SAS_AA_MB_C_MB.medewerker_email_NEW
SELECT
e.naam as naam_mdw
, a.account_management_sdat
, a.sbt_userid as sbt_id
, a.Account_Management_Functie
, a.account_management_sbl_functietitel as sbl_functie
,e.bo_nr_mdw
,e.bo_naam_mdw
, b.electronisch_adres_id as emailadres
, b.party_adres_status_code
,a.party_id
, a.party_sleutel_type
, a.sbt_userid_manager as sbt_id_mgr
,d.electronisch_adres_id as emailadres_mgr
FROM MI_VM_LDM.aACCOUNT_MANAGEMENT a
join MI_VM_LDM.aPARTY_ELECTRONISCH_ADRES_MW b
on a.party_id = b.party_id
and a.party_sleutel_type = b.party_sleutel_type
join MI_VM_LDM.aACCOUNT_MANAGEMENT c
on a.sbt_userid_manager=c.sbt_userid
join MI_VM_LDM.aPARTY_ELECTRONISCH_ADRES_MW d
on c.party_id = d.party_id
and c.party_sleutel_type = d.party_sleutel_type
join MI_SAS_AA_MB_C_MB.Siebel_Employee_NEW e
on a.sbt_userid = e.sbt_id;

CREATE TABLE MI_SAS_AA_MB_C_MB.cib_klantbeeld_rep_cock_NEW AS
(SELECT MAX(maand_nr) AS max_maand_nr FROM mi_cmb.producten) WITH DATA;

CREATE TABLE mi_sas_aa_mb_c_mb.cib_klantbeeld_rep_tb_NEW   AS
(SELECT MAX(billing_period) AS max_billing_period FROM mi_tb.wrk_ce) WITH DATA;

CREATE TABLE mi_sas_aa_mb_c_mb.cib_klantbeeld_rep_gm_NEW   AS
(SELECT MAX(maand_nr) AS max_maand_nr FROM mi_cmb.smr_transaction) WITH DATA;

CREATE TABLE mi_sas_aa_mb_c_mb.cib_klantbeeld_rep_dp_NEW   AS
(SELECT MAX(maand_nr) AS max_maand_nr FROM mi_cmb.vcrm_verkoopkans_product_week) WITH DATA;

CREATE TABLE mi_sas_aa_mb_c_mb.cib_klantbeeld_rep_rvb_NEW  AS
(SELECT MAX(datum) AS max_datum FROM mi_cmb.rvdv_scrm_bron4) WITH DATA;

CREATE TABLE mi_sas_aa_mb_c_mb.cib_klantbeeld_rep_cr_NEW   AS
(SELECT klant_nr, CAST(1*MAX("Period") AS INTEGER) AS max_period FROM mi_cmb.cib_keymetrics GROUP BY 1) WITH DATA;

CREATE TABLE mi_sas_aa_mb_c_mb.cib_klantbeeld_rep_si_NEW   AS
(SELECT EXTRACT(YEAR FROM X)*100 + EXTRACT(MONTH FROM X) AS max_maand_nr
	 FROM ( SELECT MAX(fonds_waarde_sdat) AS X FROM mi_vm_ldm.aFONDS_WAARDE ) X) WITH DATA;

CREATE TABLE MI_SAS_AA_MB_C_MB.cib_klantbeeld_klanten_NEW AS (
SELECT
	  MIA.Klant_nr
	, MIA.business_contact_nr
	, MIA.maand_nr
	, MIA.datum_gegevens
	, MIA.verkorte_naam

	, CP.ContactPersoon1
	, CP.ContactPersoon2

	, MIA.bo_nr
	, MIA.bo_naam
	, MIA.cca
	, MIA.relatiemanager
	, MIA.kvk_nr
	, MIA.sbi_code
	, MIA.sbi_oms
	, CASE WHEN MIA.klant_ind =1 AND MIA.klantstatus = 'C' THEN 'Active Client' ELSE 'No Active Client' end AS status
	, F.fonds_code

	, NULL                      AS blok0_report_period
	, REP_COCK.max_maand_nr     AS blok1_report_period
	, REP_LND.max_maand_nr      AS blok2_report_period
	, REP_TB.max_billing_period AS blok3_report_period
	, REP_GMB.max_maand_nr       AS blok4_report_period
	, REP_DPO.max_maand_nr      AS blok5_report_period
	, REP_DPC.max_maand_nr      AS blok6_report_period
	, REP_RVB.max_datum         AS blok7_report_period
	, REP_CR.max_period         AS blok8_report_period
	, CASE WHEN ZEROIFNULL(F.fonds_code) > 0 THEN REP_SI.max_maand_nr ELSE NULL END AS blok9_report_period
	, NULL                      AS blok10_report_period
FROM Mi_temp.Mia_week MIA

LEFT JOIN MI_SAS_AA_MB_C_MB.cib_klantbeeld_fondscode F
ON MIA.klant_nr = F.klant_nr

LEFT JOIN
(	SELECT
		XP.klant_nr
		, MAX(CASE WHEN XP.contact_persoon_nr = 1 THEN XP.ContactPersoon end) AS ContactPersoon1
		, MAX(CASE WHEN XP.contact_persoon_nr = 2 THEN XP.ContactPersoon end) AS ContactPersoon2
	FROM
	(	SELECT
			P.klant_nr
			, P.voornaam || CASE WHEN P.tussenvoegsel='' THEN ' ' ELSE ' ' || P.tussenvoegsel || ' ' end  || P.achternaam AS ContactPersoon
			, RANK() OVER(PARTITION BY P.klant_nr ORDER BY client_level , contactpersoon_functietitel DESC , ContactPersoon) AS Contact_persoon_nr

		FROM MI_SAS_AA_MB_C_MB.Siebel_Contactpersoon_NEW P
		WHERE 1=1
		AND P.contactpersoon_onderdeel NE 'Niet opgegeven'
		AND P.actief_ind = 1
		AND P.primair_contact_persoon_ind = 1
		AND P.email_bruikbaar = 1
	) XP
	GROUP BY 1
) CP
ON MIA.Klant_nr = CP.Klant_nr

LEFT JOIN MI_SAS_AA_MB_C_MB.cib_klantbeeld_rep_cock_NEW REP_COCK ON 1=1
LEFT JOIN MI_SAS_AA_MB_C_MB.cib_klantbeeld_rep_tb_NEW   REP_TB   ON 1=1
LEFT JOIN MI_SAS_AA_MB_C_MB.cib_klantbeeld_rep_gm_NEW   REP_GMB   ON 1=1
LEFT JOIN MI_SAS_AA_MB_C_MB.cib_klantbeeld_rep_gm_NEW   REP_GMO   ON 1=1
LEFT JOIN MI_SAS_AA_MB_C_MB.cib_klantbeeld_rep_dp_NEW  REP_DPO  ON 1=1
LEFT JOIN MI_SAS_AA_MB_C_MB.cib_klantbeeld_rep_dp_NEW  REP_DPC  ON 1=1
LEFT JOIN MI_SAS_AA_MB_C_MB.cib_klantbeeld_rep_rvb_NEW  REP_RVB  ON 1=1
LEFT JOIN MI_SAS_AA_MB_C_MB.cib_klantbeeld_rep_cr_NEW   REP_CR   ON MIA.klant_nr = REP_CR.klant_nr AND 1=1
LEFT JOIN MI_SAS_AA_MB_C_MB.cib_klantbeeld_rep_si_NEW   REP_SI   ON 1=1

WHERE 1=1
AND MIA.org_niveau2 = 'CC Consumer Services & Manufacturing'
AND MIA.relatiemanager ne 'Geen naam'
) WITH DATA PRIMARY INDEX(Klant_nr , business_contact_nr) ;

CREATE TABLE MI_SAS_AA_MB_C_MB.cib_klantbeeld_cockpit_NEW AS (
SELECT
	C.klant_nr
	, AA.cs_groep
	, AA.cib_cross_sell
	, A.maand_nr
	, SUM(A.baten) AS baten
FROM mi_cmb.baten_product A

JOIN ( SELECT maand_nr ,  jaar , jaar-1 AS vorig_jaar , maand , (jaar-2)*100 AS vanaf FROM mi_cmb.producten_YM WHERE maand_nr = (SELECT MAX(maand_nr) FROM mi_cmb.producten) GROUP BY 1,2,3,4 ) NU
ON A.maand_nr > NU.vanaf

JOIN ( SELECT maand_nr , productlevel2code , cib_cross_sell , cs_groep FROM MI_SAS_AA_MB_C_MB.cib_cross_sell GROUP BY 1,2,3,4 ) AA
ON A.combiproductlevel = AA.productlevel2code

JOIN Mi_temp.Mia_klantkoppelingen B
ON A.party_id = B.business_contact_nr

JOIN MI_SAS_AA_MB_C_MB.cib_klantbeeld_klanten_NEW C
ON B.klant_nr = C.klant_nr

GROUP BY 1,2,3,4
) WITH DATA UNIQUE PRIMARY INDEX( klant_nr , cs_groep , maand_nr);

CREATE TABLE MI_SAS_AA_MB_C_MB.cib_klantbeeld_tb_NEW AS (
SELECT
	CIB.Klant_nr
	, TB.billing_period                 AS maand_nr
	, TB.trx_soort
	, SUM(TB.turnover)	(DECIMAL(18,0)) AS omzet
	, SUM(TB.volume_ce)	(DECIMAL(18,0)) AS aantal

FROM MI_SAS_AA_MB_C_MB.cib_klantbeeld_klanten_NEW CIB

JOIN Mi_temp.Mia_klantkoppelingen KOP
ON CIB.klant_nr = KOP.klant_nr

JOIN (
	SELECT
		CE.*,
		CASE
			WHEN STF.debettrx=1 THEN 'debet'
			WHEN STF.credittrx=1 THEN 'credit'
			ELSE 'huh?'
		end AS trx_soort

	FROM mi_tb.wrk_ce CE

	JOIN ( SELECT TI , debettrx, credittrx FROM mi_tb.stf_gt WHERE debettrx + credittrx > 0 ) STF
	ON CE.TI_ID = STF.TI

	JOIN (
		SELECT billing_period , billing_period/100 AS jaar
		FROM mi_tb.wrk_ce X
		JOIN (SELECT MAX(billing_period) - 100*MAX(billing_period/100)  max_mnd FROM mi_tb.wrk_ce ) Y
		ON 1=1
		QUALIFY DENSE_RANK () OVER (ORDER BY jaar DESC) LE 3
		GROUP BY 1,2
	) PER
	ON CE.billing_period = PER.billing_period

) TB
ON KOP.business_contact_nr = TB.bc_id_owner

GROUP BY 1,2,3

) WITH DATA PRIMARY INDEX(klant_nr , maand_nr , trx_soort);

CREATE TABLE MI_SAS_AA_MB_C_MB.cib_klantbeeld_lnd_NEW AS (
	SELECT
		  K.Klant_nr
		, A.Hoofdrekening
		, A.Fac_bc_nr
		, A.contract_nr
		, RANK() OVER(PARTITION BY Klant_nr ORDER BY Limiet_type,Fac_product_oms DESC,oorspronk_verval_datum DESC,contract_nr) AS volgorde
		, A.Limiet_type
		, A.datum_ingang
		, A.oorspronk_verval_datum
		, A.Fac_Product_adm_oms
		, NULL AS Tot_Ticket
		, A.CLOSING_CR_LIMIT (DECIMAL(18,0)) AS AAB_Ticket
		, A.CLOSING_UTILIZATION_AMT (DECIMAL(18,0)) AS AAB_Drawn

		, A.datum_herziening_condities
		, A.syndicate_owned_perc (INTEGER) AS AAB_share

		, A.CLOSING_AVAILABLE_AMT
		, A.TOT_PRINCIPAL_AMT_OUTSTANDING

	FROM MI_SAS_AA_MB_C_MB.cib_klantbeeld_klanten_NEW K

) WITH DATA PRIMARY INDEX(klant_nr);

CREATE TABLE MI_SAS_AA_MB_C_MB.cib_klantbeeld_beurs_NEW AS (
SELECT
	XX.klant_nr
	, XX.verkorte_naam
	, XX.business_contact_nr
	, XX.kvk_nr

	, YY.fonds_naam
	, YY.fonds_waarde_sdat
	, YY.fonds_waarde_edat

	, CAL.year_of_calendar	AS jaar
	, CAL.month_of_year			AS maand
	, CAL.week_of_year + 1	AS week

	, YY.fonds_waarde
	, YY.fonds_waarde * Nbr_of_shares ( DECIMAL(12,0) ) AS MarketCap
	, F.Nbr_of_shares

FROM MI_SAS_AA_MB_C_MB.cib_klantbeeld_klanten_NEW XX

LEFT JOIN MI_SAS_AA_MB_C_MB.cib_klantbeeld_fondscode F
ON XX.Klant_nr = F.klant_nr

LEFT JOIN (
	SELECT A.* , B.fonds_asset_oms , C.fonds_sector_oms , D.Fonds_Type_Oms , X.fonds_waarde_sdat , X.fonds_waarde_edat , X.fonds_waarde

	FROM mi_vm_ldm.aFONDS A

	LEFT JOIN mi_vm_ldm.vFONDS_ASSET B
	ON A.fonds_asset_code = B.fonds_asset_code

	LEFT JOIN mi_vm_ldm.vFONDS_SECTOR C
	ON A.Fonds_Sector_Code = C.Fonds_Sector_Code

	LEFT JOIN mi_vm_ldm.vFONDS_type D
	ON A.Fonds_Type_Code = D.Fonds_Type_Code

	LEFT JOIN mi_vm_ldm.vFONDS_WAARDE X
	ON A.fonds_code = X.fonds_code

	WHERE 1=1
	AND x.fonds_waarde_sdat GE CURRENT_DATE - INTERVAL '01-01' YEAR TO MONTH
) YY
ON XX.fonds_code = YY.fonds_code

LEFT JOIN sys_calendar.CALENDAR CAL
ON YY.fonds_waarde_sdat = CAL.calendar_date

) WITH DATA PRIMARY INDEX(klant_nr , fonds_waarde_sdat);

CREATE TABLE MI_SAS_AA_MB_C_MB.cib_klantbeeld_gmb_NEW AS
(
SEL
B.klant_nr
, A.bc_nr
, A.maand_nr
, CASE
        WHEN A.product_group_code = 'FXO' THEN 'FX'
        WHEN A.product_group_code = 'MM Given' THEN 'Money Markets'
        WHEN A.product_group_code = 'MM Taken' THEN 'Money Markets'
        WHEN A.product_group_code = 'ECM' THEN 'ECM / DCM'
        WHEN A.product_group_code = 'DCM' THEN 'ECM / DCM'
        WHEN A.product_group_code = 'Credit Bonds' THEN 'Fixed Income'
        WHEN A.product_group_code = 'Credit Bonds Debt Issues' THEN 'Fixed Income'
        WHEN A.product_group_code = 'Government Bonds' THEN 'Fixed Income'
        ELSE A.product_group_code
        END AS Product_Group
, SUM(amount_EUR) AS Volume_EUR
, COUNT(*) AS Aantal_Trx

FROM mi_cmb.smr_transaction A

JOIN Mi_temp.Mia_klantkoppelingen B
ON A.bc_nr = B.business_contact_nr

LEFT JOIN mi_sas_aa_mb_c_mb.cib_klantbeeld_rep_gm_NEW C
ON 1=1

WHERE A.margin NE 0
AND A.bc_nr IS NOT NULL
AND A.product_group_code IN ('FX', 'FXO', 'IRD', 'MM Taken', 'MM Given', 'DCM', 'ECM', 'Credit Bonds', 'Credit Bonds Debt Issues', 'Government Bonds' , 'Securities Finance', 'Equity Brokerage' )
AND A.maand_nr > ROUND(C.max_maand_nr, -2) -200
AND A.maand_nr LE C.max_maand_nr
AND A.transaction_source NOT LIKE '%FXPM%'

GROUP BY 1,2,3,4

) WITH DATA
PRIMARY INDEX (klant_nr, bc_nr, maand_nr, product_group);

CREATE TABLE mi_temp.cib_klantbeeld_rep_gmo  AS (SELECT MAX(maand_nr) AS max_maand_nr FROM mi_sas_aa_mb_c_mb.cib_klantbeeld_gmo) WITH DATA;

CREATE TABLE mi_sas_aa_mb_c_mb.cib_klantbeeld_gmo_NEW AS mi_sas_aa_mb_c_mb.cib_klantbeeld_gmo WITH DATA
PRIMARY INDEX ( maand_nr ,Klant_nr ,bc_nr ,Product_Group );

INSERT INTO mi_sas_aa_mb_c_mb.cib_klantbeeld_gmo_NEW
SEL
A.maand_nr
, B.klant_nr
, A.bc_nr
, CASE
        WHEN A.product_group_code = 'FXO' THEN 'FX'
        WHEN A.product_group_code = 'MM Given' THEN 'Money Markets'
        WHEN A.product_group_code = 'MM Taken' THEN 'Money Markets'
        WHEN A.product_group_code = 'ECM' THEN 'ECM / DCM'
        WHEN A.product_group_code = 'DCM' THEN 'ECM / DCM'
        WHEN A.product_group_code = 'Credit Bonds' THEN 'Fixed Income'
        WHEN A.product_group_code = 'Credit Bonds Debt Issues' THEN 'Fixed Income'
        WHEN A.product_group_code = 'Government Bonds' THEN 'Fixed Income'
        ELSE A.product_group_code
        END AS Product_Group
, SUM(A.amount_EUR) AS Volume_EUR
, COUNT(*) AS Aantal_Trx

FROM mi_cmb.smr_transaction A

JOIN Mi_temp.Mia_klantkoppelingen B
ON A.bc_nr = B.business_contact_nr

LEFT JOIN mi_temp.cib_klantbeeld_rep_gmo C
ON 1=1

WHERE A.margin NE 0
AND A.bc_nr IS NOT NULL
AND A.product_group_code IN ('FX', 'FXO', 'IRD', 'MM Taken', 'MM Given', 'DCM', 'ECM', 'Credit Bonds', 'Credit Bonds Debt Issues', 'Government Bonds' , 'Securities Finance', 'Equity Brokerage' )
AND A.transaction_source NOT LIKE '%FXPM%'
AND A.start_date < (((ROUND(A.maand_nr, -2)/100)*10000 + (A.maand_nr - (ROUND(A.maand_nr, -2)/100)*100)*100 + 1) -19000000)
AND A.end_date > ((ROUND(A.maand_nr, -2)/100)*10000 + (A.maand_nr - (ROUND(A.maand_nr, -2)/100)*100)*100 + 31 -19000000)
AND A.maand_nr > C.max_maand_nr

GROUP BY 1,2,3,4;

CREATE TABLE mi_sas_aa_mb_c_mb.cib_klantbeeld_dpo_NEW AS
 (
SEL
A.maand_nr
, A.klant_nr
, A.productnaam
, B.naam_verkoopkans
, A.status
, CAST (A.slagingskans AS DECIMAL(3,0)) AS slagingskans
, A.baten_totaal_looptijd
, CAST( A.baten_totaal_Looptijd * slagingskans / 100 AS DECIMAL(22,0)) AS Revenues_Weighted
, datum_laatst_gewijzigd

FROM MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_Product_NEW A

LEFT JOIN MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_NEW B
ON A.maand_nr = B.maand_nr
AND A.Siebel_verkoopkans_id = B.Siebel_verkoopkans_id

LEFT JOIN	Mi_temp.Mia_week C
ON A.klant_nr = C.klant_nr

LEFT JOIN  mi_sas_aa_mb_c_mb.cib_klantbeeld_rep_dp_NEW D
ON 1=1

WHERE C.business_line = 'CIB'
AND A.omzet > 0
AND A.status  NOT LIKE 'Closed %'
AND A.maand_nr > D.max_maand_nr - 100

) WITH DATA
PRIMARY INDEX (maand_nr, klant_nr, productnaam, naam_verkoopkans, status);

CREATE TABLE mi_sas_aa_mb_c_mb.cib_klantbeeld_dpc_NEW AS
 (
SEL
A.maand_nr
, A.klant_nr
,  A.productnaam
, B.naam_verkoopkans
, A.status
, CAST (A.slagingskans AS DECIMAL(3,0)) AS slagingskans
, A.baten_totaal_looptijd
, CAST( A.baten_totaal_Looptijd * slagingskans / 100 AS DECIMAL(22,0)) AS Revenues_Weighted
, datum_laatst_gewijzigd

FROM MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_Product_NEW A

LEFT JOIN MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_NEW B
ON A.maand_nr = B.maand_nr
AND A.Siebel_verkoopkans_id = B.Siebel_verkoopkans_id

LEFT JOIN	Mi_temp.Mia_week C
ON A.klant_nr = C.klant_nr

LEFT JOIN  mi_sas_aa_mb_c_mb.cib_klantbeeld_rep_dp_NEW D
ON 1=1

WHERE C.business_line = 'CIB'
AND A.omzet > 0
AND A.status  LIKE 'Closed %'
AND A.maand_nr > D.max_maand_nr - 100

) WITH DATA
PRIMARY INDEX (maand_nr, klant_nr, productnaam, naam_verkoopkans, status);