import '../models/attributes.dart';

AppActorAttribution? _customAttributionSnapshot;

AppActorAttribution mergeCustomAttributionPatch(AppActorAttribution patch) {
  final existing = _customAttributionSnapshot;
  final merged = AppActorAttribution(
    provider: patch.provider,
    providerOverride: patch.providerOverride ?? existing?.providerOverride,
    status: patch.status ?? existing?.status,
    providerName: patch.providerName ?? existing?.providerName,
    campaignId: patch.campaignId ?? existing?.campaignId,
    campaignName: patch.campaignName ?? existing?.campaignName,
    adGroupId: patch.adGroupId ?? existing?.adGroupId,
    adGroupName: patch.adGroupName ?? existing?.adGroupName,
    adId: patch.adId ?? existing?.adId,
    adName: patch.adName ?? existing?.adName,
    creativeId: patch.creativeId ?? existing?.creativeId,
    creativeName: patch.creativeName ?? existing?.creativeName,
    keywordId: patch.keywordId ?? existing?.keywordId,
    keyword: patch.keyword ?? existing?.keyword,
    network: patch.network ?? existing?.network,
    source: patch.source ?? existing?.source,
    medium: patch.medium ?? existing?.medium,
    campaign: patch.campaign ?? existing?.campaign,
    adGroup: patch.adGroup ?? existing?.adGroup,
    ad: patch.ad ?? existing?.ad,
    creative: patch.creative ?? existing?.creative,
    clickId: patch.clickId ?? existing?.clickId,
    attributedAt: patch.attributedAt ?? existing?.attributedAt,
    metadata: {...?existing?.metadata, ...patch.metadata},
  );
  _customAttributionSnapshot = merged;
  return merged;
}

void resetAttributionHelperState() {
  _customAttributionSnapshot = null;
}
