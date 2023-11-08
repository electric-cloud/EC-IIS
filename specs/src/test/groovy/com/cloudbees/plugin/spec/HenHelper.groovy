package com.cloudbees.plugin.spec

import com.electriccloud.spec.PluginSpockTestSupport
import com.cloudbees.pdk.hen.*
import groovy.util.logging.Slf4j
import spock.lang.Ignore
import spock.lang.Specification

@Ignore
@Slf4j
class HenHelper extends Specification {
    static ServerHandler serverHandler = ServerHandler.getInstance()
    static RunOptions runOpts = new RunOptions()
    static String agentOs = "windows"

    static String cdFlowProjectName = "IIS Spec Tests"

    static def pluginName = "EC-IIS"
    static def iisIP = Utils.env("IIS_IP")
    static def iisPort = Utils.env("IIS_PORT", "80")
    static def iisLogin = Utils.env("IIS_LOGIN")
    static def iisPassword = Utils.env("IIS_PASSWORD")

    static String getTmp() {
        if (agentOs == "linux") {
            return "/tmp"
        } else if (agentOs == "windows") {
            return "C:\\Users\\Administrator\\AppData\\Local\\Temp\\"
        } else {
            return System.getProperty('java.io.tmpdir')
        }
    }

    static String createTestResource(String resourceName = null) {
        if (!resourceName) {
            resourceName = iisIP + ":7800"
        }
        ServerHandler.getInstance().setupResource(resourceName, iisIP, 7800)

        return resourceName
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
        String params = actualParameters.collect { k, v -> "$k: '$v'" }.join(",")
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

