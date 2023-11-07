package com.cloudbees.pdk.hen.procedures

import com.cloudbees.pdk.hen.*

class CreateWebSite extends Procedure {

    static CreateWebSite create(Plugin plugin) {
        return new CreateWebSite(procedureName: 'createWebSite', plugin: plugin,)
    }

    CreateWebSite flush() {
        this.flushParams()
        this.contextUser = null
        return this
    }

    CreateWebSite withUser(User user) {
        this.contextUser = user
        return this
    }

    CreateWebSite clone() {
        CreateWebSite cloned = new CreateWebSite(procedureName: 'createWebSite', plugin: plugin,)
        cloned.parameters = this.parameters.clone()
        return cloned
    }

    CreateWebSite config(String config) {
        this.addParam('config', config)
        return this
    }

    CreateWebSite websitename(String websitename) {
        this.addParam('websitename', websitename)
        return this
    }

    CreateWebSite websitepath(String websitepath) {
        this.addParam('websitepath', websitepath)
        return this
    }

    CreateWebSite websiteid(String websiteid) {
        this.addParam('websiteid', websiteid)
        return this
    }

    CreateWebSite bindings(String bindings) {
        this.addParam('bindings', bindings)
        return this
    }

    CreateWebSite createDirectory(boolean createDirectory) {
        this.addParam('createDirectory', createDirectory)
        return this
    }

    CreateWebSite credential(Credential credential) {
        this.addParam('credential', credential)
        return this
    }

}