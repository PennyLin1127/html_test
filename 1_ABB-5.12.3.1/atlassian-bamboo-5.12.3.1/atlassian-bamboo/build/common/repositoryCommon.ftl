[#-- @ftlvariable name="action" type="com.atlassian.bamboo.ww2.actions.build.admin.config.repository.EditRepository" --]
[#-- @ftlvariable name="" type="com.atlassian.bamboo.ww2.actions.build.admin.config.repository.EditRepository" --]
[#-- @ftlvariable name="uiConfigBean" type="com.atlassian.bamboo.ww2.actions.build.admin.create.UIConfigSupportImpl" --]
[#-- @ftlvariable name="repo" type="com.atlassian.bamboo.ww2.actions.build.admin.create.RepositoryOption" --]

[#macro basicRepositoryEdit repo plan=mutablePlan]
    [#assign repoCssClass][#if repo.group?has_content]global-repository-details[/#if][/#assign]
    [@ui.bambooSection dependsOn='selectedRepository' showOn=repo.key cssClass=repoCssClass!"" id='repository-edit-${repo.key}']
        [#if repo.group?has_content]
            [@ui.messageBox type="info" titleKey="repository.configuration"]
                [@ww.text name="repository.shared.edit"/]
                [#if fn.hasAdminPermission() || (fn.hasGlobalPermission("CREATE") && action.hasEntityPermission("READ", repo.repositoryData))]
                    [@ww.url id='editSharedRepositoryUrl' action='configureGlobalRepositories' namespace='/admin' repositoryId=repo.key /]
                    [#t]&nbsp;[@ww.text name="repository.shared.edit.admin"]
                        [@ww.param ]<a href="${editSharedRepositoryUrl}">[@ww.text name="repository.shared.edit.link"/]</a>[/@ww.param]
                    [/@ww.text]
                [/#if]
            [/@ui.messageBox]
            [@displayRepository repo.repositoryData plan false false true /]
        [#else]
            ${repo.repository.getEditHtml(buildConfiguration, plan)!}
            [#if repositoryUtils.isRepositoryTestConnectionAware(repo.repository)]
                [@testRepositoryConnectionButton id="test-connection-" + repo.repository.key?replace('[^a-zA-Z0-9]', '-', 'r') /]
            [/#if]
        [/#if]
    [/@ui.bambooSection]
[/#macro]

[#macro advancedRepositoryEdit selectedRepository='' plan=mutablePlan changeDetection=false globalRepository=false dependsOn='' showOn=true]
    [@ui.bambooSection titleKey='repository.advanced.option' dependsOn=dependsOn showOn=showOn collapsible=true isCollapsed=true]
        [#if globalRepository]
            [#list uiConfigBean.standaloneRepositories as repo]
                [#if !decorator?? || decorator != "nothing" || !selectedRepository?has_content || selectedRepository == repo.key]
                    [@ui.bambooSection dependsOn='selectedRepository' showOn=repo.key]
                    ${repo.getAdvancedEditHtml(buildConfiguration)!}
                    [/@ui.bambooSection]
                [/#if]
            [/#list]
        [#else]
            [#list uiConfigBean.repositories as repo]
                [#if !decorator?? || decorator != "nothing" || !selectedRepository?has_content || selectedRepository == repo.key]
                    [@ui.bambooSection dependsOn='selectedRepository' showOn=repo.key]
                    ${repo.getAdvancedEditHtml(buildConfiguration, plan)!}
                    [/@ui.bambooSection]
                [/#if]
            [/#list]
        [/#if]
        [@ui.bambooSection dependsOn='selectedRepository' showOn='__com.atlassian.bamboo.plugin.system.repository:cvs __nullRepository']
            [@ww.checkbox labelKey='repository.common.quietPeriod.enabled' toggle='true' name='repository.common.quietPeriod.enabled' /]
            [@ui.bambooSection dependsOn='repository.common.quietPeriod.enabled' showOn='true' ]
                [@ww.textfield labelKey='repository.common.quietPeriod.period' name='repository.common.quietPeriod.period' required=true /]
                [@ww.textfield labelKey='repository.common.quietPeriod.maxRetries' name='repository.common.quietPeriod.maxRetries' required=true /]
            [/@ui.bambooSection]
        [/@ui.bambooSection]

        [@ui.bambooSection dependsOn='selectedRepository' showOn='__nullRepository']
            [@ww.select labelKey='filter.pattern.option' name='filter.pattern.option' toggle='true'
            list=uiConfigBean.filterOptions listKey='name' listValue='label' uiSwitch='value']
            [/@ww.select]

            [@ui.bambooSection dependsOn='filter.pattern.option' showOn='regex']
                [@ww.textfield labelKey='filter.pattern.regex' name='filter.pattern.regex' /]
            [/@ui.bambooSection]
        [/@ui.bambooSection]

        [@ui.bambooSection dependsOn='selectedRepository' showOn='__nullRepository']
            [@ww.textfield labelKey="changeset.filter.pattern.regex" name="changeset.filter.pattern.regex" /]
        [/@ui.bambooSection]
        [@ui.bambooSection dependsOn='selectedRepository' showOn='__nullRepository']
            [@ww.select id="selectedWebRepositoryViewer" labelKey='webRepositoryViewer.type' name='selectedWebRepositoryViewer' toggle='true'
            list='uiConfigBean.webRepositoryViewers' listKey='key' listValue='name']
            [/@ww.select]
            [#list uiConfigBean.webRepositoryViewers as viewer]
                [#if viewer.getEditHtml(buildConfiguration, mutablePlan)!?has_content]
                    [@ui.bambooSection dependsOn='selectedWebRepositoryViewer' showOn=viewer.key]
                    ${viewer.getEditHtml(buildConfiguration, mutablePlan)!}
                    [/@ui.bambooSection]
                [/#if]
            [/#list]
        [/@ui.bambooSection]
        <script type="text/javascript">
            if (typeof AJS !== 'undefined') {
                AJS.$(function () {
                    var mutateSelectedWebRepo = function () {
                        BAMBOO.DynamicFieldParameters.mutateSelectListContent(
                            AJS.$(this), AJS.$('#selectedWebRepositoryViewer'),
                            AJS.$.parseJSON('${uiConfigBean.webRepositoryJson}')
                        );
                    };

                    var $selectedRepository = AJS.$('#selectedRepository');
                    $selectedRepository.on('change', mutateSelectedWebRepo);
                    mutateSelectedWebRepo.call($selectedRepository);
                });
            }
        </script>
    [/@ui.bambooSection]
[/#macro]

[#macro displayRepository repositoryData plan isCollapsed=false condensed=false globalRepository=false]
    [#if repositoryData??]
        [#assign repository = repositoryData.repository/]

        <div id="repository-[#if globalRepository]shared[/#if]-${repositoryData.id}" class="repository" data-key="${repositoryData.id}">
            [#if !condensed]
                [@ww.label labelKey='repository.type' value=repository.name /]
            [/#if]

            [#if uiConfigBean.requiresRepositoryDataOnView(repository)]
                ${repository.getViewHtml(repositoryData)!}
            [#elseif globalRepository]
                ${repository.getViewHtml()!}
            [#else]
                ${repository.getViewHtml(plan)!}
            [/#if]

            [#if !globalRepository]
                [@ww.label labelKey='repository.config.buildTrigger' value=repositoryData.buildTrigger?string /]
            [/#if]

            [#if !condensed]
                [#if plan?has_content]
                ${repository.getAdvancedViewHtml(plan)!}
                [#else]
                ${repository.getAdvancedViewHtml()!}
                [/#if]

                [#if repository.name != "CVS"]
                    [#if repository.quietPeriodEnabled]
                        [@ww.label labelKey='repository.common.quietPeriod.period' value=repository.quietPeriod! hideOnNull='true' /]
                        [@ww.label labelKey='repository.common.quietPeriod.maxRetries' value=repository.maxRetries! hideOnNull='true' /]
                    [/#if]
                [/#if]

                [#if repository.filterFilePatternOption?? && repository.filterFilePatternOption == 'includeOnly']
                    [#assign filterOptionDescription][@ww.text name='filter.pattern.option.includeOnly' /][/#assign]
                [#elseif repository.filterFilePatternOption?? && repository.filterFilePatternOption == 'excludeAll']
                    [#assign filterOptionDescription][@ww.text name='filter.pattern.option.excludeAll' /][/#assign]
                [#else]
                    [#assign filterOptionDescription='None' /]
                [/#if]

                [#if filterOptionDescription != 'None']
                    [@ww.label labelKey='filter.pattern.option' value=filterOptionDescription /]
                    [@ww.label labelKey='filter.pattern.regex' value=repository.filterFilePatternRegex hideOnNull='true' /]
                [/#if]
                [#if plan?has_content && repositoryData.webRepositoryViewer?has_content]
                ${repositoryData.webRepositoryViewer.getViewHtml(plan)!}
                [/#if]
            [/#if]
        </div>
    [/#if]
[/#macro]

[#macro viewGlobalRepositoryUsages planUsingRepository hiddenPlansUsingRepositoryCount environmentUsingRepository hiddenEnvironmentsUsingRepositoryCount]
<p>
    [#if planUsingRepository?has_content || hiddenPlansUsingRepositoryCount > 0]
                [@ww.text name="repository.shared.usages.header"/]
    <ul>
        [#list planUsingRepository as planIdentifier]
            <li>[@ui.renderPlanNameLink plan=planIdentifier /]</li>
        [/#list]
        [#if hiddenPlansUsingRepositoryCount > 0]
            <li>[@ww.text name="repository.shared.usages.plan.hidden" ][@ww.param value=hiddenPlansUsingRepositoryCount /][/@ww.text]</li>
        [/#if]
    </ul>
    [#else]
        [@ww.text name="repository.shared.noUses"/]
    [/#if]
</p>
<p>
    [#if environmentUsingRepository?has_content || hiddenEnvironmentsUsingRepositoryCount > 0 ]
                [@ww.text name="environment.repository.shared.usages.header"/]
    <ul>
        [#list environmentUsingRepository as environmentRepositoryLink]
            <li>[@ui.renderEnvironmentNameLink environmentRepositoryLink=environmentRepositoryLink /]</li>
        [/#list]
        [#if hiddenEnvironmentsUsingRepositoryCount > 0]
            <li>[@ww.text name="repository.shared.usages.env.hidden" ][@ww.param value=hiddenEnvironmentsUsingRepositoryCount /][/@ww.text]</li>
        [/#if]
    </ul>
    [#else]
        [@ww.text name="environment.repository.shared.noUses"/]
    [/#if]
</p>
[/#macro]

[#macro repositoryNewSelector repositoryOptions selectedRepository]
    <div id="repository-selector-new">
        <a id="repository-other" href="#repository-other-dropdown" aria-owns="repository-other-dropdown" aria-haspopup="true" class="aui-button aui-dropdown2-trigger aui-style-default">
            [@ww.text name="repository.type.select" /]
        </a>
        <div id="repository-other-dropdown" class="aui-dropdown2 aui-style-default">
            <div class="aui-dropdown2-section">
                <ul class="aui-list-truncate">
                    [#list repositoryOptions as repository]
                        <li class="option" data-key="${repository.key}">
                            <a href="#${repository.key}">${repository.name?html}</a>
                        </li>
                    [/#list]
                </ul>
            </div>
        </div>
    </div>
    <div id="repository-display-name" class="hidden">
        [@ww.textfield name="repositoryName" labelKey="plan.create.repository.name" required=true placeholderKey="plan.create.repository.placeholder" /]
    </div>
    <div id="repository-forms">
        [#list repositoryOptions as repo]
            <div id="repository-${repo.key}" class="repository hidden">
                [#if repo.repository.key == "nullRepository"]
                    <p>[@ww.text name="repository.none.label" /]</p>
                [#else]
                    <h4>${repo.repository.name} [@ww.text name="repository.details" /]</h4>
                [/#if]
                ${repo.repository.getMinimalEditHtml(buildConfiguration)!}
                [#if repositoryUtils.isRepositoryTestConnectionAware(repo.repository)]
                    [@testRepositoryConnectionButton id="test-connection-" + repo.repository.key?replace('[^a-zA-Z0-9]', '-', 'r') /]
                [/#if]
            </div>
        [/#list]
    </div>
    [#if fn.hasAdminPermission() || fn.hasGlobalPermission('CREATEREPOSITORY')]
        <div id="repository-access-option" class="hidden">
            [@s.radio
                labelKey = 'repository.shared.access'
                name = 'linkedRepositoryAccessOption'
                list = uiConfigBean.linkedRepositoryAccessOptions
                i18nPrefixForValue="repository.shared.access"
                skipGroupCssClass = true
            /]
        </div>
    [/#if]
    <script type="text/javascript">
        require(['jquery', 'widget/repository-selector-new'], function($, RepositorySelectorNew){
            return new RepositorySelectorNew({
                el: $('#repository-selector-new')
            });
        });
    </script>
[/#macro]

[#macro repositoryLinkedSelector linkedRepositories selectedRepository createPlan=false]
    <div id="repository-selector-linked">
        <select id="sharedRepoSelect">
            [#list linkedRepositories as repo]
                <option value="${repo.key}" data-repo-name="${repo.name?html}" [#if selectedRepository?has_content && selectedRepository == repo.key]selected[/#if]>${repo.name?html}</option>
            [/#list]
        </select>
        [#if !createPlan]
            <div class="repository-options">
                [#list linkedRepositories as repo]
                    [@displayRepository repo.repositoryData "" false false true /]
                [/#list]
            </div>
        [/#if]
    </div>
    <script type="text/javascript">
        require(['jquery', 'widget/repository-selector-linked'], function($, RepositorySelectorLinked){
            return new RepositorySelectorLinked({
                el: $('#repository-selector-linked'),
                params: {
                    placeholder: '[@ww.text name='repository.linked.label' /]'
                }
            });
        });
    </script>
[/#macro]

[#macro repositorySelector repositoryOptions linkedRepositories repositoryTypeOption selectedRepository="" hasCreateRepoPermission=true]
    <div id="repository-selector">
        <div class="group">
            [@ww.label labelKey="repository.type" escape="false" required=true]
                [@ww.param name="value"]
                    [@ww.hidden id="selectedRepository" name="selectedRepository"
                        value=selectedRepository cssClass="handleOnSelectShowHide handleDynamicDescription"
                    /]
                    <div class="aui-group">
                        <div class="aui-item">
                            [#if linkedRepositories?has_content]
                                <div class="radio [#if !hasCreateRepoPermission?has_content]single[/#if]">
                                    <input
                                        id="repositoryTypeLinkedOption" name="repositoryTypeOption"
                                        class="radio handleOnSelectShowHide" type="radio" value="LINKED" autocomplete="off"
                                        [#if repositoryTypeOption == "LINKED"]checked="checked"[/#if]
                                    >
                                    <label for="repositoryTypeLinkedOption">[@ww.text name="repository.type.linked.label" /]</label>
                                    [@ui.bambooSection dependsOn='repositoryTypeOption' showOn='LINKED']
                                        [@repositoryLinkedSelector linkedRepositories selectedRepository true /]
                                    [/@ui.bambooSection]
                                </div>
                            [/#if]
                            [#if hasCreateRepoPermission]
                                <div class="radio [#if !linkedRepositories?has_content]single[/#if]">
                                    <input
                                        id="repositoryTypeCreateOption" name="repositoryTypeOption"
                                        class="radio handleOnSelectShowHide" type="radio" value="NEW" autocomplete="off"
                                        [#if repositoryTypeOption == "NEW"]checked="checked"[/#if]
                                    >
                                    <label for="repositoryTypeCreateOption">[@ww.text name="repository.type.create.label" /]</label>
                                    [@ui.bambooSection dependsOn='repositoryTypeOption' showOn='NEW' cssClass="repository-section"]
                                        [@repositoryNewSelector repositoryOptions selectedRepository/]
                                    [/@ui.bambooSection]
                                    [#if (fieldErrors["selectedRepository"])?has_content]
                                        [#list fieldErrors["selectedRepository"] as error]
                                            <div class="error control-form-error">${error?html}</div>
                                        [/#list]
                                    [/#if]
                                </div>
                            [/#if]
                        </div>
                    </div>
                [/@ww.param]
            [/@ww.label]
        </div>
    </div>
    <script type="text/javascript">
        require(['jquery', 'widget/repository-selector'], function($, RepositorySelector){
            return new RepositorySelector({
                el: AJS.$('#repository-selector')
            });
        });
    </script>
[/#macro]

[#macro testRepositoryConnectionButton id]
    <div class="field-group">
        <div class="test-repository-connection-container">
            <button class="aui-button test-repository-connection" id="${id}">
                [@s.text name="repository.test.connection" /]
            </button>
            <script type="text/javascript">
                require(['jquery', 'feature/repository-connect'], function($, RepositoryConnect) {
                    new RepositoryConnect({ el: $('#' + '${id}') });
                });
            </script>
        </div>
    </div>
[/#macro]
