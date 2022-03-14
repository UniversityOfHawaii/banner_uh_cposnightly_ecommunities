-------------------------------------------------------------------------------------------------------------
--
-- File Name: stvrest_inserts.sql
-- Author:    Kyle Hunt <kylehunt@hawaii.edu>
-- Created:   18-May-17
-- Updated:   18-May-17
-- Version:   1.0
--
-- Purpose:   Insert needed records into STVREST for the CPOS process.
--
-- Notes:     1.  Run as SATURN.
--            2.  Assumes its a MEPed environment.
--            3.  Prefixes it with S<MEP CODE> for the data entry.
--
-- Audit Log 1.0:
--
--    1. Initial release of this script.                                                        KAH 18-May-17
--
-- Audit Log 1.0 End
-------------------------------------------------------------------------------------------------------------
--
PROMPT
PROMPT Start of stvrest_inserts.sql
PROMPT
--
PROMPT
PROMPT Data before inserts:
PROMPT
SELECT x.* FROM stvrest x;
--
PROMPT
PROMPT Start data inserts:
PROMPT
--
BEGIN
--
  FOR c1 IN (SELECT *
             FROM   GTVVPDI
             WHERE NOT EXISTS (SELECT 'Y' 
                               FROM   stvrest 
                               WHERE  stvrest_code =  'S' || gtvvpdi_code)
            )
  LOOP
--
    INSERT INTO stvrest
      (stvrest_code,
       stvrest_desc,
       stvrest_system_req_ind,
       stvrest_user_id,
       stvrest_activity_date,
       stvrest_vpdi_code)
    VALUES
      ('S' || c1.gtvvpdi_code,
       'External Degree Audit API for ' || c1.gtvvpdi_code,  --- Update as desired
       'Y',
       USER,
       SYSDATE,
       c1.gtvvpdi_code);
  END LOOP;
--
END;
/
--
PROMPT
PROMPT Data after inserts:
PROMPT
SELECT x.* FROM stvrest x;
--
PROMPT
PROMPT STVREST Inserts Completed
PROMPT
--
COMMIT;
