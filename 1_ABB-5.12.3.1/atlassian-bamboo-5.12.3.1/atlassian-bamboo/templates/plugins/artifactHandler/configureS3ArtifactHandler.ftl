[#-- @ftlvariable name="pluginModuleConfigurationPrefix" type="java.lang.String" --]

[#assign bucketNameHelpDialogContent]
    [@ww.text name='elastic.configure.field.bucketName.info']
        [@ww.param][@help.href pageKey="help.s3.artifact.storage.configuration"/][/@ww.param]
    [/@ww.text]
[/#assign]

[#if ctx.isOnDemandInstance()]
    [@ui.bambooSection titleKey="admin.artifactstorage.s3.header" cssClass="artifact-storage-details"]
        [@ww.text name="admin.artifactstorage.s3.description"/]
    [/@ui.bambooSection]
[/#if]

[#if fieldErrors.get(pluginModuleConfigurationPrefix + ':')?has_content]
    [#list fieldErrors.get(pluginModuleConfigurationPrefix + ':') as error]
        [@ui.messageBox type='warning' content=error/]
    [/#list]
[/#if]
[#if ec2Configured!]
    [@s.radio key='admin.artifactstorage.s3.aws.credentials.source'
        name=pluginModuleConfigurationPrefix+':credentialsSource'
        listKey="key"
        listValue="value"
        toggle="true"
        list=context.get(pluginModuleConfigurationPrefix+':credentialsSourceList')]
    [/@s.radio]
[#else]
    [@s.hidden key='admin.artifactstorage.s3.aws.credentials.source' value='custom'/]
[/#if]

[@ui.bambooSection dependsOn=pluginModuleConfigurationPrefix+':credentialsSource' showOn='custom']
    [@s.textfield key='elastic.configure.aws.field.accessKeyId' name=pluginModuleConfigurationPrefix+':accessKeyId' required=true/]
    [#if context.get(pluginModuleConfigurationPrefix+':secretAccessKey')?has_content]
        [@s.checkbox key='elastic.configure.aws.field.secretAccessKey.change' toggle='true' name=pluginModuleConfigurationPrefix+':awsSecretAccessKeyChange' /]
        [@ui.bambooSection dependsOn=pluginModuleConfigurationPrefix+':awsSecretAccessKeyChange']
            [@s.password key='elastic.configure.aws.field.secretAccessKey' name=pluginModuleConfigurationPrefix+':secretAccessKey' required=true/]
        [/@ui.bambooSection]
    [#else]
        [@s.hidden key='elastic.configure.aws.field.secretAccessKey.change' value='true' name=pluginModuleConfigurationPrefix+':awsSecretAccessKeyChange' /]
        [@s.password key='elastic.configure.aws.field.secretAccessKey' name=pluginModuleConfigurationPrefix+':secretAccessKey' required=true/]
    [/#if]
    [@ww.select labelKey='elastic.configure.aws.field.region' name=pluginModuleConfigurationPrefix+':region'
        list=context.get("availableRegions") listKey='name()'
        listValue='displayName' /]
[/@ui.bambooSection]

[@s.textfield
    key='elastic.configure.field.bucketName'
    name=pluginModuleConfigurationPrefix+':bucketName'
    required=true
    cssClass='long-field'
    maxLength="${context.get(pluginModuleConfigurationPrefix+':bucketNameMaxLength')}"
    helpDialog=bucketNameHelpDialogContent
    helpIconCssClass='aui-iconfont-info'
/]
[@s.textfield key='elastic.configure.field.bucketPath' name=pluginModuleConfigurationPrefix+':bucketPath'/]
[@s.textfield key="admin.artifactstorage.s3.maxArtifactFileCount" descriptionKey="admin.artifactstorage.s3.maxArtifactFileCount.description" name=pluginModuleConfigurationPrefix + ':maxArtifactFileCount'/]
