

# Build
Please see `Prerequisites` for building and running services.

Create a new directory (e.g. /tmp/new-snack-services).

Get all the latest source code into the above directory:

```
mkdir -p /tmp/new-snack-services
cd /tmp/new-snack-services
git clone https://github.com/sunday-take-away/employee-containers.git
git clone https://github.com/sunday-take-away/employee-service.git
git clone https://github.com/sunday-take-away/event-service.git
```

build services using script from `employee-containers`. 
This will build both the employee and event services with sbt and maven respectively.

```
cd /tmp/new-snack-services/employee-containers
./build-services.sh
```

# Run
Software will be run in local docker network.
Use docker compose to run all relevant containers.

```
cd /tmp/new-snack-services/employee-containers
docker-compose up
```

## Accessing services
Using a web browser, you can access the following services:

* `employee-service` - http://localhost:8001
* `event-service` - http://localhost:8002

Employee service has some rest methods which need authentication, use username and password from table below  
(change localhost is domain is different).

## Monitoring messages
Using a web browser, you can log into `RabbitMQ` admin UI.

http://localhost:15672 

Use username and password from table below 
(change localhost is domain is different).

## Usernames and Password
This is not intended to be highly secure, so passwords are listed here for demonstration/reproducing connectivity.\
Interface is for localhost, if this is run on cloud replace localhost with appropriate domain.

| Username      | Password      |        Interface         |               Description             |
| ------------- | ------------- | ------------------------ | ------------------------------------- |
| admin         | SnackHack     | http://localhost:15672   | RabbitMQ Admin UI                     |
| service       | SnackAttack   | localhost:5672           | RabbitMQ message queue                |
| admin         | TakeAnAdmin   | http://localhost:8083    | InfluxDB Admin UI                     |
| service       | TakeASnack    | http://localhost:8086    | InfluxDB query                        |
| admin         | HackASnack    | http://localhost:8001    | Employee Service rest authorization   |

# Prerequisites
You need the following to build and run software.
Assume that you are using mac or linux and all commands can be run from a terminal/console.

## Prerequisite build software 
* git
* java
* maven 
* scala
* sbt

## Prerequisites run software
* docker 
* docker compose

# Notes

How does this all fit together?

Essentially docker compose, orchestrates all docker containers. 
All these containers run in their own private network.
The `employee-service` stores data in `MongoDB` and sends events to `RabbitMQ`.
Messages on `RabbitMQ` are durable, meaning they are persistent until they are consumed.
The `event-service` collects messages from `RabbitMQ` and stores these in `InfluxDB`.

```
     _______________________         ________________          _______________________ 
    |                       |       /                \        |                       | 
    |    employee-service   | ===>  |    RabbitMq    |  ===>  |     event-service     |  
    |_______________________|       \________________/        |_______________________|
      
              |                                                          |
       _________________                                          _________________
      /                 \                                        /                 \
      \_________________/                                        \_________________/
       |                |                                         |                |
       |    MongoDB     |                                         |    InfluxDB    |
       \________________/                                         \________________/      
      
```



## Architecture
Services are fairly performant and light weight, below are some of the software choices made. 

### RabbitMQ 
Chosen for simplicity for Advanced Message Queue Protocol message queue.
For improved performance I would choose Kafka.

### MongoDB 
Chosen for simplicity to store employee data.
For even greater performance one can distribute these databases and shard them accordingly, 
this was not necessary for these services.

### InfluxDB
Chosen for ability to query and store event data. I'm just treating all events as time-series data.
For improved performance I would choose Casandra.

### Micro-services architecture
Microservices should be composable and should be treated as a 'black box'. 

#### Employee Service
For the `employee-service` scala with akka was employed to store and send events to message queue.
This service should be non-blocking, asynchronous and have the ability to scale.
For improved performance service can be clustered and distributed with kubernetes. 
Akka Http with own bootstrapping mechanics is used, I believe in fine grained traits and these could be lifted out 
to create an Akka/Http boot core module in order to simplify future services.

#### Employee Service
For the `event-service` java with spring boot was employed to receive events and store these in time-series fashion.
This service is fairly simple to construct. For improved performance I would use Akka Streams or Spring Data Streams, 
and have multiple instances of this service using kubernetes.

