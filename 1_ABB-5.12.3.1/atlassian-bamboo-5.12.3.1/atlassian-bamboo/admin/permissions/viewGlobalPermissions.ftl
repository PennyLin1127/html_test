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

    [#if grantedUsers?has_content]
        <table class="aui permissions" id="configureGlobalUserPermissions">
            <thead>
                <tr>
                    <th>[@ww.text name='config.global.permissions.users' /]</th>
                    [#list editablePermissions.keySet() as key]
                        <th class="checkboxCell">[@ww.text name=key /]</th>
                    [/#list]
                </tr>
            </thead>
            [#list grantedUsers as user]
                [#if action.hasEditPermissionForUserName(user) ]
                    <tr>
                        <td>
                            [@permissions.displayUserForPermission grantedUsersDisplayNames user /]
                        </td>
                        [#list editablePermissions.keySet() as key]
                            [@permissionIndicator principal='${user}' type='user' permission=editablePermissions.get(key) /]
                        [/#list]
                    </tr>
                [/#if]
            [/#list]
        </table>
    [/#if]

    [#if grantedGroups?has_content]
        <table class="aui permissions" id="configureGlobalGroupPermissions">
            <thead>
                <tr>
                    <th>[@ww.text name='config.global.permissions.groups' /]</th>
                    [#list editablePermissions.keySet() as key]
                        <th class="checkboxCell">[@ww.text name=key /]</th>
                    [/#list]
                </tr>
            </thead>
            [#list grantedGroups as group]
                [#if action.hasEditPermissionForGroup(group) ]
                    <tr>
                        <td>${group}</td>
                        [#list editablePermissions.keySet() as key]
                            [@permissionIndicator principal='${group}' type='group' permission=editablePermissions.get(key) /]
                        [/#list]
                    </tr>
                [/#if]
            [/#list]
        </table>
    [/#if]

    <table class="aui permissions" id="configureGlobalOtherPermissions">
        <thead>
        <tr>
            <th>[@ww.text name='config.global.permissions.other' /]</th>
            [#list editablePermissions.keySet() as key]
                <th class="checkboxCell">[@ww.text name=key /]</th>
            [/#list]
        </tr>
        </thead>
        <tr>
            <td>[@ww.text name='config.global.permissions.logged.in.users' /]</td>
            [#list editablePermissions.keySet() as key]
                [#if editablePermissionsForLoggedInUsers.containsKey(key)]
                    [@permissionIndicator principal=loggedInUsersPrincipal type='role' permission=editablePermissions.get(key) /]
                [#else ]
                    <td></td>
                [/#if]
            [/#list]
        </tr>
        <tr>
            <td>[@ww.text name='config.global.permissions.anonymous.users' /]</td>
            [#list editablePermissions.keySet() as key]
                [#if editablePermissionsForAnonymousUsers.containsKey(key)]
                    [@permissionIndicator principal=anonymousUsersPrincipal type='role' permission=editablePermissions.get(key) /]
                [#else ]
                    <td></td>
                [/#if]
            [/#list]
        </tr>
    </table>

    <p>
        <a href="[@ww.url action='configureGlobalPermissions' namespace='/admin' method='view'/]" id="editPermissions" class="aui-button aui-button-primary">[@ww.text name='global.buttons.edit' /]</a>
    </p>


[#macro permissionIndicator principal permission type]
    [#assign fieldname='bambooPermission_${type}_${principal?html}_${permission}' /]
    [#assign granted=grantedPermissions.contains(fieldname) /]
    <td class="checkboxCell" id="${fieldname}">
        [#if granted]
            [@ui.icon type="tick" textKey="config.global.permissions.granted" /]
        [#else]
            [@ui.icon type="cross" textKey="config.global.permissions.notgranted" /]
        [/#if]
    </td>
[/#macro]

</body>
</html>
