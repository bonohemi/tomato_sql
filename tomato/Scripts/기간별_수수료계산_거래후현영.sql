SET @STR_CD = '009001';
SET @SAL_ST_ST= '20210301';
SET @SAL_ST_ED= '20210301';

SET @TRAN_KEY = '20210201-011001-02-0006';
SET @SAL_DT = SUBSTRING(@TRAN_KEY, 1,8);
SET @STR_CD = SUBSTRING(@TRAN_KEY, 10,6);
SET @POS_NO = SUBSTRING(@TRAN_KEY, 17,2);
SET @TRAN_NO = SUBSTRING(@TRAN_KEY, 20,4);
SELECT @SAL_DT, @STR_CD, @POS_NO, @TRAN_NO,  @SAL_DT_ST, @SAL_DT_ED, @TRAN_NO_ST, @TRAN_NO_ED, @TRAN_KEY;

CALL up_BT_VenFee_Select(@SAL_DT, @STR_CD, @POS_NO, @TRAN_NO, '00', 'N');


SELECT
    CONCAT(H.ORN_SAL_DT,'-',H.ORN_STR_CD,'-',H.ORN_POS_NO,'-',H.ORN_TRAN_NO) ORN_KEY
    , H.*
FROM TR_POSTRAN_HDR H WHERE STR_CD LIKE '011001' AND SAL_DT BETWEEN '20210201' AND '20210201' AND SALE_KIND_TP = '12'



/* TITLE: 교환반품 
 * */
SELECT
    *
FROM TR_POSSALE_PAY WHERE STR_CD LIKE '011001' AND SAL_DT BETWEEN '20210201' AND '20210231' AND PAY_ITEM_ID = '10' AND PAY_AMT = 0


SELECT
    *
FROM TR_POSSALE_PAY WHERE STR_CD LIKE '011001' AND SAL_DT BETWEEN '20210201' AND '20210201' AND POS_NO = '03' AND TRAN_NO = '0316'

SELECT
    *
FROM TR_POSSALE_GDS WHERE STR_CD LIKE '011001' AND SAL_DT BETWEEN '20210201' AND '20210201' AND POS_NO = '03' AND TRAN_NO = '0316'


20210201    011001  03  0316

        SELECT * FROM TT_FEE_PAY_P1 B WHERE 1=1
            AND B.SAL_DT = '20210201'
            AND B.STR_CD = '011001'
            AND B.POS_NO = '03'
            AND B.TRAN_NO = '0316'
            AND B.결제터미널ID = '본매장'



/* TITLE: 거래후현영 
 * */
SELECT 
    H.*
FROM TR_POSTRAN_HDR H
INNER JOIN TR_POSTRAN_HDR H12 ON 1=1
    AND H12.ORN_STR_CD = H.STR_CD 
    AND H12.ORN_SAL_DT = H.SAL_DT 
    AND H12.ORN_POS_NO = H.POS_NO 
    AND H12.ORN_TRAN_NO = H.TRAN_NO
    AND H12.STR_CD = @STR_CD
    AND H12.SAL_DT BETWEEN '20210201' AND '20210201'
    AND H12.SALE_KIND_TP = '12'
    
    
SELECT STR_CD, SAL_DT, COUNT(1) AS CNT
FROM TR_POSTRAN_HDR H WHERE STR_CD LIKE '013051' AND SAL_DT BETWEEN '20210301' AND '20210330'
GROUP BY STR_CD, SAL_DT






SELECT * FROM SD_DTGDSSALE_SUM WHERE STR_CD LIKE '013051' AND SAL_DT = '20210324'

SELECT * FROM GD_GDSCLSS_MST WHERE CO_CD LIKE '1001342'