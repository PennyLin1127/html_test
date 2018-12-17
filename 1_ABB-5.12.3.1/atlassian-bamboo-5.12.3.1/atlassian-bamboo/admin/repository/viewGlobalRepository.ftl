[#-- @ftlvariable name="action" type="com.atlassian.bamboo.configuration.repository.ViewGlobalRepository" --]
[#-- @ftlvariable name="" type="com.atlassian.bamboo.configuration.repository.ViewGlobalRepository" --]
[#import "/build/common/repositoryCommon.ftl" as rc]

[#assign viewRepositoryHeaderText]
[@ww.text name="repository.details.title"]
    [@ww.param][#if repositoryData??]${repositoryData.name}[/#if][/@ww.param]
[/@ww.text]
[/#assign]

<html>
<head>
[@ui.header page=viewRepositoryHeaderText title=true/]
    <meta name="decorator" content="linkedRepository">
</head>
<body>
<h2>
    ${viewRepositoryHeaderText}
</h2>

[@ww.form action="viewAllRepositories"
    method='GET'
    namespace="/vcs"
    submitLabelKey="global.buttons.close"]
    [#if repositoryData??]
        [@rc.displayRepository repositoryData=repositoryData plan="" isCollapsed=false condensed=false globalRepository=true /]
    [#else]

    [/#if]
[/@ww.form]
<body>
