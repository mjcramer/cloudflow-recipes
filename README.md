# Cloudflow Installation Notes


For deploying cloud services, whenever I’m creating infrastructure, I like everything that I do be codified and versioned, and for this I like to use terraform. As I step through the setup process, I can interatively create and manage my resources, and at any point I can completely trash whatever I’m doing and start over at no cost, because since everything I’ve done is codified, I merely just need to redeploy the configuration to get back to where I was before.


# Cloudflow Infrastructure


A Terraform installer would be beneficial to be used with some integration testing and performance testing.
A description of initial experience in getting deployed would also be helpful

## Recipes

1. Clearing Topic Data / Reset

  In this scenario we clear out the data in a Kafka topic so that the application can be reset.

1. Topic Data Loss Recovery

  In this scenario we have data loss occur in one of our Kafka topics. This occurs in one of two ways:
  1. Some records are lost due to a network partition 
  1. A topic partition is lost because a broker hosting that partition goes down and there is isn't sufficient replication in place to change partitions.

1. Schema Transition

  We have deployed an application flow and it is running successfully. At some point we decide to add an additional field to one of the input data structures and redeploy the application, assuming some default value for old data structures that do not have this field present.
  
1. Lagom Service Integration

Is this something that would be useful?



## Step by Step Process

1. Write down use case from existing sample app and deploy it. Go over pain points…

2. Come up with a justification for modifying schema, like adding extra outlet for logging or debugging purposes… Make sure that data is in topics as if it was in production for a while. When legacy data matter AND you need to make changes to schema
	1. Avro backward compatible schema, reinterpreting as new schema that has default for fresh field. Changes will be checked by blueprint
	2. What happens if you only change the consumer with compatible change
	3. Blueprint schema should be able to extract schema rom source code and determine if they are compatible
Integration test that switches between different stages of the transition and ensures that it transitions smoothly.


## Possible deliverables
* FAQ from lessons learned
* Handwritten guide of experience
* Code -  deliverable integration tests


## Tools for capturing experience
	* Loom - record screen - upload to cloud
- 