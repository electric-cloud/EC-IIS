import spock.lang.*
import com.electriccloud.spec.*

class CreateWebsite extends PluginTestHelper {
    static def projectName = 'EC-IIS Specs CreateWebSite'
    static def iisHandler

    def doSetupSpec() {
        dsl 'setProperty(propertyName: "/plugins/EC-IIS/project/ec_debug_logToProperty", value: "/myJob/debug_logs")'
        def resName = createIISResource()
        dslFile 'dsl/CreateSite/CreateSite.dsl', [
            projName: projectName,
            resName: resName
        ]
        createHelperProject(resName)
    }

    // def doCleanupSpec() {
    //     dsl "deleteProject '$projectName'"
    // }


    def "normal params"() {
        given: 'the site is removed'
            removeSite(siteName)
        when: 'procedure runs'
            def result = runProcedureDsl("""
                runProcedure(
                    projectName: "$projectName",
                    procedureName: 'Create Site',
                    actualParameter: [
                        websitename: '$siteName',
                        websiteid: '$siteId',
                        websitepath: '$sitePath',
                        bindings: '''$bindings'''
                    ]
                )
            """)
        then: 'procedure succeeds'
            assert result.outcome == 'success'
            logger.debug(result.logs)
            assert result.logs =~ /SITE object "$siteName" added/
            assert result.logs =~ /APP object "$siteName\/" added/
        where:
            siteName << ['mysite', 'Some Site']
            siteId << ['', 56]
            sitePath << ['c:/tmp/path', 'c:/tmp/somepath']
            bindings << ['http://*:80', 'http://localhost:9080']
    }

    def "site already exists"() {
        given: 'a site'
            def siteName = 'Test Site'
            def bindings = 'http://*:80'
            def sitePath = 'c:/tmp/Test'
            createSite(siteName)
        when: 'procedure runs'
            def result = runProcedureDsl("""
                runProcedure(
                    projectName: "$projectName",
                    procedureName: 'Create Site',
                    actualParameter: [
                        websitename: '$siteName',
                        websitepath: '$sitePath',
                        bindings: '''$bindings'''
                    ]
                )
            """)
        then: 'procedure succeeds'
            assert result.outcome == 'success'
            logger.debug(result.logs)
            assert result.logs =~ /SITE object "$siteName" changed/
    }
}
