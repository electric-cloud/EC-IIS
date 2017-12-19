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

        cleanup:
            removeSite(siteName)
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
                        websitepath: 'c:/tmp/newPath',
                        bindings: '''http://*:8080'''
                    ]
                )
            """)
        then: 'procedure succeeds'
            assert result.outcome == 'success'
            logger.debug(result.logs)
            assert result.logs =~ /SITE object "$siteName" changed/
            def updatedSite = getSite(siteName)
            logger.debug(objectToJson(updatedSite))
            assert updatedSite.bindings =~ /8080/
            def updatedVdir = getVdir(siteName)
            assert updatedVdir.path =~ /newPath/
        cleanup:
            removeSite(siteName)
    }

    def "port & path already taken"() {
        given: 'a site'
            def siteName = 'Test'
            def bindings = 'http://*:80'
            def sitePath = 'c:/tmp/test'
            createSite(siteName, bindings, sitePath)
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
        cleanup:
            removeSite(siteName)
    }

    def "create site with id"() {
        given:
            def siteName = 'MySite'
            def siteId = 99
        when: 'procedure runs'
             def result = runProcedureDsl """
                runProcedure(
                    projectName: "$projectName",
                    procedureName: 'Create Site',
                    actualParameter: [
                        websitename: '$siteName',
                        websitepath: 'c:/tmp/site',
                        bindings: '''http://*:9999''',
                        websiteid: '$siteId'
                    ]
                )
            """
        then:
            assert result.outcome == 'success'
            def site = getSite(siteName)
            assert site.id == "${siteId}"
        cleanup:
            removeSite(siteName)

    }

    def "negative: invalid bindings"() {
        when: 'procedure runs'
            def result = runProcedureDsl """
                runProcedure(
                    projectName: "$projectName",
                    procedureName: 'Create Site',
                    actualParameter: [
                        websitename: 'MySite',
                        websitepath: 'c:/tmp/site',
                        bindings: '''http'''
                    ]
                )
            """
        then: 'it fails'
            assert result.outcome == 'error'
    }

    def "negative: id already taken"() {
        given:
            def siteId = 99
            def siteName = 'TestSite'
            def path = 'c:/tmp/test_site'
            def bindings = 'http://*:80'
            createSite(siteName, bindings, path, siteId)
        when: 'procedure runs'
            def result = runProcedureDsl """
                runProcedure(
                    projectName: "$projectName",
                    procedureName: 'Create Site',
                    actualParameter: [
                        websitename: 'AnotherSite',
                        websitepath: '$path',
                        bindings: '''$bindings''',
                        websiteid: '$siteId'
                    ]
                )
            """
        then:
            assert result.outcome == 'error'
        cleanup:
            removeSite(siteName)
    }
}
