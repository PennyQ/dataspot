/*01b_C_MB_Basissets_tabellen.sql ****************************************************/
/*************************************************************************************/
/* SCRIPT  '01b_C_MB_Basissets_tabellen.sql'                                         */
/*                                                                                   */
/* Opbouw van Basis sets ten behoeve van het modelleren binnen SAS.                  */
/* Het betreft tabellen met klantinfo op beschouwingsniveau commercieel)complex      */
/*-----------------------------------------------------------------------------------*/
/* Wijzigingen                                                                       */
/*                                                                                   */
/* Wie          | Datum      | Versie | Verandering(en)                              */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 04-09-2013 |   1.0  | Initiele versie                              */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 10-09-2013 |   1.1  | DROP statements naar afzonderlijk script     */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 13-09-2013 |   1.2  | NEW-tabellen                                 */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 18-09-2013 |   1.3  | Beleggen zorgplichtsignaal 3maanden oud      */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 24-09-2013 |   1.4  | 'PARTITION BY' op grote tabellen             */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 24-09-2013 |   1.5  | Mi_analyse.Miaz_interacties vervangen door   */
/*              |            |        |  Mi_cmb.Mia_interacties_NEW                  */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 30-09-2013 |   1.6  | Nieuw: MI_SAS_AA_MB_C_MB.KTV_CCC_Bedrijven   */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 04-10-2013 |   1.7  | aanpassing MI_temp.CIAA_PFV_zak_kopp         */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 05-11-2013 |   1.8  | Nieuw: Part_zak                              */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 08-11-2013 |   1.9  | KTV selectie : lead uitsl. afgelopen 7 dagen */
/*--------------+------------+--------+----------------------------------------------*/
/* HvH          | 13-11-2013 |   1.10 | BCDB SBI* als basis voor Sectorinformatie    */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 18-11-2013 |   1.11 | Correctie Sectorinformatie                   */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 09-12-2013 |   1.12 | Toevoegen Part-zak gemachtigde part klant    */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 11-12-2013 |   1.13 | Gewijzigde kredieten tabel                   */
/*--------------+------------+--------+----------------------------------------------*/
/* VT           | 18-12-2013 |   1.14 | Tijdelijke wijziging CCA agri & BUN          */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 18-12-2013 |   1.15 | Tabel met draadatum vanuit script 6b         */
/*--------------+------------+--------+----------------------------------------------*/
/* VT           | 18-12-2013 |   1.16 | Toevoegen Sectorinformatie vanuit NZDB       */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 19-12-2013 |   1.17 | Wijzigingen kredieten tabel                  */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 20-01-2014 |   1.18 | - verwijderen dubbelslag Part_zak            */
/*              |            |        | - complexe producten obv MIND data           */
/*--------------+------------+--------+----------------------------------------------*/
/* VT           | 22-01-2014 |   1.19 | Opbouw Mi_temp.Mia_week conform nieuwe namen */
/*              |            |        | en gevolgen voor vervolg aangepast           */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 28-01-2014 |   1.20 | Complexe producten en veld CGC theoretisch   */
/*--------------+------------+--------+----------------------------------------------*/
/* VT           | 29-01-2014 |   1.21 | - Toevoegen Aantal_bcs_in_scope en           */
/*              |            |        |   Bijzonder_beheer_ind aan Mi_temp.Mia_week  */
/*              |            |        | - Verwijderen Mi_temp.Mia_klant_extrainfo    */
/*              |            |        | - Tijdelijke update TPB                      */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 29-01-2014 |   1.22 | Mia_klantkoppelingen_hist                    */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 31-01-2014 |   1.23 | Asterix voor MI_SAS_AA_MB_C_MB.CIAA_beleggen */
/*              |            |        | - Complex prod: Maatwerktarifering betalvrkr */
/*--------------+------------+--------+----------------------------------------------*/
/* VT           | 04-02-2014 |   1.24 | - Algemeen Datum_gegevens aangepast          */
/*              |            |        | - Mi_temp.Signaal aangepast                  */
/*--------------+------------+--------+----------------------------------------------*/
/* VT           | 05-02-2014 |   1.25 | CUBe bedrijfstak aangepast                   */
/*--------------+------------+--------+----------------------------------------------*/
/* VT           | 09-02-2014 |   1.26 | Schoonheidsfoutje eruit gehaald              */
/*--------------+------------+--------+----------------------------------------------*/
/* VT           | 12-02-2014 |   1.27 | Benchmarken en wegloopmodel toevoegen        */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 26-02-2014 |   1.28 | extra stats tbv MSTR                         */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 28-02-2014 |   1.29 | compress velden kredieten tabel              */
/*--------------+------------+--------+----------------------------------------------*/
/* VT           | 03-03-2014 |   1.30 | Aanpassingen ten behoeve van Beoordeeld      */
/*--------------+------------+--------+----------------------------------------------*/
/* VT           | 26-03-2014 |   1.31 | Aanpassingen ten behoeve van Beoordeeld      */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 01-04-2014 |   1.32 | - Aantal mi_cmb vervangen door tabellen in   */
/*              |            |        |   MI_SAS_AA_MB_C_MB                          */
/*              |            |        | - gewijzigde CCA reeksen RM tbv. Beleggen    */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 04-04-2014 |   1.33 | Beleggen: aantal klanten met zorgplichtsign. */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 09-04-2014 |   1.34 | Complexe producten (eerste drie bij naam)    */
/*              |            |        | en verwijderen tijdelijke update TPB         */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 30-04-2014 |   1.35 | Correctie complexe producten                 */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 14-05-2014 |   1.36 | ZZP-AKW nieuwe AGIC                          */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 19-05-2014 |   1.37 | DWA heeft 'vreemde' karakters verwijderd &   */
/*              |            |        | correctie  vergeten comma bij AKW SBI codes  */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 23-05-2014 |   1.38 | Kleine wijziging complex prod GRV010/020/030 */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 27-05-2014 |   1.39 | - Betaal transacties ook voor CC             */
/*              |            |        | - gewijzigde definitie Complex Arrang. kred. */
/*              |            |        | - gewijzigde definitie Complex GRV010020030  */
/*              |            |        | - Bijzonder_beheer_ind mede obv Kredieten FI */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 06-05-2014 |   1.40 | - gewijzigde definitie Complex GRV010        */
/*--------------+------------+--------+----------------------------------------------*/
/* VT           | 08-07-2014 |   1.41 | Mia_businesscontacts toegevoegd              */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 15-07-2014 |   1.42 | Beleggen: BC zorgplicht actie vereist        */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 04-08-2014 |   1.43 | Beleggen: zorgplichtsign indien geen nul-dep */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 15-08-2014 |   1.44 | Retentie: oplossen discrepantie lopende mnd  */
/*              |            |        | en laatste maand ingelezen leads.            */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 18-08-2014 |   1.45 | Afleiden nieuwe BO-structuur YBB klanten     */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 29-08-2014 |   1.46 | - Internationaal segment nieuw in Mia_hist   */
/*              |            |        | - CGC 1205 wordt businessline 'CC'           */
/*              |            |        | - Clientgroep_theoretisch in Mia_hist vullen */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 05-09-2014 |   1.47 | Internationaal segment aanpassing            */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 18-09-2014 |   1.48 | Uitzetten CREATE TABLE KTV_CCC_Bedrijven_NEW */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 29-09-2014 |   1.49 | Aanzetten CREATE TABLE KTV_CCC_Bedrijven_NEW */
/*              |            |        | Internat ind. obv volume pct ipv trx pct     */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 15-10-2014 |   1.50 | Segment LC&MB aanpassen aan gewijzigde naam  */
/*              |            |        | Corperate Client Units                       */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 20-10-2014 |   1.51 | CGC 1232 wordt businessline 'CC'             */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 20-10-2014 |   1.52 | Complex product 'EXECUTION ONLY'             */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 03-11-2014 |   1.52 | Voorloopnul toegevoegd aan KvK-nummer in     */
/*              |            |        | Mia_businesscontacts                         */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 10-11-2014 |   1.53 | Mi_vm.vClient vervangen door                 */
/*              |            |        | MI_vm_Ldm.aKLANT_PROSPECT                    */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 18-11-2014 |   1.54 | correctie foutje bij bepalen Public voor CC  */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 28-11-2014 |   1.55 | Cidat in MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr  */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 02-12-2014 |   1.56 | Afleiding Klantstatus aangepast              */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 21-01-2015 |   1.57 | - Afleiding Maatwerk tarifering betalings-   */
/*              |            |        |   verkeer (Complex_prod_RC_mtwrk)            */
/*              |            |        | - COLLECT STATISTICS toegevoegd              */
/*              |            |        | - Maand_nr gewijzigd in Mia_businesscontacts */
/*              |            |        | - SBI, AGIC en Sector informatie uit NZDB    */
/*              |            |        |   (ipv Mi_cmb.hh_CMB_sector)                 */
/*              |            |        | - Afleiding Dashboard (sub)doelgroepen gein- */
/*              |            |        |   tegreerd in Mia_week                       */
/*              |            |        | - Updates (remedy) supsects verwijderd       */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 26-01-2015 |   1.58 | - Kleine correctie op vorige wijzigingen     */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 24-02-2015 |   1.59 | - Kleine correctie beleggen NZDB CC_nr       */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 25-02-2015 |   1.60 | Verwijderen Mi_cmb.Axl_cube_cbi              */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 30-03-2015 |   1.61 | Model_variant_id vervallen                   */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 01-06-2015 |   1.62 | Vermijden dat script stuk loopt bij ontbreken*/
/*              |            |        | tabel MI_cmb.TRC_REK_COURANT                 */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 03-06-2015 |   1.63 | CommentString toevoegen aan Mi_cmb tabellen  */
/*              |            |        | welke worden gebruikt in het CIAA schedule   */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 17-06-2015 |   1.64 | Signaal in Mia_week aangepast                */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 30-06-2015 |   1.65 | Aanpassen afleiding leidend BC               */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 02-07-2015 |   1.66 | toelichting tbv re-run                       */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 22-07-2015 |   1.67 | Aanpassen afleiding sector in Mia_week       */
/*              |            |        | (tabel S tbv CIDAR Light klanten)            */
/*              |            |        | ivm fout bij maandovergang                   */
/*--------------+------------+--------+----------------------------------------------*/
/* PO           | 10-08-2015 |   1.68 | Aanpassen internationale - script deel       */
/*              |            |        | Variabelenamen in sni/snu tabellen is        */
/*              |            |        | veranderd                                    */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 17-08-2015 |   1.69 | 1. YBB heeft nieuwe CCA codes: opnemen in    */
/*              |            |        | koppeling met Mi_vm_nzdb.vBO_teams zodat BO  */
/*              |            |        | structuur wordt gevonden                     */
/*              |            |        | 2. confrom afspraken met Mathon en Thomas    */
/*              |            |        | worden klanten obv CGC naar business line    */
/*              |            |        | RM / YBB ingedeeld                           */
/*              |            |        | 3. ihkv Clientgroep_theoretisch werd tabel   */
/*              |            |        | MI_SAS_AA_MB_C_MB.CIAA_Mia_hist geupdated,   */
/*              |            |        | ik vermoed dat dit de '_NEW' tabel moet zijn */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 24-08-2015 |   1.70 | UPDATE MI_SAS_AA_MB_C_MB.CIAA_Mia_hist ihkv  */
/*              |            |        | Clientgroep_theoretisch is te zwaar, nu een  */
/*              |            |        | INSERT                                       */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 14-09-2015 |   1.71 | Mia_week bevatte CASESPECIFIC velden         */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 17-09-2015 |   1.72 | nieuwe YBB CCA openemen                      */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 24-09-2015 |   1.73 | Toevoegen SBI's in MI_SAS_AA_MB_C_MB.Mia_sector_NEW        */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 30-09-2015 |   1.74 | 1. Mia_businesscontacts: US Person indicator */
/*              |            |        |    + omschrijving toegevoegd                 */
/*              |            |        | 2. Mia_businesscontacts: Risicoscore Klant   */
/*              |            |        |    toegevoegd                                */
/*              |            |        |    3. Mia_bc_info/Mia_klant_info/Mia_week:   */
/*              |            |        |       Surseance + Faillissement indicator    */
/*              |            |        |       toegevoegd                             */
/*              |            |        |    4. Mia_hist: Primary index op             */
/*              |            |        |       business_contact_nr tbv performance    */
/*              |            |        | 5. Mia_businesscontacts: MIFID Fitness test  */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 12-10-2015 |   1.75 | 1. Mifid fitnesstest: diverse kleine         */
/*              |            |        |    aanpassingen op format kolommen           */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 31-10-2015 |   1.76 | 1. Aanpassen naamgeving nieuwe velden        */
/*              |            |        |    Mia_Businesscontacts naar BC_xxx (v1.74)  */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB en VvT   | 11-11-2015 |   1.77 | 1. Aanpassen hele script aan nieuwe klant-   */
/*              |            |        |    complexen BCDB / Siebel                   */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 18-11-2015 |   1.78 | 1. Twee kleine aanpassingen:                 */
/*              |            |        |    - Mia_week: kolommen uit voor CC en LC&MB */
/*              |            |        |    - Toevoegen collect stats                 */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 23-11-2015 |   1.79 | 1. KEM afdelingstabellen opgenomen           */
/*              |            |        | 2. f.Segment_id = 20 werkt niet meer         */
/*              |            |        |    (TD update?) --> TRIM(f.Segment_id) = '20'*/
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 02-12-2015 |   1.80 | 1. Enkele correcties en verbeteringen n.a.v. */
/*              |            |        |    wijzigingen in versie 1.77                */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT/BdB      | 10-12-2015 |   1.81 | 1. Omzetklasse uniek maken door extensie 'x' */
/*              |            |        | 2. Mia_businesscontacts:                     */
/*              |            |        | - FATCA indicator (J - classificatie aanw.   */
/*              |            |        |   N - niet geclassificeerd)                  */
/*              |            |        | - FATCA classificatie                        */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 28-12-2015 |   1.82 | Mia_businesscontacts:                        */
/*              |            |        | COLLECT STATISTICS op PI en SI's             */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 17-01-2016 |   1.83 | Mia_week / CUBe_totaal verwijderd:           */
/*              |            |        | Sector_agic, Subsector_agic,                 */
/*              |            |        | Business_contact_nr1 tm5                     */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB/SF       | 31-01-2016 |   1.84 | 1. Bron verwijderd uit alle afdelingstabellen*/
/*              |            |        | 2. Contactinfo tijdelijk op NULL ivm Siebel: */
/*              |            |        | - Datum_volgend_contact                      */
/*              |            |        | - Datum_laatste_contact_pro_ftf              */
/*              |            |        | - Aantal_contact_pro_ftf                     */
/*              |            |        | - Aantal_contact_pro_tel                     */
/*              |            |        | - Contactpersoon                             */
/*              |            |        | - Emailadres                                 */
/*              |            |        | 3. Cx_nr verwijderd uit:                     */
/*              |            |        | - Mia_alle_bcs en Mia_business_contacts      */
/*              |            |        | 4. Bepaling Leidend_bc_ind in Mia_alle_bcs   */
/*              |            |        | gecorrigeerd                                 */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB/VvT      | 14-02-2016 |   1.85 | 1. Mia_hist/Mia_business_contacts/           */
/*              |            |        | Mia_beleggen:                                */
/*              |            |        | - House > Unit                               */
/*              |            |        | - House_bo_br > Unit_bo_nr                   */
/*              |            |        | 2. Mia_businesscontacts  toegevoegd:         */
/*              |            |        | - Koppeling_id_CE                            */
/*              |            |        | 3. Regio en regio_bo_nr nu ook beschikbaar   */
/*              |            |        | voor businessline CC                         */
/*              |            |        | 4. Mia_interacties uitgezet, wordt niet meer */
/*              |            |        |    gebruikt                                  */
/* VvT          | 15-02-2016 |   1.86 | Diverse correcties                           */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 15-02-2016 |   1.87 | stats Mi_temp.CUBe_benchmark_00x - tabellen  */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 15-02-2016 |   1.88 | KEM CGC van BCnr per laatste stand aanvraag  */
/* VvT          |            |        | Nieuwe insert Mi_temp.Mia_week               */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 16-02-2016 |   1.89 | Correctie afleiding Segment = 'Public'       */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 23-02-2016 |   1.90 | Statistics tbv VVB                           */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB/VvT      | 23-02-2016 |   1.91 | 1. Koppeling_id_CE toegevoegd aan            */
/*              |            |        | Mia_klantkoppelingen                         */
/*              |            |        | 2. Nieuwe segmentatie KZ/MB/GB/PSC/REC in    */
/*              |            |        | Mia_hist                                     */
/*              |            |        | 3. Nieuwe businesslines R&PB/CC/IC in        */
/*              |            |        | Mia_klant_info                               */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 03-03-2016 |   1.92 | - CUBEbaten hersteld (businessline, segment) */
/*              |            |        | - Commentaar altijd mbv  */  /*              */
/*              |            |        | - Commentaar altijd einde van de regel, niet */
/*              |            |        |   midden in een SQL statement                */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 03-03-2016 |   1.93 |   CUBE IC opgenomen (deels)                  */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB/VvT      | 09-03-2016 |   1.94 | - Kolomdefinities LATIN CASESPECIFIC omgezet */
/*              |            |        |   naar LATIN NOT CASESPECIFIC                */
/*              |            |        | - Afleiding Relatiemanager, Team, Unit en    */
/*              |            |        |   Regio voor vml Corporate Clients aangepast */
/*              |            |        | - CUBe aangepast voor Commercial Clients     */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 15-03-2016 |   1.95 |- Afleiding Relatiemanager, Team, Unit en     */
/*              |            |        |  Regio voor vml Corporate Clients aangepast  */
/*              |            |        |- CUBe aangepast voor Commercial Clients      */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 15-03-2016 |   1.96 | - Toevoegen kolommen aan Mia_klantbaten      */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 31-03-2016 |   1.97 | Comment Mia_baten_benchmarken_003 verwijderd */
/*              |            |        | ivm vastlopen scheduled job in CIAA schedule */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 31-03-2016 |   1.98 | 1. Statistics toegevoegd aan:                */
/*              |            |        |    -Mi_Temp.Mia_klanten                      */
/*              |            |        |    -Mia_klant_baten_benchmarken              */
/*              |            |        | 2. Koppeling_id_CG toegevoegd aan:           */
/*              |            |        |    - Mia_bc_info                             */
/*              |            |        |    - Mia_alle_bcs                            */
/*              |            |        |    - Mia_businesscontacts                    */
/*              |            |        | 3. Nieuwe tabel Mia_groepkoppelingen         */
/*              |            |        |    toegevoegd                                */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 13-04-2016 |   1.99 | 1. Onderhoudstabel Mia_TableSize_Hist        */
/*              |            |        |    toegevoegd met info over tabelgrootte en  */
/*              |            |        |    tableskew                                 */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 14-04-2016 |   2.00 | Clientgroep 9001 uitgesloten bij             */
/*              |            |        | Mia_businesscontacts                         */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 26-04-2016 |   2.01 | 1. Contactinformatie Mia_week vanuit Siebel: */
/*              |            |        |     - Datum_laatste_contact_pro_ftf          */
/*              |            |        |     - Datum_volgend_contact                  */
/*              |            |        |     - Aantal_contact_pro_tel                 */
/*              |            |        |     - Aantal_contact_pro_ftf                 */
/*              |            |        | 2. GSRI informatie toegevoegd aan            */
/*              |            |        |    Mia_businesscontacts:                     */
/*              |            |        |     - BC_Party_GSRI_berekend                 */
/*              |            |        |     - BC_GSRI_Beoord_comment                 */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 02-05-2016 |   2.02 | 1. Integratie Siebel script:                 */
/*              |            |        |     - Opbouw temp tabellen voor Mia_week     */
/*              |            |        |     - Opbouw eindtabellen onder paragraaf 10 */
/*              |            |        | 2. Opbouw onderhoudstabel Mia_tbl_size       */
/*              |            |        |    verwijderd                                */
/*              |            |        | 3. Koppeling_id_CG groepkoppelingen aangepast*/
/*              |            |        | 4. GSRI informatie: zero length velden       */
/*              |            |        |    geconverteerd naar NULL                   */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 09-05-2016 |   2.03 | UPI MI_TEMP.Siebel_Verkoopkans_NEW           */
/*              |            |        | aangepast naar PI                            */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 11-05-2016 |   2.05 | Lengte diverse Siebel velden aangepast naar  */
/*              |            |        | lengte bron velden                           */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 18-05-2016 |   2.06 | 1. Stuurtabel CGC_basis als bron voor:       */
/*              |            |        |     - business_line (mia_klant_info)         */
/*              |            |        |     - segment (mia_week)                     */
/*              |            |        | 2.LEFT() functie vervangen door SUBSTR()     */
/*              |            |        |   in opbouw Siebel tabellen                  */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 23-05-2016 |   2.07 | GSRI informatie tijdelijk op NULL ivm        */
/*              |            |        | foutieve info LDM                            */
/*--------------+------------+--------+----------------------------------------------*/
/* SS           | 23-05-2016 |   2.08 | Aanpassing bepaling Functie in               */
/*              |            |        | Siebel_Employee                              */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 24-05-2016 |   2.09 | 1. JD28: Nieuwe indeling Omzetklasse_id      */
/*              |            |        |    Mia_week/Mia_hist                         */
/*              |            |        | 2. JD31 Toegevoegd aan Mia_business_contacts:*/
/*              |            |        |    - Ultimate Legal Parent (ULP)             */
/*              |            |        |    - Global BC (GBC)                         */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 31-05-2016 |   2.10 | 1. ALC toegepast op diverse VARCHAR kolommen */
/*              |            |        |    Mia_week/Mia_hist                         */
/*              |            |        | 2. Blockcompressie toegepast op              */
/*              |            |        |    Cube_leadstatus_hist                      */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 31-05-2016 |   2.11 | 8. KTV YBC Bedrijven verwijderd uit script   */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 15-06-2016 |   2.12 | Opbouw MI_SAS_AA_MB_C_MB.Mia_sector_NEW obv  */
/*              |            |        | MI_SAS_AA_MB_C_MB.mdm_1721 + toegevoegd aan  */
/*              |            |        | Mia_week/hist:                               */
/*              |            |        |  - Subsector_code                            */
/*              |            |        |  - Subsector_oms                             */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 16-06-2016 |   2.13 | Workaround ophalen team informatie IC        */
/*              |            |        | geimplementeerd in opbouw Mia_week.          */
/*              |            |        | Team en team_bo_nr nu beschikbaar in Mia_week*/
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 19-07-2016 |   2.14 | 1. Correctie opbouw Mia_week:                */
/*              |            |        |   - afleiding Datum_laatste_contact_pro_ftf  */
/*              |            |        |   - afvangen '-101' waarde velden            */
/*              |            |        | 2. Error handling opbouw Mia_alle_bcs        */
/*              |            |        | 3. US Person velden hernoemd:                */
/*              |            |        |  Bc_US_Person_ind naar BC_SEC_US_Person_ind  */
/*              |            |        |  Bc_US_Person_oms naar BC_SEC_US_Person_oms  */
/*              |            |        |  Bc_FATCA_ind naar BC_FATCA_US_Person_ind    */
/*              |            |        |  Bc_FATCA_class naar BC_FATCA_US_Person_ind  */
/*              |            |        | 4. Klantindeling Siebel toegevoegd aan       */
/*              |            |        |    Subsegment Mia_week/hist                  */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 25-07-2016 |   2.15 | 1. Veld Extra_informatie toegevoegd aan      */
/*              |            |        |   Siebel_verkoopkans_product (ivm KEM ref.)  */
/*              |            |        | 2. GSRI velden weer gevuld nav fix           */
/*              |            |        |   aParty_GSRI tabel                          */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 09-08-2016 |   2.16 | 1. Correctie afleiding CCA, team_bo_nr       */
/*              |            |        | en team voor business_line IC                */
/*              |            |        | 2. Regio voor business_line IC uit           */
/*              |            |        | cidar_BO_Team                                */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 17-08-2016 |   2.17 | Siebel_Verkoopkans_Product:                  */
/*              |            |        |  Baten_totaal gevuld                         */
/*              |            |        | (Baten_eenmalig + baten_terugkerend)         */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 22-08-2016 |   2.18 | Siebel_Verkoopkans_Product:                  */
/*              |            |        |  Baten_totaal gecorrigeerd ivm NULL waarden  */
/*              |            |        | zeroifnull(Baten_eenmalig) +                 */
/*              |            |        | zeroifnull(baten_terugkerend)                */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 31-08-2016 |   2.19 | Siebel_Employee:                             */
/*              |            |        |  -CCA toegevoegd                             */
/*              |            |        |  -SQL voor ophalen Naam medewerker aangepast */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 05-09-2016 |   2.20 | Tabel Mi_cmb.Pvdv_offers vervangen door:     */
/*              |            |        | Mi_cmb.TB_offers                             */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 06-09-2016 |   2.21 | Kolommen toegevoegd aan Mia_week/hist:       */
/*              |            |        |  - Datum_laatste_contact_ftf                 */
/*              |            |        |  - Aantal_contact_ftf                        */
/*              |            |        |  - Aantal_contact_tel                        */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 09-09-2016 |   2.22 | 1. Correctie ophalen klant- en bc-nummer     */
/*              |            |        |  Siebel tabellen voor Commerciele Groepen.   */
/*              |            |        | 2. Bepaling klantstatus Mia_bc_info aangepast*/
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 09-09-2016 |   2.23 | 1. Correctie opbouw Siebel tabellen nav      */
/*              |            |        |    laatste wijziging                         */
/*              |            |        | 2. Siebel_act_participants:                  */
/*              |            |        |    CTP_Unique_id van VARCHAR(10)             */
/*              |            |        |    naar VARCHAR(13)                          */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 13-09-2016 |   2.24 | CUBe aanpassen mbt Siebel leads; betreft mn. */
/*              |            |        | tabel Mi_temp.Mia_baten_benchmarken_005,     */
/*              |            |        |  Mi_temp.Mia_baten_benchmarken_006,          */
/*              |            |        |  MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW       */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 15-09-2016 |   2.25 | Aanpassen Baten_benchmark in de tabel        */
/*              |            |        | Mi_temp.Mia_baten_benchmarken_003            */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 19-09-2016 |   2.26 | 1. Tijdelijke aanpassing ophalen KvK nummer  */
/*              |            |        | Mia_alle_bcs ivm DQ issue MIND (INC1389382)  */
/*              |            |        | 2. Nieuw veld Siebel Verkoopkans:            */
/*              |            |        |    - Verkoopkans_naam                        */
/*              |            |        | 3. Nieuwe velden Siebel Verkoopkans_product: */
/*              |            |        |    - Datum_aangemaakt                        */
/*              |            |        |    - Datum_laatst_gewijzigd                  */
/*              |            |        |    - Revenue_ID                              */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 20-09-2016 |   2.27 | ook IC opnemen in tabel CIAA_beleggen        */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 26-09-2016 |   2.28 | Kleine aanpassing Baten_benchmark in de      */
/*              |            |        | tabel Mi_temp.Mia_baten_benchmarken_003      */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 26-09-2016 |   2.29 | Workaround opbouw Siebel_Employee ivm        */
/*              |            |        | foutieve aanlevering BO nummers              */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 27-09-2016 |   2.30 | Aanpassingen Siebel_verkoopkans_product:     */
/*              |            |        |  - Revenue_ID en Product_unique_ID           */
/*              |            |        |  - Nieuwe kolom Baten_totaal_1ste_12mnd      */
/*              |            |        |  - Nieuwe kolom Baten_totaal_looptijd        */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 29-09-2016 |   2.31 | Grotere aanpassingen CUBe:                   */
/*              |            |        |  - Overgang op subsectoren (ipv AGIC)        */
/*              |            |        |  - Aanpassing omzetcategorieen               */
/*              |            |        |  - Productspecialist leads Rentederivaten    */
/*              |            |        |    en Commodity derivatenverwijderd          */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 03-10-2016 |   2.32 | Tijdelijke workaround Mia_businesscontacts:  */
/*              |            |        |  - qualify rank op kvkreg records            */
/*              |            |        |  - qualify rank op JOIN met                  */
/*              |            |        |  vEXTERNE_ORGANISATIE_BIK ivm primary key    */
/*              |            |        |  violation                                   */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 05-10-2016 |   2.33 | Change JD47 - nieuwe klantindicator IC:      */
/*              |            |        | Klantindicator op 1 voor IC klanten met:     */
/*              |            |        |  - met een crossref voor non CB contracten   */
/*              |            |        |  in LDM                                      */
/*              |            |        |  - CMS transacties in laatste 12 maanden     */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 06-10-2016 |   2.34 | Correctie afleiding Naam Siebel_Employee:    */
/*              |            |        | indien niet uniek langste naam selecteren    */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 11-10-2016 |   2.35 | Change SS54:                                 */
/*              |            |        | kolom TB_consultant toegevoegd (indicator)   */
/*              |            |        | Change BdB56:                                */
/*              |            |        | Nieuwe bron Subsector Mia_week/Hist:         */
/*              |            |        | mi_vm_ldm.vSBI_Plus_Industry_Rollup          */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 13-10-2016 |   2.36 | Change SS53, In- en uitstroomscript ,        */
/*              |            |        | toegevoegd - tabellen:                       */
/*              |            |        | - MI_SAS_AA_MB_C_MB.MI_migr_basis_hist       */
/*              |            |        | - MI_SAS_AA_MB_C_MB.MI_migratie_analyse_hist */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 01-11-2016 |   2.37 | CUBe_Siebel_fin_prof_geleverd toegevoegd     */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 01-11-2016 |   2.38 | CUBe_Siebel_fin_prof_geleverd: alleen 'C'    */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 08-11-2016 |   2.39 | Tijdelijke aanpassing selectie xrefs IC in   */
/*              |            |        | afwachting van correctie crossref tabel NZDB */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 10-11-2016 |   2.40 | 1. Bron omzetgegevens IC en voorm.           */
/*              |            |        | Corp. Clients aangepast van Cidar naar       */
/*              |            |        | Mi_vm_nzdb.vCC_gecor_geschatte_afgel_omz.    */
/*              |            |        | 2. Afleiding CMS_ind voor FXO transacties    */
/*              |            |        | aangepast nav feedback business              */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 22-11-2016 |   2.41 | Bron maand_nrs mi_temp.MI_migr_periode       */
/*              |            |        | aangepast naar                               */
/*              |            |        | MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr_NEW       */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 24-11-2016 |   2.42 | 1. Correctie CUBE_Baten en CUBE_leadstatus   */
/*              |            |        | 2. Mia_alle_bcs: filter op contracten        */
/*              |            |        |    product_id 1259                           */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 28-11-2016 |   2.43 | GSRI velden toegevoegd aan Mia_alle_bcs,     */
/*              |            |        | Mia_klant_info en Mia_week/hist:             */
/*              |            |        | - GSRI_goedgekeurd                           */
/*              |            |        | - GSRI_Assessment_resultaat                  */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 04-12-2016 |   2.44 | Mia_bc_info aangepast nav nieuwe definitie   */
/*              |            |        | mi_vm_NZDB.vGBC_CROSSREF                     */
/*--------------+------------+--------+----------------------------------------------*/
/* SS           | 06-12-2016 |   2.45 | 1. In- en uitstroomscript aangepast          */
/*              |            |        | 2. statistics cidar_hbc_hist verwijderd      */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 12-12-2016 |   2.46 | 1. Correctie fout bij COLLECT STATS (_NEW)   */
/*              |            |        |    bij MI_SAS_AA_MB_C_MB.MI_migr_basis_hist  */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 14-12-2016 |   2.47 | Correctie in- en uitstroom script            */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 03-01-2017 |   2.48 | Correctie KEM query                          */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 12-01-2017 |   2.49 | Nieuwe versie in- en uitstroom subscript     */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 17-01-2017 |   2.50 | Nieuwe organisatie niveaus toegevoegd aan    */
/*              |            |        | Mia_week/hist                                */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 17-01-2017 |   2.51 | Opbouw Mia_week aangepast aan nieuwe         */
/*              |            |        | Mia_organisatie (integratie stuurtabellen    */
/*              |            |        | CC en IC)                                    */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 25-01-2017 |   2.52 | 1.Toegevoegd aan Mia_week/hist:              */
/*              |            |        | - nieuwe organisatie_niveaus 1 t/m 5         */
/*              |            |        | - sectorcluster                              */
/*              |            |        | - Geo_postcode en geo_niveaus 1 t/m 3        */
/*              |            |        | 2.Nieuwe organisatie_niveaus 1 t/m 5         */
/*              |            |        | toegevoegd aan CIAA_beleggen                 */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 08-02-2017 |   2.53 | Correctie organisatieniveaus Mia_week/hist   */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 09-02-2017 |   2.54 | Aanpassing (verwijderen) complexe producten  */
/*              |            |        | - Totaal OOE 250k plus                       */
/*              |            |        | - Arrangement kredieten                      */
/*              |            |        | - Treasury                                   */
/*              |            |        | - Rentederivaten                             */
/*              |            |        | - Valuraderivaten                            */
/*              |            |        | - Commodity derivatives                      */
/*              |            |        | - Private WSealth Management                 */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 27-02-2017 |   2.55 | Aanpassingen:                                */
/*              |            |        | - Org_niveauX en Org_niveauX_bo_nr met       */
/*              |            |        |   terugwerkende kracht gevuld (Mia_hist)     */
/*              |            |        | - Toegevoegd afleiding Sectorcluster         */
/*              |            |        |   aan de hand van workaround (Mia_week/hist) */
/*              |            |        | - Sectorcluster met terugwerkende kracht     */
/*              |            |        |   gevuld (Mia_hist)                          */
/*              |            |        | - Bc_bo_bu_code, Bc_bo_bu_decode,            */
/*              |            |        |   Bc_cca_am_bu_code, Bc_cca_am_bu_decode,    */
/*              |            |        |   Bc_cca_rm_bu_code, Bc_cca_rm_bu_decode,    */
/*              |            |        |   Bc_ringfence en Bc_klantlevenscyclus       */
/*              |            |        |   toegevoegd (Mia_businesscontacts)          */
/*              |            |        | - Bc_bo_bu_code, Bc_bo_bu_decode,            */
/*              |            |        |   Bc_cca_bu_code en Bc_cca_bu_decode         */
/*              |            |        |   toegevoegd (Mia_bc_info)                   */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 08-03-2017 |   2.56 | - DROP TABLE verwijderen                     */
/*              |            |        | - Wijziging Pakketafleiding                  */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 23-03-2017 |   2.57 | Aanpassingen:                                */
/*              |            |        | - Afleiding Klantstatus voor businessline CC */
/*              |            |        |   gewijzigd (Mia_hist)                       */
/*              |            |        | - Klantstatus met terugwerkende kracht       */
/*              |            |        |   aangepast (Mia_hist)                       */
/*              |            |        | - QUALIFY RANK aangepast in Mia_bc_info:     */
/*              |            |        |   hierdoor geen mismatch met Mia_klant_info  */
/*              |            |        |   en geen Klantstatus NULL meer in Mia_hist  */
/*              |            |        | - Klantstatus NULL met terugwerkende kracht  */
/*              |            |        |   aangepast (Mia_hist)                       */
/*              |            |        | - In afleiding Mia_klant_info JOINen met     */
/*              |            |        |   Mia_bc_info ipv LEFT OUTER JOIN            */
/*              |            |        | - In- en uitstroom aangepast                 */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 24-03-2017 |   2.58 | Laatste aanpassingen In- en uitstroom        */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 06-04-2017 |   2.59 | Team IC opgegehaald vanuit NZDB (MIND-1707)  */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 11-04-2017 |   2.60 | Org_niveau 3 tm 1 aangepast ivm MIND-1707    */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 17-05-2017 |   2.61 | Afleiding klant_ind IC aangepast:            */
/*              |            |        | - tijdelijke crossref tabel mi_temp.xref     */
/*              |            |        | - afleiding xref_ind Mia_bc_info aangepast   */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 08-06-2017 |   2.62 | Siebel Financial Profile:                    */
/*              |            |        | Clientgroep_theoretisch op NULL              */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 15-06-2017 |   2.63 | Mia_sector: bron tijdelijk omgezet van       */
/*              |            |        | mi_vm_ldm.vSBI_plus_industry_RollUp naar     */
/*              |            |        | mi_cmb.SBI_plus_industry_rollup              */
/*              |            |        | mi_temp.xref: afleiding maand_nr aangepast   */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 03-07-2017 |   2.64 | Correctie Siebel Verkoopkans_product:        */
/*              |            |        | afleiding Eind_baten aangepast ivm ongeldige */
/*              |            |        | einddatum door invullen te grote tenure      */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 04-07-2017 |   2.65 | Oude BO structuur verwijderd uit:            */
/*              |            |        | - Mia_week                                   */
/*              |            |        | - CIAA_beleggen                              */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 05-07-2017 |   2.66 | Opbouw Mia_alle_bcs aangepast:               */
/*              |            |        | - koppeling voor ophalen leidend_bc en       */
/*              |            |        | commerciele entiteit met mi_vm_ldm.aparty    */
/*              |            |        | - koppeling voor ophalen commerciele groep   */
/*              |            |        | aangepast naar mi_vm_ldm.party_party_relatie */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 11-07-2017 |   2.67 | 1. Mia_sector: teruggezet naar               */
/*              |            |        |    mi_vm_ldm.vSBI_plus_industry_RollUp       */
/*              |            |        | 2. Overgebleven verwijzingen naar oude       */
/*              |            |        |    org_niveaus verwijderd                    */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 19-07-2017 |   2.68 | Joins met vBO_teams, vBO_Houses en           */
/*              |            |        | vBO_regio verwijderd                         */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 25-07-2017 |   2.69 | Bron subsegment IC aangepast naar            */
/*              |            |        | mi_vm_ldm.aCommercieel_complex_cb            */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 31-07-2017 |   2.70 | Tijdelijke workaround voor ophalen crossrefs */
/*              |            |        | verwijderd. Bron omgezet naar vgbc_crossref  */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 23-08-2017 |   2.71 | Verwijzingen naar clientgroepen, segmentatie */
/*              |            |        | en business_lines aangepast naar nieuwe AO   */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 06-09-2017 |   2.72 | Aanpassingen                                 */
/*              |            |        | - Afleiding Benchmark_ind, Uitscoor_ind en   */
/*              |            |        |   Bedrijfstak_id gewijzigd (Mia_klanten)     */
/*              |            |        | - COLLECT STATISTICS toegevoegd aan          */
/*              |            |        |   Mia_klanten ivm CUBe                       */
/*              |            |        |   (Mia_baten_benchmarken_001)                */
/*              |            |        | - INSERT-statements Mi_temp.Part_zak_t1_BC   */
/*              |            |        |   gewijzigd:                                 */
/*              |            |        |   - klantcomplexen CIB (vml IC) inmiddels    */
/*              |            |        |     correct in NZDB (vanwege intro Siebel)   */
/*              |            |        |   - verwijzing naar Business_line =          */
/*              |            |        |     'Bedrijven'                              */
/*              |            |        | - In- en uitstroom script gewijzigd:         */
/*              |            |        |   - Mia_klanten_klantnr_anders (Stap 2E)     */
/*              |            |        |     Business_line's Retail en PB samenge-    */
/*              |            |        |     voegd tot R&PB                           */
/*              |            |        |   - Mi_temp.Mia_klanten_andere_BL (Stap 2F)  */
/*              |            |        |     Business_line's Retail en PB samenge-    */
/*              |            |        |     voegd tot R&PB                           */
/*              |            |        |   - Mi_temp.Mia_migratie_totaal (Stap 3)     */
/*              |            |        |     ten behoeve van september 2017 rekening  */
/*              |            |        |     houden met veranderde organisatie        */
/*              |            |        |     (herkenbaar aan de comment eenmalig)     */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 14-09-2017 |   2.73 | correctie afleiding org_niveau3 CIB Mia_week */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 18-09-2017 |   2.74 | COLLECT STATS op Mia_hist_test verwijderd    */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 20-09-2017 |   2.75 | CUBe_Siebel_fin_prof_geleverd :              */
/*              |            |        |  - filter obv nieuwe benamingen BL en Segment*/
/*              |            |        |  - NPS anoniem uitsluiten                    */
/*              |            |        |  - NPS 2016 en recenter meeleveren           */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 20-09-2017 |   2.76 | Wegloopmodel nieuwe benamingen BL en Segment */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 20-09-2017 |   2.77 | CUBe_Siebel_fin_prof: NPS '0' toevoegen      */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 10-10-2017 |   2.78 | Opbouw Mi_temp.Mia_alle_bcs naar voren       */
/*              |            |        | gehaald, ter voorbereiding op nieuwe         */
/*              |            |        | CST_Member tabel Siebel.                     */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 12-10-2017 |   2.79 | Opbouw Siebel_commercieel_complex (OBIE)     */
/*              |            |        | verwijderd.                                  */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 17-10-2017 |   2.80 | Diverse wijzigingen nav metadatadag          */
/*              |            |        | 1.Mia_week/hist verwijderd:                  */
/*              |            |        |  - Dashboard_doelgroep                       */
/*              |            |        |  - Dashboard_subdoelgroep                    */
/*              |            |        |  - Klantsegment                              */
/*              |            |        |  - Bedrijfstak_id                            */
/*              |            |        | 2.Cube_baten_hist gewijzigd:                 */
/*              |            |        | CBI_baten gewijzigd naar Buitenland_CBI_baten*/
/*              |            |        | 3.Cube_leadstatus_hist: diverse kolommen     */
/*              |            |        |   verwijderd                                 */
/*              |            |        | 4.Opbouw CIAA_Betalen_trx verwijderd         */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 18-10-2017 |   2.81 | CIAA_beleggen: subsector_oms ipv             */
/*              |            |        | bedrijfstak_oms.                             */
/*              |            |        | Siebel_fin_prof_geleverd: subsector_oms uit  */
/*              |            |        | Mia_hist en Beoordeeld op "N"                */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 20-10-2017 |   2.82 | - bijzonder beheer obv CIF informatie        */
/*              |            |        | - aanpassingen nav nieuwe Siebel Cube tabel  */
/*              |            |        |   Mi_vm_ldm.vOutboundCUBeLead_cb             */
/*              |            |        | - extra statistics Mia_week                  */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 23-10-2017 |   2.83 | Opbouw Siebel_commercieel_complex verwijderd */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 24-10-2017 |   2.84 | Mia_baten_benchmarken_001 JOINS op segment   */
/*              |            |        | en subsegment verwijderd tbv performance     */
/*--------------+------------+--------+----------------------------------------------*/

/* BdB          | 06-11-2017 |   2.85 | Workaround Mia_sector: bron tijdelijk        */
/*              |            |        | gewijzigd naar                               */

/*              |            |        | mi_cmb.SBI_plus_industry_RollUp ivm fout in  */

/*              |            |        | bron                                         */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 09-11-2017 |   2.86 | Wijziging bijzonder beheer indicatie         */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 15-11-2017 |   2.87 | Tijdelijke workaround Mia_organisatie        */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 22-11-2017 |   2.88 | - Aanpassing tijdelijke workaround           */
/*              |            |        |   Mia_organisatie                            */
/*              |            |        | - Aanpassing SQL MI_TEMP.Siebel_Employee_NEW */
/*              |            |        |   ivm duplicate unique primary key error     */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 29-11-2017 |   2.89 | Mia_periode en Mia_sector voortaan opgebouwd */
/*              |            |        | als permanente tabellen in MI_SAS_AA_MB_C_MB */
/*              |            |        | Mia_sector inclusief tijdelijkse workaround  */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 30-11-2017 |   2.90 | Siebel testtabellen MIND inteface toegevoegd */
/*              |            |        | ter voorbereiding op afronding migratie      */
/*--------------+------------+--------+----------------------------------------------*/
/* BdB          | 04-12-2017 |   2.91 | Verwijzigingen mi_temp.mia_periode en        */
/*              |            |        | mi_temp.mia_sector naar  MI_SAS_AA_MB_C_MB.  */
/*              |            |        | Mia_periode_NEW en .Mia_sector_NEW           */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 11-12-2017 |   2.92 | Correcties op voorgaande wijziging           */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 11-12-2017 |   2.93 | Toevoegen nieuwe Kleinbedrijf CCA's          */
/*              |            |        | (53570801, 53572601 en 53572701)             */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 19-01-2018 |   2.94 | Aanpassingen als gevolg van introductie van  */
/*              |            |        | de segmenten SME® en SME (als vervanging van */
/*              |            |        | KZ en KB)                                    */
/*              |            |        | Aanpassingen Siebel: overgang op structurele */
/*              |            |        | MIND aanlevering (vervolg op wijziging 2.90) */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 25-01-2018 |   2.95 | Herstel contactinformatie in Mia_week en     */
/*              |            |        | flinke punten op de i bij aanpassingen       */
/*              |            |        | Siebel (nav wijziging 2.94)                  */
/*              |            |        | Verwijzing naar 'CBCTCX' verwijderd          */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 29-01-2018 |   2.96 | Laatste aanpassing als gevolg van aanpas-    */
/*              |            |        | singen Siebel (nav wijziging 2.94)           */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 05-03-2018 |   2.97 | Aanpassingen bijzonder beheer indicatie      */
/*              |            |        | (nav wijziging 2.86)                         */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 20-03-2018 |   2.98 | Vermijden dat KEM gegevens ontbreken agv     */
/*              |            |        | lege view mi_vm_load.vTWK_3_FACILITEITEN     */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 09-04-2018 |   2.99 | Toevoegen gedeelte AHK script tbv rapportage */
/*--------------+------------+--------+----------------------------------------------*/
/* SF           | 25-04-2018 |   2.100| Mia_kredieten_hfd vervangen door CIF         */
/*              |            |        | gevolgen voor complexe producten:            */
/*              |            |        |   Maatwerk Krediet--> obv NPL indicatie      */
/*              |            |        |   OBSI limiet --> NIET MEER TE BEPALEN       */
/*--------------+------------+--------+----------------------------------------------*/
/* PH           | 24-05-2-18 |   2.101|Mi_vm_load.vCcd_waarde, en de bijbehorende    */
/*		|            |        |outer join uit mia_week gehaald               */
/*--------------+------------+--------+----------------------------------------------*/
/* PH           | 24-05-2-18 |   2.102|CLAN-51: Geo_variabelen test tabel toegevoegd */
/*--------------+------------+--------+----------------------------------------------*/
/* PH           | 16-07-2-18 |   2.103|Mi_vm_ldm.vBo_mi_part_zak: bo_nr gewijzigd    */
/*		|            |	      |naar party_id, plus aliassen toegevoegd.	     */
/*		|            |	      |bo_nr_regio_mkb, bo_naam_regio_mkb &          */
/*		|            |	      |bo_naam_regio_part verwijderd en vervangen    */
/*		|            |        |door null				     */
/*--------------+------------+--------+----------------------------------------------*/
/* PH           | 25-07-18   |   2.104|TB_consultant toegevoegd aan mia_alle_bcs en  */
/*		|	     |	      |mia_business_contacts. Geo_variabelen 	     */
/*		|	     |        |toegevoegd aan mia_week.	                     */
/*--------------+------------+--------+----------------------------------------------*/
/* BBO          | 02-10-18   |   2.105|organisatie_niveau0 toegevoegd                */
/*              |            |        |  + Mia_businesscontacts_NEW toegevoegd       */
/*--------------+------------+--------+----------------------------------------------*/
/* VVT          | 15-10-18   |   2.106| Tijdelijke workaround Mia_sector uitgefa-    */
/*              |            |        | seerd en weer gebaseerd op Mi_vm_ldm         */
/*--------------+------------+--------+----------------------------------------------*/
/* VVT          | 17-10-18   |   2.107| Format BC_CCA_TB gewijzigd in INTEGER        */
/*--------------+------------+--------+----------------------------------------------*/
/* BBO          | 17-10-18   |   2.108| Trust- en franchisecomplex toegevoegd        */
/*--------------+------------+--------+----------------------------------------------*/
/* BBO          | 25-10-18   |   2.109| Medewerker_Security                          */
/*--------------+------------+--------+----------------------------------------------*/
/* BBO          | 26-10-18   |   2.110| AGRC toegevoegd                              */
/*--------------+------------+--------+----------------------------------------------*/
/* BBO          | 31-10-18   |   2.111| AGRC bug gefixed                             */
/*--------------+------------+--------+----------------------------------------------*/
/* PH           | 05-11-18   |   2.112| AGRC_MCT bug gefixed                         */
/*--------------+------------+--------+----------------------------------------------*/
/* BBO          | 12-11-18   |   2.113| AGRC_MCT bug gefixed                         */
/*--------------+------------+--------+----------------------------------------------*/
/* PH		| 23-11-18   |   2.114| Medewerkers tabel toegevoegd		     */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 04-12-2018 |  2.114 | Aanpassing aan Mi_temp.Mia_bc_info vanwege   */
/*              |            |        | duplicates: fix in MI_VM_LDM.aparty_gsri     */
/*--------------+------------+--------+----------------------------------------------*/
/* PH		| 05-12-2018 |  2.115 | Blockcompression verwijderd	             */
/*--------------+------------+--------+----------------------------------------------*/
/* BBO		| 10-12-2018 |  2.116 | Blockcompression toegevoegd                  */
/*--------------+------------+--------+----------------------------------------------*/
/* BBO		| 10-01-2019 |  2.117 | Aanpassing PB in Mi_temp.Mia_alle_bcs        */
/*              |            |        |  + Mia_businesscontacts                      */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 15-01-2019 |  2.118 | Toevoeging Datum_gegevens aan                */
/*              |            |        | Mia_businesscontacts                         */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 23-01-2019 |  2.119 | Bug gefixed Mia_businesscontacts             */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 24-01-2019 |  2.120 | Toevoegen Mia_week_PB en aanpassingen aan    */
/*              |            |        | Mia_week                                     */
/*--------------+------------+--------+----------------------------------------------*/
/* PH           | 14-02-2019 |  2.121 | Dagsaldi Toegevoegd                          */
/*              |            |        | 		                             */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 20-02-2019 |  2.122 | Bugfixes Dagsaldi en Gespreksrapport_id be-  */
/*              |            |        | schikbaar gemaakt in Siebel_Activiteit       */
/*--------------+------------+--------+----------------------------------------------*/
/* BBO          | 25-02-2019 |  2.123 | Ctrack toegevoegd                            */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 25-02-2019 |  2.124 | Bugfixes op de bugfix Dagsaldi               */
/*--------------+------------+--------+----------------------------------------------*/
/* BBO          | 28-02-2019 |  2.125 | Vervang LDM Bedrijfsonderdeel door Party_BO  */
/*--------------+------------+--------+----------------------------------------------*/
/* SS/VvT       | 28-02-2019 |  2.126 | Dagsaldi Gb uitgebreid met PSC en REC        */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 07-03-2019 |  2.127 | Bugfix op Ctrack: COLLECT STATISTICS AS      */
/*              |            |        | ST_280212161439_0_CTrack_OpenActions         */
/*              |            |        | werkt niet op een reeds bestaande tabel      */
/*--------------+------------+--------+----------------------------------------------*/
/* BBO          | 20-03-2019 |  2.128 | Bugfix Ctrack                                */
/*--------------+------------+--------+----------------------------------------------*/
/* PDH          | 01-04-2019 |  2.129 | mi_temp.medewerker_email                     */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 08-04-2019 |  2.130 | Bugfix op Ctrack: voorkomen duplicate error  */
/*              |            |        | MI_SAS_AA_MB_C_MB.CTrack_Portfolio_Hist_NEW  */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 10-04-2019 |  2.131 | Scripts CIB klantbeeld toegevoegd en         */
/*              |            |        | COMMENT-statements aangepast                 */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 15-04-2019 |  2.132 | Bugfix op CIB klantbeeld: statistics op      */
/*              |            |        | MI_TB tabellen voorlopig naar script 1a      */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 16-04-2019 |  2.133 | Nieuwe tabel Siebel_Activiteit_TB_revisies   */
/*              |            |        | en wijziging afleiding in Mia_week(_pb)      */
/*--------------+------------+--------+----------------------------------------------*/
/* PDH          | 01-04-2019 |  2.134 | Revisie 2.129 aangepast naar mi_sas + _NEW   */
/*--------------+------------+--------+----------------------------------------------*/
/* BBO          | 02-05-2019 |  2.135 | Aanpassing cib_klantbeeld_klanten_NEW        */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 09-05-2019 |  2.136 | Dagsaldi tabellen verwijderd                 */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 12-05-2019 |  2.137 | Org_niveau's in Mia_week_PB aangevuld        */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 05-06-2019 |  2.138 | Wijziging in CIB klantbeeld:                 */
/*              |            |        | - mi_sas_aa_mb_c_mb.cib_klantbeeld_lnd       */
/*              |            |        | - MI_SAS_AA_MB_C_MB.cib_klantbeeld_gmo       */
/*              |            |        | - mi_sas_aa_mb_c_mb.cib_klantbeeld_dpc       */
/*              |            |        | - mi_sas_aa_mb_c_mb.cib_klantbeeld_dpo       */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 13-06-2019 |  2.139 | - Workaround tbv segmentomschrijvingen       */
/*              |            |        |   MI_TEMP.aSegment                           */
/*              |            |        | - Kolom Producten2 toegevoegd                */
/*              |            |        |   Siebel_Verkoopkans_Product                 */
/*              |            |        | - Zakelijk-Particuliere koppelingen          */
/*              |            |        |   verwijderd (CIAA_Part_zak)                 */
/*              |            |        | - Internationaal indicatie verwijderd        */
/*              |            |        |   (Mi_temp.Internationale)                   */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 05-07-2019 |  2.140 | - Workaround tbv segmentomschrijvingen       */
/*              |            |        |   MI_TEMP.aSegment aangepast                 */
/*--------------+------------+--------+----------------------------------------------*/
/* PDH          | 12-07-2019 |  2.141 | Siebel kolommen toegevoegd aan               */
/*              |            |        | MI_SAS_AA_MB_C_MB.Siebel_Activiteit          */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 24-07-2019 |  2.142 | 5 nieuwe cib_klantbeeld tabellen en          */
/*              |            |        | Productboom_rationalisatie tabel toegevoegd  */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 25-07-2019 |  2.143 | Tabellen Bedrijfstype en Gekoppelde_personen */
/*              |            |        | toegevoegd                                   */
/*--------------+------------+--------+----------------------------------------------*/
/* VvT          | 25-07-2019 |  2.144 | - Workaround tbv segmentomschrijvingen       */
/*              |            |        |   MI_TEMP.aSegment aangepast                 */
/*--------------+------------+--------+----------------------------------------------*/
/*************************************************************************************/


/*
   1. Opbouw Mia_week
   2. Wegloopmodel
   3. CUBe Baten en stoplichten
   4. Advanced Analytics
   5. Zakelijk-Particuliere koppelingen --VERWIJDERD--
   6. Beleggen
   7. Kredieten         --VERWIJDERD--
   8. KTV YBC Bedrijven --VERWIJDERD--
   9. KEM pijplijn
  10. Opbouw Siebel CRM
  11. In- en uitstroom
  12. Siebel Financial Profile
  13. Siebel test tabellen MIND interface
*/



/* CommentString toevoegen aan Mi_cmb tabellen welke worden gebruikt in het CIAA schedule */
COMMENT ON Mi_cmb.Producten                     AS 'NIET VERWIJDEREN - Zelf ontsloten brontabel in schedulescript';
COMMENT ON Mi_cmb.Baten_2010_product            AS 'NIET VERWIJDEREN - Zelf ontsloten brontabel in schedulescript';
COMMENT ON Mi_cmb.Baten_2011_product            AS 'NIET VERWIJDEREN - Zelf ontsloten brontabel in schedulescript';
COMMENT ON Mi_cmb.Baten_2012_product            AS 'NIET VERWIJDEREN - Zelf ontsloten brontabel in schedulescript';
COMMENT ON Mi_cmb.Baten_2013_product            AS 'NIET VERWIJDEREN - Zelf ontsloten brontabel in schedulescript';
COMMENT ON Mi_cmb.Baten_2014_product            AS 'NIET VERWIJDEREN - Zelf ontsloten brontabel in schedulescript';
COMMENT ON Mi_cmb.Baten_2015_product            AS 'NIET VERWIJDEREN - Zelf ontsloten brontabel in schedulescript';
COMMENT ON Mi_cmb.Baten_2016_product            AS 'NIET VERWIJDEREN - Zelf ontsloten brontabel in schedulescript';
COMMENT ON Mi_cmb.Baten_2017_product            AS 'NIET VERWIJDEREN - Zelf ontsloten brontabel in schedulescript';
COMMENT ON Mi_cmb.Baten_2018_product            AS 'NIET VERWIJDEREN - Zelf ontsloten brontabel in schedulescript';
COMMENT ON Mi_cmb.Baten_2019_product            AS 'NIET VERWIJDEREN - Zelf ontsloten brontabel in schedulescript';
COMMENT ON Mi_cmb.Baten_2010                    AS 'NIET VERWIJDEREN - Zelf ontsloten brontabel in schedulescript';
COMMENT ON Mi_cmb.Baten_2011                    AS 'NIET VERWIJDEREN - Zelf ontsloten brontabel in schedulescript';
COMMENT ON Mi_cmb.Baten_2012                    AS 'NIET VERWIJDEREN - Zelf ontsloten brontabel in schedulescript';
COMMENT ON Mi_cmb.Baten_2013                    AS 'NIET VERWIJDEREN - Zelf ontsloten brontabel in schedulescript';
COMMENT ON Mi_cmb.Baten_2014                    AS 'NIET VERWIJDEREN - Zelf ontsloten brontabel in schedulescript';
COMMENT ON Mi_cmb.Baten_2015                    AS 'NIET VERWIJDEREN - Zelf ontsloten brontabel in schedulescript';
COMMENT ON Mi_cmb.Baten_2016                    AS 'NIET VERWIJDEREN - Zelf ontsloten brontabel in schedulescript';
COMMENT ON Mi_cmb.Baten_2017                    AS 'NIET VERWIJDEREN - Zelf ontsloten brontabel in schedulescript';
COMMENT ON Mi_cmb.Baten_2018                    AS 'NIET VERWIJDEREN - Zelf ontsloten brontabel in schedulescript';
COMMENT ON Mi_cmb.Baten_2019                    AS 'NIET VERWIJDEREN - Zelf ontsloten brontabel in schedulescript';
COMMENT ON Mi_cmb.Baten_product                 AS 'NIET VERWIJDEREN - Zelf ontsloten brontabel in schedulescript';
COMMENT ON Mi_cmb.baten_product_12mnd           AS 'NIET VERWIJDEREN - Zelf ontsloten brontabel in schedulescript';
COMMENT ON Mi_cmb.LU_Complexe_producten         AS 'NIET VERWIJDEREN - Stuurtabel in schedulescript';
COMMENT ON Mi_cmb.Tb_offers                     AS 'NIET VERWIJDEREN - wordt gebruikt in CIAA schedule';
COMMENT ON Mi_cmb.Sni                           AS 'NIET VERWIJDEREN - wordt gebruikt in CIAA schedule';
COMMENT ON Mi_cmb.Snu                           AS 'NIET VERWIJDEREN - wordt gebruikt in CIAA schedule';
COMMENT ON Mi_cmb.CUBe_collector_datum          AS 'NIET VERWIJDEREN - wordt gebruikt in CIAA schedule';
COMMENT ON Mi_cmb.mia_markets_lnd_verkoopkansen AS 'NIET VERWIJDEREN - wordt gebruikt in CIAA schedule';
COMMENT ON Mi_cmb.CUBe_leads_hist               AS 'NIET VERWIJDEREN - Afdelingstabel in schedulescript (CUBe)';
COMMENT ON Mi_cmb.CUBe_RM_oordeel               AS 'NIET VERWIJDEREN - wordt gebruikt in CIAA schedule';
COMMENT ON Mi_cmb.CUBe_leadstatus_hist          AS 'NIET VERWIJDEREN - Afdelingstabel in schedulescript (CUBe)';
COMMENT ON Mi_cmb.Model_tabel_cmb               AS 'NIET VERWIJDEREN - wordt gebruikt in CIAA schedule tbv Mi_sas_aa_c_mb.tModel_c_mb';

/*Blockcompressie aan*/
SET QUERY_BAND = 'BLOCKCOMPRESSION=YES;' FOR SESSION;


/*************************************************************************************

    Opbouw Tabel met draaidatum tbv. uiteindelijke uitscoren

*************************************************************************************/

/* aanmaken tabel met datum van vandaag. Deze datum wordt gebruikt voor datum to be used en de score datum zodat deze dezelfde zijn
    ,zelfs als verschillend process stappen niet op dezelfde dag draaien
*/

CREATE SET TABLE MI_TEMP.AACMB_Datum ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      Draai_Datum DATE FORMAT 'yyyy-mm-dd')
UNIQUE PRIMARY INDEX ( Draai_Datum );

.IF ERRORCODE <> 0 THEN .GOTO EOP


INSERT INTO MI_TEMP.AACMB_Datum
VALUES
    (
  CURRENT_DATE
    )
;

.IF ERRORCODE <> 0 THEN .GOTO EOP


COLLECT STATISTICS ON MI_TEMP.AACMB_Datum INDEX (Draai_Datum);

.IF ERRORCODE <> 0 THEN .GOTO EOP


/*************************************************************************************

   1. Opbouw Mia_week

*************************************************************************************/

/*-------------------------------------------------------------*/
/* STUURTABELLEN                                               */
/*                                                             */
/* Al bestaande tabellen:                                      */
/* Mi_analyse.CUBe_productdetail                               */
/* Mi_analyse.CUBe_producten                                   */
/* Mi_analyse.CUBe_bedrijfstakken                              */
/* Mi_analyse.CUBe_correctiefactor                             */
/*-------------------------------------------------------------*/


/*************************************************************************************

    BASIS SET tabel Mia_periode

*************************************************************************************/

CREATE TABLE MI_SAS_AA_MB_C_MB.Mia_periode_NEW
AS (
SELECT B.Maand_nr,
       D.Datum_gegevens,
       A.Maand AS Maand_nr_laatste_finance,
       E.Maand_L12 AS Maand_begin_jaar_ervoor,
       A.Maand_L12 AS Maand_begin_jaar,
       A.Maand AS Maand_einde_jaar,
       NULL /* Mi_analyse.CUBe_collector_datum.DateLastModified in script 05 */ AS Datum_leads,
       EXTRACT(YEAR FROM ADD_MONTHS(C.Maand_startdatum, -1))*100 + EXTRACT(MONTH FROM ADD_MONTHS(C.Maand_startdatum, -1)) AS Maand_nr_vm1,
       EXTRACT(YEAR FROM ADD_MONTHS(C.Maand_startdatum, -2))*100 + EXTRACT(MONTH FROM ADD_MONTHS(C.Maand_startdatum, -2)) AS Maand_nr_vm2,
       EXTRACT(YEAR FROM ADD_MONTHS(C.Maand_startdatum, -3))*100 + EXTRACT(MONTH FROM ADD_MONTHS(C.Maand_startdatum, -3)) AS Maand_nr_vm3,
       1 AS Lopende_maand_ind
  FROM Mi_vm_nzdb.vLu_maand A
  JOIN Mi_vm_nzdb.vLu_maand_runs B
    ON 1 = 1 AND B.Lopende_maand_ind = 1
  JOIN Mi_vm_nzdb.vLu_maand C
    ON B.Maand_nr = C.Maand
  JOIN (SELECT XA.Maand_nr,
               XA.CC_Samenvattings_datum-1 AS Datum_gegevens
          FROM Mi_vm_nzdb.vCommercieel_cluster XA
          JOIN Mi_vm_nzdb.vLU_Maand_Runs XX
            ON XA.Maand_nr = XX.Maand_nr AND XX.Lopende_maand_ind = 1
         GROUP BY 1, 2) AS D
    ON B.Maand_nr = D.Maand_nr
  JOIN Mi_vm_nzdb.vLu_maand E
    ON A.Maand_L12 = E.Maand
 WHERE A.Maand IN (SELECT MAX(X.Maand_nr) FROM Mi_cmb.Producten X)
 ) WITH DATA
UNIQUE PRIMARY INDEX ( Maand_nr )
INDEX ( Maand_begin_jaar_ervoor )
INDEX ( Maand_begin_jaar )
INDEX ( Maand_einde_jaar );

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Mia_periode_NEW COLUMN (PARTITION);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Mia_periode_NEW COLUMN (Maand_nr, Datum_gegevens);

.IF ERRORCODE <> 0 THEN .GOTO EOP


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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATS Mi_temp.BC_bijzonder_beheer_ind COLUMN (BC_nr);

.IF ERRORCODE <> 0 THEN .GOTO EOP

CREATE TABLE Mi_temp.Mia_bc_info
      (
       Klant_nr INTEGER,
       Business_contact_nr DECIMAL(12,0),
       Koppeling_id_CC CHAR(15),
       Koppeling_id_CE CHAR(15),
       Koppeling_id_CG CHAR(15),
       Deelnemer_rol BYTEINT,
       Clientgroep CHAR(4) CHARACTER SET LATIN NOT CASESPECIFIC,
       Crg BYTEINT,
       Bo_nr INTEGER,
       Bo_bu_code CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC,
       Bo_bu_decode_mi VARCHAR(60) CHARACTER SET LATIN NOT CASESPECIFIC,
       Validatieniveau BYTEINT,
       Cca INTEGER,
       Cca_bu_code CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC,
       Cca_bu_decode VARCHAR(60) CHARACTER SET LATIN NOT CASESPECIFIC,
       Relatiecategorie SMALLINT,
       Verschijningsvorm SMALLINT,
       DB_ind BYTEINT,
       Solveon_ind BYTEINT,
       FRenR_ind BYTEINT,
       Surseance_ind BYTEINT,
       Faillissement_ind BYTEINT,
       Leidend_bc_ind BYTEINT,
       In_nzdb BYTEINT,
       Xref_ind BYTEINT,
       CMS_ind BYTEINT,
       GSRI_goedgekeurd VARCHAR(8) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS ('High','Low','Medium'),
       GSRI_goedgekeurd_lvl BYTEINT,
       GSRI_Assessment_resultaat VARCHAR(9) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS ('ABOVE PAR','ON PAR','BELOW PAR'),
       GSRI_Assessment_resultaat_lvl BYTEINT
     )
UNIQUE PRIMARY INDEX ( Klant_nr, Business_contact_nr )
INDEX ( Klant_nr )
INDEX ( Business_contact_nr )
INDEX ( Bo_nr );

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

/* Bijzonder_beheer obv Fiatterende Instantie: BC met contract binnen kredietcomplex met FI Lindorff of FR&R */
  LEFT OUTER JOIN Mi_temp.BC_bijzonder_beheer_ind K
    ON K.Bc_nr = A.Party_id

  LEFT OUTER JOIN  mi_vm_ldm.aExterne_Organisatie L
    ON A.party_id = L.party_id
   AND A.party_sleutel_type = L.party_sleutel_type

/* Ophalen Koppeling_ID Commerciele Entiteit */
  LEFT OUTER JOIN (SELECT XA.Party_id,
                          XA.koppeling_id,
                          MAX(CASE WHEN XA.Party_deelnemer_rol = 1 THEN 1 ELSE NULL END) AS Party_deelnemer_rol
                   FROM Mi_vm_ldm.aParty_party_relatie XA
                   WHERE XA.Party_sleutel_type = 'BC'
                     AND XA.Party_relatie_type_code = 'CBCTCE'
                 QUALIFY RANK() OVER (PARTITION BY XA.Party_id ORDER BY XA.Koppeling_id) = 1
                   GROUP BY 1,2) AS M
    ON A.Party_id = M.Party_id

/* Ophalen Koppeling_ID Commerciele Groep */
  LEFT OUTER JOIN (SELECT XA.Party_id,
                          XA.koppeling_id,
                          MAX(CASE WHEN XA.Party_deelnemer_rol = 1 THEN 1 ELSE NULL END) AS Party_deelnemer_rol
                   FROM Mi_vm_ldm.aParty_party_relatie XA
                   WHERE XA.Party_sleutel_type = 'CC'
                     AND XA.Party_relatie_type_code = 'CCTCG'
                 QUALIFY RANK() OVER (PARTITION BY XA.Party_id ORDER BY XA.Koppeling_id) = 1
                   GROUP BY 1,2) AS N
    ON A.Gerelateerd_party_id = N.Party_id

-- Check op Cross-refs

  LEFT OUTER JOIN  (SELECT party_id, 1 AS xref_ind
               FROM mi_vm_NZDB.vGBC_CROSSREF
               WHERE maand_nr = (SEL maand_nr FROM MI_SAS_AA_MB_C_MB.Mia_periode_NEW)
               AND xref_herkomst IN ('BCTT24','BCTSAB','BCTLCA','BCTCF2','BCTCF3','BCTCF4','BCTCF5')
               AND party_sleutel_type = 'BC'
               GROUP BY 1,2) O
    ON A.Party_id = O.party_id

/* Check op CMS transacties */

   LEFT OUTER JOIN (SEL bc_nr, MAX(
                    CASE WHEN product_group_code = 'FXO' AND ZEROIFNULL(margin) <> 0 THEN 1
                    WHEN product_group_code <> 'FXO' AND product_group_code IS NOT NULL THEN 1
                    ELSE 0 END) AS CMS_ind
                FROM mi_cmb.smr_transaction
                WHERE maand_nr BETWEEN  (SEL maand_nr -100 FROM MI_SAS_AA_MB_C_MB.Mia_periode_NEW) AND (SEL maand_nr FROM MI_SAS_AA_MB_C_MB.Mia_periode_NEW)
                AND product_group_code IN ('MM Taken','FXO','FX','MM Given','IRD') -- voor deze producten is de  data gevalideerd, later aan te vullen met overige productgroepen uit de SMR transaction tabel

                GROUP BY 1) P
    ON A.Party_id = P.bc_nr

  /* GSRI informatie uit FAIR */

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.Mia_bc_info COLUMN ( IN_NZDB );
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Mia_periode_NEW COLUMN ( Lopende_maand_ind);

.IF ERRORCODE <> 0 THEN .GOTO EOP



CREATE TABLE Mi_temp.Mia_klant_info
      (
       Klant_nr INTEGER,
       Maand_nr INTEGER,
       Datum_gegevens DATE FORMAT 'YYYYMMDD',
       Clientgroep CHAR(4) CHARACTER SET LATIN NOT CASESPECIFIC,
       Business_line VARCHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
       Klantstatus CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
       Klant_ind BYTEINT,
       Aantal_bcs INTEGER,
       Aantal_bcs_in_scope INTEGER,
       Bijzonder_beheer_ind BYTEINT,
       Surseance_ind BYTEINT,
       Faillissement_ind BYTEINT,
       GSRI_goedgekeurd_lvl BYTEINT,
       GSRI_Assessment_resultaat_lvl BYTEINT,
       Leidend_bc_ind BYTEINT,
       Leidend_bc_nr DECIMAL(12,0),
       Cca INTEGER
      )
UNIQUE PRIMARY INDEX ( Klant_nr, Maand_nr )
INDEX ( Klant_nr )
INDEX ( Maand_nr );

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.Mia_bc_info COLUMN CLIENTGROEP;
COLLECT STATISTICS Mi_temp.Mia_bc_info COLUMN (IN_NZDB);
COLLECT STATISTICS Mi_temp.Mia_klant_info COLUMN (CLIENTGROEP);
COLLECT STATISTICS Mi_temp.Mia_klant_info COLUMN (BUSINESS_LINE);
COLLECT STATISTICS Mi_temp.Mia_klant_info COLUMN (KLANTSTATUS,KLANT_IND);
COLLECT STATISTICS Mi_temp.Mia_klant_info COLUMN (KLANT_NR, MAAND_NR);
COLLECT STATISTICS Mi_temp.Mia_klant_info COLUMN (KLANT_NR);
COLLECT STATISTICS Mi_temp.Mia_klant_info COLUMN CCA;

.IF ERRORCODE <> 0 THEN .GOTO EOP

CREATE TABLE Mi_temp.Mia_klantkoppelingen
      (
       Klant_nr INTEGER,
       Maand_nr INTEGER,
       Business_contact_nr DECIMAL(12,0),
       Koppeling_id_CC CHAR(15),
       Koppeling_id_CE CHAR(15),
       Volgorde INTEGER
      )
UNIQUE PRIMARY INDEX ( Klant_nr, Maand_nr, Business_contact_nr )
INDEX ( Klant_nr )
INDEX ( Maand_nr )
INDEX ( Business_contact_nr );

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.Mia_klantkoppelingen COLUMN (KLANT_NR, MAAND_NR);
COLLECT STATISTICS Mi_temp.Mia_klantkoppelingen COLUMN (KLANT_NR);
COLLECT STATISTICS Mi_temp.Mia_klantkoppelingen COLUMN VOLGORDE;
COLLECT STATISTICS Mi_cmb.Baten_2010_product COLUMN (Banktype, Party_sleutel_type, Party_id, Maand_nr);
COLLECT STATISTICS Mi_cmb.Baten_2011_product COLUMN (Banktype, Party_sleutel_type, Party_id, Maand_nr);
COLLECT STATISTICS Mi_cmb.Baten_2012_product COLUMN (Banktype, Party_sleutel_type, Party_id, Maand_nr);
COLLECT STATISTICS mi_cmb.baten_2013_product COLUMN (Banktype, Party_sleutel_type, Party_id, Maand_nr);
COLLECT STATISTICS mi_cmb.baten_2014_product COLUMN (Banktype, Party_sleutel_type, Party_id, Maand_nr);
COLLECT STATISTICS mi_cmb.baten_2015_product COLUMN (Banktype, Party_sleutel_type, Party_id, Maand_nr);
COLLECT STATISTICS mi_cmb.baten_2016_product COLUMN (Banktype, Party_sleutel_type, Party_id, Maand_nr);
COLLECT STATISTICS mi_cmb.baten_2017_product COLUMN (Banktype, Party_sleutel_type, Party_id, Maand_nr);
COLLECT STATISTICS mi_cmb.baten_product_2010_12mnd COLUMN (PARTY_SLEUTEL_TYPE,MAAND_NR);
COLLECT STATISTICS mi_cmb.baten_product_2011_12mnd COLUMN (PARTY_SLEUTEL_TYPE,MAAND_NR);
COLLECT STATISTICS mi_cmb.baten_product_2012_12mnd COLUMN (PARTY_SLEUTEL_TYPE,MAAND_NR);
COLLECT STATISTICS mi_cmb.baten_product_2013_12mnd COLUMN (PARTY_SLEUTEL_TYPE,MAAND_NR);
COLLECT STATISTICS mi_cmb.baten_product_2014_12mnd COLUMN (PARTY_SLEUTEL_TYPE,MAAND_NR);
COLLECT STATISTICS mi_cmb.baten_product_2015_12mnd COLUMN (PARTY_SLEUTEL_TYPE,MAAND_NR);
COLLECT STATISTICS mi_cmb.baten_product_2016_12mnd COLUMN (PARTY_SLEUTEL_TYPE,MAAND_NR);
COLLECT STATISTICS mi_cmb.baten_product_2017_12mnd COLUMN (PARTY_SLEUTEL_TYPE,MAAND_NR);

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS COLUMN (LEIDEND_BC_IND ,IN_NZDB ,KLANT_NR) ON Mi_temp.Mia_bc_info;
COLLECT STATISTICS COLUMN (LEIDEND_BC_IND ,IN_NZDB) ON Mi_temp.Mia_bc_info;
COLLECT STATISTICS COLUMN (KLANT_NR) ON Mi_temp.Mia_bc_info;
COLLECT STATISTICS COLUMN (LEIDEND_BC_IND) ON Mi_temp.Mia_bc_info;

.IF ERRORCODE <> 0 THEN .GOTO EOP

CREATE TABLE Mi_temp.Mia_groepkoppelingen
     (
      Groep_nr INTEGER,
      Maand_nr INTEGER,
      Klant_nr INTEGER,
      Leidende_klant_ind BYTEINT,
      Koppeling_id_CC CHAR(15) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS NULL,
      Koppeling_id_CG CHAR(15) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS NULL
     )
UNIQUE PRIMARY INDEX ( Groep_nr, Maand_nr, Klant_nr );

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

/*************************************************************************************

    BEGIN TIJDELIJKE WORKAROUND SEGMENT

*************************************************************************************/

CREATE TABLE MI_TEMP.aSegment
      (
       Segment_Id VARCHAR(256) CHARACTER SET LATIN NOT CASESPECIFIC NOT NULL,
       Segment_Type_Code CHAR(6) CHARACTER SET LATIN NOT CASESPECIFIC NOT NULL,
       Segment_Type_Volgnr SMALLINT NOT NULL,
       Segment_SDAT DATE FORMAT 'YYYY/MM/DD' NOT NULL,
       Segment_Oms VARCHAR(256) CHARACTER SET LATIN NOT CASESPECIFIC NOT NULL,
       Creatie_Datum DATE FORMAT 'YYYY/MM/DD' COMPRESS ,
       Segment_EDAT DATE FORMAT 'YYYY/MM/DD' COMPRESS
      )
UNIQUE PRIMARY INDEX ( Segment_Id, Segment_Type_Code );

.IF ERRORCODE <> 0 THEN .GOTO EOP

INSERT INTO MI_TEMP.aSegment
SELECT COALESCE(B.Segment_Id, A.Segment_Id),
       COALESCE(B.Segment_Type_Code, A.Segment_Type_Code),
       COALESCE(B.Segment_Type_Volgnr, A.Segment_Type_Volgnr),
       COALESCE(B.Segment_SDAT, A.Segment_SDAT),
       COALESCE(B.Segment_Oms, A.Segment_Oms),
       COALESCE(B.Creatie_Datum, A.Creatie_Datum),
       COALESCE(B.Segment_EDAT, A.Segment_EDAT)
  FROM MI_SAS_AA_MB_C_MB.aSegment A
  FULL OUTER JOIN (SELECT XA.*
                     FROM Mi_vm_ldm.aSegment XA
                    WHERE XA.Segment_id NE '   1'
                      AND XA.Segment_type_code NE 'CGA'
                  QUALIFY RANK () OVER (PARTITION BY XA.Segment_type_code ORDER BY COALESCE(XA.Segment_EDAT, (1991231 (DATE))) DESC) = 1) AS B
    ON A.Segment_type_code = B.Segment_type_code
   AND A.Segment_id = B.Segment_id
   AND A.Segment_id NE '   1'
   AND ((A.Segment_EDAT = B.Segment_EDAT) OR (A.Segment_EDAT IS NULL AND B.Segment_EDAT IS NULL));

.IF ERRORCODE <> 0 THEN .GOTO EOP

/*************************************************************************************

    EINDE TIJDELIJKE WORKAROUND SEGMENT

*************************************************************************************/

CREATE TABLE Mi_temp.Mia_alle_bcs
      (
       Business_contact_nr DECIMAL(12,0),
       Klant_nr INTEGER,
       Maand_nr INTEGER,
       Bc_naam VARCHAR(256) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS NULL COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       Bc_startdatum DATE FORMAT 'YYYYMMDD',
       Bc_clientgroep CHAR(4) CHARACTER SET LATIN NOT CASESPECIFIC,
       Bc_crg BYTEINT,
       Bc_bo_nr INTEGER,
       Bc_bo_naam VARCHAR(256) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS NULL COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       Bc_bo_bu_code CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC,
       Bc_bo_bu_decode VARCHAR(60) CHARACTER SET LATIN NOT CASESPECIFIC,
       Bc_validatieniveau BYTEINT,
       Bc_cca_am INTEGER,
       Bc_cca_rm INTEGER,
       Bc_cca_am_bu_code CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC,
       Bc_cca_am_bu_decode VARCHAR(60) CHARACTER SET LATIN NOT CASESPECIFIC,
       Bc_cca_rm_bu_code CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC,
       Bc_cca_rm_bu_decode VARCHAR(60) CHARACTER SET LATIN NOT CASESPECIFIC,
       Bc_cca_pb INTEGER,
       Bc_relatiecategorie SMALLINT,
       Bc_verschijningsvorm SMALLINT,
       Bc_kvk_nr CHAR(12),
       Bc_postcode CHAR(6),
       Bc_sbi_code_bcdb CHAR(6) CHARACTER SET LATIN NOT CASESPECIFIC,
       Bc_sbi_code_kvk CHAR(6) CHARACTER SET LATIN NOT CASESPECIFIC,
       Bc_contracten BYTEINT,
       Bc_klantlevenscyclus VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS ('ACTIVE', 'DECLINED (FOR FUTURE USE)', 'DORMANT (FOR FUTURE USE)', 'FORMER', 'POTENTIAL (FOR FUTURE USE)', 'PROSPECTIVE', 'REJECTED'),
       Leidend_bc_ind BYTEINT,
       Leidend_bc_pb_ind BYTEINT,
       Cc_nr INTEGER,
       Koppeling_id_CC CHAR(15),
       Koppeling_id_CE CHAR(15),
       Koppeling_id_CG CHAR(15),
       Fhh_nr INTEGER,
       Pcnl_nr INTEGER,
       Bc_Lindorff_ind BYTEINT,
       Bc_FRenR_ind BYTEINT,
       Bc_in_nzdb BYTEINT,
       DB_ind BYTEINT,
       RBS_ind BYTEINT,
       Bc_SEC_US_Person_ind BYTEINT COMPRESS (1,0,NULL),
       Bc_SEC_US_Person_oms VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS ('Geen SEC US Person','SEC US Person - Counterparties', 'SEC          US Person - U.S. Instituti','Geen SEC US Person - Accredite','Niet gereviewed op SEC US Pers',' Geen SEC US Person - Represent','SEC          US Person'),
       Bc_FATCA_US_Person_ind BYTEINT COMPRESS (1,0, NULL),
       Bc_FATCA_US_Person_class VARCHAR(46) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS ('Subject to Tax in US', 'P-NFFE', 'IGA_FFI', 'To be determined', 'NFFE', 'E-NFFE', 'Recalcitrant (applicable for Entities as well)', 'US', 'FFI', 'Not Subject to Tax in US'),
       Bc_ringfence VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS ('Alleen Maat / Vennoot (ihkv VVB review)', 'Alleen Swift Key relatie', 'Alleen T24 relatie',
                                                                               'Garantsteller/ov. betrokkene (ikv VVB)', 'Geen nieuwe diensten - zie E-archief', 'Integriteitsgevoelig.',
                                                                               'klant afgewezen, zie klantbeeld', 'klant in faillissement / in surseance', 'Klant Levenscyclus Status Former',
                                                                               'Klantacceptatie niet volledig doorlopen', 'Landenbeleid restrictie afzet producten',
                                                                               'landenbeleid verbod op afzet producten', 'Rechtspersoon zonder actieve producten'),
       Bc_Risico_score VARCHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS ('00'),
       BC_Risico_klasse_oms VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
       Bc_WtClas VARCHAR(16) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS ('Non Professional', 'Professional', 'ECP'),
       Bc_AAClas VARCHAR(16) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS ('Non Professional', 'Professional', 'ECP'),
       Bc_Rente_drv VARCHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC,
       Bc_Comm_drv VARCHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC,
       Bc_Valuta_drv VARCHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC,
       Bc_Overig_cms VARCHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
       BC_GSRI_goedgekeurd CHAR(8) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS ('High', 'Medium', 'Low'),
       BC_GSRI_Assessment_resultaat CHAR (10) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS ('ABOVE PAR', 'BELOW PAR'),
       BC_GBC_nr DECIMAL(12,0),
       BC_GBC_Naam VARCHAR(256) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS NULL COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       BC_ULP_nr DECIMAL(12,0),
       BC_ULP_Naam VARCHAR(256) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS NULL COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       BC_CCA_TB INTEGER,
       BC_CCA_TB_NAAM VARCHAR(256) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS NULL COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       BC_CCA_TB_TEAM VARCHAR(256) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS NULL COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       Trust_complex_nr DECIMAL(12,0),
       Franchise_complex_nr DECIMAL(12,0)
      )
UNIQUE PRIMARY INDEX ( Business_contact_nr, Klant_nr, Maand_nr )
INDEX ( Business_contact_nr )
INDEX ( Klant_nr )
INDEX ( Maand_nr )
INDEX ( Bc_bo_nr );

.IF ERRORCODE <> 0 THEN .GOTO EOP

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
-- US Persons
       CASE
       WHEN U.Segment_Id  IN ('02','03','06','07') THEN 0
       WHEN U.Segment_Id  IN ('01','04','05') THEN 1
       ELSE NULL
       END AS Bc_SEC_US_Person_ind,
       TRIM(V.Segment_Oms) AS Bc_SEC_US_Person_oms,
-- FATCA
       CASE
       WHEN AG.fatca_status_code_party_oms IS NULL THEN 0
       WHEN AG.fatca_status_code_party = '09' THEN 0
       ELSE 1
       END AS Bc_FATCA_US_Person_ind,
       TRIM(AG.fatca_status_code_party_oms) AS Bc_FATCA_US_Person_class,
-- Ringfence
       AK.Segment_oms AS Bc_ringfence,
-- Risico score
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
-- Fitness test Mifid
       AA.Segment_oms AS Bc_WtClas,
       AB.Segment_oms AS Bc_AAClas,
       CASE WHEN TRIM(AD.Segment_oms) = 'Geen' THEN 'No' ELSE  SUBSTR(AD.Segment_oms,11,1) END AS Bc_Rente_drv,
       CASE WHEN TRIM(AC.Segment_oms) = 'Geen' THEN 'No' ELSE  SUBSTR(AC.Segment_oms,11,1) END AS Bc_Comm_drv,
       CASE WHEN TRIM(AE.Segment_oms) = 'Geen' THEN 'No' ELSE  SUBSTR(AE.Segment_oms,11,1) END AS Bc_Valuta_drv,
       CASE
       WHEN AF.Segment_oms IS NULL THEN NULL
       WHEN SUBSTR(AF.Segment_oms,1,4) = 'Geen' THEN 'N' ELSE  'Y' END
       AS Bc_Overig_cms,
-- GSRI FAIR
       AH.BC_GSRI_Goedgekeurd AS BC_GSRI_Goedgekeurd, --tijdelijk op NULL ivm foutieve informatie LDM
       AH.BC_GSRI_Assessment_resultaat AS BC_GSRI_Assessment_resultaat, --tijdelijk op NULL ivm foutieve informatie LDM
       AI.GBC_nr AS BC_GBC_nr,
       AI.GBC_Naam AS BC_GBC_Naam,
       AI.ULP_BC_nr AS BC_ULP_nr,
       AI.ULP_Naam AS BC_ULP_Naam,
       AL.CCA as BC_CCA_TB,
       CASE
       WHEN AM.Naam IS NULL OR AM.Naam = '' THEN 'Geen naam'
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
                    GROUP BY 1, 2, 3
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
  LEFT OUTER JOIN (SELECT XA.Party_id, XA.Gerelateerd_party_id, XA.Party_sleutel_type, XA.Party_party_relatie_sdat
                     FROM Mi_vm_ldm.aParty_party_relatie XA
                    WHERE XA.Party_relatie_type_code = 'kvkreg'
                    GROUP BY 1, 2, 3, 4
                  QUALIFY RANK () OVER (PARTITION BY XA.Party_id ORDER BY XA.Party_party_relatie_sdat, XA.Gerelateerd_party_id DESC) = 1) AS K
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
  LEFT OUTER JOIN (SELECT XA.Party_id, XA.Party_sleutel_type, XA.Branche_code, XA.Ext_org_branche_sdat
                     FROM Mi_vm_ldm.vExterne_organisatie_bik XA
                    WHERE XA.Ext_org_branche_edat IS NULL
                      AND XA.Primary_branche_ind = 1
                  QUALIFY RANK() OVER (PARTITION BY XA.Party_id ORDER BY XA.Ext_org_branche_sdat, XA.Branche_code) = 1) AS Q
    ON X.Party_id = Q.Party_id
   AND X.Party_sleutel_type = Q.Party_sleutel_type
/* Bijzonder_beheer obv Fiatterende Instantie: BC met contract binnen kredietcomplex met FI Lindorff of FR&R */
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
    /* Bepalen Leidend_BC */
  LEFT OUTER JOIN (SELECT XA.Party_id,
                          XA.Koppeling_id,
                          MAX(CASE WHEN XA.Party_deelnemer_rol = 1 THEN 1 ELSE NULL END) AS Party_deelnemer_rol
                     FROM Mi_vm_ldm.aParty_party_relatie XA
                    WHERE XA.Party_sleutel_type = 'BC'
                      AND XA.Party_relatie_type_code = 'CBCTCC'
                  QUALIFY RANK() OVER (PARTITION BY XA.Party_id ORDER BY XA.Koppeling_id) = 1
                    GROUP BY 1, 2) AS T
    ON X.Party_id = T.Party_id
    /* Ophalen Koppeling_ID Commerciele Entiteit */
  LEFT OUTER JOIN (SELECT XA.Party_id,
                          XA.Koppeling_id,
                          MAX(CASE WHEN XA.Party_deelnemer_rol = 1 THEN 1 ELSE NULL END) AS Party_deelnemer_rol
                     FROM Mi_vm_ldm.aParty_party_relatie XA
                    WHERE XA.Party_sleutel_type = 'BC'
                      AND XA.Party_relatie_type_code = 'CBCTCE'
                  QUALIFY RANK() OVER (PARTITION BY XA.Party_id ORDER BY XA.Koppeling_id) = 1
                    GROUP BY 1, 2) AS Y
    ON X.Party_id = Y.Party_id
/* Ophalen Koppeling_ID Commerciele Groep */
  LEFT OUTER JOIN (SELECT XA.Party_id,
                          XA.Koppeling_id,
                          MAX(CASE WHEN XA.Party_deelnemer_rol = 1 THEN 1 ELSE NULL END) AS Party_deelnemer_rol
                     FROM Mi_vm_ldm.aParty_party_relatie XA
                    WHERE XA.Party_sleutel_type = 'CC'
                      AND XA.Party_relatie_type_code = 'CCTCG'
                  QUALIFY RANK() OVER (PARTITION BY XA.Party_id ORDER BY XA.Koppeling_id) = 1
                    GROUP BY 1, 2) AS Z
    ON A.CC_NR = Z.Party_id
   /* US Persons */
  LEFT OUTER JOIN Mi_vm_ldm.aSegment_klant U
    ON X.Party_id = U.Party_id
   AND X.Party_sleutel_type = U.Party_sleutel_type
   AND U.Segment_Type_Code = 'USPERS'
  LEFT OUTER JOIN MI_TEMP.aSegment V
    ON U.Segment_Id = V.Segment_Id
   AND U.Segment_Type_Code = V.Segment_Type_Code
  /* FATCA */
  LEFT OUTER JOIN mi_vm_ldm.aparty_fatca AG
    ON X.party_id = AG.party_id
   AND X.party_sleutel_type = AG.party_sleutel_type
  /* BC Risico Score */
  LEFT OUTER JOIN Mi_vm_ldm.aklant_prospect W
    ON X.party_id = W.party_id
   AND X.party_sleutel_type = W.party_sleutel_type
  /* MIFID Wettelijke client classificatie */
  LEFT OUTER JOIN (SELECT XA.Party_id, XA.Party_sleutel_type, XB.Segment_oms
                     FROM Mi_vm_ldm.aSegment_klant XA
                     LEFT OUTER JOIN MI_TEMP.aSegment XB
                       ON XA.Segment_Id = XB.Segment_Id
                      AND XA.Segment_Type_Code = XB.Segment_Type_Code
                    WHERE XA.Segment_type_code IN ('wtclas')) AS AA
    ON X.Party_id = AA.Party_id
   AND X.Party_sleutel_type = AA.Party_sleutel_type
  /* MIFID ABNAMRO client classificatie */
  LEFT OUTER JOIN (SELECT XA.Party_id, XA.Party_sleutel_type, XB.Segment_oms
                     FROM Mi_vm_ldm.aSegment_klant XA
                     LEFT OUTER JOIN MI_TEMP.aSegment XB
                       ON XA.Segment_Id = XB.Segment_Id
                      AND XA.Segment_Type_Code = XB.Segment_Type_Code
                    WHERE XA.Segment_type_code IN ('aaclas')) AS AB
    ON X.Party_id = AB.Party_id
   AND X.Party_sleutel_type = AB.Party_sleutel_type
  /* MIFID Fitness test Rente derivaten */
  LEFT OUTER JOIN (SELECT XA.Party_id, XA.Party_sleutel_type, XB.Segment_oms
                     FROM Mi_vm_ldm.aSegment_klant XA
                     LEFT OUTER JOIN MI_TEMP.aSegment XB
                       ON XA.Segment_Id = XB.Segment_Id
                      AND XA.Segment_Type_Code = XB.Segment_Type_Code
                    WHERE XA.Segment_type_code IN ('rntdrv')) AD
    ON X.Party_id = AD.Party_id
   AND X.Party_sleutel_type = AD.Party_sleutel_type
  /* MIFID Fitness test commodity derivaten */
  LEFT OUTER JOIN (SELECT XA.Party_id, XA.Party_sleutel_type, XB.Segment_oms
                     FROM Mi_vm_ldm.aSegment_klant XA
                     LEFT OUTER JOIN MI_TEMP.aSegment XB
                       ON XA.Segment_Id = XB.Segment_Id
                      AND XA.Segment_Type_Code = XB.Segment_Type_Code
                    WHERE XA.Segment_type_code IN ('comdrv')) AC
    ON X.Party_id = AC.Party_id
   AND X.Party_sleutel_type = AC.Party_sleutel_type
  /* MIFID Fitness test Valuta derivaten */
  LEFT OUTER JOIN (SELECT XA.Party_id, XA.Party_sleutel_type, XB.Segment_oms
                     FROM Mi_vm_ldm.aSegment_klant XA
                     LEFT OUTER JOIN MI_TEMP.aSegment XB
                       ON XA.Segment_Id = XB.Segment_Id
                      AND XA.Segment_Type_Code = XB.Segment_Type_Code
                    WHERE XA.Segment_type_code IN ('valdrv')) AE
    ON X.Party_id = AE.Party_id
   AND X.Party_sleutel_type = AE.Party_sleutel_type
  /* MIFID Fitness test Overige Markets Producten */
  LEFT OUTER JOIN (SELECT XA.Party_id, XA.Party_sleutel_type, XB.Segment_oms
                     FROM Mi_vm_ldm.aSegment_klant XA
                     LEFT OUTER JOIN MI_TEMP.aSegment XB
                       ON XA.Segment_Id = XB.Segment_Id
                      AND XA.Segment_Type_Code = XB.Segment_Type_Code
                    WHERE XA.Segment_type_code IN ('ovmkpr')) AF
    ON X.Party_id = AF.Party_id
   AND X.Party_sleutel_type = AF.Party_sleutel_type
  /* GSRI informatie uit FAIR */
  LEFT OUTER JOIN (SELECT XA.Party_id,
                          CASE
                          WHEN LENGTH(TRIM(XA.Party_GSRI_goedgekeurd)) = 0 THEN NULL
                          ELSE TRIM(XA.Party_GSRI_goedgekeurd)
                          END AS BC_GSRI_Goedgekeurd,
                          CASE
                          WHEN LENGTH(TRIM(XA.Party_Assessment_resultaat)) = 0 THEN NULL
                          ELSE TRIM(XA.Party_Assessment_resultaat)
                          END AS BC_GSRI_Assessment_resultaat
                     FROM MI_VM_LDM.aparty_gsri XA
                  QUALIFY RANK() OVER (PARTITION BY XA.Party_id ORDER BY XA.Party_gsri_SDAT DESC, XA.Gsri_expiratie_datum DESC) = 1) AS AH
    ON X.Party_id = AH.Party_id
    /* Global Business Contact en Ultimate Legal Parent */
  LEFT OUTER JOIN (SELECT XA.party_id, XA.GBC_nr, XB.GBC_naam, XC.ULP_BC_nr, XD.ULP_naam
                     FROM (SELECT XXA.Party_id, XXA.gerelateerd_party_id AS GBC_nr
                             FROM Mi_vm_ldm.aParty_party_relatie XXA
                            WHERE XXA.Party_sleutel_type = 'BC'
                              AND XXA.Party_relatie_type_code = 'CBCGBC'
                            GROUP BY 1, 2) AS XA
                     LEFT OUTER JOIN (SELECT XXA.Party_id, TRIM(XXA.Naamregel_1)||TRIM(XXA.Naamregel_2)||TRIM(XXA.Naamregel_3) AS GBC_naam
                                        FROM Mi_vm_ldm.aParty_naam XXA
                                       WHERE XXA.Party_sleutel_type = 'BC') AS XB
                       ON XA.GBC_nr = XB.Party_id
                     LEFT OUTER JOIN (SELECT XXA.Party_id, XXA.gerelateerd_party_id AS ULP_BC_nr
                                        FROM Mi_vm_ldm.aParty_party_relatie XXA
                                       WHERE XXA.Party_relatie_type_code = 'GBCUP'
                                         AND XXA.Party_sleutel_type = 'GB'
                                       GROUP BY 1, 2) AS XC
                       ON XA.GBC_nr = XC.Party_id
                     LEFT OUTER JOIN (SELECT XXA.Party_id, TRIM(XXA.Naamregel_1)||TRIM(XXA.Naamregel_2)||TRIM(XXA.Naamregel_3) AS ULP_naam
                                        FROM Mi_vm_ldm.aParty_naam XXA
                                       WHERE XXA.Party_sleutel_type = 'BC') AS XD
                       ON XC.ULP_BC_nr = XD.Party_id) AS AI
    ON X.Party_id = AI.Party_id
  /* Customerlifecycle */
  LEFT OUTER JOIN (SELECT XA.Party_id, XA.Party_sleutel_type, XA.Segment_id, XB.Segment_oms
                     FROM Mi_vm_ldm.aSegment_klant XA
                     LEFT OUTER JOIN MI_TEMP.aSegment XB
                       ON XA.Segment_Id = XB.Segment_Id
                      AND XA.Segment_Type_Code = XB.Segment_Type_Code
                    WHERE XA.Segment_type_code = 'CULICY') AJ
    ON X.Party_id = AJ.Party_id
   AND X.Party_sleutel_type = AJ.Party_sleutel_type
  /* Ringfence */
  LEFT OUTER JOIN (SELECT XA.Party_id, XA.Party_sleutel_type, XA.Segment_id, XB.Segment_oms
                     FROM Mi_vm_ldm.aSegment_klant XA
                     LEFT OUTER JOIN MI_TEMP.aSegment XB
                       ON XA.Segment_Id = XB.Segment_Id
                      AND XA.Segment_Type_Code = XB.Segment_Type_Code
                    WHERE XA.Segment_type_code = 'RIFENC') AK
    ON X.Party_id = AK.Party_id
   AND X.Party_sleutel_type = AK.Party_sleutel_type
  /* Transaction Banking */
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
 /* Trust kantoren */
  LEFT OUTER JOIN (SELECT XA.Party_id,
                          XA.Gerelateerd_party_id AS Trust_complex_nr
                     FROM Mi_vm_ldm.aParty_party_relatie XA
                    WHERE XA.Party_relatie_type_code  = 'DVNTTK') AS TR
   ON X.Party_id = TR.Party_id
 /* Franchise kantoren */
  LEFT OUTER JOIN (SELECT XA.Party_id,
                          XA.Gerelateerd_party_id AS Franchise_complex_nr
                     FROM Mi_vm_ldm.aParty_party_relatie XA
                    WHERE XA.Party_relatie_type_code  = 'FRNCSE') AS FR
   ON X.Party_id = FR.Party_id
 /* Private Banking CCA (Client Contact) */
  LEFT OUTER JOIN (SELECT XA.Party_id,
                          XA.Party_sleutel_type,
                          XA.Party_relatie_type_code,
                          XA.Gerelateerd_party_id AS Gerelateerd_party_id
                     FROM Mi_vm_ldm.aParty_party_relatie XA
                     WHERE XA.Party_relatie_type_code = 'PRVBNK'
                    GROUP BY 1, 2, 3
                  QUALIFY RANK (XA.Party_party_relatie_sdat DESC) = 1) AS AO
    ON X.Party_id = AO.Party_id
   AND X.Party_sleutel_type = AO.Party_sleutel_type
 /* Bepalen Leidend Private Banking BC Indicator */
  LEFT OUTER JOIN (SELECT XA.Party_id,
                          XA.koppeling_id,
                          MAX(CASE WHEN XA.Party_deelnemer_rol = 1 THEN 1 ELSE NULL END) AS Party_deelnemer_rol
                     FROM Mi_vm_ldm.aParty_party_relatie XA
                    WHERE XA.Party_sleutel_type = 'BC'
                      AND XA.Party_relatie_type_code = 'LDPCNL'
                  QUALIFY RANK() OVER (PARTITION BY XA.Party_id ORDER BY XA.Koppeling_id) = 1
                    GROUP BY 1, 2) AS AP
    ON X.Party_id = AP.Party_id
 WHERE X.Party_sleutel_type = 'BC';

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.Mia_alle_bcs COLUMN (BC_CLIENTGROEP);
COLLECT STATISTICS Mi_temp.Mia_alle_bcs COLUMN (BC_VERSCHIJNINGSVORM);
COLLECT STATISTICS Mi_temp.Mia_alle_bcs COLUMN (DB_IND, RBS_IND);
COLLECT STATISTICS Mi_temp.Mia_alle_bcs COLUMN (BC_CCA_RM);
COLLECT STATISTICS Mi_temp.Mia_alle_bcs COLUMN (BC_CCA_AM);
COLLECT STATISTICS Mi_temp.Mia_alle_bcs COLUMN (BC_BO_NR);
COLLECT STATISTICS Mi_temp.Mia_alle_bcs COLUMN (BC_RELATIECATEGORIE);
COLLECT STATISTICS Mi_temp.Mia_alle_bcs COLUMN (BUSINESS_CONTACT_NR);
COLLECT STATISTICS Mi_temp.Mia_alle_bcs COLUMN (DB_IND ,RBS_IND ,BC_CONTRACTEN);
COLLECT STATISTICS Mi_temp.Mia_alle_bcs COLUMN (BC_CONTRACTEN);
COLLECT STATISTICS Mi_temp.Mia_alle_bcs COLUMN (KLANT_NR);
COLLECT STATISTICS Mi_temp.Mia_alle_bcs COLUMN (BC_SBI_CODE_BCDB);
COLLECT STATISTICS Mi_temp.Mia_alle_bcs COLUMN (BC_VALIDATIENIVEAU);
COLLECT STATISTICS Mi_temp.Mia_alle_bcs COLUMN (BC_VALIDATIENIVEAU, DB_IND, RBS_IND, BC_CONTRACTEN);

.IF ERRORCODE <> 0 THEN .GOTO EOP

CREATE TABLE Mi_temp.Mia_baten_product
      (
       Party_id DECIMAL(12,0),
       Party_sleutel_type CHAR(4) CHARACTER SET LATIN NOT CASESPECIFIC,
       Maand_nr INTEGER,
       Banktype CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
       Combiproductlevel CHAR(8) CHARACTER SET LATIN NOT CASESPECIFIC,
       Prod_naam CHAR(35) CHARACTER SET LATIN NOT CASESPECIFIC,
       Baten DECIMAL(18,2)
      )
PRIMARY INDEX ( Party_id, Party_sleutel_type, Maand_nr, Banktype, Combiproductlevel )
INDEX ( Party_id )
INDEX ( Party_sleutel_type )
INDEX ( Maand_nr )
INDEX ( Banktype )
INDEX ( Combiproductlevel );

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.Mia_baten_product    COLUMN ( Party_sleutel_type );
COLLECT STATISTICS Mi_temp.Mia_baten_product    COLUMN ( PARTY_ID, COMBIPRODUCTLEVEL );
COLLECT STATISTICS Mi_temp.Mia_klantkoppelingen COLUMN ( Klant_nr);
COLLECT STATISTICS Mi_temp.Mia_klantkoppelingen COLUMN ( Klant_nr, Maand_nr );
COLLECT STATISTICS Mi_temp.Mia_klantkoppelingen COLUMN ( Klant_nr, Maand_nr, Volgorde);
COLLECT STATISTICS Mi_temp.Mia_klantkoppelingen COLUMN ( Business_contact_nr);
COLLECT STATISTICS Mi_temp.Mia_klantkoppelingen COLUMN ( Volgorde );

.IF ERRORCODE <> 0 THEN .GOTO EOP

CREATE TABLE Mi_temp.Mia_baten_detail
      (
       Klant_nr INTEGER,
       Maand_nr INTEGER,
       CUBe_product_id INTEGER,
       Baten_maand INTEGER,
       Volgorde INTEGER,
       Datum_baten DATE FORMAT 'YYYYMMDD',
       Baten_totaal DECIMAL(18,2)
      )
UNIQUE PRIMARY INDEX ( Klant_nr, Maand_nr, CUBe_product_id, Baten_maand, Volgorde )
INDEX ( Klant_nr )
INDEX ( Maand_nr )
INDEX ( CUBe_product_id )
INDEX ( Baten_maand )
INDEX ( Volgorde );

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.Mia_baten_detail COLUMN ( Klant_nr, CUBe_product_id );
COLLECT STATISTICS Mi_temp.Mia_klant_info   COLUMN ( Klant_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CUBe_producten COLUMN (CUBe_product_id, CUBe_product_oms);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CUBe_producten COLUMN Min_verhouding;

.IF ERRORCODE <> 0 THEN .GOTO EOP

CREATE TABLE Mi_temp.Mia_baten
      (
       Klant_nr INTEGER,
       Maand_nr INTEGER,
       CUBe_product_id INTEGER,
       Baten DECIMAL(18,2),
       Baten_jaar_ervoor DECIMAL(18,2),
       Baten_mnd24 DECIMAL(18,2),
       Baten_mnd23 DECIMAL(18,2),
       Baten_mnd22 DECIMAL(18,2),
       Baten_mnd21 DECIMAL(18,2),
       Baten_mnd20 DECIMAL(18,2),
       Baten_mnd19 DECIMAL(18,2),
       Baten_mnd18 DECIMAL(18,2),
       Baten_mnd17 DECIMAL(18,2),
       Baten_mnd16 DECIMAL(18,2),
       Baten_mnd15 DECIMAL(18,2),
       Baten_mnd14 DECIMAL(18,2),
       Baten_mnd13 DECIMAL(18,2),
       Baten_mnd12 DECIMAL(18,2),
       Baten_mnd11 DECIMAL(18,2),
       Baten_mnd10 DECIMAL(18,2),
       Baten_mnd09 DECIMAL(18,2),
       Baten_mnd08 DECIMAL(18,2),
       Baten_mnd07 DECIMAL(18,2),
       Baten_mnd06 DECIMAL(18,2),
       Baten_mnd05 DECIMAL(18,2),
       Baten_mnd04 DECIMAL(18,2),
       Baten_mnd03 DECIMAL(18,2),
       Baten_mnd02 DECIMAL(18,2),
       Baten_mnd01 DECIMAL(18,2)
      )
UNIQUE PRIMARY INDEX ( Klant_nr, Maand_nr, CUBe_product_id )
INDEX ( Klant_nr )
INDEX ( Maand_nr )
INDEX ( CUBe_product_id );

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.Mia_klant_info     COLUMN ( Klant_nr, Maand_nr );

.IF ERRORCODE <> 0 THEN .GOTO EOP



CREATE TABLE Mi_temp.Mia_klantbaten
      (
       Klant_nr INTEGER,
       Maand_nr INTEGER,
       Baten DECIMAL(18,2),
       Baten_jaar_ervoor DECIMAL(18,2),
       Baten_mnd24 DECIMAL(18,2),
       Baten_mnd23 DECIMAL(18,2),
       Baten_mnd22 DECIMAL(18,2),
       Baten_mnd21 DECIMAL(18,2),
       Baten_mnd20 DECIMAL(18,2),
       Baten_mnd19 DECIMAL(18,2),
       Baten_mnd18 DECIMAL(18,2),
       Baten_mnd17 DECIMAL(18,2),
       Baten_mnd16 DECIMAL(18,2),
       Baten_mnd15 DECIMAL(18,2),
       Baten_mnd14 DECIMAL(18,2),
       Baten_mnd13 DECIMAL(18,2),
       Baten_mnd12 DECIMAL(18,2),
       Baten_mnd11 DECIMAL(18,2),
       Baten_mnd10 DECIMAL(18,2),
       Baten_mnd09 DECIMAL(18,2),
       Baten_mnd08 DECIMAL(18,2),
       Baten_mnd07 DECIMAL(18,2),
       Baten_mnd06 DECIMAL(18,2),
       Baten_mnd05 DECIMAL(18,2),
       Baten_mnd04 DECIMAL(18,2),
       Baten_mnd03 DECIMAL(18,2),
       Baten_mnd02 DECIMAL(18,2),
       Baten_mnd01 DECIMAL(18,2),
       N_maanden_baten INTEGER,
       Baten_gecorrigeerd DECIMAL(18,2)
      )
UNIQUE PRIMARY INDEX ( Klant_nr, Maand_nr )
INDEX ( Klant_nr )
INDEX ( Maand_nr );

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.Mia_klantbaten       COLUMN ( Klant_nr, Maand_nr );
COLLECT STATISTICS Mi_temp.Mia_klant_info       COLUMN ( Klant_nr, Maand_nr );
COLLECT STATISTICS Mi_temp.Mia_klantkoppelingen COLUMN ( Maand_nr, Business_contact_nr );
COLLECT STATISTICS Mi_temp.Mia_klantkoppelingen COLUMN ( Klant_nr, Maand_nr );
COLLECT STATISTICS Mi_temp.Mia_klantkoppelingen COLUMN ( Klant_nr, Maand_nr );
COLLECT STATISTICS Mi_temp.Mia_klantkoppelingen COLUMN ( Klant_nr, Maand_nr, Volgorde);
COLLECT STATISTICS Mi_temp.Mia_klantkoppelingen COLUMN ( Business_contact_nr);
COLLECT STATISTICS Mi_temp.Mia_klant_info       COLUMN (Leidend_bc_nr);

.IF ERRORCODE <> 0 THEN .GOTO EOP





/*****************************************************

    Complexe producten

A    Totaal OOE 250k plus
B    Maatwerk krediet                                            --> obv NPL indicatie CIF ipv Risk indicatie MK
C    Arrangement kredieten
D    Treasury
E    AOL
F    Rentecompensatie
G    OBSI limiet                                                --> NIET MEER TE BEPALEN
H    EURIBOR Rekening Courant
I    Maatwerktarifering betalingsverkeer
J    GRV 010 - particulier RC altijd als complex beschouwen
K    --   (was :Corporate Payment Services, wordt niet bepaald)
L    Beleggen serviceconcept anders dan Direct Beleggen


    Complex indien afgelopen 12 maanden baten op een complex product:
U    GKDB    01.03.00    Rollovers
V    GKDB    01.06.00    Kasgeld
W    -- (was: GKDB    03.01.00    Rentederivaten, wordt niet bepaald 20170209)
X    -- (was: GKDB    03.02.00    Valutaderivaten, wordt niet bepaald 20170209)
Y    GKDB    03.04.00    Equity Capital Markets GMK
Z    -- (was: GKDB    03.05.00    Commodity Derivatives, wordt niet bepaald 20170209)
0    GKDB    05.02.00    Documentary credit
1    GKDB    05.03.00    Documentary collection
2    GKDB    06.01.00    Corporate Finance
3    GKDB    06.02.00    Equity Capital Markets CF
4    GKDB    07.01.00    Loan Syndications
5    GKDB    07.02.00    Structured Finance
6    GKDB    07.03.00    Acquisition & Leveraged Finance
7    GKDB    07.04.00    Export & Project Finance
8    GKDB    11.01.00    Factoring
9    -- (was: GKDB    12.01.00    Private wealth Management, wordt niet bepaald 20170209)

*****************************************************/

/*------------------------------------
De complexe producten vanuit de GKDB
------------------------------------

Stuurtabel met de GKDB producten welke als complex worden aangemerkt:  Mi_cmb.LU_Complexe_producten
*/

COLLECT STATISTICS MI_SAS_AA_MB_C_MB.LU_Complexe_producten COLUMN (CODE_COMPLEX_PRODUCT,PRODUCTLEVEL2DESCRIPTION);

.IF ERRORCODE <> 0 THEN .GOTO EOP



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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATS ON Mi_temp.Complex_prod_GKDB_12mnd COLUMN BC_nr;



.IF ERRORCODE <> 0 THEN .GOTO EOP

/*-----------------------------------------
AOL contracten
-----------------------------------------*/

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATS ON Mi_temp.Complex_prod_MIND COLUMN BC_nr;
COLLECT STATISTICS Mi_temp.Complex_prod_MIND COLUMN (CODE_COMPLEX_PRODUCT,PRODUCT_NAAM);

.IF ERRORCODE <> 0 THEN .GOTO EOP


/*-----------------------------------------
Maatwerk geldrekeningvormen 010: GRV010 particulier RC altijd als complex beschouwen

-----------------------------------------*/

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATS ON Mi_temp.Complex_GRV102030 COLUMN BC_nr;

.IF ERRORCODE <> 0 THEN .GOTO EOP


/*-----------------------------------------
Maatwerk Krediet        --> obv NPL indicatie

OBSI limiet --> NIET MEER TE BEPALEN
-----------------------------------------*/

COLLECT STATISTICS COLUMN (MAAND_NR ,FAC_CONTRACT_NR ,FAC_BC_NR) ON Mi_cmb.CIF_Complex;
COLLECT STATISTICS COLUMN (Fac_Actief_ind ,SUBSTR(TRIM(BOTH FROM PL_NPL_type ),1 ,3 )) AS ST_250415160957_1_CIF_Complex ON Mi_cmb.CIF_Complex;
COLLECT STATISTICS COLUMN (SUBSTR(TRIM(BOTH FROM PL_NPL_type),1 ,3 )) AS ST_250415160957_0_CIF_Complex ON Mi_cmb.CIF_Complex;
COLLECT STATISTICS COLUMN (FAC_CONTRACT_NR) ON Mi_cmb.CIF_Complex;

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

/*-----------------------------------------
Beleggen service concepten ongelijk aan ZELF BELEGGEN
-----------------------------------------*/

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

COLLECT STATS ON Mi_temp.Complex_prod_beleggen COLUMN BC_nr;

.IF ERRORCODE <> 0 THEN .GOTO EOP

/*-----------------------------------------
RC EURIBOR rente, RC rentecompensatie
-----------------------------------------*/

/* tabel Mi_cmb.TRC_REK_COURANT nogal eens waardoor het schedule klapt. vandaar onderstaande sql */
CREATE SET TABLE Mi_temp.CIAA_TRC_REK_COURANT ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      Mi_cmb_ind BYTEINT,
      Maand_nr INTEGER,
      Contract_nr DECIMAL(11,0),
      Ind_EURIBOR_rente SMALLINT COMPRESS(1),
      Ind_rentecompensatie SMALLINT COMPRESS(1))
UNIQUE PRIMARY INDEX ( MI_cmb_ind, Maand_nr ,Contract_nr )
;

.IF ERRORCODE <> 0 THEN .GOTO EOP
    /* data van vorige week */
INSERT INTO Mi_temp.CIAA_TRC_REK_COURANT
SELECT
       0
      ,Maand_nr
      ,Contract_nr
      ,Ind_EURIBOR_rente
      ,Ind_rentecompensatie
FROM MI_SAS_AA_MB_C_MB.CIAA_TRC_REK_COURANT
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* meest recente data */
/* onderstaande sql kan stuklopen vanwege ontbreken tabel, script moet dan echter niet worden afgebroken */
INSERT INTO MI_temp.CIAA_TRC_REK_COURANT
SELECT
       1
      ,Maand_nr
      ,Contract_nr
      ,Ind_EURIBOR_rente
      ,Ind_rentecompensatie
FROM MI_cmb.TRC_REK_COURANT
;
/*.IF ERRORCODE <> 0 THEN .GOTO EOP*/


DEL FROM MI_SAS_AA_MB_C_MB.CIAA_TRC_REK_COURANT
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* neem bij voorkeur de meest recente data, indien ontbrekend de data van vorige week */
INSERT INTO MI_SAS_AA_MB_C_MB.CIAA_TRC_REK_COURANT
SEL
       Maand_nr
      ,Contract_nr
      ,Ind_EURIBOR_rente
      ,Ind_rentecompensatie
FROM MI_temp.CIAA_TRC_REK_COURANT
QUALIFY RANK (Mi_cmb_ind DESC) = 1
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATS MI_SAS_AA_MB_C_MB.CIAA_TRC_REK_COURANT COLUMN (Maand_nr,Contract_nr,Ind_EURIBOR_rente);
COLLECT STATS MI_SAS_AA_MB_C_MB.CIAA_TRC_REK_COURANT COLUMN (Maand_nr,Contract_nr,Ind_rentecompensatie);
COLLECT STATS MI_SAS_AA_MB_C_MB.CIAA_TRC_REK_COURANT COLUMN (Maand_nr,Contract_nr);

.IF ERRORCODE <> 0 THEN .GOTO EOP





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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATS ON Mi_temp.Complex_prod_RC COLUMN BC_nr;

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATS ON Mi_temp.Complex_prod_RC COLUMN BC_nr;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.Complex_prod_RC COLUMN (CODE_COMPLEX_PRODUCT,PRODUCT_NAAM);

.IF ERRORCODE <> 0 THEN .GOTO EOP



/*-----------------------------------------
Maatwerktarifering betalingsverkeer

    (bevat maatwerk offers: dus echt maatwerkafspraken met die klant,
     of de klant maakt gebruik van maatwerk binnen een arrangement (bv. schell bezinepomp maakt gebruik van maatwerk arrangement afgesproken met Schell hoofdkantoor)
     of bv. Lindorff afspraken (deze klanten worden niet getarifeerd0
     en nog wat administratieve offers die wellicht niet als maatwerk tarifering zouden moeten worden beschouwd.

     wil je nog onderscheidt maken dan moet je echt per offer kijken, niet te doen
     )
-----------------------------------------*/

COLLECT STATISTICS Mi_cmb.TB_offers COLUMN Offer_code;

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATS ON Mi_temp.Complex_prod_RC_mtwrk COLUMN BC_nr;

.IF ERRORCODE <> 0 THEN .GOTO EOP

/*-----------------------------------------
    BC eindtabel Complexe_producten
-----------------------------------------*/

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATS ON Mi_temp.Complex_product COLUMN (Klant_nr, Maand_nr);

.IF ERRORCODE <> 0 THEN .GOTO EOP


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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATS ON Mi_temp.Complex_product COLUMN (Klant_nr, Maand_nr);

.IF ERRORCODE <> 0 THEN .GOTO EOP




/*-----------------------------------------
    Eindtabel Complexe_producten
-----------------------------------------*/

CREATE TABLE Mi_temp.Complexe_producten
      (
       Klant_nr INTEGER,
       Maand_nr INTEGER,
       Complexe_producten VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
       Aantal_complexe_producten SMALLINT
      )
UNIQUE PRIMARY INDEX ( Klant_nr, Maand_nr )
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.Complexe_producten COLUMN (Klant_nr, Maand_nr);
COLLECT STATISTICS Mi_temp.Complexe_producten COLUMN (KLANT_NR , MAAND_NR);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.MIA_organisatie COLUMN (Org_niveau3, Org_niveau2, Org_niveau1, BO_BL);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.MIA_organisatie COLUMN (Org_niveau1, Org_niveau1_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.MIA_organisatie COLUMN (Org_niveau2, Org_niveau2_nr, Org_niveau1, Org_niveau1_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.MIA_organisatie COLUMN (Org_niveau3, Org_niveau3_nr, Org_niveau2, Org_niveau2_nr, Org_niveau1, Org_niveau1_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.MIA_organisatie COLUMN (Org_niveau0, Org_niveau0_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.MIA_organisatie COLUMN (Org_niveau3, Org_niveau2, Org_niveau1, Org_niveau0, BO_BL);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.MIA_organisatie COLUMN (Org_niveau1, Org_niveau1_nr, Org_niveau0, Org_niveau0_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.MIA_organisatie COLUMN (Org_niveau2, Org_niveau2_nr, Org_niveau1, Org_niveau1_nr, Org_niveau0, Org_niveau0_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.MIA_organisatie COLUMN (Org_niveau3, Org_niveau3_nr, Org_niveau2, Org_niveau2_nr, Org_niveau1, Org_niveau1_nr, Org_niveau0, Org_niveau0_nr);


.IF ERRORCODE <> 0 THEN .GOTO EOP

/*************************************************************************************

    BASIS SET tabellen Siebel (CRM), onafhankelijk van Mia_week

*************************************************************************************/

/* ----------------------------------------------------------------------------------------------------

Siebel_Employee

------------------------------------------------------------------------------------------------------*/

CREATE TABLE MI_SAS_AA_MB_C_MB.Siebel_Employee_NEW
(
      Maand_nr INTEGER,
      Datum_gegevens DATE FORMAT 'yyyy-mm-dd',
      SBT_ID VARCHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
      Naam VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS NULL,
      Soort_mdw CHAR (2) COMPRESS ('AM','MW'),
      Functie VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
      BO_nr_mdw INTEGER,
      BO_naam_mdw VARCHAR(256) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
      CCA INTEGER,
      CCA2 INTEGER,
       CCA3 INTEGER,
      GM_ind BYTEINT,
      Account_Management_Specialism VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
      Account_Management_Segment VARCHAR(8) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
      Mdw_sdat DATE FORMAT 'yyyy-mm-dd'
     )
UNIQUE PRIMARY INDEX ( Maand_nr ,SBT_ID )
PARTITION BY RANGE_N(Maand_nr  BETWEEN 201001  AND 201012  EACH 1 ,
201101  AND 201112  EACH 1 ,
201201  AND 201212  EACH 1 ,
201301  AND 201312  EACH 1 ,
201401  AND 201412  EACH 1 ,
201501  AND 201512  EACH 1 ,
201601  AND 201612  EACH 1 ,
201701  AND 201712  EACH 1 ,
201801  AND 201812  EACH 1 ,
201901  AND 201912  EACH 1 ,
202001  AND 202012  EACH 1 ,
 NO RANGE, UNKNOWN);

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

-- Ophalen naam medewerker

INNER JOIN (SEL party_id,
                               party_sleutel_type,
                               CASE WHEN party_sleutel_type = 'MW' THEN UPPER(TRIM(Naam)) ELSE UPPER(TRIM(Naamregel_1)) END AS
                               Naam
                      FROM mi_vm_ldm.aparty_naam
                      WHERE party_sleutel_type IN ('MW', 'AM')
) b
ON a.party_id = b.party_id
AND a.party_sleutel_type = b.party_sleutel_type

-- Ophalen BO nummer medewerker

INNER JOIN (SEL party_id,
                               party_sleutel_type,
                               gerelateerd_party_id AS bo_nr
                       FROM mi_vm_ldm.aPARTY_PARTY_RELATIE
                       WHERE party_relatie_type_code IN ('AMBO', 'MWBO')
) c
ON a.party_id = c.party_id
AND a.party_sleutel_type = c.party_sleutel_type

-- Ophalen BO naam medewerker

LEFT JOIN  (SEL party_id AS bo_nr,
                                naam AS bo_naam
                        FROM mi_vm_ldm.aparty_naam
                        WHERE party_sleutel_type = 'BO'
) d
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

LEFT JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW f
ON 1=1

) XA

/*
Indien meerdere party_id's per SBT_ID:
1. AM boven MW
2. Hoogste aantal bc's gekoppeld aan AM
3. Meest recente ingangsdatum record
4. Hoogste CCA code
*/

QUALIFY RANK () OVER (PARTITION BY XA.sbt_id ORDER BY XA.party_sleutel_type ASC, ZEROIFNULL(XA.N_bcs) DESC, XA.Mdw_sdat DESC, XA.cca DESC) = 1;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Employee_NEW COLUMN ( SBT_ID);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Employee_NEW COLUMN ( SBT_ID, Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Employee_NEW COLUMN ( SBT_ID, Maand_nr, BO_nr_mdw);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Employee_NEW COLUMN ( BO_nr_mdw);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Employee_NEW COLUMN ( BO_nr_mdw, Maand_nr);

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* ----------------------------------------------------------------------------------------------------

Siebel_Activiteit

------------------------------------------------------------------------------------------------------  */

CREATE TABLE MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW
 ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      Klant_nr INTEGER,
      Maand_nr INTEGER,
      Datum_gegevens DATE FORMAT 'yyyy-mm-dd',
      Business_contact_nr DECIMAL(12,0),
      Status VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS('Done', 'Unscheduled', 'Cancelled', 'In Progress', 'Closed', 'Wacht op klant', 'New', 'Toegewezen aan derden', 'Scheduled', 'Expired' ),
      Activiteit_type VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS('Task', 'Appointment', 'Contacts'),
      Sub_type VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
      Product_groep VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
      Onderwerp VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
      Korte_omschrijving VARCHAR(250) CHARACTER SET UNICODE NOT CASESPECIFIC,
      Contact_methode VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
      Vertrouwelijk_ind BYTEINT COMPRESS (0 ,1 ),
      Datum_start DATE FORMAT 'yyyy-mm-dd',                         /*Datum contact*/
      Maand_nr_start INTEGER,
      Datum_verval DATE FORMAT 'yyyy-mm-dd',                     /*Een activiteit dient voor deze datum afgehandeld te zijn. Deze datum is dus de geplande eind datum, zelf in te vullen door medewerker */
      Maand_nr_verval INTEGER,
      Datum_eind DATE FORMAT 'yyyy-mm-dd',                         /*Dit is de datum waarop de activiteit gesloten wordt. Bij het aanmaken van een activiteit wordt deze gelijk gezet met de Vervaldatum. Maar als de activiteit gesloten wordt dan wordt deze datum bijgewerkt naar de datum van de betreffende dag.*/
      Maand_nr_eind INTEGER,
      Siebel_verkoopkans_id VARCHAR(15) CHARACTER SET LATIN NOT CASESPECIFIC,                     /*Link naar afhankelijke verkoopkans, alleen gevuld als er een link is tussen een activiteit en verkoopkans */
      Sbt_id_mdw_eigenaar VARCHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
      Naam_mdw_eigenaar VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
      Gespreksrapport_id VARCHAR(15) CHARACTER SET LATIN NOT CASESPECIFIC,
      Siebel_lead_id VARCHAR(15) CHARACTER SET LATIN NOT CASESPECIFIC,
      Siebel_revisie_id VARCHAR(15) CHARACTER SET LATIN NOT CASESPECIFIC,
      Siebel_service_request_id VARCHAR(15) CHARACTER SET LATIN NOT CASESPECIFIC,
      Datum_aangemaakt DATE FORMAT 'yyyy-mm-dd',
      Maand_nr_aangemaakt INTEGER,
      Aantal_contactpersonen INTEGER COMPRESS (NULL, 0),
      Aantal_medewerkers INTEGER COMPRESS (NULL, 0),
      Siebel_activiteit_id VARCHAR(15) CHARACTER SET LATIN NOT CASESPECIFIC NOT NULL,
      Client_level CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS ('BC','CC','CE','CG', 'XR'),
      Sdat DATE FORMAT 'yyyy-mm-dd' NOT NULL,
      Edat DATE FORMAT 'yyyy-mm-dd'
      )
UNIQUE PRIMARY INDEX (Siebel_activiteit_id);

.IF ERRORCODE <> 0 THEN .GOTO EOP

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
, TRIM(A.Siebel_lead_id)
, TRIM(A.siebel_revisie_id)
, TRIM(A.siebel_service_request_id)
, TRIM(A.Datum_aangemaakt)
, EXTRACT(YEAR FROM A.Datum_aangemaakt) * 100 + EXTRACT(MONTH FROM A.Datum_aangemaakt)
, COALESCE(CN.Aantal_CN, 0) AS Aantal_Contactpersonen -- Wordt later in het script geupdate
, COALESCE(MDW.Aantal_MDW, 0) AS Aantal_Medewerkers  -- Wordt later in het script geupdate
, TRIM(A.Siebel_activiteit_id)
, COALESCE(TRIM(sleutel_type_commercieel_cluster), TRIM(sleutel_type_rechtspersoon_bc)) AS Client_level
, A.Sdat
, A.Edat

FROM mi_vm_ldm.aACTIVITEIT_cb A

/* Maandnummer en datum_gegevens toevoegen aan tabel */
LEFT JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW B
ON 1=1

/* Toevoegen Klant en BC nummer  */
INNER JOIN Mi_temp.Mia_klantkoppelingen BC
ON a.party_id_rechtspersoon_bc = BC.Business_contact_nr

/* Namen bij SBT_id's -- Halen uit employee tabel */
LEFT JOIN MI_SAS_AA_MB_C_MB.Siebel_Employee_NEW SBT
ON SBT.SBT_ID = A.Sbt_id_mdw_eigenaar

/* Aantal contactpersonen en medewerkers */
LEFT JOIN
( SELECT siebel_activiteit_id, COUNT(DISTINCT party_id_contactpersoon) AS Aantal_CN FROM mi_vm_ldm.aActiviteit_Contactpersoon_cb GROUP BY 1 ) CN
ON CN.siebel_activiteit_id = A.siebel_activiteit_id

LEFT JOIN
( SELECT siebel_activiteit_id, COUNT(DISTINCT party_id_mdw) AS Aantal_MDW FROM mi_vm_ldm.aActiviteit_Medewerker_cb GROUP BY 1 ) MDW
ON MDW.siebel_activiteit_id = A.siebel_activiteit_id
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW COLUMN (Klant_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW COLUMN (Business_contact_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW COLUMN (Klant_nr, Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW COLUMN (Klant_nr, Maand_nr, Client_level);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW COLUMN (Business_contact_nr, Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW COLUMN (Business_contact_nr, Maand_nr, Client_level);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW COLUMN (Klant_nr, Maand_nr, Status, Activiteit_type, Sub_type, Product_groep, Contact_methode, Vertrouwelijk_ind, Siebel_activiteit_id, Client_level );
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW COLUMN (Sbt_id_mdw_eigenaar, Naam_mdw_eigenaar, Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW COLUMN (Activiteit_type, maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW COLUMN (Datum_start, maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW COLUMN (Sub_type, Activiteit_type, Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW COLUMN (Contact_methode, Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW COLUMN (Product_groep, Maand_nr, Klant_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW COLUMN (Status, Maand_nr, Klant_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW COLUMN (Contact_methode, Datum_start);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW COLUMN (Activiteit_type,Datum_start, Maand_nr, Klant_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW COLUMN (Contact_methode);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW COLUMN (Contact_methode,Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW COLUMN (Klant_nr,Activiteit_type,Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW COLUMN (Activiteit_type);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW COLUMN (Activiteit_type,Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW COLUMN (Klant_nr,Status,Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW COLUMN (Product_groep);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW COLUMN (Product_groep, Klant_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW COLUMN (Product_groep, Klant_nr, Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW COLUMN (Onderwerp, Klant_nr, Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW COLUMN (Onderwerp);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW COLUMN (Datum_eind,Datum_start, Maand_nr, Klant_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW COLUMN (Datum_verval,Datum_start, Maand_nr, Klant_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW COLUMN (Siebel_activiteit_id);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW COLUMN (Siebel_activiteit_id, Klant_nr, Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW COLUMN (Siebel_verkoopkans_id);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW COLUMN (Siebel_lead_id);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW COLUMN (Siebel_revisie_id);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW COLUMN (Siebel_service_request_id);


.IF ERRORCODE <> 0 THEN .GOTO EOP


/* ----------------------------------------------------------------------------------------------------

Siebel_Activiteit_TB_revisies

------------------------------------------------------------------------------------------------------  */

CREATE TABLE MI_SAS_AA_MB_C_MB.Siebel_Activiteit_TB_revisies_NEW
      (
       Klant_nr DECIMAL(12,0),
       Maand_nr INTEGER,
       Datum_gegevens DATE FORMAT 'yyyy-mm-dd',
       Business_contact_nr DECIMAL(12,0),
       Status VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS('Done', 'Unscheduled', 'Cancelled', 'In Progress', 'Closed', 'Wacht op klant', 'New', 'Toegewezen aan derden', 'Scheduled', 'Expired' ),
       Activiteit_type VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS('Task', 'Appointment', 'Contacts'),
       Sub_type VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       Product_groep VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       Onderwerp VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       Korte_omschrijving VARCHAR(250) CHARACTER SET UNICODE NOT CASESPECIFIC,
       Contact_methode VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       Vertrouwelijk_ind BYTEINT COMPRESS (0 ,1 ),
       Datum_start DATE FORMAT 'yyyy-mm-dd',                         /*Datum contact*/
       Maand_nr_start INTEGER,
       Datum_verval DATE FORMAT 'yyyy-mm-dd',                     /*Een activiteit dient voor deze datum afgehandeld te zijn. Deze datum is dus de geplande eind datum, zelf in te vullen door medewerker */
       Maand_nr_verval INTEGER,
       Datum_eind DATE FORMAT 'yyyy-mm-dd',                         /*Dit is de datum waarop de activiteit gesloten wordt. Bij het aanmaken van een activiteit wordt deze gelijk gezet met de Vervaldatum. Maar als de activiteit gesloten wordt dan wordt deze datum bijgewerkt naar de datum van de betreffende dag.*/
       Maand_nr_eind INTEGER,
       Siebel_verkoopkans_id VARCHAR(15) CHARACTER SET LATIN NOT CASESPECIFIC,                     /*Link naar afhankelijke verkoopkans, alleen gevuld als er een link is tussen een activiteit en verkoopkans */
       Sbt_id_mdw_eigenaar VARCHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       Naam_mdw_eigenaar VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       Gespreksrapport_id VARCHAR(15) CHARACTER SET LATIN NOT CASESPECIFIC,
       Datum_aangemaakt DATE FORMAT 'yyyy-mm-dd',
       Maand_nr_aangemaakt INTEGER,
       Aantal_contactpersonen INTEGER COMPRESS (NULL, 0),
       Aantal_medewerkers INTEGER COMPRESS (NULL, 0),
       Siebel_activiteit_id VARCHAR(15) CHARACTER SET LATIN NOT CASESPECIFIC NOT NULL,
       Client_level CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS ('BC','CC','CE','CG', 'XR'),
       Datum_bijgewerkt DATE FORMAT 'yyyy-mm-dd',
       Sbt_id_mdw_bijgewerkt VARCHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       Naam_mdw_bijgewerkt VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       TB_revisie_actueel_ind BYTEINT,
       Sdat DATE FORMAT 'yyyy-mm-dd' NOT NULL,
       Edat DATE FORMAT 'yyyy-mm-dd'
      )
UNIQUE PRIMARY INDEX (Siebel_activiteit_id);

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

/* Maandnummer en datum_gegevens toevoegen aan tabel */
  LEFT JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW B
    ON 1 = 1

/* Toevoegen Klant en BC nummer  */
  JOIN Mi_temp.Mia_alle_bcs BC
    ON A.party_id_rechtspersoon_bc = BC.Business_contact_nr

/* Namen bij SBT_id's -- Halen uit employee tabel */
  LEFT JOIN MI_SAS_AA_MB_C_MB.Siebel_Employee_NEW SBT_EIG
    ON SBT_EIG.SBT_ID = A.Sbt_id_mdw_eigenaar

/* Aantal contactpersonen en medewerkers */
  LEFT OUTER JOIN (SELECT Siebel_activiteit_id, COUNT(DISTINCT Party_id_contactpersoon) AS Aantal_CN
                     FROM Mi_vm_ldm.aActiviteit_Contactpersoon_cb
                    GROUP BY 1) CN
    ON CN.siebel_activiteit_id = A.siebel_activiteit_id

  LEFT OUTER JOIN (SELECT Siebel_activiteit_id, COUNT(DISTINCT Party_id_mdw) AS Aantal_MDW
                     FROM Mi_vm_ldm.aActiviteit_Medewerker_cb
                    GROUP BY 1) MDW
    ON MDW.siebel_activiteit_id = A.siebel_activiteit_id

/* Namen bij SBT_id's -- Halen uit employee tabel */
  LEFT JOIN MI_SAS_AA_MB_C_MB.Siebel_Employee_NEW SBT_BIJ
    ON SBT_BIJ.SBT_ID = A.Sbt_id_mdw_bijgewerkt_door

 WHERE A.Onderwerp = 'Revision / maintenance'
   AND A.Productgroep = 'Betalen & Contant geld'
   AND A.Activiteit_type = 'Task'
   AND A.Korte_omschrijving = 'TB revisie'
   AND A.Status NE 'Cancelled'
   AND A.Sdat >=  DATE '2017-09-02';

.IF ERRORCODE <> 0 THEN .GOTO EOP


/* ----------------------------------------------------------------------------------------------------

Siebel_Contactpersoon

------------------------------------------------------------------------------------------------------  */

CREATE TABLE MI_SAS_AA_MB_C_MB.Siebel_Contactpersoon_NEW
     (

            siebel_contactpersoon_id        VARCHAR(15)  CHARACTER SET LATIN NOT CASESPECIFIC NOT NULL,
            achternaam                      VARCHAR(50)  CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
            tussenvoegsel                   VARCHAR(30)  CHARACTER SET LATIN NOT CASESPECIFIC,
            achtervoegsel                   VARCHAR(15)  CHARACTER SET LATIN NOT CASESPECIFIC,
            contactpersoon_titel            VARCHAR(50)  CHARACTER SET LATIN NOT CASESPECIFIC,
            initialen                       VARCHAR(50)  CHARACTER SET LATIN NOT CASESPECIFIC,
            voornaam                        VARCHAR(50)  CHARACTER SET LATIN NOT CASESPECIFIC,

            adres                           VARCHAR(200) CHARACTER SET LATIN NOT CASESPECIFIC,
            postcode                        VARCHAR(30)  CHARACTER SET LATIN NOT CASESPECIFIC,
            plaats                          VARCHAR(50)  CHARACTER SET LATIN NOT CASESPECIFIC,
            telefoonnummer                  VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC,
            land                            VARCHAR(30)  CHARACTER SET LATIN NOT CASESPECIFIC,
            email                           VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC,
            email_net                        VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC,
            email_bruikbaar                 BYTEINT,

            contactpersoon_onderdeel           VARCHAR(30)  CHARACTER SET LATIN NOT CASESPECIFIC,
            contactpersoon_functietitel     VARCHAR(75)  CHARACTER SET LATIN NOT CASESPECIFIC,
            actief_ind                      SMALLINT,
            academische_titel               VARCHAR(30)  CHARACTER SET LATIN NOT CASESPECIFIC,
            niet_bellen_ind                 BYTEINT,
            niet_mailen_ind                 BYTEINT,
            geen_marktonderzoek_ind         BYTEINT,
            geen_events_ind                 BYTEINT,

            primair_contact_persoon_ind     BYTEINT,

            Klant_nr                        INTEGER,
            Maand_nr                        INTEGER,
            Datum_gegevens                  DATE FORMAT  'yyyy-mm-dd',
            Business_contact_nr             DECIMAL(12,0),
            client_level                    CHAR(2)      CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS ('CE','CC','BC','CG'),
            Sdat                            DATE FORMAT  'yyyy-mm-dd' NOT NULL,
            Edat                            DATE FORMAT  'yyyy-mm-dd'

)
PRIMARY INDEX (siebel_contactpersoon_id);

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

/*maandnummer toevoegen aan tabel*/
LEFT JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW B
ON 1=1

/* Toevoegen Klant en BC nummer en ClientLevel */
LEFT JOIN (
    /* Voor elke contact persoon kijken op welk niveau die is vastgelegd en vervolgens 'oprollen' naar klant niveau */
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

-- van ce -> BC
LEFT JOIN mi_vm_ldm.aparty_party_relatie B2
ON B1.ce_contactpersoon = B2.gerelateerd_party_id
AND B2.gerelateerd_party_sleutel_type = 'CE'
AND B2.party_sleutel_type = 'BC'
AND B2.party_relatie_type_code = 'CBCTCE'

-- van CG -> CC
LEFT JOIN mi_vm_ldm.aparty_party_relatie B3
ON B1.cg_contactpersoon = B3.gerelateerd_party_id
AND B3.gerelateerd_party_sleutel_type = 'CG'
AND B3.party_sleutel_type = 'CC'
AND B3.party_relatie_type_code = 'CCTCG'

-- van CC -> Leidend BC
LEFT JOIN mi_vm_ldm.aparty_party_relatie B4
ON coalesce(B1.cc_contactpersoon , B3.party_id ) = B4.gerelateerd_party_id
AND B4.gerelateerd_party_sleutel_type = 'CC'
AND B4.party_sleutel_type = 'BC'
AND B4.party_relatie_type_code = 'CBCTCC'
AND B4.party_deelnemer_rol =1

-- van (leidend) BC -> CC
LEFT JOIN mi_vm_ldm.aparty_party_relatie BX
ON coalesce( B1.bc_contactpersoon , B2.party_id , B4.party_id ) = BX.party_id
AND BX.party_sleutel_type = 'BC'
AND BX.gerelateerd_party_sleutel_type = 'CC'
AND BX.party_relatie_type_code = 'CBCTCC'

WHERE a.client_levelx not in ( 'XR' , 'XX' )
  AND klant_nr is not NULL;

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

UPDATE MI_SAS_AA_MB_C_MB.Siebel_Contactpersoon_NEW
   SET email_net                                                      = mi_temp.crm_email_updates.email_netst
 WHERE MI_SAS_AA_MB_C_MB.Siebel_Contactpersoon_NEW.siebel_contactpersoon_id = mi_temp.crm_email_updates.siebel_contactpersoon_id
   AND MI_SAS_AA_MB_C_MB.Siebel_Contactpersoon_NEW.email_net                = mi_temp.crm_email_updates.email_net;

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* ONBRUIKBARE EMAIL ADRESSEN UITSLUITEN */

UPDATE MI_SAS_AA_MB_C_MB.Siebel_Contactpersoon_NEW
   SET email_bruikbaar =
       CASE
                WHEN LENGTH(Email_net) < 9      THEN 0
                WHEN Email_net NOT LIKE '%@%.%' THEN 0
                WHEN Email_net LIKE '%xx@xx%.%' THEN 0
                WHEN Email_net LIKE '%x@x%.%'   THEN 0
                WHEN Email_net LIKE '%@xx%.%' AND Email_net NOT LIKE '%xxi%' AND Email_net NOT LIKE '%xxl%' AND Email_net NOT LIKE '%xxs%'  THEN 0
                WHEN Email_net LIKE '%xx@%.%'   THEN 0
                WHEN Email_net LIKE '%@nvt%.%'  THEN 0
                WHEN Email_net LIKE '%nvt@%.%'  THEN 0
                WHEN Email_net LIKE 'geen@%.%'  THEN 0
                WHEN Email_net LIKE '%@niet.%'  THEN 0
                WHEN Email_net LIKE '%@%.%'     THEN 1
                ELSE email_bruikbaar
            END;

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* ONBRUIKBARE ABNAMRO EMAIL ADRESSEN UITSLUITEN */
UPDATE MI_SAS_AA_MB_C_MB.Siebel_Contactpersoon_NEW
   SET email_bruikbaar =
       CASE
                WHEN Email_net like'%@%abnamro%'   THEN 0
                WHEN Email_net like'%@%abna%.com%' THEN 0
                WHEN Email_net like'%@nl%abn%'     THEN 0
                WHEN Email_net like'%@abn.%'       THEN 0
                WHEN Email_net like'%@%abn %'      THEN 0
            ELSE email_bruikbaar
            END
WHERE email_bruikbaar = 1
  AND email_net like '%@%abn%' ;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Contactpersoon_NEW COLUMN (Klant_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Contactpersoon_NEW COLUMN (Business_contact_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Contactpersoon_NEW COLUMN (Klant_nr, Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Contactpersoon_NEW COLUMN (Klant_nr, Maand_nr, client_level);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Contactpersoon_NEW COLUMN (Business_contact_nr, Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Contactpersoon_NEW COLUMN (Business_contact_nr, Maand_nr, client_level);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Contactpersoon_NEW COLUMN (siebel_contactpersoon_id);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Contactpersoon_NEW COLUMN (siebel_contactpersoon_id, Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Contactpersoon_NEW COLUMN (siebel_contactpersoon_id, Klant_nr, Maand_nr);

.IF ERRORCODE <> 0 THEN .GOTO EOP



/* ----------------------------------------------------------------------------------------------------

Siebel_Verkoopkans

------------------------------------------------------------------------------------------------------  */

CREATE TABLE MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_NEW
(
Klant_nr INTEGER,
Maand_nr INTEGER,
Datum_gegevens DATE FORMAT 'YYYY-MM-DD',
Business_contact_nr DECIMAL (12,0),
Siebel_verkoopkans_id VARCHAR(15) CHARACTER SET LATIN NOT CASESPECIFIC NOT NULL,
Naam_verkoopkans VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC,
Selling_type VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
Status VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
Siebel_verkoopkans_deal_id VARCHAR(15) CHARACTER SET LATIN NOT CASESPECIFIC,
Soort VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS ('Opportunities', 'Deal', NULL),
Productgroep VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
Campaign_code_primary VARCHAR(15) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
Herkomst VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
Deal_captain_mdw_sbt_id VARCHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
Naam_deal_captain_mdw VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
Sbt_id_mdw_aangemaakt_door VARCHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
Naam_mdw_aangemaakt_door VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
Sbt_id_mdw_bijgewerkt_door VARCHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
Naam_mdw_bijgewerkt_door VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
Vertrouwelijk_ind BYTEINT COMPRESS (NULL, 1,0),
Aantal_producten INTEGER COMPRESS (NULL,0),
Aantal_succesvol INTEGER COMPRESS (NULL,0),
Aantal_niet_succesvol INTEGER COMPRESS (NULL,0),
Aantal_in_behandeling INTEGER COMPRESS (NULL,0),
Aantal_Nieuw INTEGER COMPRESS (NULL,0),
Datum_aangemaakt DATE FORMAT 'YYYY-MM-DD',
Datum_start DATE FORMAT 'YYYY-MM-DD',
Datum_afgehandeld DATE FORMAT 'YYYY-MM-DD',
Datum_start_baten DATE FORMAT 'YYYY-MM-DD',
Lead_uuid VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
Client_level CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS ('CG','CE','CC','BC'),
Country_primary CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS ('Y','N'),
Contactpersoon_primary_siebel_id VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
Sdat DATE FORMAT 'YYYY-MM-DD',
Edat DATE FORMAT 'YYYY-MM-DD'
)
UNIQUE PRIMARY INDEX (Maand_nr, Siebel_verkoopkans_id)
INDEX (Klant_nr)
INDEX (Business_contact_nr)
INDEX (Maand_nr)
INDEX (Siebel_verkoopkans_id);

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

--KOPPELING MIA_PERIODE
LEFT JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW B
ON 1=1

--KOPPELING PRODUCT
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

-- Koppeling BC to Klant + Uitfilteren records buiten scope van de afdelingstabellen
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

WHERE Soort <> 'deal' or Soort IS NULL --uitsluiten deals, deze staan in een aparte tabel, records zonder ingevulde soort wel selecteren
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_NEW COLUMN (Siebel_verkoopkans_id);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_NEW COLUMN (Siebel_verkoopkans_id, Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_NEW COLUMN (Klant_nr, Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_NEW COLUMN (Klant_nr, Maand_nr, Selling_type);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_NEW COLUMN (Klant_nr, Maand_nr, Selling_type, status);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_NEW COLUMN (Klant_nr, Maand_nr, status);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_NEW COLUMN (Business_contact_nr, Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_NEW COLUMN (Business_contact_nr, Maand_nr, Selling_type);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_NEW COLUMN (Business_contact_nr, Maand_nr, Selling_type, status);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_NEW COLUMN (Business_contact_nr, Maand_nr, status);

.IF ERRORCODE <> 0 THEN .GOTO EOP


/* ----------------------------------------------------------------------------------------------------

Siebel_Deal

------------------------------------------------------------------------------------------------------  */

CREATE TABLE MI_SAS_AA_MB_C_MB.Siebel_Deal_NEW
(
Klant_nr INTEGER,
Maand_nr INTEGER,
Datum_gegevens DATE FORMAT 'YYYY-MM-DD',
Business_contact_nr DECIMAL (12,0),
Siebel_deal_id VARCHAR(15) CHARACTER SET LATIN NOT CASESPECIFIC NOT NULL,
Naam_verkoopkans VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC,
Selling_type VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
Status VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
Soort VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS ('Opportunities', 'Deal', NULL),
Productgroep VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
Campaign_code_primary VARCHAR(15) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
Herkomst VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
Deal_captain_mdw_sbt_id VARCHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
Naam_deal_captain_mdw VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
Sbt_id_mdw_aangemaakt_door VARCHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
Naam_mdw_aangemaakt_door VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
Sbt_id_mdw_bijgewerkt_door VARCHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
Naam_mdw_bijgewerkt_door VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
Vertrouwelijk_ind BYTEINT COMPRESS (NULL, 1,0),
Aantal_producten INTEGER COMPRESS (NULL,0),
Aantal_succesvol INTEGER COMPRESS (NULL,0),
Aantal_niet_succesvol INTEGER COMPRESS (NULL,0),
Aantal_in_behandeling INTEGER COMPRESS (NULL,0),
Aantal_Nieuw INTEGER COMPRESS (NULL,0),
Datum_aangemaakt DATE FORMAT 'YYYY-MM-DD',
Datum_start DATE FORMAT 'YYYY-MM-DD',
Datum_afgehandeld DATE FORMAT 'YYYY-MM-DD',
Datum_start_baten DATE FORMAT 'YYYY-MM-DD',
Lead_uuid VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
Client_level CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS ('CG','CE','CC','BC'),
Country_primary CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS ('Y','N'),
Contactpersoon_primary_siebel_id VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
Sdat DATE FORMAT 'YYYY-MM-DD',
Edat DATE FORMAT 'YYYY-MM-DD'
)
UNIQUE PRIMARY INDEX (Maand_nr, Siebel_deal_id)
INDEX (Klant_nr)
INDEX (Business_contact_nr)
INDEX (Maand_nr)
INDEX (Siebel_deal_id);

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

--KOPPELING MIA_PERIODE
LEFT JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW B
ON 1=1

--KOPPELING PRODUCT
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

-- Koppeling BC to Klant + Uitfilteren records buiten scope van de afdelingstabellen
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

WHERE Soort = 'deal' --alleen deals, verkoopkansen worden in een aparte tabel opgeslagen
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Deal_NEW COLUMN (Siebel_deal_id);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Deal_NEW COLUMN (Siebel_deal_id, Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Deal_NEW COLUMN (Klant_nr, Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Deal_NEW COLUMN (Klant_nr, Maand_nr, Selling_type);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Deal_NEW COLUMN (Klant_nr, Maand_nr, Selling_type, status);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Deal_NEW COLUMN (Klant_nr, Maand_nr, status);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Deal_NEW COLUMN (Business_contact_nr, Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Deal_NEW COLUMN (Business_contact_nr, Maand_nr, Selling_type);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Deal_NEW COLUMN (Business_contact_nr, Maand_nr, Selling_type, status);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Deal_NEW COLUMN (Business_contact_nr, Maand_nr, status);

.IF ERRORCODE <> 0 THEN .GOTO EOP




/* ----------------------------------------------------------------------------------------------------

Siebel_Verkoopkans_Product

- -----------------------------------------------------------------------------------------------------  */

CREATE TABLE MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_Product_NEW (
Klant_nr  INTEGER,
Maand_nr INTEGER,
Datum_gegevens DATE FORMAT 'YYYY-MM-DD',
Business_contact_nr DECIMAL(12,0),
Siebel_verkoopkans_product_id VARCHAR(50),
Siebel_verkoopkans_id VARCHAR(50),
Productnaam  VARCHAR(50),
Productnaam2  VARCHAR(50),
Productgroep  VARCHAR(50),
Pnc_contract_nummer    VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC,
Aantal DECIMAL (18,0),
Omzet  DECIMAL (18,0),
Baten_eenmalig   DECIMAL (18,0),
Baten_terugkerend   DECIMAL (18,0),
Baten_totaal_1ste_12mnd  DECIMAL (18,0),
Baten_totaal_looptijd DECIMAL (18,0),
Status VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC,
Substatus  VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
Reden  VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC,
Slagingskans   DECIMAL(22,7),
Start_baten  DATE FORMAT 'YYYY-MM-DD',
Eind_baten    DATE FORMAT 'YYYY-MM-DD',
Looptijd_mnd  INTEGER,
Vertrouwelijk_ind  INTEGER,
Sbt_id_mdw_eigenaar VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
Naam_mdw_eigenaar   VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
Sbt_id_mdw_aangemaakt_door    VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
Naam_mdw_aangemaakt_door    VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
Datum_aangemaakt     DATE FORMAT 'YYYY-MM-DD',
Datum_laatst_gewijzigd   DATE FORMAT 'YYYY-MM-DD',
Datum_nieuw   DATE FORMAT 'YYYY-MM-DD',
Datum_in_behandeling  DATE FORMAT 'YYYY-MM-DD',
Datum_gesl_succesvol  DATE FORMAT 'YYYY-MM-DD',
Datum_gesl_niet_succesvol DATE FORMAT 'YYYY-MM-DD',
Client_level  CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS ('BC','CE','CC','CG'),
Verkoopkans_product_sdat DATE FORMAT 'YYYY-MM-DD',
Verkoopkans_product_edat DATE FORMAT 'YYYY-MM-DD'
) UNIQUE PRIMARY INDEX ( siebel_verkoopkans_product_id, Maand_nr );

.IF ERRORCODE <> 0 THEN .GOTO EOP

INSERT INTO MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_Product_NEW
SEL
B.klant_nr
,B.Maand_nr
,B.Datum_gegevens
,B.Business_contact_nr
,A.siebel_verkoopkans_product_id
,A.siebel_verkoopkans_id
,C.omschrijving -- Product_naam
,C.part_number -- Productnaam2
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

-- innerjoin met verkoopkanstabel zodat er geen 'zwevende' producten ontstaan
INNER JOIN MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_NEW B
ON A.siebel_verkoopkans_id = B.siebel_verkoopkans_id

-- ophalen van productnaam
LEFT JOIN MI_VM_Ldm.aProduct_cb C
ON A.siebel_product_id = C.siebel_product_id

-- ophalen van productgroepnaam
LEFT JOIN  MI_VM_Ldm.aProductGroep_cb D
ON A.siebel_productgroep_id = D.siebel_productgroep_id

-- ophalen van de naam 'Naam_mdw_eigenaar'
LEFT JOIN MI_SAS_AA_MB_C_MB.Siebel_Employee_NEW E
ON A.sbt_id_mdw_eigenaar = E.SBT_ID AND E.Maand_nr = (SEL maand_nr FROM MI_SAS_AA_MB_C_MB.Mia_periode_NEW)

-- ophalen van de naam 'naam_mdw_aangemaakt_door'
LEFT JOIN MI_SAS_AA_MB_C_MB.Siebel_Employee_NEW F
ON A.sbt_id_mdw_aangemaakt_door = F.SBT_ID AND F.Maand_nr = (SEL maand_nr FROM MI_SAS_AA_MB_C_MB.Mia_periode_NEW)

-- ophalen data eerste keer 'new' status
LEFT JOIN (
    SEL siebel_verkoopkans_product_id,MIN(bijgewerkt_op) as Datum_nieuw
    FROM  MI_VM_LDM.vVerkoopkansproduct_CB
    WHERE status = 'New'
    GROUP BY 1
) AS XD
ON A.siebel_verkoopkans_product_id = XD.siebel_verkoopkans_product_id

-- ophalen data eerste keer 'In behandeling' status
LEFT JOIN (
    SEL siebel_verkoopkans_product_id,MIN(bijgewerkt_op) as Datum_in_behandeling
    FROM  MI_VM_LDM.vVerkoopkansproduct_CB
    WHERE status = 'In Progress'
    GROUP BY 1
) AS XE
ON A.siebel_verkoopkans_product_id = XE.siebel_verkoopkans_product_id

-- ophalen data eerste keer 'succesvol gesloten' status
LEFT JOIN (
    SEL siebel_verkoopkans_product_id,MIN(bijgewerkt_op) as Datum_gesl_succesvol
    FROM  MI_VM_LDM.vVerkoopkansproduct_CB
    WHERE status = 'Closed Successfully'
    GROUP BY 1
) AS XF
ON A.siebel_verkoopkans_product_id = XF.siebel_verkoopkans_product_id

-- ophalen data eerste keer 'niet succesvol gesloten' status
LEFT JOIN (
    SEL siebel_verkoopkans_product_id,MIN(bijgewerkt_op) as Datum_gesl_niet_succesvol
    FROM  MI_VM_LDM.vVerkoopkansproduct_CB
    WHERE status = 'Closed Unsuccessfully'
    GROUP BY 1
) AS XG
ON A.siebel_verkoopkans_product_id = XG.siebel_verkoopkans_product_id
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_Product_NEW COLUMN ( Klant_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_Product_NEW COLUMN ( Klant_nr, Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_Product_NEW COLUMN ( Klant_nr, Maand_nr, Siebel_verkoopkans_id);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_Product_NEW COLUMN ( Klant_nr, Maand_nr, Siebel_verkoopkans_id, Productnaam);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_Product_NEW COLUMN ( Klant_nr, Business_contact_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_Product_NEW COLUMN ( Klant_nr, Maand_nr, Business_contact_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_Product_NEW COLUMN ( Klant_nr, Maand_nr, Siebel_verkoopkans_id, Business_contact_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_Product_NEW COLUMN ( Klant_nr, Maand_nr, Siebel_verkoopkans_id, Productnaam, Business_contact_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_Product_NEW COLUMN ( Siebel_verkoopkans_id, Productnaam);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_Product_NEW COLUMN ( Siebel_verkoopkans_id, Productnaam, Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_Product_NEW COLUMN ( Siebel_verkoopkans_id);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_Product_NEW COLUMN ( Productnaam);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_Product_NEW COLUMN ( Productnaam, Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_Product_NEW COLUMN ( Siebel_verkoopkans_id, Productnaam, Business_contact_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_Product_NEW COLUMN ( Siebel_verkoopkans_id, Productnaam, Maand_nr, Business_contact_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_Product_NEW COLUMN ( Siebel_verkoopkans_id, Business_contact_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_Product_NEW COLUMN ( Productnaam, Business_contact_nr, Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_Product_NEW COLUMN ( Productnaam, Maand_nr, Klant_nr);

.IF ERRORCODE <> 0 THEN .GOTO EOP


/* ----------------------------------------------------------------------------------------------------

Siebel_Act_Participants

------------------------------------------------------------------------------------------------------*/

CREATE TABLE MI_SAS_AA_MB_C_MB.Siebel_act_participants_NEW
(
      Siebel_activiteit_id VARCHAR(15) CHARACTER SET LATIN NOT CASESPECIFIC,
      Maand_nr INTEGER,
      Datum_gegevens DATE FORMAT 'YYYY-MM-DD',
      Type_deelnemer VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS ('Medewerker','Contactpersoon'),
      Naam VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC,
      Functie VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
      SBT_ID VARCHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
      Siebel_Contactpersoon_id VARCHAR(15) CHARACTER SET LATIN NOT CASESPECIFIC
      )
UNIQUE PRIMARY INDEX (Siebel_activiteit_id, Maand_nr, SBT_ID, Functie, Siebel_Contactpersoon_id);

.IF ERRORCODE <> 0 THEN .GOTO EOP


-- Deze insert voegt de Werknermers (ABN AMRO) toe die bij de activiteit aanwezig waren:
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

/* uitgangspunt is de eerder aangemaakte activiteitentabel. Hier is eventuele rommel al uitgefilterd*/
FROM MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW A

/* maandnummer toevoegen*/
LEFT JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW   B
ON 1=1

/* dit betreft een koppelingtabel om alle employees aan de activiteit te plakken*/
INNER JOIN mi_vm_ldm.aActiviteit_Medewerker_cb C
ON   A.siebel_activiteit_id = C.siebel_activiteit_id

/* nette tabel met alle medewerkers*/
LEFT JOIN mi_vm_ldm.aACCOUNT_MANAGEMENT D
ON C.sleutel_type_mdw= D.party_sleutel_type
and C.party_id_mdw = D.party_id

INNER JOIN MI_SAS_AA_MB_C_MB.Siebel_Employee_NEW E
ON D.sbt_userid = E.sbt_id
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

-- Deze insert voegt de Contactpersonen (klant) toe die bij de activiteit aanwezig waren:
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

/* uitgangspunt is de eerder aangemaakte activiteitentabel. Hier is eventuele rommel al uitgefilterd*/
FROM MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW A

/* maandnummer toevoegen*/
LEFT JOIN MI_SAS_AA_MB_C_MB.Mia_periode_NEW   B
ON 1=1

/* dit betreft een koppelingtabel om alle contactpersonen aan de activiteit te plakken*/
INNER JOIN mi_vm_ldm.aActiviteit_Contactpersoon_cb C
ON A.siebel_activiteit_id = C.siebel_activiteit_id

/* Tabel met alle contactpersonen */
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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_act_participants_NEW COLUMN (Siebel_activiteit_id);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_act_participants_NEW COLUMN (Siebel_activiteit_id, Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_act_participants_NEW COLUMN (Siebel_activiteit_id, Maand_nr, Type_deelnemer);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_act_participants_NEW COLUMN (Siebel_activiteit_id, Maand_nr, Type_deelnemer, Functie);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_act_participants_NEW COLUMN (Type_deelnemer, Maand_nr, Functie);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_act_participants_NEW COLUMN (Type_deelnemer, Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_act_participants_NEW COLUMN (Type_deelnemer);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_act_participants_NEW COLUMN (Functie);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_act_participants_NEW COLUMN (Maand_nr, Functie);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_act_participants_NEW COLUMN (Type_deelnemer, Functie);

.IF ERRORCODE <> 0 THEN .GOTO EOP

-- UPDATE MI_TEMP.Siebel_Activiteit_NEW
-- Aantal medewerkers en contactpersonen aan de activiteit toevoegen - aggregatie
-- reden voor update: het aantal participants wordt berekend op basis van participantstabel die pas na de activiteitentabel wordt aangemaakt.

UPDATE MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW
FROM
(SELECT Siebel_activiteit_id,
                 SUM(case when type_deelnemer = 'contactpersoon' then 1 else 0 end) as Aantal_contactpersonen,
                 SUM(case when type_deelnemer = 'medewerker' then 1 else 0 end) as Aantal_Medewerkers
                 FROM MI_SAS_AA_MB_C_MB.Siebel_act_participants_NEW
                 GROUP BY 1
) a
SET
Aantal_Contactpersonen = A.Aantal_Contactpersonen ,
Aantal_Medewerkers = A.Aantal_Medewerkers
WHERE MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW.Siebel_activiteit_id = A.Siebel_activiteit_id;

.IF ERRORCODE <> 0 THEN .GOTO EOP



/*************************************************************************************

    BASIS SET tabel Mia_sector

*************************************************************************************/

CREATE TABLE MI_SAS_AA_MB_C_MB.Mia_sector_NEW
      (
       Maand_nr INTEGER,
       Sbi_code VARCHAR(9) CHARACTER SET LATIN NOT CASESPECIFIC,
       Sbi_oms VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       Agic_code VARCHAR(4) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       Agic_oms VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       Sector_code VARCHAR(4) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       Sector_oms VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       Subsector_code CHAR(3) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       Subsector_oms VARCHAR(256) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       Sectorcluster_code INTEGER,
       Sectorcluster_oms VARCHAR(256) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L
      )
UNIQUE PRIMARY INDEX ( Sbi_code );

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS COLUMN (Maand_nr, SBI_CODE) ON MI_SAS_AA_MB_C_MB.Mia_sector_NEW;
COLLECT STATISTICS COLUMN (SBI_CODE) ON MI_SAS_AA_MB_C_MB.Mia_sector_NEW;
COLLECT STATISTICS COLUMN (Maand_nr, agic_code) ON MI_SAS_AA_MB_C_MB.Mia_sector_NEW;
COLLECT STATISTICS COLUMN (Maand_nr, sector_code) ON MI_SAS_AA_MB_C_MB.Mia_sector_NEW;
COLLECT STATISTICS COLUMN (Maand_nr, subsector_code) ON MI_SAS_AA_MB_C_MB.Mia_sector_NEW;

.IF ERRORCODE <> 0 THEN .GOTO EOP

/******************************************************************************************************** Patrick de Hoon - 17072018
MI_TEMP.GEO_VARIABELEN
De samengestelde brontabel voor geo_variabelen & SME specifieke variabelen. Onder geo_variabelen verstaan wij land_id, gemeente/stad
naam & regio's. Voor SME specificeren wij hierin welke regio en marktgebied van toepassing is.

Om verschillen tussen de bronnen weg te halen en 1 plaatsnaam/gemeente per postcode terug te geven, wordt de tabel ook nog geupdate
met de configuratie tabel.
***********************************************************************************************************************************/

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

update mi_temp.geo_variabelen
set Geo_niveau3 = mi_cmb.geo_variabelen_conf.geo_niveau3_adj
where Geo_niveau3 = mi_cmb.geo_variabelen_conf.geo_niveau3_ori;
.IF ERRORCODE <> 0 THEN .GOTO EOP

update mi_temp.geo_variabelen
set Geo_niveau3 = mi_cmb.geo_variabelen_conf.geo_niveau3_adj
where postcode = mi_cmb.geo_variabelen_conf.postcode_ori;
.IF ERRORCODE <> 0 THEN .GOTO EOP

/*-----------------------------------------
    Mia_week
-----------------------------------------*/

COLLECT STATISTICS COLUMN (BUSINESS_CONTACT_NR ,MAAND_NR) ON Mi_temp.Mia_alle_bcs;
COLLECT STATISTICS COLUMN (CBC_OID) ON Mi_temp.geo_variabelen;
COLLECT STATISTICS COLUMN (MAAND_NR) ON Mi_temp.Mia_alle_bcs;
COLLECT STATISTICS COLUMN (BO_BL) ON MI_SAS_AA_MB_C_MB.MIA_organisatie;
COLLECT STATISTICS COLUMN (ORG_NIVEAU3_BO_NR) ON MI_SAS_AA_MB_C_MB.MIA_organisatie;
COLLECT STATISTICS USING MAXVALUELENGTH 60 COLUMN (ACTIVITEIT_TYPE ,SUB_TYPE) ON MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW;
COLLECT STATISTICS COLUMN (SUB_TYPE) ON MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW;
COLLECT STATISTICS COLUMN (DATUM_START) ON MI_SAS_AA_MB_C_MB.Siebel_Activiteit_NEW;
COLLECT STATISTICS COLUMN (MAAND_NR) ON Mi_temp.Mia_klant_info;

.IF ERRORCODE <> 0 THEN .GOTO EOP



CREATE TABLE Mi_temp.Mia_week
      (
       Klant_nr INTEGER,
       Maand_nr INTEGER,
       Datum_gegevens DATE FORMAT 'YYYY-MM-DD',
       Business_contact_nr DECIMAL(12,0),
       Verkorte_naam CHAR(24) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS NULL COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       Klant_ind BYTEINT,
       Klantstatus CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
       Business_line VARCHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
       Segment VARCHAR (10) CHARACTER SET LATIN NOT CASESPECIFIC,
       Subsegment VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC,
       Clientgroep CHAR(4) CHARACTER SET LATIN NOT CASESPECIFIC,
       Clientgroep_theoretisch CHAR(4) CHARACTER SET LATIN NOT CASESPECIFIC,
       Starter_ind BYTEINT,
       VenS_ind BYTEINT,
       ZZP_ind BYTEINT,
       Internationaal_segment VARCHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
       Bo_nr INTEGER,
       Bo_naam VARCHAR(256) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS NULL COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       CCA INTEGER,
       Relatiemanager CHAR(48) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS NULL COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       Org_niveau5 VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING TD_SYSFNLIB.LZCOMP_L DECOMPRESS USING TD_SYSFNLIB.LZDECOMP_L,
       Org_niveau5_bo_nr INTEGER COMPRESS (NULL,-101,103),
       Org_niveau4 VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING TD_SYSFNLIB.LZCOMP_L DECOMPRESS USING TD_SYSFNLIB.LZDECOMP_L,
       Org_niveau4_bo_nr INTEGER COMPRESS (NULL,-101,103),
       Org_niveau3 VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING TD_SYSFNLIB.LZCOMP_L DECOMPRESS USING TD_SYSFNLIB.LZDECOMP_L,
       Org_niveau3_bo_nr INTEGER COMPRESS (NULL,-101,103),
       Org_niveau2 VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING TD_SYSFNLIB.LZCOMP_L DECOMPRESS USING TD_SYSFNLIB.LZDECOMP_L,
       Org_niveau2_bo_nr INTEGER COMPRESS (NULL,-101,103),
       Org_niveau1 VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING TD_SYSFNLIB.LZCOMP_L DECOMPRESS USING TD_SYSFNLIB.LZDECOMP_L,
       Org_niveau1_bo_nr INTEGER COMPRESS (NULL,-101,103),
       Org_niveau0 VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING TD_SYSFNLIB.LZCOMP_L DECOMPRESS USING TD_SYSFNLIB.LZDECOMP_L,
       Org_niveau0_bo_nr INTEGER COMPRESS (NULL,-101,103),
       Bank_herkomst VARCHAR(4) CHARACTER SET LATIN NOT CASESPECIFIC,
       Kvk_nr CHAR(13) CHARACTER SET LATIN NOT CASESPECIFIC,
       Kvk_branche_nr CHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
       Kvk_branche_oms CHAR(40) CHARACTER SET LATIN NOT CASESPECIFIC,
       Kvk_klasse_werknemers VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
       Sbi_code CHAR(6) CHARACTER SET LATIN NOT CASESPECIFIC,
       Sbi_oms VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS NULL COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       Sbi_bron VARCHAR(9) CHARACTER SET UNICODE NOT CASESPECIFIC,
       AGIC_oms VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS NULL COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       Sectorcluster VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS NULL COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       CMB_sector VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS NULL COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       Subsector_code CHAR(3) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       Subsector_oms VARCHAR(256) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       Baten DECIMAL(18,0),
       Aantal_jaren_bestaan INTEGER,
       Aantal_jaren_klant INTEGER,
       Aantal_maanden_klant INTEGER,
       Omzet_inkomend DECIMAL(15,0),
       Bedrijfsomzet DECIMAL(18,0),
       Bedrijfsomzet_RM_ind BYTEINT,
       Bedrijfsomzet_jaar INTEGER,
       Omzetklasse_id SMALLINT,
       Omzetklasse_oms VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
       SoW VARCHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
       Primair_categorie VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS NULL COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       Primair_ind BYTEINT,
       Businessvolume DECIMAL(18,0),
       Creditvolume DECIMAL(18,0),
       Debetvolume DECIMAL(18,0),
       Cross_sell INTEGER,
       Cs_betalen BYTEINT,
       Cs_creditgelden BYTEINT,
       Cs_kredieten BYTEINT,
       Cs_verzekeren_ondernemer BYTEINT,
       Cs_creditcard BYTEINT,
       Cs_employee_benefits BYTEINT,
       Cs_beleggen BYTEINT,
       Cs_lease BYTEINT,
       Cs_ifn BYTEINT,
       Cs_treasury BYTEINT,
       Cs_digitaal_bankieren BYTEINT,
       Cs_pakket_prive BYTEINT,
       Cs_verzekeren_onderneming BYTEINT,
       Aantal_mnd_sinds_productafname INTEGER,
       Startersrekening_ind BYTEINT,
       Starterspakket_ind BYTEINT,
       MKB_pakket_ind BYTEINT,
       VenS_pakket_ind BYTEINT,
       Aantal_complexe_producten SMALLINT,
       Complexe_producten VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS NULL COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       Naw VARCHAR(315) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS NULL COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       Postcode VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS NULL COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       Geo_niveau1 CHAR (2) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS NULL COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       Geo_niveau2 VARCHAR(40) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS NULL COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       Geo_niveau3 VARCHAR(40) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS NULL COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       SME_regio VARCHAR(40) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS NULL COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       SME_marktgebied VARCHAR(40) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS NULL COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       Postretour_adres_ind BYTEINT,
       Telefoon_nr_vast VARCHAR(19) CHARACTER SET LATIN NOT CASESPECIFIC,
       Telefoon_nr_mobiel VARCHAR(19) CHARACTER SET LATIN NOT CASESPECIFIC,
       Contactpersoon CHAR(40) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS NULL COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       Emailadres VARCHAR(75) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS NULL COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       Datum_volgend_contact DATE FORMAT 'YYYYMMDD',
       Datum_laatste_contact_pro_ftf DATE FORMAT 'YYYYMMDD',
       Datum_laatste_contact_ftf DATE FORMAT 'YYYYMMDD',
       Aantal_contact_pro_ftf INTEGER,
       Aantal_contact_ftf INTEGER,
       Aantal_contact_pro_tel INTEGER,
       Aantal_contact_tel INTEGER,
       Faillissement_ind BYTEINT,
       Surseance_ind BYTEINT,
       Bijzonder_beheer_ind BYTEINT,
       CRG SMALLINT,
       GSRI_goedgekeurd VARCHAR(8) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS ('High','Low','Medium'),
       GSRI_Assessment_resultaat VARCHAR(9) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS ('ABOVE PAR','ON PAR','BELOW PAR'),
       Aantal_bcs INTEGER,
       Aantal_bcs_in_scope INTEGER,
       Leidend_business_contact_nr DECIMAL(12,0),
       Leidend_bc_ind BYTEINT,
       Signaal VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS NULL COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       Datum_revisie_TB DATE FORMAT 'YYYY-MM-DD',
       CCA_consultant_TB INTEGER COMPRESS 0
      )
UNIQUE PRIMARY INDEX ( Klant_nr, Maand_nr )
INDEX ( Klant_nr )
INDEX ( Maand_nr );

.IF ERRORCODE <> 0 THEN .GOTO EOP


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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.Mia_week COLUMN ( Klant_nr, Maand_nr );
COLLECT STATISTICS Mi_temp.Mia_week COLUMN ( Klant_ind, Klantstatus );
COLLECT STATISTICS Mi_temp.Mia_week COLUMN ( Klant_ind );
COLLECT STATISTICS Mi_temp.Mia_week COLUMN ( Klantstatus );

.IF ERRORCODE <> 0 THEN .GOTO EOP

/*************************************************************************************

    BEGIN TIJDELIJKE WORKAROUND

*************************************************************************************/

CREATE TABLE Mi_temp.Mia_week_UPDATE
      (
       Klant_nr INTEGER,
       Maand_nr INTEGER,
       Team_oid INTEGER,
       Org_niveau3 VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING TD_SYSFNLIB.LZCOMP_L DECOMPRESS USING TD_SYSFNLIB.LZDECOMP_L ,
       Org_niveau3_bo_nr INTEGER COMPRESS (103 ,-101 ),
       Org_niveau2 VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING TD_SYSFNLIB.LZCOMP_L DECOMPRESS USING TD_SYSFNLIB.LZDECOMP_L ,
       Org_niveau2_bo_nr INTEGER COMPRESS (103 ,-101 ),
       Org_niveau1 VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING TD_SYSFNLIB.LZCOMP_L DECOMPRESS USING TD_SYSFNLIB.LZDECOMP_L ,
       Org_niveau1_bo_nr INTEGER COMPRESS (103 ,-101 ),
       Org_niveau0 VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING TD_SYSFNLIB.LZCOMP_L DECOMPRESS USING TD_SYSFNLIB.LZDECOMP_L ,
       Org_niveau0_bo_nr INTEGER COMPRESS (103 ,-101 )
      )
UNIQUE PRIMARY INDEX ( Klant_nr ,Maand_nr )
INDEX ( Klant_nr )
INDEX ( Maand_nr );

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP



/* DAADWERKELIJK UPDATEN Mi_temp.Mia_week */

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.Mia_week COLUMN ( Klant_nr, Maand_nr );
COLLECT STATISTICS Mi_temp.Mia_week COLUMN ( Klant_ind, Klantstatus );
COLLECT STATISTICS Mi_temp.Mia_week COLUMN ( Klant_ind );
COLLECT STATISTICS Mi_temp.Mia_week COLUMN ( Klantstatus );

.IF ERRORCODE <> 0 THEN .GOTO EOP


/*************************************************************************************

    EINDE TIJDELIJKE WORKAROUND

*************************************************************************************/



CREATE TABLE Mi_temp.Mia_klanten
      (
       Klant_nr INTEGER,
       Maand_nr INTEGER,
       Bank_herkomst VARCHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
       Business_line VARCHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
       Segment VARCHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
       Subsegment VARCHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
       Benchmark_ind BYTEINT,
       Uitscoor_ind BYTEINT,
       Bedrijfstak_id VARCHAR(6),
       Omzetklasse_id SMALLINT,
       Dimensie3_id VARCHAR(40) CHARACTER SET LATIN NOT CASESPECIFIC,
       Dimensie4_id INTEGER,
       Dimensie5_id INTEGER
      )
UNIQUE PRIMARY INDEX ( Klant_nr, Maand_nr )
INDEX ( Klant_nr )
INDEX ( Maand_nr );

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.Mia_week COLUMN (MAAND_NR , SEGMENT ,KLANT_IND ,KLANTSTATUS);
COLLECT STATISTICS Mi_temp.Mia_week COLUMN (MAAND_NR , KLANT_IND ,KLANTSTATUS);
COLLECT STATISTICS Mi_temp.Mia_week COLUMN (KLANT_NR ,KLANT_IND);
COLLECT STATISTICS Mi_temp.Mia_week COLUMN (SEGMENT);
COLLECT STATISTICS Mi_temp.Mia_week COLUMN (KLANT_IND ,ZZP_IND   ,KLANTSTATUS);
COLLECT STATISTICS Mi_temp.Mia_week COLUMN CREDITVOLUME;
COLLECT STATISTICS Mi_temp.Mia_week COLUMN (KLANT_IND,CS_LEASE ,KLANTSTATUS);
COLLECT STATISTICS Mi_temp.Mia_week COLUMN AANTAL_JAREN_BESTAAN;
COLLECT STATISTICS Mi_temp.Mia_week COLUMN OMZET_INKOMEND;
COLLECT STATISTICS Mi_temp.Mia_week;
COLLECT STATISTICS Mi_temp.Mia_klanten COLUMN (MAAND_NR,BUSINESS_LINE,SUBSEGMENT,BEDRIJFSTAK_ID,OMZETKLASSE_ID,DIMENSIE4_ID,DIMENSIE5_ID);
COLLECT STATISTICS COLUMN (KLANT_NR) ON Mi_temp.Mia_klanten;
COLLECT STATISTICS COLUMN (KLANT_NR ,MAAND_NR) ON Mi_temp.Mia_klanten;
COLLECT STATISTICS COLUMN (BUSINESS_LINE) ON Mi_temp.Mia_klanten;
COLLECT STATISTICS COLUMN (BUSINESS_LINE) ON Mi_temp.Mia_week;
COLLECT STATISTICS COLUMN (CCA) ON Mi_temp.Mia_week;
COLLECT STATISTICS COLUMN (ORG_NIVEAU3) ON Mi_temp.Mia_week;
COLLECT STATISTICS COLUMN (ORG_NIVEAU2) ON Mi_temp.Mia_week;
COLLECT STATISTICS COLUMN (ORG_NIVEAU1) ON Mi_temp.Mia_week;
COLLECT STATISTICS COLUMN (ORG_NIVEAU0) ON Mi_temp.Mia_week;


.IF ERRORCODE <> 0 THEN .GOTO EOP



/*************************************************************************************

    BASIS SET tabel Mia_hist

*************************************************************************************/

/* maak columns (zeker primary index columns) zo mogelijk NOT NULL
  COMPRESS zo veel mogelijk */

/* kopie */
CREATE TABLE MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW AS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist WITH DATA
UNIQUE PRIMARY INDEX (Business_contact_nr, Klant_nr, Maand_nr)
PARTITION BY (
               RANGE_N(maand_nr  BETWEEN
                      201001  AND 201012  EACH 1,
                      201101  AND 201112  EACH 1,
                      201201  AND 201212  EACH 1,
                      201301  AND 201312  EACH 1,
                      201401  AND 201412  EACH 1,
                      201501  AND 201512  EACH 1,
                      201601  AND 201612  EACH 1,
                      201701  AND 201712  EACH 1,
                      201801  AND 201812  EACH 1,
                      201901  AND 201912  EACH 1,
                      202001  AND 202012  EACH 1,
                      NO RANGE,
                      UNKNOWN))
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW COLUMN (PARTITION);

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* WEEKCIJFERS VERWIJDEREN INDIEN MAAND REEDS AANWEZIG VAN VORIGE WEEK */
DELETE FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW
WHERE maand_nr = (SEL Maand_nr FROM Mi_temp.Mia_week GROUP BY 1)
;
.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW COLUMN (PARTITION);

.IF ERRORCODE <> 0 THEN .GOTO EOP


/* WEEKCIJFERS TOEVOEGEN */

INSERT INTO MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW
SELECT *
FROM Mi_temp.Mia_week
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW COLUMN (PARTITION);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW COLUMN (Klant_nr, Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW COLUMN (Klant_nr, Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW COLUMN (Klant_nr, Maand_nr, Business_contact_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW COLUMN CCA;
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW COLUMN Business_contact_nr;
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW COLUMN Bedrijfsomzet;
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW COLUMN Kvk_nr;
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW COLUMN Contactpersoon;
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW COLUMN Faillissement_ind;
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW COLUMN Naw;
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW COLUMN Klant_ind;
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW COLUMN Klantstatus;
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW COLUMN (MAAND_NR , SEGMENT ,KLANT_IND ,KLANTSTATUS);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW COLUMN (MAAND_NR , KLANT_IND ,KLANTSTATUS);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW COLUMN (KLANT_NR ,KLANT_IND);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW COLUMN (MAAND_NR , KLANT_IND);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW COLUMN KLANT_NR;
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW COLUMN (KLANT_IND ,KLANTSTATUS ,BUSINESS_LINE ,SEGMENT);

COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW COLUMN (MAAND_NR);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW COLUMN (BUSINESS_LINE);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW COLUMN (MAAND_NR, KLANT_IND ,KLANTSTATUS ,SEGMENT);

COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW COLUMN (Maand_nr, Business_line);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW COLUMN (Maand_nr, Segment, Subsegment);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW COLUMN (Maand_nr, CCA );
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW COLUMN (Maand_nr, Omzetklasse_id, Omzetklasse_oms);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW COLUMN SEGMENT;
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW COLUMN (PARTITION ,KLANT_NR ,MAAND_NR);

COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW COLUMN BO_NR;
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW COLUMN (VERKORTE_NAAM ,KVK_NR);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW COLUMN (KLANT_NR);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW COLUMN (MAAND_NR , BO_NR);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW COLUMN CLIENTGROEP;

COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW COLUMN (Org_niveau2);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_NEW COLUMN (Business_line, Segment, Org_niveau1);


.IF ERRORCODE <> 0 THEN .GOTO EOP


/*************************************************************************************

    BASIS SET tabel Mia_klantkoppelingen_hist

*************************************************************************************/

/* kopie */
CREATE TABLE MI_SAS_AA_MB_C_MB.Mia_klantkoppelingen_hist_NEW AS MI_SAS_AA_MB_C_MB.Mia_klantkoppelingen_hist WITH DATA
UNIQUE PRIMARY INDEX ( Klant_nr, Maand_nr ,Business_contact_nr )
PARTITION BY (
               RANGE_N(maand_nr  BETWEEN
                      201001  AND 201012  EACH 1,
                      201101  AND 201112  EACH 1,
                      201201  AND 201212  EACH 1,
                      201301  AND 201312  EACH 1,
                      201401  AND 201412  EACH 1,
                      201501  AND 201512  EACH 1,
                      201601  AND 201612  EACH 1,
                      201701  AND 201712  EACH 1,
                      201801  AND 201812  EACH 1,
                      201901  AND 201912  EACH 1,
                      202001  AND 202012  EACH 1,
                      NO RANGE,
                      UNKNOWN))
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Mia_klantkoppelingen_hist_NEW COLUMN (PARTITION);

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* WEEKCIJFERS VERWIJDEREN INDIEN MAAND REEDS AANWEZIG VAN VORIGE WEEK */
DELETE FROM MI_SAS_AA_MB_C_MB.Mia_klantkoppelingen_hist_NEW
WHERE maand_nr = (SEL Maand_nr FROM Mi_temp.Mia_klantkoppelingen GROUP BY 1)
;
.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Mia_klantkoppelingen_hist_NEW COLUMN (PARTITION);

.IF ERRORCODE <> 0 THEN .GOTO EOP


/* WEEKCIJFERS TOEVOEGEN */

INSERT INTO MI_SAS_AA_MB_C_MB.Mia_klantkoppelingen_hist_NEW
SELECT  Klant_nr
       ,Maand_nr
       ,Business_contact_nr
       ,Koppeling_id_CC
       ,Koppeling_id_CE
FROM Mi_temp.Mia_klantkoppelingen
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Mia_klantkoppelingen_hist_NEW COLUMN (PARTITION);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Mia_klantkoppelingen_hist_NEW COLUMN (Klant_nr, Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Mia_klantkoppelingen_hist_NEW COLUMN Business_contact_nr;
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Mia_klantkoppelingen_hist_NEW COLUMN MAAND_NR;
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Mia_klantkoppelingen_hist_NEW COLUMN (MAAND_NR, BUSINESS_CONTACT_NR);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Mia_klantkoppelingen_hist_NEW COLUMN (MAAND_NR, BUSINESS_CONTACT_NR,Koppeling_id_CC);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Mia_klantkoppelingen_hist_NEW COLUMN (MAAND_NR, BUSINESS_CONTACT_NR,Koppeling_id_CC,Koppeling_id_CE);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Mia_klantkoppelingen_hist_NEW COLUMN (KLANT_NR);

.IF ERRORCODE <> 0 THEN .GOTO EOP

/*************************************************************************************

    BASIS SET tabel Mia_groepkoppelingen_hist

*************************************************************************************/

CREATE TABLE Mi_sas_aa_mb_c_mb.Mia_groepkoppelingen_hist_NEW AS Mi_sas_aa_mb_c_mb.Mia_groepkoppelingen_hist WITH DATA
UNIQUE PRIMARY INDEX ( Groep_nr, Maand_nr, Klant_nr )
PARTITION BY (
               RANGE_N(maand_nr  BETWEEN
                      201001  AND 201012  EACH 1,
                      201101  AND 201112  EACH 1,
                      201201  AND 201212  EACH 1,
                      201301  AND 201312  EACH 1,
                      201401  AND 201412  EACH 1,
                      201501  AND 201512  EACH 1,
                      201601  AND 201612  EACH 1,
                      201701  AND 201712  EACH 1,
                      201801  AND 201812  EACH 1,
                      201901  AND 201912  EACH 1,
                      202001  AND 202012  EACH 1,
                      NO RANGE,
                      UNKNOWN))
INDEX (Groep_nr)
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* WEEKCIJFERS VERWIJDEREN INDIEN MAAND REEDS AANWEZIG VAN VORIGE WEEK */

DELETE FROM Mi_sas_aa_mb_c_mb.Mia_groepkoppelingen_hist_NEW
WHERE maand_nr = (SEL Maand_nr FROM Mi_temp.Mia_groepkoppelingen GROUP BY 1)
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* WEEKCIJFERS TOEVOEGEN */

INSERT INTO Mi_sas_aa_mb_c_mb.Mia_groepkoppelingen_hist_NEW
SELECT * FROM Mi_temp.Mia_groepkoppelingen
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_sas_aa_mb_c_mb.Mia_groepkoppelingen_hist_NEW COLUMN (PARTITION);
COLLECT STATISTICS Mi_sas_aa_mb_c_mb.Mia_groepkoppelingen_hist_NEW COLUMN (Groep_nr, Maand_nr, Klant_nr);

.IF ERRORCODE <> 0 THEN .GOTO EOP




/*************************************************************************************

    Tabel om per maand een chronologische rangorde aan te brengen, oa. voor
    view performance set

    (na MIa Week op te bouwen)

*************************************************************************************/

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr_NEW COLUMN (Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr_NEW COLUMN (Maand_nr_cube_baten);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr_NEW COLUMN (Maand_nr_bet_trx);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr_NEW COLUMN (Maand_nr_beleggen);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr_NEW COLUMN (Maand_nr_kredieten);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr_NEW COLUMN (Maand_nr_part_zak);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr_NEW COLUMN (Maand_nr_Cidar);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr_NEW COLUMN (N_maanden_terug);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr_NEW COLUMN (Maand_nr, N_maanden_terug);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr_NEW COLUMN (Maand_edat);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr_NEW COLUMN (Maand_edat, N_maanden_terug);

.IF ERRORCODE <> 0 THEN .GOTO EOP



/*************************************************************************************

   1B. Opbouw Mia_businesscontacts

*************************************************************************************/

CREATE TABLE MI_SAS_AA_MB_C_MB.Mia_businesscontacts_NEW
      (
       Business_contact_nr DECIMAL(12,0),
       Klant_nr INTEGER,
       Maand_nr INTEGER,
       Datum_gegevens DATE FORMAT 'YYYYMMDD',
       Bc_naam VARCHAR(256) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS NULL COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       Bc_startdatum DATE FORMAT 'YYYYMMDD',
       Bc_clientgroep CHAR(4) CHARACTER SET LATIN NOT CASESPECIFIC,
       Bc_crg BYTEINT,
       Bc_bo_nr INTEGER,
       Bc_bo_naam VARCHAR(256) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS NULL COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       Bc_bo_bu_code CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC,
       Bc_bo_bu_decode VARCHAR(60) CHARACTER SET LATIN NOT CASESPECIFIC,
       Bc_validatieniveau BYTEINT,
       Bc_cca_am INTEGER,
       Bc_cca_rm INTEGER,
       Bc_cca_am_bu_code CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC,
       Bc_cca_am_bu_decode VARCHAR(60) CHARACTER SET LATIN NOT CASESPECIFIC,
       Bc_cca_rm_bu_code CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC,
       Bc_cca_rm_bu_decode VARCHAR(60) CHARACTER SET LATIN NOT CASESPECIFIC,
       Bc_cca_pb INTEGER,
       Bc_relatiecategorie SMALLINT,
       Bc_verschijningsvorm SMALLINT,
       Bc_verschijningsvorm_oms VARCHAR(256) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS NULL COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       Bc_kvk_nr CHAR(12),
       Bc_postcode CHAR(6),
       Bc_sbi_code_bcdb CHAR(6) CHARACTER SET LATIN NOT CASESPECIFIC,
       Bc_sbi_code_kvk CHAR(6) CHARACTER SET LATIN NOT CASESPECIFIC,
       Bc_contracten BYTEINT,
       Bc_klantlevenscyclus VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS ('ACTIVE', 'DECLINED (FOR FUTURE USE)', 'DORMANT (FOR FUTURE USE)', 'FORMER', 'POTENTIAL (FOR FUTURE USE)', 'PROSPECTIVE', 'REJECTED'),
       Leidend_bc_ind BYTEINT,
       Leidend_bc_pb_ind BYTEINT,
       Cc_nr INTEGER,
       Koppeling_id_CC CHAR(15),
       Koppeling_id_CE CHAR(15),
       Koppeling_id_CG CHAR(15),
       Fhh_nr INTEGER,
       Pcnl_nr INTEGER,
       Bc_Lindorff_ind BYTEINT,
       Bc_FRenR_ind BYTEINT,
       Bc_in_nzdb BYTEINT,
       Bc_SEC_US_Person_ind BYTEINT,
       Bc_SEC_US_Person_oms VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS ('Geen SEC US Person','SEC US Person - Counterparties', 'SEC        US Person - U.S. Instituti','Geen SEC US Person - Accredite','Niet gereviewed op SEC US Pers',' Geen SEC US Person - Represent','SEC        US Person'),
       Bc_FATCA_US_Person_ind BYTEINT,
       Bc_FATCA_US_Person_class VARCHAR(46) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS ('Subject to Tax in US', 'P-NFFE', 'IGA_FFI', 'To be determined', 'NFFE', 'E-NFFE', 'Recalcitrant (applicable for Entities as well)', 'US', 'FFI', 'Not Subject to Tax in US'),
       Bc_ringfence VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS ('Alleen Maat / Vennoot (ihkv VVB review)', 'Alleen Swift Key relatie', 'Alleen T24 relatie',
                                                                               'Garantsteller/ov. betrokkene (ikv VVB)', 'Geen nieuwe diensten - zie E-archief', 'Integriteitsgevoelig.',
                                                                               'klant afgewezen, zie klantbeeld', 'klant in faillissement / in surseance', 'Klant Levenscyclus Status Former',
                                                                               'Klantacceptatie niet volledig doorlopen', 'Landenbeleid restrictie afzet producten',
                                                                               'landenbeleid verbod op afzet producten', 'Rechtspersoon zonder actieve producten'),
       Bc_Risico_score VARCHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC,
       BC_Risico_klasse_oms VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
       Bc_WtClas VARCHAR(16) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS ('Non Professional', 'Professional', 'ECP'),
       Bc_AAClas VARCHAR(16) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS ('Non Professional', 'Professional', 'ECP'),
       Bc_Rente_drv VARCHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC,
       Bc_Comm_drv VARCHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC,
       Bc_Valuta_drv VARCHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC,
       Bc_Overig_cms VARCHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
       BC_GSRI_goedgekeurd CHAR(8) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS ('High', 'Medium', 'Low'),
       BC_GSRI_Assessment_resultaat CHAR (10) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS ('ABOVE PAR', 'BELOW PAR'),
       BC_GBC_nr DECIMAL(12,0),
       BC_GBC_Naam VARCHAR(256) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS NULL COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       BC_ULP_nr DECIMAL(12,0),
       BC_ULP_Naam VARCHAR(256) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS NULL COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       BC_CCA_TB INTEGER,
       BC_CCA_TB_NAAM VARCHAR(256) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS NULL COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       BC_CCA_TB_TEAM VARCHAR(256) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS NULL COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
       Trust_complex_nr DECIMAL(12,0),
       Franchise_complex_nr DECIMAL(12,0)
      )
UNIQUE PRIMARY INDEX ( Business_contact_nr, Klant_nr, Maand_nr )
INDEX ( Business_contact_nr )
INDEX ( Klant_nr )
INDEX ( Maand_nr )
INDEX ( Bc_bo_nr );

.IF ERRORCODE <> 0 THEN .GOTO EOP

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
  LEFT OUTER JOIN MI_TEMP.aSegment B
    ON A.Bc_verschijningsvorm = B.Segment_id
   AND B.Segment_type_code = 'APPTYP'
 WHERE A.DB_ind = 0
   AND A.RBS_ind = 0
   AND A.Bc_clientgroep NOT IN ('8001', '9001');


.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Mia_businesscontacts_NEW COLUMN ( Klant_nr, Maand_nr );
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Mia_businesscontacts_NEW COLUMN BC_NAAM;
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Mia_businesscontacts_NEW COLUMN Leidend_bc_ind;
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Mia_businesscontacts_NEW COLUMN Bc_validatieniveau;
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Mia_businesscontacts_NEW COLUMN Bc_clientgroep;
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Mia_businesscontacts_NEW INDEX(Bc_bo_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Mia_businesscontacts_NEW INDEX(Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Mia_businesscontacts_NEW INDEX(Klant_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Mia_businesscontacts_NEW INDEX(Business_contact_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Mia_businesscontacts_NEW INDEX(Business_contact_nr,Klant_nr,Maand_nr);

.IF ERRORCODE <> 0 THEN .GOTO EOP






/*************************************************************************************

    1C Mia_week_PB (afhankelijk van Mia_businesscontacts)

*************************************************************************************/

CREATE TABLE Mi_temp.Mia_week_PB
      (
       Klant_nr INTEGER,
       Maand_nr INTEGER,
       Datum_gegevens DATE FORMAT 'YYYY-MM-DD',
       Business_contact_nr DECIMAL(12,0),
       Verkorte_naam CHAR(24) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING TD_SYSFNLIB.LZCOMP_L DECOMPRESS USING TD_SYSFNLIB.LZDECOMP_L ,
       Klant_ind BYTEINT,
       Klantstatus CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
       Business_line VARCHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
       Segment VARCHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
       Subsegment VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC,
       Clientgroep CHAR(4) CHARACTER SET LATIN NOT CASESPECIFIC,
       Clientgroep_theoretisch CHAR(4) CHARACTER SET LATIN NOT CASESPECIFIC,
       Starter_ind BYTEINT,
       VenS_ind BYTEINT,
       ZZP_ind BYTEINT,
       Internationaal_segment VARCHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
       Bo_nr INTEGER,
       Bo_naam VARCHAR(256) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING TD_SYSFNLIB.LZCOMP_L DECOMPRESS USING TD_SYSFNLIB.LZDECOMP_L ,
       CCA INTEGER,
       Relatiemanager CHAR(48) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING TD_SYSFNLIB.LZCOMP_L DECOMPRESS USING TD_SYSFNLIB.LZDECOMP_L ,
       Org_niveau5 VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING TD_SYSFNLIB.LZCOMP_L DECOMPRESS USING TD_SYSFNLIB.LZDECOMP_L ,
       Org_niveau5_bo_nr INTEGER COMPRESS (103 ,-101 ),
       Org_niveau4 VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING TD_SYSFNLIB.LZCOMP_L DECOMPRESS USING TD_SYSFNLIB.LZDECOMP_L ,
       Org_niveau4_bo_nr INTEGER COMPRESS (103 ,-101 ),
       Org_niveau3 VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING TD_SYSFNLIB.LZCOMP_L DECOMPRESS USING TD_SYSFNLIB.LZDECOMP_L ,
       Org_niveau3_bo_nr INTEGER COMPRESS (103 ,-101 ),
       Org_niveau2 VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING TD_SYSFNLIB.LZCOMP_L DECOMPRESS USING TD_SYSFNLIB.LZDECOMP_L ,
       Org_niveau2_bo_nr INTEGER COMPRESS (103 ,-101 ),
       Org_niveau1 VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING TD_SYSFNLIB.LZCOMP_L DECOMPRESS USING TD_SYSFNLIB.LZDECOMP_L ,
       Org_niveau1_bo_nr INTEGER COMPRESS (103 ,-101 ),
       Org_niveau0 VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING TD_SYSFNLIB.LZCOMP_L DECOMPRESS USING TD_SYSFNLIB.LZDECOMP_L ,
       Org_niveau0_bo_nr INTEGER COMPRESS (103 ,-101 ),
       Bank_herkomst VARCHAR(4) CHARACTER SET LATIN NOT CASESPECIFIC,
       Kvk_nr CHAR(13) CHARACTER SET LATIN NOT CASESPECIFIC,
       Kvk_branche_nr CHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
       Kvk_branche_oms CHAR(40) CHARACTER SET LATIN NOT CASESPECIFIC,
       Kvk_klasse_werknemers VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
       Sbi_code CHAR(6) CHARACTER SET LATIN NOT CASESPECIFIC,
       Sbi_oms VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING TD_SYSFNLIB.LZCOMP_L DECOMPRESS USING TD_SYSFNLIB.LZDECOMP_L ,
       Sbi_bron VARCHAR(9) CHARACTER SET UNICODE NOT CASESPECIFIC,
       AGIC_oms VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING TD_SYSFNLIB.LZCOMP_L DECOMPRESS USING TD_SYSFNLIB.LZDECOMP_L ,
       Sectorcluster VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING TD_SYSFNLIB.LZCOMP_L DECOMPRESS USING TD_SYSFNLIB.LZDECOMP_L ,
       CMB_sector VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING TD_SYSFNLIB.LZCOMP_L DECOMPRESS USING TD_SYSFNLIB.LZDECOMP_L ,
       Subsector_code CHAR(3) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING TD_SYSFNLIB.LZCOMP_L DECOMPRESS USING TD_SYSFNLIB.LZDECOMP_L ,
       Subsector_oms VARCHAR(256) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING TD_SYSFNLIB.LZCOMP_L DECOMPRESS USING TD_SYSFNLIB.LZDECOMP_L ,
       Baten DECIMAL(18,0),
       Aantal_jaren_bestaan INTEGER,
       Aantal_jaren_klant INTEGER,
       Aantal_maanden_klant INTEGER,
       Omzet_inkomend DECIMAL(15,0),
       Bedrijfsomzet DECIMAL(18,0),
       Bedrijfsomzet_RM_ind BYTEINT,
       Bedrijfsomzet_jaar INTEGER,
       Omzetklasse_id SMALLINT,
       Omzetklasse_oms VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
       SoW VARCHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
       Primair_categorie VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING TD_SYSFNLIB.LZCOMP_L DECOMPRESS USING TD_SYSFNLIB.LZDECOMP_L ,
       Primair_ind BYTEINT,
       Businessvolume DECIMAL(18,0),
       Creditvolume DECIMAL(18,0),
       Debetvolume DECIMAL(18,0),
       Cross_sell INTEGER,
       Cs_betalen BYTEINT,
       Cs_creditgelden BYTEINT,
       Cs_kredieten BYTEINT,
       Cs_verzekeren_ondernemer BYTEINT,
       Cs_creditcard BYTEINT,
       Cs_employee_benefits BYTEINT,
       Cs_beleggen BYTEINT,
       Cs_lease BYTEINT,
       Cs_ifn BYTEINT,
       Cs_treasury BYTEINT,
       Cs_digitaal_bankieren BYTEINT,
       Cs_pakket_prive BYTEINT,
       Cs_verzekeren_onderneming BYTEINT,
       Aantal_mnd_sinds_productafname INTEGER,
       Startersrekening_ind BYTEINT,
       Starterspakket_ind BYTEINT,
       MKB_pakket_ind BYTEINT,
       VenS_pakket_ind BYTEINT,
       Aantal_complexe_producten SMALLINT,
       Complexe_producten VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING TD_SYSFNLIB.LZCOMP_L DECOMPRESS USING TD_SYSFNLIB.LZDECOMP_L ,
       Naw VARCHAR(315) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING TD_SYSFNLIB.LZCOMP_L DECOMPRESS USING TD_SYSFNLIB.LZDECOMP_L ,
       Postcode VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING TD_SYSFNLIB.LZCOMP_L DECOMPRESS USING TD_SYSFNLIB.LZDECOMP_L ,
       Geo_niveau1 CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING TD_SYSFNLIB.LZCOMP_L DECOMPRESS USING TD_SYSFNLIB.LZDECOMP_L ,
       Geo_niveau2 VARCHAR(40) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING TD_SYSFNLIB.LZCOMP_L DECOMPRESS USING TD_SYSFNLIB.LZDECOMP_L ,
       Geo_niveau3 VARCHAR(40) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING TD_SYSFNLIB.LZCOMP_L DECOMPRESS USING TD_SYSFNLIB.LZDECOMP_L ,
       SME_regio VARCHAR(40) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING TD_SYSFNLIB.LZCOMP_L DECOMPRESS USING TD_SYSFNLIB.LZDECOMP_L ,
       SME_marktgebied VARCHAR(40) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING TD_SYSFNLIB.LZCOMP_L DECOMPRESS USING TD_SYSFNLIB.LZDECOMP_L ,
       Postretour_adres_ind BYTEINT,
       Telefoon_nr_vast VARCHAR(19) CHARACTER SET LATIN NOT CASESPECIFIC,
       Telefoon_nr_mobiel VARCHAR(19) CHARACTER SET LATIN NOT CASESPECIFIC,
       Contactpersoon CHAR(40) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING TD_SYSFNLIB.LZCOMP_L DECOMPRESS USING TD_SYSFNLIB.LZDECOMP_L ,
       Emailadres VARCHAR(75) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING TD_SYSFNLIB.LZCOMP_L DECOMPRESS USING TD_SYSFNLIB.LZDECOMP_L ,
       Datum_volgend_contact DATE FORMAT 'YYYYMMDD',
       Datum_laatste_contact_pro_ftf DATE FORMAT 'YYYYMMDD',
       Datum_laatste_contact_ftf DATE FORMAT 'YYYYMMDD',
       Aantal_contact_pro_ftf INTEGER,
       Aantal_contact_ftf INTEGER,
       Aantal_contact_pro_tel INTEGER,
       Aantal_contact_tel INTEGER,
       Faillissement_ind BYTEINT,
       Surseance_ind BYTEINT,
       Bijzonder_beheer_ind BYTEINT,
       CRG SMALLINT,
       GSRI_goedgekeurd VARCHAR(8) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS ('High','Low','Medium'),
       GSRI_Assessment_resultaat VARCHAR(9) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS ('ABOVE PAR','ON PAR','BELOW PAR'),
       Aantal_bcs INTEGER,
       Aantal_bcs_in_scope INTEGER,
       Leidend_business_contact_nr DECIMAL(12,0),
       Leidend_bc_ind BYTEINT,
       Signaal VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING TD_SYSFNLIB.LZCOMP_L DECOMPRESS USING TD_SYSFNLIB.LZDECOMP_L ,
       Datum_revisie_TB DATE FORMAT 'YYYY-MM-DD',
       CCA_consultant_TB INTEGER COMPRESS 0
      )
UNIQUE PRIMARY INDEX ( Klant_nr, Maand_nr )
INDEX ( Klant_nr )
INDEX ( Maand_nr );

.IF ERRORCODE <> 0 THEN .GOTO EOP

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
       'PB' AS Org_niveau3,
       309113 AS Org_niveau3_bo_nr,
       'PB' AS Org_niveau2,
       309113 AS Org_niveau2_bo_nr,
       'PB' AS Org_niveau1,
       309113 AS Org_niveau1_bo_nr,
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

.IF ERRORCODE <> 0 THEN .GOTO EOP


/* kopie */
CREATE TABLE MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_NEW AS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB WITH DATA
UNIQUE PRIMARY INDEX (Business_contact_nr, Klant_nr, Maand_nr)
PARTITION BY (
               RANGE_N(maand_nr  BETWEEN
                      201001  AND 201012  EACH 1,
                      201101  AND 201112  EACH 1,
                      201201  AND 201212  EACH 1,
                      201301  AND 201312  EACH 1,
                      201401  AND 201412  EACH 1,
                      201501  AND 201512  EACH 1,
                      201601  AND 201612  EACH 1,
                      201701  AND 201712  EACH 1,
                      201801  AND 201812  EACH 1,
                      201901  AND 201912  EACH 1,
                      202001  AND 202012  EACH 1,
                      NO RANGE,
                      UNKNOWN))
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB COLUMN (PARTITION);

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* GEEN HISTORIE BEWAREN, DUS ALLES VERWIJDEREN */
DELETE FROM MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_NEW;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_NEW COLUMN (PARTITION);

.IF ERRORCODE <> 0 THEN .GOTO EOP


/* WEEKCIJFERS TOEVOEGEN */

INSERT INTO MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_NEW
SELECT *
FROM Mi_temp.Mia_week_PB
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_NEW COLUMN (PARTITION);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_NEW COLUMN (Klant_nr, Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_NEW COLUMN (Klant_nr, Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_NEW COLUMN (Klant_nr, Maand_nr, Business_contact_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_NEW COLUMN CCA;
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_NEW COLUMN Business_contact_nr;
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_NEW COLUMN Bedrijfsomzet;
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_NEW COLUMN Kvk_nr;
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_NEW COLUMN Contactpersoon;
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_NEW COLUMN Faillissement_ind;
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_NEW COLUMN Naw;
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_NEW COLUMN Klant_ind;
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_NEW COLUMN Klantstatus;
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_NEW COLUMN (MAAND_NR , SEGMENT ,KLANT_IND ,KLANTSTATUS);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_NEW COLUMN (MAAND_NR , KLANT_IND ,KLANTSTATUS);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_NEW COLUMN (KLANT_NR ,KLANT_IND);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_NEW COLUMN (MAAND_NR , KLANT_IND);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_NEW COLUMN KLANT_NR;
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_NEW COLUMN (KLANT_IND ,KLANTSTATUS ,BUSINESS_LINE ,SEGMENT);

COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_NEW COLUMN (MAAND_NR);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_NEW COLUMN (BUSINESS_LINE);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_NEW COLUMN (MAAND_NR, KLANT_IND ,KLANTSTATUS ,SEGMENT);

COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_NEW COLUMN (Maand_nr, Business_line);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_NEW COLUMN (Maand_nr, Segment, Subsegment);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_NEW COLUMN (Maand_nr, CCA );
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_NEW COLUMN (Maand_nr, Omzetklasse_id, Omzetklasse_oms);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_NEW COLUMN SEGMENT;
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_NEW COLUMN (PARTITION ,KLANT_NR ,MAAND_NR);

COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_NEW COLUMN BO_NR;
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_NEW COLUMN (VERKORTE_NAAM ,KVK_NR);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_NEW COLUMN (KLANT_NR);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_NEW COLUMN (MAAND_NR , BO_NR);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_NEW COLUMN CLIENTGROEP;

COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_NEW COLUMN (Org_niveau2);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_hist_PB_NEW COLUMN (Business_line, Segment, Org_niveau1);

.IF ERRORCODE <> 0 THEN .GOTO EOP




/*************************************************************************************

    BASIS SET tabellen Siebel (CRM), afhankelijk van Mia_week

*************************************************************************************/

/* ----------------------------------------------------------------------------------------------------

Siebel_CST_Member

------------------------------------------------------------------------------------------------------  */

-- Tijdelijke tabel waarin de klantcomplexen van retail staan, dus BC - Leidend_BC en klant_nr. Klant_nr hoeft niet altijd aanwezig te zijn.
-- Bij een ontbrekend leidend BC wordt het gewone BC als leidend gezien.

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

-- Creeren tijdelijke tabel voor selecteren van alle CST members die aangeleverd zijn. De uiteindelijke tabel is hier een selectie van, om van elke rol binnen een team maar 1 medewerker over te houden. Een medewerker kan wel 2 rollen binnen 1 team hebben, dus hoeft niet uniek te zijn.

CREATE TABLE MI_TEMP.Siebel_CST_Member_TEMP
(
      Klant_nr INTEGER,
      Business_contact_nr DECIMAL(12,0),
      Client_level CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS('BC','CC','CE','CG'),
      Leidend_Business_contact DECIMAL(12,0),
      Bc_Business_segment VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC,
      Maand_nr INTEGER,
      Datum_gegevens DATE FORMAT 'yyyy-mm-dd',
      SBT_ID VARCHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
      Naam VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC,
      Sbl_cst_deelnemer_rol VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
      SBL_gedelegeerde_ind CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      TB_Consultant CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS ('N','Y'),
      Party_party_relatie_sdat  DATE FORMAT 'YYYY-MM-DD' NOT NULL,
      Party_party_relatie_edat DATE FORMAT 'YYYY-MM-DD'
      )
PRIMARY INDEX ( Business_contact_nr, Klant_nr, Maand_nr, sbt_id, Sbl_cst_deelnemer_rol);

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

-- De tijdelijke tabel bevat data waarbij medewerkers en klanten vaker kunnen voorkomen, omdat ze op meerdere clientlevels aangeleverd kunnen zijn. Om ervoor te zorgen dat een klant in combinatie met een medewerker maar 1x voorkomt, wordt hier een qualify op data gedaan.
-- LET OP: Een medewerker kan 2 rollen binnen 1 team hebben en dus is klant_nr / SBT_id niet uniek.
-- LET OP: Er kunnen verschillende medewerkers aangeleverd worden met dezelfde rol. Binnen CE is iemand anders de RM dan op CC niveau. Van elke rol wordt maar 1 iemand opgenomen in 1 team (hoogst aangeleverde clientlevel krijgt voorrang)

-- HISTORIE MOET BEWAARD BLIJVEN!!! Na half jaar evaluatie of historie bewaren nodig is.

CREATE TABLE Mi_temp.Siebel_CST_Member_NEW AS MI_TEMP.Siebel_CST_Member_TEMP WITH DATA;

.IF ERRORCODE <> 0 THEN .GOTO EOP

DELETE FROM mi_temp.Siebel_CST_Member_NEW
WHERE maand_nr = (SEL Maand_nr FROM Mi_temp.Mia_week GROUP BY 1)
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

-- Updaten TB consultant

-- Als er meerdere TB consultants aangeleverd worden, dan wordt degene gekozen die op hoogst clientlevel is aangeleverd, gevolgd door rol (CTS consultant krijgt voorrang boven Cash Management Consultant en overige) en gevolgd op SBT_id DESC
-- TB Consultants worden aangeleverd onder CTS consultant (rol 45), Cash Management Consultant

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

-- Consultant bijzoeken en TB_consultant veld updaten in CST member
-- Join op leidend BC, SBT_ID

UPDATE Mi_temp.Siebel_CST_Member_NEW
FROM (SELECT A.SBT_ID,
             A.Leidend_Business_contact,
             A.sbl_cst_deelnemer_rol
      FROM MI_TEMP.Consultants_CST_member A
      WHERE  A.Leidend_Business_contact = mi_temp.Siebel_CST_Member_NEW.Leidend_Business_contact
      AND A.SBT_ID = mi_temp.Siebel_CST_Member_NEW.SBT_ID
      AND A.sbl_cst_deelnemer_rol = mi_temp.Siebel_CST_Member_NEW.sbl_cst_deelnemer_rol
      GROUP BY 1,2,3) KL
SET TB_Consultant = CASE WHEN KL.Leidend_Business_contact IS NOT NULL THEN 'Y' END
WHERE KL.SBT_ID = mi_temp.Siebel_CST_Member_NEW.SBT_ID
AND KL.Leidend_Business_contact = MI_TEMP.Siebel_CST_Member_NEW.Leidend_Business_contact
AND TRIM(KL.sbl_cst_deelnemer_rol) = TRIM(MI_TEMP.Siebel_CST_Member_NEW.sbl_cst_deelnemer_rol);

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS MI_TEMP.Siebel_CST_Member_NEW COLUMN ( SBT_ID);
COLLECT STATISTICS MI_TEMP.Siebel_CST_Member_NEW COLUMN ( SBT_ID, Maand_nr);
COLLECT STATISTICS MI_TEMP.Siebel_CST_Member_NEW COLUMN ( Klant_nr, SBT_ID, Maand_nr);
COLLECT STATISTICS MI_TEMP.Siebel_CST_Member_NEW COLUMN ( Klant_nr, Leidend_business_contact, SBT_ID, Maand_nr);
COLLECT STATISTICS MI_TEMP.Siebel_CST_Member_NEW COLUMN ( Klant_nr, Leidend_business_contact, client_level, SBT_ID, Maand_nr);
COLLECT STATISTICS MI_TEMP.Siebel_CST_Member_NEW COLUMN ( Klant_nr, Leidend_business_contact, client_level, SBT_ID, sbl_cst_deelnemer_rol, Maand_nr);
COLLECT STATISTICS MI_TEMP.Siebel_CST_Member_NEW COLUMN (Klant_nr);
COLLECT STATISTICS MI_TEMP.Siebel_CST_Member_NEW COLUMN (Klant_nr, Maand_nr);
COLLECT STATISTICS MI_TEMP.Siebel_CST_Member_NEW COLUMN (Klant_nr, Maand_nr, SBT_ID);
COLLECT STATISTICS MI_TEMP.Siebel_CST_Member_NEW COLUMN (Client_level, Maand_nr);
COLLECT STATISTICS MI_TEMP.Siebel_CST_Member_NEW COLUMN (Client_level, Maand_nr, SBT_ID);
COLLECT STATISTICS MI_TEMP.Siebel_CST_Member_NEW COLUMN (Client_level);

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* ----------------------------------------------------------------------------------------------------

Siebel_Verkoopteam_Member

------------------------------------------------------------------------------------------------------  */

CREATE TABLE MI_SAS_AA_MB_C_MB.Siebel_Verkoopteam_Member_NEW
 (
 klant_nr INTEGER
,maand_nr INTEGER
,datum_gegevens DATE FORMAT  'yyyy-mm-dd'
,business_contact_nr DECIMAL(12,0)
,siebel_verkoopkans_id VARCHAR(15) CHARACTER SET LATIN NOT CASESPECIFIC
,sbt_id VARCHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC
,naam VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L
,bo_nr_mdw INTEGER
,bo_naam_mdw VARCHAR(256) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L
,functie VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L
,primary_ind BYTEINT
,Client_level CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L
,sdat DATE FORMAT  'yyyy-mm-dd'
,edat DATE FORMAT  'yyyy-mm-dd'
)
UNIQUE PRIMARY INDEX (siebel_verkoopkans_id, klant_nr, business_contact_nr, sbt_id, primary_ind);

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP


COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopteam_Member_NEW COLUMN (klant_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopteam_Member_NEW COLUMN (business_contact_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopteam_Member_NEW COLUMN (klant_nr, maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopteam_Member_NEW COLUMN (klant_nr, maand_nr, client_level);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopteam_Member_NEW COLUMN (business_contact_nr, maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopteam_Member_NEW COLUMN (business_contact_nr, maand_nr, client_level);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopteam_Member_NEW COLUMN (siebel_verkoopkans_id);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopteam_Member_NEW COLUMN (sbt_id);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopteam_Member_NEW COLUMN (sbt_id, siebel_verkoopkans_id);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopteam_Member_NEW COLUMN (Klant_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopteam_Member_NEW COLUMN (Klant_nr, Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopteam_Member_NEW COLUMN (Klant_nr, Maand_nr, siebel_verkoopkans_id);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopteam_Member_NEW COLUMN (Klant_nr, Maand_nr, siebel_verkoopkans_id, primary_ind);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopteam_Member_NEW COLUMN (Klant_nr, Maand_nr, SBT_ID);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopteam_Member_NEW COLUMN (Klant_nr, Maand_nr, SBT_ID, primary_ind);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopteam_Member_NEW COLUMN (Klant_nr, Maand_nr, SBT_ID, siebel_verkoopkans_id);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopteam_Member_NEW COLUMN (Klant_nr, Business_contact_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopteam_Member_NEW COLUMN (Klant_nr, Business_contact_nr, Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopteam_Member_NEW COLUMN (Klant_nr, Maand_nr, siebel_verkoopkans_id, Business_contact_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopteam_Member_NEW COLUMN (Business_contact_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopteam_Member_NEW COLUMN (Business_contact_nr, Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_Verkoopteam_Member_NEW COLUMN (Maand_nr, siebel_verkoopkans_id, Business_contact_nr);

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* ----------------------------------------------------------------------------------------------------

Siebel_Verkoopkans_Contactpersoon

------------------------------------------------------------------------------------------------------*/

CREATE TABLE MI_SAS_AA_MB_C_MB.Siebel_verkoopkans_contactpersoon_NEW
 (
 klant_nr INTEGER
,maand_nr INTEGER
,datum_gegevens DATE FORMAT  'yyyy-mm-dd'
,business_contact_nr DECIMAL(12,0)
,siebel_verkoopkans_id VARCHAR(15) CHARACTER SET LATIN NOT CASESPECIFIC
,primary_ind BYTEINT
,siebel_contactpersoon_id VARCHAR(15)  CHARACTER SET LATIN NOT CASESPECIFIC -- hiermee kun je van alles koppelen uit Siebel_contactpersoon
,Client_level CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L
,sdat DATE FORMAT  'yyyy-mm-dd'
,edat DATE FORMAT  'yyyy-mm-dd'
)
UNIQUE PRIMARY INDEX (siebel_verkoopkans_id, klant_nr, siebel_contactpersoon_id);

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_verkoopkans_contactpersoon_NEW COLUMN (klant_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_verkoopkans_contactpersoon_NEW COLUMN (business_contact_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_verkoopkans_contactpersoon_NEW COLUMN (klant_nr, maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_verkoopkans_contactpersoon_NEW COLUMN (klant_nr, maand_nr, client_level);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_verkoopkans_contactpersoon_NEW COLUMN (business_contact_nr, maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_verkoopkans_contactpersoon_NEW COLUMN (business_contact_nr, maand_nr, client_level);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_verkoopkans_contactpersoon_NEW COLUMN (siebel_verkoopkans_id);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_verkoopkans_contactpersoon_NEW COLUMN (siebel_contactpersoon_id);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_verkoopkans_contactpersoon_NEW COLUMN (siebel_contactpersoon_id, maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_verkoopkans_contactpersoon_NEW COLUMN (siebel_contactpersoon_id, maand_nr, client_level);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_verkoopkans_contactpersoon_NEW COLUMN (siebel_contactpersoon_id, maand_nr, client_level, klant_nr);

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* ----------------------------------------------------------------------------------------------------

Siebel_CST_Member_hist

------------------------------------------------------------------------------------------------------  */

/* kopie tabel aanmaken*/
CREATE TABLE MI_SAS_AA_MB_C_MB.Siebel_CST_Member_hist_NEW  AS MI_SAS_AA_MB_C_MB.Siebel_CST_Member_hist WITH DATA
 PRIMARY INDEX (Klant_nr, Maand_nr, sbt_id)
PARTITION BY RANGE_N(maand_nr  BETWEEN
    201001  AND 201012  EACH 1,
    201101  AND 201112  EACH 1,
    201201  AND 201212  EACH 1,
    201301  AND 201312  EACH 1,
    201401  AND 201412  EACH 1,
    201501  AND 201512  EACH 1,
    201601  AND 201612  EACH 1,
    201701  AND 201712  EACH 1,
    201801  AND 201812  EACH 1,
    201901  AND 201912  EACH 1,
    202001  AND 202012  EACH 1,
    NO RANGE,
    UNKNOWN);

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_CST_Member_hist_NEW COLUMN (PARTITION);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_CST_Member_hist_NEW COLUMN (Klant_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_CST_Member_hist_NEW COLUMN (Klant_nr, Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_CST_Member_hist_NEW COLUMN (Klant_nr, Maand_nr, SBT_ID);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_CST_Member_hist_NEW COLUMN (Client_level, Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_CST_Member_hist_NEW COLUMN (Client_level, Maand_nr, SBT_ID);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Siebel_CST_Member_hist_NEW COLUMN (Client_level);

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* Weekcijfers verwijderen indien maand reeds aanwezig van vorige week*/
DELETE FROM  MI_SAS_AA_MB_C_MB.Siebel_CST_Member_hist_NEW
WHERE maand_nr = (SEL Maand_nr FROM MI_SAS_AA_MB_C_MB.Mia_periode_NEW);


.IF ERRORCODE <> 0 THEN .GOTO EOP

/* Weekcijfers toevoegen*/
INSERT INTO MI_SAS_AA_MB_C_MB.Siebel_CST_Member_hist_NEW
SELECT * FROM Mi_temp.Siebel_CST_Member_NEW;

.IF ERRORCODE <> 0 THEN .GOTO EOP





/*************************************************************************************

   2. Wegloopmodel

   Commerciele clusters waarbij het volgende van toepassing is:
   - Business Volume vorige maand bedroeg minimaal €100.000
      en
   - Business Volume huidige maand minimaal 20% afgenomen tov. voorgaande maand
      en
   - Business Volume huidige maand minimaal 20% afgenomen tov. Laagste Business volume voorgaande 12 maanden
      en
   - segment RM, minimaal 1 jaar klant, niet onder beheer van FR&R/Solveon (voor zover inzichtelijk)
     geen Notaris (bus.vol. derdengelden varieert sterk)

*************************************************************************************/

CREATE TABLE Mi_temp.Wegl_rapportage_moment_t1
      (
       Maand_nr                  INTEGER
      )
UNIQUE PRIMARY INDEX ( Maand_nr );

.IF ERRORCODE <> 0 THEN .GOTO EOP

INSERT INTO Mi_temp.Wegl_rapportage_moment_t1
SELECT Maand_nr
FROM Mi_temp.Mia_week
GROUP BY 1;

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS COLUMN (MAANDNRLY) ON Mi_temp.Wegl_rapportage_moment;

.IF ERRORCODE <> 0 THEN .GOTO EOP

/*
-- BESTAANDE KLANTEN ALS UITGANGSPUNT, BESTOND REEDS 12 mnd terug
--
--   Decode status:
--   -  1 bestaand ongewijzigd
--   -  2 nieuw
--   -  3 vervallen
--   - 99 niet te duiden
*/
CREATE TABLE Mi_temp.Cluster_status_basis
      (
       Klant_nr INTEGER,
       Status INTEGER
      )
UNIQUE PRIMARY INDEX ( Klant_nr );

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* Bestaande klanten                                           */
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

/* verwijderen klanten die afgelopen 12 maanden minimaal 1x Solveon indicatie in kredietentabel */
DELETE FROM Mi_temp.Cluster_status_basis
WHERE Klant_nr IN
        (
        SEL Klant_nr

        FROM
                (
                 SEL c.Klant_nr
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
                ) a
        )
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* verwijderen klanten bijzonder beheer en klanten waarbij minimaal 1 BC op BO van Solveon/FR&R staat  */

DELETE FROM Mi_temp.Cluster_status_basis
WHERE Klant_nr IN
(
 SEL Klant_nr
 FROM mi_temp.mia_week  a
 WHERE (ZEROIFNULL(Faillissement_ind) + ZEROIFNULL(Surseance_ind) + ZEROIFNULL(Bijzonder_beheer_ind)) > 0
 GROUP BY 1
);

 .IF ERRORCODE <> 0 THEN .GOTO EOP

DELETE FROM Mi_temp.Cluster_status_basis
WHERE Klant_nr IN
(
 SEL e.gerelateerd_party_id AS Cluster_nr
 FROM mi_vm_ldm.aparty_party_relatie c

 INNER JOIN
                 (
                  SEL a.bo_nr
                  FROM mi_vm_ldm.vbo_mi_part_zak a
                  WHERE a.bo_naam LIKE '%SOLV%'
                     OR a.bo_naam LIKE '%BIJZ.KRED%'
                     OR a.bo_naam LIKE '%BIJZ. KRED%'
                     OR a.bo_naam LIKE '%LINDORFF%'
                 ) d
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

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* verwijderen klanten waarvan minimaal 1 BC failliet/surseance */
DELETE FROM Mi_temp.Cluster_status_basis
WHERE Klant_nr IN
(
  SEL a.cc_nr
  FROM mi_vm_nzdb.vCommercieel_business_contact a
  INNER JOIN Mi_temp.Wegl_rapportage_moment XB
     ON a.Maand_nr = XB.Maand_nr
  INNER JOIN (       SEL
                         Party_id  AS Cbc_nr
                     FROM MI_VM_Ldm.aKLANT_PROSPECT
                     WHERE Party_sleutel_type = 'BC'
                       AND Beschikkingsmacht IN (4, 5)
                    GROUP BY 1) AS G
    ON A.Cbc_nr = G.Cbc_nr
 GROUP BY 1
)
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* verwijderen Notarissen (grote volume fluctuaties op derdengelden rekeningen) */
DELETE FROM Mi_temp.Cluster_status_basis
WHERE Klant_nr IN
(
SEL
        a.Klant_nr
FROM mi_temp.mia_week  a
WHERE a.SBI_code IN ('69103')
   OR a.Kvk_branche_nr IN ('69103')
);

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* ACTUELE WEEK data van RM-klanten */

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

/*bepalen historische business volume items voor klanten*/

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

/*bepalen wegloopcriteria indien 12 maanden historie aanwezig en het min. business volume van afgelopen 12 mnd groter is dan 0*/
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

.IF ERRORCODE <> 0 THEN .GOTO EOP


/* vorige maand minimaal 100k business volume & huidig business volume minimaal 20% gedaald tov vorige maand en laagste volume afgelopen 12 maanden*/

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* leads die deze maand voor het eerst zijn weggeschreven met stoplicht (week_1e_retentie_stoplicht is gevuld)
   blijven staan, overige leads verwijderen en opnieuw bepalen  */

DELETE
  FROM MI_SAS_AA_MB_C_MB.Model_wegloop_hist
 WHERE maand_nr IN (SELECT Maand_nr FROM Mi_temp.Mia_week GROUP BY 1)
   AND ZEROIFNULL(week_1e_retentie_stoplicht ) = 0;

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* leads vorige maand voor het eerst opgevoerd maar nog geen 4 weken gesignaleerd */
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
/* deze maand nog niet weggeschreven */
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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Model_wegloop_hist COLUMN (Klant_nr,Maand_nr,Retentie_stoplicht );
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Model_wegloop_hist COLUMN (Maand_nr,Retentie_stoplicht );
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Model_wegloop_hist COLUMN (Maand_nr );
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Model_wegloop_hist COLUMN (Week_1e_retentie_stoplicht );
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Model_wegloop_hist COLUMN (Klant_nr );
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Model_wegloop_hist COLUMN (Klant_nr,Week_1e_retentie_stoplicht );
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Model_wegloop_hist COLUMN (Retentie_stoplicht );
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Model_wegloop_hist COLUMN (Klant_nr,Maand_nr);


.IF ERRORCODE <> 0 THEN .GOTO EOP



/*************************************************************************************

   3. CUBe Baten en stoplichten

*************************************************************************************/

/************************************************************************************/
/* 3.1 Historie CUBe leads bijwerken obv Siebel terugkoppeling                      */
/************************************************************************************/

-- Huidige en voorgaande maand bepalen

CREATE TABLE Mi_temp.Mia_periode_CUBe
      (
       Maand_nr INTEGER,
       Datum_gegevens DATE FORMAT 'YYYYMMDD',
       Maand_nr_vm1 INTEGER
      )
UNIQUE PRIMARY INDEX ( Maand_nr )
INDEX ( Maand_nr_vm1 )
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS COLUMN (MAAND_NR_VM1) ON Mi_temp.Mia_periode_CUBe;
COLLECT STATISTICS COLUMN (MAAND_NR) ON Mi_temp.Mia_periode_CUBe;

.IF ERRORCODE <> 0 THEN .GOTO EOP

-- Nieuwe versie historische tabel CUBe leads

CREATE TABLE MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW
(
 UUID                 CHAR(36) CHARACTER SET LATIN NOT CASESPECIFIC,
 Klant_nr             INTEGER,
 Business_contact_nr  DECIMAL(12,0),
 Maand_nr             INTEGER,
 CUBe_product_id      INTEGER,
 Bedrijfstak_id       CHAR(3) CHARACTER SET LATIN CASESPECIFIC,
 Omzetklasse_id       SMALLINT,
 Baten                DECIMAL(18,2),
 Baten_benchmark      DECIMAL(18,2),
 Penetratie           DECIMAL(10,4),
 Lichtbeheer          BYTEINT,
 Status               VARCHAR(25),
 N_mnd_status         INTEGER,
 Lead_opvolgen        BYTEINT,
 Recordtype           CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
 Datum_aanlevering    DATE FORMAT 'yyyy-mm-dd',
 Datum_terugkoppeling DATE FORMAT 'yyyy-mm-dd',
 Siebel_cube_lead_ID  VARCHAR(15) CHARACTER SET LATIN NOT CASESPECIFIC,
 Koppeling_id_CC      VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC,
 Datum_bijgewerkt     DATE FORMAT 'yyyy-mm-dd',
 SBT_id_mdw_bijgewerkt_door VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
 Siebel_verkoopkans_id  VARCHAR(15) CHARACTER SET LATIN NOT CASESPECIFIC,
 Siebel_verkoopkans_Status VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS USING LZCOMP_L DECOMPRESS USING LZDECOMP_L,
 Siebel_verkoopkans_Sdat DATE FORMAT 'MM-DD-YYYY'
 )
UNIQUE PRIMARY INDEX ( Maand_nr, UUID )
INDEX ( Klant_nr )
INDEX ( Business_contact_nr )
INDEX ( Maand_nr )
INDEX ( CUBe_product_id )
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COMMENT ON MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW AS 'NIET VERWIJDEREN - Afdelingstabel in schedulescript (CUBe)';

.IF ERRORCODE <> 0 THEN .GOTO EOP

-- vullen met oude historie
INSERT INTO MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW
SELECT * FROM MI_SAS_AA_MB_C_MB.CUBe_leads_hist
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATS MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW INDEX (Maand_nr, UUID);
COLLECT STATS MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW COLUMN (UUID);
COLLECT STATS MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW COLUMN (UUID, Maand_nr);
COLLECT STATS MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW COLUMN (Recordtype);
COLLECT STATS MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW COLUMN (Status, N_mnd_status);
COLLECT STATS MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW COLUMN (MAAND_NR);
COLLECT STATS MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW COLUMN (DATUM_TERUGKOPPELING);
COLLECT STATS MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW COLUMN (RECORDTYPE);
COLLECT STATS MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW COLUMN (Siebel_cube_lead_ID);
COLLECT STATS MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW COLUMN (Siebel_verkoopkans_id);
COLLECT STATS MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW COLUMN (Datum_bijgewerkt);
COLLECT STATS MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW COLUMN (SBT_id_mdw_bijgewerkt_door);
COLLECT STATS MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW COLUMN (Koppeling_id_CC);
COLLECT STATS MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW COLUMN (Siebel_verkoopkans_Status);
COLLECT STATS MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW COLUMN (Siebel_verkoopkans_Status,Siebel_verkoopkans_Sdat);
COLLECT STATS MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW COLUMN (Siebel_verkoopkans_Sdat);

.IF ERRORCODE <> 0 THEN .GOTO EOP

-- Indien de laatste levering in vorige maand heeft plaatsgevonden dan de leads kopieren naar huidige maand voor verwerking Siebel feedback
-- Reeds verwijderde leads niet kopieren naar de nieuwe maand
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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATS MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW;

.IF ERRORCODE <> 0 THEN .GOTO EOP

-- Leads van meest recente maand bijwerken met de laatst bekende status van het UUID

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATS MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW;

.IF ERRORCODE <> 0 THEN .GOTO EOP

-- N_mnd_status bijwerken

UPDATE MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW
FROM
     (
      SELECT TRIM(XA.UUID) AS UUID,
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
             COALESCE(XA.Status, 'New') AS StatusX,
             XA.Lead_opvolgen,
             ROW_NUMBER() OVER (PARTITION BY XA.UUID ORDER BY Maand_nr
                 -- reset de nummering indien de voorgaande status van de UUID afwijkend is
              RESET WHEN StatusX <>  MAX(StatusX) OVER (PARTITION BY XA.UUID ORDER BY Maand_nr ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING)) N_mnd_status
       FROM MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW XA
      )  A
SET N_mnd_status =  A.N_mnd_status

WHERE MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW.UUID = A.UUID
  AND MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW.Maand_nr = A.Maand_nr
;

.IF ERRORCODE <> 0 THEN .GOTO EOP



/************************************************************************************/
/* 3.2 CUBe model uitscoren, nieuwe leads genereren                                 */
/************************************************************************************/

/*-------------------------------------------------------------*/
/* VERZAMELEN BASISGEGEVENS                                    */
/*-------------------------------------------------------------*/

COLLECT STATISTICS Mi_temp.Mia_klanten COLUMN ( Benchmark_ind );
COLLECT STATISTICS Mi_temp.Mia_klanten COLUMN ( Maand_nr, Business_line, Segment, Omzetklasse_id );
COLLECT STATISTICS Mi_temp.Mia_klanten COLUMN ( Maand_nr, Business_line, Segment, Subsegment, Bedrijfstak_id, Omzetklasse_id, Dimensie3_id, Dimensie4_id, Dimensie5_id );
COLLECT STATISTICS Mi_temp.Mia_baten COLUMN ( Klant_nr, Maand_nr );
COLLECT STATISTICS COLUMN (DIMENSIE3_ID) ON Mi_temp.Mia_klanten;

.IF ERRORCODE <> 0 THEN .GOTO EOP

CREATE TABLE Mi_temp.CUBe_benchmark_000
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
       N_klanten INTEGER
      )
UNIQUE PRIMARY INDEX ( Maand_nr, Business_line, Segment, Subsegment, Bedrijfstak_id,
                       Omzetklasse_id, Dimensie3_id, Dimensie4_id, Dimensie5_id );

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.CUBe_benchmark_000 COLUMN Business_line;
COLLECT STATISTICS Mi_temp.CUBe_benchmark_000 COLUMN (Maand_nr, Business_line, Segment, Subsegment, Bedrijfstak_id, Omzetklasse_id, Dimensie4_id, Dimensie5_id);
COLLECT STATISTICS Mi_temp.Mia_klanten COLUMN (Business_line, Bedrijfstak_id);
COLLECT STATISTICS Mi_temp.Mia_klanten COLUMN (Maand_nr, Business_line, Segment, Subsegment, Bedrijfstak_id, Omzetklasse_id, Dimensie4_id, Dimensie5_id);
COLLECT STATISTICS Mi_temp.Mia_klanten COLUMN (Klant_nr, Maand_nr);
COLLECT STATISTICS COLUMN (SUBSEGMENT) ON  Mi_temp.CUBe_benchmark_000;
COLLECT STATISTICS COLUMN (DIMENSIE4_ID) ON   Mi_temp.CUBe_benchmark_000;
COLLECT STATISTICS COLUMN (DIMENSIE5_ID) ON   Mi_temp.CUBe_benchmark_000;
COLLECT STATISTICS COLUMN (MAAND_NR ,BUSINESS_LINE ,SEGMENT , SUBSEGMENT ,BEDRIJFSTAK_ID ,OMZETKLASSE_ID ,DIMENSIE3_ID ,DIMENSIE4_ID , DIMENSIE5_ID) ON Mi_temp.CUBe_benchmark_000;
COLLECT STATISTICS COLUMN (BENCHMARK_IND ,BUSINESS_LINE) ON  Mi_temp.Mia_klanten;
COLLECT STATISTICS COLUMN (KLANT_NR ,MAAND_NR ,CUBE_PRODUCT_ID)  ON Mi_temp.Mia_baten;
COLLECT STATISTICS COLUMN (MAAND_NR ,SEGMENT ,SUBSEGMENT,BEDRIJFSTAK_ID , OMZETKLASSE_ID ,DIMENSIE4_ID ,DIMENSIE5_ID) ON  Mi_temp.CUBe_benchmark_000;
COLLECT STATISTICS COLUMN (MAAND_NR) ON  Mi_temp.CUBe_benchmark_000;
COLLECT STATISTICS COLUMN (MAAND_NR) ON Mi_temp.Mia_klanten;
COLLECT STATISTICS COLUMN (DIMENSIE5_ID) ON    Mi_temp.Mia_klanten;
COLLECT STATISTICS COLUMN (DIMENSIE4_ID) ON  Mi_temp.Mia_klanten;
COLLECT STATISTICS COLUMN (SUBSEGMENT) ON Mi_temp.Mia_klanten;
COLLECT STATISTICS COLUMN (MAAND_NR ,SEGMENT ,SUBSEGMENT ,BEDRIJFSTAK_ID , OMZETKLASSE_ID ,DIMENSIE4_ID ,DIMENSIE5_ID) ON  Mi_temp.Mia_klanten;
COLLECT STATISTICS COLUMN (BENCHMARK_IND ,BUSINESS_LINE,KLANT_NR , MAAND_NR) ON Mi_temp.Mia_klanten;
COLLECT STATISTICS COLUMN (SEGMENT ,SUBSEGMENT ,BEDRIJFSTAK_ID ,OMZETKLASSE_ID ,DIMENSIE4_ID ,DIMENSIE5_ID) ON Mi_temp.Mia_klanten;
COLLECT STATISTICS COLUMN (SEGMENT ,SUBSEGMENT ,BEDRIJFSTAK_ID,OMZETKLASSE_ID ,DIMENSIE4_ID ,DIMENSIE5_ID) ON Mi_temp.CUBe_benchmark_000;
COLLECT STATISTICS COLUMN (SEGMENT ,SUBSEGMENT ,DIMENSIE4_ID , DIMENSIE5_ID) ON Mi_temp.Mia_klanten;
COLLECT STATISTICS COLUMN (SEGMENT ,SUBSEGMENT ,DIMENSIE4_ID , DIMENSIE5_ID) ON Mi_temp.CUBe_benchmark_000;
COLLECT STATISTICS COLUMN (MAAND_NR ,BUSINESS_LINE ,SEGMENT ,SUBSEGMENT ,DIMENSIE4_ID ,DIMENSIE5_ID) ON  Mi_temp.CUBe_benchmark_000;
COLLECT STATISTICS COLUMN (MAAND_NR ,BUSINESS_LINE ,SEGMENT ,SUBSEGMENT ,DIMENSIE4_ID ,DIMENSIE5_ID) ON Mi_temp.Mia_klanten;

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.Mia_baten COLUMN Baten;
COLLECT STATISTICS Mi_temp.CUBe_benchmark_001 COLUMN (Maand_nr, Business_line, Segment, Omzetklasse_id, CUBe_product_id);
COLLECT STATISTICS COLUMN (CUBE_PRODUCT_ID) ON Mi_temp.Mia_baten;
COLLECT STATISTICS COLUMN (N_MET_PRODUCT) ON  Mi_temp.CUBe_benchmark_001;
COLLECT STATISTICS COLUMN (MAAND_NR ,BUSINESS_LINE ,SEGMENT , SUBSEGMENT ,BEDRIJFSTAK_ID ,OMZETKLASSE_ID ,DIMENSIE3_ID,DIMENSIE4_ID , DIMENSIE5_ID ,CUBE_PRODUCT_ID) ON  Mi_temp.CUBe_benchmark_001;

.IF ERRORCODE <> 0 THEN .GOTO EOP



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

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.CUBe_benchmark_002 COLUMN (Omzetklasse_id);
COLLECT STATISTICS Mi_temp.CUBe_benchmark_002 COLUMN (Omzetklasse_id, Min_penetratie_en_klanten_ind);

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.CUBe_benchmark_003 COLUMN Min_penetratie_en_klanten_ind;
COLLECT STATISTICS Mi_temp.CUBe_benchmark_003 COLUMN Overgenomen_baten_benchmark;
COLLECT STATISTICS COLUMN (MAAND_NR ,BUSINESS_LINE ,SEGMENT , SUBSEGMENT ,BEDRIJFSTAK_ID ,DIMENSIE3_ID ,DIMENSIE4_ID,DIMENSIE5_ID , CUBE_PRODUCT_ID) ON Mi_temp.CUBe_benchmark_002;
COLLECT STATISTICS COLUMN (MAAND_NR ,BUSINESS_LINE ,SEGMENT, SUBSEGMENT ,BEDRIJFSTAK_ID ,OMZETKLASSE_ID ,DIMENSIE3_ID,DIMENSIE4_ID , DIMENSIE5_ID ,CUBE_PRODUCT_ID) ON  Mi_temp.CUBe_benchmark_002;
COLLECT STATISTICS COLUMN (OMZETKLASSE_ID) ON  Mi_temp.CUBe_benchmark_003;
COLLECT STATISTICS COLUMN (MAAND_NR ,BUSINESS_LINE ,SEGMENT , SUBSEGMENT ,BEDRIJFSTAK_ID ,OMZETKLASSE_ID ,DIMENSIE3_ID ,DIMENSIE4_ID , DIMENSIE5_ID ,CUBE_PRODUCT_ID) ON Mi_temp.CUBe_benchmark_003;
COLLECT STATISTICS COLUMN (OVERGENOMEN_BATEN_BENCHMARK ,MIN_PENETRATIE_EN_KLANTEN_IND) ON Mi_temp.CUBe_benchmark_003;

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.CUBe_benchmark_003 COLUMN Min_penetratie_en_klanten_ind;
COLLECT STATISTICS Mi_temp.CUBe_benchmark_003 COLUMN Overgenomen_baten_benchmark;

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.CUBe_benchmark_003 COLUMN Min_penetratie_en_klanten_ind;
COLLECT STATISTICS Mi_temp.CUBe_benchmark_003 COLUMN Overgenomen_baten_benchmark;

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.CUBe_benchmark_003 COLUMN Min_penetratie_en_klanten_ind;
COLLECT STATISTICS Mi_temp.CUBe_benchmark_003 COLUMN Overgenomen_baten_benchmark;

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.CUBe_benchmark_003 COLUMN Min_penetratie_en_klanten_ind;
COLLECT STATISTICS Mi_temp.CUBe_benchmark_003 COLUMN Overgenomen_baten_benchmark;

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.CUBe_benchmark_003 COLUMN Min_penetratie_en_klanten_ind;
COLLECT STATISTICS Mi_temp.CUBe_benchmark_003 COLUMN Overgenomen_baten_benchmark;
COLLECT STATISTICS Mi_temp.CUBe_benchmark_002 COLUMN ( Min_penetratie_en_klanten_ind );
COLLECT STATISTICS Mi_temp.CUBe_benchmark_002 COLUMN (Maand_nr, Business_line, Segment, Omzetklasse_id, CUBe_product_id);
COLLECT STATISTICS Mi_temp.CUBe_benchmark_003 COLUMN (Maand_nr, Business_line, Segment, Omzetklasse_id, CUBe_product_id);

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP



/*-------------------------------------------------------------*/
/* VERZAMELEN BASISGEGEVENS                                    */
/*-------------------------------------------------------------*/

UPDATE MI_SAS_AA_MB_C_MB.Mia_periode_NEW
   SET Datum_leads = Mi_cmb.CUBe_collector_datum.DateLastModified;

.IF ERRORCODE <> 0 THEN .GOTO EOP



COLLECT STATISTICS Mi_temp.CUBe_benchmark_003 COLUMN ( Maand_nr, Business_line, Segment, Omzetklasse_id );
COLLECT STATISTICS Mi_temp.Mia_baten COLUMN ( Klant_nr, Maand_nr );
COLLECT STATISTICS Mi_temp.CUBe_benchmark_003 COLUMN ( Maand_nr, Business_line, Segment, Subsegment, Bedrijfstak_id, Omzetklasse_id, Dimensie4_id, Dimensie5_id );
COLLECT STATISTICS Mi_temp.CUBe_benchmark_003 COLUMN (MAAND_NR ,BUSINESS_LINE ,SUBSEGMENT,BEDRIJFSTAK_ID ,OMZETKLASSE_ID ,DIMENSIE4_ID ,DIMENSIE5_ID);
COLLECT STATISTICS COLUMN (SUBSEGMENT) ON  Mi_temp.CUBe_benchmark_003;
COLLECT STATISTICS COLUMN (BEDRIJFSTAK_ID) ON Mi_temp.CUBe_benchmark_003;
COLLECT STATISTICS COLUMN (DIMENSIE4_ID) ON Mi_temp.CUBe_benchmark_003;
COLLECT STATISTICS COLUMN (DIMENSIE5_ID) ON Mi_temp.CUBe_benchmark_003;
COLLECT STATISTICS COLUMN (BUSINESS_LINE) ON Mi_temp.CUBe_benchmark_003;
COLLECT STATISTICS COLUMN (BUSINESS_LINE ,KLANT_NR ,MAAND_NR) ON Mi_temp.Mia_klanten;
COLLECT STATISTICS COLUMN (KLANT_NR) ON Mi_temp.Mia_klanten;
COLLECT STATISTICS COLUMN (BUSINESS_LINE) ON Mi_temp.Mia_klanten;

.IF ERRORCODE <> 0 THEN .GOTO EOP


CREATE TABLE Mi_temp.Mia_baten_benchmarken_001
      (
       Klant_nr INTEGER,
       Maand_nr INTEGER,
       CUBe_product_id INTEGER,
       Baten DECIMAL(18,2),

       Baten_benchmark DECIMAL(18,2),
       Penetratie DECIMAL(10,4),
       Min_verhouding DECIMAL(10,2),
       Min_benchmark DECIMAL(10,0),
       Min_penetratie DECIMAL(10,2),
       Adresseerbaarheid DECIMAL(10,2),
       Lichtbeheer BYTEINT
      )
UNIQUE PRIMARY INDEX ( Klant_nr, Maand_nr, CUBe_product_id )
INDEX ( Klant_nr )
INDEX ( Maand_nr )
INDEX ( CUBe_product_id );

.IF ERRORCODE <> 0 THEN .GOTO EOP


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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.Mia_baten_benchmarken_001 COLUMN ( Klant_nr, Maand_nr );
COLLECT STATISTICS Mi_temp.Mia_baten_benchmarken_001 COLUMN ( Lichtbeheer );


COLLECT STATISTICS COLUMN (KLANT_NR ,MAAND_NR ,CUBE_PRODUCT_ID, BATEN ,BATEN_BENCHMARK ,PENETRATIE ,MIN_VERHOUDING,MIN_BENCHMARK ,MIN_PENETRATIE ,ADRESSEERBAARHEID) ON Mi_temp.Mia_baten_benchmarken_001;
COLLECT STATISTICS COLUMN (MAAND_NR) ON Mi_temp.Mia_baten_benchmarken_001;
COLLECT STATISTICS COLUMN (KLANT_NR) ON Mi_temp.Mia_baten_benchmarken_001;
COLLECT STATISTICS COLUMN (LICHTBEHEER ,CUBE_PRODUCT_ID) ON Mi_temp.Mia_baten_benchmarken_001;
COLLECT STATISTICS COLUMN (CUBE_PRODUCT_ID) ON Mi_temp.Mia_baten_benchmarken_001;
COLLECT STATISTICS COLUMN (MAAND_NR) ON Mi_temp.Mia_baten_benchmarken_001;
COLLECT STATISTICS COLUMN (KLANT_NR ,MAAND_NR) ON Mi_temp.Mia_baten_benchmarken_001;
COLLECT STATISTICS COLUMN (LICHTBEHEER) ON Mi_temp.Mia_baten_benchmarken_001;

.IF ERRORCODE <> 0 THEN .GOTO EOP

CREATE TABLE Mi_temp.Mia_baten_benchmarken_002
      (
       Klant_nr INTEGER,
       Maand_nr INTEGER,
       CUBe_product_id INTEGER,
       Baten DECIMAL(18,2),

       Baten_benchmark DECIMAL(18,2),
       Penetratie DECIMAL(10,4),
       Min_verhouding DECIMAL(10,2),
       Min_benchmark DECIMAL(10,0),
       Min_penetratie DECIMAL(10,2),
       Adresseerbaarheid DECIMAL(10,2),
       Lichtbeheer BYTEINT
      )
UNIQUE PRIMARY INDEX ( Klant_nr, Maand_nr, CUBe_product_id )
INDEX ( Klant_nr )
INDEX ( Maand_nr )
INDEX ( CUBe_product_id );

.IF ERRORCODE <> 0 THEN .GOTO EOP

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
;INSERT INTO Mi_temp.Mia_baten_benchmarken_002
SELECT A.*
  FROM Mi_temp.Mia_baten_benchmarken_001 A
 WHERE A.CUBe_product_id IN (1, 9, 25, 26)
   AND A.Lichtbeheer NE 1;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.Mia_klanten COLUMN Business_line;
COLLECT STATISTICS Mi_temp.Mia_klanten COLUMN (Klant_nr);
COLLECT STATISTICS Mi_temp.Mia_klanten COLUMN Segment;
COLLECT STATISTICS COLUMN (BUSINESS_LINE ,KLANT_NR) ON Mi_temp.Mia_klanten;
COLLECT STATISTICS COLUMN (BC_NR) ON Mi_cmb.mia_markets_lnd;
COLLECT STATISTICS COLUMN (( CASE WHEN ((aantal_euribor_leningen > 0) AND (aantal_derivaten = 0 )) THEN (1) ELSE (0) END )) AS ST_030311360979_0_mia_markets_lnd ON Mi_cmb.mia_markets_lnd;
COLLECT STATISTICS COLUMN (maand_nr ,( CASE WHEN((aantal_derivaten > 0) AND (((ADD_MONTHS((max_maturity_date ),(36)))< laatste_afloop_datum) AND (aantal_euribor_leningen > 0 )))THEN (1) ELSE (0) END ),bc_nr) AS ST_220312544215_1_mia_markets_lnd ON Mi_cmb.mia_markets_lnd;
COLLECT STATISTICS COLUMN (( CASE WHEN ((aantal_derivaten > 0) AND (((ADD_MONTHS((max_maturity_date ),(36 )))< laatste_afloop_datum) AND (aantal_euribor_leningen > 0 ))) THEN (1) ELSE (0) END )) AS ST_220312544215_0_mia_markets_lnd ON Mi_cmb.mia_markets_lnd;
COLLECT STATISTICS COLUMN (COMMODITY ,BEDRIJFSTAK_ID) ON MI_SAS_AA_MB_C_MB.CUBe_bedrijfstak;
COLLECT STATISTICS COLUMN (BEDRIJFSTAK_ID) ON MI_SAS_AA_MB_C_MB.CUBe_bedrijfstak;
COLLECT STATISTICS COLUMN (COMMODITY) ON MI_SAS_AA_MB_C_MB.CUBe_bedrijfstak;
COLLECT STATISTICS COLUMN (KLANT_NR) ON Mi_temp.Mia_baten_benchmarken_002;
COLLECT STATISTICS COLUMN (BATEN) ON Mi_temp.Mia_baten_benchmarken_002;
COLLECT STATISTICS COLUMN (CUBE_PRODUCT_ID) ON Mi_temp.Mia_baten_benchmarken_002;
COLLECT STATISTICS COLUMN (CUBE_PRODUCT_ID ,CLUSTER_NR) ON Mi_cmb.CUBe_leads_hist;
COLLECT STATISTICS COLUMN (CUBE_PRODUCT_ID ,MAAND_NR) ON Mi_cmb.CUBe_leads_hist;
COLLECT STATISTICS COLUMN (RETENTIE_STOPLICHT ,KLANT_NR) ON MI_SAS_AA_MB_C_MB.Model_wegloop_hist;

.IF ERRORCODE <> 0 THEN .GOTO EOP

CREATE TABLE Mi_temp.Mia_baten_benchmarken_003
      (
       Klant_nr INTEGER,
       Maand_nr INTEGER,
       CUBe_product_id INTEGER,
       Baten DECIMAL(18,2),

       Baten_benchmark DECIMAL(18,2),
       Penetratie DECIMAL(10,4),
       Min_verhouding DECIMAL(10,2),
       Min_benchmark DECIMAL(10,0),
       Min_penetratie DECIMAL(10,2),
       Adresseerbaarheid DECIMAL(10,2),
       Lichtbeheer BYTEINT
      )
UNIQUE PRIMARY INDEX ( Klant_nr, Maand_nr, CUBe_product_id )
INDEX ( Klant_nr )
INDEX ( Maand_nr )
INDEX ( CUBe_product_id );

.IF ERRORCODE <> 0 THEN .GOTO EOP

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
;INSERT INTO Mi_temp.Mia_baten_benchmarken_003
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
;INSERT INTO Mi_temp.Mia_baten_benchmarken_003
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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.Mia_week COLUMN Verkorte_naam;
COLLECT STATISTICS Mi_temp.Mia_klanten COLUMN (Klant_nr, Maand_nr);

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.Mia_baten_benchmarken_002 COLUMN (Baten);
COLLECT STATISTICS Mi_temp.Mia_baten_benchmarken_003 COLUMN (CUBe_product_id);

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.Mia_baten_benchmarken_002 COLUMN (CUBe_product_id);

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.Mia_week COLUMN Klantstatus;

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Model_wegloop_hist COLUMN (Retentie_stoplicht);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Model_wegloop_hist COLUMN (Maand_nr, Retentie_stoplicht);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Model_wegloop_hist COLUMN (Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Model_wegloop_hist COLUMN Week_1e_retentie_stoplicht;
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Model_wegloop_hist COLUMN (Klant_nr, Week_1e_retentie_stoplicht);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.Model_wegloop_hist COLUMN Klant_nr;

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* BESTAANDE RETENTIELEADS, MITS NIET OUDER DAN 3 MAANDEN */
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
   AND XZ.Datum > ADD_MONTHS(XY.Datum, -3); /* NIET OUDER DAN 3 MAANDEN */
/* NIEUWE RETENTIELEADS */
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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS COLUMN (KLANT_NR ,MAAND_NR ,CUBE_PRODUCT_ID) ON Mi_temp.Mia_baten_benchmarken_003;
COLLECT STATISTICS COLUMN (KLANT_NR ,MAAND_NR ,CUBE_PRODUCT_ID) ON Mi_temp.Mia_baten_benchmarken_002;

.IF ERRORCODE <> 0 THEN .GOTO EOP

CREATE TABLE Mi_temp.Mia_baten_benchmarken_004
      (
       Klant_nr INTEGER,
       Maand_nr INTEGER,
       CUBe_product_id INTEGER,
       Baten DECIMAL(18,2),

       Baten_benchmark DECIMAL(18,2),
       Penetratie DECIMAL(10,4),
       Min_verhouding DECIMAL(10,2),
       Min_benchmark DECIMAL(10,0),
       Min_penetratie DECIMAL(10,2),
       Adresseerbaarheid DECIMAL(10,2),
       Lichtbeheer BYTEINT
      )
UNIQUE PRIMARY INDEX ( Klant_nr, Maand_nr, CUBe_product_id )
INDEX ( Klant_nr )
INDEX ( Maand_nr )
INDEX ( CUBe_product_id );

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.Mia_klantkoppelingen COLUMN (Business_contact_nr);
COLLECT STATISTICS Mi_temp.Mia_klantkoppelingen COLUMN (Maand_nr, Business_contact_nr);
COLLECT STATISTICS COLUMN (CUBE_PRODUCT_ID) ON Mi_temp.Mia_baten_benchmarken_004;
COLLECT STATISTICS COLUMN (MAAND_NR) ON Mi_temp.Mia_baten_benchmarken_004;
COLLECT STATISTICS COLUMN (KLANT_NR) ON Mi_temp.Mia_baten_benchmarken_004;
COLLECT STATISTICS COLUMN (KLANT_NR ,MAAND_NR ,CUBE_PRODUCT_ID) ON Mi_temp.Mia_baten_benchmarken_004;
COLLECT STATISTICS COLUMN (CUBE_PRODUCT_ID) ON Mi_temp.Mia_baten_benchmarken_004;
COLLECT STATISTICS COLUMN (MAAND_NR) ON Mi_temp.Mia_baten_benchmarken_004;
COLLECT STATISTICS COLUMN (KLANT_NR) ON Mi_temp.Mia_baten_benchmarken_004;
COLLECT STATISTICS COLUMN (KLANT_NR ,MAAND_NR,BUSINESS_CONTACT_NR) ON Mi_temp.Mia_klantkoppelingen;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS COLUMN (CUBE_PRODUCT_ID) ON MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW;
COLLECT STATISTICS COLUMN (KLANT_NR ,MAAND_NR ,CUBE_PRODUCT_ID) ON MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW;
COLLECT STATISTICS COLUMN (KLANT_NR) ON MI_SAS_AA_MB_C_MB.CUBe_leads_hist_NEW;

.IF ERRORCODE <> 0 THEN .GOTO EOP

CREATE TABLE Mi_temp.Mia_baten_benchmarken_005
      (
       Klant_nr INTEGER,
       Maand_nr INTEGER,
       CUBe_product_id INTEGER,
       UUID CHAR(36) CHARACTER SET LATIN NOT CASESPECIFIC,
       Baten DECIMAL(18,2),
       Baten_benchmark DECIMAL(18,2),
       Penetratie DECIMAL(10,4),
       Min_verhouding DECIMAL(10,2),
       Min_benchmark DECIMAL(10,0),
       Min_penetratie DECIMAL(10,2),
       Adresseerbaarheid DECIMAL(10,2),
       Lichtbeheer BYTEINT,
       Baten_potentieel DECIMAL(18,2),
       Baten_potentieel_adress DECIMAL(18,2),
       Status VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
       N_mnd_status INTEGER
      )
UNIQUE PRIMARY INDEX ( Klant_nr, Maand_nr, CUBe_product_id )
INDEX ( Klant_nr )
INDEX ( Maand_nr )
INDEX ( CUBe_product_id );

.IF ERRORCODE <> 0 THEN .GOTO EOP

-- koppelen leads aan reeds uitgeleverde leads op basis van Klant_nr, CUBe_product_id, maand_nr --> eerste 2 velden vormen ook de basis voor UUID
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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.Mia_baten_benchmarken_005 COLUMN (Klant_nr);
COLLECT STATISTICS Mi_temp.Mia_baten_benchmarken_005 COLUMN (Klant_nr, Maand_nr);
COLLECT STATISTICS Mi_temp.Mia_baten_benchmarken_005 COLUMN (UUID);
COLLECT STATISTICS Mi_temp.Mia_baten_benchmarken_005 COLUMN (UUID, Maand_nr);
COLLECT STATISTICS COLUMN (CUBE_PRODUCT_ID) ON Mi_temp.Mia_baten_benchmarken_005;
COLLECT STATISTICS COLUMN (KLANT_NR) ON Mi_temp.Mia_baten_benchmarken_005;
COLLECT STATISTICS COLUMN (STATUS) ON Mi_temp.Mia_baten_benchmarken_005;

.IF ERRORCODE <> 0 THEN .GOTO EOP

CREATE TABLE Mi_temp.Mia_baten_benchmarken_006
      (
       Klant_nr INTEGER,
       Baten DECIMAL(18,2),
       Baten_potentieel DECIMAL(18,2),
       Kredieten_baten DECIMAL(18,2),
       Kredieten_stoplicht BYTEINT,
       Kredieten_n_mnd_lead INTEGER,
       Kredieten_bmark DECIMAL(18,2),
       Kredieten_pen DECIMAL(10,4),
       Kredieten_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
       Lease_baten DECIMAL(18,2),
       Lease_stoplicht BYTEINT,
       Lease_n_mnd_lead INTEGER,
       Lease_bmark DECIMAL(18,2),
       Lease_pen DECIMAL(10,4),
       Lease_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
       Factoring_baten DECIMAL(18,2),
       Factoring_stoplicht BYTEINT,
       Factoring_n_mnd_lead INTEGER,
       Factoring_bmark DECIMAL(18,2),
       Factoring_pen DECIMAL(10,4),
       Factoring_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
       Creditgelden_baten DECIMAL(18,2),
       Creditgelden_stoplicht BYTEINT,
       Creditgelden_n_mnd_lead INTEGER,
       Creditgelden_bmark DECIMAL(18,2),
       Creditgelden_pen DECIMAL(10,4),
       Creditgelden_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
       Domestic_cash_baten DECIMAL(18,2),
       Domestic_cash_stoplicht BYTEINT,
       Domestic_cash_n_mnd_lead INTEGER,
       Domestic_cash_bmark DECIMAL(18,2),
       Domestic_cash_pen DECIMAL(10,4),
       Domestic_cash_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
       iDEAL_baten DECIMAL(18,2),
       iDEAL_stoplicht BYTEINT,
       iDEAL_n_mnd_lead INTEGER,
       iDEAL_bmark DECIMAL(18,2),
       iDEAL_pen DECIMAL(10,4),
       iDEAL_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
       International_cash_baten DECIMAL(18,2),
       International_cash_stoplicht BYTEINT,
       International_cash_n_mnd_lead INTEGER,
       International_cash_bmark DECIMAL(18,2),
       International_cash_pen DECIMAL(10,4),
       International_cash_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
       Cards_baten DECIMAL(18,2),
       Cards_stoplicht BYTEINT,
       Cards_n_mnd_lead INTEGER,
       Cards_bmark DECIMAL(18,2),
       Cards_pen DECIMAL(10,4),
       Cards_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
       Documentary_colcred_baten DECIMAL(18,2),
       Documentary_colcred_stoplicht BYTEINT,
       Documentary_colcred_n_mnd_lead INTEGER,
       Documentary_colcred_bmark DECIMAL(18,2),
       Documentary_colcred_pen DECIMAL(10,4),
       Documentary_colcred_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
       Garanties_baten DECIMAL(18,2),
       Garanties_stoplicht BYTEINT,
       Garanties_n_mnd_lead INTEGER,
       Garanties_bmark DECIMAL(18,2),
       Garanties_pen DECIMAL(10,4),
       Garanties_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
       Schade_baten DECIMAL(18,2),
       Schade_stoplicht BYTEINT,
       Schade_n_mnd_lead INTEGER,
       Schade_bmark DECIMAL(18,2),
       Schade_pen DECIMAL(10,4),
       Schade_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
       Leven_en_pensioen_baten DECIMAL(18,2),
       Leven_en_pensioen_stoplicht BYTEINT,
       Leven_en_pensioen_n_mnd_lead INTEGER,
       Leven_en_pensioen_bmark DECIMAL(18,2),
       Leven_en_pensioen_pen DECIMAL(10,4),
       Leven_en_pensioen_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
       Zorg_en_inkomen_baten DECIMAL(18,2),
       Zorg_en_inkomen_stoplicht BYTEINT,
       Zorg_en_inkomen_n_mnd_lead INTEGER,
       Zorg_en_inkomen_bmark DECIMAL(18,2),
       Zorg_en_inkomen_pen DECIMAL(10,4),
       Zorg_en_inkomen_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
       Rentederivaten_baten DECIMAL(18,2),
       Rentederivaten_stoplicht BYTEINT,
       Rentederivaten_n_mnd_lead INTEGER,
       Rentederivaten_bmark DECIMAL(18,2),
       Rentederivaten_pen DECIMAL(10,4),
       Rentederivaten_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
       Valutaderivaten_baten DECIMAL(18,2),
       Valutaderivaten_stoplicht BYTEINT,
       Valutaderivaten_n_mnd_lead INTEGER,
       Valutaderivaten_bmark DECIMAL(18,2),
       Valutaderivaten_pen DECIMAL(10,4),
       Valutaderivaten_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
       Effecten_baten DECIMAL(18,2),
       Effecten_stoplicht BYTEINT,
       Effecten_n_mnd_lead INTEGER,
       Effecten_bmark DECIMAL(18,2),
       Effecten_pen DECIMAL(10,4),
       Effecten_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
       Commodity_baten DECIMAL(18,2),
       Commodity_stoplicht BYTEINT,
       Commodity_n_mnd_lead INTEGER,
       Commodity_bmark DECIMAL(18,2),
       Commodity_pen DECIMAL(10,4),
       Commodity_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,

       Corp_finance_baten DECIMAL(18,2),
       Corp_finance_stoplicht BYTEINT,
       Corp_finance_n_mnd_lead INTEGER,
       Corp_finance_bmark DECIMAL(18,2),
       Corp_finance_pen DECIMAL(10,4),
       Corp_finance_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,

       CBI_cmts_signaal VARCHAR(50),
       CBI_cmts_baten DECIMAL(18,2),
       CBI_cmts_stoplicht BYTEINT,
       CBI_cmts_n_mnd_lead INTEGER, /* eigenlijk landen */
       CBI_cmts_bmark DECIMAL(18,2),
       CBI_cmts_pen DECIMAL(10,4),
       CBI_cmts_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
       CBI_kredieten_signaal VARCHAR(50),
       CBI_kredieten_baten DECIMAL(18,2),
       CBI_kredieten_stoplicht BYTEINT,
       CBI_kredieten_n_mnd_lead INTEGER, /* eigenlijk landen */
       CBI_kredieten_bmark DECIMAL(18,2),
       CBI_kredieten_pen DECIMAL(10,4),
       CBI_kredieten_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
       CBI_treasury_signaal VARCHAR(50),
       CBI_treasury_baten DECIMAL(18,2),
       CBI_treasury_stoplicht BYTEINT,
       CBI_treasury_n_mnd_lead INTEGER, /* eigenlijk landen */
       CBI_treasury_bmark DECIMAL(18,2),
       CBI_treasury_pen DECIMAL(10,4),
       CBI_treasury_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
       CBI_trade_signaal VARCHAR(50), /* eigenlijk landen */
       CBI_trade_baten DECIMAL(18,2),
       CBI_trade_stoplicht BYTEINT,
       CBI_trade_n_mnd_lead INTEGER, /* eigenlijk landen */
       CBI_trade_bmark DECIMAL(18,2),
       CBI_trade_pen DECIMAL(10,4),
       CBI_trade_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
       Acquisitie_baten DECIMAL(18,2),
       Acquisitie_stoplicht BYTEINT,
       Acquisitie_status VARCHAR(50),
       Acquisitie_bmark DECIMAL(18,2),
       Acquisitie_pen DECIMAL(10,4),
       Acquisitie_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
       Retentie_baten DECIMAL(18,2),
       Retentie_stoplicht BYTEINT,
       Retentie_status VARCHAR(50),
       Retentie_bmark DECIMAL(18,2),
       Retentie_pen DECIMAL(10,4),
       Retentie_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,

       PS_cmts BYTEINT,
       PS_factoring  BYTEINT,
       PS_lease BYTEINT,
       PS_markets BYTEINT,
       PS_verzekeren BYTEINT,
       PS_cbi BYTEINT
      )
UNIQUE PRIMARY INDEX ( Klant_nr);

.IF ERRORCODE <> 0 THEN .GOTO EOP


-- Status = 'nee' --> geen stoplicht (kan wel of niet zijn aangeleverd aan Siebel)
-- Status = 'ja'  --> stoplicht maar geen status dus niet aangeleverd aan Siebel of nog geen feedback uit Siebel
-- anders de Status obv feedback Siebel

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


.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS COLUMN (DATUM_INGELEZEN) ON Mi_cmb.CUBe_RM_oordeel;

.IF ERRORCODE <> 0 THEN .GOTO EOP

CREATE TABLE Mi_temp.CUBe_leadstatus
     (
      Klant_nr INTEGER,
      Maand_nr INTEGER,
      Datum_gegevens DATE FORMAT 'yyyy-mm-dd',
      Datum_baten DATE FORMAT 'yyyy-mm-dd',
      Datum_leads DATE FORMAT 'yyyy-mm-dd',
      Kredieten_n_mnd_lead INTEGER,
      Kredieten_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS (NULL, 'nee'),
      Lease_n_mnd_lead INTEGER,
      Lease_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS (NULL, 'nee'),
      Factoring_n_mnd_lead INTEGER,
      Factoring_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS (NULL, 'nee'),
      Creditgelden_n_mnd_lead INTEGER,
      Creditgelden_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS (NULL, 'nee'),
      Domestic_cash_n_mnd_lead INTEGER,
      Domestic_cash_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS (NULL, 'nee'),
      iDEAL_n_mnd_lead INTEGER,
      iDEAL_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS (NULL, 'nee'),
      International_cash_n_mnd_lead INTEGER,
      International_cash_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS (NULL, 'nee'),
      Cards_n_mnd_lead INTEGER,
      Cards_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS (NULL, 'nee'),
      Documentary_colcred_n_mnd_lead INTEGER,
      Documentary_colcred_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS (NULL, 'nee'),
      Garanties_n_mnd_lead INTEGER,
      Garanties_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS (NULL, 'nee'),
      Rentederivaten_n_mnd_lead INTEGER,
      Rentederivaten_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS (NULL, 'nee'),
      Valutaderivaten_n_mnd_lead INTEGER,
      Valutaderivaten_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS (NULL, 'nee'),
      Effecten_n_mnd_lead INTEGER,
      Effecten_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS (NULL, 'nee'),
      Commodity_n_mnd_lead INTEGER,
      Commodity_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS (NULL, 'nee'),
      Corp_finance_n_mnd_lead INTEGER,
      Corp_finance_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS (NULL, 'nee'),
      CBI_cmts_n_mnd_lead INTEGER,
      CBI_cmts_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS (NULL, 'nee'),
      Acquisitie_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS (NULL, 'nee'),
      Retentie_lead VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS (NULL, 'nee')
      )
UNIQUE PRIMARY INDEX ( Klant_nr, Maand_nr);

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP



/*************************************************************************************

    BASIS SET tabel CUBe_baten_hist

*************************************************************************************/

/* maak columns (zeker primary index columns) zo mogelijk NOT NULL
   COMPRESS zo veel mogelijk */

/* kopie */
CREATE TABLE MI_SAS_AA_MB_C_MB.CIAA_Cube_Baten_hist_NEW AS MI_SAS_AA_MB_C_MB.CIAA_Cube_Baten_hist WITH DATA
UNIQUE PRIMARY INDEX ( Klant_nr ,Maand_nr)
PARTITION BY ( RANGE_N(Maand_nr  BETWEEN 201001  AND 201012  EACH 1 ,
201101  AND 201112  EACH 1 ,
201201  AND 201212  EACH 1 ,
201301  AND 201312  EACH 1 ,
201401  AND 201412  EACH 1 ,
201501  AND 201512  EACH 1 ,
201601  AND 201612  EACH 1 ,
201701  AND 201712  EACH 1 ,
201801  AND 201812  EACH 1 ,
201901  AND 201912  EACH 1 ,
202001  AND 202012  EACH 1 ,
 NO RANGE, UNKNOWN));

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Cube_Baten_hist_NEW COLUMN (PARTITION);

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* WEEKCIJFERS VERWIJDEREN INDIEN MAAND REEDS AANWEZIG VAN VORIGE WEEK */
DELETE FROM MI_SAS_AA_MB_C_MB.CIAA_Cube_Baten_hist_NEW
WHERE maand_nr = (SEL Maand_nr FROM Mi_temp.Mia_week GROUP BY 1)
;
.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Cube_Baten_hist_NEW COLUMN (PARTITION);

.IF ERRORCODE <> 0 THEN .GOTO EOP


/* WEEKCIJFERS TOEVOEGEN */

INSERT INTO MI_SAS_AA_MB_C_MB.CIAA_Cube_Baten_hist_NEW
SELECT *
  FROM Mi_temp.CUBe_baten;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Cube_Baten_hist_NEW COLUMN (PARTITION);

COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Cube_Baten_hist_NEW COLUMN (Klant_nr, Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Cube_Baten_hist_NEW COLUMN (MAAND_NR);


/* actuele maand niet in samenv tabellen --> uiteindelijk meest recente hist data tonen in score views */
UPDATE MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr_NEW
SET Maand_nr_Cube_baten = (CASE  WHEN MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr_NEW.Maand_nr > (SEL MAX(Maand_nr) AS Maand_nr FROM MI_SAS_AA_MB_C_MB.CIAA_Cube_Baten_hist_NEW) THEN (SEL MAX(Maand_nr) AS Maand_nr FROM MI_SAS_AA_MB_C_MB.CIAA_Cube_Baten_hist_NEW)
                             ELSE MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr_NEW.Maand_nr
                         END)
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr_NEW;



.IF ERRORCODE <> 0 THEN .GOTO EOP

DELETE
  FROM Mi_cmb.CUBe_leadstatus_hist
 WHERE Maand_nr IN (SELECT Maand_nr FROM MI_SAS_AA_MB_C_MB.Mia_periode_NEW);

.IF ERRORCODE <> 0 THEN .GOTO EOP

INSERT INTO Mi_cmb.CUBe_leadstatus_hist
SELECT *
  FROM Mi_temp.CUBe_leadstatus;

.IF ERRORCODE <> 0 THEN .GOTO EOP

DELETE
  FROM MI_SAS_AA_MB_C_MB.CUBe_model
 WHERE Maand_nr IN (SELECT Maand_nr FROM MI_SAS_AA_MB_C_MB.Mia_periode_NEW);

.IF ERRORCODE <> 0 THEN .GOTO EOP

INSERT INTO MI_SAS_AA_MB_C_MB.CUBe_model
SELECT *
  FROM Mi_temp.CUBe_benchmark_003;

.IF ERRORCODE <> 0 THEN .GOTO EOP



/*************************************************************************************

   4. Advanced Analytics

*************************************************************************************/



/*************************************************************************************

   5. Zakelijk-Particuliere koppelingen

*************************************************************************************/



/*************************************************************************************

   6. Beleggen

*************************************************************************************/

/* BCnrs met zorgplicht signalen */

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS MI_temp.CIAA_Beleggen_t1 COLUMN (Klant_nr, Maand_nr);

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* AGGREGATIE KLANTINFORMATIE */

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
    ,NULL (DECIMAL(12,0)) AS Part_BC_nr

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

.IF ERRORCODE <> 0 THEN .GOTO EOP


/* VERWIJDER LEESTEKENS IN DOCUMENTNAAM */
UPDATE MI_temp.CIAA_Beleggen
SET Bediening_beleggen_naam =  TRIM(BOTH FROM Char_Subst(Bediening_beleggen_naam,'''',''))
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

UPDATE MI_temp.CIAA_Beleggen
SET Bediening_naam =  TRIM(BOTH FROM Char_Subst(Bediening_naam,'''',''))
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* UPDATE DISLOCATIE */
UPDATE MI_temp.CIAA_Beleggen
SET Dislocatie_beleggen = Word_subst(Dislocatie_beleggen, 'BELEGGINGSSPECIALISTEN', 'BA')
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

UPDATE MI_temp.CIAA_Beleggen
SET Dislocatie_beleggen = Word_subst(Dislocatie_beleggen, 'BELEGGINGSSPECIALSTEN', 'BA')
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

UPDATE MI_temp.CIAA_Beleggen
SET Dislocatie_beleggen = Word_subst(Dislocatie_beleggen, 'AMSTERDAM', 'Amsterdam')
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

UPDATE MI_temp.CIAA_Beleggen
SET Dislocatie_beleggen = Word_subst(Dislocatie_beleggen, 'BREDA', 'Breda')
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

UPDATE MI_temp.CIAA_Beleggen
SET Dislocatie_beleggen = Word_subst(Dislocatie_beleggen, 'DEN HAAG', 'Den Haag')
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

UPDATE MI_temp.CIAA_Beleggen
SET Dislocatie_beleggen = Word_subst(Dislocatie_beleggen, 'DORDRECHT', 'Dordrecht')
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

UPDATE MI_temp.CIAA_Beleggen
SET Dislocatie_beleggen = Word_subst(Dislocatie_beleggen, 'EINDHOVEN', 'Eindhoven')
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

UPDATE MI_temp.CIAA_Beleggen
SET Dislocatie_beleggen = Word_subst(Dislocatie_beleggen, 'GRONINGEN', 'Groningen')
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

UPDATE MI_temp.CIAA_Beleggen
SET Dislocatie_beleggen = Word_subst(Dislocatie_beleggen, 'HAARLEM', 'Haarlem')
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

UPDATE MI_temp.CIAA_Beleggen
SET Dislocatie_beleggen = Word_subst(Dislocatie_beleggen, 'HILVERSUM', 'Hilversum')
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

UPDATE MI_temp.CIAA_Beleggen
SET Dislocatie_beleggen = Word_subst(Dislocatie_beleggen, 'MAASTRICHT', 'Maastricht')
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

UPDATE MI_temp.CIAA_Beleggen
SET Dislocatie_beleggen = Word_subst(Dislocatie_beleggen, 'ROTTERDAM', 'Rotterdam')
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

UPDATE MI_temp.CIAA_Beleggen
SET Dislocatie_beleggen = Word_subst(Dislocatie_beleggen, 'VELP', 'Velp')
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

UPDATE MI_temp.CIAA_Beleggen
SET Dislocatie_beleggen = Word_subst(Dislocatie_beleggen, 'ZEIST', 'Zeist')
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

UPDATE MI_temp.CIAA_Beleggen
SET Dislocatie_beleggen = Word_subst(Dislocatie_beleggen, 'ALKMAAR', 'Alkmaar')
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* kopie */
CREATE TABLE MI_SAS_AA_MB_C_MB.CIAA_beleggen_NEW AS MI_SAS_AA_MB_C_MB.CIAA_beleggen WITH DATA
UNIQUE PRIMARY INDEX ( Klant_nr ,Maand_nr)
PARTITION BY (
               RANGE_N(maand_nr  BETWEEN
                      201001  AND 201012  EACH 1,
                      201101  AND 201112  EACH 1,
                      201201  AND 201212  EACH 1,
                      201301  AND 201312  EACH 1,
                      201401  AND 201412  EACH 1,
                      201501  AND 201512  EACH 1,
                      201601  AND 201612  EACH 1,
                      201701  AND 201712  EACH 1,
                      201801  AND 201812  EACH 1,
                      201901  AND 201912  EACH 1,
                      202001  AND 202012  EACH 1,
                      NO RANGE,
                      UNKNOWN))
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_beleggen_NEW COLUMN (PARTITION);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_beleggen_NEW COLUMN (Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_beleggen_NEW COLUMN (Klant_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_beleggen_NEW COLUMN (Klant_nr, Maand_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_beleggen_NEW COLUMN (Klant_nr, Maand_nr);

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* weekdata actuele maand verwijderen */
DELETE FROM MI_SAS_AA_MB_C_MB.CIAA_beleggen_NEW
WHERE MI_SAS_AA_MB_C_MB.CIAA_beleggen_NEW.Maand_nr = MI_temp.CIAA_Beleggen.Maand_nr
;

.IF ERRORCODE <> 0 THEN .GOTO EOP


/* nieuwe data toevoegen */
INSERT INTO MI_SAS_AA_MB_C_MB.CIAA_beleggen_NEW
SELECT
        a.*
FROM MI_temp.CIAA_Beleggen    a
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS ON MI_SAS_AA_MB_C_MB.CIAA_beleggen_NEW;

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* maand_nr gegevens */
UPDATE MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr_NEW
SET Maand_nr_beleggen = (CASE  WHEN MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr_NEW.Maand_nr > (SEL MAX(Maand_nr) AS Maand_nr FROM MI_SAS_AA_MB_C_MB.CIAA_beleggen_NEW) THEN (SEL MAX(Maand_nr) AS Maand_nr FROM MI_SAS_AA_MB_C_MB.CIAA_beleggen_NEW)
                             ELSE MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr_NEW.Maand_nr
                       END                       )
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS MI_SAS_AA_MB_C_MB.CIAA_Mia_MaandNr_NEW;

.IF ERRORCODE <> 0 THEN .GOTO EOP


/*************************************************************************************

   7. Kredieten

*************************************************************************************/

/* Mia_kredieten_hfd uitgefaseerd */


/*************************************************************************************

   9. KEM pijplijn

*************************************************************************************/

/*-----------------------------------------
KEM faciliteiten
-----------------------------------------*/

/* view mi_vm_load.vTWK_3_FACILITEITEN wel eens leeg waardoor het schedule klapt/KEM tabellen leeg zijn. vandaar onderstaande sql */
CREATE SET TABLE Mi_temp.CIAA_TWK_3_FAC ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      Recent_ind BYTEINT,
      Datum_gegevens DATE FORMAT 'YYYY-MM-DD',
      fk_aanvr_wkmid DECIMAL(18,0),
      fk_aanvr_versie SMALLINT,
      fk_voorstel_ver SMALLINT,
      rc_bestaande_kredi DECIMAL(12,0),
      rc_gewenste_kredie DECIMAL(12,0),
      rc_bestaande_kred0 DECIMAL(12,0),
      rc_gewenste_kredi0 DECIMAL(12,0),
      bestaande_leningen DECIMAL(12,0),
      gewenste_leningen DECIMAL(12,0),
      bestaande_lease_aa DECIMAL(12,0),
      gewenste_lease_aa DECIMAL(12,0),
      bestaande_obsi_vta DECIMAL(12,0),
      gewenste_obsi_vta DECIMAL(12,0),
      totaal_faciliteite DECIMAL(14,0),
      totaal_faciliteit0 DECIMAL(14,0),
      samenhang_facilite DECIMAL(12,0),
      samenhang_facilit0 DECIMAL(12,0),
      samenhang_facilit1 CHAR(120) CHARACTER SET LATIN NOT CASESPECIFIC,
      totaal_one_obligor DECIMAL(14,0),
      totaal_one_obligo0 DECIMAL(14,0),
      ml_lening_lease_3e DECIMAL(12,0),
      ml_lening_lease_30 DECIMAL(12,0),
      ml_lening_lease_31 CHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
      rc_bestaande_krd_t DECIMAL(14,0),
      gewenste_extra_afl DECIMAL(12,0),
      notatie_vorm SMALLINT,
      date_time_created CHAR(26) CHARACTER SET LATIN NOT CASESPECIFIC,
      userid_created CHAR(8) CHARACTER SET LATIN NOT CASESPECIFIC,
      date_time_last_upd CHAR(26) CHARACTER SET LATIN NOT CASESPECIFIC,
      userid_last_update CHAR(8) CHARACTER SET LATIN NOT CASESPECIFIC,
      bsk_dekkingstekort DECIMAL(12,0),
      max_bsk DECIMAL(12,0),
      totaal_6_maand_afl DECIMAL(12,0),
      totaal_kredieten_b DECIMAL(14,0),
      totaal_kredieten_g DECIMAL(14,0),
      bestaande_len_extr DECIMAL(12,0),
      bestde_mddr_limiet DECIMAL(12,0),
      gewnst_mddr_limiet DECIMAL(12,0))
UNIQUE PRIMARY INDEX (Recent_ind,fk_aanvr_wkmid,fk_aanvr_versie );


.IF ERRORCODE <> 0 THEN .GOTO EOP
    /* data van vorige week */
INSERT INTO Mi_temp.CIAA_TWK_3_FAC
SELECT
       0
      ,a.*
FROM MI_SAS_AA_MB_C_MB.CIAA_TWK_3_FAC a
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* meest recente data */
/* onderstaande sql kan stuklopen vanwege ontbreken tabel, script moet dan echter niet worden afgebroken */
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
/*.IF ERRORCODE <> 0 THEN .GOTO EOP*/


DEL FROM MI_SAS_AA_MB_C_MB.CIAA_TWK_3_FAC
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* neem bij voorkeur de meest recente data, indien ontbrekend de data van vorige week */
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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS COLUMN (FK_AANVR_WKMID) ON MI_SAS_AA_MB_C_MB.CIAA_TWK_3_FAC;
COLLECT STATISTICS COLUMN (FK_AANVR_WKMID ,FK_AANVR_VERSIE) ON MI_SAS_AA_MB_C_MB.CIAA_TWK_3_FAC;

.IF ERRORCODE <> 0 THEN .GOTO EOP

/*************************************************************************************

   9. KEM pijplijn

*************************************************************************************/

CREATE TABLE Mi_temp.KEM_funnel_rapp_moment
      (
       Maand_Nr            INTEGER,
       Maand_sdat          DATE FORMAT 'YYYYMMDD',
       Maand_edat          DATE FORMAT 'YYYYMMDD',
       Maand_edat_timestmp TIMESTAMP(6),
       KEM_gegevens_datum  DATE FORMAT 'YYYYMMDD',
       KEM_gegevens_timestmp TIMESTAMP(6),
       Maand_NrLm        INTEGER,
       Maand_Lm_sdat     DATE FORMAT 'YYYYMMDD',
       Maand_Lm_edat     DATE FORMAT 'YYYYMMDD',
       Maand_NrL3m        INTEGER,
       Maand_L3m_sdat     DATE FORMAT 'YYYYMMDD',
       Maand_L3m_edat     DATE FORMAT 'YYYYMMDD',
       Maand_NrL6m        INTEGER,
       Maand_L6m_sdat     DATE FORMAT 'YYYYMMDD',
       Maand_L6m_edat     DATE FORMAT 'YYYYMMDD',
       Maand_NrL12m        INTEGER,
       Maand_L12m_sdat     DATE FORMAT 'YYYYMMDD',
       Maand_L12m_edat     DATE FORMAT 'YYYYMMDD',
       Max_maand_Mia_kred  INTEGER
       )
UNIQUE PRIMARY INDEX ( Maand_nr )
;

.IF ERRORCODE <> 0 THEN .GOTO EOP


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

.IF ERRORCODE <> 0 THEN .GOTO EOP

UPDATE  Mi_temp.KEM_funnel_rapp_moment
FROM
     (
     SEL MAX(a.Maand_nr) AS Maand_nr
     FROM mi_cmb.vCIF_complex_MF a

     INNER JOIN Mi_temp.KEM_funnel_rapp_moment per
        ON 1 = 1

     WHERE  a.Maand_nr <= per.Maand_nr
     ) a

SET Max_maand_Mia_kred = a.Maand_nr
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.KEM_funnel_rapp_moment COLUMN Maand_Nr;
COLLECT STATISTICS Mi_temp.KEM_funnel_rapp_moment COLUMN Maand_sdat;
COLLECT STATISTICS Mi_temp.KEM_funnel_rapp_moment COLUMN Maand_edat;
COLLECT STATISTICS Mi_temp.KEM_funnel_rapp_moment COLUMN Maand_NrLm;
COLLECT STATISTICS Mi_temp.KEM_funnel_rapp_moment COLUMN Maand_Lm_sdat;
COLLECT STATISTICS Mi_temp.KEM_funnel_rapp_moment COLUMN Maand_Lm_edat;
COLLECT STATISTICS Mi_temp.KEM_funnel_rapp_moment COLUMN Maand_NrL3m;
COLLECT STATISTICS Mi_temp.KEM_funnel_rapp_moment COLUMN Maand_L3m_sdat;
COLLECT STATISTICS Mi_temp.KEM_funnel_rapp_moment COLUMN Maand_L3m_edat;
COLLECT STATISTICS Mi_temp.KEM_funnel_rapp_moment COLUMN Maand_NrL6m;
COLLECT STATISTICS Mi_temp.KEM_funnel_rapp_moment COLUMN Maand_L6m_sdat;
COLLECT STATISTICS Mi_temp.KEM_funnel_rapp_moment COLUMN Maand_L6m_edat;
COLLECT STATISTICS Mi_temp.KEM_funnel_rapp_moment COLUMN Maand_NrL12m;
COLLECT STATISTICS Mi_temp.KEM_funnel_rapp_moment COLUMN Maand_L12m_sdat;
COLLECT STATISTICS Mi_temp.KEM_funnel_rapp_moment COLUMN Maand_L12m_edat;
COLLECT STATISTICS Mi_temp.KEM_funnel_rapp_moment COLUMN Max_maand_Mia_kred;
COLLECT STATISTICS Mi_temp.KEM_funnel_rapp_moment COLUMN KEM_gegevens_datum;
COLLECT STATISTICS Mi_temp.KEM_funnel_rapp_moment COLUMN KEM_gegevens_timestmp;

.IF ERRORCODE <> 0 THEN .GOTO EOP

/***************************************************************

        Per aanvraag alles statussen van de LAATSTE versie (nieuwe versie bij een rebound)

***************************************************************/


/* alle aanvragen per versie chronologisch volgnr toekenen
   !! bij een rebound wordt een nieuw versienr toegekend. Per nieuwe versie wordt (meestal) wel de 1e AANVRAAG versie overgenomen met de initiele creatiedatum !! */

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.KEM_funnel_t1a COLUMN FK_AANVR_WKMID;

.IF ERRORCODE <> 0 THEN .GOTO EOP


/* initiele datum uit de aanvraag (vTWK_3_KREDIET_AANV) ophalen, deze kan voor de 1e datum in (TWK_3_KRD_V_STAT) liggen */

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.KEM_funnel_t1b COLUMN (FK_AANVR_VERSIE, VOLGNR_CHRONO_OLD_NEW);
COLLECT STATISTICS Mi_temp.KEM_funnel_t1b COLUMN DATE_CREATED_STAP;
COLLECT STATISTICS Mi_temp.KEM_funnel_t1b COLUMN (FK_AANVR_WKMID, FK_AANVR_VERSIE);
COLLECT STATISTICS Mi_temp.KEM_funnel_t1b COLUMN (FK_AANVR_WKMID, DATE_CREATED_STAP);
COLLECT STATISTICS Mi_temp.KEM_funnel_t1b COLUMN (FK_AANVR_WKMID);

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* indien de aanvraagdatum uit de aanvraag gelijk is aan de creatie datum van de eerste stap uit de eerste versie dan de Timestamp uit de status tabel overnemen
   in het aanvraagbestand zit namelijk geen timestamp */
UPDATE Mi_temp.KEM_funnel_t1b
FROM
     (
     SEL  a.FK_AANVR_WKMID
        , a.Timestamp_created_stap
     FROM  Mi_temp.KEM_funnel_t1b       a
     WHERE a.Volgnr_chrono_old_new = 1                         /* eerste stap                                             */
       AND a.FK_AANVR_VERSIE = 1                               /* van eerste versie                                       */
       AND a.Date_created_stap = a.Date_aanvraag               /* creatie en aanvraag DATUM gelijk                        */
       AND a.Timestamp_created_stap <> a.Timestamp_aanvraag    /* dan creatie timestamp stap als aanvraag timestamp nemen */
     GROUP BY 1,2
     ) a

SET Timestamp_aanvraag = a.Timestamp_created_stap
WHERE Mi_temp.KEM_funnel_t1b.FK_AANVR_WKMID = a.FK_AANVR_WKMID
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.KEM_funnel_t1b;

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* Selecteren relevante aanvraag versies mbt rapportagemaand */

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.KEM_funnel_t1c COLUMN (FK_AANVR_WKMID, FK_AANVR_VERSIE ,FUNNEL_STAP ,FUNNEL_STAP_NR);

.IF ERRORCODE <> 0 THEN .GOTO EOP


/* Naar soort pijplijn opsplitsen */
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

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP


/* DLT obv KEM stappen */
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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATS Mi_temp.KEM_funnel_t2 COLUMN (fk_aanvr_wkmid, fk_aanvr_versie, Soort_pijplijn, Volgnr_chrono_new_old);
COLLECT STATS Mi_temp.KEM_funnel_t2 COLUMN (Volgnr_chrono_new_old);

.IF ERRORCODE <> 0 THEN .GOTO EOP



/* Indicatie of laatste KEM status in rapportage maand actueel is.
   Actueel indien:
    - status ongelijk aan Afgesloten of Afgebroken
    of
    - status Afgesloten of Afgebroken en date_created_stap in rapportage maand
*/

UPDATE Mi_temp.KEM_funnel_t2
FROM
     (
     SEL  a.fk_aanvr_wkmid
         ,a.fk_aanvr_versie
         ,a.Soort_pijplijn
         ,CASE WHEN a.Status_nr >=89  AND a.Date_created_stap < per.Maand_sdat THEN 0
               ELSE 1
          END AS Stap_actueel_indX

     FROM Mi_temp.KEM_funnel_t2 a

     INNER JOIN Mi_temp.KEM_funnel_rapp_moment per
        ON 1 = 1

     WHERE a.Volgnr_chrono_new_old = 1
       AND Stap_actueel_indX = 1
     ) a

SET Stap_actueel_ind = a.Stap_actueel_indX
WHERE Mi_temp.KEM_funnel_t2.fk_aanvr_wkmid = a.fk_aanvr_wkmid
  AND Mi_temp.KEM_funnel_t2.fk_aanvr_versie = a.fk_aanvr_versie
  AND Mi_temp.KEM_funnel_t2.Soort_pijplijn = a.Soort_pijplijn
  AND Mi_temp.KEM_funnel_t2.Volgnr_chrono_new_old = 1
;

.IF ERRORCODE <> 0 THEN .GOTO EOP


/* Indicatie of laatste KEM status in afgelopen 3 mnd actueel is.
   Actueel indien:
    - status ongelijk aan Afgesloten of Afgebroken
    of
    - status Afgesloten of Afgebroken en date_created_stap in rapportage maand
*/

UPDATE Mi_temp.KEM_funnel_t2
FROM
     (
     SEL  a.fk_aanvr_wkmid
         ,a.fk_aanvr_versie
         ,a.Soort_pijplijn
         ,a.Volgnr_chrono_new_old
         ,1 AS Stap_3mnd_indX

     FROM Mi_temp.KEM_funnel_t2 a

     INNER JOIN Mi_temp.KEM_funnel_rapp_moment per
        ON 1 = 1

     WHERE (a.Date_created_stap > per.Maand_L3m_edat         /* alles afgelopen 3 maanden created */

            OR (a.Date_created_stap <= per.Maand_L3m_edat    /* ouder dan 3 maanden, MAAR         */
                AND a.Volgnr_chrono_new_old = 1              /* het is de meest recente versie    */
                AND ZEROIFNULL(a.Status_nr) < 89             /* die niet afgesloten/afgebroken is */
                )
            )
     ) a

SET Stap_3mnd_ind = a.Stap_3mnd_indX
WHERE Mi_temp.KEM_funnel_t2.fk_aanvr_wkmid = a.fk_aanvr_wkmid
  AND Mi_temp.KEM_funnel_t2.fk_aanvr_versie = a.fk_aanvr_versie
  AND Mi_temp.KEM_funnel_t2.Soort_pijplijn = a.Soort_pijplijn
  AND Mi_temp.KEM_funnel_t2.Volgnr_chrono_new_old = a.Volgnr_chrono_new_old
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* Indicatie of laatste KEM status in afgelopen 6 mnd actueel is.
   Actueel indien:
    - status ongelijk aan Afgesloten of Afgebroken
    of
    - status Afgesloten of Afgebroken en date_created_stap in rapportage maand
*/

UPDATE Mi_temp.KEM_funnel_t2
FROM
     (
     SEL  a.fk_aanvr_wkmid
         ,a.fk_aanvr_versie
         ,a.Soort_pijplijn
         ,a.Volgnr_chrono_new_old
         ,1 AS Stap_6mnd_indX

     FROM Mi_temp.KEM_funnel_t2 a

     INNER JOIN Mi_temp.KEM_funnel_rapp_moment per
        ON 1 = 1

     WHERE (a.Date_created_stap > per.Maand_L6m_edat         /* alles afgelopen 6 maanden created */

            OR (a.Date_created_stap <= per.Maand_L6m_edat    /* ouder dan 6 maanden, MAAR         */
                AND a.Volgnr_chrono_new_old = 1              /* het is de meest recente versie    */
                AND ZEROIFNULL(a.Status_nr) < 89             /* die niet afgesloten/afgebroken is */
                )
            )
     ) a

SET Stap_6mnd_ind = a.Stap_6mnd_indX
WHERE Mi_temp.KEM_funnel_t2.fk_aanvr_wkmid = a.fk_aanvr_wkmid
  AND Mi_temp.KEM_funnel_t2.fk_aanvr_versie = a.fk_aanvr_versie
  AND Mi_temp.KEM_funnel_t2.Soort_pijplijn = a.Soort_pijplijn
  AND Mi_temp.KEM_funnel_t2.Volgnr_chrono_new_old = a.Volgnr_chrono_new_old
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* Indicatie of laatste KEM status in afgelopen 12 mnd actueel is.
   Actueel indien:
    - status ongelijk aan Afgesloten of Afgebroken
    of
    - status Afgesloten of Afgebroken en date_created_stap in rapportage maand
*/

UPDATE Mi_temp.KEM_funnel_t2
FROM
     (
     SEL  a.fk_aanvr_wkmid
         ,a.fk_aanvr_versie
         ,a.Soort_pijplijn
         ,a.Volgnr_chrono_new_old
         ,1 AS Stap_12mnd_indX

     FROM Mi_temp.KEM_funnel_t2 a

     INNER JOIN Mi_temp.KEM_funnel_rapp_moment per
        ON 1 = 1

     WHERE (a.Date_created_stap > per.Maand_L12m_edat        /* alles afgelopen 12 maanden created */

            OR (a.Date_created_stap <= per.Maand_L12m_edat   /* ouder dan 12 maanden, MAAR         */
                AND a.Volgnr_chrono_new_old = 1              /* het is de meest recente versie     */
                AND ZEROIFNULL(a.Status_nr) < 89             /* die niet afgesloten/afgebroken is  */
                )
            )
     ) a

SET Stap_12mnd_ind = a.Stap_12mnd_indX
WHERE Mi_temp.KEM_funnel_t2.fk_aanvr_wkmid = a.fk_aanvr_wkmid
  AND Mi_temp.KEM_funnel_t2.fk_aanvr_versie = a.fk_aanvr_versie
  AND Mi_temp.KEM_funnel_t2.Soort_pijplijn = a.Soort_pijplijn
  AND Mi_temp.KEM_funnel_t2.Volgnr_chrono_new_old = a.Volgnr_chrono_new_old
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATS Mi_temp.KEM_funnel_t2 COLUMN (fk_aanvr_wkmid, fk_aanvr_versie, Soort_pijplijn);
COLLECT STATS Mi_temp.KEM_funnel_t2 COLUMN (fk_aanvr_wkmid, fk_aanvr_versie);
COLLECT STATS Mi_temp.KEM_funnel_t2 COLUMN (Volgnr_chrono_old_new);
COLLECT STATS Mi_temp.KEM_funnel_t2 COLUMN fk_aanvr_wkmid;
COLLECT STATS Mi_temp.KEM_funnel_t2 COLUMN Stap_actueel_ind;

.IF ERRORCODE <> 0 THEN .GOTO EOP


/***************************************************************

        hulptabellen (overgenomen uit Script mia_kredieten_KEM.sql)

***************************************************************/


/* KEM / financieringsoverzicht
   Financiering_lang = Faciliteit_kort + OBSI + Leningen_lang
*/

CREATE TABLE Mi_temp.KEM_funnel_faciliteit
    (
      fk_aanvr_wkmid                DECIMAL(21,0)
    , fk_aanvr_versie               INTEGER
    , Faciliteit_kort_bestaand      DECIMAL(12,0)
    , Faciliteit_kort_gevraagd      DECIMAL(12,0)
    , OBSI_bestaand                 DECIMAL(12,0)
    , OBSI_gevraagd                 DECIMAL(12,0)
    , Lease_AA_bestaand             DECIMAL(12,0)
    , Lease_AA_gevraagd             DECIMAL(12,0)
    , Leningen_lang_bestaand        DECIMAL(12,0)
    , Leningen_lang_gevraagd        DECIMAL(12,0)
    , Financiering_lang_bestaand    DECIMAL(12,0)
    , Financiering_lang_gevraagd    DECIMAL(12,0)
    , One_Obligor_lang_bestaand     DECIMAL(12,0)
    , One_Obligor_lang_gevraagd     DECIMAL(12,0)
    , Totaal6mnds_aflossing         DECIMAL(12,0)
    , BSK_max                       DECIMAL(12,0)
    , BSK_dekkingstekort            DECIMAL(12,0)
    )
UNIQUE PRIMARY INDEX ( fk_aanvr_wkmid, fk_aanvr_versie )
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.KEM_funnel_faciliteit COLUMN (FK_AANVR_WKMID, FK_AANVR_VERSIE);

.IF ERRORCODE <> 0 THEN .GOTO EOP


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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.KEM_funnel_jaarrekening COLUMN (FK_AANVR_WKMID, FK_AANVR_VERSIE);

.IF ERRORCODE <> 0 THEN .GOTO EOP

CREATE TABLE mi_temp.KEM_funnel_PRCDTL_KRDVS
    (fk_aanvr_wkmid                  DECIMAL(21,0),
     fk_aanvr_versie                 INTEGER,
     RARORAC_indicatief              DECIMAL (16,4),
     RARORAC_fiat                    DECIMAL (16,4),
     RARORAC_offerte                 DECIMAL (16,4),
     RARORAC_geaccepteerd            DECIMAL (16,4),
     RARORAC                         DECIMAL (16,4),
     EP_indicatief                   DECIMAL (16,4),
     EP_fiat                         DECIMAL (16,4),
     EP_offerte                      DECIMAL (16,4),
     EP_geaccepteerd                 DECIMAL (16,4),
     EP                              DECIMAL (16,4),
     UCR_indicatief                  CHAR(2),
     UCR_fiat                        CHAR(2),
     UCR_offerte                     CHAR(2),
     UCR_geaccepteerd                CHAR(2),
     UCR                             CHAR(2),
     Client_RARORAC_indicatief         DECIMAL(16,4),
     Client_RARORAC_fiat             DECIMAL(16,4),
     Client_RARORAC_offerte          DECIMAL(16,4),
     Client_RARORAC_geaccepteerd     DECIMAL(16,4),
     Client_EP_indicatief             DECIMAL(16,4),
     Client_EP_fiat                     DECIMAL(16,4),
     Client_EP_offerte                 DECIMAL(16,4),
     Client_EP_geaccepteerd          DECIMAL(16,4),
     EC_indicatief                     DECIMAL(16,4),
     EC_fiat                         DECIMAL(16,4),
     EC_offerte                         DECIMAL(16,4),
     EC_geaccepteerd                 DECIMAL(16,4),
     Inkomsten_totaal_indicatief     DECIMAL(16,4),
     Inkomsten_totaal_fiat             DECIMAL(16,4),
     Inkomsten_totaal_offerte         DECIMAL(16,4),
     Inkomsten_totaal_geaccepteerd     DECIMAL(16,4),
     Client_AAEBREFFECT_TO_ind         DECIMAL(16,4),
     Client_AAEBREFFECT_TO_fiat         DECIMAL(16,4),
     Client_AAEBREFFECT_TO_offerte     DECIMAL(16,4),
     Client_AAEBREFFECT_TO_geacc     DECIMAL(16,4),
     Client_inkomsten_totaal_ind     DECIMAL(16,4),
     Client_inkomsten_totaal_fiat     DECIMAL(16,4),
     Client_inkomsten_totaal_off     DECIMAL(16,4),
     Client_inkomsten_totaal_geacc   DECIMAL(16,4),
     Client_optiekosten_indicatief     DECIMAL(16,4),
     Client_optiekosten_fiat         DECIMAL(16,4),
     Client_optiekosten_offerte         DECIMAL(16,4),
     Client_optiekosten_geacc        DECIMAL(16,4),
     Client_belastingen_indicatief     DECIMAL(16,4),
     Client_belastingen_fiat         DECIMAL(16,4),
     Client_belastingen_offerte         DECIMAL(16,4),
     Client_belastingen_geacc        DECIMAL(16,4),
     Client_exp_loss_indicatief         DECIMAL(16,4),
     Client_exp_loss_fiat            DECIMAL(16,4),
     Client_exp_loss_offerte         DECIMAL(16,4),
     Client_exp_loss_geaccepteerd     DECIMAL(16,4),
     Client_EC_indicatief             DECIMAL(16,4),
     Client_EC_fiat                     DECIMAL(16,4),
     Client_EC_offerte                 DECIMAL(16,4),
     Client_EC_geaccepteerd             DECIMAL(16,4),
     Client_oper_kosten_indicatief     DECIMAL(16,4),
     Client_oper_kosten_fiat         DECIMAL(16,4),
     Client_oper_kosten_offerte         DECIMAL(16,4),
     Client_oper_kosten_geacc         DECIMAL(16,4),
     Client_result_na_bel_ind         DECIMAL(16,4),
     Client_result_na_bel_fiat         DECIMAL(16,4),
     Client_result_na_bel_offerte     DECIMAL(16,4),
     Client_result_na_bel_geacc         DECIMAL(16,4)
    )
UNIQUE PRIMARY INDEX ( fk_aanvr_wkmid, fk_aanvr_versie )
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATS mi_temp.KEM_funnel_PRCDTL_KRDVS INDEX ( fk_aanvr_wkmid, fk_aanvr_versie );

.IF ERRORCODE <> 0 THEN .GOTO EOP

CREATE TABLE Mi_temp.KEM_funnel_KENMERK_P_KR
    (
     fk_aanvr_wkmid                DECIMAL(21,0),
     fk_aanvr_versie               INTEGER,
     Type_krediet_code             VARCHAR (5),
     Type_Doelgroep                CHAR(3),
     Type_VST                      CHAR(3)
    )
UNIQUE PRIMARY INDEX ( fk_aanvr_wkmid, fk_aanvr_versie )
;

.IF ERRORCODE <> 0 THEN .GOTO EOP


/* wanneer sprake van XL? Indien type XL aanwezig? (aanvraag kan meerdere typen tegelijk hebben (bv. MBO, COOG, MKN, APT, fk_aanvr_wkmid = 130822142542712922 ) */
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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATS Mi_temp.KEM_funnel_KENMERK_P_KR INDEX ( fk_aanvr_wkmid, fk_aanvr_versie );
COLLECT STATISTICS COLUMN (VOLGNR_CHRONO_NEW_OLD,FK_AANVR_WKMID ,SOORT_PIJPLIJN) ON Mi_temp.KEM_funnel_t2;
COLLECT STATISTICS COLUMN (SOORT_PIJPLIJN) ON Mi_temp.KEM_funnel_t2;
COLLECT STATISTICS COLUMN (FK_AANVR_VERSIE) ON Mi_temp.KEM_funnel_t2;
COLLECT STATISTICS COLUMN (VOLGNR_CHRONO_NEW_OLD ,SOORT_PIJPLIJN) ON Mi_temp.KEM_funnel_t2;
COLLECT STATISTICS COLUMN (DATE_CREATED_STAP) ON Mi_temp.KEM_funnel_t2;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS COLUMN (TD_SYSFNLIB.TO_NUMBER (TRANSLATE((Fac_BC_nr )USING LATIN_TO_UNICODE)(VARCHAR(32000), CHARACTER SET UNICODE, NOT CASESPECIFIC))) AS ST_260411063105_3_CIF_Complex ON Mi_cmb.CIF_Complex;
COLLECT STATISTICS COLUMN (ZEROIFNULL(TD_SYSFNLIB.TO_NUMBER (TRANSLATE((Hoofdrekening )USING LATIN_TO_UNICODE)(VARCHAR(32000), CHARACTER SET UNICODE, NOT CASESPECIFIC)))) AS ST_260411063105_1_CIF_Complex ON Mi_cmb.CIF_Complex;
COLLECT STATISTICS COLUMN (DATE_AANVRAAG) ON  Mi_temp.KEM_funnel_t2;

/* detail info aanvraagversie */
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

.IF ERRORCODE <> 0 THEN .GOTO EOP

/*************************************************************************************/

CREATE SET TABLE MI_SAS_AA_MB_C_MB.KEM_pijplijn_NEW ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      FK_AANVR_WKMID DECIMAL(18,0),
      FK_AANVR_VERSIE SMALLINT,
      Maand_nr INTEGER,
      Datum_KEM_gegevens DATE FORMAT 'YY/MM/DD',
      Soort_pijplijn CHAR(6) CHARACTER SET UNICODE NOT CASESPECIFIC,
      Status VARCHAR(40) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS('AFGESLOTEN','Voorstel maken','AFGEBROKEN','AANVRAAG','Voorstel bekrachtigen & Fiatteren','BEKRACHTIGING AANGEBODEN','BEKRACHTIGD','GEFIATTEERD','FIAT AANGEBODEN','TER CONTROLE AANGEBODEN'),
      Status_nr INTEGER,
      Timestamp_created_stap TIMESTAMP(6),
      Date_created_stap DATE FORMAT 'YY/MM/DD',
      Volgnr_chrono_old_new INTEGER,
      Volgnr_chrono_new_old INTEGER,
      Timestamp_aanvraag TIMESTAMP(6),
      Date_aanvraag DATE FORMAT 'YY/MM/DD',
      Timestmp_voorg_stap TIMESTAMP(6),
      Date_voorg_stap DATE FORMAT 'YY/MM/DD',
      Status_voorg_stap VARCHAR(40) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS('AFGESLOTEN','Voorstel maken','AFGEBROKEN','AANVRAAG','Voorstel bekrachtigen & Fiatteren','BEKRACHTIGING AANGEBODEN','BEKRACHTIGD','GEFIATTEERD','FIAT AANGEBODEN','TER CONTROLE AANGEBODEN'),
      Status_nr_voorg_stap INTEGER,
      Timestmp_volg_stap TIMESTAMP(6),
      Date_volg_stapv DATE FORMAT 'YY/MM/DD',
      Status_volg_stap VARCHAR(40) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS('AFGESLOTEN','Voorstel maken','AFGEBROKEN','AANVRAAG','Voorstel bekrachtigen & Fiatteren','BEKRACHTIGING AANGEBODEN','BEKRACHTIGD','GEFIATTEERD','FIAT AANGEBODEN','TER CONTROLE AANGEBODEN'),
      Status_nr_volg_stap INTEGER,
      DLT_stap INTEGER,
      DLT_cumulatief INTEGER,
      Stap_actueel_ind BYTEINT,
      /*Stap_3mnd_ind BYTEINT,*/
      /*Stap_6mnd_ind BYTEINT,*/
      Stap_12mnd_ind BYTEINT
      )
UNIQUE PRIMARY INDEX ( FK_AANVR_WKMID ,FK_AANVR_VERSIE ,Soort_pijplijn ,Status_nr )
PARTITION BY (CASE_N(Soort_pijplijn = 'KEM', Soort_pijplijn = 'Funnel', NO CASE, UNKNOWN) )
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

COMMENT ON MI_SAS_AA_MB_C_MB.KEM_pijplijn_NEW   AS 'NIET VERWIJDEREN - Afdelingstabel in schedulescript (KEM)' ;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATS MI_SAS_AA_MB_C_MB.KEM_pijplijn_NEW COLUMN (PARTITION);
COLLECT STATS MI_SAS_AA_MB_C_MB.KEM_pijplijn_NEW COLUMN (PARTITION ,SOORT_PIJPLIJN);
COLLECT STATS MI_SAS_AA_MB_C_MB.KEM_pijplijn_NEW COLUMN (fk_aanvr_wkmid, fk_aanvr_versie, Soort_pijplijn, Volgnr_chrono_new_old);
COLLECT STATS MI_SAS_AA_MB_C_MB.KEM_pijplijn_NEW COLUMN (Volgnr_chrono_new_old);
COLLECT STATS MI_SAS_AA_MB_C_MB.KEM_pijplijn_NEW COLUMN (fk_aanvr_wkmid, fk_aanvr_versie, Soort_pijplijn);
COLLECT STATS MI_SAS_AA_MB_C_MB.KEM_pijplijn_NEW COLUMN (fk_aanvr_wkmid, fk_aanvr_versie);
COLLECT STATS MI_SAS_AA_MB_C_MB.KEM_pijplijn_NEW COLUMN (Volgnr_chrono_old_new);
COLLECT STATS MI_SAS_AA_MB_C_MB.KEM_pijplijn_NEW COLUMN fk_aanvr_wkmid;
COLLECT STATS MI_SAS_AA_MB_C_MB.KEM_pijplijn_NEW COLUMN Stap_actueel_ind;
COLLECT STATS MI_SAS_AA_MB_C_MB.KEM_pijplijn_NEW COLUMN (FK_AANVR_WKMID ,SOORT_PIJPLIJN);
COLLECT STATS MI_SAS_AA_MB_C_MB.KEM_pijplijn_NEW COLUMN Stap_12mnd_ind;
COLLECT STATS MI_SAS_AA_MB_C_MB.KEM_pijplijn_NEW COLUMN DATE_CREATED_STAP;
COLLECT STATS MI_SAS_AA_MB_C_MB.KEM_pijplijn_NEW COLUMN (PARTITION ,SOORT_PIJPLIJN ,VOLGNR_CHRONO_NEW_OLD);
COLLECT STATS MI_SAS_AA_MB_C_MB.KEM_pijplijn_NEW COLUMN  STATUS_NR;
COLLECT STATS MI_SAS_AA_MB_C_MB.KEM_pijplijn_NEW COLUMN (SOORT_PIJPLIJN ,STATUS_NR ,VOLGNR_CHRONO_OLD_NEW);
COLLECT STATS MI_SAS_AA_MB_C_MB.KEM_pijplijn_NEW COLUMN STATUS_NR;
COLLECT STATS MI_SAS_AA_MB_C_MB.KEM_pijplijn_NEW COLUMN (FK_AANVR_WKMID, SOORT_PIJPLIJN ,STAP_12MND_IND);
COLLECT STATS MI_SAS_AA_MB_C_MB.KEM_pijplijn_NEW COLUMN (SOORT_PIJPLIJN, STAP_12MND_IND);
COLLECT STATS MI_SAS_AA_MB_C_MB.KEM_pijplijn_NEW COLUMN (SOORT_PIJPLIJN, VOLGNR_CHRONO_NEW_OLD);
COLLECT STATS MI_SAS_AA_MB_C_MB.KEM_pijplijn_NEW COLUMN (PARTITION ,SOORT_PIJPLIJN ,STAP_12MND_IND);
COLLECT STATS MI_SAS_AA_MB_C_MB.KEM_pijplijn_NEW COLUMN(SOORT_PIJPLIJN ,STATUS ,STATUS_NR ,STATUS_VOORG_STAP,STATUS_NR_VOORG_STAP);
COLLECT STATS MI_SAS_AA_MB_C_MB.KEM_pijplijn_NEW COLUMN MAAND_NR;

.IF ERRORCODE <> 0 THEN .GOTO EOP

CREATE SET TABLE MI_SAS_AA_MB_C_MB.KEM_aanvraag_det_NEW ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      FK_AANVR_WKMID DECIMAL(18,0),
      FK_AANVR_VERSIE SMALLINT,
      Maand_nr INTEGER,
      UserID_laatste_stap CHAR(8) CHARACTER SET LATIN NOT CASESPECIFIC,
      BOnr_laatste_stap INTEGER,
      Doelgroep CHAR(3) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS('BIN','MED','PAR','AGR','MKB'),
      Datum_laatste_gesp DATE FORMAT 'YY/MM/DD',
      RM_naam CHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS('Conversiepost','x','YourBusiness Banking', ''),
      RM_UserID CHAR(6) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS(''),
      Specialist_advies_datum DATE FORMAT 'YY/MM/DD',
      Specialist_type CHAR(5) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS('','AS','RAMB','SOB','VG','KR'),
      Specialist_advies_type CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS('','1','2','3','4','5'),
      Specialist_BOnr INTEGER,
      Specialist_naam CHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS(''),
      Specialist_UserID CHAR(6) CHARACTER SET LATIN NOT CASESPECIFIC,
      Voorstel_status_actueel_nr SMALLINT COMPRESS(80,85,0,75),
      Voorstel_status_actueel CHAR(25) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS('AFGEBROKEN','AFGESLOTEN'),
      Voorstel_Dossier_nr DECIMAL(12,0),
      Voorstel_Klant_nr DECIMAL(13,0),
      Voorstel_BCnr_hfdrek_nr DECIMAL(12,0),
      Voorstel_BC_CGC INTEGER,
      Voorstel_BC_CGC_einde INTEGER,
      Voorstel_Hoofdrekening_nr DECIMAL(10,0),
      Voorstel_sector CHAR(12) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS('','DIENSTVERL','HANDEL','LANDBOUW','MEDICI','PRODUCTIE','TRANSPORT'),
      Voorstel_type_bron CHAR(3) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS('AAN','REV','REN','AFL','KRB'),
      Voorstel_type VARCHAR(9) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS('REV','WIJZIGING','NIEUW','REN','AFL','KRB','OD','RCM','ACT'),
      Voorstel_type_instroom VARCHAR(35) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS('Revisie','Nieuw','Renteherziening','Aflossen ML','Krediet beëindigen','Overdispositie','Saldo rentecompensatie','Actualisatie','Correctie renteperc lening','Opschorten ML','Mutatiekredietnemer','Omzetten variabele naar vaste rente','Wijziging - verhoging','Wijziging - verlaging'),
      Voorstel_beoordeling_policy CHAR(12) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS('','ORANJE','ROOD','GROEN'),
      Voorstel_beoordeling_model CHAR(12) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS('','ORANJE','ROOD','GROEN'),
      Voorstel_beoordeling_totaal CHAR(12) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS('','ORANJE','ROOD','GROEN','ORANJEGROEN','verl. zonder','akkoord','verl. met','rev.dat.hh'),
      Voorstel_Kantoor_naam VARCHAR(40) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS('Retail/CV/Beroepsgroep Arrangementen'),
      Voorstel_Kantoor_BOnr INTEGER,
      Voorstel_Kantoor_naam_act VARCHAR(40) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS('Retail/CV/Beroepsgroep Arrangementen'),
      Voorstel_SBU_srt_bo_code_act CHAR(3) CHARACTER SET LATIN NOT CASESPECIFIC,
      Voorstel_Type_bo_nr_act VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
      Voorstel_BU_code_act CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC,
      Voorstel_BU_decode_mi_act VARCHAR(60) CHARACTER SET LATIN NOT CASESPECIFIC,
      Voorstel_Regio_nr_act INTEGER,
      Voorstel_Regio_naam_act CHAR(40) CHARACTER SET LATIN NOT CASESPECIFIC,
      FI_CODE_OUD CHAR(3) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS('E23','E53','E93','E83','E43','E99','E55'),
      FI_CODE_NEW CHAR(3) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS('E23','E53','E93','E83','E43','E99','E55'),
      Voorstel_Classificatie CHAR(15) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS('','RETAIL','NON-RETAIL'),
      Voorstel_FRR_beoordeling CHAR(15) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS('','AKKOORD','NIET AKKOORD'),
      Voorstel_FRR_behandelpad CHAR(15) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS('','NVT','RES_REG','RES_HOK'),
      Voorstel_FRR_te_starten_dos CHAR(15) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS('','GEEN','AAN'),
      Voorstel_FRR_target_ficode CHAR(3) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS(''),
      Voorstel_arrangement_code CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS(''),
      Voorstel_huidige_revisie_dat DATE FORMAT 'YY/MM/DD',
      Voorstel_nieuwe_revisie_dat DATE FORMAT 'YY/MM/DD',
      Voorstel_rek_saldocomp_ind CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS('','N','J'),
      Voorstel_Aanvraag_gegevens_ind BYTEINT,
      Voorstel_Client_ind BYTEINT,
      Voorstel_Jaarrekening_ind BYTEINT,
      Voorstel_Kredietbehoefte_ind BYTEINT,
      Voorstel_Kredietoplossing_ind BYTEINT,
      Voorstel_zekerheden_ind BYTEINT,
      Voorstel_non_financials_ind BYTEINT,
      Voorstel_aflossverplicht_ind BYTEINT,
      Voorstel_aanvraag_vragen_ind BYTEINT,
      Voorstel_pricing_ind BYTEINT,
      Voorstel_alg_toelichting_ind BYTEINT,
      Voorstel_revisie_ind BYTEINT,
      Faciliteit_kort_bestaand DECIMAL(12,0),
      Faciliteit_kort_gevraagd DECIMAL(12,0),
      OBSI_bestaand DECIMAL(12,0),
      OBSI_gevraagd DECIMAL(12,0),
      Lease_AA_bestaand DECIMAL(12,0),
      Lease_AA_gevraagd DECIMAL(12,0),
      Leningen_lang_bestaand DECIMAL(12,0),
      Leningen_lang_gevraagd DECIMAL(12,0),
      Financiering_lang_bestaand DECIMAL(12,0),
      Financiering_lang_gevraagd DECIMAL(12,0),
      One_Obligor_lang_bestaand DECIMAL(12,0),
      One_Obligor_lang_gevraagd DECIMAL(12,0),
      Totaal6mnds_aflossing DECIMAL(12,0),
      BSK_max DECIMAL(12,0),
      BSK_dekkingstekort DECIMAL(12,0),
      Date_jaarrekening DATE FORMAT 'YY/MM/DD',
      Bedrijfsomzet INTEGER,
      Inkoopwaarde INTEGER,
      Toegevoegde_waarde DECIMAL(10,0),
      Personeelskosten INTEGER,
      Bedrijfskosten INTEGER,
      Bruto_resultaat DECIMAL(10,0),
      Afschrijvingen INTEGER,
      Rentelasten INTEGER,
      Overige_baten_en_l INTEGER,
      Bedrijfsresultaat DECIMAL(10,0),
      Incidentele_baten INTEGER,
      Belastingen INTEGER,
      Winst_en_verlies_n DECIMAL(10,0),
      Saldo_uitkering INTEGER,
      Uitkering INTEGER,
      Ingehouden_winst_e DECIMAL(10,0),
      Gecorr_rentelasten DECIMAL(12,0),
      RARORAC_indicatief DECIMAL(16,4),
      RARORAC_fiat DECIMAL(16,4),
      RARORAC_offerte DECIMAL(16,4),
      RARORAC_geaccepteerd DECIMAL(16,4),
      RARORAC DECIMAL(16,4),
      EP_indicatief DECIMAL(16,4),
      EP_fiat DECIMAL(16,4),
      EP_offerte DECIMAL(16,4),
      EP_geaccepteerd DECIMAL(16,4),
      EP DECIMAL(16,4),
      UCR_indicatief CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC,
      UCR_fiat CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC,
      UCR_offerte CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC,
      UCR_geaccepteerd CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC,
      UCR CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC,
      Client_RARORAC_indicatief DECIMAL(16,4),
      Client_RARORAC_fiat DECIMAL(16,4),
      Client_RARORAC_offerte DECIMAL(16,4),
      Client_RARORAC_geaccepteerd DECIMAL(16,4),
      Client_EP_indicatief DECIMAL(16,4),
      Client_EP_fiat DECIMAL(16,4),
      Client_EP_offerte DECIMAL(16,4),
      Client_EP_geaccepteerd DECIMAL(16,4),
      EC_indicatief DECIMAL(16,4),
      EC_fiat DECIMAL(16,4),
      EC_offerte DECIMAL(16,4),
      EC_geaccepteerd DECIMAL(16,4),
      Inkomsten_totaal_indicatief DECIMAL(16,4),
      Inkomsten_totaal_fiat DECIMAL(16,4),
      Inkomsten_totaal_offerte DECIMAL(16,4),
      Inkomsten_totaal_geaccepteerd DECIMAL(16,4),
      Client_AAEBREFFECT_TO_ind DECIMAL(16,4),
      Client_AAEBREFFECT_TO_fiat DECIMAL(16,4),
      Client_AAEBREFFECT_TO_offerte DECIMAL(16,4),
      Client_AAEBREFFECT_TO_geacc DECIMAL(16,4),
      Client_inkomsten_totaal_ind DECIMAL(16,4),
      Client_inkomsten_totaal_fiat DECIMAL(16,4),
      Client_inkomsten_totaal_off DECIMAL(16,4),
      Client_inkomsten_totaal_geacc DECIMAL(16,4),
      Client_optiekosten_indicatief DECIMAL(16,4),
      Client_optiekosten_fiat DECIMAL(16,4),
      Client_optiekosten_offerte DECIMAL(16,4),
      Client_optiekosten_geacc DECIMAL(16,4),
      Client_belastingen_indicatief DECIMAL(16,4),
      Client_belastingen_fiat DECIMAL(16,4),
      Client_belastingen_offerte DECIMAL(16,4),
      Client_belastingen_geacc DECIMAL(16,4),
      Client_exp_loss_indicatief DECIMAL(16,4),
      Client_exp_loss_fiat DECIMAL(16,4),
      Client_exp_loss_offerte DECIMAL(16,4),
      Client_exp_loss_geaccepteerd DECIMAL(16,4),
      Client_EC_indicatief DECIMAL(16,4),
      Client_EC_fiat DECIMAL(16,4),
      Client_EC_offerte DECIMAL(16,4),
      Client_EC_geaccepteerd DECIMAL(16,4),
      Client_oper_kosten_indicatief DECIMAL(16,4),
      Client_oper_kosten_fiat DECIMAL(16,4),
      Client_oper_kosten_offerte DECIMAL(16,4),
      Client_oper_kosten_geacc DECIMAL(16,4),
      Client_result_na_bel_ind DECIMAL(16,4),
      Client_result_na_bel_fiat DECIMAL(16,4),
      Client_result_na_bel_offerte DECIMAL(16,4),
      Client_result_na_bel_geacc DECIMAL(16,4),
      Type_krediet_code VARCHAR(5) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS('XL','STRT','MKN'),
      Type_Doelgroep CHAR(3) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS('BIN','MED','PAR','AGR','MKB'),
      Type_VST CHAR(3) CHARACTER SET LATIN NOT CASESPECIFIC COMPRESS('AAN','REV','AFL','REN','RCM'),
      NPL_ind BYTEINT,
      FRR_ind BYTEINT,

      ACBS_Contract_nr DECIMAL(11,0),
      ACBS_BC_nr DECIMAL(12,0),
      ACBS_Klant_nr INTEGER,
      ACBS_OOE  DECIMAL(18,2),
      ACBS_Limiet_krediet DECIMAL(18,2),
      ACBS_Saldo_doorlopend DECIMAL(18,2),
      ACBS_Bron_ACBS_ind BYTEINT,
      ACBS_Saldocompensatie_ind BYTEINT,
      ACBS_Ingangdatum_krediet DATE FORMAT 'YY/MM/DD'
      )
UNIQUE PRIMARY INDEX ( FK_AANVR_WKMID ,FK_AANVR_VERSIE )
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

INSERT INTO MI_SAS_AA_MB_C_MB.KEM_aanvraag_det_NEW
SELECT * FROM Mi_temp.KEM_funnel_t3;

COMMENT ON MI_SAS_AA_MB_C_MB.KEM_aanvraag_det_NEW   AS 'NIET VERWIJDEREN - Afdelingstabel in schedulescript (KEM)' ;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATS MI_SAS_AA_MB_C_MB.KEM_aanvraag_det_NEW COLUMN (fk_aanvr_wkmid, fk_aanvr_versie);
COLLECT STATS MI_SAS_AA_MB_C_MB.KEM_aanvraag_det_NEW COLUMN  FK_AANVR_WKMID;
COLLECT STATS MI_SAS_AA_MB_C_MB.KEM_aanvraag_det_NEW COLUMN VOORSTEL_BC_CGC;
COLLECT STATS MI_SAS_AA_MB_C_MB.KEM_aanvraag_det_NEW COLUMN VOORSTEL_BC_CGC_einde;
COLLECT STATS MI_SAS_AA_MB_C_MB.KEM_aanvraag_det_NEW COLUMN (VOORSTEL_BC_CGC,VOORSTEL_BC_CGC_einde);
COLLECT STATS MI_SAS_AA_MB_C_MB.KEM_aanvraag_det_NEW COLUMN FK_AANVR_WKMID;
COLLECT STATS MI_SAS_AA_MB_C_MB.KEM_aanvraag_det_NEW COLUMN VOORSTEL_HOOFDREKENING_NR;
COLLECT STATS MI_SAS_AA_MB_C_MB.KEM_aanvraag_det_NEW COLUMN VOORSTEL_BCNR_HFDREK_NR;
COLLECT STATS MI_SAS_AA_MB_C_MB.KEM_aanvraag_det_NEW COLUMN (VOORSTEL_TYPE);
COLLECT STATS MI_SAS_AA_MB_C_MB.KEM_aanvraag_det_NEW COLUMN (VOORSTEL_BC_CGC ,VOORSTEL_TYPE_INSTROOM);
COLLECT STATS MI_SAS_AA_MB_C_MB.KEM_aanvraag_det_NEW COLUMN (FRR_ind);
COLLECT STATS MI_SAS_AA_MB_C_MB.KEM_aanvraag_det_NEW COLUMN (FRR_ind);
COLLECT STATS MI_SAS_AA_MB_C_MB.KEM_aanvraag_det_NEW COLUMN Voorstel_BU_decode_mi_act;
COLLECT STATS MI_SAS_AA_MB_C_MB.KEM_aanvraag_det_NEW COLUMN Voorstel_Regio_nr_act;
COLLECT STATS MI_SAS_AA_MB_C_MB.KEM_aanvraag_det_NEW COLUMN Voorstel_Regio_naam_act;
COLLECT STATS MI_SAS_AA_MB_C_MB.KEM_aanvraag_det_NEW COLUMN  (VOORSTEL_DOSSIER_NR);
COLLECT STATS MI_SAS_AA_MB_C_MB.KEM_aanvraag_det_NEW COLUMN  VOORSTEL_KANTOOR_BONR;

.IF ERRORCODE <> 0 THEN .GOTO EOP



/*************************************************************************************

   10. AHK tbv rapportage (in MSTR)

*************************************************************************************/

/*************************************************************************************

       Kred_rapportage_moment_afdtabellen  -Hulptabel

*************************************************************************************/

CREATE TABLE Mi_temp.Kred_rapportage_moment_afdtabellen
      (
       Maand_nr                         INTEGER,
       Ultimomaand_start_datum_tee      DATE FORMAT 'YYYYMMDD',
       Ultimomaand_eind_datum_tee       DATE FORMAT 'YYYYMMDD'
      )
UNIQUE PRIMARY INDEX ( Maand_nr )
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

INSERT INTO Mi_temp.Kred_rapportage_moment_afdtabellen
SEL
     lm.maand
    ,lm.maand_sdat
    ,lm.maand_edat
FROM Mi_vm.vlu_maand                      lm
WHERE lm.maand = (SELECT MAX(maand_nr) FROM mi_cmb.cif_complex);

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_temp.Kred_rapportage_moment_afdtabellen COLUMN Ultimomaand_eind_datum_tee;
COLLECT STATISTICS Mi_temp.Kred_rapportage_moment_afdtabellen COLUMN Ultimomaand_start_datum_tee;

.IF ERRORCODE <> 0 THEN .GOTO EOP

/*************************************************************************************

       ahk_basis_NEW

*************************************************************************************/

CREATE SET TABLE MI_SAS_AA_MB_C_MB.ahk_basis_NEW ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      contract_nr DECIMAL(12,0),
      bc_nr DECIMAL(12,0),
      maand_nr INTEGER, --CHAR(6) CHARACTER SET LATIN NOT CASESPECIFIC,
      valuta_krediet VARCHAR(64) CHARACTER SET LATIN NOT CASESPECIFIC,
      kredietsoort CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC,
      kred_lim DECIMAL(18,0),
      avg_pos DECIMAL(18,0),
      gem_obligopositie DECIMAL(18,0),
      laagste_uitnutting DECIMAL(18,0),
      hoogste_uitnutting DECIMAL(18,0))
PRIMARY INDEX ( contract_nr ,bc_nr ,maand_nr ,valuta_krediet , kredietsoort );

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* Historie overnemen */
INSERT INTO MI_SAS_AA_MB_C_MB.ahk_basis_NEW
SELECT * FROM MI_SAS_AA_MB_C_MB.ahk_basis;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS  MI_SAS_AA_MB_C_MB.ahk_basis_NEW  COLUMN (maand_nr, contract_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.ahk_basis_NEW  COLUMN (maand_nr, bc_nr);
COLLECT STATISTICS  MI_SAS_AA_MB_C_MB.ahk_basis_NEW  COLUMN (maand_nr, bc_nr, contract_nr);
COLLECT STATISTICS MI_SAS_AA_MB_C_MB.ahk_basis_NEW COLUMN (maand_nr, valuta_krediet);
COLLECT STATISTICS  MI_SAS_AA_MB_C_MB.ahk_basis_NEW COLUMN (maand_nr, kredietsoort);

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* WEEKCIJFERS VERWIJDEREN INDIEN MAAND REEDS AANWEZIG VAN VORIGE WEEK */
DELETE FROM MI_SAS_AA_MB_C_MB.ahk_basis_NEW
WHERE Maand_nr = (SEL Maand_nr FROM MI_temp.Kred_rapportage_moment_afdtabellen)
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* insert nieuwe data */
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

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* hulptabel op Temp droppen */
DROP TABLE  MI_temp.Kred_rapportage_moment_afdtabellen;

.IF ERRORCODE <> 0 THEN .GOTO EOP




/**********************************************************************************************/
/* 11 IN- EN UITSTROOM IN- EN UITSTROOM IN- EN UITSTROOM IN- EN UITSTROOM IN- EN UITSTROOM IN */
/**********************************************************************************************/

/*--------------------------------------------------------------------------------------------*/
/* STAP 1                                                                                     */
/* Verzamel van alle BC’s de benodigde gegevens                                               */
/* (aanwezig aan het begin van de periode en/of aan het einde van de periode)                 */
/*--------------------------------------------------------------------------------------------*/

CREATE TABLE Mi_temp.Mia_migratie_BC_basis
      (
       Klant_nr INTEGER,
       Maand_nr INTEGER,
       Business_contact_nr DECIMAL(13,0),
       Maand_nr_begin INTEGER,
       Maand_nr_eind INTEGER,
       In_begin BYTEINT,
       In_eind BYTEINT,
       Klant_ind_begin BYTEINT,
       Klant_ind_eind BYTEINT,
       Klant_nr_begin INTEGER,
       Klant_nr_eind INTEGER,
       Klant_nr_ongewijzigd BYTEINT,
       Klant_nr_gewijzigd BYTEINT,
       Klant_nr_weg BYTEINT,
       Klant_nr_nieuw BYTEINT,
       Samengevoegd BYTEINT,
       Uiteengevallen BYTEINT,
       Nieuw_BC BYTEINT,
       Vervallen_BC BYTEINT,
       CGC_begin CHAR(4) CHARACTER SET LATIN NOT CASESPECIFIC,
       CGC_eind CHAR(4) CHARACTER SET LATIN NOT CASESPECIFIC,
       Business_line_begin VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC,
       Business_line_eind VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC,
       Segment_begin VARCHAR(4) CHARACTER SET LATIN NOT CASESPECIFIC,
       Segment_eind VARCHAR(4) CHARACTER SET LATIN NOT CASESPECIFIC
      )
UNIQUE PRIMARY INDEX ( Klant_nr, Maand_nr, Business_contact_nr )
INDEX ( Klant_nr )
INDEX ( Maand_nr )
INDEX ( Business_contact_nr )
INDEX ( Klant_nr_begin )
INDEX ( Klant_nr_eind );

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

/*--------------------------------------------------------------------------------------------*/
/* STAP 2                                                                                     */
/* Identificeer de uitzonderingen                                                             */
/*--------------------------------------------------------------------------------------------*/

/*--------------------------------------------------------------------------------------------*/
/* STAP 2A                                                                                    */
/* Identificeeer uiteengevallen klant(complex)en                                              */
/* - Meerdere Klant_nr_eind's bij één Klant_nr_begin                                          */
/*--------------------------------------------------------------------------------------------*/

UPDATE Mi_temp.Mia_migratie_BC_basis
   SET Uiteengevallen = 1
 WHERE Mi_temp.Mia_migratie_BC_basis.Klant_nr_begin IN (SELECT Klant_nr_begin
                                                          FROM Mi_temp.Mia_migratie_BC_basis
                                                         WHERE Nieuw_BC + Vervallen_BC = 0
                                                           AND Klant_nr_eind IS NOT NULL
                                                         GROUP BY 1 HAVING COUNT(DISTINCT Klant_nr_eind) > 1);

.IF ERRORCODE <> 0 THEN .GOTO EOP

/*--------------------------------------------------------------------------------------------*/
/* STAP 2B                                                                                    */
/* Identificeeer samengevoegde klant(complex)en                                               */
/* - Meerdere Klant_nr_begin's bij één Klant_nr_eind                                          */
/*--------------------------------------------------------------------------------------------*/

UPDATE Mi_temp.Mia_migratie_BC_basis
   SET Samengevoegd = 1
 WHERE Mi_temp.Mia_migratie_BC_basis.Klant_nr_eind IN (SELECT Klant_nr_eind
                                                         FROM Mi_temp.Mia_migratie_BC_basis
                                                        WHERE Nieuw_BC + Vervallen_BC = 0
                                                        GROUP BY 1 HAVING COUNT(DISTINCT ZEROIFNULL(Klant_nr_begin)) > 1);

.IF ERRORCODE <> 0 THEN .GOTO EOP

CREATE TABLE Mi_temp.Mia_klanten_uiteengevallen
      (
       Klant_nr INTEGER,
       Maand_nr INTEGER,
       Uiteengevallen BYTEINT,
       Ook_samengevoegd BYTEINT
      )
UNIQUE PRIMARY INDEX ( Klant_nr, Maand_nr )
INDEX ( Klant_nr )
INDEX ( Maand_nr );

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

CREATE TABLE Mi_temp.Mia_klanten_samengevoegd
      (
       Klant_nr INTEGER,
       Maand_nr INTEGER,
       Samengevoegd BYTEINT,
       Ook_uiteengevallen BYTEINT
      )
UNIQUE PRIMARY INDEX ( Klant_nr, Maand_nr )
INDEX ( Klant_nr )
INDEX ( Maand_nr );

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

/*--------------------------------------------------------------------------------------------*/
/* STAP 2C                                                                                    */
/* Identificeeer nieuwe klant(complex)en                                                      */
/* - Klant_nr_begin IS NULL                                                                   */
/*--------------------------------------------------------------------------------------------*/

CREATE TABLE Mi_temp.Mia_klanten_nieuw
      (
       Klant_nr INTEGER,
       Maand_nr INTEGER,
       Nieuw BYTEINT,
       Aantal_bcs INTEGER,
       Aantal_bcs_nieuw INTEGER
      )
UNIQUE PRIMARY INDEX ( Klant_nr, Maand_nr )
INDEX ( Klant_nr )
INDEX ( Maand_nr );

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

/*--------------------------------------------------------------------------------------------*/
/* STAP 2D                                                                                    */
/* Identificeeer vervallen klant(complex)en                                                   */
/* - Klant_nr_eind IS NULL                                                                    */
/*--------------------------------------------------------------------------------------------*/

CREATE TABLE Mi_temp.Mia_klanten_weg
      (
       Klant_nr INTEGER,
       Maand_nr INTEGER,
       Vervallen BYTEINT,
       Aantal_bcs INTEGER,
       Aantal_bcs_vervallen INTEGER
      )
UNIQUE PRIMARY INDEX ( Klant_nr, Maand_nr )
INDEX ( Klant_nr )
INDEX ( Maand_nr );

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

/*--------------------------------------------------------------------------------------------*/
/* STAP 2E                                                                                    */
/* Identificeeer klant(complex)en met (alleen) wijziging Klant_nr                             */
/*--------------------------------------------------------------------------------------------*/

CREATE TABLE Mi_temp.Mia_klanten_klantnr_anders
      (
       Klant_nr INTEGER,
       Maand_nr INTEGER,
       Klant_nr_nieuw INTEGER,
       Wijziging_klantnummer BYTEINT,
       Business_line_begin VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC,
       Business_line_eind VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC,
       Klant_ind_begin BYTEINT,
       Klant_ind_eind BYTEINT,
       Ook_instroom BYTEINT,
       Ook_uitstroom BYTEINT
      )
UNIQUE PRIMARY INDEX ( Klant_nr, Maand_nr )
INDEX ( Klant_nr )
INDEX ( Maand_nr )
INDEX ( Klant_nr_nieuw );

.IF ERRORCODE <> 0 THEN .GOTO EOP

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
.IF ERRORCODE <> 0 THEN .GOTO EOP

/*--------------------------------------------------------------------------------------------*/
/* STAP 2F                                                                                    */
/* Identificeeer klant(complex)en waarvan alle BC's afkomstig zijn van of overgeboekt zijn    */
/* naar een andere Businessline (en komt niet meer voor in de afdelingstabellen)              */
/*--------------------------------------------------------------------------------------------*/

CREATE TABLE Mi_temp.Mia_klanten_andere_BL
      (
       Klant_nr INTEGER,
       Maand_nr INTEGER,
       Andere_BL BYTEINT,
       Business_line VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC
      )
UNIQUE PRIMARY INDEX ( Klant_nr, Maand_nr )
INDEX ( Klant_nr )
INDEX ( Maand_nr );

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

/*--------------------------------------------------------------------------------------------*/
/* STAP 3                                                                                     */
/* Bepaal de In- en uitstroom gegevens per klant:                                             */
/* - Eerst de klanten met één of meerdere uitzonderingen                                      */
/* - Daarna de klanten zonder uitzonderingen (lees waarvan de klant(complex)samenstelling     */
/*   ongewijzigd is)                                                                          */
/*--------------------------------------------------------------------------------------------*/

CREATE TABLE Mi_temp.Mia_migratie_totaal
      (
       Klant_nr INTEGER,
       Maand_nr INTEGER,
       Business_line VARCHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC,
       Periode VARCHAR(5) CHARACTER SET LATIN NOT CASESPECIFIC,
       Maand_nr_begin INTEGER,
       Maand_nr_eind INTEGER,
       In_begin BYTEINT,
       In_eind BYTEINT,
       Bediening_begin VARCHAR(25) CHARACTER SET LATIN NOT CASESPECIFIC,
       Bediening_eind VARCHAR(25) CHARACTER SET LATIN NOT CASESPECIFIC,
       Klant_nr_nieuw INTEGER,
       In_uitstroom VARCHAR(50) CHARACTER SET UNICODE NOT CASESPECIFIC,
       Van_kop VARCHAR(20) CHARACTER SET UNICODE NOT CASESPECIFIC,
       Van_sub VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
       Naar_kop VARCHAR(20) CHARACTER SET UNICODE NOT CASESPECIFIC,
       Naar_sub VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
       Categorie1 VARCHAR(20) CHARACTER SET UNICODE NOT CASESPECIFIC,
       Categorie2 VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
       Samen BYTEINT,
       Uiteen BYTEINT,
       FRenR_begin BYTEINT,
       FRenR_eind BYTEINT
      )
UNIQUE PRIMARY INDEX ( Klant_nr, Maand_nr, Business_line, Periode )
INDEX ( Maand_nr_begin )
INDEX ( Maand_nr_eind );

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

/*--------------------------------------------------------------------------------------------*/
/* STAP 4                                                                                     */
/* Basis set tabel Mia_migratie_hist                                                          */
/* - Kopie maken                                                                              */
/* - Weekcijfers verwijderen indien maand reeds aanwezig van vorige week                      */
/* - Weekcijfers toevoegen                                                                    */
/*--------------------------------------------------------------------------------------------*/

CREATE TABLE Mi_sas_aa_mb_c_mb.Mia_migratie_hist_NEW AS Mi_sas_aa_mb_c_mb.Mia_migratie_hist WITH DATA
UNIQUE PRIMARY INDEX ( Klant_nr, Maand_nr, Business_line, Periode )
INDEX ( Maand_nr_begin )
INDEX ( Maand_nr_eind );

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_sas_aa_mb_c_mb.Mia_migratie_hist_NEW COLUMN ( PARTITION );

.IF ERRORCODE <> 0 THEN .GOTO EOP

DELETE
  FROM Mi_sas_aa_mb_c_mb.Mia_migratie_hist_NEW
 WHERE Mi_sas_aa_mb_c_mb.Mia_migratie_hist_NEW.Maand_nr_begin = MI_SAS_AA_MB_C_MB.Mia_periode_NEW.Maand_nr_vm1
   AND Mi_sas_aa_mb_c_mb.Mia_migratie_hist_NEW.Maand_nr_eind  = MI_SAS_AA_MB_C_MB.Mia_periode_NEW.Maand_nr;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_sas_aa_mb_c_mb.Mia_migratie_hist_NEW COLUMN ( PARTITION );

.IF ERRORCODE <> 0 THEN .GOTO EOP

INSERT INTO Mi_sas_aa_mb_c_mb.Mia_migratie_hist_NEW
SELECT A.*
  FROM Mi_temp.Mia_migratie_totaal A;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_sas_aa_mb_c_mb.Mia_migratie_hist_NEW COLUMN ( PARTITION );
COLLECT STATISTICS Mi_sas_aa_mb_c_mb.Mia_migratie_hist_NEW COLUMN ( Maand_nr );
COLLECT STATISTICS Mi_sas_aa_mb_c_mb.Mia_migratie_hist_NEW COLUMN ( Maand_nr_begin );
COLLECT STATISTICS Mi_sas_aa_mb_c_mb.Mia_migratie_hist_NEW COLUMN ( Maand_nr_eind );
COLLECT STATISTICS Mi_sas_aa_mb_c_mb.Mia_migratie_hist_NEW COLUMN ( Maand_nr_begin, Maand_nr );
COLLECT STATISTICS Mi_sas_aa_mb_c_mb.Mia_migratie_hist_NEW COLUMN ( Maand_nr_eind, Maand_nr );
COLLECT STATISTICS Mi_sas_aa_mb_c_mb.Mia_migratie_hist_NEW COLUMN ( Maand_nr_begin, Maand_nr, Klant_nr );
COLLECT STATISTICS Mi_sas_aa_mb_c_mb.Mia_migratie_hist_NEW COLUMN ( Maand_nr_eind, Maand_nr, Klant_nr );

.IF ERRORCODE <> 0 THEN .GOTO EOP



/***************************************************************/
/* 12.  SCRIPT AANLEVERING SIEBEL FINANCIAL PROFILE            */
/***************************************************************/

.IF ERRORCODE <> 0 THEN .GOTO EOP
/*-------------------------------------------------------------*/
/*                 FINANCIAL PROFILE                           */
/*                                                             */
/*  - Wekelijks alle FINANCIAL PROFILES opnieuw aanleveren     */
/*  - Schonen van FINANCIAL PROFILES van BCnrs welke niet meer */
/*    actueel zijn (bv. vervallen of nier meer Leidend BCnr)   */
/*-------------------------------------------------------------*/

    -- creatie actuele tabel
CREATE SET TABLE MI_SAS_AA_MB_C_MB.CUBe_Siebel_fin_prof_geleverd_NEW ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
     (
      Business_contact_nr DECIMAL(12,0),
      Datum_gegevens DATE FORMAT 'yyyy-mm-dd',
      Sw_geleverd BYTEINT,
      Datum_baten DATE FORMAT 'yyyy-mm-dd',
      Bedrijfstak_oms VARCHAR(55) CHARACTER SET LATIN NOT CASESPECIFIC,
      Baten DECIMAL(18,0),
      Baten_potentieel DECIMAL(18,0),
      Creditvolume DECIMAL(18,0),
      Debetvolume DECIMAL(18,0),
      Omzet_inkomend DECIMAL(15,0),
      Signaal VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC,
      Compl_prod01 CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      Compl_prod02 CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      Compl_prod03 CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      Compl_prod04 CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      Compl_prod05 CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      Compl_prod06 CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      Compl_prod07 CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      Compl_prod08 CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      Compl_prod09 CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      Compl_prod10 CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      Compl_prod11 CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      Compl_prod12 CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      Compl_prod13 CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      Compl_prod14 CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      Compl_prod15 CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      Compl_prod16 CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      Compl_prod17 CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      Compl_prod18 CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      Compl_prod19 CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      Compl_prod20 CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      Compl_prod21 CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      Compl_prod22 CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      Compl_prod23 CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      Compl_prod24 CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      Compl_prod25 CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      Compl_prod26 CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      Compl_prod27 CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      Compl_prod28 CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      Cp1_text VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC,
      Cp2_text VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC,
      Cp3_text VARCHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC,
      N_complex DECIMAL(10,0),
      Potentieel_theoretisch DECIMAL(18,0),
      Clientgroep_theoretisch CHAR(100) CHARACTER SET LATIN NOT CASESPECIFIC,
      Oordeel_RM VARCHAR(3) CHARACTER SET LATIN NOT CASESPECIFIC,
      Beoordeeld VARCHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
      NPS VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC)
UNIQUE PRIMARY INDEX ( Business_contact_nr ,Datum_gegevens );

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATS MI_SAS_AA_MB_C_MB.CUBe_Siebel_fin_prof_geleverd_NEW INDEX ( Business_contact_nr ,Datum_gegevens );
COLLECT STATS MI_SAS_AA_MB_C_MB.CUBe_Siebel_fin_prof_geleverd_NEW COLUMN (Sw_geleverd);

.IF ERRORCODE <> 0 THEN .GOTO EOP

-- vullen met alle actuele CUBe FINACIAL PROFILES
INSERT INTO MI_SAS_AA_MB_C_MB.CUBe_Siebel_fin_prof_geleverd_NEW
SELECT
        A.Business_contact_nr                                 AS Business_contact_nr
       ,A.Datum_gegevens                                      AS Datum_gegevens
       ,0                                                     AS Sw_geleverd /* tbv CTAPE (verplaatsen van Mi_export naar AV3) */
       ,B.Datum_baten                                         AS Datum_baten
       ,A.subsector_oms                                       AS Bedrijfstak_oms
       ,B.Baten                                               AS Baten
       ,B.Baten_potentieel                                    AS Baten_potentieel
       ,A.Creditvolume                                        AS Creditvolume
       ,A.Debetvolume                                         AS Debetvolume
       ,A.Omzet_inkomend                                      AS Omzet_inkomend
       ,A.Signaal                                             AS Signaal
       ,CASE WHEN E.Code_A IS NULL THEN 'N' ELSE E.Code_A END AS Compl_prod01
       ,CASE WHEN E.Code_B IS NULL THEN 'N' ELSE E.Code_B END AS Compl_prod02
       ,CASE WHEN E.Code_C IS NULL THEN 'N' ELSE E.Code_C END AS Compl_prod03
       ,CASE WHEN E.Code_D IS NULL THEN 'N' ELSE E.Code_D END AS Compl_prod04
       ,CASE WHEN E.Code_E IS NULL THEN 'N' ELSE E.Code_E END AS Compl_prod05
       ,CASE WHEN E.Code_F IS NULL THEN 'N' ELSE E.Code_F END AS Compl_prod06
       ,CASE WHEN E.Code_G IS NULL THEN 'N' ELSE E.Code_G END AS Compl_prod07
       ,CASE WHEN E.Code_H IS NULL THEN 'N' ELSE E.Code_H END AS Compl_prod08
       ,CASE WHEN E.Code_I IS NULL THEN 'N' ELSE E.Code_I END AS Compl_prod09
       ,CASE WHEN E.Code_J IS NULL THEN 'N' ELSE E.Code_J END AS Compl_prod10
       ,CASE WHEN E.Code_K IS NULL THEN 'N' ELSE E.Code_K END AS Compl_prod11    --binnen Siebel is dit 'Corporate Payments Services'
       ,CASE WHEN E.Code_L IS NULL THEN 'N' ELSE E.Code_L END AS Compl_prod12
       ,CASE WHEN E.Code_U IS NULL THEN 'N' ELSE E.Code_U END AS Compl_prod13
       ,CASE WHEN E.Code_V IS NULL THEN 'N' ELSE E.Code_V END AS Compl_prod14
       ,CASE WHEN E.Code_W IS NULL THEN 'N' ELSE E.Code_W END AS Compl_prod15
       ,CASE WHEN E.Code_X IS NULL THEN 'N' ELSE E.Code_X END AS Compl_prod16
       ,CASE WHEN E.Code_Y IS NULL THEN 'N' ELSE E.Code_Y END AS Compl_prod17
       ,CASE WHEN E.Code_Z IS NULL THEN 'N' ELSE E.Code_Z END AS Compl_prod18
       ,CASE WHEN E.Code_0 IS NULL THEN 'N' ELSE E.Code_0 END AS Compl_prod19
       ,CASE WHEN E.Code_1 IS NULL THEN 'N' ELSE E.Code_1 END AS Compl_prod20
       ,CASE WHEN E.Code_2 IS NULL THEN 'N' ELSE E.Code_2 END AS Compl_prod21
       ,CASE WHEN E.Code_3 IS NULL THEN 'N' ELSE E.Code_3 END AS Compl_prod22
       ,CASE WHEN E.Code_4 IS NULL THEN 'N' ELSE E.Code_4 END AS Compl_prod23
       ,CASE WHEN E.Code_5 IS NULL THEN 'N' ELSE E.Code_5 END AS Compl_prod24
       ,CASE WHEN E.Code_6 IS NULL THEN 'N' ELSE E.Code_6 END AS Compl_prod25
       ,CASE WHEN E.Code_7 IS NULL THEN 'N' ELSE E.Code_7 END AS Compl_prod26
       ,CASE WHEN E.Code_8 IS NULL THEN 'N' ELSE E.Code_8 END AS Compl_prod27
       ,CASE WHEN E.Code_9 IS NULL THEN 'N' ELSE E.Code_9 END AS Compl_prod28
       ,D.Complex_product_1                                   AS Cp1_text
       ,D.Complex_product_2                                   AS Cp2_text
       ,D.Complex_product_3                                   AS Cp3_text
       ,A.Aantal_complexe_producten                           AS N_complex
       ,0.5*B.Baten_potentieel                          AS Potentieel_theoretisch
       /*,CASE
             WHEN SUBSTR(A.Clientgroep_theoretisch, 4, 1) = '0' THEN A.Clientgroep_theoretisch||' Houden'
             WHEN SUBSTR(A.Clientgroep_theoretisch, 4, 1) = '1' THEN A.Clientgroep_theoretisch||' Neerwaarts'
             WHEN SUBSTR(A.Clientgroep_theoretisch, 4, 1) = '2' THEN A.Clientgroep_theoretisch||' Intermediair'
             WHEN SUBSTR(A.Clientgroep_theoretisch, 4, 1) = '3' THEN A.Clientgroep_theoretisch||' Potentie'
             WHEN SUBSTR(A.Clientgroep_theoretisch, 4, 1) = '4' THEN A.Clientgroep_theoretisch||' Complex(KZ) / nvt(MB/GB)'
             WHEN SUBSTR(A.Clientgroep_theoretisch, 4, 1) = '5' THEN A.Clientgroep_theoretisch||' Afwikkelen'
             WHEN SUBSTR(A.Clientgroep_theoretisch, 4, 1) = '6' THEN A.Clientgroep_theoretisch||' Vaste kern'
             WHEN SUBSTR(A.Clientgroep_theoretisch, 4, 1) = '7' THEN A.Clientgroep_theoretisch||' Third Party Banking'
             WHEN SUBSTR(A.Clientgroep_theoretisch, 4, 1) = '9' THEN A.Clientgroep_theoretisch||' Opwaarts'
        END*/
       ,NULL AS Clientgroep_theoretisch /* INCL OMSCHRIJVING */
       ,SUBSTR(A.Clientgroep_theoretisch, 1, 3)               AS Oordeel_RM
       ,'N' AS Beoordeeld
       ,F.NPS                                                 AS NPS

  FROM Mi_temp.Mia_week A
  LEFT OUTER JOIN Mi_temp.CUBe_baten B
    ON A.Klant_nr = B.Klant_nr AND A.Maand_nr = B.Maand_nr
  LEFT OUTER JOIN (SELECT X.Klant_nr,
                          MAX(CASE WHEN X.Volgorde = 1 THEN X.Product_naam ELSE NULL END) AS Complex_product_1,
                          MAX(CASE WHEN X.Volgorde = 2 THEN X.Product_naam ELSE NULL END) AS Complex_product_2,
                          MAX(CASE WHEN X.Volgorde = 3 THEN X.Product_naam ELSE NULL END) AS Complex_product_3
                     FROM (SELECT XA.*,
                                  RANK() OVER (PARTITION BY XA.Klant_nr ORDER BY XA.Code_complex_product ASC) AS Volgorde
                             FROM (SELECT XXA.Klant_nr,
                                          XXA.Code_complex_product,
                                          CASE WHEN XXA.Code_complex_product = 'J' THEN 'GRV 010, 020 en 030' ELSE XXA.Product_naam END AS Product_naam
                                     FROM Mi_temp.Complex_product XXA
                                    GROUP BY 1, 2, 3) AS XA) AS X
                    GROUP BY 1) AS D
    ON A.Klant_nr = D.Klant_nr
  LEFT OUTER JOIN (SELECT A.Klant_nr,
                          A.Maand_nr,
                          MAX(CASE WHEN TRIM(A.Code_complex_product) = 'A' THEN 'Y' ELSE 'N' END) AS Code_A,
                          MAX(CASE WHEN TRIM(A.Code_complex_product) = 'B' THEN 'Y' ELSE 'N' END) AS Code_B,
                          MAX(CASE WHEN TRIM(A.Code_complex_product) = 'C' THEN 'Y' ELSE 'N' END) AS Code_C,
                          MAX(CASE WHEN TRIM(A.Code_complex_product) = 'D' THEN 'Y' ELSE 'N' END) AS Code_D,
                          MAX(CASE WHEN TRIM(A.Code_complex_product) = 'E' THEN 'Y' ELSE 'N' END) AS Code_E,
                          MAX(CASE WHEN TRIM(A.Code_complex_product) = 'F' THEN 'Y' ELSE 'N' END) AS Code_F,
                          MAX(CASE WHEN TRIM(A.Code_complex_product) = 'G' THEN 'Y' ELSE 'N' END) AS Code_G,
                          MAX(CASE WHEN TRIM(A.Code_complex_product) = 'H' THEN 'Y' ELSE 'N' END) AS Code_H,
                          MAX(CASE WHEN TRIM(A.Code_complex_product) = 'I' THEN 'Y' ELSE 'N' END) AS Code_I,
                          MAX(CASE WHEN TRIM(A.Code_complex_product) = 'J' THEN 'Y' ELSE 'N' END) AS Code_J,
                          MAX(CASE WHEN TRIM(A.Code_complex_product) = 'K' THEN 'Y' ELSE 'N' END) AS Code_K,
                          MAX(CASE WHEN TRIM(A.Code_complex_product) = 'L' THEN 'Y' ELSE 'N' END) AS Code_L,
                          MAX(CASE WHEN TRIM(A.Code_complex_product) = 'M' THEN 'Y' ELSE 'N' END) AS Code_M,
                          MAX(CASE WHEN TRIM(A.Code_complex_product) = 'N' THEN 'Y' ELSE 'N' END) AS Code_N,
                          MAX(CASE WHEN TRIM(A.Code_complex_product) = 'O' THEN 'Y' ELSE 'N' END) AS Code_O,
                          MAX(CASE WHEN TRIM(A.Code_complex_product) = 'P' THEN 'Y' ELSE 'N' END) AS Code_P,
                          MAX(CASE WHEN TRIM(A.Code_complex_product) = 'Q' THEN 'Y' ELSE 'N' END) AS Code_Q,
                          MAX(CASE WHEN TRIM(A.Code_complex_product) = 'R' THEN 'Y' ELSE 'N' END) AS Code_R,
                          MAX(CASE WHEN TRIM(A.Code_complex_product) = 'S' THEN 'Y' ELSE 'N' END) AS Code_S,
                          MAX(CASE WHEN TRIM(A.Code_complex_product) = 'T' THEN 'Y' ELSE 'N' END) AS Code_T,
                          MAX(CASE WHEN TRIM(A.Code_complex_product) = 'U' THEN 'Y' ELSE 'N' END) AS Code_U,
                          MAX(CASE WHEN TRIM(A.Code_complex_product) = 'V' THEN 'Y' ELSE 'N' END) AS Code_V,
                          MAX(CASE WHEN TRIM(A.Code_complex_product) = 'W' THEN 'Y' ELSE 'N' END) AS Code_W,
                          MAX(CASE WHEN TRIM(A.Code_complex_product) = 'X' THEN 'Y' ELSE 'N' END) AS Code_X,
                          MAX(CASE WHEN TRIM(A.Code_complex_product) = 'Y' THEN 'Y' ELSE 'N' END) AS Code_Y,
                          MAX(CASE WHEN TRIM(A.Code_complex_product) = 'Z' THEN 'Y' ELSE 'N' END) AS Code_Z,
                          MAX(CASE WHEN TRIM(A.Code_complex_product) = '0' THEN 'Y' ELSE 'N' END) AS Code_0,
                          MAX(CASE WHEN TRIM(A.Code_complex_product) = '1' THEN 'Y' ELSE 'N' END) AS Code_1,
                          MAX(CASE WHEN TRIM(A.Code_complex_product) = '2' THEN 'Y' ELSE 'N' END) AS Code_2,
                          MAX(CASE WHEN TRIM(A.Code_complex_product) = '3' THEN 'Y' ELSE 'N' END) AS Code_3,
                          MAX(CASE WHEN TRIM(A.Code_complex_product) = '4' THEN 'Y' ELSE 'N' END) AS Code_4,
                          MAX(CASE WHEN TRIM(A.Code_complex_product) = '5' THEN 'Y' ELSE 'N' END) AS Code_5,
                          MAX(CASE WHEN TRIM(A.Code_complex_product) = '6' THEN 'Y' ELSE 'N' END) AS Code_6,
                          MAX(CASE WHEN TRIM(A.Code_complex_product) = '7' THEN 'Y' ELSE 'N' END) AS Code_7,
                          MAX(CASE WHEN TRIM(A.Code_complex_product) = '8' THEN 'Y' ELSE 'N' END) AS Code_8,
                          MAX(CASE WHEN TRIM(A.Code_complex_product) = '9' THEN 'Y' ELSE 'N' END) AS Code_9
                     FROM Mi_temp.Complex_product A
                    GROUP BY 1, 2) AS E
    ON A.Klant_nr = E.Klant_nr

     -- NPS(R), niet anoniem en score tussen 1 en 10; bij meerdere scores per klant nemen we de laagste score binnen het meest recente onderzoek
  LEFT OUTER JOIN (SELECT A.Klant_nr,
                          CASE
                          WHEN B.NPS_aanbeveling_ABN_AMRO BETWEEN 9 AND 10 THEN CAST(B.NPS_aanbeveling_ABN_AMRO AS VARCHAR(2))||' (Promotor,'||SUBSTR(B.Kto_id, 9, 6)||')'
                          WHEN B.NPS_aanbeveling_ABN_AMRO BETWEEN 7 AND  8 THEN CAST(B.NPS_aanbeveling_ABN_AMRO AS VARCHAR(2))||' (Passive,'||SUBSTR(B.Kto_id, 9, 6)||')'
                          WHEN B.NPS_aanbeveling_ABN_AMRO BETWEEN 0 AND  6 THEN CAST(B.NPS_aanbeveling_ABN_AMRO AS VARCHAR(2))||' (Detractor,'||SUBSTR(B.Kto_id, 9, 6)||')'
                          ELSE NULL
                          END AS NPS
                   FROM (SELECT *
                         FROM MI_SAS_AA_MB_C_MB.Mia_klantkoppelingen_hist_NEW
                         WHERE Maand_nr IN (SELECT MAX(Maand_nr) FROM MI_SAS_AA_MB_C_MB.Mia_klantkoppelingen_hist_NEW )
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
                  ) AS F
    ON A.Klant_nr = F.Klant_nr

WHERE (A.Klant_ind = 1 OR A.Klantstatus = 'S')  -- clients & suspects
       -- OUDE SEGEMENTATIE: CC & IC; uitgesloten is Retail inclusief KleinBedrijf
       -- NIEUW SEGEMENTATIE: CBC & CIB & SME; uitgesloten KleinBedrijf !!
  AND (A.Business_line IN ('CBC', 'CIB','SME') AND A.Segment <> 'SME')
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATS MI_SAS_AA_MB_C_MB.CUBe_Siebel_fin_prof_geleverd_NEW;

.IF ERRORCODE <> 0 THEN .GOTO EOP

-- Schonen indien niet meer actueel (bv. vervallen, migreert of niet meer Leidend BCnr

INSERT INTO MI_SAS_AA_MB_C_MB.CUBe_Siebel_fin_prof_geleverd_NEW
SEL
    oud.Business_contact_nr
   ,DATE AS Datum_gegevens
   ,0 AS Sw_geleverd
   ,'9999-12-31' AS Datum_baten
   ,'' AS Bedrijfstak_oms
   ,0 AS Baten
   ,0 AS Baten_potentieel
   ,0 AS Creditvolume
   ,0 AS Debetvolume
   ,0 AS Omzet_inkomend
   ,'' AS Signaal
   ,'N' AS Compl_prod01
   ,'N' AS Compl_prod02
   ,'N' AS Compl_prod03
   ,'N' AS Compl_prod04
   ,'N' AS Compl_prod05
   ,'N' AS Compl_prod06
   ,'N' AS Compl_prod07
   ,'N' AS Compl_prod08
   ,'N' AS Compl_prod09
   ,'N' AS Compl_prod10
   ,'N' AS Compl_prod11
   ,'N' AS Compl_prod12
   ,'N' AS Compl_prod13
   ,'N' AS Compl_prod14
   ,'N' AS Compl_prod15
   ,'N' AS Compl_prod16
   ,'N' AS Compl_prod17
   ,'N' AS Compl_prod18
   ,'N' AS Compl_prod19
   ,'N' AS Compl_prod20
   ,'N' AS Compl_prod21
   ,'N' AS Compl_prod22
   ,'N' AS Compl_prod23
   ,'N' AS Compl_prod24
   ,'N' AS Compl_prod25
   ,'N' AS Compl_prod26
   ,'N' AS Compl_prod27
   ,'N' AS Compl_prod28
   ,'' AS Cp1_text
   ,'' AS Cp2_text
   ,'' AS Cp3_text
   ,0 AS N_complex
   ,0 AS Potentieel_theoretisch
   ,'' Clientgroep_theoretisch
   ,'' AS Oordeel_RM
   ,'' AS Beoordeeld
   ,'' AS NPS
FROM MI_SAS_AA_MB_C_MB.CUBe_Siebel_fin_prof_geleverd  oud

LEFT OUTER JOIN MI_SAS_AA_MB_C_MB.CUBe_Siebel_fin_prof_geleverd_NEW   act
   ON oud.Business_contact_nr = act.Business_contact_nr

WHERE act.Business_contact_nr IS NULL
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATS MI_SAS_AA_MB_C_MB.CUBe_Siebel_fin_prof_geleverd_NEW;

.IF ERRORCODE <> 0 THEN .GOTO EOP



/***************************************************************/
/*   Aanmaken autorisatie tabel voor MSTR                      */
/***************************************************************/


CREATE TABLE MI_SAS_AA_MB_C_MB.Medewerker_Security_NEW
      (Datum_gegevens DATE
       ,SBT_id VARCHAR(256)
       ,Naam_mdw VARCHAR(256)
       ,Soort_mdw  VARCHAR(10)
       ,BO_nr_mdw INTEGER
       ,BO_naam_mdw VARCHAR(256)
       ,GM_ind INTEGER
       ,Mdw_sdat DATE
       ,Org_niveau3 VARCHAR(100)
       ,Org_niveau3_bo_nr INTEGER
       ,Org_niveau2 VARCHAR(100)
       ,Org_niveau2_bo_nr INTEGER
       ,Org_niveau1 VARCHAR(100)
       ,Org_niveau1_bo_nr INTEGER
       ,Org_niveau0 VARCHAR(100)
       ,Org_niveau0_bo_nr INTEGER)
UNIQUE PRIMARY INDEX ( Datum_gegevens, SBT_id,  Soort_mdw, Mdw_sdat)
 ;

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

-- Ophalen naam medewerker

INNER JOIN (SEL party_id,
                party_sleutel_type,
                CASE WHEN party_sleutel_type = 'MW' THEN UPPER(TRIM(Naam)) ELSE UPPER(TRIM(Naamregel_1)) END AS Naam
            FROM mi_vm_ldm.aparty_naam
            WHERE party_sleutel_type IN ('MW')) b
ON a.party_id = b.party_id
AND a.party_sleutel_type = b.party_sleutel_type

-- Ophalen BO nummer medewerker

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

/*-----------------------------------------------------*/
/*                 AGRC - Operational Risk Management  */
/*                                                     */
/*  - Aanmaken MCT: Managed Control and Testing        */
/*  - Aanmaken REM: Risk Event Management              */
/*  - aanmaken IMAT: Issue management & Tracking       */
/*-----------------------------------------------------*/


/***********************************************************************************/
-- MCT: Managed Control and Testing
/***********************************************************************************/

CREATE MULTISET TABLE MI_SAS_AA_MB_C_MB.AGRC_MCT_NEW ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
             (
              Draaidatum DATE FORMAT 'YY/MM/DD',
              Maand_nr  INTEGER,
              Volgnummer INTEGER,
              Value_Chain VARCHAR(500) CHARACTER SET LATIN CASESPECIFIC,
              Control_Responsible_2nd_LoD VARCHAR(130) CHARACTER SET LATIN CASESPECIFIC,
              Business_Structures VARCHAR(80) CHARACTER SET LATIN CASESPECIFIC,
              Business_Structure_Category VARCHAR(60) CHARACTER SET LATIN CASESPECIFIC,
              Business_Structure_Cat_II VARCHAR(60) CHARACTER SET LATIN CASESPECIFIC,
              Country_Code VARCHAR(80) CHARACTER SET LATIN CASESPECIFIC,
              Control_Name VARCHAR(130) CHARACTER SET LATIN CASESPECIFIC,
              Control_ID VARCHAR(20) CHARACTER SET LATIN CASESPECIFIC,
              Monitor_Status VARCHAR(40) CHARACTER SET LATIN CASESPECIFIC,
              Monitor_Status_Max INTEGER,
              Monitor_Status_Max_II INTEGER,
              Monitor_Status_Due  VARCHAR(40) CHARACTER SET LATIN CASESPECIFIC,
              Monitor_Status_EndofRep  VARCHAR(40) CHARACTER SET LATIN CASESPECIFIC,
              RAG_Monitor VARCHAR(30) CHARACTER SET LATIN CASESPECIFIC,
              Tester_Status VARCHAR(30) CHARACTER SET LATIN CASESPECIFIC,
              RAG_Tester VARCHAR(30) CHARACTER SET LATIN CASESPECIFIC,
              Monitoring_End_of_Reporting DATE FORMAT 'YY/MM/DD',
              Monitoring_End_of_Reporting_Q INTEGER,
              MCT_Filter_Qmin2 INTEGER,
              Monitor_Due_Date DATE FORMAT 'YY/MM/DD',
              Monitor_Answer_Date DATE FORMAT 'YY/MM/DD',
              Monitored_by VARCHAR(120) CHARACTER SET LATIN CASESPECIFIC,
              Tester_Due_Date DATE FORMAT 'YY/MM/DD',
              Tester_Answer_Date DATE FORMAT 'YY/MM/DD',
              Tested_by VARCHAR(120) CHARACTER SET LATIN CASESPECIFIC,
              CM_Conduct_driver_applicable_ VARCHAR(3) CHARACTER SET LATIN CASESPECIFIC,
              vMaxCTMDueDate DATE FORMAT 'YY/MM/DD',
              vTestStatusNew VARCHAR(30) CHARACTER SET LATIN CASESPECIFIC,
              vMonitorStatus VARCHAR(30) CHARACTER SET LATIN CASESPECIFIC,
              vMonitorStatusNew VARCHAR(30) CHARACTER SET LATIN CASESPECIFIC)
PRIMARY INDEX (Draaidatum , Volgnummer );

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS  MI_SAS_AA_MB_C_MB.AGRC_MCT_NEW COLUMN (Maand_nr, Business_Structure_Category, Monitoring_End_of_Reporting, Monitoring_End_of_Reporting_Q);
COLLECT STATISTICS  MI_SAS_AA_MB_C_MB.AGRC_MCT_NEW COLUMN (Maand_nr);
COLLECT STATISTICS  MI_SAS_AA_MB_C_MB.AGRC_MCT_NEW COLUMN (Business_Structure_Category);
COLLECT STATISTICS  MI_SAS_AA_MB_C_MB.AGRC_MCT_NEW COLUMN (Monitoring_End_of_Reporting);
COLLECT STATISTICS  MI_SAS_AA_MB_C_MB.AGRC_MCT_NEW COLUMN (Monitoring_End_of_Reporting_Q);

.IF ERRORCODE <> 0 THEN .GOTO EOP

/************************************/
/* REM Risk Event Management        */
/************************************/

CREATE MULTISET TABLE MI_SAS_AA_MB_C_MB.AGRC_REM_NEW ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
             (
              Draaidatum DATE FORMAT 'YY/MM/DD',
              Maand_nr  INTEGER,
              Volgnummer INTEGER,
              Event_Type VARCHAR(40) CHARACTER SET LATIN CASESPECIFIC,
              Event_Type_Cat_1 VARCHAR(30) CHARACTER SET LATIN CASESPECIFIC,
              Event_Type_Cat_2 VARCHAR(30) CHARACTER SET LATIN CASESPECIFIC,
              Event_ID VARCHAR(30) CHARACTER SET LATIN CASESPECIFIC,
              Input_Date DATE FORMAT 'YY/MM/DD',
              Total_Gross_Loss_Plus_EUR FLOAT,
              Total_Net_Loss_Plus_bef_Insur FLOAT,
              Exposure_Amount_EUR FLOAT,
              Business_Structure_Name VARCHAR(80) CHARACTER SET LATIN CASESPECIFIC,
              Business_Structure_Category VARCHAR(60) CHARACTER SET LATIN CASESPECIFIC,
              Business_Structure_Cat_II VARCHAR(60) CHARACTER SET LATIN CASESPECIFIC,
              Geography VARCHAR(30) CHARACTER SET LATIN CASESPECIFIC,
              Event_Category VARCHAR(180) CHARACTER SET LATIN CASESPECIFIC,
              Cause_category_1 VARCHAR(80) CHARACTER SET LATIN CASESPECIFIC,
              Workflow_status VARCHAR(20) CHARACTER SET LATIN CASESPECIFIC,
              Number_of_incidents VARCHAR(3) CHARACTER SET LATIN CASESPECIFIC,
              Short_description VARCHAR(200) CHARACTER SET LATIN CASESPECIFIC,
              Long_description VARCHAR(4000) CHARACTER SET LATIN CASESPECIFIC,
              Steps_Taken VARCHAR(4000) CHARACTER SET LATIN CASESPECIFIC,
              Event_Creator VARCHAR(80) CHARACTER SET LATIN CASESPECIFIC,
              Process VARCHAR(160) CHARACTER SET LATIN CASESPECIFIC,
              Product VARCHAR(100) CHARACTER SET LATIN CASESPECIFIC,
              Date_of_rec DATE FORMAT 'YY/MM/DD',
              Date_of_rec_Year INTEGER,
              Date_of_rec_Month  INTEGER,
              Date_of_rec_Quarte_  INTEGER,
              Accounting_Date DATE FORMAT 'YY/MM/DD',
              Acc_date_Year INTEGER,
              Acc_date_Month INTEGER,
              Acc_date_Quarter INTEGER,
              Provision_Date DATE FORMAT 'YY/MM/DD',
              Financial_Status VARCHAR(40) CHARACTER SET LATIN CASESPECIFIC,
              Date_of_Discovery DATE FORMAT 'YY/MM/DD')
              PRIMARY INDEX ( Draaidatum, Volgnummer);

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS  MI_SAS_AA_MB_C_MB.AGRC_REM_NEW COLUMN (Maand_nr, Event_Type, Input_Date, Business_Structure_Category, Workflow_status);
COLLECT STATISTICS  MI_SAS_AA_MB_C_MB.AGRC_REM_NEW COLUMN (Maand_nr);
COLLECT STATISTICS  MI_SAS_AA_MB_C_MB.AGRC_REM_NEW COLUMN (Event_Type);
COLLECT STATISTICS  MI_SAS_AA_MB_C_MB.AGRC_REM_NEW COLUMN (Input_Date);
COLLECT STATISTICS  MI_SAS_AA_MB_C_MB.AGRC_REM_NEW COLUMN (Business_Structure_Category);
COLLECT STATISTICS  MI_SAS_AA_MB_C_MB.AGRC_REM_NEW COLUMN (Workflow_status);

.IF ERRORCODE <> 0 THEN .GOTO EOP

/*************************************/
/* IMAT: Issue management & Tracking */
/*************************************/

CREATE MULTISET TABLE MI_SAS_AA_MB_C_MB.AGRC_IMAT_NEW ,NO FALLBACK ,
     NO BEFORE JOURNAL,
     NO AFTER JOURNAL,
     CHECKSUM = DEFAULT,
     DEFAULT MERGEBLOCKRATIO
             (
              Draaidatum DATE FORMAT 'YY/MM/DD',
              Maand_nr  INTEGER,
              Volgnummer INTEGER,
              Business_Structure VARCHAR(60) CHARACTER SET LATIN CASESPECIFIC,
              Business_Structure_Category VARCHAR(80) CHARACTER SET LATIN CASESPECIFIC,
              Business_Structure_Cat_II VARCHAR(80) CHARACTER SET LATIN CASESPECIFIC,
              Level2 VARCHAR(36) CHARACTER SET LATIN CASESPECIFIC,
              Level3 VARCHAR(36) CHARACTER SET LATIN CASESPECIFIC,
              Country_Code VARCHAR(30) CHARACTER SET LATIN CASESPECIFIC,
              Issue_ID VARCHAR(30) CHARACTER SET LATIN CASESPECIFIC,
              Due_in_days INTEGER,
              Issue_due INTEGER,
              Due_category VARCHAR(80) CHARACTER SET LATIN CASESPECIFIC,
              Level_of_Concern VARCHAR(20) CHARACTER SET LATIN CASESPECIFIC,
              Current_Workflow_Step VARCHAR(30) CHARACTER SET LATIN CASESPECIFIC,
              Issue_Title VARCHAR(120) CHARACTER SET LATIN CASESPECIFIC,
              Issue_Description VARCHAR(1200) CHARACTER SET LATIN CASESPECIFIC,
              Issue_business_owner VARCHAR(40) CHARACTER SET LATIN CASESPECIFIC,
              Risk_Area VARCHAR(30) CHARACTER SET LATIN CASESPECIFIC,
              Issue_created_date DATE FORMAT 'YY/MM/DD',
              Issue_reg_date_AGRC DATE FORMAT 'YY/MM/DD',
              Issue_Revised_Compl_Date DATE FORMAT 'YY/MM/DD',
              Action_Plan_ID VARCHAR(30) CHARACTER SET LATIN CASESPECIFIC,
              Action_Plan_Name VARCHAR(120) CHARACTER SET LATIN CASESPECIFIC,
              Action_plan_desc VARCHAR(1200) CHARACTER SET LATIN CASESPECIFIC,
              Action_plan_creation_date DATE FORMAT 'YY/MM/DD',
              Issue_target_Compl_Review DATE FORMAT 'YY/MM/DD',
              Issue_Source VARCHAR(80) CHARACTER SET LATIN CASESPECIFIC)
              PRIMARY INDEX (Draaidatum, Volgnummer);

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS  MI_SAS_AA_MB_C_MB.AGRC_IMAT_NEW COLUMN (Maand_nr, Business_Structure_Category, Due_category, Level_of_Concern, Current_Workflow_Step, Issue_Source);
COLLECT STATISTICS  MI_SAS_AA_MB_C_MB.AGRC_IMAT_NEW COLUMN (Maand_nr);
COLLECT STATISTICS  MI_SAS_AA_MB_C_MB.AGRC_IMAT_NEW COLUMN (Business_Structure_Category);
COLLECT STATISTICS  MI_SAS_AA_MB_C_MB.AGRC_IMAT_NEW COLUMN (Due_category);
COLLECT STATISTICS  MI_SAS_AA_MB_C_MB.AGRC_IMAT_NEW COLUMN (Level_of_Concern);
COLLECT STATISTICS  MI_SAS_AA_MB_C_MB.AGRC_IMAT_NEW COLUMN (Current_Workflow_Step);
COLLECT STATISTICS  MI_SAS_AA_MB_C_MB.AGRC_IMAT_NEW COLUMN (Issue_Source);

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS  mi_cmb.medewerkers  COLUMN (party_id);

.IF ERRORCODE <> 0 THEN .GOTO EOP


/*-----------------------------------------------------*/
/*             Ctrack - Risk Management op kredieten   */
/*-----------------------------------------------------*/

CREATE TABLE MI_SAS_AA_MB_C_MB.CTrack_Portfolio_Hist_NEW AS MI_SAS_AA_MB_C_MB.CTrack_Portfolio_Hist WITH DATA
UNIQUE PRIMARY INDEX ( Portfolio_Id, Maand_nr)
PARTITION BY (
               RANGE_N(maand_nr  BETWEEN
                      201801  AND 201812  EACH 1,
                      201901  AND 201912  EACH 1,
                      202001  AND 202012  EACH 1,
                      202101  AND 202112  EACH 1,
                      202201  AND 202212  EACH 1,
                      202301  AND 202312  EACH 1,
                      202401  AND 202412  EACH 1,
                      202501  AND 202512  EACH 1,
                      NO RANGE,
                      UNKNOWN))
;
-- verwijder oude data uit Historie en als nieuwe maand dan blijft historie bestaan

.IF ERRORCODE <> 0 THEN .GOTO EOP

DELETE
FROM MI_SAS_AA_MB_C_MB.CTrack_Portfolio_Hist_NEW
WHERE Maand_nr = (SELECT Maand_nr FROM MI_SAS_AA_MB_C_MB.Mia_periode_NEW)
;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS COLUMN (BORROWER_ID) ON MI_NEMO.CTrack_Portfolio;
COLLECT STATISTICS COLUMN (RELATION_ID) ON MI_NEMO.CTrack_OpenActions;

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

CREATE TABLE MI_SAS_AA_MB_C_MB.medewerker_email_NEW
(naam_mdw 					VARCHAR(255),
account_management_sdat		DATE,
sbt_id          			VARCHAR(255),
Account_Management_Functie  VARCHAR(25),
sbl_functie                 VARCHAR(1000),
BO_nr_mdw                   INTEGER,
BO_naam_mdw                 VARCHAR(256),
emailadres                  VARCHAR(255),
party_adres_status_code     CHAR(3),
party_id                    DECIMAL(13,0),
party_sleutel_type          CHAR(2),
sbt_id_mgr                  VARCHAR(6),
emailadres_mgr              VARCHAR(255))
UNIQUE PRIMARY INDEX (naam_mdw, emailadres, party_id);

.IF ERRORCODE <> 0 THEN .GOTO EOP

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

/*************************************************************************************

    CIB klantbeeld

*************************************************************************************/

COLLECT STATISTICS COLUMN (MAAND_NR) ON mi_cmb.producten;
COLLECT STATISTICS COLUMN (MAAND_NR ,JAAR ,MAAND)	ON mi_cmb.producten_YM;
COLLECT STATISTICS COLUMN (MAAND_NR) ON mi_cmb.producten_YM;
COLLECT STATISTICS COLUMN (JAAR) ON mi_cmb.producten_YM;
COLLECT STATISTICS COLUMN (MAAND) ON mi_cmb.producten_YM;
COLLECT STATISTICS COLUMN (ORG_NIVEAU0) ON MI_SAS_AA_MB_C_MB.CIAA_Mia_hist;
COLLECT STATISTICS COLUMN (BO_NAAM) ON MI_SAS_AA_MB_C_MB.CIAA_Mia_hist;
COLLECT STATISTICS COLUMN (BUSINESS_LINE ,KLANT_NR ,MAAND_NR) ON MI_SAS_AA_MB_C_MB.CIAA_Mia_hist;
COLLECT STATISTICS COLUMN (BUSINESS_LINE ,KLANT_NR) ON MI_SAS_AA_MB_C_MB.CIAA_Mia_hist;

COLLECT STATISTICS COLUMN (CIB_CROSS_SELL, CS_GROEP) ON MI_SAS_AA_MB_C_MB.cib_cross_sell;
COLLECT STATISTICS COLUMN (PRODUCTLEVEL2CODE) ON MI_SAS_AA_MB_C_MB.cib_cross_sell;
COLLECT STATISTICS COLUMN (MAAND_NR, PRODUCTLEVEL2CODE, CIB_CROSS_SELL, CS_GROEP)	ON MI_SAS_AA_MB_C_MB.cib_cross_sell;
COLLECT STATISTICS COLUMN (CS_GROEP) ON MI_SAS_AA_MB_C_MB.cib_cross_sell;
COLLECT STATISTICS COLUMN (MAAND_NR) ON MI_SAS_AA_MB_C_MB.cib_cross_sell;
COLLECT STATISTICS COLUMN (BC_NR ,PRODUCT_GROUP_CODE ,MAAND_NR)	ON mi_cmb.smr_transaction;
COLLECT STATISTICS COLUMN (BC_NR) ON mi_cmb.smr_transaction;
COLLECT STATISTICS COLUMN (MARGIN) ON mi_cmb.smr_transaction;
COLLECT STATISTICS COLUMN (PRODUCT_GROUP_CODE) ON mi_cmb.smr_transaction;
COLLECT STATISTICS COLUMN (TRANSACTION_SOURCE) ON mi_cmb.smr_transaction;
COLLECT STATISTICS COLUMN (MAAND_NR) ON mi_cmb.smr_transaction;
COLLECT STATISTICS COLUMN (KLANT_NR) ON MI_SAS_AA_MB_C_MB.cib_klantbeeld_fondscode;
COLLECT STATISTICS COLUMN (TI) ON mi_tb.stf_gt;
COLLECT STATISTICS COLUMN (CREDITTRX) ON mi_tb.stf_gt;
COLLECT STATISTICS COLUMN (DEBETTRX) ON mi_tb.stf_gt;

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* RAPPORTAGE PERIODE TABELLEN */
CREATE TABLE MI_SAS_AA_MB_C_MB.cib_klantbeeld_rep_cock_NEW AS
(SELECT MAX(maand_nr) AS max_maand_nr FROM mi_cmb.producten) WITH DATA;

.IF ERRORCODE <> 0 THEN .GOTO EOP

CREATE TABLE mi_sas_aa_mb_c_mb.cib_klantbeeld_rep_tb_NEW   AS
(SELECT MAX(billing_period) AS max_billing_period FROM mi_tb.wrk_ce) WITH DATA;

.IF ERRORCODE <> 0 THEN .GOTO EOP

CREATE TABLE mi_sas_aa_mb_c_mb.cib_klantbeeld_rep_lnd_NEW  AS
(SELECT MAX(maand_nr) AS max_maand_nr FROM mi_cmb.vcif_complex) WITH DATA;

.IF ERRORCODE <> 0 THEN .GOTO EOP

CREATE TABLE mi_sas_aa_mb_c_mb.cib_klantbeeld_rep_gm_NEW   AS
(SELECT MAX(maand_nr) AS max_maand_nr FROM mi_cmb.smr_transaction) WITH DATA;

.IF ERRORCODE <> 0 THEN .GOTO EOP

CREATE TABLE mi_sas_aa_mb_c_mb.cib_klantbeeld_rep_dp_NEW   AS
(SELECT MAX(maand_nr) AS max_maand_nr FROM mi_cmb.vcrm_verkoopkans_product_week) WITH DATA;

.IF ERRORCODE <> 0 THEN .GOTO EOP

CREATE TABLE mi_sas_aa_mb_c_mb.cib_klantbeeld_rep_rvb_NEW  AS
(SELECT MAX(datum) AS max_datum FROM mi_cmb.rvdv_scrm_bron4) WITH DATA;

.IF ERRORCODE <> 0 THEN .GOTO EOP

CREATE TABLE mi_sas_aa_mb_c_mb.cib_klantbeeld_rep_cr_NEW   AS
(SELECT klant_nr, CAST(1*MAX("Period") AS INTEGER) AS max_period FROM mi_cmb.cib_keymetrics GROUP BY 1) WITH DATA;

.IF ERRORCODE <> 0 THEN .GOTO EOP

CREATE TABLE mi_sas_aa_mb_c_mb.cib_klantbeeld_rep_si_NEW   AS
(SELECT EXTRACT(YEAR FROM X)*100 + EXTRACT(MONTH FROM X) AS max_maand_nr
	 FROM ( SELECT MAX(fonds_waarde_sdat) AS X FROM mi_vm_ldm.aFONDS_WAARDE ) X) WITH DATA;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS ON MI_SAS_AA_MB_C_MB.cib_klantbeeld_rep_cock_NEW INDEX (max_maand_nr);
COLLECT STATISTICS ON MI_SAS_AA_MB_C_MB.cib_klantbeeld_rep_cr_NEW INDEX (Klant_nr);
COLLECT STATISTICS ON MI_SAS_AA_MB_C_MB.cib_klantbeeld_rep_dp_NEW INDEX (max_maand_nr);
COLLECT STATISTICS ON MI_SAS_AA_MB_C_MB.cib_klantbeeld_rep_gm_NEW INDEX (max_maand_nr);
COLLECT STATISTICS ON MI_SAS_AA_MB_C_MB.cib_klantbeeld_rep_lnd_NEW INDEX (max_maand_nr);
COLLECT STATISTICS ON MI_SAS_AA_MB_C_MB.cib_klantbeeld_rep_rvb_NEW INDEX (max_datum);
COLLECT STATISTICS ON MI_SAS_AA_MB_C_MB.cib_klantbeeld_rep_si_NEW INDEX (max_maand_nr);
COLLECT STATISTICS ON MI_SAS_AA_MB_C_MB.cib_klantbeeld_rep_tb_NEW INDEX (max_billing_period);

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* ------------------------------------------------------------------------------------------------------------------- */
/* KLANTEN TABEL                                                                                                       */
/* ------------------------------------------------------------------------------------------------------------------- */

COLLECT STATISTICS COLUMN (PRIMAIR_CONTACT_PERSOON_IND, EMAIL_BRUIKBAAR, ACTIEF_IND) ON MI_SAS_AA_MB_C_MB.Siebel_Contactpersoon_NEW;
COLLECT STATISTICS COLUMN (CONTACTPERSOON_ONDERDEEL) ON MI_SAS_AA_MB_C_MB.Siebel_Contactpersoon_NEW;
COLLECT STATISTICS COLUMN (ACTIEF_IND) ON MI_SAS_AA_MB_C_MB.Siebel_Contactpersoon_NEW;
COLLECT STATISTICS COLUMN (PRIMAIR_CONTACT_PERSOON_IND) ON MI_SAS_AA_MB_C_MB.Siebel_Contactpersoon_NEW;
COLLECT STATISTICS COLUMN (EMAIL_BRUIKBAAR) ON MI_SAS_AA_MB_C_MB.Siebel_Contactpersoon_NEW;

.IF ERRORCODE <> 0 THEN .GOTO EOP

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
LEFT JOIN MI_SAS_AA_MB_C_MB.cib_klantbeeld_rep_lnd_NEW  REP_LND  ON 1=1
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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS ON MI_SAS_AA_MB_C_MB.cib_klantbeeld_klanten_NEW INDEX (Klant_nr, Business_contact_nr);
COLLECT STATISTICS COLUMN (FONDS_CODE) ON MI_SAS_AA_MB_C_MB.cib_klantbeeld_klanten_NEW;
COLLECT STATISTICS COLUMN (KLANT_NR) ON MI_SAS_AA_MB_C_MB.cib_klantbeeld_klanten_NEW;

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* ------------------------------------------------------------------------------------------------------------------- */
/* COCKPIT TABEL                                                                                                       */
/* ------------------------------------------------------------------------------------------------------------------- */

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS ON MI_SAS_AA_MB_C_MB.cib_klantbeeld_cockpit_NEW INDEX (Klant_nr, cs_groep, maand_nr);

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* ------------------------------------------------------------------------------------------------------------------- */
/* TRANSACTION BANKING                                                                                                 */
/* ------------------------------------------------------------------------------------------------------------------- */

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS ON MI_SAS_AA_MB_C_MB.cib_klantbeeld_tb_NEW INDEX (klant_nr , maand_nr , trx_soort);

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* ------------------------------------------------------------------------------------------------------------------- */
/* LENDING                                                                                                             */
/* ------------------------------------------------------------------------------------------------------------------- */

CREATE TABLE MI_SAS_AA_MB_C_MB.cib_klantbeeld_lnd_NEW AS (
	SELECT
		  K.Klant_nr
		, A.Hoofdrekening
		, A.Fac_bc_nr
		, A.contract_nr
		, RANK() OVER(PARTITION BY Klant_nr ORDER BY Limiet_type,Fac_product_oms DESC,oorspronk_verval_datum DESC,contract_nr) AS volgorde
		, A.Limiet_type
		, A.datum_ingang
		, CASE
			WHEN (upper(Limiet_type) = 'NON LOAN LIMIT') AND /*(upper(Fac_Product_adm_oms) = 'REKENING-COURANT KREDIET/ZAKELIJK') AND*/ (A.oorspronk_verval_datum = DATE '2066-06-06') THEN NULL
			ELSE A.oorspronk_verval_datum
		  END as oorspronk_verval_datum

		, CASE WHEN upper(MUNTCODE) = 'EUR' THEN A.Fac_Product_adm_oms ELSE trim(A.Fac_Product_adm_oms) || ' (' || trim(MUNTCODE) || ' Loan)' END as Fac_Product_adm_oms

		, NULL AS Tot_Ticket
		, A.CLOSING_CR_LIMIT (DECIMAL(18,0)) AS AAB_Ticket
		, CASE
			WHEN A.aflopend_krediet_ind   = 1 THEN A.AFLOPEND_OPGENOMEN
			WHEN A.doorlopend_krediet_ind = 1 THEN A.DOORLOPEND_OPGENOMEN
			ELSE NULL
		  END as AAB_Drawn

		, A.datum_herziening_condities
		, A.syndicate_owned_perc (INTEGER) AS AAB_share

		, NULL as CLOSING_AVAILABLE_AMT			/* niet gebruiken */
		, NULL as TOT_PRINCIPAL_AMT_OUTSTANDING /* niet gebruiken */

	FROM MI_SAS_AA_MB_C_MB.cib_klantbeeld_klanten_NEW K

	LEFT JOIN (SELECT CIF.* FROM mi_cmb.vcif_complex CIF JOIN MI_SAS_AA_MB_C_MB.cib_klantbeeld_rep_lnd REP ON CIF.maand_nr = REP.max_maand_nr) A
	ON K.klant_nr = A.Fac_klant_nr
	AND A.fac_actief_ind = 1
	AND a.Complex_level_laagste_niv_ind = 1

) WITH DATA PRIMARY INDEX(klant_nr);

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS ON MI_SAS_AA_MB_C_MB.cib_klantbeeld_lnd_NEW INDEX (Klant_nr);

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* ------------------------------------------------------------------------------------------------------------------- */
/* BEURSKOERS                                                                                                          */
/* ------------------------------------------------------------------------------------------------------------------- */

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS ON MI_SAS_AA_MB_C_MB.cib_klantbeeld_beurs_NEW INDEX (Klant_nr, Fonds_Waarde_SDAT);

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* ------------------------------------------------------------------------------------------------------------------- */
/*GLOBAL MARKETS - DONE BUSINESS                                                                                       */
/* ------------------------------------------------------------------------------------------------------------------- */

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

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS ON MI_SAS_AA_MB_C_MB.cib_klantbeeld_gmb_NEW INDEX (Klant_nr, bc_nr, maand_nr, Product_Group);

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* ------------------------------------------------------------------------------------------------------------------- */
/* GLOBAL MARKETS - OPEN BUSINESS                                                                                      */
/* ------------------------------------------------------------------------------------------------------------------- */

CREATE TABLE mi_temp.cib_klantbeeld_rep_gmo  AS (SELECT MAX(maand_nr) AS max_maand_nr FROM mi_sas_aa_mb_c_mb.cib_klantbeeld_gmo) WITH DATA;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS COLUMN (MAX_MAAND_NR) ON Mi_temp.cib_klantbeeld_rep_gmo;

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* Maken kopie */
CREATE TABLE mi_sas_aa_mb_c_mb.cib_klantbeeld_gmo_NEW AS mi_sas_aa_mb_c_mb.cib_klantbeeld_gmo WITH DATA
PRIMARY INDEX ( maand_nr ,Klant_nr ,bc_nr ,Product_Group );

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* Verwijderen lopende maand */
DELETE FROM mi_sas_aa_mb_c_mb.cib_klantbeeld_gmo_NEW
WHERE maand_nr = (SEL Max_maand_nr FROM mi_temp.cib_klantbeeld_rep_gmo GROUP BY 1);

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* Toevoegen nieuwe cijfers */
INSERT INTO mi_sas_aa_mb_c_mb.cib_klantbeeld_gmo_NEW
SEL
D.max_maand as maand_nr
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
        END AS product_group
, SUM(A.amount_EUR) AS Volume_EUR
, COUNT(*) AS Aantal_Trx

from mi_cmb.smr_transaction A

left join
(
sel distinct BB.maand_nr, AA.maand_einddatum as max_date
from mi_vm_nzdb.vlu_maand AA

inner join mi_cmb.smr_transaction BB
on AA.maand = (SELECT MAX(AA.maand_nr) AS max_maand FROM mi_cmb.smr_transaction AA)
) B
on A.maand_nr = B.maand_nr

left join
(
sel max(maand_nr) as max_maand
from mi_cmb.smr_transaction
) D
on 1=1

left join mi_sas_aa_mb_c_mb.MIA_businesscontacts_NEW C
on A.bc_nr = C.business_contact_nr

WHERE A.margin NE 0
AND A.bc_nr IS NOT NULL
AND A.product_group_code IN ('FX', 'FXO', 'IRD', 'MM Taken', 'MM Given', 'DCM', 'ECM', 'Credit Bonds', 'Credit Bonds Debt Issues', 'Government Bonds' , 'Securities Finance', 'Equity Brokerage' )
AND C.klant_nr IS NOT NULL
AND A.transaction_source NOT LIKE '%FXPM%'
AND A.end_date > B.max_date

GROUP BY 1, 2, 3, 4;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS ON mi_sas_aa_mb_c_mb.cib_klantbeeld_gmo_NEW INDEX ( maand_nr ,Klant_nr ,bc_nr ,Product_Group );

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* ------------------------------------------------------------------------------------------------------------------- */
/* DEAL PIPELINE - OPEN                                                                                                */
/* ------------------------------------------------------------------------------------------------------------------- */

COLLECT STATISTICS COLUMN (MAAND_NR) ON MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_NEW;
COLLECT STATISTICS COLUMN (OMZET) ON MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_Product_NEW;
COLLECT STATISTICS COLUMN (STATUS) ON MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_Product_NEW;
COLLECT STATISTICS COLUMN (MAAND_NR) ON MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_Product_NEW;

.IF ERRORCODE <> 0 THEN .GOTO EOP

CREATE MULTISET TABLE mi_sas_aa_mb_c_mb.cib_klantbeeld_dpo_NEW AS
      (
	SELECT
		  A.maand_nr
		, A.klant_nr
		, A.productnaam
		, A.productgroep
		, B.naam_verkoopkans
		, A.status
		, A.substatus

		, CAST (A.slagingskans AS DECIMAL(3,0)) AS slagingskans
		, A.baten_totaal_looptijd
		, CAST( A.baten_totaal_Looptijd * slagingskans / 100 AS DECIMAL(22,0)) AS Revenues_Weighted
		, A.datum_laatst_gewijzigd
		, extract(year from A.datum_laatst_gewijzigd)*100 + extract(month from A.datum_laatst_gewijzigd) as maand_nr_laatste_wijziging

		, D.max_maand_nr

	FROM MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_Product_NEW A

	JOIN MI_SAS_AA_MB_C_MB.cib_klantbeeld_klanten_NEW XA
	ON A.klant_nr = XA.klant_nr

	JOIN MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_NEW B
	ON A.maand_nr = B.maand_nr
	AND A.Siebel_verkoopkans_id = B.Siebel_verkoopkans_id
	AND B.naam_verkoopkans not like 'MIGRATED%'

	LEFT JOIN  mi_sas_aa_mb_c_mb.cib_klantbeeld_rep_dp_NEW D
	ON 1=1

	WHERE NOT (A.status LIKE 'Closed %')
	--AND maand_nr_laatste_wijziging > D.max_maand_nr-100

) WITH DATA PRIMARY INDEX (Klant_nr, Maand_nr, productnaam, naam_verkoopkans, status);

.IF ERRORCODE <> 0 THEN .GOTO EOP

UPDATE MI_SAS_AA_MB_C_MB.cib_klantbeeld_dpo_NEW SET productnaam = 'Confidential';
UPDATE MI_SAS_AA_MB_C_MB.cib_klantbeeld_dpo_NEW SET productgroep = 'Confidential';

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS ON MI_SAS_AA_MB_C_MB.cib_klantbeeld_dpo_NEW INDEX (Maand_nr, Klant_nr, Productnaam, Naam_verkoopkans, Status);

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* ------------------------------------------------------------------------------------------------------------------- */
/* DEAL PIPELINE - CLOSED                                                                                              */
/* ------------------------------------------------------------------------------------------------------------------- */

CREATE MULTISET TABLE mi_sas_aa_mb_c_mb.cib_klantbeeld_dpc_NEW AS
      (
	SELECT
		  A.maand_nr
		, A.klant_nr
		, A.productnaam
		, A.productgroep
		, B.naam_verkoopkans
		, A.status
		, A.substatus

		, CAST (A.slagingskans AS DECIMAL(3,0)) AS slagingskans
		, A.baten_totaal_looptijd
		, CAST( A.baten_totaal_Looptijd * slagingskans / 100 AS DECIMAL(22,0)) AS Revenues_Weighted
		, A.datum_laatst_gewijzigd
		, extract(year from A.datum_laatst_gewijzigd)*100 + extract(month from A.datum_laatst_gewijzigd) as maand_nr_laatste_wijziging

		, D.max_maand_nr

	FROM MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_Product_NEW A

	JOIN MI_SAS_AA_MB_C_MB.cib_klantbeeld_klanten_NEW XA
	ON A.klant_nr = XA.klant_nr

	JOIN MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_NEW B
	ON A.maand_nr = B.maand_nr
	AND A.Siebel_verkoopkans_id = B.Siebel_verkoopkans_id
	AND B.naam_verkoopkans not like 'MIGRATED%'

	LEFT JOIN  mi_sas_aa_mb_c_mb.cib_klantbeeld_rep_dp_NEW D
	ON 1=1

	WHERE A.status LIKE 'Closed %'
	  AND maand_nr_laatste_wijziging > D.max_maand_nr-100
) WITH DATA
PRIMARY INDEX (maand_nr, klant_nr, productnaam, naam_verkoopkans, status);

.IF ERRORCODE <> 0 THEN .GOTO EOP

UPDATE MI_SAS_AA_MB_C_MB.cib_klantbeeld_dpc_NEW SET productnaam = 'Confidential';

.IF ERRORCODE <> 0 THEN .GOTO EOP

UPDATE MI_SAS_AA_MB_C_MB.cib_klantbeeld_dpc_NEW SET productgroep = 'Confidential';

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS ON MI_SAS_AA_MB_C_MB.cib_klantbeeld_dpc_NEW INDEX (Maand_nr, Klant_nr, Productnaam, Naam_verkoopkans, Status);

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* ------------------------------------------------------------------------------------------------------------------- */
/* NPS                                                                                                                 */
/* ------------------------------------------------------------------------------------------------------------------- */

CREATE TABLE mi_sas_aa_mb_c_mb.cib_klantbeeld_NPS_NEW
AS
(
SELECT A.klant_nr
    , A.business_contact_nr
    , NPS.kto_id
    , NPS.interview_nr
    , NPS.selectie_id
--    , NPS.business_contact_nr
    , NPS.maand_nr
    , NPS.datum
    , NPS.NPS_ABNAMRO

FROM  mi_sas_aa_mb_c_mb.cib_klantbeeld_klanten_NEW A

LEFT JOIN  (
    SELECT
          AA.kto_id
        , AA.interview_nr
        , AA.selectie_id
        , AA.business_contact_nr
        , AA.maand_nr
        , AA.datum
        , AA.klant_nr
        , CC.vraag_optie_ID as NPS_ABNAMRO

    FROM  MI_CMB.mia_kto_klant_nw21 AA

    LEFT JOIN  mi_cmb.mia_kto_antwoord_nw21 CC
    ON  AA.interview_nr = CC.interview_nr
    AND  CC.vraag_ID = 'AA_NPS'

    WHERE AA.kto_id = 'rNPS'
    AND AA.klant_nr IS NOT NULL

    /* sommige klanten hebben meerdere interviews op een datum. Om die uniek te maken onderstaande rank() uitvoeren         */
    /* Een andere klant maakt het helemaal bont ... daar maakt alleen periode/oms het record uniek AA.klant_nr = 1100635161 */
    QUALIFY RANK() OVER (PARTITION BY AA.klant_nr ORDER BY AA.datum DESC, NPS_ABNAMRO DESC, AA.interview_nr , AA.selectie_id , AA.periode) = 1

) NPS
ON A.klant_nr = NPS.klant_nr
AND ZEROIFNULL(NPS.NPS_ABNAMRO) le 10

) WITH DATA
PRIMARY INDEX (klant_nr);

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS ON MI_SAS_AA_MB_C_MB.cib_klantbeeld_NPS_NEW INDEX (klant_nr);

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* ------------------------------------------------------------------------------------------------------------------- */
/* ADRES                                                                                                               */
/* ------------------------------------------------------------------------------------------------------------------- */

CREATE TABLE MI_SAS_AA_MB_C_MB.cib_klantbeeld_ADRES_NEW AS
(

SELECT
A.klant_nr
, A.business_contact_nr
, B.straatnaam as straatnaam
, B.huis_nr
, B.postcode
, B.stadnaam
, B.land_geogr_id

FROM MI_SAS_AA_MB_C_MB.cib_klantbeeld_klanten_NEW A

LEFT JOIN mi_vm_ldm.aparty_officieel_adres B
ON A.business_contact_nr = B.party_id
AND B.party_sleutel_type = 'BC'


) WITH DATA
PRIMARY INDEX (klant_nr);

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS ON MI_SAS_AA_MB_C_MB.cib_klantbeeld_ADRES_NEW INDEX (klant_nr);

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* ------------------------------------------------------------------------------------------------------------------- */
/* RVB                                                                                                                 */
/* ------------------------------------------------------------------------------------------------------------------- */

CREATE TABLE mi_sas_aa_mb_c_mb.cib_klantbeeld_RVB_NEW AS
(
SELECT A.klant_nr
, CEO.voornaam || ' ' || CEO.tussenvoegsel || ' ' || CEO.achternaam AS CEO_Naam
, CFO.voornaam || ' ' || CFO.tussenvoegsel || ' ' || CFO.achternaam AS CFO_Naam
, RVC1.voornaam || ' ' || RVC1.tussenvoegsel || ' ' || RVC1.achternaam AS RVC1_Naam
, NULL AS RVC2_Naam

FROM mi_sas_aa_mb_c_mb.cib_klantbeeld_klanten_NEW A

LEFT JOIN
(
SELECT
AA.klant_nr
, CASE WHEN AA.contactpersoon_onderdeel = '' THEN 10
	WHEN AA.contactpersoon_onderdeel = 'Niet opgegeven' THEN 20
	WHEN AA.contactpersoon_onderdeel = 'CBI contact' THEN 30
	WHEN AA.contactpersoon_onderdeel = 'Management Algemeen' THEN 40
	WHEN AA.contactpersoon_onderdeel ='General Management' THEN 50
	WHEN AA.contactpersoon_onderdeel ='Raad van Bestuur' THEN 60
	WHEN AA.contactpersoon_onderdeel ='Board of Directors' THEN 70
ELSE 0 END AS Onderdeel_Score
, CASE WHEN AA.contactpersoon_functietitel IN ('CEO', 'C.E.O.', 'CEO%') THEN 2
	WHEN AA.contactpersoon_functietitel IN ( 'Algemeen directeur', 'RvB voorzitter' ) THEN 1
ELSE 0 END AS functie_score
, onderdeel_score + functie_score AS job_score
, AA.voornaam
, AA.tussenvoegsel
, AA.achternaam

FROM  MI_SAS_AA_MB_C_MB.Siebel_Contactpersoon_NEW AA

WHERE functie_score  > 0

QUALIFY ROW_NUMBER() OVER(PARTITION BY klant_nr ORDER BY job_score DESC) = 1

) CEO
ON A.klant_nr = CEO.klant_nr

LEFT JOIN
(
SELECT
AA.klant_nr
, CASE WHEN AA.contactpersoon_onderdeel = '' THEN 10
	WHEN AA.contactpersoon_onderdeel = 'Financiële Management' THEN 20
	WHEN AA.contactpersoon_onderdeel = 'Financial Management' THEN 30
	WHEN AA.contactpersoon_onderdeel = 'Financieel Management' THEN 40
	WHEN AA.contactpersoon_onderdeel ='Finance' THEN 50
	WHEN AA.contactpersoon_onderdeel ='Raad van Bestuur' THEN 60
	WHEN AA.contactpersoon_onderdeel ='Board of Directors' THEN 70
ELSE 0 END AS Onderdeel_Score
, CASE WHEN AA.contactpersoon_functietitel IN ('CFO', 'C.F.O.', 'Financieel directeur', 'CFO%', 'Financial Manager', 'Directeur Financien', 'Financieel Directeur', 'Financial Director', 'Chief Financial Officer', 'Hoofd Financien', 'Finance Director'
) THEN 1 ELSE 0 END AS functie_score
, onderdeel_score + functie_score AS job_score
, AA.voornaam
, AA.tussenvoegsel
, AA.achternaam

FROM  MI_SAS_AA_MB_C_MB.Siebel_Contactpersoon_NEW AA

QUALIFY ROW_NUMBER() OVER(PARTITION BY klant_nr ORDER BY job_score DESC) = 1

WHERE functie_score  > 0

) CFO
ON A.klant_nr = CFO.klant_nr

LEFT JOIN
(
SELECT
AA.klant_nr
, CASE WHEN AA.contactpersoon_onderdeel = 'Raad van Commissarissen' THEN 10
	WHEN AA.contactpersoon_onderdeel = 'Supervisory Board' THEN 20
ELSE 0 END AS Onderdeel_Score
, CASE WHEN AA.contactpersoon_functietitel IN ( 'RvC voorzitter', 'Supervisory Board President' ) THEN 1 ELSE 0 END AS functie_score
, onderdeel_score + functie_score AS job_score
, AA.voornaam
, AA.tussenvoegsel
, AA.achternaam

FROM MI_SAS_AA_MB_C_MB.Siebel_Contactpersoon_NEW AA

QUALIFY ROW_NUMBER() OVER(PARTITION BY klant_nr ORDER BY job_score DESC) = 1

WHERE functie_score  > 0

) RVC1
ON A.klant_nr = RVC1.klant_nr

) WITH DATA
PRIMARY INDEX (klant_nr);

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS ON MI_SAS_AA_MB_C_MB.cib_klantbeeld_RVB_NEW INDEX (klant_nr);

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* ------------------------------------------------------------------------------------------------------------------- */
/* UCR                                                                                                                 */
/* ------------------------------------------------------------------------------------------------------------------- */

CREATE TABLE mi_sas_aa_mb_c_mb.cib_klantbeeld_UCR_NEW AS
(
SELECT
A.klant_nr
, CASE WHEN B.fac_bc_ucr IS NULL THEN '-' ELSE B.fac_bc_ucr  END AS UCR

FROM mi_sas_aa_mb_c_mb.cib_klantbeeld_klanten_NEW A

LEFT JOIN
(
SELECT
aa.fac_klant_nr
, aa.fac_bc_ucr

FROM mi_cmb.cif_complex AA

QUALIFY ROW_NUMBER() OVER(PARTITION BY fac_klant_nr ORDER BY OOE DESC) = 1

WHERE AA.maand_nr = (SELECT MAX(maand_nr) FROM mi_cmb.cif_complex)
AND AA.fac_actief_ind =1
AND AA.fac_klant_nr IS NOT NULL
AND AA.fac_bc_ucr IS NOT NULL
) b
ON A.klant_nr = B.fac_klant_nr

) WITH DATA
PRIMARY INDEX (klant_nr);

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS ON MI_SAS_AA_MB_C_MB.cib_klantbeeld_UCR_NEW INDEX (klant_nr);

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* ------------------------------------------------------------------------------------------------------------------- */
/* DPX                                                                                                                 */
/* ------------------------------------------------------------------------------------------------------------------- */

CREATE MULTISET TABLE mi_sas_aa_mb_c_mb.cib_klantbeeld_DPX_NEW AS (

	SELECT
		  A.maand_nr
		, A.klant_nr
		, A.productgroep
		, A.productnaam
		, B.naam_verkoopkans
		, A.status
		, A.substatus

		, CAST (A.slagingskans AS DECIMAL(3,0)) AS slagingskans
		, A.baten_totaal_looptijd
		, CAST( A.baten_totaal_Looptijd * slagingskans / 100 AS DECIMAL(22,0)) AS Revenues_Weighted
		, A.datum_laatst_gewijzigd
		, extract(year from A.datum_laatst_gewijzigd)*100 + extract(month from A.datum_laatst_gewijzigd) as maand_nr_laatste_wijziging

		, D.max_maand_nr

		, A.sbt_id_mdw_eigenaar
		, A.sbt_id_mdw_aangemaakt_door as sbt_id_mdw_aangemaakt_door_vkp
		, B.deal_captain_mdw_sbt_id
		, B.sbt_id_mdw_aangemaakt_door as sbt_id_mdw_aangemaakt_door_vk
		, B.sbt_id_mdw_bijgewerkt_door

		, XA.relatiemanager
		, XA.sbt_id

		, case
			when ( (A.status LIKE 'Closed %'    ) ) then 'closed'
			when ( NOT (A.status LIKE 'Closed %') ) then 'open'
			else 'tbd'
		end as dp_status

		, case
			when A.sbt_id_mdw_aangemaakt_door like '%@SSP%' then 0
			when B.sbt_id_mdw_bijgewerkt_door like '%@SSP%' then 0
			when trim(XA.sbt_id) = trim(A.sbt_id_mdw_aangemaakt_door) then 1
			when trim(XA.sbt_id) = trim(B.sbt_id_mdw_aangemaakt_door) then 1
			when trim(XA.sbt_id) = trim(B.sbt_id_mdw_bijgewerkt_door) then 1
			else 0
		end dp_select

FROM MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_Product_NEW A

	JOIN (
		-- de gebruikelijke klanten 'ophalen' maar voorzien van sbt-id van de coverage banker
		select K.klant_nr , K.cca , K.relatiemanager , M.sbt_id
		from MI_SAS_AA_MB_C_MB.cib_klantbeeld_klanten_NEW K

		left join mi_vm_nzdb.vmedewerker M
		on K.cca = M.adviseur
		and K.maand_nr = M.maand
	) XA
	ON A.klant_nr = XA.klant_nr

	JOIN MI_SAS_AA_MB_C_MB.Siebel_Verkoopkans_NEW B

	ON A.maand_nr = B.maand_nr
	AND A.Siebel_verkoopkans_id = B.Siebel_verkoopkans_id
	AND B.naam_verkoopkans not like 'MIGRATED%'

	LEFT JOIN  mi_sas_aa_mb_c_mb.cib_klantbeeld_rep_dp_NEW D
	ON 1=1

--	WHERE ( Closed deals mochten niet ouder dan 12 maanden zijn                              ) OR ( Alle open deals                )
	WHERE ( (A.status LIKE 'Closed %') AND (maand_nr_laatste_wijziging > D.max_maand_nr-100) ) OR ( NOT (A.status LIKE 'Closed %') )

) WITH DATA
PRIMARY INDEX (maand_nr, klant_nr, productnaam, naam_verkoopkans, status);

.IF ERRORCODE <> 0 THEN .GOTO EOP

UPDATE MI_SAS_AA_MB_C_MB.cib_klantbeeld_DPX_NEW SET productnaam = 'Confidential';

.IF ERRORCODE <> 0 THEN .GOTO EOP

UPDATE MI_SAS_AA_MB_C_MB.cib_klantbeeld_DPX_NEW SET productgroep = 'Confidential';

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS ON MI_SAS_AA_MB_C_MB.cib_klantbeeld_DPX_NEW INDEX (Maand_nr, Klant_nr, Productnaam, Naam_verkoopkans, Status);

.IF ERRORCODE <> 0 THEN .GOTO EOP

/*************************************************************************************

        Productboom_rationalisatie

*************************************************************************************/

CREATE TABLE MI_SAS_AA_MB_C_MB.Productboom_rationalisatie_NEW
      (
       Prod_lvl_6_id VARCHAR(10) CHARACTER SET LATIN NOT CASESPECIFIC NOT NULL,
       Prod_lvl_6_desc VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC,
       Prod_lvl_5_id INTEGER NOT NULL,
       Prod_lvl_5_desc VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC,
       Prod_lvl_4_id INTEGER NOT NULL,
       Prod_lvl_4_desc VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC,
       Prod_lvl_3_id INTEGER NOT NULL,
       Prod_lvl_3_desc VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC,
       Prod_lvl_2_id INTEGER NOT NULL,
       Prod_lvl_2_desc VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC,
       Prod_lvl_1_id INTEGER NOT NULL,
       Prod_lvl_1_desc VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC,
       CA_id INTEGER NOT NULL,
       CA_desc VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC,
       Tech_key VARCHAR(60) CHARACTER SET LATIN NOT CASESPECIFIC,
       Bron VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC,
       MSTR_view VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC,
       Teradata_tabel_boom VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC,
       Teradata_databron_1 VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC,
       Teradata_databron_2 VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC,
       Prod_status_id INTEGER NOT NULL DEFAULT 9999 ,
       Prod_status_desc VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC DEFAULT 'TBD',
       Hash_row BYTE(4),
       Prod_status_3_id INTEGER,
       Prod_status_3_desc VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC DEFAULT 'TBD',
       Prod_status_4_id INTEGER,
       Prod_status_4_desc VARCHAR(30) CHARACTER SET LATIN NOT CASESPECIFIC DEFAULT 'TBD'
      )
PRIMARY INDEX ( Prod_lvl_6_id, Prod_lvl_5_id, Prod_lvl_4_id, Prod_lvl_3_id, Prod_lvl_2_id, Prod_lvl_1_id );

.IF ERRORCODE <> 0 THEN .GOTO EOP

INSERT INTO MI_SAS_AA_MB_C_MB.Productboom_rationalisatie_NEW
SELECT A.*
  FROM Mi_cmb.Productboom_rationalisatie A;

.IF ERRORCODE <> 0 THEN .GOTO EOP

/*************************************************************************************

        Mia_gekoppelde_personen_hist

*************************************************************************************/

CREATE TABLE Mi_temp.Mia_businesscontacts_KvK
      (
       Klant_nr INTEGER,
       Maand_nr INTEGER,
       Business_contact_nr DECIMAL(12,0),
       Bc_KvK_nr CHAR(12) CHARACTER SET LATIN NOT CASESPECIFIC,
       Geldige_KvK_inschrijving BYTEINT,
       KvK_nr CHAR(12) CHARACTER SET LATIN NOT CASESPECIFIC,
       N_werkzame_personen_tot INTEGER,
       N_werkzame_personen_full INTEGER,
       Economisch_actief BYTEINT,
       KvK_Onderneming_ind BYTEINT,
       KvK_Vereniging_ind BYTEINT,
       KvK_Stichting_ind BYTEINT,
       KvK_Kerkgenoot_ind BYTEINT,
       KvK_rechtsvorm CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC
      )
UNIQUE PRIMARY INDEX ( Klant_nr, Maand_nr, Business_contact_nr );

.IF ERRORCODE <> 0 THEN .GOTO EOP

INSERT INTO Mi_temp.Mia_businesscontacts_KvK
SELECT A.Klant_nr,
       A.Maand_nr,
       A.Business_contact_nr,
       A.Bc_kvk_nr,
       CASE WHEN B.KvK_nummer IS NOT NULL THEN 1 ELSE 0 END AS Geldige_KvK_inschrijving,
       B.KvK_nummer AS KvK_nr,
       B.N_werkzame_personen_tot,
       B.N_werkzame_personen_full,
       B.Economisch_actief,
       CASE WHEN B.Soort_onderneming = 'O' THEN 1 ELSE 0 END AS KvK_Onderneming_ind,
       CASE WHEN B.Soort_onderneming = 'V' THEN 1 ELSE 0 END AS KvK_Vereniging_ind,
       CASE WHEN B.Soort_onderneming = 'S' THEN 1 ELSE 0 END AS KvK_Stichting_ind,
       CASE WHEN B.Soort_onderneming = 'K' THEN 1 ELSE 0 END AS KvK_Kerkgenoot_ind,
       B.KvK_rechtsvorm
  FROM Mi_sas_aa_mb_c_mb.Mia_businesscontacts_NEW A
  LEFT OUTER JOIN (SELECT A.KvK_nummer AS KvK_nummer,
                          1*(CASE WHEN A.Aant_werkzame_pers_tot BETWEEN '0000000' AND '9999999' THEN A.Aant_werkzame_pers_tot ELSE 0 END) AS N_werkzame_personen_tot,
                          1*(CASE WHEN A.Aant_werkzame_pers_full BETWEEN '0000000' AND '9999999' THEN A.Aant_werkzame_pers_full ELSE 0 END) AS N_werkzame_personen_full,
                          A.Economisch_acteif AS Economisch_actief,
                          A.Soort_onderneming,
                          A.Rechtsvorm_fijn AS KvK_rechtsvorm
                     FROM (SELECT *
                            FROM Mi_vm.vKvk XA
                         QUALIFY ROW_NUMBER() OVER(PARTITION BY Kvk_nummer
                                                      ORDER BY CASE WHEN XA.datum_opheffing <> '00.00.0000' THEN 0 ELSE 1 END DESC,
                                                               CASE XA.hoofd_fil_ind WHEN 'H' THEN 1 ELSE 0 END DESC,
                                                               CASE WHEN XA.branche_number <> '' THEN 1 ELSE 0 END DESC,
                                                               CASE WHEN XA.datum_inschrijving <> '00.00.0000' THEN CAST(XA.datum_inschrijving AS DATE FORMAT 'DD.MM.YYYY') END DESC,
                                                               XA.mut_branch_num,
                                                               XA.mut_ca_postcode,
                                                               XA.mut_zaak_postcode,
                                                               XA.branche_number) = 1) A
                    WHERE A.Vestigings_indicator NOT IN ('H', 'E')) B
    ON A.Bc_kvk_nr = B.KvK_nummer
 WHERE A.Klant_nr IS NOT NULL;

.IF ERRORCODE <> 0 THEN .GOTO EOP

CREATE TABLE Mi_temp.Mia_gekoppelden
      (
       Klant_nr INTEGER,
       Maand_nr INTEGER,
       Business_contact_nr DECIMAL(12,0),
       Rol_code VARCHAR(6) CHARACTER SET LATIN NOT CASESPECIFIC NOT NULL,
       Rol_nr BYTEINT,
       Rol_oms VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC NOT NULL,
       Fhh_nr INTEGER,
       Pcnl_nr INTEGER,
       Gekoppeld_Bc_nr DECIMAL(12,0),
       Gekoppeld_Bc_naam VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC,
       Gekoppeld_Bc_clientgroep VARCHAR(256) CHARACTER SET LATIN NOT CASESPECIFIC,
       Gekoppeld_Bc_businessline VARCHAR(256) CHARACTER SET LATIN NOT CASESPECIFIC,
       Gekoppeld_Bc_relatiecategorie SMALLINT,
       Gekoppeld_Bc_verschijningsvorm_oms VARCHAR(256) CHARACTER SET LATIN NOT CASESPECIFIC,
       Gekoppeld_Bc_natuurlijke_persoon_ind BYTEINT,
       Gekoppeld_Bc_contracten BYTEINT,
       Gekoppeld_Bc_nationaliteit CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC,
       Gekoppeld_Bc_geboorte_datum DATE FORMAT 'YYYYMMDD',
       Gekoppeld_Bc_leeftijd INTEGER,
       Gekoppeld_Bc_overleden_ind BYTEINT,
       Gekoppeld_Bc_geslacht CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
       Gekoppeld_Bc_postcode CHAR(6) CHARACTER SET LATIN NOT CASESPECIFIC,
       Onderneming_aan_huis BYTEINT,
       Geldige_KvK_inschrijving BYTEINT
      )
UNIQUE PRIMARY INDEX ( Klant_nr, Business_contact_nr, Maand_nr, Rol_code, Gekoppeld_Bc_nr )
INDEX ( Fhh_nr )
INDEX ( Pcnl_nr );

.IF ERRORCODE <> 0 THEN .GOTO EOP

INSERT INTO Mi_temp.Mia_gekoppelden
SELECT A.Klant_nr,
       A.Maand_nr,
       A.Business_contact_nr,
       C.Rol_code,
       C.Rol_nr,
       C.Rol_oms,
       CASE WHEN F.Business_line = 'Retail' THEN D.Fhh_nr ELSE NULL END AS Fhh_nr,
       CASE WHEN F.Business_line = 'PB' THEN D.Pcnl_nr ELSE NULL END AS Pc_nl_nr,
       B.Party_id AS Gekoppeld_Bc_nr,
       D.Bc_naam AS Gekoppeld_Bc_naam,
       D.Bc_clientgroep AS Gekoppeld_Bc_clientgroep,
       F.Business_line AS Gekoppeld_Bc_businessline,
       D.Bc_relatiecategorie AS Gekoppeld_Bc_relatiecategorie,
       D.Bc_verschijningsvorm_oms AS Gekoppeld_Bc_verschijningsvorm_oms,
       CASE WHEN D.Bc_verschijningsvorm IN (1, 2, 3) THEN 1 ELSE 0 END AS Gekoppeld_Bc_natuurlijke_persoon_ind,
       D.Bc_contracten AS Gekoppeld_Bc_contracten,
       E.Nationaliteit AS Gekoppeld_Bc_nationaliteit,
       E.Geboorte_datum AS Gekoppeld_Bc_geboorte_datum,
       (CASE
        WHEN EXTRACT(DAY FROM A.Datum_gegevens) < EXTRACT(DAY FROM E.Geboorte_datum) THEN (((A.Datum_gegevens - E.Geboorte_datum) MONTH(4)) (INTEGER)) - 1
        ELSE (((A.Datum_gegevens - E.Geboorte_datum) MONTH(4)) (INTEGER))
        END) / 12 AS Gekoppeld_Bc_leeftijd,
       E.Overleden_ind AS Gekoppeld_Bc_overleden_ind,
       E.Geslacht AS Gekoppeld_Bc_geslacht,
       D.Bc_postcode AS Gekoppeld_Bc_postcode,
       CASE WHEN G.Post_adres_id = H.Post_adres_id THEN 1 ELSE 0 END Onderneming_aan_huis,
       ZEROIFNULL(X.Geldige_KvK_inschrijving) AS Geldige_KvK_inschrijving
  FROM Mi_sas_aa_mb_c_mb.Mia_businesscontacts_NEW A
  JOIN Mi_vm_ldm.aParty_party_relatie B
    ON A.Business_contact_nr = B.Gerelateerd_party_id
  JOIN Mi_sas_aa_mb_c_mb.Mia_rollen_natuurlijke_personen C
    ON B.Party_relatie_type_code = C.Rol_code
  JOIN Mi_sas_aa_mb_c_mb.Mia_businesscontacts_NEW D
    ON B.Party_id = D.Business_contact_nr
  LEFT OUTER JOIN Mi_vm_ldm.aIndividu E
    ON B.Party_id = E.Party_id
   AND E.Party_sleutel_type = 'BC'
  LEFT OUTER JOIN Mi_sas_aa_mb_c_mb.Cgc_basis F
    ON D.Bc_clientgroep = F.Clientgroep
  LEFT OUTER JOIN Mi_vm_ldm.aParty_post_adres G
    ON B.Party_id = G.Party_id
   AND G.Party_sleutel_type = 'BC'
   AND G.Adres_gebruik_type_code = 'AV'
  LEFT OUTER JOIN Mi_vm_ldm.aParty_post_adres H
    ON A.Business_contact_nr = H.Party_id
   AND H.Party_sleutel_type = 'BC'
   AND H.Adres_gebruik_type_code = 'AV'
  LEFT OUTER JOIN Mi_temp.Mia_businesscontacts_KvK X
    ON A.Business_contact_nr = X.Business_contact_nr
 WHERE A.Klant_nr IS NOT NULL;

.IF ERRORCODE <> 0 THEN .GOTO EOP

CREATE TABLE Mi_temp.Mia_gekoppelde_personen
      (
       Klant_nr INTEGER,
       Maand_nr INTEGER,
       Rol_code VARCHAR(6) CHARACTER SET LATIN NOT CASESPECIFIC NOT NULL,
       Rol_nr BYTEINT,
       Rol_oms VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC NOT NULL,
       Fhh_nr INTEGER,
       Pcnl_nr INTEGER,
       Persoon_Bc_nr DECIMAL(12,0),
       Persoon_Bc_naam VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC,
       Persoon_Bc_clientgroep VARCHAR(256) CHARACTER SET LATIN NOT CASESPECIFIC,
       Persoon_Bc_businessline VARCHAR(256) CHARACTER SET LATIN NOT CASESPECIFIC,
       Persoon_Bc_relatiecategorie SMALLINT,
       Persoon_Bc_verschijningsvorm_oms VARCHAR(256) CHARACTER SET LATIN NOT CASESPECIFIC,
       Persoon_Bc_contracten BYTEINT,
       Persoon_Bc_nationaliteit CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC,
       Persoon_Bc_geboorte_datum DATE FORMAT 'YYYYMMDD',
       Persoon_Bc_leeftijd INTEGER,
       Persoon_Bc_overleden_ind BYTEINT,
       Persoon_Bc_geslacht CHAR(1) CHARACTER SET LATIN NOT CASESPECIFIC,
       Persoon_Bc_postcode CHAR(6) CHARACTER SET LATIN NOT CASESPECIFIC,
       Onderneming_aan_huis BYTEINT
      )
UNIQUE PRIMARY INDEX ( Klant_nr, Maand_nr, Rol_code, Persoon_Bc_nr )
INDEX ( Fhh_nr )
INDEX ( Pcnl_nr );

.IF ERRORCODE <> 0 THEN .GOTO EOP

INSERT INTO Mi_temp.Mia_gekoppelde_personen
SELECT A.Klant_nr,
       A.Maand_nr,
       A.Rol_code,
       A.Rol_nr,
       A.Rol_oms,
       A.Fhh_nr,
       A.Pcnl_nr,
       A.Gekoppeld_Bc_nr AS Persoon_Bc_nr,
       A.Gekoppeld_Bc_naam AS Persoon_Bc_naam,
       A.Gekoppeld_Bc_clientgroep AS Persoon_Bc_clientgroep,
       A.Gekoppeld_Bc_businessline AS Persoon_Bc_businessline,
       A.Gekoppeld_Bc_relatiecategorie AS Persoon_Bc_relatiecategorie,
       A.Gekoppeld_Bc_verschijningsvorm_oms AS Persoon_Bc_verschijningsvorm_oms,
       A.Gekoppeld_Bc_contracten AS Persoon_Bc_contacten,
       A.Gekoppeld_Bc_nationaliteit AS Persoon_Bc_nationaliteit,
       A.Gekoppeld_Bc_geboorte_datum AS Persoon_Bc_geboortedatum,
       A.Gekoppeld_Bc_leeftijd AS Persoon_Bc_leeftijd,
       A.Gekoppeld_Bc_overleden_ind AS Persoon_Bc_overleden_ind,
       A.Gekoppeld_Bc_geslacht As Persoon_Bc_geslacht,
       A.Gekoppeld_Bc_postcode AS Persoon_Bc_postcode,
       A.Onderneming_aan_huis
  FROM Mi_temp.Mia_gekoppelden A
-- Alleen gekoppelde natuurlijke personen (bestuurders en/of bevoegden)
 WHERE A.Gekoppeld_Bc_natuurlijke_persoon_ind = 1
-- Alleen zakelijke klanten met geldige KvK inschrijving
   AND A.Geldige_KvK_inschrijving = 1
QUALIFY RANK () OVER (PARTITION BY A.Klant_nr, A.Maand_nr, A.Gekoppeld_Bc_naam, A.Gekoppeld_Bc_geboorte_datum ORDER BY A.Rol_nr, A.Gekoppeld_bc_nr, A.Business_contact_nr) = 1;

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* kopie */
CREATE TABLE Mi_sas_aa_mb_c_mb.Mia_gekoppelde_personen_hist_NEW AS Mi_sas_aa_mb_c_mb.Mia_gekoppelde_personen_hist WITH DATA
UNIQUE PRIMARY INDEX ( Klant_nr, Maand_nr, Rol_code, Persoon_Bc_nr )
INDEX ( Fhh_nr )
INDEX ( Pcnl_nr );

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_sas_aa_mb_c_mb.Mia_gekoppelde_personen_hist_NEW COLUMN (PARTITION);

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* WEEKCIJFERS VERWIJDEREN INDIEN MAAND REEDS AANWEZIG VAN VORIGE WEEK */
DELETE FROM Mi_sas_aa_mb_c_mb.Mia_gekoppelde_personen_hist_NEW A
 WHERE A.Maand_nr = (SELECT X.Maand_nr FROM Mi_temp.Mia_gekoppelde_personen X GROUP BY 1);

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_sas_aa_mb_c_mb.Mia_gekoppelde_personen_hist_NEW COLUMN (PARTITION);

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* WEEKCIJFERS TOEVOEGEN */

INSERT INTO Mi_sas_aa_mb_c_mb.Mia_gekoppelde_personen_hist_NEW
SELECT A.*
  FROM Mi_temp.Mia_gekoppelde_personen A;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COMMENT ON Mi_sas_aa_mb_c_mb.Mia_gekoppelde_personen_hist_NEW AS 'NIET VERWIJDEREN - Afdelingstabel in schedulescript';

.IF ERRORCODE <> 0 THEN .GOTO EOP

/*************************************************************************************

        Mia_bedrijfstype_hist

*************************************************************************************/

-------------------------------------------
-- Mi_temp.Mia_personen_samenvatting
-------------------------------------------

CREATE TABLE Mi_temp.Mia_personen_samenvatting
      (
       Klant_nr INTEGER,
       Maand_nr INTEGER,
       Aantal_verschillende_rollen INTEGER,
       Aantal_personen INTEGER,
       Rol_oms_MIN VARCHAR(29) CHARACTER SET UNICODE NOT CASESPECIFIC,
       Rol_oms_MAX VARCHAR(29) CHARACTER SET UNICODE NOT CASESPECIFIC,
       Aantal_Belanghebbenden INTEGER,
       Aantal_Bestuurders INTEGER,
       Aantal_Overige_bestuurders INTEGER,
       Aantal_Ondernemers INTEGER,
       Aantal_Eigenaren INTEGER,
       Aantal_Commanditaire_vennoten INTEGER,
       Aantal_Vennoten INTEGER,
       Aantal_Stille_venoten INTEGER,
       Aantal_Maten INTEGER,
       Aantal_Aansprakelijke_personen_BNVio INTEGER,
       Aantal_Aansprakelijke_personen_IV INTEGER,
       Aantal_Particuliere_deelnemers INTEGER,
       Aantal_particuliere_klanten INTEGER,
       Aantal_bediening_Retail INTEGER,
       Aantal_bediening_Private INTEGER,
       Aantal_nationaliteit_Nederland INTEGER,
       Aantal_nationaliteit_Buitenland INTEGER,
       Aantal_vrouwen INTEGER,
       Aantal_mannen INTEGER
      )
UNIQUE PRIMARY INDEX ( Klant_nr, Maand_nr );

.IF ERRORCODE <> 0 THEN .GOTO EOP

INSERT INTO Mi_temp.Mia_personen_samenvatting
SELECT A.Klant_nr,
       A.Maand_nr,
       COUNT(DISTINCT B.Rol_code) AS Aantal_verschillende_rollen,
       COUNT(DISTINCT B.Persoon_Bc_naam||B.Persoon_Bc_geboorte_datum) AS Aantal_personen,
       MIN(B.Rol_oms) AS Rol_oms_MIN,
       MAX(B.Rol_oms) AS Rol_oms_MAX,
       SUM(CASE WHEN B.Rol_oms = 'Uiteindelijk belanghebbende'                    THEN 1 ELSE 0 END) AS Aantal_Belanghebbenden,
       SUM(CASE WHEN B.Rol_oms = 'Bestuurder'                                     THEN 1 ELSE 0 END) AS Aantal_Bestuurders,
       SUM(CASE WHEN B.Rol_oms = 'Overig bestuurder'                              THEN 1 ELSE 0 END) AS Aantal_Overige_bestuurders,
       SUM(CASE WHEN B.Rol_oms = 'Ondernemer (OenO)'                              THEN 1 ELSE 0 END) AS Aantal_Ondernemers,
       SUM(CASE WHEN B.Rol_oms = 'Eigenaar'                                       THEN 1 ELSE 0 END) AS Aantal_Eigenaren,
       SUM(CASE WHEN B.Rol_oms = 'Vennoot (CV)'                                   THEN 1 ELSE 0 END) AS Aantal_Commanditaire_vennoten,
       SUM(CASE WHEN B.Rol_oms = 'Vennoot (VOF)'                                  THEN 1 ELSE 0 END) AS Aantal_Vennoten,
       SUM(CASE WHEN B.Rol_oms = 'Stille Vennoot'                                 THEN 1 ELSE 0 END) AS Aantal_Stille_venoten,
       SUM(CASE WHEN B.Rol_oms = 'Maat'                                           THEN 1 ELSE 0 END) AS Aantal_Maten,
       SUM(CASE WHEN B.Rol_oms = 'Aansprakelijk persoon (BV of NV in oprichting)' THEN 1 ELSE 0 END) AS Aantal_Aansprakelijke_personen_BNVio,
       SUM(CASE WHEN B.Rol_oms = 'Aansprakelijk persoon (Informele Vereniging)'   THEN 1 ELSE 0 END) AS Aantal_Aansprakelijke_personen_IV,
       SUM(CASE WHEN B.Rol_oms = 'Particuliere deelnemer'                         THEN 1 ELSE 0 END) AS Aantal_Particuliere_deelnemers,
       COUNT(DISTINCT COALESCE(B.Fhh_nr, B.Pcnl_nr)) AS Aantal_particuliere_klanten,
       SUM(CASE WHEN B.Persoon_Bc_businessline = 'Retail'  THEN 1 ELSE 0 END) AS Aantal_bediening_Retail,
       SUM(CASE WHEN B.Persoon_Bc_businessline = 'PB'  THEN 1 ELSE 0 END) AS Aantal_bediening_Private,
       SUM(CASE WHEN B.Persoon_Bc_Nationaliteit =  'NL' THEN 1 ELSE 0 END) AS Aantal_nationaliteit_Nederland,
       SUM(CASE WHEN B.Persoon_Bc_Nationaliteit NE 'NL' THEN 1 ELSE 0 END) AS Aantal_nationaliteit_Buitenland,
       SUM(CASE WHEN B.Persoon_Bc_Geslacht = 'V' THEN 1 ELSE 0 END) AS Aantal_vrouwen,
       SUM(CASE WHEN B.Persoon_Bc_Geslacht = 'M' THEN 1 ELSE 0 END) AS Aantal_mannen
  FROM Mi_temp.Mia_week A
  LEFT OUTER JOIN Mi_temp.Mia_gekoppelde_personen B
    ON A.Klant_nr = B.Klant_nr AND A.Maand_nr = B.Maand_nr
 GROUP BY 1, 2;

.IF ERRORCODE <> 0 THEN .GOTO EOP

-------------------------------------------
-- Mi_temp.Bedrijfstype_basis_001
-------------------------------------------

CREATE TABLE Mi_temp.Bedrijfstype_basis_001
      (
       Klant_nr INTEGER,
       Maand_nr INTEGER,
       Aantal_rechtsvormen INTEGER,
       Rechtsvorm_oms_MIN VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC,
       Rechtsvorm_oms_MAX VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC,
       Eenmanszaak_ind BYTEINT,
       Maatschap_ind BYTEINT,
       VOF_ind BYTEINT,
       CV_ind BYTEINT,
       BV_ind BYTEINT,
       NV_ind BYTEINT,
       NVBVio_ind BYTEINT,
       Cooperatie_ind BYTEINT,
       Waarborgmaatschap_ind BYTEINT,
       Vereniging_ind BYTEINT,
       Stichting_ind BYTEINT,
       Kerkgenootschap_ind BYTEINT,
       Buitenland_ind BYTEINT,
       Anders_ind BYTEINT,
       Onbekend_ind BYTEINT
      )
UNIQUE PRIMARY INDEX ( Klant_nr, Maand_nr );

.IF ERRORCODE <> 0 THEN .GOTO EOP

INSERT INTO Mi_temp.Bedrijfstype_basis_001
SELECT A.Klant_nr,
       A.Maand_nr,
       COUNT(DISTINCT C.Rechtsvorm_nr) AS Aantal_rechtsvormen,
       MIN(C.Rechtsvorm_oms) AS Rechtsvorm_oms_MIN,
       MAX(C.Rechtsvorm_oms) AS Rechtsvorm_oms_MAX,
       MAX(CASE WHEN C.Rechtsvorm_oms = 'Eenmanszaak'       THEN 1 ELSE 0 END) AS Eenmanszaak_ind,
       MAX(CASE WHEN C.Rechtsvorm_oms = 'Maatschap'         THEN 1 ELSE 0 END) AS Maatschap_ind,
       MAX(CASE WHEN C.Rechtsvorm_oms = 'VOF'               THEN 1 ELSE 0 END) AS VOF_ind,
       MAX(CASE WHEN C.Rechtsvorm_oms = 'CV'                THEN 1 ELSE 0 END) AS CV_ind,
       MAX(CASE WHEN C.Rechtsvorm_oms = 'BV'                THEN 1 ELSE 0 END) AS BV_ind,
       MAX(CASE WHEN C.Rechtsvorm_oms = 'NV'                THEN 1 ELSE 0 END) AS NV_ind,
       MAX(CASE WHEN C.Rechtsvorm_oms = 'NV of BV io'       THEN 1 ELSE 0 END) AS NVBVio_ind,
       MAX(CASE WHEN C.Rechtsvorm_oms = 'Cooperatie'        THEN 1 ELSE 0 END) AS Cooperatie_ind,
       MAX(CASE WHEN C.Rechtsvorm_oms = 'Waarborgmaatschap' THEN 1 ELSE 0 END) AS Waarborgmaatschap_ind,
       MAX(CASE WHEN C.Rechtsvorm_oms = 'Vereniging'        THEN 1 ELSE 0 END) AS Vereniging_ind,
       MAX(CASE WHEN C.Rechtsvorm_oms = 'Stichting'         THEN 1 ELSE 0 END) AS Stichting_ind,
       MAX(CASE WHEN C.Rechtsvorm_oms = 'Kerkgenootschap'   THEN 1 ELSE 0 END) AS Kerkgenootschap_ind,
       MAX(CASE WHEN C.Rechtsvorm_oms = 'Buitenland'        THEN 1 ELSE 0 END) AS Buitenland_ind,
       MAX(CASE WHEN C.Rechtsvorm_oms = 'Anders'            THEN 1 ELSE 0 END) AS Anders_ind,
       MAX(CASE WHEN C.Rechtsvorm_oms = 'Onbekend'          THEN 1 ELSE 0 END) AS Onbekend_ind
  FROM Mi_temp.Mia_week A
  LEFT OUTER JOIN Mi_sas_aa_mb_c_mb.Mia_businesscontacts_NEW B
    ON A.Klant_nr = B.Klant_nr
  LEFT OUTER JOIN Mi_sas_aa_mb_c_mb.Bedrijfstype_rechtsvorm C
    ON B.Bc_verschijningsvorm = C.Verschijningsvorm
  LEFT OUTER JOIN Mi_temp.Mia_businesscontacts_KvK X
    ON B.Business_contact_nr = X.Business_contact_nr
-- Alleen zakelijke klanten met geldige KvK inschrijving
 WHERE X.Geldige_KvK_inschrijving = 1
 GROUP BY 1, 2;

.IF ERRORCODE <> 0 THEN .GOTO EOP

-------------------------------------------
-- Mi_temp.Bedrijfstype_BC_hulp
-------------------------------------------

CREATE TABLE Mi_temp.Bedrijfstype_BC_hulp
      (
       Klant_nr INTEGER,
       Maand_nr INTEGER,
       Bc_KvK_nr CHAR(12) CHARACTER SET LATIN NOT CASESPECIFIC,
       Geldige_KvK_inschrijving BYTEINT,
       KvK_nr CHAR(12) CHARACTER SET LATIN NOT CASESPECIFIC,
       N_werkzame_personen_tot INTEGER,
       N_werkzame_personen_full INTEGER,
       Economisch_actief BYTEINT,
       KvK_Onderneming_ind BYTEINT,
       KvK_Vereniging_ind BYTEINT,
       KvK_Stichting_ind BYTEINT,
       KvK_Kerkgenoot_ind BYTEINT,
       KvK_rechtsvorm CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC
      )
UNIQUE PRIMARY INDEX ( Klant_nr, Maand_nr, Bc_KvK_nr );

.IF ERRORCODE <> 0 THEN .GOTO EOP

INSERT INTO Mi_temp.Bedrijfstype_BC_hulp
SELECT A.Klant_nr,
       A.Maand_nr,
       A.Bc_kvk_nr,
       A.Geldige_KvK_inschrijving,
       A.KvK_nr,
       A.N_werkzame_personen_tot,
       A.N_werkzame_personen_full,
       A.Economisch_actief,
       A.KvK_Onderneming_ind,
       A.KvK_Vereniging_ind,
       A.KvK_Stichting_ind,
       A.KvK_Kerkgenoot_ind,
       A.KvK_rechtsvorm
  FROM Mi_temp.Mia_businesscontacts_KvK A
 WHERE Geldige_KvK_inschrijving = 1;

.IF ERRORCODE <> 0 THEN .GOTO EOP

-------------------------------------------
-- Mi_temp.Bedrijfstype_hulp
-------------------------------------------

CREATE TABLE Mi_temp.Bedrijfstype_hulp
      (
       Klant_nr INTEGER,
       Maand_nr INTEGER,
       Geldige_KvK_inschrijving BYTEINT,
       N_geldige_KvK_inschrijvingen INTEGER,
       N_werkzame_personen_tot INTEGER,
       N_werkzame_personen_full INTEGER,
       Economisch_actief BYTEINT,
       KvK_Onderneming_ind BYTEINT,
       KvK_Vereniging_ind BYTEINT,
       KvK_Stichting_ind BYTEINT,
       KvK_Kerkgenoot_ind BYTEINT,
       Min_KvK_rechtsvorm CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC,
       Max_KvK_rechtsvorm CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC
      )
UNIQUE PRIMARY INDEX ( Klant_nr, Maand_nr );

.IF ERRORCODE <> 0 THEN .GOTO EOP

INSERT INTO Mi_temp.Bedrijfstype_hulp
SELECT A.Klant_nr,
       A.Maand_nr,
       MAX(ZEROIFNULL(B.Geldige_KvK_inschrijving)) AS Geldige_KvK_inschrijving_ind,
       SUM(ZEROIFNULL(B.Geldige_KvK_inschrijving)) AS N_geldige_KvK_inschrijvingen,
       SUM(B.N_werkzame_personen_tot) AS N_werkzame_personen_tot,
       SUM(B.N_werkzame_personen_full) AS N_werkzame_personen_full,
       MAX(ZEROIFNULL(B.Economisch_actief)) AS Economisch_actief,
       MAX(ZEROIFNULL(B.KvK_Onderneming_ind)) AS KvK_Onderneming_ind,
       MAX(ZEROIFNULL(B.KvK_Vereniging_ind)) AS KvK_Vereniging_ind,
       MAX(ZEROIFNULL(B.KvK_Stichting_ind)) AS KvK_Stichting_ind,
       MAX(ZEROIFNULL(B.KvK_Kerkgenoot_ind)) AS KvK_Kerkgenoot_ind,
       MIN(B.KvK_rechtsvorm),
       MAX(B.KvK_rechtsvorm)
  FROM Mi_temp.Mia_week A
  LEFT OUTER JOIN Mi_temp.Bedrijfstype_BC_hulp B
    ON A.Klant_nr = B.Klant_nr
 GROUP BY 1, 2;

.IF ERRORCODE <> 0 THEN .GOTO EOP

-------------------------------------------
-- Mi_temp.Bedrijfstype_basis_002
-------------------------------------------

CREATE TABLE Mi_temp.Bedrijfstype_basis_002
      (
       Klant_nr INTEGER,
       Maand_nr INTEGER,
       Aantal_rechtsvormen INTEGER,
       Rechtsvorm_oms_MIN VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC,
       Rechtsvorm_oms_MAX VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC,
       Eenmanszaak_ind BYTEINT,
       Maatschap_ind BYTEINT,
       VOF_ind BYTEINT,
       CV_ind BYTEINT,
       BV_ind BYTEINT,
       NV_ind BYTEINT,
       NVBVio_ind BYTEINT,
       Cooperatie_ind BYTEINT,
       Waarborgmaatschap_ind BYTEINT,
       Vereniging_ind BYTEINT,
       Stichting_ind BYTEINT,
       Kerkgenootschap_ind BYTEINT,
       Buitenland_ind BYTEINT,
       Anders_ind BYTEINT,
       Onbekend_ind BYTEINT,

       Geldige_KvK_inschrijving BYTEINT,
       N_geldige_KvK_inschrijvingen INTEGER,
       N_werkzame_personen_tot INTEGER,
       KvK_klasse_werknemers VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
       N_werkzame_personen_full INTEGER,
       Economisch_actief BYTEINT,
       KvK_Onderneming_ind BYTEINT,
       KvK_Vereniging_ind BYTEINT,
       KvK_Stichting_ind BYTEINT,
       KvK_Kerkgenoot_ind BYTEINT,
       Min_KvK_rechtsvorm CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC,
       Max_KvK_rechtsvorm CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC,
       Levensfase VARCHAR(16) CHARACTER SET LATIN NOT CASESPECIFIC,
       Omzet_inkomend DECIMAL(18,0),
       Aantal_verschillende_rollen INTEGER,
       Aantal_personen INTEGER,
       Rol_oms_MIN VARCHAR(29) CHARACTER SET UNICODE NOT CASESPECIFIC
      )
UNIQUE PRIMARY INDEX( Klant_nr, Maand_nr );

.IF ERRORCODE <> 0 THEN .GOTO EOP

INSERT INTO Mi_temp.Bedrijfstype_basis_002
SELECT A.Klant_nr,
       A.Maand_nr,
       ZEROIFNULL(B.Aantal_rechtsvormen),
       B.Rechtsvorm_oms_MIN,
       B.Rechtsvorm_oms_MAX,
       ZEROIFNULL(B.Eenmanszaak_ind),
       ZEROIFNULL(B.Maatschap_ind),
       ZEROIFNULL(B.VOF_ind),
       ZEROIFNULL(B.CV_ind),
       ZEROIFNULL(B.BV_ind),
       ZEROIFNULL(B.NV_ind),
       ZEROIFNULL(B.NVBVio_ind),
       ZEROIFNULL(B.Cooperatie_ind),
       ZEROIFNULL(B.Waarborgmaatschap_ind),
       ZEROIFNULL(B.Vereniging_ind),
       ZEROIFNULL(B.Stichting_ind),
       ZEROIFNULL(B.Kerkgenootschap_ind),
       ZEROIFNULL(B.Buitenland_ind),
       ZEROIFNULL(B.Anders_ind),
       ZEROIFNULL(B.Onbekend_ind),

       C.Geldige_KvK_inschrijving,
       C.N_geldige_KvK_inschrijvingen,
       C.N_werkzame_personen_tot,
       CASE
       WHEN D.N_werknemers_klasse_oms IS NULL THEN 'Onbekend'
       ELSE D.N_werknemers_klasse_oms
       END AS KvK_klasse_werknemers,
       C.N_werkzame_personen_full,
       C.Economisch_actief,
       C.KvK_Onderneming_ind,
       C.KvK_Vereniging_ind,
       C.KvK_Stichting_ind,
       C.KvK_Kerkgenoot_ind,
       C.Min_KvK_rechtsvorm,
       C.Max_KvK_rechtsvorm,
       CASE
       WHEN A.Aantal_jaren_bestaan < 3             THEN 'Startup'
       WHEN A.Aantal_jaren_bestaan BETWEEN 3 AND 4 THEN 'Jong bedrijf'
       WHEN A.Aantal_jaren_bestaan >= 5            THEN 'Bestaand bedrijf'
       ELSE NULL
       END AS Levensfase,
       A.Omzet_inkomend,
       E.Aantal_verschillende_rollen,
       E.Aantal_personen,
       E.Rol_oms_MIN

  FROM Mi_temp.Mia_week A
  LEFT OUTER JOIN Mi_temp.Bedrijfstype_basis_001 B
    ON A.Klant_nr = B.Klant_nr AND A.Maand_nr = B.Maand_nr
  LEFT OUTER JOIN Mi_temp.Bedrijfstype_hulp C
    ON A.Klant_nr = C.Klant_nr AND A.Maand_nr = C.Maand_nr
	LEFT OUTER JOIN Mi_vm_nzdb.vN_werknemers_klasse D
    ON C.Maand_nr = D.Maand_nr
   AND C.N_werkzame_personen_tot BETWEEN D.N_werknemers_klasse_min AND D.N_werknemers_klasse_max
  LEFT OUTER JOIN Mi_temp.Mia_personen_samenvatting E
    ON A.Klant_nr = E.Klant_nr AND A.Maand_nr = E.Maand_nr;

.IF ERRORCODE <> 0 THEN .GOTO EOP

-------------------------------------------
-- Mi_temp.Bedrijfstype_basis_003
-------------------------------------------

CREATE TABLE Mi_temp.Bedrijfstype_basis_003
      (
       Klant_nr INTEGER,
       Maand_nr INTEGER,
       Aantal_rechtsvormen INTEGER,
       Rechtsvorm_oms_MIN VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC,
       Rechtsvorm_oms_MAX VARCHAR(255) CHARACTER SET LATIN NOT CASESPECIFIC,
       Eenmanszaak_ind BYTEINT,
       Maatschap_ind BYTEINT,
       VOF_ind BYTEINT,
       CV_ind BYTEINT,
       BV_ind BYTEINT,
       NV_ind BYTEINT,
       NVBVio_ind BYTEINT,
       Cooperatie_ind BYTEINT,
       Waarborgmaatschap_ind BYTEINT,
       Vereniging_ind BYTEINT,
       Stichting_ind BYTEINT,
       Kerkgenootschap_ind BYTEINT,
       Buitenland_ind BYTEINT,
       Anders_ind BYTEINT,
       Onbekend_ind BYTEINT,
       Geldige_KvK_inschrijving BYTEINT,
       N_geldige_KvK_inschrijvingen INTEGER,
       N_werkzame_personen_tot INTEGER,
       KvK_klasse_werknemers VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
       N_werkzame_personen_full INTEGER,
       Economisch_actief BYTEINT,
       KvK_Onderneming_ind BYTEINT,
       KvK_Vereniging_ind BYTEINT,
       KvK_Stichting_ind BYTEINT,
       KvK_Kerkgenoot_ind BYTEINT,
       Min_KvK_rechtsvorm CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC,
       Max_KvK_rechtsvorm CHAR(2) CHARACTER SET LATIN NOT CASESPECIFIC,
       Levensfase VARCHAR(16) CHARACTER SET LATIN NOT CASESPECIFIC,
       Omzet_inkomend DECIMAL(18,0),
       Aantal_verschillende_rollen INTEGER,
       Aantal_personen INTEGER,
       Rol_oms_MIN VARCHAR(29) CHARACTER SET UNICODE NOT CASESPECIFIC,

       Bedrijfstype_detail VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
       Bedrijfstype VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC
      )
UNIQUE PRIMARY INDEX( Klant_nr, Maand_nr );

.IF ERRORCODE <> 0 THEN .GOTO EOP

INSERT INTO Mi_temp.Bedrijfstype_basis_003
SELECT A.*,
       CASE
       WHEN A.Aantal_rechtsvormen = 0 THEN 'Niet te bepalen'
       WHEN A.Aantal_verschillende_rollen = 0 THEN 'Niet te bepalen'
       WHEN A.Aantal_personen = 0 THEN 'Niet te bepalen'
       WHEN A.N_werkzame_personen_tot IS NULL THEN 'Niet te bepalen'

       WHEN A.Aantal_rechtsvormen > 1 THEN 'Complex'
       WHEN A.Rechtsvorm_oms_MIN IN ('Anders', 'Onbekend') THEN 'Overig'
       WHEN A.Rechtsvorm_oms_MIN IN ('NV', 'NV of BV io', 'Cooperatie', 'Waarborgmaatschap', 'Vereniging', 'Stichting', 'Kerkgenootschap', 'Buitenland') THEN A.Rechtsvorm_oms_MIN

       WHEN A.Rechtsvorm_oms_MIN IN ('Eenmanszaak') AND A.Aantal_verschillende_rollen = 1 AND A.Aantal_personen = 1  AND A.Rol_oms_MIN = 'Eigenaar'      AND A.Aantal_personen >= A.N_werkzame_personen_tot THEN 'ZZP-EZ'
       WHEN A.Rechtsvorm_oms_MIN IN ('Eenmanszaak') AND A.Aantal_verschillende_rollen = 1 AND A.Aantal_personen = 1  AND A.Rol_oms_MIN = 'Eigenaar'      AND A.Aantal_personen < A.N_werkzame_personen_tot  THEN 'ZMP-EZ'
       WHEN A.Rechtsvorm_oms_MIN IN ('Maatschap')   AND A.Aantal_verschillende_rollen = 1 AND A.Aantal_personen >= 1 AND A.Rol_oms_MIN = 'Maat'          AND A.Aantal_personen >= A.N_werkzame_personen_tot THEN 'ZZP-MTS'
       WHEN A.Rechtsvorm_oms_MIN IN ('Maatschap')   AND A.Aantal_verschillende_rollen = 1 AND A.Aantal_personen >= 1 AND A.Rol_oms_MIN = 'Maat'          AND A.Aantal_personen < A.N_werkzame_personen_tot  THEN 'ZMP-MTS'
       WHEN A.Rechtsvorm_oms_MIN IN ('VOF')         AND A.Aantal_verschillende_rollen = 1 AND A.Aantal_personen >= 1 AND A.Rol_oms_MIN = 'Vennoot (VOF)' AND A.Aantal_personen >= A.N_werkzame_personen_tot THEN 'ZZP-VOF'
       WHEN A.Rechtsvorm_oms_MIN IN ('VOF')         AND A.Aantal_verschillende_rollen = 1 AND A.Aantal_personen >= 1 AND A.Rol_oms_MIN = 'Vennoot (VOF)' AND A.Aantal_personen < A.N_werkzame_personen_tot  THEN 'ZMP-VOF'
       WHEN A.Rechtsvorm_oms_MIN IN ('CV')          AND A.Aantal_verschillende_rollen = 1 AND A.Aantal_personen >= 1 AND A.Rol_oms_MIN = 'Vennoot (CV)'  AND A.Aantal_personen >= A.N_werkzame_personen_tot THEN 'ZZP-CV'
       WHEN A.Rechtsvorm_oms_MIN IN ('CV')          AND A.Aantal_verschillende_rollen = 1 AND A.Aantal_personen >= 1 AND A.Rol_oms_MIN = 'Vennoot (CV)'  AND A.Aantal_personen < A.N_werkzame_personen_tot  THEN 'ZMP-CV'
       WHEN A.Rechtsvorm_oms_MIN IN ('Eenmanszaak', 'Maatschap', 'VOF', 'CV') THEN A.Rechtsvorm_oms_MIN

       WHEN A.Rechtsvorm_oms_MIN IN ('BV') AND A.Aantal_verschillende_rollen >= 1 AND A.Aantal_personen = 1 AND A.Rol_oms_MIN = 'Uiteindelijk belanghebbende' AND A.N_werkzame_personen_tot = 1 AND A.Omzet_inkomend < 150000 THEN 'ZZP-BV*'
       WHEN A.Rechtsvorm_oms_MIN IN ('BV') AND A.Aantal_verschillende_rollen >= 1 AND A.Aantal_personen = 1 AND A.Rol_oms_MIN = 'Bestuurder'                  AND A.N_werkzame_personen_tot = 1 AND A.Omzet_inkomend < 150000 THEN 'ZZP-BV*'
       WHEN A.Rechtsvorm_oms_MIN IN ('BV') AND A.Aantal_verschillende_rollen >= 1 AND A.Aantal_personen = 1 AND A.Rol_oms_MIN = 'Uiteindelijk belanghebbende' AND A.N_werkzame_personen_tot > 1 AND A.Omzet_inkomend < 150000 THEN 'ZMP-BV*'
       WHEN A.Rechtsvorm_oms_MIN IN ('BV') AND A.Aantal_verschillende_rollen >= 1 AND A.Aantal_personen = 1 AND A.Rol_oms_MIN = 'Bestuurder'                  AND A.N_werkzame_personen_tot > 1 AND A.Omzet_inkomend < 150000 THEN 'ZMP-BV*'
       WHEN A.Rechtsvorm_oms_MIN IN ('BV') AND A.Aantal_verschillende_rollen >= 1 AND A.Aantal_personen = 1 AND A.Rol_oms_MIN = 'Uiteindelijk belanghebbende' AND A.N_werkzame_personen_tot = 0                               THEN 'BV0'
       WHEN A.Rechtsvorm_oms_MIN IN ('BV') AND A.Aantal_verschillende_rollen >= 1 AND A.Aantal_personen = 1 AND A.Rol_oms_MIN = 'Bestuurder'                  AND A.N_werkzame_personen_tot = 0                               THEN 'BV0'

       WHEN A.Rechtsvorm_oms_MIN IN ('BV') AND A.N_werkzame_personen_tot = 0 THEN 'BV0'
       WHEN A.Rechtsvorm_oms_MIN IN ('BV') THEN A.Rechtsvorm_oms_MIN
       ELSE 'Ntb'
       END AS Bedrijfstype_detail,
       CASE
       WHEN Bedrijfstype_detail = 'Complex' THEN 'Overig'
       WHEN SUBSTR(Bedrijfstype_detail, 1, 3) = 'ZZP' THEN 'ZZP'
       WHEN SUBSTR(Bedrijfstype_detail, 1, 3) = 'ZMP' THEN 'ZMP'
       WHEN SUBSTR(Bedrijfstype_detail, 1, 2) = 'BV' THEN 'BV'
       ELSE Bedrijfstype_detail
       END AS Bedrijfstype

  FROM Mi_temp.Bedrijfstype_basis_002 A;

.IF ERRORCODE <> 0 THEN .GOTO EOP

-------------------------------------------
-- Mi_temp.Mia_bedrijfstype
-------------------------------------------

CREATE TABLE Mi_temp.Mia_bedrijfstype
      (
       Klant_nr INTEGER,
       Maand_nr INTEGER,
       Geldige_KvK_inschrijving BYTEINT,
       N_geldige_KvK_inschrijvingen INTEGER,
       N_werkzame_personen_tot INTEGER,
       KvK_klasse_werknemers VARCHAR(20) CHARACTER SET LATIN NOT CASESPECIFIC,
       N_werkzame_personen_full INTEGER,
       Economisch_actief BYTEINT,
       Levensfase VARCHAR(16) CHARACTER SET LATIN NOT CASESPECIFIC,
       Bedrijfstype_detail VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC,
       Bedrijfstype VARCHAR(50) CHARACTER SET LATIN NOT CASESPECIFIC
      )
UNIQUE PRIMARY INDEX( Klant_nr, Maand_nr );

.IF ERRORCODE <> 0 THEN .GOTO EOP

INSERT INTO Mi_temp.Mia_bedrijfstype
SELECT A.Klant_nr,
       A.Maand_nr,
       A.Geldige_KvK_inschrijving,
       A.N_geldige_KvK_inschrijvingen,
       A.N_werkzame_personen_tot,
       A.KvK_klasse_werknemers,
       A.N_werkzame_personen_full,
       A.Economisch_actief,
       A.Levensfase,
       A.Bedrijfstype_detail,
       A.Bedrijfstype
  FROM Mi_temp.Bedrijfstype_basis_003 A;

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* kopie */
CREATE TABLE Mi_sas_aa_mb_c_mb.Mia_bedrijfstype_hist_NEW AS Mi_sas_aa_mb_c_mb.Mia_bedrijfstype_hist WITH DATA
UNIQUE PRIMARY INDEX( Klant_nr, Maand_nr );

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_sas_aa_mb_c_mb.Mia_bedrijfstype_hist_NEW COLUMN (PARTITION);

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* WEEKCIJFERS VERWIJDEREN INDIEN MAAND REEDS AANWEZIG VAN VORIGE WEEK */
DELETE FROM Mi_sas_aa_mb_c_mb.Mia_bedrijfstype_hist_NEW A
 WHERE A.Maand_nr = (SELECT X.Maand_nr FROM Mi_temp.Mia_bedrijfstype X GROUP BY 1);

.IF ERRORCODE <> 0 THEN .GOTO EOP

COLLECT STATISTICS Mi_sas_aa_mb_c_mb.Mia_bedrijfstype_hist_NEW COLUMN (PARTITION);

.IF ERRORCODE <> 0 THEN .GOTO EOP

/* WEEKCIJFERS TOEVOEGEN */

INSERT INTO Mi_sas_aa_mb_c_mb.Mia_bedrijfstype_hist_NEW
SELECT A.*
  FROM Mi_temp.Mia_bedrijfstype A;

.IF ERRORCODE <> 0 THEN .GOTO EOP

COMMENT ON Mi_sas_aa_mb_c_mb.Mia_bedrijfstype_hist_NEW AS 'NIET VERWIJDEREN - Afdelingstabel in schedulescript';

.IF ERRORCODE <> 0 THEN .GOTO EOP



/*Blockcompressie uit*/
SET QUERY_BAND = 'BLOCKCOMPRESSION=NO;' FOR SESSION;
