[#-- @ftlvariable name="action" type="com.atlassian.bamboo.configuration.repository.DeleteGlobalRepository" --]
[#-- @ftlvariable name="" type="com.atlassian.bamboo.configuration.repository.DeleteGlobalRepository" --]
<html>
<head>
[@ui.header pageKey=title title=true/]
    <meta name="decorator" content="linkedRepository">
</head>
<body>
[#assign cancelUri][#if repositoryDashboardOn]/vcs/viewAllRepositories.action[#else]/admin/configureGlobalRepositories.action[/#if][/#assign]

[@ww.form   action="deleteGlobalRepository"
namespace="/admin"
submitLabelKey="global.buttons.delete"
cancelUri=cancelUri]

    [@ui.messageBox type="warning" titleKey="repository.delete.confirm" /]

    [#import "/build/common/repositoryCommon.ftl" as rc]
    [@rc.viewGlobalRepositoryUsages planUsingRepository hiddenPlansUsingRepositoryCount environmentUsingRepository hiddenEnvironmentsUsingRepositoryCount /]
    [@ww.hidden name="createRepositoryKey"/]
    [@ww.hidden name="repositoryId"/]
[/@ww.form]
</body>