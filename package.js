try {
    Package.describe({
        summary: "Observatory: Apollo. Lightweight but versatile logger, part of Observatory suite (http://observatoryjs.com)"
    });

    Package.on_use(function (api) {
        api.use(['coffeescript', 'underscore','standard-app-packages','ejson'], ['client','server']);
        //api.use(['webapp'], ['server']);

        api.add_files(['lib/TLog.coffee','lib/EventLogger.coffee'],['client','server']);
        api.add_files('lib/connectHook.coffee','server');
        api.add_files('lib/monitoringHooks.coffee','server');
        api.add_files('lib/Monitor.coffee','server');

        api.add_files('lib/client/templates.coffee','client');

        api.export (['TLog','Inspect','Observatory'], ['client','server']);
    });
}
catch (err) {
    console.log("Error while trying to load a package: " + err.message);
}
