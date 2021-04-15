SELECT a.CREDIT_SALE_AMT, a.* FROM SD_DTGDSSALE_SUM a WHERE a.SAL_DT = '20210310' AND a.STR_CD = '019001';

CREATE OR REPLACE TABLE mqdb.SD_DTGDSSALE_SUM_20210311 SELECT * FROM SD_DTGDSSALE_SUM WHERE SAL_DT BETWEEN '20210305' AND '20210310';

UPDATE SD_DTGDSSALE_SUM SET CREDIT_SALE_AMT = 0
WHERE SAL_DT BETWEEN '20210308' AND '20210308'
AND STR_CD LIKE '013029';

UPDATE SD_DTGDSSALE_SUM A, (

        SELECT
              P.SAL_DT
            , P.STR_CD
            , P.PLU_CD
            , SUM(P.CREDIT_SALE_AMT) AS CREDIT_SALE_AMT
            , count(1) over()
        FROM (

                SELECT
                    P.SAL_DT , P.STR_CD , P.POS_NO, P.TRAN_NO , G.PLU_CD, G.TAX_TP, G.SALE_AMT * G.SALE_RTN_SGN AS SALE_AMT
                    , (G.SALE_AMT* G.SALE_RTN_SGN) / SUM(SALE_AMT* G.SALE_RTN_SGN) OVER(PARTITION BY G.SAL_DT , G.STR_CD , G.POS_NO, G.TRAN_NO) AS SALE_RT
                    , P.PAY_AMT * ( (G.SALE_AMT* G.SALE_RTN_SGN) / SUM(SALE_AMT* G.SALE_RTN_SGN) OVER(PARTITION BY G.SAL_DT , G.STR_CD , G.POS_NO, G.TRAN_NO)) AS CREDIT_SALE_AMT
                    , P.PAY_AMT AS PAY_AMT
                    , GM.VEN_CD
                    , V.VEN_TP
                FROM (

                    SELECT P.SAL_DT , P.STR_CD , P.POS_NO, P.TRAN_NO , SUM(P.PAY_AMT * P.SALE_RTN_SGN)  AS PAY_AMT
                    FROM TR_POSSALE_PAY P
                    WHERE 1=1
                        AND P.STR_CD LIKE '013029'
                        AND P.SAL_DT BETWEEN '20210308' AND '20210308'
                        AND P.PAY_ITEM_ID = '50'
                        AND P.DESI_CNCL_TP = '0'
                    GROUP BY P.SAL_DT , P.STR_CD , P.POS_NO, P.TRAN_NO

                ) P
                INNER JOIN TR_POSSALE_GDS G ON 1=1
                    AND G.STR_CD = P.STR_CD
                    AND G.SAL_DT = P.SAL_DT
                    AND G.POS_NO = P.POS_NO
                    AND G.TRAN_NO = P.TRAN_NO
--                     AND G.PLU_CD  = '200364'
                    AND G.DESI_CNCL_TP = '0'
                INNER JOIN VW_GDS_MST GM ON 1=1
                    AND G.STR_CD = GM.STR_CD
                    AND G.PLU_CD = GM.PLU_CD
                INNER JOIN ST_VEN_MST V ON 1=1
                    AND V.CO_CD = GM.CO_CD
                    AND V.STR_CD = GM.STR_CD
                    AND v.VEN_CD = gm.VEN_CD

        ) P GROUP BY P.SAL_DT, P.STR_CD, P.PLU_CD

    ) B
SET A.CREDIT_SALE_AMT = B.CREDIT_SALE_AMT
WHERE 1=1
    AND A.SAL_DT = B.SAL_DT
    AND A.STR_CD = B.STR_CD
    AND A.PLU_CD = B.PLU_CD
