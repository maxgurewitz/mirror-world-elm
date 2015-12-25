var dot = require('dot');
var fs = require('fs');
var path = require('path');
var packageJson = require('../package.json');

dot.process({ path: path.join('.', 'src', 'dot') });

var render = require('../src/dot');

var html = render({
  projectName: packageJson.name
});

fs.writeFileSync(
  path.join('.', 'assets', 'index.html'),
  html,
  { flags: 'w+' }
)

