try {
    Package.describe({
        "summary": "Versatile and powerful logging and application management (http://observatoryjs.com)",
        "version": "0.9.2",
        "name": 'superstringsoft:observatory-beta',
        "git": "https://github.com/superstringsoftware/observatory.git"
    });

    Package.on_use(function (api) {
        api.versionsFrom(["METEOR@1.1.0.3"]);
        var both = ['client', 'server'];
        api.use(['coffeescript', 'underscore', 'standard-app-packages', 'ejson'], both);
        api.use('accounts-password', 'server');

        // galileo files
        api.add_files('lib/lib/observatory-galileo/src/MessageEmitter.coffee', both);
        api.add_files('lib/lib/observatory-galileo/src/GenericEmitter.coffee', both);
        api.add_files('lib/lib/observatory-galileo/src/Logger.coffee', both);
        api.add_files('lib/lib/observatory-galileo/src/ConsoleLogger.coffee', both);
        api.add_files(['lib/lib/observatory-galileo/src/Observatory.coffee', 'lib/lib/observatory-galileo/src/Toolbox.coffee'], both);


        api.add_files('lib/lib/auth/auth.coffee', 'server');

        api.add_files('lib/server/MeteorInternals.coffee', 'server');
        api.add_files('lib/server/ObservatoryServer.coffee', 'server');
        api.add_files('lib/server/ObservatoryMongo.coffee', 'server');
        api.add_files('lib/server/emitters/DDPEmitter.coffee', 'server');
        api.add_files('lib/server/emitters/DDPConnectionEmitter.coffee', 'server');
        api.add_files('lib/server/emitters/HttpEmitter.coffee', 'server');
        api.add_files('lib/server/emitters/MonitoringEmitter.coffee', 'server');
        api.add_files('lib/server/emitters/SystemEmitter.coffee', 'server');
        api.add_files('lib/MeteorLogger.coffee', both);

        api.add_files('lib/Settings.coffee', both);
        api.add_files('lib/server/Settings.coffee', 'server');
        api.add_files('lib/client/Settings.coffee', 'client');

        // loading CommandProcessor module
        api.add_files('features/CommandProcessor/server/CommandServer.coffee', 'server');
        api.add_files('features/CommandProcessor/server/methods.coffee', 'server');
        api.add_files('features/CommandProcessor/client/CommandClient.coffee', 'client');

        // automagical
        api.add_files('features/automagical-overloaded/subscriptions.coffee', 'client');
        api.add_files('features/automagical-overloaded/collections.coffee', both);

        api.add_files('lib/server/Observatory.coffee', 'server');
        api.add_files('lib/server/methods.coffee', 'server');
        api.add_files('lib/client/Observatory.coffee', 'client');

        api.add_files(['lib/Observatory.coffee'], both);
        api.add_files('globals.js', both);
        api.export('Observatory');

    });
}
catch (err) {
    console.log("Error while trying to load a package: " + err.message);
}
