@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'material issue note'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_MTR_ISSUE_NOTE as select from  I_MaterialDocumentHeader_2 as a
    left outer join ztb_mtr_issue        as b on a.MaterialDocument = b.materialdocument
{
  key a.MaterialDocument,
      b.base64_3 as base64,
      b.m_ind
}
