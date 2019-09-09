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

       -- Drawings
      SEL
           c.Draw_Bc_nr (INTEGER) AS Bc_nr
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