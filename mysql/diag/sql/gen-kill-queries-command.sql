/*
 * Meta-query to build RDS kill query calls for queries that associated to selected threads.
 * The mysql.rds_kill_query(id) call terminates kill the query that is running on the thread id.
 * Reference: 
 * http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.MySQL.CommonDBATasks.html#Appendix.MySQL.CommonDBATasks.Kill
*/

/*==============================================================================*/
/* Set variables */
/* 
 * Use the following variables to select query threads to kill.
 * All variables used to define the selection of thread to kill are in AND in the query statment.
*/
SET @QUERY_USER="%";    /*Filter for user, "%" for all users*/
SET @QUERY_HOST="%";    /*Filter for host, "%" for all hosts*/
SET @QUERY_DB="%";      /*Filter for DB, "%" for all DBs*/
SET @QUERY_COMMAND="Query"; /*Filter ids for command thread is executing, "%" for all commands*/
SET @QUERY_TIME_MIN=0;  /*Set minimum execution time for running thread ids, set 0 for all queries*/ 
SET @QUERY_STATE="%";   /*Filter ids for query state, "%" for all states*/
/*==============================================================================*/

/*==============================================================================*/
/* Define statment */
SET @query=CONCAT(\
    "SELECT  "\
    "CONCAT(\"CALL mysql.rds_kill_query(\",id,\");\") AS KILL_QUERY_CMD, "\
    "user, host, db, command, time, state, info "\
    "from INFORMATION_SCHEMA.PROCESSLIST "\
    "where user like \'" , @QUERY_USER, "\' "\
    "and host like \'" , @QUERY_HOST, "\' "\
    "and db like \'" , @QUERY_DB, "\' "\
    "and command like \'" , @QUERY_COMMAND , "\' "\
    "and time >= " , @QUERY_TIME_MIN , " "\
    "and state like \'" , @QUERY_STATE , "\' "\
);

/* Prepare statment */
PREPARE stmt FROM @query;

/* Execute statment */
EXECUTE stmt;

/* Clean */
DEALLOCATE PREPARE stmt;
SET @query=Null;
SET @QUERY_USER=Null;  
SET @QUERY_HOST=Null;  
SET @QUERY_DB=Null;  
SET @QUERY_COMMAND=Null; 
SET @QUERY_TIME_MIN=Null;
SET @QUERY_STATE=Null;  
/*==============================================================================*/
