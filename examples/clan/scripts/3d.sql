#DATASPOT-TERADATA

replace view MI_VM_SAS_AA_MB_C_MB.vVerloop_trx_en_kred_gebruik as
		select * from MI_SAS_AA_MB_C_MB.verloop_trx_en_kred_gebruik;

replace view Mi_cmb.vVerloop_trx_en_kred_gebruik as
		select * from MI_VM_SAS_AA_MB_C_MB.vVerloop_trx_en_kred_gebruik;