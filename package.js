try {
Package.describe({
  summary: "Powerful, yet easy to use, logging and monitoring package"
});

Package.on_use(function (api) {
  api.use(['coffeescript', 'bootstrap', 'underscore','templating','less'], 'client');

  api.add_files('logging/observatory.coffee','server');
  api.add_files('monitoring/server/connectHook.coffee','server');
  api.add_files('logging/lib/inspect.coffee','server');
  api.add_files('client/codemirror/codemirror.js','client');
  api.add_files('client/codemirror/javascript.js','client');
  api.add_files('client/codemirror/codemirror.css','client');
  api.add_files([
      'client/codemirror/theme/ambiance.css',
      'client/codemirror/theme/solarized.css'],'client');

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
  ]*/


  api.add_files([
  	'logging/observatory.coffee',
    'logging/lib/inspect.coffee',
    'logging/client/observatory.html',
    'logging/client/observatoryTemplates.coffee',
    'logging/client/observatory.less',

  ], 'client');

});
}
catch (err) {
  console.log("Error while trying to load a package: " + err.message);
};
