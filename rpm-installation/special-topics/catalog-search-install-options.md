# Catalog Search Install Options

The AI Catalog search can be configured with different search install options.

# Option 1

Deploy ElasticSearch on dedicated nodes.

# Option 2

Deploy ElasticSearch withing the DataRobot cluster on a shared node. This is recommended for non-english or medium installs.

# Option 3

Don't deploy ElasticSearch at all, and instead enable the catalog regex search. This is recommended for smaller installs, only english is supported at the moment.

## Public API environment variables

### TRY_MONGO_REGEX_CATALOG_SEARCH

Search the catalog with a case sensitive prefix regex search.

### TRY_ADVANCED_MONGO_REGEX_CATALOG_SEARCH

Search the catalog with a case insensitive regex search. Will give you the best non-elastic search experience but is only recommended for installs with a catalog containing less than 500 catalog items.
