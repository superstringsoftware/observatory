try {
    Package.describe({
        "summary": "Versatile and powerful logging and application management (http://observatoryjs.com)",
        "version": "0.4.9-rc.1_4",
        "name": 'superstringsoft:observatory-beta',
        "git": "https://github.com/superstringsoftware/observatory.git"
    });

    Package.on_use(function (api) {
        api.versionsFrom(["METEOR@1.1.0.3"]);
        var both = ['client', 'server'];
        api.use(['coffeescript', 'underscore', 'standard-app-packages', 'ejson'], both);
        api.use('accounts-password', 'server');

        // galileo files
        api.add_files(['lib/lib/observatory-galileo/src/Observatory.coffee', 'lib/lib/observatory-galileo/src/Toolbox.coffee'], both);

        api.add_files('lib/server/MeteorInternals.coffee', 'server');
        api.add_files('lib/server/ObservatoryServer.coffee', 'server');
        api.add_files('lib/server/ObservatoryMongo.coffee', 'server');
        api.add_files('lib/server/DDPEmitter.coffee', 'server');
        api.add_files('lib/server/DDPConnectionEmitter.coffee', 'server');
        api.add_files('lib/server/HttpEmitter.coffee', 'server');
        api.add_files('lib/server/MonitoringEmitter.coffee', 'server');
        api.add_files('lib/server/SystemEmitter.coffee', 'server');
        api.add_files('lib/MeteorLogger.coffee', both);

        api.add_files('lib/Settings.coffee', both);
        api.add_files('lib/server/Settings.coffee', 'server');
        api.add_files('lib/client/Settings.coffee', 'client');

        api.add_files('lib/server/Observatory.coffee', 'server');
        api.add_files('lib/client/Observatory.coffee', 'client');
        api.add_files('lib/client/templates.coffee', 'client');
        api.add_files(['lib/Observatory.coffee'], both);
        api.add_files('globals.js', both);
        api.export('Observatory');
        api.export('TLog');
    });
}
catch (err) {
    console.log("Error while trying to load a package: " + err.message);
}
