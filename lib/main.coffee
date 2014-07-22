{$} = require atom.packages.resourcePath + '/src/space-pen-extensions'
_ = require atom.packages.resourcePath + '/node_modules/underscore-plus'

#--- Module
module.exports =
  activate: ->
    @bindEvents()
    process.nextTick =>
      @onWindowLoad()

  deactivate: ->

  bindEvents: ->
    # Dropping files on the window will open in the current window rather than spawning a new one.
    $(document).off 'drop'
    $(document).on 'drop', (e) ->
      e.preventDefault()
      e.stopPropagation()
      pathsToOpen = _.pluck(e.originalEvent.dataTransfer.files, 'path')
      _.each pathsToOpen, (pathToOpen) ->
        try
          atom.workspace.open(pathToOpen)
        catch error
          # Path is probably a directory
          # For now, just ignore it.



  onWindowLoad: ->
    @sortPackagesMenu()

  sortPackagesMenu: ->
    packagesMenu = atom.menu.template[5]
    packagesMenu.submenu.sort (a, b) ->
      if a.label then a.label.localeCompare(b.label) else -1
    atom.menu.update()
