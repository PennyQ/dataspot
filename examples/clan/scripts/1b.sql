#DATASPOT-TERADATA

INSERT INTO MI_TEMP.AACMB_Datum
VALUES
    (
  CURRENT_DATE
    );

CREATE TABLE MI_SAS_AA_MB_C_MB.Mia_periode  AS
 (
SELECT B.Maand_nr,
       D.Datum_gegevens,
       A.Maand  Maand_nr_laatste_finance,
       E.Maand_L12  Maand_begin_jaar_ervoor,
       A.Maand_L12  Maand_begin_jaar,
       A.Maand  Maand_einde_jaar,
       EXTRACT(YEAR FROM ADD_MONTHS(C.Maand_startdatum, -1))*100 + EXTRACT(MONTH FROM ADD_MONTHS(C.Maand_startdatum, -1))  Maand_nr_vm1,
       EXTRACT(YEAR FROM ADD_MONTHS(C.Maand_startdatum, -2))*100 + EXTRACT(MONTH FROM ADD_MONTHS(C.Maand_startdatum, -2))  Maand_nr_vm2,
       EXTRACT(YEAR FROM ADD_MONTHS(C.Maand_startdatum, -3))*100 + EXTRACT(MONTH FROM ADD_MONTHS(C.Maand_startdatum, -3))  Maand_nr_vm3,
       1  Lopende_maand_ind
  FROM Mi_vm_nzdb.vLu_maand A
  JOIN Mi_vm_nzdb.vLu_maand_runs B
    ON 1 = 1 AND B.Lopende_maand_ind = 1
  JOIN Mi_vm_nzdb.vLu_maand C
    ON B.Maand_nr = C.Maand
  JOIN (SELECT XA.Maand_nr,
               XA.CC_Samenvattings_datum-1  Datum_gegevens
          FROM Mi_vm_nzdb.vCommercieel_cluster XA
          JOIN Mi_vm_nzdb.vLU_Maand_Runs XX
            ON XA.Maand_nr = XX.Maand_nr AND XX.Lopende_maand_ind = 1
         GROUP BY 1, 2)  D
    ON B.Maand_nr = D.Maand_nr
  JOIN Mi_vm_nzdb.vLu_maand E
    ON A.Maand_L12 = E.Maand
 WHERE A.Maand IN (SELECT MAX(X.Maand_nr) FROM Mi_cmb.Producten X)
 ) WITH DATA
UNIQUE PRIMARY INDEX ( Maand_nr )
INDEX ( Maand_begin_jaar_ervoor )
INDEX ( Maand_begin_jaar )
INDEX ( Maand_einde_jaar );

CREATE TABLE Mi_temp.BC_bijzonder_beheer_ind AS
(
SELECT a.Bc_nr (INTEGER)  Bc_nr
       ,MAX(Ind_soort_bijz_beheer)  Ind_soort_bijz_beheer
FROM (
      SELECT MAX(CASE WHEN b.Bijzonder_beheer_type LIKE '%Lindorff%' THEN 1 ELSE 2 END)  Ind_soort_bijz_beheer
      FROM (SELECT
                 Master_faciliteit_ID
                ,Maand_nr
                ,MAX(Bijzonder_beheer_ind)  Ind_Bijzonder_beheer
                ,MAX(CASE WHEN ZEROIFNULL(OOE) <> 0 THEN 1 ELSE 0 END)  Ind_OOE
            FROM mi_cmb.vCIF_complex
            WHERE Fac_actief_ind = 1
              AND Maand_nr = (SELECT MAX(Maand_nr)  Maand_nr FROM mi_cmb.vCIF_complex)
            GROUP BY 1,2
            HAVING Ind_Bijzonder_beheer = 1 AND Ind_OOE = 1
           ) a
      INNER JOIN Mi_cmb.vCIF_Complex  b
         ON b.Maand_nr = a.Maand_nr
        AND b.Master_faciliteit_ID = a.Master_faciliteit_ID
        AND b.Fac_actief_ind = 1
      GROUP BY 1
      UNION
      INNER JOIN (SELECT Master_faciliteit_ID
		                ,Maand_nr
		                ,MAX(Bijzonder_beheer_ind)  Ind_Bijzonder_beheer
		                ,MAX(CASE WHEN ZEROIFNULL(OOE) <> 0 THEN 1 ELSE 0 END)  Ind_OOE
		            FROM mi_cmb.vCIF_complex
		            WHERE Fac_actief_ind = 1
		              AND Maand_nr = (SELECT MAX(Maand_nr)  Maand_nr FROM mi_cmb.vCIF_complex)
		            GROUP BY 1,2
		            HAVING Ind_Bijzonder_beheer = 1 AND Ind_OOE = 1) a
      INNER JOIN Mi_cmb.vCIF_Complex  b
         ON b.Maand_nr = a.Maand_nr
        AND b.Master_faciliteit_ID = a.Master_faciliteit_ID
        AND b.Fac_actief_ind = 1

      INNER JOIN mi_cmb.vcif_drawing c
         ON c.Master_faciliteit_id = b.Master_faciliteit_id
        AND c.Faciliteit_id = b.Faciliteit_id
        AND c.maand_nr = b.maand_nr
        AND c.draw_actief_ind = 1
      GROUP BY 1) a
GROUP BY 1
) WITH DATA
UNIQUE PRIMARY INDEX (Bc_nr);

INSERT INTO Mi_temp.Mia_bc_info
SELECT A.Gerelateerd_party_id  Klant_nr
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
  LEFT OUTER JOIN (SELECT A.Cbc_nr  Party_id
                     FROM Mi_vm_nzdb.vCommercieel_business_contact A
                     JOIN Mi_vm_nzdb.vLU_Maand_Runs XX
                       ON A.Maand_nr = XX.Maand_nr AND XX.Lopende_maand_ind = 1)  I
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
                          MAX(CASE WHEN XA.Party_deelnemer_rol = 1 THEN 1 ELSE NULL END)  Party_deelnemer_rol
                   FROM Mi_vm_ldm.aParty_party_relatie XA
                   WHERE XA.Party_sleutel_type = 'BC'
                     AND XA.Party_relatie_type_code = 'CBCTCE'
                 QUALIFY RANK() OVER (PARTITION BY XA.Party_id ORDER BY XA.Koppeling_id) = 1
                   GROUP BY 1,2)  M
    ON A.Party_id = M.Party_id
  LEFT OUTER JOIN (SELECT XA.Party_id,
                          XA.koppeling_id,
                          MAX(CASE WHEN XA.Party_deelnemer_rol = 1 THEN 1 ELSE NULL END)  Party_deelnemer_rol
                   FROM Mi_vm_ldm.aParty_party_relatie XA
                   WHERE XA.Party_sleutel_type = 'CC'
                     AND XA.Party_relatie_type_code = 'CCTCG'
                 QUALIFY RANK() OVER (PARTITION BY XA.Party_id ORDER BY XA.Koppeling_id) = 1
                   GROUP BY 1,2)  N
    ON A.Gerelateerd_party_id = N.Party_id
  LEFT OUTER JOIN  (SELECT party_id, 1  xref_ind
               FROM mi_vm_NZDB.vGBC_CROSSREF
               WHERE maand_nr = (SELECT maand_nr FROM MI_SAS_AA_MB_C_MB.Mia_periode )
               AND xref_herkomst IN ('BCTT24','BCTSAB','BCTLCA','BCTCF2','BCTCF3','BCTCF4','BCTCF5')
               AND party_sleutel_type = 'BC'
               GROUP BY 1,2) O
    ON A.Party_id = O.party_id
   LEFT OUTER JOIN (SELECT bc_nr, MAX(
                    CASE WHEN product_group_code = 'FXO' AND ZEROIFNULL(margin) <> 0 THEN 1
                    WHEN product_group_code <> 'FXO' AND product_group_code IS NOT NULL THEN 1
                    ELSE 0 END)  CMS_ind
                FROM mi_cmb.smr_transaction
                WHERE maand_nr BETWEEN  (SELECT maand_nr -100 FROM MI_SAS_AA_MB_C_MB.Mia_periode ) AND (SELECT maand_nr FROM MI_SAS_AA_MB_C_MB.Mia_periode )
                AND product_group_code IN ('MM Taken','FXO','FX','MM Given','IRD') -- voor deze producten is de  data gevalideerd, later aan te vullen met overige productgroepen uit de SMR transaction tabel

                GROUP BY 1) P
    ON A.Party_id = P.bc_nr
  LEFT JOIN
        (SELECT  Party_id
        ,CASE WHEN LENGTH(TRIM(Party_GSRI_goedgekeurd)) = 0 THEN NULL
                        ELSE TRIM(Party_GSRI_goedgekeurd) END  GSRI_Goedgekeurd
        ,CASE WHEN GSRI_Goedgekeurd = 'HIGH' THEN 1
              WHEN GSRI_Goedgekeurd = 'MEDIUM' THEN 2
              WHEN GSRI_Goedgekeurd = 'LOW' THEN 3
              END  GSRI_goedgekeurd_lvl
        ,CASE WHEN LENGTH(TRIM(Party_Assessment_resultaat)) = 0 THEN NULL
                        ELSE TRIM(Party_Assessment_resultaat) END  GSRI_Assessment_resultaat
        ,CASE WHEN GSRI_Assessment_resultaat = 'ABOVE PAR' THEN 1
              WHEN GSRI_Assessment_resultaat = 'ON PAR' THEN 2
              WHEN GSRI_Assessment_resultaat = 'BELOW PAR' THEN 3
              END  GSRI_Assessment_resultaat_lvl
        FROM MI_VM_LDM.aparty_gsri
     QUALIFY RANK() OVER (PARTITION BY Party_id ORDER BY Party_gsri_SDAT DESC, Gsri_expiratie_datum DESC) = 1) Q
    ON A.Party_id = Q.Party_id
 WHERE A.Party_sleutel_type = 'bc'
   AND A.Party_relatie_type_code = 'CBCTCC'
QUALIFY RANK() OVER (PARTITION BY A.Party_id ORDER BY A.Party_party_relatie_sdat DESC, A.Koppeling_id) = 1;

INSERT INTO Mi_temp.Mia_klant_info
SELECT A.Cc_nr  Klant_nr,
       XX.Maand_nr  Maand_nr,
       XX.Datum_gegevens  Datum_gegevens,
       A.Cc_client_groep_code  Clientgroep,
       E.Business_line,
       CASE
       WHEN E.business_line <> 'CIB' AND C.Mkb_klant_ind = 1 THEN 'C'
       WHEN Max_valniveau IN (1, 2) THEN 'S'
       WHEN Max_valniveau IN (3, 4) THEN 'C'
       ELSE NULL
       END  Klantstatus,
       CASE WHEN E.business_line <> 'CIB' THEN ZEROIFNULL(C.Mkb_klant_ind)
       ELSE (CASE WHEN b.Xref_ind = 1 OR b.CMS_ind = 1 OR C.Mkb_klant_ind = 1 THEN 1 ELSE 0 END) END  Klant_ind,
       B.Aantal_bcs,
       B.Aantal_bcs_in_scope,
       CASE WHEN B.Solveon_ind + B.FRenR_ind > 0 THEN 1 ELSE 0 END  Bijzonder_beheer_ind,
       B.Surseance_ind,
       B.Faillissement_ind,
       B.GSRI_goedgekeurd_lvl,
       B.GSRI_Assessment_resultaat_lvl,
       B.Leidend_bc_ind,
       A.Leidend_cbc_oid  Leidend_bc_nr,
       D.Cca
  FROM Mi_vm_nzdb.vCommercieel_cluster A
  JOIN MI_SAS_AA_MB_C_MB.Mia_periode  XX
    ON A.Maand_nr = XX.Maand_nr AND XX.Lopende_maand_ind = 1
  JOIN (SELECT XA.Klant_nr,
               MAX(XA.Validatieniveau)  Max_valniveau,
               COUNT(*)  Aantal_bcs,
               SUM(XA.In_nzdb)  Aantal_bcs_in_scope,
               MAX(XA.Solveon_ind)  Solveon_ind,
               MAX(XA.FRenR_ind)  FRenR_ind,
               MAX(XA.Surseance_ind)  Surseance_ind,
               MAX(XA.Faillissement_ind)  Faillissement_ind,
               MAX(XA.Leidend_bc_ind)  Leidend_bc_ind,
               MAX(XA.Xref_ind)  Xref_ind,
               MAX(XA.CMS_ind)  CMS_ind,
          MAX(GSRI_goedgekeurd_lvl)  GSRI_goedgekeurd_lvl,
          MAX(GSRI_Assessment_resultaat_lvl)  GSRI_Assessment_resultaat_lvl
          FROM Mi_temp.Mia_bc_info XA
         GROUP BY 1)  B
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
       END  Volgorde
  FROM Mi_temp.Mia_klant_info A
  LEFT OUTER JOIN Mi_temp.Mia_bc_info B
    ON A.Klant_nr = B.Klant_nr
   AND B.In_nzdb = 1
 GROUP BY 1, 2;

INSERT INTO Mi_temp.Mia_groepkoppelingen
SELECT
 A.Gerelateerd_party_id  Groep_nr
,B.Maand_nr
,B.Klant_nr
,ZEROIFNULL(A.Party_deelnemer_rol)  Leidende_klant_ind
,C.Koppeling_id_CC
,A.koppeling_id  Koppeling_id_CG
FROM (SELECT XA.Party_id,
             XA.Gerelateerd_party_id,
             XA.koppeling_id,
              MAX(CASE WHEN XA.Party_deelnemer_rol = 1 THEN 1 ELSE NULL END)  Party_deelnemer_rol
       FROM Mi_vm_ldm.aParty_party_relatie XA
       WHERE XA.Party_sleutel_type = 'CC'
         AND XA.Party_relatie_type_code = 'CCTCG'
         AND XA.Gerelateerd_party_id IS NOT NULL
     QUALIFY RANK() OVER (PARTITION BY XA.Party_id ORDER BY XA.Koppeling_id) = 1
     GROUP BY 1,2,3)  A
INNER JOIN Mi_temp.Mia_klant_info B
ON A.Party_id = B.Klant_nr
LEFT OUTER JOIN Mi_temp.Mia_bc_info C
ON A.Party_id = C.Klant_nr
AND C.In_nzdb = 1
AND C.Leidend_bc_ind = 1;

INSERT INTO Mi_temp.Mia_alle_bcs
SELECT X.Party_id  Business_contact_nr
  FROM Mi_vm_ldm.aParty X
  LEFT OUTER JOIN (SELECT XA.Party_id,
                          XA.Party_sleutel_type,
                          MAX(CASE WHEN XA.Party_relatie_type_code = 'CBCTCC' THEN XA.Gerelateerd_party_id END)  Cc_nr,
                          MAX(CASE WHEN XA.Party_relatie_type_code = 'LIDFHH' THEN XA.Gerelateerd_party_id END)  Fhh_nr,
                          MAX(CASE WHEN XA.Party_relatie_type_code = 'LDPCNL' THEN XA.Gerelateerd_party_id END)  Pcnl_nr
                     FROM Mi_vm_ldm.aParty_party_relatie XA
                    WHERE XA.Party_sleutel_type = 'bc'
                      AND XA.Party_relatie_type_code IN ('CBCTCC', 'LIDFHH', 'LDPCNL')
                    GROUP BY 1, 2)  A
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
  LEFT OUTER JOIN (SELECT XA.Cbc_nr  Party_id
                     FROM Mi_vm_nzdb.vCommercieel_business_contact XA
                     JOIN Mi_vm_nzdb.vLU_Maand_Runs XX
                       ON XA.Maand_nr = XX.Maand_nr AND XX.Lopende_maand_ind = 1)  I
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
                          COUNT(*)  Aantal_rekeningen
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
                    GROUP BY 1)  O
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
                          MAX(CASE WHEN XA.Party_deelnemer_rol = 1 THEN 1 ELSE NULL END)  Party_deelnemer_rol
                     FROM Mi_vm_ldm.aParty_party_relatie XA
                    WHERE XA.Party_sleutel_type = 'BC'
                      AND XA.Party_relatie_type_code = 'CBCTCC'
                  QUALIFY RANK() OVER (PARTITION BY XA.Party_id ORDER BY XA.Koppeling_id) = 1
                    GROUP BY 1,2
                  )  T
  ON X.Party_id = T.Party_id
  LEFT OUTER JOIN (SELECT XA.Party_id,
                          XA.koppeling_id,
                          MAX(CASE WHEN XA.Party_deelnemer_rol = 1 THEN 1 ELSE NULL END)  Party_deelnemer_rol
                   FROM Mi_vm_ldm.aParty_party_relatie XA
                   WHERE XA.Party_sleutel_type = 'BC'
                     AND XA.Party_relatie_type_code = 'CBCTCE'
                 QUALIFY RANK() OVER (PARTITION BY XA.Party_id ORDER BY XA.Koppeling_id) = 1
                   GROUP BY 1,2)  Y
  ON X.Party_id = Y.Party_id
 LEFT OUTER JOIN (SELECT XA.Party_id,
                          XA.koppeling_id,
                          MAX(CASE WHEN XA.Party_deelnemer_rol = 1 THEN 1 ELSE NULL END)  Party_deelnemer_rol
                   FROM Mi_vm_ldm.aParty_party_relatie XA
                   WHERE XA.Party_sleutel_type = 'CC'
                     AND XA.Party_relatie_type_code = 'CCTCG'
                 QUALIFY RANK() OVER (PARTITION BY XA.Party_id ORDER BY XA.Koppeling_id) = 1
                   GROUP BY 1,2)  Z
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
        ,CASE WHEN LENGTH(TRIM(Party_GSRI_goedgekeurd)) = 0 THEN NULL ELSE TRIM(Party_GSRI_goedgekeurd) END  BC_GSRI_Goedgekeurd
        ,CASE WHEN LENGTH(TRIM(Party_Assessment_resultaat)) = 0 THEN NULL ELSE TRIM(Party_Assessment_resultaat) END  BC_GSRI_Assessment_resultaat
        FROM MI_VM_LDM.aparty_gsri
       QUALIFY RANK() OVER (PARTITION BY Party_id ORDER BY Party_gsri_SDAT DESC, Gsri_expiratie_datum DESC) = 1) AH
    ON X.Party_id = AH.Party_id
   AND x.Party_sleutel_type = 'BC'
  LEFT OUTER JOIN (SELECT a.party_id, a.GBC_nr, b.GBC_naam, c.ULP_BC_nr, d.ULP_naam
                   FROM (SELECT XA.Party_id, XA.gerelateerd_party_id  GBC_nr
                     FROM Mi_vm_ldm.aParty_party_relatie XA
                     WHERE XA.Party_sleutel_type = 'BC'
                     AND XA.Party_relatie_type_code = 'CBCGBC'
                     GROUP BY 1,2 ) A
                  LEFT OUTER JOIN
                    (SELECT party_id, TRIM(Naamregel_1)||TRIM(Naamregel_2)||TRIM(Naamregel_3)  GBC_naam
                    FROM Mi_vm_ldm.aParty_naam
                    WHERE Party_sleutel_type = 'BC') B
                  ON A.GBC_nr = B.party_id
                  LEFT OUTER JOIN
                    (SELECT  XA.Party_id, XA.gerelateerd_party_id  ULP_BC_nr
                     FROM Mi_vm_ldm.aParty_party_relatie XA
                     WHERE XA.Party_relatie_type_code = 'GBCUP'
                     AND Party_sleutel_type = 'GB'
                     GROUP BY 1,2) C
                  ON A.GBC_nr = C.party_id
                  LEFT OUTER JOIN
                    (SELECT party_id, TRIM(Naamregel_1)||TRIM(Naamregel_2)||TRIM(Naamregel_3)  ULP_naam
                     FROM Mi_vm_ldm.aParty_naam
                     WHERE Party_sleutel_type = 'BC') D
                  ON C.ULP_BC_nr = D.PARTY_ID) AI
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
  LEFT OUTER JOIN (SELECT XA.Party_id  Business_contact_nr,
                                  XA.Gerelateerd_party_id  CCA
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
        R.Gerelateerd_party_id  Trust_complex_nr
        FROM MI_VM_LDM.aPARTY_PARTY_RELATIE R
        WHERE   R.party_relatie_type_code  = 'DVNTTK')  TR
   ON TR.party_id = X.Party_id
   LEFT JOIN (SELECT  R.party_id,
        R.Gerelateerd_party_id  Franchise_complex_nr
        FROM MI_VM_LDM.aPARTY_PARTY_RELATIE R
        WHERE   R.party_relatie_type_code = 'FRNCSE')  FR
   ON FR.party_id = X.Party_id
LEFT OUTER JOIN (SELECT XA.Party_id,
                          XA.Party_sleutel_type,
                          XA.Party_relatie_type_code,
                          XA.Gerelateerd_party_id  Gerelateerd_party_id
                     FROM Mi_vm_ldm.aParty_party_relatie XA
                     WHERE XA.Party_relatie_type_code = 'PRVBNK'
                    GROUP BY 1,2,3
                  QUALIFY RANK (XA.Party_party_relatie_sdat DESC) = 1)  AO
    ON X.Party_id = AO.Party_id
   AND X.Party_sleutel_type = AO.Party_sleutel_type
  LEFT OUTER JOIN (
                   SELECT XA.Party_id,
                          XA.koppeling_id,
                          MAX(CASE WHEN XA.Party_deelnemer_rol = 1 THEN 1 ELSE NULL END)  Party_deelnemer_rol
                     FROM Mi_vm_ldm.aParty_party_relatie XA
                    WHERE XA.Party_sleutel_type = 'BC'
                      AND XA.Party_relatie_type_code = 'LDPCNL'
                  QUALIFY RANK() OVER (PARTITION BY XA.Party_id ORDER BY XA.Koppeling_id) = 1
                    GROUP BY 1,2
                  )  AP
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
  JOIN MI_SAS_AA_MB_C_MB.Mia_periode  X
    ON A.Maand_nr >= X.Maand_begin_jaar_ervoor AND A.Maand_nr <= X.Maand_einde_jaar;

INSERT INTO Mi_temp.Mia_baten_detail
SELECT A.Klant_nr,
       A.Maand_nr,
       D.CUBe_product_id,
       E.Maand_nr  Baten_maand,
       F.Volgorde,
       G.Maand_SDAT  Datum_baten,
       SUM(E.Baten)  Baten_totaal
  FROM Mi_temp.Mia_klant_info A
  JOIN MI_SAS_AA_MB_C_MB.CUBe_productdetail B
    ON 1 = 1
  JOIN Mi_temp.Mia_klantkoppelingen C
    ON A.Klant_nr = C.Klant_nr AND A.Maand_nr = C.Maand_nr
  JOIN MI_SAS_AA_MB_C_MB.CUBe_productdetail D
    ON B.CUBe_product_id = D.CUBe_product_id
  JOIN MI_SAS_AA_MB_C_MB.Mia_periode  X
    ON A.Maand_nr = X.Maand_nr
  JOIN Mi_temp.Mia_baten_product E
    ON C.Business_contact_nr = E.Party_id AND E.Combiproductlevel = B.Productlevel2code AND E.Combiproductlevel = D.Productlevel2code
   AND E.Maand_nr > X.Maand_begin_jaar_ervoor AND E.Maand_nr <= X.Maand_einde_jaar
  LEFT OUTER JOIN (SELECT Maand  Maand_nr,
                          RANK(Maand DESC)  Volgorde
                     FROM Mi_vm.vLu_maand A
                     JOIN MI_SAS_AA_MB_C_MB.Mia_periode  B
                       ON A.Maand > B.Maand_begin_jaar_ervoor AND A.Maand <= B.Maand_einde_jaar)  F
    ON E.Maand_nr = F.Maand_nr
  LEFT OUTER JOIN Mi_vm.vLu_maand G
    ON E.Maand_nr = G.Maand
 GROUP BY 1, 2, 3, 4, 5, 6;

INSERT INTO Mi_temp.Mia_baten
SELECT A.Klant_nr,
       A.Maand_nr,
       B.CUBe_product_id,
       SUM(CASE WHEN C.Volgorde >= 13 THEN 0.00 ELSE ZEROIFNULL(C.Baten_totaal) END)  Baten,
       SUM(CASE WHEN C.Volgorde <= 12 THEN 0.00 ELSE ZEROIFNULL(C.Baten_totaal) END)  Baten_ervoor,
       SUM(CASE WHEN C.Volgorde = 24 THEN C.Baten_totaal ELSE 0 END)  Baten_mnd24,
       SUM(CASE WHEN C.Volgorde = 23 THEN C.Baten_totaal ELSE 0 END)  Baten_mnd23,
       SUM(CASE WHEN C.Volgorde = 22 THEN C.Baten_totaal ELSE 0 END)  Baten_mnd22,
       SUM(CASE WHEN C.Volgorde = 21 THEN C.Baten_totaal ELSE 0 END)  Baten_mnd21,
       SUM(CASE WHEN C.Volgorde = 20 THEN C.Baten_totaal ELSE 0 END)  Baten_mnd20,
       SUM(CASE WHEN C.Volgorde = 19 THEN C.Baten_totaal ELSE 0 END)  Baten_mnd19,
       SUM(CASE WHEN C.Volgorde = 18 THEN C.Baten_totaal ELSE 0 END)  Baten_mnd18,
       SUM(CASE WHEN C.Volgorde = 17 THEN C.Baten_totaal ELSE 0 END)  Baten_mnd17,
       SUM(CASE WHEN C.Volgorde = 16 THEN C.Baten_totaal ELSE 0 END)  Baten_mnd16,
       SUM(CASE WHEN C.Volgorde = 15 THEN C.Baten_totaal ELSE 0 END)  Baten_mnd15,
       SUM(CASE WHEN C.Volgorde = 14 THEN C.Baten_totaal ELSE 0 END)  Baten_mnd14,
       SUM(CASE WHEN C.Volgorde = 13 THEN C.Baten_totaal ELSE 0 END)  Baten_mnd13,
       SUM(CASE WHEN C.Volgorde = 12 THEN C.Baten_totaal ELSE 0 END)  Baten_mnd12,
       SUM(CASE WHEN C.Volgorde = 11 THEN C.Baten_totaal ELSE 0 END)  Baten_mnd11,
       SUM(CASE WHEN C.Volgorde = 10 THEN C.Baten_totaal ELSE 0 END)  Baten_mnd10,
       SUM(CASE WHEN C.Volgorde =  9 THEN C.Baten_totaal ELSE 0 END)  Baten_mnd09,
       SUM(CASE WHEN C.Volgorde =  8 THEN C.Baten_totaal ELSE 0 END)  Baten_mnd08,
       SUM(CASE WHEN C.Volgorde =  7 THEN C.Baten_totaal ELSE 0 END)  Baten_mnd07,
       SUM(CASE WHEN C.Volgorde =  6 THEN C.Baten_totaal ELSE 0 END)  Baten_mnd06,
       SUM(CASE WHEN C.Volgorde =  5 THEN C.Baten_totaal ELSE 0 END)  Baten_mnd05,
       SUM(CASE WHEN C.Volgorde =  4 THEN C.Baten_totaal ELSE 0 END)  Baten_mnd04,
       SUM(CASE WHEN C.Volgorde =  3 THEN C.Baten_totaal ELSE 0 END)  Baten_mnd03,
       SUM(CASE WHEN C.Volgorde =  2 THEN C.Baten_totaal ELSE 0 END)  Baten_mnd02,
       SUM(CASE WHEN C.Volgorde =  1 THEN C.Baten_totaal ELSE 0 END)  Baten_mnd01
  FROM Mi_temp.Mia_klant_info A
  JOIN MI_SAS_AA_MB_C_MB.CUBe_producten B
    ON 1 = 1
  LEFT OUTER JOIN Mi_temp.Mia_baten_detail C
    ON A.Klant_nr = C.Klant_nr AND B.CUBe_product_id = C.CUBe_product_id
 GROUP BY 1, 2, 3;

INSERT INTO Mi_temp.Mia_klantbaten
SELECT A.Klant_nr,
       A.Maand_nr,
       SUM(A.Baten)  BatenX,
       SUM(A.Baten_jaar_ervoor)  Baten_jaar_ervoor,
       SUM(A.Baten_mnd24)  Baten_mnd24X,
       SUM(A.Baten_mnd23)  Baten_mnd23X,
       SUM(A.Baten_mnd22)  Baten_mnd22X,
       SUM(A.Baten_mnd21)  Baten_mnd21X,
       SUM(A.Baten_mnd20)  Baten_mnd20X,
       SUM(A.Baten_mnd19)  Baten_mnd19X,
       SUM(A.Baten_mnd18)  Baten_mnd18X,
       SUM(A.Baten_mnd17)  Baten_mnd17X,
       SUM(A.Baten_mnd16)  Baten_mnd16X,
       SUM(A.Baten_mnd15)  Baten_mnd15X,
       SUM(A.Baten_mnd14)  Baten_mnd14X,
       SUM(A.Baten_mnd13)  Baten_mnd13X,
       SUM(A.Baten_mnd12)  Baten_mnd12X,
       SUM(A.Baten_mnd11)  Baten_mnd11X,
       SUM(A.Baten_mnd10)  Baten_mnd10X,
       SUM(A.Baten_mnd09)  Baten_mnd09X,
       SUM(A.Baten_mnd08)  Baten_mnd08X,
       SUM(A.Baten_mnd07)  Baten_mnd07X,
       SUM(A.Baten_mnd06)  Baten_mnd06X,
       SUM(A.Baten_mnd05)  Baten_mnd05X,
       SUM(A.Baten_mnd04)  Baten_mnd04X,
       SUM(A.Baten_mnd03)  Baten_mnd03X,
       SUM(A.Baten_mnd02)  Baten_mnd02X,
       SUM(A.Baten_mnd01)  Baten_mnd01X,
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
       END  N_maanden_baten,
       BatenX*(12.0000/N_maanden_baten)  Baten_gecorrigeerd
  FROM Mi_temp.Mia_baten A
 GROUP BY 1, 2;

CREATE TABLE Mi_temp.Complex_prod_GKDB_12mnd AS
(SELECT
      a.Party_id                                        BC_nr
     ,b.Code_complex_product
     ,'GKDB - ' || TRIM(BOTH FROM b.Product_naam) (VARCHAR(40))  Product_naam
     ,SUM(ZEROIFNULL(a.Baten))                        Baten
     ,SUM(ZEROIFNULL(a.Baten_12mnd))                  Baten_12mnd
     ,a.Maand_nr                                      Maand_baten
FROM mi_cmb.baten_product_12mnd a
INNER JOIN (SELECT  combiproductlevel
                   ,Code_complex_product
                   ,MAX(ProductLevel2Description)  Product_naam
            FROM MI_SAS_AA_MB_C_MB.LU_Complexe_producten
            GROUP BY 1,2
           ) b
   ON a.combiproductlevel = b.combiproductlevel
WHERE a.Party_sleutel_type = 'BC'
  AND a.Maand_nr = (SELECT MAX(Maand_nr) FROM mi_cmb.baten_product_12mnd)
  AND (ZEROIFNULL(a.Baten_12mnd) (DECIMAL(18,2)) ) <> 0                /* baten zijn in FLOAT, hele kleine bedragen er tussen */
GROUP BY 1,2,3,6
) WITH DATA PRIMARY INDEX(BC_nr);

CREATE TABLE Mi_temp.Complex_prod_MIND AS
(SELECT   b.Party_id  BC_nr
     ,CASE
          WHEN a.Product_id = 1602          THEN 'E'
        END  Code_complex_product
     ,CASE
          WHEN a.Product_id = 1602          THEN c.Product_naam_extern /*AOL*/
        END (VARCHAR(40))  Product_naam
     ,COUNT(DISTINCT a.Contract_nr)  N_contracten
     ,MAX(a.Contract_nr)             MAX_contract_nr
FROM Mi_vm_ldm.aContract
INNER JOIN Mi_vm_ldm.aParty_contract
   ON b.Contract_nr = a.Contract_nr
  AND b.contract_soort_code = a.contract_soort_code
  AND b.contract_hergebruik_volgnr = a.contract_hergebruik_volgnr
  AND b.Party_sleutel_type = 'BC'
  AND b.Party_contract_rol_code = 'C'
LEFT OUTER JOIN mi_vm_ldm.aProduct
   ON c.product_id = a.Product_id
WHERE a.contract_status_code <> 3
  AND a.Product_id IN (1602)
GROUP BY 1,2,3
) WITH DATA
PRIMARY INDEX(BC_nr);

CREATE TABLE Mi_temp.Complex_GRV102030 AS
(SELECT   b.Party_id  BC_nr
     ,'J'         Code_complex_product
     ,CASE
          WHEN a.Herkomst_admin_key_soort_code = 'GRV' AND TRIM(a.Herkomst_administratie_key) = '10' THEN 'GRV 010'
        END (VARCHAR(40))  Product_naam
     ,NULL  Ind_krediet
     ,COUNT(DISTINCT a.Contract_nr)  N_contracten
     ,MAX(a.Contract_nr)             MAX_contract_nr
FROM Mi_vm_ldm.aContract
INNER JOIN Mi_vm_ldm.aParty_contract
   ON b.Contract_nr = a.Contract_nr
  AND b.contract_soort_code = a.contract_soort_code
  AND b.contract_hergebruik_volgnr = a.contract_hergebruik_volgnr
  AND b.Party_sleutel_type = 'BC'
  AND b.Party_contract_rol_code = 'C'
WHERE a.contract_status_code <> 3
  AND a.Herkomst_admin_key_soort_code = 'GRV'
  AND TRIM(a.Herkomst_administratie_key) = '10'        /* particulier RC altijd als complex beschouwen */
GROUP BY 1,2,3
) WITH DATA PRIMARY INDEX(BC_nr);

CREATE TABLE Mi_temp.Complex_prod_KredAS
(SELECT
      TO_NUMBER(a.Fac_BC_nr)  (INTEGER)              BC_nr
     ,'B'                                            Code_complex_product
     ,'Maatwerk Krediet'              (VARCHAR(40))  Product_naam
     ,COUNT(DISTINCT a.Fac_Contract_nr)              N_contracten
     ,MAX(TO_NUMBER(a.Fac_Contract_nr) (INTEGER))    MAX_contract_nr
     ,a.Maand_nr                                     Maand_Kredieten
FROM Mi_cmb.vCIF_complex a
WHERE a.Fac_actief_ind = 1
  AND NOT a.Fac_BC_nr IS NULL
  AND NOT a.Fac_Contract_nr IS NULL
  AND SUBSTR(TRIM(PL_NPL_type),1,3) = 'NPL'
  AND ZEROIFNULL(OOE) > 0
  AND a.Maand_nr = (SELECT MAX(Maand_nr)  Maand_nr FROM Mi_cmb.vCIF_complex)
GROUP BY 1,2,3,6
) WITH DATA PRIMARY INDEX(BC_nr);

CREATE TABLE Mi_temp.Complex_prod_beleggen AS
(SELECT
      a.cBC_nr                                       BC_nr
     ,'L'                                            Code_complex_product
     ,'Beleggen met advies'           (VARCHAR(40))  Product_naam
     ,COUNT(DISTINCT a.Contract_nr)                  N_contracten
     ,MAX(a.Contract_nr)                             MAX_contract_nr
FROM mi_vm_nzdb.vEff_Contract_Feiten_Periode   a
WHERE NOT a.Service_concept_naam LIKE '%ZELF%'
  AND NOT a.Service_concept_naam = 'EXECUTION ONLY'
  AND a.Maand_nr = (SELECT MAX(Maand_nr)  Maand_nr FROM mi_vm_nzdb.vEff_Contract_Feiten_Periode)
  AND a.Standaard_contract_ind = 1
GROUP BY 1,2,3
) WITH DATA PRIMARY INDEX(BC_nr);

INSERT INTO Mi_temp.CIAA_TRC_REK_COURANT
SELECT
       0
      ,Maand_nr
      ,Contract_nr
      ,Ind_EURIBOR_rente
      ,Ind_rentecompensatie
FROM MI_SAS_AA_MB_C_MB.CIAA_TRC_REK_COURANT;

CREATE TABLE Mi_temp.Complex_prod_RC
AS (SELECT
      b.Party_id                                      BC_nr
     ,'H'                                            Code_complex_product
     ,'RC EURIBOR rente'              (VARCHAR(40))  Product_naam
     ,COUNT(DISTINCT a.Contract_nr)                  N_contracten
     ,MAX(a.Contract_nr)                             MAX_contract_nr
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
) WITH DATA PRIMARY INDEX(BC_nr);

INSERT INTO Mi_temp.Complex_prod_RC
SELECT b.Party_id                                      BC_nr
     ,'F'                                            Code_complex_product
     ,'RC rentecompensatie'           (VARCHAR(40))  Product_naam
     ,COUNT(DISTINCT a.Contract_nr)                  N_contracten
     ,MAX(a.Contract_nr)                             MAX_contract_nr
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
GROUP BY 1,2,3;

CREATE TABLE Mi_temp.Complex_prod_RC_mtwrk AS
(SELECT BC_number                         BC_nr
	     ,'I'                                                    Code_complex_product
	     ,'Maatwerk tarifering betalingsverkeer'  (VARCHAR(40))  Product_naam

FROM Mi_cmb.Tb_offers
LEFT OUTER JOIN  mi_cmb.pvdv_offer_oms
ON A.offer_code = B.offer_code
WHERE COALESCE (offer_oms, 'x') NOT LIKE 'PIN-in-1%'
GROUP BY 1,2,3
) WITH DATA PRIMARY INDEX(BC_nr);

CREATE TABLE Mi_temp.Complex_product AS
(SELECT  a.Klant_nr
    ,a.Maand_nr
    ,b.BC_nr
    ,b.Code_complex_product (CHAR(1))  Code_complex_product
    ,b.Product_naam   (CHAR(30))  Product_naam
FROM Mi_temp.Mia_klantkoppelingen
INNER JOIN Mi_temp.Complex_prod_GKDB_12mnd
  ON b.BC_nr = a.Business_Contact_nr
GROUP BY 1,2,3,4,5
) WITH DATA PRIMARY INDEX (Klant_nr, Maand_nr);

INSERT INTO Mi_temp.Complex_product
SELECT  a.Klant_nr
    ,a.Maand_nr
    ,b.BC_nr
    ,b.Code_complex_product (CHAR(1))  Code_complex_product
    ,b.Product_naam
FROM Mi_temp.Mia_klantkoppelingen
INNER JOIN Mi_temp.Complex_prod_MIND
  ON b.BC_nr = a.Business_Contact_nr
GROUP BY 1,2,3,4,5;

INSERT INTO Mi_temp.Complex_product
SELECT  a.Klant_nr
    ,a.Maand_nr
    ,b.BC_nr
    ,b.Code_complex_product (CHAR(1))  Code_complex_product
    ,b.Product_naam
FROM Mi_temp.Mia_klantkoppelingen
INNER JOIN Mi_temp.Complex_GRV102030
  ON b.BC_nr = a.Business_Contact_nr
GROUP BY 1,2,3,4,5;

INSERT INTO Mi_temp.Complex_product
SELECT  a.Klant_nr
    ,a.Maand_nr
    ,b.BC_nr
    ,b.Code_complex_product (CHAR(1))
    ,b.Product_naam
FROM Mi_temp.Mia_klantkoppelingen
INNER JOIN Mi_temp.Complex_prod_Kred
  ON b.BC_nr = a.Business_Contact_nr
GROUP BY 1,2,3,4,5;

INSERT INTO Mi_temp.Complex_product
SELECT  a.Klant_nr
    ,a.Maand_nr
    ,b.BC_nr
    ,b.Code_complex_product (CHAR(1))
    ,b.Product_naam
FROM Mi_temp.Mia_klantkoppelingen
INNER JOIN Mi_temp.Complex_prod_RC
  ON b.BC_nr = a.Business_Contact_nr
GROUP BY 1,2,3,4,5;

INSERT INTO Mi_temp.Complex_product
SELECT a.Klant_nr
    ,a.Maand_nr
    ,b.BC_nr
    ,b.Code_complex_product (CHAR(1))
    ,b.Product_naam
FROM Mi_temp.Mia_klantkoppelingen a
INNER JOIN Mi_temp.Complex_prod_beleggen b
  ON b.BC_nr = a.Business_Contact_nr
GROUP BY 1,2,3,4,5;

INSERT INTO Mi_temp.Complex_product
SELECT  a.Klant_nr
    ,a.Maand_nr
    ,b.BC_nr
    ,b.Code_complex_product (CHAR(1))
    ,b.Product_naam
FROM Mi_temp.Mia_klantkoppelingen a
INNER JOIN Mi_temp.Complex_prod_RC_mtwrk b
  ON b.BC_nr = a.Business_Contact_nr
GROUP BY 1,2,3,4,5;

INSERT INTO Mi_temp.Complexe_producten
SELECT a.Klant_nr
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
      TRIM(BOTH FROM a.Code_9)  Complexe_producten
     ,a.Aantal_complexe_producten
FROM (SELECT
           a.Klant_nr
          ,a.Maand_nr
          ,MAX(CASE WHEN a.Code_complex_product = 'A' THEN a.Code_complex_product ELSE '' END)  Code_A
          ,MAX(CASE WHEN a.Code_complex_product = 'B' THEN a.Code_complex_product ELSE '' END)  Code_B
          ,MAX(CASE WHEN a.Code_complex_product = 'C' THEN a.Code_complex_product ELSE '' END)  Code_C
          ,MAX(CASE WHEN a.Code_complex_product = 'D' THEN a.Code_complex_product ELSE '' END)  Code_D
          ,MAX(CASE WHEN a.Code_complex_product = 'E' THEN a.Code_complex_product ELSE '' END)  Code_E
          ,MAX(CASE WHEN a.Code_complex_product = 'F' THEN a.Code_complex_product ELSE '' END)  Code_F
          ,MAX(CASE WHEN a.Code_complex_product = 'G' THEN a.Code_complex_product ELSE '' END)  Code_G
          ,MAX(CASE WHEN a.Code_complex_product = 'H' THEN a.Code_complex_product ELSE '' END)  Code_H
          ,MAX(CASE WHEN a.Code_complex_product = 'I' THEN a.Code_complex_product ELSE '' END)  Code_I
          ,MAX(CASE WHEN a.Code_complex_product = 'J' THEN a.Code_complex_product ELSE '' END)  Code_J
          ,MAX(CASE WHEN a.Code_complex_product = 'K' THEN a.Code_complex_product ELSE '' END)  Code_K
          ,MAX(CASE WHEN a.Code_complex_product = 'L' THEN a.Code_complex_product ELSE '' END)  Code_L
          ,MAX(CASE WHEN a.Code_complex_product = 'M' THEN a.Code_complex_product ELSE '' END)  Code_M
          ,MAX(CASE WHEN a.Code_complex_product = 'N' THEN a.Code_complex_product ELSE '' END)  Code_N
          ,MAX(CASE WHEN a.Code_complex_product = 'O' THEN a.Code_complex_product ELSE '' END)  Code_O
          ,MAX(CASE WHEN a.Code_complex_product = 'P' THEN a.Code_complex_product ELSE '' END)  Code_P
          ,MAX(CASE WHEN a.Code_complex_product = 'Q' THEN a.Code_complex_product ELSE '' END)  Code_Q
          ,MAX(CASE WHEN a.Code_complex_product = 'R' THEN a.Code_complex_product ELSE '' END)  Code_R
          ,MAX(CASE WHEN a.Code_complex_product = 'S' THEN a.Code_complex_product ELSE '' END)  Code_S
          ,MAX(CASE WHEN a.Code_complex_product = 'T' THEN a.Code_complex_product ELSE '' END)  Code_T
          ,MAX(CASE WHEN a.Code_complex_product = 'U' THEN a.Code_complex_product ELSE '' END)  Code_U
          ,MAX(CASE WHEN a.Code_complex_product = 'V' THEN a.Code_complex_product ELSE '' END)  Code_V
          ,MAX(CASE WHEN a.Code_complex_product = 'W' THEN a.Code_complex_product ELSE '' END)  Code_W
          ,MAX(CASE WHEN a.Code_complex_product = 'X' THEN a.Code_complex_product ELSE '' END)  Code_X
          ,MAX(CASE WHEN a.Code_complex_product = 'Y' THEN a.Code_complex_product ELSE '' END)  Code_Y
          ,MAX(CASE WHEN a.Code_complex_product = 'Z' THEN a.Code_complex_product ELSE '' END)  Code_Z
          ,MAX(CASE WHEN a.Code_complex_product = '0' THEN a.Code_complex_product ELSE '' END)  Code_0
          ,MAX(CASE WHEN a.Code_complex_product = '1' THEN a.Code_complex_product ELSE '' END)  Code_1
          ,MAX(CASE WHEN a.Code_complex_product = '2' THEN a.Code_complex_product ELSE '' END)  Code_2
          ,MAX(CASE WHEN a.Code_complex_product = '3' THEN a.Code_complex_product ELSE '' END)  Code_3
          ,MAX(CASE WHEN a.Code_complex_product = '4' THEN a.Code_complex_product ELSE '' END)  Code_4
          ,MAX(CASE WHEN a.Code_complex_product = '5' THEN a.Code_complex_product ELSE '' END)  Code_5
          ,MAX(CASE WHEN a.Code_complex_product = '6' THEN a.Code_complex_product ELSE '' END)  Code_6
          ,MAX(CASE WHEN a.Code_complex_product = '7' THEN a.Code_complex_product ELSE '' END)  Code_7
          ,MAX(CASE WHEN a.Code_complex_product = '8' THEN a.Code_complex_product ELSE '' END)  Code_8
          ,MAX(CASE WHEN a.Code_complex_product = '9' THEN a.Code_complex_product ELSE '' END)  Code_9
          ,COUNT(DISTINCT a.Code_complex_product)  Aantal_complexe_producten
     FROM  Mi_temp.Complex_product  a
     GROUP BY 1,2);

CREATE TABLE Mi_temp.Internationaal_maanden AS
(SELECT Maand_nr
FROM( SELECT
          sni.Maand_nr
         ,RANK(sni.Maand_nr)  Maand_teller
      FROM (SELECT Maand_nr
            FROM (SELECT boekdatum, COUNT(*)  Aantal
                  FROM mi_cmb.Snu a
                  GROUP BY 1) a
            INNER JOIN (SELECT a.Datum
                          ,a.Maand_werkdag_nr
                          ,b.*
                      FROM  mi_vm.vKalender a
                      INNER JOIN ( SELECT
                                     Maand_nr
                                    ,MAX(Maand_werkdag_nr)  Laatste_maand_werkdag_nr
                                 FROM mi_vm.vKalender
                                 WHERE NOT Maand_werkdag_nr IS NULL
                                 GROUP BY 1) b
                         ON b.Maand_nr = a.Maand_nr ) b
               ON b.datum = a.boekdatum
            WHERE Maand_werkdag_nr >= (Laatste_maand_werkdag_nr - 2)
            GROUP BY 1) snu
      INNER JOIN (SELECT Maand_nr
           		  FROM (SELECT boekdatum, COUNT(*)  Aantal
                 		 FROM mi_cmb.Sni a
                 		GROUP BY 1 ) a
				 INNER JOIN(SELECT  a.Datum
                         ,a.Maand_werkdag_nr
                         ,b.*
                     FROM  mi_vm.vKalender a
                     INNER JOIN (SELECT Maand_nr
                                   	  ,MAX(Maand_werkdag_nr)  Laatste_maand_werkdag_nr
                                FROM mi_vm.vKalender
                                WHERE NOT Maand_werkdag_nr IS NULL
                                GROUP BY 1) b
                        ON b.Maand_nr = a.Maand_nr) b
              ON b.datum = a.Boekdatum
           WHERE Maand_werkdag_nr >= (Laatste_maand_werkdag_nr - 2)
           GROUP BY 1 ) sni
         ON sni.Maand_nr = snu.Maand_nr) a
WHERE Maand_teller <= 12 ) WITH DATA UNIQUE PRIMARY INDEX (maand_nr);

CREATE TABLE mi_temp.Internationaal_snisnu AS
(SELECT
    COALESCE(A.bc_nr,B.bc_nr)        BC_nr,
    COALESCE(A.maand_nr,B.maand_nr)  Maand_nr,
    SUM(A.N_snu_trx)                 N_snu_trx,
    SUM(a.amount_snu)                amount_snu,
    SUM(B.N_sni_trx)                 N_sni_trx,
    SUM(b.amount_sni)                amount_sni
FROM (SELECT
           b.party_id                                                          BC_nr,
           EXTRACT( YEAR FROM boekdatum)*100+ EXTRACT (MONTH FROM boekdatum)   Maand_nr,
           COUNT(*)                                                            N_snu_trx,
           SUM((c.valuta_koers (FLOAT)) * bedragvv)                            Amount_snu
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
    GROUP BY 1,2) A
FULL OUTER JOIN (SELECT
          b.party_id                                                          BC_nr,
          EXTRACT( YEAR FROM boekdatum)*100+ EXTRACT (MONTH FROM boekdatum)   Maand_nr,
          COUNT(*)                                                            N_sni_trx,
          SUM((c.valuta_koers (FLOAT)) * bedragvv)                            Amount_sni
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
   GROUP BY 1,2) B
   ON A.bc_nr = B.bc_nr
  AND A.Maand_nr = B.Maand_nr
GROUP BY 1,2
) WITH DATA UNIQUE PRIMARY INDEX (Maand_nr, BC_nr);

CREATE TABLE mi_temp.Internationaal_trx_bc AS
(SELECT
     cbc_oid  BC_nr
    ,c.Maand_nr
    ,COUNT(DISTINCT c.contract_oid)          N_contracten
    ,SUM(c.CS_N_CR_trx)                      CS_N_CR_trx
    ,SUM(c.CS_CR_bedrag_trx)                 CS_CR_bedrag_trx
    ,SUM(c.CS_N_CR_buitenlandse_trx)         CS_N_CR_buitenlandse_trx
    ,SUM(c.CS_CR_bedrag_buitenlandse_trx)    CS_CR_bedrag_buitenl_trx
    ,SUM(c.CS_N_DT_trx)                      CS_N_DT_trx
    ,SUM(c.CS_DT_bedrag_trx)                 CS_DT_bedrag_trx
    ,SUM(c.CS_N_DT_buitenlandse_trx)         CS_N_DT_buitenlandse_trx
    ,SUM(c.CS_DT_bedrag_buitenlandse_trx)    CS_DT_bedrag_buitenl_trx
FROM mi_vm_nzdb.vCS_geld_contr_feiten_periode c
INNER JOIN Mi_temp.Internationaal_maanden Mnd
   ON Mnd.Maand_nr = c.Maand_nr
GROUP BY 1,2
)WITH DATA UNIQUE PRIMARY INDEX (Maand_nr, BC_nr);

CREATE TABLE mi_temp.Internationaal_trx_tabel AS
(SELECT
     a.bc_nr
    ,a.maand_nr
    ,ZEROIFNULL(a.CS_N_CR_trx        )                     CS_N_CR_trx
    ,ZEROIFNULL(a.CS_CR_bedrag_trx        )                CS_CR_bedrag_trx
    ,ZEROIFNULL(a.CS_N_CR_buitenlandse_trx  )              CS_N_CR_buitenlandse_trx
    ,ZEROIFNULL(a.CS_CR_bedrag_buitenl_trx  )              CS_CR_bedrag_buitenl_trx
    ,ZEROIFNULL(a.CS_N_DT_trx        )                     CS_N_DT_trx
    ,ZEROIFNULL(a.CS_DT_bedrag_trx        )                CS_DT_bedrag_trx
    ,ZEROIFNULL(a.CS_N_DT_buitenlandse_trx  )              CS_N_DT_buitenlandse_trx
    ,ZEROIFNULL(a.CS_DT_bedrag_buitenl_trx  )              CS_DT_bedrag_buitenl_trx
    ,ZEROIFNULL(b.N_sni_trx                 )              N_sni_trx
    ,ZEROIFNULL(b.amount_sni                )              amount_sni
    ,ZEROIFNULL(b.N_snu_trx                 )              N_snu_trx
    ,ZEROIFNULL(b.amount_snu                )              amount_snu
FROM mi_temp.Internationaal_trx_bc        a
LEFT JOIN mi_temp.Internationaal_snisnu    b
  ON a.bc_nr=b.bc_nr
 AND a.maand_nr=b.maand_nr
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14
)WITH DATA UNIQUE PRIMARY INDEX (Maand_nr, BC_nr);

CREATE TABLE mi_temp.Internationaal_1 AS
(SELECT
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
        ,CS_N_CR_trx+CS_N_CR_buitenlandse_trx+N_sni_trx                  N_CR_transacties
        ,CS_N_CR_buitenlandse_trx+N_sni_trx                              N_CR_btl_transacties
        ,CS_CR_bedrag_trx+CS_CR_bedrag_buitenl_trx+amount_sni            sum_CR_transacties
        ,CS_CR_bedrag_buitenl_trx+amount_sni                             sum_CR_btl_transacties
        ,a.CS_N_DT_trx+a.CS_N_DT_buitenlandse_trx+N_snu_trx              N_DT_transacties
        ,a.CS_N_DT_buitenlandse_trx+N_snu_trx                            N_DT_btl_transacties
        ,a.CS_DT_bedrag_trx+a.CS_DT_bedrag_buitenl_trx+amount_snu        sum_DT_transacties
        ,a.CS_DT_bedrag_buitenl_trx+amount_snu                           sum_DT_btl_transacties
FROM mi_temp.Internationaal_trx_tabel a
) WITH DATA UNIQUE PRIMARY INDEX (Maand_nr, BC_nr);

CREATE TABLE mi_temp.Internationaal_2 AS
(SELECT a.klant_nr
       ,a.maand_nr
       ,SUM(b.N_CR_transacties)         N_CR_transacties
       ,SUM(b.N_CR_btl_transacties)     N_CR_btl_transacties
       ,SUM(b.sum_CR_transacties)       sum_CR_transacties
       ,SUM(b.sum_CR_btl_transacties)   sum_CR_btl_transacties
       ,SUM(b.N_DT_transacties)         N_DT_transacties
       ,SUM(b.N_DT_btl_transacties)     N_DT_btl_transacties
       ,SUM(b.sum_DT_transacties)       sum_DT_transacties
       ,SUM(b.sum_DT_btl_transacties)   sum_DT_btl_transacties
FROM Mi_temp.Mia_klantkoppelingen a
LEFT OUTER JOIN mi_temp.Internationaal_1 b
   ON a.business_contact_nr = b.bc_nr
WHERE a.maand_nr = (SELECT MAX(Maand_nr) FROM MI_SAS_AA_MB_C_MB.Mia_periode  Mnd)
GROUP BY 1,2
) WITH DATA PRIMARY INDEX(Klant_nr,maand_nr);

CREATE TABLE mi_temp.Internationaal_3 AS
(SELECT a.maand_nr
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
       ,(a.N_CR_btl_transacties (FLOAT))   / NULLIFZERO(a.N_CR_transacties(FLOAT))    btl_cr_prc
       ,(a.sum_CR_btl_transacties (FLOAT)) / NULLIFZERO(a.sum_CR_transacties(FLOAT))  btl_cr_prc_volume
       ,(a.N_DT_btl_transacties (FLOAT))   / NULLIFZERO(a.N_DT_transacties(FLOAT))    btl_dt_prc
       ,(a.sum_DT_btl_transacties(FLOAT))  / NULLIFZERO(a.sum_DT_transacties(FLOAT))  btl_dt_prc_volume
       ,(a.N_CR_btl_transacties + a.N_DT_btl_transacties (FLOAT)) / NULLIFZERO(a.N_CR_transacties + a.N_DT_transacties)  btl_prc
       ,(a.sum_CR_btl_transacties  + a.sum_DT_btl_transacties (FLOAT)) / NULLIFZERO(a.sum_CR_transacties + a.sum_DT_transacties)  btl_prc_volume
FROM mi_temp.Internationaal_2        a
INNER JOIN Mi_temp.Mia_klant_info b
   ON b.Klant_nr = a.Klant_nr
  AND b.Maand_nr = a.Maand_nr
WHERE b.Klantstatus = 'C'
  AND b.Klant_ind = 1
  AND b.Business_line in ('CBC', 'SME')
) WITH DATA PRIMARY INDEX(Klant_nr);

CREATE TABLE Mi_temp.Internationale AS
(SELECT A.Maand_nr
    ,A.Business_line
    ,A.Klant_nr
    ,CASE
        WHEN ZEROIFNULL(btl_cr_prc_volume) = 0 THEN '0.nvt'
        WHEN ZEROIFNULL(btl_cr_prc_volume) LT 0.10 THEN '<10%'
        WHEN btl_cr_prc_volume LT 0.40 THEN '<40%'
        WHEN btl_cr_prc_volume LT 0.70 THEN '<70%'
        ELSE '>70%'
      END  credit_percentage_buitenland
    ,CASE
        WHEN ZEROIFNULL(btl_dt_prc_volume) = 0 THEN '0.nvt'
        WHEN ZEROIFNULL(btl_dt_prc_volume) LT 0.10 THEN '<10%'
        WHEN btl_dt_prc_volume LT 0.40 THEN '<40%'
        WHEN btl_dt_prc_volume LT 0.70 THEN '<70%'
        ELSE '>70%'
      END  debet_percentage_buitenland
    ,CASE
        WHEN a.Business_line in ('CBC', 'SME')        AND ZEROIFNULL(btl_cr_prc_volume) LT 0.10    AND ZEROIFNULL(btl_dt_prc_volume) LT 0.10 THEN 'Nationaal'
        WHEN a.Business_line in ('CBC', 'SME')        AND ZEROIFNULL(btl_cr_prc_volume) LT 0.40    AND ZEROIFNULL(btl_dt_prc_volume) LT 0.40 THEN 'Int.Light'
        WHEN a.Business_line in ('CBC', 'SME')        AND ZEROIFNULL(btl_cr_prc_volume) LT 0.70    AND ZEROIFNULL(btl_dt_prc_volume) LT 0.70 THEN 'Int.Medium'
        WHEN a.Business_line in ('CBC', 'SME')        AND ZEROIFNULL(btl_cr_prc_volume) GE 0.70    OR ZEROIFNULL(btl_dt_prc_volume)  GE 0.70 THEN 'Int.Heavy'
        ELSE 'tbd'
     END  Int_Klasse
FROM mi_temp.Internationaal_3 A
) WITH DATA UNIQUE PRIMARY INDEX(Klant_nr, Maand_nr);

INSERT INTO MI_SAS_AA_MB_C_MB.Siebel_Employee 
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
,MAX(CASE WHEN RANG = 2 THEN XA.CCA ELSE NULL END) OVER (PARTITION BY sbt_id)  CCA2
,MAX(CASE WHEN RANG = 3 THEN XA.CCA ELSE NULL END) OVER (PARTITION BY sbt_id)  CCA3
,XA.GM_ind
,XA.Account_Management_Specialism
,XA.Account_Management_Segment
,XA.Mdw_sdat
FROM (SELECT
 f.maand_nr  Maand_nr
,f.datum_gegevens  Datum_gegevens
,a.sbt_id  SBT_id
,b.Naam  Naam
,a.party_sleutel_type  Soort_mdw
,a.Functie  Functie
,c.bo_nr  BO_nr_mdw
,TRIM(d.BO_naam)  BO_naam_mdw
,gm.GM_ind
,a.CCA
,Account_Management_Specialism
,Account_Management_Segment
,a.Mdw_sdat
,a.party_sleutel_type
,e.N_bcs
,RANK () OVER (PARTITION BY a.sbt_id ORDER BY a.party_sleutel_type ASC, e.N_bcs DESC, a.Mdw_sdat DESC, a.cca DESC)  Rang
FROM (SELECT party_id,
                      CASE WHEN party_sleutel_type = 'AM' THEN party_id ELSE NULL END AS
                      CCA,
                      CASE WHEN LENGTH(TRIM(COALESCE(Account_Management_Functie, account_management_sbl_functietitel))) > 0
                      THEN TRIM(COALESCE(Account_Management_Functie, account_management_sbl_functietitel, 'ONBEKEND')) ELSE 'ONBEKEND' end
                       Functie,
                      party_sleutel_type,
                      TRIM(sbt_userid)  sbt_id,
                      COALESCE(CASE WHEN LENGTH(TRIM(account_management_specialism)) > 1 THEN TRIM(account_management_specialism) ELSE NULL END, 'Onbekend')
                       Account_Management_Specialism,
                      COALESCE(CASE WHEN LENGTH(TRIM(account_management_segment)) > 1 THEN TRIM(account_management_segment) ELSE NULL END, 'Onbekend')
                       Account_Management_Segment,
                      account_management_sdat  Mdw_sdat
                      FROM MI_VM_LDM.aaccount_management
                WHERE sbt_id IS NOT NULL
                AND sbt_id  <> 'UI0319'
                AND TRIM(FUNCTIE) NOT IN ('Zelst. Verm. Beh.', 'zelfst.Verm.Beh')
                AND LENGTH(TRIM(sbt_id)) > 0) a
INNER JOIN (SELECT party_id,
                               party_sleutel_type,
                               CASE WHEN party_sleutel_type = 'MW' THEN UPPER(TRIM(Naam)) ELSE UPPER(TRIM(Naamregel_1)) END AS
                               Naam
                      FROM mi_vm_ldm.aparty_naam
                      WHERE party_sleutel_type IN ('MW', 'AM')) b
ON a.party_id = b.party_id
AND a.party_sleutel_type = b.party_sleutel_type
INNER JOIN (SELECT party_id,
                               party_sleutel_type,
                               gerelateerd_party_id  bo_nr
                       FROM mi_vm_ldm.aPARTY_PARTY_RELATIE
                       WHERE party_relatie_type_code IN ('AMBO', 'MWBO')
) c
ON a.party_id = c.party_id
AND a.party_sleutel_type = c.party_sleutel_type
LEFT JOIN  (SELECT party_id  bo_nr,
                                naam  bo_naam
                        FROM mi_vm_ldm.aparty_naam
                        WHERE party_sleutel_type = 'BO'
) d
ON c.bo_nr = d.bo_nr
LEFT JOIN (SELECT Party_id  bo_nr,
                               Structuur,
                               Case when substr(Structuur,1,6) = '334524' then 1 else 0 end  GM_ind
                               FROM  mi_vm_ldm.aParty_BO)  gm
on c.bo_nr = gm.bo_nr
LEFT JOIN (SELECT gerelateerd_party_id, gerelateerd_party_sleutel_type, COUNT(party_id)  N_bcs
                        FROM mi_vm_ldm.aparty_party_relatie
                        WHERE party_relatie_type_code IN ('relman','cltadv')
                        GROUP BY 1,2) e
ON a.party_id = e.gerelateerd_party_id
AND a.party_sleutel_type = e.gerelateerd_party_sleutel_type
LEFT JOIN MI_SAS_AA_MB_C_MB.Mia_periode  f
ON 1=1) XA

INSERT INTO MI_SAS_AA_MB_C_MB.Siebel_Activiteit 
SELECT BC.klant_nr  Klant_nr
, B. maand_nr
, B. datum_gegevens
, TRIM(A.party_id_rechtspersoon_bc)  Business_contact_nr
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
, COALESCE(TRIM(SBT.Naam), 'Onbekend')  Naam_mdw_eigenaar
, TRIM(A.Siebel_gespreksrapport_id)  Gespreksrapport_ID
, TRIM(A.Datum_aangemaakt)
, EXTRACT(YEAR FROM A.Datum_aangemaakt) * 100 + EXTRACT(MONTH FROM A.Datum_aangemaakt)
, COALESCE(CN.Aantal_CN, 0)  Aantal_Contactpersonen -- Wordt later in het script geupdate
, COALESCE(MDW.Aantal_MDW, 0)  Aantal_Medewerkers  -- Wordt later in het script geupdate
, TRIM(A.Siebel_activiteit_id)
, COALESCE(TRIM(sleutel_type_commercieel_cluster), TRIM(sleutel_type_rechtspersoon_bc))  Client_level
, A.Sdat
, A.Edat
FROM mi_vm_ldm.aACTIVITEIT_cb A
LEFT JOIN MI_SAS_AA_MB_C_MB.Mia_periode  B
ON 1=1
INNER JOIN Mi_temp.Mia_klantkoppelingen BC
ON a.party_id_rechtspersoon_bc = BC.Business_contact_nr
LEFT JOIN MI_SAS_AA_MB_C_MB.Siebel_Employee  SBT
ON SBT.SBT_ID = A.Sbt_id_mdw_eigenaar
LEFT JOIN
( SELECT siebel_activiteit_id, COUNT(DISTINCT party_id_contactpersoon)  Aantal_CN FROM mi_vm_ldm.aActiviteit_Contactpersoon_cb GROUP BY 1 ) CN
ON CN.siebel_activiteit_id = A.siebel_activiteit_id
LEFT JOIN
(SELECT siebel_activiteit_id, COUNT(DISTINCT party_id_mdw)  Aantal_MDW FROM mi_vm_ldm.aActiviteit_Medewerker_cb GROUP BY 1 ) MDW
ON MDW.siebel_activiteit_id = A.siebel_activiteit_id;

INSERT INTO MI_SAS_AA_MB_C_MB.Siebel_Activiteit_TB_revisies 
SELECT COALESCE(BC.Klant_nr, BC.Pcnl_nr)  Klant_nr,
       B.Maand_nr,
       B.Datum_gegevens,
       TRIM(A.party_id_rechtspersoon_bc)  Business_contact_nr,
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
       COALESCE(TRIM(SBT_EIG.Naam), 'Onbekend')  Naam_mdw_eigenaar,
       TRIM(A.Siebel_gespreksrapport_id)  Gespreksrapport_ID,
       TRIM(A.Datum_aangemaakt),
       EXTRACT(YEAR FROM A.Datum_aangemaakt) * 100 + EXTRACT(MONTH FROM A.Datum_aangemaakt),
       COALESCE(CN.Aantal_CN, 0)  Aantal_Contactpersonen, -- Wordt later in het script geupdate
       COALESCE(MDW.Aantal_MDW, 0)  Aantal_Medewerkers,  -- Wordt later in het script geupdate
       TRIM(A.Siebel_activiteit_id),
       COALESCE(TRIM(sleutel_type_commercieel_cluster), TRIM(sleutel_type_rechtspersoon_bc))  Client_level,
       A.datum_bijgewerkt  Datum_bijgewerkt,
       TRIM(A.Sbt_id_mdw_bijgewerkt_door)  Sbt_id_mdw_bijgewerkt,
       COALESCE(TRIM(SBT_BIJ.Naam), 'Onbekend')  Naam_mdw_bijgewerkt,
       CASE
       WHEN RANK () OVER (PARTITION BY COALESCE(BC.Klant_nr, BC.Pcnl_nr) ORDER BY A.Datum_verval DESC, A.Datum_start DESC, A.Siebel_activiteit_id DESC) = 1 THEN 1
       ELSE 0
       END  TB_revisie_actueel_ind,
       A.Sdat,
       A.Edat
  FROM Mi_vm_ldm.aACTIVITEIT A
  LEFT JOIN MI_SAS_AA_MB_C_MB.Mia_periode  B
    ON 1 = 1
  JOIN Mi_temp.Mia_alle_bcs BC
    ON A.party_id_rechtspersoon_bc = BC.Business_contact_nr
  LEFT JOIN MI_SAS_AA_MB_C_MB.Siebel_Employee  SBT_EIG
    ON SBT_EIG.SBT_ID = A.Sbt_id_mdw_eigenaar
  LEFT OUTER JOIN (SELECT Siebel_activiteit_id, COUNT(DISTINCT Party_id_contactpersoon)  Aantal_CN
                     FROM Mi_vm_ldm.aActiviteit_Contactpersoon_cb
                    GROUP BY 1) CN
    ON CN.siebel_activiteit_id = A.siebel_activiteit_id
  LEFT OUTER JOIN (SELECT Siebel_activiteit_id, COUNT(DISTINCT Party_id_mdw)  Aantal_MDW
                     FROM Mi_vm_ldm.aActiviteit_Medewerker_cb
                    GROUP BY 1) MDW
    ON MDW.siebel_activiteit_id = A.siebel_activiteit_id
  LEFT JOIN MI_SAS_AA_MB_C_MB.Siebel_Employee  SBT_BIJ
    ON SBT_BIJ.SBT_ID = A.Sbt_id_mdw_bijgewerkt_door
 WHERE A.Onderwerp = 'Revision / maintenance'
   AND A.Productgroep = 'Betalen & Contant geld'
   AND A.Activiteit_type = 'Task'
   AND A.Korte_omschrijving = 'TB revisie'
   AND A.Status NE 'Cancelled'
   AND A.Sdat >=  DATE '2017-09-02';

INSERT INTO MI_SAS_AA_MB_C_MB.Siebel_Contactpersoon 
SELECT A.siebel_contactpersoon_id
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
FROM (SELECT
        XA.*
        , case
            when XA.client_level = 'Bussines Contact'   then 'BC'
            when XA.client_level  = 'Commercial Complex' then 'CC'
            when XA.client_level  = 'Commercial Entity'  then 'CE'
            when XA.client_level  = 'Commercial Group'   then 'CG'
            when XA.client_level  = 'Ext. Local Ref.'    then 'XR'
            else 'XX'
          end  client_levelx
    FROM mi_vm_ldm.acontact_persoon_cb XA
    QUALIFY rank() over(partition by XA.siebel_contactpersoon_id , XA.party_id order by XA.contactpersoon_sdat desc) =1) A
LEFT JOIN MI_SAS_AA_MB_C_MB.Mia_periode  B
ON 1=1
LEFT JOIN (SELECT
        party_sleutel_type
        , gerelateerd_party_id  cn
        , party_relatie_type_code
        , case when party_sleutel_type = 'BC' then party_id else null end  bc_contactpersoon
        , case when party_sleutel_type = 'CE' then party_id else null end  ce_contactpersoon
        , case when party_sleutel_type = 'CC' then party_id else null end  cc_contactpersoon
        , case when party_sleutel_type = 'CG' then party_id else null end  cg_contactpersoon
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

CREATE TABLE mi_temp.crm_email_updates AS
(SELECT siebel_contactpersoon_id
        , email
        , email_net
    FROM MI_SAS_AA_MB_C_MB.Siebel_Contactpersoon  A
    JOIN mi_temp.crm_email_updates
    ON 1=1
    WHERE email ne ''
    AND email_net <> email_netst
) WITH DATA PRIMARY INDEX(siebel_contactpersoon_id);

INSERT INTO MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans 
SELECT
 mia.Klant_nr
,B.Maand_nr
,prod.Aantal_succesvol
,prod.Aantal_niet_succesvol
,prod.Aantal_in_behandeling
,prod.Aantal_Nieuw
,a.Datum_aangemaakt
,a.Datum_start
,a.Datum_afgehandeld
FROM mi_vm_ldm.aVerkoopkans_cb a
LEFT JOIN MI_SAS_AA_MB_C_MB.Mia_periode  B
ON 1=1
LEFT JOIN (SELECT siebel_verkoopkans_id
                                       ,COUNT(siebel_verkoopkans_product_id)  Aantal_producten
                                       ,SUM(CASE WHEN TRIM(status) = 'Closed Successfully' THEN 1 ELSE 0 end)  Aantal_succesvol
                                       ,SUM(CASE WHEN TRIM(status) = 'Closed Unsuccessfully' THEN 1 ELSE 0 end)  Aantal_niet_succesvol
                                       ,SUM(CASE WHEN TRIM(status) = 'In Progress' THEN 1 ELSE 0 end)  Aantal_in_behandeling
                                       ,SUM(CASE WHEN TRIM(status) = 'New' THEN 1 ELSE 0 end)  Aantal_Nieuw
                      FROM mi_vm_ldm.aVerkoopkansProduct_cb A
                      GROUP BY 1) prod
ON a.siebel_verkoopkans_id= prod.siebel_verkoopkans_id
INNER JOIN mi_temp.mia_klantkoppelingen mia
ON a.party_id_rechtspersoon_bc = mia.business_contact_nr
LEFT JOIN MI_SAS_AA_MB_C_MB.Siebel_Employee  emp1
ON a.Deal_captain_mdw_sbt_id = emp1.sbt_id
AND b.maand_nr = emp1.maand_nr
LEFT JOIN MI_SAS_AA_MB_C_MB.Siebel_Employee  emp2
ON a.Sbt_id_mdw_aangemaakt_door = emp2.sbt_id
AND b.maand_nr = emp2.maand_nr
LEFT JOIN MI_SAS_AA_MB_C_MB.Siebel_Employee  emp3
ON a.Sbt_id_mdw_bijgewerkt_door = emp3.sbt_id
AND b.maand_nr = emp3.maand_nr
WHERE Soort <> 'deal' or Soort IS NULL;

INSERT INTO MI_SAS_AA_MB_C_MB.Siebel_Deal 
SELECT mia.Klant_nr
,B.Maand_nr
,B.Datum_gegevens
,a.party_id_rechtspersoon_bc  business_contact_nr
,a.Siebel_verkoopkans_id  Siebel_deal_id
,a.Naam_verkoopkans
,a.Selling_type
,a.Status
,a.Soort
,a.Productgroep
,a.Campaign_code_primary
,a.Herkomst
,a.Deal_captain_mdw_sbt_id
,emp1.Naam  Naam_deal_captain_mdw
,a.Sbt_id_mdw_aangemaakt_door
,emp2.Naam  Naam_mdw_aangemaakt_door
,a.Sbt_id_mdw_bijgewerkt_door
,emp3.Naam  Naam_mdw_bijgewerkt_door
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
END  Clientlevel
,a.Country_primary
,a.contactpersoon_primary_siebel_id
,a.verkoopkans_sdat  Sdat
,a.verkoopkans_edat  Edat
FROM mi_vm_ldm.aVerkoopkans_cb a
LEFT JOIN MI_SAS_AA_MB_C_MB.Mia_periode  B
ON 1=1
LEFT JOIN (SELECT siebel_verkoopkans_id
                                       ,COUNT(siebel_verkoopkans_product_id)  Aantal_producten
                                       ,SUM(CASE WHEN TRIM(status) = 'Closed Successfully' THEN 1 ELSE 0 end)  Aantal_succesvol
                                       ,SUM(CASE WHEN TRIM(status) = 'Closed Unsuccessfully' THEN 1 ELSE 0 end)  Aantal_niet_succesvol
                                       ,SUM(CASE WHEN TRIM(status) = 'In Progress' THEN 1 ELSE 0 end)  Aantal_in_behandeling
                                       ,SUM(CASE WHEN TRIM(status) = 'New' THEN 1 ELSE 0 end)  Aantal_Nieuw
                      FROM mi_vm_ldm.aVerkoopkansProduct_cb A
                      GROUP BY 1) prod
ON a.siebel_verkoopkans_id= prod.siebel_verkoopkans_id
INNER JOIN mi_temp.mia_klantkoppelingen mia
ON a.party_id_rechtspersoon_bc = mia.business_contact_nr
LEFT JOIN MI_SAS_AA_MB_C_MB.Siebel_Employee  emp1
ON a.Deal_captain_mdw_sbt_id = emp1.sbt_id
AND b.maand_nr = emp1.maand_nr
LEFT JOIN MI_SAS_AA_MB_C_MB.Siebel_Employee  emp2
ON a.Sbt_id_mdw_aangemaakt_door = emp2.sbt_id
AND b.maand_nr = emp2.maand_nr
LEFT JOIN MI_SAS_AA_MB_C_MB.Siebel_Employee  emp3
ON a.Sbt_id_mdw_bijgewerkt_door = emp3.sbt_id
AND b.maand_nr = emp3.maand_nr
WHERE Soort = 'deal';

INSERT INTO MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_Product 
SELECT B.klant_nr
,B.Maand_nr
,B.Datum_gegevens
,B.Business_contact_nr
,A.siebel_verkoopkans_product_id
,A.siebel_verkoopkans_id
,C.omschrijving
,D.omschrijving
,A.pnc_contract_nummer
,A.aantal
,A.Omzet
FROM  MI_VM_LDM.aVerkoopkansproduct_CB A
INNER JOIN MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans  B
ON A.siebel_verkoopkans_id = B.siebel_verkoopkans_id
LEFT JOIN MI_VM_Ldm.aProduct_cb C
ON A.siebel_product_id = C.siebel_product_id
LEFT JOIN  MI_VM_Ldm.aProductGroep_cb D
ON A.siebel_productgroep_id = D.siebel_productgroep_id
LEFT JOIN MI_SAS_AA_MB_C_MB.Siebel_Employee  E
ON A.sbt_id_mdw_eigenaar = E.SBT_ID AND E.Maand_nr = (SELECT maand_nr FROM MI_SAS_AA_MB_C_MB.Mia_periode )
LEFT JOIN MI_SAS_AA_MB_C_MB.Siebel_Employee  F
ON A.sbt_id_mdw_aangemaakt_door = F.SBT_ID AND F.Maand_nr = (SELECT maand_nr FROM MI_SAS_AA_MB_C_MB.Mia_periode )
LEFT JOIN (
    SELECT siebel_verkoopkans_product_id,MIN(bijgewerkt_op)  Datum_nieuw
    FROM  MI_VM_LDM.vVerkoopkansproduct_CB
    WHERE status = 'New'
    GROUP BY 1
)  XD
ON A.siebel_verkoopkans_product_id = XD.siebel_verkoopkans_product_id
LEFT JOIN (
    SELECT siebel_verkoopkans_product_id,MIN(bijgewerkt_op)  Datum_in_behandeling
    FROM  MI_VM_LDM.vVerkoopkansproduct_CB
    WHERE status = 'In Progress'
    GROUP BY 1
)  XE
ON A.siebel_verkoopkans_product_id = XE.siebel_verkoopkans_product_id
LEFT JOIN (
    SELECT siebel_verkoopkans_product_id,MIN(bijgewerkt_op)  Datum_gesl_succesvol
    FROM  MI_VM_LDM.vVerkoopkansproduct_CB
    WHERE status = 'Closed Successfully'
    GROUP BY 1
)  XF
ON A.siebel_verkoopkans_product_id = XF.siebel_verkoopkans_product_id
LEFT JOIN (
    SELECT siebel_verkoopkans_product_id,MIN(bijgewerkt_op)  Datum_gesl_niet_succesvol
    FROM  MI_VM_LDM.vVerkoopkansproduct_CB
    WHERE status = 'Closed Unsuccessfully'
    GROUP BY 1
)  XG
ON A.siebel_verkoopkans_product_id = XG.siebel_verkoopkans_product_id;

INSERT INTO MI_SAS_AA_MB_C_MB.Siebel_act_participants 
SELECT TRIM(A.Siebel_activiteit_id)  Siebel_activiteit_id
,B.Maand_nr
,B.datum_gegevens
,'Medewerker'  Type_deelnemer
,E.Naam
,E.Functie
,E.sbt_id
,NULL  Siebel_Contactpersoon_id
FROM MI_SAS_AA_MB_C_MB.Siebel_Activiteit  A
LEFT JOIN MI_SAS_AA_MB_C_MB.Mia_periode    B
ON 1=1
INNER JOIN mi_vm_ldm.aActiviteit_Medewerker_cb C
ON   A.siebel_activiteit_id = C.siebel_activiteit_id
LEFT JOIN mi_vm_ldm.aACCOUNT_MANAGEMENT D
ON C.sleutel_type_mdw= D.party_sleutel_type
and C.party_id_mdw = D.party_id
INNER JOIN MI_SAS_AA_MB_C_MB.Siebel_Employee  E
ON D.sbt_userid = E.sbt_id;
INSERT INTO MI_SAS_AA_MB_C_MB.Siebel_act_participants 
SELECT TRIM(A.Siebel_activiteit_id)
,b.Maand_nr
,b.datum_gegevens
,'Contactpersoon'  Type_deelnemer
,E.Naam
,E.Functie
,NULL  SBT_ID
,TRIM(E.siebel_contactpersoon_id)  siebel_contactpersoon_id
FROM MI_SAS_AA_MB_C_MB.Siebel_Activiteit  A
LEFT JOIN MI_SAS_AA_MB_C_MB.Mia_periode    B
ON 1=1
INNER JOIN mi_vm_ldm.aActiviteit_Contactpersoon_cb C
ON A.siebel_activiteit_id = C.siebel_activiteit_id
LEFT JOIN mi_vm_ldm.acontact_persoon_cb D
on C.party_id_contactpersoon = D.party_id
AND C.sleutel_type_contactpersoon = D.party_sleutel_type
INNER JOIN (select siebel_contactpersoon_id,
                      COALESCE(trim(voornaam)||' '||trim(tussenvoegsel)||' '||trim(achternaam)||' '||trim(achtervoegsel), 'Onbekend')  Naam,
                      TRIM(contactpersoon_functietitel)  Functie
                      from MI_SAS_AA_MB_C_MB.Siebel_Contactpersoon 
                      group by 1,2,3) E
ON D.siebel_contactpersoon_id = E.siebel_contactpersoon_id;

UPDATE MI_SAS_AA_MB_C_MB.Siebel_Activiteit 
FROM(SELECT Siebel_activiteit_id,
                 SUM(case when type_deelnemer = 'contactpersoon' then 1 else 0 end)  Aantal_contactpersonen,
                 SUM(case when type_deelnemer = 'medewerker' then 1 else 0 end)  Aantal_Medewerkers
                 FROM MI_SAS_AA_MB_C_MB.Siebel_act_participants 
                 GROUP BY 1) a
SET Aantal_Contactpersonen = A.Aantal_Contactpersonen ,
Aantal_Medewerkers = A.Aantal_Medewerkers
WHERE MI_SAS_AA_MB_C_MB.Siebel_Activiteit .Siebel_activiteit_id = A.Siebel_activiteit_id;

INSERT INTO MI_SAS_AA_MB_C_MB.Mia_sector 
SELECT x.Maand_nr,
       SBI_Plus_Code  Sbi_code,
       SBI_Plus_NAME_NL  Sbi_oms,
       AGIC_Code  Agic_code,
       AGIC_NAME_NL  Agic_oms,
       CMB_Sector_Code  Sector_code,
       CMB_Sector_NAME_NL  Sector_oms,
       CB_Subsector_Code  Subsector_code,
       CB_Subsector_NAME_NL  Subsector_oms,
       CASE
       WHEN CMB_Sector_NAME_NL IN ('Bouw', 'Olie & Gas', 'Transport & Logistiek', 'Utilities') THEN 1
       WHEN CMB_Sector_NAME_NL IN ('Agrarisch', 'Food', 'Retail') THEN 2
       WHEN CMB_Sector_NAME_NL IN ('Financial Institutions', 'Leisure', 'Technologie, Media & Telecom', 'Zakelijke dienstverlening') THEN 3
       WHEN CMB_Sector_NAME_NL IN ('Healthcare', 'Overheid & Onderwijs', 'Real Estate') THEN 4
       WHEN CMB_Sector_NAME_NL IN ('Industrie') THEN 5
       WHEN CMB_Sector_NAME_NL IN ('Prive Personen') THEN 6
       ELSE NULL
       END  Sectorcluster_code,
       CASE
       WHEN CMB_Sector_NAME_NL IN ('Bouw', 'Olie & Gas', 'Transport & Logistiek', 'Utilities') THEN 'Business-to-business'
       WHEN CMB_Sector_NAME_NL IN ('Agrarisch', 'Food', 'Retail') THEN 'Consumer'
       WHEN CMB_Sector_NAME_NL IN ('Financial Institutions', 'Leisure', 'Technologie, Media & Telecom', 'Zakelijke dienstverlening') THEN 'Services'
       WHEN CMB_Sector_NAME_NL IN ('Healthcare', 'Overheid & Onderwijs', 'Real Estate') THEN 'Real Estate, Public & Healthcare'
       WHEN CMB_Sector_NAME_NL IN ('Industrie') THEN 'Manufacturing'
       WHEN CMB_Sector_NAME_NL IN ('Prive Personen') THEN 'Private Individuals'
       ELSE NULL
       END  Sectorcluster_oms
  FROM Mi_vm_ldm.vSBI_plus_industry_RollUp
  JOIN MI_SAS_AA_MB_C_MB.Mia_periode  X
    ON 1=1
 GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10;

CREATE TABLE mi_temp.geo_variabelen AS
(select D.maand_nr,
			D.cbc_postcode  postcode,
            D.CBC_oid,
            XI.land_geogr_id  Geo_niveau1,
              XJ.geo_locatie  Geo_niveau2,
              case when coalesce(XK.gemnaam, XI.Stad_naam) = ' ' then null
			  			else coalesce(XK.gemnaam, XI.Stad_naam) END  Geo_niveau3,
               XJ.Org_niveau2  SME_regio,
            XJ.Marktgebied  SME_marktgebied
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
JOIN mi_cmb.geo_variabelen_conf
on 1=1
where d.maand_nr = MI_SAS_AA_MB_C_MB.Mia_periode.maand_nr
group by 1,2,3,4,5,6,7,8) with data and stats
UNIQUE PRIMARY INDEX (maand_nr,postcode,cbc_oid);

INSERT INTO Mi_temp.Mia_week
SELECT MIA.Klant_nr  Klant_nr,
       A.Maand_nr  Maand_nr,
       MIA.Datum_gegevens  Datum_gegevens,
       D.CBC_nr  Business_contact_nr,
       Bc_CCA_TB  CCA_consultant_TB
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
                          MAX(XA.Telefoon_nummer)
                     FROM Mi_vm_ldm.aParty_telefoon_adres XA
                    WHERE XA.Party_sleutel_type = 'bc'
                      AND XA.Adres_gebruik_type_code = 'tv'
                    GROUP BY 1)  G
    ON D.CBC_nr = G.Party_id
  LEFT OUTER JOIN (SELECT XA.Party_id,
                          MAX(XA.Telefoon_nummer)  Telefoon_nr_mobiel
                     FROM Mi_vm_ldm.aParty_telefoon_adres XA
                    WHERE XA.Party_sleutel_type = 'bc'
                      AND XA.Adres_gebruik_type_code = 'tm'
                    GROUP BY 1)  H
    ON D.CBC_nr = H.Party_id
  LEFT OUTER JOIN (SELECT XA.Party_id,
                          XA.Party_sleutel_type,
                          MAX(XA.Electronisch_adres_id)  Email_adres
                     FROM Mi_vm_ldm.aParty_electronisch_adres XA
                    WHERE XA.Party_sleutel_type = 'bc'
                      AND XA.Adres_gebruik_type_code = 'em'
                    GROUP BY 1, 2)  I
    ON D.CBC_nr = I.Party_id AND I.Party_sleutel_type = 'bc'
  LEFT OUTER JOIN (SELECT XA.CC_nr  Cluster_nr,
                          MIN(XA.Contract_nr)  Contract_nr
                     FROM Mi_vm_nzdb.vContract XA
                     JOIN Mi_vm_nzdb.vLU_Maand_Runs XB
                       ON XA.Maand_nr = XB.Maand_nr AND XB.Lopende_maand_ind = 1
                    WHERE XA.Contract_status_code NE 3
                      AND XA.Contract_soort_code BETWEEN 1 AND 99
                    GROUP BY 1)  J
    ON MIA.Klant_nr = J.Cluster_nr
  LEFT OUTER JOIN (SELECT XA.Klant_nr  Cluster_nr,
                          MAX(CASE WHEN XA.Volgorde = 0 THEN XA.Business_contact_nr ELSE NULL END)  Leidend_bc
                     FROM Mi_temp.Mia_klantkoppelingen XA
                    GROUP BY 1)  K
    ON MIA.Klant_nr = K.Cluster_nr
  LEFT OUTER JOIN Mi_vm_nzdb.vCC_omzet_versch_bronnen L
    ON MIA.Klant_nr = L.CC_nr AND MIA.Maand_nr = L.Maand_nr AND L.Omzet_bron_id = 5
  LEFT OUTER JOIN (SELECT XA.CC_nr,
                          XA.Maand_nr,
                          SUM(XB.Business_volume)  CC_business_volume,
                          SUM(XB.Credit_volume)  CC_credit_volume,
                          SUM(XB.Debet_volume)  CC_debet_volume
                     FROM Mi_vm_nzdb.vCommercieel_business_contact XA
                     JOIN Mi_vm_nzdb.vLU_Maand_Runs XX
                       ON XA.Maand_nr = XX.Maand_nr AND XX.Lopende_maand_ind = 1
                     LEFT OUTER JOIN Mi_vm_nzdb.vContract_feiten_snapshot XB
                       ON XA.CBC_oid = XB.CBC_oid AND XA.Maand_nr = XB.Maand_nr
                    GROUP BY 1, 2)  M
    ON MIA.Klant_nr = M.CC_nr AND MIA.Maand_nr = M.Maand_nr
  LEFT OUTER JOIN Mi_vm_nzdb.vMKB_RM_denorm N
  ON A.CC_accountmanager_oid = N.MKB_accountmanager_oid AND A.Maand_nr = N.Maand_nr
  LEFT OUTER JOIN Mi_vm_ldm.aParty_naam NN
    ON MIA.CCA = NN.Party_id AND NN.Party_sleutel_type = 'AM'
  LEFT OUTER JOIN (SELECT XA.CC_nr,
                          XA.Maand_nr,
                          MAX(XB.Segment_id)  CRG
                     FROM Mi_vm_nzdb.vCommercieel_business_contact XA
                     JOIN Mi_vm_nzdb.vLU_Maand_Runs XX
                       ON XA.Maand_nr = XX.Maand_nr AND XX.Lopende_maand_ind = 1
                     JOIN Mi_vm_ldm.aSegment_klant XB
                       ON XA.CBC_nr = XB.Party_id AND XB.Party_sleutel_type = 'bc' AND XB.Segment_type_code = 'crg'
                    GROUP BY 1, 2)  O
    ON MIA.Klant_nr = O.CC_nr AND MIA.Maand_nr = O.Maand_nr
  LEFT OUTER JOIN Mi_vm_nzdb.vCross_sell_cc P
    ON MIA.Klant_nr = P.CC_nr AND MIA.Maand_nr = P.Maand_nr
  LEFT OUTER JOIN (SELECT XA.Bo_nr  NEWBank_bo_nr
                     FROM Mi_vm_ldm.vBo_mi_part_zak XA
                    WHERE (XA.Bu_code = '1R')
                       OR (XA.Bu_code = '1C' AND XA.Bo_nr NOT IN (988938, 988999)))  Q
    ON A.Leidend_bankshop_nr = Q.NEWBank_bo_nr
  LEFT OUTER JOIN Mi_vm_nzdb.vTIR_cc_bank_herkomst R
    ON MIA.Klant_nr = R.Cc_nr AND MIA.Maand_nr = R.Month_nr
    LEFT OUTER JOIN (SELECT XA.Cc_nr,
                          XA.Maand_nr,
                         'H'||XC.KvK_nr (CHAR(13))  Kvk_nr,
                          COALESCE(CASE WHEN XB.Cbc_sbi_company_activity IN  ('000000','-101') THEN NULL ELSE XB.Cbc_sbi_company_activity END, XC.Kvk_branche_code)  Sbi_code,
                          CASE
                          WHEN XB.Cbc_sbi_company_activity NOT IN ('000000','-101') THEN 'BCDB SBI*'
                          WHEN XC.Kvk_branche_oms IS NOT NULL THEN 'KvK'
                          ELSE NULL
                          END  Sbi_bron,
                          XC.Kvk_branche_code  Kvk_branche_nr,
                          XC.Kvk_branche_oms  Kvk_branche_oms
                     FROM Mi_vm_nzdb.vCommercieel_cluster XA
                     JOIN MI_SAS_AA_MB_C_MB.Mia_periode  XX
                       ON XA.Maand_nr = XX.Maand_nr
                     JOIN Mi_vm_nzdb.vCommercieel_business_contact XB
                       ON XA.Leidend_CBC_oid = XB.CBC_oid AND XA.Maand_nr = XB.Maand_nr
                     LEFT OUTER JOIN Mi_vm_nzdb.vCoci_denorm XC
                       ON XA.Cc_kvk_registratie_oid = XC.Kvk_oid AND XA.Maand_nr = XC.Maand_nr)  S
    ON A.Cc_nr = S.Cc_nr AND A.Maand_nr = S.Maand_nr
  LEFT OUTER JOIN MI_SAS_AA_MB_C_MB.Mia_sector  T
    ON S.Sbi_code = T.Sbi_code
  LEFT OUTER JOIN (SELECT XA.Cc_nr  Cluster_nr,
                          COUNT(XD.Party_id)  N_bcs_valniv12
                     FROM Mi_vm_nzdb.vCommercieel_business_contact XA
                     JOIN Mi_vm_nzdb.vLU_Maand_Runs XX
                       ON XA.Maand_nr = XX.Maand_nr AND XX.Lopende_maand_ind = 1
                     JOIN Mi_vm_nzdb.vCommercieel_cluster XC
                       ON XA.Cc_nr = XC.Cc_nr AND XA.Maand_nr = XC.Maand_nr
                     JOIN Mi_vm_ldm.aKlant_prospect XD
                       ON XA.Cbc_nr = XD.Party_id AND XD.klant_validatie_niveau IN (1, 2) AND XD.Party_sleutel_type = 'bc'
                    GROUP BY 1)  Z
    ON MIA.Klant_nr = Z.Cluster_nr
  LEFT OUTER JOIN (SELECT XA.CC_nr  Cluster_nr,
                          XA.Maand_nr,
                          MAX(CASE WHEN XB.CS_product_naam_extern LIKE '%Ond%rek%starter%'                       THEN 1 ELSE 0 END)  Starters_rekening,
                          MAX(CASE WHEN XB.CS_product_naam_intern LIKE '%Starters%pakket%'                       THEN 1 ELSE 0 END)  Starters_pakket,
                          MAX(CASE WHEN XB.CS_product_naam_intern LIKE '%MKB%Pakket%' OR XB.CS_product_id = 1358 THEN 1 ELSE 0 END)  MKB_pakket,
                          MAX(CASE WHEN XB.CS_product_id = 1345                                                  THEN 1 ELSE 0 END)  VenS_pakket
                     FROM Mi_vm_nzdb.vContract XA
                     JOIN Mi_vm_nzdb.vLU_Maand_Runs XX
                       ON XA.Maand_nr = XX.Maand_nr AND XX.Lopende_maand_ind = 1
                     JOIN Mi_vm_nzdb.vCs_product XB
                       ON XA.Product_id = XB.CS_product_id AND XA.Maand_nr = XB.Maand_nr
                    WHERE (XB.CS_product_naam_intern LIKE ANY ('%Starters%pakket%', '%MKB%Pakket%') OR
                           XB.CS_product_naam_extern LIKE '%Ond%rek%starter%' OR XB.CS_product_id IN (1345, 1358))
                      AND XA.Contract_status_code NE 3
                    GROUP BY 1, 2)  AA
    ON MIA.Klant_nr = AA.Cluster_nr
  LEFT OUTER JOIN (SELECT XA.Bo_nr,
                          XA.Bo_naam
                     FROM Mi_vm_ldm.vBo_mi_part_zak XA)  AB
    ON A.Leidend_bankshop_nr = AB.Bo_nr
  LEFT OUTER JOIN (SELECT XA.Klant_nr,
                          XD.Naam  Contactpersoon
                     FROM Mi_temp.Mia_klantkoppelingen XA
                     JOIN Mi_vm_ldm.aParty_party_relatie XC
                       ON XA.Business_contact_nr = XC.Party_id AND XC.Party_sleutel_type = 'bc'
                     JOIN Mi_vm_ldm.aParty_naam XD
                       ON XC.Gerelateerd_party_id = XD.Party_id AND XD.Party_sleutel_type = 'CP'
                    WHERE XC.Party_relatie_type_code = 'CTTPSN'
                  QUALIFY RANK ( XA.Volgorde ASC, XC.Party_party_relatie_SDAT DESC, XD.Party_id ASC, XD.Naam ASC ) = 1
                    GROUP BY 1)  AC
    ON MIA.Klant_nr = AC.Klant_nr
  LEFT OUTER JOIN Mi_temp.Complexe_producten AD
    ON MIA.Klant_nr = AD.Klant_nr AND MIA.Maand_nr = AD.Maand_nr
    JOIN Mia_week_UPDATE
    ON 1=1
  LEFT OUTER JOIN (SELECT A.Klant_nr,
                          C.Datum_volgend_contact,
                          B.Datum_laatste_contact_pro_ftf,
                          B.Datum_laatste_contact_ftf,
                          SUM(CASE WHEN TRIM(A.Contact_methode) = 'Face to Face' AND A.Sub_type = 'bank initiative' AND A.Datum_start BETWEEN ADD_MONTHS(D.Datum_gegevens, -12) AND D.Datum_gegevens THEN 1 ELSE 0 END)  Aantal_contact_pro_ftf,
                          SUM(CASE WHEN TRIM(A.Contact_methode) = 'Face to Face' AND A.Datum_start BETWEEN ADD_MONTHS(D.Datum_gegevens, -12) AND D.Datum_gegevens THEN 1 ELSE 0 END)  Aantal_contact_ftf,
                          SUM(CASE WHEN TRIM(A.Contact_methode) IN ('Telephone', 'Tel warme overdracht') AND A.Sub_type = 'bank initiative' AND A.Datum_start BETWEEN ADD_MONTHS(D.Datum_gegevens, -12) AND D.Datum_gegevens THEN 1 ELSE 0 END)  Aantal_contact_pro_tel,
                          SUM(CASE WHEN TRIM(A.Contact_methode) IN ('Telephone', 'Tel warme overdracht') AND A.Datum_start BETWEEN ADD_MONTHS(D.Datum_gegevens, -12) AND D.Datum_gegevens THEN 1 ELSE 0 END)  Aantal_contact_tel
                FROM MI_SAS_AA_MB_C_MB.Siebel_Activiteit  A
                LEFT OUTER JOIN (SELECT A.Klant_nr,
                                        MAX(A.Datum_start)  Datum_laatste_contact_ftf,
                                        MAX(CASE WHEN A.Sub_type = 'bank initiative' THEN A.Datum_start ELSE NULL END)  Datum_laatste_contact_pro_ftf
                                   FROM MI_SAS_AA_MB_C_MB.Siebel_Activiteit  A
                                   LEFT JOIN MI_SAS_AA_MB_C_MB.Mia_periode  B
                                     ON A.Maand_nr = B.Maand_nr
                                  WHERE A.Datum_start <= B.Datum_gegevens
                                    AND TRIM(A.Contact_methode) = 'Face to Face'
                                  GROUP BY 1)  B
                  ON A.Klant_nr = B.Klant_nr
                LEFT OUTER JOIN (SELECT A.Klant_nr,
                                        MAX(A.Datum_start)  Datum_volgend_contact
                                   FROM MI_SAS_AA_MB_C_MB.Siebel_Activiteit  A
                                   LEFT JOIN MI_SAS_AA_MB_C_MB.Mia_periode  B
                                     ON A.Maand_nr = B.Maand_nr
                                  WHERE A.Datum_start BETWEEN B.Datum_gegevens+1 AND ADD_MONTHS(B.Datum_gegevens, 60)
                                    AND A.Activiteit_type = 'Appointment'
                                    AND A.Sub_type = 'Customer Appointment'
                                  GROUP BY 1)  C
                  ON A.Klant_nr = C.Klant_nr
                LEFT OUTER JOIN MI_SAS_AA_MB_C_MB.Mia_periode  D
                  ON A.Maand_nr = D.Maand_nr
               WHERE A.Datum_start <= D.Datum_gegevens
               GROUP BY 1, 2, 3, 4)  AE
    ON MIA.Klant_nr = AE.Klant_nr
  LEFT OUTER JOIN Mi_vm_nzdb.vN_werknemers_klasse XA
   ON A.CC_N_werknemers_klasse_code = XA.N_werknemers_klasse_code AND A.Maand_nr = XA.Maand_nr
  LEFT JOIN (SELECT party_id, gerelateerd_party_id  Org_niveau3_bo_nr
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
                          XA.Datum_verval  Revisie_datum
                     FROM MI_SAS_AA_MB_C_MB.Siebel_Activiteit_TB_revisies  XA
                    WHERE XA.TB_revisie_actueel_ind = 1)  XJ
    ON MIA.Klant_nr = XJ.Klant_nr;

INSERT INTO Mi_temp.Mia_week_UPDATE
SELECT A.Klant_nr,
       A.Maand_nr,
       B.Cc_team_oid,
       COALESCE(XA.Org_niveau3, XB.Org_niveau3, 'Onbekend')  Org_niveau3,
       COALESCE(XA.Org_niveau3_bo_nr, XB.Org_niveau3_bo_nr, -101)  Org_niveau3_bo_nr,
       COALESCE(XA.Org_niveau2, XB.Org_niveau2, 'Onbekend')  Org_niveau2,
       COALESCE(XA.Org_niveau2_bo_nr, XB.Org_niveau2_bo_nr, -101)  Org_niveau2_bo_nr,
       COALESCE(XA.Org_niveau1, XB.Org_niveau1, 'Onbekend')  Org_niveau1,
       COALESCE(XA.Org_niveau1_bo_nr, XB.Org_niveau1_bo_nr, -101)  Org_niveau1_bo_nr,
       COALESCE(XA.Org_niveau0, XB.Org_niveau0, 'Onbekend')  Org_niveau0,
       COALESCE(XA.Org_niveau0_bo_nr, XB.Org_niveau0_bo_nr, -101)  Org_niveau0_bo_nr
  FROM Mi_temp.Mia_week A
  LEFT OUTER JOIN Mi_vm_nzdb.vCommercieel_cluster B
    ON A.Klant_nr = B.Cc_nr AND A.Maand_nr = B.Maand_nr
  LEFT OUTER JOIN Mi_sas_aa_mb_c_mb.Mia_organisatie_workaround XA
    ON SUBSTR(A.CCA, 4, 6) = XA.Bo_nr AND ((A.Business_line IN ('CBC', 'SME') AND XA.BO_BL IN ('CBC', 'SME')) OR (A.Business_line = 'CIB' AND XA.BO_BL = 'CIB'))
  LEFT OUTER JOIN Mi_sas_aa_mb_c_mb.Mia_organisatie_workaround XB
    ON A.Bo_nr = XB.Bo_nr AND ((A.Business_line IN ('CBC', 'SME') AND XB.BO_BL IN ('CBC', 'SME')) OR (A.Business_line = 'CIB' AND XB.BO_BL = 'CIB'));

UPDATE Mi_temp.Mia_week
   SET Org_niveau3       = Mi_temp.Mia_week_UPDATE.Org_niveau3      ,
       Org_niveau3_bo_nr = Mi_temp.Mia_week_UPDATE.Org_niveau3_bo_nr,
       Org_niveau2       = Mi_temp.Mia_week_UPDATE.Org_niveau2      ,
       Org_niveau2_bo_nr = Mi_temp.Mia_week_UPDATE.Org_niveau2_bo_nr,
       Org_niveau1       = Mi_temp.Mia_week_UPDATE.Org_niveau1      ,
       Org_niveau1_bo_nr = Mi_temp.Mia_week_UPDATE.Org_niveau1_bo_nr,
       Org_niveau0       = Mi_temp.Mia_week_UPDATE.Org_niveau0      ,
       Org_niveau0_bo_nr = Mi_temp.Mia_week_UPDATE.Org_niveau0_bo_nr
 WHERE Mi_temp.Mia_week.Klant_nr = Mi_temp.Mia_week_UPDATE.Klant_nr
   AND Mi_temp.Mia_week.Maand_nr = Mi_temp.Mia_week_UPDATE.Maand_nr;

INSERT INTO Mi_temp.Mia_klanten
SELECT A.Klant_nr,
       A.Maand_nr,
       A.Bank_herkomst,
       NULL  Dimensie3_id,
       NULL  Dimensie4_id,
       NULL  Dimensie5_id
  FROM Mi_temp.Mia_week A
  LEFT OUTER JOIN Mi_temp.Mia_klantbaten B
    ON A.Klant_nr = B.Klant_nr AND A.Maand_nr = B.Maand_nr
 WHERE (A.Klant_ind = 1 OR A.Klantstatus = 'S');

INSERT INTO MI_SAS_AA_MB_C_MB.CIAA_Mia_hist 
SELECT *
FROM Mi_temp.Mia_week;

INSERT INTO MI_SAS_AA_MB_C_MB.Mia_klantkoppelingen_hist 
SELECT  Klant_nr
       ,Maand_nr
       ,Business_contact_nr
       ,Koppeling_id_CC
       ,Koppeling_id_CE
FROM Mi_temp.Mia_klantkoppelingen;

INSERT INTO Mi_sas_aa_mb_c_mb.Mia_groepkoppelingen_hist 
SELECT * FROM Mi_temp.Mia_groepkoppelingen
;

CREATE TABLE MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr AS
(SELECT
     a.Maand_nr
    ,b.Maand_edat
   ,(CSUM(1,maand_nr DESC) -1)  N_maanden_terug
   ,NULL ( INTEGER)  Maand_nr_cube_baten
   ,NULL ( INTEGER)  Maand_nr_bet_trx
   ,NULL ( INTEGER)  Maand_nr_beleggen
   ,NULL ( INTEGER)  Maand_nr_kredieten
   ,NULL ( INTEGER)  Maand_nr_part_zak
   ,NULL ( INTEGER)  Maand_nr_Cidar
FROM(SELECT Maand_nr
      FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_hist 
      GROUP BY 1) a
INNER JOIN MI_vm.vlu_maand  b
   ON b.Maand = a.Maand_nr
) WITH DATA UNIQUE PRIMARY INDEX (Maand_nr);



INSERT INTO MI_SAS_AA_MB_C_MB.Mia_businesscontacts 
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
       B.Segment_oms  Bc_verschijningsvorm_oms,
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
  JOIN MI_SAS_AA_MB_C_MB.Mia_periode  X
    ON 1 = 1
  LEFT OUTER JOIN Mi_vm_ldm.aSegment B
    ON A.Bc_verschijningsvorm = B.Segment_id
   AND B.Segment_type_code = 'APPTYP'
 WHERE A.DB_ind = 0
   AND A.RBS_ind = 0
   AND A.Bc_clientgroep NOT IN ('8001', '9001');

INSERT INTO Mi_temp.Mia_week_PB
SELECT A.Pcnl_nr  Klant_nr,
       A.Maand_nr  Maand_nr,
       A.Datum_gegevens  Datum_gegevens,
       A.Business_contact_nr  Business_contact_nr,
       A.Bc_naam  Verkorte_naam,
       A.Bc_CCA_TB  CCA_consultant_TB
  FROM MI_SAS_AA_MB_C_MB.Mia_businesscontacts  A
  JOIN Mi_cmb.vCGC_basis B
    ON A.Bc_clientgroep = B.Clientgroep
  LEFT OUTER JOIN (SELECT XA.Klant_nr,
                          XA.Datum_verval  Revisie_datum
                     FROM MI_SAS_AA_MB_C_MB.Siebel_Activiteit_TB_revisies  XA
                    WHERE XA.TB_revisie_actueel_ind = 1)  C
    ON A.Pcnl_nr = C.Klant_nr
  LEFT OUTER JOIN MI_SAS_AA_MB_C_MB.Mia_sector  D
    ON Sbi_codeX = D.Sbi_code
  LEFT OUTER JOIN MI_SAS_AA_MB_C_MB.Mia_sector  E
    ON A.Bc_SBI_code_KvK = E.Sbi_code
  LEFT OUTER JOIN Mi_vm_ldm.aParty_naam F
    ON A.Bc_cca_PB = F.Party_id AND F.Party_sleutel_type = 'AM'
 WHERE A.Pcnl_nr IS NOT NULL
   AND B.Business_line = 'PB'
QUALIFY ROW_NUMBER() OVER (PARTITION BY A.Pcnl_nr ORDER BY A.Leidend_bc_pb_ind, A.Business_contact_nr DESC ) = 1;



INSERT INTO MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB 
SELECT *
FROM Mi_temp.Mia_week_PB;

CREATE TABLE mi_temp.cst_mi_private_banking_scope AS
(SELECT   a.business_contact_nr
        , a.bc_naam
        , a.klant_nr
        , b.Verkorte_naam  klant_naam
        , c.business_segment
        , a.bc_clientgroep
FROM Mi_temp.Mia_alle_bcs            a
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
WITH DATA UNIQUE PRIMARY INDEX (business_contact_nr);

INSERT INTO MI_TEMP.Siebel_CST_Member_TEMP
SELECT CASE WHEN A.Party_sleutel_type = 'BC' THEN COALESCE(BC.klant_nr, i.klant_nr_MI)
      		WHEN A.Party_sleutel_type = 'CE' THEN CE.gerelateerd_party_id
      		WHEN A.Party_sleutel_type = 'CC' THEN A.party_id
      		WHEN A.Party_sleutel_type = 'CG' THEN CG.party_id -- Uit partyrelatie tabel op deelnemersrol = 1
 ELSE NULL END  Klant_nrX
,CASE WHEN A.Party_sleutel_type = 'BC' THEN A.party_id
       WHEN A.Party_sleutel_type <> 'BC' THEN COALESCE(E.business_contact_nr,     i.bc_leidend_bc,NULL)
       END  Business_contact_nrX -- Leidend_BC van retail wordt opgehaald uit party tabel waarvoor hierboven tijdelijke tabel is aangemaakt. DR: i. als ali toegevoegd voor dudielijkheid
,A.party_sleutel_type  Client_level
,COALESCE(E.business_contact_nr, CASE WHEN A.Party_sleutel_type = 'BC' THEN bc_leidend_bc ELSE NULL END)  Leidend_BC    -- Leidend BC kolom is handig voor Retail, omdat deze niet altijd een klant_nr hebben, leidend BC kolom is wel gevuld.
,COALESCE(H.Business_segment, 'Onbekend')  BC_Business_segment    -- Kolom waaraan je kan zien of het Retail is of niet.
,B. maand_nr
,B. datum_gegevens
,D.sbt_id_mdw
,COALESCE(F.Naam, D.sbt_id_mdw )  Naam
,CASE WHEN TRIM(A.sbl_cst_deelnemer_rol) LIKE ANY  ('%1%', '%2%', '%3%', '%4%', '%5%', '%6%', '%7%', '%8%', '%9%', '%0%') THEN X.weergegeven_waarde
      WHEN TRIM(A.sbl_cst_deelnemer_rol) = '' THEN 'Onbekend'
      ELSE COALESCE(TRIM(A.sbl_cst_deelnemer_rol), 'Onbekend')
      END  SBL_cst_deelnemer_rol
,A.SBL_gedelegeerde_ind  SBL_gedelegeerde_ind
,'N'               TB_Consultant
,A.Party_party_relatie_sdat
,A.Party_party_relatie_edat
FROM MI_VM_LDM.aPARTY_PARTY_RELATIE_cst_member A
LEFT JOIN MI_SAS_AA_MB_C_MB.Mia_periode  B
ON 1=1
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

LEFT JOIN MI_SAS_AA_MB_C_MB.Siebel_Employee  F
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
)  X
ON A.sbl_cst_deelnemer_rol = X.taal_onafhankelijke_code

WHERE (Leidend_BC IS NOT NULL AND Business_contact_nrX IS NOT NULL);

INSERT INTO Mi_temp.Siebel_CST_Member 
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
                                                    business_contact_nr DESC) = 1)  a
QUALIFY RANK () OVER (PARTITION BY Leidend_Business_contact, sbl_cst_deelnemer_rol ORDER BY (CASE WHEN a.client_level = 'CG' THEN 3
                                                  WHEN a.client_level = 'CC' THEN 2
                                                  WHEN a.client_level = 'CE' THEN 1
                                                  WHEN a.client_level = 'BC' THEN 0 END) DESC) = 1;

CREATE TABLE MI_TEMP.Consultants_CST_member AS
(SELECT
 Leidend_Business_contact
,a.SBL_cst_deelnemer_rol
,a.SBT_id
,CASE WHEN a.naam IS NOT NULL THEN a.naam
      ELSE a.SBT_id END  naam
,'Y'  TB_Consultant
FROM  mi_temp.Siebel_CST_Member         A
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

UPDATE Mi_temp.Siebel_CST_Member 
FROM (SELECT A.SBT_ID,
             A.Leidend_Business_contact,
             A.sbl_cst_deelnemer_rol
      FROM MI_TEMP.Consultants_CST_member A
      WHERE  A.Leidend_Business_contact = mi_temp.Siebel_CST_Member .Leidend_Business_contact
      AND A.SBT_ID = mi_temp.Siebel_CST_Member .SBT_ID
      AND A.sbl_cst_deelnemer_rol = mi_temp.Siebel_CST_Member .sbl_cst_deelnemer_rol
      GROUP BY 1,2,3) KL
SET TB_Consultant = CASE WHEN KL.Leidend_Business_contact IS NOT NULL THEN 'Y' END
WHERE KL.SBT_ID = mi_temp.Siebel_CST_Member .SBT_ID
AND KL.Leidend_Business_contact = MI_TEMP.Siebel_CST_Member .Leidend_Business_contact
AND TRIM(KL.sbl_cst_deelnemer_rol) = TRIM(MI_TEMP.Siebel_CST_Member .sbl_cst_deelnemer_rol);


INSERT INTO MI_SAS_AA_MB_C_MB.Siebel_Verkoopteam_Member 
SELECT
 C.klant_nr
,B.maand_nr
,B.datum_gegevens
,C.business_contact_nr
,A.siebel_verkoopkans_id
,D.sbt_id_mdw  sbt_id
,E.naam
,E.bo_nr_mdw
,E.bo_naam_mdw
,E.functie
,A.primary_ind
,C.client_level
,A.salesteam_member_sdat  sdat
,A.salesteam_member_edat  edat

FROM mi_vm_ldm.averkoopteam_member_cb A

/* maandnummer toevoegen aan tabel */
LEFT JOIN MI_SAS_AA_MB_C_MB.Mia_periode  B
ON 1=1

/* toevoegen klant_nr, bc_nr en klantniveau uit verkoopkans tabel zodat als het misgaat het op één plek misgaat */
INNER JOIN MI_SAS_AA_MB_C_MB.siebel_verkoopkans  C
ON C.siebel_verkoopkans_id = A.siebel_verkoopkans_id

/* sbt_id ophalen uit positietabel */
INNER JOIN mi_vm_ldm.apositie_cb D
ON D.siebel_positie_id = A.siebel_positie_id

/* obv sbt_id overige membergegevens ophalen via de employee tabel */
INNER JOIN MI_SAS_AA_MB_C_MB.siebel_employee  E
ON E.sbt_id = D.sbt_id_mdw
QUALIFY RANK() OVER(PARTITION BY D.sbt_id_mdw ORDER BY A.primary_ind DESC) = 1 -- Indien sbt_id zowel primary als non-primary dan alleen primary selecteren
;

INSERT INTO MI_SAS_AA_MB_C_MB.Siebel_verkoopkans_contactpersoon 
SELECT
 C.klant_nr
,B.maand_nr
,B.datum_gegevens
,C.business_contact_nr
,A.siebel_verkoopkans_id
,A.primary_ind
,D.siebel_contactpersoon_id
,C.client_level
,A.vk_ctp_sdat  sdat
,A.vk_ctp_edat  edat

FROM mi_vm_ldm.averkoopkans_contactpersoon_cb A
LEFT JOIN MI_SAS_AA_MB_C_MB.Mia_periode  B
ON 1=1

/* toevoegen klant_nr, bc_nr en klantniveau uit verkoopkans tabel zodat als het misgaat het op één plek misgaat */
INNER JOIN MI_SAS_AA_MB_C_MB.siebel_verkoopkans  C
ON C.siebel_verkoopkans_id = A.siebel_verkoopkans_id

/* ivm ophalen overige contactpersoongegevens uit PO's tabel eerst siebel_contactpersoon_id toevoegen*/
INNER JOIN mi_vm_ldm.acontact_persoon_cb D
ON D.party_id = A.party_id_contactpersoon
AND D.party_sleutel_type = A.sleutel_type_contactpersoon
AND D.party_hergebruik_volgnr = A.hergebruik_volgnr_contactpersoon

QUALIFY RANK() OVER(PARTITION BY D.siebel_contactpersoon_id ORDER BY A.primary_ind DESC) = 1 -- Indien siebel_contactpersoon_id zowel primary als non-primary dan alleen primary selecteren
;

INSERT INTO MI_SAS_AA_MB_C_MB.Siebel_CST_Member_hist 
SELECT * FROM Mi_temp.Siebel_CST_Member ;

INSERT INTO Mi_temp.Wegl_rapportage_moment_t1
SELECT Maand_nr
FROM Mi_temp.Mia_week
GROUP BY 1;

CREATE TABLE Mi_temp.Wegl_rapportage_moment
AS (SELECT  a.*
        ,lm.Maand_sdat  Ultimomaand_start_datum_tee
        ,lm.Maand_edat  Ultimomaand_eind_datum_tee
        ,klndr.Jaar_week_nr  Jaar_week
        ,lm.MaandNrLm   MaandNrL1m
        ,lm1.Maand_Edat  MaandNrL1m_edat
        ,lm2.MaandNrLm  MaandNrL2m
        ,lm2x.Maand_Edat  MaandNrL2m_edat
        ,lm.MaandNrL3m
        ,lm3.Maand_Edat  MaandNrL3m_edat
        ,lm.MaandNrL6m
        ,lm6.Maand_Edat  MaandNrL6m_edat
        ,lm.MaandNrL9m
        ,lm9.Maand_Edat  MaandNrL9m_edat
        ,lm.MaandNrLY
        ,lY.Maand_Edat  MaandNrLY_edat
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
   )   WITH DATA UNIQUE PRIMARY INDEX ( Maand_nr );

INSERT INTO Mi_temp.Cluster_status_basis
SELECT A.Cluster_nr  Klant_nr,
       1
FROM (SELECT XA.CC_nr  Cluster_nr
      FROM Mi_vm_nzdb.vCommercieel_cluster XA
      INNER JOIN Mi_vm_nzdb.vCross_sell_cc   c
         ON XA.Cc_nr = c.CC_nr
        AND XA.Maand_nr = c.Maand_nr

      INNER JOIN Mi_temp.Wegl_rapportage_moment XB
         ON XA.Maand_nr = XB.Maand_nr
      WHERE c.MKB_klant_ind = 1) A
INNER JOIN (SELECT XA.Klant_nr  Cluster_nr
      FROM Mi_cmb.vMia_hist XA
      INNER JOIN Mi_temp.Wegl_rapportage_moment XB
         ON XA.Maand_nr = XB.MaandNrLY
      WHERE XA.Klant_ind = 1) B
   ON A.Cluster_nr = B.Cluster_nr;

DELETE FROM Mi_temp.Cluster_status_basis
WHERE Klant_nr IN
        (
        SELECT Klant_nr
        FROM(SELECT c.Klant_nr
                 FROM Mi_cmb.vCIF_complex a
                 INNER JOIN Mi_temp.Wegl_rapportage_moment b
                    ON a.Maand_nr >= B.MaandNrLY
                 INNER JOIN Mi_temp.Mia_alle_bcs c
                    ON c.Business_contact_nr = TO_NUMBER(a.Fac_BC_nr)
                 WHERE a.Fac_actief_ind = 1
                   AND ZEROIFNULL(a.Bijzonder_beheer_ind) >= 1
                   AND NOT a.Fac_BC_nr IS NULL
                   AND NOT c.Klant_nr IS NULL
                 GROUP BY 1
                ) a);

DELETE FROM Mi_temp.Cluster_status_basis
WHERE Klant_nr IN
(
 SELECT Klant_nr
 FROM mi_temp.mia_week  a
 WHERE (ZEROIFNULL(Faillissement_ind) + ZEROIFNULL(Surseance_ind) + ZEROIFNULL(Bijzonder_beheer_ind)) > 0
 GROUP BY 1
);


DELETE FROM Mi_temp.Cluster_status_basis
WHERE Klant_nr IN
(SELECT e.gerelateerd_party_id  Cluster_nr
 FROM mi_vm_ldm.aparty_party_relatie c
 INNER JOIN ( SELECT a.bo_nr
                  FROM mi_vm_ldm.vbo_mi_part_zak a
                  WHERE a.bo_naam LIKE '%SOLV%'
                     OR a.bo_naam LIKE '%BIJZ.KRED%'
                     OR a.bo_naam LIKE '%BIJZ. KRED%'
                     OR a.bo_naam LIKE '%LINDORFF%' ) d
    ON d.bo_nr = c.gerelateerd_party_id
 INNER JOIN Mi_vm_ldm.aParty_party_relatie e
    ON e.Party_id = c.Party_id
   AND e.Party_sleutel_type = 'BC'
   AND e.Party_relatie_type_code = 'CBCTCC'
   AND e.Gerelateerd_party_sleutel_type = 'CC'

WHERE c.party_sleutel_type='BC'
   AND c.gerelateerd_party_sleutel_type='BO'
   AND c.party_relatie_type_code='BOBEHR'
 GROUP BY 1);

.I
DELETE FROM Mi_temp.Cluster_status_basis
WHERE Klant_nr IN
(
  SELECT a.cc_nr
  FROM mi_vm_nzdb.vCommercieel_business_contact a
  INNER JOIN Mi_temp.Wegl_rapportage_moment XB
     ON a.Maand_nr = XB.Maand_nr
  INNER JOIN (       SEL
                         Party_id   Cbc_nr
                     FROM MI_VM_Ldm.aKLANT_PROSPECT
                     WHERE Party_sleutel_type = 'BC'
                       AND Beschikkingsmacht IN (4, 5)
                    GROUP BY 1)  G
    ON A.Cbc_nr = G.Cbc_nr
 GROUP BY 1
)
;

DELETE FROM Mi_temp.Cluster_status_basis
WHERE Klant_nr IN
(
SELECT
        a.Klant_nr
FROM mi_temp.mia_week  a
WHERE a.SBI_code IN ('69103')
   OR a.Kvk_branche_nr IN ('69103')
);

CREATE TABLE Mi_temp.Wegl_act_week AS
(SELECT a.Klant_nr
        ,a.Maand_nr
        ,bas.Status
        ,a.Klant_ind
        ,a.Verkorte_naam
        ,a.Business_contact_nr
        ,a.Clientgroep
        ,COALESCE(b.Segment, 'NB')  Bediening
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


CREATE TABLE Mi_temp.Wegl_hist_volume AS
(SELECT XA.CC_nr  Klant_nr,
     XA.Maand_nr,
     SUM(XB.Business_volume)  CC_business_volume,
     SUM(XB.Credit_volume)  CC_credit_volume,
     SUM(XB.Debet_volume)  CC_debet_volume
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

CREATE TABLE Mi_temp.Wegl_business_vol_items AS
(SELECT  Klant_nr
    ,MAX(CASE WHEN mnd.Maand_nr < 201308 THEN 11 ELSE 12 END)  N_mnd_max
    ,MAX(CASE WHEN a.maand_nr = mnd.MaandNRL1m THEN ZEROIFNULL(a.cc_Business_volume) ELSE 0 END)  Business_vol_L1m
    ,MAX(CASE WHEN a.maand_nr = Mnd.MaandNrLY  THEN ZEROIFNULL(a.cc_Business_volume) ELSE 0 END)  Business_vol_LY
    ,MIN( ZEROIFNULL(a.cc_Business_volume))     Min_Business_volume
    ,MAX( ZEROIFNULL(a.cc_Business_volume))     Max_Business_volume
    ,COUNT(DISTINCT a.maand_nr)  N_mnd
FROM Mi_temp.Wegl_hist_volume a
INNER JOIN Mi_temp.Wegl_rapportage_moment       mnd
   ON 1 = 1
WHERE a.maand_nr BETWEEN mnd.MaandNrLY AND mnd.MaandNRL1m
GROUP BY 1
HAVING Min_Business_volume > 0 AND N_mnd = N_mnd_max) WITH DATA
UNIQUE PRIMARY INDEX (Klant_nr);

CREATE TABLE Mi_temp.Wegl_potentieel AS
(SELECT  a.*
    ,b.Business_vol_L1m
    ,b.Business_vol_LY
    ,b.Min_Business_volume
    ,b.Max_Business_volume
FROM  Mi_temp.Wegl_act_week     a
JOIN Mi_temp.Wegl_business_vol_items      b
ON a.Klant_nr = b.Klant_nr
WHERE ZEROIFNULL(b.Business_vol_L1m) > 100000
  AND  ZEROIFNULL(a.Businessvolume (FLOAT))/ NULLIFZERO(b.Business_vol_L1m) < 0.8
  AND  ZEROIFNULL(a.Businessvolume (FLOAT))/ NULLIFZERO(b.Min_Business_volume) < 0.8
) WITH DATA
UNIQUE PRIMARY INDEX (Klant_nr);

DELETE
  FROM MI_SAS_AA_MB_C_MB.Model_wegloop_hist
 WHERE maand_nr IN (SELECT Maand_nr FROM Mi_temp.Mia_week GROUP BY 1)
   AND ZEROIFNULL(week_1e_retentie_stoplicht ) = 0;

INSERT INTO MI_SAS_AA_MB_C_MB.Model_wegloop_hist
SELECT a.Klant_nr
      ,mnd.Maand_nr
      ,a.Businessvolume
      ,a.Businessvolume_L1m
      ,a.Businessvolume_LY
      ,a.Min_businessvolume
      ,a.Max_businessvolume
      ,1  Retentie_stoplicht
      ,NULL  Week_1e_retentie_stoplicht
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

INSERT INTO MI_SAS_AA_MB_C_MB.Model_wegloop_hist
SELECT a.Klant_nr
      ,a.Maand_nr
      ,Businessvolume
      ,Business_vol_L1m  Businessvolume_L1m
      ,Business_vol_LY  Businessvolume_LY
      ,Min_Business_volume  Min_businessvolume
      ,Max_Business_volume  Max_businessvolume
      ,CASE WHEN ZEROIFNULL(c.Klant_nr) = 0 THEN 1 ELSE 0 END  Retentie_stoplicht
      ,CASE WHEN ZEROIFNULL(c.Klant_nr) = 0 THEN klndr.Jaar_week_nr  ELSE NULL END  Week_1e_retentie_stoplicht
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
   AND d.business_line in ('CBC', 'SME');

INSERT INTO Mi_temp.Mia_periode_CUBe
SELECT B.Maand_nr,
       D.Datum_gegevens,
       EXTRACT(YEAR FROM ADD_MONTHS(C.Maand_startdatum, -1))*100 + EXTRACT(MONTH FROM ADD_MONTHS(C.Maand_startdatum, -1))  Maand_nr_vm1
  FROM Mi_vm_nzdb.vLu_maand_runs B
  JOIN Mi_vm_nzdb.vLu_maand C
    ON B.Maand_nr = C.Maand
  JOIN (SELECT XA.Maand_nr,
               XA.CC_Samenvattings_datum-1  Datum_gegevens
          FROM Mi_vm_nzdb.vCommercieel_cluster XA
          JOIN Mi_vm_nzdb.vLU_Maand_Runs XX
            ON XA.Maand_nr = XX.Maand_nr AND XX.Lopende_maand_ind = 1
         GROUP BY 1, 2)  D
    ON B.Maand_nr = D.Maand_nr
 WHERE B.Lopende_maand_ind = 1;

INSERT INTO MI_SAS_AA_MB_C_MB.CUBe_leads_hist 
SELECT * FROM MI_SAS_AA_MB_C_MB.CUBe_leads_hist;

INSERT INTO MI_SAS_AA_MB_C_MB.CUBe_leads_hist 
SELECT
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
FROM MI_SAS_AA_MB_C_MB.CUBe_leads_hist  a
INNER JOIN (
           SELECT MAX(CASE WHEN NOT UUID IS NULL THEN 1 ELSE 0 END)   Ind_nieuwe_mnd
           FROM MI_SAS_AA_MB_C_MB.CUBe_leads_hist  a

           INNER JOIN Mi_temp.Mia_periode_CUBe b
              ON a.Maand_nr = b.Maand_nr
           ) x
    ON 1 = 1
INNER JOIN Mi_temp.Mia_periode_CUBe b
   ON a.Maand_nr = b.Maand_nr_vm1

WHERE ZEROIFNULL(x.Ind_nieuwe_mnd) = 0
  AND (a.Recordtype <> 'D' OR (a.Recordtype = 'D' AND a.Datum_terugkoppeling IS NULL))
;

UPDATE MI_SAS_AA_MB_C_MB.CUBe_leads_hist 
FROM (SELECT A.Datum_bijgewerkt
            ,A.SBT_id_mdw_bijgewerkt_door

     FROM Mi_vm_ldm.vOutboundCUBeLead_cb  A
     QUALIFY ROW_NUMBER() OVER (PARTITION BY CASE WHEN A.UUID LIKE 'CUBE%' THEN A.UUID ELSE 'CUBE-' || TRIM(UUID) END
                                ORDER BY Cube_lead_sdat DESC,
                                         (CASE WHEN Cube_lead_edat IS NULL THEN 1 ELSE 0 end) DESC,
                                         Cube_lead_edat DESC
                                ) = 1
     ) A
SET
      Status                     = CASE WHEN NOT A.Cube_lead_edat IS NULL AND MI_SAS_AA_MB_C_MB.CUBe_leads_hist .Koppeling_id_CC =  A.Commercieel_cluster_koppeling_id THEN 'Adm Closed - edat gevuld'
                                        WHEN NOT A.Cube_lead_edat IS NULL AND MI_SAS_AA_MB_C_MB.CUBe_leads_hist .Koppeling_id_CC <> A.Commercieel_cluster_koppeling_id THEN 'Adm Closed - KopIdCC gewijzigd'
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
WHERE TRIM(MI_SAS_AA_MB_C_MB.CUBe_leads_hist .UUID) = TRIM(A.UUID)
  AND MI_SAS_AA_MB_C_MB.CUBe_leads_hist .Maand_nr = (SELECT Maand_nr FROM Mi_temp.Mia_periode_CUBe GROUP BY 1)
  AND ((A.Cube_lead_edat + 1) >= MI_SAS_AA_MB_C_MB.CUBe_leads_hist .Datum_aanlevering OR A.Cube_lead_edat IS NULL);

UPDATE MI_SAS_AA_MB_C_MB.CUBe_leads_hist 
FROM
     (
      SELECT TRIM(XA.UUID)  UUID,
             XA.Klant_nr,
             XA.Business_contact_nr,
             XA.Maand_nr,
             XA.CUBe_product_id,
             XA.Bedrijfstak_id,
             XA.Omzetklasse_id,
             XA.Baten,
             XA.Baten_benchmark,
             XA.Penetratie,
             XA.Lichtbeheer,
             COALESCE(XA.Status, 'New')  StatusX,
             XA.Lead_opvolgen,
             ROW_NUMBER() OVER (PARTITION BY XA.UUID ORDER BY Maand_nr
              RESET WHEN StatusX <>  MAX(StatusX) OVER (PARTITION BY XA.UUID ORDER BY Maand_nr ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING)) N_mnd_status
       FROM MI_SAS_AA_MB_C_MB.CUBe_leads_hist  XA
      )  A
SET N_mnd_status =  A.N_mnd_status
WHERE MI_SAS_AA_MB_C_MB.CUBe_leads_hist .UUID = A.UUID
  AND MI_SAS_AA_MB_C_MB.CUBe_leads_hist .Maand_nr = A.Maand_nr;

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
       COUNT(*)  N_klanten
  FROM Mi_temp.Mia_klanten A
 WHERE A.Benchmark_ind = 1
 GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9;

CREATE TABLE Mi_temp.CUBe_benchmark_001
      (
       Maand_nr INTEGER,
       Business_line VARCHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
       Segment VARCHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
       Subsegment VARCHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
       Bedrijfstak_id VARCHAR(6),
       Omzetklasse_id SMALLINT,
       Dimensie3_id VARCHAR(40) CHARACTER SET LATIN NOT CASESPECIFIC,
       Dimensie4_id INTEGER,
       Dimensie5_id INTEGER,
       CUBe_product_id INTEGER,

       Min_verhouding DECIMAL(10,2),
       Min_benchmark DECIMAL(10,0),
       Min_penetratie DECIMAL(10,2),
       Adresseerbaarheid DECIMAL(10,2),
       N_met_product INTEGER,
       Baten_product DECIMAL(18,2),
       N_klanten INTEGER,
       Penetratie DECIMAL(10,4)
      )
UNIQUE PRIMARY INDEX ( Maand_nr, Business_line, Segment, Subsegment, Bedrijfstak_id,
                       Omzetklasse_id, Dimensie3_id, Dimensie4_id, Dimensie5_id, CUBe_product_id );



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
           END)  Min_benchmark,
       MIN(CASE
           WHEN A.Business_line in ('CBC', 'SME') THEN D.Min_penetratie_CC
           ELSE NULL
           END)  Min_penetratie,
       MIN(D.Adresseerbaarheid),
       SUM(CASE WHEN B.Baten NE 0.00 THEN 1 ELSE 0 END)  N_met_product,
       SUM(B.Baten)  Baten_product,
       MAX(C.N_klanten)  N_klanten,
       (SUM(CASE WHEN B.Baten NE 0.00 THEN 1 ELSE 0 END) (DECIMAL(18,6))) /
       (MAX(CASE WHEN A.Business_line in ('CBC', 'SME') AND A.Bedrijfstak_id IS NULL THEN NULL ELSE C.N_klanten END) (DECIMAL(18,6)))  Penetratie
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



COLLECT STATISTICS Mi_temp.Mia_baten COLUMN Baten;
COLLECT STATISTICS Mi_temp.CUBe_benchmark_001 COLUMN (Maand_nr, Business_line, Segment, Omzetklasse_id, CUBe_product_id);
COLLECT STATISTICS COLUMN (CUBE_PRODUCT_ID) ON Mi_temp.Mia_baten;
COLLECT STATISTICS COLUMN (N_MET_PRODUCT) ON  Mi_temp.CUBe_benchmark_001;
COLLECT STATISTICS COLUMN (MAAND_NR ,BUSINESS_LINE ,SEGMENT , SUBSEGMENT ,BEDRIJFSTAK_ID ,OMZETKLASSE_ID ,DIMENSIE3_ID,DIMENSIE4_ID , DIMENSIE5_ID ,CUBE_PRODUCT_ID) ON  Mi_temp.CUBe_benchmark_001;





CREATE TABLE Mi_temp.CUBe_benchmark_002
      (
       Maand_nr INTEGER,
       Business_line VARCHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
       Segment VARCHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
       Subsegment VARCHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
       Bedrijfstak_id VARCHAR(6),
       Omzetklasse_id SMALLINT,
       Dimensie3_id VARCHAR(40) CHARACTER SET LATIN NOT CASESPECIFIC,
       Dimensie4_id INTEGER,
       Dimensie5_id INTEGER,
       CUBe_product_id INTEGER,
       Min_verhouding DECIMAL(10,2),
       Min_benchmark DECIMAL(10,0),
       Min_penetratie DECIMAL(10,2),
       Adresseerbaarheid DECIMAL(10,2),
       N_met_product INTEGER,
       Baten_product DECIMAL(18,2),
       N_klanten INTEGER,
       Penetratie DECIMAL(10,4),

       Baten_benchmark DECIMAL(18,2),
       Baten_cumulatief DECIMAL(18,2),
       Percentage_cumulatief DECIMAL(10,4),
       D01 DECIMAL(18,2),
       D02 DECIMAL(18,2),
       D03 DECIMAL(18,2),
       D04 DECIMAL(18,2),
       D05 DECIMAL(18,2),
       D06 DECIMAL(18,2),
       D07 DECIMAL(18,2),
       D08 DECIMAL(18,2),
       D09 DECIMAL(18,2),
       D10 DECIMAL(18,2),
       Min_penetratie_en_klanten_ind BYTEINT
      )
UNIQUE PRIMARY INDEX ( Maand_nr, Business_line, Segment, Subsegment, Bedrijfstak_id,
                       Omzetklasse_id, Dimensie3_id, Dimensie4_id, Dimensie5_id, CUBe_product_id );



INSERT INTO Mi_temp.CUBe_benchmark_002
SELECT A.*,
       MIN(CASE
           WHEN D.CUBe_product_id IN ( 1, 2 ) AND D.Deciel_baten = 2 THEN D.Baten
           WHEN D.CUBe_product_id NOT IN ( 1, 2 ) AND D.Deciel_baten = 3 THEN D.Baten
           ELSE NULL
           END)  Baten_benchmark,
       MAX(CASE
           WHEN D.CUBe_product_id IN ( 1, 2 ) AND D.Deciel_baten = 2 THEN D.Cumulatieve_baten
           WHEN D.CUBe_product_id NOT IN ( 1, 2 ) AND D.Deciel_baten = 3 THEN D.Cumulatieve_baten
           ELSE NULL
           END)  Baten_cumulatief,
       (Baten_cumulatief (DECIMAL(18,6))) / (Baten_product (DECIMAL(18,6)))  Percentage_cumulatief,
       MIN(CASE WHEN A.N_met_product >= 10 AND D.Deciel_baten =  1 THEN D.Baten ELSE NULL END)  V01,
       MIN(CASE WHEN A.N_met_product >= 10 AND D.Deciel_baten =  2 THEN D.Baten ELSE NULL END)  V02,
       MIN(CASE WHEN A.N_met_product >= 10 AND D.Deciel_baten =  3 THEN D.Baten ELSE NULL END)  V03,
       MIN(CASE WHEN A.N_met_product >= 10 AND D.Deciel_baten =  4 THEN D.Baten ELSE NULL END)  V04,
       MIN(CASE WHEN A.N_met_product >= 10 AND D.Deciel_baten =  5 THEN D.Baten ELSE NULL END)  V05,
       MIN(CASE WHEN A.N_met_product >= 10 AND D.Deciel_baten =  6 THEN D.Baten ELSE NULL END)  V06,
       MIN(CASE WHEN A.N_met_product >= 10 AND D.Deciel_baten =  7 THEN D.Baten ELSE NULL END)  V07,
       MIN(CASE WHEN A.N_met_product >= 10 AND D.Deciel_baten =  8 THEN D.Baten ELSE NULL END)  V08,
       MIN(CASE WHEN A.N_met_product >= 10 AND D.Deciel_baten =  9 THEN D.Baten ELSE NULL END)  V09,
       MIN(CASE WHEN A.N_met_product >= 10 AND D.Deciel_baten = 10 THEN D.Baten ELSE NULL END)  V10,
       MAX(CASE WHEN A.Penetratie >= A.Min_penetratie AND A.N_met_product >= 10 THEN 1 ELSE 0 END)  Min_penetratie_en_klanten_ind
  FROM Mi_temp.CUBe_benchmark_001 A
  LEFT OUTER JOIN (SELECT A.*,
                          B.CUBe_product_id,
                          B.Baten,
                          QUANTILE( 10, B.Baten ASC, A.Klant_nr ASC) + 1  Deciel_baten,
                          CSUM(B.Baten, A.Maand_nr, A.Business_line, A.Segment, A.Subsegment,
                               A.Bedrijfstak_id, A.Omzetklasse_id, A.Dimensie3_id, A.Dimensie4_id,
                               A.Dimensie5_id, B.CUBe_product_id, B.Baten DESC)  Cumulatieve_baten
                     FROM Mi_temp.Mia_klanten A
                     LEFT OUTER JOIN Mi_temp.Mia_baten B
                       ON A.Klant_nr = B.Klant_nr AND A.Maand_nr = B.Maand_nr AND B.Baten NE 0.00
                    GROUP BY A.Maand_nr, A.Business_line, A.Segment, A.Subsegment, A.Bedrijfstak_id,
                          A.Omzetklasse_id, A.Dimensie3_id, A.Dimensie4_id, A.Dimensie5_id, B.CUBe_product_id)  D
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



COLLECT STATISTICS Mi_temp.CUBe_benchmark_002 COLUMN (Omzetklasse_id);
COLLECT STATISTICS Mi_temp.CUBe_benchmark_002 COLUMN (Omzetklasse_id, Min_penetratie_en_klanten_ind);



CREATE TABLE Mi_temp.CUBe_benchmark_003
      (
       Maand_nr INTEGER,
       Business_line VARCHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
       Segment VARCHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
       Subsegment VARCHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
       Bedrijfstak_id VARCHAR(6),
       Omzetklasse_id SMALLINT,
       Dimensie3_id VARCHAR(40) CHARACTER SET LATIN NOT CASESPECIFIC,
       Dimensie4_id INTEGER,
       Dimensie5_id INTEGER,
       CUBe_product_id INTEGER,
       Min_verhouding DECIMAL(10,2),
       Min_benchmark DECIMAL(10,0),
       Min_penetratie DECIMAL(10,2),
       Adresseerbaarheid DECIMAL(10,2),
       N_met_product INTEGER,
       Baten_product DECIMAL(18,2),
       N_klanten INTEGER,
       Penetratie DECIMAL(10,4),

       Baten_benchmark DECIMAL(18,2),
       Baten_cumulatief DECIMAL(18,2),
       Percentage_cumulatief DECIMAL(10,4),
       D01 DECIMAL(18,2),
       D02 DECIMAL(18,2),
       D03 DECIMAL(18,2),
       D04 DECIMAL(18,2),
       D05 DECIMAL(18,2),
       D06 DECIMAL(18,2),
       D07 DECIMAL(18,2),
       D08 DECIMAL(18,2),
       D09 DECIMAL(18,2),
       D10 DECIMAL(18,2),
       Min_penetratie_en_klanten_ind BYTEINT,
       Overgenomen_baten_benchmark BYTEINT
      )
UNIQUE PRIMARY INDEX ( Maand_nr, Business_line, Segment, Subsegment, Bedrijfstak_id,
                       Omzetklasse_id, Dimensie3_id, Dimensie4_id, Dimensie5_id, CUBe_product_id );



INSERT INTO Mi_temp.CUBe_benchmark_003
SELECT A.*,
       0  Overgenomen_baten_benchmark
  FROM Mi_temp.CUBe_benchmark_002 A
 WHERE A.Omzetklasse_id = 0
;INSERT INTO Mi_temp.CUBe_benchmark_003
SELECT A.*,
       0  Overgenomen_baten_benchmark
  FROM Mi_temp.CUBe_benchmark_002 A
 WHERE A.Omzetklasse_id = 1
   AND A.Min_penetratie_en_klanten_ind = 1
;INSERT INTO Mi_temp.CUBe_benchmark_003
SELECT A.*,
       0  Overgenomen_baten_benchmark
  FROM Mi_temp.CUBe_benchmark_002 A
 WHERE A.Omzetklasse_id = 2
   AND A.Min_penetratie_en_klanten_ind = 1;



COLLECT STATISTICS Mi_temp.CUBe_benchmark_003 COLUMN Min_penetratie_en_klanten_ind;
COLLECT STATISTICS Mi_temp.CUBe_benchmark_003 COLUMN Overgenomen_baten_benchmark;
COLLECT STATISTICS COLUMN (MAAND_NR ,BUSINESS_LINE ,SEGMENT , SUBSEGMENT ,BEDRIJFSTAK_ID ,DIMENSIE3_ID ,DIMENSIE4_ID,DIMENSIE5_ID , CUBE_PRODUCT_ID) ON Mi_temp.CUBe_benchmark_002;
COLLECT STATISTICS COLUMN (MAAND_NR ,BUSINESS_LINE ,SEGMENT, SUBSEGMENT ,BEDRIJFSTAK_ID ,OMZETKLASSE_ID ,DIMENSIE3_ID,DIMENSIE4_ID , DIMENSIE5_ID ,CUBE_PRODUCT_ID) ON  Mi_temp.CUBe_benchmark_002;
COLLECT STATISTICS COLUMN (OMZETKLASSE_ID) ON  Mi_temp.CUBe_benchmark_003;
COLLECT STATISTICS COLUMN (MAAND_NR ,BUSINESS_LINE ,SEGMENT , SUBSEGMENT ,BEDRIJFSTAK_ID ,OMZETKLASSE_ID ,DIMENSIE3_ID ,DIMENSIE4_ID , DIMENSIE5_ID ,CUBE_PRODUCT_ID) ON Mi_temp.CUBe_benchmark_003;
COLLECT STATISTICS COLUMN (OVERGENOMEN_BATEN_BENCHMARK ,MIN_PENETRATIE_EN_KLANTEN_IND) ON Mi_temp.CUBe_benchmark_003;



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
       1  Overgenomen_baten_benchmark
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
       0  Overgenomen_baten_benchmark
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
       1  Overgenomen_baten_benchmark
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
       0  Overgenomen_baten_benchmark
  FROM Mi_temp.CUBe_benchmark_002 A
 WHERE A.Omzetklasse_id = 4
   AND A.Min_penetratie_en_klanten_ind = 1;



COLLECT STATISTICS Mi_temp.CUBe_benchmark_003 COLUMN Min_penetratie_en_klanten_ind;
COLLECT STATISTICS Mi_temp.CUBe_benchmark_003 COLUMN Overgenomen_baten_benchmark;



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
       1  Overgenomen_baten_benchmark
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
       0  Overgenomen_baten_benchmark
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
       1  Overgenomen_baten_benchmark
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
       0  Overgenomen_baten_benchmark
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
       1  Overgenomen_baten_benchmark
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
       0  Overgenomen_baten_benchmark
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
       END  Lichtje
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
           END)  Lichtje
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
   AND A.Lichtbeheer = 1
 GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10;


INSERT INTO Mi_temp.Mia_baten_benchmarken_002
SELECT A.*
  FROM Mi_temp.Mia_baten_benchmarken_001 A
 WHERE A.CUBe_product_id NOT IN (1, 9, 25, 26)
;INSERT INTO Mi_temp.Mia_baten_benchmarken_002
SELECT A.*
  FROM Mi_temp.Mia_baten_benchmarken_001 A
 WHERE A.CUBe_product_id IN (1, 9, 25, 26)
   AND A.Lichtbeheer NE 1;




INSERT INTO Mi_temp.Mia_baten_benchmarken_003
SELECT A.Klant_nr,
       A.Maand_nr,
       25  CUBe_product_id,  /* Lease */
       NULL  Baten,
       CASE
       WHEN A.Omzetklasse_id = 0 THEN 1500
       WHEN A.Omzetklasse_id = 1 THEN 1500
       WHEN A.Omzetklasse_id = 2 THEN 3000
       WHEN A.Omzetklasse_id = 3 THEN 5000
       WHEN A.Omzetklasse_id = 4 THEN 10000
       WHEN A.Omzetklasse_id >= 5 THEN 25000
       END  Baten_benchmark,
       NULL  Penetratie,
       NULL  Min_verhouding,
       NULL  Min_benchmark,
       NULL  Min_penetratie,
       NULL  Adresseerbaarheid,
       3  Lichtje
  FROM Mi_temp.Mia_klanten A
  JOIN (SELECT XC.Klant_nr
          FROM (SELECT XXA.Contract_Nr,
                       XXA.Contract_Soort_Code
                  FROM Mi_vm_ldm.vGeld_contract_event XXA
                 WHERE XXA.Tegenrekening_nr_num IN (650010744, 586814701, 235048631, 270208305, 300072651, 4504107) /* Andere lessors */
                   AND XXA.Mutatie_bedrag_DC_ind = 'D'
                   AND XXA.Valuta_Datum >= ADD_MONTHS(DATE, -12)
                 GROUP BY 1, 2)  XA
          JOIN Mi_vm_ldm.aParty_contract XB
            ON XA.Contract_nr = XB.Contract_nr AND XA.Contract_soort_code = XB.Contract_soort_code
           AND XB.Party_sleutel_type = 'bc'
          JOIN Mi_temp.Mia_klantkoppelingen XC
            ON XB.Party_id = XC.Business_contact_nr
         GROUP BY 1)  B
    ON A.Klant_nr = B.Klant_nr
   AND A.Klant_nr NOT IN (SELECT X.Klant_nr
                            FROM Mi_temp.Mia_baten_benchmarken_003 X
                           WHERE X.CUBe_product_id = 25)  /* Lease */
;INSERT INTO Mi_temp.Mia_baten_benchmarken_003
SELECT A.Klant_nr,
       A.Maand_nr,
       26  CUBe_product_id,  /* Factoring */
       NULL  Baten,
       CASE
       WHEN A.Omzetklasse_id = 3 THEN 20000
       WHEN A.Omzetklasse_id = 4 THEN 30000
       WHEN A.Omzetklasse_id >= 5 THEN 40000
       END  Baten_benchmark,
       NULL  Penetratie,
       NULL  Min_verhouding,
       NULL  Min_benchmark,
       NULL  Min_penetratie,
       NULL  Adresseerbaarheid,
       3  Lichtje
  FROM Mi_temp.Mia_klanten A
 WHERE A.Omzetklasse_id >= 3 /* 2,5 mln omzet of meer */
   AND A.Bedrijfstak_id IN (SELECT X.Bedrijfstak_id
                              FROM MI_SAS_AA_MB_C_MB.CUBe_bedrijfstak X
                             WHERE X.Factoring = 1)
   AND A.Klant_nr NOT IN (SELECT X.Klant_nr
                            FROM Mi_temp.Mia_baten_benchmarken_003 X
                           WHERE X.CUBe_product_id = 26)  /* Factoring */
   AND A.Business_line in ('CBC', 'SME')
;INSERT INTO Mi_temp.Mia_baten_benchmarken_003
SELECT A.Klant_nr,
       A.Maand_nr,
       26  CUBe_product_id,  /* Factoring */
       NULL  Baten,
       CASE
       WHEN A.Omzetklasse_id = 3 THEN 20000
       WHEN A.Omzetklasse_id = 4 THEN 30000
       WHEN A.Omzetklasse_id >= 5 THEN 40000
       END  Baten_benchmark,
       NULL  Penetratie,
       NULL  Min_verhouding,
       NULL  Min_benchmark,
       NULL  Min_penetratie,
       NULL  Adresseerbaarheid,
       4  Lichtje
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
   AND A.Business_line in ('CBC', 'SME');



INSERT INTO Mi_temp.Mia_baten_benchmarken_003
SELECT A.Klant_nr,
       A.Maand_nr,
       12  CUBe_product_id,  /* International Cash Management */
       NULL  Baten,
       CASE
       WHEN A.Omzetklasse_id = 2 THEN 250
       WHEN A.Omzetklasse_id = 3 THEN 500
       WHEN A.Omzetklasse_id = 4 THEN 750
       WHEN A.Omzetklasse_id >= 5 THEN 1500
       END  Baten_benchmark,
       NULL  Penetratie,
       NULL  Min_verhouding,
       NULL  Min_benchmark,
       NULL  Min_penetratie,
       NULL  Adresseerbaarheid,
       3  Lichtje
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
       12  CUBe_product_id,  /* International Cash Management */
       NULL  Baten,
       CASE
       WHEN A.Omzetklasse_id = 2 THEN 250
       WHEN A.Omzetklasse_id = 3 THEN 500
       WHEN A.Omzetklasse_id = 4 THEN 750
       WHEN A.Omzetklasse_id >= 5 THEN 1500
       END  Baten_benchmark,
       NULL  Penetratie,
       NULL  Min_verhouding,
       NULL  Min_benchmark,
       NULL  Min_penetratie,
       NULL  Adresseerbaarheid,
       3  Lichtje
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
       12  CUBe_product_id,  /* International Cash Management */
       NULL  Baten,
       CASE
       WHEN A.Omzetklasse_id = 2 THEN 250
       WHEN A.Omzetklasse_id = 3 THEN 500
       WHEN A.Omzetklasse_id = 4 THEN 750
       WHEN A.Omzetklasse_id >= 5 THEN 1500
       END  Baten_benchmark,
       NULL  Penetratie,
       NULL  Min_verhouding,
       NULL  Min_benchmark,
       NULL  Min_penetratie,
       NULL  Adresseerbaarheid,
       3  Lichtje
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



COLLECT STATISTICS Mi_temp.Mia_week COLUMN Klantstatus;



INSERT INTO Mi_temp.Mia_baten_benchmarken_003
SELECT A.Klant_nr,
       A.Maand_nr,
       80  CUBe_product_id,  /* Acquisitie */
       NULL  Baten,
       NULL  Baten_benchmark,
       NULL  Penetratie,
       NULL  Min_verhouding,
       NULL  Min_benchmark,
       NULL  Min_penetratie,
       NULL  Adresseerbaarheid,
       1  Lichtje
  FROM Mi_temp.Mia_klanten A
  JOIN Mi_temp.Mia_week B
    ON A.Klant_nr = B.Klant_nr AND A.Maand_nr = B.Maand_nr
 WHERE (A.Business_line in ('CBC', 'SME'))
   AND B.Klantstatus = 'S';



INSERT INTO Mi_temp.Mia_baten_benchmarken_003
SELECT A.Cluster_nr,
       A.Maand_nr,
       81  CUBe_product_id,
       NULL  Baten,
       NULL  Baten_benchmark,
       NULL  Penetratie,
       NULL  Min_verhouding,
       NULL  Min_benchmark,
       NULL  Min_penetratie,
       NULL  Adresseerbaarheid,
       2  Lichtje
FROM Mi_cmb.CUBe_leads_hist A
  JOIN (SELECT MAX(Maand_nr)  Maand_nr
        FROM Mi_cmb.CUBe_leads_hist
        ) XX
    ON A.Maand_nr = XX.Maand_nr
  JOIN Mi_vm.vKalender XY
    ON XY.Datum = DATE
  JOIN MI_SAS_AA_MB_C_MB.Model_wegloop_hist B
    ON A.Cluster_nr = B.Klant_nr
  JOIN Mi_vm.vKalender XZ
    ON B.Week_1e_retentie_stoplicht = XZ.Jaar_week_nr
   AND XY.Dag_naam = XZ.Dag_naam

WHERE A.CUBe_product_id = 81
   AND XZ.Datum > ADD_MONTHS(XY.Datum, -3);


INSERT INTO Mi_temp.Mia_baten_benchmarken_003
SELECT A.Klant_nr,
       A.Maand_nr,
       81  CUBe_product_id,
       NULL  Baten,
       NULL  Baten_benchmark,
       NULL  Penetratie,
       NULL  Min_verhouding,
       NULL  Min_benchmark,
       NULL  Min_penetratie,
       NULL  Adresseerbaarheid,
       CASE
       WHEN A.Week_1e_retentie_stoplicht = XY.Jaar_week_nr THEN 1
       WHEN A.Retentie_stoplicht = 1 THEN 2
       ELSE 0
       END  Lichtje
FROM MI_SAS_AA_MB_C_MB.Model_wegloop_hist A
  JOIN Mi_vm_nzdb.vLU_Maand_Runs XX
    ON A.Maand_nr = XX.Maand_nr
   AND XX.Lopende_maand_ind = 1
  JOIN Mi_vm.vKalender XY
    ON XY.Datum = DATE
  LEFT OUTER JOIN (SELECT D.Cluster_nr
                   FROM Mi_cmb.CUBe_leads_hist D
                   WHERE D.CUBe_product_id = 81 GROUP BY 1
                   ) D
    ON A.Klant_nr = D.Cluster_nr
WHERE A.Retentie_stoplicht = 1
  AND D.Cluster_nr IS NULL;




INSERT INTO Mi_temp.Mia_baten_benchmarken_004
SELECT A.Klant_nr,
       A.Maand_nr,
       A.CUBe_product_id,
       A.Baten,
       CASE
       WHEN B.CUBe_product_id IN (5, 8, 12, 25, 26) AND B.Baten_benchmark > 0 AND (A.Baten_benchmark = 0 OR A.Baten_benchmark IS NULL) THEN B.Baten_benchmark
       ELSE A.Baten_benchmark
       END  Baten_benchmark,
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
       END  Lichtje
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
       END  Baten_potentieel,
       Baten_potentieel * A.Adresseerbaarheid,
       B.Status,
       B.N_mnd_status
FROM Mi_temp.Mia_baten_benchmarken_004 A

LEFT OUTER JOIN (SELECT * FROM MI_SAS_AA_MB_C_MB.CUBe_leads_hist  XA
                 QUALIFY ROW_NUMBER() OVER (PARTITION BY Klant_nr, Maand_nr, CUBe_product_id ORDER BY UUID DESC) = 1
                ) B
  ON A.Klant_nr = B.Klant_nr
 AND A.Maand_nr = B.Maand_nr
 AND A.CUBe_product_id = B.CUBe_product_id
;


INSERT INTO Mi_temp.Mia_baten_benchmarken_006
SELECT A.Klant_nr
  FROM Mi_temp.Mia_baten_benchmarken_005 A
  LEFT OUTER JOIN MI_SAS_AA_MB_C_MB.CUBe_producten D
    ON A.CUBe_product_id = D.CUBe_product_id
 GROUP BY 1;


INSERT INTO Mi_temp.CUBe_baten
SELECT A.Klant_nr,
       A.Maand_nr,
       A.Datum_gegevens,
       E.Maand_SDAT  Datum_baten,
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
       B.CBI_cmts_baten  Buitenland_CBI_baten,
       ZEROIFNULL(B.Acquisitie_stoplicht),
       B.Acquisitie_status,
       ZEROIFNULL(B.Retentie_stoplicht),
       B.Retentie_status
  FROM Mi_temp.Mia_week A
  LEFT OUTER JOIN Mi_temp.Mia_baten_benchmarken_006 B
    ON A.Klant_nr = B.Klant_nr
  JOIN MI_SAS_AA_MB_C_MB.Mia_periode  D
    ON A.Maand_nr = D.Maand_nr
  LEFT OUTER JOIN Mi_vm.vLu_maand E
    ON D.Maand_einde_jaar = E.Maand
 WHERE (A.Klant_ind = 1 OR Klantstatus = 'S');




INSERT INTO Mi_temp.CUBe_leadstatus
SELECT A.Klant_nr,
       A.Maand_nr,
       A.Datum_gegevens,
       E.Maand_SDAT  Datum_baten,
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
  JOIN MI_SAS_AA_MB_C_MB.Mia_periode  D
    ON A.Maand_nr = D.Maand_nr
  LEFT OUTER JOIN Mi_vm.vLu_maand E
    ON D.Maand_einde_jaar = E.Maand
 WHERE (A.Klant_ind = 1 OR Klantstatus = 'S');


INSERT INTO MI_SAS_AA_MB_C_MB.CIAA_Cube_Baten_hist 
SELECT *
  FROM Mi_temp.CUBe_baten;

INSERT INTO Mi_cmb.CUBe_leadstatus_hist
SELECT *
  FROM Mi_temp.CUBe_leadstatus;

INSERT INTO MI_SAS_AA_MB_C_MB.CUBe_model
SELECT *
  FROM Mi_temp.CUBe_benchmark_003;






INSERT INTO Mi_temp.Part_zak_periode SELECT (SELECT MAX(Maand)  Maand_FHH FROM Mi_vm_info.vLU_FHH), (SELECT MAX(Maand)  Maand_PBNL FROM Mi_vm_info.vLU_PBNL);



CREATE TABLE Mi_temp.Part_zak_t1_BC
AS
(
SELECT  a.Maand_nr
    ,a.Klant_nr
    ,a.Klantstatus
    ,a.Klant_ind
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
) WITH DATAPRIMARY INDEX(Klant_nr);


INSERT INTO Mi_temp.Part_zak_t1_BC
SELECT  a.Maand_nr
    ,a.Klant_nr
,a.Klantstatus
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
SELECT a.Part_BC_nr
        ,MAX(CASE WHEN b.Party_Contract_rol_code = 'C' AND c.Product_id > 1 THEN 1 ELSE 0 END)  Contractant_ind
        ,MAX(CASE WHEN b.Party_Contract_rol_code = 'G' THEN 1 ELSE 0 END)  Gemachtigd_ind

FROM Mi_temp.Part_zak_t1_BC a

LEFT OUTER JOIN mi_vm_ldm.aParty_contract b
   ON b.Party_id = a.Part_BC_nr
  AND b.Party_sleutel_type = 'BC'

LEFT OUTER JOIN mi_vm_ldm.aContract c
   ON c.Contract_nr = b.Contract_nr
  AND c.Contract_soort_code = b.Contract_soort_code
  AND c.Contract_hergebruik_volgnr = b.Contract_hergebruik_volgnr

WHERE c.Contract_status_code <> 3
GROUP BY 1
) WITH DATA PRIMARY INDEX(Part_BC_nr);



CREATE TABLE Mi_temp.Part_zak_BC AS
(SELECT
     a.*
    ,ZEROIFNULL(b.Contractant_ind)  Contractant_ind
    ,ZEROIFNULL(b.Gemachtigd_ind)   Gemachtigd_ind

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
FROM
      (
      SELECT  a.FHH
             ,a.Klant_nr
             ,a.Maand_nr
             ,a.Klantstatus
             ,a.Klant_ind
               ,MIN(Relatie_oms)  FHH_relatie_oms
      FROM Mi_temp.Part_zak_t1_BC a
      WHERE a.PBNL IS NULL
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

  ) WITH DATA PRIMARY INDEX(Klant_nr);




INSERT INTO Mi_temp.Part_zak_FHH
SELECT
        a.Klant_nr
       ,a.Maand_nr
       ,a.Klantstatus
FROM
      (
      SELECT  a.PBNL
             ,a.Klant_nr
             ,a.Maand_nr
             ,a.Klantstatus
             ,a.Klant_ind
               ,MIN(Relatie_oms)  FHH_relatie_oms
      FROM Mi_temp.Part_zak_t1_BC a
      WHERE ZEROIFNULL(a.PBNL) > 0
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




INSERT INTO MI_SAS_AA_MB_C_MB.CIAA_Part_zak 
SEL
     Klant_nr
    ,Maand_nr
    ,Klantstatus
FROM Mi_temp.Part_zak_FHH
GROUP BY 1,2,3,4
;


CREATE TABLE MI_temp.CIAA_Beleggen_t1
AS
(
SELECT   Mnd.Maand_nr
        ,BC.Klant_nr                                         Klant_nr
        ,ICFP.CBC_nr                                         BC_nr
        ,MAX(CASE WHEN (ZEROIFNULL(MC.Statuten_afwezig_ind         ) +
                        ZEROIFNULL(MC.Statuten_niet_gecheckt_ind   ) +
                        ZEROIFNULL(MC.Jaarcijfers_afwezig_ind      ) +
                        ZEROIFNULL(MC.Jaarcijfers_niet_gecheckt_ind) +
                        ZEROIFNULL(MC.Jaarcijfers_niet_recent_ind  )  ) >= 1 THEN 1
                  ELSE 0
             END)                                             Zorgplicht_signaal
        ,MAX(ZEROIFNULL(MC.Statuten_Afwezig_Ind          ))   Statuten_Afwezig_Ind
        ,MAX(ZEROIFNULL(MC.Statuten_Niet_Gecheckt_Ind    ))   Statuten_Niet_Gecheckt_Ind
        ,MAX(ZEROIFNULL(MC.Jaarcijfers_Afwezig_Ind       ))   Jaarcijfers_Afwezig_Ind
        ,MAX(ZEROIFNULL(MC.Jaarcijfers_Niet_Gecheckt_Ind ))   Jaarcijfers_Niet_Gecheckt_Ind
        ,MAX(ZEROIFNULL(MC.Jaarcijfers_Niet_Recent_Ind   ))   Jaarcijfers_Niet_Recent_Ind
        ,MAX(CASE WHEN ZEROIFNULL(ICFP.Totaal_belegd_vermogen) = 0 THEN 0 ELSE 1 END)  Actie_vereist

FROM Mi_vm_nzdb.vEff_Contract_Feiten_Periode              ICFP

INNER JOIN MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr  Mnd
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

INNER JOIN MI_SAS_AA_MB_C_MB.Mia_klantkoppelingen_hist     BC
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
FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_hist      MIa

INNER JOIN MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr  Mnd
   ON mnd.Maand_nr = MIa.Maand_nr

LEFT OUTER JOIN MI_vm.vClientgroep clntgrp
   ON clntgrp.Clientgroep = MIa.Clientgroep

INNER JOIN MI_vm_nzdb.vCC_Eff_Feiten_Periode       a
   ON MIa.Klant_nr = a.cc_nr
  AND MIa.Maand_nr = a.Maand_nr

INNER JOIN
            (
            SELECT
                    bc.Klant_nr  cc_nr
                   ,bc.maand_nr
                   ,COUNT(DISTINCT(contract_oid))   N_stand_eff_contr
            FROM MI_vm_nzdb.vEff_Contract_Feiten_Periode a

            INNER JOIN MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr  Mnd
               ON mnd.Maand_nr = a.Maand_nr
              AND mnd.N_maanden_terug = 0

            INNER JOIN MI_SAS_AA_MB_C_MB.Mia_klantkoppelingen_hist     BC
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
LEFT OUTER JOIN
                (
                 SELECT  bc.Klant_nr  cc_nr
                 FROM MI_vm_nzdb.vEff_Contract_Vermogen a

                 INNER JOIN MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr  Mnd
                    ON mnd.Maand_nr = a.Maand_nr
                   AND mnd.N_maanden_terug = 0

                 INNER JOIN MI_SAS_AA_MB_C_MB.Mia_klantkoppelingen_hist     BC
                    ON bc.business_contact_nr = a.CBC_nr
                   AND bc.Maand_nr = a.Maand_nr

                 WHERE a.Standaard_contract_ind = 1
                 GROUP BY 1,2
                 ) b
   ON b.Maand_nr = a.Maand_nr
  AND b.CC_nr = a.CC_nr
LEFT OUTER JOIN (SELECT bc.Klant_nr  cc_nr
                 FROM MI_vm_nzdb.vEff_Contract_Transacties    a

                 INNER JOIN MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr  Mnd
                    ON mnd.Maand_nr = a.Maand_nr
                   AND mnd.N_maanden_terug = 0

                 INNER JOIN MI_SAS_AA_MB_C_MB.Mia_klantkoppelingen_hist     BC
                    ON bc.business_contact_nr = a.CBC_nr
                   AND bc.Maand_nr = a.Maand_nr

                 WHERE a.Standaard_contract_ind = 1
                   AND a.uitlevering_ontvangst_code IS NULL
                 GROUP BY 1,2
                ) c
   ON c.Maand_nr = a.Maand_nr
  AND c.CC_nr = a.CC_nr
LEFT OUTER JOIN (SELECT bc.Klant_nr  cc_nr
                 FROM MI_vm_nzdb.vEff_Contract_Transacties    a

                 INNER JOIN MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr  Mnd
                    ON mnd.Maand_nr = a.Maand_nr
                   AND mnd.N_maanden_terug = 0

                 INNER JOIN MI_SAS_AA_MB_C_MB.Mia_klantkoppelingen_hist     BC
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
                SELECT *
                FROM  Mi_temp.Part_zak_BC
                GROUP BY 1,2
                QUALIFY RANK (Relatie_oms ASC, Part_bc_CGC DESC, Part_BC_nr DESC) = 1
                ) g
  ON g.Klant_nr = a.CC_nr
LEFT OUTER JOIN
                 (
                  SELECT  a.Klant_nr
                  FROM MI_SAS_AA_MB_C_MB.CIAA_beleggen    a

                  INNER JOIN MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr     b
                     ON a.Maand_nr = b.Maand_nr

                  WHERE b.N_maanden_terug BETWEEN 1 AND 3
                    AND a.Zorgplicht_signaal = 'ja'
                  GROUP BY 1
                  HAVING COUNT(*) = 3
                 ) h
  ON h.Klant_nr = Mia.Klant_nr

LEFT OUTER JOIN (SELECT  Maand_nr
                     ,Klant_nr
                     ,COUNT(DISTINCT BC_nr)  N_BC_zorgplicht
                     ,MAX(BC_nr)             BC_nr_zorgplicht
                     ,MAX(Actie_vereist)     Zorgplicht_Actie_vereist
                 FROM MI_temp.CIAA_Beleggen_t1
                 WHERE Actie_vereist = 1
                 GROUP BY 1,2
                 ) i
    ON i.Maand_nr = Mia.Maand_nr
   AND i.Klant_nr = Mia.Klant_nr

WHERE Mia.Klant_ind = 1
  AND Mia.Clientgroep < 1300
  AND Mnd.N_maanden_terug = 0
) WITH DATA UNIQUE PRIMARY INDEX (Maand_nr, Klant_nr);

INSERT INTO MI_SAS_AA_MB_C_MB.CIAA_beleggen 
SELECT a.*
FROM MI_temp.CIAA_Beleggen;


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
SELECT    a.Datum_gegevens
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
SELECT
     a.maand
    ,a.maand_sdat
    ,a.maand_edat
    ,( (CAST (a.maand_edat  TIMESTAMP(6)))  + INTERVAL '1' DAY  ) - INTERVAL '1' SECOND  Maand_edat_timestmp

    ,g.KEM_gegevens_datum
    ,( (CAST (g.KEM_gegevens_datum     TIMESTAMP(6)))  + INTERVAL '1' DAY  ) - INTERVAL '1' SECOND  KEM_gegevens_timestmp

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

INNER JOIN MI_SAS_AA_MB_C_MB.Mia_periode  per
   ON a.maand = per.Maand_nr

INNER JOIN  Mi_vm.vlu_maand  c
   ON c.Maand = a.MaandNrLY

INNER JOIN  Mi_vm.vlu_maand  d
   ON d.Maand = a.MaandNrL3M

INNER JOIN  Mi_vm.vlu_maand  e
   ON e.Maand = a.MaandNrL6M

INNER JOIN  Mi_vm.vlu_maand  f
   ON f.Maand = a.MaandNrLM

INNER JOIN (SELECT MAX(CAST (  SUBSTR( (TRIM(BOTH FROM (CASE WHEN SUBSTR(timestamp_created,1,4) = '0001' THEN NULL ELSE timestamp_created END) )) ,1,10)   DATE FORMAT 'YYYY-MM-DD'))  KEM_gegevens_datum
            FROM mi_vm_load.vTWK_3_KRD_V_STAT
            ) g
  ON 1=1;



UPDATE  Mi_temp.KEM_funnel_rapp_moment
FROM(SELECT MAX(a.Maand_nr)  Maand_nr
     FROM mi_cmb.vCIF_complex_MF a

     INNER JOIN Mi_temp.KEM_funnel_rapp_moment per
        ON 1 = 1

     WHERE  a.Maand_nr <= per.Maand_nr
     ) a

SET Max_maand_Mia_kred = a.Maand_nr
;


CREATE TABLE Mi_temp.KEM_funnel_t1a AS
  (SELECT
      a.fk_aanvr_wkmid
     ,a.fk_aanvr_versie
     ,a.Status  KEM_status
     ,d.KEM_status_nr
     ,d.Funnel_stap_oms  Funnel_stap
FROM mi_vm_load.vTWK_3_KRD_V_STAT  a
LEFT OUTER JOIN MI_SAS_AA_MB_C_MB.KEM_LU_funnel d
   ON TRIM(a.Status) = TRIM(d.Kem_status_oms)
) WITH DATA
UNIQUE PRIMARY INDEX (fk_aanvr_wkmid, fk_aanvr_versie, KEM_status_nr)
;


CREATE TABLE Mi_temp.KEM_funnel_t1b
AS
(
SELECT
     a.FK_AANVR_WKMID
    ,a.FK_AANVR_VERSIE
    ,a.KEM_status
    ,a.Kem_status_nr
    ,a.Funnel_stap
    ,a.Funnel_stap_nr
    ,CASE WHEN a.Volgnr_chrono_old  = 1 AND b.Aanvraag_versie_sdat < a.Date_created_stap THEN   CAST(b.Aanvraag_versie_sdat  TIMESTAMP(6))
          ELSE a.Timestamp_created_stap
     END (TIMESTAMP)  Timestamp_created_stap
    ,CASE WHEN a.Volgnr_chrono_old  = 1 AND b.Aanvraag_versie_sdat < a.Date_created_stap THEN b.Aanvraag_versie_sdat
          ELSE a.Date_created_stap
     END  Date_created_stap
    ,a.Volgnr_chrono_old 
    ,CAST(b.Aanvraag_versie_sdat  TIMESTAMP(6))   Timestamp_aanvraag
    ,b.Aanvraag_versie_sdat        Date_aanvraag

FROM Mi_temp.KEM_funnel_t1a a
LEFT OUTER JOIN
           (SELECT  wkm_id
                    ,MIN(CAST (  SUBSTR( (TRIM(BOTH FROM (CASE WHEN SUBSTR(DATE_TIME_CREATED,1,4) = '0001' THEN NULL ELSE DATE_TIME_CREATED END) )) ,1,10)   DATE FORMAT 'YYYY-MM-DD'))  Aanvraag_versie_sdat
                   ,MAX(doelgroep_code)     Doelgroep
            FROM mi_vm_load.vTWK_3_KREDIET_AANV
            GROUP BY 1
            )    b
   ON a.fk_aanvr_wkmid = b.wkm_id
) WITH DATA
UNIQUE PRIMARY INDEX (fk_aanvr_wkmid, fk_aanvr_versie, KEM_status_nr)
;

UPDATE Mi_temp.KEM_funnel_t1b
FROM
     (
     SELECT  a.FK_AANVR_WKMID
        , a.Timestamp_created_stap
     FROM  Mi_temp.KEM_funnel_t1b       a
     WHERE a.Volgnr_chrono_old  = 1
       AND a.FK_AANVR_VERSIE = 1
       AND a.Date_created_stap = a.Date_aanvraag
       AND a.Timestamp_created_stap <> a.Timestamp_aanvraag
     GROUP BY 1,2
     ) a

SET Timestamp_aanvraag = a.Timestamp_created_stap
WHERE Mi_temp.KEM_funnel_t1b.FK_AANVR_WKMID = a.FK_AANVR_WKMID;

CREATE TABLE Mi_temp.KEM_funnel_t1c
AS
(
SELECT
      a.FK_AANVR_WKMID
     ,a.FK_AANVR_VERSIE
     ,a.KEM_status
     ,a.Kem_status_nr
     ,a.Funnel_stap
FROM Mi_temp.KEM_funnel_t1b  a

INNER JOIN Mi_temp.KEM_funnel_rapp_moment per
   ON 1 = 1

INNER JOIN (
            SELECT  FK_AANVR_WKMID
                ,MAX(a.fk_aanvr_versie)  Max_fk_aanvr_versie
            FROM Mi_temp.KEM_funnel_t1b a

            INNER JOIN Mi_temp.KEM_funnel_rapp_moment per
               ON 1 = 1
            WHERE a.Date_created_stap <= per.Maand_edat
            GROUP BY 1
            ) b
   ON a.fk_aanvr_wkmid = b.fk_aanvr_wkmid
  AND a.fk_aanvr_versie = b.Max_fk_aanvr_versie
WHERE a.Date_created_stap <= per.Maand_edat
) WITH DATA
UNIQUE PRIMARY INDEX (fk_aanvr_wkmid, fk_aanvr_versie, KEM_status_nr);

CREATE TABLE Mi_temp.KEM_funnel_t1d
AS
(
SELECT
     a.FK_AANVR_WKMID
    ,a.FK_AANVR_VERSIE
    ,'KEM'                (CHAR(6))      Soort_pijplijn
    ,a.KEM_status         (VARCHAR(40))  Status
    ,a.Kem_status_nr                     Status_nr
    ,a.Timestamp_created_stap
    ,a.Date_created_stap
    ,a.Volgnr_chrono_old 
    ,a.Volgnr_chrono _old
    ,a.Timestamp_aanvraag
    ,a.Date_aanvraag
FROM Mi_temp.KEM_funnel_t1c a
) WITH DATA
UNIQUE PRIMARY INDEX (fk_aanvr_wkmid, fk_aanvr_versie, Soort_pijplijn, Status_nr)
;



INSERT INTO Mi_temp.KEM_funnel_t1d
SELECT
     a.FK_AANVR_WKMID
    ,a.FK_AANVR_VERSIE
    ,'Funnel'                       Soort_pijplijn
    ,a.Funnel_stap
    ,a.Funnel_stap_nr
    ,MIN(a.Timestamp_created_stap)  Timestamp_created_stapX
    ,MIN(a.Date_created_stap)       Date_created_stapX
    ,RANK() OVER (PARTITION BY a.fk_aanvr_wkmid, a.fk_aanvr_versie ORDER BY Timestamp_created_stapX ASC)  Volgnr_chrono_old  /* !! op timestamp gesorteerd */
    ,RANK() OVER (PARTITION BY a.fk_aanvr_wkmid, a.fk_aanvr_versie ORDER BY Timestamp_created_stapX DESC)  Volgnr_chrono _old /* !! op timestamp gesorteerd */
    ,MIN(a.Timestamp_aanvraag)
    ,MIN(a.Date_aanvraag)
FROM Mi_temp.KEM_funnel_t1c a
GROUP BY 1,2,3,4,5
;


CREATE TABLE Mi_temp.KEM_funnel_t2
AS
(
SELECT
      a.FK_AANVR_WKMID
     ,a.FK_AANVR_VERSIE
     ,per.Maand_Nr
     ,per.KEM_gegevens_datum
     ,a.Soort_pijplijn
     ,a.Status
     ,a.Status_nr
     ,a.Timestamp_created_stap
     ,a.Date_created_stap
FROM Mi_temp.KEM_funnel_t1d   a
INNER JOIN Mi_temp.KEM_funnel_rapp_moment per
   ON 1 = 1
) WITH DATA
UNIQUE PRIMARY INDEX (fk_aanvr_wkmid, fk_aanvr_versie, Soort_pijplijn, Status_nr);

UPDATE Mi_temp.KEM_funnel_t2
FROM
     (
     SELECT  a.fk_aanvr_wkmid
         ,a.fk_aanvr_versie
         ,a.Soort_pijplijn
         ,CASE WHEN a.Status_nr >=89  AND a.Date_created_stap < per.Maand_sdat THEN 0
               ELSE 1
          END  Stap_actueel_indX

     FROM Mi_temp.KEM_funnel_t2 a

     INNER JOIN Mi_temp.KEM_funnel_rapp_moment per
        ON 1 = 1

     WHERE a.Volgnr_chrono _old = 1
       AND Stap_actueel_indX = 1
     ) a

SET Stap_actueel_ind = a.Stap_actueel_indX
WHERE Mi_temp.KEM_funnel_t2.fk_aanvr_wkmid = a.fk_aanvr_wkmid
  AND Mi_temp.KEM_funnel_t2.fk_aanvr_versie = a.fk_aanvr_versie
  AND Mi_temp.KEM_funnel_t2.Soort_pijplijn = a.Soort_pijplijn
  AND Mi_temp.KEM_funnel_t2.Volgnr_chrono _old = 1;

UPDATE Mi_temp.KEM_funnel_t2
FROM
     (
     SELECT  a.fk_aanvr_wkmid
         ,a.fk_aanvr_versie
         ,a.Soort_pijplijn
         ,a.Volgnr_chrono _old
         ,1  Stap_3mnd_indX

     FROM Mi_temp.KEM_funnel_t2 a

     INNER JOIN Mi_temp.KEM_funnel_rapp_moment per
        ON 1 = 1

     WHERE (a.Date_created_stap > per.Maand_L3m_edat

            OR (a.Date_created_stap <= per.Maand_L3m_edat
                AND a.Volgnr_chrono _old = 1
                AND ZEROIFNULL(a.Status_nr) < 89
                )
            )
     ) a
SET Stap_3mnd_ind = a.Stap_3mnd_indX
WHERE Mi_temp.KEM_funnel_t2.fk_aanvr_wkmid = a.fk_aanvr_wkmid
  AND Mi_temp.KEM_funnel_t2.fk_aanvr_versie = a.fk_aanvr_versie
  AND Mi_temp.KEM_funnel_t2.Soort_pijplijn = a.Soort_pijplijn
  AND Mi_temp.KEM_funnel_t2.Volgnr_chrono _old = a.Volgnr_chrono _old
;

UPDATE Mi_temp.KEM_funnel_t2
FROM
     (
     SELECT  a.fk_aanvr_wkmid
         ,a.fk_aanvr_versie
         ,a.Soort_pijplijn
         ,a.Volgnr_chrono _old
         ,1  Stap_6mnd_indX

     FROM Mi_temp.KEM_funnel_t2 a

     INNER JOIN Mi_temp.KEM_funnel_rapp_moment per
        ON 1 = 1

     WHERE (a.Date_created_stap > per.Maand_L6m_edat

            OR (a.Date_created_stap <= per.Maand_L6m_edat
                AND a.Volgnr_chrono _old = 1
                AND ZEROIFNULL(a.Status_nr) < 89
                )
            )
     ) a

SET Stap_6mnd_ind = a.Stap_6mnd_indX
WHERE Mi_temp.KEM_funnel_t2.fk_aanvr_wkmid = a.fk_aanvr_wkmid
  AND Mi_temp.KEM_funnel_t2.fk_aanvr_versie = a.fk_aanvr_versie
  AND Mi_temp.KEM_funnel_t2.Soort_pijplijn = a.Soort_pijplijn
  AND Mi_temp.KEM_funnel_t2.Volgnr_chrono _old = a.Volgnr_chrono _old
;

UPDATE Mi_temp.KEM_funnel_t2
FROM
     (
     SELECT  a.fk_aanvr_wkmid
         ,a.fk_aanvr_versie
         ,a.Soort_pijplijn
         ,a.Volgnr_chrono _old
         ,1  Stap_12mnd_indX

     FROM Mi_temp.KEM_funnel_t2 a

     INNER JOIN Mi_temp.KEM_funnel_rapp_moment per
        ON 1 = 1

     WHERE (a.Date_created_stap > per.Maand_L12m_edat

            OR (a.Date_created_stap <= per.Maand_L12m_edat
                AND a.Volgnr_chrono _old = 1
                AND ZEROIFNULL(a.Status_nr) < 89
                )
            )
     ) a

SET Stap_12mnd_ind = a.Stap_12mnd_indX
WHERE Mi_temp.KEM_funnel_t2.fk_aanvr_wkmid = a.fk_aanvr_wkmid
  AND Mi_temp.KEM_funnel_t2.fk_aanvr_versie = a.fk_aanvr_versie
  AND Mi_temp.KEM_funnel_t2.Soort_pijplijn = a.Soort_pijplijn
  AND Mi_temp.KEM_funnel_t2.Volgnr_chrono _old = a.Volgnr_chrono _old
;


INSERT INTO Mi_temp.KEM_funnel_faciliteit
SELECT
     a.fk_aanvr_wkmid
    ,a.fk_aanvr_versie
    ,a.Totaal_kredieten_b   Faciliteit_kort_bestaand
    ,a.Totaal_kredieten_g   Faciliteit_kort_gevraagd
    ,a.Bestaande_obsi_vta   OBSI_bestaand
    ,a.Gewenste_obsi_vta    OBSI_gevraagd
    ,a.BESTAANDE_LEASE_AA   Lease_AA_bestaand
    ,a.GEWENSTE_LEASE_AA    Lease_AA_gevraagd
    ,a.Bestaande_leningen   Leningen_lang_bestaand
    ,a.Gewenste_leningen    Leningen_lang_gevraagd
    ,a.Totaal_faciliteite   Financiering_lang_bestaand
    ,a.Totaal_faciliteit0   Financiering_lang_gevraagd
    ,a.Totaal_one_obligo0   One_Obligor_lang_bestaand
    ,a.Totaal_one_obligor   One_Obligor_lang_gevraagd
    ,a.totaal_6_maand_afl   Totaal6mnds_aflossing
    ,a.MAX_BSK              BSK_max
    ,a.BSK_DEKKINGSTEKORT   BSK_dekkingstekort

FROM MI_SAS_AA_MB_C_MB.CIAA_TWK_3_FAC    a

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
(SELECT
     a.FK_AANVR_WKMID
    ,a.FK_AANVR_VERSIE
    ,(CASE WHEN SUBSTR(a.DATUM_RAPPORT,7,4) = '0001' THEN NULL
           ELSE CAST(SUBSTRING( a.DATUM_RAPPORT FROM 1 FOR 2) ||
                     SUBSTRING( a.DATUM_RAPPORT FROM 4 FOR 2) ||
                     SUBSTRING( a.DATUM_RAPPORT FROM 7 FOR 4)
                       DATE  FORMAT 'DDMMYYYY' )
      END)  Date_jaarrekening
    ,c.BEDRIJFSOMZET        Bedrijfsomzet
    ,c.INKOOPWAARDE         Inkoopwaarde
    ,c.TOEGEVOEGDE_WAARDE   Toegevoegde_waarde
    ,c.PERSONEELSKOSTEN     Personeelskosten
    ,c.BEDRIJFSKOSTEN       Bedrijfskosten
    ,c.BRUTO_RESULTAAT      Bruto_resultaat
    ,c.AFSCHRIJVINGEN       Afschrijvingen
    ,c.RENTELASTEN          Rentelasten
    ,c.OVERIGE_BATEN_EN_L   Overige_baten_en_l
    ,c.BEDRIJFSRESULTAAT    Bedrijfsresultaat
    ,c.INCIDENTELE_BATEN    Incidentele_baten
    ,c.BELASTINGEN          Belastingen
    ,c.WINST_EN_VERLIES_N   Winst_en_verlies_n
    ,c.SALDO_UITKERING      Saldo_uitkering
    ,c.UITKERING            Uitkering
    ,c.INGEHOUDEN_WINST_E   Ingehouden_winst_e
    ,c.GECORR_RENTELASTEN   Gecorr_rentelasten

FROM mi_vm_load.vTWK_3_JAARREKENIN            a
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
) WITH DATA
UNIQUE PRIMARY INDEX ( fk_aanvr_wkmid, fk_aanvr_versie );


INSERT INTO mi_temp.KEM_funnel_PRCDTL_KRDVS
SELECT
     a.fk_aanvr_wkmid
    ,a.fk_aanvr_versie
    ,a.Credit_RARORAC_indicatief
    ,a.Credit_RARORAC_fiat
FROM(SELECT
          a.fk_aanvr_wkmid
      FROM mi_vm_load.vTWK_3_PRCDTL_KRDVS a
      INNER JOIN (SELECT
                       a.fk_aanvr_wkmid
                      ,a.fk_aanvr_versie
                  FROM Mi_temp.KEM_funnel_t2  a
                  GROUP BY 1,2
                 ) b
         ON b.FK_AANVR_WKMID = a.FK_AANVR_WKMID
        AND B.fk_aanvr_versie = A.fk_aanvr_versie
      GROUP BY 1,2
     ) a;

INSERT INTO Mi_temp.KEM_funnel_KENMERK_P_KR
SEL
      a.fk_aanvr_wkmid   WKM_ID
     ,a.fk_aanvr_versie  Versie_nummer
     ,TRIM(BOTH FROM a.FK_type_kenm_code )
     ,TRIM(BOTH FROM a.FK_TYPE_KENM_DLG_C)
     ,TRIM(BOTH FROM a.FK_TYPE_KENM_VST_T)
FROM mi_vm_load.vTWK_3_KENMERK_P_KR    a
INNER JOIN (SEL
                 a.fk_aanvr_wkmid
                ,a.fk_aanvr_versie
            FROM Mi_temp.KEM_funnel_t2  a
            GROUP BY 1,2
           ) b
   ON b.FK_AANVR_WKMID = a.FK_AANVR_WKMID
  AND B.fk_aanvr_versie = A.fk_aanvr_versie

GROUP BY a.fk_aanvr_wkmid, a.fk_aanvr_Versie
QUALIFY RANK (CASE WHEN TRIM(BOTH FROM a.FK_type_kenm_code ) = 'XL' THEN 1 ELSE 0 END DESC, a.date_time_created DESC, a.date_time_last_upd DESC ) = 1;

CREATE TABLE Mi_temp.KEM_funnel_t3
AS (
SELECT
     a.fk_aanvr_wkmid
    ,a.fk_aanvr_versie
    ,per.Maand_Nr
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
                 ,a.USERID_CREATOR       UserID_laatste_stap
                 ,a.BO_NUMMER_CREATOR    BOnr_laatste_stap
                /* per status een rij */
            FROM mi_vm_load.vTWK_3_KRD_V_STAT  a

            INNER JOIN Mi_temp.KEM_funnel_rapp_moment per
               ON 1 = 1
            WHERE (CAST (  SUBSTR( (TRIM(BOTH FROM (CASE WHEN SUBSTR(a.TIMESTAMP_CREATED,1,4) = '0001' THEN NULL ELSE a.TIMESTAMP_CREATED END) )) ,1,10)   DATE FORMAT 'YYYY-MM-DD'))  < per.Maand_sdat
            QUALIFY RANK (TIMESTAMP_CREATED DESC) = 1
            GROUP BY 1,2
            ) c
   ON a.fk_aanvr_wkmid = c.fk_aanvr_wkmid
  AND a.fk_aanvr_versie = c.fk_aanvr_versie
LEFT OUTER JOIN (
                  SELECT  a.*
                      ,b.Date_aanvraag
                      ,b.date_created_stap
                      ,a.BC_NUMMER_HFDK         Voorstel_BCnr_hfdrek_nr
                      ,a.CGC_CODE               Voorstel_BC_CGC
                      ,TRIM(d.Segment_id) (INTEGER)  Voorstel_BC_CGC_einde
                      ,a.HOOFDREKENING_NUMM     Voorstel_Hoofdrekening_nr
                      ,c.Gerelateerd_party_id   Klant_nr
                      ,c.Party_party_relatie_Sdat
                      ,c.Party_party_relatie_Edat
                  FROM mi_vm_load.vTWK_3_KRD_VOORSTEL a

                  LEFT OUTER JOIN Mi_temp.KEM_funnel_t2  b
                     ON b.fk_aanvr_wkmid = a.fk_aanvr_wkmid
                    AND b.fk_aanvr_versie = a.fk_aanvr_versie
                  LEFT OUTER JOIN  mi_vm_ldm.vparty_party_relatie c
                     ON c.Party_id = a.BC_NUMMER_HFDK
                    AND c.Party_sleutel_type = 'BC'
                    AND c.gerelateerd_party_sleutel_type = 'CC'
                    AND c.party_relatie_type_code IN ('CBCTCC')
                    AND c.Party_party_relatie_Sdat <= b.date_created_stap
                    AND (c.Party_party_relatie_Edat >=  b.Date_aanvraag OR c.Party_party_relatie_Edat IS NULL)
                  LEFT OUTER JOIN  mi_vm_ldm.vSegment_klant d
                     ON d.Party_id = a.BC_NUMMER_HFDK
                    AND d.Party_sleutel_type = 'BC'
                    AND d.Segment_type_code = 'CG'
                    AND d.Segment_klant_Sdat <= b.date_created_stap
                    AND (d.Segment_klant_Edat >=  b.date_created_stap OR d.Segment_klant_Edat IS NULL)

                  WHERE b.Soort_pijplijn = 'Funnel'
                    AND b.volgnr_chrono _old = 1
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
LEFT OUTER JOIN
                (SELECT
                      TO_NUMBER(d.Hoofdrekening) (INTEGER)  Contract_nr
                     ,d.Maand_nr
                     ,MAX(TO_NUMBER(d.Fac_bc_nr))  BC_nr
                     ,MAX(e.Klant_nr)  Klant_nr
                     ,SUM(ZEROIFNULL(d.OOE))  OOE
                     ,SUM(ZEROIFNULL(d.Doorlopend_Limiet))  Limiet_krediet
                     ,SUM(ZEROIFNULL(d.Doorlopend_saldo))  Saldo_doorlopend
                     ,1  Bron_ACBS_ind
                     ,MAX(ZEROIFNULL(CASE WHEN ZEROIFNULL(d.Doorlopend_debet_limiet) > 0 THEN 1 ELSE 0 END ))  Saldocompensatie_ind
                     ,MIN(d.Datum_ingang)  Ingangdatum_krediet
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
LEFT OUTER JOIN
                (SEL
                      TO_NUMBER(d.Contract_nr) (INTEGER)  Contract_nr
                     ,d.Maand_nr
                     ,MAX(TO_NUMBER(d.Fac_bc_nr))  BC_nr
                     ,MAX(e.Klant_nr)  Klant_nr
                     ,SUM(ZEROIFNULL(d.OOE))  OOE
                     ,SUM(ZEROIFNULL(d.Doorlopend_Limiet))  Limiet_krediet
                     ,SUM(ZEROIFNULL(d.Doorlopend_saldo))  Saldo_doorlopend
                     ,1  Bron_ACBS_ind
                     ,MAX(ZEROIFNULL(CASE WHEN ZEROIFNULL(d.Doorlopend_debet_limiet) > 0 THEN 1 ELSE 0 END ))  Saldocompensatie_ind
                     ,MIN(d.Datum_ingang)  Ingangdatum_krediet
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
LEFT OUTER JOIN
                (SEL
                      TO_NUMBER(d.Fac_bc_nr)  BC_nr
                     ,d.Maand_nr
                     ,SUM(ZEROIFNULL(d.OOE))  OOE
                     ,SUM(ZEROIFNULL(d.Doorlopend_Limiet))  Limiet_krediet
                     ,SUM(ZEROIFNULL(d.Doorlopend_saldo))  Saldo_doorlopend
                     ,1  Bron_ACBS_ind
                     ,MAX(ZEROIFNULL(CASE WHEN ZEROIFNULL(d.Doorlopend_debet_limiet) > 0 THEN 1 ELSE 0 END ))  Saldocompensatie_ind
                     ,MIN(d.Datum_ingang)  Ingangdatum_krediet
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
LEFT OUTER JOIN
                (SEL
                      e.Klant_nr
                     ,d.Maand_nr
                     ,SUM(ZEROIFNULL(d.OOE))  OOE
                     ,SUM(ZEROIFNULL(d.Doorlopend_Limiet))  Limiet_krediet
                     ,SUM(ZEROIFNULL(d.Doorlopend_saldo))  Saldo_doorlopend
                     ,1  Bron_ACBS_ind
                     ,MAX(ZEROIFNULL(CASE WHEN ZEROIFNULL(d.Doorlopend_debet_limiet) > 0 THEN 1 ELSE 0 END ))  Saldocompensatie_ind
                     ,MIN(d.Datum_ingang)  Ingangdatum_krediet
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
LEFT OUTER JOIN
                (SEL
                      d.Party_id  BO_nr
                     ,d.BO_naam
                     ,d.sbu_srt_bo_code
                     ,MAX(d.Type_bo_nr)  Type_bo_nr
                     ,d.BU_code
                     ,CASE WHEN d.bu_code = '1n' AND d.bo_naam LIKE ANY ('%FR&R%', '%lindorf%') THEN 'FR&R' ELSE d.BU_decode_mi END  BU_decode_mi
                     ,null                                                              Regio_nr
                     ,null  Regio_naam
                 FROM mi_vm_ldm.vBo_mi_part_zak d
                 /*WHERE bu_code NOT IN ('1H','1C', '1R')*/
                 GROUP BY 1,2,3,5,6,7,8
                 ) m
   ON d.KANTOOR_BO_NUMMER = m.Bo_nr

) WITH DATA
UNIQUE PRIMARY INDEX ( fk_aanvr_wkmid, fk_aanvr_versie )
;

INSERT INTO MI_SAS_AA_MB_C_MB.KEM_pijplijn 
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
       ,Volgnr_chrono_old 
       ,Volgnr_chrono _old
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

INSERT INTO MI_SAS_AA_MB_C_MB.KEM_aanvraag_det 
SELECT * FROM Mi_temp.KEM_funnel_t3;

INSERT INTO Mi_temp.Kred_rapportage_moment_afdtabellen
SELECT
     lm.maand
    ,lm.maand_sdat
    ,lm.maand_edat
FROM Mi_vm.vlu_maand                      lm
WHERE lm.maand = (SELECT MAX(maand_nr) FROM mi_cmb.cif_complex);

INSERT INTO MI_SAS_AA_MB_C_MB.ahk_basis 
SELECT * FROM MI_SAS_AA_MB_C_MB.ahk_basis;


DELETE FROM MI_SAS_AA_MB_C_MB.ahk_basis 
WHERE Maand_nr = (SELECT Maand_nr FROM MI_temp.Kred_rapportage_moment_afdtabellen)
;

INSERT INTO MI_SAS_AA_MB_C_MB.ahk_basis 
SELECT
    char_subst(b.master_cr_facility ,'abcdefghijklmnopqrstuvwxyzÀÁÂÃÄÅÆàáâãäåæÇçÈÉÊËèéêëÌÍÎÏÒÓÔÕÖòóôõöÙÚÛÜùúûüýÿ+.,-/;:\_=','')  (DEC(12,0))  hoofdrekening
    , char_subst(c.klant_nr ,'abcdefghijklmnopqrstuvwxyzÀÁÂÃÄÅÆàáâãäåæÇçÈÉÊËèéêëÌÍÎÏÒÓÔÕÖòóôõöÙÚÛÜùúûüýÿ+.,-/;:\_=','') (DEC(12,0))  bc_nr
    , ((EXTRACT(YEAR FROM b.periode_datum) * 100) + EXTRACT(MONTH FROM b.periode_datum) )  maand_nr --b.periode_datum  (FORMAT 'yyyymm') (INTEGER)  maand
    , a.original_currency_code
    , b.kredietsoort (char(2))
    , MAX(a.closing_cr_limit)*-1 (DEC(15,0)) krediet_limiet
    , AVG(a.tot_principal_amt_outstanding)*-1 (DEC(15,0)) gem_POS
    , AVG(a.closing_guarantee_utlz_amt)*-1 (DEC(15,0)) gem_obligopositie
    , MIN(CASE WHEN a.tot_principal_amt_outstanding GT 0 THEN a.tot_principal_amt_outstanding  ELSE 0 END)*-1 (DEC(15,0))  MIN_POS
    , MAX(CASE WHEN a.tot_principal_amt_outstanding GT 0 THEN a.tot_principal_amt_outstanding ELSE 0 END)*-1  (DEC(15,0))  MAX_POS

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
       0  Samengevoegd,
       0  Uiteengevallen,
       CASE WHEN XD.Party_id IS NULL AND B.Klant_nr_begin IS NULL THEN 1 ELSE 0 END  Nieuw_BC,
       CASE WHEN XE.Party_id IS NULL AND B.Klant_nr_eind IS NULL THEN 1 ELSE 0 END  Vervallen_BC,
       XF.Segment_id  CGC_begin,
       XG.Segment_id  CGC_eind,
       XH.Business_line  Business_line_begin,
       XI.Business_line  Business_line_eind,
       XH.Segment  Segment_begin,
       XI.Segment  Segment_eind
  FROM (SELECT XA.Klant_nr,
               XA.Maand_nr,
               XA.Business_contact_nr
          FROM Mi_sas_aa_mb_c_mb.Mia_klantkoppelingen_hist  XA
          JOIN MI_SAS_AA_MB_C_MB.Mia_periode  XX
            ON 1 = 1
         WHERE (XA.Maand_nr = XX.Maand_nr OR XA.Maand_nr = XX.Maand_nr_vm1) AND XX.Lopende_maand_ind = 1
         GROUP BY 1, 2, 3)  A
  LEFT OUTER JOIN (SELECT XA.Business_contact_nr,
               XX.Maand_nr_vm1  Maand_nr_begin,
               XX.Maand_nr  Maand_nr_eind,
               MAX(CASE WHEN XA.Maand_nr = XX.Maand_nr_vm1 THEN 1 ELSE NULL END)  In_begin,
               MAX(CASE WHEN XA.Maand_nr = XX.Maand_nr     THEN 1 ELSE NULL END)  In_eind,
               MAX(CASE WHEN XA.Maand_nr = XX.Maand_nr_vm1 THEN XB.Klant_ind ELSE NULL END)  Klant_ind_begin,
               MAX(CASE WHEN XA.Maand_nr = XX.Maand_nr     THEN XB.Klant_ind ELSE NULL END)  Klant_ind_eind,
               MIN(XA.Maand_nr)  Maand_nr,
               MAX(CASE WHEN XA.Maand_nr = XX.Maand_nr_vm1 THEN XA.Klant_nr ELSE NULL END)  Klant_nr_begin,
               MAX(CASE WHEN XA.Maand_nr = XX.Maand_nr     THEN XA.Klant_nr ELSE NULL END)  Klant_nr_eind,
               CASE WHEN Klant_nr_begin = Klant_nr_eind THEN 1 ELSE 0 END  Klant_nr_ongewijzigd,
               CASE WHEN Klant_nr_begin NE Klant_nr_eind THEN 1 ELSE 0 END  Klant_nr_gewijzigd,
               CASE WHEN Klant_nr_eind IS NULL THEN 1 ELSE 0 END  Klant_nr_weg,
               CASE WHEN Klant_nr_begin IS NULL THEN 1 ELSE 0 END  Klant_nr_nieuw
          FROM Mi_sas_aa_mb_c_mb.Mia_klantkoppelingen_hist  XA
          LEFT OUTER JOIN Mi_sas_aa_mb_c_mb.CIAA_Mia_hist  XB
            ON XA.Klant_nr = XB.Klant_nr AND XA.Maand_nr = XB.Maand_nr
          JOIN MI_SAS_AA_MB_C_MB.Mia_periode  XX
            ON 1 = 1
         WHERE (XA.Maand_nr = XX.Maand_nr OR XA.Maand_nr = XX.Maand_nr_vm1) AND XX.Lopende_maand_ind = 1
         GROUP BY 1, 2, 3)  B
         ON A.Business_contact_nr = B.Business_contact_nr
  LEFT OUTER JOIN (SELECT XA.Maand_nr,
                          XA.Datum_gegevens  Datum_begin_periode
                     FROM Mi_sas_aa_mb_c_mb.CIAA_Mia_hist  XA
                     JOIN MI_SAS_AA_MB_C_MB.Mia_periode  XX
                       ON 1 = 1
                    WHERE XA.Maand_nr = XX.Maand_nr_vm1 AND XX.Lopende_maand_ind = 1
                    GROUP BY 1, 2)  XB
    ON B.Maand_nr_begin = XB.Maand_nr
  LEFT OUTER JOIN (SELECT XA.Maand_nr,
                          XA.Datum_gegevens  Datum_eind_periode
                     FROM Mi_sas_aa_mb_c_mb.CIAA_Mia_hist  XA
                     JOIN MI_SAS_AA_MB_C_MB.Mia_periode  XX
                       ON 1 = 1
                    WHERE XA.Maand_nr = XX.Maand_nr AND XX.Lopende_maand_ind = 1
                    GROUP BY 1, 2)  XC
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

UPDATE Mi_temp.Mia_migratie_BC_basis
   SET Uiteengevallen = 1
 WHERE Mi_temp.Mia_migratie_BC_basis.Klant_nr_begin IN (SELECT Klant_nr_begin
                                                          FROM Mi_temp.Mia_migratie_BC_basis
                                                         WHERE Nieuw_BC + Vervallen_BC = 0
                                                           AND Klant_nr_eind IS NOT NULL
                                                         GROUP BY 1 HAVING COUNT(DISTINCT Klant_nr_eind) > 1);

UPDATE Mi_temp.Mia_migratie_BC_basis
   SET Samengevoegd = 1
 WHERE Mi_temp.Mia_migratie_BC_basis.Klant_nr_eind IN (SELECT Klant_nr_eind
                                                         FROM Mi_temp.Mia_migratie_BC_basis
                                                        WHERE Nieuw_BC + Vervallen_BC = 0
                                                        GROUP BY 1 HAVING COUNT(DISTINCT ZEROIFNULL(Klant_nr_begin)) > 1);

INSERT INTO Mi_temp.Mia_klanten_uiteengevallen
SELECT A.Klant_nr,
       A.Maand_nr,
       MAX(A.Uiteengevallen)  Uiteengevallen,
       MAX(B.Ook_samengevoegd)  Ook_samengevoegd
  FROM Mi_temp.Mia_migratie_BC_basis A
  LEFT OUTER JOIN (SELECT XA.Klant_nr,
                          MAX(XA.Samengevoegd)  Ook_samengevoegd
                     FROM Mi_temp.Mia_migratie_BC_basis XA
                    WHERE XA.Uiteengevallen = 1
                    GROUP BY 1)  B
    ON A.Klant_nr = B.Klant_nr
 WHERE A.Uiteengevallen = 1
 GROUP BY 1, 2;

INSERT INTO Mi_temp.Mia_klanten_samengevoegd
SELECT A.Klant_nr,
       A.Maand_nr,
       MAX(A.Samengevoegd)  Samengevoegd,
       MAX(B.Ook_uiteengevallen)  Ook_uiteengevallen
  FROM Mi_temp.Mia_migratie_BC_basis A
  LEFT OUTER JOIN (SELECT XA.Klant_nr,
                          MAX(XA.Uiteengevallen)  Ook_uiteengevallen
                     FROM Mi_temp.Mia_migratie_BC_basis XA
                    WHERE XA.Samengevoegd = 1
                    GROUP BY 1)  B
    ON A.Klant_nr = B.Klant_nr
 WHERE A.Samengevoegd = 1
 GROUP BY 1, 2;


INSERT INTO Mi_temp.Mia_klanten_nieuw
SELECT *
  FROM (SELECT XA.Klant_nr,
               XA.Maand_nr,
               MAX(XA.Nieuw_BC)  Nieuw,
               COUNT(*)  Aantal_bcs,
               SUM(XA.Nieuw_BC)  Aantal_bcs_nieuw
          FROM Mi_temp.Mia_migratie_BC_basis XA
         GROUP BY 1, 2)  A
 WHERE A.Nieuw > 0;

INSERT INTO Mi_temp.Mia_klanten_weg
SELECT A.*
  FROM (SELECT XA.Klant_nr,
               XA.Maand_nr,
               MAX(XA.Vervallen_BC)  Vervallen,
               COUNT(*)  Aantal_bcs,
               SUM(XA.Vervallen_BC)  Aantal_bcs_vervallen
          FROM Mi_temp.Mia_migratie_BC_basis XA
         GROUP BY 1, 2)  A
 WHERE A.Vervallen > 0;

INSERT INTO Mi_temp.Mia_klanten_klantnr_anders
SELECT A.Klant_nr,
       A.Maand_nr,
       A.Klant_nr_eind  Klant_nr_nieuw,
       1  Wijziging_klantnummer,
       CASE
       WHEN A.Business_line_begin IN ('Retail', 'PB') THEN 'R&PB'
       WHEN A.Business_line_begin IN ('CBC', 'SME') AND Ook_instroom = 1 THEN 'Nieuw'
       ELSE A.Business_line_begin
       END  Business_line_begin,
       CASE
       WHEN A.Business_line_eind IN ('Retail', 'PB') THEN 'R&PB'
       WHEN A.Business_line_eind IN ('CBC', 'SME') AND Ook_uitstroom = 1 THEN 'Weg'
       ELSE A.Business_line_eind
       END  Business_line_eind,
       A.Klant_ind_begin,
       A.Klant_ind_eind,
       CASE
       WHEN A.Business_line_begin NOT IN ('CBC', 'SME') AND A.Klant_ind_eind = 1 AND A.Business_line_eind IN ('CBC', 'SME') THEN 1
       WHEN A.Business_line_begin IN ('CBC', 'SME')     AND A.Klant_ind_begin = 0 AND A.Klant_ind_eind = 1 AND A.Business_line_eind IN ('CBC', 'SME') THEN 1
       ELSE 0
       END  Ook_instroom,
       CASE
       WHEN A.Business_line_eind NOT IN ('CBC', 'SME') AND A.Klant_ind_begin = 1 AND A.Business_line_begin IN ('CBC', 'SME') THEN 1
       WHEN A.Business_line_eind IN ('CBC', 'SME')     AND A.Klant_ind_eind = 0 AND A.Klant_ind_begin = 1 AND A.Business_line_begin IN ('CBC', 'SME') THEN 1
       ELSE 0
       END  Ook_uitstroom
  FROM (SELECT XA.Klant_nr,
               XA.Maand_nr,
               XA.Klant_nr_eind,
               MIN(XA.Business_line_begin)  Business_line_begin,
               MIN(XA.Business_line_eind)  Business_line_eind,
               MIN(XA.Segment_begin)  Segment_begin,
               MIN(XA.Segment_eind)  Segment_eind,
               MAX(XA.Klant_ind_begin)  Klant_ind_begin,
               MAX(XA.Klant_ind_eind)  Klant_ind_eind,
               SUM(XA.Samengevoegd)  Samen,
               SUM(XA.Uiteengevallen)  Uiteen,
               SUM(XA.Nieuw_BC)  Nieuw,
               SUM(XA.Vervallen_BC)  Vervallen
          FROM Mi_temp.Mia_migratie_BC_basis XA
          JOIN MI_SAS_AA_MB_C_MB.Mia_periode  XX
            ON 1 = 1
         WHERE XA.Maand_nr = XX.Maand_nr_vm1 AND XX.Lopende_maand_ind = 1
           AND XA.Klant_nr_gewijzigd = 1
         GROUP BY 1, 2, 3)  A
 WHERE A.Samen = 0
   AND A.Uiteen = 0
   AND A.Nieuw = 0
   AND A.Vervallen = 0;

INSERT INTO Mi_temp.Mia_klanten_andere_BL
SELECT A.Klant_nr,
       A.Maand_nr,
       1  Andere_BL,
       CASE
       WHEN A.Business_line IN ('Retail', 'PB') THEN 'R&PB'
       ELSE A.Business_line
       END  Business_line
  FROM (SELECT XA.Klant_nr,
               XA.Maand_nr,
               COUNT(*)  Aantal_bcs,
               SUM(XA.Klant_nr_weg)  Aantal_bcs_weg,
               MAX(XA.Business_line_eind)  Business_line
          FROM Mi_temp.Mia_migratie_BC_basis XA
         WHERE XA.Vervallen_BC = 0
         GROUP BY 1, 2)  A
 WHERE A.Aantal_bcs = A.Aantal_bcs_weg;
INSERT INTO Mi_temp.Mia_klanten_andere_BL
SELECT A.Klant_nr,
       A.Maand_nr,
       1  Andere_BL,
       CASE
       WHEN A.Business_line IN ('Retail', 'PB') THEN 'R&PB'
       ELSE A.Business_line
       END  Business_line
  FROM (SELECT XA.Klant_nr,
               XA.Maand_nr,
               MAX(XA.Business_line_eind)  Business_line
          FROM Mi_temp.Mia_migratie_BC_basis XA
         WHERE XA.Samengevoegd = 0
           AND XA.Uiteengevallen = 0
           AND XA.Nieuw_BC = 0
           AND XA.Vervallen_BC = 0
           AND XA.In_begin IS NULL
         GROUP BY 1, 2)  A;


INSERT INTO Mi_temp.Mia_migratie_totaal
SELECT A.Klant_nr,
       A.Maand_nr_eind  Maand_nr
  FROM (SELECT CASE WHEN H5.Ook_instroom = 1 THEN H5.Klant_nr ELSE A.Klant_nr END  Klant_nr
          FROM Mi_sas_aa_mb_c_mb.CIAA_Mia_hist  A
          JOIN MI_SAS_AA_MB_C_MB.Mia_periode  XX
            ON 1 = 1

          LEFT OUTER JOIN Mi_temp.Mia_klanten_klantnr_anders H5
            ON A.Klant_nr = H5.Klant_nr AND (H5.Business_line_begin IN ('CBC', 'SME') OR H5.Business_line_eind IN ('CBC', 'SME'))

         WHERE 1 = 1
           AND (A.Maand_nr = XX.Maand_nr OR A.Maand_nr = XX.Maand_nr_vm1) AND XX.Lopende_maand_ind = 1
           AND ((A.Klant_ind = 1
           AND A.Klantstatus = 'C'
           AND (A.Business_line IN ('CBC', 'SME', 'CC' /* eenmalig */) OR (H5.Ook_instroom = 1) OR (A.Business_line = 'Retail' AND A.Segment = 'YBB' /* eenmalig */))))

         GROUP BY 1, 2, 3)  A

  JOIN MI_SAS_AA_MB_C_MB.Mia_periode  XX
    ON 1 = 1

  LEFT OUTER JOIN Mi_sas_aa_mb_c_mb.CIAA_Mia_hist  B
    ON A.Klant_nr = B.Klant_nr
   AND B.Maand_nr = XX.Maand_nr_vm1

  LEFT OUTER JOIN Mi_sas_aa_mb_c_mb.CIAA_Mia_hist  C
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

  LEFT OUTER JOIN Mi_sas_aa_mb_c_mb.CIAA_Mia_hist  D
    ON H5.Klant_nr_nieuw = D.Klant_nr
   AND D.Maand_nr = XX.Maand_nr

 WHERE A.Klant_nr NOT IN (SELECT Klant_nr_nieuw FROM Mi_temp.Mia_klanten_klantnr_anders);

INSERT INTO Mi_sas_aa_mb_c_mb.Mia_migratie_hist 
SELECT A.*
  FROM Mi_temp.Mia_migratie_totaal A;
  JOIN  Mi_sas_aa_mb_c_mb.Mia_migratie_hist
  on 1=1

INSERT INTO MI_SAS_AA_MB_C_MB.CUBe_Siebel_fin_prof_geleverd 
SELECT A.Business_contact_nr
  FROM Mi_temp.Mia_week A
  LEFT OUTER JOIN Mi_temp.CUBe_baten B
    ON A.Klant_nr = B.Klant_nr AND A.Maand_nr = B.Maand_nr
  LEFT OUTER JOIN (SELECT X.Klant_nr,
                          MAX(CASE WHEN X.Volgorde = 1 THEN X.Product_naam ELSE NULL END)  Complex_product_1,
                          MAX(CASE WHEN X.Volgorde = 2 THEN X.Product_naam ELSE NULL END)  Complex_product_2,
                          MAX(CASE WHEN X.Volgorde = 3 THEN X.Product_naam ELSE NULL END)  Complex_product_3
                     FROM (SELECT XA.*,
                                  RANK() OVER (PARTITION BY XA.Klant_nr ORDER BY XA.Code_complex_product ASC)  Volgorde
                             FROM (SELECT XXA.Klant_nr,
                                          XXA.Code_complex_product,
                                          CASE WHEN XXA.Code_complex_product = 'J' THEN 'GRV 010, 020 en 030' ELSE XXA.Product_naam END  Product_naam
                                     FROM Mi_temp.Complex_product XXA
                                    GROUP BY 1, 2, 3)  XA)  X
                    GROUP BY 1)  D
    ON A.Klant_nr = D.Klant_nr
  LEFT OUTER JOIN (SELECT A.Klant_nr
                     FROM Mi_temp.Complex_product A
                    GROUP BY 1, 2)  E
    ON A.Klant_nr = E.Klant_nr
  LEFT OUTER JOIN (SELECT A.Klant_nr,
                          CASE
                          WHEN B.NPS_aanbeveling_ABN_AMRO BETWEEN 9 AND 10 THEN CAST(B.NPS_aanbeveling_ABN_AMRO  VARCHAR(2))||' (Promotor,'||SUBSTR(B.Kto_id, 9, 6)||')'
                          WHEN B.NPS_aanbeveling_ABN_AMRO BETWEEN 7 AND  8 THEN CAST(B.NPS_aanbeveling_ABN_AMRO  VARCHAR(2))||' (Passive,'||SUBSTR(B.Kto_id, 9, 6)||')'
                          WHEN B.NPS_aanbeveling_ABN_AMRO BETWEEN 0 AND  6 THEN CAST(B.NPS_aanbeveling_ABN_AMRO  VARCHAR(2))||' (Detractor,'||SUBSTR(B.Kto_id, 9, 6)||')'
                          ELSE NULL
                          END  NPS
                   FROM (SELECT *
                         FROM MI_SAS_AA_MB_C_MB.Mia_klantkoppelingen_hist 
                         WHERE Maand_nr IN (SELECT MAX(Maand_nr) FROM MI_SAS_AA_MB_C_MB.Mia_klantkoppelingen_hist  )
                        ) A

                   JOIN (SELECT XA.Business_contact_nr,
                                XA.Kto_id,
                                XA.NPS_aanbeveling_ABN_AMRO
                         FROM Mi_cmb.vMia_kto_resultaten XA
                         WHERE ZEROIFNULL(XA.Anoniem_ind) = 0
                           AND ZEROIFNULL(XA.NPS_aanbeveling_ABN_AMRO) BETWEEN 0 AND 10
                        ) B
                       ON A.Business_contact_nr = B.Business_contact_nr
                   QUALIFY ROW_NUMBER() OVER (PARTITION BY A.Klant_nr ORDER BY CASE WHEN NPS IS NULL THEN 0 ELSE 1 END DESC, B.Kto_id DESC, B.NPS_aanbeveling_ABN_AMRO ASC) = 1
                  )  F
    ON A.Klant_nr = F.Klant_nr

WHERE (A.Klant_ind = 1 OR A.Klantstatus = 'S')
  AND (A.Business_line IN ('CBC', 'CIB','SME') AND A.Segment <> 'SME');

INSERT INTO MI_SAS_AA_MB_C_MB.CUBe_Siebel_fin_prof_geleverd 
SELECT
    oud.Business_contact_nr
   ,DATE  Datum_gegevens
   ,0  Sw_geleverd
   ,'9999-12-31'  Datum_baten
   ,''  Bedrijfstak_oms
   ,0  Baten
   ,0  Baten_potentieel
   ,0  Creditvolume
   ,0  Debetvolume
   ,0  Omzet_inkomend
   ,''  Signaal
   ,'N'  Compl_prod01
   ,'N'  Compl_prod02
   ,'N'  Compl_prod03
   ,'N'  Compl_prod04
   ,'N'  Compl_prod05
   ,'N'  Compl_prod06
   ,'N'  Compl_prod07
   ,'N'  Compl_prod08
   ,'N'  Compl_prod09
   ,'N'  Compl_prod10
   ,'N'  Compl_prod11
   ,'N'  Compl_prod12
   ,'N'  Compl_prod13
   ,'N'  Compl_prod14
   ,'N'  Compl_prod15
   ,'N'  Compl_prod16
   ,'N'  Compl_prod17
   ,'N'  Compl_prod18
   ,'N'  Compl_prod19
   ,'N'  Compl_prod20
   ,'N'  Compl_prod21
   ,'N'  Compl_prod22
   ,'N'  Compl_prod23
   ,'N'  Compl_prod24
   ,'N'  Compl_prod25
   ,'N'  Compl_prod26
   ,'N'  Compl_prod27
   ,'N'  Compl_prod28
   ,''  Cp1_text
   ,''  Cp2_text
   ,''  Cp3_text
   ,0  N_complex
   ,0  Potentieel_theoretisch
   ,'' Clientgroep_theoretisch
   ,''  Oordeel_RM
   ,''  Beoordeeld
   ,''  NPS
FROM MI_SAS_AA_MB_C_MB.CUBe_Siebel_fin_prof_geleverd  oud

LEFT OUTER JOIN MI_SAS_AA_MB_C_MB.CUBe_Siebel_fin_prof_geleverd    act
   ON oud.Business_contact_nr = act.Business_contact_nr

WHERE act.Business_contact_nr IS NULL
;

INSERT INTO MI_SAS_AA_MB_C_MB.Medewerker_Security 
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
			f.datum_gegevens  Datum_gegevens
			,a.sbt_id  SBT_id
			,b.Naam  Naam
			,a.party_sleutel_type  Soort_mdw
			,a.Functie  Functie
			,c.bo_nr  BO_nr_mdw
			,TRIM(d.BO_naam)  BO_naam_mdw
			,gm.GM_ind
			,a.CCA
			,Account_Management_Specialism
			,Account_Management_Segment
			,a.Mdw_sdat
			,a.party_sleutel_type
			,e.N_bcs
			,RANK () OVER (PARTITION BY a.sbt_id ORDER BY a.party_sleutel_type ASC, e.N_bcs DESC, a.Mdw_sdat DESC, a.cca DESC)  Rang
			FROM (	SELECT party_id,
			                      CASE WHEN party_sleutel_type = 'AM' THEN party_id ELSE NULL END  CCA,
			                      CASE WHEN LENGTH(TRIM(COALESCE(Account_Management_Functie, account_management_sbl_functietitel))) > 0
			                      THEN TRIM(COALESCE(Account_Management_Functie, account_management_sbl_functietitel, 'ONBEKEND')) ELSE 'ONBEKEND' end   Functie,
			                      party_sleutel_type,
			                      TRIM(sbt_userid)  sbt_id,
			                      COALESCE(CASE WHEN LENGTH(TRIM(account_management_specialism)) > 1 THEN TRIM(account_management_specialism) ELSE NULL END, 'Onbekend')  Account_Management_Specialism,
			                      COALESCE(CASE WHEN LENGTH(TRIM(account_management_segment)) > 1 THEN TRIM(account_management_segment) ELSE NULL END, 'Onbekend')        Account_Management_Segment,
			                      max(account_management_sdat)  Mdw_sdat
			                FROM MI_VM_LDM.aaccount_management
			                WHERE sbt_id IS NOT NULL
			                AND sbt_id  <> 'UI0319'
			                AND TRIM(FUNCTIE) NOT IN ('Zelst. Verm. Beh.', 'zelfst.Verm.Beh')
			                AND LENGTH(TRIM(sbt_id)) > 0
			group by 1,2,3,4,5,6,7	) a
INNER JOIN (SELECT party_id,
                party_sleutel_type,
                CASE WHEN party_sleutel_type = 'MW' THEN UPPER(TRIM(Naam)) ELSE UPPER(TRIM(Naamregel_1)) END  Naam
            FROM mi_vm_ldm.aparty_naam
            WHERE party_sleutel_type IN ('MW')) b
ON a.party_id = b.party_id
AND a.party_sleutel_type = b.party_sleutel_type
INNER JOIN (SELECT party_id,
             party_sleutel_type,
             gerelateerd_party_id  bo_nr
             FROM mi_vm_ldm.aPARTY_PARTY_RELATIE
             WHERE party_relatie_type_code IN ('AMBO', 'MWBO')) c
ON a.party_id = c.party_id
AND a.party_sleutel_type = c.party_sleutel_type
LEFT JOIN  (SELECT party_id  bo_nr,
                                naam  bo_naam
                        FROM mi_vm_ldm.aparty_naam
                        WHERE party_sleutel_type = 'BO') d
ON c.bo_nr = d.bo_nr
LEFT JOIN (SELECT Party_id  bo_nr,
                               Structuur,
                               Case when substr(Structuur,1,6) = '334524' then 1 else 0 end  GM_ind
                               FROM  mi_vm_ldm.aParty_BO)  gm
on c.bo_nr = gm.bo_nr
LEFT JOIN (SELECT gerelateerd_party_id, gerelateerd_party_sleutel_type, COUNT(party_id)  N_bcs
                        FROM mi_vm_ldm.aparty_party_relatie
                        WHERE party_relatie_type_code IN ('relman','cltadv')
                        GROUP BY 1,2) e
ON a.party_id = e.gerelateerd_party_id
AND a.party_sleutel_type = e.gerelateerd_party_sleutel_type
LEFT JOIN MI_SAS_AA_MB_C_MB.Mia_periode f
ON 1=1 ) XA
join Mi_sas_aa_mb_c_mb.Mia_organisatie_workaround p on p.bo_nr = xa.bo_nr_mdw
;

INSERT INTO MI_SAS_AA_MB_C_MB.AGRC_MCT 
 SELECT a.Draaidatum
                FROM MI_CMB.AGRC_MCT_bron a
                        left join (
                        select b.Business_Structures, b.Control_ID, max(b.Monitor_Due_Date__calculated_)  max_mon
                        FROM MI_CMB.AGRC_MCT_bron  b group by b.Business_Structures, b.Control_ID  ) c
                        on c.Business_Structures||c.Control_ID||c.max_mon = a.Business_Structures||a.Control_ID||a.Monitor_Due_Date__calculated_
                    left join (select d.Business_Structures
                        FROM MI_CMB.AGRC_MCT_bron  d
                        group by d.Business_Structures, d.Control_ID, jaar, kwartaal) e
                        on e.Business_Structures||e.Control_ID||e.max_mon_II = a.Business_Structures||a.Control_ID||a.Monitor_Due_Date__calculated ;


INSERT INTO MI_SAS_AA_MB_C_MB.AGRC_REM 
            select
            a.Draaidatum
            , a.Maand_nr
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

INSERT INTO MI_SAS_AA_MB_C_MB.AGRC_IMAT 
            SELECT
            a.Draaidatum
            , a.Maand_nr
            , a.Action_plan_creation_date
            , a.Issue_target_Completion___Review
            , trim(a.Issue_source)
            FROM MI_CMB.AGRC_IMAT_bron a;


create table mi_cmb.medewerkers as(
SELECT
a.party_id
, e.naam  naam_mdw
, a.sbt_userid  sbt_id
, a.account_management_sdat
, a.Account_Management_Functie
, a.account_management_sbl_functietitel  sbl_functie
,e.bo_nr_mdw
,e.bo_naam_mdw
, b.electronisch_adres_id  emailadres
, b.party_adres_status_code
, a.party_sleutel_type
, a.sbt_userid_manager  sbt_id_mgr
,d.electronisch_adres_id  emailadres_mgr
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


DELETE
FROM MI_SAS_AA_MB_C_MB.CTrack_Portfolio_Hist 
WHERE Maand_nr = (SELECT Maand_nr FROM MI_SAS_AA_MB_C_MB.Mia_periode )
;

INSERT INTO  MI_SAS_AA_MB_C_MB.CTrack_Portfolio_Hist 
SELECT Portfolio_Id
    ,B.Maand_nr
    ,EXTRACT(YEAR FROM  A.Extraction_date )*100 +EXTRACT(MONTH FROM A.Extraction_date )  Maand_nr_delivery
    ,CASE WHEN EXTRACT(MONTH FROM  A.Extraction_date )  = 1
          THEN (EXTRACT(YEAR FROM  A.Extraction_date )-1)*100 +12
      ELSE EXTRACT(YEAR FROM  A.Extraction_date )*100 +EXTRACT(MONTH FROM A.Extraction_date )-1
     END  Maand_nr_reporting
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
FROM  MI_NEMO.CTrack_Portfolio A
LEFT OUTER JOIN MI_SAS_AA_MB_C_MB.Mia_periode  B ON 1 = 1
LEFT JOIN  Mi_vm_nzdb.vLU_maand per on per.Maand = Maand_nr_delivery
LEFT JOIN (SELECT DISTINCT
                             C.Party_id  Business_contact_nr
                            , C.Contract_nr
                            , C.Cc_nr  Klant_nr
                            FROM Mi_vm_ldm.aParty_contract C
                            WHERE C.Party_sleutel_type = 'bc'
                            AND C.Party_contract_rol_code = 'c'
                            AND C.contract_soort_code > 0
                            QUALIFY RANK() OVER (PARTITION BY C.Contract_nr ORDER BY C.Contract_soort_code DESC, C.Party_id) = 1) D
                            on A.borrower_id = D.contract_nr
   LEFT JOIN (select
                                E.relation_id
                                , EXTRACT(YEAR FROM  E.Extraction_date )*100 +EXTRACT(MONTH FROM E.Extraction_date )  Maand_nr_delivery_dub
                                , count(*)   Acties_totaal
                                , sum(CASE WHEN e.followup_date < perr.Maand_startdatum -1 then 1 else 0 end)  Acties_achterstand -- EB 20181106 script aangepast, gaat goed? Ter validatie voorgelegd, kolom stond al in script
                                FROM  MI_NEMO.CTrack_OpenActions E
                                LEFT JOIN  Mi_vm_nzdb.vLU_maand perr on perr.Maand  = Maand_nr_delivery_dub
                            QUALIFY RANK() OVER (PARTITION BY E.relation_id ORDER BY Maand_nr_delivery_dub DESC) = 1
                                group by 1, 2) G
                                ON A.borrower_id = G.relation_id;


INSERT INTO MI_SAS_AA_MB_C_MB.medewerker_email 
SELECT
e.naam  naam_mdw
, a.account_management_sdat
, a.sbt_userid  sbt_id
, a.Account_Management_Functie
, a.account_management_sbl_functietitel  sbl_functie
,e.bo_nr_mdw
,e.bo_naam_mdw
, b.electronisch_adres_id  emailadres
, b.party_adres_status_code
,a.party_id
, a.party_sleutel_type
, a.sbt_userid_manager  sbt_id_mgr
,d.electronisch_adres_id  emailadres_mgr
FROM MI_VM_LDM.aACCOUNT_MANAGEMENT a
join MI_VM_LDM.aPARTY_ELECTRONISCH_ADRES_MW b
on a.party_id = b.party_id
and a.party_sleutel_type = b.party_sleutel_type
join MI_VM_LDM.aACCOUNT_MANAGEMENT c
on a.sbt_userid_manager=c.sbt_userid
join MI_VM_LDM.aPARTY_ELECTRONISCH_ADRES_MW d
on c.party_id = d.party_id
and c.party_sleutel_type = d.party_sleutel_type
join MI_SAS_AA_MB_C_MB.Siebel_Employee  e
on a.sbt_userid = e.sbt_id;


CREATE TABLE MI_SAS_AA_MB_C_MB.cib_klantbeeld_rep_cock  AS
(SELECT MAX(maand_nr)  max_maand_nr FROM mi_cmb.producten) WITH DATA;



CREATE TABLE mi_sas_aa_mb_c_mb.cib_klantbeeld_rep_tb    AS
(SELECT MAX(billing_period)  max_billing_period FROM mi_tb.wrk_ce) WITH DATA;



CREATE TABLE mi_sas_aa_mb_c_mb.cib_klantbeeld_rep_lnd   AS
(SELECT MAX(maand_nr)  max_maand_nr FROM mi_cmb.vcif_complex) WITH DATA;



CREATE TABLE mi_sas_aa_mb_c_mb.cib_klantbeeld_rep_gm    AS
(SELECT MAX(maand_nr)  max_maand_nr FROM mi_cmb.smr_transaction) WITH DATA;



CREATE TABLE mi_sas_aa_mb_c_mb.cib_klantbeeld_rep_dp    AS
(SELECT MAX(maand_nr)  max_maand_nr FROM mi_cmb.vcrm_verkoopkans_product_week) WITH DATA;



CREATE TABLE mi_sas_aa_mb_c_mb.cib_klantbeeld_rep_rvb   AS
(SELECT MAX(datum)  max_datum FROM mi_cmb.rvdv_scrm_bron4) WITH DATA;



CREATE TABLE mi_sas_aa_mb_c_mb.cib_klantbeeld_rep_cr    AS
(SELECT klant_nr, CAST(1*MAX("Period")  INTEGER)  max_period FROM mi_cmb.cib_keymetrics GROUP BY 1) WITH DATA;



CREATE TABLE mi_sas_aa_mb_c_mb.cib_klantbeeld_rep_si    AS
(SELECT EXTRACT(YEAR FROM X)*100 + EXTRACT(MONTH FROM X)  max_maand_nr
	 FROM ( SELECT MAX(fonds_waarde_sdat)  X FROM mi_vm_ldm.aFONDS_WAARDE ) X) WITH DATA;


CREATE TABLE MI_SAS_AA_MB_C_MB.cib_klantbeeld_klanten   AS (
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
FROM Mi_temp.Mia_week MIA

LEFT JOIN MI_SAS_AA_MB_C_MB.cib_klantbeeld_fondscode F
ON MIA.klant_nr = F.klant_nr

LEFT JOIN
(	SELECT
		XP.klant_nr
		, MAX(CASE WHEN XP.contact_persoon_nr = 1 THEN XP.ContactPersoon end)  ContactPersoon1
		, MAX(CASE WHEN XP.contact_persoon_nr = 2 THEN XP.ContactPersoon end)  ContactPersoon2
	FROM
	(	SELECT
			P.klant_nr
			, P.voornaam || CASE WHEN P.tussenvoegsel='' THEN ' ' ELSE ' ' || P.tussenvoegSELECT || ' ' end  || P.achternaam  ContactPersoon
			, RANK() OVER(PARTITION BY P.klant_nr ORDER BY client_level , contactpersoon_functietitel DESC , ContactPersoon)  Contact_persoon_nr

		FROM MI_SAS_AA_MB_C_MB.Siebel_Contactpersoon  P
		WHERE 1=1
		AND P.contactpersoon_onderdeel NE 'Niet opgegeven'
		AND P.actief_ind = 1
		AND P.primair_contact_persoon_ind = 1
		AND P.email_bruikbaar = 1
	) XP
	GROUP BY 1
) CP
ON MIA.Klant_nr = CP.Klant_nr

LEFT JOIN MI_SAS_AA_MB_C_MB.cib_klantbeeld_rep_cock
  ON 1=1
LEFT JOIN MI_SAS_AA_MB_C_MB.cib_klantbeeld_rep_tb
  ON 1=1
LEFT JOIN MI_SAS_AA_MB_C_MB.cib_klantbeeld_rep_lnd
  ON 1=1
LEFT JOIN MI_SAS_AA_MB_C_MB.cib_klantbeeld_rep_gm
  ON 1=1
LEFT JOIN MI_SAS_AA_MB_C_MB.cib_klantbeeld_rep_gm
on 1=1
LEFT JOIN MI_SAS_AA_MB_C_MB.cib_klantbeeld_rep_dp
on  1=1
LEFT JOIN MI_SAS_AA_MB_C_MB.cib_klantbeeld_rep_dp
  ON 1=1
LEFT JOIN MI_SAS_AA_MB_C_MB.cib_klantbeeld_rep_rvb
  ON 1=1
LEFT JOIN MI_SAS_AA_MB_C_MB.cib_klantbeeld_rep_cr
  ON MIA.klant_nr = REP_CR.klant_nr AND 1=1
LEFT JOIN MI_SAS_AA_MB_C_MB.cib_klantbeeld_rep_si
  ON 1=1
WHERE 1=1
AND MIA.org_niveau2 = 'CC Consumer Services & Manufacturing'
AND MIA.relatiemanager ne 'Geen naam'
) WITH DATA PRIMARY INDEX(Klant_nr , business_contact_nr) ;

CREATE TABLE MI_SAS_AA_MB_C_MB.cib_klantbeeld_cockpit AS (
SELECT
	C.klant_nr
	, AA.cs_groep
	, AA.cib_cross_sell
	, A.maand_nr
	, SUM(A.baten)  baten
FROM mi_cmb.baten_product A

JOIN ( SELECT maand_nr ,  jaar , jaar-1  vorig_jaar , maand , (jaar-2)*100  vanaf FROM mi_cmb.producten_YM WHERE maand_nr = (SELECT MAX(maand_nr) FROM mi_cmb.producten) GROUP BY 1,2,3,4 ) NU
ON A.maand_nr > NU.vanaf

JOIN ( SELECT maand_nr , productlevel2code , cib_cross_sell , cs_groep FROM MI_SAS_AA_MB_C_MB.cib_cross_sell GROUP BY 1,2,3,4 ) AA
ON A.combiproductlevel = AA.productlevel2code

JOIN Mi_temp.Mia_klantkoppelingen B
ON A.party_id = B.business_contact_nr

JOIN MI_SAS_AA_MB_C_MB.cib_klantbeeld_klanten  C
ON B.klant_nr = C.klant_nr

GROUP BY 1,2,3,4
) WITH DATA UNIQUE PRIMARY INDEX( klant_nr , cs_groep , maand_nr);

CREATE TABLE MI_SAS_AA_MB_C_MB.cib_klantbeeld_tb AS (
SELECT
	CIB.Klant_nr
	, TB.billing_period                  maand_nr
	, TB.trx_soort
	, SUM(TB.turnover)	(DECIMAL(18,0))  omzet
	, SUM(TB.volume_ce)	(DECIMAL(18,0))  aantal

FROM MI_SAS_AA_MB_C_MB.cib_klantbeeld_klanten  CIB

JOIN Mi_temp.Mia_klantkoppelingen KOP
ON CIB.klant_nr = KOP.klant_nr

JOIN (
	SELECT
		CE.*,
		CASE
			WHEN STF.debettrx=1 THEN 'debet'
			WHEN STF.credittrx=1 THEN 'credit'
			ELSE 'huh?'
		end  trx_soort

	FROM mi_tb.wrk_ce CE

	JOIN ( SELECT TI , debettrx, credittrx FROM mi_tb.stf_gt WHERE debettrx + credittrx > 0 ) STF
	ON CE.TI_ID = STF.TI

	JOIN (
		SELECT billing_period , billing_period/100  jaar
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

CREATE TABLE MI_SAS_AA_MB_C_MB.cib_klantbeeld_lnd AS (
	SELECT
		  K.Klant_nr
		, A.Hoofdrekening
		, A.Fac_bc_nr
		, A.contract_nr
		, RANK() OVER(PARTITION BY Klant_nr ORDER BY Limiet_type,Fac_product_oms DESC,oorspronk_verval_datum DESC,contract_nr)  volgorde
		, A.Limiet_type
		, A.datum_ingang
		, CASE
			WHEN (upper(Limiet_type) = 'NON LOAN LIMIT') AND /*(upper(Fac_Product_adm_oms) = 'REKENING-COURANT KREDIET/ZAKELIJK') AND*/ (A.oorspronk_verval_datum = DATE '2066-06-06') THEN NULL
			ELSE A.oorspronk_verval_datum
		  END  oorspronk_verval_datum

		, CASE WHEN upper(MUNTCODE) = 'EUR' THEN A.Fac_Product_adm_oms ELSE trim(A.Fac_Product_adm_oms) || ' (' || trim(MUNTCODE) || ' Loan)' END  Fac_Product_adm_oms

		, NULL  Tot_Ticket
		, A.CLOSING_CR_LIMIT (DECIMAL(18,0))  AAB_Ticket
		, CASE
			WHEN A.aflopend_krediet_ind   = 1 THEN A.AFLOPEND_OPGENOMEN
			WHEN A.doorlopend_krediet_ind = 1 THEN A.DOORLOPEND_OPGENOMEN
			ELSE NULL
		  END  AAB_Drawn

		, A.datum_herziening_condities
		, A.syndicate_owned_perc (INTEGER)  AAB_share

		, NULL  CLOSING_AVAILABLE_AMT
		, NULL  TOT_PRINCIPAL_AMT_OUTSTANDING

	FROM MI_SAS_AA_MB_C_MB.cib_klantbeeld_klanten  K

	LEFT JOIN (SELECT CIF.*
	            FROM mi_cmb.vcif_complex CIF
	            JOIN MI_SAS_AA_MB_C_MB.cib_klantbeeld_rep_lnd
	            ON CIF.maand_nr = REP.max_maand_nr) A
	ON K.klant_nr = A.Fac_klant_nr
	AND A.fac_actief_ind = 1
	AND a.Complex_level_laagste_niv_ind = 1

) WITH DATA PRIMARY INDEX(klant_nr);


CREATE TABLE MI_SAS_AA_MB_C_MB.cib_klantbeeld_beurs  AS (
SELECT
	XX.klant_nr
	, XX.verkorte_naam
	, XX.business_contact_nr
	, XX.kvk_nr

	, YY.fonds_naam
	, YY.fonds_waarde_sdat
	, YY.fonds_waarde_edat

	, CAL.year_of_calendar	 jaar
	, CAL.month_of_year			 maand
	, CAL.week_of_year + 1	 week

	, YY.fonds_waarde
	, YY.fonds_waarde * Nbr_of_shares ( DECIMAL(12,0) )  MarketCap
	, F.Nbr_of_shares

FROM MI_SAS_AA_MB_C_MB.cib_klantbeeld_klanten  XX

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



CREATE TABLE MI_SAS_AA_MB_C_MB.cib_klantbeeld_gmb  AS
(
SELECT
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
        END  Product_Group
, SUM(amount_EUR)  Volume_EUR
, COUNT(*)  Aantal_Trx

FROM mi_cmb.smr_transaction A

JOIN Mi_temp.Mia_klantkoppelingen B
ON A.bc_nr = B.business_contact_nr

LEFT JOIN mi_sas_aa_mb_c_mb.cib_klantbeeld_rep_gm  C
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



CREATE TABLE mi_temp.cib_klantbeeld_rep_gmo AS  (SELECT MAX(maand_nr)  max_maand_nr FROM mi_sas_aa_mb_c_mb.cib_klantbeeld_gmo) WITH DATA;

CREATE TABLE mi_sas_aa_mb_c_mb.cib_klantbeeld_gmo   AS (SELECT * FROM mi_sas_aa_mb_c_mb.cib_klantbeeld_gmo) WITH DATA
PRIMARY INDEX ( maand_nr ,Klant_nr ,bc_nr ,Product_Group );

DELETE FROM mi_sas_aa_mb_c_mb.cib_klantbeeld_gmo 
WHERE maand_nr = (SELECT Max_maand_nr FROM mi_temp.cib_klantbeeld_rep_gmo GROUP BY 1);

INSERT INTO mi_sas_aa_mb_c_mb.cib_klantbeeld_gmo 
SELECT
D.max_maand  maand_nr
, C.klant_nr
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
        END  product_group
, SUM(A.amount_EUR)  Volume_EUR
, COUNT(*)  Aantal_Trx

from mi_cmb.smr_transaction A

left join
(
SELECT distinct BB.maand_nr, AA.maand_einddatum  max_date
from mi_vm_nzdb.vlu_maand AA

inner join mi_cmb.smr_transaction BB
on AA.maand = (SELECT MAX(AA.maand_nr)  max_maand FROM mi_cmb.smr_transaction AA)
) B
on A.maand_nr = B.maand_nr

left join
(
SELECT max(maand_nr)  max_maand
from mi_cmb.smr_transaction
) D
on 1=1

left join mi_sas_aa_mb_c_mb.MIA_businesscontacts  C
on A.bc_nr = C.business_contact_nr

WHERE A.margin NE 0
AND A.bc_nr IS NOT NULL
AND A.product_group_code IN ('FX', 'FXO', 'IRD', 'MM Taken', 'MM Given', 'DCM', 'ECM', 'Credit Bonds', 'Credit Bonds Debt Issues', 'Government Bonds' , 'Securities Finance', 'Equity Brokerage' )
AND C.klant_nr IS NOT NULL
AND A.transaction_source NOT LIKE '%FXPM%'
AND A.end_date > B.max_date

GROUP BY 1, 2, 3, 4;


CREATE TABLE mi_sas_aa_mb_c_mb.cib_klantbeeld_dpo  AS
      (
	SELECT
		  A.maand_nr
		, A.klant_nr
		, A.productnaam
		, A.productgroep
		, B.naam_verkoopkans
		, A.status
		, A.substatus

		, CAST (A.slagingskans  DECIMAL(3,0))  slagingskans
		, A.baten_totaal_looptijd
		, CAST( A.baten_totaal_Looptijd * slagingskans / 100  DECIMAL(22,0))  Revenues_Weighted
		, A.datum_laatst_gewijzigd
		, extract(year from A.datum_laatst_gewijzigd)*100 + extract(month from A.datum_laatst_gewijzigd)  maand_nr_laatste_wijziging

		, D.max_maand_nr

	FROM MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_Product  A

	JOIN MI_SAS_AA_MB_C_MB.cib_klantbeeld_klanten  XA
	ON A.klant_nr = XA.klant_nr

	JOIN MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans  B
	ON A.maand_nr = B.maand_nr
	AND A.Siebel_verkoopkans_id = B.Siebel_verkoopkans_id
	AND B.naam_verkoopkans not like 'MIGRATED%'

	LEFT JOIN  mi_sas_aa_mb_c_mb.cib_klantbeeld_rep_dp  D
	ON 1=1

	WHERE NOT (A.status LIKE 'Closed %')
) WITH DATA PRIMARY INDEX (Klant_nr, Maand_nr, productnaam, naam_verkoopkans, status);

CREATE TABLE mi_sas_aa_mb_c_mb.cib_klantbeeld_dpc  AS
      (
	SELECT
		  A.maand_nr
		, A.klant_nr
		, A.productnaam
		, A.productgroep
		, B.naam_verkoopkans
		, A.status
		, A.substatus

		, CAST (A.slagingskans  DECIMAL(3,0))  slagingskans
		, A.baten_totaal_looptijd
		, CAST( A.baten_totaal_Looptijd * slagingskans / 100  DECIMAL(22,0))  Revenues_Weighted
		, A.datum_laatst_gewijzigd
		, extract(year from A.datum_laatst_gewijzigd)*100 + extract(month from A.datum_laatst_gewijzigd)  maand_nr_laatste_wijziging

		, D.max_maand_nr

	FROM MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_Product  A

	JOIN MI_SAS_AA_MB_C_MB.cib_klantbeeld_klanten  XA
	ON A.klant_nr = XA.klant_nr

	JOIN MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans  B
	ON A.maand_nr = B.maand_nr
	AND A.Siebel_verkoopkans_id = B.Siebel_verkoopkans_id
	AND B.naam_verkoopkans not like 'MIGRATED%'

	LEFT JOIN  mi_sas_aa_mb_c_mb.cib_klantbeeld_rep_dp  D
	ON 1=1

	WHERE A.status LIKE 'Closed %'
	  AND maand_nr_laatste_wijziging > D.max_maand_nr-100
) WITH DATA
PRIMARY INDEX (maand_nr, klant_nr, productnaam, naam_verkoopkans, status);