package com.cloudbees.pdk.hen.procedures

import com.cloudbees.pdk.hen.*

class EditConfiguration extends Procedure {

    static EditConfiguration create(Plugin plugin) {
        return new EditConfiguration(procedureName: 'EditConfiguration', plugin: plugin, credentials: [
            'credential': null,
        ])
    }


    EditConfiguration flush() {
        this.flushParams()
        this.contextUser = null
        return this
    }

    EditConfiguration withUser(User user) {
        this.contextUser = user
        return this
    }


    EditConfiguration clone() {
        EditConfiguration cloned = new EditConfiguration(procedureName: 'EditConfiguration', plugin: plugin, credentials: [
                    'credential': null,
                ])
        cloned.parameters = this.parameters.clone()
        return cloned
    }

    EditConfiguration config(String config) {
        this.addParam('config', config)
        return this
    }

    EditConfiguration desc(String desc) {
        this.addParam('desc', desc)
        return this
    }

    EditConfiguration iisUrl(String iisUrl) {
        this.addParam('iis_url', iisUrl)
        return this
    }

    EditConfiguration checkConnection(boolean checkConnection) {
        this.addParam('checkConnection', checkConnection)
        return this
    }

    EditConfiguration iisPort(String iisPort) {
        this.addParam('iis_port', iisPort)
        return this
    }

    EditConfiguration defaultHeaders(String defaultHeaders) {
        this.addParam('defaultHeaders', defaultHeaders)
        return this
    }

    EditConfiguration credential(String user, String password) {
        this.addCredential('credential', user, password)
        return this
    }

    EditConfiguration credentialReference(String path) {
        this.addCredentialReference('credential', path)
        return this
    }
}