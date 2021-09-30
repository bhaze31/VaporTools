# Rapid Boil

Rapid boil is a command line utility to generate scaffolding code for Vapor
applications. It uses multiple commands to be able to generate models, controllers,
views, protocols, and resources for Vapor backed servers. It follows a strict folder
structure as follows:

## Models
The models folder is where the base file for each model lives. This includes
the type definitions for the model, the schema name, and initialization code. The
default migration is added when a model is created to the migrations folder as
opposed to residing in the model itself, keeping resources separate.

Each model also gets a Model+WebController and Model+APIController files if no
flag is passed to conform to the resource protocol. To not generate a resource
file, pass --skip-web or --skip-api to ignore these files.

## Migrations
The migrations folder holds all the migrations for models. They are generated using
MTimestamp_MigrationName format, to ensure that all migrations are run in order.
If the migration is generated for a model, that models resource folder is updated
to include the migration. If the migration is not for a model, the migration
is appended to the main routes file. To pass a model to an individual migration
file, use --model ModelName or -m ModelName.

## Controllers
Controllers contain two sub folders by default, API and Web. API controllers are
by default sub-routed with /api, but this can be overwritten using --route Route
or -r Route. Web controllers use the model name and basic REST standards for the
routing.

Each controller conforms to their respective protocol that is generated when the
app is bootstrapped by the rapid-boil initiate command.
