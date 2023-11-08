package com.cloudbees.pdk.hen.procedures

import com.cloudbees.pdk.hen.*

class CheckServerStatus extends Procedure {

    static CheckServerStatus create(Plugin plugin) {
        return new CheckServerStatus(procedureName: 'CheckServerStatus', plugin: plugin)
    }

    CheckServerStatus flush() {
        this.flushParams()
        this.contextUser = null
        return this
    }

    CheckServerStatus withUser(User user) {
        this.contextUser = user
        return this
    }

    CheckServerStatus clone() {
        CheckServerStatus cloned = new CheckServerStatus(procedureName: 'CheckServerStatus', plugin: plugin,)
        cloned.parameters = this.parameters.clone()
        return cloned
    }

    CheckServerStatus configname(String configname) {
        this.addParam('configname', configname)
        return this
    }

    CheckServerStatus checkUrl(String checkUrl) {
        this.addParam('checkUrl', checkUrl)
        return this
    }

    CheckServerStatus expectStatus(String expectStatus) {
        this.addParam('expectStatus', expectStatus)
        return this
    }

    CheckServerStatus checkUnavailable(String checkUnavailable) {
        this.addParam('unavailable', checkUnavailable)
        return this
    }

    CheckServerStatus checkTimeout(String checkTimeout) {
        this.addParam('checkTimeout', checkTimeout)
        return this
    }

    CheckServerStatus checkRetries(String checkRetries) {
        this.addParam('checkRetries', checkRetries)
        return this
    }

}