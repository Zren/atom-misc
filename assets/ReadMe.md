## Assets

### Install Packages From The Web (Windows)

![](http://i.imgur.com/o0vT43h.png)

This isn't user friendly (it requires editing the script), and doesn't come with an uninstall script.

* First edit `./assets/RegisterApmUrlScheme.reg`. Change the paths for NodeJS and the location of this package. Run the registry file. This will install a custom URI scheme (apm://) into the registry.
* Install the `./assets/webInstallerForAtomPackages.user.js` userscript. This will register the url handler in your browser, as well as generate the install button.
