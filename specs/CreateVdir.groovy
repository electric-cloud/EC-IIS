import spock.lang.*
import com.electriccloud.spec.*

class CreateVirtualDirectory extends PluginTestHelper {
    static def projectName = 'EC-IIS Specs CreateVirtualDirectory'
    static def iisHandler
    static def procName = 'CreateVirtualDirectory'

    def doSetupSpec() {
        dsl 'setProperty(propertyName: "/plugins/EC-IIS/project/ec_debug_logToProperty", value: "/myJob/debug_logs")'
        def resName = createIISResource()
        dslFile 'dsl/RunProcedure.dsl', [
            projName: projectName,
            resName: resName,
            procName: procName,
            params: [
                appname: '',
                path: '',
                physicalpath: ''
            ]
        ]
        createHelperProject(resName)
    }

    def doCleanupSpec() {
        dsl "deleteProject '$projectName'"
    }

    @Unroll
    def "create vdir #appName"() {
        given:
            def siteName = randomize('site')
            createSite(siteName)
        when: "procedure runs"
            def result = runProcedureDsl """
                runProcedure(
                    projectName: "$projectName",
                    procedureName: '$procName',
                    actualParameter: [
                        appname: '${siteName}/',
                        path: '$appName/',
                        physicalpath: 'c:/tmp/path'
                    ]
                )
            """
        then:
            assert result.outcome == 'success'
        cleanup:
            removeSite(siteName)
        where:
            appName << ['app', 'my app']
    }

    @Unroll
    def "update dir"() {
        given:
            def siteName = randomize('site')
            createSite(siteName)
            def appName = 'app'
            createApp(siteName, appName)
        when:
            def result = runProcedureDsl """
                runProcedure(
                    projectName: "$projectName",
                    procedureName: '$procName',
                    actualParameter: [
                        appname: '${siteName}/',
                        path: '$appName/',
                        physicalpath: 'c:/tmp/another path'
                    ]
                )
            """
        then:
            assert result.outcome == 'success'
            def vdir = getVdir(siteName, appName)
            assert vdir.path == 'C:\\tmp\\another path'
    }

    @Unroll
    def "negative: non-existing site"() {
        given:
            def siteName = 'some site'
        when:
            def result = runProcedureDsl """
                runProcedure(
                    projectName: "$projectName",
                    procedureName: '$procName',
                    actualParameter: [
                        appname: '${siteName}/',
                        path: 'some path/',
                        physicalpath: 'c:/tmp/another path'
                    ]
                )
            """
        then:
            assert result.outcome == 'error'
    }
}
