# Simmer

Simmer is a command line utility to generate scaffolding, migrations, and other boilerplate code for Vapor applications. It uses multiple commands to be able to generate models, controllers, views, protocols, and resources for Vapor backed servers. It follows a strict folder structure for your application, so the ability to generate the contents of the file is allowed without actually writing to your project.
Simmer also relies on a few Swift packages for generating responses in controllers and managing migrations:

## Dependencies
* AutoMigrator: pulls migrations automatically without explicitly telling the application to load it.
* FormattedResponse: Response handler to switch between formats without needing to define different routes.  

## Models
The models folder is where the base file for each model lives. This includes
the type definitions for the model, the schema name, and initialization code. The
default migration is added when a model is created to the migrations folder as
opposed to residing in the model itself, keeping resources separate.

## Controllers
Controllers are how the application interacts with clients. By default, both Web
and API controllers are generated for simmer. The reasoning is that there are
different attributes that may be exposed for an API versus the Web representation,
especially with Leaf templates. However, if basic CRUD operations are all that are
needed, Scaffold and Model both accept the --basic flag which will generate a
single controller for the Model. If --skip-web or --skip-api is passed to scaffold,
only the necessary representable and file will be generated. 

## Migrations
The migrations folder holds all the migrations for models. They are generated using
MTimestamp_MigrationName format, to ensure that all migrations are run in order.
If the migration is generated for a model, that models resource folder is updated
to include the migration. If the migration is not for a model, the migration
is appended to the main routes file. To pass a model to an individual migration
file, use --model ModelName or -m ModelName.

## Tests

---

# Development
To be able to run in your own project without installing through homebrew, you can run `swift run build --configuration release` and then copy the output into your path.

The folder structure for adding new commands is as follows:

All code starts in the `Commands` folder. All commands should be named `XxxCommand` and should have a \_commandName of `xxx`. The commands then call into the `FileLoader` folder. These use the files in `DefaultFiles` to find and replace information. `Generators` can be used to manage data to make the data easily repeatable should it need to be used in another `FileLoader`. The `FileLoader` should be the only file to actually write to the `Sources` folder.
