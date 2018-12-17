[#-- @ftlvariable name="action" type="com.atlassian.bamboo.migration.cloud.actions.ExportFromCloudAction" --]
[#-- @ftlvariable name="" type="com.atlassian.bamboo.migration.cloud.actions.ExportFromCloudAction" --]
<html>
<head>
    <title>[@s.text name="admin.export.cloud.title"/]</title>
[#if action.exportFileAvailable]
    <meta name="decorator" content="exportCloud">
[#else]
    <meta name="decorator" content="admin">
[/#if]
    <meta name="adminCrumb" content="exportCloud"/>
</head>
<body>
[@ui.header pageKey="admin.export.cloud.title" descriptionKey="admin.export.cloud.description" /]

[@ww.url id="exportCloudUrl" action="exportCloud" namespace="/admin" /]
[@ww.url id="exportCloudStatusUrl" action="exportCloudStatus" namespace="/admin" /]

<script type="text/javascript">
    define('bamboo/export-cloud-status-poller', [
        'jquery'
    ], function(
        $
    ) {
        'use strict';

        var ExportCloudStatusPoller = function(opts) {
            var defaults = {
                requestUrl: '${exportCloudStatusUrl?js_string}',
                redirectUrl: '${exportCloudUrl?js_string}',
                initialState: null
            },
            options = $.extend(true, defaults, opts),
            refreshStatus = function() {
                $.ajax({
                           url: options.requestUrl,
                           type: 'get',
                           success: function(response) {
                               if (response.exportState != options.initialState) {
                                   window.location = options.redirectUrl;
                               }
                           },
                           //error access to server (restarts, network failed etc)
                           error: function(request, textStatus, errorThrown) {
                               console.log(textStatus);
                           }
                       }
                )
            };

            refreshStatus();
            setInterval(refreshStatus, 5000);
        };

        return ExportCloudStatusPoller;
    });
</script>


[@s.form action="performExportCloud" namespace="/admin"]
    [#if action.exportFileAvailable]
        [#if ctx.serverLifecycleState == "PAUSED"]
            <p>[@s.text name="admin.export.cloud.paused"/]</p>
        [/#if]
        <p>[@s.text name="admin.export.cloud.file.available"/]</p>
        <p>
            <a class="aui-button aui-button-primary"
               href="${req.contextPath}/cloudExportFile">[@s.text name="admin.export.cloud.download"]
                   [@s.param value=action.exportFileSize /]
               [/@s.text]</a>
            [@ww.url id="deleteCloudExportFile" action="deleteCloudExportFile" namespace="/admin" /]
            <a class="aui-button mutative"
               href="${deleteCloudExportFile}">[@s.text name="admin.export.cloud.delete"/]</a>
        </p>
    [#elseif action.exportInProgress]
        <p>[@s.text name="admin.export.cloud.progress" /]</p>
        <div class="aui-progress-indicator" style="margin-top:1em; width: 60%">
            <span class="aui-progress-indicator-value"></span>
        </div>
        <script type="text/javascript">
            require(['jquery', 'bamboo/export-cloud-status-poller'], function($, ExportCloudStatusPoller) {

                var exportCloudStatusPoller = new ExportCloudStatusPoller({initialState: 'IN_PROGRESS'});

            });
        </script>
    [#elseif action.pausingServer]
        <p>[@s.text name="admin.export.cloud.pausing" /]</p>
        <div class="aui-progress-indicator" style="margin-top:1em; width: 60%">
            <span class="aui-progress-indicator-value"></span>
        </div>
        <script type="text/javascript">
            require(['jquery', 'bamboo/export-cloud-status-poller'], function($, ExportCloudStatusPoller) {

                var exportCloudStatusPoller = new ExportCloudStatusPoller({initialState: 'PAUSING_SERVER'});

            });
        </script>
    [#else]
        [#if action.errorMessage??]
            [@ui.messageBox type="error" titleKey="admin.export.cloud.error"]
                <p>${action.errorMessage} [@s.text name="admin.export.cloud.error.contact.support"/]</p>
            [/@ui.messageBox]
        [/#if]
        <p>[@s.text name="admin.export.cloud.instruction1"/]</p>
        <p>[@s.text name="admin.export.cloud.instruction2"/]</p>
            [@s.password name="currentUserPassword" required=true labelKey="admin.export.cloud.password"/]
            [@s.password name="currentUserPasswordRepeat" required=true labelKey="admin.export.cloud.password.confirm"/]
            [#if action.exportArtifactsDisabled]
                [@ui.messageBox type='warning' ]
                    [@s.text name="admin.export.cloud.artifacts.export.disabled"]
                        [@s.param][@help.href pageKey="cloud.reduce.artifacts.size"/][/@s.param]
                    [/@s.text]
                [/@ui.messageBox]
            [#else ]
                [@s.checkbox name="exportArtifacts" labelKey="admin.export.cloud.artifacts.export" /]
            [/#if]
        <p>
            <button type="submit"
                    class="aui-button aui-button-primary mutative">[@s.text name="admin.export.cloud.export"/]</button>
        </p>
    [/#if]
[/@s.form]
</body>
</html>
