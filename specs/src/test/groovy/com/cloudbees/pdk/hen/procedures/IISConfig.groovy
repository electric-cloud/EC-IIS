package com.cloudbees.pdk.hen.procedures

import groovy.transform.AutoClone
import com.cloudbees.pdk.hen.*

//generated
class IISConfig extends Procedure {

    static IISConfig create(Plugin plugin) {
        return new IISConfig(procedureName: 'CreateConfiguration', plugin: plugin, credentials: [
                'credential': null,
        ])
    }


    IISConfig flush() {
        this.flushParams()
        this.contextUser = null
        return this
    }

    IISConfig withUser(User user) {
        this.contextUser = user
        return this
    }


    IISConfig clone() {
        IISConfig cloned = new IISConfig(procedureName: 'CreateConfiguration', plugin: plugin, credentials: [
                'credential': null,
        ])
        cloned.parameters = this.parameters.clone()
        return cloned
    }

    IISConfig config(String config) {
        this.addParam('config', config)
        return this
    }

    IISConfig desc(String desc) {
        this.addParam('desc', desc)
        return this
    }

    IISConfig iisUrl(String iisUrl) {
        this.addParam('iis_url', iisUrl)
        return this
    }

    IISConfig checkConnection(boolean checkConnection) {
        this.addParam('checkConnection', checkConnection)
        return this
    }

    IISConfig iisPort(String iisPort) {
        this.addParam('iis_port', iisPort)
        return this
    }

    IISConfig defaultHeaders(String defaultHeaders) {
        this.addParam('defaultHeaders', defaultHeaders)
        return this
    }

    IISConfig credential(String user, String password) {
        this.addCredential('credential', user, password)
        return this
    }

    IISConfig credentialReference(String path) {
        this.addCredentialReference('credential', path)
        return this
    }
}
    
