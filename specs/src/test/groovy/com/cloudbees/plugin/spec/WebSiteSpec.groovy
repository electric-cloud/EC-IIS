package com.cloudbees.plugin.spec

import com.electriccloud.plugins.annotations.Sanity
import spock.lang.Shared
import spock.lang.Ignore
import spock.lang.Unroll

class WebSiteSpec extends PluginTestHelper {
    static final String configName = 'specsConfig'
    static final String procedureName = 'Get Experiments'

    @Shared
    GetExperiments procedure

    @Shared
    FeatureFlags oldConfig

    def doSetupSpec() {
        procedure = FeatureFlags.create().getExperiments.applicationId(appId).envName(envName)
        oldConfig = FeatureFlags.createWithoutConfig()
        oldConfig.configure(oldConfig.config)
    }

    @Sanity
    def 'get experiments'() {
        setup:
        String flagName = generateRandomFlagName()
        Flag experiment = Flag.builder().name(flagName).enabled(false).value(
            SplittedValue.builder().percentage(10).option(new BooleanOption(true)).build()
        ).build()
        try {
            rolloutAPI.createFlag(getAppId(), experiment.name, null)
        } catch (RolloutApiException e) {
            if (e.message =~ /exist/) {

            } else {
                throw e
            }
        }
        when:
        def r = procedure.run()
        then:
        assert r.successful
        assert r.jobLog =~ / name: ${flagName}, description: /
        assert r.jobLog =~ /true with probability of 10/
        cleanup:
        rolloutAPI.deleteFlag(getAppId(), experiment.name)
    }

    @Sanity
    def 'get experiments with schedules'() {
        setup:
        String flagName = generateRandomFlagName()
        Flag experiment = Flag.builder().name(flagName).enabled(false).value(
            ScheduledValue.builder().percentage(10).from(new Date()).option(new BooleanOption(true)).build()
        ).build()
        try {
            rolloutAPI.createFlag(getAppId(), experiment.name, null)
        } catch (RolloutApiException e) {
            if (e.message =~ /exist/) {

            } else {
                throw e
            }
        }
        rolloutAPI.configureFlag(appId, envName, experiment)
        when:
        def r = procedure.run()
        then:
        assert r.successful
        assert r.jobLog =~ /name: ${flagName}, description: /
        assert r.jobLog =~ /true with probability of 10% starting from /
        cleanup:
        rolloutAPI.deleteFlag(getAppId(), experiment.name)
    }

    @Sanity
    def 'get experiments with string values'() {
        setup:
        String flagName = generateRandomFlagName()
        Flag experiment = Flag.builder().name(flagName).enabled(false).value(
            SplittedValue.builder().percentage(10).option(new StringOption("option")).build()
        ).availableValues(["option", "another value"]).build()
        try {
            rolloutAPI.createFlag(getAppId(), experiment.name, null)
        } catch (RolloutApiException e) {
            if (e.message =~ /exist/) {

            }
            else {
                throw e
            }
        }
        rolloutAPI.configureFlag(getAppId(), envName, experiment)
        when:
        def r = procedure.run()
        then:
        assert r.successful
        assert r.jobLog =~ / name: ${flagName}, description: /
        assert r.jobLog =~ /option with probability of 10%/
        cleanup:
        rolloutAPI.deleteFlag(getAppId(), experiment.name)
    }

    def 'get experiments with invalid app id'() {
        when:
        def r = procedure.flush().envName(envName).applicationId('wrongappid24charctrslong').run()
        then:
        assert !r.successful
        assert r.jobLog =~ /Failed to execute API call: Bad Request/
    }

    @Sanity
    def 'validate apps dropdown'() {
        when:
        def options = oldConfig.getExperiments.dropdown('applicationId')
        then:
        assert options.size() > 0
        assert options.find { it.value == appId }
    }

    @Sanity
    def 'validate envs dropdown'() {
        when:
        def options = oldConfig.getExperiments.applicationId(appId).dropdown('envName')
        then:
        assert options.size() > 0
        assert options.find { it.value == envName }
    }
}
