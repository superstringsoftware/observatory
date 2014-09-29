try {
    Package.describe({
        summary: "Versatile and powerful logging and application management (http://observatoryjs.com)",
        "version": "0.4.6",
        "git": "https://github.com/superstringsoftware/observatory.git"

    });

    Package.on_use(function (api) {
        api.versionsFrom("METEOR@0.9.0");
        //console.log("loading observatory: apollo -- now working with Meteor 0.9");
        api.use(['coffeescript', 'underscore','standard-app-packages','ejson'], ['client','server']);
        api.use('accounts-password', 'server')
        //api.use(['webapp'], ['server']);

        // galileo files
        api.add_files(['lib/lib/observatory-galileo/src/Observatory.coffee','lib/lib/observatory-galileo/src/Toolbox.coffee'],['client','server']);

        api.add_files('lib/server/MeteorInternals.coffee','server');
        api.add_files('lib/server/ObservatoryServer.coffee','server');
        api.add_files('lib/server/DDPEmitter.coffee','server');
        api.add_files('lib/server/DDPConnectionEmitter.coffee','server');
        api.add_files('lib/server/HttpEmitter.coffee','server');
        api.add_files('lib/server/MonitoringEmitter.coffee','server');
        api.add_files('lib/MeteorLogger.coffee',['client','server']);
        //api.add_files('lib/server/monitoringHooks.coffee','server');

        api.add_files('lib/Settings.coffee',['client','server']);
        api.add_files('lib/server/Settings.coffee','server');
        api.add_files('lib/client/Settings.coffee','client');


        api.add_files('lib/server/Observatory.coffee','server');
        api.add_files('lib/client/Observatory.coffee','client');

        api.add_files('lib/client/templates.coffee','client');

        api.add_files(['lib/Observatory.coffee'],['client','server']);

        api.add_files('globals.js',['client','server']);

        api.export ('Observatory');
        api.export ('TLog');



        //console.dir(Observatory);


    });
}
catch (err) {
    console.log("Error while trying to load a package: " + err.message);
}
