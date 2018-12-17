[#-- @ftlvariable name="action" type="com.atlassian.bamboo.configuration.ConfigureGlobalPermissions" --]
[#-- @ftlvariable name="" type="com.atlassian.bamboo.configuration.ConfigureGlobalPermissions" --]

[#import "/fragments/permissions/permissions.ftl" as permissions/]

<html>
<head>
    <title>[@ww.text name='config.global.permissions.title' /]</title>
    <meta name="decorator" content="adminpage">
    <meta name="adminCrumb" content="configureGlobalPermissions">
</head>
<body>
[@ui.header pageKey='config.global.permissions.heading' descriptionKey='config.global.permissions.description' /]

<div class="aui-group permissionForm">
    <div class="aui-item formArea">
        [@ww.form action='configureGlobalPermissions' submitLabelKey='global.buttons.update' titleKey='config.global.permissions.title' id='permissions' cancelUri='/admin/viewGlobalPermissions.action' cssClass='top-label']
            [@permissions.permissionsEditor entityId=securedDomainObject.id
                editablePermissions=editablePermissions/]
        [/@ww.form]
    </div>
    <div class="aui-item helpTextArea">
        <h3 class="helpTextHeading">[@ww.text name='config.global.permissions.permission.types' /]</h3>
        <ul>
            [#list editablePermissions.keySet() as key]
                <li><strong>[@ww.text name=key /]</strong> - [@ww.text name='${key}.description' /]</li>
            [/#list]
        </ul>
    </div>
</div>
</body>
</html>


