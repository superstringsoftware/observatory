try {
Package.describe({
  summary: "Powerful, yet easy to use, logging, monitoring and application management package. See http://observatoryjs.com for full details."
});

Package.on_use(function (api) {
  api.use(['coffeescript', 'underscore','templating','less'], 'client');
  api.use (['observatory-galileo', 'observatory-apollo'], ['client','server']);
  
  console.log("...loading observatory");
  console.log("This is version 0.3.0 with completely redesigned architecture and a host of new features available - ");
  console.log("please check out http://observatoryjs.com for details. There's automagical logging, profiling, application monitoring and more.");

  api.add_files('lib/codemirror/codemirror.js','client');
  api.add_files('lib/codemirror/javascript.js','client');
  api.add_files('lib/codemirror/coffeescript.js','client');
  api.add_files('lib/codemirror/codemirror.css','client');
  api.add_files([
      'lib/codemirror/theme/ambiance.css',
      'lib/codemirror/theme/solarized.css'],'client');
  api.add_files([
    'mars/observatory.html',
    'mars/observatoryTemplates.coffee',
    'mars/observatory.less'
    ], 'client');

});
}
catch (err) {
  console.log("Error while trying to load a package: " + err.message);
};

/*

api.add_files('lib/codemirror/xml.js','client');
  api.add_files('lib/codemirror/htmlmixed.js','client');
  api.add_files('lib/codemirror/css.js','client');
  api.add_files('lib/codemirror/markdown.js','client');
  


 */

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

