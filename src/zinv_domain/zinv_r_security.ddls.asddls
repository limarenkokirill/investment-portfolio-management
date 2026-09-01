@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Security Root View Entity'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZINV_R_SECURITY as select from zinv_security as securityDB
{
  key securityDB.securityuuid          as SecurityUUID,

      securityDB.isin                  as ISIN,
      securityDB.ticker                as Ticker,
      securityDB.securityname          as SecurityName,
      securityDB.issuer                as Issuer,
      securityDB.opendate              as OpenDate,
      securityDB.closedate             as CloseDate,
      securityDB.securitytype          as SecurityType,
      securityDB.currency              as Currency,
      securityDB.status                as Status,

      @Semantics.user.createdBy: true
      securityDB.created_by            as CreatedBy,

      @Semantics.systemDateTime.createdAt: true
      securityDB.created_at            as CreatedAt,

      @Semantics.user.localInstanceLastChangedBy: true
      securityDB.local_last_changed_by as LocalLastChangedBy,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      securityDB.local_last_changed_at as LocalLastChangedAt,

      @Semantics.systemDateTime.lastChangedAt: true
      securityDB.last_changed_at       as LastChangedAt
}
