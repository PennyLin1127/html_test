[#-- @ftlvariable name="action" type="com.atlassian.bamboo.configuration.repository.EditGlobalRepository" --]
[#-- @ftlvariable name="" type="com.atlassian.bamboo.configuration.repository.EditGlobalRepository" --]
[#-- snippet displayed in repository config right panel --]
    <html>
<head>
[@ui.header pageKey="sharedRepositories.edit.title" title=true/]
    <meta name="decorator" content="linkedRepository">
</head>
<body>
[#import "/build/common/repositoryCommon.ftl" as rc/]
<h2>
    [#if repositoryDashboardOn]
        [#if repositoryId > 0]
            [@ww.text name="repository.shared.edit.title" /]
        [#else]
            [@ww.text name="vcs.create.new.title" /]
        [/#if]

        <div class="aui-toolbar inline share-repository-toolbar">
            <ul class="toolbar-group">
                <li class="toolbar-item">
                    <a class="viewRepositoryUsagesTrigger toolbar-trigger"
                            href="[@ww.url action='viewPlansUsingGlobalRepository' namespace='/admin' repositoryId=repositoryId /]">
                        [@ww.text name="repository.shared.view.usages"/]
                    </a>
                </li>
                <li class="toolbar-item">
                    <a class="toolbar-trigger repositoryTools"
                            href="[@ww.url action='configureGlobalRepositoryPermissions' namespace='/admin' repositoryId=repositoryId /]">
                        [@ww.text name="repository.shared.permissions.edit"/]
                    </a>
                </li>
            </ul>
        </div>
    [/#if]

</h2>

[#if successMessage?has_content]
    [@ui.messageBox type="success" title=successMessage?html /]
[/#if]

[#assign cancelUri][#if repositoryDashboardOn]/vcs/viewAllRepositories.action[#else]/admin/editGlobalRepository.action[/#if][/#assign]

[@ww.form  action=submitAction
    method='POST'
    enctype='multipart/form-data'
    namespace="/admin"
    submitLabelKey="repository.update.button"
    cancelUri=cancelUri
]

    [@ww.hidden name="repositoryId" value=repositoryId /]
    [@ww.hidden name="repositoryType" value=selectedRepository /]

    [#if !repositoryDashboardOn && repositoryId > 0]
    <div class="aui-toolbar inline share-repository-toolbar">
        <ul class="toolbar-group">
            <li class="toolbar-item">
                <a class="viewRepositoryUsagesTrigger toolbar-trigger"
                        href="[@ww.url action='viewPlansUsingGlobalRepository' namespace='/admin' repositoryId=repositoryId /]">
                    [@ww.text name="repository.shared.view.usages"/]
                </a>
            </li>
            <li class="toolbar-item">
                <a class="toolbar-trigger repositoryTools"
                        href="[@ww.url action='configureGlobalRepositoryPermissions' namespace='/admin' repositoryId=repositoryId /]">
                    [@ww.text name="repository.shared.permissions.edit"/]
                </a>
            </li>
        </ul>
    </div>
    [/#if]

    [@dj.simpleDialogForm
        triggerSelector="#viewPlansTrigger_${repositoryId}"
        width=600
        height=300
        headerKey="repository.shared.view.usages"/]

    [@ww.select labelKey='repository.type'
        name='selectedRepository'
        id="selectedRepository"
        toggle='true'
        list=uiConfigBean.standaloneRepositories
        listKey='key'
        listValue='name'
        optionDescription='optionDescription']
    [/@ww.select]

    [@ui.bambooSection id='repository-id']
        [@ww.textfield labelKey="repository.name" name="repositoryName" id="repositoryName" maxlength="${repositoryNameMaxLength}" required=true/]
    [/@ui.bambooSection]

    [@ui.bambooSection id='repository-configuration']
        [#list uiConfigBean.standaloneRepositories as repo]
            [#if !decorator?? || decorator != "nothing" || !selectedRepository?has_content || selectedRepository == repo.key]
                [@ui.bambooSection dependsOn='selectedRepository' showOn=repo.key id='repository-edit-${repo.key}']
                    ${repo.getEditHtml(buildConfiguration)!}
                    [#if repositoryUtils.isRepositoryTestConnectionAware(repo)]
                        [@rc.testRepositoryConnectionButton id="test-connection-" + repo.key?replace('[^a-zA-Z0-9]', '-', 'r') /]
                    [/#if]
                [/@ui.bambooSection]
            [/#if]
        [/#list]

        [@rc.advancedRepositoryEdit
            selectedRepository=selectedRepository plan=''
            changeDetection=false globalRepository=true
        /]

        <script type="text/javascript">
            require = window.require || window.parent.require;
            require(['jquery', 'util/events'], function($, events){
                $(function () {
                    // manually trigger selector change event
                    var $selectedRepository = $('#selectedRepository').find(":selected");

                    events.EventBus.trigger(
                        'repository:selector:change', {}, 'NEW', $selectedRepository.val()
                    );
                });
            });
        </script>
    [/@ui.bambooSection]
[/@ww.form]

<script type="text/javascript">
    BAMBOO.REPOSITORY.viewUsages.init({
                                          labelsDialog: {
                                              header: "[@ww.text name='repository.shared.view.usages' /]"
                                          }
                                      });
</script>

</body>