try {
    Package.describe({
        summary: "Observatory: Apollo. Lightweight but versatile logger, part of Observatory suite (http://observatoryjs.com)"
    });

    Package.on_use(function (api) {
        api.use(['coffeescript', 'underscore','standard-app-packages','ejson'], ['client','server']);
        //api.use(['webapp'], ['server']);

        api.add_files('TLog.coffee',['client','server']);
        api.add_files('connectHook.coffee','server');
        api.add_files('monitoringHooks.coffee','server');
        api.add_files('Monitor.coffee','server');

        api.export (['TLog','Inspect','Observatory'], ['client','server']);
    });
}
catch (err) {
    console.log("Error while trying to load a package: " + err.message);
}
