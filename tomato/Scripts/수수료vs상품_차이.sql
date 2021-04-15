SELECT
    *
FROM (
    SELECT
        CASE
          WHEN DATE_FORMAT(NOW(), '%d') = '01' THEN DATE_FORMAT(LAST_DAY(NOW() - INTERVAL 2 MONTH) + INTERVAL 1 DAY, '%Y-%m-%d')
          ELSE DATE_FORMAT(LAST_DAY(NOW() - INTERVAL 1 MONTH) + INTERVAL 1 DAY, '%Y-%m-%d')
        END                                                       AS 시작일 ,
        CASE
          WHEN DATE_FORMAT(NOW(), '%d') = '01' THEN DATE_FORMAT(LAST_DAY(NOW() - INTERVAL 1 MONTH), '%Y-%m-%d')
          ELSE DATE_FORMAT(NOW(), '%Y-%m-%d')
        END                                                       AS 마지막일 ,
        A.영업일자 ,
        A.매장코드 ,
        A.매장명 ,
        A.거래처코드 ,
        A.거래처명 ,
        A.상품코드 ,
        ROUND( SUM(A.수수료매출) )                                AS 수수료매출 ,
        ROUND( SUM(A.상품매출) )                                  AS 상품매출 ,
        ROUND( SUM(A.수수료매출)       - SUM(A.상품매출) )        AS 매출차이 ,
        ROUND( SUM(A.수수료현금)       - SUM(A.상품현금) )        AS 현금차이 ,
        ROUND( SUM(A.수수료카드)       - SUM(A.상품카드) )        AS 카드차이 ,
        ROUND( SUM(A.수수료외상)       - SUM(A.상품외상) )        AS 외상차이 ,
        ROUND( SUM(A.수수료포인트사용) - SUM(A.상품포인트사용) )  AS 포인트사용차이 ,
        ROUND( SUM(A.수수료포인트적립) - SUM(A.상품포인트적립) )  AS 포인트적립차이 ,
        ROUND( SUM(A.수수료캐시백사용) - SUM(A.상품캐시백사용) )  AS 캐시백사용차이 ,
        ROUND( SUM(A.수수료캐시백적립) - SUM(A.상품캐시백적립) )  AS 캐시백적립차이 ,
        ROUND( SUM(A.수수료현영)       - SUM(A.상품현영) )        AS 현영차이
    FROM (
        select
            FS.SAL_DT                                             as 영업일자 ,
            FS.STR_CD                                             AS 매장코드 ,
            SSM.STR_NM                                            AS 매장명 ,
            FS.FEE_VEN_CD                                         AS 거래처코드 ,
            SVM.VEN_NM                                            AS 거래처명 ,
            FS.PLU_CD                                             AS 상품코드 ,
            GGM.GDS_NM                                            AS 상품명 ,
            SUM(FS.SALE_QTY)                                      AS 수수료수량 ,
            SUM(FS.SALE_AMT)                                      AS 수수료매출 ,
            0 AS 상품수량 ,
            0 AS 상품매출 ,
            SUM(FS.CASH_SALE_AMT)                                 AS 수수료현금 ,
            SUM(FS.CARD_SALE_AMT)                                 AS 수수료카드 ,
            SUM(FS.CREDIT_SALE_AMT)                               AS 수수료외상 ,
            SUM(FS.PNT_SALE_AMT)                                  AS 수수료포인트사용 ,
            SUM(FS.PNT_SAVE_AMT)                                  AS 수수료포인트적립 ,
            SUM(FS.CASHBK_SALE_AMT)                               AS 수수료캐시백사용 ,
            SUM(FS.CASHBK_SAVE_AMT)                               AS 수수료캐시백적립 ,
            SUM(FS.BON_STR_CASH_BILL_PBC_AMT)
            + SUM(FS.VEN_CASHRPT_PBC_AMT)                         AS 수수료현영 ,
            0 AS 상품현금 ,
            0 AS 상품카드 ,
            0 AS 상품외상 ,
            0 AS 상품포인트사용 ,
            0 AS 상품포인트적립 ,
            0 AS 상품캐시백사용 ,
            0 AS 상품캐시백적립 ,
            0 AS 상품현영
        FROM SD_DTFEEGDSSALE_SUM FS /* 수수료매장 지불관리 테이블 */
          LEFT JOIN ST_STR_MST SSM
            ON  FS.STR_CD = SSM.STR_CD
          LEFT JOIN GD_GDS_MST GGM
            ON  FS.PLU_CD = GGM.PLU_CD
            AND GGM.STR_CD = FS.STR_CD
          LEFT JOIN ST_VEN_MST SVM
            ON  FS.FEE_VEN_CD = SVM.VEN_CD
            AND GGM.STR_CD = SVM.STR_CD
            AND GGM.CO_CD  = SVM.CO_CD
        WHERE 1=1
          AND (
            CASE
              WHEN DATE_FORMAT(NOW(), '%d') = '01' THEN FS.SAL_DT BETWEEN DATE_FORMAT(LAST_DAY(NOW() - INTERVAL 2 MONTH) + INTERVAL 1 DAY, '%Y%m%d') AND DATE_FORMAT(LAST_DAY(NOW() - INTERVAL 1 MONTH), '%Y%m%d')
              ELSE FS.SAL_DT BETWEEN DATE_FORMAT(LAST_DAY(NOW() - INTERVAL 1 MONTH) + INTERVAL 1 DAY, '%Y%m%d') AND DATE_FORMAT(NOW(), '%Y%m%d')
            END)
          AND FS.STR_CD LIKE '%'
          AND SVM.VEN_TP IN ('30', '40')
          AND FS.STR_CD <> '012002'
        GROUP BY FS.STR_CD , FS.FEE_VEN_CD , FS.SAL_DT , FS.PLU_CD
        UNION ALL
        select
            GS.SAL_DT                                   as 영업일자 ,
            GS.STR_CD                                   AS 매장코드 ,
            SSM.STR_NM                                  AS 매장명 ,
            GGM.VEN_CD                                  AS 거래처코드 ,
            SVM.VEN_NM                                  AS 거래처명 ,
            GS.PLU_CD                                   AS 상품코드 ,
            GGM.GDS_NM                                  AS 상품명 ,
            0 AS 수수료수량 ,
            0 AS 수수료매출 ,
            SUM(GS.SALE_QTY)                            AS 상품수량 ,
            SUM(GS.SALE_AMT)                            AS 상품매출 ,
            0 AS 수수료현금 ,
            0 AS 수수료카드 ,
            0 AS 수수료외상 ,
            0 AS 수수료포인트사용 ,
            0 AS 수수료포인트적립 ,
            0 AS 수수료캐시백사용 ,
            0 AS 수수료캐시백적립 ,
            0 AS 수수료현영 ,
            SUM(GS.CASH_SALE_AMT) + SUM(GFPN_SALE_AMT)  AS 상품현금 ,
            SUM(GS.CARD_SALE_AMT)                       AS 상품카드 ,
            SUM(GS.CREDIT_SALE_AMT)                     AS 상품외상 ,
            SUM(GS.PNT_USE_AMT)                         AS 상품포인트사용 ,
            SUM(GS.PNT_SAVE_AMT)                        AS 상품포인트적립 ,
            SUM(GS.CASHBK_SALE_AMT)                     AS 상품캐시백사용 ,
            SUM(GS.CASHBK_SAVE_AMT)                     AS 상품캐시백적립 ,
            SUM(GS.CASHRPT_PBC_AMT)                     AS 상품현영
        FROM SD_DTGDSSALE_SUM GS /* 상품 매출현황 테이블 */
          LEFT JOIN ST_STR_MST SSM
            ON  GS.STR_CD = SSM.STR_CD
          LEFT JOIN GD_GDS_MST GGM
            ON  GS.PLU_CD = GGM.PLU_CD
            AND GGM.STR_CD = GS.STR_CD
          LEFT JOIN ST_VEN_MST SVM
            ON  GGM.VEN_CD = SVM.VEN_CD
            AND SVM.STR_CD = GGM.STR_CD
            AND SVM.CO_CD  = GGM.CO_CD
        WHERE 1=1
          AND (
            CASE
              WHEN DATE_FORMAT(NOW(), '%d') = '01' THEN GS.SAL_DT BETWEEN DATE_FORMAT(LAST_DAY(NOW() - INTERVAL 2 MONTH) + INTERVAL 1 DAY, '%Y%m%d') AND DATE_FORMAT(LAST_DAY(NOW() - INTERVAL 1 MONTH), '%Y%m%d')
              ELSE GS.SAL_DT BETWEEN DATE_FORMAT(LAST_DAY(NOW() - INTERVAL 1 MONTH) + INTERVAL 1 DAY, '%Y%m%d') AND DATE_FORMAT(NOW(), '%Y%m%d')
            END)
          AND GS.STR_CD LIKE '%'
          AND SVM.VEN_TP IN ('30', '40')
          AND GS.STR_CD <> '012002'
          # AND GS.VEN_CD IS NOT NULL
        GROUP BY GS.STR_CD , GGM.VEN_CD , GS.SAL_DT , GS.PLU_CD
    ) A
    GROUP BY A.매장코드 , A.거래처코드 , A.영업일자, A.상품코드
) A
WHERE 1=1
  AND (
       A.매출차이       <> 0
    or A.현금차이       <> 0
    or A.카드차이       <> 0
    or A.외상차이       <> 0
    or A.포인트사용차이 <> 0
    or A.포인트적립차이 <> 0
    or A.캐시백사용차이 <> 0
    or A.캐시백적립차이 <> 0
    )
GROUP BY A.매장코드 , A.거래처코드 , A.영업일자 , A.상품코드
ORDER BY A.매장명 , A.거래처코드 ASC
;