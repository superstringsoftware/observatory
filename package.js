try {
    Package.describe({
        summary: "Observatory: Apollo. Versatile and powerful logger package, part of Observatory suite (http://observatoryjs.com)"
    });

    Package.on_use(function (api) {
        console.log("loading observatory: apollo");
        api.use(['coffeescript', 'underscore','standard-app-packages','ejson'], ['client','server']);
        //api.use(['webapp'], ['server']);

        api.add_files('lib/server/ObservatoryServer.coffee','server');
        api.add_files('lib/server/DDPEmitter.coffee','server');
        api.add_files('lib/server/HttpEmitter.coffee','server');
        api.add_files('lib/MeteorLogger.coffee',['client','server']);
        api.add_files(['lib/TLog.coffee', 'lib/Observatory.coffee'],['client','server']);
        api.add_files('lib/monitoringHooks.coffee','server');
        api.add_files('lib/Monitor.coffee','server');

        api.add_files('lib/client/templates.coffee','client');
        

        api.export (['TLog','Inspect','Observatory'], ['client','server']);
    });
}
catch (err) {
    console.log("Error while trying to load a package: " + err.message);
}
