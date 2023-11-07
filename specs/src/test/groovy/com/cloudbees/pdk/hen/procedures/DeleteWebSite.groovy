package com.cloudbees.pdk.hen.procedures

import com.cloudbees.pdk.hen.*

class DeleteWebSite extends Procedure {

    static DeleteWebSite create(Plugin plugin) {
        return new DeleteWebSite(procedureName: 'deleteWebSite', plugin: plugin,)
    }

    DeleteWebSite flush() {
        this.flushParams()
        this.contextUser = null
        return this
    }

    DeleteWebSite withUser(User user) {
        this.contextUser = user
        return this
    }

    DeleteWebSite clone() {
        DeleteWebSite cloned = new DeleteWebSite(procedureName: 'deleteWebSite', plugin: plugin,)
        cloned.parameters = this.parameters.clone()
        return cloned
    }

    DeleteWebSite config(String config) {
        this.addParam('config', config)
        return this
    }

    DeleteWebSite websitename(String websitename) {
        this.addParam('websitename', websitename)
        return this
    }

    DeleteWebSite strictMode(boolean strictMode) {
        this.addParam('strictMode', strictMode)
        return this
    }

}