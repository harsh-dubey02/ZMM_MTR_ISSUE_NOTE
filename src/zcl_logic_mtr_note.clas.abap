CLASS zcl_logic_mtr_note DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS get_pdf_64
      IMPORTING
                VALUE(io_materialdocument) TYPE  I_MaterialDocumentHeader_2-materialdocument    "<-write your input name and type
      RETURNING VALUE(pdf_64)              TYPE string..

  PRIVATE SECTION.

    METHODS build_xml
      IMPORTING
        VALUE(io_materialdocument) TYPE  I_MaterialDocumentHeader_2-materialdocument  "<-write your input name and type
      RETURNING
        VALUE(rv_xml)              TYPE string.
ENDCLASS.



CLASS ZCL_LOGIC_MTR_NOTE IMPLEMENTATION.


  METHOD get_pdf_64.

    DATA(lv_xml) = build_xml(
                      io_materialdocument   = io_materialdocument ).    "<-write your input name

    IF lv_xml IS INITIAL.
      RETURN.
    ENDIF.

    CALL METHOD zadobe_ads_class=>getpdf
      EXPORTING
        template = 'ZMTR_ISSUE/ZMTR_ISSUE'     "<-write your template and schema name
        xmldata  = lv_xml
      RECEIVING
        result   = DATA(lv_result).

    IF lv_result IS NOT INITIAL.
      pdf_64 = lv_result.
    ENDIF.

  ENDMETHOD.


  METHOD build_xml.
  DATA:
      lv_docdate          TYPE I_MATERIALDOCUMENTHEADER_2-DocumentDate,
      lv_materialdocument TYPE I_MATERIALDOCUMENTHEADER_2-MaterialDocument,
      lv_dept             TYPE I_MATERIALDOCUMENTITEM_2-IssuingOrReceivingStorageLoc,
      Lv_mat_desc         type I_ProductDescription-ProductDescription,
      lv_pr_bt_cd         type I_MATERIALDOCUMENTITEM_2-MaterialDocumentItemText,
      lv_res_no           type I_MATERIALDOCUMENTITEM_2-Reservation,
      lv_year             type string,
      lv_month            type string,
      lv_day              type string,
      lv_month_name       type string,
      lv_doc_date_text    type string,
      lv_sr_no            TYPE i VALUE 0.

*--------------------------------------
* READ MATERIAL DOCUMENT
*--------------------------------------
    SELECT
      a~MaterialDocument,
      a~PostingDate,
      b~Material,
      b~QuantityInBaseUnit,
      b~Batch,
      b~IssuingOrReceivingStorageLoc,
      b~reservation,
      b~MaterialDocumentItemText,
      c~ProductDescription
    FROM I_MATERIALDOCUMENTHEADER_2 AS a
    INNER JOIN I_MATERIALDOCUMENTITEM_2 AS b
      ON a~MaterialDocument = b~MaterialDocument
    LEFT OUTER JOIN I_ProductDescription AS c
    ON b~Material = c~Product
    AND c~Language = @sy-langu
    WHERE a~MaterialDocument = @io_MaterialDocument
      AND DebitCreditCode = 'H'
    INTO TABLE @DATA(it_matdoc).

    IF it_matdoc IS INITIAL.
      RETURN.
    ENDIF.

*--------------------------------------
* HEADER DATA — FIRST RECORD
*--------------------------------------
    READ TABLE it_matdoc INTO DATA(ls_first) INDEX 1.

    lv_docdate          = ls_first-PostingDate.
    lv_materialdocument = io_MaterialDocument.
    lv_dept             = ls_first-IssuingOrReceivingStorageLoc.
    lv_res_no           = ls_first-Reservation.

   DATA(lv_xml_header) = |<form1>|.

DATA(lv_xml_items) = ``.

LOOP AT it_matdoc INTO DATA(ls_item).

  SHIFT ls_item-Material LEFT DELETING LEADING '0'.

  lv_xml_items = lv_xml_items && "#EC CI_NOORDER
  |  <SUBFORM3>| &&
  |     <RM_CD>{ ls_item-Material }</RM_CD>| &&
  |     <RM_DES>{ ls_item-ProductDescription }</RM_DES>| &&
  |     <GRN_NO>{ io_materialdocument }</GRN_NO>| &&
  |     <G_WT></G_WT>| &&
  |     <T_WT></T_WT>| &&
  |     <N_WT>{ ls_item-QuantityInBaseUnit }</N_WT>| &&
  |     <BT_PD>{ ls_item-MaterialDocumentItemText }</BT_PD>| &&
  |     <OP_NM></OP_NM>| &&
  |     <ISS_DT>{ lv_doc_date_text }</ISS_DT>| &&
  |     <BT_CD>{ ls_item-Batch }</BT_CD>| &&
  |  </SUBFORM3>|.



ENDLOOP.

DATA(lv_xml_footer) = |</form1>|.

rv_xml = |{ lv_xml_header } { lv_xml_items } { lv_xml_footer }|.

  ENDMETHOD.
ENDCLASS.
