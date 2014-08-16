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
    @deleteWindowMenu()
    @deleteFileMenuYourCommands()
    @insertConfigMenu()
    atom.menu.update()

  sortPackagesMenu: ->
    packagesMenu =  _.findWhere(atom.menu.template, {label:'Packages'}) or _.findWhere(atom.menu.template, {label:'&Packages'})
    packagesMenu.submenu.sort (a, b) ->
      if a.label then a.label.localeCompare(b.label) else -1

  deleteWindowMenu: ->
    for menu, index in atom.menu.template
      if menu?.label is 'Window' or menu?.label is '&Window'
        atom.menu.template.splice(index, 1)
        break

  deleteFileMenuYourCommands: ->
    yourCommands = [
      'application:open-your-config'
      'application:open-your-init-script'
      'application:open-your-keymap'
      'application:open-your-snippets'
      'application:open-your-stylesheet'
    ]
    fileMenu =  _.findWhere(atom.menu.template, {label:'Atom'}) or _.findWhere(atom.menu.template, {label:'&File'})
    for yourCommand in yourCommands
      for item, index in fileMenu.submenu
        if item?.command is yourCommand
          fileMenu.submenu.splice(index, 1)
          break

  newConfigMenu: ->
    menu = {
      label: 'Config'
      submenu: [
        {
          label: 'User'
          submenu: [
            { label: 'Config', command: 'application:open-your-config' }
            { label: 'Init Script', command: 'application:open-your-init-script' }
            { label: 'Keymap', command: 'application:open-your-keymap' }
            { label: 'Snippets', command: 'application:open-your-snippets' }
            { label: 'Stylesheet', command: 'application:open-your-stylesheet' }
          ]
        }
      ]
    }

  insertConfigMenu: ->
    for menu, index in atom.menu.template
      if menu?.label is 'Config'
        # Replace
        atom.menu.template[index] = @newConfigMenu()
      else if menu?.label is 'Help' or menu?.label is '&Help'
        # Insert before
        atom.menu.template.splice(index - 1, 0, @newConfigMenu())
