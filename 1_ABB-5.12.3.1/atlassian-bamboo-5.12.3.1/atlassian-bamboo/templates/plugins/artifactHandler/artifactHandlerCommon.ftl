[#macro displayArtifactHandlerEnableDisableTable artifactHandlerDescriptors]
<table class="aui">
    <thead>
    <tr>
        <th>Artifact handler name</th>
        <th class="checkboxCell">Enabled for shared artifacts</th>
        <th class="checkboxCell">Enabled for non-shared artifacts</th>
    </tr>
    </thead>
<tbody>
[#list artifactHandlerDescriptors as artifactHandlerDescriptor]
    <tr>
        <td>${artifactHandlerDescriptor.name}</td>
        <td class="checkboxCell">[@s.checkbox name='${artifactHandlerDescriptor.configurationPrefix}:enabledForShared' theme='simple'/]</td>
        <td class="checkboxCell">[@s.checkbox name='${artifactHandlerDescriptor.configurationPrefix}:enabledForNonShared' theme='simple'/]</td>
    </tr>
[/#list]
</tbody>
</table>
[/#macro]

[#--this macro can only be used once on every page--]
[#macro storageUsageProgressBar usedSpaceInGb upperLimitInGb]
    [#assign leftSpace = upperLimitInGb - usedSpaceInGb]
    [#if leftSpace < 0]
        [#assign leftSpace = 0]
    [/#if]
    [#if upperLimitInGb == 0]
        [#assign usedCapacity = 1]
    [#else]
        [#assign usedCapacity = usedSpaceInGb/upperLimitInGb]
    [/#if]

    [#if usedCapacity > 1]
        [#assign usedCapacity = 1]
    [/#if]
    <div id="storageCapacityProgress"></div>
    <table id="spaceUsage">
        <tr>
            <td width="30%">
                <div class="usedSpaceCircle [#if usedCapacity==1]error[/#if]"></div>
                <span id="usedSpace">${i18n.getText('admin.artifactstorage.local.used', [usedSpaceInGb?string['0.#']!0])}</span>
            </td>
            <td width="30%">
                <div class="leftSpaceCircle"></div>
                <span id="leftSpace">${i18n.getText('admin.artifactstorage.local.left', [leftSpace?string['0.#']!'25'])}</span>
            </td>
            <td width="40%" style="text-align: right">
                <strong>${i18n.getText('admin.artifactstorage.local.total', [upperLimitInGb?string['0.#']!'25'])}</strong>
            </td>
        </tr>
    </table>

    <script type="text/javascript">
        require(['jquery', 'widget/progress-bar', 'page/artifact-storage-config'], function($, ProgressBar, ArtifactStorageConfig) {
            new ProgressBar({
                el: "#storageCapacityProgress",
                value: +(${usedCapacity})
            });
            [#if usedCapacity == 1 && selectedArtifactStorage == 'com.atlassian.bamboo.plugin.artifact.handler.remote:BambooRemoteArtifactHandler']
                return new ArtifactStorageConfig({
                    target: '#selectedArtifactStorage'
                });
            [/#if]
        });
</script>
[/#macro]