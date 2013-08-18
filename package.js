try {
    Package.describe({
        summary: "Observatory: Apollo. Lightweight but versatile logger, part of Observatory suite (http://observatoryjs.com)"
    });

    Package.on_use(function (api) {
        //observatory-settings may not exist, so catch any errors
        try {
            api.use('observatory-settings');
        } catch (err){
        }

        api.use(['coffeescript', 'underscore'], ['client','server']);

        api.add_files('TLog.coffee',['client','server']);
        api.add_files('connectHook.coffee','server');
        api.add_files('monitoringHooks.coffee','server');
        api.add_files('Monitor.coffee','server');
    });
}
catch (err) {
    console.log("Error while trying to load a package: " + err.message);
}