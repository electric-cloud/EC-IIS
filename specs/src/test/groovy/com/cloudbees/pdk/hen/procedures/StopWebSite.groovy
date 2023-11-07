package com.cloudbees.pdk.hen.procedures

import com.cloudbees.pdk.hen.*

class StopWebSite extends Procedure {

    static StopWebSite create(Plugin plugin) {
        return new StopWebSite(procedureName: 'stopWebSite', plugin: plugin,)
    }

    StopWebSite flush() {
        this.flushParams()
        this.contextUser = null
        return this
    }

    StopWebSite withUser(User user) {
        this.contextUser = user
        return this
    }

    StopWebSite clone() {
        StopWebSite cloned = new StopWebSite(procedureName: 'stopWebSite', plugin: plugin,)
        cloned.parameters = this.parameters.clone()
        return cloned
    }

    StopWebSite config(String config) {
        this.addParam('config', config)
        return this
    }

    StopWebSite websitename(String websitename) {
        this.addParam('sitename', websitename)
        return this
    }

}