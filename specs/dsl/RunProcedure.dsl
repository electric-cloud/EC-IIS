def projName = args.projName
def resName = args.resName
def params = args.params
def procName = args.procName

// def params = [
//   appname: '',
//   physicalpath: '',
//   path: '',
// ]

project projName, {
    procedure procName, {
      resourceName = resName

      step 'Run IIS procedure', {
        description = ''
        subprocedure = procName
        subproject = '/plugins/EC-IIS/project'

        params.each { name, defValue ->
          actualParameter name, '$[' + name + ']'
        }
      }


      params.each {name, defValue ->
        formalParameter name, defaultValue: defValue, {
          type = 'textarea'
        }
      }
  }
}
