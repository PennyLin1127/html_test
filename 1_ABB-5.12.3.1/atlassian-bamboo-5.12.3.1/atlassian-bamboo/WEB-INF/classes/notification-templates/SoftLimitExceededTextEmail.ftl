[#-- @ftlvariable name="baseUrl" type="java.lang.String" --][#lt/]
[#-- @ftlvariable name="applicationHost" type="java.lang.String" --][#lt/]
[#-- @ftlvariable name="storageLimits" type="com.atlassian.bamboo.configuration.StorageLimits" --][#lt/]
[#-- @ftlvariable name="atlassianAgentsEnabled" type="java.lang.Boolean" --][#lt/]
[#include "notificationCommonsText.ftl"][#lt/]
[#assign configurationUrl = baseUrl + '/admin/configureArtifactStorage.action' /][#lt/]
[#assign headline = i18n.getText("storage.capping.warning.email.soft.limit.header", [applicationHost]) /][#lt/]
[#assign policyUrl = i18n.getText('help.cloud.storage.policy') /][#lt/]
[#assign policyLink]${i18n.getText("storage.capping.warning.email.link.cloud.storage.policy")}: ${policyUrl}[/#assign][#lt/]
[@notificationTitleText title=headline /]
${i18n.getText("storage.capping.warning.email.soft.limit.body.part1", [storageLimits.hardLimit])}
[#if atlassianAgentsEnabled=true]
    ${i18n.getText("storage.capping.warning.email.soft.limit.body.part2.aa")}
[#else]
    ${i18n.getText("storage.capping.warning.email.soft.limit.body.part2")}
[/#if]
[#if atlassianAgentsEnabled != true]
    ${i18n.getText("storage.capping.warning.email.link.configure.storage")}: ${configurationUrl}
[/#if]
${i18n.getText("storage.capping.warning.email.soft.limit.body.part3")} ${i18n.getText("storage.capping.warning.email.soft.limit.body.part4", [policyLink])}

${i18n.getText("storage.capping.warning.email.soft.limit.body.part5")}
[@showEmailFooter /]
