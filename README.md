# HaaS - Hadoop as a Service

Installing a Hadoop cluster has never been so easy.

![Haas big cluster](http://i.imgur.com/RjdY089.png)

# How to use

## Install HaaS

```
gem install haas
```

## Configure your environment with your AWS account

Get your AWS key and secret.

Set the two environment variable ```AWS_KEY``` and ```AWS_SECRET```.

Accept the [Terms and Conditions for the instance image](http://aws.amazon.com/marketplace/pp?sku=eggbgx9svw4xhzs1omttdv29q).

## Launch

```
haas --launch
```

## Optional parameters

<table>
  <tr>
    <th>Option</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td>--nb-instances</td>
    <td>The number of instances you want to have in your cluster.</td>
    <td>5</td>
  </tr>
  <tr>
    <td>--instance-type</td>
    <td>The EC2 instance type.</td>
    <td>m3.large</td>
  </tr>
  <tr>
    <td>--aws-region</td>
    <td>The AWS region to launch the instances.</td>
    <td>us-east-1</td>
  </tr>
</table>

## Strop the cluster

```
haas --terminate
```

# Known issues and limitations

## Cloud Provider

HaaS is working only with AWS. If you need another cloud provider create an issue about it.

## AWS Limitations

### EC2 Limits

By default, you can launch only 20 instances per region on AWS.
This tool will check if you have enough instances available before launching a cluster.
If you need mode, you can [increase your EC2 limit here](https://aws.amazon.com/support/createCase?serviceLimitIncreaseType=ec2-instances&type=service_limit_increase).

### Linux distribution

For cost saving reasons, this tool is using the official CentOS 6.5 image rather than the RedHat or the Suse.
The CentOS instances are not adding licences fee and are free to use (at the price af a classic Linux EC2).
To use this instance, you only have to [accept the Terms and Conditions here](http://aws.amazon.com/marketplace/pp?sku=eggbgx9svw4xhzs1omttdv29q).

## Hadoop distribution

Only the HortonWorks distribution is currently supported.
If you want to have another distribution supported, feel free to submit a pull request or an issue.

Contributing
------------

If you wish to contribute on this cookbook:

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Author: [Julien Pellet](https://twitter.com/julienpellet)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.