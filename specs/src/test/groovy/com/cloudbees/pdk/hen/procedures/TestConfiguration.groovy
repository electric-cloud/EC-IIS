package com.cloudbees.pdk.hen.procedures

import com.cloudbees.pdk.hen.*

class TestConfiguration extends Procedure {

    static TestConfiguration create(Plugin plugin) {
        return new TestConfiguration(procedureName: 'TestConfiguration', plugin: plugin, credentials: [
            'credential': null,
        ])
    }

    TestConfiguration flush() {
        this.flushParams()
        this.contextUser = null
        return this
    }

    TestConfiguration withUser(User user) {
        this.contextUser = user
        return this
    }

    TestConfiguration clone() {
        TestConfiguration cloned = new TestConfiguration(procedureName: 'TestConfiguration', plugin: plugin, credentials: [
                    'credential': null,
                ])
        cloned.parameters = this.parameters.clone()
        return cloned
    }

    TestConfiguration config(String config) {
        this.addParam('config', config)
        return this
    }

    TestConfiguration desc(String desc) {
        this.addParam('desc', desc)
        return this
    }

    TestConfiguration iisUrl(String iisUrl) {
        this.addParam('iis_url', iisUrl)
        return this
    }

    TestConfiguration checkConnection(boolean checkConnection) {
        this.addParam('checkConnection', checkConnection)
        return this
    }

    TestConfiguration iisPort(String iisPort) {
        this.addParam('iis_port', iisPort)
        return this
    }

    TestConfiguration defaultHeaders(String defaultHeaders) {
        this.addParam('defaultHeaders', defaultHeaders)
        return this
    }

    TestConfiguration credential(String user, String password) {
        this.addCredential('credential', user, password)
        return this
    }

    TestConfiguration credentialReference(String path) {
        this.addCredentialReference('credential', path)
        return this
    }
}