@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Security Projection View Entity'
@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZINV_C_SECURITY
  provider contract transactional_query as projection on ZINV_R_SECURITY
{
    key SecurityUUID,
    ISIN,
    Ticker,
    SecurityName,
    Issuer,
    OpenDate,
    CloseDate,
    SecurityType as InstrumentType,
    @Consumption.valueHelpDefinition: [{ 
    entity: { name: 'I_Currency', element: 'Currency' }
    }]
    Currency,
    Status,
    CreatedBy,
    CreatedAt,
    LocalLastChangedBy,
    LocalLastChangedAt,
    LastChangedAt
}
