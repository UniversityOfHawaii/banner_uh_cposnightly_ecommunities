/*

===================================================================================================
                               University of Hawai'i Audit Trail
===================================================================================================

    Kyle Hunt (kylehunt@hawaii.edu)                                                     10-JUL-2019
    AUDIT TRAIL: UH:8.15:1
    JIRA BAN-1377 - Course Program of Study
         BAN-2215 - Process to populate population selections    
         BAN-2216 - Script to check override box on SFASCRE

    1.  Initial mods done to package.
    2.  Added procedures p_load_popsels and p_preserve_overrides.
    3.  Added procedure p_clear_popsels.                                                22-APR-2020
    4.  Added check to maximum amount of popsels to create for each college.            24-APR-2020
    5.  Updated p_load_popsels() SQL population logic to use home campus logic. Will take all terms
        entered on SFACPSC and do a unique unduplicated list of students from all terms.
    6.  Added procedure f_exclude_prog.                                                 06-MAY-2020
    7.  Modified cursor get_batch_c to only process students that were home campus      07-MAY-2020
        based on the home home campus the job user is.

===================================================================================================
               
--  AUDIT TRAIL END
-*/
--
-- NOTE: Omitted much of Ellucian code, only adding procedure/function bodies and modified code.
--
--

CREATE OR REPLACE PACKAGE BODY sfkscre
AS
   --AUDIT_TRAIL_MSGKEY_UPDATE
-- PROJECT : MSGKEY
-- MODULE  : SFKSCRE1
-- SOURCE  : enUS
-- TARGET  : I18N
-- DATE    : Thu Feb 01 03:47:48 2018
-- MSGSIGN : #dea158c142dc72f3
--TMI18N.ETR DO NOT CHANGE--
   --
   -- FILE NAME..: sfkscre1.sql
   -- RELEASE....: UH:8.15:1 -- 8.15
   -- OBJECT NAME: sfkscre
   -- PRODUCT....: STUDENT
   -- USAGE......: Package to facilitate Student Course Evaluation Audit process.
   -- COPYRIGHT..: Copyright 2018. Ellucian Company L.P. and its affiliates.*
   --
   -- Contains confidential and proprietary information of Ellucian and its subsidiaries.
   -- Use of these materials is limited to Ellucian licensees, and is
   -- subject to the terms and conditions of one or more written license agreements
   -- between Ellucian and the licensee in question.

-- BA UH:8.15:1 - UH Variables
--   TYPE t_inserts_aat IS TABLE OF glbextr%ROWTYPE INDEX BY BINARY_INTEGER;
   --datainserts sfkscre.t_inserts_aat;

   C_LOGGING_ENABLED         CONSTANT BOOLEAN      := TRUE;
   --C_LOGGING_ENABLED         CONSTANT BOOLEAN      := TRUE;
    
   C_LOGGING_METHOD          CONSTANT VARCHAR2(10) := 'DBMS';
   --C_LOGGING_METHOD          CONSTANT VARCHAR2(10) := 'PDEBUG';
   
   FUNCTION f_exclude_prog( p_pidm_in IN sgbstdn.sgbstdn_pidm%TYPE,
                            p_term_in IN sgbstdn.sgbstdn_term_code_eff%TYPE)
   RETURN BOOLEAN;
   
-- EA UH:8.15:1

   --
   --
   --Function to capture the Student Registration, Curricula, Academic History changes
   -- And populate the SFRSCRE table
   --
   FUNCTION f_populate_audit (
      p_run_mode            IN     VARCHAR2,
      p_jobsub_no           IN     sfrscre.sfrscre_jobsub_no%TYPE,
      p_application         IN     glbextr.glbextr_application%TYPE DEFAULT NULL,
      p_selection           IN     glbextr.glbextr_selection%TYPE DEFAULT NULL,
      p_creator_id          IN     glbextr.glbextr_creator_id%TYPE DEFAULT NULL,
      p_user_id             IN     glbextr.glbextr_user_id%TYPE DEFAULT NULL,
      p_student_id          IN     spriden.spriden_id%TYPE DEFAULT NULL,
      p_in_program_ind      IN     sfbcpsc.sfbcpsc_in_program_ind%TYPE,
      p_esl_ind             IN     sfbcpsc.sfbcpsc_esl_ind%TYPE,
      p_remedial_ind        IN     sfbcpsc.sfbcpsc_remedial_ind%TYPE,
      p_repeat_ind          IN     sfbcpsc.sfbcpsc_repeat_ind%TYPE,
      p_in_prog_dflt_cde    IN     sfbcpsc.sfbcpsc_in_prog_dflt_cde%TYPE,
      p_terms_rules         IN     S_TERMS_RULE_NT,
      p_in_prog_ovr_rules   IN     S_IN_PROGRAM_OVR_RULE_NT,
      p_in_aid_rule_ind     IN     sfbcpsc.sfbcpsc_aid_ind%TYPE,
	   p_on_demand_evaluation IN    VARCHAR2 DEFAULT 'N', 
      p_runseq_out          OUT sfrscre.sfrscre_runseq_no%TYPE,
      p_errmsg_out          OUT VARCHAR2,
      p_record_count_out    OUT NUMBER)
      RETURN VARCHAR2
   IS
--
-- <<<<<<<<<<<<<<<<SNIPPED>>>>>>>>>>>>
--
     -- Get the list of students for processing if run mode is Batch
      CURSOR get_batch_c (
         p_term_code   stvterm.stvterm_code%TYPE) IS
         SELECT sfbetrm_pidm stud_pidm
-- BA UH:8.15:1 - Add in home campus logic, that way it will NOT process all students in the
--           non-VPDed table SFBETRM.
--         FROM sfbetrm
           FROM sfbetrm JOIN ( SELECT d.sgbstdn_pidm, d.sgbstdn_vpdi_code
                               FROM   sgbstdn d
                               WHERE  d.sgbstdn_term_code_eff = ( SELECT MAX(g.sgbstdn_term_code_eff)
                                                                  FROM   sgbstdn g
                                                                  WHERE  g.sgbstdn_pidm = d.sgbstdn_pidm
                                                                  AND    g.sgbstdn_term_code_eff <= p_term_code
                                                                 )
                               AND    d.sgbstdn_vpdi_code = g$_vpdi_security.g$_vpdi_get_inst_code_fnc
                              )
               ON sfbetrm_pidm = sgbstdn_pidm
-- EA UH:8.15:1
          WHERE sfbetrm_term_code = p_term_code;

--
-- <<<<<<<<<<<<<<<<SNIPPED>>>>>>>>>>>>
--

      lv_create_date sfrscre.sfrscre_create_date%TYPE:= '';
      lv_exists      VARCHAR2(1) := 'N';
      BEGIN
-- BA UH:8.15:1
      IF ( f_exclude_prog(p_pidm,p_term_code) ) THEN
         RETURN;
      END IF;
-- EA UH:8.15:1
  
--
-- <<<<<<<<<<<<<<<<SNIPPED>>>>>>>>>>>>
--
-- Following goes at END of the package to avoid Ellucian code changes.

-- BA UH:8.15:1
-- ================================================================================================
-- ==                                                                                            ==
-- ==                                       UH Procedures                                       ==
-- ==                                                                                            ==
-- ================================================================================================
   --
   -- Switch between logging systems.
   --
   PROCEDURE WL
     ( msg_in VARCHAR2 )
   IS

   BEGIN
     IF ( C_LOGGING_ENABLED ) THEN
       IF ( C_LOGGING_METHOD = 'DBMS' ) THEN
         dbms_output.put_line( SUBSTR( msg_in,1,4000) );
       END IF;

       IF ( C_LOGGING_METHOD = 'PDEBUG' ) THEN
         p_ban_debug(msg_in);
       END IF;
     END IF;
   END WL;

   --
   -- Validate the popselection exists.
   -- Returns false if any errors occurs.
   --
   FUNCTION f_popsel_exists
     ( app_in       VARCHAR2,
       selection_in VARCHAR2,
       creator_in   VARCHAR2 )
   RETURN BOOLEAN
   IS
     retval BOOLEAN := false;
     cnt    NUMBER  := 0;

     CURSOR findPopselC
     IS ( SELECT NVL(COUNT(*),0)
           FROM  glbslct x
           WHERE x.glbslct_application = app_in
           AND   x.glbslct_selection   = selection_in
           AND   x.glbslct_creator_id  = creator_in );

   BEGIN
     OPEN  findPopselC;
     FETCH findPopselC  INTO  cnt;
     CLOSE findPopselC;
     IF ( cnt = 1 ) THEN
       retval := TRUE;
     ELSE
       retval := FALSE;
     END IF;
     RETURN retval;
   EXCEPTION
     WHEN OTHERS THEN
       WL('ERROR: F_POPSEL_EXISTS - ' || SQLERRM);
       RETURN FALSE;
   END f_popsel_exists;

   --
   -- Validate VPDI code. Returns false if any errors occurs.
   --
   FUNCTION f_valid_vpdi
     ( vpdi_in IN gtvvpdi.gtvvpdi_code%TYPE )
   RETURN BOOLEAN
   IS
     retval BOOLEAN := FALSE;
     cnt    NUMBER  := 0;

   BEGIN
     SELECT COUNT(*)
      INTO  cnt
      FROM  gtvvpdi
      WHERE gtvvpdi_code = vpdi_in;
     IF ( cnt = 1 ) THEN
       retval := TRUE;
     END IF;
     RETURN retval;
   EXCEPTION
     WHEN OTHERS THEN
       RETURN FALSE;
   END f_valid_vpdi;

   --
   -- Validate TERM code. Returns false if any errors occurs.
   --
   FUNCTION f_valid_term
     ( term_in IN stvterm.stvterm_code%TYPE )
   RETURN BOOLEAN
   IS
     retval BOOLEAN := FALSE;
     cnt    NUMBER  := 0;

   BEGIN
     SELECT COUNT(*)
      INTO  cnt
      FROM  stvterm
      WHERE stvterm_code = term_in;
     IF ( cnt = 1 ) THEN
        retval := TRUE;
     END IF;
     RETURN retval;
   EXCEPTION
     WHEN OTHERS THEN
       RETURN FALSE;
   END f_valid_term;

   ----------------------------------------------------------------
   --
   -- Procedure to clear all student populations used to run in the
   -- Java process.
   --
   -- p_application      - Which application to house the
   --                      popselect under
   -- p_creator_id       - Which create to house the popselect under
   -- p_user_id          - Which user id to house the popselect under
   -- p_selection_prefix - Prefix of the name of popselect;
   --                      process appends college and batch number
   --                       to end of it.
   -- p_vpdi_code        - Which college to populate
   --
   PROCEDURE p_clear_popsels
     ( p_application        IN glbextr.glbextr_application%TYPE,
       p_selection_prefix   IN glbextr.glbextr_selection%TYPE,
       p_creator_id         IN glbextr.glbextr_creator_id%TYPE,
       p_user_id            IN glbextr.glbextr_user_id%TYPE,
       p_vpdi_code          IN glbextr.glbextr_vpdi_code%TYPE )
   IS

   BEGIN
     WL(' ');
     WL(' Clearing popsels...');
     WL(' ');

     DELETE FROM glbextr
      WHERE glbextr_application =  UPPER(p_application)
      AND   glbextr_creator_id  =  UPPER(p_creator_id)
      AND   glbextr_user_id     =  UPPER(p_user_id)
      AND   glbextr_selection LIKE p_selection_prefix ||'_'|| UPPER(p_vpdi_code) ||'%';

     WL(' ');
     WL('Removed '|| SQL%ROWCOUNT ||' previous records...');
     WL(' ');
     COMMIT;
   END p_clear_popsels;

   PROCEDURE p_load_popsels
     ( p_application        IN glbextr.glbextr_application%TYPE,
       p_selection_prefix   IN glbextr.glbextr_selection%TYPE,
       p_creator_id         IN glbextr.glbextr_creator_id%TYPE,
       p_user_id            IN glbextr.glbextr_user_id%TYPE,
       p_vpdi_code          IN glbextr.glbextr_vpdi_code%TYPE,
       p_batches            IN NUMBER )
   IS
     doProcessing     BOOLEAN                          := TRUE;
     lv_selection     glbextr.glbextr_selection%TYPE   := NULL;
     lv_cnt_total     NUMBER;

   BEGIN
     --
     -- Data validations
     --
     IF ( p_application IS NULL OR p_application = '' ) THEN
       WL(' ');
       WL(' ERROR: Paramater APPLICATION is NULL or not valid.');
       WL(' ');
       RETURN;
     END IF;

     IF ( p_selection_prefix IS NULL OR p_selection_prefix = '' ) THEN
       WL(' ');
       WL(' ERROR: Paramater SELECTION PREFIX is NULL or not valid.');
       WL(' ');
       RETURN;
     END IF;

     IF ( p_creator_id IS NULL OR p_creator_id = '' ) THEN
       WL(' ');
       WL(' ERROR: Paramater CREATOR is NULL or not valid.');
       WL(' ');
       RETURN;
     END IF;

     IF ( p_user_id IS NULL OR p_user_id = '' ) THEN
       WL(' ');
       WL(' ERROR: Paramater USER ID is NULL or not valid.');
       WL(' ');
       RETURN;
     END IF;

     IF ( p_vpdi_code IS NULL OR p_vpdi_code = '' ) THEN
       WL(' ');
       WL(' ERROR: Paramater VPDI CODE is NULL or not valid.');
       WL(' ');
       RETURN;
     END IF;

     IF ( f_valid_vpdi(p_vpdi_code) = FALSE ) THEN
       WL(' ');
       WL(' ERROR: Paramater VPDI CODE is not valid.');
       WL(' ');
       RETURN;
     END IF;

     IF ( p_batches <= 0 ) THEN
       WL(' ');
       WL(' ERROR: Parameter BATCHES is to small; needs to be greater or equal to 1.');
       WL(' ');
       RETURN;
     END IF;

     IF ( p_batches > sfkscre.UH_MAX_POPSEL_BATCHES ) THEN
       WL(' ');
       WL(' ERROR: Parameter BATCHES is to large; needs to be less than or equal to '|| sfkscre.UH_MAX_POPSEL_BATCHES ||' .');
       WL(' ');
       RETURN;
     END IF;

     --
     -- Empty out containers...
     --
     p_clear_popsels( p_application,
                      p_selection_prefix,
                      p_creator_id,
                      p_user_id,
                      p_vpdi_code );

     --
     -- Validate that all popselects are present and defined
     --
     FOR i IN 1 .. p_batches LOOP
       -- Generate the selection name
       lv_selection    := p_selection_prefix
                  ||'_'|| UPPER(p_vpdi_code)
                  ||'_'|| LPAD(i,2,'0');

       IF ( F_POPSEL_EXISTS(p_application, lv_selection, p_creator_id ) = FALSE ) THEN
         WL('  POPSELECT NOT DEFINED: '|| LPAD(i,4,' ')
                                ||' : '|| p_application
                                ||'.'  || lv_selection
                                ||'.'  || p_creator_id );
         doProcessing := FALSE;
       END IF;
     END LOOP;

     IF ( doProcessing ) THEN
/* -- NOTE: Previous way using an array table and using forall inserts
       WL(' ');
       WL('Gathering Students....' );
       WL(' ' );
       OPEN   getStudentsC;
       FETCH  getStudentsC BULK COLLECT INTO datainserts;
       CLOSE  getStudentsC;
       WL(' ');
       WL('Populating PopSelects....' );
       WL(' ' );
       FORALL i IN datainserts.first .. datainserts.last
         INSERT INTO glbextr VALUES datainserts(i);
*/ -- NOTE: Faster way to just use MOD to distribute amongst popsels.
       WL(' ');
       WL('Populating PopSelects....' );
       WL(' ' );
/* -- NOTE: original query based of CPOS batch logic
       INSERT INTO glbextr
            ( glbextr_application,
              glbextr_selection,
              glbextr_creator_id,
              glbextr_user_id,
              glbextr_key,
              glbextr_activity_date,
              glbextr_sys_ind,
              glbextr_slct_ind,
              glbextr_surrogate_id,
              glbextr_version,
              glbextr_data_origin,
              glbextr_vpdi_code )
       SELECT UPPER(p_application)      glbextr_application,
              p_selection_prefix
                ||'_'|| UPPER(p_vpdi_code)
                ||'_'|| LPAD(MOD(rownum,p_batches)+1,2,'0') glbextr_selection,
              UPPER(p_creator_id)       glbextr_creator_id,
              UPPER(p_user_id)          glbextr_user_id,
              sfbetrm_pidm              glbextr_key,
              SYSDATE                   glbextr_activity_date,
              'M'                       glbextr_sys_ind,
              NULL                      glbextr_slct_ind,
              NULL                      glbextr_surrogate_id,
              NULL                      glbextr_version,
              NULL                      glbextr_data_origin,
              NULL                      glbextr_vpdi_code
        FROM  sfbetrm
        WHERE sfbetrm_term_code = '201810';
*/ -- NOTE:  Modified to pull back home campus and goverend by SFACPSC
       INSERT INTO glbextr
            ( glbextr_application,
              glbextr_selection,
              glbextr_creator_id,
              glbextr_user_id,
              glbextr_key,
              glbextr_activity_date,
              glbextr_sys_ind,
              glbextr_slct_ind,
              glbextr_surrogate_id,
              glbextr_version,
              glbextr_data_origin,
              glbextr_vpdi_code)
       SELECT UPPER(p_application)      glbextr_application,
              p_selection_prefix
                ||'_'|| UPPER(p_vpdi_code)
                ||'_'|| LPAD(MOD(rownum,p_batches)+1,2,'0') glbextr_selection,
              UPPER(p_creator_id)       glbextr_creator_id,
              UPPER(p_user_id)          glbextr_user_id,
              sfbetrm_pidm              glbextr_key,
              SYSDATE                   glbextr_activity_date,
              'M'                       glbextr_sys_ind,
              NULL                      glbextr_slct_ind,
              NULL                      glbextr_surrogate_id,
              NULL                      glbextr_version,
              NULL                      glbextr_data_origin,
              NULL                      glbextr_vpdi_code
        FROM ( -- Remove duplicates from all terms
              SELECT sfbetrm_pidm
               FROM ( -- Get home campus for the SFBETRM
                     SELECT (SELECT d.sgbstdn_vpdi_code
                              FROM  sgbstdn d
                              WHERE d.sgbstdn_pidm      = e.sfbetrm_pidm
                              AND   d.sgbstdn_levl_code = 'UG'
                              AND   d.sgbstdn_term_code_eff = (
                                      SELECT MAX(g.sgbstdn_term_code_eff)
                                       FROM  sgbstdn g
                                       WHERE g.sgbstdn_pidm = d.sgbstdn_pidm
                                       AND   g.sgbstdn_term_code_eff <= e.sfbetrm_term_code )
                            )  home_camp,
                            e.sfbetrm_pidm
                      FROM  sfbetrm  e
                      -- Limit to what was entered on SFACPSC terms, ensure locked down to current campus
                      WHERE sfbetrm_term_code IN (
                              SELECT sfrcpst_term_code
                               FROM  sfrcpst
                               WHERE sfrcpst_vpdi_code = p_vpdi_code ) )
               -- Pull back ONLY the home campus SFBETRM records
               WHERE home_camp = p_vpdi_code
               GROUP BY
                     sfbetrm_pidm
             )
        -- Uncomment to limit to first X students.
        --WHERE rownum <= 20
        ;

       WL(' ');
       WL('Inserted '|| SQL%ROWCOUNT ||' records:');
/* -- NOTE: Previous way using an array table and using forall inserts
       FOR c1 IN (SELECT *
                   FROM (SELECT glbextr_selection,
                                COUNT(*) cnt
                          FROM  TABLE(datainserts)
                          GROUP BY
                                glbextr_selection )
                   ORDER BY
                         glbextr_selection )
       LOOP
         WL('  '|| c1.glbextr_selection ||' '|| c1.cnt );
       END LOOP;
*/
       lv_cnt_total := 0;
       FOR c1 IN (SELECT *
                   FROM (SELECT glbextr_selection,
                                COUNT(*) cnt
                          FROM  glbextr
                          WHERE glbextr_application = p_application
                          AND   glbextr_creator_id  = p_creator_id
                          AND   glbextr_user_id     = p_user_id
                          AND   glbextr_selection LIKE ( p_selection_prefix ||'_'|| UPPER(p_vpdi_code) ||'%' )
                          GROUP BY
                                glbextr_selection )
                   ORDER BY glbextr_selection )
       LOOP
         WL('  '|| c1.glbextr_selection ||' '|| c1.cnt );
         lv_cnt_total := lv_cnt_total + c1.cnt;
       END LOOP;
       WL('  TOTAL    : '|| lv_cnt_total );
       WL(' ');
       WL('Saving data...');
       COMMIT;
     ELSE
       WL(' ');
       WL('  ERORR: Required popselects do not exist');
       WL(' ');
     END IF;
   END p_load_popsels;

   ----------------------------------------------------------------
   --
   -- Function to determine if the student should be excluded from
   -- processing based on the rules on SFACPSC Excluded Programs
   -- tab.  Takes a student and term combination and determines if
   -- the effective SGASTDN record contains major, level, degree,
   -- college, or campus exclusion rules.
   --
   -- p_pidm_in - Pidm of student to search for
   -- p_term_in - Effective Term Code to limit results for
   --
   -- Return Value: BOOLEAN
   --   TRUE    - Student SGASTDN record matched any exclusion
   --             rules.  Mainly triggers for graduate level
   --             students.
   --   FALSE   - Student SGASTDN record didn't match any
   --             exclusion rules.  Mainly triggers for
   --             undergraduate level students.
   --
    FUNCTION f_exclude_prog
      ( p_pidm_in IN sgbstdn.sgbstdn_pidm%TYPE,
        p_term_in IN sgbstdn.sgbstdn_term_code_eff%TYPE )
    RETURN BOOLEAN
    IS
      lv_check VARCHAR2(1) := 'N';

      CURSOR validProg_c
      IS
        SELECT 'Y'
         FROM  sgbstdn d
         -- Get current SGBSTDN record for the term code
         WHERE d.sgbstdn_pidm          = p_pidm_in
         AND   d.sgbstdn_term_code_eff = (
                 SELECT MAX(g.sgbstdn_term_code_eff)
                  FROM  sgbstdn g
                  WHERE g.sgbstdn_pidm           = d.sgbstdn_pidm
                --AND   g.sgbstdn_vpdi_code      = d.sgbstdn_vpdi_code
                  AND   g.sgbstdn_term_code_eff <= p_term_in )
         -- Check that SGBSTDN records do not fall into the exclusion rules.
         AND   NOT EXISTS (
                 SELECT 'Y'
                  FROM  sfrprgx e
                  WHERE d.sgbstdn_term_code_eff >= e.sfrprgx_from_term_code
                  AND   d.sgbstdn_term_code_eff <= e.sfrprgx_to_term_code
                  AND (    (d.sgbstdn_levl_code     = e.sfrprgx_levl_code
                            AND e.sfrprgx_program   IS NULL
                            AND e.sfrprgx_camp_code IS NULL
                            AND e.sfrprgx_coll_code IS NULL
                            AND e.sfrprgx_degc_code IS NULL )
                        --
                        OR (d.sgbstdn_majr_code_1   = e.sfrprgx_program
                            AND d.sgbstdn_levl_code = e.sfrprgx_levl_code
                            AND e.sfrprgx_camp_code IS NULL
                            AND e.sfrprgx_coll_code IS NULL
                            AND e.sfrprgx_degc_code IS NULL )
                        --
                        OR (d.sgbstdn_majr_code_1   = e.sfrprgx_program
                            AND d.sgbstdn_levl_code = e.sfrprgx_levl_code
                            AND d.sgbstdn_camp_code = e.sfrprgx_camp_code
                            AND e.sfrprgx_coll_code IS NULL
                            AND e.sfrprgx_degc_code IS NULL )
                        --
                        OR (d.sgbstdn_majr_code_1     = e.sfrprgx_program
                            AND d.sgbstdn_levl_code   = e.sfrprgx_levl_code
                            AND d.sgbstdn_camp_code   = e.sfrprgx_camp_code
                            AND d.sgbstdn_coll_code_1 = e.sfrprgx_coll_code
                            AND e.sfrprgx_degc_code   IS NULL )
                        --
                        OR (d.sgbstdn_majr_code_1 = e.sfrprgx_program
                            AND d.sgbstdn_levl_code   = e.sfrprgx_levl_code
                            AND d.sgbstdn_camp_code   = e.sfrprgx_camp_code
                            AND d.sgbstdn_coll_code_1 = e.sfrprgx_coll_code
                            AND d.sgbstdn_degc_code_1 = e.sfrprgx_degc_code ) ) );

   BEGIN
     OPEN  validProg_c;
     FETCH validProg_c INTO lv_check;
     CLOSE validProg_c;

     IF lv_check = 'Y' THEN
       RETURN FALSE;
     ELSE
       RETURN TRUE;
     END IF;
   END f_exclude_prog;

   ----------------------------------------------------------------
   --
   -- Procedure to preserve manual overrides. When grade roll has
   -- run for part of terms that have ended, it triggers a new
   -- Course Program of Study (CPOS) audit to be rerun.  When the
   -- new audit runs it is no longer counting the courses where
   -- they received a non passing grade.  In order to avoid graded
   -- (failing) courses from becoming ineligible for aid after
   -- disbursement, this is to be run prior to the CPOS audit to
   -- ‘preserve override’ on any course with a grade entered on
   -- SFRSTCR (registration table).
   --
   -- p_vpdi - College to process
   -- p_term - Term code to process
   --
   PROCEDURE p_preserve_overrides
     ( p_vpdi_code IN gtvvpdi.gtvvpdi_code%TYPE,
       p_term_code IN stvterm.stvterm_code%TYPE )
   IS

   BEGIN
     WL(' ');
     WL(' Preserving overrides...');
     WL(' ');

     IF ( p_vpdi_code IS NULL OR p_vpdi_code = '' ) THEN
       WL(' ');
       WL(' ERROR: Paramater VPDI CODE is NULL or not valid.');
       WL(' ');
       RETURN;
     END IF;

     IF ( f_valid_vpdi(p_vpdi_code) = FALSE ) THEN
       WL(' ');
       WL(' ERROR: Paramater VPDI CODE is not valid.');
       WL(' ');
       RETURN;
     END IF;

     IF ( p_term_code IS NULL OR p_term_code = '' ) THEN
       WL(' ');
       WL(' ERROR: Paramater TERM CODE is NULL or not valid.');
       WL(' ');
       RETURN;
     END IF;

     IF ( f_valid_term(p_term_code) = FALSE ) THEN
       WL(' ');
       WL(' ERROR: Paramater TERM CODE is not valid.');
       WL(' ');
       RETURN;
     END IF;

     -- Update records that are:
     --    1. Not currently flagged
     --    2. Only the last recent run sequence
     --    3. A grade exists on SFRSTCR
     --    4. The grade that exists on SFRSTCR is NOT "X"
     --    5. And course status is only RC, RE, and RW
     --
     UPDATE sfrscre e
      SET   e.sfrscre_preserve_ovr_cde = 'Y'
      WHERE e.sfrscre_vpdi_code = p_vpdi_code
      AND   e.sfrscre_term_code = p_term_code
      AND   e.sfrscre_preserve_ovr_cde IS NULL
      AND   e.sfrscre_term_code IN (
              SELECT t.sfrcpst_term_code
               FROM  sfrcpst t
               WHERE TRUNC(SYSDATE) >= t.sfrcpst_start_date
               AND   TRUNC(SYSDATE) <  t.sfrcpst_end_date
               AND   e.sfrscre_vpdi_code = t.sfrcpst_vpdi_code )
      AND   e.sfrscre_runseq_no = (
              SELECT MAX(i2.sfrscre_runseq_no)
               FROM  sfrscre i2
               WHERE i2.sfrscre_pidm      = e.sfrscre_pidm
               AND   i2.sfrscre_term_code = e.sfrscre_term_code
               AND   i2.sfrscre_vpdi_code = e.sfrscre_vpdi_code )
      AND   EXISTS (
              SELECT 'Y'
               FROM  sfrstcr r
               WHERE e.sfrscre_vpdi_code = r.sfrstcr_vpdi_code
               AND   e.sfrscre_term_code = r.sfrstcr_term_code
               AND   e.sfrscre_crn       = r.sfrstcr_crn
               AND   e.sfrscre_pidm      = r.sfrstcr_pidm
               AND   r.sfrstcr_rsts_code IN ('RC', -- Reinstated Course
                                             'RE', -- **Registered**
                                             'RW'  -- **Registered On Web**
                                            )
               AND   r.sfrstcr_grde_code IS NOT NULL
               AND   COALESCE(r.sfrstcr_grde_code,'xxNULLxx') != 'X' );

     WL(' ');
     WL(' Updated '|| SQL%ROWCOUNT ||' records...');
     WL(' ');
     COMMIT;
   END p_preserve_overrides;

   ----------------------------------------------------------------
   --
   -- Procedure to preserve manual overrides. When grade roll has
   -- run for part of terms that have ended, it triggers a new
   -- Course Program of Study (CPOS) audit to be rerun.  When the
   -- new audit runs it is no longer counting the courses where
   -- they received a non passing grade.  In order to avoid graded
   -- (failing) courses from becoming ineligible for aid after
   -- disbursement, this is to be run prior to the CPOS audit to
   -- ‘preserve override’ on any course with a grade entered on
   -- SFRSTCR (registration table).
   --
   -- p_vpdi - College to process
   --
   PROCEDURE p_preserve_overrides
     ( p_vpdi_code IN gtvvpdi.gtvvpdi_code%TYPE )
   IS

   BEGIN
     WL(' ');
     WL(' Preserving overrides...');
     WL(' ');

     IF ( p_vpdi_code IS NULL OR p_vpdi_code = '' ) THEN
       WL(' ');
       WL(' ERROR: Paramater VPDI CODE is NULL or not valid.');
       WL(' ');
       RETURN;
     END IF;

     IF ( f_valid_vpdi(p_vpdi_code) = FALSE ) THEN
       WL(' ');
       WL(' ERROR: Paramater VPDI CODE is not valid.');
       WL(' ');
       RETURN;
     END IF;

     -- Update records that are:
     --    1. Not currently flagged
     --    2. Only the last recent run sequence
     --    3. A grade exists on SFRSTCR
     --    4. The grade that exists on SFRSTCR is NOT "X"
     --    5. And course status is only RC, RE, and RW
     --
     UPDATE sfrscre e
      SET   e.sfrscre_preserve_ovr_cde = 'Y'
      WHERE e.sfrscre_vpdi_code = p_vpdi_code
      AND   e.sfrscre_preserve_ovr_cde IS NULL
      AND   e.sfrscre_term_code IN (
              SELECT t.sfrcpst_term_code
               FROM  sfrcpst t
               WHERE TRUNC(SYSDATE) >= t.sfrcpst_start_date
               AND   TRUNC(SYSDATE) <  t.sfrcpst_end_date
               AND   e.sfrscre_vpdi_code = t.sfrcpst_vpdi_code )
      AND   e.sfrscre_runseq_no = (
              SELECT MAX(i2.sfrscre_runseq_no)
               FROM  sfrscre i2
               WHERE i2.sfrscre_pidm      = e.sfrscre_pidm
               AND   i2.sfrscre_term_code = e.sfrscre_term_code
               AND   i2.sfrscre_vpdi_code = e.sfrscre_vpdi_code )
      AND   EXISTS (
              SELECT 'Y'
               FROM  sfrstcr r
               WHERE e.sfrscre_vpdi_code = r.sfrstcr_vpdi_code
               AND   e.sfrscre_term_code = r.sfrstcr_term_code
               AND   e.sfrscre_crn       = r.sfrstcr_crn
               AND   e.sfrscre_pidm      = r.sfrstcr_pidm
               AND   r.sfrstcr_rsts_code IN ('RC', -- Reinstated Course
                                             'RE', -- **Registered**
                                             'RW'  -- **Registered On Web**
                                            )
               AND   r.sfrstcr_grde_code IS NOT NULL
               AND   COALESCE(r.sfrstcr_grde_code,'xxNULLxx') != 'X' );

     WL(' ');
     WL(' Updated '|| SQL%ROWCOUNT ||' records...');
     WL(' ');
     COMMIT;
   END p_preserve_overrides;
----------------------------------------------------------------
-- EA UH:8.15:1


END sfkscre;
/
