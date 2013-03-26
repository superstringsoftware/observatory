try {
    Package.describe({
        summary: "Observatory: Apollo. Lightweight but versatile logger, part of Observatory suite (http://observatoryjs.com)"
    });

    Package.on_use(function (api) {
        api.use(['coffeescript', 'underscore'], ['client','server']);

        api.add_files('lib/TLog.coffee',['client','server']);
        api.add_files('lib/connectHook.coffee','server');
        api.add_files('lib/monitoringHooks.coffee','server');
        api.add_files('lib/Monitor.coffee','server');

    });
}
catch (err) {
    console.log("Error while trying to load a package: " + err.message);
};
