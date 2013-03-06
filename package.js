Package.describe({
  summary: "Powerful, yet easy to use, logging and monitoring package"
});

Package.on_use(function (api) {
  api.use(['coffeescript', 'bootstrap', 'underscore', 'templating','less'], 'client');

  api.add_files([
  	'logging/observatory.coffee',
    'logging/lib/inspect.js',
    'logging/client/observatory.html',
    'logging/client/observatoryTemplates.coffee',
    'logging/client/observatory.less',
    'testing/mtest.coffee',
    'testing/sampleTests.coffee',
    'testing/client/mtestsTemplates.coffee',
    'testing/client/lib/chai.js'
  ], 'client');

  api.add_files('logging/observatory.coffee','server');
  api.add_files('logging/lib/inspect.js','server');
  api.add_files('testing/mtest.coffee','server');
  api.add_files('testing/sampleTests.coffee','server');
});
