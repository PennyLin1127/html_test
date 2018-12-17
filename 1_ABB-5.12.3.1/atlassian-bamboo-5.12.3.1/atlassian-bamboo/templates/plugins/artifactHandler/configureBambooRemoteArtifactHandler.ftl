[#if ctx.isOnDemandInstance()]
    [#import "/templates/plugins/artifactHandler/artifactHandlerCommon.ftl" as artifactHandlerCommon]

    [@ui.bambooSection titleKey="admin.artifactstorage.local.header"]
        ${i18n.getText("admin.artifactstorage.local.description")}
    [/@ui.bambooSection]
    [#--this part is used in different contexts, so these fields can be not provided by action--]

    [#if ctx.featureManager.onDemandInstance ]
        [#if context.get(pluginModuleConfigurationPrefix+':takenSpaceInGb')??]
            [#assign takenSpaceInGb = context.get(pluginModuleConfigurationPrefix+':takenSpaceInGb')]
        [#else]
            [#assign takenSpaceInGb = 0]
        [/#if]
        [#if context.get(pluginModuleConfigurationPrefix+':upperLimitInGb')??]
            [#assign upperLimitInGb = context.get(pluginModuleConfigurationPrefix+':upperLimitInGb')]
        [#else]
            [#assign upperLimitInGb = 1]
        [/#if]

        [@artifactHandlerCommon.storageUsageProgressBar usedSpaceInGb=takenSpaceInGb upperLimitInGb=upperLimitInGb/]
    [/#if]
[/#if]
