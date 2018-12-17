[#-- @ftlvariable name="action" type="com.atlassian.bamboo.configuration.agent.atlassian.ConfigureAtlassianAgentsStorage" --]
[#-- @ftlvariable name="" type="com.atlassian.bamboo.configuration.agent.atlassian.ConfigureAtlassianAgentsStorage" --]
[#import "/templates/plugins/artifactHandler/artifactHandlerCommon.ftl" as artifactHandlerCommon]

<html>
    <head>
        [@ui.header pageKey='webitems.system.admin.build.artifactStorage' title=true /]
        <meta name="decorator" content="adminpage">
        <meta name="adminCrumb" content="configureArtifactStorage">
    </head>
    <body>
        [@ui.header pageKey='webitems.system.admin.build.artifactStorage' /]
        <p>
            [@ww.text name="agent.atlassian.storage.description"]
                [@ww.param name="value"][@help.staticUrl pageKey="help.cloud.storage.policy"][@ww.text name="agent.atlassian.storage.policy" /][/@help.staticUrl][/@ww.param]
            [/@ww.text]
        </p>

        <h3>[@ww.text name='agent.atlassian.storage.usage.title' /]</h3>
        [@artifactHandlerCommon.storageUsageProgressBar usedSpaceInGb=usedSpaceInGb upperLimitInGb=upperLimitInGb/]
    </body>
</html>