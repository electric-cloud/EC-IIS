package com.cloudbees.plugin.spec

import com.cloudbees.pdk.hen.Credential
import com.cloudbees.pdk.hen.IIS
import com.cloudbees.pdk.hen.models.Project
import com.cloudbees.pdk.hen.models.Resource
import com.cloudbees.pdk.hen.procedures.CheckServerStatus
import com.cloudbees.pdk.hen.procedures.IISConfig
import com.cloudbees.pdk.hen.Utils
import static com.cloudbees.pdk.hen.Utils.setConfigurationValues

import com.electriccloud.plugins.annotations.Sanity
import groovy.util.logging.Slf4j
import spock.lang.Stepwise

@Slf4j
@Stepwise
class WebSiteSpec extends HenHelper {
    static Project project
    static String resourceName
    static IIS plugin

    def setupSpec() {
//        runOpts.timeout = 240
        project = new Project(cdFlowProjectName)
        project.create()
        println("#XX0: " + project)
        resourceName = createTestResource()
        println("#XX1: " + resourceName)
        plugin = IIS.create(resourceName)
        println("#XX2: " + plugin)
    }

    def cleanupSpec() {
        project.delete()
    }

    @Sanity
    def 'get server status'() {
//        setup: "Create plugin and config"
        when: "Run Plugin Procedure - Clone: Mirror"
//        CheckServerStatus checkServerStatus = plugin.checkServerStatus.checkUrl(iisIP)
        CheckServerStatus checkServerStatus = new CheckServerStatus(procedureName: 'CheckServerStatus', plugin: plugin, resourceName: resourceName)
        println("#000: " + checkServerStatus)
        def r = checkServerStatus.runNaked(runOpts)
        then:
        assert r.successful
        println("#001: " + r.outcome)
        println("#002: " + r.jobLog)
//        cleanup:
    }

}
