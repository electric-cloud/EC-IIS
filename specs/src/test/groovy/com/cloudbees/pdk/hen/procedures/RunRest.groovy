package com.cloudbees.pdk.hen.procedures

import groovy.transform.AutoClone
import com.cloudbees.pdk.hen.*
import com.cloudbees.pdk.hen.*

//generated
class RunRest extends Procedure {

    static RunRest create(Plugin plugin) {
        return new RunRest(procedureName: 'runRest', plugin: plugin, )
    }


    RunRest flush() {
        this.flushParams()
        this.contextUser = null
        return this
    }

    RunRest withUser(User user) {
        this.contextUser = user
        return this
    }


    RunRest clone() {
        RunRest cloned = new RunRest(procedureName: 'runRest', plugin: plugin, )
        cloned.parameters = this.parameters.clone()
        return cloned
    }

    //Generated
    
    RunRest acceptedMimeTypes(String acceptedMimeTypes) {
        this.addParam('acceptedMimeTypes', acceptedMimeTypes)
        return this
    }
    
    
    RunRest config(String config) {
        this.addParam('config', config)
        return this
    }
    
    
    RunRest contentType(String contentType) {
        this.addParam('contentType', contentType)
        return this
    }
    
    
    RunRest cookieHeaderValue(String cookieHeaderValue) {
        this.addParam('cookieHeaderValue', cookieHeaderValue)
        return this
    }
    
    
    RunRest filePath(String filePath) {
        this.addParam('filePath', filePath)
        return this
    }
    
    
    RunRest formContent(String formContent) {
        this.addParam('formContent', formContent)
        return this
    }
    
    
    RunRest headers(String headers) {
        this.addParam('headers', headers)
        return this
    }
    
    
    RunRest ignoreAuth(boolean ignoreAuth) {
        this.addParam('ignoreAuth', ignoreAuth)
        return this
    }
    
    
    RunRest pathUrl(String pathUrl) {
        this.addParam('pathUrl', pathUrl)
        return this
    }
    
    
    RunRest postScriptContent(String postScriptContent) {
        this.addParam('postScriptContent', postScriptContent)
        return this
    }
    
    
    RunRest postScriptOutput(String postScriptOutput) {
        this.addParam('postScriptOutput', postScriptOutput)
        return this
    }
    
    
    RunRest postScriptShell(String postScriptShell) {
        this.addParam('postScriptShell', postScriptShell)
        return this
    }
    
    
    RunRest queryOptions(String queryOptions) {
        this.addParam('queryOptions', queryOptions)
        return this
    }
    
    
    RunRest requestTimeout(String requestTimeout) {
        this.addParam('requestTimeout', requestTimeout)
        return this
    }
    
    
    RunRest requestType(String requestType) {
        this.addParam('requestType', requestType)
        return this
    }
    
    RunRest requestType(RequestTypeOptions requestType) {
        this.addParam('requestType', requestType.toString())
        return this
    }
    
    
    RunRest responseoutpp(String responseoutpp) {
        this.addParam('response_outpp', responseoutpp)
        return this
    }
    
    
    RunRest responseContentPolling(String responseContentPolling) {
        this.addParam('responseContentPolling', responseContentPolling)
        return this
    }
    
    
    RunRest targetFile(String targetFile) {
        this.addParam('targetFile', targetFile)
        return this
    }
    
    
    RunRest writeToFile(boolean writeToFile) {
        this.addParam('writeToFile', writeToFile)
        return this
    }
    
    
    
    
    enum RequestTypeOptions {
    
    GET("GET"),
    
    POST("POST"),
    
    PUT("PUT"),
    
    PATCH("PATCH"),
    
    DELETE("DELETE"),
    
    HEAD("HEAD")
    
    private String value
    RequestTypeOptions(String value) {
        this.value = value
    }

    String toString() {
        return this.value
    }
}
    
}