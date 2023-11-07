package com.cloudbees.plugin.spec

import com.electriccloud.spec.PluginSpockTestSupport
import com.cloudbees.pdk.hen.*

class PluginTestHelper extends PluginSpockTestSupport {
    static ServerHandler serverHandler = ServerHandler.getInstance()

    static final String projectName = 'IIS Spec Tests'
    static def pluginName = "EC-IIS"
    static def iisIP = Utils.env("IIS_IP")
    static def iisPort = Utils.env("IIS_PORT", "80")
    static def iisLogin = Utils.env("IIS_LOGIN")
    static def iisPassword = Utils.env("IIS_PASSWORD")

    def createCustomConfig(configName, userName, password) {
        createPluginConfiguration(pluginName, configName, [desc: "test configuration", checkConnection: "0"], userName, password)
    }

    def createConfig(configName = 'specConfig') {
        createCustomConfig(configName, iisLogin, iisPassword)
    }

    static private void createTestResource(String resourceName) {
        ServerHandler.getInstance().setupResource(resourceName, iisIP, 7800)
    }

    def getStepSummary(def jobId, def stepName) {
        assert jobId
        def summary
        def property = "/myJob/jobSteps/RunProcedure/steps/$stepName/summary"
        try {
            summary = getJobProperty(property, jobId)
        } catch (Throwable e) {
            logger.debug("Can't retrieve Upper Step Summary from the property: '$property'; check job: " + jobId)
        }
        return summary
    }

    List<Map> getFormalParameterOptions(String pluginName, String procedureName, String parameterName, Map actualParameters) {
        String params = actualParameters.collect {k, v -> "$k: '$v'"}.join(",")
        String script = """
getFormalParameterOptions formalParameterName: '$parameterName',
    projectName: '/plugins/$pluginName/project',
    procedureName: '$procedureName',
    actualParameter: [$params]
            """
        def formalParameterOptions = dsl(script)?.option
        return formalParameterOptions
    }

}

