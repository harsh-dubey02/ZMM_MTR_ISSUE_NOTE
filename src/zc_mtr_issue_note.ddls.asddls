@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'consumption for mtr issue note'
@Metadata.allowExtensions: true
define root view entity ZC_MTR_ISSUE_NOTE as projection on ZI_MTR_ISSUE_NOTE
{
    key MaterialDocument,
    base64,
    m_ind
}
