%default WASB_SCHEME 'wasb';
%default ROOT_FOLDER 'logs';

iislog = LOAD '$WASB_SCHEME:///$ROOT_FOLDER/$YEAR/$MONTH/$DAY/$INPUTFILE' USING PigStorage(' ') AS (date: chararray
, time: chararray
, sourceIP: chararray
, csMethod: chararray
, csUriStem: chararray
, csUriQuery: chararray
, sourcePort: chararray
, csUsername: chararray
, cIP: chararray
, csUserAgent: chararray
, csReferer: chararray
, scStatus: int
, scSubStatus: int
, scWin32Status: int
, timeTaken: int);
errors = FILTER iislog BY date == '$YEAR-$MONTH-$DAY' AND scStatus != 200 AND scStatus != 201;
STORE errors INTO '$WASB_SCHEME:///$ROOT_FOLDER/$YEAR/$MONTH/$DAY/output';