CREATE OR ALTER PROCEDURE AK_ROHERARCHYTREE (
  INSELECTLEVEL SMALLINT)
RETURNS (
  TREELEVEL SMALLINT,
  PARENTOPID SMALLINT,
  OPERATIONID SMALLINT,
  OPERATIONNAME VARCHAR(255),
  OPLEVEL SMALLINT)
AS
BEGIN
  IF (INSELECTLEVEL IS NULL) THEN BEGIN
                                    SUSPEND;
                                  END
  ELSE
      FOR
    /* Procedure Text */
          WITH RECURSIVE ROtree AS (
          SELECT
            :INSELECTLEVEL AS TreeLevel,
            ro.PARENTOPID,
            ro.OPERATIONID,
            ro.OPERATIONNAME,
            COALESCE(ro.OPLEVEL,0) AS OPLEVEL
          FROM RESTRICTEDOPERATIONS AS ro
          WHERE ro.PARENTOPID IS NULL
          UNION ALL
          SELECT
            1 + TreeLevel,
            ro.PARENTOPID,
            ro.OPERATIONID,
            ro.OPERATIONNAME,
            COALESCE(ro.OPLEVEL,0) AS OPLEVEL
          FROM RESTRICTEDOPERATIONS AS ro
          JOIN ROtree AS tro
          ON ro.PARENTOPID = tro.OPERATIONID
          )
          SELECT
            t.TreeLevel,
            t.PARENTOPID,
            t.OPERATIONID,
            t.OPERATIONNAME,
            t.OPLEVEL
          FROM ROtree AS t
          ORDER BY
            TreeLevel,
            PARENTOPID,
            OPERATIONID
      INTO
        :TreeLevel,
        :PARENTOPID,
        :OPERATIONID,
        :OPERATIONNAME,
        :OPLEVEL
      DO
      BEGIN
        SUSPEND; -- Returns the current row
      END
END