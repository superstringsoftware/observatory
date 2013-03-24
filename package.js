try {
    Package.describe({
        summary: "Observatory: Apollo. Lightweight but versatile logger, part of Observatory suite (http://observatoryjs.com)"
    });

    Package.on_use(function (api) {
        api.use(['coffeescript', 'underscore'], ['client','server']);

        api.add_files('TLog.coffee',['client','server']);
        api.add_files('connectHook.coffee','server');

    });
}
catch (err) {
    console.log("Error while trying to load a package: " + err.message);
};
