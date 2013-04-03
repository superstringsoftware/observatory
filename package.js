try {
Package.describe({
  summary: "Powerful, yet easy to use, logging and monitoring package"
});

Package.on_use(function (api) {
  api.use(['coffeescript', 'bootstrap', 'underscore','templating','less','observatory-apollo'], 'client');

  api.add_files('lib/codemirror/codemirror.js','client');
  api.add_files('lib/codemirror/javascript.js','client');
  api.add_files('lib/codemirror/codemirror.css','client');
  api.add_files([
      'lib/codemirror/theme/ambiance.css',
      'lib/codemirror/theme/solarized.css'],'client');
  api.add_files([
    'mars/observatory.html',
    'mars/observatoryTemplates.coffee',
    'mars/observatory.less',
    'mars/objinspector.html',
    'mars/objinspector.coffee',
    'mars/objinspector.less'
    ], 'client');

});
}
catch (err) {
  console.log("Error while trying to load a package: " + err.message);
};

/*
 'client/codemirror/theme/blackboard.css',
 'client/codemirror/theme/cobalt.css',
 'client/codemirror/theme/eclipse.css',
 'client/codemirror/theme/elegant.css',
 'client/codemirror/theme/erlang-dark.css',
 'client/codemirror/theme/lesser-dark.css',
 'client/codemirror/theme/monokai.css',
 'client/codemirror/theme/neat.css',
 'client/codemirror/theme/night.css',
 'client/codemirror/theme/rubyblue.css',

 'client/codemirror/theme/twilight.css',
 'client/codemirror/theme/vibrant-ink.css',
 'client/codemirror/theme/xq-dark.css'
 */

