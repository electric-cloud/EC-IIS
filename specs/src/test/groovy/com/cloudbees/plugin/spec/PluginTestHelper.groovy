package com.cloudbees.plugin.spec

import com.electriccloud.spec.PluginSpockTestSupport

class PluginTestHelper extends PluginSpockTestSupport {
    static final String projectName = 'IIS Spec Tests'
    static def pluginName = "EC-IIS"
    static def iisIP = System.getenv("IIS_IP")
    static def iisPort = System.getenv("IIS_PORT")
    static def iisLogin = System.getenv("IIS_LOGIN")
    static def iisPassword = System.getenv("IIS_PASSWORD")

    static def procedureName = ""
    static String CONFIG_NAME = 'specConfig'


    def createConfig(configName) {
        createPluginConfiguration(pluginName, configName, [desc: "test configuration", checkConnection: "0"], iisLogin, iisPassword)
    }
    def createInvalidConfig(configName) {
        createPluginConfiguration(pluginName, configName, [desc: "test configuration", checkConnection: "0"], "wrong_admin", 'wrong_password')
    }

    String getEnvName() {
        return System.getenv("ROLLOUT_ENV_NAME") ?: "Production"
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

