Package.describe({
  summary: "Powerful, yet easy to use, logging and monitoring package"
});

Package.on_use(function (api) {
  api.use(['coffeescript', 'bootstrap', 'underscore', 'templating','less'], 'client');

  api.add_files([
  	'observatory.coffee',
    'inspect.js',
    'client/observatory.html',
    'client/observatoryTemplates.coffee',
    'client/observatory.less'], 'client');

  api.add_files('observatory.coffee','server');
  api.add_files('inspect.js','server');
});
