package com.cloudbees.plugin.spec

import com.electriccloud.plugins.annotations.Sanity
import spock.lang.Shared
import spock.lang.Ignore
import spock.lang.Unroll

class WebSiteSpec extends PluginTestHelper {
    static String procedureName = ""

    def doSetupSpec() {
        createConfig()
    }

    @Sanity
    def 'get experiments'() {
        setup:
        when:
        def r = procedure.run()
        then:
        assert r.successful
        assert r.jobLog =~ / name: ${flagName}, description: /
        assert r.jobLog =~ /true with probability of 10/
        cleanup:
        rolloutAPI.deleteFlag(getAppId(), experiment.name)
    }

}
