-------------------------------------------------------------------------------------------------------------
--
-- File Name: sobrest_clone_updates.sql
-- Author:    Kyle Hunt <kylehunt@hawaii.edu>
-- Created:   18-May-17
-- Version:   1.3
--
-- Purpose:   Updates needed records in SOBREST for the cloning process.
--
-- Notes:     1.  Run as SATURN.
--            2.  Assumes one test URL that uses PORTs to determine which environment is to be used. 
--                Update the URL as needed for your institution.
--
-- Audit Log 1.0:
--
--    1. Initial release of this script.                                                      KAH 18-May-2017
--    2. Added to logic to change the URL and port pending which environment is used.             09-DEC-2019
--    3. Updated user name.
--    4. Renamed script and updated documentation.                                                21-APR-2020
--
-- Audit Log 1.0 End
-------------------------------------------------------------------------------------------------------------
--
PROMPT
PROMPT Start of sobrest_clone_updates.sql
PROMPT
--
PROMPT
PROMPT Data before updates:
PROMPT
SELECT x.* FROM sobrest x;
--
PROMPT
PROMPT Updating data
PROMPT
UPDATE sobrest
SET    sobrest_url =  REPLACE( sobrest_url,
                               'https://www.institution.edu:<port01>',
                               CASE UPPER(sys_context('USERENV','DB_NAME'))
                                  WHEN 'BANDEV'   THEN 'https://test.institution.edu:<port02>'
                                  WHEN 'BANDEV2'  THEN 'https://test.institution.edu:<port03>'
                                  WHEN 'BANPPRD'  THEN 'https://test.institution.edu:<port04>'
                                  WHEN 'BANPPRD2' THEN 'https://test.institution.edu:<port05>'
                                  WHEN 'BANTRNG'  THEN 'https://test.institution.edu:<port06>'
                                  WHEN 'BANTRNG2' THEN 'https://test.institution.edu:<port07>'
                                  ELSE                 'FIXME'
                               END
                      )
;
--
PROMPT
PROMPT Data after updates:
PROMPT
SELECT x.* FROM sobrest x;
--
PROMPT
PROMPT SOBREST Updates Completed
PROMPT
--
COMMIT;
