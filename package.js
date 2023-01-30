try {
    Package.describe({
        "summary": "Versatile and powerful logging and application management (http://observatoryjs.com)",
        "version": "2.0.0",
        "name": 'superstringsoft:observatory',
        "git": "https://github.com/superstringsoftware/observatory.git"
    });

    Package.onUse(function (api) {
        api.versionsFrom(["METEOR@2.10.0"]);
        var both = ['client', 'server'];
        api.use(['coffeescript', 'underscore', 'standard-app-packages', 'ejson'], both);
        api.use('accounts-password', 'server');

        // galileo files
        api.addFiles('lib/lib/observatory-galileo/src/MessageEmitter.coffee', both);
        api.addFiles('lib/lib/observatory-galileo/src/GenericEmitter.coffee', both);
        api.addFiles('lib/lib/observatory-galileo/src/Logger.coffee', both);
        api.addFiles('lib/lib/observatory-galileo/src/ConsoleLogger.coffee', both);
        api.addFiles(['lib/lib/observatory-galileo/src/Observatory.coffee', 'lib/lib/observatory-galileo/src/Toolbox.coffee'], both);


        api.addFiles('lib/lib/auth/auth.coffee', 'server');

        api.addFiles('lib/server/MeteorInternals.coffee', 'server');
        api.addFiles('lib/server/ObservatoryServer.coffee', 'server');
        api.addFiles('lib/server/ObservatoryMongo.coffee', 'server');
        api.addFiles('lib/server/emitters/DDPEmitter.coffee', 'server');
        api.addFiles('lib/server/emitters/DDPConnectionEmitter.coffee', 'server');
        api.addFiles('lib/server/emitters/HttpEmitter.coffee', 'server');
        api.addFiles('lib/server/emitters/MonitoringEmitter.coffee', 'server');
        api.addFiles('lib/server/emitters/SystemEmitter.coffee', 'server');
        api.addFiles('lib/MeteorLogger.coffee', both);

        api.addFiles('lib/Settings.coffee', both);
        api.addFiles('lib/server/Settings.coffee', 'server');
        api.addFiles('lib/client/Settings.coffee', 'client');

        // loading CommandProcessor module
        api.addFiles('features/CommandProcessor/server/CommandServer.coffee', 'server');
        api.addFiles('features/CommandProcessor/server/methods.coffee', 'server');
        api.addFiles('features/CommandProcessor/client/CommandClient.coffee', 'client');

        // automagical
        api.addFiles('features/automagical-overloaded/subscriptions.coffee', 'client');
        api.addFiles('features/automagical-overloaded/collections.coffee', both);

        api.addFiles('lib/server/Observatory.coffee', 'server');
        api.addFiles('lib/server/methods.coffee', 'server');
        api.addFiles('lib/client/Observatory.coffee', 'client');

        api.addFiles(['lib/Observatory.coffee'], both);
        api.addFiles('globals.js', both);
        api.export('Observatory');

    });
}
catch (err) {
    console.log("Error while trying to load a package: " + err.message);
}
