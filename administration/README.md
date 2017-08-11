Architecture overview
=====================

Basic Drawing:
--------------

![](images/admin-basic-drawing.png)

Basic explanation:
------------------

###Cores

DataRobot Enterprise Edition is available as a per-core annual software license that is deployed on customers’ hardware - whether on-premise or on a private cloud. The Platform edition of DataRobot is targeted for large enterprises as well as businesses and organizations in regulated industries that cannot use a public cloud service for analytics.

The pricing is straightforward and reflects the value that lies in the computation required to build accurate predictive models in addition to deploying them for predictions. It is based on the number of CPU cores that DataRobot is deployed on.

###Memory

Practically speaking, DataRobot can handle up to 100GB of data for training models. With datasets of this size, we make sure to try out both in-memory and distributed algorithms to determine which is the best fit for your specific dataset. We downsample the data to fit the RAM available in a single server and train models using single instance algorithms. We also run the entire dataset (or as much of it that can fit) on a Spark cluster and train distributed algorithms from MLlib. Those results are then available on the "Leaderboard" for you to review and compare.

###Queues

The "Worker Usage" interface (located on the right sidebar of the application)  functions as a live activity feed that displays the file imports and model building queues. This interface is always visible on the right-hand side of the application.

Workers types
-------------

###EDA

When you begin a new project by importing a dataset file, the "Worker Usage" interface appears and you can clearly see it processing three steps: (1) Uploading Data, (2) Reading raw data, and (3) Exploratory Data Analysis. Once the file import is complete, you can see how long it took for the "Worker User" interface to complete each of those three steps in the queue. The timestamps are written directly underneath each numbered step along with a green green checkmark to indicate that each step was completed.

![](images/worker-types-eda.png)

###Modeling

Once you choose a prediction target topic from your dataset and select your preferred settings, you can then “Start” the model building process.

![](images/modeling-worker-type.png)

Once DataRobot begins building models, the "Worker Usage" interface will display and process through another numbered list of steps to begin building each model.

![](images/modeling-worker-type-2.png)

Then, the modeling queue will start and display a list of model names being queued up and built for your dataset. You are able to view the queue of models that have yet to execute, and the running execution of the model on a worker (a cpu instance). Each project has its own "Job Queue", which services model computation requests from the corresponding Modeling Dashboard instance. Every job either executing or in the queue can be deleted at any time. A job in the queue displays the title of the model to run, the % sample size, and the number that represents the cross validation (CV) set.

![](images/modeling-worker-type-3.png)

There are three Modeling Modes that affect how DataRobot functions and builds models for you.

(MAKE TABLE):

***Note:*** If you select either the Autopilot or Quick modes, DataRobot will select only the relevant models that fit best with your dataset and prediction need.

###Prediction

As each model is built, it is added to the "Leaderboard" located under the "Models" tab. The "Leaderboard" lists every model built for your particular dataset in order of accuracy and speed with the fastest and most accurate models on top. You can now make predictions based off of these models using two methods: (1) importing and making predictions on a new dataset, or (2) making predictions on the original dataset.

![](images/worker-type-prediction.png)

When you make predictions off of these models, the queue again appears on the right-hand side to show a live feed of the progress being made and the work being done on the predictions.

![](images/worker-type-prediction2.png)

###Worker count vs. worker availability for shared projects

At the top of the "Worker Usage" interface is the worker count that is automatically set to 4. This indicates that there are 4 workers currently being used for your project. You can either increase or decrease the number of workers by clicking either the up or down arrows located next to the worker count number. A higher worker count number means that projects can be processed quickly, compared to having only 1 or 2. You can also pause the workers from building models, and also resume the process by clicking the Play/Pause icon located to the left of the Worker count.

![](images/modeling-worker-type-4.png)

You will notice that you are initially set to a 4 worker limit. This can worker limit can be changed by the Admin. Admins have access to the management console, which allows them to create groups within their organization. Once these group-based worker assignments are created, Admins can then set modeling limits for their groups. This means that Admins can set a cap on the number of workers that each group can use, which minimizes resource contention throughout organizations.

Hadoop Drawing:
---------------

![](images/admin-hadoop-drawing.png)

###Hadoop explanation as it differs from basic

There are four main differences between DataRobot Hadoop and the standard deploy: 1) Model building uses existing Hadoop data nodes resources, 2) Hadoop has the ability to perform high-throughput scoring using Spark, 3) Hadoop’s cluster resources and DataRobot are managed by YARN, and 4) DataRobot can utilize Hadoop resource to allow bigger data ingest and model building (5GB vs 10GB).

Security
---------

###LDAP

LDAP (Lightweight Directory Access Protocol) is a directory service access  protocol used for centralized or single-signon authentication. SLDAP or LDAPS are the same, both means LDAP over SSL (SSL encrypted connection to LDAP server).

DataRobot supports LDAP, but uses different LDAP attributes for different directory service products such as MS AD, Open LDAP, Oracle Internet Directory, iPlanet, Oracle Virtual Directory, and IBM Directory. This means that the attribute configuration for different products will be different.

LDAP is the protocol that communicates with the directory service, allowing the directory server and LDAP client to communicate effectively with each other in order to validate users during application login.

![](images/ldap-sign-in-admin.png)

DataRobot can authenticate users through the configured LDAP. A user’s login information is sent over from DataRobot and checked against the Directory Service through LDAP. If that user’s information is valid, that result is sent back and an entry is then created for that user in DataRobot.

Note: When a first-time user is authenticated through LDAP, only their username is created and saved in DataRobot - not their password. This is a one-time process that only happens for the first login.

DataRobot stores users in email format (the domain that represents that organization) for the internal DataRobot authentication.

![](images/ldap-admin-org-domains.png)

However, LDAP users only have a simple username that appear in a list on DataRobot.

![](images/admin-ldap-usernames.png)

When a user has been validated with their initial LDAP login, the organization’s admin can go into DataRobot to set permissions for that user under the Manage Users section located in their profile dropdown menu.

![](images/ldap-admin-manage-users.png)

1. Select a user by clicking on their username to access that user’s account information. ![](images/ldap-admin-select-user.png)

2. You are now viewing that user’s profile. Click Change Permissions to see a list of each individual permission.![](images/admin-ldap-username-permission.png)

3. Now you can Enable or Disable features for this user by checking the boxes, or leaving them blank. You can also set this user’s organization, number of workers, and a file upload size limit. ![](images/ldap-admin-user-permissions.png)

Having an LDAP supported directory service keeps all of the users and organizations categorised and accessible. Any updates made in LDAP Directory server  will automatically update every application without the need to manually search and edit each one individually. For example, if a user is removed from Directory server, the application which is configured to authenticate to this particular Directory server won’t allow the removed user to login. This is a streamlined and efficient way for admins to accurately manage the DataRobot application authentication for large companies.

###About config.yaml

Part of config.yaml is involved with LDAP configuration as a step in the protocol process of reading and authenticating in every user’s login information (username and password) from the client’s LDAP supported Directory Service such as MS AD. Config.yaml is master configuration file for the DataRobot cluster,  this facilitates the passage of user information between DataRobot and LDAP supported Directory Service in the organization for centralized user authentication.

The following is an example of LDAP configuration for Microsoft Active Directory in config.yaml file:

```
app_configuration:

 drenv_override:

   USER_AUTH_LDAP_BIND_DN: tuser1@example.com

   USER_AUTH_LDAP_BIND_PASSWORD: &#039;&lt;clear text password here&gt;&#039;

   USER_AUTH_LDAP_GLOBAL_OPTIONS: &#039;[]&#039;

   USER_AUTH_LDAP_SEARCH_BASE_DN: ou=datarobot,dc=example,dc=com

   USER_AUTH_LDAP_SEARCH_FILTER: (&amp;(objectClass=user)(sAMAccountName=$username))

   USER_AUTH_LDAP_URI: ldap://ad-controller.example.com:389

   USER_AUTH_TYPE: ldapsearch
```
 o