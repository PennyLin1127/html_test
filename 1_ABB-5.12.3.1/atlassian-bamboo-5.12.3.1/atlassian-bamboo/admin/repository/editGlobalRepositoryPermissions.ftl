[#-- @ftlvariable name="" type="com.atlassian.bamboo.configuration.repository.ConfigureGlobalRepositoryPermissions" --]
[#-- @ftlvariable name="action" type="com.atlassian.bamboo.configuration.repository.ConfigureGlobalRepositoryPermissions" --]

[#import "/fragments/permissions/permissions.ftl" as permissions/]

[@ww.text id="title" name="repository.shared.edit.permissions.title"]
    [@ww.param][#if repositoryData??]${repositoryData.name?html}[#else]Unknown[/#if][/@ww.param]
[/@ww.text]
<html>
<head>
    [@ui.header page=title title=true/]
    <meta name="decorator" content="linkedRepository">
</head>
<body>
[@ui.header page=title descriptionKey="repository.shared.edit.permissions.description"/]
[#if repositoryDashboardOn]
    [@ww.url id="cancelUri" namespace='admin/repository' action="editGlobalRepository"  repositoryId=repositoryId/]
[#else]
    [@ww.url id="cancelUri" namespace='admin' action="configureGlobalRepositories"  repositoryId=repositoryId/]
[/#if]

[@ww.form action='updateGlobalRepositoryPermissions' submitLabelKey='global.buttons.update' id='permissions' cancelUri='${cancelUri}' cssClass='top-label']
    [@permissions.permissionsEditor entityId=repositoryId anonymousAllowed=false editablePermissions=editablePermissions /]
    [@ww.hidden name='repositoryId' /]
[/@ww.form]
</body>
</html>
