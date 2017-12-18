import spock.lang.*
import com.electriccloud.spec.*

class PluginTestHelper extends PluginSpockTestSupport {

    static def helperProjName = 'IIS Helper Project'

    def redirectLogs(String parentProperty = '/myJob') {
        def propertyLogName = parentProperty + '/debug_logs'
        dsl """
            setProperty(
                propertyName: "/plugins/EC-IIS/project/ec_debug_logToProperty",
                value: "$propertyLogName"
            )
        """
        return propertyLogName
    }

    def redirectLogsToPipeline() {
        def propertyName = '/myPipelineRuntime/debugLogs'
        dsl """
            setProperty(
                propertyName: "/plugins/EC-IIS/project/ec_debug_logToProperty",
                value: "$propertyName"
            )
        """
        propertyName
    }

    def getJobLogs(def jobId) {
        assert jobId
        def logs
        try {
            logs = getJobProperty("/myJob/debug_logs", jobId)
        } catch (Throwable e) {
            logs = "Possible exception in logs; check job"
        }
        logs
    }

    def getPipelineLogs(flowRuntimeId) {
        assert flowRuntimeId
        getPipelineProperty('/myPipelineRuntime/debugLogs', flowRuntimeId)
    }


    def runProcedureDsl(dslString) {
        redirectLogs()
        assert dslString

        def result = dsl(dslString)
        assert result.jobId
        waitUntil {
            jobCompleted result.jobId
        }
        def logs = getJobLogs(result.jobId)
        def outcome = jobStatus(result.jobId).outcome
        logger.debug("DSL: $dslString")
        logger.debug("Logs: $logs")
        logger.debug("Outcome: $outcome")
        [logs: logs, outcome: outcome, jobId: result.jobId]
    }

    def createIISResource() {
        def hostname = System.getenv('IIS_RESOURCE_HOST')
        def resources = dsl "getResources()"
        logger.debug(objectToJson(resources))

        def resource = resources.resource.find {
            it.hostName == hostname
        }
        if (resource) {
            logger.debug("IIS resource already exists")
            return resource.resourceName
        }

        def port = System.getenv('IIS_RESOURCE_PORT') ?: '7800'
        def workspaceName = randomize("IIS")

        def workspaceResult = dsl """
            createWorkspace(
                workspaceName: '${workspaceName}',
                agentDrivePath: 'c:/tmp/workspace',
                agentUncPath: 'c:\\\\tmp\\\\workspace',
                local: '1'
            )
        """

        logger.debug(objectToJson(workspaceResult))

        def result = dsl """
            createResource(
                resourceName: '${randomize("IIS")}',
                hostName: '$hostname',
                port: '$port',
                workspaceName: '$workspaceName'
            )
        """

        logger.debug(objectToJson(result))
        def resName = result?.resource?.resourceName
        assert resName
        resName
    }

    def createHelperProject(resName) {
        def appcmdPath = 'c:/windows/system32/inetsrv/appcmd.exe'

        dsl """
            project '$helperProjName', {

                procedure 'Run App Cmd', {
                    resourceName = '$resName'
                    step 'Run Command', {
                        command = '$appcmdPath \$[appCmd]'
                    }
                    formalParameter 'appCmd', defaultValue: '', {
                        type = 'entry'
                    }
                }

            }
        """
    }

    def removeSite(siteName) {
        def result = dsl """
            runProcedure(
                projectName: '$helperProjName',
                procedureName: 'Run App Cmd',
                actualParameter: [
                    appCmd: 'delete site "$siteName"'
                ]
            )
        """
        assert result.jobId
        waitUntil {
            jobCompleted result.jobId
        }
    }

    def createSite(siteName, bindings = '', path = '') {
        bindings ?: 'http://*:80'
        path ?: 'c:/tmp/test_path'
        def result = dsl """
            runProcedure(
                projectName: '$helperProjName',
                procedureName: 'Run App Cmd',
                actualParameter: [
                    appCmd: 'add site /name:"$siteName" /bindings:"$bindings" /physicalpath:"$path"'
                ]
            )
        """
        assert result.jobId
        waitUntil {
            jobCompleted result.jobId
        }
    }

}
