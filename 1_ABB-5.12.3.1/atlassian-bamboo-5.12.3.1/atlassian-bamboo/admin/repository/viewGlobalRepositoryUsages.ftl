[#-- @ftlvariable name="" type="com.atlassian.bamboo.configuration.repository.ConfigureGlobalRepositories" --]

<html>
<head>
[@ui.header pageKey=title title=true/]
    <meta name="decorator" content="linkedRepository">
</head>
<body>
[#import "/build/common/repositoryCommon.ftl" as rc]

[@ww.form id='viewRepositoryUsagesForm'
    action='editGlobalRepository'
    submitLabelKey='global.buttons.close']
    [@ww.hidden name="repositoryId" value=repositoryId/]

    [@rc.viewGlobalRepositoryUsages planUsingRepository hiddenPlansUsingRepositoryCount environmentUsingRepository hiddenEnvironmentsUsingRepositoryCount/]
[/@ww.form]
</body>