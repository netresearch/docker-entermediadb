# EnterMediaDB

This is an image running [the EnterMediaDB Digital Asset Management System](http://entermediadb.org/) on an [openjdk base image](https://hub.docker.com/_/openjdk/).

## What is EnterMediaDB

> EnterMedia is an open source, flexible, web-based media database to help manage digital assets. The user interface is sleek, simple, and easy to use. With focus on security, scalability, and customization, this product is ideal for complex needs of an enterprise environment. 

*(Quoted from [EnterMediaDB website](http://entermediadb.org/media_database_overview/))*

## How to use this image

### Run

```bash
docker run --name entermediadb -p 8080:8080 -d netresearch/entermediadb
```

Navigate to http://whateveryourhostis:8080 - the default username as well as the password are **admin**.

### Data directory

The data directory is at `/media/data` - in order to mount your data directory from outside, add `-v my-data-dir:/media/data` to the options of the `docker run` command above. 

## GitHub

If you have any problems, questions, feature requests or simply stars to give please visit the [GitHub repository](https://github.com/netresearch/docker-entermediadb).