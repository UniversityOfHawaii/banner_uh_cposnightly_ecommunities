/*
===============================================================================
                       University of Hawai'i Audit Trail
===============================================================================

    Kyle Hunt (kylehunt@hawaii.edu)                                 10-JUL-2019
    AUDIT TRAIL: UH:8.14:1
    JIRA BAN-1377 - Course Program of Study
         BAN-2215 - Process to populate population selections    
         BAN-2216 - Script to check override box on SFASCRE

    1.  Initial mods done to package.
    2.  Added procedures p_load_popsels and p_preserve_overrides.

    Kyle Hunt (kylehunt@hawaii.edu)                                 22-APR-2020
    3.  Added procedures p_clear_popsels.
    4.  Added package constant UH_MAX_POPSEL_BATCHES.

--  AUDIT TRAIL END
-*/
--
CREATE OR REPLACE PACKAGE sfkscre
AS
   --AUDIT_TRAIL_MSGKEY_UPDATE
-- PROJECT : MSGKEY
-- MODULE  : SFKSCRE
-- SOURCE  : enUS
-- TARGET  : I18N
-- DATE    : Fri Sep 15 05:33:59 2017
-- MSGSIGN : #0000000000000000
--TMI18N.ETR DO NOT CHANGE--
   --
   -- FILE NAME..: sfkscre.sql
   -- RELEASE....: UH:8.14:1 -- 8.14
   -- OBJECT NAME: sfkscre
   -- PRODUCT....: STUDENT
   -- USAGE......: Package to facilitate Student Course Evaluation process.
   -- COPYRIGHT..: Copyright 2017 Ellucian Company L.P. and its affiliates.
   --
   -- Contains confidential and proprietary information of Ellucian and its subsidiaries.
   -- Use of these materials is limited to Ellucian licensees, and is
   -- subject to the terms and conditions of one or more written license agreements
   -- between Ellucian and the licensee in question.
   --

--
-- NOTE: Omitted much of Ellucian code, only adding procedure/function declarations
--

-- BA UH:8.14:1
-- ================================================================================================
--                              University of Hawai'i Modifications
-- ================================================================================================

   --TYPE t_inserts_aat IS TABLE OF glbextr%ROWTYPE INDEX BY BINARY_INTEGER;
   UH_MAX_POPSEL_BATCHES     CONSTANT NUMBER := 10;

   --
   -- Procedure to clear all student populations used to run in the Java process.
   --   p_application       - Which application to house the popselect under
   --   p_creator_id        - Which create to house the popselect under
   --   p_user_id           - Which user id to house the popselect under
   --   p_selection_prefix  - Prefix of the name of popselect; process appends college and
   --                         batch number to end of it.
   --   p_vpdi_code         - Which college to populate
   PROCEDURE p_clear_popsels( p_application        IN glbextr.glbextr_application%TYPE,
                              p_selection_prefix   IN glbextr.glbextr_selection%TYPE,
                              p_creator_id         IN glbextr.glbextr_creator_id%TYPE,
                              p_user_id            IN glbextr.glbextr_user_id%TYPE,
                              p_vpdi_code          IN glbextr.glbextr_vpdi_code%TYPE
   );

   --
   -- Procedure to evenly distribute the student population to run amongst the specified batches
   --   p_application       - Which application to house the popselect under
   --   p_creator_id        - Which create to house the popselect under
   --   p_user_id           - Which user id to house the popselect under
   --   p_selection_prefix  - Prefix of the name of popselect; process appends college and
   --                         batch number to end of it.
   --   p_vpdi_code         - Which college to populate
   --   p_batches           - How many popselects to distribute students over
   PROCEDURE p_load_popsels( p_application        IN glbextr.glbextr_application%TYPE,
                             p_selection_prefix   IN glbextr.glbextr_selection%TYPE,
                             p_creator_id         IN glbextr.glbextr_creator_id%TYPE,
                             p_user_id            IN glbextr.glbextr_user_id%TYPE,
                             p_vpdi_code          IN glbextr.glbextr_vpdi_code%TYPE,
                             p_batches            IN NUMBER   
   );

   --
   -- Procedure to preserve manual overrides. When grade roll has run for part of terms 
   -- that have ended, it triggers a new Course Program of Study (CPOS) audit to be rerun. 
   -- When the new audit runs it is no longer counting the courses where they received a 
   -- non passing grade. In order to avoid graded (failing) courses from becoming ineligible
   -- for aid after disbursement, this is to be run prior to the CPOS audit 
   -- to ‘preserve override’ on any course with a grade entered on SFRSTCR (registration table).
   --
   --   p_vpdi  - College to process
   --   p_term  - Term code to process
   PROCEDURE p_preserve_overrides( p_vpdi IN gtvvpdi.gtvvpdi_code%TYPE,
                                   p_term IN stvterm.stvterm_code%TYPE );

   
-- EA UH:8.14:1
   
   
---------------------------------------------------------------------------------------

END sfkscre;
/
