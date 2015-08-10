Parking Lot
===========

This is a simple project to facilitate domain parking and redirects.

It consists of:

 - Ubuntu 14.04 (Trusty) base OS
 - Apache 2.4
 - Apache virtual host configuration files
 - A test script for each vhost config file
 - Packer template for AMI generation
 - Docker templets for running Apache testing in a container
 - Build and testing scripts for local and TeamCity (build server)
 - Cloudformation template for the running web server cluster in AWS

### Usage

The process of getting a new domain parked or redirected is:
1. Add the vhost configuration to $root/sites/(name).conf
1. Add a test script to $root/testing/tests/(name).sh which should sufficently
   test that the URLs you intend to redirect work correctly (see existing scripts)

Optionally (and recommended), if you would like to run the tests locally:
1. Build a docker image for testing (only needed the first time)
1. Run tests in running Docker image

Once you push your commit to the repository, a TeamCity trigger will activate
and kick off the tests and build. If successful, the resulting configuration
is pushed to and S3 bucket.

The running web servers will check and download an updated tarball every 5
minutes, triggered (and staggered) by cron.

The docker image and AMI are also generated by TeamCity projects, which are
also built automatically by their TeamCity project configurations.

If you commit any changes to the docker/ or scripts/ directories, a new
docker image will be generated, and uploaded to the dockreg.gutools.co.uk:8080
docker registry we have hosted internally.

Same goes for the Packer AMI generation. Any changes to the packer/ or scripts/
directories will trigger a new AMI to be generated and made available in the
AWS account.

### Requirements

You will probably need to run these scripts on a Linux box and require:

 - AWS CLI tools
 - Git
 - Docker (for local testing)
 - Packer (for AMI generation only)

You will also need your AWS credentials available in your environment.
For example:

	AWS_ACCESS_KEY_ID=(key)
	AWS_SECRET_ACCESS_KEY=(secret)

This project is running in the 'aws' account. See Andy or Troy for access.


### Building the Docker test containter

Firstly, you will need Docker installed and available in your path.

To build the container, run the build script:

	$ cd docker/
	$ ./build-local.sh

This will download the latest Ubuntu 14.04 Docker image and run the build
scripts to install and configure Apache.

Once it's done, it should be available in your local Docker registry:

	$ docker images
	REPOSITORY    TAG     IMAGE ID      CREATED        VIRTUAL SIZE
	parking-lot   latest  18bd9197758b  5 minutes ago  207.3 MB


### Running the build script

Once you have a local docker container available, you can run the test suite
against it.

Run the local build script like this:

	$ ./build-local.sh 
	Booting container...
	Running tests...
	all 2 default-vhost tests passed in 0.018s.
	all 4 guardian-public tests passed in 0.033s.
	all 291 gmgplc tests passed in 3.720s.
	parking-lot/
	parking-lot/sites/
	parking-lot/sites/gmgplc.conf
	parking-lot/sites/guardian-public.conf
	parking-lot/sites/000-default.conf
	Uploading to S3...
	upload: ./parking-lot.tar.gz to s3://parking-lot/PROD/parking-lot.tar.gz
	upload: ./parking-lot-version.txt to s3://parking-lot/PROD/parking-lot-version.txt
	upload: ./parking-lot.sha256 to s3://parking-lot/PROD/parking-lot.sha256
	Cleaning up...

This shows a successful test run, with the result sent to S3 to be applied.


### Updating the AWS AMI

If the running hosts need to be updated at all, the changes can be make in the
packer or scripts directories.

The packer template copies the $root/scripts directory when building the AMI,
so any customisation can be done from there.

Most of the building work is done via the $root/scripts/setup.sh script. This
script is also shared with the Docker container build also, to keep the 
development and production environments as similar as possible.

You can build the new AMI by:

	$ cd packer/
	$ ./build-local.sh

When you're satisfied that the AMI is OK and have committed any changes, look
on TeamCity for the parking-lot-ami project for the latest build log to find
the AMI last generated. You can also find it in the AWS console too.


### Updating the Parking Lot cluster in AWS

The cluster has been built using CloudFormation, and the template is
stored in this repository, along with a helper script.

Using the latest AMI generated (NOTE: Need a nicer way to find the latest), you
can update the CloudFormation stack by running the command:

    $ cd cloudformation
	$ ./stack.sh -a update -m ami-729ccd05 -s PROD
	Configuring stack...
	arn:aws:cloudformation:eu-west-1:528313740988:stack/parking-lot-PROD/5fdf9770-365f-11e5-b208-50fa18c86ab4

You will need your AWS account credentials loaded (either ~/.aws/config, or
environment variables) for the 'aws' account to do this.
