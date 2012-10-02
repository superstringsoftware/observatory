Package.describe({
  summary: "Simple & pretty logger"
});

Package.on_use(function (api) {
  api.use(['coffeescript', 'bootstrap', 'underscore', 'templating','less'], 'client');

  api.add_files([
  	'telescope.coffee',
    'client/logs.html',
    'client/logs.coffee',
    'client/logs.less'], 'client');

  api.add_files(
    'telescope.coffee',
  		'server');
});
