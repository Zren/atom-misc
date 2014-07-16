var spawn = function(command, args, cb) {
  var ChildProcess = require('child_process');
  var childProcess = ChildProcess.spawn(command, args);

  childProcess.stdout.setEncoding('utf8');

  childProcess.stderr.setEncoding('utf8');
  childProcess.stderr.on('data', function (data) {
    console.log('childProcess stderr: ' + data);
  });

  childProcess.on('close', function (code, signal) {
    if (code !== 0) {
      console.log('childProcess stream ' + signal + ' exited with code ' + code + '.');
    }
  });
  childProcess.on('exit', function (code) {
    if (code !== 0) {
      console.log('childProcess exited with code ' + code);
    }

    cb(null);
  });
  childProcess.on('error', function (err) {
    cb(err);
  });
  return childProcess;
};

var apmUriHandler = function(input, cb){
  if (!input)
    return cb('Invalid URI');

  var url = require('url');
  var u = url.parse(input);
  var command = u.host;
  var args = u.path;

  if (!command)
    return cb('Invalid URI: No command set. Eg: apm://command');

  switch (command) {
    case 'install':
      if (!args)
        return cb('Invalid URI: Missing package name. Eg: apm://install/tree-view');

      var packageName = args.substring(1); // Remove leading slash.

      if (!packageName)
        return cb('Invalid URI: Missing package name. Eg: apm://install/tree-view');

      var command = 'C:\\Chocolatey\\bin\\apm.bat';
      console.log('Running: ' + command + ' install ' + packageName);
      var apmInstall = spawn(command, ['install', packageName], cb);
      apmInstall.stdout.on('data', function (data) {
        console.log('' + data);
      });

      break;
    default:
      break;
  }
  // console.log(input, command, args, u);
};

var pause = function() {
  console.log();
  console.log(' > Press any key to exit');
  process.stdin.resume();
  process.stdin.on('data', function () {
    process.exit();
  });
};

var main = function() {
  var input = process.argv[2];
  apmUriHandler(input, function(err){
    if (err)
      console.error(err);

    pause();
  });

  // apmUriHandler('apm://install/', function(err){
  //   if (err)
  //     return console.error(err);
  // });
  // apmUriHandler('apm://');
  // apmUriHandler('apm://');
  // apmUriHandler('apm://install/');
  // apmUriHandler('apm://install');
  // apmUriHandler('apm://install/asd asdf');
  // apmUriHandler('apm:// /asd asdf');
  // apmUriHandler('apm:// /asd asdf');
};
main();
