# banner_uh_cposnightly_ecommunities

                                        UNIVERSITY OF HAWAII
                                           BANNER CENTRAL
                           COURSE PROGRAM OF STUDY (CPOS) NIGHTLY ROUTINES
                                          FOR ECOMMUNITIES 

PURPOSE:

    The Course Program of Study (CPOS) nightly routines are used to process all of the students 
    daily.  It does this by assigning all of an institution's students to multiple popselection and 
    then submits parallel executions of SFPCPOS until all popselections are completed.

NOTES:

     1.   Process is intended to run under the JOBSUB user to run this processes as the output is 
          stored to the $JOB_HOME financial aid folders.
     2.   University of Hawaii is a customized MEPed installation of Banner. Some of the code within
          is unique to MEP. If you are a baseline NON-MEP institution, it should work, just with 
          some tweaks. Mainly, we use many LOOPs to process each MEP code.
     3.   The concept of shell variable $UH_HOME is the directory where all of our custom code and 
          processes reside, with a folder housing a project/process files. This helps keep UH code 
          out of baseline Banner code. Ex:

              $UH_HOME =  /u01/uhmods/

              $UH_HOME/bin
              $UH_HOME/etc
              $UH_HOME/sfpcpos_nightly

     4.   Modifications were also done to the SFKSCRE package. A shorted, abbreviated versions of the 
          package header and body are included. This includes a few logic changes, logic on how to 
          load students into the different popsels, and how to preserve overrides when a grade has 
          been rolled but may not count towards a students program.


HOW TO INSTALL:

     BASH Files:

          Place the following executable scripts into its project folder. EX:
               $UH_HOME/sfpcpos_nightly:

          run_sfpcpos_parallel.shl           - Main script that runs the entire process

          sfpcpos_controls_all.cfg           - Example configuration files that determines which 
          sfpcpos_controls_test.cfg            institutions to process, sleep duration, and 
                                               population selection variables.

          sfpcpos_parallel_bandev.crontab    - Example CRON entry for scheduling
                                               the process.

          create_jobsub_directories.shl      - Script used to create UH's jobsub folder scheme.
                                               Used by SAs to replicate the folder structure on
                                               all environments. Modify as needed.

          check_install.shl                  - Run after create_jobsub_directories.shl which
                                               verifies structure, permissions, and files are
                                               in the right location.

          Place the following in your $BANNER_HOME custom directory. This folder is the root 
          directory that UH uses to hold all the customization that have been done to the system. 

          EX:
              $BANNER_HOME/student/misc            <---- Baseline file
              $BANNER_HOME/uhmods/student/misc/    <---- UH Modified version
          
          Then re-link the file from the custom folder to $BANNER_LINKS.

          sfpcpos_nightly.shl                - Modified version of the sfpcpos.shl file that takes
                                               in the custom credential file that it reads to start 
                                               a SFPCPOS run.


    SQL Files to execute:

          Following SQL scripts are placed in to the $BANNER_HOME custom directory. Same concept for
          the above shell script:
               $BANNER_HOME/uhmods/student/misc

          sfkscre_faload_grants.sql          - Script to grant needed database permissions to the
                                               database accounts that will do the processing.

          stvrest_inserts.sql                - Script to seed all REST_CODE entries for each
                                               MEP code entered on GTVVPDI.

          sobrest_inserts.sql                - Script to seed all SOAREST entries for each MEP
                                               code entered on GTIVVPDI using the REST_CODE from
                                               previous script.

          sobrest_clone_updates.sql          - Example cloning script to include in database 
                                               refreshes so each environment points to the intended
                                               Degree Audit System API URL.


          Following SQL scripts are placed into the $BANNER_HOME/uhmods/student/dbprocs directory:

          sfkscre.sql                        - Abbreviated changes done to the SFKSCRE package that
          sfkscre1.sql                         include logic change


HOW TO CONFIGURE:

     There are two configuration locations that need to be reviewed by your institution and edited
     to work in your environment:

     OS configuration:  sfpcpos_controls_all.cfg

          MAX_PARALLEL:  Maximum amount of SFPCPOS Java processes to run. This is dependent upon
                         the JOBSUB machines available RAM. In the sfpcpos.shl fille, Ellucian
                         sets the SFPCPOS Java processes to use a maximum amount of 1024mb of RAM.
                         For example, the default is set to be 10 concurrent processes; therefore 
                         requiring around 10gb of RAM to be available for all processes to use.
                         Increase or decrease according to available resources.

          SLEEP_TIME:    Amount of time to sleep between monitoring SFPCPOS processes when
                         processing all queued JOBSUBs.  Defaulted to 5 mins. The lower this
                         duration will result in quicker processing of the queue.

          collegeCtrl:   Array of MEP/VPD codes to process. Allows for institutions to be turned
                         ON and OFF depending the institutions' readiness for CPOS processing.
                         Values match on what has been entered on GTVVPDI.

          popSelCtrls:   Array indexed by MEP/VPD codes that contains an institution's controls
                         for which user to use for the SFPCPOS process, popselection to use 
                         (application, prefix, user, creator) and batches/buckets to split an 
                         institutions student population into. This creates N popselections for the 
                         institution. General rule of thumb is to try create batches of 1,000 to 
                         2,000 due to when SFPCPOS errors out, it rolls back ALL changes in that 
                         session. This allows for progress to be made on the student population 
                         while isolating any issues that may arise from affecting other batches of 
                         students.

          emailsCtrls:   Array indexed by MEP/VPD codes that contains a space delimited list of
                         recipients of any progress or issue emails.

                         Includes a "FUNC" entry for the system functional to receive progress
                         emails.

                         Includes a "DEVS" entry for developers to receive any errors during
                         processing.

     Database Configuration: sfkscre.sql

          UH_MAX_POPSEL_BATCHES:  Max amount of batches allowed per institution.

HOW TO RUN:

     Run the script with the following:
         bash run_sfpcpos_parallel.shl SID CONFIG > LOG 2>&1
       
         Where:
              SID     : Which environment to run in
              CONFIG  : Which configuration file to use
         Ex:
              run_sfpcpos_parallel.shl bandev sfpcpos_controls_test.cfg
              run_sfpcpos_parallel.shl bandev sfpcpos_controls_all.cfg

OTHER INFORMATION:

     GitHub URL:
     https://github.com/UniversityOfHawaii/banner_uh_cposnightly_ecommunities