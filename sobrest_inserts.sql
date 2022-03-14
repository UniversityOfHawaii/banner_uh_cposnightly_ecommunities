-------------------------------------------------------------------------------------------------------------
--
-- File Name: sobrest_inserts.sql
-- Author:    Kyle Hunt <kylehunt@hawaii.edu>
-- Created:   18-May-17
-- Version:   1.3
--
-- Purpose:   Insert needed records into SOBREST for the CPOS process.
--
-- Notes:     1.  Run as SATURN.
--            2.  Assumes its a MEPed environment.
--            3.  Prefixes it with S<MEP CODE> for the data entry.
--
-- Audit Log 1.0:
--
--    1. Initial release of this script.                                                      KAH 18-May-2017
--    2. Added to logic to change the URL and port pending which environment is used.             09-DEC-2019
--    3. Updated user name.
--
-- Audit Log 1.0 End
-------------------------------------------------------------------------------------------------------------
--
PROMPT
PROMPT Start of sobrest_inserts.sql
PROMPT
--
PROMPT
PROMPT Data before inserts:
PROMPT
SELECT x.* FROM sobrest x;
--
PROMPT
PROMPT Deleting data
PROMPT
DELETE FROM sobrest 
WHERE sobrest_api_code in ( SELECT 'S' || gtvvpdi_code 
                            FROM GTVVPDI );
--
PROMPT
PROMPT Start data inserts:
PROMPT
--
SET SCAN OFF;
--
DECLARE
  lv_url  VARCHAR2(100);
BEGIN
--
-- Change URL and port pending environment
--
  CASE UPPER(sys_context('USERENV','DB_NAME'))
    WHEN 'BANDEV'   THEN lv_url := 'https://test.institution.edu:<port01>';
    WHEN 'BANDEV2'  THEN lv_url := 'https://test.institution.edu:<port02>';
    WHEN 'BANPPRD'  THEN lv_url := 'https://test.institution.edu:<port03>';
    WHEN 'BANPPRD2' THEN lv_url := 'https://test.institution.edu:<port04>';
    WHEN 'BANTRNG'  THEN lv_url := 'https://test.institution.edu:<port05>';
    WHEN 'BANTRNG2' THEN lv_url := 'https://test.institution.edu:<port06>';
    WHEN 'PROD'     THEN lv_url := 'https://www.institution.edu:<port07>';
    ELSE                 lv_url := 'FIXME';
  END CASE;
--
-- Insert for only missing STAR STVREST codes S%
--
  FOR c1 IN ( SELECT *
              FROM   GTVVPDI
              WHERE  EXISTS (SELECT 'Y'
                             FROM   stvrest 
                             WHERE  stvrest_code =  'S' || gtvvpdi_code)
              AND    NOT EXISTS ( SELECT 'Y'
                                  FROM   sobrest
                                  WHERE  sobrest_api_code = 'S' || gtvvpdi_code )
            )
--
  LOOP
    BEGIN
      INSERT INTO sobrest
        (sobrest_api_code,
         sobrest_url,
         sobrest_username,
         sobrest_password,
         sobrest_user_id,
         sobrest_activity_date,
         sobrest_vpdi_code)
      VALUES
        ('S' || c1.gtvvpdi_code,
         lv_url || '/cpos/v1/runAudit?campus='||UPPER(c1.gtvvpdi_code)||'&term=202010',   -- Default TERM code appended to insert.
         'degree_audit_user',                                                             -- Generic user required for insert, change on SOAREST
         sokrest.f_encrypt('degree_audit_pass_' || LOWER(c1.gtvvpdi_code)),               -- Generic password required for insert, change on SOAREST.
         USER,
         SYSDATE,
         c1.gtvvpdi_code);
    END;
  END LOOP;
--
END;
/
--
SET SCAN ON;
--
PROMPT
PROMPT Data after inserts:
PROMPT
SELECT x.* FROM sobrest x;
--
PROMPT
PROMPT SOBREST Inserts Completed
PROMPT
--
COMMIT;
