[#-- @ftlvariable name="" type="com.atlassian.bamboo.configuration.agent.atlassian.ViewAtlassianAgent" --]
[#-- @ftlvariable name="action" type="com.atlassian.bamboo.configuration.agent.atlassian.ViewAtlassianAgent" --]

[#import "/agent/commonAgentFunctions.ftl" as agt]
[#import "/admin/elastic/commonElasticFunctions.ftl" as ela]
<html>
<head>
    <title>
        [@ww.text name='agent.view.heading'/]
    </title>
    <meta name="decorator" content="adminpage">
    <meta name="adminCrumb" content="agentsConfig">
</head>
<body>
    <h2>[@ww.text name='agent.atlassian.details.title' /]</h2>
    <p>[@ww.text name='agents.description' /]</p>
    [#if agentStatus == 'RUNNING']
        <div class="agent-info form-view">
            [@ww.label labelKey='agent.atlassian.details.image' showDescription=true escape=false]
                [@ww.param name='value']<strong>${imageName}</strong>[/@ww.param]
            [/@ww.label]
        </div>
        <div class="agent-tab-container">
            [#assign tabs=[action.getText('elastic.instance.access.tab'), action.getText('elastic.image.capabilities'),action.getText('system.info.title')] /]
            [#assign image=agent.elasticImageConfiguration]

            [@dj.tabContainer headings=tabs selectedTab=selectedTab!]
                [@dj.contentPane labelKey='elastic.instance.access.tab']
                    [@ui.bambooPanel]
                        [@s.url id='pkFileUrl' namespace='/admin/elastic' action='getPkFile'/]
                        [#assign pkHttpLinkAndLocalLocation='<a href="${pkFileUrl}">${unvalidatedPkLocation}</a>' /]
                        [@ela.sshAccess sshAccessEnabled pkHttpLinkAndLocalLocation hostname /]
                    [/@ui.bambooPanel]
                [/@dj.contentPane]

                [@dj.contentPane labelKey='elastic.image.capabilities']
                    [@agt.capabilitiesElasticAgent capabilitySet capabilitySetDecorator /]
                [/@dj.contentPane]

                [@dj.contentPane labelKey='system.info.title']
                    [@agt.systemInfoAgent systemInfo=systemInfo /]
                [/@dj.contentPane]
            [/@dj.tabContainer]
        </div>
    [#elseif agentStatus == 'STARTING']
        <div class="atlassian-agent-status starting">
            <div class="illustration"></div>
            <div class="description">
                <h4>[@ww.text name='agent.atlassian.starting.title' /]</h4>
                <p>[@ww.text name='agent.atlassian.starting.description' /]</p>
            </div>
        </div>
    [#else]
        <div class="atlassian-agent-status offline">
            <div class="illustration"></div>
            <div class="description">
                <h4>[@ww.text name='agent.atlassian.offline.title' /]</h4>
                <p>[@ww.text name='agent.atlassian.offline.description']
                     [@ww.param]<a href="${req.contextPath}/allPlans.action">[/@ww.param]
                     [@ww.param]</a>[/@ww.param]
                   [/@ww.text]
                 </p>
            </div>
        </div>
    [/#if]
</body>
</html>