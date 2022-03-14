-------------------------------------------------------------------------------------------------------------
--
-- File Name: sfkscre_faload_grants.sql
-- Author:    Kyle Hunt <kylehunt@hawaii.edu>
-- Created:   06-May-20
-- Updated:   06-May-20
-- Version:   1.0
--
-- Purpose:   Grants execute on the SFKSCRE package to all FA Load accounts.
--
--
-- Notes:     1.  None.
--
-- Audit Log 1.0:
--
--    1. Initial release of this script.                                                        KAH 06-May-20
--
-- Audit Log 1.0 End
-------------------------------------------------------------------------------------------------------------
PROMPT 
PROMPT Granting EXECUTE on SFKSCRE to all XXX_FALOAD accounts...
PROMPT 
GRANT EXECUTE ON baninst1.sfkscre TO HAW_FALOAD;
GRANT EXECUTE ON baninst1.sfkscre TO HIL_FALOAD;
GRANT EXECUTE ON baninst1.sfkscre TO HON_FALOAD;
GRANT EXECUTE ON baninst1.sfkscre TO KAP_FALOAD;
GRANT EXECUTE ON baninst1.sfkscre TO KAU_FALOAD;
GRANT EXECUTE ON baninst1.sfkscre TO LEE_FALOAD;
GRANT EXECUTE ON baninst1.sfkscre TO MAN_FALOAD;
GRANT EXECUTE ON baninst1.sfkscre TO MAU_FALOAD;
GRANT EXECUTE ON baninst1.sfkscre TO WIN_FALOAD;
GRANT EXECUTE ON baninst1.sfkscre TO WOA_FALOAD;
--
PROMPT 
PROMPT Done with grants
PROMPT
