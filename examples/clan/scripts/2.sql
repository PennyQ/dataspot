#DATASPOT-TERADATA

REPLACE VIEW mi_VM_SAS_AA_MB_C_MB.vCIAA_Mia_MaandNr
AS
SELECT
      mnd.*
FROM mi_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr mnd
;

REPLACE VIEW mi_VM_SAS_AA_MB_C_MB.vMia_hist
AS
SELECT *
FROM mi_SAS_AA_MB_C_MB.CIAA_Mia_hist MIa;



REPLACE VIEW mi_cmb.vMia_hist AS
SELECT *
FROM mi_vm_sas_aa_mb_c_mb.vMia_hist;


REPLACE VIEW mi_VM_SAS_AA_MB_C_MB.vMia_hist_PB
AS
SELECT *
FROM mi_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB MIa;



REPLACE VIEW mi_cmb.vMia_hist_PB AS
SELECT *
FROM mi_vm_sas_aa_mb_c_mb.vMia_hist_PB;

REPLACE VIEW mi_VM_SAS_AA_MB_C_MB.vMia_hist_PB_old
AS
SELECT *
FROM mi_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_OLD MIa;



REPLACE VIEW mi_cmb.vMia_hist_PB AS
SELECT * FROM mi_vm_sas_aa_mb_c_mb.vMia_hist_PB;

REPLACE VIEW mi_CMB.vMia_Periode AS
SELECT * FROM mi_SAS_AA_MB_C_MB.Mia_periode;


REPLACE VIEW mi_CMB.vMia_sector AS
SELECT * FROM mi_SAS_AA_MB_C_MB.Mia_sector;



REPLACE VIEW mi_VM_SAS_AA_MB_C_MB.vMia_week AS
SELECT Mia.*
FROM mi_SAS_AA_MB_C_MB.CIAA_Mia_hist MIa

LEFT OUTER JOIN mi_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr     b
  ON b.Maand_nr = MIa.Maand_nr

  WHERE b.N_maanden_terug = 0;

REPLACE VIEW mi_VM_SAS_AA_MB_C_MB.vMia_week_PB
AS
SELECT Mia.*
FROM mi_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB MIa

LEFT OUTER JOIN mi_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr     b
  ON b.Maand_nr = MIa.Maand_nr

  WHERE b.N_maanden_terug = 0
;

REPLACE VIEW mi_VM_SAS_AA_MB_C_MB.vMia_week_PB_old
AS
SELECT Mia.*
FROM mi_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_OLD Mia

LEFT OUTER JOIN mi_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr_OLD     b
  ON b.Maand_nr = MIa.Maand_nr

WHERE b.N_maanden_terug = 0;


REPLACE VIEW mi_cmb.vMia_week_PB
AS SELECT *
FROM mi_VM_SAS_AA_MB_C_MB.vMia_week_PB;

REPLACE VIEW mi_VM_SAS_AA_MB_C_MB.vCIAA_Mia_hist
AS
SELECT
     mia.Klant_nr
    ,mia.Maand_nr
FROM mi_SAS_AA_MB_C_MB.CIAA_Mia_hist              MIa
LEFT OUTER JOIN mi_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr     b
  ON b.Maand_nr = MIa.Maand_nr;



REPLACE VIEW mi_cmb.vMia_hist_incl_PB AS
SELECT Mia.*
  FROM mi_cmb.vMia_hist Mia
join mi_cmb.vMia_hist_PB Mia_PB
on 1=1;


REPLACE VIEW mi_cmb.vMia_week_incl_PB AS
SELECT Mia.*
  FROM mi_cmb.vMia_week Mia
join mi_cmb.vMia_week_PB Mia_PB;
on 1=1

REPLACE VIEW mi_vm_sas_aa_mb_c_mb.vMia_klantkoppelingen_hist AS
SELECT *
FROM mi_sas_aa_mb_c_mb.Mia_klantkoppelingen_hist
;



REPLACE VIEW mi_cmb.vMia_klantkoppelingen_hist AS
 SELECT *
   FROM mi_vm_sas_aa_mb_c_mb.vMia_klantkoppelingen_hist;



REPLACE VIEW mi_cmb.vMia_klantkoppelingen AS
 SELECT *
   FROM mi_vm_sas_aa_mb_c_mb.vMia_klantkoppelingen_hist
   WHERE Maand_nr IN (SELECT MAX(Maand_nr) FROM mi_vm_sas_aa_mb_c_mb.vMia_klantkoppelingen_hist);


REPLACE VIEW mi_vm_sas_aa_mb_c_mb.vMia_groepkoppelingen_hist AS
SELECT *
FROM mi_sas_aa_mb_c_mb.Mia_groepkoppelingen_hist
;



REPLACE VIEW mi_cmb.vMia_groepkoppelingen_hist AS
 SELECT *
   FROM mi_vm_sas_aa_mb_c_mb.vMia_groepkoppelingen_hist;



REPLACE VIEW mi_cmb.vMia_groepkoppelingen AS
 SELECT *
   FROM mi_vm_sas_aa_mb_c_mb.vMia_groepkoppelingen_hist
   WHERE Maand_nr IN (SELECT MAX(Maand_nr) FROM mi_vm_sas_aa_mb_c_mb.vMia_klantkoppelingen_hist);





REPLACE VIEW mi_vm_sas_aa_mb_c_mb.vCube_Baten_hist AS
SELECT *
FROM mi_SAS_AA_MB_C_MB.CIAA_Cube_Baten_hist    bat
;

REPLACE VIEW mi_VM_SAS_AA_MB_C_MB.vCIAA_Cube_Baten_hist
AS
SELECT
     bat.Klant_nr
    ,bat.Maand_nr
    ,bat.Datum_gegevens
    ,bat.Datum_baten
    ,bat.Baten
    ,bat.Baten_potentieel
    ,bat.Kredieten_baten
    ,bat.Kredieten_stoplicht AS Kredieten_stopl
    ,bat.Kredieten_bmark
    ,bat.Kredieten_pen
    ,bat.Lease_baten
    ,bat.Lease_stoplicht AS Lease_stopl
    ,bat.Lease_bmark
    ,bat.Lease_pen
FROM mi_SAS_AA_MB_C_MB.CIAA_Cube_Baten_hist    bat

LEFT OUTER JOIN mi_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr     b
  ON b.Maand_nr = bat.Maand_nr
;


AS
SEL
     eff.*
FROM mi_SAS_AA_MB_C_MB.CIAA_Beleggen         eff
;



REPLACE VIEW mi_CMB.vMia_Beleggen
AS
SEL
     eff.*
FROM mi_VM_SAS_AA_MB_C_MB.vMia_Beleggen         eff
;

REPLACE VIEW mi_VM_SAS_AA_MB_C_MB.vCIAA_Mia_Beleggen
AS
SELECT
     Eff.Klant_nr
    ,Eff.Maand_nr
    ,Eff.BC_nr
    ,Eff.Verkorte_naam


FROM mi_SAS_AA_MB_C_MB.CIAA_Beleggen         eff

LEFT OUTER JOIN mi_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr     b
  ON b.Maand_nr = eff.Maand_nr
;


REPLACE VIEW mi_VM_SAS_AA_MB_C_MB.vMia_Kredieten_hfd
AS
SELECT
      Mia.*
FROM mi_SAS_AA_MB_C_MB.mia_kredieten_hfd                 MIa
;



REPLACE VIEW mi_CMB.vMia_Kredieten_hfd AS
SELECT
      Mia.*
FROM mi_VM_SAS_AA_MB_C_MB.vMia_Kredieten_hfd                 MIa
;

REPLACE VIEW mi_VM_SAS_AA_MB_C_MB.vCIAA_Mia_kredieten_hfd
AS
SELECT
     Mia.Maand_nr
    ,Mia.Klant_nr
    ,COUNT(DISTINCT Mia.Contract_nr) AS N_Kredietcomplex
    ,MAX(CASE WHEN Mia.Bron_ACBS_ind = 1 THEN 1 ELSE 0 END) AS Ind_bron_ACBS
    ,MAX(CASE WHEN Mia.Bron_ACBS_ind = 0 THEN 1 ELSE 0 END) AS Ind_bron_OK
    ,MAX(Mia.Saldocompensatie_ind) AS Ind_saldocompens
    ,MAX(CASE WHEN Mia.Krediet_categorie_RISK = 'BK' THEN 1 ELSE 0 END) AS Ind_BK
    ,MAX(CASE WHEN Mia.Krediet_categorie_RISK = 'MK' THEN 1 ELSE 0 END) AS Ind_MK
    ,MAX(CASE WHEN Mia.Krediet_categorie_RISK = 'OV' THEN 1 ELSE 0 END) AS Ind_OV
    ,MAX(CASE WHEN Mia.Krediet_categorie_RISK = 'OK' THEN 1 ELSE 0 END) AS Ind_OK
    ,MAX(CASE WHEN Mia.Krediet_categorie_RISK = 'OX' THEN 1 ELSE 0 END) AS Ind_OX
    ,MIN(Mia.Vervaldatum_aflopend) AS MIN_vervaldt_aflop
    ,MAX(Mia.Aflopend_krediet_ind) AS Ind_aflopend
    ,MAX(Mia.Doorlopend_krediet_ind)  AS Ind_Doorlopend
    ,MAX(Mia.OBSI_limiet_ind)  AS Ind_OBSI_limiet
    ,SUM(Mia.OOE) AS OOE
    ,SUM(Mia.Doorlopend_opgenomen)    AS Doorlopend_opgenomen
    ,SUM(Mia.Doorlopend_uitnutt_perc) AS Doorlopend_uitnutt_perc
    ,SUM(Mia.Debet_volume)            AS Debet_volume
    ,SUM(Mia.Limiet_krediet)          AS Limiet_krediet
    ,SUM(Mia.Saldo_doorlopend)        AS Saldo_doorlopend
    ,SUM(Mia.Saldo_aflopend)          AS Saldo_aflopend
    ,SUM(Mia.Positie_obligo)          AS Positie_obligo
    ,MIN(Mia.Datum_revisie) AS MIN_dtm_revisie
    ,MAX(Mia.Datum_vorige_revisie) AS MAX_dtm_vorige_rev
    ,MAX(Mia.Ind_bijzonder_beheer) AS Solveon
    ,MAX(Mia.Krediet_soort) AS MAX_krediet_soort
    ,MAX(Mia.CRG) AS CRG
    ,MAX(Mia.UCR) AS UCR

    ,MAX(b.N_maanden_terug) AS N_maanden_terug

FROM mi_SAS_AA_MB_C_MB.Mia_Kredieten_hfd           Mia

LEFT OUTER JOIN mi_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr     b
  ON b.Maand_nr = MIa.Maand_nr

WHERE Klant_nr IS NOT NULL
  AND Klant_CGC BETWEEN 1100 AND 1299
GROUP BY 1,2;

REPLACE VIEW mi_VM_SAS_AA_MB_C_MB.vPart_zak
AS
SELECT
     pz.*
FROM mi_SAS_AA_MB_C_MB.CIAA_Part_zak    pz
;



REPLACE VIEW mi_CMB.vMia_Part_zak
AS
SELECT
     pz.*
FROM mi_VM_SAS_AA_MB_C_MB.vPart_zak    pz
;


REPLACE VIEW mi_VM_SAS_AA_MB_C_MB.vCIAA_Part_zak
AS
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
    ,pz.Sum_Baten_12mnd
    ,b.N_maanden_terug

FROM mi_SAS_AA_MB_C_MB.CIAA_Part_zak    pz

LEFT OUTER JOIN mi_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr     b
  ON b.Maand_nr = pz.Maand_nr;

REPLACE VIEW mi_cmb.vMia_week
AS SELECT *
FROM mi_VM_SAS_AA_MB_C_MB.vmia_week;

REPLACE VIEW mi_cmb.vmia_businesscontacts AS
SELECT A.Business_contact_nr,
       A.Klant_nr,
       A.Maand_nr,
       A.Datum_gegevens
  FROM mi_SAS_AA_MB_C_MB.Mia_businesscontacts A
  LEFT OUTER JOIN mi_cmb.vMia_week B
      ON A.Klant_nr = B.Klant_nr
  AND A.Maand_nr = B.Maand_nr
  LEFT OUTER JOIN mi_SAS_AA_MB_C_MB.CGC_BASIS C
  ON 1=1;

REPLACE VIEW mi_cmb.vKEM_pijplijn
AS
SELECT
      a.*
FROM mi_SAS_AA_MB_C_MB.KEM_pijplijn  a
;




REPLACE VIEW mi_VM_SAS_AA_MB_C_MB.vKEM_pijplijn
AS
SELECT
      a.*
FROM mi_SAS_AA_MB_C_MB.KEM_pijplijn  a
;




REPLACE VIEW mi_cmb.vKEM_aanvraag_det
AS
SELECT
      a.*
FROM mi_SAS_AA_MB_C_MB.KEM_aanvraag_det  a
;




REPLACE VIEW mi_VM_SAS_AA_MB_C_MB.vKEM_aanvraag_det
AS
SELECT
      a.*
FROM mi_SAS_AA_MB_C_MB.KEM_aanvraag_det  a
;



REPLACE VIEW mi_CMB.ahk_basis
AS
SELECT *
FROM mi_SAS_AA_MB_C_MB.ahk_basis;




REPLACE VIEW mi_CMB.VCGC_BASIS
 AS SELECT *
 FROM mi_SAS_AA_MB_C_MB.CGC_BASIS;



REPLACE VIEW mi_CMB.vRep_levels
AS SELECT * FROM  mi_SAS_AA_MB_C_MB.Rep_levels;




REPLACE VIEW mi_cmb.vMia_migratie_hist AS
SELECT *
  FROM mi_sas_aa_mb_c_mb.Mia_migratie_hist;



REPLACE VIEW mi_cmb.Mia_migratie_week AS
SELECT A.*
  FROM mi_sas_aa_mb_c_mb.Mia_migratie_hist A
  LEFT OUTER JOIN mi_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr B
    ON A.Maand_nr = B.Maand_nr
 WHERE B.N_maanden_terug = 0;




REPLACE VIEW mi_cmb.vTB_Baten_hist AS
SELECT *
FROM mi_SAS_AA_MB_C_MB.TB_Baten_hist;




REPLACE VIEW mi_VM_SAS_AA_MB_C_MB.vEM_Doelgroep_basis_CC_IC
AS
SELECT
     mia.Klant_nr
FROM mi_VM_SAS_AA_MB_C_MB.vCIAA_Mia_hist                      mia

INNER JOIN mi_VM_SAS_AA_MB_C_MB.VCIAA_Mia_MaandNr            mnd
   ON Mnd.Maand_nr = mia.Maand_nr

LEFT OUTER JOIN mi_VM_SAS_AA_MB_C_MB.vCIAA_Cube_Baten_hist   bat
   ON bat.Klant_nr = mia.Klant_nr
  AND bat.Maand_nr = mnd.Maand_nr_Cube_baten

LEFT OUTER JOIN mi_VM_SAS_AA_MB_C_MB.vCIAA_Mia_kredieten_hfd krd
   ON Krd.Klant_nr = mia.Klant_nr
  AND Krd.Maand_nr = mnd.Maand_nr_kredieten

LEFT OUTER JOIN mi_VM_SAS_AA_MB_C_MB.vCIAA_Part_zak    pz
   ON pz.Klant_nr = mia.Klant_nr
  AND pz.Maand_nr = mnd.Maand_nr_part_zak

WHERE mia.Business_line IN ('CC', 'IC')
;




REPLACE VIEW mi_cmb.vCUBe_leadstatus AS
SELECT
 a.Klant_nr
FROM mi_cmb.CUBe_leadstatus_hist A
  LEFT OUTER JOIN mi_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr     b
    ON a.Maand_nr = b.Maand_nr
 WHERE b.N_maanden_terug = 0;


REPLACE VIEW mi_cmb.vmia_organisatie AS
SELECT
 Org_niveau3
,Org_niveau3_bo_nr
,Org_niveau2
,Org_niveau2_bo_nr
,Org_niveau1
,Org_niveau1_bo_nr
,Org_niveau0
,Org_niveau0_bo_nr
,BO_BL
FROM mi_SAS_AA_MB_C_MB.MIA_organisatie;


REPLACE VIEW mi_cmb.mia_organisatie AS
SELECT
 Org_niveau3
,Org_niveau3_bo_nr
,Org_niveau2
,Org_niveau2_bo_nr
,Org_niveau1
,Org_niveau1_bo_nr
,BO_BL
FROM mi_SAS_AA_MB_C_MB.MIA_organisatie;



REPLACE VIEW mi_cmb.vCRM_Employee_week AS
SELECT A.*
  FROM mi_SAS_AA_MB_C_MB.Siebel_Employee A;




REPLACE VIEW mi_cmb.vCRM_Contactpersoon_week AS
SELECT A.Klant_nr,
       A.Maand_nr,
       A.Datum_gegevens,
       A.Business_contact_nr,
       A.Siebel_contactpersoon_id,
       A.Achternaam,
       A.Tussenvoegsel,
       A.Achtervoegsel,
       A.Contactpersoon_titel,
       A.Initialen,
       A.Voornaam,
       A.Adres,
       A.Postcode,
       A.Plaats,
       A.Telefoonnummer,
       A.Land,
       A.Email,
       A.Email_net,
       A.Email_bruikbaar,
       A.Contactpersoon_onderdeel,
       A.Contactpersoon_functietitel,
       A.Actief_ind,
       A.Academische_titel,
       A.Niet_bellen_ind,
       A.Niet_mailen_ind,
       A.Geen_marktonderzoek_ind,
       A.Geen_events_ind,
       A.Primair_contact_persoon_ind,
       A.Client_level,
       A.SDAT,
       A.EDAT
 FROM mi_SAS_AA_MB_C_MB.Siebel_Contactpersoon A;




REPLACE VIEW mi_cmb.vCRM_Verkoopkans_week AS
SELECT A.*
  FROM mi_SAS_AA_MB_C_MB.Siebel_Verkoopkans A;




REPLACE VIEW mi_cmb.vCRM_Verkoopkans_product_week AS
SELECT A.Klant_nr,
       A.Maand_nr,
       A.Datum_gegevens,
       A.Business_contact_nr,
       A.Siebel_verkoopkans_product_id,
       A.Siebel_verkoopkans_id,
       A.Productnaam,
       A.Productgroep,
       A.Pnc_contract_nummer,
       A.Aantal,
       A.Omzet,
       A.Baten_eenmalig,
       A.Baten_terugkerend,
       A.Baten_totaal_1ste_12mnd,
       A.Baten_totaal_looptijd,
       A.Status,
       A.Substatus,
       A.Reden,
       A.Slagingskans,
       A.Start_baten,
       A.Eind_baten,
       A.Looptijd_mnd,
       A.Vertrouwelijk_ind,
       A.Sbt_id_mdw_eigenaar,
       A.Naam_mdw_eigenaar,
       A.Sbt_id_mdw_aangemaakt_door,
       A.Naam_mdw_aangemaakt_door,
       A.Datum_aangemaakt,
       A.Datum_laatst_gewijzigd,
       A.Datum_nieuw,
       A.Datum_in_behandeling,
       A.Datum_gesl_succesvol,
       A.Datum_gesl_niet_succesvol,
       A.Client_level,
       A.Verkoopkans_product_sdat AS SDAT,
       A.Verkoopkans_product_edat AS EDAT
  FROM mi_SAS_AA_MB_C_MB.Siebel_Verkoopkans_Product A;





REPLACE VIEW mi_cmb.vCRM_Activiteit_week AS
SELECT A.*
  FROM mi_SAS_AA_MB_C_MB.Siebel_Activiteit A;




REPLACE VIEW mi_cmb.vCRM_Activiteit_participants_week AS
SELECT A.*
  FROM mi_SAS_AA_MB_C_MB.Siebel_act_participants A;



REPLACE VIEW mi_cmb.vCRM_CST_member_week AS
SELECT A.Klant_nr,
       A.Maand_nr,
       A.Datum_gegevens,
       A.Business_contact_nr,
       A.Leidend_Business_contact,
       A.Bc_Business_segment,
       A.SBT_ID,
       A.Naam,
       A.Sbl_cst_deelnemer_rol,
       A.SBL_gedelegeerde_ind,
       A.TB_Consultant,
       A.Client_level,
       A.Party_party_relatie_sdat AS SDAT,
       A.Party_party_relatie_edat AS EDAT
  FROM mi_SAS_AA_MB_C_MB.Siebel_CST_member_HIST A
  LEFT OUTER JOIN mi_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr B
    ON A.Maand_nr = B.Maand_nr
 WHERE B.N_maanden_terug = 0;



REPLACE VIEW mi_cmb.vCRM_CST_member_hist AS
SELECT A.Klant_nr,
       A.Maand_nr,
       A.Datum_gegevens,
       A.Business_contact_nr,
       A.Leidend_Business_contact,
       A.Bc_Business_segment,
       A.SBT_ID,
       A.Naam,
       A.Sbl_cst_deelnemer_rol,
       A.SBL_gedelegeerde_ind,
       A.TB_Consultant,
       A.Client_level,
       A.Party_party_relatie_sdat AS SDAT,
       A.Party_party_relatie_edat AS EDAT
  FROM mi_SAS_AA_MB_C_MB.Siebel_CST_member_HIST A;

REPLACE VIEW mi_cmb.vCRM_Verkoopkans_contactpersoon_week AS
SELECT A.*
  FROM mi_SAS_AA_MB_C_MB.Siebel_verkoopkans_contactpersoon A;

REPLACE VIEW mi_cmb.vCRM_Verkoopteam_member_week AS
SELECT A.*
  FROM mi_SAS_AA_MB_C_MB.Siebel_verkoopteam_member A;



REPLACE VIEW mi_cmb.vCRM_Deal_week AS
SELECT A.*
  FROM mi_SAS_AA_MB_C_MB.Siebel_Deal A;



REPLACE VIEW mi_cmb.vPc_commercial_banking AS
SELECT COALESCE(A.Pc4, B.Pc4) AS Pc4,
       A.Org_niveau2_bo_nr,
       A.Org_niveau2,
       A.Marktgebied,
       A.FAC_bo_nr,
       A.FAC,
       B.Geo_locatie
  FROM mi_SAS_AA_MB_C_MB.Pc_SME_Banking A
  FULL OUTER JOIN mi_SAS_AA_MB_C_MB.Pc_Geo_locaties B
    ON A.Pc4 = B.Pc4;




REPLACE VIEW mi_cmb.Pc_commercial_clients AS
SELECT *
  FROM mi_SAS_AA_MB_C_MB.Pc_commercial_clients;




REPLACE VIEW mi_CMB.vMedewerker_Security
AS
  SELECT SA.* FROM mi_SAS_AA_MB_C_MB.Medewerker_Security SA
;





REPLACE VIEW mi_cmb.AGRC_MCT
AS SELECT * FROM mi_SAS_AA_MB_C_MB.AGRC_MCT;



REPLACE VIEW mi_cmb.AGRC_REM
AS SELECT * FROM mi_SAS_AA_MB_C_MB.AGRC_REM;



REPLACE VIEW mi_cmb.AGRC_IMAT
AS SELECT * FROM mi_SAS_AA_MB_C_MB.AGRC_IMAT;




REPLACE VIEW mi_CMB.vCTrack_Portfolio_Hist
AS SELECT A.*
FROM mi_SAS_AA_MB_C_MB.CTrack_Portfolio_Hist A;


REPLACE VIEW mi_cmb.vMedewerker_email
AS SELECT * FROM mi_SAS_AA_MB_C_MB.medewerker_email;
